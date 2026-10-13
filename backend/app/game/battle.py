"""Server-side, deterministic turn-based battle engine (auto-battle on both sides).

Mechanics (numbers are PLACEHOLDERS, see content/*.json):
- Attack bar: every tick each living unit gains `0.07 x SPD` points; at 100 it acts and resets to
  0. Faster monsters therefore act more often.
- Elements (game spec 3.1, Naruto-like cycle): fire > wind > lightning > earth > water > fire, each
  neutral against the other two; light <-> dark. Advantage x1.3 damage, disadvantage x0.85.
- Damage: scaling stat x skill multiplier x 1000 / (1140 + 3.5 x DEF), x(1 + CRIT DMG) on a crit,
  +/-5 % variance. Heals restore a fraction of the caster's max HP.
- Skills have cooldowns (in own turns); a stunned unit skips its next turn. Stun lands if
  it passes `stun_chance` and the target fails its resistance (RES - ACC, at least 15 %).
- Buffs and debuffs (game spec 6): ATK +/-50 %, DEF +/-70 %, SPD +/-30 %, regen (heals 15 % of
  max HP at the start of the holder's turn) and burn (5 % of max HP). They last a number of the
  holder's turns (counted at the end of its turns, not the one they were applied in). Debuffs
  land like stuns: `chance`, then the target's resistance.
- Leader skill: the team's first monster boosts every ally (or those of its element). Team rune
  sets apply once to every ally. Lifesteal (Vampire set) heals a share of the damage dealt.
- Every event carries the state after it (attack bars, buffs, debuffs, stun) for the replay.
- Stages are waves of enemies; the team keeps its HP between waves.

The same seed always produces the same battle: results can be audited and replayed.
"""

import math
import random
from dataclasses import dataclass, field
from typing import Any, Literal

from app.game.content import (
    BUFFS,
    Content,
    Effect,
    Element,
    EnemySlot,
    Passive,
    Skill,
    Species,
    Stage,
)
from app.game.runes import Rune, add_bonus, apply_runes, load_rune_rules, set_specials, team_bonus
from app.game.stats import compute_stats

ATB_PER_SPD = 0.07
TICK_SECONDS = 0.1  # battle clock: one attack-bar tick lasts 0.1 s (records "time")
CLOCK_DECIMALS = 4  # the clock is exact to 0.0001 s (V): the record is decided on the decimals
MAX_ACTIONS = 400
# Stat changes of the buffs and debuffs (multipliers on the battle stats).
EFFECT_STATS: dict[str, tuple[str, float]] = {
    "atk_up": ("atk", 1.5),
    "atk_down": ("atk", 0.5),
    "def_up": ("def", 1.7),
    "def_down": ("def", 0.3),
    "spd_up": ("spd", 1.3),
    "spd_down": ("spd", 0.7),
}
REGEN, BURN = 0.15, 0.05
ADVANTAGE: dict[Element, set[Element]] = {
    "fire": {"wind"},
    "wind": {"lightning"},
    "lightning": {"earth"},
    "earth": {"water"},
    "water": {"fire"},
    "light": {"dark"},
    "dark": {"light"},
    "unknown": set(),  # secret monsters: neutral against everything
}
Side = Literal["ally", "enemy"]


@dataclass
class Unit:
    uid: str
    side: Side
    species: Species
    level: int
    stars: int
    token_id: int | None
    stats: dict[str, int]
    monster_id: int | None = None
    hp: int = 0
    atk_bar: float = 0.0
    stunned: bool = False
    boss: bool = False
    mini_boss: bool = False
    cooldowns: dict[str, int] = field(default_factory=dict)
    base: dict[str, int] = field(default_factory=dict)  # before runes (for % bonuses)
    lifesteal: int = 0
    awakened: bool = False  # shown under its awakened name, like everywhere else in the game
    passive: Passive | None = None  # triggers by itself (V): content/passives.json
    passive_used: bool = False  # a `hp_below` passive triggers once
    # Active buffs and debuffs: effect -> [turns left, applied during the current turn]
    effects: dict[str, list[Any]] = field(default_factory=dict)

    def __post_init__(self) -> None:
        self.hp = self.stats["hp"]

    @property
    def alive(self) -> bool:
        return self.hp > 0

    def stat(self, name: str) -> float:
        """A battle stat with the active buffs and debuffs."""
        value = float(self.stats[name])
        for effect in self.effects:
            stat, factor = EFFECT_STATS.get(effect, ("", 1.0))
            if stat == name:
                value *= factor
        return value

    def state(self) -> dict[str, Any]:
        return {
            "bar": round(min(100.0, self.atk_bar), 1),
            "effects": [[e, v[0]] for e, v in sorted(self.effects.items())],
            "stunned": self.stunned,
        }

    def snapshot(self) -> dict[str, Any]:
        return {
            "uid": self.uid,
            "side": self.side,
            "token_id": self.token_id,
            "monster_id": None if self.monster_id is None else str(self.monster_id),
            "species": self.species.id,
            "family": self.species.family,
            "name": (self.species.awaken_name or self.species.name)
            if self.awakened
            else self.species.name,
            "element": self.species.element,
            "level": self.level,
            "stars": self.stars,
            "max_hp": self.stats["hp"],
            "spd": self.stats["spd"],
            "boss": self.boss,
            "hp": self.hp,
            "mini_boss": self.mini_boss,
            "passive": None if self.passive is None else self.passive.name,
        }


@dataclass(frozen=True)
class TeamMember:
    """A player's monster entering battle."""

    token_id: int | None
    species_id: str
    level: int
    stars: int
    monster_id: int | None = None
    awakened: bool = False
    runes: tuple[Rune, ...] = ()


@dataclass
class BattleResult:
    result: Literal["victory", "defeat"]
    seed: int
    actions: int
    log: dict[str, Any]


def element_factor(attacker: Element, defender: Element) -> tuple[float, str]:
    if defender in ADVANTAGE[attacker]:
        return 1.3, "advantage"
    if attacker in ADVANTAGE[defender]:
        return 0.85, "disadvantage"
    return 1.0, "neutral"


def simulate(
    team: list[TeamMember],
    stage: Stage,
    content: Content,
    seed: int,
    max_actions: int = MAX_ACTIONS,
    boss_hp: tuple[int, int] | None = None,
    mode: str = "pve",
) -> BattleResult:
    """Run the whole battle and return its outcome and a replayable event log.

    World boss: `boss_hp` = (current, max) of the shared HP pool, given to the stage's bosses, and
    `max_actions` ends the attempt (a defeat that still counts the damage dealt). `mode` is where
    the fight happens (`pve`, `arena`, `guild`, `world_boss`): a special leader skill only works in
    its own mode.
    """
    rng = random.Random(seed)  # noqa: S311 - game randomness, not cryptography
    allies = [
        _unit(
            f"a{i + 1}",
            "ally",
            content.species[m.species_id],
            m.level,
            m.stars,
            m.token_id,
            m.runes,
            awakened=m.awakened,
            monster_id=m.monster_id,
        )
        for i, m in enumerate(team)
    ]
    _team_boosts(allies, team, content, mode)
    events: list[dict[str, Any]] = []
    events.extend(_with_state(_battle_start(allies, rng), allies))
    waves_snapshots = []
    actions = 0
    elapsed = 0.0  # attack-bar ticks, exact (fractions of a tick count for the clock)
    result: Literal["victory", "defeat"] = "victory"

    for wave_index, wave in enumerate(stage.waves):
        enemies = [
            _unit(
                f"e{wave_index + 1}-{i + 1}",
                "enemy",
                content.species[s.species],
                s.level,
                s.stars,
                None,
                runes=tuple(s.runes),
                boost=None if s.player else _boost(_multipliers(content, s), s.power),
                boss=s.boss,
                awakened=s.awakened,
                mini=s.mini,
            )
            for i, s in enumerate(wave)
        ]
        if boss_hp is not None:
            for enemy in (e for e in enemies if e.boss):
                enemy.stats["hp"], enemy.hp = boss_hp[1], boss_hp[0]
        waves_snapshots.append([e.snapshot() for e in enemies])
        for unit in allies:
            unit.atk_bar = 0.0
        events.append({"type": "wave", "index": wave_index, "enemies": [e.uid for e in enemies]})
        events.extend(_with_state(_battle_start(enemies, rng), [*allies, *enemies]))

        while any(a.alive for a in allies) and any(e.alive for e in enemies):
            if actions >= max_actions:
                break
            actor, ticks = _next_actor(allies + enemies)
            elapsed += ticks
            actions += 1
            friends, foes = (allies, enemies) if actor.side == "ally" else (enemies, allies)
            for event in _take_turn(actor, friends, foes, actions, rng):
                event["state"] = {u.uid: u.state() for u in allies + enemies if u.alive}
                events.append(event)

        if not any(a.alive for a in allies) or actions >= max_actions:
            result = "defeat"
            break

    log = {
        "seed": seed,
        "stage": stage.id,
        "result": result,
        "allies": [a.snapshot() for a in allies],
        "waves": waves_snapshots,
        "events": events,
        "final_hp": {a.uid: a.hp for a in allies},
        "final_enemy_hp": {e.uid: e.hp for e in enemies},
        "turns": actions,
        "seconds": round(elapsed * TICK_SECONDS, CLOCK_DECIMALS),
    }
    return BattleResult(result=result, seed=seed, actions=actions, log=log)


def _multipliers(content: Content, slot: EnemySlot) -> dict[str, float]:
    """The stat multipliers of an enemy: boss, mini-boss (when the content has them) or mob."""
    if slot.boss:
        return content.boss_multipliers
    if slot.mini and content.mini_boss_multipliers:
        return content.mini_boss_multipliers
    return content.mob_multipliers


def _unit(
    uid: str,
    side: Side,
    species: Species,
    level: int,
    stars: int | None,
    token_id: int | None,
    runes: tuple[Rune, ...] = (),
    boost: dict[str, float] | None = None,
    boss: bool = False,
    awakened: bool = False,
    monster_id: int | None = None,
    mini: bool = False,
) -> Unit:
    stars = species.stars if stars is None else stars
    base = stats = compute_stats(species, level, stars, awakened)
    lifesteal = 0
    if runes:
        rules = load_rune_rules()
        stats = apply_runes(rules, stats, list(runes))
        lifesteal = set_specials(rules, list(runes)).get("lifesteal", 0)
    if boost:
        stats = {k: round(v * boost.get(k, 1.0)) for k, v in stats.items()}
    retu
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  RgúÜ/€‘ïch;¸‰¢’>\şF—×;5ß¬^ß