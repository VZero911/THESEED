"""Admin console (docs/admin/CAHIER_DES_CHARGES_CONSOLE.md): global view of The Seed for V.

Access with the default `system-admin` account (V's norm): its password lives only in the local
.env (`SYSTEM_ADMIN_PASSWORD`, `make admin-password`). A sign-in gives a 30-minute token valid on
`/console/*` only â€” no right in the game and none on the chain. 5 failed attempts lock the console
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

router = APIRouter(prefix="/console", tags=["console"])

USERNAME = "system-admin"
TOKEN_MINUTES = 120  # V: no more logouts every 2 minutes (was 30)
LOCK_AFTER = 5
LOCK_MINUTES = 15
_AUDIENCE = "the-seed-console"
_ALGORITHM = "HS256"
_ROOT = Path(__file__).resolve().parents[3]
_bearer = HTTPBearer(auto_error=False)


def _enabled(settings: Settings) -> None:
    if settings.environment not in ("local", "test"):
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="console_disabled")
    if settings.system_admin_password is None:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, detail="console_not_configured")


def require_console(
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(_bearer)],
    settings: SettingsDep,
    now: NowDep,
) -> str:
    """The console session (`system-admin`), or 401 `console_unauthorized`."""
    _enabled(settings)
    if credentials is None:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="console_unauthorized")
    try:
        claims = jwt.decode(
            credentials.credentials,
            settings.jwt_key,
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


ConsoleDep = Annotated[str, Depends(require_console)]


class LoginIn(BaseModel):
    username: str = Field(max_length=64)
    password: str = Field(max_length=256)


def _failures(session: Session, now: datetime) -> int:
    """Failed attempts in the last LOCK_MINUTES since the last success."""
    since = now - timedelta(minutes=LOCK_MINUTES)
    last_ok = session.scalar(select(func.max(ConsoleLogin.at)).where(ConsoleLogin.success))
    if last_ok is not None and last_ok > since:
        since = last_ok
    return int(
        session.scalar(
            select(func.count()).where(ConsoleLogin.at > since, ConsoleLogin.success.is_(False))
        )
        or 0
    )


@router.post("/login")
def login(
    body: LoginIn, request: Request, session: SessionDep, settings: SettingsDep, now: NowDep
) -> dict[str, Any]:
    """`system-admin` + password -> a console token (30 min). Locked 15 min after 5 failures."""
    _enabled(settings)
    password = settings.system_admin_password
    if password is None:  # _enabled checks it; a plain check survives `python -O`
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, detail="console_not_configured")
    if _failures(session, now) >= LOCK_AFTER:
        raise HTTPException(status.HTTP_429_TOO_MANY_REQUESTS, detail="console_locked")
    expected = password.get_secret_value().encode()
    ok = hmac.compare_digest(body.username.encode(), USERNAME.encode()) & hmac.compare_digest(
        body.password.encode(), expected
    )
    client = request.client.host if request.client else None
    session.add(ConsoleLogin(at=now, success=ok, client=client))
    session.commit()
    if not ok:
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, detail="console_bad_credentials")
    expires = now + timedelta(minutes=TOKEN_MINUTES)
    token = jwt.encode(
        {
            "sub": USERNAME,
            "aud": _AUDIENCE,
            "iat": int(now.timestamp()),
            "exp": int(expires.timestamp()),
        },
        settings.jwt_key,
        algorithm=_ALGORITHM,
    )
    return {"access_token": token, "expires_in": TOKEN_MINUTES * 60, "username": USERNAME}


@router.get("/me")
def me(user: ConsoleDep) -> dict[str, str]:
    return {"username": user}


@router.post("/notices")
def post_console_notice(
    body: NoticeIn,
    user: ConsoleDep,
    session: SessionDep,
    settings: SettingsDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    """Publish a dev note and anchor it on chain from the console (same rules as
    `POST /admin/notices`: idempotent by `key`, a published note never changes)."""
    note, created = _game_guard(
        lambda: notices.publish(session, key=body.key, kind=body.kind, title=body.title,
                                body=body.body, created_at=now, important=body.important,
                                operator=operator, chain_id=settings.chain_id)
    )  # fmt: skip
    session.commit()
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
    try:
        result = call()
    except ExplorerError as exc:
        raise HTTPException(exc.status, detail=exc.code) from exc
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
    """Alerts about the game operator's gas and the maintenance flag (beta runbook Â§2.4, Â§2.9)."""
    alerts: list[dict[str, str]] = []
    if maintenance_on:
        alerts.append(
            {"level": "warning", "text": "Le jeu est en maintenance (Ã©critures refusÃ©es)."}
        )
    if balance_wei is not None and balance_wei < int(minimum_eth * 10**18):
        alerts.append(
            {
                "level": "error" if balance_wei == 0 else "warning",
                "text": f"L'opÃ©rateur du jeu n'a presque plus d'ETH pour le gas "
                f"({balance_wei / 10**18:.4f} ETH).",
            }
        )
    return alerts


# --- The console's twins of the admin routes (the console token is not a wallet session) ---------


@router.get("/tags")
def console_tags(user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    return admin_api.get_tags(console_actor(user), session)


@router.post("/tags")
def console_give_tag(
    body: admin_api.TagIn, user: ConsoleDep, session: SessionDep, now: NowDep
) -> dict[str, Any]:
    return admin_api.post_tag(body, console_actor(user), session, now)


@router.delete("/tags/{address}/{tag}")
def console_remove_tag(
    address: Annotated[str, PathParam(pattern=r"^0x[0-9a-fA-F]{40}$")],
    tag: str,
    user: ConsoleDep,
    session: SessionDep,
    now: NowDep,
) -> dict[str, bool]:
    return admin_api.delete_tag(address, tag, console_actor(user), session, now)


@router.get("/roles")
def console_roles(user: ConsoleDep, operator: OperatorDep) -> dict[str, Any]:
    """The on-chain role types with their rank and the holder of each unique one (ADR 0036)."""
    return {"roles": _game_guard(lambda: game_roles.catalogue(operator))}


@router.post("/roles")
def console_give_role(
    body: admin_api.RoleIn,
    user: ConsoleDep,
    session: SessionDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    return admin_api.give_role(body, console_actor(user), session, operator, now)


@router.delete("/roles/{address}/{role}")
def console_remove_role(
    address: Annotated[str, PathParam(pattern=r"^0x[0-9a-fA-F]{40}$")],
    role: str,
    user: ConsoleDep,
    session: SessionDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    return admin_api.take_role(address, role, console_actor(user), session, operator, now)


@router.post("/polls/{key}/follow-up")
def console_poll_follow_up(
    key: str,
    body: admin_api.PollFollowUpIn,
    user: ConsoleDep,
    session: SessionDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    return admin_api.follow_up_poll(key, body, console_actor(user), session, operator, now)


@router.get("/reports")
def console_reports(
    user: ConsoleDep,
    session: SessionDep,
    state: Annotated[str, Query(pattern="^(open|closed|all)$")] = "open",
) -> dict[str, Any]:
    return reports_api.list_reports(console_actor(user), session, state)  # type: ignore[arg-type]


@router.post("/reports/{report_id}/close")
def console_close_report(
    report_id: int, user: ConsoleDep, session: SessionDep, now: NowDep
) -> dict[str, Any]:
    return reports_api.close_report(report_id, console_actor(user), session, now)


@router.get("/contributions/rules")
def console_reward_rules(user: ConsoleDep) -> dict[str, Any]:
    return contrib_api.get_rules(console_actor(user))


@router.post("/contributions/quote")
def console_reward_quote(
    body: contrib_api.QuoteIn,
    user: ConsoleDep,
    session: SessionDep,
    operator: contrib_api.MaybeOperator,
    now: NowDep,
) -> dict[str, Any]:
    return contrib_api.post_quote(body, console_actor(user), session, operator, now)


@router.post("/contributions", status_code=status.HTTP_201_CREATED)
def console_reward_propose(
    body: contrib_api.ProposeIn,
    user: ConsoleDep,
    session: SessionDep,
    operator: contrib_api.MaybeOperator,
    now: NowDep,
) -> dict[str, Any]:
    return contrib_api.propose(body, console_actor(user), session, operator, now)


@router.get("/contributions")
def console_reward_list(user: ConsoleDep, session: SessionDep) -> dict[str, Any]:
    return contrib_api.list_awards(console_actor(user), session)


@router.post("/contributions/{award_id}/approve")
def console_reward_approve(
    award_id: int, user: ConsoleDep, session: SessionDep, operator: OperatorDep, now: NowDep
) -> dict[str, Any]:
    return contrib_api.approve(award_id, console_actor(user), session, operator, now)


@router.post("/contributions/{award_id}/reject")
def console_reward_reject(
    award_id: int, user: ConsoleDep, session: SessionDep, now: NowDep
) -> dict[str, Any]:
    return contrib_api.reject(award_id, console_actor(user), session, now)


class MaintenanceBody(BaseModel):
    on: bool
    message: str = Field(default="", max_length=200)


@router.post("/maintenance")
def set_maintenance(body: MaintenanceBody, user: ConsoleDep, request: Request) -> dict[str, Any]:
    """The console's switch for the maintenance flag (same as POST /admin/maintenance)."""
    state = request.app.state.maintenance
    state.on, state.message = body.on, body.message if body.on else ""
    return {"maintenance": state.on, "message": state.message, "by": user}


@router.get("/overview")
def overview(
    request: Request,
    user: ConsoleDep,
    session: SessionDep,
    settings: SettingsDep,
    deployment: DeploymentDep,
    now: NowDep,
) -> dict[str, Any]:
    """Health, chain, economy, game and alerts in one call (console home)."""
    try:
        session.execute(text("SELECT 1"))
        database = True
    except Exception:
        database = False
    explorer = _explorer(session, settings, deployment)
    try:
        head: int | None = explorer.head()
    except ExplorerError:
        head = None
    indexed = indexed_block(session, settings.chain_id)
    lag = None if head is None or indexed is None else max(0, head - indexed)
    economy = get_economy(session, settings, deployment)
    agents = _registry(_ROOT / "agents" / "agents.json", "agents")
    servers = _registry(_ROOT / "MCP" / "servers.json", "servers")

    alerts: list[dict[str, str]] = []
    if head is None:
        alerts.append({"level": "error", "text": "Le nÅ“ud (RPC) ne rÃ©pond pas."})
    if not database:
        alerts.append({"level": "error", "text": "La base de donnÃ©es ne rÃ©pond pas."})
    if lag is not None and lag > 20:
        alerts.append({"level": "warning", "text": f"L'indexer a {lag} blocs de retard."})
    for token in economy.tokens:
        if token.paused:
            alerts.append({"level": "warning", "text": f"{token.symbol} est en pause."})
        if token.epoch and i
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  pO!¬HÏrø˜óð_9~Ož/
¥NÚâ‡Ï˜;¤ãÃ×Þ