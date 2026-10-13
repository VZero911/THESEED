"""The PvP league (V, 2026-10-03): asynchronous, players only, 4 monsters on each side.

A player sets a defense of up to 4 monsters. Attackers pick one of 5 opponents near their rating
and fight it with their own team of 4, one arena wing a fight; the server plays both sides (the
defender is offline), runes included. The rating moves like Elo, the defender loses less than the
attacker gains. Seasons last two weeks: at the end, rewards by league are paid once and the ratings
are pulled back toward the start (soft reset). Everything is off-chain: points and chests.
"""

import json
import secrets
from dataclasses import dataclass
from datetime import UTC, date, datetime, timedelta
from functools import lru_cache
from pathlib import Path
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db.models import (
    GameArenaDefense,
    GameArenaFight,
    GameArenaRating,
    GameGuildMember,
    GameMonster,
    User,
)
from app.game.battle import simulate
from app.game.content import Content, EnemySlot, Stage
from app.game.errors import GameError
from app.game.monsters import add_items
from app.game.operator import GameOperator
from app.game.service import get_player, load_team, spend_wings, wings_state

TEAM_SIZE = 4
OPPONENTS = 5
_FILE = Path(__file__).parent / "content" / "arena.json"


@dataclass(frozen=True)
class League:
    id: str
    name: str
    min: int
    reward: dict[str, Any]


@dataclass(frozen=True)
class LeagueRules:
    start_rating: int
    k: int
    placement_fights: int
    placement_k_factor: float
    season_days: int
    epoch: date
    soft_reset: float
    base_rating: int
    defender_loss_share: float
    leagues: tuple[League, ...]


@lru_cache
def load_rules() -> LeagueRules:
    raw = json.loads(_FILE.read_text(encoding="utf-8"))["league"]
    leagues = tuple(
        League(l["id"], l["name"], int(l["min"]), l["reward"])
        for l in raw["leagues"]  # noqa: E741
    )
    if [lg.min for lg in leagues] != sorted(lg.min for lg in leagues) or leagues[0].min != 0:
        raise ValueError("league: thresholds must start at 0 and increase")
    return LeagueRules(
        start_rating=int(raw["start_rating"]),
        k=int(raw["k"]),
        placement_fights=int(raw["placement_fights"]),
        placement_k_factor=float(raw["placement_k_factor"]),
        season_days=int(raw["season_days"]),
        epoch=date.fromisoformat(raw["season_epoch"]),
        soft_reset=float(raw["soft_reset"]),
        base_rating=int(raw["base_rating"]),
        defender_loss_share=float(raw["defender_loss_share"]),
        leagues=leagues,
    )


# ------------------------------------------------------------------ pure rules


def season_of(now: datetime) -> int:
    """The season number of a moment (two weeks each, from the epoch; negative before it)."""
    rules = load_rules()
    return (now.astimezone(UTC).date() - rules.epoch).days // rules.season_days


def season_ends_in(now: datetime) -> int:
    """Seconds until the current season closes (at 00:00 UTC)."""
    rules = load_rules()
    end_day = rules.epoch + timedelta(days=(season_of(now) + 1) * rules.season_days)
    end = datetime(end_day.year, end_day.month, end_day.day, tzinfo=UTC)
    return max(0, int((end - now.astimezone(UTC)).total_seconds()))


def league_of(rating: int) -> dict[str, Any]:
    """The league and division (3 and below, 1 is the best) of a rating; Legend has no division."""
    leagues = load_rules().leagues
    idx = max(i for i, lg in enumerate(leagues) if rating >= lg.min)
    lg = leagues[idx]
    division: int | None = None
    if idx + 1 < len(leagues):
        # Bronze starts where new players start (Bronze 3), the others at their threshold.
        low = lg.min or min(load_rules().start_rating, leagues[1].min)
        third = max(1, (leagues[idx + 1].min - low) // 3)
        division = 3 - min(2, max(0, rating - low) // third)
    return {"id": lg.id, "name": lg.name, "division": division, "index": idx}


def expected_score(own: int, other: int) -> float:
    return 1.0 / (1.0 + 10 ** ((other - own) / 400))


def in_placement(games_played: int) -> bool:
    """A player's first fights of a season are placement fights: their rating moves faster."""
    return games_played < load_rules().placement_fights


def rating_moves(
    attacker: int, defender: int, attacker_won: bool, placement: bool = False
) -> tuple[int, int]:
    """(attacker delta, defender delta): Elo, with the defender losing only part of what the
    attacker wins (V: defending is not a chore), and never below 0. In a placement fight the
    attacker's move is multiplied (the defender's is not): a new player finds their league fast."""
    rules = load_rules()
    expected = expected_score(attacker, defender)
    gain = round(rules.k * ((1.0 if attacker_won else 0.0) - expected))
    boost = rules.placement_k_factor if placement else 1.0
    if attacker_won:
        gain = max(1, gain)
        loss = round(gain * rules.defender_loss_share)
        return round(gain * boost), -min(loss, defender)
    gain = min(-1, gain)
    reward = round(-gain * rules.defender_loss_share)
    return -min(round(-gain * boost), attacker), reward


def soft_reset(rating: int) -> int:
    """New season: pulled part of the way back toward the base rating."""
    rules = load_rules()
    return round(rules.base_rating + (rating - rules.base_rating) * rules.soft_reset)


# ------------------------------------------------------------------ state


def _rating_row(session: Session, user: User, now: datetime) -> GameArenaRating:
    """The player's rating row, created on the first visit and rolled to the current season
    (the finished season's reward becomes due, the rating soft-resets)."""
    rules = load_rules()
    season = season_of(now)
    row = session.get(GameArenaRating, user.id, with_for_update=True)
    if row is None:
        row = GameArenaRating(
            user_id=user.id,
            season=season,
            rating=rules.start_rating,
            wins=0,
            losses=0,
            streak=0,
            best_streak=0,
            updated_at=now,
        )
        session.add(row)
        session.flush()
    elif row.season < season:
        if row.wins + row.losses > 0:
            row.last_season, row.last_rating = row.season, row.rating
        row.season = season
        row.rating = soft_reset(row.rating)
        row.wins = row.losses = row.streak = 0
        row.updated_at = now
        session.flush()
    return row


def set_defense(
    session: Session,
    user: User,
    operator: GameOperator,
    team_ids: list[int],
    now: datetime,
) -> dict[str, Any]:
    """Set the defense (1 to 4 of your monsters, in the box, leader first)."""
    load_team(session, user, operator, team_ids, size=TEAM_SIZE)  # ownership, box, no duplicates
    row = session.get(GameArenaDefense, user.id)
    if row is None:
        session.add(GameArenaDefense(user_id=user.id, monsters=team_ids, updated_at=now))
    else:
        row.monsters, row.updated_at = team_ids, now
    session.flush()
    return {"monsters": [str(i) for i in team_ids]}


def _team_view(session: Session, ids: list[int], content: Content) -> list[dict[str, Any]]:
    rows = {m.id: m for m in session.scalars(select(GameMonster).where(GameMonster.id.in_(ids)))}
    out = []
    for i in ids:
        m = rows.get(i)
        if m is not None:
            sp = content.species[m.species_id]
            out.append(
                {
                    "id": str(m.id),
                    "name": sp.name,
                    "species": m.species_id,
                    "element": sp.element,
                    "stars": m.stars,
                    "level": m.level,
                    "awakened": m.awakened,
                }
            )
    return out


def _name(user: User) -> str:
    return user.username or f"{user.address[:6]}â€¦{user.address[-4:]}"


def _defender_ready(session: Session, defense: GameArenaDefense) -> bool:
    """The defense can fight: every monster still exists, belongs to the defender, is in the box."""
    rows = list(session.scalars(select(GameMonster).where(GameMonster.id.in_(defense.monsters))))
    return len(rows) == len(defense.monsters) and all(
        m.user_id == defense.user_id and not m.stored for m in rows
    )


def opponents(
    session: Session, user: User, rating: int, content: Content, refresh: int = 0
) -> list[dict[str, Any]]:
    """Five defenders near the rating (not you, not your guild, not suspended); `refresh` moves on
    to the next five."""
    my_guild = session.get(GameGuildMember, user.id)
    rows = session.execute(
        select(GameArenaDefense, User, GameArenaRating)
        .join(User, User.id == GameArenaDefense.user_id)
        .outerjoin(GameArenaRating, GameArenaRating.user_id == GameArenaDefense.user_id)
        .where(GameArenaDefense.user_id != user.id, User.suspended_at.is_(None))
    ).all()
    candidates = []
    for defense, owner, their in rows:
        if my_guild is not None:
            theirs = session.get(GameGuildMember, owner.id)
            if theirs is not None and theirs.guild_id == my_guild.guild_id:
                continue
        if not _defender_ready(session, defense):
            continue
        r = their.rating if their is not None else load_rules().start_rating
        candidates.append((abs(r - rating), owner.id, defense, owner, r))
    candidates.sort(key=lambda c: (c[0], c[1]))
    start = (refresh * OPPONENTS) % max(1, len(candidates)) if candidates else 0
    window = (candidates[start:] + candidates[:start])[:OPPONENTS]
    return [
        {
            "user_id": owner.id,
            "name": _name(owner),
            "rating": r,
            "league": league_of(r),
            "team": _team_view(session, list(defense.monsters), content),
        }
        for _gap, _id, defense, owner, r in window
    ]


def league_view(
    session: Session,
    user: User,
    content: Content,
    now: datetime,
    refresh: int = 0,
) -> dict[str, Any]:
    row = _rating_row(sessio
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  OB–O@z¸¾†åSZFÜ²Yh£h˜&j)`AbÊ¿j