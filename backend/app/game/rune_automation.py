"""Rune automation (V): auto-upgrade and auto-equip, with the tools around them.

- Auto-upgrade: runes go up to a target level within a Mana budget; a rune whose potential falls
  below a minimum rank after a proc is stopped there (no Mana wasted on a bad rune). One Mana burn
  per rune (all its levels), not per level.
- Auto-equip: the best runes for each monster by a profile (`rune_auto.choose`), free runes only
  or also those of other monsters; a request for a team equips the monsters in order, a monster
  never takes the runes given to one before it.
- Auto-grind: one grind per chosen base stat (e.g. speed) of the chosen runes, taken from the
  stock of that rune set (the named rarity, else the cheapest one that can still improve the
  stat), within `max_grinds`. The preview shows the exact plan; the real run can carry
  `expect_grinds` (the human check: it refuses when the plan changed since the player looked).
- Around them: a preview (`dry_run`), an undo (snapshot of what the monsters wore), a log, and the
  player's own profiles.
"""

import random
from datetime import datetime
from typing import Any

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.db.models import (
    GameMonster,
    GameRune,
    GameRuneLog,
    GameRuneProfile,
    GameRuneSnapshot,
    User,
)
from app.game import materials
from app.game.content import Content
from app.game.errors import GameError
from app.game.monsters import get_owned_many
from app.game.operator import GameOperator
from app.game.rune_auto import Profile, choose, load_profiles, profile_for_role
from app.game.rune_service import _store, equip, rune_view, to_rune, unequip
from app.game.runes import (
    RANKS,
    Rune,
    RuneRules,
    apply_runes,
    estimate,
    material_range,
    reinforce,
    upgrade,
)
from app.game.service import TOKEN_UNIT, spend_mana
from app.game.stats import compute_stats

SNAPSHOTS_KEPT = 10
RANK_FLOORS = {label: floor for floor, label in RANKS} | {"D": 0}
MAX_RUNES = 200  # runes per auto-upgrade request
MAX_GRINDS = 500  # grindstones per auto-grind request


def _log(
    session: Session, user: User, kind: str, details: dict[str, Any], mana: int, now: datetime
) -> None:
    session.add(GameRuneLog(user_id=user.id, kind=kind, details=details, mana=mana, created_at=now))


# ------------------------------------------------------------------ auto-upgrade


def _upgrade_candidates(
    session: Session, user: User, rules: RuneRules, rune_ids: list[int]
) -> list[GameRune]:
    """The runes to upgrade (the equipped ones if none are named), locked, best first."""
    query = select(GameRune).where(GameRune.user_id == user.id)
    query = (
        query.where(GameRune.id.in_(rune_ids))
        if rune_ids
        else query.where(GameRune.monster_id.is_not(None))
    )
    # Locked: two auto-upgrades (or a manual upgrade) at once must not pay twice for one rune.
    rows = list(session.scalars(query.order_by(GameRune.id).limit(MAX_RUNES).with_for_update()))
    if rune_ids and len(rows) != len(set(rune_ids)):
        raise GameError("rune_not_found", 404)
    # Equipped runes first, then the most promising ones.
    rows.sort(key=lambda r: (r.monster_id is None, -estimate(rules, to_rune(r)).potential, r.id))
    return rows


def _missing_funds(operator: GameOperator, user: User, cost: int) -> str | None:
    """The error code when the player cannot pay `cost` Mana now, else None."""
    if operator.mana_balance(user.address) < cost * TOKEN_UNIT:
        return "not_enough_mana"
    if operator.mana_allowance(user.address) < cost * TOKEN_UNIT:
        return "allowance_too_low"
    return None


def _roll_upgrades(
    rules: RuneRules, rune: Rune, target_level: int, floor: int
) -> tuple[int, list[dict[str, Any]], str | None]:
    """Level the rune up to the target (procs rolled), stopping when its potential falls under
    `floor`; returns (Mana paid, procs, the reason it stopped early or None)."""
    paid, procs, stop = 0, [], None
    rng = random.SystemRandom()
    while rune.level < target_level:
        paid += rules.upgrade_cost_mana[rune.level]
        proc = upgrade(rules, rune, rng)
        if proc is not None:
            procs.append({"kind": proc.kind, "stat": proc.stat, "amount": proc.amount})
            if estimate(rules, rune).potential < floor:
                stop = "below_rank"
                break
    return paid, procs, stop


def _log_upgrade(
    session: Session,
    user: User,
    log_row: GameRuneLog | None,
    results: list[dict[str, Any]],
    spent: int,
    target_level: int,
    now: datetime,
) -> GameRuneLog:
    """Keep the log up to date with each rune paid, in the same commit, so a later failure never
    leaves Mana spent without its log line."""
    summary = [
        {k: r[k] for k in ("rune_id", "from", "to", "cost", "stopped")}
        for r in results
        if "rune" in r
    ]
    if log_row is None:
        log_row = GameRuneLog(user_id=user.id, kind="upgrade", created_at=now)
        session.add(log_row)
    log_row.details = {"runes": summary, "target": target_level}
    log_row.mana = spent
    return log_row


def auto_upgrade(
    session: Session,
    user: User,
    operator: GameOperator,
    rules: RuneRules,
    rune_ids: list[int],
    target_level: int,
    budget_mana: int,
    min_rank: str,
    dry_run: bool,
    now: datetime,
) -> dict[str, Any]:
    """Upgrade these runes (all the equipped ones if none) up to `target_level`.

    The preview gives the exact cost to the target (levels cost a known amount); for real, a rune
    may stop earlier when a proc leaves its potential below `min_rank`.
    """
    if not 1 <= target_level <= rules.max_level:
        raise GameError("invalid_target_level", 400)
    if min_rank not in RANK_FLOORS:
        raise GameError("invalid_rank", 400)
    rows = _upgrade_candidates(session, user, rules, rune_ids)
    floor = RANK_FLOORS[min_rank]
    spent = 0
    results: list[dict[str, Any]] = []
    stopped_budget = False
    log_row: GameRuneLog | None = None
    for row in rows:
        rune = to_rune(row)
        if rune.level >= target_level:
            continue
        cost = sum(rules.upgrade_cost_mana[level] for level in range(rune.level, target_level))
        if spent + cost > budget_mana:
            stopped_budget = True
            results.append({"rune_id": row.id, "skipped": "budget", "cost": cost})
            continue
        if dry_run:
            spent += cost
            results.append(
                {"rune_id": row.id, "from": rune.level, "to": target_level, "cost": cost}
            )
            continue
        short = _missing_funds(operator, user, cost)
        if short is not None:
            if not any("to" in r for r in results):
                raise GameError(short)
            results.append({"rune_id": row.id, "skipped": short, "cost": cost})
            break  # the runes done so far are kept
        start = rune.level
        paid, procs, stop = _roll_upgrades(rules, rune, target_level, floor)
        spend_mana(operator, user.address, paid)
        _store(row, rune)
        spent += paid
        results.append(
            {
                "rune_id": row.id,
                "from": start,
                "to": rune.level,
                "cost": paid,
                "procs": procs,
                "stopped": stop,
                "rune": rune_view(row, rules),
            }
        )
        log_row = _log_upgrade(session, user, log_row, results, spent, target_level, now)
        session.flush()
        session.commit()  # each rune is paid and kept on its own (a later failure undoes nothing)
    return {
        "dry_run": dry_run,
        "target_level": target_level,
        "mana": spent,
        "runes": results,
        "budget_reached": stopped_budget,
    }


# ------------------------------------------------------------------ auto-grind


def _grind_plan(
    session: Session,
    user: User,
    rules: RuneRules,
    rows: list[GameRune],
    stats: set[str],
    max_grinds: int,
    rarity: str | None,
) -> list[tuple[GameRune, list[tuple[int, str]]]]:
    """For each rune, the (substat index, rarity) grinds to spend, within the stock of its set and
    `max_grinds` in all. One grind per stat: grinds keep the better roll, so a stat already at the
    top of a rarity's range is skipped for that rarity. Pure planning: nothing is spent."""
    held = materials.stock(session, user, "grind")
    left = max_grinds
    plan: list[tuple[GameRune, list[tuple[int, str]]]] = []
    for row in rows:
        rune = to_rune(row)
        picks: list[tuple[int, str]] = []
        for index, sub in enumerate(rune.substats):
            if left <= 0:
                break
            if sub.stat not in stats or not rules.stats[sub.stat].reinforceable:
                continue
            for candidate in [rarity] if rarity else list(rules.rarity_order):
                key = ("grind", rune.set_id, candidate)
                top = material_range(rules, "grind", sub.stat, rune.stars, candidate)[1]
                if held.get(key, 0) > 0 and sub.grind < top:
                    picks.append((index, candidate))
                    held[key] -= 1
                    left -= 1
                    break
        if picks:
            plan.append((row, picks))
    return plan


def auto_grind(
    session: Session,
    user: User,
    operator: GameOperator,
    rules: RuneRules,
    rune_ids: list[int],
    stats: list[str],
    max_grinds: int,
    expect_grinds: int | None,
    dry_run: bool,
    now: datetime,
    rarity: str | None = None,
) -> dict[str, Any]:
    """Grind the chosen base stats of these runes (the equipped ones if none), once each."""
    unknown = [s for s in stats if s not in rules.stats or not rules.stats[s].reinforceable]
    if not stats or unknown:
        raise GameError("invalid_stat", 400)
    if not 1 <= max_grinds <= MAX_GRINDS:
        raise GameError("invalid_max_grinds", 400)
    if rarity is not None and rarity not in rules.rarities:
        raise GameError("invalid_rarity", 400)
    rows = _upgrade_candidates(session, user, rules, rune_ids)
    plan = _grind_plan(session, user, rules, rows, set(stats), max_grinds, rarity)
    total = sum(len(picks) for _, picks in plan)
    mana = total * rules.reinforce_cost_mana
    preview = [
      
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  Qd}˜¶k4É¨Âåÿ×á‘Ô¬ÖÏöl?(KîQGÂ_^