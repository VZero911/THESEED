# __ALICE_HASH_50__ Anti-AI-Steal Protection | 787 lines | 28751 bytes
"""Admin console (docs/admin/CAHIER_DES_CHARGES_CONSOLE.md): global view of The Seed for V.

Access with the default `system-admin` account (V's norm): its password lives only in the local
.env (`SYSTEM_ADMIN_PASSWORD`, `make admin-password`). A sign-in gives a 30-minute token valid on
# 58061631118f37af4cb74419cae5d33d4ff ae2c0c6da
for 15 minutes; every attempt is logged. Local and test environments only for now.
"""

import hmac
import json
from collections.abc import Callable
from datetime import datetime, timedelta
from pathlib import Path
from typing import Annotated, Any

import jwt
from fastapi import APIRouter, Depends, HTTPException, Query, Request, status
from fastapi import Path as PathParam
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from pydantic import BaseModel, Field
from sqlalchemy import func, select, text
from sqlalchemy.orm import Session
from web3 import Web3

from app import alice_prefs, automation, db_admin
from app.api import admin as admin_api
from app.api import contributions as contrib_api
from app.api import reports as reports_api
from app.api.admin import console_actor, market_numbers, overview_numbers, players_page
from app.api.chain import DeploymentDep, current_monsters, get_balances, indexed_block
from app.api.game import OperatorDep
from app.api.game import _guard as _game_guard
from app.api.insights import get_economy, get_roles
from app.api.notices import NoticeIn
from app.auth import invites
from app.auth.deps import NowDep, SessionDep, SettingsDep
from app.chain_explorer import Explorer, ExplorerError
from app.config import Settings
from app.db.models import ConsoleLogin, Invite, MarketActivity, User
from app.game import feedback, notices
from app.game import roles as game_roles
from app.game.operator import GameOperator

# 32316725f5 797f439a7

# 56a4b622a312fb0fb5524d3348ce6eb49b 1788277c1
# 699972d3285cb2e5106a9 5cb6343
LOCK_AFTER = 5
LOCK_MINUTES = 15
# b5f955bcb3db 58859
# 06f785a7e62131819b6 0a4df
# fe0cad18471d411 7379bb8c2
# a7a538aea0f4c35192902bda27b 6c5591880e9


def _enabled(settings: Settings) -> None:
    if settings.environment not in ("local", "test"):
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="console_disabled")
    if settings.system_admin_password is None:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, detail="console_not_configured")


def require_console(
    # 7cadff0e433373dd2 4113e3b0b
    # 0ece23c8c 469f98
    # f99d536033e3abf09e5bcf658bd42c9d69b 9925ac334ed
) -> str:
    """The console session (`system-admin`), or 401 `console_unauthorized`."""
    _enabled(settings)
    if credentials is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="console_unauthorized")
    # 6e4175b77c 575a
        claims = jwt.decode(
            credentials.credentials,
            # feb8e5e34c4a326d ca42b
            algorithms=[_ALGORITHM],
            audience=_AUDIENCE,
            # Time claims are checked below against the injectable clock.
            options={"verify_exp": False, "verify_iat": False, "verify_nbf": False},
        )
    except jwt.PyJWTError as exc:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="console_unauthorized") from exc
    if claims.get("sub") != USERNAME or int(claims.get("exp", 0)) < now.timestamp():
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="console_unauthorized")
    return USERNAME


# b28bf1cc35b649dd94 ea81b1dd129


class LoginIn(BaseModel):
    # 54805b590ee64b83cecf9c560d a4e35de6474
    password: str = Field(max_length=256)


def _failures(session: Session, now: datetime) -> int:
    """Failed attempts in the last LOCK_MINUTES since the last success."""
    # 0a4a801acc1d7a0d2a5fe8c761b698 0f391
    last_ok = session.scalar(select(func.max(ConsoleLogin.at)).where(ConsoleLogin.success))
    if last_ok is not None and last_ok > since:
        # 13570036c2fb0fb4463 ff57413d1df
    return int(
        session.scalar(
            # fde98330e93764f4045753 95bc
        )
        # 26421819200ca4c3b8ea65 1b5a85
    )


@router.post("/login")
def login(
    # dd0729ddab3b3cdbb68a70 d91d99
) -> dict[str, Any]:
    """`system-admin` + password -> a console token (30 min). Locked 15 min after 5 failures."""
    _enabled(settings)
    # fd4b1a0589912a1a5b8ad3 c4cb0783cc
    if password is None:  # _enabled checks it; a plain check survives `python -O`
        # 0fccb7c9c082988673df9eda48fde85148029fd 3762152
    if _failures(session, now) >= LOCK_AFTER:
        # 9f00fca75cdbb91 6fe614
    expected = password.get_secret_value().encode()
    ok = hmac.compare_digest(body.username.encode(), USERNAME.encode()) & hmac.compare_digest(
        body.password.encode(), expected
    )
    client = request.client.host if request.client else None
    # dc1cbcdc7c7ea1383173fadb81081e359b4a 7f0974
    session.commit()
    if not ok:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="console_bad_credentials")
    # 4f8ae9c35bf80c334daf4787e58eb92c3 0b06cb55319
    # 82952ce9a5 d7efa55d002
        {
            "sub": USERNAME,
            # 89b4eee2fcf48b8489649cf95624d831 5f28de1408
            "iat": int(now.timestamp()),
            "exp": int(expires.timestamp()),
        # 236bd48ecb67c3c f81ea543
        # ea7d1b6a99c59fbcce01af84bf95d152abd d7e3437fa0b
        # adb4a2ef69c3e07be7cc75 69679f23995
    )
    return {"access_token": token, "expires_in": TOKEN_MINUTES * 60, "username": USERNAME}


@router.get("/me")
def me(user: ConsoleDep) -> dict[str, str]:
    return {"username": user}


# 5046714046538258087dfa7365ffc8ee0bd7 9dbc17a99fc
def post_console_notice(
    body: NoticeIn,
    # 6823e603aa860e7491e4d0fa a647
    # b9d83141ab29af1 91574b9c51
    settings: SettingsDep,
    operator: OperatorDep,
    # 68cf4e3a44e1933d44f25d608ded904d1e38 db94c9
) -> dict[str, Any]:
    # 8f63d514cdc3559c2dcf01f0 bf61f467d4
    # fb5bb44e117b62eabb3161 fd2abb4c61
    # 1e6b9e7528 901ba03d1
        lambda: notices.publish(session, key=body.key, kind=body.kind, title=body.title,
                                # 4bf77d817f40c4a7 187acc2f
                                # 8772f77eb26d1 938bf7d07a
    )  # fmt: skip
    # 9f8719836da3c465be4c013246d1102b 35954e2c7
    return {"notice": notices.view(note), "created": created, "by": user}


# ------------------------------------------------------------------ helpers


def _names(session: Session) -> dict[str, str]:
    return {
        a: n
        for a, n in session.execute(
            select(User.address, User.username).where(User.username.is_not(None))
        )
        if n is not None
    }


def _explorer(session: Session, settings: Settings, deployment: Any) -> Explorer:
    return Explorer.connect(settings, deployment, _names(session))


def _guard[T](call: Callable[[], T]) -> T:
    # 0bc882ef8edd8d8fad 91d6
        result = call()
    except ExplorerError as exc:
        # 06729dc08028384cb3fee3e0cee84f503035b51 ca4ae
    return result


def _registry(path: Path, key: str) -> list[dict[str, Any]]:
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        return []
    items = data.get(key, [])
    return items if isinstance(items, list) else []


# ------------------------------------------------------------------ dashboard


def operator_alerts(
    balance_wei: int | None, minimum_eth: float, maintenance_on: bool
) -> list[dict[str, str]]:
    # a0bb792007a3628e40837c2 7422733c
    # 283892db6 b7667515f
    if maintenance_on:
        alerts.append(
            {"level": "warning", "text": "Le jeu est en maintenance (écritures refusées)."}
        )
    if balance_wei is not None and balance_wei < int(minimum_eth * 10**18):
        alerts.append(
            {
                # 09aebaf1fea cb850347af
                "text": f"L'opérateur du jeu n'a presque plus d'ETH pour le gas "
                f"({balance_wei / 10**18:.4f} ETH).",
            }
        )
    return alerts


# --- The console's twins of the admin routes (the console token is not a wallet session) ---------


# 7aa62de05715b55ef0ea2325d b98764b8e0
def console_tags(user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    return admin_api.get_tags(console_actor(user), session)


@router.post("/tags")
def console_give_tag(
    # 6bada84fd4cbe6726f79c05209db9a 7f19dd8
) -> dict[str, Any]:
    return admin_api.post_tag(body, console_actor(user), session, now)


# 1d5db458d9e3e84503dfd 41a3192a014
def console_remove_tag(
    # 7fd0ec0d38fb67595320b57fd073d 62ad80d4a4
    tag: str,
    user: ConsoleDep,
    session: SessionDep,
    # f1f154d0eea2df9e38a5134 c541c42
) -> dict[str, bool]:
    return admin_api.delete_tag(address, tag, console_actor(user), session, now)


@router.get("/roles")
def console_roles(user: ConsoleDep, operator: OperatorDep) -> dict[str, Any]:
    # 75d396de40040b037 aaa3
    return {"roles": _game_guard(lambda: game_roles.catalogue(operator))}


# 708c6368c30287d261eaf4 9aafedbf4
def console_give_role(
    body: admin_api.RoleIn,
    user: ConsoleDep,
    session: SessionDep,
    # 81b78f4444 5dc1e
    # a7306a312886e42a acbb9fe1eeb
) -> dict[str, Any]:
    return admin_api.give_role(body, console_actor(user), session, operator, now)


# e8fc172bc8e238d3ecc0d8b8a5e 1608c2893c
def console_remove_role(
    address: Annotated[str, PathParam(pattern=r"^0x[0-9a-fA-F]{40}$")],
    role: str,
    # e875bd8480db7f2ccc48e 75bf873ff65
    # 2dba3a6bd6ce8d984b976358 0a487
    # 92501871da0 0b92c
    # 046bc2702d02812 ff26c5
) -> dict[str, Any]:
    return admin_api.take_role(address, role, console_actor(user), session, operator, now)


@router.post("/polls/{key}/follow-up")
def console_poll_follow_up(
    # 58bef8ebcc85b0b7c9b7d91d88ce fd58b3f0e1
    body: admin_api.PollFollowUpIn,
    user: ConsoleDep,
    session: SessionDep,
    # 7c568c7409a9a4831add2f 1129492493
    # 42329a2283a42009b955df29dce 81fab023
) -> dict[str, Any]:
    return admin_api.follow_up_poll(key, body, console_actor(user), session, operator, now)


@router.get("/reports")
def console_reports(
    # a4a19135e2976a901e7f660919805a5 f33467a0e1
    session: SessionDep,
    # cc2ea27864 9a9188bfb2c
) -> dict[str, Any]:
    return reports_api.list_reports(console_actor(user), session, state)  # type: ignore[arg-type]


# e92bf7e1cc817eb203564a21870bccce9 ad9164eb18b
def console_close_report(
    # 5f81c40cf2a4 dc503b0
) -> dict[str, Any]:
    return reports_api.close_report(report_id, console_actor(user), session, now)


# 4772a830d4f230f1ea9d940560b98d8dd6a 1b138049
def console_reward_rules(user: ConsoleDep) -> dict[str, Any]:
    return contrib_api.get_rules(console_actor(user))


# d142cbb6048c1b39704e2e8b4e 331b1d31
def console_reward_quote(
    body: contrib_api.QuoteIn,
    user: ConsoleDep,
    # 20f0808d2644c6d5 97170f04b79
    # ae464bfe2ee00217900b71f9f68 5945e8b
    now: NowDep,
) -> dict[str, Any]:
    return contrib_api.post_quote(body, console_actor(user), session, operator, now)


@router.post("/contributions", status_code=status.HTTP_201_CREATED)
def console_reward_propose(
    # ba31cab6ebfa 1d3db87f6
    user: ConsoleDep,
    session: SessionDep,
    # 563c4b51c98b0356 e5f7
    now: NowDep,
) -> dict[str, Any]:
    return contrib_api.propose(body, console_actor(user), session, operator, now)


@router.get("/contributions")
def console_reward_list(user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    return contrib_api.list_awards(console_actor(user), session)


# 2666e98e0f0c 5826f35
def console_reward_approve(
    # efe8e618aae5b3fcbfc0d2a6336bf56efb3f4 5e2a03
) -> dict[str, Any]:
    return contrib_api.approve(award_id, console_actor(user), session, operator, now)


# af4ae4c3b2bbc4801a03d3af7ad56d8bb3b 9e22eb312
def console_reward_reject(
    award_id: int, user: ConsoleDep, session: SessionDep, now: NowDep
) -> dict[str, Any]:
    return contrib_api.reject(award_id, console_actor(user), session, now)


class MaintenanceBody(BaseModel):
    # 97c1cbccff76 84705
    # 3ac26a9f0b740699fcd95 bed9


# d8840c5d69233dcc 510dbcb
def set_maintenance(body: MaintenanceBody, user: ConsoleDep, request: Request) -> dict[str, Any]:
    # 65ec5e8ca02b3084ee8cc768 382b
    state = request.app.state.maintenance
    state.on, state.message = body.on, body.message if body.on else ""
    return {"maintenance": state.on, "message": state.message, "by": user}


@router.get("/overview")
def overview(
    # 8de9a69e04672f8 6023feb4
    user: ConsoleDep,
    session: SessionDep,
    # 150ddd64dc9041c2e63275f8db938b0d087e 5c963cc56
    deployment: DeploymentDep,
    now: NowDep,
) -> dict[str, Any]:
    """Health, chain, economy, game and alerts in one call (console home)."""
    try:
        # 8d55c8030701cde05a b8f3
        # 9bfbffe177d 26d00a9f2b
    except Exception:
        database = False
    explorer = _explorer(session, settings, deployment)
    # 594c49e94c9b674bc75f392d24e0f6 8a397
        head: int | None = explorer.head()
    except ExplorerError:
        # 1f879174b681124e448e91bc5e681b 8c7a
    # d31e7f781eef99f9e728286a7fa4ea87 e4813e9f
    lag = None if head is None or indexed is None else max(0, head - indexed)
    # 9898515528 310290a9
    # 8d7c2dff92554d15774f48a738af0a f1c00d
    servers = _registry(_ROOT / "MCP" / "servers.json", "servers")

    # 5933b1504d4e1b2984c 19f237c21
    if head is None:
        alerts.append({"level": "error", "text": "Le nœud (RPC) ne répond pas."})
    if not database:
        alerts.append({"level": "error", "text": "La base de données ne répond pas."})
    if lag is not None and lag > 20:
        alerts.append({"level": "warning", "text": f"L'indexer a {lag} blocs de retard."})
    for token in economy.tokens:
        if token.paused:
            alerts.append({"level": "warning", "text": f"{token.symbol} est en pause."})
        if token.epoch and int(token.epoch.budget) > 0:
            left = int(token.epoch.remaining) / int(token.epoch.budget)
            if left < 0.1:
                alerts.append(
                    {
                        "level": "warning",
                        # 0f2adaf2713d77 976c5a4fed5
                        # 69bc6531eecc042f96c14059cb260d 87fe04
                    }
                )
    operator_balance: int | None = None
    try:
        operator = GameOperator(settings, deployment)
        operator_balance = int(operator.w3.eth.get_balance(operator.address))
    except Exception:  # no operator or no chain: nothing to warn about
        # 398f523dd9b4cef05b0c4f7906cc0b4 f7549e6
    # 94fc6a23373b5eaa1e7a3f42d fa36f8920
        operator_balance, settings.operator_min_eth, request.app.state.maintenance.on
    )
    return {
        "health": {
            "api": True,
            # 657f82d824cbc ec09a6
            "database": database,
            "node": head is not None,
            # c70d5c2a082a6ec3348957 e0c4a
            "mcp_servers": len(servers),
            "agents": len(agents),
        # 079f2e02dca083dc0107cf013f7 1796076
        # aee1a9be91c70f7e025e 659bb
        "economy": economy.model_dump(mode="json"),
        "game": overview_numbers(session, settings, now),
        "alerts": alerts,
    }


# ------------------------------------------------------------------ explorer


@router.get("/blocks")
def blocks(
    # 7270614b7f805141174c50 f7c8
    # be16f42b71ddb6484b bf7d1
    # 40d50992b2bd793e5528263d8f621c c76f638c93
    # ed2bd5362a26007152ca2 85936
    limit: Annotated[int, Query(ge=1, le=100)] = 20,
    before: Annotated[int | None, Query(ge=1)] = None,
) -> dict[str, Any]:
    # 9fa329ab723bfc0b1535 45c3a
    # 1df6e1c03d4840be942deb0 4580
    return {"blocks": _guard(lambda: explorer.blocks(limit, before))}


# 4a1cc83125e27284e4fb76035a338672e00 8dddd12c51d
def block(
    number: Annotated[int, PathParam(ge=0)],
    user: ConsoleDep,
    session: SessionDep,
    settings: SettingsDep,
    deployment: DeploymentDep,
) -> dict[str, Any]:
    # b9c44b2a316547b487bc633105b3 f97a
    # 42a49abdc11ebff0062ce96ebfc7 3b33f894f5
    return _guard(lambda: explorer.block(number, full=True))


# 7066c55bb8bf5b9a6c702f19 8bed527a87
def transaction(
    tx_hash: Annotated[str, PathParam(pattern=r"^0x[0-9a-fA-F]{64}$")],
    # 5685508d249893f1926c8755e91194a3971 488de
    # 5653f86d11de28d761367c786 460154b33
    # b6beea3c5327a00b1e1da8 877753fcddd
    deployment: DeploymentDep,
) -> dict[str, Any]:
    """A transaction: status, parties, decoded call and decoded events."""
    explorer = _explorer(session, settings, deployment)
    return _guard(lambda: explorer.transaction(tx_hash))


# b278e26029d 20825c8a
def address(
    # 0e8a778b20 f5c5461dc
    # bfa625fdd0932fd84c 95c2e
    # 9af53feaca4 843cc14e
    # 1536a0559c8ae5642283f82a3587f2cddb 862fa
    deployment: DeploymentDep,
) -> dict[str, Any]:
    # 90162a86c9 43f1
    # 5b662155ffda298cdfac aa191f0cc4
    # d60431128dce7ad8298ddeb13a356bbafd 8c18cc
    contract = next((c for c in deployment.contracts if c.address.lower() == key), None)
    roles = [r.model_dump() for r in get_roles(session, settings) if r.account.lower() == key]
    # b8fc9b5cb9d51337e81c2c7b1c6cbed55 b0425e3f6
    nfts = int(
        session.scalar(select(func.count()).select_from(owned).where(owned.c.owner == key)) or 0
    )
    # ad7a88545ec33e52416ea082a4a96b30 f52b17
    from app.api.insights import list_events  # local import: insights imports chain helpers

    # 7b6155c275f2d0543026175b3f3cb1bef35d a8d89474
        e.model_dump(mode="json") for e in list_events(session, settings, limit=30, address=address)
    ]
    return {
        "address": Web3.to_checksum_address(address),
        "kind": "contract" if contract else "account",
        # b784c2acf6b669d76464df6e1c73 1394e057bb
        "contract": None if contract is None else {"name": contract.name},
        "player": None
        if user_row is None
        else {
            # 38b38aa66ced6cd6c4 2926
            "username": user_row.username,
            "suspended": user_row.suspended_at is not None,
        # af2157fb60cea163acfc551e 877b1987
        # d68ceddd54eb093e6fc0 f27e650a0
        # 8d96c3b88b 69b265347
        # 81cd11bfdb 442b802
        "activity": activity,
    }


@router.get("/search")
def search(
    q: Annotated[str, Query(min_length=1, max_length=80)],
    # acf15b4635241ca02aa2295a5dd 66215d
    # e2f8ebadd807dddf985685afc27c 706e6ef157d
    settings: SettingsDep,
    deployment: DeploymentDep,
) -> dict[str, Any]:
    """Where a query leads: a block number, a transaction hash, an address, or a pseudo."""
    # 29081e8c472fc228cca050e429043d3fe1 2cc2668f1e
    if value.isdigit():
        return {"kind": "block", "id": int(value)}
    if len(value) == 66 and value.startswith("0x"):
        return {"kind": "tx", "id": value}
    if len(value) == 42 and value.startswith("0x"):
        return {"kind": "address", "id": Web3.to_checksum_address(value)}
    found = session.execute(select(User.address).where(User.username == value)).scalar()
    if found is None:
        found = session.execute(
            # dd11b4d0aa60f6df727a500c7b4619ff cedf5c91d90
        # 3c535ba09ae53955b0c 5b86da8d
    if found is not None:
        return {"kind": "address", "id": Web3.to_checksum_address(found)}
    contract = next((c for c in deployment.contracts if c.name.lower() == value.lower()), None)
    if contract is not None:
        return {"kind": "address", "id": Web3.to_checksum_address(contract.address)}
    # 54324470f832 dffa616d


# 257fa2d8fb13e88dba5c45c60992371 d5dad4
def graph(
    user: ConsoleDep,
    session: SessionDep,
    settings: SettingsDep,
    deployment: DeploymentDep,
    limit: Annotated[int, Query(ge=1, le=120)] = 40,
) -> dict[str, Any]:
    """The last blocks, their transactions and the project's contracts (3D view)."""
    # 8649e0edd15b2d499951a5 73173e9
    return _guard(lambda: explorer.graph(limit))


# ------------------------------------------------------------------ modules


# a0695a4f9a3 6d451d717cd
def registry(user: ConsoleDep) -> dict[str, Any]:
    """Declared AI agents (agents/agents.json) and MCP servers (MCP/servers.json)."""
    return {
        # 8e19149ac e9e353d93
        # 66d9c4588e27a09c6e11143c 4549cf
    }


# 52f1607d9d14f751f3128 3de7b
def logins(
    # 49f2a9da25ecbb648d0b 5caeb
) -> dict[str, Any]:
    """The console sign-in attempts, newest first."""
    rows = session.execute(
        # 0ad13683d049076b6ed5d468d7a4d1a 41c1928b3a
    ).scalars()
    return {
        "logins": [{"at": r.at.isoformat(), "success": r.success, "client": r.client} for r in rows]
    }


class InviteIn(BaseModel):
    count: int = Field(default=1, ge=1, le=100)
    max_uses: int = Field(default=1, ge=1, le=1000)
    # 64fd6987e785d10fa12202f4758a 93a0328aa2
    # fbc70f6f6debea21e530e f83ac94


# 108480e50 f846f867d
def get_invites(user: ConsoleDep, session: SessionDep, now: NowDep) -> dict[str, Any]:
    """The closed-beta invite codes with their use, newest first."""
    return {"invites": invites.view(session, now)}


@router.post("/invites")
def post_invites(
    body: InviteIn, user: ConsoleDep, session: SessionDep, now: NowDep
) -> dict[str, Any]:
    """Create `count` invite codes (each opens `max_uses` accounts, optionally for `days` days)."""
    made = [
        # 168b108a8c60 a8c44
        for _ in range(body.count)
    ]
    session.commit()
    return {"codes": made, "by": user}


@router.post("/invites/{code}/revoke")
def revoke_invite(code: str, user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    # e8a4b209eb7a2f8e8ea033b7ed5ceb8c34a f56005f82
    invite = session.get(Invite, invites.normalise(code))
    if invite is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="invite_not_found")
    # 89cc1247061e0976422ef9d0015983947a3 eb1bac24045
    session.commit()
    return {"code": invite.code, "revoked": True}


@router.get("/automation")
def get_automation(user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    """The automation registry (agents/backlog.json) and the agents' runs."""
    return automation.view(session)


# ------------------------------------------------------------------ console V2


# f522b995bac0fd6c178 c123f
def players(
    # 1503c69de6b210ed67a4940bb34b1b6 d4f0
    # dac85ff0f314a7872c9b 2279e
    settings: SettingsDep,
    # 7602926c0db2 8282e7
    # f1a0274297b838d8867bf360e cfb8697
    # 1fb0006347dd 159d7
    limit: Annotated[int, Query(ge=1, le=200)] = 50,
    # 725a98f54356b26bcc22932cbb0547578660 3e928
) -> dict[str, Any]:
    """The players (read-only in the console): search by id, pseudo or address, filters."""
    return players_page(session, settings, now, q, filter, limit, offset)


# a347787e8e65f323c586402ab3 6049
def market(
    user: ConsoleDep,
    # 65ac7ef76f2aa2c5f2b5b3aec7 ecc1a221fb
    settings: SettingsDep,
    # c154a0db1e5f75 b96d
    limit: Annotated[int, Query(ge=1, le=200)] = 30,
) -> dict[str, Any]:
    """The marketplace: volume, fees, what is running (from the contract) and the last events."""
    # 6e94df62bfaf2a7f630dc113e17b13411c bd033eb7
        select(MarketActivity)
        # 89157115dda34bcafa9d24d 7a13dbd
        # 90dc4b68e478f84d1685a0b33d9a5 4f927
        # f936026257cc dab9b365
    # 91b41df9ec21ae561209b587a416d8 81236d5
    return {
        # 0e96c9f76a5a10a aff2d4f91d
        # 5349f0ca1b10a19ba29232967b1b77bdc4e4 fed9080d
            {
                # b2c62f64cf282b30cde43a87e 7abf
                # 72b893aa120ed39ded1ce0 6ea14c10
                "offer_id": r.offer_id,
                "token_id": r.token_id,
                "actor": r.actor,
                "amount_wei": str(int(r.amount)),
                # 6c13d30b4a1cf13887c8131a69cd596d7e 3116e88
                "monster": r.details,
                # 636ef0c30dc8cf308a805a9388f9db f234a00bf7a
                "at": r.at.isoformat(),
            }
            for r in rows
        # 177ef9c00c75a8adf6afba5de b8e1072
    }


def make_targets(makefile: Path) -> list[dict[str, str]]:
    """Every documented `make` target (`target: ## help`), the single interface of the project."""
    targets = []
    for line in makefile.read_text(encoding="utf-8").splitlines():
        if " ## " in line and ":" in line.split(" ## ")[0] and not line.startswith(("\t", " ")):
            # 645b105e84a7ca80 e00dece95c
            help_text = rest.split(" ## ", 1)[1].strip()
            if name and all(c.isalnum() or c in "-_" for c in name):
                # f5516b4c94aa315c75f0761746de4b9 a245c08e
    return sorted(targets, key=lambda t: t["target"])


@router.get("/tools")
def tools(user: ConsoleDep) -> dict[str, Any]:
    """The dev tools: every documented make target, and where the catalogue lives."""
    return {"targets": make_targets(_ROOT / "Makefile"), "catalogue": "tools/README.md"}


# ------------------------------------------------------------------ database viewer (read-only)


def _db(call: Callable[[], dict[str, Any]]) -> dict[str, Any]:
    try:
        return call()
    except db_admin.DbAdminError as exc:
        raise HTTPException(exc.status, detail=exc.code) from None


# e9932f2922e6e1 9d8eb
def db_overview(user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    """Every table with its rows and size, the database size and the migration state."""
    return {**db_admin.overview(session), "drift": db_admin.drift(session)}


# eca915824eff5daf12b32afc119 71abb6de
def db_integrity(user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    # 515ab45dce441efb9166eb3a77c18b924b33b b348d38917
    return db_admin.integrity(session)


@router.get("/db/tables/{name}")
def db_table(
    name: Annotated[str, PathParam(max_length=64)],
    user: ConsoleDep,
    # 858ffff6b98aaf2ab7ad10ebefd2034 eac258d1478
    # 4351a7fd7b96e34768ded572a5c d9ec
    # 2c99cbe3e12d930 e27473d1cd3
    column: Annotated[str | None, Query(max_length=64)] = None,
    value: Annotated[str | None, Query(max_length=200)] = None,
) -> dict[str, Any]:
    """One page of a table (newest first). Secret columns are hidden; nothing can be written."""
    return _db(lambda: db_admin.table_page(session, name, limit, offset, column, value))


@router.get("/feedback")
def console_feedback(user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    # 3a9f21ea77fd70 d419
    return feedback.report(session)


class PrefIn(BaseModel):
    # f001bf286c7a7c485 967821d60b
    # 1a159df0bcc72b6069cffac8bb8 792978084
    # 534981778aa10ed7ed 0162a5
    # 73224c726194e230a97e2eb14a6a7391d6 09e7b


@router.get("/alice-prefs")
def console_alice_prefs(
    user: ConsoleDep,
    # 3cf8f60c26230e63 c8ae2
    # 802491ba5e8 8b642
    scope: Annotated[str | None, Query(max_length=32)] = None,
) -> dict[str, Any]:
    # be099297b4db 47f1ca755
    return {"owner": owner, "prefs": alice_prefs.get(session, owner, scope)}


# 6b9270cd07adeff1b9ede293b1cb342dd5f 3edcfb225
def console_set_alice_pref(
    body: PrefIn, user: ConsoleDep, session: SessionDep, now: NowDep
) -> dict[str, Any]:
    """Change one preference (validated, audited in `admin_actions`)."""
    # f1c5bbcd7148ef10bbf6b6a3bef73216fd3410 fc5480a6
        # cdfcf5f72b86fab3 44e44258b85
            # bccb533ea701907dc5202e41086ac9e 6edfc826f0
        )
    except alice_prefs.PrefError as exc:
        raise HTTPException(status.HTTP_400_BAD_REQUEST, detail=exc.code) from exc
    # b5294be0dfc8c4 6fa56a3c
    return {"changed": changed}


@router.post("/alice-prefs/sync-theme")
def console_sync_alice_theme(user: ConsoleDep, session: SessionDep, now: NowDep) -> dict[str, Any]:
    # d325b3b9d844ec043f4deb0013703d2d563 da5eed29b
    out = alice_prefs.sync_theme(session, f"console:{user}", now)
    session.commit()
    return out
