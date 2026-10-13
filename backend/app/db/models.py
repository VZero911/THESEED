"""ORM models: users and sessions (auth), indexed chain data (indexer)."""

from datetime import date, datetime
from decimal import Decimal
from typing import Any

from sqlalchemy import (
    BigInteger,
    Boolean,
    CheckConstraint,
    Computed,
    Date,
    DateTime,
    Float,
    ForeignKey,
    ForeignKeyConstraint,
    Index,
    Integer,
    Numeric,
    String,
    Text,
    UniqueConstraint,
    false,
    func,
    text,
)
from sqlalchemy.dialects.postgresql import JSONB, TSVECTOR
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.db.base import Base


class User(Base):
    """A wallet that signed in at least once. The address is the identity; the rest is profile."""

    __tablename__ = "users"
    __table_args__ = (
        # Lower-case hex, so equality in SQL (and later joins with indexed events) is exact.
        CheckConstraint("address ~ '^0x[0-9a-f]{40}$'", name="address_lowercase_hex"),
    )

    id: Mapped[int] = mapped_column(primary_key=True)
    address: Mapped[str] = mapped_column(String(42), unique=True)
    username: Mapped[str | None] = mapped_column(String(32), unique=True)
    avatar_url: Mapped[str | None] = mapped_column(String(2048))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now())
    last_login_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    invite_code: Mapped[str | None] = mapped_column(String(32), doc="closed beta: invite used")
    suspended_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True), doc="set by an admin: the account cannot sign in or play"
    )
    suspended_reason: Mapped[str | None] = mapped_column(String(500))

    sessions: Mapped[list["RefreshToken"]] = relationship(back_populates="user")


class AuthNonce(Base):
    """A single-use challenge embedded in a SIWE message to prevent replaying a signed login."""

    __tablename__ = "auth_nonces"

    nonce: Mapped[str] = mapped_column(String(64), primary_key=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    used_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class RefreshToken(Base):
    """A login session. Only the SHA-256 of the opaque token is stored; rotated on every refresh."""

    __tablename__ = "refresh_tokens"
    __table_args__ = (Index("ix_refresh_tokens_user_id_active", "user_id", "revoked_at"),)

    id: Mapped[int] = mapped_column(primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    token_hash: Mapped[str] = mapped_column(String(64), unique=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    revoked_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    replaced_by_id: Mapped[int | None] = mapped_column(
        ForeignKey("refresh_tokens.id", ondelete="SET NULL")
    )

    user: Mapped[User] = relationship(back_populates="sessions")


# --------------------------------------------------------------------------- indexer
# Raw events are the source of truth; balances and owners are computed from `token_transfers` at
# read time. Undoing a reorg is therefore just deleting the orphaned blocks (cascade).

# uint256 fits in 78 decimal digits.
Uint256 = Numeric(78, 0)


class IndexerCursor(Base):
    """Last block fully processed for a chain (the indexer resumes from `block_number + 1`)."""

    __tablename__ = "indexer_cursors"

    chain_id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    block_number: Mapped[int] = mapped_column(BigInteger)
    block_hash: Mapped[str] = mapped_column(String(66))
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class IndexedBlock(Base):
    """A block that contained indexed events (kept to detect and undo reorgs)."""

    __tablename__ = "indexed_blocks"

    chain_id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    number: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    hash: Mapped[str] = mapped_column(String(66))
    timestamp: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class ChainEvent(Base):
    """One decoded log emitted by one of our contracts."""

    __tablename__ = "chain_events"
    __table_args__ = (
        UniqueConstraint("chain_id", "block_hash", "log_index"),
        ForeignKeyConstraint(
            ["chain_id", "block_number"],
            ["indexed_blocks.chain_id", "indexed_blocks.number"],
            ondelete="CASCADE",
        ),
        Index("ix_chain_events_contract_event", "chain_id", "contract", "event"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    chain_id: Mapped[int] = mapped_column(BigInteger)
    block_number: Mapped[int] = mapped_column(BigInteger)
    block_hash: Mapped[str] = mapped_column(String(66))
    tx_hash: Mapped[str] = mapped_column(String(66))
    log_index: Mapped[int] = mapped_column(Integer)
    contract: Mapped[str] = mapped_column(String(64), doc="Name in the deployment file")
    address: Mapped[str] = mapped_column(String(42), doc="Emitting proxy, lower-case")
    event: Mapped[str] = mapped_column(String(64))
    args: Mapped[dict[str, Any]] = mapped_column(JSONB, doc="Decoded arguments, JSON-safe")


class TokenTransfer(Base):
    """Normalized ERC-20 / ERC-721 / ERC-1155 movement, for balance and ownership queries.

    ERC-20: token_id NULL. ERC-721: value 1. ERC-1155 batches: one row per (id, value) pair.
    Mints have from_address 0x0, burns to_address 0x0.
    """

    __tablename__ = "token_transfers"
    __table_args__ = (
        Index("ix_token_transfers_to", "chain_id", "contract", "to_address"),
        Index("ix_token_transfers_from", "chain_id", "contract", "from_address"),
        Index("ix_token_transfers_token", "chain_id", "contract", "token_id"),
    )

    event_id: Mapped[int] = mapped_column(
        ForeignKey("chain_events.id", ondelete="CASCADE"), primary_key=True
    )
    batch_index: Mapped[int] = mapped_column(Integer, primary_key=True, default=0)
    chain_id: Mapped[int] = mapped_column(BigInteger)
    contract: Mapped[str] = mapped_column(String(64))
    block_number: Mapped[int] = mapped_column(BigInteger)
    log_index: Mapped[int] = mapped_column(Integer)
    from_address: Mapped[str] = mapped_column(String(42))
    to_address: Mapped[str] = mapped_column(String(42))
    token_id: Mapped[Decimal | None] = mapped_column(Uint256)
    value: Mapped[Decimal] = mapped_column(Uint256)


# --------------------------------------------------------------------------- game (milestone 1)
# The chain owns the monster (ERC-721 tokenId); its game data (species, level, XP) lives here,
# keyed by (chain_id, token_id) â€” ADR 0003 / D8.


class GameMonster(Base):
    """Game state of one monster.

    A monster of 3+ natural stars is a Monster NFT (`chain_id`, `token_id`; its owner is read from
    the chain). A 1-2 star monster (food, lutins) is off-chain only: no token, owned by `user_id`
    (game spec 4).
    """

    __tablename__ = "game_monsters"
    __table_args__ = (
        UniqueConstraint("chain_id", "contract", "token_id"),
        CheckConstraint(
            "(token_id IS NOT NULL) OR (user_id IS NOT NULL)", name="nft_or_owned_offchain"
        ),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    chain_id: Mapped[int] = mapped_column(BigInteger)
    contract: Mapped[str | None] = mapped_column(
        String(42),
        doc="Monster proxy (lowercase) of an NFT: token ids restart with a new deployment",
    )
    token_id: Mapped[int | None] = mapped_column(BigInteger)
    user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), index=True, doc="owner of an off-chain monster"
    )
    species_id: Mapped[str] = mapped_column(String(64))
    stars: Mapped[int] = mapped_column(Integer)
    level: Mapped[int] = mapped_column(Integer, default=1)
    xp: Mapped[int] = mapped_column(Integer, default=0)
    awakened: Mapped[bool] = mapped_column(Boolean, default=False, server_default=false())
    stored: Mapped[bool] = mapped_column(
        Boolean, default=False, server_default=false(), doc="in the storage, not the box"
    )
    locked: Mapped[bool] = mapped_column(
        Boolean, default=False, server_default=false(), doc="cannot be used as food"
    )
    origin: Mapped[str] = mapped_column(
        String(16), doc="summon | starter | drop | adopted (minted outside the game)"
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GamePlayer(Base):
    """Per-user game state. Energy regenerates over time (computed lazily)."""

    __tablename__ = "game_players"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    energy: Mapped[int] = mapped_column(Integer)
    energy_updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    wings: Mapped[int | None] = mapped_column(
        Integer, doc="arena wings; None until the first fight (then the content's start value)"
    )
    wings_updated_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    starter_claimed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    box_capacity: Mapped[int | None] = mapped_column(
        Integer, doc="monster box size when raised by a gift (default: content)"
    )


class GameSummon(Base):
    """One summon: MANA burned through a signed permit, then a monster minted."""

    __tablename__ = "game_summons"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    chain_id: Mapped[int] = mapped_column(BigInteger)
    token_id: Mapped[int | None] = mapped_column(BigInteger)
    monster_id: Mapped[int | None] = mapped_column(
        ForeignKey("game_monsters.id", ondelete="SET NULL")
    )
    species_id: Mapped[str] = mapped_column(String(64))
    stars: Mapped[int] = mapped_column(Integer)
    cost_wei: Mapped[Decimal] = mapped_column(Uint256)
    burn_tx: Mapped[str] = mapped_column(String(66))
    mint_tx: Mapped[str | None] = mapped_column(String(66))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameBattle(Base):
    """A finished battle, with its full event log for replay and audit (same seed, same fight)."""

    __tablename__ = "game_battles"
    __table_args__ = (
        # "My latest battles": the newest rows of one player read straight off the index.
        Index("ix_game_battles_user_created", "user_id", text("created_at DESC"), text("id DESC")),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    chain_id: Mapped[int] = mapped_column(BigInteger)
    stage_id: Mapped[str] = mapped_column(String(64))
    team: Mapped[list[int]] = mapped_column(JSONB)
    seed: Mapped[int] = mapped_column(BigInteger)
    result: Mapped[str] = mapped_column(String(16))
    reward_mana_wei: Mapped[Decimal] = mapped_column(Uint256, default=0)
    reward_tx: Mapped[str | None] = mapped_column(String(66))
    log: Mapped[dict[str, Any]] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    # Records (V): actions until the end and battle clock; null on battles before records.
    turns: Mapped[int | None] = mapped_column(Integer)
    seconds: Mapped[float | None] = mapped_column(Float)


class GameGrindRun(Base):
    """One grind run fought (18 waves, docs/game/GRIND_RUNS.md); a won run is claimed once."""

    __tablename__ = "game_grind_runs"
    __table_args__ = (Index("ix_game_grind_runs_user_run", "user_id", "run_id"),)

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"))
    run_id: Mapped[str] = mapped_column(String(64))
    seed: Mapped[int] = mapped_column(BigInteger)
    team: Mapped[list[int]] = mapped_column(JSONB)
    result: Mapped[str] = mapped_column(String(16))  # "won" or "lost"
    energy: Mapped[int] = mapped_column(Integer)  # what the start really cost
    battle_id: Mapped[int | None] = mapped_column(
        ForeignKey("game_battles.id", ondelete="SET NULL")
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    claimed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class GameRune(Base):
    """A rune owned by a player (off-chain by default, game spec section 5).

    `substats` is a list of {stat, value, grind, changed}. A rune is equipped when it points to a
    monster; one rune per slot per monster.
    """

    __tablename__ = "game_runes"
    __table_args__ = (
        UniqueConstraint("monster_id", "slot"),
        CheckConstraint("slot BETWEEN 1 AND 7", name="slot_range"),
        CheckConstraint("stars BETWEEN 1 AND 7", name="stars_range"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    set_id: Mapped[str] = mapped_column(String(32))
    slot: Mapped[int] = mapped_column(Integer)
    stars: Mapped[int] = mapped_column(Integer)
    rarity: Mapped[str] = mapped_column(String(16))
    level: Mapped[int] = mapped_column(Integer, default=0)
    main_stat: Mapped[str | None] = mapped_column(String(16))
    substats: Mapped[list[dict[str, Any]]] = mapped_column(JSONB)
    innate: Mapped[dict[str, Any] | None] = mapped_column(
        JSONB, doc="fixed extra stat {stat, value} on some runes"
    )
    monster_id: Mapped[int | None] = mapped_column(
        ForeignKey("game_monsters.id", ondelete="SET NULL"), index=True, doc="equipped on"
    )
    source: Mapped[str] = mapped_column(String(64), doc="where it dropped (stage id)")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameStageClear(Base):
    """A stage the player has won at least once (unlocks the next one)."""

    __tablename__ = "game_stage_clears"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    stage_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    clears: Mapped[int] = mapped_column(Integer, default=1)
    first_cleared_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameItem(Base):
    """Stackable off-chain items a player owns (essences...), by item id from content/items.json."""

    __tablename__ = "game_items"
    __table_args__ = (CheckConstraint("quantity >= 0", name="quantity_positive"),)

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    item_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    quantity: Mapped[int] = mapped_column(Integer, default=0)


class GameRuneMaterial(Base):
    """Grinds and gems in their own storage (rune rework v2, ADR 0090): one row per kind, rune set
    and rarity, so a player's stock reads as a small table and never mixes with ordinary items."""

    __tablename__ = "game_rune_materials"
    __table_args__ = (
        CheckConstraint("quantity >= 0", name="material_quantity_positive"),
        CheckConstraint("kind IN ('grind', 'gem')", name="material_kind"),
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    kind: Mapped[str] = mapped_column(String(8), primary_key=True)
    set_id: Mapped[str] = mapped_column(String(32), primary_key=True)
    rarity: Mapped[str] = mapped_column(String(16), primary_key=True)
    quantity: Mapped[int] = mapped_column(Integer, default=0)


class GameMail(Base):
    """A message in the player's reward box: team notices, gifts, rewards to claim.

    `key` makes one-off gifts idempotent (e.g. "founder"); `rewards` is {energy, box_capacity,
    mana, crystal, items: {id: quantity}}; nothing on-chain is minted before the claim.
    """

    __tablename__ = "game_mail"
    __table_args__ = (UniqueConstraint("user_id", "key"),)

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    key: Mapped[str | None] = mapped_column(String(64))
    sender: Mapped[str] = mapped_column(String(32))
    title: Mapped[str] = mapped_column(String(200))
    body: Mapped[str] = mapped_column(String(4000))
    rewards: Mapped[dict[str, Any]] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    read_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    claimed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class GameWorldBoss(Base):
    """One life of the world boss: its shared HP pool, from its spawn to its death."""

    __tablename__ = "game_world_bosses"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    element: Mapped[str] = mapped_column(String(16))
    species_id: Mapped[str] = mapped_column(String(64))
    max_hp: Mapped[int] = mapped_column(BigInteger)
    hp: Mapped[int] = mapped_column(BigInteger)
    spawned_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    killed_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    killed_by: Mapped[int | None] = mapped_column(ForeignKey("users.id", ondelete="SET NULL"))


class GameWorldBossAttack(Base):
    """One attempt of a player against the world boss (5 a day), with its replay."""

    __tablename__ = "game_world_boss_attacks"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    boss_id: Mapped[int] = mapped_column(
        ForeignKey("game_world_bosses.id", ondelete="CASCADE"), index=True
    )
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    team: Mapped[list[int]] = mapped_column(JSONB)
    # Runes worn by the team during the attempt (V: never the same ones twice in a day).
    runes: Mapped[list[int]] = mapped_column(JSONB, default=list, server_default="[]")
    seed: Mapped[int] = mapped_column(BigInteger)
    damage: Mapped[int] = mapped_column(BigInteger)
    reward_mana_wei: Mapped[Decimal] = mapped_column(Uint256, default=0)
    log: Mapped[dict[str, Any]] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)


class GameFriendship(Base):
    """A friend request from `user_id` to `friend_id`; accepted, it links both players."""

    __tablename__ = "game_friendships"
    __table_args__ = (
        UniqueConstraint("user_id", "friend_id"),
        CheckConstraint("user_id <> friend_id", name="not_self"),
    )

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    user_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    friend_id: Mapped[int] = mapped_column(ForeignKey("users.id", ondelete="CASCADE"), index=True)
    accepted: Mapped[bool] = mapped_column(Boolean, default=False, server_default=false())
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameGuild(Base):
    """A guild (V: 50 members at most). Open guilds take anyone; closed ones take requests."""

    __tablename__ = "game_guilds"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    name: Mapped[str] = mapped_column(String(32), unique=True)
    description: Mapped[str] = mapped_column(String(500), default="")
    open: Mapped[bool] = mapped_column(Boolean, default=True)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    xp: Mapped[int] = mapped_column(
        BigInteger, default=0, server_default="0", doc="guild level XP (app/game/levels.py)"
    )


class GameGuildMember(Base):
    """A player in a guild (one guild per player): leader, officer or member."""

    __tablename__ = "game_guild_members"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    guild_id: Mapped[int] = mapped_column(
        ForeignKey("game_guilds.id", ondelete="CASCADE"), index=True
    )
    role: Mapped[str] = mapped_column(String(16))
    joined_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameGuildRequest(Base):
    """A request to join a closed guild, until an officer or the leader answers it."""

    __tablename__ = "game_guild_requests"

    guild_id: Mapped[int] = mapped_column(
        ForeignKey("game_guilds.id", ondelete="CASCADE"), primary_key=True
    )
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameShopPurchase(Base):
    """How many times a player bought an offer on a (UTC) day, for the daily limits."""

    __tablename__ = "game_shop_purchases"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    offer_id: Mapped[str] = mapped_column(String(64), primary_key=True)
    day: Mapped[str] = mapped_column(String(10), primary_key=True)
    count: Mapped[int] = mapped_column(Integer, default=0)


class IdempotencyKey(Base):
    """The stored answer of a spend route for a client's `Idempotency-Key`: a retry of the same
    request (lost answer, double tap) gets this answer instead of paying twice."""

    __tablename__ = "idempotency_keys"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    key: Mapped[str] = mapped_column(String(64), primary_key=True)
    route: Mapped[str] = mapped_column(String(64))
    response: Mapped[dict[str, Any]] = mapped_column(JSONB)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)


class GamePoll(Base):
    """A poll of content/polls.json once opened on-chain (Polls contract, ADR 0019)."""

    __tablename__ = "game_polls"

    key: Mapped[str] = mapped_column(String(64), primary_key=True)
    chain_id: Mapped[int] = mapped_column(BigInteger)
    # The Polls contract the poll lives on: a new deployment (same chain id) opens it again.
    contract: Mapped[str | None] = mapped_column(String(42))
    poll_id: Mapped[int] = mapped_column(BigInteger)
    content_hash: Mapped[str] = mapped_column(String(66))
    tx: Mapped[str] = mapped_column(String(66))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    # The second reward: set once an admin marks the finished poll useful (ADR 0019 follow-up).
    followup_level: Mapped[str | None] = mapped_column(String(16))
    followup_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class GamePollVote(Base):
    """A player's vote, mirrored from the chain (the free answer's text lives only here)."""

    __tablename__ = "game_poll_votes"

    poll_key: Mapped[str] = mapped_column(
        ForeignKey("game_polls.key", ondelete="CASCADE"), primary_key=True
    )
    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    option: Mapped[int] = mapped_column(Integer)
    answer: Mapped[str | None] = mapped_column(String(500))
    tx: Mapped[str] = mapped_column(String(66))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameFeedback(Base):
    """A feedback request of a player (V, 2026-10-04): asked, then answered or skipped. One row per
    (player, question); the answer is a rating, a choice or a short text."""

    __tablename__ = "game_feedback"
    __table_args__ = (
        CheckConstraint("rating is null or rating between 1 and 5", name="feedback_rating"),
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    question_key: Mapped[str] = mapped_column(String(40), primary_key=True)
    status: Mapped[str] = mapped_column(String(10), default="asked", doc="asked|answered|skipped")
    asked_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    answered_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    rating: Mapped[int | None] = mapped_column(Integer)
    choice: Mapped[int | None] = mapped_column(Integer)
    text: Mapped[str | None] = mapped_column(String(500))


class AlicePref(Base):
    """A preference of V or of A.L.I.C.E (V, 2026-10-04): modular settings, one row per
    (owner, scope, key) with a JSON value. `scope` groups them (theme, monitor...). Mirrors
    docs/alice/theme.json; written only through the admin console, each change audited."""

    __tablename__ = "alice_prefs"

    owner: Mapped[str] = mapped_column(String(64), primary_key=True, doc="v | alice | an address")
    scope: Mapped[str] = mapped_column(String(32), primary_key=True)
    key: Mapped[str] = mapped_column(String(64), primary_key=True)
    value: Mapped[Any] = mapped_column(JSONB)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))
    updated_by: Mapped[str] = mapped_column(String(42))


class GamePlayerSettings(Base):
    """The player's own setup (V, 2026-10-03): navigation bar position, icon order, size...
    kept on the account, not on the device. `screens`: one setup per named screen."""

    __tablename__ = "game_player_settings"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    data: Mapped[dict[str, Any]] = mapped_column(JSONB, default=dict)
    updated_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class Invite(Base):
    """A closed-beta invite code: how many accounts it can open, until when, and whether it was
    revoked. Used at an account's first sign-in (`users.invite_code` keeps which one)."""

    __tablename__ = "invites"

    code: Mapped[str] = mapped_column(String(32), primary_key=True)
    max_uses: Mapped[int] = mapped_column(Integer, default=1)
    uses: Mapped[int] = mapped_column(Integer, default=0)
    expires_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))
    revoked: Mapped[bool] = mapped_column(Boolean, default=False, server_default=false())
    note: Mapped[str] = mapped_column(String(120), default="")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class ContributionAward(Base):
    """A priced contribution (ADR 0035): who, what, why it helps the system, the breakdown of the
    number, and where it stands (proposed -> paid, or rejected)."""

    __tablename__ = "contribution_awards"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    address: Mapped[str] = mapped_column(String(42), index=True)
    kind: Mapped[str] = mapped_column(String(24))
    title: Mapped[str] = mapped_column(String(160))
    why: Mapped[str] = mapped_column(String(500), doc="how it helps the system")
    reference: Mapped[str] = mapped_column(String(120), default="", doc="commit, PR, issue, link")
    audience: Mapped[str] = mapped_column(String(12))
    currency: Mapped[str] = mapped_column(String(8), default="poc")
    amount: Mapped[int] = mapped_column(Integer)
    breakdown: Mapped[dict[str, Any]] = mapped_column(JSONB, default=dict)
    status: Mapped[str] = mapped_column(
        String(10), default="proposed", doc="proposed|paying|paid|rejected"
    )
    proposed_by: Mapped[str] = mapped_column(String(42))
    decided_by: Mapped[str | None] = mapped_column(String(42))
    tx: Mapped[str | None] = mapped_column(String(80))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)
    decided_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True))


class BugReport(Base):
    """A report sent from the game (bug, idea or abuse): text, where the player was, status."""

    __tablename__ = "bug_reports"

    id: Mapped[int] = mapped_column(BigInteger, primary_key=True)
    user_id: Mapped[int | None] = mapped_column(
        ForeignKey("users.id", ondelete="SET NULL"), index=True
    )
    kind: Mapped[str] = mapped_column(String(8), doc="bug | idea | abuse")
    text: Mapped[str] = mapped_column(String(2000))
    context: Mapped[dict[str, Any]] = mapped_column(JSONB, default=dict)
    status: Mapped[str] = mapped_column(String(8), default="open", doc="open | closed")
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), index=True)


class AccountTag(Base):
    """A tag held by an account (ADR 0034): contributor, ai_agent, node, server, tester, artist.
    Staff tags (admin, moderator, animator) and system come from the settings.
    The player tag is implicit."""

    __tablename__ = "account_tags"

    address: Mapped[str] = mapped_column(String(42), primary_key=True)
    tag: Mapped[str] = mapped_column(String(24), primary_key=True)
    note: Mapped[str] = mapped_column(String(120), default="")
    granted_by: Mapped[str] = mapped_column(String(42))
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameArenaRivalWin(Base):
    """First win over a rival on a UTC day (rival arena, V 2026-10-03): the day's rewards are paid
    once; the row is the receipt."""

    __tablename__ = "game_arena_rival_wins"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    rival: Mapped[int] = mapped_column(Integer, primary_key=True)
    day: Mapped[date] = mapped_column(Date, primary_key=True)
    arena_points: Mapped[int] = mapped_column(Integer, default=0)
    guild_points: Mapped[int] = mapped_column(Integer, default=0)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True))


class GameArenaDefense(Base):
    """The player's defense team in the PvP league: up to 4 monster ids, leader first."""

    __tablename__ = "game_arena_defenses"

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id", ondelete="CASCADE"), primary_key=True
    )
    monsters: Mapped[list[int]] = mapped_column
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  î°W}“‰-tÍ JX>Éç…èÒþÂÜv<.jÌe;Š¢Ökg