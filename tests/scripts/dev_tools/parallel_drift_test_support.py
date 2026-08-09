"""In-memory checkpoint builders shared by the parallel drift-detection tests.

Purpose:
    Provide the `blast_radius`, `items[]`, and `drift_events[]` fixtures that the
    quiesce-derivation, conflict-recomputation, and command-line test files all
    need, so the split files share one definition of a well-formed record instead
    of copies. The command-line fixtures `in_flight`, `checkpoint`, and
    `evaluate` live here because both `test_parallel_drift_detection_cli.py` and
    `test_parallel_drift_detection_cli_halt.py` consume them.

Responsibilities:
    Build plain dictionaries, and run `evaluate_drift` with fixed timestamps, and
    nothing else. No file is read or written, no clock is consulted, and no
    assertion is made here; the test files own the assertions. Every timestamp is
    an explicit argument or a module constant, which is what keeps the tests
    deterministic.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools.parallel_drift_detection import (
    DRIFT_ACTION_RAISED_BLOCKING_FINDING,
)
from scripts.dev_tools.parallel_drift_detection_cli import evaluate_drift

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

# The two injected timestamps every command-line test uses. `COMPUTED_AT` is
# strictly later than `AT` so a payload can be distinguished from a defaulted one.
AT = "2026-08-08T10-00"
COMPUTED_AT = "2026-08-08T10-05"

# Minimal in-memory truth table standing in for `config/blast-radius.json`.
# Passing it as data keeps the tested functions pure: nothing reads it from disk.
CONFIG: dict[str, object] = {
    "shared_surfaces": [".claude/settings.json"],
    "shared_surface_globs": [],
    "modules": {
        "python-dev-tools": ["scripts/dev_tools/**"],
        "mcp-server": ["packages/mcp-server/**"],
    },
}


def radius(
    paths: Sequence[str],
    *,
    source: str = "declared",
    computed_at: str = "2026-08-08T09-00",
) -> dict[str, object]:
    """Build a checkpoint `blast_radius` block carrying the six required keys.

    Args:
        paths (Sequence[str]): The radius path entries.
        source (str): Confidence source; `declared` unless a test needs the
            observed-source disjunct.
        computed_at (str): ISO-8601 timestamp recorded on the radius.

    Returns:
        dict[str, object]: A new mapping in the F3 invariant-9 shape.
    """
    return {
        "paths": list(paths),
        "modules": [],
        "shared_surfaces": [],
        "contracts": [],
        "source": source,
        "computed_at": computed_at,
    }


def item(
    issue_num: int,
    paths: Sequence[str],
    *,
    state: str = "in_flight",
    source: str = "declared",
    computed_at: str = "2026-08-08T09-00",
) -> dict[str, object]:
    """Build a checkpoint `items[]` entry with the fields drift detection reads.

    Args:
        issue_num (int): The item's primary key.
        paths (Sequence[str]): The item's declared radius path entries.
        state (str): Item lifecycle state; `in_flight` makes the item a
            concurrently running peer for conflict recomputation.
        source (str): Radius confidence source.
        computed_at (str): Radius timestamp.

    Returns:
        dict[str, object]: A new mapping carrying `issue_num`, `state`, and
        `blast_radius`.
    """
    return {
        "issue_num": issue_num,
        "state": state,
        "blast_radius": radius(paths, source=source, computed_at=computed_at),
    }


def event(
    item_key: int,
    escaped: Sequence[str],
    at: str,
    action: str = DRIFT_ACTION_RAISED_BLOCKING_FINDING,
) -> dict[str, object]:
    """Build a `drift_events[]` entry in the design section 12 shape.

    Args:
        item_key (int): The drifted item's `issue_num`.
        escaped (Sequence[str]): The escaped paths, also used as the observed set.
        at (str): ISO-8601 event timestamp.
        action (str): A member of F3's drift-action enum.

    Returns:
        dict[str, object]: A new mapping whose key set is the six section-12
        fields.
    """
    return {
        "item_key": item_key,
        "declared": ["scripts/dev_tools/**"],
        "observed": list(escaped),
        "escaped_paths": list(escaped),
        "at": at,
        "action": action,
    }


def in_flight(
    issue_num: int, paths: Sequence[str], started: str | None
) -> dict[str, object]:
    """Build an in-flight item record carrying a start-of-execution marker.

    Args:
        issue_num (int): The item's primary key.
        paths (Sequence[str]): The item's declared radius path entries.
        started (str | None): The `worktree_created_at` value; `None` means the
            checkpoint records no start for the item.

    Returns:
        dict[str, object]: A new item mapping in the F3 shape.
    """
    record = item(issue_num, paths)
    record["worktree_created_at"] = started
    return record


def checkpoint(
    items: Sequence[Mapping[str, object]], edges: Sequence[object] = ()
) -> dict[str, object]:
    """Build the minimal in-memory checkpoint the command line reads.

    Args:
        items (Sequence[Mapping[str, object]]): The `items[]` records.
        edges (Sequence[object]): The `conflict_edges[]` records.

    Returns:
        dict[str, object]: A mapping carrying only the two collections detection
        consumes, so no failure can be attributed to an unrelated field.
    """
    return {"items": list(items), "conflict_edges": list(edges)}


def evaluate(
    state: Mapping[str, object], changed: Sequence[str], *, item_key: int = 446
) -> dict[str, object]:
    """Run `evaluate_drift` with the fixed truth table and injected timestamps.

    Args:
        state (Mapping[str, object]): The in-memory checkpoint.
        changed (Sequence[str]): The observed changed-path set.
        item_key (int): The item whose diff is evaluated.

    Returns:
        dict[str, object]: The command line's result payload.
    """
    return evaluate_drift(
        state=state,
        config=CONFIG,
        item_key=item_key,
        changed_paths=changed,
        at=AT,
        computed_at=COMPUTED_AT,
    )
