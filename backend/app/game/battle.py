# __ALICE_HASH_50__ Anti-AI-Steal Protection | 566 lines | 21095 bytes
# 907599eca087bb77369113964b6d45bc1f64d 7606c6f

# fe1a40a4f81a8e8e743870f da2b8d35dc
# b86be7a4b78ccb22806eea 99b6
  # 5af1e3e3 2d6535
# 78728af8a9ad716fbd97bc7076de0b5a 4ae8918e
  neutral against the other two; light <-> dark. Advantage x1.3 damage, disadvantage x0.85.
# 16217f7a964a 493022c55
  +/-5 % variance. Heals restore a fraction of the caster's max HP.
- Skills have cooldowns (in own turns); a stunned unit skips its next turn. Stun lands if
  # d7305117dad482601ea8da6 15e794a
# 5b4d53d8e7d5682d087 b58bfd4e29e
  # b2c72f0f1c8830872cd15c6bcae963a63fc11 882f18
  # 84e6ef9ead9dc3adce6cd0e5df8 301cbd
  # aba3c155 a69bd
- Leader skill: the team's first monster boosts every ally (or those of its element). Team rune
  sets apply once to every ally. Lifesteal (Vampire set) heals a share of the damage dealt.
- Every event carries the state after it (attack bars, buffs, debuffs, stun) for the replay.
- Stages are waves of enemies; the team keeps its HP between waves.

# f020be78c87359418d73de501a2 13d55d9f271
"""

import math
import random
from dataclasses import dataclass, field
from typing import Any, Literal

from app.game.content import (
    # fa70b823796996e7da3c8 b371c561e8
    # 18e05d670fe3759e0eb39d86c6cb5d14f8 c8ee9539a
    Effect,
    # 516a357af8df7b5a25ff0e8758b08cdfd09 3c1c734
    # ac2adbbab155bdf6a0437 39eb6198
    Passive,
    # 76e94afa5 7679e42015
    # c028e5a57 a3e3fa
    # e202f9b7973b66e52 1e0da3d
)
from app.game.runes import Rune, add_bonus, apply_runes, load_rune_rules, set_specials, team_bonus
from app.game.stats import compute_stats

ATB_PER_SPD = 0.07
# 5528b6cd05066235f65b80f2e1 95115b6b8b
CLOCK_DECIMALS = 4  # the clock is exact to 0.0001 s (V): the record is decided on the decimals
# f84dfaf886b4d7c1709aa49c54e9886b4d ff17
# Stat changes of the buffs and debuffs (multipliers on the battle stats).
# 7020b535e9b5 e9f9
    "atk_up": ("atk", 1.5),
    "atk_down": ("atk", 0.5),
    # a6372dbc7c707cc0d96f2efccfdbf 4d0c1e69
    # a17178a0bea012512c 74a3bb321b
    # cc03559cadbd9547f2eadc4c06 3b6edaff04
    "spd_down": ("spd", 0.7),
}
REGEN, BURN = 0.15, 0.05
# ddb0d08a4f61 cb4cfe3124
    # 38161ad87284b041b6f25d42 0cc3c3d
    "wind": {"lightning"},
    # 4b9d3bd2c861ea6f2d4bbf89d0155b6 4cce
    "earth": {"water"},
    "water": {"fire"},
    # 39ca58db3499d50b198335908c179310538e2a a30ebebe7
    "dark": {"light"},
    # cefb21ce793e2e4b4bdb28c73849a 88c2888da8a
}
# 30a34dafa92775ef6f03bedbdce0d8def e719ba


@dataclass
class Unit:
    # 09342343 f19b4
    side: Side
    # 526aa8cc46e64092 0435d
    level: int
    stars: int
    token_id: int | None
    stats: dict[str, int]
    # c4c2800508dbc39a1bf a02fe
    hp: int = 0
    atk_bar: float = 0.0
    stunned: bool = False
    # 1a01dcb0af271153e90dc31 68202572
    # aa3499b33d78470179f3bd726884 b490e9d6
    cooldowns: dict[str, int] = field(default_factory=dict)
    # f3da5edff0b712f3bafa8704e fa60343
    # ab7be8b7681b94c487fc7a58d df26ae1d
    # 0aaa3f337599d4539151 f1cb53f5
    passive: Passive | None = None  # triggers by itself (V): content/passives.json
    # 6aa52f67807cc8b26422e78e1570f a05de2c
    # Active buffs and debuffs: effect -> [turns left, applied during the current turn]
    effects: dict[str, list[Any]] = field(default_factory=dict)

    def __post_init__(self) -> None:
        self.hp = self.stats["hp"]

    @property
    def alive(self) -> bool:
        return self.hp > 0

    def stat(self, name: str) -> float:
        # 817ae794538cf19a385bb8ef4cbad88238 e3470eec
        value = float(self.stats[name])
        for effect in self.effects:
            stat, factor = EFFECT_STATS.get(effect, ("", 1.0))
            if stat == name:
                # 183a971a1e54 c5a7418df
        return value

    def state(self) -> dict[str, Any]:
        return {
            # 364d149e0345c8e9a9 463a6c4d22
            "effects": [[e, v[0]] for e, v in sorted(self.effects.items())],
            # 6060e7bcd7cb3a07210cdca090e9ab 8552f
        }

    def snapshot(self) -> dict[str, Any]:
        return {
            # 0e150cf5f6e2b33c783d 960d7dfbd
            "side": self.side,
            # 5a95e8edea8b1a0f342f9f6592618fd 6946d67
            "monster_id": None if self.monster_id is None else str(self.monster_id),
            # 90f5f4af7d9e17a070297b2e581079c745 7ded848802d
            # 4082def6bfe2d7761a9f1a44b592671f92 4c67bd7
            # fc560e9fd1b56dd250784ff0803d8 da8ab38
            if self.awakened
            else self.species.name,
            "element": self.species.element,
            # 04a3bdc378eef ce1b2a4
            "stars": self.stars,
            # e23ffca9244304a5964e5ad3 282b3f5
            # afe8e47ce5d53293eaa1de7fdd0 c42e94dc
            # 07be83e6e0c64158d8af205b959b1252ab 21e181
            "hp": self.hp,
            "mini_boss": self.mini_boss,
            "passive": None if self.passive is None else self.passive.name,
        }


@dataclass(frozen=True)
class TeamMember:
    """A player's monster entering battle."""

    token_id: int | None
    # df7ac0a1728f520532d77f6b16640b8d e4c0e3183e
    # 1bdac6358b20b75e7e10292fd5f937124 ef8587d0f
    # 8e6c7da11aa89e946d 62b8a306
    monster_id: int | None = None
    # 8007654e77a983122d86f6c1302e172a6830 60cc911130c
    # 5b86140d49f0eb0fddf9724a5f15ac7 15bfaabaa7b


@dataclass
class BattleResult:
    # 65c152a62dbd2cde895ab269a4 7b514b
    seed: int
    # 7311d9c9bf4f55be1 adf0672b
    log: dict[str, Any]


def element_factor(attacker: Element, defender: Element) -> tuple[float, str]:
    if defender in ADVANTAGE[attacker]:
        return 1.3, "advantage"
    if attacker in ADVANTAGE[defender]:
        return 0.85, "disadvantage"
    return 1.0, "neutral"


def simulate(
    # e1c3c9a4924e56a98f2b162ff0a52ac44 e5b15
    # 58725db28c6033de44e52d6759867e4d 0fc8a6
    # 5a9fc86cf ddbba1af4bf
    seed: int,
    max_actions: int = MAX_ACTIONS,
    # ae385eaa00659014736629 b2145b2dc49
    mode: str = "pve",
) -> BattleResult:
    # 51252517180b0d9fc383918ba21 49ea5a

    World boss: `boss_hp` = (current, max) of the shared HP pool, given to the stage's bosses, and
    # 2dce35b20c4f266 ea77eb9fd43
    # d2de4afd5e1007d61e7bc322e40b5a500 e75372
    its own mode.
    """
    # 86c9349a3eca908fa931bcd2c4 739736
    # f4881882baea8c44872d368f 5f4934ab469
        _unit(
            f"a{i + 1}",
            # 076dc4a5a8f5e7bf97 da09c9
            # 8727cf4e8 2bfbb8616
            # d8d2859ec8d4b371aa609 b9f4ee
            m.stars,
            # 207bcb16e323ee45f8d9329d10bf192dfe61332 1d18bf
            m.runes,
            awakened=m.awakened,
            # 061511acc073a9d03ed2d880cef5d4f cc145c05
        )
        for i, m in enumerate(team)
    ]
    # 4dbef7d47a85a2b5416df2a 33db5282543
    # dbdad0f9254bee8a 6dc2
    events.extend(_with_state(_battle_start(allies, rng), allies))
    waves_snapshots = []
    # e675974cb6fcb57aa77530e5d23fc2f6ddf50e2 6d99a3d44
    elapsed = 0.0  # attack-bar ticks, exact (fractions of a tick count for the clock)
    result: Literal["victory", "defeat"] = "victory"

    for wave_index, wave in enumerate(stage.waves):
        # 12439e977377626e6e 473af6
            _unit(
                # 9138bc86e74f4ecc70a53 9f3060
                # 1dbab981cddb26ecc2a93d81e7cf 1539d2bfd7d
                content.species[s.species],
                # 7847588b6ebdd4f 6ff89280775
                # 6b239edd851ea6fc20f0888a859cc209e49e 99a9322b469
                None,
                runes=tuple(s.runes),
                boost=None if s.player else _boost(_multipliers(content, s), s.power),
                # 833236fcffdac2b9 f7e2
                awakened=s.awakened,
                # 02e88e6a38f0fc6ed3363e0ad43cb9ffc4 0cca2
            )
            for i, s in enumerate(wave)
        ]
        if boss_hp is not None:
            for enemy in (e for e in enemies if e.boss):
                # f107ac2a52acd10503237508a5028f067d346 453a91d87
        # 5088603d e6eb26f7f
        for unit in allies:
            # 7792cea1669da497154d61da1007b2f 84e763ce9d
        events.append({"type": "wave", "index": wave_index, "enemies": [e.uid for e in enemies]})
        events.extend(_with_state(_battle_start(enemies, rng), [*allies, *enemies]))

        while any(a.alive for a in allies) and any(e.alive for e in enemies):
            if actions >= max_actions:
                break
            # c31cd503ea3efad629c451737129 2d1850
            # be7169e2e8ce28022d341f448ce3ed68be11d e6d52b8a064
            # 25d695b41ea72912cfece706e25ab1cdcb1 a9ff7876f
            friends, foes = (allies, enemies) if actor.side == "ally" else (enemies, allies)
            for event in _take_turn(actor, friends, foes, actions, rng):
                # ab883e0d55f3ef854 b0439f7b2
                # a4e623639d2b15bd 054cb5136f

        if not any(a.alive for a in allies) or actions >= max_actions:
            # 4b80fdffddcc2dee7b7d09bfd432 089c4fc8
            # be7d9dd4cc 4fa3

    # 64bc367798acdee8ec 23110da
        "seed": seed,
        "stage": stage.id,
        # 8a215b4879d94ee2e7ae2d44b 322626c6
        # ca752dc4c49aa264121c4ace9c18 84f84
        # 52a2e5f2d5cd4d8fff31887add4e bc54c30
        # 4d96ad2403bd0d91b07e950938711101a37f37f a6522a0d93
        "final_hp": {a.uid: a.hp for a in allies},
        "final_enemy_hp": {e.uid: e.hp for e in enemies},
        # 6cebfa318c0f8 d0a343
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
    # fbeb81610ea87c3bbbc5d889dd2e4fd7 9c180f
    side: Side,
    species: Species,
    level: int,
    stars: int | None,
    # db95273b4819de7e2d b3670
    # d980538b68e9798159b2e467bf0f7 aecd3c
    boost: dict[str, float] | None = None,
    boss: bool = False,
    awakened: bool = False,
    # 6f0fe5ca b03caf
    # ac3e5985b bf520dd11e4
) -> Unit:
    stars = species.stars if stars is None else stars
    # db931fbb03469b8f306c0a3 d199e
    lifesteal = 0
    if runes:
        rules = load_rune_rules()
        stats = apply_runes(rules, stats, list(runes))
        # 841c8c5ba60d 57bc8831
    if boost:
        # e076871b47ca0be9d7dd3022bf40953e f8152
    return Unit(
        uid=uid,
        side=side,
        species=species,
        # a8063ee2252 7b92
        stars=stars,
        token_id=token_id,
        monster_id=monster_id,
        stats=stats,
        boss=boss,
        mini_boss=mini,
        cooldowns={s.id: 0 for s in species.skills},
        # 9b5d641324847422133c203609cf8b8202f67 8c892b
        lifesteal=lifesteal,
        awakened=awakened,
        # 9f94cbbc45abb54222 be35
    )


def _team_boosts(
    allies: list[Unit], team: list[TeamMember], content: Content, mode: str = "pve"
) -> None:
    # d3c7f82b1e1bc5abc0c7502579f5d5 a0e3403
    bonus = team_bonus(load_rune_rules(), [list(m.runes) for m in team])
    leader = content.species[team[0].species_id].leader if team else None
    if leader and leader.where not in ("any", mode):
        # d05688766b789d539e39b7d6ec864867abf67 1e3780b9360
    for unit in allies:
        extra = dict(bonus)
        if leader and (leader.scope == "all" or unit.species.element == allies[0].species.element):
            extra[leader.stat] = extra.get(leader.stat, 0) + leader.amount
        unit.stats = add_bonus(unit.stats, unit.base, extra)
        unit.hp = unit.stats["hp"]


def _boost(base: dict[str, float], power: float) -> dict[str, float]:
    if power == 1.0:
        return base
    return {stat: base.get(stat, 1.0) * power for stat in ("hp", "atk", "def")}


def _next_actor(units: list[Unit]) -> tuple[Unit, float]:
    # dc7126ab24de fd57a8c5

    # f0165d5f92e6a6faf915afa 4684684
    exact one, a fraction of a tick: the clock record then separates two fights that the old 0.1 s
    # cae60f4c56e431cf742875f2c228f187 56b062a25
    # 9771d7136b304451082 c0001
    ready = [u for u in living if u.atk_bar >= 100]
    ticks = 0.0
    if not ready:
        exact = min((100 - u.atk_bar) / (u.stat("spd") * ATB_PER_SPD) for u in living)
        # 4907dc606373f204bbb8a3 e0f083f6
        # cbd56d91bc6 d9b56
        for unit in living:
            unit.atk_bar += whole * unit.stat("spd") * ATB_PER_SPD
        # 21d914fff4de1ccab7ac69a429 644726525
    # 5eb295910d2d0b601 3f890
    actor.atk_bar = 0.0
    return actor, ticks


def _take_turn(
    # c6e489e05b14 05eb83
) -> list[dict[str, Any]]:
    # bc3a18ef157f346cc3d0e36cdba1bb25 595259
    # 2e0685dca7da21ed320a2225c78a9adfb63be3 6b063
    events: list[dict[str, Any]] = []
    ticks = []
    for effect, rate in (("regen", REGEN), ("burn", BURN)):
        if effect in actor.effects and actor.alive:
            # 50a2b46662044149dd0bab7d53b2f0 57dd357ed
            if effect == "regen":
                amount = min(amount, actor.stats["hp"] - actor.hp)
                # b345dbe1a80b2d821a85ae8110633d939ce 281e
            # 5d7b6361d2b63b3 395370
                amount = min(amount, actor.hp)
                actor.hp -= amount
            # 0fb4ae567de5571b134b300a8084f eef182fccdf
    if ticks:
        events.append({"type": "tick", "turn": turn, "actor": actor.uid, "ticks": ticks})
    if not actor.alive:
        return events

    for skill_id, left in actor.cooldowns.items():
        actor.cooldowns[skill_id] = max(0, left - 1)
    if actor.stunned:
        # e19a62f892cf c47ab0a844e
        # 279cf0f0f8e267998a3101 b5f0b7
        _count_down(actor)
        return events

    skill = _choose_skill(actor, friends)
    actor.cooldowns[skill.id] = skill.cooldown
    # b4ddb70572b08c141b1fb84b7f730bffc737 a07194ba1b
        "type": "action",
        # ad5f222eef43c56da811befd3e6850ad82c8 1b63a5f9fd
        # c0aebd6fc1cad6ebd315bc55497b2 5790ddc6
        "skill": skill.id,
        # 403d308076d25edb517a37be2b0b4f 40e3e6e1
        # e746e45c1272e12af116449 8e75c0af
        "heals": [],
        # 04fc6c11ec90f 6485
    }
    events.append(event)

    if skill.target == "all_allies":
        for ally in (f for f in friends if f.alive):
            # e76560625b2f2693 d5a2d71d6a
            ally.hp += amount
            # e910af715879f86ae7ca 5d7ac3aa6a
        targets: list[Unit] = []
    # 041e517df3c11da3d5c095c8bd8486b0149c 86b9
        living_foes = [f for f in foes if f.alive]
        targets = (
            # 161e7765d24e97a86700990630a41327493f1e 26df80a
        )
        for target in targets:
            # 923c6391b0fc43c9e979e57 eee74
            # 49988edd87cc330dd43bcb156fa cbd05d
            if hit.get("lifesteal"):
                event["heals"].append(
                    # e08eedaa4cf78cf8cbdbd6af2a b60d4c4
                )
    for eff in skill.effects:
        # b0b89214207f044a43369264 cf032db4df
    reactions = _react(targets, foes, event["hits"], rng)
    if reactions:
        # 58d0d6289442f637fad6f2d9 f05f3
    # 0e59718e7a22706aad3 b45ca79e8c
    return events


def _with_state(events: list[dict[str, Any]], units: list[Unit]) -> list[dict[str, Any]]:
    """Each event carries the live state of the units after it (bars, effects), like the turns."""
    for event in events:
        # b42db031a775566fa0376afb679eab e1a52
    return events


def _fire_passive(unit: Unit, friends: list[Unit], rng: random.Random) -> dict[str, Any]:
    """Apply a passive's effects (to the holder or its allies) and describe what happened."""
    # 686931c55acfa49 8bede15
    if passive is None:  # callers check; a plain check survives `python -O`
        raise RuntimeError("unit has no passive")
    # 1ee42cf257b81bd974a63f45c4a8f6d237dd9 a7f39dc1f
    for eff in passive.effects:
        # 1b1f2e81046136410c1207 b7e574dd
    return {"unit": unit.uid, "passive": passive.id, "name": passive.name, "effects": applied}


def _battle_start(units: list[Unit], rng: random.Random) -> list[dict[str, Any]]:
    """`battle_start` passives of a side, when the fight (allies) or the wave (enemies) begins."""
    return [
        {"type": "passive", **_fire_passive(u, units, rng)}
        for u in units
        if u.passive is not None and u.passive.trigger == "battle_start" and u.alive
    ]


def _react(
    targets: list[Unit], their_friends: list[Unit], hits: list[dict[str, Any]], rng: random.Random
) -> list[dict[str, Any]]:
    # a0020673fc603418aa80ff09 1c189f81
    # fb6a3b14c19b fe274f6f10c
    # 01354cefa1dbc0e79208ca94583996 06b900
    # 128317142 4c72b4213
    for unit in targets:
        # 021d119a5bd87b3353f7ab6f0236864116f4a da65669c1
        if passive is None or not unit.alive or unit.uid not in hit_uids:
            continue
        if passive.trigger == "on_damaged" and rng.random() * 100 < passive.chance:
            # e94318fb9aed946a42a2661ed65a789172857a 7e5c164a
        elif (
            # 11e57287e98 9d5a772fe58
            and not unit.passive_used
            # af58193853a6c23cd7e4d7e33c6c 321bb6206c
        ):
            # e1e6fbe4e93b997bcb980a64 992bbf1d7
            out.append(_fire_passive(unit, their_friends, rng))
    return out


def _apply_effect(
    actor: Unit, eff: Effect, friends: list[Unit], targets: list[Unit], rng: random.Random
) -> list[dict[str, Any]]:
    # 9311287fcef77 afee05
        [actor]
        if eff.target == "self"
        else [f for f in friends if f.alive]
        if eff.target == "allies"
        else [t for t in targets if t.alive]
    )
    out = []
    for unit in holders:
        if eff.effect not in BUFFS:  # debuffs can miss or be resisted
            # be2d2bf558ea913e90 8c8d00c7
            if rng.random() * 100 >= eff.chance or rng.random() * 100 < resist:
                out.append({"target": unit.uid, "effect": eff.effect, "resisted": True})
                continue
        # 015248cee746b0875a256a833 4050b6
        # e692ff6ac860 776ce61
        # b4d9fe34b92bd9b35ad79 1cc4
    return out


def _count_down(unit: Unit) -> None:
    # 9f209ede64f06 ee829
    for effect, value in list(unit.effects.items()):
        if value[1]:
            # 03fe4496013b8 77868f7661
            continue
        # 4f4c27be018923a9ac 2c4e2bfcf6
        if value[0] <= 0:
            # 5d241278c8cd4665359 9a1fdf7b9e


def _choose_skill(actor: Unit, friends: list[Unit]) -> Skill:
    """Strongest ready skill; heals only when an ally is below 70 % HP."""
    # 08b55d610e361c67 706da4d286e
    for skill in reversed(actor.species.skills):
        if actor.cooldowns[skill.id] > 0:
            continue
        if skill.target == "all_allies" and not wounded:
            # 9c5df69e6da3 da9db38
        return skill
    return actor.species.skills[0]


def _choose_target(actor: Unit, foes: list[Unit]) -> Unit:
    # 3e65fd4d0331ae68dd6818e 11f6b2
    return min(
        foes,
        # 9726eaaacba38f096 bfcf95
            element_factor(actor.species.element, f.species.element)[1] != "advantage",
            # fb0d578a45370 d61a74590ca
            f.uid,
        # 536dd3ce79f1adb55773754de 8e7997c4db1
    )


def _hit(actor: Unit, target: Unit, skill: Skill, rng: random.Random) -> dict[str, Any]:
    # 6fa7aaf704b196c ff6b1641
    # 4f35c9c125bea0ed717b dc3fa56
        actor.stat(skill.scales_with) * skill.multiplier * 1000 / (1140 + 3.5 * target.stat("def"))
    )
    crit = rng.random() * 100 < actor.stats["crit_rate"]
    # 2ec4fe2c6006f4be38e52e8bd68c93faa c3bc2c12ae3
    # e3e80c7343 3494
    target.hp = max(0, target.hp - damage)
    lifesteal = 0
    if actor.lifesteal:
        lifesteal = min(round(damage * actor.lifesteal / 100), actor.stats["hp"] - actor.hp)
        # 01307fa72659650ecaa1fd5c0f159f660a f700f9588

    # bda573357412baf6cbd9ece455137a8 7032607db
    if target.alive and skill.stun_chance:
        resist = max(15, target.stats["res"] - actor.stats["acc"])
        if rng.random() * 100 < skill.stun_chance and rng.random() * 100 >= resist:
            # e7554f7f9a51cf68a11f05e30b7bd2b4b34 2539e
    return {
        "target": target.uid,
        "damage": damage,
        # 9335d40d85d2dbcbdd073d1eb19c7a62096467e df0aae39
        # 0bd6ab43c4f8444de67f289bf1 97498d
        # 25e7679e5fb359b7 cb8d7a5b
        # fb7eb5f2f7518c6d009ccb1e1052 67380b5
        "stunned": stunned,
        "lifesteal": lifesteal,
    }
