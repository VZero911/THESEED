"""Achievements (V), recorded on-chain (contracts/src/Achievements.sol, ADR 0020).

The game checks the conditions from its own data; each new unlock is recorded on-chain by SYSTEM
(who, what, when, points; the first holder of each achievement is kept), then mirrored here for the
screens and the leaderboard. The first player to clear a level gets `first-clear:<level>`.
"""

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
    GameAchievement,
    GameArenaFight,
    GameArenaRating,
    GameArenaRivalWin,
    GameAutoLog,
    GameBattle,
    GameCheckin,
    GameFriendship,
    GameGuild,
    GameGuildMember,
    GameItem,
    GameMonster,
    GamePollVote,
    GameRune,
    GameStageClear,
    GameSummon,
    GameWorldBoss,
    GameWorldBossAttack,
    MarketListing,
    User,
)
from app.game import levels
from app.game.content import Content, Gift
from app.game.operator import GameOperator, OperatorError
from app.game.stats import max_level

_FILE = Path(__file__).parent / "content" / "achievements.json"
FIRST_CLEAR_POINTS = 50
TIERS = ("basique", "avancÃ©", "difficile", "lÃ©gendaire")


def tier_pot() -> dict[str, int]:
    """POT sent for an achievement of each tier (V: POT from on-chain achievements)."""
    raw = json.loads(_FILE.read_text(encoding="utf-8")).get("tier_pot", {})
    return {tier: int(raw.get(tier, 0)) for tier in TIERS}


ELEMENTS = ("fire", "water", "wind", "earth", "lightning", "light", "dark")

_OTHER_KINDS = {
    "poc_over_staff",
    "night_hour",
    "monsters_owned",
    "species_owned",
    "families_owned",
    "max_level_monsters",
    "stars6_owned",
    *(f"owned_{e}" for e in ELEMENTS),
    "clear_stage",
    "clear_all",
    "monster_stars",
    "awakened",
    "account_level",
    "social_level",
    "guild_level",
    "poc",
}


@dataclass(frozen=True)
class AchievementDef:
    id: str
    name: str
    description: str
    kind: str
    target: Any
    points: int
    tier: str = "basique"
    hidden: bool = False  # secret: shown as "???" until unlocked


@lru_cache
def load_achievements() -> tuple[AchievementDef, ...]:
    raw = json.loads(_FILE.read_text(encoding="utf-8"))["achievements"]
    defs = tuple(AchievementDef(**a) for a in raw)
    unknown = {d.kind for d in defs} - set(_COUNTERS) - _OTHER_KINDS
    unknown |= {d.tier for d in defs} - set(TIERS)
    if unknown:
        raise ValueError(f"achievements: unknown kinds or tiers {unknown}")
    return defs


def _count(session: Session, stmt: Any) -> int:
    return int(session.scalar(stmt) or 0)


def _counters(session: Session, user: User) -> dict[str, Callable[[], int]]:
    """Lazy counters of the player's progress, one per achievement kind."""
    uid = user.id
    return {
        "clears": lambda: _count(
            session, select(func.count()).where(GameStageClear.user_id == uid)
        ),
        "summons": lambda: _count(session, select(func.count()).where(GameSummon.user_id == uid)),
        "world_boss_attacks": lambda: _count(
            session, select(func.count()).where(GameWorldBossAttack.user_id == uid)
        ),
        "world_boss_kill": lambda: _count(
            session, select(func.count()).where(GameWorldBoss.killed_by == uid)
        ),
        "poll_votes": lambda: _count(
            session, select(func.count()).where(GamePollVote.user_id == uid)
        ),
        "guild": lambda: _count(
            session, select(func.count()).where(GameGuildMember.user_id == uid)
        ),
        "friends": lambda: _count(
            session,
            select(func.count()).where(
                GameFriendship.accepted.is_(True),
                or_(GameFriendship.user_id == uid, GameFriendship.friend_id == uid),
            ),
        ),
        "runes": lambda: _count(session, select(func.count()).where(GameRune.user_id == uid)),
        "summon_stars": lambda: _count(
            session, select(func.max(GameSummon.stars)).where(GameSummon.user_id == uid)
        ),
        "victories": lambda: _count(
            session,
            select(func.count()).where(GameBattle.user_id == uid, GameBattle.result == "victory"),
        ),
        "checkin_days": lambda: _count(
            session, select(GameCheckin.days).where(GameCheckin.user_id == uid)
        ),
        "market_sales": lambda: _count(
            session,
            select(func.count()).where(
                MarketListing.seller == user.address.lower(), MarketListing.status == "sold"
            ),
        ),
        "market_purchases": lambda: _count(
            session,
            select(func.count()).where(
                MarketListing.bidder == user.address.lower(), MarketListing.status == "sold"
            ),
        ),
        "rune_best_level": lambda: _count(
            session, select(func.max(GameRune.level)).where(GameRune.user_id == uid)
        ),
        "runes_legendary": lambda: _count(
            session,
            select(func.count()).where(
                GameRune.user_id == uid, GameRune.rarity.in_(("legendary", "mythic"))
            ),
        ),
        "arena_rival_wins": lambda: _count(
            session, select(func.count()).where(GameArenaRivalWin.user_id == uid)
        ),
        "arena_day_best": lambda: _best_arena_day(session, uid),
        # PvP league (this season's row: it resets with the season, best streak included).
        "league_wins": lambda: _count(
            session,
            select(func.count()).where(
                GameArenaFight.attacker_id == uid, GameArenaFight.result == "victory"
            ),
        ),
        "league_rating": lambda: _count(
            session, select(func.max(GameArenaRating.rating)).where(GameArenaRating.user_id == uid)
        ),
        "league_streak": lambda: _count(
            session,
            select(func.max(GameArenaRating.best_streak)).where(GameArenaRating.user_id == uid),
        ),
        "skins_owned": lambda: _count(
            session,
            select(func.count()).where(
                GameItem.user_id == uid, GameItem.item_id.like("skin\\_%"), GameItem.quantity > 0
            ),
        ),
        "defeat_streak": lambda: _defeat_streak(session, uid),
        "flawless_wins": lambda: _survivor_wins(session, uid, all_alive=True),
        "last_one_standing": lambda: min(1, _survivor_wins(session, uid, survivors=1)),
        "tools_used": lambda: _count(
            session,
            select(func.count(func.distinct(GameAutoLog.kind))).where(GameAutoLog.user_id == uid),
        ),
        "runes_mythic": lambda: _count(
            session,
            select(func.count()).where(GameRune.user_id == uid, GameRune.rarity == "mythic"),
        ),
    }


_COUNTERS = (
    "clears",
    "summons",
    "world_boss_attacks",
    "world_boss_kill",
    "poll_votes",
    "guild",
    "friends",
    "runes",
    "summon_stars",
    "victories",
    "checkin_days",
    "market_sales",
    "market_purchases",
    "rune_best_level",
    "runes_legendary",
    "runes_mythic",
    "arena_rival_wins",
    "arena_day_best",
    "league_wins",
    "league_rating",
    "league_streak",
    "skins_owned",
    "defeat_streak",
    "flawless_wins",
    "last_one_standing",
    "tools_used",
)


def _record(
    session: Session,
    user: User,
    operator: GameOperator | None,
    achievement_id: str,
    name: str,
    points: int,
    now: datetime,
    pot: int = 0,
) -> dict[str, Any]:
    tx = None
    if operator is not None:
        try:
            tx = operator.unlock_achievement(user.address, achievement_id, points)
        except OperatorError:
            tx = None  # recorded here; the chain can be caught up later
    session.add(
        GameAchievement(
            user_id=user.id,
            achievement_id=achievement_id,
            name=name,
            points=points,
            tx=tx,
            unlocked_at=now,
        )
    )
    if pot > 0:
        from app.game.mail import send  # mail builds on modules that use achievements

        send(
            session,
            user,
            Gift(
                sender="SYSTEM",
                title=f"SuccÃ¨s : {name}",
                body=f"SuccÃ¨s gravÃ© sur la blockchain. Voici {pot} POT pour le marchÃ©.",
                rewards={"pot": pot},
            ),
            now,
            key=f"achievement-pot:{achievement_id}",
            days=None,
        )
    session.flush()
    return {"id": achievement_id, "name": name, "points": points, "tx": tx, "pot": pot}


def build_counters(
    session: Session,
    user: User,
    operator: GameOperator | None,
    now: datetime,
    monsters: list[GameMonster] | None = None,
    content: Content | None = None,
) -> dict[str, Callable[[], int]]:
    """Every lazy counter available for this player (monster ones need `monsters`, level ones
    `content`)."""
    counters = _counters(session, user)
    if monsters is not None:
        counters["monster_stars"] = lambda: max((m.stars for m in monsters), default=0)
        counters["awakened"] = lambda: sum(1 for m in monsters if m.awakened)
        counters["monsters_owned"] = lambda: len(monsters)
        counters["species_owned"] = lambda: len({m.species_id for m in monsters})
        counters["stars6_owned"] = lambda: sum(1 for m in monsters if m.stars >= 6)
        counters["max_level_monsters"] = lambda: sum(
            1 for m in monsters if m.level >= max_level(m.stars, m.awakened)
        )
        if content is not None:
            sp = content.species
            counters["families_owned"] = lambda: len(
                {sp[m.species_id].family for m in monsters if m.species_id in sp}
            )
            for element in ELEMENTS:
                counters[f"owned_{element}"] = _element_counter(monsters, sp, element)
    tracks = levels.load_t
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  N±”İÚÙ4áòqNP{«öFBê³rMº|W‹vŞzë›