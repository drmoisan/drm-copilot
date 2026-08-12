"""Compose receipt-bound cohort admission with existing runtime authorities."""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from scripts.dev_tools._parallel_drift_shape import ParallelDriftInputError
from scripts.dev_tools._parallel_mutation_models import (
    PINNED_ITEM_STATE,
    UNSTARTED_ITEM_STATES,
)
from scripts.dev_tools._parallel_orchestrator_state_cohort_barrier import (
    VIOLATION_PREFIX as COHORT_VIOLATION_PREFIX,
)
from scripts.dev_tools._parallel_orchestrator_state_cohort_barrier import (
    validate_cohort_barrier_ordering,
)
from scripts.dev_tools._parallel_orchestrator_state_drift import validate_drift_gate
from scripts.dev_tools._parallel_state_common import (
    is_non_negative_integer,
    is_positive_integer,
)
from scripts.dev_tools.parallel_drift_detection import (
    DRIFT_ACTION_HALTED_LATER_STARTED_ITEM,
    unresolved_drift_item_keys,
)
from scripts.dev_tools.parallel_mutation_protocol import recolor_unstarted

if TYPE_CHECKING:
    from collections.abc import Mapping

RECEIPT_COHORT_VIOLATION_PREFIX = "PARALLEL_RECEIPT_COHORT_VIOLATION:"
NOT_STARTED_MERGE_STATUS = "not_started"
WORKTREE_REMOVED_MERGE_STATUS = "worktree_removed"
REQUEUE_MUTATION_OPERATION = "requeue"


def _mapping_entries(value: object) -> list[dict[str, object]]:
    """Return object-shaped JSON collection entries without mutating them."""

    if not isinstance(value, list):
        return []
    return [
        cast("dict[str, object]", entry)
        for entry in cast("list[object]", value)
        if isinstance(entry, dict)
    ]


def _items_by_key(state: Mapping[str, object]) -> dict[int, dict[str, object]]:
    """Index well-keyed checkpoint items by their integer primary key."""

    records: dict[int, dict[str, object]] = {}
    for record in _mapping_entries(state.get("items")):
        key = record.get("issue_num")
        if is_positive_integer(key):
            records.setdefault(cast("int", key), record)
    return records


def _cohort_assignments(
    state: Mapping[str, object], records: Mapping[int, dict[str, object]]
) -> dict[int, int]:
    """Project current-generation persisted cohorts into item assignments."""

    generation = state.get("recolor_generation")
    if not is_non_negative_integer(generation):
        return {}
    assignments: dict[int, int] = {}
    for cohort in _mapping_entries(state.get("cohorts")):
        if cohort.get("generation") != generation:
            continue
        index = cohort.get("index")
        item_keys = cohort.get("item_keys")
        if not is_non_negative_integer(index) or not isinstance(item_keys, list):
            continue
        for value in cast("list[object]", item_keys):
            if is_positive_integer(value) and cast("int", value) in records:
                assignments.setdefault(cast("int", value), cast("int", index))
    return assignments


def _conflict_edges(state: Mapping[str, object]) -> list[tuple[int, int]]:
    """Return valid persisted conflict endpoints in document order."""

    edges: list[tuple[int, int]] = []
    for edge in _mapping_entries(state.get("conflict_edges")):
        first = edge.get("a")
        second = edge.get("b")
        if (
            is_positive_integer(first)
            and is_positive_integer(second)
            and first != second
        ):
            edges.append((cast("int", first), cast("int", second)))
    return edges


def _has_started(record: Mapping[str, object]) -> bool:
    """Report whether durable item fields show that execution has begun."""

    timestamp = record.get("worktree_created_at")
    if isinstance(timestamp, str) and timestamp.strip():
        return True
    status = record.get("merge_status")
    return isinstance(status, str) and status != NOT_STARTED_MERGE_STATUS


def _has_path(record: Mapping[str, object], field: str) -> bool:
    """Report whether a receipt field binds a non-empty repository path."""

    value = record.get(field)
    return isinstance(value, str) and bool(value.strip())


def _receipt_mode(records: Mapping[int, Mapping[str, object]]) -> bool:
    """Preserve legacy checkpoints until an additive receipt field is present."""

    fields = (
        "launch_receipt_path",
        "launch_status_path",
        "merge_receipt_path",
        "worktree_removal_receipt_path",
    )
    return any(any(field in record for field in fields) for record in records.values())


def _receipt_barrier_errors(
    state: Mapping[str, object],
    records: Mapping[int, dict[str, object]],
    existing_errors: list[str],
) -> list[str]:
    """Validate external receipt bindings for ordered conflicting cohorts."""

    if not _receipt_mode(records):
        return []
    assignments = _cohort_assignments(state, records)
    errors: list[str] = []
    later_launch_reported: set[int] = set()
    for first, second in _conflict_edges(state):
        first_index = assignments.get(first)
        second_index = assignments.get(second)
        if first_index is None or second_index is None or first_index == second_index:
            continue
        predecessor_key, later_key = (
            (first, second) if first_index < second_index else (second, first)
        )
        predecessor = records.get(predecessor_key)
        later = records.get(later_key)
        if predecessor is None or later is None or not _has_started(later):
            continue

        if predecessor.get("merge_status") != WORKTREE_REMOVED_MERGE_STATUS:
            barrier_error = (
                f"{COHORT_VIOLATION_PREFIX}: {predecessor_key} ran concurrently "
                f"with conflicting {later_key}"
            )
            if barrier_error not in existing_errors and barrier_error not in errors:
                errors.append(barrier_error)
            errors.append(
                f"{RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item {later_key} "
                f"started before conflicting predecessor {predecessor_key} was "
                "both merged and worktree-removed."
            )
        if not (
            _has_path(predecessor, "merge_receipt_path")
            and _has_path(predecessor, "worktree_removal_receipt_path")
        ):
            errors.append(
                f"{RECEIPT_COHORT_VIOLATION_PREFIX} predecessor {predecessor_key} "
                "must bind merge_receipt_path and worktree_removal_receipt_path "
                f"before later-cohort item {later_key} admission."
            )
        if later_key not in later_launch_reported and not (
            _has_path(later, "launch_receipt_path")
            and _has_path(later, "launch_status_path")
        ):
            errors.append(
                f"{RECEIPT_COHORT_VIOLATION_PREFIX} later-cohort item {later_key} "
                "must bind launch_receipt_path and launch_status_path before "
                "admission."
            )
            later_launch_reported.add(later_key)
    return errors


def _unresolved_drift_errors(state: Mapping[str, object], context: str) -> list[str]:
    """Render the shared unresolved-drift decision as one quiescence error."""

    events = _mapping_entries(state.get("drift_events"))
    items = _mapping_entries(state.get("items"))
    try:
        unresolved = unresolved_drift_item_keys(events, items)
    except ParallelDriftInputError:
        return []
    if not unresolved:
        return []
    return [
        f"{context} unresolved drift for items {list(unresolved)!r} blocks "
        "admission and completion."
    ]


def _halt_requeue_errors(state: Mapping[str, object], context: str) -> list[str]:
    """Validate persisted halt presence and ascending requeue order."""

    mutations = _mapping_entries(state.get("mutations"))
    errors: list[str] = []
    for position, event in enumerate(_mapping_entries(state.get("drift_events"))):
        if event.get("action") != DRIFT_ACTION_HALTED_LATER_STARTED_ITEM:
            continue
        event_at = event.get("at")
        requeues = [
            mutation
            for mutation in mutations
            if mutation.get("op") == REQUEUE_MUTATION_OPERATION
            and isinstance(mutation.get("at"), str)
            and isinstance(event_at, str)
            and cast("str", mutation.get("at")) >= event_at
        ]
        keys = [
            cast("int", key)
            for mutation in requeues
            if is_positive_integer(key := mutation.get("item_key"))
        ]
        if not keys:
            errors.append(
                f"{context} drift_events[{position}] "
                "halted_later_started_item action requires a persisted requeue "
                "mutation."
            )
        elif keys != sorted(keys):
            errors.append(
                f"{context} requeue mutation item order must be ascending; "
                f"found: {keys!r}."
            )
    return errors


def _recolor_errors(state: Mapping[str, object], context: str) -> list[str]:
    """Validate pinned work and delegate unstarted recoloring to its authority."""

    events = _mapping_entries(state.get("drift_events"))
    mutations = _mapping_entries(state.get("mutations"))
    if not any(
        event.get("action") == DRIFT_ACTION_HALTED_LATER_STARTED_ITEM
        for event in events
    ) or not any(
        mutation.get("op") == REQUEUE_MUTATION_OPERATION for mutation in mutations
    ):
        return []

    records = _items_by_key(state)
    assignments = _cohort_assignments(state, records)
    pinned = frozenset(
        key
        for key, record in records.items()
        if record.get("state") == PINNED_ITEM_STATE
    )
    errors: list[str] = []
    moved_pinned = sorted(key for key in pinned if key in assignments)
    if moved_pinned:
        errors.append(
            f"{context} drift recolor must pin running items {moved_pinned!r}."
        )

    generation = state.get("recolor_generation")
    current_cohort = state.get("current_cohort")
    if (
        not is_non_negative_integer(generation)
        or cast("int", generation) == 0
        or not is_non_negative_integer(current_cohort)
    ):
        return errors
    unstarted = sorted(
        key
        for key, record in records.items()
        if record.get("state") in UNSTARTED_ITEM_STATES
    )
    expected = recolor_unstarted(
        unstarted,
        _conflict_edges(state),
        pinned,
        cast("int", generation) - 1,
        current_cohort=cast("int", current_cohort),
    )
    actual = {key: assignments[key] for key in unstarted if key in assignments}
    if expected.cohort_assignments != actual:
        errors.append(
            f"{context} recomputed cohort assignments do not match deterministic "
            "unstarted recoloring."
        )
    return errors


def validate_receipt_bound_cohort_admission(
    state: Mapping[str, object], context: str
) -> list[str]:
    """Return ordered receipt, drift, halt, and recolor validation errors."""

    state_map = cast("dict[str, object]", state)
    barrier_errors = validate_cohort_barrier_ordering(state_map)
    records = _items_by_key(state)
    receipt_bound = _receipt_mode(records)
    return [
        *barrier_errors,
        *_receipt_barrier_errors(state, records, barrier_errors),
        *(_unresolved_drift_errors(state, context) if receipt_bound else []),
        *(validate_drift_gate(state, context) if not receipt_bound else []),
        *(_halt_requeue_errors(state, context) if receipt_bound else []),
        *(_recolor_errors(state, context) if receipt_bound else []),
    ]


__all__ = [
    "RECEIPT_COHORT_VIOLATION_PREFIX",
    "validate_receipt_bound_cohort_admission",
]
