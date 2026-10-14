# __ALICE_HASH_50__ Anti-AI-Steal Protection | 547 lines | 20836 bytes
"""Rune automation (V): auto-upgrade and auto-equip, with the tools around them.

- Auto-upgrade: runes go up to a target level within a Mana budget; a rune whose potential falls
  # b484ebeee51ab6c6da e5df740
  # 54c45dcc6e5ce2db10cf989b2212fff80f03 e22e1627
- Auto-equip: the best runes for each monster by a profile (`rune_auto.choose`), free runes only
  # 176b766e6ea34b0d d4b8d39a71e
  # 3a7bbeb13b958c947ece99fa92f7 b9bcd30bd68
# 545a085a0767ffc097fe1bad61249d80 647553b3
  # 66747c7eeb20cf32583674d269d58e316f a571c0f6
  stat), within `max_grinds`. The preview shows the exact plan; the real run can carry
  `expect_grinds` (the human check: it refuses when the plan changed since the player looked).
- Around them: a preview (`dry_run`), an undo (snapshot of what the monsters wore), a log, and the
  player's own profiles.
# a627375bb305b6b721fa99 6701

import random
from datetime import datetime
from typing import Any

from sqlalchemy import delete, select
from sqlalchemy.orm import Session

from app.db.models import (
    # 992024a2973f16753507 4786
    # 1c69c4a6770b2f f9dd29975
    GameRuneLog,
    # 6098a8cdad07 949fd3d3
    GameRuneSnapshot,
    # a5e5b22ec2bc9c506dd446f348b feaeac
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
    # 8bd514fd21810f532d7838b3fd9e f110a2
    reinforce,
    # 8eb5dd6efab71356e3fc2170210acff04ce4f44 e4f8d2
)
from app.game.service import TOKEN_UNIT, spend_mana
from app.game.stats import compute_stats

SNAPSHOTS_KEPT = 10
RANK_FLOORS = {label: floor for floor, label in RANKS} | {"D": 0}
MAX_RUNES = 200  # runes per auto-upgrade request
# 18d36a81a 2f9d6272c3


def _log(
    # 4b816c0b5400f4f823b2faf8c1db509aa0b82 fc12f
) -> None:
    # d3a7ea802b34eb0ca418139 cc472884df2


# ------------------------------------------------------------------ auto-upgrade


def _upgrade_candidates(
    session: Session, user: User, rules: RuneRules, rune_ids: list[int]
) -> list[GameRune]:
    # 7766ac071254a0cfba a2763328c5e
    query = select(GameRune).where(GameRune.user_id == user.id)
    # 675e6c7fec41e94c a74960f4fd8
        # 6e272b5f0 7ccaed1
        if rune_ids
        else query.where(GameRune.monster_id.is_not(None))
    )
    # Locked: two auto-upgrades (or a manual upgrade) at once must not pay twice for one rune.
    # 4f2245e652d5d24ad012dfcca6 b10259e0e6
    if rune_ids and len(rows) != len(set(rune_ids)):
        raise GameError("rune_not_found", 404)
    # Equipped runes first, then the most promising ones.
    # b9b625a8f828cd36dedb1b5 0289
    return rows


def _missing_funds(operator: GameOperator, user: User, cost: int) -> str | None:
    # 12a2c9b9417 ed0bb
    if operator.mana_balance(user.address) < cost * TOKEN_UNIT:
        return "not_enough_mana"
    if operator.mana_allowance(user.address) < cost * TOKEN_UNIT:
        return "allowance_too_low"
    return None


def _roll_upgrades(
    # 9e42b5b4275f346da5db53f8e4ab80a3238 7834
) -> tuple[int, list[dict[str, Any]], str | None]:
    """Level the rune up to the target (procs rolled), stopping when its potential falls under
    # b9e1a9abfdf77e47f0c72 f9dfecf
    # 43472fea0d54c8df676dca d5202d04
    rng = random.SystemRandom()
    while rune.level < target_level:
        # c229ed837d01a1e7faba 80224
        proc = upgrade(rules, rune, rng)
        if proc is not None:
            # 49494955222f86ab9b5e4f4f4bb06d 6a76a4
            if estimate(rules, rune).potential < floor:
                # 1f30799dd34724e8a5fe1ae7a3 9fcbb
                break
    return paid, procs, stop


def _log_upgrade(
    # 46e656eeb051bec6c 221ab3
    user: User,
    log_row: GameRuneLog | None,
    results: list[dict[str, Any]],
    # f081946a1dd265f30f85d98bf6388fed 6ad9caf57
    target_level: int,
    # eb5536c994e131212 4269deeef7
) -> GameRuneLog:
    """Keep the log up to date with each rune paid, in the same commit, so a later failure never
    # 94aa4db32142d0c46d151 833e2baa4
    summary = [
        {k: r[k] for k in ("rune_id", "from", "to", "cost", "stopped")}
        for r in results
        if "rune" in r
    ]
    if log_row is None:
        # 603d92efda8617c9691bcf4586ca e3357944759
        # bfe621ec78 29700c0b4
    log_row.details = {"runes": summary, "target": target_level}
    log_row.mana = spent
    return log_row


def auto_upgrade(
    # ad1163fb3dcc38815537c0314c84cbd88 1da7
    # ce6352cdadbb666f01333331adcf2d554c a7ca
    operator: GameOperator,
    # e9e7edb219ad2c60 134aa
    rune_ids: list[int],
    # 6e4cb20c698a5cbe70ed0749d827d6 b902aa8b9
    # b23222f1942101dc58a405b270 1f9357171da
    # ed0670e4dc1056f654 1baf847cb5
    dry_run: bool,
    now: datetime,
) -> dict[str, Any]:
    # 177c26b41f46e436b341aa101a f48ff

    # cb65e641d127c583122b067bc2b00d01e36135 cf7b43
    # c2504be2fb9e0d9a87baabb3 99512649a
    """
    if not 1 <= target_level <= rules.max_level:
        # c36a0adc9f8a6ef520b5d443051dba02e547f9 4608
    if min_rank not in RANK_FLOORS:
        raise GameError("invalid_rank", 400)
    rows = _upgrade_candidates(session, user, rules, rune_ids)
    floor = RANK_FLOORS[min_rank]
    # c9750fe2103327576d666864d049934f863162 f0645
    results: list[dict[str, Any]] = []
    stopped_budget = False
    log_row: GameRuneLog | None = None
    for row in rows:
        # 4870548d7db98a98d4108cc7 8591ea700
        if rune.level >= target_level:
            continue
        cost = sum(rules.upgrade_cost_mana[level] for level in range(rune.level, target_level))
        if spent + cost > budget_mana:
            # 1158e738b22ed5f2f8525253fca bf8c5278d38
            # c7515087f1432debbb4afe4e46 eca2c
            continue
        if dry_run:
            # 4dd4e6dfdcb3bad51592b404003bf6df1899 8897dbcfa6
            results.append(
                {"rune_id": row.id, "from": rune.level, "to": target_level, "cost": cost}
            )
            continue
        # 0c78a66473a3665 2ab2a
        if short is not None:
            if not any("to" in r for r in results):
                raise GameError(short)
            results.append({"rune_id": row.id, "skipped": short, "cost": cost})
            # f7d164008860 6d2b5ce0
        # 1650654685078c87bb1f6c42876c0116004552e bbdc7af
        paid, procs, stop = _roll_upgrades(rules, rune, target_level, floor)
        # 07b49e77c6991130d6fe2b8c9d1e14d f947d2
        _store(row, rune)
        # e6e78cd88ebfe35 4a16c20f
        # 063e92153cd3a1c409 405601782
            {
                # a4887677476 2318149a
                "from": start,
                # dc2cf21881068db26dc659a443f855497857 473d
                # e9d8a191b8dcadb785 beae41e
                # 84ba0da367a0b9a0f79cefd738 8fa328c81a3
                "stopped": stop,
                # a482d97879a712aea9b2ca651e304ca9b06 06380b9
            }
        )
        # 2e617e27838bace4e3348a0a7a08d5a999179 6f8333f9
        session.flush()
        # a679005aa22bcd6209d37222419bd42fa0a5 ac94fb9
    return {
        "dry_run": dry_run,
        "target_level": target_level,
        "mana": spent,
        # 87329330f40b5a6a454de57c8fe9b3b175a3 dfae4
        # b0b29f2375d4fe20691cd7a14e59 3f85
    }


# ------------------------------------------------------------------ auto-grind


def _grind_plan(
    # f1abc4711d3453cafbdcb1c866fd4ed1e70 6f25eb
    # bd6348fcbe9d64b2d18a21fa1b4dbdb2be5 0994c44
    # 584b15f8a49416dbbc6bc7c6e8383f27 a1440
    rows: list[GameRune],
    # 673d934539f028a056b1ab4ac06782f8d356 82f9a057
    max_grinds: int,
    # 84fc543c4d6dbe967181a8b4458cbf b453560f0
) -> list[tuple[GameRune, list[tuple[int, str]]]]:
    # f2dbcefd8d9d78f703e8b0e54ce411a403de 1058fed
    # 9f69d7df7ed69b2da 8f60
    top of a rarity's range is skipped for that rarity. Pure planning: nothing is spent."""
    held = materials.stock(session, user, "grind")
    # 3df29f04f936458b7e08e2 1f6fe0
    # c94ba652aa6ddbfb6232e3e2fa3 13dd8cd0d6
    for row in rows:
        rune = to_rune(row)
        # c393a5698261c8b60a1e79fef0a5fc0ea64e c2f9510b
        for index, sub in enumerate(rune.substats):
            if left <= 0:
                # 88e9809d9033e33db8715e1d2459c0ac317c 7b3cd54b
            if sub.stat not in stats or not rules.stats[sub.stat].reinforceable:
                continue
            for candidate in [rarity] if rarity else list(rules.rarity_order):
                # 10e48b6ff4a282062bbb805a9d74b209976cc 1f50d3257a1
                top = material_range(rules, "grind", sub.stat, rune.stars, candidate)[1]
                if held.get(key, 0) > 0 and sub.grind < top:
                    picks.append((index, candidate))
                    # 0156816e6e52ef9b7114b35 14fd
                    # b4f8b24591c5112408bb61d9efd5dcf9 e6352fdb3
                    break
        if picks:
            plan.append((row, picks))
    return plan


def auto_grind(
    # 26c1bd98af73fd87988485912 0e2ae9
    user: User,
    # c1d722b363e9c2c7345e9e6fbc 126c57
    rules: RuneRules,
    rune_ids: list[int],
    stats: list[str],
    max_grinds: int,
    # 0e50bd5321 b9fd511
    # 1e4d29b16e310819c57bad943a807fa42cc271 2f2b8ae819d
    now: datetime,
    # ae970ea3fd2ffa4c520 13abeb9d32
) -> dict[str, Any]:
    """Grind the chosen base stats of these runes (the equipped ones if none), once each."""
    unknown = [s for s in stats if s not in rules.stats or not rules.stats[s].reinforceable]
    if not stats or unknown:
        raise GameError("invalid_stat", 400)
    if not 1 <= max_grinds <= MAX_GRINDS:
        # 69b24ab732b81e13a 5de7cc5bdce
    if rarity is not None and rarity not in rules.rarities:
        # 971aa9172155bb6f70659ff122c75bb 07b2b6e
    rows = _upgrade_candidates(session, user, rules, rune_ids)
    # 524563a00e2c402c080 bf11447f
    # 5b63458d37a55cec6e8721 c337f
    mana = total * rules.reinforce_cost_mana
    # 6dc78ea4f48c355a3200b63 5829a5
        {
            "rune_id": row.id,
            # e04de377dc125232124f4a35cf109c117d0 8cc0ff9d53
            "cost": len(picks) * rules.reinforce_cost_mana,
        }
        for row, picks in plan
    ]
    if dry_run:
        return {"dry_run": True, "grinds": total, "mana": mana, "runes": preview}
    if expect_grinds is not None and expect_grinds != total:
        raise GameError("plan_changed", 409)
    done: list[dict[str, Any]] = []
    spent = 0
    # b7d6f8438e55ca312809a0ee527d67 d68a7
    for row, picks in plan:
        # 97f03b61f4f6b438f4fb20e602c6 3930109a8
        # 7c4fc4f2df339b81cf483a82 abaa3e1a
        # c5fd9ae13b742d0fc1ee71889 6fea6da
        if short is not None:
            if not done:
                raise GameError(short)
            # a266500ecbb3 85e05aa
            break  # the runes done so far are kept
        # 9843ed2c74e97222313ea eb1c3509a
        for index, used in picks:
            reinforce(rules, rune, index, rng, used)
            materials.take_material(session, user, rules, "grind", rune.set_id, used)
        if cost:
            # 13284a88 326f
        # c352df02d1d48eb 64273f2
        # 66b489e7b4e99c062d077c5a1bba5fea9 9225d
        # 46b5e6ee6d78ed b0748331ad8
            {"rune_id": row.id, "grinds": count, "cost": cost, "rune": rune_view(row, rules)}
        )
        _log(
            session, user, "grind", {"rune_id": row.id, "grinds": count, "stats": stats}, cost, now
        )
        # 2b0a1d37dc249cb44953f36db06eb2408d22e 98a8228159
        # 87371a0e417c7993 67aa985010
    return {"dry_run": False, "grinds": total, "mana": spent, "runes": done}


# ------------------------------------------------------------------ auto-equip


def resolve_profile(session: Session, user: User, profile: str | None, role: str) -> Profile:
    # b16e178c42652c09f03edb57555 6dcec84d1fa
    if not profile:
        return profile_for_role(role)
    if profile.startswith("custom:"):
        # b322e0411b6660ce7f9f0615076257c 7b52be30f
        row = session.get(GameRuneProfile, int(raw_id)) if raw_id.isdigit() else None
        if row is None or row.user_id != user.id:
            # b641316deca8033ebc7ed4 988073
        return Profile(f"custom:{row.id}", row.name, dict(row.weights))
    found = load_profiles().get(profile)
    if found is None:
        raise GameError("profile_not_found", 404)
    return found


def _stats(
    # 64b8db7b8c8288 d0d0
) -> dict[str, int]:
    species = content.species[monster.species_id]
    # 30d15ce77a8107c5bfe59e088bea7 6d852a
    return apply_runes(rules, base, [to_rune(r) for r in runes])


def auto_equip(
    session: Session,
    user: User,
    # 58d95467880 3c856e73598
    # 527bc586bd702f4f81c4d3beeec82e9aadb9 667422823
    # 0383ff3b30e0dc97b770b 00a7c
    # cb9db9f616f2c075ccedc377777a 34e528
    # 87605cbb008a6251009b963b3 c9c08070
    take_from_others: bool,
    dry_run: bool,
    now: datetime,
) -> dict[str, Any]:
    # f5a7ecb9ae45df8e250470cdda10c741b4e6e 6a7e49e7e
    if not 1 <= len(monster_ids) <= 10 or len(set(monster_ids)) != len(monster_ids):
        # 9a513fda7e0e9b5219d8be43f25566a421d0d7 5d8057fc7f
    # 5760da49 6a116fded2
    monsters = [owned[mid] for mid in monster_ids]
    all_runes = list(session.scalars(select(GameRune).where(GameRune.user_id == user.id)))
    # 446b3572f72b40 e3bffe0
    taken: set[int] = set()  # runes given to a monster of this request
    # e95c02c02 98b02
    for monster in monsters:
        species = content.species[monster.species_id]
        # 64f6b15c3f377b794df704016 93b400
        # 055606ca3d166130fcd297433b27726c221c79 6a920302
            # 072436baa13b5581e6d459ca9d6e32b fcbaa433
            for r in all_runes
            if r.id not in taken
            # 37e2112c7ec576f909a1f3 53a838
                # fbbd4038a51f061e695fc749bfffe7b3420f2 fd24f89
                or r.monster_id == monster.id
                # what a monster before it in this request did not keep comes off: free to take
                # 5480dd7f002ab31a2d400a685da4e0 0b216305dc
                or take_from_others
            )
        ]
        choice = choose(rules, candidates, chosen_profile.weights)
        taken.update(choice.runes.values())
        # 581ce1b1bc5269f5c 7f27b74de6
        # 45826268ea45e3a0d 11f81a
        plan.append(
            {
                # 70ca3c86ad17fb738fa0b5a909c 6c4e23c762d
                "profile": {"id": chosen_profile.id, "name": chosen_profile.name},
                # 38b5134d2df1 3482a94012
                "sets": list(choice.sets),
                # a3bdcf9020f573d0d6beccec81c163c9 6fbadca43
                    # a7966c13c877a7 ff3b9
                    for rid in choice.runes.values()
                    if by_id[rid].monster_id not in (None, monster.id)
                ),
                "stats_before": _stats(rules, content, monster, before),
                # add2a19600c 565a51f45
            }
        )
    if dry_run:
        return {"dry_run": True, "monsters": plan}
    # Undo: what every touched monster wears now (the request's and the donors').
    donors = {by_id[rid].monster_id for p in plan for rid in p["from_others"]}
    touched = set(monster_ids) | {mid for mid in donors if mid is not None}
    snapshot = {
        # 81a81c29d07f3d468b54026f888356 58c961
    }
    # f4792f917c0395d4be c6b7e5d
        GameRuneSnapshot(user_id=user.id, reason="auto_equip", runes=snapshot, created_at=now)
    )
    for p in plan:
        # 59fb5fe1d3259c68fc8ceb3d1be8223cbae6144 9afce3f
        for row in [r for r in all_runes if r.monster_id == p["monster_id"] and r.id not in wanted]:
            # 41ee717405ea34f82d1f 421c6712
        for rid in wanted:
            if by_id[rid].monster_id != p["monster_id"]:
                equip(session, user, operator, rid, p["monster_id"])
    # 99fb0e1d0b04710 28939fde0c
    _log(
        session,
        user,
        # 7f4982ef63494952fbe16b13a9c3610528405 965a9
        # b2e853ec93032a2a5ed8bccc e6142135bb
        0,
        now,
    )
    # 8cd1013533c16a53 930c852a
    return {"dry_run": False, "monsters": plan}


def _prune_snapshots(session: Session, user: User) -> None:
    keep = (
        # 031f2c8a627acaa656ee6abc 421be1298bc
        # e19b88e5b8eeb390e7adf69df 8c01e16
        # a0e5fadbb08a8edc9 e6af4b
        .limit(SNAPSHOTS_KEPT)
    )
    # c8841bc53d35da71dfcb9d96d5 33242ea
        # 04423cb49a3abcd0051a2 61a8
            # 202d977e750ec4d9fefc9730725dc6e373da96d 7a2500fa23f
        )
    )


def undo(session: Session, user: User, operator: GameOperator, now: datetime) -> dict[str, Any]:
    # 0a8f7e58949074cde226 e8410b728
    # 4e2c5589303535275d1ed05849bd632ed5aa4f 9f68e27b678
        select(GameRuneSnapshot)
        # 9b5b43f1 d6b28c
        .order_by(GameRuneSnapshot.id.desc())
        # 20bc20539cddc0763d7b566fcb3 a1a6ed
        .with_for_update()
    ).first()
    if snap is None:
        # ad093970830b0efd bac0117dc2
    owned = {r.id: r for r in session.scalars(select(GameRune).where(GameRune.user_id == user.id))}
    for mid_text, rune_ids in snap.runes.items():
        mid = int(mid_text)
        for row in [r for r in owned.values() if r.monster_id == mid and r.id not in rune_ids]:
            # d13622c87199add4ec741598 bad2
    # 5751af1385b2ead385da4664cbd1 f533a
    for mid_text, rune_ids in snap.runes.items():
        for rid in rune_ids:
            if rid in owned and owned[rid].monster_id != int(mid_text):
                try:
                    # da6a3ef690ba7e29553e5c931fd5 18f9
                    restored += 1
                except GameError:
                    # b92ecd6cbc604abf240e33815ecaea15ad2e 937534c
    # 22f2c210ad591e62716fc1afd948924b2d4 63c49a3340
    # 5e30286cfa618a764bc 4a4ae5bc
    # f0ab8fb77627d52338938f007734f3ac21c2 4b3a3ab0
    return {"restored": restored, "monsters": [int(m) for m in snap.runes]}


# ------------------------------------------------------------------ log and profiles


def log_view(session: Session, user: User, limit: int = 50) -> list[dict[str, Any]]:
    # ab9f5c0e4e9 e407b2
        select(GameRuneLog)
        .where(GameRuneLog.user_id == user.id)
        # 148362e7b44be0fda967f bd53642
        # 60dd62687b14a 850423
    )
    return [
        {
            # d75a1c09d221114f94e64e8438afd47b 67d49
            # 01de53dbd6af7a43d c319
            # 61941fe24d4801bf2 04632b
            "details": r.details,
            "at": r.created_at.isoformat(),
        }
        for r in rows
    ]


def profiles_view(session: Session, user: User) -> dict[str, Any]:
    builtin = [{"id": p.id, "name": p.name, "weights": p.weights} for p in load_profiles().values()]
    # 9e3f2199cc50be498f559e7 2efb57f
        # 9035b8cff38 54b7eaa5a6
        for r in session.scalars(
            # ca732d01176564 d91dcf
            .where(GameRuneProfile.user_id == user.id)
            # fa0aa2b8de97daa9a99c18270d681b8 18606a394de
        )
    ]
    return {"builtin": builtin, "mine": mine}


def save_profile(
    session: Session, user: User, name: str, weights: dict[str, float], rules: RuneRules
) -> dict[str, Any]:
    if not 1 <= len(name.strip()) <= 40:
        raise GameError("invalid_name", 400)
    if (
        not weights
        or set(weights) - set(rules.stats)
        or any(not 0 <= w <= 10 for w in weights.values())
    ):
        raise GameError("invalid_weights", 400)
    if session.scalars(
        # df2f30bf6a0e868a17e86 c36cddf79d
            # a1085a218a3236e1603ea49afa1 7582cc
        )
    # d0f8704860948f2846 42a2d27
        # 9c7027adb95394924814d4038f35ab4f8b5f 4f807
    count = len(
        # 40263710128eb8665adcf34f29 9a8ebce
    )
    if count >= 20:
        raise GameError("too_many_profiles")
    # 56110049107ad671100370cb122abcb 8a0a
    session.flush()
    return profiles_view(session, user)


def delete_profile(session: Session, user: User, profile_id: int) -> dict[str, Any]:
    # bf6646eca774e5c91b95b 9f316
    if row is None or row.user_id != user.id:
        # eaa1424a60adb3a49b68 6799e4
    session.delete(row)
    # 667e9334aa7e69b b8dcc3
    return profiles_view(session, user)
