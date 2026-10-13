"""The game's numbers as spreadsheet tables (V: "MCP connectors for a future Excel, monster and
rune stats and so on").

Every table is flat (one header row, one value per cell, no nested cell) so that Excel, LibreOffice
or Google Sheets open the CSV as is, and a pivot table or a formula works on it. The tables are
built from the content files the game really reads, so the sheet never drifts from the game.

Read only. `validate` takes a table edited in a spreadsheet (CSV text) and says what would change
and what is wrong, but never writes anything: a real change goes through the content files, a pull
request and V's review (`NORME.md` Â§2). The MCP server `seed-data` (`app/mcp_data_server.py`) and
`make sheets-export` use this module.
"""

import csv
import io
import json
from collections.abc import Callable
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from app.game import levels, shop
from app.game.achievements import load_achievements
from app.game.calendar import load_calendar, milestones
from app.game.content import STATS, Content, load_content
from app.game.runes import load_rune_rules
from app.game.stats import LEVELS_PER_STAR, MAX_STARS, compute_stats, max_level

Cell = str | int | float | bool | None


@dataclass(frozen=True)
class Table:
    name: str
    description: str
    columns: tuple[str, ...]
    rows: tuple[tuple[Cell, ...], ...]
    key: tuple[str, ...] = ()  # the columns that identify a row (for `validate`)

    def records(self) -> list[dict[str, Cell]]:
        return [dict(zip(self.columns, row, strict=True)) for row in self.rows]


class SheetError(ValueError):
    """A request the sheet tools cannot answer (unknown table, bad filter...)."""


def _json(value: Any) -> str:
    """A nested value in one cell: compact JSON, readable and parsable."""
    return json.dumps(value, ensure_ascii=False, separators=(",", ":"), sort_keys=True)


# ------------------------------------------------------------------------ the tables


def _species(content: Content) -> Table:
    columns = (
        "id", "name", "family", "element", "stars", "role", "grey", "summonable", "secret",
        *STATS, "awaken_name", "awaken_bonus", "leader_stat", "leader_amount", "leader_scope",
        "leader_where",
        "skills",
    )  # fmt: skip
    rows = []
    for s in sorted(content.species.values(), key=lambda s: s.id):
        leader = s.leader
        rows.append(
            (
                s.id, s.name, s.family, s.element, s.stars, s.role, s.grey, s.summonable, s.secret,
                *(s.max[stat] for stat in STATS),
                s.awaken_name, _json(s.awaken_bonus) if s.awaken_bonus else "",
                leader.stat if leader else "", leader.amount if leader else "",
                leader.scope if leader else "", leader.where if leader else "", len(s.skills),
            )
        )  # fmt: skip
    return Table(
        "species",
        "Every monster: its stats at 6 stars, max level, awakened, awakening and leader skill.",
        columns,
        tuple(rows),
        key=("id",),
    )


def _skills(content: Content) -> Table:
    columns = (
        "species_id", "skill_id", "name", "multiplier", "cooldown", "target", "heal",
        "stun_chance", "scales_with", "effects",
    )  # fmt: skip
    rows = [
        (
            sp.id, k.id, k.name, k.multiplier, k.cooldown, k.target, k.heal, k.stun_chance,
            k.scales_with, _json([vars(e) for e in k.effects]) if k.effects else "",
        )
        for sp in sorted(content.species.values(), key=lambda s: s.id)
        for k in sp.skills
    ]  # fmt: skip
    return Table("skills", "The skills of every monster.", columns, tuple(rows), key=("skill_id",))


def _stat_curve(content: Content) -> Table:
    """Level by level, what `compute_stats` gives: the formula as numbers, to check an Excel one."""
    columns = ("species_id", "stars", "awakened", "level", *STATS)
    rows: list[tuple[Cell, ...]] = []
    for sp in sorted(content.species.values(), key=lambda s: s.id):
        if sp.secret:
            continue
        for awakened in (False, True):
            cap = max_level(sp.stars, awakened)
            for level in sorted({1, *range(10, cap, 10), cap}):
                stats = compute_stats(sp, level, sp.stars, awakened)
                rows.append((sp.id, sp.stars, awakened, level, *(stats[s] for s in STATS)))
    return Table(
        "stat_curve",
        "Stats of each monster at its natural stars, every 10 levels and at the cap, unawakened "
        "and awakened (use the tool monster_stats for any level or evolved stars).",
        columns,
        tuple(rows),
        key=("species_id", "awakened", "level"),
    )


def _rune_stats() -> Table:
    rules = load_rune_rules()
    columns = (
        "stat", "label", "category", "main_max", "main_max_7", "sub_min", "sub_max",
        "grind_min", "grind_max", "gem_min", "gem_max",
    )  # fmt: skip
    rows = [
        (
            k,
            s.label,
            s.category,
            s.main_max,
            s.main_max_7,
            s.sub[0],
            s.sub[1],
            s.grind[0] if s.grind else None,
            s.grind[1] if s.grind else None,
            s.gem[0],
            s.gem[1],
        )
        for k, s in rules.stats.items()
    ]
    return Table(
        "rune_stats",
        "Rune stats at 6 stars: main stat at +25 (6 and 7 stars), substat roll range (first "
        "roll and procs), and the top-rarity range of a grind and of a gem (each rarity below "
        "shrinks both ends). Other stars: multiply by rune_star_factor.",
        columns,
        tuple(rows),
        key=("stat",),
    )


def _rune_sets() -> Table:
    rules = load_rune_rules()
    rows = [
        (s.id, s.name, s.pieces, s.scope, _json(s.bonus))
        for s in sorted(rules.sets.values(), key=lambda s: s.id)
    ]
    return Table(
        "rune_sets",
        "Rune sets: pieces needed, who gets the bonus, the bonus.",
        ("id", "name", "pieces", "scope", "bonus"),
        tuple(rows),
        key=("id",),
    )


def _rune_star_factor() -> Table:
    rules = load_rune_rules()
    rows = [(stars, factor) for stars, factor in sorted(rules.star_factor.items())]
    return Table(
        "rune_star_factor",
        "Multiplier of every rune value by the rune's stars (1.0 at 6 stars).",
        ("stars", "factor"),
        tuple(rows),
        key=("stars",),
    )


def _rune_rarities() -> Table:
    rules = load_rune_rules()
    rows = [(r.id, r.label, r.substats, r.base_procs) for r in rules.rarities.values()]
    return Table(
        "rune_rarities",
        "Rune rarities, the substats each one starts with and the procs it already carries.",
        ("id", "label", "substats", "base_procs"),
        tuple(rows),
        key=("id",),
    )


def _rune_slots() -> Table:
    rules = load_rune_rules()
    rows = [(slot, ",".join(mains)) for slot, mains in sorted(rules.slots.items())]
    return Table(
        "rune_slots",
        "The main stats each of the 7 slots may roll (empty: fixed by the slot).",
        ("slot", "main_stats"),
        tuple(rows),
        key=("slot",),
    )


def _stages(content: Content) -> Table:
    columns = (
        "id", "name", "kind", "group", "index", "difficulty", "element", "requires", "energy",
        "reward_mana", "xp", "team_size", "waves", "enemies", "boss_level",
    )  # fmt: skip
    rows = []
    for s in content.stages.values():
        enemies = [e for wave in s.waves for e in wave]
        rows.append(
            (
                s.id, s.name, s.kind, s.group, s.index, s.difficulty, s.element or "",
                s.requires or "", s.energy, s.reward_mana, s.xp, s.team_size, len(s.waves),
                len(enemies), max((e.level for e in enemies if e.boss), default=None),
            )
        )  # fmt: skip
    return Table(
        "stages",
        "Scenario, dungeons and tower: energy, rewards, team size, waves.",
        columns,
        tuple(rows),
        key=("id",),
    )


def _summon_pools(content: Content) -> Table:
    rows = []
    for pool in content.summon_pools.values():
        scroll = next((i.id for i in content.items.values() if i.pool == pool.id), "")
        total = sum(w for lane in pool.lanes for w in lane.star_weights.values())
        for n, lane in enumerate(pool.lanes, start=1):
            for stars, weight in sorted(lane.star_weights.items()):
                rows.append(
                    (pool.id, pool.name, scroll, pool.cost_mana, n, ",".join(lane.elements),
                     stars, weight, round(100 * weight / total, 4))
                )  # fmt: skip
    return Table(
        "summon_pools",
        "Summon pools: scroll and Mana cost per summon (V: both), then the weight (per 10,000) of "
        "each star grade in each lane.",
        ("pool", "name", "scroll", "cost_mana", "lane", "elements", "stars", "weight", "percent"),
        tuple(rows),
        key=("pool", "lane", "stars"),
    )


def _items(content: Content) -> Table:
    rows = [
        (i.id, i.name, i.kind, i.element, i.pool, i.set, i.category, i.tier)
        for i in sorted(content.items.values(), key=lambda i: i.id)
    ]
    return Table(
        "items",
        "Inventory items: scrolls, essences, grindstones, gems, chests, materials.",
        ("id", "name", "kind", "element", "pool", "set", "category", "tier"),
        tuple(rows),
        key=("id",),
    )


def _achievements() -> Table:
    rows = [(a.id, a.name, a.kind, _json(a.target), a.points, a.tier) for a in load_achievements()]
    return Table(
        "achievements",
        "Achievements engraved on chain: what to do, points and tier.",
        ("id", "name", "kind", "target", "points", "tier"),
        tuple(rows),
        key=("id",),
    )


def _levels() -> Table:
    rows = []
    for name, track in load_tracks().items():
        for source, xp in sorted(track.xp.items()):
            rows.append((name, track.max, track.a, track.b, track.total_for(track.max), source, xp))
    return Table(
        "levels",
        "Account, social and guild levels: XP to reach L is a*(L-1)^2 + b*(L-1); XP per action.",
        ("track", "max_level", "curve_a", "curve_b", "xp_to_max", "xp_source", "xp_amount"),
        tuple(rows),
        key=("track", "xp_source"),
    )


def load_tracks() -> dict[str, Any]:
    return levels.load_tracks()


def _calendar() -> Table:
    _, days = load_calendar()
    rows: list[tuple[Cell, ...]] = [(str(i + 1), _json(r)) for i, r in enumerate(days)]
    rows += [(f"total {m['days']}", _json(m["rewards"])) for m in milestones()]
    return Table(
        "calendar",
        "The login calendar: day 1 to 28 of a cycle, then the one-off milestones on total days.",
        ("day", "rewards"),
        tuple(rows),
        key=("day",),
    )


def _chests() -> Table:
    rows = []
    for chest_id, chest in shop.load_chests().items():
        total = sum(line["weight"] for line in chest["loot"])
        for line in chest["loot"]:
            reward = {k: v for k, v in line.items() if k != "weight"}
            rows.append(
                (chest_id, chest["rolls"], line["weight"], round(100 * line["weight"] / total, 2),
                 _json(reward))
            )  # fmt: skip
    return Table(
        "chests",
        "Chest loot tables: rolls per chest, the weight of each line, what it gives (min, max).",
        ("chest", "rolls", "weight", "percent", "reward"),
        tuple(rows),
        key=("chest", "reward"),
    )


def _team_sizes(content: Content) -> Table:
    sizes = content.team_sizes
    rows: list[tuple[Cell, ...]] = [
        ("default", sizes.default),
        ("pvp", sizes.pvp),
        ("min", sizes.min),
        ("max", sizes.max),
    ]
    rows += [
        (f"rule {_json({k: v for k, v in r.items() if k != 'size'})}", r["size"])
        for r in sizes.rules
    ]
    rows += [(f"stage {k}", v) for k, v in sorted(sizes.special_stages.items())]
    return Table(
        "team_sizes",
        "How many monsters may fight: 4 by default, 5 in the great dungeons, 3 special.",
        ("rule", "size"),
        tuple(rows),
        key=("rule",),
    )


def _contribution_kinds() -> Table:
    from app.game.contribution_rewards import load_rules

    rows = [(k["id"], k["label"], k["base"], k["area"]) for k in load_rules().kinds.values()]
    return Table(
        "contribution_kinds",
        "What a contribution is: the base POC of each kind of work and its area.",
        ("kind", "label", "base_poc", "area"),
        tuple(rows),
        key=("kind",),
    )


def _contribution_factors() -> Table:
    raw = json.loads(
        (Path(__file__).parent / "content" / "contribution_rules.json").read_text(encoding="utf-8")
    )
    rows = [
        (name, r["level"], r["multiplier"], r["meaning"])
        for name, levels_ in raw["factors"].items()
        for r in levels_
    ]
    return Table(
        "contribution_factors",
        "The contribution multipliers: size, impact, quality, audience, area, contributor.",
        ("factor", "level", "multiplier", "meaning"),
        tuple(rows),
        key=("factor", "level"),
    )


def _contribution_limits() -> Table:
    from app.game.contribution_rewards import load_rules

    rules = load_rules()
    rows: list[tuple[Cell, ...]] = [(k, str(v)) for k, v in rules.limits.items()]
    rows += [("scarcity_trigger", str(rules.trigger)), ("scarcity_floor", str(rules.floor))]
    rows += [(f"currency_{c['id']}_per_poc", str(c["per_poc"])) for c in rules.currencies.values()]
    rows += [
        (f"currency_{c['id']}_enabled", "yes" if c["enabled"] else "no")
        for c in rules.currencies.values()
    ]
    return Table(
        "contribution_limits",
        "Caps, period, scarcity adjustment and the currencies a contribution can be paid in.",
        ("setting", "value"),
        tuple(rows),
        key=("setting",),
    )


_BUILDERS: dict[str, Callable[[Content], Table]] = {
    "species": _species,
    "skills": _skills,
    "stat_curve": _stat_curve,
    "rune_stats": lambda _c: _rune_stats(),
    "rune_sets": lambda _c: _rune_sets(),
    "rune_star_factor": lambda _c: _rune_star_factor(),
    "rune_rarities": lambda _c: _rune_rarities(),
    "rune_slots": lambda _c: _rune_slots(),
    "stages": _stages,
    "summon_pools": _summon_pools,
    "items": _items,
    "achievements": lambda _c: _achievements(),
    "levels": lambda _c: _levels(),
    "calendar": lambda _c: _calendar(),
    "chests": lambda _c: _chests(),
    "team_sizes": _team_sizes,
    "contribution_kinds": lambda _c: _contribution_kinds(),
    "contribution_factors": lambda _c: _contribution_factors(),
    "contribution_limits": lambda _c: _contribution_limits(),
}


def table_names() -> list[str]:
    return list(_BUILDERS)


def build(name: str, content: Content | None = None) -> Table:
    builder = _BUILDERS.get(name)
    if builder is None:
        raise SheetError(f"unknown table {name!r}; known tables: {', '.j
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  uévã{¤™¿´“ÇâÜø¬S.~’zÎh
j–úÈïhg