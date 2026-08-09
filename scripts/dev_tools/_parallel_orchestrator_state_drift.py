"""Layer-2 drift gate for the parallel-orchestrator checkpoint.

Purpose:
    Enforce the retrospective half of the design section 9 drift gate: an item
    whose latest ``drift_events[]`` entry is unresolved must not have progressed
    its ``merge_status``. Layer 1 is a per-call PreToolUse deterrent and can be
    bypassed; this validator is the durable backstop that a resume or completion
    workflow cannot skip.

Responsibilities:
    Compute the unresolved-drift item set and report one
    ``PARALLEL_DRIFT_GATE_VIOLATION:`` error per item whose ``merge_status`` is in
    ``PROGRESSED_MERGE_STATUSES``. Resolution semantics are IMPORTED from
    ``parallel_drift_detection.unresolved_drift_item_keys`` and are never restated
    here, so the producer and this consumer cannot disagree about what "resolved"
    means.

Check ownership (F3 versus F8):
    F3 owns every per-field shape check of invariant 18 and already runs them
    unconditionally in ``_parallel_state_records.validate_drift_events``:
    ``drift_events`` list-ness, per-entry object-ness, ``item_key`` resolution to
    an ``items[].issue_num``, ``declared`` and ``observed`` as string lists,
    ``escaped_paths`` non-empty, ``at`` non-empty, and ``action`` enum membership.
    F3 likewise owns the ``items[]`` checks this gate consumes: the
    ``merge_status`` enum (invariant 7), the state/merge-status pairing
    (invariant 8), and the ``blast_radius`` shape (invariant 9). NONE of those is
    repeated here, so one malformed field yields one error from one owner.

    F8 owns exactly two things F3 does not check. First, the gate verdict itself:
    unresolved drift versus a progressed ``merge_status``, which is behavior over
    two collections rather than the shape of either. Second, a fail-closed record
    that the gate could not run -- at most one error -- because a silently inert
    gate is precisely the failure this invariant exists to prevent. That record
    carries the imported pure function's own refusal message rather than a
    re-derived field diagnosis.

Key invariants:
    Key-gated and additive: a checkpoint with no ``drift_events`` key returns an
    empty list, so an existing checkpoint validates byte-identically. Nothing is
    ever raised, and the input is never mutated.

Message shape:
    Every error begins with the literal token ``PARALLEL_DRIFT_GATE_VIOLATION:``,
    which the feature spec fixes, followed by the caller's context prefix. This
    leads with the token rather than the context, matching the
    ``EPIC_WAVE_BARRIER_VIOLATION`` precedent in
    ``validate_epic_orchestrator_state.py``; it is a deliberate, spec-mandated
    departure from the ``Parallel checkpoint``-first convention of the other
    parallel helpers.
"""

from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, cast

from scripts.dev_tools._parallel_state_common import (
    MERGED_MERGE_STATUSES,
    is_positive_integer,
)
from scripts.dev_tools.parallel_drift_detection import (
    ParallelDriftInputError,
    unresolved_drift_item_keys,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

__all__ = [
    "GATE_VIOLATION_PREFIX",
    "PROGRESSED_MERGE_STATUSES",
    "validate_drift_gate",
]

# The literal token the feature spec assigns to this invariant.
GATE_VIOLATION_PREFIX = "PARALLEL_DRIFT_GATE_VIOLATION:"

# The merge statuses that count as progression toward merge. The two terminal
# members are reused from F3's constant rather than respelled; ``pr_open`` and
# ``ci_green`` are the two pre-terminal members the gate adds. Every member is a
# member of F3's ``VALID_MERGE_STATUS``, which a test asserts so an upstream
# rename fails loudly instead of silently weakening the gate.
PROGRESSED_MERGE_STATUSES: tuple[str, ...] = (
    "pr_open",
    "ci_green",
    *MERGED_MERGE_STATUSES,
)


def validate_drift_gate(state: Mapping[str, object], context: str) -> list[str]:
    """Report the items that progressed toward merge with drift still unresolved.

    Args:
        state (Mapping[str, object]): The parsed parallel checkpoint. Only
            ``drift_events`` and ``items`` are read, and neither is mutated.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: One ``PARALLEL_DRIFT_GATE_VIOLATION:`` error per item whose
        latest drift event is unresolved while its ``merge_status`` is in
        ``PROGRESSED_MERGE_STATUSES``, in ascending item-key order, preceded by at
        most one fail-closed error when part of the event log could not be
        evaluated. An empty list when the ``drift_events`` key is absent, when
        either collection is not a list, or when no item violates the gate.

    Raises:
        None. Malformed input is reported as an error string, matching every other
        checkpoint validator.

    Side Effects:
        None.
    """
    if "drift_events" not in state:
        return []

    events = state.get("drift_events")
    items = state.get("items")
    # F3 already reports a non-list ``drift_events`` or ``items``. The gate cannot
    # rank an event log it cannot iterate, so it stays silent rather than emitting
    # a second error for the same defect.
    if not isinstance(events, list) or not isinstance(items, list):
        return []

    event_entries = cast("list[object]", events)
    records = _object_entries(event_entries)
    item_records = _object_entries(cast("list[object]", items))

    # Resolution is imported, never restated: the pure module owns the
    # latest-event-per-item reduction and both resolution disjuncts. When it
    # refuses the log the gate cannot be shown satisfied, so it fails closed with
    # exactly one error carrying that module's own message.
    try:
        unresolved = unresolved_drift_item_keys(records, item_records)
    except ParallelDriftInputError as error:
        return [
            f"{GATE_VIOLATION_PREFIX} {context} drift_events could not be "
            f"evaluated, so the drift gate fails closed: {error}"
        ]

    errors: list[str] = []
    # A non-object entry is dropped above and its shape error belongs to F3, but
    # the gate is inert for that entry, which must be visible rather than implied.
    if len(records) != len(event_entries):
        errors.append(
            f"{GATE_VIOLATION_PREFIX} {context} drift_events holds an entry that "
            f"is not an object, so the drift gate could not be evaluated for it."
        )
    errors.extend(_progressed_item_errors(unresolved, item_records, context))
    return errors


def _object_entries(entries: Sequence[object]) -> list[Mapping[str, object]]:
    """Keep the object-shaped members of a checkpoint collection.

    Args:
        entries (Sequence[object]): A deserialized ``drift_events`` or ``items``
            collection.

    Returns:
        list[Mapping[str, object]]: The mapping members, in input order. A
        non-mapping member is dropped because F3 already reports it and the gate
        has no field to read on it.

    Raises:
        None.

    Side Effects:
        None.
    """
    # Filter rather than reject: this helper must not raise, and the dropped
    # entries are reported by their owning validator.
    return [
        cast("Mapping[str, object]", entry)
        for entry in entries
        if isinstance(entry, Mapping)
    ]


def _merge_statuses_by_item_key(
    item_records: Sequence[Mapping[str, object]],
) -> dict[int, object]:
    """Index each item's recorded ``merge_status`` by its primary key.

    Args:
        item_records (Sequence[Mapping[str, object]]): The object-shaped
            ``items[]`` entries.

    Returns:
        dict[int, object]: Item key mapped to its ``merge_status`` value verbatim,
        which may be absent and therefore ``None``. An item whose ``issue_num`` is
        not a positive integer is omitted, because F3 already rejects that key and
        the gate cannot attribute a verdict to it.

    Raises:
        None.

    Side Effects:
        None.
    """
    # Build the lookup once so the per-item verdict below is a dictionary read
    # rather than a rescan of the whole collection.
    statuses: dict[int, object] = {}
    for record in item_records:
        item_key = record.get("issue_num")
        if is_positive_integer(item_key):
            statuses[cast("int", item_key)] = record.get("merge_status")
    return statuses


def _progressed_item_errors(
    unresolved: Sequence[int],
    item_records: Sequence[Mapping[str, object]],
    context: str,
) -> list[str]:
    """Report each unresolved item whose ``merge_status`` already progressed.

    Args:
        unresolved (Sequence[int]): Item keys whose latest drift event is
            unresolved, ascending as the pure module returns them.
        item_records (Sequence[Mapping[str, object]]): The object-shaped
            ``items[]`` entries, read for ``merge_status`` only.
        context (str): Surface prefix rendered into each message.

    Returns:
        list[str]: One error per violating item, in ascending item-key order. An
        item still at ``not_started``, ``worktree_created``, or either blocked
        status has not progressed and contributes no error, which is what makes
        the gate compatible with the ``blocked_drift`` state the halt path writes.

    Raises:
        None.

    Side Effects:
        None.
    """
    statuses = _merge_statuses_by_item_key(item_records)

    # Report every violating item, not just the first, so one validation pass
    # tells the orchestrator the whole set of items it must unwind.
    errors: list[str] = []
    for item_key in unresolved:
        status = statuses.get(item_key)
        if status in PROGRESSED_MERGE_STATUSES:
            errors.append(
                f"{GATE_VIOLATION_PREFIX} {context} items[] issue_num {item_key} "
                f"has an unresolved drift event while merge_status is {status!r}; "
                f"merge progression is forbidden until the drift is resolved."
            )
    return errors
