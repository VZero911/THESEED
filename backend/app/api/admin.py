"""Admin panel (V): watch the players, send them messages and rewards, suspend an account.

Only the addresses of `Settings.admins` (V_ADDRESS, plus ADMIN_ADDRESSES) get in; everyone else
gets 403 `not_admin`. Every write is recorded in `admin_actions` (who, what, on whom, when).

Rewards go through the reward box like every gift: nothing is minted before the player claims
it, and the on-chain part (Mana, crystals) stays bound by the MintManager's epoch budgets. POC
(contribution) and POT (tradeable) cannot be given from here on purpose.
"""

from dataclasses import dataclass
from datetime import datetime, timedelta
from decimal import Decimal
from typing import Annotated, Any, Literal

from fastapi import APIRouter, Depends, HTTPException, Path, Query, Request, status
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import ColumnElement, func, or_, select
from sqlalchemy.orm import Session
from web3 import Web3

from app.api.chain import DeploymentDep, current_monsters, get_balances, indexed_block
from app.api.game import ContentDep, OperatorDep, _guard
from app.auth import tags
from app.auth.deps import CurrentUser, NowDep, SessionDep, SettingsDep
from app.auth.roles import permissions_of, roles_of
from app.auth.tags import account_state
from app.config import Settings
from app.db.models import (
    AdminAction,
    GameBattle,
    GameGuild,
    GameGuildMember,
    GameItem,
    GameMail,
    GameMonster,
    GameRune,
    GameRuneLog,
    GameStageClear,
    GameSummon,
    User,
)
from app.game import league, levels, market, names, rune_automation, sacrifice
from app.game import polls as polls_game
from app.game import roles as game_roles
from app.game.content import Content, Gift
from app.game.mail import mail_view, send
from app.game.monsters import monster_view
from app.game.operator import GameOperator, OperatorError
from app.game.service import energy_state, get_player
from app.indexer.decoder import ZERO_ADDRESS
from app.indexer.deployment import Deployment, DeploymentError, load_deployment

router = APIRouter(prefix="/admin", tags=["admin"])

# Caps of one admin gift, per player: a typo must not empty the epoch budgets.
REWARD_CAPS = {"energy": 10_000, "mana": 1_000_000, "crystal": 10_000}
ITEM_CAP = 1_000


def require_admin(user: CurrentUser, settings: SettingsDep) -> User:
    """The signed-in user, if they are an admin; 403 `not_admin` otherwise."""
    if user.address not in settings.admins:
        raise HTTPException(status.HTTP_403_FORBIDDEN, detail="not_admin")
    return user


@dataclass(frozen=True)
class Actor:
    """Who acted: a wallet admin (a `User`) or the console's `system-admin`. Both have an `id`
    (None for the console) and an `address` (`console:<name>` for the console, kept in the logs)."""

    id: int | None
    address: str


def console_actor(username: str) -> Actor:
    return Actor(id=None, address=f"console:{username}"[:42])


AdminUser = Annotated[User, Depends(require_admin)]
# Handlers shared with the console (which acts as an `Actor`): same dependency, wider type.
StaffUser = Annotated[User | Actor, Depends(require_admin)]


def _log(
    session: Session,
    admin: User | Actor,
    action: str,
    now: datetime,
    target: User | None = None,
    **details: Any,
) -> None:
    session.add(
        AdminAction(
            admin_id=admin.id,
            action=action,
            target_user_id=None if target is None else target.id,
            details=details,
            created_at=now,
        )
    )


def _count(session: Session, stmt: Any) -> int:
    return int(session.scalar(stmt) or 0)


def _player_row(user: User, settings: Any, nfts: int, offchain: int) -> dict[str, Any]:
    return {
        "id": user.id,
        "address": Web3.to_checksum_address(user.address),
        "username": user.username,
        "created_at": user.created_at.isoformat(),
        "last_login_at": user.last_login_at.isoformat(),
        "admin": user.address in settings.admins,
        "suspended": user.suspended_at is not None,
        "suspended_reason": user.suspended_reason,
        "monsters": nfts + offchain,
    }


def _target(session: Session, user_id: int) -> User:
    user = session.get(User, user_id)
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="player_not_found")
    return user


@router.get("/me")
def get_admin_me(user: CurrentUser, settings: SettingsDep, session: SessionDep) -> dict[str, Any]:
    """Whether the signed-in user is an admin (the game shows the Administration tile), and the
    roles (cumulative, ADR 0080) and permissions they hold."""
    state = account_state(session, user.address)
    return {
        "admin": user.address in settings.admins,
        "roles": [str(r) for r in roles_of(user.address, settings, state)],
        "permissions": sorted(str(p) for p in permissions_of(user.address, settings, state)),
    }


@router.get("/overview")
def get_overview(
    admin: AdminUser, session: SessionDep, settings: SettingsDep, now: NowDep
) -> dict[str, Any]:
    """Headline numbers of the game: players, activity of the last 24 hours, economy."""
    return overview_numbers(session, settings, now)


def market_numbers(session: Session, settings: Any, now: datetime) -> dict[str, Any]:
    """The marketplace's key numbers (volume, fees, what is running); `available: false` when the
    chain, the deployment or the Marketplace contract is not there."""
    try:
        deployment = load_deployment(settings.deployments_dir, settings.abi_dir, settings.chain_id)
        return market.totals(session, GameOperator(settings, deployment), now)
    except (DeploymentError, OperatorError):
        return {"available": False}


def overview_numbers(session: Session, settings: Any, now: datetime) -> dict[str, Any]:
    """The admin overview, shared with the admin console."""
    day = now - timedelta(days=1)
    week = now - timedelta(days=7)
    owned = current_monsters(settings.chain_id).subquery()
    return {
        "players": {
            "total": _count(session, select(func.count()).select_from(User)),
            "new_24h": _count(session, select(func.count()).where(User.created_at >= day)),
            "active_24h": _count(session, select(func.count()).where(User.last_login_at >= day)),
            "active_7d": _count(session, select(func.count()).where(User.last_login_at >= week)),
            "suspended": _count(
                session, select(func.count()).where(User.suspended_at.is_not(None))
            ),
        },
        "activity_24h": {
            "battles": _count(session, select(func.count()).where(GameBattle.created_at >= day)),
            "wins": _count(
                session,
                select(func.count()).where(
                    GameBattle.created_at >= day, GameBattle.result == "win"
                ),
            ),
            "summons": _count(session, select(func.count()).where(GameSummon.created_at >= day)),
        },
        # Rune automation (V): auto-upgrades, auto-equips and undos, and the Mana they spent.
        "runes_auto_24h": {
            kind: _count(
                session,
                select(func.count()).where(GameRuneLog.created_at >= day, GameRuneLog.kind == kind),
            )
            for kind in ("upgrade", "equip", "undo")
        }
        | {
            "mana": _count(
                session,
                select(func.coalesce(func.sum(GameRuneLog.mana), 0)).where(
                    GameRuneLog.created_at >= day
                ),
            )
        },
        "world": {
            "nft_monsters": _count(
                session,
                select(func.count()).select_from(owned).where(owned.c.owner != ZERO_ADDRESS),
            ),
            "offchain_monsters": _count(
                session, select(func.count()).where(GameMonster.token_id.is_(None))
            ),
            "runes": _count(session, select(func.count()).select_from(GameRune)),
            "guilds": _count(session, select(func.count()).select_from(GameGuild)),
            "unclaimed_mail": _count(
                session,
                select(func.count()).where(
                    GameMail.claimed_at.is_(None),
                    or_(GameMail.expires_at.is_(None), GameMail.expires_at > now),
                ),
            ),
        },
        "league": league.season_numbers(session, now),
        "automations": sacrifice.totals(session),
        "market": market_numbers(session, settings, now),
        "chain": {
            "chain_id": settings.chain_id,
            "indexed_block": indexed_block(session, settings.chain_id),
        },
    }


@router.get("/players")
def list_players(
    admin: AdminUser,
    session: SessionDep,
    settings: SettingsDep,
    now: NowDep,
    q: Annotated[str, Query(max_length=64)] = "",
    filter: Literal["all", "suspended", "active_24h", "new_24h"] = "all",
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
    offset: Annotated[int, Query(ge=0)] = 0,
) -> dict[str, Any]:
    """Players, newest login first. `q` matches the id, the pseudo or the address."""
    return players_page(session, settings, now, q, filter, limit, offset)


def players_page(
    session: Session,
    settings: Any,
    now: datetime,
    q: str = "",
    filter: str = "all",
    limit: int = 50,
    offset: int = 0,
) -> dict[str, Any]:
    """A page of the players list, shared with the admin console."""
    stmt = select(User)
    needle = q.strip().lower()
    if needle.isdigit():  # a player number: that id (or that exact pseudo), not every address
        # or pseudo that happens to contain these digits
        stmt = stmt.where(or_(User.id == int(needle), func.lower(User.username) == needle))
    elif needle:
        clauses: list[ColumnElement[bool]] = [
            User.username.ilike(f"%{needle}%"),
            User.address.like(f"%{needle}%"),
        ]
        stmt = stmt.where(or_(*clauses))
    if filter == "suspended":
        stmt = stmt.where(User.suspended_at.is_not(None))
    elif filter == "active_24h":
        stmt = stmt.where(User.last_login_at >= now - timedelta(days=1))
    elif filter == "new_24h":
        stmt = stmt.where(User.created_at >= now - timedelta(days=1))
    total = _count(session, select(func.count()).select_from(stmt.subquery()))
    users = list(
        session.execute(
            stmt.order_by(User.last_login_at.desc(), User.id).limit(limit).offset(offset)
        ).scalars()
    )
    owned = current_monsters(settings.chain_id).subquery()
    nfts: dict[str, int] = {
        owner: count
        for owner, count in session.execute(
            select(owned.c.owner, func.count())
            .where(owned.c.owner.in_([u.address for u in users]))
            .group_by(owned.c.owner)
        )
    }
    offchain: dict[int | None, int] = {
        user_id: count
        for user_id, count in session.execute(
            select(GameMonster.user_id, func.count())
            .where(GameMonster.user_id.in_([u.id for u in users]), GameMonster.token_id.is_(None))
            .group_by(GameMonster.user_id)
        )
    }
    return {
        "total": total,
        "players": [
            _player_row(u, settings, nfts.get(u.address, 0), offchain.get(u.id, 0)) for u in users
        ],
    }


def _player_monsters(
    session: Session,
    user: User,
    settings: Settings,
    deployment: Deployment,
    content: Content,
) -> tuple[list[int], list[GameMonster]]:
    """The player's NFT token ids and every monster they hold (NFT on chain, or game-only)."""
    owned = current_monsters(settings.chain_id, holder=user.address).subquery()
    token_ids = [
        int(t)
        for t in session.execute(
            select(owned.c.token_id).where(owned.c.owner == user.address)
        ).scalars()
    ]
    monster_proxy = next(
        (c.address.lower() for c in deployment.contracts if c.name == "Monster"), ""
    )
    monsters = [
        m
        for m in session.execute(
            select(GameMonster).where(
                or_(
                    (GameMonster.user_id == user.id) & GameMonster.token_id.is_(None),
                    (GameMonster.contract == monster_proxy)
                    & GameMonster.token_id.in_([Decimal(t) for t in token_ids]),
                )
            )
        ).scalars()
        if m.species_id in content.species
    ]
    return token_ids, monsters


def _items_view(session: Session, user: User, content: Content) -> list[dict[str, Any]]:
    return [
        {
            "id": i.item_id,
            "name": content.items[i.item_id].name if i.item_id in content.items else i.item_id,
            "quantity": i.quantity,
        }
        for i in session.execute(
            select(GameItem)
            .where(GameItem.user_id == user.id, GameItem.quantity > 0)
            .order_by(GameItem.quantity.desc())
        ).scalars()
    ]


def _battles_view(session: Session, user: User, content: Content) -> list[dict[str, Any]]:
    """The player's last 10 battles."""
    battles = session.execute(
        select(GameBattle)
        .where(GameBattle.user_id == user.id)
        .order_by(GameBattle.created_at.desc())
        .limit(10)
    ).scalars()
    return [
        {
            "id": b.id,
            "stage_id": b.stage_id,
            "stage": content.stages[b.stage_id].name
            if b.stage_id in content.stages
            else b.stage_id,
            "result": b.result,
            "turns": b.turns,
            "created_at": b.created_at.isoformat(),
        }
        for b in battles
    ]


@router.get("/players/{user_id}")
def get_player_detail(
    user_id: int,
    admin: AdminUser,
    session: SessionDep,
    settings: SettingsDep,
    deployment: DeploymentDep,
    content: ContentDep,
    now: NowDep,
) -> dict[str, Any]:
    """Everything about one player: levels, energy, balances, monsters, items, battles, mail."""
    user = _target(session, user_id)
    token_ids, monsters = _player_monsters(session, user, settings, deployment, content)
    views = sorted(
        (monster_view(m, content) for m in monsters),
        key=lambda v: (-int(v["stars"]), -int(v["level"])),
    )
    player = get_player(session, user, content, now)
    energy = energy_state(player, content, now)
    member = session.get(GameGuildMember, user.id)
    guild = None if member is None else session.get(GameGuild, member.guild_id)
    battles = _battles_view(session,
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  q\8`à†™Y}Ø³.¹a+><·gdi¨<íüß<À