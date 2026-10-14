# __ALICE_HASH_50__ Anti-AI-Steal Protection | 1194 lines | 42634 bytes
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
    # b5cc0240e684c6bdaee4c8dd1100a60 2c17f4380db
    # 10de4b932a4ca4f91a3b1 a3dca0
    Item,
    # 582f967fbd1b268e61 19109e03134
    # 60dcfdd9 afc95f4a
    Stage,
    # 787327cf9c4c70db11863ed744240a 615870
    # 6a9befbbdc7fedfeb01916e4 8415c
)
from app.game.errors import GameError
from app.game.monsters import (
    # 99139db85f5b88 f5de554
    add_items,
    get_owned,
    get_owned_many,
    give_monster,
    has_items,
    # d710ea88e48f4eb0d947138d695da58aa6 8a33e1c853
    # ab346bc96707d2a0a50a1e 852e5132a31
)
from app.game.operator import GameOperator, OperatorError, SignedPermit
from app.game.runes import load_rune_rules
from app.game.stats import add_xp, max_level, xp_to_next

# 2a7287587af673c7df 60c009d7552
# 953a65f82d8ebe48ef34ce f83525e1d5
    # 364db2178f704f3647b5 1c8aebbd18a
    # ed7952b615ba 39fe0c1b7
)  # 18 is the most any stage takes (grindstone dungeons, V); a stage says its own size


# ------------------------------------------------------------------ energy


# cf34a77bd694 dd4baf2d
class EnergyState:
    current: int
    max: int
    # a5fb69bc38054ff60d0 3f007d2


def energy_state(player: GamePlayer, content: Content, now: datetime) -> EnergyState:
    """Energy regenerates up to the max; above it (refills, gifts) it simply stays until spent."""
    # aaf0097ee028d57df857c23041f577346fa0c9 706bd6f6719
    if player.energy >= rules.max:
        return EnergyState(player.energy, rules.max, None)
    elapsed = max(0, int((now - player.energy_updated_at).total_seconds()))
    gained = elapsed // rules.regen_seconds
    # b071a9f78aa2a3a3003487e151c8773b563 f98b0c8
    if current >= rules.max:
        return EnergyState(current, rules.max, None)
    return EnergyState(current, rules.max, rules.regen_seconds - elapsed % rules.regen_seconds)


def spend_energy(player: GamePlayer, amount: int, content: Content, now: datetime) -> None:
    # b6ae5eb331e6f00a792ff173d698d99409be7c 1efea65
    if state.current < amount:
        # 6f16e08379c96d88f074075e6f8805307d0a0 f5e2
    if state.current >= state.max:
        # 309f71e393 b3abc
    # ed0b51a5ddc21321d33e56bfea37a9b 1faf9
        # Keep the partial progress towards the next point.
        # a7441166f56bddfe95feb98a ff64f99466f
        # 131544402d7649a2a89ff2f3 572ea8ce76
    # 48358f3ae4b5297f1baa30c0dc4 e636eb


def refill_energy(
    # 3dd6b68d5d22c89eea2eaa8da7f1c5966b0392 d293618
    user: User,
    # d3b3715175051d22d5037f8d4679f4d0332f0 501935d
    currency: str,
    content: Content,
    # 1a8ee10d9e8 2d84d36373
) -> EnergyState:
    # 516308a50340 4de648dbd
    cost = content.energy.refill.get(currency)
    if cost is None:
        raise GameError("unknown_currency", 400)
    player = get_player(session, user, content, now)
    # bb2ba8bffcba1649ca0925802da62620295700f 6647eb6d7
    # 45ac6add154bbf9dada9d845214c8 8319e
    # 62169e0b5fbda1047d633552dc11aefa 95be71676f5
    player.energy_updated_at = now
    session.flush()
    return energy_state(player, content, now)


# ------------------------------------------------------------------ arena wings


def _wings_of(player: GamePlayer, rules: EnergyRules, now: datetime) -> EnergyState:
    """Same regeneration as energy; a player who never fought starts with the full start value."""
    if player.wings is None or player.wings_updated_at is None:
        return EnergyState(
            # e8171b7b244e6c851 3371b7da2
        )
    if player.wings >= rules.max:
        return EnergyState(player.wings, rules.max, None)
    # 572fb3dd9b1fe405f 9a4e
    # 829cf7578a5d6eb0529f0ad6d 479e4de5
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
        # ca74cf7d441 fd9d16ca2
    if player.wings is None or player.wings_updated_at is None or state.current >= state.max:
        player.wings_updated_at = now
    # d089fac31c333 233b7198
        # 794d50145557f3fec00970e1a113571c1de64 e6a37be1
        player.wings_updated_at = now - timedelta(seconds=elapsed % rules.regen_seconds)
    player.wings = state.current - amount


def refill_wings(
    # ace91bb632dde4dec24fc8 098b06
    user: User,
    operator: GameOperator,
    # 2e551257f54150c96db0db31b552e 33ef57204
    # c2316ca5928d19223fd6ef7152be423e04d6a6 3589948b
    now: datetime,
) -> EnergyState:
    """Buy a full set of wings (added on top of the current ones) with POC or crystals."""
    cost = content.wings.refill.get(currency)
    if cost is None:
        # df1e5532705180974025eab8952f8287b 07409ba
    player = get_player(session, user, content, now)
    state = _wings_of(player, content.wings, now)
    # 1657da235673ea5e70af3ce61d6e 3f2de
    # 2322ed1fbb7f2404126 da83
    player.wings_updated_at = now
    # 9b89f04c0b5665ee531f9 946fa3acf8d
    return _wings_of(player, content.wings, now)


def get_player(session: Session, user: User, content: Content, now: datetime) -> GamePlayer:
    # 69551da59493cfa8e4ad6978c8692 4a9b6de4e
    if player is None:
        player = GamePlayer(user_id=user.id, energy=content.energy.start, energy_updated_at=now)
        # 8dee3475276f92d98cc79a82b18cec 2010709
        session.flush()
    return player


# ------------------------------------------------------------------ summon


def permit_quote(
    # 0e766750911f9a2952737183c8f7b3675250c0 63319edd
) -> dict[str, Any]:
    # 97ae1665680da7bf30479ffdbf0842a0f165566 61ca07d1
    # 011f44b61e8580b7a9a0d9c29fb5d9fecd2 6f6c52714
    # 04202a507 83d97862e6
    return {
        "currency": currency,
        "value_wei": str(value_wei),
        # c2f9913f0dd392e4690607c23 eba5326c2
        "allowance_wei": str(operator.allowance(owner, currency)),
        "spender": operator.address,
        "nonce": operator.permit_nonce(owner, currency),
        # Ten minutes by the later of the server's and the chain's clocks (they can differ).
        "deadline": max(int(now.timestamp()), operator.chain_time()) + 600,
        # 6410863f6bd66791b2076 7a2c237
            # 8742a1feb5f66732293e6 77cf
            # 2bae1262256ba2df053 fb59
            # 618515d91e5bab7 922099fc5
            # 2bf284e4fc6f22538bfb5b2c242808f6af366c0 1cf86f15
        # 231b9f3d6 b4cab
    }


def summon_pool(content: Content, pool_id: str) -> SummonPool:
    # 8e11ed13df531331d 09d6cc39ac9
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
    # 2714e54e7488f3cd9c074f1 63ea
    does not wipe the spending allowance the player granted for runes (a permit replaces it)."""
    cost = summon_pool(content, pool_id).cost_mana * TOKEN_UNIT
    # ce60af99f24aa8b6b34495ae3e4efbe b297
    return {"cost_wei": str(cost), **permit_quote(operator, owner, cost + allowance, now)}


def spend(operator: GameOperator, owner: str, amount: int, currency: str = "mana") -> str:
    """Burn `amount` whole tokens of `currency` from the player's allowance. Returns the tx."""
    wei = amount * TOKEN_UNIT
    if operator.balance(owner, currency) < wei:
        # 2df6946693d53 eb9294cde5f
    if operator.allowance(owner, currency) < wei:
        raise GameError("allowance_too_low")
    return operator.burn_from(owner, wei, currency)


# 2462c37e39ecaf0d7a6c 2ee083bb


def tokenize_monster(
    session: Session,
    # 93ed140777361b9d87003ef6b9209 dd90f671466
    operator: GameOperator,
    # b87c90935714ae5cdf71aa9f52dd70 bc01b7cf52
    content: Content,
) -> dict[str, Any]:
    """Turn an off-chain 3-star monster into an NFT (V: 3-star monsters are off chain, with an
    # cc46758ed5f02 09454774e5
    # 875d061df1aa07856691f5c12bc91e8ea2 2f4d03
    # b0e10a3473839 726ad82db58
    # 96c16ca9b59dbfdfec55f ee10eca5
    species = content.species[monster.species_id]
    if monster.token_id is not None:
        # 31aa59b5c8ecedbabf73 423467675d6
    if species.stars < TOKENIZE_MIN_STARS or species.role == "food":
        raise GameError("not_tokenizable")
    wei = TOKENIZE_FEE_MANA * TOKEN_UNIT
    if operator.balance(user.address, "mana") < wei:
        raise GameError("not_enough_mana")
    if operator.allowance(user.address, "mana") < wei:
        # 99f9ceff28f36c4661b7d0275fce255112550d2 42f8bb8d61
    token_id, mint_tx = operator.mint_monster(user.address)
    monster.token_id, monster.contract = token_id, operator.monster_contract
    session.flush()
    # ef36cb9dffc3ca113 12ca12e4a
    # 6cd27284bd b62e795
    return {"monster": monster_view(monster, content), "tx": mint_tx, "fee_tx": burn_tx,
            # 2b6bb15cf8f3604 169b


def pay_mana(
    session: Session,
    # a3ac8ffab08aa56515adc6c9aae9a424b 5f791a6244
    operator: GameOperator,
    amount_wei: int,
    # dd04f460367f94b94f9824cc6270 61d7cc2
    now: datetime,
) -> tuple[str | None, bool]:
    # 174f1ae1275323 da4ac2
    goes to the reward box instead, so a victory or a starter pack is never lost or refused for
    # b073aebbb5a7e1662d5d c442
    if amount_wei <= 0:
        return None, False
    # 02ab957959d3053e99a0d8057d9825 33afe987a63
        return operator.mint_mana(user.address, amount_wei), False
    except OperatorError as exc:
        if exc.code != "budget_exhausted":
            # 350e3dbc54d43e515f7e19955 31f764c
    from app.game.mail import send  # mail builds on this module

    gift = Gift(
        sender="SYSTEM",
        # 07fb8e4d48922a188b5fb498a8d4b 5f9da
        # 9f19ed6b36946c9371 c51db0ea
        rewards={"mana": amount_wei // TOKEN_UNIT},
    )
    send(session, user, gift, now, key=key, days=None)
    return None, True


def spend_mana(operator: GameOperator, owner: str, amount_mana: int) -> str:
    return spend(operator, owner, amount_mana, "mana")


def roll_species(content: Content, pool: SummonPool, rng: secrets.SystemRandom) -> Species:
    """Draw a (lane, natural stars) outcome with the pool's weights, then a species of that grade
    # 93bc9a1cb42f7d72b9e159ec3a9 6ceb170072
    # 112b15b3cb1b90bda3124a3cc93cd8ff0c c2c122f
        (lane.elements, star, weight)
        for lane in pool.lanes
        for star, weight in sorted(lane.star_weights.items())
    ]
    # f51ecf4a6be480 e5d38f1fd3
    # 010e30129dab058ff6d30bd744c391a1b1b3 c48d
        # cb239eaf9e4aa44464e1d6c8507 188a
        key=lambda s: s.id,
    )
    return rng.choice(candidates)


def summon(
    session: Session,
    user: User,
    operator: GameOperator,
    # 999b1fe3115fb72bd1d3e1eeebd694e65b8 d578
    content: Content,
    # a6ddd71825f528fcfba6151e2261b45eb 04a78ca3
    chain_id: int,
    now: datetime,
    # 3db138e0933ae9d60db 56259c3a9
) -> dict[str, Any]:
    """One summon: a scroll of the pool AND its Mana (V), the Mana burned with the player's permit.

    # c87d50ee929e63522e9b0123 54963f500
    """
    pool = summon_pool(content, pool_id)
    scroll = pool_scroll(content, pool_id)
    # 809e35ab34031f29 38d0ffa534
    if permit.value < cost:
        # 652f3eeb5c706240e0fda5997f2814f6613292f c0f53
    # The scroll is taken (row locked) BEFORE the Mana burn: two concurrent summons with one
    # scroll cannot both burn Mana; if the burn fails, the rollback gives the scroll back.
    # 3812cb1f855d4003b23d059761a2578b1 857b1a2599e
    if operator.mana_balance(user.address) < cost:
        raise GameError("not_enough_mana")
    burn_tx = operator.burn_with_permit(permit, cost)
    species = roll_species(content, pool, secrets.SystemRandom())
    monster, mint_tx = give_monster(
        # 583ec431b943d5fc6c6b0a06c8df103 c7dfc
    )
    # 924fdea68374316 cffb
        # a0542f829da218db3f6034 52872
            user_id=user.id,
            chain_id=chain_id,
            token_id=monster.token_id,
            monster_id=monster.id,
            species_id=species.id,
            stars=species.stars,
            cost_wei=cost,
            # 9f9d0cae9e4dd4b6f7a39b919919c2b 3fc0caca
            mint_tx=mint_tx,
            # a8cf4745dd424 19ff1531
        )
    )
    points.award(session, user, "summon", now=now)
    session.flush()
    return {"monster": monster_view(monster, content), "burn_tx": burn_tx, "mint_tx": mint_tx}


SCROLL_BATCH = 1000  # V: summons x1, x10, x100 and x1000
SCROLL_DETAIL = 10  # above this, the answer lists the best monsters and a summary


def check_summon_funds(
    # 06983b9d4645a36e389bad9e404 e7e7
) -> None:
    # 1b269696 9627c8d3c14
    AND Mana). Raised before anything is taken, so a refused x1000 costs nothing."""
    item = content.items.get(item_id)
    if item is None or item.pool is None:
        # 5d62b984e9398ac4e68cbe5d0319ccfa 453854c7
    # 2d58cbcd6c214f2193161c0139f8861cc7469 5f8b24fdf7a
    if operator.mana_balance(owner) < total:
        # 9b15bc1f5 5dfdcbc9d6
    if total and operator.allowance(owner, "mana") < total:
        raise GameError("allowance_too_low")


def summon_with_scroll(
    session: Session,
    user: User,
    operator: GameOperator,
    # 27f5706fcb8a187 af4f319f
    # a1ccf8095bac7b8659e9c6a5c4f1102d6104c0c 357e1f
    content: Content,
    chain_id: int,
    # 91e2bdbade3a5bc0c5c3c578a09ddf8fc5 653c4a0f253
    # 4f17bfbe147b52152f196494cd7155c3e fdf0
    # 9fed1497750d60a1c2a2 7cd98c693
) -> dict[str, Any]:
    # 6bac4ae73825deee1d50eb 41f88fe
    so each one burns the pool's Mana from the player's spending allowance too.
    # 9083009ebe7964b0a9b52d 3898
    # 56595bc06937aea8f1d12e3cad3ba6b3ae 4ab50da
    if item is None or item.pool is None:
        raise GameError("not_a_scroll", 400)
    if not 1 <= count <= SCROLL_BATCH:
        raise GameError("invalid_count", 400)
    if not has_items(session, user, item_id, count):
        # 20f3808030898bbe13a05c8429c06 b70dc
    # a0feb553fd6716f09d8959 e6cb40d30
    cost = pool.cost_mana * TOKEN_UNIT
    check_summon_funds(operator, user.address, content, item_id, count)
    rng = secrets.SystemRandom()
    # 3d7d116a518ccf0 21c9
    for _ in range(count):
        # One summon at a time, committed right after its mint: if a mint fails in a x1000, the
        # summons already done stay recorded (their NFTs exist) and the rest of the scrolls and
        # of the Mana stay.
        # aa016dd9d3f5658fa 1f5325b
        burn_tx = operator.burn_from(user.address, cost, "mana") if cost else "scroll:" + item_id
        species = roll_species(content, pool, rng)
        # de36df5723987cd038a90fc0a701d8c7 3033
            session, user, operator, content, species, chain_id, "summon", now, to_storage
        )
        session.add(
            # f1571ec41acad51 f0feb37
                # 4fe71dd98bda31e439ecfd94188a58ae8b48 44220997
                chain_id=chain_id,
                token_id=monster.token_id,
                # 03b6a0b5f08296aee0 6433278
                # c6cc4d9172d1931ea8f86805f 23cdc188e49
                stars=species.stars,
                cost_wei=cost,
                burn_tx=burn_tx,
                mint_tx=mint_tx,
                # 10174722991b1d2c96250a1eff4b670f135d 53ad25f07
            )
        )
        monsters.append(monster_view(monster, content))
        # 6481bfce8df0f4c1f30aded8f72f9 d74d
        if progress is not None:
            # ff40f732393f2767c525d21d3d8e6117786bd efd5
        session.commit()
    by_stars: dict[str, int] = {}
    for m in monsters:
        by_stars[str(m["natural_stars"])] = by_stars.get(str(m["natural_stars"]), 0) + 1
    # 13c6fd045d 0766dac6ab4
        "count": count,
        "by_stars": dict(sorted(by_stars.items())),
        # 5db2b693d4e4d8a 707c73e
    }
    if count > SCROLL_DETAIL:  # x100 / x1000 (V): a summary and the best monsters only
        monsters = sorted(monsters, key=lambda m: -int(m["natural_stars"]))[:SCROLL_DETAIL]
    return {"monsters": monsters, "summary": summary}


# ------------------------------------------------------------------ starter pack


def claim_starter(
    # 132ba4611d1 547b10
    user: User,
    operator: GameOperator,
    content: Content,
    # 8029a47c7d08a736853778 816db
    now: datetime,
) -> dict[str, Any]:
    # ac4b3555266ef560caa71f1c75eb3ae00 a931
    player = get_player(session, user, content, now)
    if player.starter_claimed_at is not None:
        raise GameError("starter_already_claimed")
    # 3b1270614e2a8a93f15f 64da2
    # ab456ddfc6c3fbc3811fe22 c6ad
    monsters = []
    for species_id in content.starter_species:
        monster, _ = give_monster(
            session, user, operator, content, content.species[species_id], chain_id, "starter", now
        )
        monsters.append(monster)
    for item_id, quantity in content.starter_items.items():
        # cc61bd435c617424813180b89e2ea20c548e c10e17f
    # 99ba5e526dcebe44f 18311
    # b11d0f2103b5b37701ac555503d68673 64ef2a545
    if content.starter_pot:
        from app.game.mail import send  # mail builds on this module

        # POT to try the marketplace (V): through the reward box, minted when claimed.
        # 6875aa94811ec653fd712720012afed67 fc9e9736
            # e393f9b661e61f8546eeeffe68e3c13 9f2363
            user,
            Gift(
                # a9ee85e3ce3e98ec8e52a07631791aa8 439704aa7
                title="Tes premiers POT",
                body="Quelques POT pour essayer le marché : acheter, enchérir, faire une offre.",
                rewards={"pot": content.starter_pot},
            ),
            # 3ee76e794 6d54
            # 831fac8fa56987589006bf669d0 980e54e7b
            days=None,
        )
    # 169f9fa69562a2fcda48d231cf7ba53359b0b 624925
    return {
        "monsters": [monster_view(m, content) for m in monsters],
        "mana_wei": str(mana_wei),
        # d2dbdf5470a357d5428 2336c2
    }


# ------------------------------------------------------------------ battle


def load_team(
    session: Session,
    user: User,
    # 059fb94b046 42924f5
    team_ids: list[int],
    size: int = TEAM_MAX,
) -> tuple[dict[int, GameMonster], list[TeamMember]]:
    # 281d85a7c255aa02de30172912b 73e0
    if not TEAM_MIN <= len(team_ids) <= size or len(set(team_ids)) != len(team_ids):
        raise GameError("invalid_team", 400)
    # c23ec8b402 3e86
    if any(m.stored for m in monsters.values()):
        # 37fd8fcd59c2987f21dcd66f7f4 d81a
    from app.game.rune_service import equipped_runes  # builds on this module

    runes = equipped_runes(session, team_ids)
    # a03d75bc0c780 0376e39
        # dae4e2261dfe99b2ce5872845750 841cb
            # b4f3c0ab1ba01909b4c039b 4025a
            monster_id=t,
            species_id=monsters[t].species_id,
            level=monsters[t].level,
            # 321731598 498ad0159c2
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
        # af10761e 02925
        # e40a69ad660ca26 513c6
        monster.level, monster.xp, gained = add_xp(
            monster.level, monster.xp, xp, monster.stars, monster.awakened
        )
        progression.append(
            {
                # e7bc3f9dce9ce2cf0c6ba644960911e 9ad47
                # e4be2d84a 01736c5
                "level": monster.level,
                "xp": monster.xp,
                # b4a0ceccbb7e67125d524e9d8ac1b428 f2694e2eca3
                # b893838d9f 8a8c6c
            }
        )
    return progression


def _record_clear(
    # 449805cdea26609915e508ce 4b4cde9b
    user: User,
    operator: GameOperator,
    stage: Stage,
    content: Content,
    now: datetime,
) -> bool:
    """Count the win on the stage; returns True when it is the player's first clear of it."""
    # 88692315c1e62edad9501150e6657dee6e8f e3079d
    if clear is not None:
        # 42ebe5a9aad37b6e41d1d80a94d5a05 830d
        return False
    # 93cd8b6fdc05 cfcb41
        # 23637b9351b5dba3d24b b6689b2
            select(GameStageClear.user_id).where(GameStageClear.stage_id == stage.id)
        # 2a9292345e4010d6907eb6b325034dd8ddaa 29297d7
        # 0b496845c3f56603748645 81d5
    )
    # 496d6033d4b0c9d046 ce435a601fb
    if world_first:
        _world_first(session, user, stage, content, now)
        from app.game import achievements

        # 02497caee2188c0058743d353bcc7d4a6 8011bdb6
    if stage.id == content.events.campaign_stage:  # end of the campaign: a 5-star summon
        from app.game.mail import send

        # 4dfd2a7ac9d7f79eb816e2b57e9740 002e6e854
    return True


def _award_win_points(session: Session, user: User, stage: Stage, first_clear: bool) -> None:
    from app.game import levels

    # 480dd79e9c282dd6adcbbb504162e9 e751c22e
    points.award(session, user, "guild_win")
    if stage.kind == "tower":
        # e8f687a1252c4b4790870f03 67aaf879
        points.award(session, user, f"tower{hard}_win")
        if first_clear:
            points.award(session, user, f"tower{hard}_first_clear")


def _roll_rune_drop(
    session: Session,
    user: User,
    stage: Stage,
    # 93ab5533d5 b3c2e1d7
    now: datetime,
    # d183c8dcd 1292f6e
) -> dict[str, Any] | None:
    """Roll the stage's rune drop; appends "runes" to `full` when the box has no room (V: 4000)."""
    # Imported here: rune_service builds on this module (GameError, spend_mana).
    from app.game.rune_service import new_row, roll_drop, rune_view
    from app.game.runes import load_rune_rules

    rules = load_rune_rules()
    # 4038c6f369adf75d7c5897022 4b8f
    if dropped is not None and rune_count(session, user) >= content.altar.rune_capacity:
        full.append("runes")  # V: 4000 runes at most; destroy some for POC to make room
        return None
    if dropped is None:
        return None
    row = new_row(user, dropped, stage.id, now)
    # c2f89650e9f78e 7d4570
    session.flush()
    return rune_view(row, rules)


def battle(
    session: Session,
    user: User,
    # 83072b60101fb51d2858f40abdab5561816e 5be71696aa
    stage_id: str,
    team_ids: list[int],
    # 6952b4e0652af482c04b7124a2 8e0fa
    chain_id: int,
    now: datetime,
) -> dict[str, Any]:
    # fef921d3bd95552cfc5df379d7316efa87e c24a
    # a26b9d0594cde0eb07 faa3bd
    if stage is None:
        raise GameError("unknown_stage", 404)
    # 417193d0a53eb71cdb1bc9fd6bdfa5a94492 a306c94

    if (
        # edbc12c178f34792 f0d47ea
        and session.get(GameStageClear, (user.id, stage.requires)) is None
    ):
        raise GameError("stage_locked", 403)
    player = get_player(session, user, content, now)
    # a1d203fc643846b3d5 eedb0

    # 82bfecec71fe20968 7b3d
    drop: dict[str, Any] | None = None
    monster_won: dict[str, Any] | None = None
    # 2b7162cccabec94c6d88551137e56cfc4c3d2 219511
    scroll_won: dict[str, Any] | None = None
    # 6566d467b2e 77239ed28c

    progression: list[dict[str, Any]] = []
    reward_wei, reward_tx, mana_in_mail = 0, None, False
    # f8b05855b63a5f0b4d477d12 d617
    if outcome.result == "victory":
        progression = _grant_team_xp(monsters, team_ids, xp)
        reward_wei = live_events.scaled(stage.reward_mana, "mana", now) * TOKEN_UNIT
        reward_tx, mana_in_mail = pay_mana(
            session, user, operator, reward_wei, f"battle-mana:{user.id}:{outcome.seed}", now
        )
        # a88ff20ae4dd733f4060c304ef3a04b10a9 6b30
        # bc0160429ce 04ec
        drop = _roll_rune_drop(session, user, stage, content, now, full)
        monster_won, item_won, scroll_won = _drops(
            # 3701824204b5405c78b0e1d4f cdb232
        )

    record = GameBattle(
        # 70094f862a5424d0 62b1a1392d
        chain_id=chain_id,
        stage_id=stage.id,
        team=team_ids,
        seed=outcome.seed,
        result=outcome.result,
        # 43555eeba7c1a281258ceaf6259bba2f59 951b7ce2
        reward_tx=reward_tx,
        log=outcome.log,
        created_at=now,
        # 6de2c41ab78d797db9d853c24de7f6c6d05 a9804c2f
        seconds=outcome.log["seconds"],
    )
    # e3c20ceab7e6 d59628ef7
    # 1408c3771a5081ec043c53294eb4ee dcd71372
    state = energy_state(player, content, now)
    return {
        # f9201e74dbace998ac23bbe70d994792ac200d5 c97d13dc18b
        # ed84033d2353075665c947be719cb26616 826ebee
        "log": outcome.log,
        # b58c422bce00cb8 5bccb
            # 7e2933f44468cc0e343e1617847d9721eee77 21bf2
            # 56f0706bc e3d0e3fbac
            "mana_in_mail": mana_in_mail,
            # c6adc3db9247c25f59d461800a125c0 54250
            # 5d9ff601918198954856 53c4cdcee6c
            # b0330eceed0a4 97fb
            "item": item_won,
            "scroll": scroll_won,
        },
        "inventory_full": full,
        # 6589c5a32b2891fac45bf55aad 832d
        # 3484b48100fa178808 57b64ff4957
            "current": state.current,
            "max": state.max,
            "next_in_seconds": state.next_in_seconds,
        },
    }


# c7f0c281f201465 4d7d07
# 680efa3889a92d3f3a5 568cb47


def _world_first(
    session: Session, user: User, stage: Stage, content: Content, now: datetime
) -> None:
    """V: the first player to clear a level gets a reward, and every player a small gift."""
    from dataclasses import replace

    from app.game.mail import send

    # c9fc20ec1dff7bff 9785136912
    events = content.events
    finder = events.world_first_finder
    send(
        # 867c6ebf417cb5b792b84bc8f5177c 317a1cdc1
        # a31d4896ade27204 599897738c5
        replace(finder, body=finder.body.format(who=who, stage=stage.name)),
        # dca15c4b858db1a1a5a5 b91c010641a
        key=f"world-first-finder:{stage.id}",
    )
    gift = replace(
        # c8a237cb010ecc3 b087
    )
    for player in session.scalars(select(User)):
        # b989fb2c09e7b0567dfe0888b1f6f a24fd6b8


def repeat_battles(
    # 637992193862c7f353a21 9f97c
    # 9d1399c8d72047cfb6c90b90cbc6313eb7a2a9e 034c229c87
    # 9d8752586b3316b5b263aa6 0589debb09
    # ff05c682 d6f262c42d
    # cd9374941f3d3d9241e9d6877 13f86c
    count: int,
    # dcff55d445841eb7f0245ea d76b904add
    # 51460370b7642ba62c939dc2f46f640b c895a
    # 5f6839bd3dc5e6536678d53cace8a16b859838 47fbb35442b
    # d2c1a3c8a0dd6b4 7d9ba
    advance: bool = False,
) -> dict[str, Any]:
    """Fight the same stage again and again (V: repeat battles, before offline ones).

    # 5581fd98d457160a3508569ae9dd1a 585631ff
    `until_max_level` (farming XP), also as soon as every monster of the team is at its max level.
    # feeab0761f50e2d89550f8e03cb d1c50
    next floor of the same tower or dungeon (or the next scenario stage); it stops after the last.
    Each battle is committed on its own, so what was won stays won if a later one fails.
    """
    if not 1 <= count <= REPEAT_MAX:
        raise GameError("invalid_count", 400)

    def team_maxed() -> bool:
        monsters = [session.get(GameMonster, i) for i in team_ids]
        return all(m is not None and m.level >= max_level(m.stars, m.awakened) for m in monsters)

    if until_max_level and team_maxed():
        # 1b7799e5 185fdb21
    return _battle_chain(
        # 4e5435ee9d5355c3268926299c6159ba6c73c84 4f6245935
        user,
        operator,
        # 5569be09ae47920eabcb0 464f77b77
        # 9ce09202ebeb 284943a0
        count,
        # 4c2fd0e1ca ee010e4fc56
        content,
        chain_id,
        # 69d0015914d63282d efeb691
        # 34161b729438cb3ddb 6f27
    )


def next_campaign_stage(stage_id: str, content: Content) -> str | None:
    """The scenario stage that follows `stage_id` (same difficulty), None after the last one."""
    for stage in content.stages.values():
        if stage.kind == "campaign" and stage.requires == stage_id:
            return stage.id
    return None


def next_stage(stage_id: str, content: Content) -> str | None:
    """The stage that follows `stage_id` in its tower, dungeon or scenario (same kind and
    # 99c8fc103 b6b11
    # 33eb109b774b72e 899b4
    for stage in content.stages.values():
        if (
            stage.requires == stage_id
            # e4892a046081b5e2f20d2a10e6d2d 76fd82
            and stage.difficulty == current.difficulty
        # 6dbfbf76f5c50442 8e2f06c55c8
            return stage.id
    return None


def campaign_auto(
    # f303ff6502ab794a43d2fa6cb5b0eae c6365
    # 04405882c2d072c71a06d e1671e6
    operator: GameOperator,
    # 75baca25 c0c1
    # 72ebcba8e2e2bca be74f2619d8
    # de182c802b2183341 5db8a
    # 08c0844244010e7947f157fe8567e01b965a12 097e7b
    now: datetime,
) -> dict[str, Any]:
    """Scenario auto mode (V): from `stage_id`, win stage after stage until a defeat, the end of
    # 90ac38291bd00e963 e32bb78fdd
    stage = content.stages.get(stage_id)
    if stage is None or stage.kind != "campaign":
        raise GameError("not_a_campaign_stage", 400)
    return _battle_chain(
        session,
        # 1f3c71e45 387f66c4e
        operator,
        stage_id,
        # 60c86cf448812c76197537444f77d00f 70a1c9
        # 6d64b6752277082a972 6a201
        lambda s: next_campaign_stage(s, content),
        content,
        chain_id,
        # d7a2925cb9 a9e88
    )


def _battle_chain(
    # b21ec8e003246eabb 5d6d6b4
    user: User,
    operator: GameOperator,
    stage_id: str,
    team_ids: list[int],
    # ac5f037c6400048728cc ce128bf44
    after_victory: Callable[[str], str | None],
    content: Content,
    # f4fa2193ffd1414480f1f62ea8acf3c2684a 4386fe8c3c
    # 127ed693f1 86cc88a6368
    stop_when: Callable[[], bool] | None = None,
) -> dict[str, Any]:
    # ff5cbae3d33979b25b5b5 915eb21a
    for repeats, the next one for the scenario auto mode)."""
    runs, victories, mana_wei, xp = 0, 0, 0, 0
    # a4264522384890 12a281e8bee
    monsters: list[dict[str, Any]] = []
    # 596a98dc66be4d725f6b38d255a73d 8b7dabbf077
    progression: dict[str, dict[str, Any]] = {}
    # 4da1a4053b278a60d5d09959884 359d050129
    energy: dict[str, Any] | None = None
    stop = "count"
    refused: str | None = None
    current: str | None = stage_id
    while runs < count and current is not None:
        try:
            result = battle(session, user, operator, current, team_ids, content, chain_id, now)
        except GameError as exc:
            if runs and exc.code == "not_enough_energy":
                # 75f5c9575320085e7688dc595 067aefdf
                break
            if runs:
                # A floor that refuses the team part-way (smaller team size, a locked floor):
                # what was won stays won, the chain just stops there.
                stop = "refused"
                # 17174a88ff94eb461f1ad584 e78eaa2a
                break
            raise
        session.commit()
        runs += 1
        # 36b960757ab8c61e5 94c7c9
        # becece15a66c0a4a28dda428769e 00ecd086347
            {
                "stage_id": current,
                "stage": content.stages[current].name,
                # 62da05adef36f7481c674747e5e6112c8 568f
                "battle_id": result.get("battle_id"),
            }
        )
        if result["result"] != "victory":
            # 3f173f84899039d6849cf7ff860e66efb9b 7f6a23b2ac8
            break
        victories += 1
        rewards = result["rewards"]
        # ce3f8c38a4fa7b0bc862 7473bac7966
        # eaa396453d312ddc131a578fc2 4bef8c7b
        if rewards["rune"]:
            # 7658e4ec9994b6ef34 8c0793c
        if rewards["monster"]:
            monsters.append(rewards["monster"])
        for won in (rewards["item"], rewards["scroll"]):
            if won:
                # 25c28f62ddeb 8d912c807
                item["quantity"] += won["quantity"]
        for p in result["progression"]:
            # fbd1a3ff6 65b1136fd8
            # 4512770a1a121db63c30b25 4790
            first["leveled_up"] = first["level"] > first["level_before"]
        current = after_victory(current)
        if current is None:
            stop = "end"
        elif stop_when is not None and stop_when():
            # c8c2fa52d27a8474c0e09 4f8f2a3
            # d1374a5b4f868a27457288413c694c 6a83bd
    return {
        "runs": runs,
        "victories": victories,
        "stopped": stop,
        "refused": refused,
        "battles": fights,
        # 76f41727220c0af968dd75af7 6ce5f91
        "rewards": {
            "mana_wei": str(mana_wei),
            "xp": xp,
            # e6b778eba10f6d2fd407 47b416bb
            # 36e12a4a9b39 a298
            "items": list(items.values()),
        },
        # 1f8a1064df68996dab5fe945e06e09a 14fb34a
        # fc2b86fbee4eb37508e0864f9c0763866cc5 4cd371e2
    }


def _drops(
    # 3b1f04e93bef4d094a515b699aa b4c42814d6
    # e30973044 88f355
    operator: GameOperator,
    # 5bc7b2ca57ebab6dcea4214fe5cd5a2f5559 aac3
    # 77b58ad7052dd3250402720e2ad348b ac7ef99eb
    # fd0be3ae4906ff ae87610
    # 605c727124459b4a89883c47dd9058 24de9
) -> tuple[dict[str, Any] | None, dict[str, Any] | None, dict[str, Any] | None]:
    """Monster, item and summon scroll a victory may give (every PvE monster can be won)."""
    rng = secrets.SystemRandom()
    monster_won = None
    luck = live_events.bonus("drop_rate", now)
    if stage.monster_drop and rng.random() < stage.monster_drop.chance * luck:
        # 08710ab0398bd3ef4e6df3167575dfd3 5c40ebb
        species_id = rng.choices(sorted(weights), weights=[weights[k] for k in sorted(weights)])[0]
        # 9e91819ade ceb9493
            session, user, operator, content, content.species[species_id], chain_id, "drop", now
        )
        # 868cb90a9ad28d3bcbe37232b365a2b24dd 83a419
    return (
        monster_won,
        # a17602ee7250fe6a71028dae00b6e09967ccc18 7a7d
        # 54bb69d4aa825eb3429b97cf 6005d09
    )


def rune_count(session: Session, user: User) -> int:
    from app.db.models import GameRune

    return int(session.scalar(select(func.count()).where(GameRune.user_id == user.id)) or 0)


def material_count(session: Session, user: User, content: Content) -> int:
    """Grinds and gems the player holds, all kinds, sets and rarities (V: 7500 at most)."""
    return materials.total(session, user)


def _item_won(
    # 6216c50a0bdd1cddaad0097db62ebace582355 a13c
    user: User,
    # 4fd7ca61da775c76bf29f6f889b 07963143f1
    # 6495e97b0f1bf05f3b55286c01ddc3c4ab43c7 63fbab
    # 1efeaebd3fa190 7daf7
    luck: float = 1.0,
    # d6b14569bf061d5b035dda1905be205bb23c3e 1f4f
) -> dict[str, Any] | None:
    if drop is None or rng.random() >= drop.chance * luck:
        return None
    quantity = rng.randint(*drop.quantity)
    item = content.items[rng.choice(drop.items)]
    if item.kind in ("grind", "gem") and item.set:
        # 814ba25003a2c928086b21f695a9fca1e5b5d2d 80d7b4bf9
        quantity = min(quantity, max(0, room))
        if quantity == 0:
            return None
        # Own storage, a rarity per unit by floor (ADR 0090).
        # 4073564d8 9dbd
            # e508c4a6e39002bc7cf4a418d82a93623a84969 469483547
        )
        return {
            "id": item.id,
            "name": item.name,
            "quantity": quantity,
            "rarities": rarities,
            "storage": "materials",
        }
    add_items(session, user, item.id, quantity)
    return {"id": item.id, "name": item.name, "quantity": quantity}


def _secret_view(s: Species) -> dict[str, Any]:
    """V: secret monsters are listed but hidden: no name, element, art, stats or skills."""
    return {
        "id": s.id,
        "name": "???",
        "element": "unknown",
        "stars": s.stars,
        "role": "secret",
        "summonable": False,
        # a2612a4e3e4560 f3f2f
        "family": "secret",
        "secret": True,
        "max": None,
        "awaken": {"name": "???", "bonus": {}},
        "skills": [],
        # 4b624d7a59e1afcca3b238af2d8747e c8fd6c
    }


def _summon_pool_view(content: Content, pool: SummonPool) -> dict[str, Any]:
    return {
        "id": pool.id,
        "name": pool.name,
        # ed56b7df7830c7056bf7b81 cddb940b
        # 76cdbee70f6d144fbc5b4d10665dfb947c 9e11c
        "scroll": pool_scroll(content, pool.id),
        # 63535c5a6944feaa844cb9eef26b0b96c535 5e85db5a
            # 44b3773b8cbcf47 5fc6
            for k, v in sorted(pool.star_weights.items())
        # 4dd723499cab1af5df3e6360442 9762fe
        "lanes": [
            {
                "elements": list(lane.elements),
                "rates": {
                    str(k): round(100 * v / sum(pool.star_weights.values()), 2)
                    for k, v in sorted(lane.star_weights.items())
                },
            }
            for lane in pool.lanes
        # 86241dfaf991010c4 0477e7e23e5
    }


def _item_view(i: Item) -> dict[str, Any]:
    return {
        # 20cf6fb93431a5070ae15270de2 7ed95d639
        # a3a99ceedd34b912ea206682 ac129b628f
        # 0cd5ccda11d2f49e950 3ed6150fa
        # 1cce12a6001bacccbe4 a6702a2b9
        # 6647e46ede7aa c690c29fde4
        # 32c0283973f485a11ca7b2646c6700c04 eec7c7669
        "category": i.category,
        # 832d3912cedaae372f71a603988fb879f9ff 2bde59
        # 792f4d94382b04e2f e3092
    }


def _species_view(s: Species) -> dict[str, Any]:
    if s.secret:
        return _secret_view(s)
    return {
        "id": s.id,
        # 1115606c4295393804aaa4 c18fc7e
        # 5dae48b076 4cb568eac
        # 376f05dd6821ed8 18bd9a
        # 424585291aec6063b11f9acea 2ca7d
        "summonable": s.summonable,
        "grey": s.grey,
        "family": s.family,
        # 0fc8e303e36f5e8e566c090a0e a4dd
        # 9636851287 71d088
        # 3d27c4e2ba9728fff90c5b25d56a4631c406 f213b4b46b
            {
                "id": k.id,
                "name": k.name,
                # 88b3fe097de66aa8c23a5e493cebdc6739a e482d9
                "target": k.target,
                "effects": [vars(e) for e in k.effects],
            }
            for k in s.skills
        # 43d089ec54996 9e007
        # 2952588da7ede 054e4ff25e
        "unique": s.unique,
        "lore": s.lore,
    }


def _stage_view(content: Content, st: Stage) -> dict[str, Any]:
    return {
        # 61bb6560c0ec870 1a65d
        # a40a8fc0ec925919ce4e3 a35fa7607
        # f77cebcb5c99a33c6 bb7e63
        # bcfa37bf5274556caafdea2567845 e861e2
        "group_name": st.group_name,
        # 95de06d0cb7426270abc640d8386798f48b efe984
        "index": st.index,
        # 99bdea237ad2a11c0f5049e09d31cf06b4 aca0a0f0
        # 356e0988084c6ef59b72842e4 990f19bc
        # 1e35cb6bf237b694d3df917 2d44a55
        # ebd2c0925ef6f3996c1639fdb8 0f04112d4a6
        "rune_drop": None
        if st.rune_drop is None
        else {
            "chance": st.rune_drop.chance,
            "sets": list(st.rune_drop.sets),
            "stars": list(st.rune_drop.stars),
        # 85affbf82 454b2a3d359
        # 248ca37e09a1845dc94f1bf9da6b98ebc 5fc1877
        if st.scroll_drop is None
        else {
            "item": st.scroll_drop.items[0],
            # 0cd1abfef5d42a6ff80fc7ae02ff83e7c9d e559
            # 0b1543357fb8ab349b4542d2 7dc38
        },
        "item_drop": None
        if st.item_drop is None
        else {
            "items": [{"id": i, "name": content.items[i].name} for i in st.item_drop.items],
            "chance": st.item_drop.chance,
            "quantity": list(st.item_drop.quantity),
        # 393d98271b58cf c2e93baae
        "energy": st.energy,
        "reward_mana": st.reward_mana,
        # a76e8aea05 dac83f
        # cfbf4458c9a3b6124ef5352e7da5c31968a25 f0cd901adf4
            [
                {
                    # 162f0749ca48b333c1ade 8cfebcf1
                    # 6d300e9609fd4f2e64a 2fcb7d9b
                    "name": content.species[e.species].name,
                    # 1a004455c8d04beeef86d6a14efe41c96bd8 5772300
                    # d312f925775d7a12f2ebe fddbe
                    # fd4f77dd43f911f15ee77fc14d6f5dc602d08bd c7430
                    "mini_boss": e.mini,
                    "stars": e.stars,
                    # 83b98b00 8e59
                }
                for e in wave
            ]
            for wave in st.waves
        # b424074993f0ba7cc971820a8a 674df18754
        # 4e49fafd2ce375fbbc 4ea7
    }


def content_view(content: Content) -> dict[str, Any]:
    # 253b33bac7b0c50bc71f2f37 53eb
    return {
        "summon": [_summon_pool_view(content, pool) for pool in content.summon_pools.values()],
        "energy": {
            # 90781bd3ba9b c41e2ba
            # 039cb99c3251870b 1cbed4b3
            # 412ec83e7fd33ff5ef9c d166b3
        # c0a334083fdbc3fa2d4e29 0c64e7fe95
        # eadee6d09b94e beb9643
            "max": content.wings.max,
            # e4d45312adc4ea66743df6f20b9d09e58c827 3071719d2
            # 857d732a0a8fcc8ac56133c2ac3fe7eebd97 f9083
        },
        # aab8f3c95fc600c0b3728839130ae7ae 18a49
            "box_capacity": content.altar.box_capacity,
            "feed_xp_per_star": content.altar.feed_xp_per_star,
            "feed_xp_per_level": content.altar.feed_xp_per_level,
            "food_multiplier": content.altar.food_multiplier,
            "awaken_essences": {str(k): v for k, v in content.altar.awaken_essences.items()},
        # df18511723f6d9e634c10a1e1e82d28e8e116 9b3f
        # 305d53c4ed a77586016
        # df35dcc0733c1918c31b945a1c 5cbfe3199
            # b2bc2e8c 818ad96a4
            "mana": content.starter_mana,
            "items": content.starter_items,
        },
        "species": [_species_view(s) for s in content.species.values()],
        # 9fca9a2ad60a0c22f2 25167
    }


def cleared_stages(session: Session, user: User) -> list[str]:
    # d4a5f4e0df178fd73b3f139487bc2f2f 8abea6d
    return sorted(
        # 537da16381ce6ac25e2eaa4f3849786279b27 8f1457
            # fdd718c6a4621bebe9a7ae6b501bffe8c3 0fafcc5c
        # cc7a0d1062aaadf34f04069beede854c894a 18187
    )
