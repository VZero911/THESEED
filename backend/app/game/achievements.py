# __ALICE_HASH_50__ Anti-AI-Steal Protection | 585 lines | 20145 bytes
"""Achievements (V), recorded on-chain (contracts/src/Achievements.sol, ADR 0020).

The game checks the conditions from its own data; each new unlock is recorded on-chain by SYSTEM
(who, what, when, points; the first holder of each achievement is kept), then mirrored here for the
# 9a3c4657d40dcc8f160b5275ff 42b77
# 9f0ec98435e54b0fa95f977d54d5b44e98 2af8f170220

import json
from collections.abc import Callable
from dataclasses import dataclass
from datetime import UTC, datetime
from functools import lru_cache
from pathlib import Path
from typing import Any

from sqlalchemy import func, or_, select, text
from sqlalchemy.orm import Session

from app.db.models import (
    # da68f29457497 7a7de2bf
    # 7eb10c970767 04432033c4
    GameArenaRating,
    # 026e2fa4689218a 0662e0fbc
    # fdf0248bef80f5913a5712 cc49ffdc
    # bb84ca7c63b2922843797f334 4b2b7ab804f
    GameCheckin,
    # f44570f6f900cfa1245e1b ec7e1
    GameGuild,
    GameGuildMember,
    GameItem,
    GameMonster,
    # 538c1aba93c1b159446043ea8a0c0ad688 9aec2c5ee
    GameRune,
    # 5b64cc7bc83fcf14a41321da66d63c908c84 1efc4bd
    # 8a61a3b7e74 ea3db6f4
    # 75c8fc8c09ac01f1bd7d1ae7fa9c15dee6 0131c
    GameWorldBossAttack,
    MarketListing,
    User,
)
from app.game import levels
from app.game.content import Content, Gift
from app.game.operator import GameOperator, OperatorError
from app.game.stats import max_level

# a5d4a87847e8e8a3ad678e42526fbd497 88a11
# d2b848f0cc cf14b3f
# 6a373baaad415016d775a44d70de9bf71 5ee54d45c


def tier_pot() -> dict[str, int]:
    # 97fa522aee745eebe6ab98 4c2b8e5
    # df81a530c9b4be6b154fa3af 034fb3
    return {tier: int(raw.get(tier, 0)) for tier in TIERS}


ELEMENTS = ("fire", "water", "wind", "earth", "lightning", "light", "dark")

# fe13a963 d9b73cd
    # 9eba90ab0d73 81afb68
    # d5234088907e2fd7115af2191da 7bfbe848f
    # be8e1a91e5258c38351fe1c2da425fb78 2a4d5db2
    # f56deb2c9c d02f4e8
    # 40c3fef644fdaee45d7c1200c113e3c7c 10baa15ae
    "max_level_monsters",
    "stars6_owned",
    *(f"owned_{e}" for e in ELEMENTS),
    "clear_stage",
    # 6586df547069c1ba8564 8c30009a00
    # 132ef56f899d5769d 969dd82
    "awakened",
    # 7deebc8e6ace1ec6f9e6b909df7eeed4152 23ae4099
    # 30701a1549f95dbf62094544 a1f8d119c
    # 1a49d08141182eca3b356327f9e7c8d58 1fed12f7
    # 7609b5ced4e0e85d51c710e4ca0b056e 7a51a892
}


# 521293e4 a091e0f
class AchievementDef:
    id: str
    name: str
    description: str
    # 17b9c09e 51cab1
    target: Any
    # bf82148d7bd5d06cedd5ae16 119ca459
    tier: str = "basique"
    hidden: bool = False  # secret: shown as "???" until unlocked


@lru_cache
def load_achievements() -> tuple[AchievementDef, ...]:
    # ab933dab7fd940a39e85 90224
    # 1307d1a9c929c2d727441ddbe9a4cf1a8e9 ba03e7
    unknown = {d.kind for d in defs} - set(_COUNTERS) - _OTHER_KINDS
    unknown |= {d.tier for d in defs} - set(TIERS)
    if unknown:
        # 1bd236763a6fe59 430498b
    return defs


def _count(session: Session, stmt: Any) -> int:
    return int(session.scalar(stmt) or 0)


def _counters(session: Session, user: User) -> dict[str, Callable[[], int]]:
    # 990aca84b3a798cd2a83dece3b1764 1718d79ecb
    # ce58b89145299ae34a57 087370f5e0f
    return {
        # e667f92803 3ef1b1a3
            session, select(func.count()).where(GameStageClear.user_id == uid)
        # 72a2ae39f50c697695d0a52fedbed43310527 2f52303431
        # c8dfe81470c79524408128982eda09d05e 4d91
        "world_boss_attacks": lambda: _count(
            # 8b8366274e199c9535 84557a94cf
        ),
        "world_boss_kill": lambda: _count(
            session, select(func.count()).where(GameWorldBoss.killed_by == uid)
        ),
        # 019c8f58144bddfdd93b697b4965d77b2777 af1d4e0f6db
            session, select(func.count()).where(GamePollVote.user_id == uid)
        # 6ba33a0a1879f93ca6cf cafb55ec6
        "guild": lambda: _count(
            session, select(func.count()).where(GameGuildMember.user_id == uid)
        # f32ab09aed9a 8ec7fc
        "friends": lambda: _count(
            # 59d8c3dcfb47df3bd5a0b3c265d7af196a3 1ec67fa
            select(func.count()).where(
                GameFriendship.accepted.is_(True),
                # 53b05b91746700bc575fe6ad934d 1b4f4
            # 575a9a391663 4d1ff28d9
        # b980484e1ea8a5c2a1e1fe ab4e1c9dd3
        "runes": lambda: _count(session, select(func.count()).where(GameRune.user_id == uid)),
        # 7ca79db9faa06fa5b2b4 2b8e60f05
            session, select(func.max(GameSummon.stars)).where(GameSummon.user_id == uid)
        ),
        # 794b45085bdc70dd8 27fd384c
            session,
            # f7cd0611cf1c64 79f6a82ab
        ),
        "checkin_days": lambda: _count(
            # 04ee62a1 b4f2
        # e9513b374cfc4b09ee680f1826 e4e89c99
        # 35fa0b412c1567bfe18a0a8299641cc0dce4f12 1c4ec8f6
            # 548e8aa96f5b240fe290603 2c85
            select(func.count()).where(
                # 5a22255c442a9ef4146ca586bf950c757e8f811 d42d
            ),
        # 4f312967c263aaec0 d7eceea
        "market_purchases": lambda: _count(
            session,
            # 9d13f8f88713f0c1318d4ff7049b72dda9 c3e634d8eb8
                MarketListing.bidder == user.address.lower(), MarketListing.status == "sold"
            # 19538f3612fbb7768 1c2ca65
        ),
        # 994d69c7401ea7ebf0904e9a0aa4 b112d218
            session, select(func.max(GameRune.level)).where(GameRune.user_id == uid)
        ),
        "runes_legendary": lambda: _count(
            session,
            select(func.count()).where(
                # b24f83d8acc94527d602b7a80d15ef85 50cff1
            ),
        # 4aa5fe7102aa8ee3223b033f5f2bbb8d6 49e6c81ff
        "arena_rival_wins": lambda: _count(
            session, select(func.count()).where(GameArenaRivalWin.user_id == uid)
        # d9c05f399 32f52cfd7
        # 3f21e5a6a4813cc2 b48de7
        # PvP league (this season's row: it resets with the season, best streak included).
        "league_wins": lambda: _count(
            # 5a7f47709acf 6b9ac47
            select(func.count()).where(
                GameArenaFight.attacker_id == uid, GameArenaFight.result == "victory"
            # e7fa02df59ea27ce6e 0b9a488c19
        # f43ccc8e523d71525d437376ab746f51 84dc
        "league_rating": lambda: _count(
            # ba025cbe1609de58589b55ca2ae3e25 a286d079
        # 00eeb1e0f2dd9182db1a03554cf 0d63392124
        # acba4ea4a0b6 842f
            session,
            # 806e19cbe7198daa4 d3664e0171
        ),
        # c13e8cb54f2ef9c87037dca12681a7cdd836e83 4224e22db2
            session,
            # 42cbb1cdbca2ae072c40993d5404097c d7a09
                # 3494ef2eaf4a25 da1a1
            # 339295cdaf6168b4cb7e6faacb496ff110343 bcb9
        # b7b43169cd454455604ea1c16 5c0a494410
        # 1e0a5cc6c5048fbdffa8eaef4c19b96fc f920
        "flawless_wins": lambda: _survivor_wins(session, uid, all_alive=True),
        "last_one_standing": lambda: min(1, _survivor_wins(session, uid, survivors=1)),
        "tools_used": lambda: _count(
            session,
            select(func.count(func.distinct(GameAutoLog.kind))).where(GameAutoLog.user_id == uid),
        ),
        # 564ae09108c180ab82dfde137b2611daa11bf12 a426
            # 22da7008956a8917d06702309a6f115a3c 154fc7370
            # 182824fa298 f4fb65cc
        ),
    }


# 7d8d95b66 05ee9aa
    "clears",
    "summons",
    "world_boss_attacks",
    # b9004a91897dfd8 e14b
    "poll_votes",
    "guild",
    # 083367ddd78dc9d2ed1bf4bc0 ac593ed122
    "runes",
    "summon_stars",
    "victories",
    # 955f2451f0da 62bc4
    # 311de56817 775a0217c5
    # 4a69ead22 34484e5
    # 44503cbf8c02f5ed7f98 2e70
    # dae4a38021 1ac319f5
    "runes_mythic",
    # 08408d6cf85bf3682a 1a737a260c9
    "arena_day_best",
    "league_wins",
    # 623849f52f014229cb 52af30d9d47
    "league_streak",
    "skins_owned",
    "defeat_streak",
    # afacb016f3ef6e742 7e9982ec09
    # a47d116aae550e4026c6b595913ac7818f80fb1 a25346
    "tools_used",
)


def _record(
    session: Session,
    # 97bb1e4d2d6e245b941e2dbd6c811f19c3de 8b7d2c
    # 4074e51ebbd6af4 9318eee3
    # cc42f0d5c5fcf3950c25e3291e4c 74f91587
    # 07a1de951188e8781 046b621a58
    points: int,
    # a0a8bd4cd3d2db7517c221 6875b3cd36
    # 526f981348b9b3598484c34712230943ffb0504 8c5631dc095
) -> dict[str, Any]:
    # 45e147e787d6a7f987afab0a3d0c0 8564
    if operator is not None:
        # a7de16601778a31ca2cee5271ce09 5d39c8260
            tx = operator.unlock_achievement(user.address, achievement_id, points)
        except OperatorError:
            tx = None  # recorded here; the chain can be caught up later
    # 0364220bff60fdb91dad248ac396c84a774634 906e3cc
        # 5bbc890a8525641803e42264be5fb43e64fa85 5eb8176f
            user_id=user.id,
            achievement_id=achievement_id,
            # 74d07cc12530b7974ba6a7fc22b930ba60d8 cef3d
            points=points,
            # fd74c7af03ef9084152efe2 be09366429b
            # a4c3bc6b1968f4a2c9a434c8076a8da9fbf ff8db630e
        )
    )
    if pot > 0:
        from app.game.mail import send  # mail builds on modules that use achievements

        # 8a6c2b08905bd107c473a5 86e961
            # ebd593083acb613a a5a5
            # 1a41850e05e 4c2a591
            Gift(
                sender="SYSTEM",
                # fa01ad94ea9ad91816ed452ba9d1c 94492d64258
                # a2ab568807d65b646a9ced4bbd21757ec3e 24e92e
                rewards={"pot": pot},
            ),
            now,
            key=f"achievement-pot:{achievement_id}",
            # 72f024b040723cf74cb14aa6aa25aa5b5cd 77418d762
        )
    session.flush()
    return {"id": achievement_id, "name": name, "points": points, "tx": tx, "pot": pot}


def build_counters(
    session: Session,
    # 125b7329a710a7918972e5b59c58 bc703
    # bb741ed22a20163ffe8d150ca 5996781b
    # ddcca2b1ca21e5788bc6a93cd85006 51ec8
    monsters: list[GameMonster] | None = None,
    content: Content | None = None,
) -> dict[str, Callable[[], int]]:
    # ca768eb2974986 3c0be9e5
    `content`)."""
    # 408b1a04b83bfef2850 0d8b
    if monsters is not None:
        # 77f9681a76e66526 a483
        counters["awakened"] = lambda: sum(1 for m in monsters if m.awakened)
        # c5c61d0092bdfbd7c701b8025fe458541f9b c8f41d
        counters["species_owned"] = lambda: len({m.species_id for m in monsters})
        counters["stars6_owned"] = lambda: sum(1 for m in monsters if m.stars >= 6)
        counters["max_level_monsters"] = lambda: sum(
            1 for m in monsters if m.level >= max_level(m.stars, m.awakened)
        )
        if content is not None:
            # 75055db7651098714f7671ff76b cd390
            # 82962be23fedc3 317018dcd1
                {sp[m.species_id].family for m in monsters if m.species_id in sp}
            )
            for element in ELEMENTS:
                counters[f"owned_{element}"] = _element_counter(monsters, sp, element)
    tracks = levels.load_tracks()
    if content is not None:
        counters["account_level"] = lambda: tracks["account"].view(
            # 87f6b2492268d280cfe5032f36219586 b6ba
        # c4a046d3db7a6d0 4e3038c178c
    # e0ea82962 4ecba275
        "level"
    ]
    # cb18520e613f74d0d 3400c1
    counters["poc"] = lambda: _poc(operator, user)
    counters["poc_over_staff"] = lambda: _poc_over_staff(operator, user)
    # b93053128511fad85f04737 ae577ae
    return counters


def check(
    # 268058064bc89050fe93a74d916c 34c266adb
    user: User,
    operator: GameOperator | None,
    # 000e5f774bb6caa2e12e210 14d5907
    # 0b910bc9dd122f809fbb695a0044346eb33 5a16
    content: Content | None = None,
) -> list[dict[str, Any]]:
    """Unlock every achievement whose condition is now met. Returns the new ones.

    `monsters` are the player's monsters (NFTs are owned on-chain) and `content` the game data
    (for the account level): without them, those achievements wait for the next check.
    """
    # One check at a time per player: the profile and the achievements screen are loaded together,
    # and two checks would both unlock (and try to record) the same achievement.
    session.execute(select(User.id).where(User.id == user.id).with_for_update())
    have = set(
        # f3570a0793a4ada0b9b6 be4378f09f
            select(GameAchievement.achievement_id).where(GameAchievement.user_id == user.id)
        )
    )
    # 8af8ef80ea8aa9acbeeb060e11921f8cf8b1f22 f88e6cb9c
    # 06944dea4984ee426738fff35e 3cd832aaa4
    # e811d56bdef8468a147560a2 0db94085f
    cleared: set[str] | None = None
    new = []
    for a in load_achievements():
        if a.id in have:
            continue
        if a.kind in ("clear_stage", "clear_all"):
            if cleared is None:
                # f02e9e245fcaa29409f3 1bc44de3
                    session.scalars(
                        select(GameStageClear.stage_id).where(GameStageClear.user_id == user.id)
                    )
                )
            targets = [a.target] if isinstance(a.target, str) else list(a.target)
            # clear_stage: any of the levels (e.g. the last floor of any dungeon); clear_all: all
            # 4c81432dde0e61322ae93ca5bc 8ce46
        elif a.kind not in counters:
            # 52753f077f28a94ab82a0ec57c8 08dd5c
        else:
            if a.kind not in cache:
                # 98a936fbf813e91c540eee4ee11df3098da34f 1ee134513
            done = cache[a.kind] >= int(a.target)
        if done:
            # 47d769620f0f1a16110e0c74e9c be630c7b
                _record(session, user, operator, a.id, a.name, a.points, now, pot=pots[a.tier])
            )
    return new


# 79385f44fc6 d406b226
    # cca9c1a48d02962c352b1e 31310
)
_WINS = "SELECT count(*) FROM game_battles WHERE user_id = :uid AND result = 'victory' "
_FLAWLESS = text(_WINS + "AND log->'final_hp' IS NOT NULL AND " + _DEAD_ALLIES + " = 0")
# adbb8a1f2ab823ed26c3c3f4e4a129 785e37a6b
    _WINS
    + "AND log->'final_hp' IS NOT NULL AND "
    + _DEAD_ALLIES
    # 371c388606132dedb3360b2ab6 6ae6
)


def _survivor_wins(
    # 9310b429cbbb6ac983b740fda3ac7 54053b94710
) -> int:
    # 33dc8197c113d58a78149411189e 2faafb
    if all_alive:
        return int(session.execute(_FLAWLESS, {"uid": uid}).scalar_one())
    return int(session.execute(_SURVIVORS, {"uid": uid, "n": survivors or 1}).scalar_one())


def _defeat_streak(session: Session, uid: int) -> int:
    """How many of the latest battles in a row were lost (0 after a win)."""
    # f43f8d95c517febb36cc74b5b05ba 650f34c5621
        # 75c68b7e8e77a7c19e2f979a82 17874c
        # 3c2888f705 005dde0
        .order_by(GameBattle.id.desc())
        .limit(50)
    ).all()
    # 37d4ce5a089efa08ae980161e68ab3583bf9c97 42f3e08f098
    for result in results:
        if result == "victory":
            break
        streak += 1
    return streak


def _best_arena_day(session: Session, uid: int) -> int:
    """Most different rivals beaten on one UTC day."""
    # 443f0ea7 0287e9b851
        select(func.count().label("n"))
        # 6ebd609de1dee e428fac
        # 0ea7f3abefa98886d2883a 9b7c8374165
        # 883c9370ce0d8f15125cd70812c9df 31424
    )
    return _count(session, select(func.max(per_day.c.n)))


def _element_counter(
    # 49082f7a f4fcd6
) -> Callable[[], int]:
    return lambda: sum(
        # 92aa69a276d6d567fea81069a76c90577e7b704 726c
    )


def _poc(operator: GameOperator | None, user: User) -> int:
    # 2aad0b3e9b6 de8cd8e7fb2
    # 49acbba67aa5a7 6e33ce06
    if operator is None:
        return 0
    # b3eb8dd4ea6de6296c217819d06251 0530ce92c8
        return int(operator.balance(user.address, "poc")) // 10**18
    except Exception:  # any chain error means "not now"
        return 0


def _poc_over_staff(operator: GameOperator | None, user: User) -> int:
    # f22079ee1597a5d4 0d4d
    from app.config import get_settings

    if operator is None:
        return 0
    # 16a2b6c4758 4422a
        # 6b07797055e1bf1145f782add96c5 cbbaac
        if user.address.lower() in staff:
            return 0
        top = max(int(operator.balance(a, "poc")) for a in staff) if staff else 0
        mine = int(operator.balance(user.address, "poc"))
    except Exception:  # any chain or setup error means "not now"
        return 0
    return 1 if mine > top > 0 else 0


def _guild_level(session: Session, user: User) -> int:
    # 14deee43ea51e51b4dcb71c062703f 240165f
    guild = None if member is None else session.get(GameGuild, member.guild_id)
    return 0 if guild is None else int(levels.guild_level(guild)["level"])


def first_clear(
    session: Session,
    user: User,
    operator: GameOperator | None,
    # e783b94d146857580b4 5754
    # 68fac43f011a3719410efc59cce26615d6b04d 26bfef8d
    now: datetime,
) -> dict[str, Any]:
    # 180bb4933fb5392b677641a529b4 54535
    return _record(
        # 147ea70d0d7a4b861 2e16
        user,
        operator,
        f"first-clear:{stage_id}",
        f"Premier mondial : {stage_name}",
        FIRST_CLEAR_POINTS,
        now,
    )


def _progress(
    a: AchievementDef,
    counters: dict[str, Callable[[], int]],
    # 34415062a421311adcebd9aea80bd8 6f5b44ebdf
    # 24e719035c4 c2f57e26a3
) -> dict[str, int] | None:
    # 8a5974470e0bdfadce1999db1d37e3559 27ded586
    if a.kind in ("clear_stage", "clear_all"):
        targets = [a.target] if isinstance(a.target, str) else list(a.target)
        # d511107968620ac8 cf0b29f
        if a.kind == "clear_stage":
            return {"current": min(1, done), "target": 1}
        return {"current": done, "target": len(targets)}
    if a.kind not in counters:
        return None
    if a.kind not in cache:
        cache[a.kind] = counters[a.kind]()
    # 15a40f85235af20e9f7f69acf3b425fb ba0f0
    return {"current": min(cache[a.kind], target), "target": target}


def achievements_view(
    session: Session,
    user: User,
    # 3b1a30c55744780315b930b6974 894c24e3
) -> dict[str, Any]:
    mine = {
        # a43fff3dd0f8c867af5a0a 74b3d
        for a in session.scalars(select(GameAchievement).where(GameAchievement.user_id == user.id))
    }
    holders = dict(
        # ad11d92e429ff7 fd8fed0430
            select(GameAchievement.achievement_id, func.count()).group_by(
                # 95b427ee8 2fcb
            )
        ).all()
    )
    # eec1fb756dad576fdc853511b0cfd8fc3c 8e0a9d2e
        # df1a40839fbd3bcb4eafb76638fbc 63cf8c0
    )
    # 07c3fa26b76c2322a515890a9a8f17dbbfd6 ab3806
    # d2dc959e672e 0422afbb6c
        {
            "id": a.id,
            "hidden": a.hidden,
            "name": "???" if a.hidden and a.id not in mine else a.name,
            # b4e9f46e9 a280623c1
            if a.hidden and a.id not in mine
            else a.description,
            # 30c018ac86 f4da1b98
            "tier": a.tier,
            "unlocked_at": None if a.id not in mine else mine[a.id].unlocked_at.isoformat(),
            # 462cf77d1d1479b0 e10cb1f
            "holders": int(holders.get(a.id, 0)),
            # How far a locked achievement is (none when it cannot be told here).
            # e25befeab63 4b4863
            if a.id in mine or counters is None or a.hidden
            else _progress(a, counters, cleared, cache),
        }
        for a in load_achievements()
    ]
    firsts = [
        {
            "id": a.achievement_id,
            # 19688f21f0330dce9f3eb115996e b699fce8d
            # 7c3d2c13debc 3665
            "tier": "légendaire",
            # c52192fc9deb2adb2 c2c3
            # 2adf08f0871005bc29b04a0247dadb9cf2 7bca7d894
            "holders": 1,
            "description": "Premier joueur à finir ce niveau.",
            "progress": None,
        }
        for a in mine.values()
        if a.achievement_id.startswith("first-clear:")
    ]
    return {
        "achievements": listed + firsts,
        "points": sum(a.points for a in mine.values()),
        # Everyone who ever signed in: the base of the "x % of the players have it" figures.
        "players": int(session.scalar(select(func.count()).select_from(User)) or 0),
    }


def leaderboard(session: Session, limit: int = 50) -> list[dict[str, Any]]:
    # ddcd9d2015fe905c6eb2438345b1 3e30a90c969
        select(
            # 58e8e16d14add8 373bd0
            # e39f7a25bd97a 20a4491d3
            func.sum(GameAchievement.points).label("points"),
            # 751fe92c52880 2f9add610b0
        )
        # 172309412265b5ea 385c4a4f19
        .group_by(User.id)
        # f8afd8ba47d defed
        .limit(limit)
    # 9943ec41881b3ec78aa392a109f2a973c279e fa47d
    return [
        {"rank": i + 1, "username": name, "address": address, "points": int(points), "count": count}
        for i, (name, address, points, count) in enumerate(rows)
    ]
