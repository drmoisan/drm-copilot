"""Validate the parallel-orchestrator checkpoint artifact.

Purpose:
    Enforce the repository contract for
    ``artifacts/orchestration/parallel-orchestrator-state.json`` -- spec
    invariants 1 through 19 unconditionally and invariants 20 and 21 only under
    ``require_complete`` -- before any resume, scheduling, or completion-gate
    workflow relies on its contents.

Flow:
    Parse the checkpoint JSON, reject a non-object root, check the required-key
    set, validate run identity (``route_id``, ``mode``, ``max_concurrency``),
    scan for prohibited keys, then delegate each collection to
    ``scripts/dev_tools/_parallel_state_common.py`` and
    ``scripts/dev_tools/_parallel_state_structures.py``. Each collection check
    is presence-gated so an absent required key reports exactly one error.

Cache doctrine:
    This checkpoint is a CACHE of durable state, not the source of truth. Every
    field is re-derivable from ``git worktree list --porcelain``, ``git
    branch``, and ``gh pr view --json state,mergedAt,headRefOid``. Validation
    therefore checks internal consistency only and never consults a repository.

Invariants and constraints:
    The validator returns a list of error strings and never mutates its input,
    matching ``validate_epic_orchestrator_state_text``. No JSON Schema file is
    authored or imported; enforcement is this validator's logic plus the prose
    rules, per ``.claude/rules/orchestrator-state.md``. Every error string
    begins with the literal prefix ``Parallel checkpoint`` and ends with a
    period, so the TypeScript parity port has one shape to mirror.
"""

from __future__ import annotations

import json
from typing import cast

from scripts.dev_tools import _parallel_orchestrator_state_mutations as mutation_rules
from scripts.dev_tools._parallel_orchestrator_state_cohort_barrier import (
    validate_cohort_barrier_ordering,
)
from scripts.dev_tools._parallel_orchestrator_state_drift import validate_drift_gate
from scripts.dev_tools._parallel_state_common import (
    MERGED_MERGE_STATUSES,
    VALID_MODES,
    enum_error,
    in_bounded_range,
    item_context,
    scan_prohibited_keys,
    validate_items,
)
from scripts.dev_tools._parallel_state_structures import (
    collect_issue_numbers,
    validate_cohort_shapes,
    validate_conflict_edges,
    validate_current_cohort_bound,
    validate_current_generation_cohorts,
    validate_drift_events,
    validate_mutations,
    validate_receipt_arrays,
)

# Literal context prefix for every error this module and its helpers emit.
CONTEXT = "Parallel checkpoint"

# The route identity this checkpoint must declare (invariant 2).
EXPECTED_ROUTE_ID = "parallel"

# Inclusive bounds on ``max_concurrency`` (invariant 4, assumption A7).
MIN_CONCURRENCY = 1
MAX_CONCURRENCY = 8

# Required top-level keys (invariant 1). The first four mirror the epic
# baseline so the existing structural checkpoint hooks apply unmodified; the
# rest are the parallel-specific fields of schema S2.
REQUIRED_KEYS: tuple[str, ...] = tuple(
    (
        "objective completed_steps next_step last_updated route_id parallel_slug "
        "parallel_manifest_path parallel_status_doc_path mode max_concurrency "
        "current_cohort recolor_generation cohorts items conflict_edges mutations "
        "drift_events"
    ).split()
)


def _missing_required_keys(state: dict[str, object]) -> list[str]:
    """Report every absent required top-level key (invariant 1).

    Args:
        state (dict[str, object]): The parsed checkpoint object.

    Returns:
        list[str]: One error per missing key, in ``REQUIRED_KEYS`` order.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Report every missing key rather than the first, so one validation pass
    # tells the author the whole set of fields still to write.
    return [
        f"{CONTEXT} missing required key: {key}."
        for key in REQUIRED_KEYS
        if key not in state
    ]


def _validate_identity(state: dict[str, object]) -> list[str]:
    """Validate run identity fields against invariants 2 through 4.

    Each check is presence-gated: an absent key has already produced its own
    required-key error, and reporting a second error for the same omission
    would overstate the number of defects.

    Args:
        state (dict[str, object]): The parsed checkpoint object.

    Returns:
        list[str]: One error per violated identity condition.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    route_id = state.get("route_id")
    if "route_id" in state and route_id != EXPECTED_ROUTE_ID:
        errors.append(
            f"{CONTEXT} route_id must be '{EXPECTED_ROUTE_ID}'; found: {route_id!r}."
        )

    mode = state.get("mode")
    if "mode" in state and mode not in VALID_MODES:
        errors.append(enum_error(CONTEXT, "mode", VALID_MODES, mode))

    concurrency = state.get("max_concurrency")
    if "max_concurrency" in state and not in_bounded_range(
        concurrency, MIN_CONCURRENCY, MAX_CONCURRENCY
    ):
        errors.append(
            f"{CONTEXT} max_concurrency must be an integer from "
            f"{MIN_CONCURRENCY} through {MAX_CONCURRENCY}; found: {concurrency!r}."
        )
    return errors


def _validate_collections(state: dict[str, object]) -> list[str]:
    """Delegate every checkpoint collection to its helper validator.

    Covers invariants 5 through 9 (items and blast radii), 12 through 14
    (cohorts), 15 (conflict edges), 16 and 17 (mutations), 18 (drift events),
    and 19 (receipt arrays). Cohort assignment is never recomputed here; that
    is the planner-side parity check assigned to F4.

    Args:
        state (dict[str, object]): The parsed checkpoint object.

    Returns:
        list[str]: The concatenated helper errors, in schema order.

    Raises:
        None.

    Side Effects:
        None.
    """

    items = state.get("items")
    issue_nums = collect_issue_numbers(items)
    generation = state.get("recolor_generation")
    cohorts = state.get("cohorts")

    errors: list[str] = []
    # Each collection is gated on its own key so a missing required key costs
    # exactly one error, while a present but malformed value is fully checked.
    if "items" in state:
        errors.extend(validate_items(items, CONTEXT))
    if "cohorts" in state:
        errors.extend(validate_cohort_shapes(cohorts, issue_nums, generation, CONTEXT))
        errors.extend(
            validate_current_generation_cohorts(cohorts, items, generation, CONTEXT)
        )
    if "current_cohort" in state:
        errors.extend(
            validate_current_cohort_bound(
                state.get("current_cohort"), cohorts, generation, CONTEXT
            )
        )
    if "conflict_edges" in state:
        errors.extend(
            validate_conflict_edges(state.get("conflict_edges"), issue_nums, CONTEXT)
        )
    if "mutations" in state:
        errors.extend(
            validate_mutations(state.get("mutations"), issue_nums, generation, CONTEXT)
        )
    if "drift_events" in state:
        errors.extend(
            validate_drift_events(state.get("drift_events"), issue_nums, CONTEXT)
        )
    errors.extend(validate_receipt_arrays(state, CONTEXT))
    return errors


def _records_close_mutation(state: dict[str, object]) -> bool:
    """Report whether the mutation log records the run-level close operation.

    Args:
        state (dict[str, object]): The parsed checkpoint object.

    Returns:
        bool: True when any object-shaped ``mutations[]`` entry carries
        ``op == 'close'``. Entry shape is not re-checked here; invariant 16
        already reported any malformed record.

    Raises:
        None.

    Side Effects:
        None.
    """

    mutations = state.get("mutations")
    if not isinstance(mutations, list):
        return False
    return any(
        isinstance(entry, dict)
        and cast("dict[str, object]", entry).get("op") == "close"
        for entry in cast("list[object]", mutations)
    )


def _validate_completion(state: dict[str, object]) -> list[str]:
    """Enforce the mode-dependent completion gate (invariants 20 and 21).

    A withdrawn item is exempt: it left the run before reaching a merge
    outcome, so requiring a terminal merge status of it would make every run
    that dropped an item permanently incompletable. Both modes share that
    per-item condition; open mode adds the ``/parallel-close`` record, because
    an open run has no other signal that admissions have stopped.

    Args:
        state (dict[str, object]): The parsed checkpoint object.

    Returns:
        list[str]: One error per non-withdrawn item lacking a terminal merge
        status, in positional order, followed by the open-mode close-mutation
        error when that record is absent.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    items = state.get("items")
    entries = cast("list[object]", items) if isinstance(items, list) else []
    # Check every item so the gate reports the full remaining work, not just
    # the first item that has not finished merging.
    for index, entry in enumerate(entries):
        if not isinstance(entry, dict):
            continue
        record = cast("dict[str, object]", entry)
        if record.get("state") == "withdrawn":
            continue
        merge_status = record.get("merge_status")
        if merge_status not in MERGED_MERGE_STATUSES:
            errors.append(
                f"{item_context(CONTEXT, index)} completion validation failed: "
                f"merge_status is not merged or worktree_removed; "
                f"found: {merge_status!r}."
            )

    if state.get("mode") == "open" and not _records_close_mutation(state):
        errors.append(
            f"{CONTEXT} completion validation failed: open mode requires a "
            f"mutations[] entry with op 'close'."
        )
    return errors


def validate_parallel_orchestrator_state_text(
    text: str, *, require_complete: bool = False
) -> list[str]:
    """Validate a parallel-orchestrator checkpoint document.

    Args:
        text (str): Raw checkpoint JSON text.
        require_complete (bool): When True, additionally enforce the
            mode-dependent completion gate (invariants 20 and 21). When False
            the gate contributes no errors, so an in-progress run validates.

    Returns:
        list[str]: Validation errors for a malformed or incomplete checkpoint;
        an empty list when the checkpoint is valid. Invalid JSON and a
        non-object root each return a single-element list, because no field
        check is meaningful without a parsed object.

    Raises:
        None.

    Side Effects:
        None; the input text is parsed into a fresh object that is never
        written back.
    """

    try:
        state = json.loads(text)
    except json.JSONDecodeError as exc:
        return [f"{CONTEXT} is not valid JSON: {exc}."]

    if not isinstance(state, dict):
        return [f"{CONTEXT} root must be a JSON object."]
    state_map = cast("dict[str, object]", state)

    errors: list[str] = []
    errors.extend(_missing_required_keys(state_map))
    errors.extend(_validate_identity(state_map))
    errors.extend(scan_prohibited_keys(state_map, CONTEXT))
    errors.extend(_validate_collections(state_map))
    errors.extend(mutation_rules.validate_mutation_protocol(state_map, CONTEXT))
    errors.extend(validate_drift_gate(state_map, CONTEXT))

    # BEGIN F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION
    # F7 (parallel enforcement hooks) owns the retrospective cohort-ordering
    # invariant of design section 9 Layer 2. Its entire edit to this module is
    # one appended `errors.extend(<helper>(state_map, CONTEXT))` call inside
    # this block, plus the helper's import. Nothing else in this function moves,
    # so F7 and F3 cannot contend over the same lines (epic wave-4 rule).
    # Add F7 helper invocations below this line, one per line.
    errors.extend(validate_cohort_barrier_ordering(state_map))
    # END F7 EXTENSION SEAM -- PARALLEL_COHORT_BARRIER_VIOLATION

    if require_complete:
        errors.extend(_validate_completion(state_map))
    return errors
