"""Game API (milestone 1): catalogue, profile, summon, battle, replays."""

import hashlib
import json
from collections.abc import Callable
from typing import TYPE_CHECKING, Annotated, Any

from fastapi import (
    APIRouter,
    BackgroundTasks,
    Depends,
    HTTPException,
    Path,
    Query,
    Request,
    Response,
    status,
)
from pydantic import BaseModel, ConfigDict, Field
from sqlalchemy import select

from app.api.chain import DeploymentDep, current_monsters
from app.api.deps_locks import gate
from app.auth.deps import CurrentUser, NowDep, SessionDep, SettingsDep
from app.db.models import GameBattle
from app.db.session import SessionFactory, get_session_factory
from app.game import (
    achievements,
    arena,
    banners,
    calendar,
    decks,
    feedback,
    grind_service,
    hints,
    jobs,
    league,
    levels,
    live_events,
    locks,
    materials,
    points,
    polls,
    records,
    rune_automation,
    shop,
    skins,
    storage,
    world_boss,
)
from app.game import settings as player_settings
from app.game.content import Content, load_content
from app.game.errors import GameError
from app.game.idempotency import IdemKey
from app.game.idempotency import run as idempotent
from app.game.mail import (
    claim,
    claim_all,
    ensure_founder_gift,
    list_mail,
    pending_count,
    unclaimed_count,
)
from app.game.monsters import (
    awaken,
    awaken_cost,
    box_capacity,
    craft_unique,
    evolve,
    feed,
    has_items,
    list_items,
    monster_view,
    owned_monsters,
    set_flags,
)
from app.game.operator import GameOperator, OperatorError, SignedPermit
from app.game.rune_service import (
    change_rune,
    equip,
    equipped_runes,
    list_runes,
    reinforce_rune,
    unequip,
    upgrade_rune,
)
from app.game.runes import RuneError, RuneRules, active_sets, apply_runes, load_rune_rules
from app.game.service import (
    REPEAT_MAX,
    SCROLL_BATCH,
    SCROLL_DETAIL,
    TEAM_MAX,
    battle,
    campaign_auto,
    check_summon_funds,
    claim_starter,
    cleared_stages,
    content_view,
    energy_state,
    get_player,
    permit_quote,
    refill_energy,
    refill_wings,
    repeat_battles,
    summon,
    summon_quote,
    summon_with_scroll,
    tokenize_monster,
    wings_state,
)
from app.indexer.decoder import ZERO_ADDRESS

if TYPE_CHECKING:
    from app.game.sacrifice import BurnSignature

router = APIRouter(prefix="/game", tags=["game"])

ContentDep = Annotated[Content, Depends(load_content)]
SessionFactoryDep = Annotated[SessionFactory, Depends(get_session_factory)]
CLAIM_DIRECT = 20  # more pending rewards than this: "claim all" runs in the background
RulesDep = Annotated[RuneRules, Depends(load_rune_rules)]


def get_operator(settings: SettingsDep, deployment: DeploymentDep) -> GameOperator:
    try:
        return GameOperator(settings, deployment)
    except OperatorError as exc:
        raise HTTPException(status.HTTP_503_SERVICE_UNAVAILABLE, detail=exc.code) from exc


OperatorDep = Annotated[GameOperator, Depends(get_operator)]


SIGNATURE = r"^0x[0-9a-fA-F]{130}$"


class SummonRequest(BaseModel):
    """The player's EIP-2612 permit signature over the quote (owner = signed-in user).

    `value` is the permit's value as signed (quote `value_wei`); it defaults to the bare cost.
    """

    deadline: int = Field(ge=0, le=2**63, description="unix seconds")
    signature: str = Field(pattern=SIGNATURE)
    value: str | None = Field(default=None, pattern=r"^[0-9]{1,78}$")
    pool: str = Field(default="standard", max_length=32)
    to_storage: bool = Field(default=False, description="the new monster goes to the storage")


class AllowanceRequest(BaseModel):
    """A permit making `value` (wei) what the game may spend for the player in `currency`."""

    value: str = Field(pattern=r"^[0-9]{1,78}$")
    currency: str = Field(default="mana", pattern="^(mana|poc|crystal)$")
    deadline: int = Field(ge=0, le=2**63, description="unix seconds")
    signature: str = Field(pattern=SIGNATURE)


class ScrollRequest(BaseModel):
    item_id: str = Field(min_length=1, max_length=64)
    count: int = Field(default=1, ge=1, le=SCROLL_BATCH)
    to_storage: bool = Field(default=False, description="the new monsters go to the storage")


class RefillRequest(BaseModel):
    currency: str = Field(pattern="^(poc|crystal)$")


class EquipRequest(BaseModel):
    monster_id: int = Field(ge=1)


class AutoUpgradeRequest(BaseModel):
    rune_ids: list[int] = Field(default=[], max_length=200)
    target_level: int = Field(ge=1, le=25)
    budget_mana: int = Field(ge=0)
    min_rank: str = Field(default="B", max_length=3)
    dry_run: bool = False


class AutoGrindRequest(BaseModel):
    rune_ids: list[int] = Field(default=[], max_length=200)
    stats: list[Annotated[str, Field(max_length=32)]] = Field(min_length=1, max_length=8)
    max_grinds: int = Field(default=50, ge=1, le=500)
    expect_grinds: int | None = Field(default=None, ge=0)  # the human check: the plan seen
    rarity: str | None = Field(default=None, max_length=16)  # None: the cheapest that can help
    dry_run: bool = True  # the preview is the default, the real run is asked for


class AutoEquipRequest(BaseModel):
    monster_ids: list[int] = Field(min_length=1, max_length=10)
    profile: str | None = None
    take_from_others: bool = False
    dry_run: bool = False


class RuneProfileRequest(BaseModel):
    name: str = Field(min_length=1, max_length=40)
    weights: dict[str, float]


class BurnRequest(BaseModel):
    """The player's signature of a `BurnMonsters` message (`POST /game/sacrifice/typed-data`)."""

    deadline: int = Field(ge=0, le=2**63, description="unix seconds")
    signature: str = Field(pattern=r"^0x[0-9a-fA-F]+$", max_length=4096)


class FoodRequest(BaseModel):
    """Monsters to sacrifice (not locked); NFT ones need the player's burn signature (ADR 0023)."""

    food: list[int] = Field(min_length=1, max_length=50)
    burn: BurnRequest | None = None

    def to_burn(self) -> "BurnSignature | None":
        from app.game.sacrifice import BurnSignature

        if self.burn is None:
            return None
        return BurnSignature(deadline=self.burn.deadline, signature=self.burn.signature)


class FlagsRequest(BaseModel):
    stored: bool | None = None
    locked: bool | None = None


class StorageRequest(BaseModel):
    ids: list[int] = Field(min_length=1, max_length=200)
    stored: bool


class ArrangeRequest(BaseModel):
    to_box: list[int] = Field(default=[], max_length=200)
    to_storage: list[int] = Field(default=[], max_length=200)


class AutoArrangeRequest(BaseModel):
    keep_free: int = Field(default=0, ge=0, le=50, description="slots left empty in the box")
    dry_run: bool = True


class AutoStoreRequest(BaseModel):
    max_stars: int = Field(default=3, ge=1, le=6)
    keep_best: int = Field(
        default=1, ge=0, le=50, description="best ones kept in the box, per species"
    )
    only_food: bool = False
    dry_run: bool = True


class SubstatRequest(BaseModel):
    index: int = Field(ge=0, le=4)
    rarity: str | None = Field(default=None, max_length=16)  # None: the cheapest rarity held


class BattleRequest(BaseModel):
    stage_id: str = Field(min_length=1, max_length=64)
    team: list[int] = Field(min_length=1, max_length=TEAM_MAX)


class GrindStartRequest(BaseModel):
    run: str = Field(min_length=1, max_length=64)
    team: list[int] = Field(min_length=1, max_length=TEAM_MAX)


class GrindClaimRequest(BaseModel):
    grind_id: int = Field(ge=1)


class WorldBossRequest(BaseModel):
    """One team per attempt (`teams`, up to 5), or a single `team`: the same monsters and runes
    cannot attack twice in a day (V), so a repeated team is refused (`count` above 1)."""

    teams: list[Annotated[list[int], Field(min_length=1, max_length=20)]] | None = Field(
        default=None, min_length=1, max_length=5
    )
    team: list[int] | None = Field(default=None, min_length=1, max_length=20)
    count: int = Field(default=1, ge=1, le=5)


class PollChoice(BaseModel):
    option: int = Field(ge=0, le=15)
    answer: str | None = Field(default=None, max_length=500)


class PollVote(PollChoice):
    deadline: int = Field(gt=0, lt=2**64)
    signature: str = Field(pattern=r"^0x[0-9a-fA-F]+$", max_length=4000)


class DeckRequest(BaseModel):
    name: str = Field(min_length=1, max_length=40)
    monsters: list[int] = Field(min_length=1, max_length=20)


class CountRequest(BaseModel):
    count: int = Field(default=1, ge=1, le=10)


class ChestRequest(BaseModel):
    count: int = Field(default=1, ge=1, le=shop.CHEST_BATCH)


class RepeatRequest(BattleRequest):
    count: int = Field(ge=1, le=REPEAT_MAX)
    until_max_level: bool = Field(
        default=False, description="farm XP: stop when every team monster is at its max level"
    )
    advance: bool = Field(
        default=False, description="after each victory, go to the next floor (tower, dungeon)"
    )


_CONTENT_BODY: dict[tuple[int, int], tuple[bytes, str]] = {}


@router.get("/content")
def get_content(request: Request, content: ContentDep, rules: RulesDep) -> Response:
    """Species, stages, summon rates, energy and rune rules.

    The catalogue is static for a process and weighs 1.5 MB: it is serialised once, served with an
    ETag (a client that has it gets a 304 with no body) and compressed by the gzip middleware."""
    key = (id(content), id(rules))
    if key not in _CONTENT_BODY:
        body = json.dumps({**content_view(content), "runes": rules_view(rules)}).encode()
        _CONTENT_BODY.clear()
        _CONTENT_BODY[key] = (body, '"' + hashlib.sha256(body).hexdigest()[:20] + '"')
    body, etag = _CONTENT_BODY[key]
    headers = {"ETag": etag, "Cache-Control": "no-cache"}  # always revalidate, cheaply
    if request.headers.get("if-none-match") == etag:
        return Response(status_code=status.HTTP_304_NOT_MODIFIED, headers=headers)
    return Response(body, media_type="application/json", headers=headers)


def rules_view(rules: RuneRules) -> dict[str, Any]:
    return {
        "max_level": rules.max_level,
        "proc_every": rules.proc_every,
        "max_substats": rules.max_substats,
        "stats": {
            k: {
                "label": s.label,
                "category": s.category,
                "reinforceable": s.reinforceable,
                "grind": list(s.grind) if s.grind else None,  # top-rarity range, 6 stars
                "gem": list(s.gem),
            }
            for k, s in rules.stats.items()
        },
        "slots": {str(k): list(v) for k, v in rules.slots.items()},
        "rarities": [
            {"id": r.id, "label": r.label, "substats": r.substats, "base_procs": r.base_procs}
            for r in rules.rarities.values()
        ],
        "sets": [
            {
                "id": s.id,
                "name": s.name,
                "pieces": s.pieces,
                "bonus": s.bonus,
                "scope": s.scope,
            }
            for s in rules.sets.values()
        ],
        "change_cost_mana": rules.change_cost_mana,
        "reinforce_cost_mana": rules.reinforce_cost_mana,
    }


@router.get("/profile")
def get_profile(
    user: CurrentUser,
    session: SessionDep,
    settings: SettingsDep,
    content: ContentDep,
    rules: RulesDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    """Energy, MANA balance and the player's monsters with their game data."""
    owned = current_monsters(settings.chain_id, holder=user.address).subquery()
    token_ids = [
        int(t)
        for t in session.execute(
            select(owned.c.token_id).where(
                owned.c.owner == user.address, owned.c.owner != ZERO_ADDRESS
            )
        ).scalars()
    ]
    monsters = owned_monsters(
        session, user, settings.chain_id, operator.monster_contract, token_ids, content, now
    )
    runes = equipped_runes(session, [m.id for m in monsters])
    player = get_player(session, user, content, now)
    ensure_founder_gift(session, user, content, now)
    energy = energy_state(player, content, now)
    wings = wings_state(player, content, now)
    unlocked = achievements.check(session, user, operator, now, monsters, content)
    level_info = levels.levels_view(session, user, content, now)
    session.commit()
    return {
        "address": user.address,
        "new_achievements": unlocked,
        "checkin_available": not calendar.calendar_view(session, user, now)["checked_today"],
        "levels": level_info,
        "starter_available": player.starter_claimed_at is None,
        "cleared_stages": cleared_stages(session, user),
        "mana_wei": str(_guard(lambda: operator.mana_balance(user.address))),
        "poc_wei": str(_guard(lambda: operator.balance(user.address, "poc"))),
        "crystal_wei": str(
            _guard(lambda: operator.balance(user.address, "crystal"))
            if "crystal" in operator.currencies
            else 0
        ),
        "pot_wei": str(
            _guard(lambda: operator.balance(user.address, "pot"))
            if "pot" in operator.currencies
            else 0
        ),
        "energy": {
            "current": energy.current,
            "max": energy.max,
            "next_in_seconds": energy.next_in_seconds,
        },
        "wings": {
            "current": wings.current,
            "max": wings.max,
            "next_in_seconds": wings.next_in_seconds,
        },
        "monsters": sorted(
            (
                {
                    **(view := monster_view(m, content)),
                    "stats_with_runes": apply_runes(rules, view["stats"], runes[m.id]),
                    "sets": [s.name for s in active_sets(rules, runes[m.id])],
                    "awaken_cost": awaken_cost(content.species[m.species_id], content),
                }
                for m in monsters
            ),
            key=lambda m: (m["stored"], -m["stars"], -m["level"], int(m["id"])),
        ),
        "box_capacity": box_capacity(session, user, content),
        "items": list_items(session, user, content),
        "unclaimed_mail": unclaimed_count(session, user, now),
    }


@router.post("/starter")
def post_starter(
    user: CurrentUser,
    session: SessionDep,
    settings: SettingsDep,
    content: ContentDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    """Once per player: the starter monsters and MANA (see content/summon.json)."""
    result = _guard(lambda: claim_starter(session, user, operator, content, settings.chain_id, now))
    session.commit()
    return result


@router.get("/summon/quote")
def get_summon_quote(
    user: CurrentUser,
    content: ContentDep,
    operator: OperatorDep,
    now: NowDep,
    pool: str = "standard",
) -> dict[str, Any]:
    """The permit to sign for one summon (EIP-712 typed data: domain + Permit message)."""
    return _guard(lambda: summon_quote(operator, user.address, content, pool, now))


@router.post("/summon")
def post_summon(
    body: SummonRequest,
    user: CurrentUser,
    session: SessionDep,
    settings: SettingsDep,
    content: ContentDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    """Burn the summon cost with the player's signed permit and mint a new monster."""
    pool = content.summon_pools.get(body.pool)
    if pool is None:
        raise HTTPException(status.HTTP_404_NOT_FOUND, detail="unknown_summon")
    value = int(body.value) if body.value is not None else pool.cost_mana * 10**18
    permit = _permit(user.address, value, body.deadline, body.signature)
    result = _guard(
        lambda: summon(
            session,
            user,
            operator,
            permit,
            content,
            body.pool,
            settings.chain_id,
            now,
            body.to_storage,
        )
    )
    session.commit()
    return result


@router.get("/allowance/quote")
def get_allowance_quote(
    amount: Annotated[int, Query(ge=0, le=10**12, description="whole tokens")],
    user: CurrentUser,
    operator: OperatorDep,
    now: NowDep,
    currency: Annotated[str, Query(pattern="^(mana|poc|crystal)$")] = "mana",
) -> dict[str, Any]:
    """The permit to sign so the game may spend up to `amount` of a currency (MANA for runes,
    POC or crystals for energy...)."""
    return _guard(lambda: permit_quote(operator, user.address, amount * 10**18, now, currency))


@router.post("/allowance")
def post_allowance(
    body: AllowanceRequest, user: CurrentUser, operator: OperatorDep
) -> dict[str, Any]:
    """Record the signed permit on-chain: the player pays nothing, the operator sends it."""
    permit = _permit(user.address, int(body.value), body.deadline, body.signature)
    tx = _guard(lambda: operator.set_allowance_with_permit(permit, body.currency))
    allowance = _guard(lambda: operator.allowance(user.address, body.currency))
    return {"allowance_wei": str(allowance), "tx": tx}


@router.post("/energy/refill")
def post_refill(
    body: RefillRequest,
    user: CurrentUser,
    session: SessionDep,
    content: ContentDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    """Buy a full bar of energy with POC (for now) or crystals, from the spending allowance."""
    state = _guard(lambda: refill_energy(session, user, operator, body.currency, content, now))
    session.commit()
    return {
        "energy": {
            "current": state.current,
            "max": state.max,
            "next_in_seconds": state.next_in_seconds,
        }
    }


@router.get("/settings")
def get_player_settings(user: CurrentUser, session: SessionDep) -> dict[str, Any]:
    """The player's own setup (navigation bar position, icon order, size), kept on the account."""
    return player_settings.get_settings(session, user).model_dump()


@router.put("/settings")
def put_player_settings(
    body: player_settings.PlayerSettings, user: CurrentUser, session: SessionDep, now: NowDep
) -> dict[str, Any]:
    """Save the player's setup; unknown fields and bad icon ids are refused."""
    saved = player_settings.put_settings(session, user, body, now)
    session.commit()
    return saved.model_dump()


@router.post("/monsters/storage")
def post_storage(
    body: StorageRequest, user: CurrentUser, session: SessionDep, content: ContentDep
) -> dict[str, Any]:
    """Move up to 200 monsters between the box and the storage, all or nothing."""
    rows = _guard(lambda: storage.set_stored_many(session, user, body.ids, body.stored, content))
    session.commit()
    return {
        "monsters": [monster_view(m, content) for m in rows],
        "box": storage.box_state(session, user, content),
    }


@router.post("/monsters/arrange")
def post_arrange(
    body: ArrangeRequest, user: CurrentUser, session: SessionDep, content: ContentDep
) -> dict[str, Any]:
    """Swap monsters between the box and the storage in one request, all or nothing."""
    rows = _guard(
        lambda: storage.arrange(
            session, user, content, to_box=body.to_box, to_storage=body.to_storage
        )
    )
    session.commit()
    return {
        "monsters": [monster_view(m, content) for m in rows],
        "box": storage.box_state(session, user, content),
    }


@router.post("/monsters/auto-arrange")
def post_auto_arrange(
    body: AutoArrangeRequest,
    user: CurrentUser,
    session: SessionDep,
    content: ContentDep,
    now: NowDep,
) -> dict[str, Any]:
    """Fill the box with the best movable monsters (preview by default; a run is logged and can be
    undone). Never moves a locked, awakened, decked or rune-wearing monster."""
    result = _guard(
        lambda: storage.auto_arrange(
            session, user, content, now, keep_free=body.keep_free, dry_run=body.dry_run
        )
    )
    session.commit()
    return result


@router.post("/monsters/auto-arrange/undo")
def post_auto_arrange_undo(
    user: CurrentUser, session: SessionDep, content: ContentDep, now: NowDep
) -> dict[str, Any]:
    """Put back what the last auto-arrange moved (as far as the box has room)."""
    result = _guard(lambda: storage.undo_auto_arrange(session, user, content, now))
    session.commit()
    return result


@router.post("/monsters/auto-store")
def post_auto_store(
    body: AutoStoreRequest, user: CurrentUser, session: SessionDep, content: ContentDep, now: NowDep
) -> dict[str, Any]:
    """Store the monsters that are not needed (never locked, awakened, in a deck or wearing runes).
    Preview by default (`dry_run`); a real run is logged and can be undone."""
    result = _guard(
        lambda: storage.auto_store(
            session,
            user,
            content,
            now,
            max_stars=body.max_stars,
            keep_best=body.keep_best,
            only_food=body.only_food,
            dry_run=body.dry_run,
        )
    )
    session.commit()
    return result


@router.post("/monsters/auto-store/undo")
def post_auto_store_undo(
    user: CurrentUser, session: SessionDep, content: ContentDep, now: NowDep
) -> dict[str, Any]:
    """Bring back the monsters of the last auto-store (as many as the box can hold)."""
    result = _guard(lambda: storage.undo_auto_store(session, user, content, now))
    session.commit()
    return result


class RivalFightRequest(BaseModel):
    team: list[int] = Field(min_length=1, max_length=4)


@router.get("/unlocks")
def get_unlocks(
    user: CurrentUser, session: SessionDep, content: ContentDep, now: NowDep
) -> dict[str, Any]:
    """Which features are open for me and what the closed ones need (a view is never hidden)."""
    return locks.view(session, user, content, now)


@router.get("/hints")
def get_hints(
    user: CurrentUser, session: SessionDep, content: ContentDep, now: NowDep
) -> dict[str, Any]:
    """Welcome notice for new accounts, up to three suggestions, and what is open (no tutorial)."""
    return hints.view(session, user, content, now)


@router.get("/arena/rivals")
def get_arena_rivals(
    user: CurrentUser, session: SessionDep, content: ContentDep, now: NowDep
) -> dict[str, Any]:
    """The ten rivals, what today's first win gives, which are beaten, and the wings."""
    view = arena.rivals_view(session, user, content, now)
    session.commit()
    return view


@router.post("/arena/rivals/{rival}/fight", dependencies=[Depends(gate("arena"))])
def post_arena_rival_fight(
    rival: int,
    body: RivalFightRequest,
    user: CurrentUser,
    session: SessionDep,
    content: ContentDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    """Fight a rival with a team of up to 4: one arena wing, rewards on the day's first win."""
    result = _guard(
        lambda: arena.fight_rival(session, user, operator, rival, body.team, content, now)
    )
    session.commit()
    return result


class DefenseRequest(BaseModel):
    team: list[int] = Field(min_length=1, max_length=4)


class LeagueFightRequest(BaseModel):
    defender: int = Field(ge=1, le=2**31)
    team: list[int] = Field(min_length=1, max_length=4)


@router.put("/arena/defense")
def put_arena_defense(
    body: DefenseRequest, user: CurrentUser, session: SessionDep, operator: OperatorDep, now: NowDep
) -> dict[str, Any]:
    """Set the PvP defense: 1 to 4 of your monsters from the box, leader first."""
    result = _guard(lambda: league.set_defense(session, user, operator, body.team, now))
    session.commit()
    return result


@router.get("/arena/league")
def get_arena_league(
    user: CurrentUser,
    session: SessionDep,
    content: ContentDep,
    now: NowDep,
    refresh: Annotated[int, Query(ge=0, le=1000)] = 0,
) -> dict[str, Any]:
    """My rating, league, season countdown, defense and five opponents near my rating."""
    view = league.league_view(session, user, content, now, refresh)
    session.commit()
    return view


@router.post("/arena/league/fight", dependencies=[Depends(gate("arena"))])
def post_arena_league_fight(
    body: LeagueFightRequest,
    user: CurrentUser,
    session: SessionDep,
    content: ContentDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    """Attack a defender with up to 4 monsters: one arena wing, rating moves on both sides."""
    result = _guard(
        lambda: league.fight(session, user, operator, body.defender, body.team, content, now)
    )
    session.commit()
    return result


@router.get("/arena/league/log")
def get_arena_league_log(user: CurrentUser, session: SessionDep) -> dict[str, Any]:
    """The league fights I took part in, newest first (who attacked me, and my attacks)."""
    return {"log": league.defense_log(session, user)}


@router.get("/arena/league/fights/{fight_id}")
def get_arena_league_fight(fight_id: int, user: CurrentUser, session: SessionDep) -> dict[str, Any]:
    """The replay of one of my league fights."""
    return _guard(lambda: league.fight_replay(session, user, fight_id))


@router.post("/arena/league/season/claim")
def post_arena_season_claim(user: CurrentUser, session: SessionDep, now: NowDep) -> dict[str, Any]:
    """Claim the finished season's reward by the league I ended in (once)."""
    result = _guard(lambda: league.claim_season_reward(session, user, now))
    session.commit()
    return result


@router.post("/wings/refill")
def post_wings_refill(
    body: RefillRequest,
    user: CurrentUser,
    session: SessionDep,
    content: ContentDep,
    operator: OperatorDep,
    now: NowDep,
) -> dict[str, Any]:
    """Buy a full set of arena wings with POC or crystals, from the spending allowance."""
    state = _guard(lambda: refill_wings(session, user, operator, body.currency, content, now))
    session.commit()
    return {
        "wings": {
            "current": state.current,
            "max": state.max,
            "next_in_seconds": state.next_in_seconds,
        }
    }


@router.post("/runes/auto-upgrade")
def post_auto_upgrade(
    body: AutoUpgradeRequest,
    user: CurrentUser,
    session: SessionDep,
    operator: OperatorDep,
    rules: RulesDep,
    now: NowDep,
) -> dict[str, Any]:
    """Upgrade runes up to a level within a Mana budget, stopping the ones that turn bad.
    `dry_run`: the exact cost to the target, nothing spent."""
    result = _guard(
        lambda: rune_automation.auto_upgrade(
            session,
            user,
            operator,
            rules,
            body.rune_ids,
            body.target_level,
            body.budget_mana,
            body.min_rank,
            body.dry_run,
            now,
        )
    )
    session.commit()
    return result


@router.post("/runes/auto-grind")
def post_auto_grind(
    body: AutoGrindRequest,
    user: CurrentUser,
    session: SessionDep,
    operator: OperatorDep,
    rules: RulesDep,
    now: NowDep,
) -> dict[str, Any]:
    """Grind chosen base stats (one grind each) with the grinds in stock. Preview by default;
    for real, `expect_grinds` (from the preview) refuses a plan that
    changed (409 `plan_changed`)."""
    result = _guard(
        lambda: rune_automation.auto_grind(
            session,
            user,
            operator,
            rules,
            body.rune_ids,
            body.stats,
            body.max_grinds,
            body.expect_grinds,
            body.dry_run,
            now,
            body.rarity,
        )
    )
    session.commit()
    return result


@router.post("/runes/auto-equip")
def post_auto_equip(
    body: AutoEquipRequest,
    user: CurrentUser,
    session: SessionDep,
    operator: OperatorDep,
    rules: RulesDep,
    content: ContentDep,
    now: NowDep,
) -> dict[str, Any]:
    """The best runes for these monsters (first = priority); `dry_run` shows the stats before and
    after without changing anything."""
    result = _guard(
        lambda: rune_automation.auto_equip(
            session,
            user,
            opera
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ÚÕx½ –Ûi¼óe¶¾ À )‚éfYI£>?«