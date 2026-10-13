"""Game rules on top of the content, the battle engine, the database and the operator."""

import secrets
from collections.abc import Callable
from dataclasses import dataclass
from datetime import datetime, timedelta
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.orm import Session

from app.db.models import GameBattle, GameMonster, GamePlayer, GameStageClear, GameSummon, User
from app.game import live_events, materials, points
from app.game.battle import TeamMember, simulate
from app.game.content import (
    Content,
    EnergyRules,
    Gift,
    Item,
    ItemDrop,
    Species,
    Stage,
    SummonPool,
    can_summon,
)
from app.game.errors import GameError
from app.game.monsters import (
    TOKENIZE_MIN_STARS,
    add_items,
    get_owned,
    get_owned_many,
    give_monster,
    has_items,
    monster_view,
    take_items,
)
from app.game.operator import GameOperator, OperatorError, SignedPermit
from app.game.runes import load_rune_rules
from app.game.stats import add_xp, max_level, xp_to_next

TOKEN_UNIT = 10**18
TEAM_MIN, TEAM_MAX = (
    1,
    18,
)  # 18 is the most any stage takes (grindstone dungeons, V); a stage says its own size


# ------------------------------------------------------------------ energy


@dataclass(frozen=True)
class EnergyState:
    current: int
    max: int
    next_in_seconds: int | None  # None when full


def energy_state(player: GamePlayer, content: Content, now: datetime) -> EnergyState:
    """Energy regenerates up to the max; above it (refills, gifts) it simply stays until spent."""
    rules = content.energy
    if player.energy >= rules.max:
        return EnergyState(player.energy, rules.max, None)
    elapsed = max(0, int((now - player.energy_updated_at).total_seconds()))
    gained = elapsed // rules.regen_seconds
    current = min(rules.max, player.energy + gained)
    if current >= rules.max:
        return EnergyState(current, rules.max, None)
    return EnergyState(current, rules.max, rules.regen_seconds - elapsed % rules.regen_seconds)


def spend_energy(player: GamePlayer, amount: int, content: Content, now: datetime) -> None:
    state = energy_state(player, content, now)
    if state.current < amount:
        raise GameError("not_enough_energy")
    if state.current >= state.max:
        player.energy_updated_at = now  # regeneration starts from the moment we drop below max
    else:
        # Keep the partial progress towards the next point.
        elapsed = int((now - player.energy_updated_at).total_seconds())
        player.energy_updated_at = now - timedelta(seconds=elapsed % content.energy.regen_seconds)
    player.energy = state.current - amount


def refill_energy(
    session: Session,
    user: User,
    operator: GameOperator,
    currency: str,
    content: Content,
    now: datetime,
) -> EnergyState:
    """Buy a full bar of energy (added on top of the current one) with POC or crystals."""
    cost = content.energy.refill.get(currency)
    if cost is None:
        raise GameError("unknown_currency", 400)
    player = get_player(session, user, content, now)
    state = energy_state(player, content, now)
    spend(operator, user.address, cost, currency)
    player.energy = state.current + content.energy.max
    player.energy_updated_at = now
    session.flush()
    return energy_state(player, content, now)


# ------------------------------------------------------------------ arena wings


def _wings_of(player: GamePlayer, rules: EnergyRules, now: datetime) -> EnergyState:
    """Same regeneration as energy; a player who never fought starts with the full start value."""
    if player.wings is None or player.wings_updated_at is None:
        return EnergyState(
            rules.start, rules.max, None if rules.start >= rules.max else rules.regen_seconds
        )
    if player.wings >= rules.max:
        return EnergyState(player.wings, rules.max, None)
    elapsed = max(0, int((now - player.wings_updated_at).total_seconds()))
    current = min(rules.max, player.wings + elapsed // rules.regen_seconds)
    if current >= rules.max:
        return EnergyState(current, rules.max, None)
    return EnergyState(current, rules.max, rules.regen_seconds - elapsed % rules.regen_seconds)


def wings_state(player: GamePlayer, content: Content, now: datetime) -> EnergyState:
    return _wings_of(player, content.wings, now)


def spend_wings(player: GamePlayer, amount: int, content: Content, now: datetime) -> None:
    """One wing per arena fight; regeneration keeps its partial progress."""
    rules = content.wings
    state = _wings_of(player, rules, now)
    if state.current < amount:
        raise GameError("not_enough_wings")
    if player.wings is None or player.wings_updated_at is None or state.current >= state.max:
        player.wings_updated_at = now
    else:
        elapsed = int((now - player.wings_updated_at).total_seconds())
        player.wings_updated_at = now - timedelta(seconds=elapsed % rules.regen_seconds)
    player.wings = state.current - amount


def refill_wings(
    session: Session,
    user: User,
    operator: GameOperator,
    currency: str,
    content: Content,
    now: datetime,
) -> EnergyState:
    """Buy a full set of wings (added on top of the current ones) with POC or crystals."""
    cost = content.wings.refill.get(currency)
    if cost is None:
        raise GameError("unknown_currency", 400)
    player = get_player(session, user, content, now)
    state = _wings_of(player, content.wings, now)
    spend(operator, user.address, cost, currency)
    player.wings = state.current + content.wings.max
    player.wings_updated_at = now
    session.flush()
    return _wings_of(player, content.wings, now)


def get_player(session: Session, user: User, content: Content, now: datetime) -> GamePlayer:
    player = session.get(GamePlayer, user.id, with_for_update=True)
    if player is None:
        player = GamePlayer(user_id=user.id, energy=content.energy.start, energy_updated_at=now)
        session.add(player)
        session.flush()
    return player


# ------------------------------------------------------------------ summon


def permit_quote(
    operator: GameOperator, owner: str, value_wei: int, now: datetime, currency: str = "mana"
) -> dict[str, Any]:
    """An EIP-2612 permit to sign (EIP-712 domain + fields): `value_wei` becomes the operator's
    allowance, i.e. how much of `currency` (mana, poc, crystal) the game may spend for the player
    until it is used up."""
    return {
        "currency": currency,
        "value_wei": str(value_wei),
        "balance_wei": str(operator.balance(owner, currency)),
        "allowance_wei": str(operator.allowance(owner, currency)),
        "spender": operator.address,
        "nonce": operator.permit_nonce(owner, currency),
        # Ten minutes by the later of the server's and the chain's clocks (they can differ).
        "deadline": max(int(now.timestamp()), operator.chain_time()) + 600,
        "domain": {
            "name": operator.token_name(currency),
            "version": "1",
            "chainId": operator.w3.eth.chain_id,
            "verifyingContract": operator.currency(currency).address,
        },
    }


def summon_pool(content: Content, pool_id: str) -> SummonPool:
    pool = content.summon_pools.get(pool_id)
    if pool is None:
        raise GameError("unknown_summon", 404)
    return pool


def pool_scroll(content: Content, pool_id: str) -> str:
    """The scroll item of a summon pool: every summon burns one of them (and the pool's Mana)."""
    for item in content.items.values():
        if item.pool == pool_id:
            return item.id
    raise GameError("not_a_scroll", 500)


def summon_quote(
    operator: GameOperator, owner: str, content: Content, pool_id: str, now: datetime
) -> dict[str, Any]:
    """The permit for one summon. Its value is the cost plus the current allowance, so a summon
    does not wipe the spending allowance the player granted for runes (a permit replaces it)."""
    cost = summon_pool(content, pool_id).cost_mana * TOKEN_UNIT
    allowance = operator.mana_allowance(owner)
    return {"cost_wei": str(cost), **permit_quote(operator, owner, cost + allowance, now)}


def spend(operator: GameOperator, owner: str, amount: int, currency: str = "mana") -> str:
    """Burn `amount` whole tokens of `currency` from the player's allowance. Returns the tx."""
    wei = amount * TOKEN_UNIT
    if operator.balance(owner, currency) < wei:
        raise GameError(f"not_enough_{currency}")
    if operator.allowance(owner, currency) < wei:
        raise GameError("allowance_too_low")
    return operator.burn_from(owner, wei, currency)


TOKENIZE_FEE_MANA = 100  # V's option to tokenize a 3-star monster: a small Mana fee (placeholder)


def tokenize_monster(
    session: Session,
    user: User,
    operator: GameOperator,
    monster_id: int,
    content: Content,
) -> dict[str, Any]:
    """Turn an off-chain 3-star monster into an NFT (V: 3-star monsters are off chain, with an
    option to tokenize). The balance and the allowance are checked first, the NFT is minted and
    linked and written down at once (an NFT without its monster would be adopted as a stranger),
    then the fee is burned."""
    monster = get_owned(session, user, operator, monster_id)
    species = content.species[monster.species_id]
    if monster.token_id is not None:
        raise GameError("already_nft")
    if species.stars < TOKENIZE_MIN_STARS or species.role == "food":
        raise GameError("not_tokenizable")
    wei = TOKENIZE_FEE_MANA * TOKEN_UNIT
    if operator.balance(user.address, "mana") < wei:
        raise GameError("not_enough_mana")
    if operator.allowance(user.address, "mana") < wei:
        raise GameError("allowance_too_low")
    token_id, mint_tx = operator.mint_monster(user.address)
    monster.token_id, monster.contract = token_id, operator.monster_contract
    session.flush()
    session.commit()  # the NFT exists on the chain: the link must not be lost
    burn_tx = operator.burn_from(user.address, wei, "mana")
    return {"monster": monster_view(monster, content), "tx": mint_tx, "fee_tx": burn_tx,
            "fee_mana": TOKENIZE_FEE_MANA}  # fmt: skip


def pay_mana(
    session: Session,
    user: User,
    operator: GameOperator,
    amount_wei: int,
    key: str,
    now: datetime,
) -> tuple[str | None, bool]:
    """Mint a Mana reward. When the period's mint budget is spent (`budget_exhausted`), the reward
    goes to the reward box instead, so a victory or a starter pack is never lost or refused for
    that reason. Returns (transaction, sent to the box)."""
    if amount_wei <= 0:
        return None, False
    try:
        return operator.mint_mana(user.address, amount_wei), False
    except OperatorError as exc:
        if exc.code != "budget_exhausted":
            raise
    from app.game.mail import send  # mail builds on this module

    gift = Gift(
        sender="SYSTEM",
        title="RÃ©compense en attente",
        body="La limite de crÃ©ation du jour est atteinte : ta rÃ©compense t'attend ici.",
        rewards={"mana": amount_wei // TOKEN_UNIT},
    )
    send(session, user, gift, now, key=key, days=None)
    return None, True


def spend_mana(operator: GameOperator, owner: str, amount_mana: int) -> str:
    return spend(operator, owner, amount_mana, "mana")


def roll_species(content: Content, pool: SummonPool, rng: secrets.SystemRandom) -> Species:
    """Draw a (lane, natural stars) outcome with the pool's weights, then a species of that grade
    among the lane's elements (light and dark only come out of pools that list them)."""
    outcomes = [
        (lane.elements, star, weight)
        for lane in pool.lanes
        for star, weight in sorted(lane.star_weights.items())
    ]
    elements, stars, _ = rng.choices(outcomes, weights=[o[2] for o in outcomes])[0]
    candidates = sorted(
        (s for s in content.species.values() if can_summon(s, stars, pool, elements)),
        key=lambda s: s.id,
    )
    return rng.choice(candidates)


def summon(
    session: Session,
    user: User,
    operator: GameOperator,
    permit: SignedPermit,
    content: Content,
    pool_id: str,
    chain_id: int,
    now: datetime,
    to_storage: bool = False,
) -> dict[str, Any]:
    """One summon: a scroll of the pool AND its Mana (V), the Mana burned with the player's permit.

    The permit may allow more than the cost: the rest stays as the spending allowance.
    """
    pool = summon_pool(content, pool_id)
    scroll = pool_scroll(content, pool_id)
    cost = pool.cost_mana * TOKEN_UNIT
    if permit.value < cost:
        raise GameError("wrong_cost", 400)
    # The scroll is taken (row locked) BEFORE the Mana burn: two concurrent summons with one
    # scroll cannot both burn Mana; if the burn fails, the rollback gives the scroll back.
    take_items(session, user, scroll, 1)
    if operator.mana_balance(user.address) < cost:
        raise GameError("not_enough_mana")
    burn_tx = operator.burn_with_permit(permit, cost)
    species = roll_species(content, pool, secrets.SystemRandom())
    monster, mint_tx = give_monster(
        session, user, operator, content, species, chain_id, "summon", now, to_storage
    )
    session.add(
        GameSummon(
            user_id=user.id,
            chain_id=chain_id,
            token_id=monster.token_id,
            monster_id=monster.id,
            species_id=species.id,
            stars=species.stars,
            cost_wei=cost,
            burn_tx=burn_tx,
            mint_tx=mint_tx,
            created_at=now,
        )
    )
    points.award(session, user, "summon", now=now)
    session.flush()
    return {"monster": monster_view(monster, content), "burn_tx": burn_tx, "mint_tx": mint_tx}


SCROLL_BATCH = 1000  # V: summons x1, x10, x100 and x1000
SCROLL_DETAIL = 10  # above this, the answer lists the best monsters and a summary


def check_summon_funds(
    operator: GameOperator, owner: str, content: Content, item_id: str, count: int
) -> None:
    """The Mana of `count` summons with this scroll is there and the game may spend it (V: scroll
    AND Mana). Raised before anything is taken, so a refused x1000 costs nothing."""
    item = content.items.get(item_id)
    if item is None or item.pool is None:
        raise GameError("not_a_scroll", 400)
    total = summon_pool(content, item.pool).cost_mana * TOKEN_UNIT * count
    if operator.mana_balance(owner) < total:
        raise GameError("not_enough_mana")
    if total and operator.allowance(owner, "mana") < total:
        raise GameError("allowance_too_low")


def summon_with_scroll(
    session: Session,
    user: User,
    operator: GameOperator,
    item_id: str,
    count: int,
    content: Content,
    chain_id: int,
    now: datetime,
    progress: Callable[[int], None] | None = None,
    to_storage: bool = False,
) -> dict[str, Any]:
    """Use summon scrolls (drops, gifts, end of the campaign). V: a summon is a scroll AND Mana,
    so each one burns the pool's Mana from the player's spending allowance too.
    `progress(n)` is called after each summon (background jobs, #21)."""
    item = content.items.get(item_id)
    if item is None or item.pool is None:
        raise GameError("not_a_scroll", 400)
    if not 1 <= count <= SCROLL_BATCH:
        raise GameError("invalid_count", 400)
    if not has_items(session, user, item_id, count):
        raise GameError("not_enough_items")
    pool = summon_pool(content, item.pool)
    cost = pool.cost_mana * TOKEN_UNIT
    check_summon_funds(operator, user.address, content, item_id, count)
    rng = secrets.SystemRandom()
    monsters = []
    for _ in range(count):
        # One summon at a time, committed right after its mint: if a mint fails in a x1000, the
        # summons already done stay recorded (their NFTs exist) and the rest of the scrolls and
        # of the Mana stay.
        take_items(session, user, item_id, 1)
        burn_tx = operator.burn_from(user.address, cost, "mana") if cost else "scroll:" + item_id
        species = roll_species(content, pool, rng)
        monster, mint_tx = give_monster(
            session, user, operator, content, species, chain_id, "summon", now, to_storage
        )
        session.add(
            GameSummon(
                user_id=user.id,
                chain_id=chain_id,
                token_id=monster.token_id,
                monster_id=monster.id,
                species_id=species.id,
                stars=species.stars,
                cost_wei=cost,
                burn_tx=burn_tx,
                mint_tx=mint_tx,
                created_at=now,
            )
        )
        monsters.append(monster_view(monster, content))
        points.award(session, user, "summon", now=now)
        if progress is not None:
            progress(len(monsters))
        session.commit()
    by_stars: dict[str, int] = {}
    for m in monsters:
        by_stars[str(m["natural_stars"])] = by_stars.get(str(m["natural_stars"]), 0) + 1
    summary = {
        "count": count,
        "by_stars": dict(sorted(by_stars.items())),
        "nft": sum(1 for m in monsters if m["nft"]),
    }
    if count > SCROLL_DETAIL:  # x100 / x1000 (V): a summary and the best monsters only
        monsters = sorted(monsters, key=lambda m: -int(m["natural_stars"]))[:SCROLL_DETAIL]
    return {"monsters": monsters, "summary": summary}


# ------------------------------------------------------------------ starter pack


def claim_starter(
    session: Session,
    user: User,
    operator: GameOperator,
    content: Content,
    chain_id: int,
    now: datetime,
) -> dict[str, Any]:
    """Give a new player their first monsters and some MANA, once."""
    player = get_player(session, user, content, now)
    if player.starter_claimed_at is not None:
        raise GameError("starter_already_claimed")
    player.starter_claimed_at = now
    session.flush()  # the locked row + flag make a concurrent second claim fail
    monsters = []
    for species_id in content.starter_species:
        monster, _ = give_monster(
            session, user, operator, content, content.species[species_id], chain_id, "starter", now
        )
        monsters.append(monster)
    for item_id, quantity in content.starter_items.items():
        add_items(session, user, item_id, quantity)
    mana_wei = content.starter_mana * TOKEN_UNIT
    mana_tx, _ = pay_mana(session, user, operator, mana_wei, f"starter-mana:{user.id}", now)
    if content.starter_pot:
        from app.game.mail import send  # mail builds on this module

        # POT to try the marketplace (V): through the reward box, minted when claimed.
        send(
            session,
            user,
            Gift(
                sender="SYSTEM",
                title="Tes premiers POT",
                body="Quelques POT pour essayer le marchÃ© : acheter, enchÃ©rir, faire une offre.",
                rewards={"pot": content.starter_pot},
            ),
            now,
            key="starter-pot",
            days=None,
        )
    session.flush()
    return {
        "monsters": [monster_view(m, content) for m in monsters],
        "mana_wei": str(mana_wei),
        "mana_tx": mana_tx,
    }


# ------------------------------------------------------------------ battle


def load_team(
    session: Session,
    user: User,
    operator: GameOperator,
    team_ids: list[int],
    size: int = TEAM_MAX,
) -> tuple[dict[int, GameMonster], list[TeamMember]]:
    """The player's monsters for a fight (owned, not in storage, no duplicates), with runes."""
    if not TEAM_MIN <= len(team_ids) <= size or len(set(team_ids)) != len(team_ids):
        raise GameError("invalid_team", 400)
    monsters = get_owned_many(session, user, operator, team_ids)
    if any(m.stored for m in monsters.values()):
        raise GameError("monster_in_storage")
    from app.game.rune_service import equipped_runes  # builds on this module

    runes = equipped_runes(session, team_ids)
    team = [
        TeamMember(
            token_id=monsters[t].token_id,
            monster_id=t,
            species_id=monsters[t].species_id,
            level=monsters[t].level,
            stars=monsters[t].stars,
            awakened=monsters[t].awakened,
            runes=tuple(runes[t]),
        )
        for t in team_ids
    ]
    return monsters, team


def _grant_team_xp(monsters: dict[int, Any], team_ids: list[int], xp: int) -> list[dict[str, Any]]:
    """Add `xp` to each monster of the winning team; the progression the client shows."""
    progression = []
    for monster_id in team_ids:
        monster = monsters[monster_id]
        before = monster.level
        monster.level, monster.xp, gained = add_xp(
            monster.level, monster.xp, xp, monster.stars, monster.awakened
        )
        progression.append(
            {
                "monster_id": str(monster_id),
                "level_before": before,
                "level": monster.level,
                "xp": monster.xp,
                "xp_to_next": xp_to_next(monster.level),
                "leveled_up": gained > 0,
            }
        )
    return progression


def _record_clear(
    session: Session,
    user: User,
    operator: 
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  ¦ŠŒÈÏoµÖø ¸(JûsŽ.½;{*ÛïL‰ëE' 