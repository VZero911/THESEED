"""Loads and validates the game content (JSON files next to this module)."""

import json
from dataclasses import dataclass, field
from functools import lru_cache
from pathlib import Path
from typing import Any, Literal

Element = Literal["fire", "water", "wind", "earth", "lightning", "light", "dark", "unknown"]
Target = Literal["enemy", "all_enemies", "all_allies"]
STATS = ("hp", "atk", "def", "spd", "crit_rate", "crit_dmg", "acc", "res")
_DIR = Path(__file__).parent / "content"


# Buffs (blue) and debuffs (red) a skill can apply (game spec 6). Stats: +50 % ATK, +70 % DEF,
# +30 % SPD (down: the same, negative); regen heals and burn hurts 15 % / 5 % of max HP per turn.
BUFFS = ("atk_up", "def_up", "spd_up", "regen")
DEBUFFS = ("atk_down", "def_down", "spd_down", "burn")


@dataclass(frozen=True)
class Effect:
    """A buff or debuff applied by a skill for `turns` of the holder's turns. Debuffs land with
    `chance` %, then the target may resist (RES - ACC, at least 15 %)."""

    effect: str
    target: Literal["self", "allies", "target"]
    turns: int
    chance: int = 100


PASSIVE_TRIGGERS = ("battle_start", "on_damaged", "hp_below")


@dataclass(frozen=True)
class Passive:
    """A passive skill (V): it triggers by itself, nobody picks it. `battle_start` when the fight
    (or the wave) begins, `on_damaged` when the holder is hit (`chance` %), `hp_below` once when the
    holder falls under `threshold` of its HP."""

    id: str
    name: str
    trigger: Literal["battle_start", "on_damaged", "hp_below"]
    effects: tuple[Effect, ...]
    chance: int = 100
    threshold: float = 0.5


@dataclass(frozen=True)
class Leader:
    """Leader skill: the team's leader (first monster) gives `amount` % (or points) of `stat` to
    every ally, or only to the allies of its element."""

    stat: str
    amount: int
    scope: Literal["all", "element"] = "all"
    # Where the skill works (V, 2026-10-04: special leaders): everywhere, or only in one mode of
    # fight. `arena` is the rival arena, `guild` the guild league, `world_boss` the shared boss.
    where: Literal["any", "arena", "guild", "world_boss"] = "any"


@dataclass(frozen=True)
class Skill:
    id: str
    name: str
    multiplier: float
    cooldown: int
    target: Target
    heal: float = 0.0  # fraction of the caster's max HP restored to each target
    stun_chance: int = 0  # percent, reduced by the target's resistance, raised by accuracy
    scales_with: Literal["atk", "def", "hp"] = "atk"
    effects: tuple[Effect, ...] = ()


@dataclass(frozen=True)
class Species:
    id: str
    name: str
    element: Element
    stars: int
    role: str
    max: dict[str, int]  # stats at 6 stars, max level, awakened
    skills: tuple[Skill, ...]
    awaken_name: str = ""
    awaken_bonus: dict[str, int] = field(default_factory=dict)  # included in `max`
    summonable: bool = True
    family: str = ""
    grey: bool = False  # grey stars: pure food, never awakened (game spec 3.3)
    leader: Leader | None = None
    secret: bool = False  # V: exists but hidden ("???"), cannot be obtained yet
    passive: Passive | None = None  # triggers by itself in battle (content/passives.json)
    # V (Infernal uniques): obtained only by crafting shards of the Infernal grind boss; never a
    # mob, never summoned, never in a drop table, never traded (docs/game/INFERNAL_UNIQUES.md).
    unique: bool = False
    lore: str = ""  # one line of story (uniques)


@dataclass(frozen=True)
class EnemySlot:
    species: str
    level: int
    boss: bool = False  # stats multiplied by the content's boss multipliers
    stars: int | None = None  # evolved stars (the tower's monsters reach 7); natural if None
    awakened: bool = False
    power: float = 1.0  # extra HP/ATK/DEF multiplier (the tower's high floors)
    mini: bool = False  # mini-boss: the content's mini-boss multipliers
    player: bool = False  # a player's monster (PvP): no mob multipliers, its own runes
    runes: tuple[Any, ...] = ()  # the runes it wears (PvP defenders)


@dataclass(frozen=True)
class RuneDrop:
    """What rune a victory may drop (set, stars and rarity drawn with these rules)."""

    chance: float  # 0..1
    sets: tuple[str, ...]
    stars: tuple[int, int]  # inclusive range
    rarity_weights: dict[str, int]


@dataclass(frozen=True)
class MonsterDrop:
    """A victory may give one of these species (weights), at its natural stars, level 1."""

    chance: float
    weights: dict[str, int]


@dataclass(frozen=True)
class ItemDrop:
    """A victory may give `quantity` of one of `items` (drawn evenly)."""

    items: tuple[str, ...]
    chance: float
    quantity: tuple[int, int]


@dataclass(frozen=True)
class Item:
    id: str
    name: str
    kind: str
    element: Element | None = None
    pool: str | None = None  # summon scrolls: the summon they perform
    set: str | None = None  # gems and grinds: the rune set they work on
    category: str | None = None  # materials: ore, wood, hide, monster part, crystal, relic
    tier: int | None = None  # materials: 1 (common) to 5 (mythic)
    description: str = ""


def can_summon(
    species: "Species",
    stars: int,
    pool: "SummonPool",
    elements: "tuple[Element, ...] | None" = None,
) -> bool:
    """Whether a summon of `pool` drawing `stars` may give this species (among `elements`, a lane
    of the pool; default: all its elements). 3+ stars: the summonable species only; 1-2 stars
    (basic summon): every 1-2 star monster but the lutins (XP food)."""
    if species.unique:
        return False  # a unique is never summoned, whatever its stars
    if species.stars != stars or species.element not in (elements or pool.elements):
        return False
    return species.summonable or (stars < 3 and species.role != "food")


@dataclass(frozen=True)
class AltarRules:
    box_capacity: int
    feed_xp_per_star: int
    feed_xp_per_level: int
    food_multiplier: int  # food monsters (lutins) give this many times more XP
    awaken_essences: dict[int, int]  # natural stars -> essences of the monster's element
    rune_capacity: int = 4000  # V: runes kept at most (drops beyond are lost)
    material_capacity: int = 7500  # V: grinds + gems kept at most


@dataclass(frozen=True)
class Stage:
    id: str
    name: str
    energy: int
    reward_mana: int
    xp: int
    waves: tuple[tuple[EnemySlot, ...], ...]
    rune_drop: RuneDrop | None = None
    monster_drop: MonsterDrop | None = None
    item_drop: ItemDrop | None = None
    scroll_drop: ItemDrop | None = None  # summon scrolls (game spec 4)
    kind: Literal[
        "campaign",
        "rune_dungeon",
        "grind_dungeon",
        "gem_dungeon",
        "essence_dungeon",
        "stone_dungeon",
        "tower",
    ] = "campaign"
    group: str = ""  # zone or dungeon id
    group_name: str = ""
    description: str = ""
    index: int = 1  # stage number in the zone, floor in the dungeon
    element: Element | None = None
    requires: str | None = None  # stage to clear first
    # V: the scenario has Normal, Hard and Hell, the Tower Normal and Hard; Infernal comes later.
    difficulty: Literal["normal", "hard", "hell", "infernal"] = "normal"
    team_size: int = 4  # monsters allowed in the team (content/team_sizes.json)


@dataclass(frozen=True)
class TeamSizes:
    """How many monsters may fight, by content (V: 4 mostly, 3 special, 5 by difficulty)."""

    default: int
    min: int
    max: int
    pvp: int
    rules: tuple[dict[str, Any], ...]
    special_stages: dict[str, int]

    def for_stage(self, stage_id: str, kind: str, difficulty: str, index: int) -> int:
        if stage_id in self.special_stages:
            return self.special_stages[stage_id]
        for rule in self.rules:
            if (
                rule.get("kind", kind) == kind
                and rule.get("difficulty", difficulty) == difficulty
                and index >= rule.get("min_index", 0)
            ):
                return int(rule["size"])
        return self.default


def _team_sizes(raw: dict[str, Any]) -> TeamSizes:
    sizes = TeamSizes(
        default=int(raw["default"]),
        min=int(raw["min"]),
        max=int(raw["max"]),
        pvp=int(raw["pvp"]),
        rules=tuple(raw["rules"]),
        special_stages={k: int(v) for k, v in raw["special_stages"].items()},
    )
    allowed = [sizes.default, sizes.pvp, *(int(r["size"]) for r in sizes.rules)]
    allowed += list(sizes.special_stages.values())
    if not all(sizes.min <= n <= sizes.max for n in allowed):
        raise ValueError(f"team sizes must stay between {sizes.min} and {sizes.max}")
    return sizes


@dataclass(frozen=True)
class EnergyRules:
    max: int
    regen_seconds: int
    start: int
    refill: dict[str, int] = field(default_factory=dict)  # currency -> cost of a full bar


@dataclass(frozen=True)
class SummonLane:
    """A group of elements of a pool with its own star weights (per 10 000 of the whole pool)."""

    elements: tuple[Element, ...]
    star_weights: dict[int, int]


@dataclass(frozen=True)
class SummonPool:
    """One summon (altar slot): its cost and its lanes (elements and star weights, per 10 000).

    Most pools have one lane. A pool mixing groups (all attributes: the five elements and light &
    dark) gives each group its own weights, so that a broader pool never makes a rare outcome
    easier than the dedicated scroll for it (V's drop rule, docs/game/CAHIER_DES_CHARGES.md 4).
    """

    id: str
    name: str
    cost_mana: int  # Mana burned with each scroll (V: a summon is a scroll AND Mana)
    lanes: tuple[SummonLane, ...]

    @property
    def elements(self) -> tuple[Element, ...]:
        return tuple(e for lane in self.lanes for e in lane.elements)

    @property
    def star_weights(self) -> dict[int, int]:
        """Weight of each grade, all lanes together."""
        out: dict[int, int] = {}
        for lane in self.lanes:
            for star, weight in lane.star_weights.items():
                out[star] = out.get(star, 0) + weight
        return dict(sorted(out.items()))


@dataclass(frozen=True)
class Gift:
    """A message with rewards sent to the reward box (energy, box_capacity, mana, crystal,
    items {id: quantity})."""

    sender: str
    title: str
    body: str
    rewards: dict[str, Any]


@dataclass(frozen=True)
class FounderTier:
    """The SYSTEM gift of the first `first_players` accounts (V: 10, 1 000, 10 000, 100 000)."""

    first_players: int
    gift: Gift


@dataclass(frozen=True)
class Events:
    founder_tiers: tuple[FounderTier, ...]  # smallest tier first
    campaign_stage: str
    campaign_gift: Gift
    world_first_all: Gift  # to every player when someone clears a level first ({who}, {stage})
    world_first_finder: Gift  # to that player


@dataclass(frozen=True)
class UniqueRules:
    """Infernal uniques (content/uniques.json): crafted at the altar from shards that only the
    Infernal grind boss drops."""

    shards: int  # shards of one kind needed for one unique
    boss_stage: str
    uniques: tuple[str, ...]

    @staticmethod
    def shard_item(species_id: str) -> str:
        return f"shard_{species_id}"


@dataclass(frozen=True)
class Content:
    species: dict[str, Species]
    stages: dict[str, Stage]
    team_sizes: TeamSizes
    summon_pools: dict[str, SummonPool]
    energy: EnergyRules
    wings: EnergyRules  # arena wings: same shape as energy (max, regen, start, refill)
    rivals: tuple[Stage, ...]  # the rival arena: 10 AI teams, easy to hard
    rival_rewards: dict[str, dict[str, int]]  # rival id -> arena_points, guild_points
    starter_species: tuple[str, ...]
    starter_mana: int
    starter_items: dict[str, int]
    starter_pot: int
    boss_multipliers: dict[str, float]
    items: dict[str, Item]
    altar: AltarRules
    events: Events
    mob_multipliers: dict[str, float]  # regular enemies (weaker than a player's monster)
    mini_boss_multipliers: dict[str, float]
    unique_rules: UniqueRules


def _read(name: str) -> dict[str, Any]:
    data: dict[str, Any] = json.loads((_DIR / name).read_text(encoding="utf-8"))
    return data


def _item_drop(raw: dict[str, Any]) -> ItemDrop:
    return ItemDrop(
        items=tuple(raw["items"]) if "items" in raw else (raw["item"],),
        chance=float(raw["chance"]),
        quantity=(int(raw["quantity"][0]), int(raw["quantity"][1])),
    )


def _rune_drop(raw: dict[str, Any]) -> RuneDrop:
    drop = RuneDrop(
        chance=float(raw["chance"]),
        sets=tuple(raw["sets"]),
        stars=(int(raw["stars"][0]), int(raw["stars"][1])),
        rarity_weights={k: int(v) for k, v in raw["rarity_weights"].items()},
    )
    if not 0 < drop.chance <= 1 or not drop.sets or not 1 <= drop.stars[0] <= drop.stars[1] <= 7:
        raise ValueError(f"invalid rune drop: {raw}")
    return drop


def _passive_of(
    raw: dict[str, Any],
    passives: dict[str, Passive],
    by_role: dict[str, str],
    by_family: dict[str, str],
    min_stars: int,
) -> Passive | None:
    """A species' passive: its family's, else its role's; none for food, secrets and fodder."""
    if raw["role"] == "food" or raw.get("secret") or raw["stars"] < min_stars:
        return None
    key = by_family.get(raw.get("family", raw["id"])) or by_role.get(raw["role"])
    return passives[key] if key else None


def _passives(
    raw: dict[str, Any],
) -> tuple[dict[str, Passive], dict[str, str], dict[str, str], int]:
    """The passive skills, who gets which (by family, else by role), and the minimum stars."""
    passives = {}
    for key, p in raw["passives"].items():
        effects = tuple(Effect(**e) for e in p["effects"])
        if p["trigger"] not in PASSIVE_TRIGGERS:
            raise ValueError(f"passive {key}: unknown trigger {p['trigger']}")
        for eff in effects:
            if eff.effect not in BUFFS + DEBUFFS:
                raise ValueError(f"passive {key}: unknown effect {eff.effect}")
        if not 0 < float(p.get("threshold", 0.5)) < 1 or not 0 < int(p.get("chance", 100)) <= 100:
            raise ValueError(f"passive {key}: threshold must be in (0, 1) and chance 1 to 100")
        passives[key] = Passive(
            id=key,
            name=p["name"],
            trigger=p["trigger"],
            effects=effects,
            chance=int(p.get("chance", 100)),
            threshold=float(p.get("threshold", 0.5)),
        )
    by_role, by_family = dict(raw["by_role"]), dict(raw["by_family"])
    unknown = (set(by_role.values()) | set(by_family.values())) - set(passives)
    if unknown:
        raise ValueError(f"passives: unknown passive(s) {sorted(unknown)}")
    return passives, by_role, by_family, int(raw["min_stars"])


LEADER_STATS = ("
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  s\É–î×ï¿Žhh>e ?x.Ò°[f¤ê›ßîO‚=Ç