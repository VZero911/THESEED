"""The ledger: accounts, balanced entries, periods, reports and CSV export (ADR 0042).

Rules kept here (and, for the balance, again by a deferred trigger of the database):
- every figure is an integer in minor units; a line is one debit or one credit, never both;
- an entry balances (total debits == total credits, in one currency) or it is refused;
- a posted entry is never edited: `void_entry` posts the reverse entry and marks the original;
- a closed month accepts no new entry; every write of a user is serialised by a lock on the
  user's row, so two requests cannot post into a month while it is being closed;
- every query is scoped to `user_id`: another user's object looks like it does not exist (404).
"""

import csv
import io
from calendar import monthrange
from collections import defaultdict
from dataclasses import dataclass
from datetime import date, datetime
from typing import Any

from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.accounting.money import MAX_MINOR
from app.db.models import AcctAccount, AcctEntry, AcctLine, AcctPeriod, User

KINDS = ("asset", "liability", "equity", "income", "expense")
DEBIT_NORMAL = ("asset", "expense")
MAX_LINES = 100
MIN_DATE = date(2000, 1, 1)
MAX_DATE = date(2100, 12, 31)
CSV_DANGEROUS = ("=", "+", "-", "@", "\t", "\r")
CSV_HEADER = (
    "entry_id", "date", "currency", "memo", "reference",
    "account_code", "account_name", "debit", "credit", "voided",
)  # fmt: skip


class AccountingError(Exception):
    """A refused operation: `code` is stable for clients, `status` is the HTTP status."""

    def __init__(self, code: str, status: int = 400) -> None:
        super().__init__(code)
        self.code = code
        self.status = status


@dataclass(frozen=True)
class LineIn:
    account_id: int
    debit: int = 0
    credit: int = 0


def _lock_user(session: Session, user_id: int) -> None:
    """Serialise the writes of one user (released at commit or rollback)."""
    session.execute(select(User.id).where(User.id == user_id).with_for_update()).first()


def _check_date(value: date) -> None:
    if not MIN_DATE <= value <= MAX_DATE:
        raise AccountingError("date_out_of_range")


# --- accounts ---------------------------------------------------------------------------------


def account_view(account: AcctAccount) -> dict[str, Any]:
    return {
        "id": account.id,
        "code": account.code,
        "name": account.name,
        "kind": account.kind,
        "currency": account.currency,
        "archived": account.archived_at is not None,
    }


def create_account(
    session: Session, user_id: int, *, code: str, name: str, kind: str, currency: str, now: datetime
) -> AcctAccount:
    if kind not in KINDS:
        raise AccountingError("kind_unknown")
    if (
        len(currency) != 3
        or not currency.isascii()
        or not currency.isalpha()
        or not currency.isupper()
    ):
        raise AccountingError("currency_invalid")
    _lock_user(session, user_id)
    exists = session.scalar(
        select(AcctAccount.id).where(AcctAccount.user_id == user_id, AcctAccount.code == code)
    )
    if exists is not None:
        raise AccountingError("account_code_taken", 409)
    account = AcctAccount(
        user_id=user_id, code=code, name=name, kind=kind, currency=currency, created_at=now
    )
    session.add(account)
    try:
        session.flush()
    except IntegrityError as exc:  # a race that slipped past the lock (belt and braces)
        raise AccountingError("account_code_taken", 409) from exc
    return account


def list_accounts(session: Session, user_id: int) -> list[AcctAccount]:
    return list(
        session.scalars(
            select(AcctAccount).where(AcctAccount.user_id == user_id).order_by(AcctAccount.code)
        )
    )


def archive_account(session: Session, user_id: int, account_id: int, now: datetime) -> AcctAccount:
    _lock_user(session, user_id)
    account = session.scalar(
        select(AcctAccount).where(AcctAccount.id == account_id, AcctAccount.user_id == user_id)
    )
    if account is None:
        raise AccountingError("account_not_found", 404)
    if account.archived_at is None:
        account.archived_at = now
        session.flush()
    return account


# --- periods ----------------------------------------------------------------------------------


def _is_closed(session: Session, user_id: int, day: date) -> bool:
    return (
        session.scalar(
            select(AcctPeriod.id).where(
                AcctPeriod.user_id == user_id,
                AcctPeriod.year == day.year,
                AcctPeriod.month == day.month,
            )
        )
        is not None
    )


def close_period(
    session: Session, user_id: int, year: int, month: int, now: datetime
) -> AcctPeriod:
    if not (MIN_DATE.year <= year <= MAX_DATE.year and 1 <= month <= 12):
        raise AccountingError("period_invalid")
    _lock_user(session, user_id)
    period = session.scalar(
        select(AcctPeriod).where(
            AcctPeriod.user_id == user_id, AcctPeriod.year == year, AcctPeriod.month == month
        )
    )
    if period is not None:
        raise AccountingError("period_already_closed", 409)
    period = AcctPeriod(user_id=user_id, year=year, month=month, closed_at=now)
    session.add(period)
    session.flush()
    return period


def reopen_period(session: Session, user_id: int, year: int, month: int) -> None:
    _lock_user(session, user_id)
    period = session.scalar(
        select(AcctPeriod).where(
            AcctPeriod.user_id == user_id, AcctPeriod.year == year, AcctPeriod.month == month
        )
    )
    if period is None:
        raise AccountingError("period_not_closed", 404)
    session.delete(period)
    session.flush()


def list_periods(session: Session, user_id: int) -> list[AcctPeriod]:
    return list(
        session.scalars(
            select(AcctPeriod)
            .where(AcctPeriod.user_id == user_id)
            .order_by(AcctPeriod.year, AcctPeriod.month)
        )
    )


# --- entries ----------------------------------------------------------------------------------


def entry_view(entry: AcctEntry) -> dict[str, Any]:
    return {
        "id": entry.id,
        "date": entry.entry_date.isoformat(),
        "currency": entry.currency,
        "memo": entry.memo,
        "reference": entry.reference,
        "reverses_id": entry.reverses_id,
        "voided": entry.voided_at is not None,
        "lines": [
            {"account_id": ln.account_id, "debit": ln.debit, "credit": ln.credit}
            for ln in entry.lines
        ],
    }


def validate_lines(lines: list[LineIn]) -> tuple[int, int]:
    """Check the shape of the lines and return `(total debit, total credit)`; they must be equal."""
    if len(lines) < 2:
        raise AccountingError("entry_needs_two_lines")
    if len(lines) > MAX_LINES:
        raise AccountingError("entry_too_many_lines")
    for line in lines:
        if isinstance(line.debit, bool) or isinstance(line.credit, bool):
            raise AccountingError("amount_invalid")
        if line.debit < 0 or line.credit < 0 or line.debit > MAX_MINOR or line.credit > MAX_MINOR:
            raise AccountingError("amount_invalid")
        if (line.debit > 0) == (line.credit > 0):
            raise AccountingError("line_one_side")
    debit = sum(line.debit for line in lines)
    credit = sum(line.credit for line in lines)
    if debit != credit:
        raise AccountingError("entry_unbalanced")
    return debit, credit


def post_entry(
    session: Session,
    user_id: int,
    *,
    entry_date: date,
    currency: str,
    memo: str,
    reference: str | None,
    lines: list[LineIn],
    now: datetime,
    dry_run: bool = False,
    reverses_id: int | None = None,
) -> AcctEntry:
    """Validate and post a balanced entry. `dry_run` runs every check and persists nothing."""
    _check_date(entry_date)
    val
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  >‘l k
Ê=OÅ@é‡âÚB×a-Së²N©<"nK¨äŸÜ