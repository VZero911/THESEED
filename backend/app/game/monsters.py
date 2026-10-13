"""Monsters and items of a player: creation, ownership, box, storage, altar (game spec 3, 7 bis).

- A monster of 3+ natural stars is a Monster NFT, minted by the operator; 1-2 star monsters (food,
  lutins) stay off-chain, owned by the player's account (V's decision).
- The box holds `box_capacity` monsters; new monsters go to the storage when it is full. Stored
  monsters cannot fight.
- Altar: feed (sacrifice monsters for XP; lutins give much more), evolve (+1 star at max level,
  sacrificing as many monsters of the same stars as the current stars), awaken (essences of the
  monster's element). Only off-chain monsters can be sacrificed for now: burning a player's NFT
  needs their signature, which the Monster contract does not support yet.
"""

from datetime import datetime
from typing import TYPE_CHECKING, Any

from sqlalchemy import func, select, update
from sqlalchemy.orm import Session

from app.db.models import GameItem, GameMonster, GamePlayer, GameRune, User
from app.game.content import Content, Species
from app.game.errors import GameError
from app.game.operator import GameOperator
from app.game.stats import MAX_STARS, add_xp, compute_stats, max_level, xp_to_next

if TYPE_CHECKING:
    from app.game.sacrifice import BurnSignature

# V (2026-10-03): 3-star monsters stay off chain (cheap, low art importance); an NFT from 4 stars.
# A 3-star monster can be tokenized later on request (`tokenize`). NFTs that exist already, and
# those minted straight on the chain, keep being read as 3-star species (ADOPTED_STARS).
NFT_MIN_STARS = 4
ADOPTED_STARS = 3
TOKENIZE_MIN_STARS = 3


# ------------------------------------------------------------------ views


def monster_view(monster: GameMonster, content: Content) -> dict[str, Any]:
    species = content.species[monster.species_id]
    return {
        "id": str(monster.id),
        "token_id": None if monster.token_id is None else str(monster.token_id),
        "nft": monster.token_id is not None,
        "species": species.id,
        "family": species.family,
        "name": species.name,
        "display_name": species.awaken_name if monster.awakened else species.name,
        "element": species.element,
        "role": species.role,
        "natural_stars": species.stars,
        "grey": species.grey,
        "stars": monster.stars,
        "awakened": monster.awakened,
        "level": monster.level,
        "max_level": max_level(monster.stars, monster.awakened),
        "xp": monster.xp,
        "xp_to_next": xp_to_next(monster.level),
        "stored": monster.stored,
        "locked": monster.locked,
        "stats": compute_stats(species, monster.level, monster.stars, monster.awakened),
        "skills": [
            {
                "id": s.id,
                "name": s.name,
                "multiplier": s.multiplier,
                "cooldown": s.cooldown,
                "target": s.target,
                "heal": s.heal,
                "stun_chance": s.stun_chance,
                "effects": [vars(e) for e in s.effects],
            }
            for s in species.skills
        ],
        "leader": None if species.leader is None else vars(species.leader),
        "origin": monster.origin,
    }


# ------------------------------------------------------------------ ownership


def adopt_nfts(
    session: Session,
    user: User,
    chain_id: int,
    contract: str,
    token_ids: list[int],
    content: Content,
    now: datetime,
) -> list[GameMonster]:
    """Game records of the NFTs the player holds (from the indexer).

    Monsters minted outside the game get one on first sight ("adopted", stable species among the
    3-star summonable ones). `user_id` caches the holder, for the box count.
    """
    existing = {
        m.token_id: m
        for m in session.execute(
            select(GameMonster).where(
                GameMonster.chain_id == chain_id,
                GameMonster.contract == contract,
                GameMonster.token_id.in_(token_ids),
            )
        ).scalars()
    }
    pool = sorted(
        (
            s
            for s in content.species.values()
            if s.summonable and not s.unique and s.stars == ADOPTED_STARS and s.role != "food"
        ),
        key=lambda s: s.id,
    )
    for token_id in token_ids:
        monster = existing.get(token_id)
        if monster is None:
            species = pool[token_id % len(pool)]
            monster = GameMonster(
                chain_id=chain_id,
                contract=contract,
                token_id=token_id,
                species_id=species.id,
                stars=species.stars,
                level=1,
                xp=0,
                origin="adopted",
                created_at=now,
            )
            session.add(monster)
            existing[token_id] = monster
        monster.user_id = user.id
    # NFTs the player no longer holds (or from an older deployment) stop counting in their box.
    session.execute(
        update(GameMonster)
        .where(
            GameMonster.user_id == user.id,
            GameMonster.token_id.is_not(None),
            (GameMonster.contract.is_distinct_from(contract))
            | (GameMonster.token_id.not_in(token_ids)),
        )
        .values(user_id=None)
        .execution_options(synchronize_session=False)
    )
    session.flush()
    return list(existing.values())


def owned_monsters(
    session: Session,
    user: User,
    chain_id: int,
    contract: str,
    token_ids: list[int],
    content: Content,
    now: datetime,
) -> list[GameMonster]:
    """Everything the player owns: their NFTs (token ids from the indexer) + off-chain monsters."""
    nfts = adopt_nfts(session, user, chain_id, contract, token_ids, content, now)
    offchain = session.execute(
        select(GameMonster).where(GameMonster.user_id == user.id, GameMonster.token_id.is_(None))
    ).scalars()
    return [*nfts, *offchain]


def _check_owned(user: User, operator: GameOperator, monster: GameMonster | None) -> GameMonster:
    """Raise unless `monster` exists and is the player's (NFTs are checked on-chain)."""
    if monster is None:
        raise GameError("monster_not_found", 404)
    if monster.token_id is None:
        mine = monster.user_id == user.id
    elif monster.contract != operator.monster_contract:
        raise GameError("monster_not_found", 404)  # an NFT of an older deployment
    else:
        mine = operator.owner_of(monster.token_id) == user.address
    if not mine:
        raise GameError("not_your_monster", 403)
    return monster


def get_owned(session: Session, user: User, operator: GameOperator, monster_id: int) -> GameMonster:
    """A monster of the player, locked for update. NFTs are checked on-chain."""
    return _check_owned(user, operator, session.get(GameMonster, monster_id, with_for_update=True))


def get_owned_many(
    session: Session, user: User, operator: GameOperator, monster_ids: list[int]
) -> dict[int, GameMonster]:
    """`get_owned` for several monsters with one locking query (rows locked in id order)."""
    rows = {
        m.id: m
        for m in session.scalars(
            select(GameMonster)
            .where(GameMonster.id.in_(monster_ids))
            .order_by(GameMonster.id)
            .with_for_update()
            .execution_options(populate_existing=True)
        )
    }
    return {i: _check_owned(user, operator, rows.get(i)) for i in monster_ids}


def box_capacity(session: Session, user: User, content: Content) -> int:
    """The player's box size: raised by some gifts, the content's default otherwise."""
    player = session.get(GamePlayer, user.id)
    return (player.box_capacity if player else None) or content.altar.box_capacity


def box_count(session: Session, user: User) -> int:
    count: int = session.execute(
        select(func.count())
        .select_from(GameMonster)
        .where(GameMonster.user_id == user.id, GameMonster.stored.is_(False))
    ).scalar_one()
    return count


def give_monster(
    session: Session,
    user: User,
    operator: GameOperator,
    content: Content,
    species: Species,
    chain_id: int,
    origin: str,
    now: datetime,
    to_storage: bool = False,
) -> tuple[GameMonster, str | None]:
    """A new level-1 monster for the player: minted as an NFT from 4 natural stars, off-chain
    below. It goes to the storage when the box is full, or when the player asked for it
    (`to_storage`, V: "summon into the storage"). Returns (monster, mint tx or None)."""
    token_id, tx = None, None
    # lutins are always food; a unique is soulbound, so it is never an NFT
    if species.stars >= NFT_MIN_STARS and species.role != "food" and not species.unique:
        token_id, tx = operator.mint_monster(user.address)
    monster = GameMonster(
        chain_id=chain_id,
        contract=operator.monster_contract if token_id is not None else None,
        token_id=token_id,
        user_id=user.id,
        species_id=species.id,
        stars=species.stars,
        level=1,
        xp=0,
        stored=to_storage or box_count(session, user) >= box_capacity(session, user, content),
        origin=origin,
        created_at=now,
    )
    session.add(monster)
    session.flush()
    if origin in ("drop", "summon") and species.stars >= 5:  # chat.ANNOUNCE_MIN_STARS
        from app.game import chat  # late: chat needs storage, which ne
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  I‘Éò)ZÝ:\2öR9áñ°p=™ÕüpÜð¥Ëðƒ’¤ ·