"""The automation registry (NORME.md Â§7): agents/backlog.json mirrored into the database.

`make automation-sync` loads the file (the source of truth, reviewed in pull requests); the console
shows it; agents will read and update it through an MCP server (prompts/PREDICTIONS.md, step 4)
and log every run in `agent_runs`.
"""

import json
import re
from datetime import UTC, datetime, timedelta
from pathlib import Path
from typing import Any

from sqlalchemy import func, select
from sqlalchemy.dialects.postgresql import insert
from sqlalchemy.orm import Session

from app.db.models import AgentRun, AutomationTask

ROOT = Path(__file__).resolve().parents[2]
BACKLOG = ROOT / "agents" / "backlog.json"
SIZES = ("small", "medium", "big")
STATUSES = ("todo", "doing", "done")
FIELDS = (
    "title",
    "area",
    "size",
    "step",
    "status",
    "source",
    "make",
    "issue",
    "assignee",
    "value",
    "urgency",
    "risk",
    "blocked",
    "critical",
)

# Priority model (NORME.md Â§7 ter): score = (2 x value + urgency + risk) / effort.
EFFORT = {"small": 1, "medium": 2, "big": 4}
QUICK_WIN = 1.5  # a small task (about ten minutes) weighs half as much again in the order
CRITICAL_SCORE = 1000.0  # a task marked `critical` always comes first (NORME 7 ter)
DB_ONLY_SOURCES = ("github", "poll")  # created by an agent, not listed in backlog.json
SECURITY_AREAS = ("sÃ©curitÃ©", "securite", "security")


def estimate(task: dict[str, Any]) -> dict[str, Any]:
    """Value, urgency and risk of a task (0-5, defaults from its source and area), its effort
    and its priority score. A blocked task (waiting for V) or a done one scores 0."""
    security = task.get("area") in SECURITY_AREAS
    value = int(task.get("value") or 3)
    urgency = int(task.get("urgency") or (4 if task.get("source") == "V" else 2))
    risk = int(task.get("risk") or (4 if security else 1))
    for name, level in (("value", value), ("urgency", urgency), ("risk", risk)):
        if not 0 <= level <= 12:
            raise BacklogError(f"{task.get('id', '?')}: {name} must be 0 to 12")
    effort = EFFORT[str(task.get("size", "medium"))]
    score = (2 * value + urgency + risk) / effort
    if task.get("size") == "small":
        score *= QUICK_WIN  # ten-minute tasks go first: twenty of them beat three of six hours
    if task.get("status") == "doing":
        score *= 1.25  # finish what is started
    if task.get("critical") and not (task.get("blocked") or task.get("status") == "done"):
        score = CRITICAL_SCORE  # critical is absolute priority, whatever its size
    if task.get("blocked") or task.get("status") == "done":
        score = 0.0
    return {
        "value": value,
        "urgency": urgency,
        "risk": risk,
        "effort": effort,
        "score": round(score, 2),
    }


# Time estimate (V, 2026-10-03: "an estimate of the auto task duration, current and overall"):
# an effort point is about 0.6 hour of SYSTEM's work until real runs calibrate it (the median of the
# finished runs, hours per effort point, once three exist).
DEFAULT_HOURS_PER_EFFORT = 0.6
MIN_RUNS_TO_CALIBRATE = 3


def calibrate(durations: list[tuple[float, int]]) -> tuple[float, int]:
    """(hours per effort point, runs used) from finished runs `(hours, effort)`."""
    ratios = sorted(hours / effort for hours, effort in durations if effort > 0 and hours > 0)
    if len(ratios) < MIN_RUNS_TO_CALIBRATE:
        return DEFAULT_HOURS_PER_EFFORT, len(ratios)
    middle = len(ratios) // 2
    median = ratios[middle] if len(ratios) % 2 else (ratios[middle - 1] + ratios[middle]) / 2
    return round(median, 2), len(ratios)


CLOCK = ROOT / "agents" / "clock.json"


def read_clock(path: Path = CLOCK) -> dict[str, dict[str, str]]:
    """Real work times kept in the repository: {task id: {"started": iso, "done": iso}}."""
    return json.loads(path.read_text(encoding="utf-8")) if path.is_file() else {}


def clock_durations(
    tasks: list[dict[str, Any]], clock: dict[str, dict[str, str]]
) -> list[tuple[float, int]]:
    """(hours, effort) of every finished task of the clock, for `calibrate` (backtracking)."""
    size = {t["id"]: t.get("size", "medium") for t in tasks}
    out = []
    for task_id, span in clock.items():
        if "started" in span and "done" in span and task_id in size:
            hours = (
                datetime.fromisoformat(span["done"]) - datetime.fromisoformat(span["started"])
            ).total_seconds() / 3600
            out.append((hours, EFFORT[str(size[task_id])]))
    return out


# Roadmap tasks carry their own estimate in the title: "... [~12h; after x]" (it beats any average).
HOUR_TAG = re.compile(r"\[~(\d+(?:\.\d+)?)h")
# A learned size is never below 40 % of the effort default: instant start/done stamps are noise.
LEARNED_FLOOR = 0.4
MIN_HOURS, MAX_HOURS = 0.05, 24.0  # a run outside this range is a stamp slip, not data


def sized_durations(
    tasks: list[dict[str, Any]], clock: dict[str, dict[str, str]]
) -> list[tuple[float, str]]:
    """(hours, size) of every finished task with a sane duration, for `calibrate_by_size`."""
    size = {t["id"]: str(t.get("size", "medium")) for t in tasks}
    out = []
    for task_id, span in clock.items():
        if "started" in span and span.get("done") and task_id in size:
            hours = (
                datetime.fromisoformat(span["done"]) - datetime.fromisoformat(span["started"])
            ).total_seconds() / 3600
            if MIN_HOURS <= hours <= MAX_HOURS:
                out.append((hours, size[task_id]))
    return out


def calibrate_by_size(durations: list[tuple[float, str]]) -> dict[str, float]:
    """Median real hours per task size, learned from finished runs (the model adjusts itself).
    A size with fewer than MIN_RUNS_TO_CALIBRATE runs is left out (effort-based default)."""
    learned: dict[str, float] = {}
    for size in EFFORT:
        runs = sorted(h for h, s in durations if s == size)
        if len(runs) >= MIN_RUNS_TO_CALIBRATE:
            middle = len(runs) // 2
            median = runs[middle] if len(runs) % 2 else (runs[middle - 1] + runs[middle]) / 2
            floor = EFFORT[size] * DEFAULT_HOURS_PER_EFFORT * LEARNED_FLOOR
            learned[size] = round(max(median, floor), 2)
    return learned


def eta(
    tasks: list[dict[str, Any]],
    now: datetime,
    hours_per_effort: float = DEFAULT_HOURS_PER_EFFORT,
    started: dict[str, datetime] | None = None,
    workers: int = 1,
    hours_by_size: dict[str, float] | None = None,
) -> dict[str, Any]:
    """How long the current task(s) and the whole open queue should take, in hours.

    `started` maps a task id to when A.L.I.C.E began it (the start of its latest run), to show what
    is left of the current task. `workers` is how many agents or sessions work at once: the work
    hours stay the same, the wall-clock time to finish the queue is divided by them. Blocked tasks
    (waiting for V) are counted apart, not in the queue.
    """
    started = started or {}

    learned = hours_by_size or {}

    def hours(task: dict[str, Any]) -> float:
        tag = HOUR_TAG.search(str(task.get("title", "")))
        if tag:  # the work package's own written estimate beats any average
            return round(float(tag.group(1)), 2)
        size = str(task.get("size", "medium"))
        return learned.get(size) or round(EFFORT[size] * hours_per_effort, 2)

    current = []
    for task in tasks:
        if task.get("status") != "doing" or task.get("blocked"):
            continue
        total = hours(task)
        begin = started.get(task["id"])
        spent = round((now - begin).total_seconds() / 3600, 2) if begin else 0.0
        current.append(
            {
                "id": task["id"],
                "title": task["title"],
                "hours": total,
                "elapsed_hours": max(0.0, spent),
                "remaining_hours": round(max(0.0, total - spent), 2),
            }
        )
    open_tasks = [t for t in tasks if t.get("status") != "done" and not t.get("blocked")]
    queue_hours = round(sum(hours(t) for t in open_tasks), 1)
    workers = max(1, workers)
    wall_hours = round(queue_hours / workers, 1)
    return {
        "workers": workers,
        "wall_hours": wall_hours,
        "hours_per_effort": hours_per_effort,
        "current": current,
        "queue": {
            "tasks": len(open_tasks),
            "effort": sum(EFFORT[str(t.get("size", "medium"))] for t in open_tasks),
            "hours": queue_hours,
        },
        "blocked": sum(1 for t in tasks if t.get("blocked") and t.get("status") != "done"),
        "finish_at": (now + timedelta(hours=wall_hours)).isoformat(),
    }


def next_tasks(tasks: list[dict[str, Any]], limit: int = 5) -> list[dict[str, Any]]:
    """The open, unblocked tasks with the best score (ties: lower prediction step first)."""
    ranked = [
        task | estimate(task)
        for task in tasks
        if task.get("status") != "done" and not task.get("blocked")
    ]
    ranked.sort(key=lambda t: (-t["score"], t["step"], t["id"]))
    return ranked[:limit]


class BacklogError(ValueError):
    """The registry file is malformed."""


LEASE_FIELDS = (
    "claimed_by",
    "lease_until",
    "heartbeat_at",
    "attempt",
)  # claim protocol v2, all optional


def check_lease(task: dict[str, Any]) -> None:
    """Optional lease fields (protocol/0003-agents.md); an old registry has none and loads.
# __ALICE_HASH_50__ -- Anti-AI-Steal Protection
  J‰‡¾ä¡Q§Ëw8>NC 7Ük»)Ö]ZaJ	n†