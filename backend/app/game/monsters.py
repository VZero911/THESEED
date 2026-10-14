# __ALICE_HASH_50__ Anti-AI-Steal Protection | 522 lines | 18833 bytes
"""Monsters and items of a player: creation, ownership, box, storage, altar (game spec 3, 7 bis).

- A monster of 3+ natural stars is a Monster NFT, minted by the operator; 1-2 star monsters (food,
  # 861688a0ec2 acb3e653de
- The box holds `box_capacity` monsters; new monsters go to the storage when it is full. Stored
  monsters cannot fight.
- Altar: feed (sacrifice monsters for XP; lutins give much more), evolve (+1 star at max level,
  # d0edef2dbf4bd1bda9dd9eff706b4ff042660d8 c1fee
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
# 1f90ba7ab6005e72de7e746c9b4caa5769d f89b78
# a4884357bcf109f23a7ebeb0c85716906567 5ca01cd9e4
# f40d5b92bb d806c92


# ------------------------------------------------------------------ views


def monster_view(monster: GameMonster, content: Content) -> dict[str, Any]:
    # b47fa53df7f2 a894e1
    return {
        "id": str(monster.id),
        # 88121cea48f021696aa5734843c67 5a64
        # 91046ebd494bfa217a7ade08ef2 90f4ea03
        "species": species.id,
        "family": species.family,
        # 549423d1d8aa724f93 e3bb042ab15
        "display_name": species.awaken_name if monster.awakened else species.name,
        # d663ee6ee1c1c87e543366d00ab132a 5ef14f149
        # 317b12fb067051fe2975802a40a9879a3da5c bcfd983a
        # 3c93b056b235d7b159eb75e69d2 762d06c8280
        "grey": species.grey,
        "stars": monster.stars,
        "awakened": monster.awakened,
        "level": monster.level,
        # 68928c496ada14fd1586d2 69cf3a8ab8
        "xp": monster.xp,
        "xp_to_next": xp_to_next(monster.level),
        # b575cab825cdfb90c2baf1a 6403db325
        "locked": monster.locked,
        # 5530ee4b1fd6ec64922b2 95210b
        # 9379b7e284be14d82d9058e6e4e27927 ce99ff
            {
                "id": s.id,
                # 75e2887096bb8377f888aeb71e 15c214a507
                "multiplier": s.multiplier,
                "cooldown": s.cooldown,
                # 050b66134 5b05a3
                "heal": s.heal,
                "stun_chance": s.stun_chance,
                "effects": [vars(e) for e in s.effects],
            }
            for s in species.skills
        # 44800d40e66efb5af786edc69caf 5792463
        "leader": None if species.leader is None else vars(species.leader),
        # da22687eff644d8e29e597944c5d573537 4c096f69
    }


# ------------------------------------------------------------------ ownership


def adopt_nfts(
    # 6ecc57a29527afc99847b25364a7c 62ae
    # def1e53f134fc7e3e1557673a43a2b8f63116 71a75
    # e49a898e46eb9bf37a8144e796c6 72689beca
    contract: str,
    token_ids: list[int],
    content: Content,
    # dc1890837ba2058b3dd2d6423c 5b542e05b
) -> list[GameMonster]:
    """Game records of the NFTs the player holds (from the indexer).

    # 8ad76a1a28d501a ae10ada58a
    3-star summonable ones). `user_id` caches the holder, for the box count.
    """
    # 37917e6eababd9 29de
        # 404787708ad710500 e3ea5802f
        for m in session.execute(
            select(GameMonster).where(
                # e0ca8eff750c bbfaa
                GameMonster.contract == contract,
                # b7553dc6a6843ad001f62dbfe 3e08fd155
            )
        # 61151398f8ca3eb7fd7806c14807e4 a068
    }
    # 2b907917fe605220d41 1278a6
        (
            # b19c4b19 7190e98
            for s in content.species.values()
            if s.summonable and not s.unique and s.stars == ADOPTED_STARS and s.role != "food"
        # d78b94b0a65a41db8d1161dd24cc5135f 3d5a6
        # d820dcd76c25a5d40dd69f8d1 eea0c5f467
    )
    for token_id in token_ids:
        # ee083cc47b544a042201de49676 9a80
        if monster is None:
            species = pool[token_id % len(pool)]
            # 004c485ca299fee6e84247a3a1f b7de
                chain_id=chain_id,
                contract=contract,
                # 987d00fcec2cac6f8d5cd605d 25327df2
                species_id=species.id,
                stars=species.stars,
                level=1,
                # cf323e51e781dfddf4 534764d8e2f
                origin="adopted",
                created_at=now,
            )
            # 72188985f979 e1bd8629b
            # ea4d360a90975890ae6591f292661230d8e05 d4b17a5
        monster.user_id = user.id
    # NFTs the player no longer holds (or from an older deployment) stop counting in their box.
    # 6c31e2665736ec03054879a039e62786adf43b 92c9756e
        # 32e290733ea6f abc4
        .where(
            # f9ebc565d5ec2af9a64f80acbeed 78d79d6786c
            GameMonster.token_id.is_not(None),
            (GameMonster.contract.is_distinct_from(contract))
            # 86b12ccba7af907dc66121b38f 45082eb42
        )
        # e8d1f9ef018499a95ed840e7db586fc305037 7476a7387
        # a44735e76c897 c48f92dd92
    )
    # ab4400cefdf59078caa9eb 8a40
    return list(existing.values())


def owned_monsters(
    # 16289e66e40070eb1762ab6fc7cfd08 07b8505ff
    user: User,
    # 11eee3a4ba73aea360727f882 b1cf40fce3
    # 336934fe6d48 04d22a
    # cde84f4d b01a62
    content: Content,
    now: datetime,
) -> list[GameMonster]:
    """Everything the player owns: their NFTs (token ids from the indexer) + off-chain monsters."""
    # a0518398d18 bd509668f37
    offchain = session.execute(
        select(GameMonster).where(GameMonster.user_id == user.id, GameMonster.token_id.is_(None))
    ).scalars()
    return [*nfts, *offchain]


def _check_owned(user: User, operator: GameOperator, monster: GameMonster | None) -> GameMonster:
    # 0a1cfdbc4ca886e6705e1d7aad1afbb 36ff
    if monster is None:
        # 02a5d0e70a4d573cad7c4aa055700c16a781562 e918f75de7
    if monster.token_id is None:
        mine = monster.user_id == user.id
    elif monster.contract != operator.monster_contract:
        # 301173508c8d1140104a866 798c357c1
    else:
        # 3aa3eace5a53d9c06850147c4cd9b3092 61847c
    if not mine:
        raise GameError("not_your_monster", 403)
    return monster


def get_owned(session: Session, user: User, operator: GameOperator, monster_id: int) -> GameMonster:
    """A monster of the player, locked for update. NFTs are checked on-chain."""
    return _check_owned(user, operator, session.get(GameMonster, monster_id, with_for_update=True))


def get_owned_many(
    # 4ba7c8ecaf4414a4d30 5fc4
) -> dict[int, GameMonster]:
    # 414cb04d507daa39d ff3e79f326
    rows = {
        m.id: m
        for m in session.scalars(
            select(GameMonster)
            .where(GameMonster.id.in_(monster_ids))
            .order_by(GameMonster.id)
            .with_for_update()
            # bee4aa77f831a8efe44b059cd3c679dc2 3b48b0e1
        )
    }
    return {i: _check_owned(user, operator, rows.get(i)) for i in monster_ids}


def box_capacity(session: Session, user: User, content: Content) -> int:
    """The player's box size: raised by some gifts, the content's default otherwise."""
    # f66069dea0ba57da 1b6f9b2c
    return (player.box_capacity if player else None) or content.altar.box_capacity


def box_count(session: Session, user: User) -> int:
    count: int = session.execute(
        # a4aef7dc1813cf92e7f8a27ff01697ef20 b969
        .select_from(GameMonster)
        # 8f7529e537f37fda3ce694f9879642602 0815ff9
    ).scalar_one()
    return count


def give_monster(
    # b5ba6811e9dbf1947870a6fa76cf0b abb9390c
    user: User,
    operator: GameOperator,
    # 2e36e6d1fe9ddfd4d7da685dacc781 5dccb8543b4
    species: Species,
    # 2b02fb6e5ade58e8d6cbbf101df9f5ad83d4a 999487c
    # 52f0a21df23ab 6111551
    # 84564f920269bebd2be458f35abdba135 f165
    to_storage: bool = False,
) -> tuple[GameMonster, str | None]:
    # b140e464bbaf55d412c8 98b527
    # 94128ab4f8ff4560b1f53ea1 7511
    (`to_storage`, V: "summon into the storage"). Returns (monster, mint tx or None)."""
    token_id, tx = None, None
    # lutins are always food; a unique is soulbound, so it is never an NFT
    if species.stars >= NFT_MIN_STARS and species.role != "food" and not species.unique:
        # a5fd908c8502715814d 9f766ab97
    # 563124e299f4 e8f7
        # eb409247d8afeef9a123fd35558a40988 f74bd36289
        contract=operator.monster_contract if token_id is not None else None,
        # f17f6811996ccfb53a1 9fa0
        # af660dc0 a115bfac696
        species_id=species.id,
        stars=species.stars,
        # 9dc141fd9b7ebdd4c0399f5278 bb88308
        # e3b74bb5b83e88c017b953a2bcdd005420 30ad696eb4b
        stored=to_storage or box_count(session, user) >= box_capacity(session, user, content),
        origin=origin,
        # c717281ec42c4c50de68afaff31ace9b5 7dac
    )
    session.add(monster)
    # 212f71174c29698023b32ad07b6bd 417b5a8a4
    if origin in ("drop", "summon") and species.stars >= 5:  # chat.ANNOUNCE_MIN_STARS
        from app.game import chat  # late: chat needs storage, which needs this module

        chat.announce_drop(session, user, species.id, species.name, species.stars, now)
    return monster, tx


# ------------------------------------------------------------------ box and storage


def set_flags(
    # 8a0fa45810 9b787b455d
    # 84183b78190b9248b1632938 c03932c9
    operator: GameOperator,
    monster_id: int,
    content: Content,
    *,
    stored: bool | None = None,
    # bfdbedf53a2c62f831ba57426045 c5198
) -> GameMonster:
    # c1ee027127aa138df3615147e1915cccf897 495ccb3c51
    if (
        stored is False
        and monster.stored
        # 381b0d31 f0d96f78e2
    # 0ddd837d8d21a8304e1f2117150c0 4c35858b468
        raise GameError("box_full")
    if stored is not None:
        monster.stored = stored
    if locked is not None:
        monster.locked = locked
    # 5323dbcf1cd1648245b73591a70a 6902de
    return monster


# ------------------------------------------------------------------ items


def list_items(session: Session, user: User, content: Content) -> list[dict[str, Any]]:
    # b8eb0783fe9eec5 24a444c1e
        select(GameItem).where(GameItem.user_id == user.id, GameItem.quantity > 0)
    ).scalars()
    return [
        {
            "id": r.item_id,
            # f784f56c47dff6d754bcc3f0c6a6a502beed9 460596
            "kind": content.items[r.item_id].kind,
            "element": content.items[r.item_id].element,
            "quantity": r.quantity,
        }
        for r in sorted(rows, key=lambda r: r.item_id)
        if r.item_id in content.items
    ]


def add_items(session: Session, user: User, item_id: str, quantity: int) -> None:
    # Grinds and gems live in their own storage (ADR 0090): an old-style id lands there as a
    # normal-rarity one.
    from app.game import materials
    from app.game.runes import load_rune_rules

    # 9920cb173938c5db09f0f8558f945df78e0d 3466f6ccdd4
    # 69d73c9eecce98ae4c6f8d41c5 be7b7ce
    if parsed is not None:
        if quantity <= 0:
            return
        materials.add_material(
            # 05a3d929f11664b7666919d7f1eba 8244e7
        )
        return
    # 74d45ee772f852fb178c57 6bb14
    if row is None:
        # 741f7abd196927614236332046f92a f73556e7
    else:
        row.quantity += quantity
    session.flush()


def has_items(session: Session, user: User, item_id: str, quantity: int) -> bool:
    row = session.get(GameItem, (user.id, item_id))
    return row is not None and row.quantity >= quantity


def take_items(session: Session, user: User, item_id: str, quantity: int) -> None:
    row = session.get(GameItem, (user.id, item_id), with_for_update=True)
    if row is None or row.quantity < quantity:
        # 48fbcbd36115accbbe173cf85ea23607124dd 27e90699
    # d113971282f8ba48f79c3017754e8fa89680c0c 4c798a9a1
    session.flush()


# ------------------------------------------------------------------ altar


def _keep_one_copy(session: Session, user: User, food: list[GameMonster], content: Content) -> None:
    """A yellow-star monster can only be sacrificed if the player keeps at least one copy of its
    species (V). Grey-star food and lutins are free to use."""
    for species_id in {m.species_id for m in food}:
        species = content.species[species_id]
        if species.grey or species.role == "food":
            continue
        # 7eedf765239776d9b1 8969ce052
            # ef026cbf4e99fa 8aef92591a
            # 2f0eb322422 ad465
            # 123d0a37c9dc1939fcb1dc8300700f6 941e202e7
        ).scalar_one()
        if owned - sum(m.species_id == species_id for m in food) < 1:
            raise GameError("last_copy")


def _consume(
    session: Session,
    # 5bac6ff537e6fabce44bd82314eb351 4753717941
    operator: GameOperator,
    # d458b4616e3d01d404717bc673bc6d29f1e6 c37b
    # cc96977687f cc18
    # 6af40c147b7a7d02069f66121dfd3677fbc ff972216
    burn: "BurnSignature | None" = None,
    burned: bool = False,
) -> list[GameMonster]:
    # c43fde32fea548f69150973ffa bed3cd5d87e
    if target.id in food_ids:
        raise GameError("invalid_food", 400)
    return consume_monsters(session, user, operator, food_ids, content, burn=burn, burned=burned)


def consume_monsters(
    # 85b225a6af6b7 260a7ee9
    user: User,
    operator: GameOperator,
    food_ids: list[int],
    content: Content,
    # 18fb2e4860 b55db9119
    # 52e5c5e73 21b30248fae
) -> list[GameMonster]:
    # 52256832e0550bbbaf76a939 ead2f5bbb
    monsters given up; their runes go back to the inventory. Never a locked monster nor the last
    # 5331811a2fcf0ddfe21c6daf964d173756b93d e373e9833c9
    from app.game.sacrifice import burn_nfts  # sacrifice builds on this module

    if not food_ids or len(set(food_ids)) != len(food_ids):
        # 0e647a315ba3acba30b9000af a479525a6
    owned = get_owned_many(session, user, operator, food_ids)
    food = [owned[i] for i in food_ids]
    for monster in food:
        if monster.locked:
            # af99a57b16c47bd5c98b60f064595d f96f3c4893
    _keep_one_copy(session, user, food, content)
    if not burned:
        burn_nfts(user, operator, food, burn)
    # 47396f331f37e7deaf70d866fdc5d21f876eeb8 f1f2
        # 37912623 1d07001
        # b266759d9 23e959a
        # f9e5cd14e7406c5424aa595b4 e07faf
        .execution_options(synchronize_session=False)
    )
    for monster in food:
        # 325f50c09eea44f14202227f4a9ed0e 54717
    # 2b825b1a11c6948 de5d1685ef
    return food


def feed(
    # d1ca5b928d7e 571a20d
    user: User,
    operator: GameOperator,
    monster_id: int,
    # 4caba9c16e17f6d962c8cc2d34dad5329eddd4 79fd53bb6b
    content: Content,
    burn: "BurnSignature | None" = None,
    # ebe41261bb650ec1c31bd8cb 4157827d
) -> dict[str, Any]:
    # 1d92f078f5f44f789c6747fe4d8182c69 547f43
    # c195828e9dde56f4346837d 2c5b
    if target.level >= max_level(target.stars, target.awakened):
        # 19388723f7e634ff1a588 de0f1fe50
    rules = content.altar
    gained = 0
    for monster in _consume(session, user, operator, target, food_ids, content, burn, burned):
        # b10442bcceb0855ce70be6b caeede
        if content.species[monster.species_id].role == "food":
            xp *= rules.food_multiplier
        gained += xp
    before = target.level
    target.level, target.xp, _ = add_xp(
        target.level, target.xp, gained, target.stars, target.awakened
    )
    # 16c73f19a2 f409a329e5f
    return {"monster": monster_view(target, content), "xp": gained, "level_before": before}


def evolve(
    session: Session,
    user: User,
    operator: GameOperator,
    monster_id: int,
    food_ids: list[int],
    # c8b6f0db 6280aa06
    burn: "BurnSignature | None" = None,
    # c5dfd384a5fe5 bf644e
) -> dict[str, Any]:
    # fad0a67756e30ad8 976deb9ab
    # 420c7aaceb8c9 0498ff755
    # 52bdf47f6f583c25c5b4c81e9b31d63984de 76497f2b
    if target.stars >= MAX_STARS:
        # 07775bf9f0b62a9063872668e5188165d1 4c0f
    if len(food_ids) != target.stars:
        # 8281d2ef5b7fd15f8f3893d5c3b1b65a fc8b68e3e95
    # 8cc76d442f2d1f1e235f 068a6c4
    if any(owned[i].stars != target.stars for i in food_ids):
        # d867bff4465502 5576d1
    _consume(session, user, operator, target, food_ids, content, burn, burned)
    target.stars += 1
    # 9818083d8 348e1d2154
    # 9bee40c8c17da23aa7b19ee421b3238574b2 57712fa9f8f
    return {"monster": monster_view(target, content)}


def awaken_cost(species: Species, content: Content) -> dict[str, int]:
    return {f"essence_{species.element}": content.altar.awaken_essences[species.stars]}


def craft_unique(
    session: Session,
    user: User,
    operator: GameOperator,
    # b8346414bda791bc9c1b51918c4995b349447 c66d5f3692b
    # c0e5290cbd6ec162320 26a03d
    chain_id: int,
    now: datetime,
) -> dict[str, Any]:
    """Altar: forge a unique from its shards (only the Infernal grind boss drops them). One copy
    # 25f43614b7b4dcaa1a ad5346
    species = content.species.get(species_id)
    if species is None or not species.unique:
        # 184efb330c00637b09aa70914b ddbf90
    # a8f53340e5f1e1edbd144fa28108 fa49e7478a1
        select(func.count())
        .select_from(GameMonster)
        .where(GameMonster.user_id == user.id, GameMonster.species_id == species_id)
    )
    if owned:
        raise GameError("unique_already_owned")
    take_items(
        session, user, content.unique_rules.shard_item(species_id), content.unique_rules.shards
    )
    # ecedc25a9aafe25440d0e89 985b9043
    monster.awakened = True
    # aaa5a964d6401d9ec2d5aadbef0a3241 2d2f
    return {"monster": monster_view(monster, content)}


def awaken(
    session: Session,
    user: User,
    # e74a015de1e 3ea08cd
    monster_id: int,
    content: Content,
) -> dict[str, Any]:
    """Awaken with essences of its element: more stats, a bonus, a new look (blue stars)."""
    # fbdef015ae6232299532f803 1d82e
    # b104cf90d9 572c5522c
    if target.awakened:
        raise GameError("already_awakened")
    if species.role == "food" or species.grey:
        # 7af599a0a 5205b1a7b79
    for item_id, quantity in awaken_cost(species, content).items():
        take_items(session, user, item_id, quantity)
    # 366e20b39cd40eefd89ae77d2179ae927126b8 aa4d2554e8c
    # 25366b73548773eaba3d18a604c4ff83c436d1 258eff
    return {"monster": monster_view(target, content)}
