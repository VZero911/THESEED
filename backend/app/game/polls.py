"""Player polls (V), recorded on-chain (contracts/src/Polls.sol, ADR 0019).

- Polls are data (content/polls.json). The first time one is listed while open, SYSTEM (the game's
  operator) opens it on-chain with the hash of its text.
- A player votes by signing an EIP-712 `Vote(pollId, option, answerHash)` (no gas); SYSTEM relays
  it, the contract checks the signature and counts one vote per player. The free answer's text
  stays here; only its hash is on-chain.
- Voting gives the poll's reward (Mana, POC, scrolls). V can veto a poll on-chain: its result is
  then shown as vetoed and never applied.
"""

import json
from dataclasses import dataclass
from datetime import datetime
from functools import lru_cache
from pathlib import Path
from typing import Any

from sqlalchemy import delete, func, select
from sqlalchemy.orm import Session
from web3 import Web3

from app.db.models import GamePoll, GamePollVote, User
from app.game import points
from app.game.content import Content, Gift
from app.game.errors import GameError
from app.game.mail import grant_rewards, send
from app.game.operator import GameOperator, OperatorError

_FILE = Path(__file__).parent / "content" / "polls.json"
VOTE_TYPES = {
    "Vote": [
        {"name": "pollId", "type": "uint256"},
        {"name": "voter", "type": "address"},
        {"name": "option", "type": "uint8"},
        {"name": "answerHash", "type": "bytes32"},
        {"name": "deadline", "type": "uint256"},
    ]
}
VOTE_VALIDITY_SECONDS = 3600  # how long a signed vote stays valid: the relayer cannot hold it back
ZERO_HASH = "0x" + "00" * 32


@dataclass(frozen=True)
class PollDef:
    key: str
    question: str
    options: tuple[str, ...]
    free_answer: bool
    starts_at: datetime
    ends_at: datetime
    reward: dict[str, Any]  # the base reward, before the impact multiplier
    chain_change: str = "none"
    chain_contracts: tuple[str, ...] = ()
    chain_note: str = ""
    follow_up: dict[str, Any] | None = None

    def multiplier(self) -> float:
        """How much the poll's chain impact scales its rewards (bigger change, bigger reward)."""
        return load_rules().impact_multipliers[self.chain_change]

    def effective_reward(self) -> dict[str, Any]:
        """The vote reward adapted to the estimated impact on the blockchain."""
        return scale_reward(self.reward, self.multiplier())

    def content_hash(self) -> bytes:
        """keccak256 of the poll's text, as stored on-chain."""
        text = json.dumps(
            {"question": self.question, "options": list(self.options)},
            ensure_ascii=False,
            sort_keys=True,
            separators=(",", ":"),
        )
        return bytes(Web3.keccak(text=text))

    def running(self, now: datetime) -> bool:
        return self.starts_at <= now < self.ends_at


@dataclass(frozen=True)
class PollRules:
    impact_multipliers: dict[str, float]
    follow_up_levels: dict[str, float]


@lru_cache
def load_rules() -> PollRules:
    raw = json.loads(_FILE.read_text(encoding="utf-8"))
    return PollRules(
        impact_multipliers={k: float(v) for k, v in raw["impact_multipliers"].items()},
        follow_up_levels={k: float(v) for k, v in raw["follow_up_levels"].items()},
    )


def scale_reward(reward: dict[str, Any], factor: float) -> dict[str, Any]:
    """A reward times `factor`: amounts round half up, a present item never drops below 1."""

    def scaled(n: int) -> int:
        return max(1, int(n * factor + 0.5))

    out: dict[str, Any] = {}
    for key, value in reward.items():
        if key == "items" and isinstance(value, dict):
            out["items"] = {item: scaled(int(q)) for item, q in value.items()}
        elif isinstance(value, int) and not isinstance(value, bool):
            out[key] = scaled(value)
        else:
            out[key] = value
    return out


@lru_cache
def load_polls() -> tuple[PollDef, ...]:
    raw = json.loads(_FILE.read_text(encoding="utf-8"))["polls"]
    polls = []
    rules = load_rules()
    for p in raw:
        if not 2 <= len(p["options"]) <= 16:
            raise ValueError(f"poll {p['key']}: 2 to 16 options")
        change = p.get("chain", {}).get("change", "none")
        if change not in rules.impact_multipliers:
            raise ValueError(f"poll {p['key']}: unknown chain change {change}")
        polls.append(
            PollDef(
                key=p["key"],
                question=p["question"],
                options=tuple(p["options"]),
                free_answer=bool(p.get("free_answer", False)),
                starts_at=datetime.fromisoformat(p["starts_at"]),
                ends_at=datetime.fromisoformat(p["ends_at"]),
                reward=p.get("reward", {}),
                chain_change=change,
                chain_contracts=tuple(p.get("chain", {}).get("contracts", [])),
                chain_note=p.get("chain", {}).get("note", ""),
                follow_up=p.get("follow_up"),
            )
        )
    return tuple(polls)


def poll_option_counts(session: Session, poll: PollDef) -> list[int]:
    """The votes counted here for each option of a poll, in the options' order."""
    counts = dict(
        session.execute(
            select(GamePollVote.option, func.count())
            .where(GamePollVote.poll_key == poll.key)
            .group_by(GamePollVote.option)
        ).all()
    )
    return [int(counts.get(i, 0)) for i in range(len(poll.options))]


def answer_hash(answer: str | None) -> str:
    return ZERO_HASH if not answer else "0x" + bytes(Web3.keccak(text=answer.strip())).hex()


def _definition(key: str) -> PollDef:
    poll = next((p for p in load_polls() if p.key == key), None)
    if poll is None:
        raise GameError("unknown_poll", 404)
    return poll


def _on_chain(
    session: Session, operator: GameOperator, poll: PollDef, chain_id: int, now: datetime
) -> GamePoll:
    """The on-chain poll, opened by SYSTEM the first time it is needed."""
    row = session.get(GamePoll, poll.key, with_for_update=True)
    contract = operator.polls_address()
    if row is not None and row.chain_id == chain_id and row.contract == contract:
        return row
    if row is not None:  # a new deployment: the old votes belong to a contract that is gone
        session.execute(delete(GamePollVote).where(GamePollVote.poll_key == poll.key))
    poll_id, tx = operator.create_poll(
        poll.content_hash(),
        len(poll.options),
        poll.free_answer,
        int(poll.starts_at.timestamp()),
        int(poll.ends_at.timestamp()),
    )
    if row is None:
        row = GamePoll(
            key=poll.key, created_at=now, chain_id=chain_id, poll_id=0, content_hash="", tx=""
        )
        session.add(row)
    row.chain_id, row.poll_id, row.tx, row.contract = chain_id, poll_id, tx, contract
    row.content_hash = "0x" + poll.content_hash().hex()
    session.flush()
    return row


def _address(operator: GameOperator) -> str | None:
    try:
        return operator.polls_address()
    except OperatorError:
        return None


def polls_view(
    session: Session, user: User, operator: GameOperator | None, chain_id: int, now: datetime
) -> list[dict[str, Any]]:
    defs = load_polls()
    keys = [p.key for p in defs]
    # One query each for every poll (rows, tallies, the player's votes), not three per poll.
    rows = {r.key: r for r in session.scalars(select(GamePoll).where(GamePoll.key.in_(keys)))}
    tallies: dict[str, dict[int, int]] = {}
    for key, option, n in session.execute(
        select(GamePollVote.poll_key, GamePollVote.option, func.count())
        .where(GamePollVote.poll_key.in_(keys))
        .group_by(GamePollVote.poll_key, GamePollVote.option)
    ):
        tallies.setdefault(key, {})[option] = n
    votes = {
        v.poll_key: v
        for v in session.scalars(
            select(GamePollVote).where(
                GamePollVote.poll_key.in_(keys), GamePollVote.user_id == user.id
            )
        )
    }
    out = []
    for poll in defs:
 
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  >ÃŽDn€å“©[ŠËˆ\8Ò-/ÔXä­<‹ÞTþè)6