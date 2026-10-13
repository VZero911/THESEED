"""The marketplace in the game (ADR 0024): players trade their NFT monsters for POT, on-chain.

The Marketplace contract holds the monsters on sale and the POT of bids and offers, and applies
every rule. This module:
- prepares each action: checks it, shows a preview (fee, what the seller gets, the POT needed) and
  returns the EIP-712 message the player signs (and the POT permit when the allowance is short);
- relays the signed action as SYSTEM, so the player pays no gas;
- mirrors the contract's events into the database for search, filters, price history and the
  journal. The mirror follows the chain whoever sent the transaction (the game or a wallet
  directly): rows are rewritten from the contract's own state, each event is applied once.
"""

from dataclasses import dataclass, field
from datetime import UTC, datetime
from decimal import Decimal
from statistics import median
from typing import Any

from sqlalchemy import func, or_, select, update
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session

from app.db.models import (
    ChainEvent,
    GameMonster,
    GameRune,
    IndexedBlock,
    MarketActivity,
    MarketCursor,
    MarketListing,
    MarketOffer,
    User,
)
from app.game import market_rules as rules
from app.game import txlock
from app.game.content import Content, load_content
from app.game.errors import GameError
from app.game.monsters import box_capacity, box_count, get_owned, monster_view
from app.game.operator import GameOperator, OperatorError, SignedPermit
from app.indexer.decoder import DecodedEvent

SIGNATURE_MINUTES = 10
SETTLE_BATCH = 20
SYNC_BATCH = 1000
PAGE_MAX = 100

KINDS = {"fixed": 0, "auction": 1}
KIND_NAMES = {v: k for k, v in KINDS.items()}
LISTING_STATUS = {1: "active", 2: "sold", 3: "cancelled", 4: "unsold"}
OFFER_STATUS = {1: "active", 2: "accepted", 3: "cancelled"}
ACTIVE = 1

_UINT = "uint256"
_TAIL = [{"name": "nonce", "type": _UINT}, {"name": "deadline", "type": _UINT}]


def _fields(*pairs: tuple[str, str]) -> list[dict[str, str]]:
    return [{"name": name, "type": kind} for name, kind in pairs] + _TAIL


# EIP-712 types, exactly as the contract hashes them.
TYPES: dict[str, list[dict[str, str]]] = {
    "Sell": _fields(
        ("seller", "address"),
        ("tokenId", _UINT),
        ("kind", "uint8"),
        ("price", _UINT),
        ("reservePrice", _UINT),
        ("duration", _UINT),
    ),
    "SetPrice": _fields(("seller", "address"), ("listingId", _UINT), ("price", _UINT)),
    "Cancel": _fields(("seller", "address"), ("listingId", _UINT)),
    "Buy": _fields(("buyer", "address"), ("listingId", _UINT), ("price", _UINT)),
    "Bid": _fields(("bidder", "address"), ("listingId", _UINT), ("amount", _UINT)),
    "Offer": _fields(
        ("buyer", "address"), ("tokenId", _UINT), ("amount", _UINT), ("expiresAt", _UINT)
    ),
    "CancelOffer": _fields(("buyer", "address"), ("offerId", _UINT)),
    "AcceptOffer": _fields(("seller", "address"), ("offerId", _UINT), ("amount", _UINT)),
}
PERMIT_TYPES = {
    "Permit": [
        {"name": "owner", "type": "address"},
        {"name": "spender", "type": "address"},
        {"name": "value", "type": _UINT},
        {"name": "nonce", "type": _UINT},
        {"name": "deadline", "type": _UINT},
    ]
}


@dataclass(frozen=True)
class Action:
    """What a player wants to do on the marketplace (amounts in wei of POT)."""

    action: str
    monster_id: int | None = None
    token_id: int | None = None
    listing_id: int | None = None
    offer_id: int | None = None
    kind: str = "fixed"
    price: int = 0
    reserve: int = 0
    duration: int = 0


@dataclass(frozen=True)
class Signed:
    """The player's signature of the prepared message, and the POT permit when one was asked."""

    deadline: int
    signature: str
    expires_at: int | None = None
    permit: SignedPermit | None = None


@dataclass
class Plan:
    """A checked action: the message to sign, the contract call, what it costs and gives."""

    primary: str
    message: dict[str, Any]
    function: str
    args: tuple[Any, ...]
    pot_needed: int = 0
    preview: dict[str, Any] = field(default_factory=dict)
    monster: GameMonster | None = None


# ------------------------------------------------------------------ preparing an action


def _listing(operator: GameOperator, listing_id: int | None) -> dict[str, Any]:
    listing = operator.market_listing(listing_id) if listing_id else None
    if listing is None:
        raise GameError("listing_not_found", 404)
    if listing["status"] != ACTIVE:
        raise GameError("listing_not_active")
    return listing


def _offer(operator: GameOperator, offer_id: int | None) -> dict[str, Any]:
    offer = operator.market_offer(offer_id) if offer_id else None
    if offer is None:
        raise GameError("offer_not_found", 404)
    if offer["status"] != ACTIVE:
        raise GameError("offer_not_active")
    return offer


def _need_pot(operator: GameOperator, user: User, amount: int) -> None:
    if operator.balance(user.address, "pot") < amount:
        raise GameError("not_enough_pot")


def _sale_preview(amount: int, fee_bps: int) -> dict[str, Any]:
    return {
        "amount_wei": str(amount),
        "fee_bps": fee_bps,
        "fee_wei": str(rules.fee(amount, fee_bps)),
        "seller_gets_wei": str(rules.proceeds(amount, fee_bps)),
    }


def _plan_sell(
    session: Session, user: User, operator: GameOperator, action: Action, config: dict[str, Any]
) -> Plan:
    if action.monster_id is None or action.kind not in KINDS:
        raise GameError("invalid_market_action", 400)
    monster = get_owned(session, user, operator, action.monster_id)
    species = load_content().species.get(monster.species_id)
    refusal = rules.listing_refusal(
        bool(species and species.unique), monster.token_id is not None, monster.locked
    )
    if refusal is not None:  # only unlocked NFT monsters trade; the Infernal uniques never do
        raise GameError(refusal)
    if monster.token_id is None:  # unreachable: the refusal covers it (keeps the type narrow)
        raise GameError("not_tradable")
    if action.price <= 0:
        raise GameError("invalid_price", 400)
    if action.kind == "auction":
        if not rules.MIN_AUCTION_DURATION <= action.duration <= rules.MAX_DURATION:
            raise GameError("invalid_duration", 400)
        if action.reserve and action.reserve < action.price:
            raise GameError("invalid_reserve", 400)
    elif action.reserve or not 0 <= action.duration <= rules.MAX_DURATION:
        raise GameError("invalid_duration" if not action.reserve else "invalid_reserve", 400)
    sale = (
        int(monster.token_id),
        KINDS[action.kind],
        action.price,
        action.reserve,
        action.duration,
    )
    return Plan(
        primary="Sell",
        message={
            "seller": user.address,
            "tokenId": sale[0],
            "kind": sale[1],
            "price": str(sale[2]),
            "reservePrice": str(sale[3]),
            "duration": sale[4],
        },
        function="sellWithSignature",
        args=(user.address, sale),
        preview={
            "kind": action.kind,
            "duration": action.duration,
            "reserve_wei": str(action.reserve),
            **_sale_preview(action.price, config["fee_bps"]),
        },
        monster=monster,
    )


def _plan_listing_change(
    operator: GameOperator, user: User, action: Action, config: dict[str, Any]
) -> Plan:
    """Cancel a listing without bids, or change the price of a fixed-price one (the seller only)."""
    me = user.address
    listing = _listing(operator, action.listing_id)
    if listing["seller"] != me:
        raise GameError("not_your_listing", 403)
    if action.action == "cancel":
        if listing["bidder"] is not None:
            raise GameError("listing_has_bids")
        return Plan(
            "Cancel",
            {"seller": me, "listingId": action.listing_id},
            "cancelWithSignature",
            (me, action.listing_id),
            preview={"returns_token_id": str(listing["token_id"])},
        )
    if listing["kind"] != KINDS["fixed"]:
        raise GameError("wrong_listing_kind")
    if action.price <= 0:
        raise GameError("invalid_price", 400)
    return Plan(
        "SetPrice",
        {"seller": me, "listingId": action.listing_id, "price": str(action.price)},
        "setPriceWithSignature",
        (me, action.listing_id, action.price),
        preview={
            "previous_wei": str(listing["price"]),
            **_sale_preview(action.price, config["fee_bps"]),
        },
    )


def _plan_buy_or_bid(
    operator: GameOperator, user: User, action: Action, config: dict[str, Any], chain_now: int
) -> Plan:
    """Buy a fixed-price listing or bid on an auction (never one's own, never an ended one)."""
    me = user.address
    listing = _listing(operator, action.listing_id)
    if listing["seller"] == me:
        raise GameError("own_listing")
    if listing["ends_at"] and chain_now >= listing["ends_at"]:
        raise GameError("listing_ended")
    if action.action == "buy":
        if listing["kind"] != KINDS["fixed"]:
            raise GameError("wrong_listing_kind")
        if listing["price"] != action.price:
            raise GameError("price_changed")
        _need_pot(operator, user, action.price)
        return Plan(
            "Buy",
            {"buyer": me, "listingId": action.listing_id, "price": str(action.price)},
            "buyWithSignature",
            (me, action.listing_id, action.price),
            pot_needed=action.price,
            preview=_sale_preview(action.price, config["fee_bps"]),
        )
    if listing["kind"] != KINDS["auction"]:
        raise GameError("wrong_listing_kind")
    minimum = rules.min_next_bid(
        listing["price"],
        listing["bid"],
        listing["bidder"] is not None,
        config["min_bid_increment_bps"],
    )
    if action.price < minimum:
        raise GameError("bid_too_low")
    _need_pot(operator, user, action.price)
    return Plan(
        "Bid",
        {"bidder": me, "listingId": action.listing_id, "amount": str(action.price)},
        "bidWithSignature",
        (me, action.listing_id, action.price),
        pot_needed=action.price,
        preview={
            "amount_wei": str(action.price),
            "min_next_bid_wei": str(minimum),
            "ends_at": rules.extended_end(
                listing["ends_at"], chain_now, config["extension_window"]
            ),
            "reserve_met": action.price >= listing["reserve_price"],
        },
    )


def _plan_offer(
    operator: GameOperator, user: User, action: Action, chain_now: int, expires_at: int | None
) -> Plan:
    """An offer on a monster, escrowed in POT, that its holder (or its seller) may accept."""
    me = user.address
    if action.token_id is None or action.price <= 0:
        raise GameError("invalid_price", 400)
    if not 0 < action.duration <= rules.MAX_DURATION:
        raise GameError("invalid_duration", 400)
    holder = operator.owner_of(action.token_id)
    if holder is None:
        raise GameError("monster_not_found", 404)
    listing_id = operator.market_listing_of_token(action.token_id)
    if listing_id:
        holder = (operator.market_listing(listing_id) or {}).get("seller")
    if holder == me:
        raise GameError("own_listing")
    _need_pot(operator, user, action.price)
    # Signed by the player: the expiry returned by the preview comes back with the signature.
    expiry = expires_at if expires_at is not None else chain_now + action.duration
    return Plan(
        "Offer",
        {
            "buyer": me,
            "tokenId": action.token_id,
            "amount": str(action.price),
            "expiresAt": expiry,
        },
        "makeOfferWithSignature",
        (me, action.token_id, action.price, expiry),
        pot_needed=action.price,
        preview={"amount_wei": str(action.price), "expires_at": expiry},
    )


def _plan_cancel_offer(operator: GameOperator, user: User, action: Action) -> Plan:
    me = user.address
    offer = _offer(operator, action.offer_id)
    if offer["buyer"] != me:
        raise GameError("not_your_offer", 403)
    return Plan(
        "CancelOffer",
        {"buyer": me, "offerId": action.offer_id},
        "cancelOfferWithSignature",
        (me, action.offer_id),
        preview={"refund_wei": str(offer["amount"])},
    )


def _plan_accept_offer(
    session: Session,
    user: User,
    operator: GameOperator,
    action: Action,
    config: dict[str, Any],
    chain_now: int,
) -> Plan:
    """Accept an offer on a monster the player holds or has listed (without bids)."""
    me = user.address
    offer = _offer(operator, action.offer_id)
    if chain_now >= offer["expires_at"]:
        raise GameError("offer_expired")
    if offer["buyer"] == me:
        raise GameError("own_listing")
    listing_id = operator.market_listing_of_token(offer["token_id"])
    monster = None
    if listing_id:
        listing = _listing(operator, listing_id)
        if listing["seller"] != me:
            raise GameError("not_your_monster", 403)
        if listing["bidder"] is not None:
            raise GameError("listing_has_bids")
    else:
        if operator.owner_of(offer["token_id"]) != me:
            raise GameError("not_your_monster", 403)
        monster = _monster_of_token(session, operator, offer["token_id"])
        if monster is not None and monster.locked:
            raise GameError("monster_locked")
    return Plan(
        "AcceptOffer",
        {"seller": me, "offerId": action.offer_id, "amount": str(offer["amount"])},
        "acceptOfferWithSignature",
        (me, action.offer_id, offer["amount"]),
        preview=_sale_preview(offer["amount"], config["fee_bps"]),
        monster=monster,
    )


def _plan(
    session: Session, user: User, operator: GameOperator, action: Action, expires_at: int | None
) -> Plan:
    """Check an action against the chain's current state and build its message and call."""
    config = operator.market_config()
    name = action.action
    if config["paused"] and name not in ("cancel", "cancel_offer"):
        raise GameError("market_paused")
    if name == "sell":
        return _plan_sell(session, user, operator, action, config)
    if name in ("set_price", "cancel"):
        return _plan_listing_change(operator, user, action, config)
    if name in ("buy", "bid"):
        return _plan_buy_or_bid(operator, user, action, config, operator.chain_time())
    if name == "offer":
        return _plan_offer(operator, user, action, operator.chain_time(), expires_at)
    if name == "cancel_offer":
        return _plan_cancel_offer(operator, user, action)
    if name == "accept_offer":
        return _plan_accept_offer(session, user, operator, action, config, operator.chain_time())
    raise GameError("invalid_market_action", 400)


def _mirror_lock(session: Session, operator: GameOperator) -> None:
    """The mirror's writers (relays, settlements, `sync`) take this lock BEFORE any row lock, so
    they cannot deadlock on a monster row; it is held until the commit."""
    txlock.lock(session, "market-mirror", _chain(operator), operator.market_address())


def _deadline(operator: GameOperator, now: datetime) -> int:
    """Ten minutes from now, by the later of the server's and the chain's clocks."""
    return max(int(now.timestamp()), operator.chain_time()) + SIGNATURE_MINUTES * 60


def prepare(
    session: Session, user: User, operator: GameOperator, action: Action, now: datetime
) -> dict[str, Any]:
    """Preview of an action (nothing changes) and the message(s) the player signs."""
    plan = _plan(session, user, operator, action, None)
    deadline = _deadline(operator, now)
    market = operator.market_address()
    permit = None
    allowance = operator.allowance(user.address, "pot", market) if plan.pot_needed else 0
    if plan.pot_needed > allowance:
        pot = operator.currency("pot")
        permit = {
            "domain": {
                "name": operator.token_name("pot"),
                "version": "1",
                "chainId": int(operator.w3.eth.chain_id),
                "verifyingContract": str(pot.address),
            },
            "types": PERMIT_TYPES,
            "primaryType": "Permit",
            "message": {
                "owner": user.address,
                "spender": market,
                "value": str(plan.pot_needed),
                "nonce": operator.permit_nonce(user.address, "pot"),
                "deadline": deadline,
            },
        }
    return {
        "typed_data": {
            "domain": operator.market_domain(),
            "types": {plan.primary: TYPES[plan.primary]},
            "primaryType": plan.primary,
            "message": {
                **plan.message,
                "nonce": operator.market_nonce(user.address),
                "deadline": deadline,
            },
        },
        "permit": permit,
        "preview": {
            **plan.preview,
            "pot_needed_wei": str(plan.pot_needed),
            "balance_wei": str(operator.balance(user.address, "pot")),
        },
    }


def submit(
    session: Session,
    user: User,
    operator: GameOperator,
    content: Content,
    action: Action,
    signed: Signed,
    now: datetime,
) -> dict[str, Any]:
    """Relay the player's signed action on-chain and bring the mirror up to date."""
    _mirror_lock(session, operator)
    plan = _plan(session, user, operator, action, signed.expires_at)
    market = operator.market_address()
    if plan.pot_needed:
        if signed.permit is not None:
            operator.set_allowance_with_permit(signed.permit, "pot", market)
        if operator.allowance(user.address, "pot", market) < plan.pot_needed:
            raise GameError("allowance_too_low")
    receipt = operator.market_send(
        plan.function,
        *plan.args,
        signed.deadline,
        bytes.fromhex(signed.signature.removeprefix("0x")),
    )
    applied = apply_receipt(session, operator, content, receipt)
    session.flush()
    tx = "0x" + bytes(receipt["transactionHash"]).hex()
    return {"tx": tx, "events": applied}


def settle(
    session: Session,
    operator: GameOperator,
    content: Content,
    listing_id: int,
    requester: str | None = None,
) -> dict[str, Any]:
    """End a listing that reached its end (SYSTEM pays the gas). With a `requester` (a player
    asking through the API), only the seller or the highest bidder may ask (#27)."""
    _mirror_lock(session, operator)
    listing = _listing(operator, listing_id)
    if requester is not None and requester not in (listing["seller"], listing["bidder"]):
        raise GameError("not_your_listing", 403)
    if not listing["ends_at"] or operator.chain_time() < listing["ends_at"]:
        raise GameError("listing_not_ended")
    receipt = operator.market_send("settle", listing_id)
    applied = apply_receipt(session, operator, content, receipt)
    session.flush()
    return {"tx": "0x" + bytes(receipt["transactionHash"]).hex(), "events": applied}


def settle_due(
    session: Session, operator: GameOperator, content: Content, limit: int = SETTLE_BATCH
) -> dict[str, Any]:
    """Settle the listings whose end has passed (at most `limit`), oldest end first."""
    chain_now = datetime.fromtimestamp(operator.chain_time(), UTC)
    due = session.execute(
        select(MarketListing.listing_id)
        .where(
            MarketListing.chain_id == _chain(operator),
            MarketListing.contract == operator.market_address(),
            MarketListing.status == "active",
            MarketListing.ends_at.is_not(None),
            MarketListing.ends_at <= chain_now,
        )
        .order_by(MarketListing.ends_at)
        .limit(limit)
    ).scalars()
    settled, failed = [], []
    for listing_id in list(due):
        try:
            settle(session, operator, content, int(listing_id))
            settled.append(int(listing_id))
        except (GameError, OperatorError):
            failed.append(int(listing_id))
            _refresh_listing(session, operator, content, int(listing_id), chain_now)
    return {"settled": settled, "failed": failed}


# ------------------------------------------------------------------ mirror


def _chain(operator: GameOperator) -> int:
    return int(operator.w3.eth.chain_id)


def _chain_now(operator: GameOperator) -> datetime:
    """The chain's clock: what the contract compares ends and expiries with."""
    return datetime.fromtimestamp(operator.chain_time(), UTC)


def _when(seconds: int) -> datetime | None:
    return datetime.fromtimestamp(seconds, UTC) if seconds else None


def _monster_of_token(
    session: Session, operator: GameOperator, token_id: int
) -> GameMonster | None:
    return session.execute(
        select(GameMonster).where(
            GameMonster.chain_id == _chain(operator),
            GameMonster.contract == operator.monster_contract,
            GameMonster.token_id == token_id,
        )
    ).scalar_one_or_none()


def _snapshot(monster: GameMonster | None, content: Content) -> dict[str, Any]:
    if monster is None:
        return {}
    species = content.species.get(monster.species_id)
    return {
        "species": monster.species_id,
        "element": species.element if species else None,
        "stars": monster.stars,
        "level": monster.level,
        "awakened": monster.awakened,
    }


def _user_of(session: Session, address: str | None) -> User | None:
    if address is None:
        return None
    return session.execute(select(User).where(User.address == address)).scalar_one_or_none()


def _move_monster(
    session: Session, monster: GameMonster | None, holder: User | None, content: Content
) -> None:
    """Hand a monster to its new holder in the game: runes off, unlocked, in the box if it fits.
    `holder` None: the monster is in escrow (or held by a wallet that never played)."""
    if monster is None:
        return
    session.execute(
        update(GameRune)
        .where(GameRune.monster_id == monster.id)
        .values(monster_id=None)
        .execution_options(synchronize_session=False)
    )
    if holder is not None and monster.user_id != holder.id:
        monster.stored = box_count(session, holder) >= box_capacity(session, holder, content)
    monster.locked = False
    monster.user_id = None if holder is None else holder.id


def _refresh_listing(
    session: Session, operator: GameOperator, content: Content, listing_id: int, at: datetime
) -> MarketListing | None:
    """Rewrite a listing's row from the contract's state."""
    state = operator.market_listing(listing_id)
    if state is None:
        return None
    chain, contract = _chain(operator), operator.market_address()
    row = session.execute(
        select(MarketListing).where(
            MarketListing.chain_id == chain,
            MarketListing.contract == contract,
            MarketListing.listing_id == listing_id,
        )
    ).scalar_one_or_none()
    if row is None:
        monster = _monster_of_token(session, operator, state["token_id"])
        snap = _snapshot(monster, content)
        row = MarketListing(
            chain_id=chain,
            contract=contract,
            listing_id=listing_id,
            seller=state["seller"],
            token_id=state["token_id"],
            monster_id=None if monster is None else monster.id,
            species_id=snap.get("species"),
            element=snap.get("element"),
            stars=snap.get("stars"),
            level=snap.get("level"),
            awakened=bool(snap.get("awakened")),
            kind=KIND_NAMES[state["kind"]],
            status="active",
            price=Decimal(state["price"]),
            created_at=at,
        )
        session.add(row)
    row.status = LISTING_STATUS[state["status"]]
    row.price = Decimal(state["price"])
    row.reserve_price = Decimal(state["reserve_price"])
    row.ends_at = _when(state["ends_at"])
    row.bidder = state["bidder"]
    row.bid = Decimal(state["bid"])
    if row.status !=
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  Ω[#
£ÎáˆM2¿ÑPaè§ﬂØ˝+sL„íÅf‹È