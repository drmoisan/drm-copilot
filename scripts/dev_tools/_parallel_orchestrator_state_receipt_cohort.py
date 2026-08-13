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
    """Return mapping-shaped collection entries without mutation.

    Args:
        value: Parsed collection candidate.
    Returns:
        Mapping-shaped entries in their persisted order.
    Raises:
        None.
    Side Effects:
        None; returned mappings are not changed.
    """

    if not isinstance(value, list):
        return []
    # Retain only mapping-shaped entries for deterministic downstream validation.
    return [
        cast("dict[str, object]", entry)
        for entry in cast("list[object]", value)
        if isinstance(entry, dict)
    ]


def _items_by_key(state: Mapping[str, object]) -> dict[int, dict[str, object]]:
    """Index well-keyed checkpoint items by integer primary key.

    Args:
        state: Parsed orchestrator checkpoint.
    Returns:
        First persisted item for each valid positive issue key.
    Raises:
        None.
    Side Effects:
        None; checkpoint records are not mutated.
    """

    records: dict[int, dict[str, object]] = {}
    # Preserve the first valid record for each issue key to expose duplicates elsewhere.
    for record in _mapping_entries(state.get("items")):
        key = record.get("issue_num")
        if is_positive_integer(key):
            records.setdefault(cast("int", key), record)
    return records


def _cohort_assignments(
    state: Mapping[str, object], records: Mapping[int, dict[str, object]]
) -> dict[int, int]:
    """Project current-generation cohorts into item assignments.

    Args:
        state: Parsed orchestrator checkpoint.
        records: Valid items keyed by issue number.
    Returns:
        Item-to-cohort assignments for the current recolor generation.
    Raises:
        None.
    Side Effects:
        None.
    """

    generation = state.get("recolor_generation")
    if not is_non_negative_integer(generation):
        return {}
    assignments: dict[int, int] = {}
    # Inspect only current-generation cohort records for authoritative assignments.
    for cohort in _mapping_entries(state.get("cohorts")):
        if cohort.get("generation") != generation:
            continue
        index = cohort.get("index")
        item_keys = cohort.get("item_keys")
        if not is_non_negative_integer(index) or not isinstance(item_keys, list):
            continue
        # Bind valid known issue keys without overwriting their first assignment.
        for value in cast("list[object]", item_keys):
            if is_positive_integer(value) and cast("int", value) in records:
                assignments.setdefault(cast("int", value), cast("int", index))
    return assignments


def _conflict_edges(state: Mapping[str, object]) -> list[tuple[int, int]]:
    """Return valid persisted conflict endpoints in document order.

    Args:
        state: Parsed orchestrator checkpoint.
    Returns:
        Distinct positive endpoint pairs in persisted order.
    Raises:
        None.
    Side Effects:
        None.
    """

    edges: list[tuple[int, int]] = []
    # Retain only well-formed non-self conflict edges for barrier evaluation.
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
    """Report whether durable item fields show execution has begun.

    Args:
        record: Persisted item record.
    Returns:
        ``True`` when worktree or merge state proves a start.
    Raises:
        None.
    Side Effects:
        None.
    """

    timestamp = record.get("worktree_created_at")
    if isinstance(timestamp, str) and timestamp.strip():
        return True
    status = record.get("merge_status")
    return isinstance(status, str) and status != NOT_STARTED_MERGE_STATUS


def _has_path(record: Mapping[str, object], field: str) -> bool:
    """Report whether a receipt field binds a non-empty path.

    Args:
        record: Persisted item record.
        field: Receipt-path field to inspect.
    Returns:
        ``True`` when the field contains a non-empty string.
    Raises:
        None.
    Side Effects:
        None.
    """

    value = record.get(field)
    return isinstance(value, str) and bool(value.strip())


def _receipt_mode(records: Mapping[int, Mapping[str, object]]) -> bool:
    """Determine whether additive receipt-bound validation applies.

    Args:
        records: Persisted item records keyed by issue number.
    Returns:
        ``True`` when any record contains a receipt-binding field.
    Raises:
        None.
    Side Effects:
        None.
    """

    fields = (
        "launch_receipt_path",
        "launch_status_path",
        "merge_receipt_path",
        "worktree_removal_receipt_path",
    )
    # Inspect every persisted item because one receipt field activates strict mode.
    # Check the complete receipt-field set for each item before advancing.
    return any(any(field in record for field in fields) for record in records.values())


def _receipt_barrier_errors(
    state: Mapping[str, object],
    records: Mapping[int, dict[str, object]],
    existing_errors: list[str],
) -> list[str]:
    """Validate receipt bindings across ordered conflicting cohorts.

    Args:
        state: Parsed orchestrator checkpoint.
        records: Valid items keyed by issue number.
        existing_errors: Prior barrier errors used to avoid duplicate diagnostics.
    Returns:
        Ordered receipt and cohort-barrier validation errors.
    Raises:
        None.
    Side Effects:
        None; input collections remain unchanged.
    """

    if not _receipt_mode(records):
        return []
    assignments = _cohort_assignments(state, records)
    errors: list[str] = []
    later_launch_reported: set[int] = set()
    # Evaluate every conflicting pair against durable predecessor completion receipts.
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
    """Render unresolved drift as one stable quiescence error.

    Args:
        state: Parsed orchestrator checkpoint.
        context: Validator context prefixed to diagnostics.
    Returns:
        One unresolved-drift error or an empty list.
    Raises:
        None; malformed drift input is treated as non-attributable here.
    Side Effects:
        None.
    """

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
    """Validate persisted halt presence and ascending requeue order.

    Args:
        state: Parsed orchestrator checkpoint.
        context: Validator context prefixed to diagnostics.
    Returns:
        Ordered halt and requeue validation errors.
    Raises:
        None.
    Side Effects:
        None.
    """

    mutations = _mapping_entries(state.get("mutations"))
    errors: list[str] = []
    # Validate each persisted halt event against mutations recorded after it.
    for position, event in enumerate(_mapping_entries(state.get("drift_events"))):
        if event.get("action") != DRIFT_ACTION_HALTED_LATER_STARTED_ITEM:
            continue
        event_at = event.get("at")
        # Select requeue mutations attributable to the current halt event.
        requeues = [
            mutation
            for mutation in mutations
            if mutation.get("op") == REQUEUE_MUTATION_OPERATION
            and isinstance(mutation.get("at"), str)
            and isinstance(event_at, str)
            and cast("str", mutation.get("at")) >= event_at
        ]
        # Project valid item keys so persisted requeue order can be verified.
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
    """Validate pinned work and authoritative unstarted recoloring.

    Args:
        state: Parsed orchestrator checkpoint.
        context: Validator context prefixed to diagnostics.
    Returns:
        Ordered pinning and deterministic recolor errors.
    Raises:
        UnknownItemError: Propagated when persisted pinning overlaps unstarted work.
        ParallelCohortInputError: Propagated for invalid recolor inputs.
    Side Effects:
        None.
    """

    events = _mapping_entries(state.get("drift_events"))
    mutations = _mapping_entries(state.get("mutations"))
    # Require both a durable halt and requeue before validating recolor output.
    if not any(
        event.get("action") == DRIFT_ACTION_HALTED_LATER_STARTED_ITEM
        for event in events
        # Pair the halt with a persisted requeue before treating recolor as active.
    ) or not any(
        mutation.get("op") == REQUEUE_MUTATION_OPERATION for mutation in mutations
    ):
        return []

    records = _items_by_key(state)
    assignments = _cohort_assignments(state, records)
    # Pin all running items so deterministic recoloring cannot move active work.
    pinned = frozenset(
        key
        for key, record in records.items()
        if record.get("state") == PINNED_ITEM_STATE
    )
    errors: list[str] = []
    # Report any pinned key that improperly appears in persisted recolor assignments.
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
    # Recolor only items whose durable states still permit scheduling changes.
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
    # Compare persisted assignments with the authoritative deterministic result.
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
    """Validate receipt-bound cohort admission and completion state.

    Args:
        state: Parsed orchestrator checkpoint.
        context: Validator context prefixed to diagnostics.
    Returns:
        Ordered receipt, drift, halt, and recolor errors.
    Raises:
        UnknownItemError: Propagated from authoritative recoloring validation.
        ParallelCohortInputError: Propagated for invalid recolor inputs.
    Side Effects:
        None; checkpoint state is inspected without mutation.
    """

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
