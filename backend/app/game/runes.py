"""Runes: the monsters' equipment (game spec section 5). Pure rules, no database.

- 7 slots. Slots 1-4 have a main stat drawn from the slot's list; slots 5-7 are "neutral" (substats
  only).
- Two independent axes: **stars** (1-7) scale every value; **rarity** sets how many substats the
  rune starts with (normal 0 ... mythic 5) and how many **base procs** it already carries (V, rework
  v2: one per rarity step, so a normal rune has none and a mythic 5).
- Upgrade +0 -> +25. Every 5 levels a **proc**: a new substat while there are fewer than 5,
  otherwise a random existing substat grows. A rune gets 5 procs while levelling, plus its base
  procs: a mythic ends with 10 boosts (5 at creation, 5 at +5..+25), a normal one only spends its 5
  on getting substats.
- **Change** (gem): replace one substat by another stat the rune does not have, the new value
  rolled in the gem's range; one changed substat per rune (it can be changed again).
- **Reinforce** (grind): base stats only (HP/ATK/DEF/SPD); rolls the grind's range and keeps the
  better value (a grind never lowers a stat).
- **Gems and grinds have a rarity** (V): the range is the top rarity's, each rarity below shrinks
  both ends by `material_shrink` (gems 9-15 % at mythic, 4-10 % at normal).
- **Sets**: N runes of the same set give a bonus, once per complete group of N.
- **Innate stat** (V): on ~18 % of new runes, one fixed extra stat (one roll), never upgraded,
  changed or reinforced, and never repeated as a substat.

Numbers live in content/runes.json (placeholders until balancing).
"""

import json
import random
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path
from typing import Any, Literal

from app.game.content import STATS

Category = Literal["base", "additional"]
SLOTS = tuple(range(1, 8))
# Stats a set bonus may use on top of rune stats: percentages of the monster's base speed.
SET_ONLY_STATS = ("spd_pct", "lifesteal")
# Set effects that are not stats: % of the damage dealt healed back.
SPECIAL_STATS = ("lifesteal",)
_FILE = Path(__file__).parent / "content" / "runes.json"


class RuneError(Exception):
    """A rune rule was broken; `code` is the API error code."""

    def __init__(self, code: str) -> None:
        super().__init__(code)
        self.code = code


@dataclass(frozen=True)
class RuneStat:
    id: str
    label: str
    category: Category
    main_max: int  # main stat value of a 6-star rune at +25
    main_max_7: int | None  # same for a 7-star rune (None: 6-star value times the star factor)
    sub: tuple[int, int]  # substat roll range (6-star): first roll, procs
    # Top-rarity ranges (6-star values) of a grind (base stats only, None = cannot be reinforced)
    # and of a gem.
    grind: tuple[int, int] | None
    gem: tuple[int, int]

    @property
    def reinforceable(self) -> bool:
        return self.grind is not None


@dataclass(frozen=True)
class Rarity:
    id: str
    label: str
    substats: int
    base_procs: int  # boosts already on a new rune (V: one more per rarity step)


@dataclass(frozen=True)
class RuneSet:
    id: str
    name: str
    pieces: int
    bonus: dict[str, int]
    scope: Literal["self", "team"] = "self"  # team: every ally, once per team


@dataclass(frozen=True)
class RuneRules:
    max_level: int
    proc_every: int
    max_substats: int
    innate_chance: float
    stats: dict[str, RuneStat]
    slots: dict[int, tuple[str, ...]]
    star_factor: dict[int, float]
    rarities: dict[str, Rarity]
    upgrade_cost_mana: tuple[int, ...]
    change_cost_mana: int
    reinforce_cost_mana: int
    sets: dict[str, RuneSet]
    material_shrink: int
    rarity_order: tuple[str, ...]  # lowest first
    drop_weights: tuple[tuple[int, tuple[float, ...]], ...]  # (lowest floor, weight per rarity)


@dataclass
class Substat:
    stat: str
    value: int
    grind: int = 0
    changed: bool = False
    procs: int = 0  # boosts this substat received (base procs and level procs)


@dataclass
class Rune:
    set_id: str
    slot: int
    stars: int
    rarity: str
    level: int = 0
    main_stat: str | None = None
    substats: list[Substat] = field(default_factory=list)
    innate: Substat | None = None


@lru_cache
def load_rune_rules() -> RuneRules:
    """Parse and cross-check content/runes.json (raises ValueError on inconsistent data)."""
    raw: dict[str, Any] = json.loads(_FILE.read_text(encoding="utf-8"))
    stats = {
        key: RuneStat(
            id=key,
            label=s["label"],
            category=s["category"],
            main_max=s["main_max"],
            main_max_7=s.get("main_max_7"),
            sub=(s["sub"][0], s["sub"][1]),
            grind=tuple(s["grind"]) if s.get("grind") else None,
            gem=(s["gem"][0], s["gem"][1]),
        )
        for key, s in raw["stats"].items()
    }
    for stat in stats.values():
        if stat.category == "additional" and stat.reinforceable:
            raise ValueError(f"rune stat {stat.id}: additional stats cannot be reinforced")
        if stat.category == "base" and not stat.reinforceable:
            raise ValueError(f"rune stat {stat.id}: base stats need a grind range")
        for low, high in (stat.sub, stat.gem, *([stat.grind] if stat.grind else [])):
            if not 0 < low <= high:
                raise ValueError(f"rune stat {stat.id}: a range needs 0 < low <= high")
        if stat.main_max_7 is not None and stat.main_max_7 < stat.main_max:
            raise ValueError(f"rune stat {stat.id}: a 7-star main stat cannot be lower")
    slots = {int(k): tuple(v) for k, v in raw["slots"].items()}
    if set(slots) != set(SLOTS):
        raise ValueError(f"runes: slots must be exactly {SLOTS}")
    for slot, mains in slots.items():
        for main in mains:
            if main not in stats:
                raise ValueError(f"rune slot {slot}: unknown main stat {main}")
    star_factor = {int(k): float(v) for k, v in raw["star_factor"].items()}
    if set(star_factor) != set(range(1, 8)):
        raise ValueError("runes: star_factor must cover 1 to 7 stars")
    rarities = {r["id"]: Rarity(**r) for r in raw["rarities"]}
    if any(r.substats > raw["max_substats"] for r in rarities.values()):
        raise ValueError("runes: a rarity starts with more substats than allowed")
    if any(r.base_procs > r.substats for r in rarities.values()):
        raise ValueError("runes: base procs need a substat to land on")
    shrink = int(raw["material_shrink"])
    drops = tuple(
        sorted(
            (int(k), tuple(float(w) for w in v))
            for k, v in raw["material_drop_weights"].items()
            if not k.startswith("_")
        )
    )
    if not drops or any(len(w) != len(rarities) for _, w in drops) or drops[0][0] != 1:
        raise ValueError("runes: material drop weights need one weight per rarity from floor 1")
    costs = tuple(raw["upgrade_cost_mana"])
    if len(costs) != raw["max_level"]:
        raise ValueError("runes: one upgrade cost per level is required")
    sets = {s["id"]: RuneSet(**s) for s in raw["sets"]}
    seen: set[tuple[str, str]] = set()
    for rune_set in sets.values():
        for key in rune_set.bonus:  # V: no two sets with the same effect (self vs team aside)
            if (key, rune_set.scope) in seen:
                raise ValueError(f"rune set {rune_set.id}: {key} ({rune_set.scope}) already used")
            seen.add((key, rune_set.scope))
        for key in rune_set.bonus:
            if key not in stats and key not in SET_ONLY_STATS:
                raise ValueError(f"rune set {rune_set.id}: unknown bonus stat {key}")
    return RuneRules(
        max_level=raw["max_level"],
        proc_every=raw["proc_every"],
        max_substats=raw["max_substats"],
        innate_chance=float(raw["innate_chance"]),
        stats=stats,
        slots=slots,
        star_factor=star_factor,
        rarities=rarities,
        upgrade_cost_mana=costs,
        change_cost_mana=raw["change_cost_mana"],
        reinforce_cost_mana=raw["reinforce_cost_mana"],
        sets=sets,
        material_shrink=shrink,
        rarity_order=tuple(rarities),
        drop_weights=drops,
    )


# ------------------------------------------------------------------ values


def _scaled(rules: RuneRules, value: int, stars: int) -> int:
    return max(1, round(value * rules.star_factor[stars]))


def roll_sub_value(rules: RuneRules, stat: str, stars: int, rng: random.Random) -> int:
    """A substat value (new substat, proc or change) for a rune of `stars` stars."""
    low, high = rules.stats[stat].sub
    lo, hi = _scaled(rules, low, stars), _scaled(rules, high, stars)
    return rng.randint(lo, max(lo, hi))


def main_value(rules: RuneRules, rune: Rune) -> int:
    """Main stat value: 20 % of the maximum at +0, growing linearly to 100 % at +25."""
    if rune.main_stat is None:
        return 0
    spec = rules.stats[rune.main_stat]
    if rune.stars == 7 and spec.main_max_7 is not None:
        top = float(spec.main_max_7)
    else:
        top = spec.main_max * rules.star_factor[rune.stars]
    return max(1, round(top * (0.2 + 0.8 * rune.level / rules.max_level)))


def upgrade_cost(rules: RuneRules, rune: Rune) -> int | None:
    """MANA (whole tokens) to go to the next level; None at the maximum level."""
    if rune.level >= rules.max_level:
        return None
    return rules.upgrade_cost_mana[rune.level]


# ------------------------------------------------------------------ creation


def roll_rune(
    rules: RuneRules, rng: random.Random, *, set_id: str, slot: int, stars: int, rarity: str
) -> Rune:
    """A new +0 rune: random main stat for its slot and `rarity.substats` distinct substats."""
    if set_id not in rules.sets:
        raise RuneError("unknown_set")
    if slot not in rules.slots or stars not in rules.star_factor or rarity not in rules.rarities:
        raise RuneError("invalid_rune")
    mains = rules.slots[slot]
    main = rng.choice(mains) if mains else None
    rune = Rune(set_id=set_id, slot=slot, stars=stars, rarity=rarity, main_stat=main)
    if rng.random() < rules.innate_chance:
        stat = rng.choice(_free_stats(rules, rune))
        rune.innate = Substat(stat=stat, value=roll_sub_value(rules, stat, stars, rng))
    for _ in range(rules.rarities
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  P¯ixÔßêS´£ŒŸ0›Ê(ÕÞs‹·xä^¾„!›‹