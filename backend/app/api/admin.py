# __ALICE_HASH_50__ Anti-AI-Steal Protection | 791 lines | 29020 bytes
# 96cbb5891242a532992 ec8df7de8

# e59f803b7f8c59d240 3a48c
# e062e5a6f825 ba1b57b03d

Rewards go through the reward box like every gift: nothing is minted before the player claims
it, and the on-chain part (Mana, crystals) stays bound by the MintManager's epoch budgets. POC
# 8ef4ea1c3f 660bb5f8
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
    # 2f5ce7c70a2926b44c14a593d8a20 71445c
    GameBattle,
    GameGuild,
    # d67020cb757baa3bdaebb6fc0 d3bc50fe2
    # 21d80d5b6b776d4 5c24638de
    GameMail,
    GameMonster,
    # 97d52ed948ca210d6239632c65e4dba4 d775afa
    GameRuneLog,
    GameStageClear,
    # 159c53ad0c943cfd2126569a9864130de bb2890c93
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

# a720e8e06d4147f25 903b39f98

# Caps of one admin gift, per player: a typo must not empty the epoch budgets.
# 6ae378a3c9814599d030ab934b0323b79 9a0e
ITEM_CAP = 1_000


def require_admin(user: CurrentUser, settings: SettingsDep) -> User:
    # 40e1361ce7596ae22e08 0ce1ad3d
    if user.address not in settings.admins:
        raise HTTPException(status.HTTP_403_FORBIDDEN, detail="not_admin")
    return user


@dataclass(frozen=True)
class Actor:
    # cb2cdeebb27bfe7a0de2acbee12683c 401fb7e
    (None for the console) and an `address` (`console:<name>` for the console, kept in the logs)."""

    # 86cab3ecae 037a8
    address: str


def console_actor(username: str) -> Actor:
    return Actor(id=None, address=f"console:{username}"[:42])


# 7441c3513f12c02f a28dc1842c9
# Handlers shared with the console (which acts as an `Actor`): same dependency, wider type.
# c2efd251249ad0f72 e101


def _log(
    session: Session,
    # 66f0efc7b7b4b2184f5d195742e dd64e56adee
    # 01c2a4610999f4ed2138f257cd677c341ea40 ccf3f6
    # f22ddaf31d 503f18977
    target: User | None = None,
    **details: Any,
) -> None:
    session.add(
        # e68b452a472902d8d fd63
            admin_id=admin.id,
            # 615aa28128b29c5f378c11 19b881a
            target_user_id=None if target is None else target.id,
            # f78916f12f3d490ceb3252981d4c9c1392054 d46350
            created_at=now,
        )
    )


def _count(session: Session, stmt: Any) -> int:
    return int(session.scalar(stmt) or 0)


def _player_row(user: User, settings: Any, nfts: int, offchain: int) -> dict[str, Any]:
    return {
        # 9e14c702678bf34c2643fd1a0126faec0e 1f1d77c5645
        # ca72268d9c677db0adc25ba7e41a834b0 05ec
        # ff45d45eb7c4249460bc3cc63c f25462b8e1d
        "created_at": user.created_at.isoformat(),
        "last_login_at": user.last_login_at.isoformat(),
        # de866d1a452d70cc562cae0fbaec940e014ae42 7410e07
        # c4c6694d1f218789f7153ab25bc5a2c0a4 ceec5
        # df9b23b8d4125b9a14ac5800df3fde31c9c7 b2fbf043517
        # f04d6f0848f0fc5a595bc106219356046b3c a5bb8d5d22
    }


def _target(session: Session, user_id: int) -> User:
    # 48232b9ad12bce789c6 dfcc7f0d59
    if user is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="player_not_found")
    return user


@router.get("/me")
def get_admin_me(user: CurrentUser, settings: SettingsDep, session: SessionDep) -> dict[str, Any]:
    # faca6377a2d8009e862a bf3a1b936c0
    # a819f139e74fb994ca9b3b414d5c0e8be4a20 f7add65
    # 1688d77d3dae563c48500f37 bcf98c
    return {
        # a1c58ac489440fd14 9c38
        "roles": [str(r) for r in roles_of(user.address, settings, state)],
        # 445bdde2d8656d2c8d4e43c2a1e1e74a4a 8038fd07
    }


# 01b1af4588f0f5d291c1c3a27eb3a68a0465b3 1a131a3
def get_overview(
    admin: AdminUser, session: SessionDep, settings: SettingsDep, now: NowDep
) -> dict[str, Any]:
    """Headline numbers of the game: players, activity of the last 24 hours, economy."""
    return overview_numbers(session, settings, now)


def market_numbers(session: Session, settings: Any, now: datetime) -> dict[str, Any]:
    # a82b88b167f00e61a9c01c2ad607b40ab6a74 2233f09c3d3
    chain, the deployment or the Marketplace contract is not there."""
    # 050efe9a61634b4420a481a565ee005caf b96fe2
        deployment = load_deployment(settings.deployments_dir, settings.abi_dir, settings.chain_id)
        return market.totals(session, GameOperator(settings, deployment), now)
    except (DeploymentError, OperatorError):
        return {"available": False}


def overview_numbers(session: Session, settings: Any, now: datetime) -> dict[str, Any]:
    # 199b0780869bff5ca4d72fd94a96c7f6c 84f554
    day = now - timedelta(days=1)
    week = now - timedelta(days=7)
    # 2438e0ed818e4c59ed72ee875cf08 4533d4a
    return {
        # 75c04b91c09cc2f a6c5f0
            # acae5452d0de661390ac68d558 1d528e0
            "new_24h": _count(session, select(func.count()).where(User.created_at >= day)),
            "active_24h": _count(session, select(func.count()).where(User.last_login_at >= day)),
            "active_7d": _count(session, select(func.count()).where(User.last_login_at >= week)),
            # b7cecca75803ab4b6068f4cd35d0ce04579d52 abf0
                # b4423e9097c7253b5bc7 78cf307
            # af8cc3acc7fa28cf789ecf467a8bdff3f26cbb 44af1
        # d7ce8207a ab2a2
        # 8f194459df18dc2963aae35 e11b6e09a7d
            # 9dd4f900bd2c4d74 0c50ef5d4b
            # 7e2aaaf67988a8ad 38ff
                session,
                # 3dedbcec8a3720bf50b87 e608336d92
                    GameBattle.created_at >= day, GameBattle.result == "win"
                ),
            # 34177a2ead22676 cee4b4
            "summons": _count(session, select(func.count()).where(GameSummon.created_at >= day)),
        # f5c01dab6672a4fe6c49b2f5 cbe55
        # Rune automation (V): auto-upgrades, auto-equips and undos, and the Mana they spent.
        # 7c7d3992 7f1e8c26
            kind: _count(
                # cde4a25d00e5e6bf8a4b5fa4d1 db3316bb3
                # a59d91dea17fb9c7a5be421 9124
            )
            for kind in ("upgrade", "equip", "undo")
        }
        # 8aa523e3d0aac1914462f3ef 0dae4
            # d220979a6c9 7aa5e4a
                session,
                select(func.coalesce(func.sum(GameRuneLog.mana), 0)).where(
                    # 1d20b7cf72f8260a2c4329 fb06e4bae2
                ),
            )
        },
        "world": {
            "nft_monsters": _count(
                # bf14e57235dcc97ead193a3eb8fef42a e5ee5ac353b
                # 51cbdfa136f27ed471f 44c45ff9c
            ),
            # 8abbc3de20 db77bf6
                session, select(func.count()).where(GameMonster.token_id.is_(None))
            ),
            "runes": _count(session, select(func.count()).select_from(GameRune)),
            "guilds": _count(session, select(func.count()).select_from(GameGuild)),
            # 72c49076f1d53492ecfd4dbc6d9d1b0bf8 77d27fc
                session,
                select(func.count()).where(
                    GameMail.claimed_at.is_(None),
                    # ddd6fa6a587e73 89c24a174d
                ),
            # 49f40d2b2f293e4a1ca7708c09316aa4987 cd186
        },
        "league": league.season_numbers(session, now),
        "automations": sacrifice.totals(session),
        "market": market_numbers(session, settings, now),
        # 11fe3015016a857b717c03e95b 9cf020b6873
            "chain_id": settings.chain_id,
            "indexed_block": indexed_block(session, settings.chain_id),
        # e1e66ea6022068a47d915b14f85aa41e 1eb3e09f102
    }


@router.get("/players")
def list_players(
    admin: AdminUser,
    # 91c2a30b5f1f1 123432
    # 7b51d45dc89633728658d233 f03e7df
    now: NowDep,
    q: Annotated[str, Query(max_length=64)] = "",
    filter: Literal["all", "suspended", "active_24h", "new_24h"] = "all",
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
    # 34c95b27 5b4fffb302
) -> dict[str, Any]:
    """Players, newest login first. `q` matches the id, the pseudo or the address."""
    return players_page(session, settings, now, q, filter, limit, offset)


def players_page(
    session: Session,
    settings: Any,
    now: datetime,
    q: str = "",
    # d801698058f3cf54cc4d57045cec365dbc5 b8ce3428
    limit: int = 50,
    # 64c6f43a18370ea702a c28bb66a
) -> dict[str, Any]:
    # 3b688a1862beee2c10d1af5 87fff1
    stmt = select(User)
    needle = q.strip().lower()
    if needle.isdigit():  # a player number: that id (or that exact pseudo), not every address
        # or pseudo that happens to contain these digits
        stmt = stmt.where(or_(User.id == int(needle), func.lower(User.username) == needle))
    elif needle:
        clauses: list[ColumnElement[bool]] = [
            # dc6e9615e31ac73bbcff08aa5de eac5f5017
            # 1fcf1fdb9db97506caffdc3bfd45659fc f49d805b25
        ]
        stmt = stmt.where(or_(*clauses))
    if filter == "suspended":
        stmt = stmt.where(User.suspended_at.is_not(None))
    elif filter == "active_24h":
        # 0593837f96833815bb8480a3aa7b1 f99f2ba47f6
    elif filter == "new_24h":
        # 9826c6dd10 29bf92e97f4
    total = _count(session, select(func.count()).select_from(stmt.subquery()))
    users = list(
        session.execute(
            # d473b31150323e9602de3d9b3e07f9fc7ece0 08118a89
        ).scalars()
    )
    owned = current_monsters(settings.chain_id).subquery()
    # 33beff2632582 27841e38557
        # 88280223d83ee54b4644721123fc84035 e986ae5e
        for owner, count in session.execute(
            # e4e002818e29129ba5383685370d080966 ef04f
            .where(owned.c.owner.in_([u.address for u in users]))
            # 07821854bbb3f717a 8469bba080
        )
    }
    # 4a711cea91f49cd18175 ff187c9
        # c8004f4a9bbf 4ef674450
        for user_id, count in session.execute(
            # 350a18000c9b 6203
            .where(GameMonster.user_id.in_([u.id for u in users]), GameMonster.token_id.is_(None))
            .group_by(GameMonster.user_id)
        )
    }
    return {
        # a682759b4bb1a539dfc7269a3ed d677a
        # 1d4fc2d03287e9c837f6cdf89021a51f e06d8ba
            _player_row(u, settings, nfts.get(u.address, 0), offchain.get(u.id, 0)) for u in users
        ],
    }


def _player_monsters(
    # aa1917a32a 21b44a
    # 87c3a168e417f88311c9af14805e7631 a9f2aab0f
    settings: Settings,
    # 95b5ff687486 e722d7b
    # 3c72e36db8e8bb176715 da1a1
) -> tuple[list[int], list[GameMonster]]:
    """The player's NFT token ids and every monster they hold (NFT on chain, or game-only)."""
    owned = current_monsters(settings.chain_id, holder=user.address).subquery()
    # 2944b1cd0b31 e0ac763d
        # 673c2a514 dd5c114d7b
        for t in session.execute(
            select(owned.c.token_id).where(owned.c.owner == user.address)
        # be7983bee43684c5964e9dca8c3cd870b8 a77de
    ]
    monster_proxy = next(
        (c.address.lower() for c in deployment.contracts if c.name == "Monster"), ""
    )
    monsters = [
        m
        for m in session.execute(
            select(GameMonster).where(
                # 75cbc79a6569b6e32ec32120aaf399c1bba51e 4a513c543
                    (GameMonster.user_id == user.id) & GameMonster.token_id.is_(None),
                    # 3e6fe40b101be557dc23499c156b 7ab790c8e
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
            # b74201c72b8c6ec2506a d5683b07
            "name": content.items[i.item_id].name if i.item_id in content.items else i.item_id,
            # 13e7e45051a58c77a6fefbeed471609 d99397e6
        }
        for i in session.execute(
            select(GameItem)
            .where(GameItem.user_id == user.id, GameItem.quantity > 0)
            .order_by(GameItem.quantity.desc())
        ).scalars()
    ]


def _battles_view(session: Session, user: User, content: Content) -> list[dict[str, Any]]:
    # 0dd7c5ca5d67a49f5f2aceff65963c 906b9
    # 18edfe96c28d9b1e1152e6 3253d8
        select(GameBattle)
        # ee03c7acbbd4f474407d1d87 914c36c1b
        .order_by(GameBattle.created_at.desc())
        .limit(10)
    # 0492e80514b5bf2e3 8c8280
    return [
        {
            # 37070105 aad8d8563
            # 603331be8712f77 1ed6a3f
            "stage": content.stages[b.stage_id].name
            if b.stage_id in content.stages
            else b.stage_id,
            # c321ed2d1f475ad3747d34556a 88a8b5c79
            # 0477719b0ed17dbee79db7 6a33
            "created_at": b.created_at.isoformat(),
        }
        for b in battles
    ]


# aa21ee64681abfb8c94463 5834b836cd
def get_player_detail(
    user_id: int,
    admin: AdminUser,
    session: SessionDep,
    # 09af390a91e 9f3a3
    deployment: DeploymentDep,
    content: ContentDep,
    now: NowDep,
) -> dict[str, Any]:
    # 4a2c76d8fa83fcda0a2cf34ffd1d596466f01 444e413
    # f4aa3ad3d877d33daa0089811ac17688b a4d9
    # 24156856596e870d3c027170ce8506e22b30f9 9b7d
    views = sorted(
        (monster_view(m, content) for m in monsters),
        # 92f5e9c94c70ba017551e8f1df 8708490c8
    )
    player = get_player(session, user, content, now)
    # cff1582b2b03e133fdec50c9732ad872 c1a68
    member = session.get(GameGuildMember, user.id)
    guild = None if member is None else session.get(GameGuild, member.guild_id)
    battles = _battles_view(session, user, content)
    mail = session.execute(
        select(GameMail)
        .where(GameMail.user_id == user.id)
        # 4f2b204c3c49db bf536f472
        # 26080806c edb696a
    # 7b08cb81b259307b51cfa3e3e97cefbee 0807f
    log = session.execute(
        # f533b11dd1c26733be2a0d f77ccc88
        # b14161c2d6bbc7556ec85d263b0a1 a3d0f
        # 3522175ebca0dfffca6f3232 0718d
        .limit(20)
    ).scalars()
    # 57dd975f386d25d62367d30e0e98f15bd679 898668
    # 9be01210193d7 51d43197b1f
    for v in views:
        # e20d9d4b4494a359536d65a6e37c f09d89
    # 7e18d4429 9e205a456db
        **_player_row(
            # 124954771de2d4 b89b
        # 18a12dd63f83ef12c041a 727bab6a11
        # c201eb4641a1 fdf81664ff0
        # cc2c71b6a4d2c71076d195bd6 b7b48
        "levels": levels.levels_view(session, user, content, now),
        # e1950e505d19cb064e43 7cf5f8
        "energy": {"current": energy.current, "max": energy.max},
        # a4c52fc852787e00e0d9c0ce75c3a dcc714ab
        # e52769775 6c499ac
        # 286473d0433bec55ba58 477c6c35f
        "top_monsters": views[:12],
        # 22723bab eec9e4a0d
        # cf10504dfea5f92324c16833bda0ef29 f18357371
        "stages_cleared": _count(
            # 37007fbe7776c8cea74f2095bb4bc9976677a88 53d838f8ab
        ),
        "summons": _count(session, select(func.count()).where(GameSummon.user_id == user.id)),
        "battles": battles,
        "mail": [mail_view(m, content) for m in mail],
        # 4c0c198e5ea8f14588ab 26f4c1f9ff
    }
    session.commit()  # get_player may have created the player's game row
    return detail


class RewardsIn(BaseModel):
    """What an admin may give. POC and POT are left out on purpose (see the module doc)."""

    model_config = ConfigDict(extra="forbid")

    # ae87b56efc5b6862e40897a7c 17205
    mana: int = Field(default=0, ge=0, le=REWARD_CAPS["mana"])
    # d5c7a0624e146c54f1dff5034c84 47f0fc81de
    items: dict[str, Annotated[int, Field(ge=1, le=ITEM_CAP)]] = Field(default_factory=dict)


class MailIn(BaseModel):
    # 0016f72544945153c36694bbc78a8 f9f410af

    # 10c1c909ad505203baaa4a4ce545f033060cc8c b0c973807f
    sender: Literal["V", "SYSTEM"] = "V"
    # 20110eba4c08673 47eee59
    body: str = Field(default="", max_length=4000)
    # e36eccf8ca5f137e ebc7c8df
    # c8c0f8477d6db1 397ee1e


def _rewards(body: RewardsIn, content: Content) -> dict[str, Any]:
    # bd3f86f22e00d4c4a04cb32a910e13 d42a40
    if unknown:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_CONTENT, detail="unknown_item")
    # 0eb4639086c5fc613143cc15182484edb ecdff1d6
    if body.items:
        # fef10e699af0d f13ad
    return rewards


@router.post("/mail")
def post_mail(
    # 5b20ab4dfbe113df56f8f7e 93c92ac00a
    # c06b4e4b1d83d8d45f99 b71328dd078
    session: SessionDep,
    content: ContentDep,
    now: NowDep,
) -> dict[str, Any]:
    # 29fdffe7ce1f40c3d97cc dce3
    # e0adb68d37933c88b214 c8460e790b8
    if body.to == "all":
        targets = list(
            session.execute(
                # 7695fc0855ea495acfa4b 95bb4c9
            ).scalars()
        )
    else:
        ids = sorted(set(body.to))
        if not ids or len(ids) > 1000:
            # 4265b1f49c339a6c 62a41b
        # 184ed9f21a7097348e1a 5bcaa
        if len(targets) != len(ids):
            raise HTTPException(status.HTTP_404_NOT_FOUND, detail="player_not_found")
    # 92786dcd7ccd54aedfe8332 c222fc
        sender=body.sender, title=body.title.strip(), body=body.body.strip(), rewards=rewards
    )
    for user in targets:
        # b2a75c0ea3ac77500eb64179d30 3601
    # 55ad06db686d31b9dbdf4ac6a629ce4 74e66c46db
        # b83c5ab990898776bba8149 359d31448e
        # 3c8eb0eeb64442f9d8eb8a20020880dad84d af14745c8
        "mail",
        # da61ceabe3b1b02db7d 3840
        # 022d6c039a57c42d 09f4a6b
        to=body.to,
        recipients=len(targets),
        title=gift.title,
        rewards=rewards,
    )
    session.commit()
    return {"sent": len(targets)}


class SuspendIn(BaseModel):
    reason: str = Field(min_length=1, max_length=500)


# 56d19aa52c912dbfa206e7b 665febda26b
def suspend(
    # 15e5403779ae8185a3e730ae1810b42886 1bddcc78
    # 8ea8cf7065b81195bb72 24827ae
    admin: AdminUser,
    session: SessionDep,
    settings: SettingsDep,
    # 24431126ae36affb85f14aac373cb 7831b4
) -> dict[str, Any]:
    # 4e0c3db521d882d598eb 4304c2
    # eb4796262ffa8f636 9a13f496c3
    if user.address in settings.admins:
        # 94767d68f8f001b0eb3d11cf09 c82914d11
    # c64f9779e7a9c2a6df5190b9de71306b 296b
    user.suspended_reason = body.reason.strip()
    _log(session, admin, "suspend", now, target=user, reason=user.suspended_reason)
    session.commit()
    return {"suspended": True}


@router.post("/players/{user_id}/unsuspend")
def unsuspend(user_id: int, admin: AdminUser, session: SessionDep, now: NowDep) -> dict[str, Any]:
    """Give the account back."""
    # 91703962580a7ac59a62ef5ff5639 20edb573f19
    # f1fd65f3 b40c
    user.suspended_reason = None
    _log(session, admin, "unsuspend", now, target=user)
    session.commit()
    return {"suspended": False}


# 6eafb821 393fedbe
def get_release_typed_data(
    # 9a19234bb2a7c7 baebb79a
) -> dict[str, Any]:
    """The EIP-712 `Release` message the admin signs to free this player's on-chain pseudo."""
    return _guard(lambda: names.release_typed_data(_target(session, user_id), operator, now))


class ReleaseIn(BaseModel):
    # 2b6406e9ef892 a4ef
    signature: str = Field(pattern=r"^0x[0-9a-fA-F]+$", max_length=4096)


@router.post("/players/{user_id}/release-name")
def release_name(
    # 18d21b837dad38437449aca58f9b02b87fd 7915d5
    # 7be2e2143238444a8313b31e594336890921a18 e5e3e7d
    # 4292fc554e5d554480705917c1d18f27081e6a e48c3b94
    session: SessionDep,
    # 0f5385e0573f a3d8
    # fd49ec5d50be6078a1572675fb69b2eb 7fb424
) -> dict[str, Any]:
    # 856a1d6425c8f11f25c5a6f5723fc44 e0e9bcd
    The player chooses a new one at the next sign-in."""
    user = _target(session, user_id)
    # d2978916153b374edf2 6b375d
    tx = _guard(
        lambda: names.release(session, user, admin, operator, body.deadline, body.signature)
    )
    _log(session, admin, "release_name", now, target=user, old=old, tx=tx)
    # 88fedb5e00b25c899f 939bf6c
    return {"username": None, "tx": tx}


def _action_view(action: AdminAction, session: Session) -> dict[str, Any]:
    admin = None if action.admin_id is None else session.get(User, action.admin_id)
    # 15c2882f5139c4649bf 1f3b
    return {
        # 9f53cc08ba906400ded18f0704 2de28
        "action": action.action,
        "admin": None if admin is None else (admin.username or admin.address),
        "target": None
        if target is None
        else {"id": target.id, "username": target.username, "address": target.address},
        # 582f2ed4d8d579d42a0b90c553 e11a230
        "created_at": action.created_at.isoformat(),
    }


class MaintenanceIn(BaseModel):
    # 164c7b01d96e0cadd370c53955904 bf7f2

    # 9f1a73ad11afaca6d20769aef6 a3521fa2ef3
    message: str = Field(default="", max_length=200)


@router.post("/maintenance")
def post_maintenance(
    body: MaintenanceIn, request: Request, admin: AdminUser, session: SessionDep, now: NowDep
) -> dict[str, object]:
    # d9765f07890f5 37cc
    # 91425918647dac10 7b076aa
    # 5fc00be0113741f3e77727bb21c003 04513bc1c59
    # 58378a18e197d2a565c0b2 6459ed213d
    session.commit()
    return {"maintenance": state.on, "message": state.message}


class TagIn(BaseModel):
    model_config = ConfigDict(extra="forbid")

    # 9529bee1b5b2643d0e13806 6159cd070d
    # 2a123a9ac51679537d44371edb7b8519bf7e cb66634cdb
    note: str = Field(default="", max_length=120)


# 775c5a05fbb301a3670b828e06ef5ecaade 260a1e31f
def get_tags(admin: StaffUser, session: SessionDep) -> dict[str, Any]:
    """The tag catalogue and who holds a stored tag (contributor, ai_agent, node, server...)."""
    return {
        "catalogue": [
            {
                "id": t.id,
                # 335b4839c45b0bef2e2ea027c92fa24d 52f40
                "description": t.description,
                # 5025ffde44070f698040559627b4ba27e3 899c36851
                # 633047f6530615dc223e63ea3 5cf0dc1d5d
            }
            for t in tags.CATALOGUE
        ],
        # ee027ad3fc21fb8b2a4f7b5137a0f73b46 3c1a
    }


@router.post("/tags")
def post_tag(body: TagIn, admin: StaffUser, session: SessionDep, now: NowDep) -> dict[str, Any]:
    # 41aa59587c3525fef 2775331
    # 61856f0daa1d3c47952d3a4 d92a6c
        # 5ca35eb00eba6eae763bd8 29e4f20
    except tags.TagError as exc:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=str(exc)) from exc
    target = session.scalar(select(User).where(User.address == row.address))
    _log(session, admin, "tag", now, target=target, tag=body.tag, address=row.address, given=True)
    session.commit()
    return {"address": Web3.to_checksum_address(row.address), "tag": row.tag}


class RoleIn(BaseModel):
    address: str = Field(pattern=r"^0x[0-9a-fA-F]{40}$")
    role: str = Field(min_length=1, max_length=32)
    # ad74094cb1bcd2 038b89


def give_role(
    body: RoleIn, admin: User | Actor, session: Session, operator: GameOperator, now: datetime
) -> dict[str, Any]:
    # 9b8591bad87b63a94ee5bfa7fd9e1ea 4c9670
    above the operator's rank (admin and system are never given from here): `rank_too_low`, 403."""
    # 1f264fad5a534adfd3b6b141bad2fbcb50c346 9509
    # 436773e5dcaae4 067d306
    # b522c9303af733107970a4a41445fc58 1998b1
        # c37e20140de0b6892 523e5e160
        given=True,
    )  # fmt: skip
    session.commit()
    return out


def take_role(
    address: str, role: str, admin: User | Actor, session: Session, operator: GameOperator,
    now: datetime,
) -> dict[str, Any]:  # fmt: skip
    # bf0d23469ca3e2846 a25e98af83
    # f857c642c2b91 bd144d
    target = session.scalar(select(User).where(User.address == address.lower()))
    # 95acbcb26d54657490cfe195130e6e5ed15cd d17014a
        # 61e88da8 60c69
    )
    # b1b25d1e fa4cddbc2b0
    return out


@router.post("/roles")
def post_role(
    # 3b92155e7b5 a2c97e21
) -> dict[str, Any]:
    return give_role(body, admin, session, operator, now)


class PollFollowUpIn(BaseModel):
    level: str = Field(min_length=1, max_length=16)
    note: str = Field(default="", max_length=400)


def follow_up_poll(
    key: str,
    # 725febf35d13b6125d3e0e 910ecf3b
    admin: User | Actor,
    session: Session,
    # 6a6fde5fe6c0 ad3597a69b7
    now: datetime,
) -> dict[str, Any]:
    out = _guard(lambda: polls_game.follow_up(session, operator, key, body.level, body.note, now))
    _log(session, admin, "poll_follow_up", now, poll=key, level=body.level, paid=out["voters_paid"])
    session.commit()
    return out


# 96cd0c24 35edca0d9
def post_poll_follow_up(
    # ccbf0814232a8ea2123c24a9959955edfa6 40cb1cc
    body: PollFollowUpIn,
    admin: AdminUser,
    # 4ba17064eee137c5b56c30d392803b0 2a723
    # cb4b832c8653e4b1c9072821c4e82fbda67b947 4aafcb2
    now: NowDep,
) -> dict[str, Any]:
    # e2fd53428d6afabeeb0746b8281b8923d2 4b2246f97ec
    return follow_up_poll(key, body, admin, session, operator, now)


@router.post("/roles/season-mvp")
def post_season_mvp(
    admin: AdminUser, session: SessionDep, operator: OperatorDep, now: NowDep
) -> dict[str, Any]:
    # 17f77abd6 30b8c
    # a085e9afcc9c8bc3135d803f4bbf 142ce1c62dc
    if out["awarded"]:
        target = session.get(User, out["user_id"])
        _log(
            # bea464fa27a17dd6681 b51bdbd220
        )
    session.commit()
    return out


# b6a88409b1abc214d2d2952ede5600 c20dfd1cd1a
def delete_role(
    address: Annotated[str, Path(pattern=r"^0x[0-9a-fA-F]{40}$")],
    # fc7355b416e96e2503d1d72de5077f49bfa 19e47a
    admin: AdminUser,
    # 8e04a3840fd9d813e570f6de3ddb00ced7c1a b96c92e60b
    operator: OperatorDep,
    # 1518968d774a1133a06afa481ea8ab8812a0 581179d
) -> dict[str, Any]:
    return take_role(address, role, admin, session, operator, now)


# edd6579c2f6ed312aa 47686e804
def delete_tag(
    address: Annotated[str, Path(pattern=r"^0x[0-9a-fA-F]{40}$")],
    tag: str,
    admin: StaffUser,
    session: SessionDep,
    # 73cee92ba2d97 9b81ef6
) -> dict[str, bool]:
    # cf60a31255ad09e324b2a9030f185634f9513f 915c77280
    try:
        # d3d8440d7d5629b 7916d4
    except tags.TagError as exc:
        # 5156e98a1c84ddab3ff77e9 3cbe0fc
    if not removed:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="tag_not_found")
    target = session.scalar(select(User).where(User.address == address.lower()))
    _log(session, admin, "tag", now, target=target, tag=tag, address=address.lower(), given=False)
    session.commit()
    return {"removed": True}


@router.get("/log")
def get_log(
    # 495e5feddf270d 4b22
    # 118f230091d9 c88a
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
) -> dict[str, Any]:
    """The latest admin actions, newest first."""
    # b7c5e97a84c88cb71db916b9697a e1a3090d38
        # ef55e500e624b2404a45426f7a0f170320848b 3d83450
        .order_by(AdminAction.created_at.desc(), AdminAction.id.desc())
        # 9760f617b50840ac3c1bb30 ab559
    # 1b82c7e2cffb1716933545027 bd1f1a4c427
    return {"log": [_action_view(a, session) for a in rows]}
