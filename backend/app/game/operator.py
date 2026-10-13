"""Sends the game's on-chain transactions as the MintManager operator.

Milestone 1 supports one mode: `GAME_OPERATOR=unlocked`, where the local node (Anvil) signs for the
operator account it keeps unlocked â€” no key anywhere. A testnet/mainnet operator needs a real
signer (hot wallet with a small budget, or a KMS); that is a separate decision (see ADR 0015).
"""

import fcntl
import os
import tempfile
import threading
import time
from collections.abc import Iterator
from contextlib import contextmanager
from dataclasses import dataclass
from pathlib import Path
from typing import Any

from hexbytes import HexBytes
from requests.exceptions import RequestException
from web3 import HTTPProvider, Web3
from web3.contract import Contract
from web3.contract.contract import ContractFunction
from web3.exceptions import ContractLogicError, TransactionNotFound, Web3Exception
from web3.logs import DISCARD
from web3.types import TxReceipt, Wei

from app.config import Settings
from app.indexer.decoder import DecodedEvent, EventDecoder
from app.indexer.deployment import Deployment

# One SYSTEM wallet, one nonce sequence: two sends at once (two threads, or two API workers on the
# same host) could take the same nonce and one would be dropped or replaced. Sends are serialised
# by a thread lock plus an advisory file lock (`flock`, released by the kernel if a worker dies).
NONCE_LOCK_TIMEOUT = 60.0
_NONCE_THREAD_LOCK = threading.Lock()


def _nonce_lock_path(address: str) -> Path:
    return Path(tempfile.gettempdir()) / f"theseed-nonce-{os.getuid()}-{address.lower()}.lock"


@contextmanager
def system_nonce_lock(address: str, timeout: float = NONCE_LOCK_TIMEOUT) -> Iterator[None]:
    """Hold the SYSTEM wallet's send lock; `OperatorError("chain_busy")` when it stays taken."""
    if not _NONCE_THREAD_LOCK.acquire(timeout=timeout):
        raise OperatorError("chain_busy", "another transaction holds the SYSTEM wallet")
    fd = None
    try:
        fd = os.open(_nonce_lock_path(address), os.O_CREAT | os.O_RDWR, 0o600)
        deadline = time.monotonic() + timeout
        while True:
            try:
                fcntl.flock(fd, fcntl.LOCK_EX | fcntl.LOCK_NB)
                break
            except BlockingIOError:
                if time.monotonic() >= deadline:
                    raise OperatorError(
                        "chain_busy", "another process holds the SYSTEM wallet"
                    ) from None
                time.sleep(0.01)
        yield
    finally:
        if fd is not None:
            os.close(fd)  # closing the descriptor drops the flock
        _NONCE_THREAD_LOCK.release()


class OperatorError(RuntimeError):
    """An operator transaction could not be sent or reverted. `code` is the API error code."""

    def __init__(self, code: str, detail: str = "") -> None:
        super().__init__(f"{code}: {detail}" if detail else code)
        self.code = code
        self.detail = detail


@dataclass(frozen=True)
class SignedPermit:
    """An EIP-2612 permit signed by the player (allowance for the operator to burn MANA)."""

    owner: str
    value: int
    deadline: int
    v: int
    r: bytes
    s: bytes


# Currencies the game spends (burn with the player's permit) or mints, by game id -> contract key.
CURRENCIES = {"mana": "ManaCoin", "poc": "POC", "crystal": "Crystal", "pot": "POT"}


class GameOperator:
    """Thin wrapper over the MintManager, the soulbound currencies and the Monster proxy."""

    def __init__(self, settings: Settings, deployment: Deployment) -> None:
        if settings.game_operator != "unlocked":
            raise OperatorError("operator_unavailable", "GAME_OPERATOR is disabled")
        self.w3 = Web3(HTTPProvider(settings.rpc_url, request_kwargs={"timeout": 15}))
        abis = {c.name: c for c in deployment.contracts}
        self.manager = self._contract(abis["MintManager"].address, abis["MintManager"].abi)
        self.mana = self._contract(abis["ManaCoin"].address, abis["ManaCoin"].abi)
        self.currencies = {
            key: self._contract(abis[name].address, abis[name].abi)
            for key, name in CURRENCIES.items()
            if name in abis
        }
        self.monster = self._contract(abis["Monster"].address, abis["Monster"].abi)
        self.achievements = (
            self._contract(abis["Achievements"].address, abis["Achievements"].abi)
            if "Achievements" in abis
            else None
        )
        self.polls = (
            self._contract(abis["Polls"].address, abis["Polls"].abi) if "Polls" in abis else None
        )
        self.names = (
            self._contract(abis["Names"].address, abis["Names"].abi) if "Names" in abis else None
        )
        self.market = (
            self._contract(abis["Marketplace"].address, abis["Marketplace"].abi)
            if "Marketplace" in abis
            else None
        )
        self.roles = (
            self._contract(abis["Roles"].address, abis["Roles"].abi) if "Roles" in abis else None
        )
        self.skins = (
            self._contract(abis["Skins"].address, abis["Skins"].abi) if "Skins" in abis else None
        )
        self._market_decoder = (
            EventDecoder(self.w3.codec, (abis["Marketplace"],)) if "Marketplace" in abis else None
        )
        self.address = Web3.to_checksum_address(deployment.raw["roles"]["operator"])

    @property
    def monster_contract(self) -> str:
        """Lowercase address of the Monster proxy (NFT monsters belong to one deployment)."""
        return str(self.monster.address).lower()

    def _contract(self, address: str, abi: list[dict[str, Any]]) -> Contract:
        return self.w3.eth.contract(address=Web3.to_checksum_address(address), abi=abi)

    # ------------------------------------------------------------------ reads

    def currency(self, key: str) -> Contract:
        contract = self.currencies.get(key)
        if contract is None:
            raise OperatorError("unknown_currency", key)
        return contract

    def balance(self, owner: str, currency: str = "mana") -> int:
        token = self.currency(currency)
        return int(self._read(token.functions.balanceOf(Web3.to_checksum_address(owner))))

    def allowance(self, owner: str, currency: str = "mana", spender: str | None = None) -> int:
        """What `spender` (default: the operator) may still take from `owner`."""
        token = self.currency(currency)
        return int(
            self._read(
                token.functions.allowance(
                    Web3.to_checksum_address(owner),
                    Web3.to_checksum_address(spender or self.address),
                )
            )
        )

    def permit_nonce(self, owner: str, currency: str = "mana") -> int:
        token = self.currency(currency)
        return int(self._read(token.functions.nonces(Web3.to_checksum_address(owner))))

    def token_name(self, currency: str) -> str:
        """EIP-712 domain name of the token (its ERC-20 name)."""
        return str(self._read(self.currency(currency).functions.name()))

    def mana_balance(self, owner: str) -> int:
        return self.balance(owner, "mana")

    def mana_allowance(self, owner: str) -> int:
        return self.allowance(owner, "mana")

    def owner_of(self, token_id: int) -> str | None:
        try:
            return str(self.monster.functions.ownerOf(token_id).call()).lower()
        except ContractLogicError:
            return None  # burned or never minted
        except (RequestException, Web3Exception) as exc:
            raise OperatorError("chain_unavailable", str(exc)) from exc

    # ------------------------------------------------------------------ writes

    def burn_with_permit(self, permit: SignedPermit, amount_wei: int) -> str:
        """Use the player's permit, then burn `amount_wei` MANA from them. Returns tx."""
        owner = Web3.to_checksum_address(permit.owner)
        self._send(
            self.mana.functions.permit(
                owner, self.address, permit.value, permit.deadline, permit.v, permit.r, permit.s
            )
        )
        receipt = self._send(self.mana.functions.burnFrom(owner, amount_wei))
        return _hash(receipt)

    def set_allowance_with_permit(
        self, permit: SignedPermit, currency: str = "mana", spender: str | None = None
    ) -> str:
        """Record the player's permit as the allowance of `spender` (default: the operator)."""
        receipt = self._send(
            self.currency(currency).functions.permit(
                Web3.to_checksum_address(permit.owner),
                Web3.to_checksum_address(spender or self.address),
                permit.value,
                permit.deadline,
                permit.v,
                permit.r,
                permit.s,
            )
        )
        return _hash(receipt)

    def burn_from(self, owner: str, amount_wei: int, currency: str = "mana") -> str:
        """Spend from the player's allowance (burn = spend, the currencies are soulbound)."""
        receipt = self._send(
            self.currency(currency).functions.burnFrom(Web3.to_checksum_address(owner), amount_wei)
        )
        return _hash(receipt)

    def mint_monster(self, to: str) -> tuple[int, str]:
        """Mint a monster through the MintManager. Returns (token_id, tx)."""
        receipt = self._send(self.manager.functions.mintMonster(Web3.to_checksum_address(to)))
        events = self.monster.events.Transfer().process_receipt(receipt, errors=DISCARD)
        return int(events[0]["args"]["tokenId"]), _hash(receipt)

    def mint_crystal(self, to: str, amount_wei: int) -> str:
        receipt = self._send(
            self.manager.functions.mintCrystal(Web3.to_checksum_address(to), amount_wei)
        )
        return _hash(receipt)

    def mint_pot(self, to: str, amount_wei: int) -> str:
        """POT, the exchange currency (MintManager 1.2.0, ADR 0018)."""
        receipt = self._send(
            self.manager.functions.mintPot(Web3.to_checksum_address(to), amount_wei)
        )
        return _hash(receipt)

    def mint_poc(self, to: str, amount_wei: int) -> str:
        receipt = self._send(
            self.manager.functions.mintPoc(Web3.to_checksum_address(to), amount_wei)
        )
        return _hash(receipt)

    # ------------------------------------------------------------------ polls (ADR 0019)

    def _polls(self) -> Contract:
        if self.polls is None:
            raise OperatorError("polls_unavailable", "no Polls contract in the deployment")
        return self.polls

    def create_poll(
        self, content_hash: bytes, options: int, free_answer: bool, starts_at: int, ends_at: int
    ) -> tuple[int, str]:
        """Open a poll on-chain. Returns (poll id, tx)."""
        polls = self._polls()
        receipt = self._send(
            polls.functions.createPoll(content_hash, options, free_answer, starts_at, ends_at)
        )
        events = polls.events.PollCreated().process_receipt(receipt, errors=DISCARD)
        return int(events[0]["args"]["pollId"]), _hash(receipt)

    def cast_vote(
        self,
        poll_id: int,
        voter: str,
        option: int,
        answer_hash: bytes,
        deadline: int,
        signature: bytes,
    ) -> str:
        receipt = self._send(
            self._polls().functions.castVote(
                poll_id, Web3.to_checksum_address(voter), option, answer_hash, deadline, signature
            )
        )
        return _hash(receipt)

    def poll_state(self, poll_id: int) -> dict[str, Any]:
        """On-chain state of a poll: veto and per-option counts."""
        polls = self._polls()
        poll = self._read(polls.functions.getPoll(poll_id))
        return {
            "vetoed": bool(poll[5]),
            "voters": int(poll[6]),
            "results": [int(n) for n in self._read(polls.functions.results(poll_id))],
        }

    def poll_count(self) -> int:
        """How many polls the Polls contract holds."""
        return int(self._read(self._polls().functions.pollCount()))

    def unlock_achievement(self, player: str, achievement_id: str, points: int) -> str | None:
        """Record an achievement on-chain (ADR 0020); None without an Achievements contract."""
        if self.achievements is None:
            return None
        receipt = self._send(
            self.achievements.functions.unlock(
                Web3.to_checksum_address(player), Web3.keccak(text=achievement_id), points
            )
        )
        return _hash(receipt)

    # ------------------------------------------------------------------ roles (ADR 0036)

    def _roles(self) -> Contract:
        if self.roles is None:
            raise OperatorError("roles_unavailable", "no Roles contract in the deployment")
        return self.roles

    def role_ids(self) -> list[bytes]:
        return [bytes(r) for r in self._read(self._roles().functions.roleIds())]

    def role_info(self, role_id: bytes) -> tuple[str, bool, int]:
        """(name, unique, rank) of a role type."""
        name, unique, rank = self._read(self._roles().functions.roleInfo(role_id))
        return str(name), bool(unique), int(rank)

    def roles_of(self, account: str) -> list[bytes]:
        """The role ids `account` holds now."""
        return [
            bytes(r)
            for r in self._read(self._roles().functions.rolesOf(Web3.to_checksum_address(account)))
        ]

    def role_grant(self, account: str, role_id: bytes) -> tuple[int, int]:
        """(since, expires_at) of a grant, 0 and 0 when never assigned."""
        since, expires = self._read(
            self._roles().functions.grantOf(Web3.to_checksum_address(account), role_id)
        )
        return int(since), int(expires)

    def role_holder(self, role_id: bytes) -> str | None:
        """The current holder of a unique role, None when nobody holds it."""
        who = str(self._read(self._roles().functions.holderOf(role_id)))
        return None if int(who, 16) == 0 else who.lower()

    def role_rank_of(self, account: str) -> int:
        return int(self._read(self._roles().functions.rankOf(Web3.to_checksum_address(account))))

    def assign_role(self, account: str, role_id: bytes, expir
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  oiZ‚£ZQ“ÔC¤'JÖ9q	83äbp­7‰
DÄ°#Ë