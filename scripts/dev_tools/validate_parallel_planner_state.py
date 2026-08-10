"""Validate the parallel-planner checkpoint artifact.

Purpose:
    Enforce the repository contract for
    ``artifacts/orchestration/parallel-planner-state.json`` -- spec invariants
    P1 through P4 unconditionally and the structural readiness gate P6 through
    P9 only under ``require_ready_for_execution`` -- before a prepared parallel
    run is handed to the orchestrator surface.

Flow:
    Parse the checkpoint JSON, reject a non-object root, check the S3
    required-key set, validate run identity (``parallel_slug``,
    ``parallel_manifest_path``, ``mode``, ``max_concurrency``), scan for
    prohibited keys, then delegate the item, cohort, and conflict-edge
    collections to ``scripts/dev_tools/_parallel_state_common.py`` and
    ``scripts/dev_tools/_parallel_state_structures.py`` so the planner and
    orchestrator surfaces share one implementation of each shape.

Deliberate omissions:
    Spec P5 records that F3 does NOT recompute the cohort coloring: parity
    against ``parallel_cohort_computation.py`` is F4's planner-side check, the
    analogue of the epic planner's ``compute_wave_numbers`` cross-check. The
    readiness gate here is structural only; the deep readiness-integrity
    machinery (git integrity, launch-evidence binding, kickoff-contract
    cross-checks) is likewise F4's, and this module never parses kickoff
    CONTENT -- invariant P9 constrains the kickoff PATH only (assumption A6).

Invariants and constraints:
    The validator returns a list of error strings and never mutates its input.
    No JSON Schema file is authored or imported; enforcement is this
    validator's logic plus the prose rules, per
    ``.claude/rules/orchestrator-state.md``. Every error string begins with the
    literal prefix ``Parallel planner checkpoint`` and ends with a period, so
    the TypeScript parity port has one shape to mirror.
"""

from __future__ import annotations

import json
from typing import cast

from scripts.dev_tools._parallel_state_common import (
    VALID_MODES,
    enum_error,
    in_bounded_range,
    is_non_empty_string,
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
)

# Literal context prefix for every error this module and its helpers emit.
CONTEXT = "Parallel planner checkpoint"

# Inclusive bounds on ``max_concurrency`` (invariant P2, assumption A7).
MIN_CONCURRENCY = 1
MAX_CONCURRENCY = 8

# Required top-level keys (invariant P1, schema S3). ``kickoff_prompt_path`` is
# deliberately absent: it is optional outside the readiness gate, where
# invariant P9 then pins its exact value.
REQUIRED_KEYS: tuple[str, ...] = tuple(
    (
        "objective parallel_slug parallel_manifest_path mode max_concurrency "
        "items cohorts conflict_edges recolor_generation completed_steps "
        "next_step last_updated"
    ).split()
)

# Required per-item keys (invariant P3, schema S3). The preparation fields have
# no unconditional value constraint; the readiness gate pins them.
REQUIRED_ITEM_KEYS: tuple[str, ...] = tuple(
    (
        "issue_num feature_folder kind state blast_radius preparation_status "
        "research_path plan_path preflight_status"
    ).split()
)

# Complexity bands accepted for the optional per-item ``complexity_band``,
# mirroring the epic planner's band vocabulary (invariant P3).
VALID_COMPLEXITY_BANDS: tuple[str, ...] = ("C1", "C2", "C3", "C4")

# Readiness sentinel and per-item readiness values (invariants P7 and P8).
READY_NEXT_STEP = "PARALLEL_EXECUTION_READY"
READY_PREPARATION_STATUS = "prepared"
READY_PREFLIGHT_STATUS = "PREFLIGHT: ALL CLEAR"

# Only the planner-computed radius is authoritative for scheduling, so the
# readiness gate requires the declared source (invariant P7, design 5.2).
READY_RADIUS_SOURCE = "declared"

# A parallel run needs at least two items to be worth scheduling (invariant P6).
MINIMUM_READY_ITEMS = 2

# Kickoff-prompt path convention pinned by invariant P9 (assumption A6). The
# path is checked; its contents are F4's concern and are never read here.
KICKOFF_PATH_TEMPLATE = "artifacts/orchestration/parallel-kickoff-{slug}.md"

# Per-item paths the readiness gate requires to name a produced artifact.
READY_ITEM_PATH_KEYS: tuple[str, ...] = ("research_path", "plan_path")


def _missing_required_keys(state: dict[str, object]) -> list[str]:
    """Report every absent required top-level key (invariant P1).

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
    # tells the planner the whole set of fields still to write.
    return [
        f"{CONTEXT} missing required key: {key}."
        for key in REQUIRED_KEYS
        if key not in state
    ]


def _validate_identity(state: dict[str, object]) -> list[str]:
    """Validate run identity fields against invariant P2.

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
    # The slug and the manifest path bind the checkpoint to one authored run;
    # either being blank makes the checkpoint unattributable.
    for key in ("parallel_slug", "parallel_manifest_path"):
        if key in state and not is_non_empty_string(state.get(key)):
            errors.append(f"{CONTEXT} {key} must be a non-empty string.")

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


def _item_records(items: object) -> list[tuple[int, dict[str, object]]]:
    """Pair each object-shaped ``items[]`` entry with its position.

    Args:
        items (object): The candidate ``items`` value as deserialized.

    Returns:
        list[tuple[int, dict[str, object]]]: One ``(index, record)`` pair per
        object-shaped entry, in document order. A non-list ``items`` yields an
        empty result; its shape error belongs to the shared item validator.

    Raises:
        None.

    Side Effects:
        None.
    """

    if not isinstance(items, list):
        return []
    # Skip non-object entries: the shared item validator already reported their
    # shape, and no per-key check is meaningful without a mapping.
    return [
        (index, cast("dict[str, object]", entry))
        for index, entry in enumerate(cast("list[object]", items))
        if isinstance(entry, dict)
    ]


def _validate_item_contract(items: object) -> list[str]:
    """Validate the planner-specific per-item contract (invariant P3).

    Covers the required-key set and the optional ``complexity_band`` enum. The
    value shapes shared with the other parallel surfaces -- ``issue_num``
    uniqueness, ``feature_folder``, ``kind``, ``state``, and ``blast_radius``
    -- are checked by ``validate_items`` instead of being restated here.

    Args:
        items (object): The candidate ``items`` value as deserialized.

    Returns:
        list[str]: Per-entry errors in positional order: missing required keys
        in ``REQUIRED_ITEM_KEYS`` order, then the band error when present.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    # Check every entry so one pass reports the whole set of unprepared items.
    for index, record in _item_records(items):
        entry_context = item_context(CONTEXT, index)
        errors.extend(
            f"{entry_context} missing required key: {key}."
            for key in REQUIRED_ITEM_KEYS
            if key not in record
        )
        band = record.get("complexity_band")
        # The band is optional: absence is the backward-compatible shape, so
        # the enum check is presence-gated rather than requirement-gated.
        if "complexity_band" in record and band not in VALID_COMPLEXITY_BANDS:
            errors.append(
                enum_error(
                    entry_context, "complexity_band", VALID_COMPLEXITY_BANDS, band
                )
            )
    return errors


def _validate_collections(state: dict[str, object]) -> list[str]:
    """Delegate the planner collections to their helper validators.

    Covers invariant P3's shared item shape and invariant P4's cohort and
    conflict-edge shapes (orchestrator invariants 12 through 15). The cohort
    coloring itself is never recomputed here; that is spec P5, assigned to F4.

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
        errors.extend(validate_items(items, CONTEXT, require_kind=True))
        errors.extend(_validate_item_contract(items))
    if "cohorts" in state:
        errors.extend(validate_cohort_shapes(cohorts, issue_nums, generation, CONTEXT))
        errors.extend(
            validate_current_generation_cohorts(cohorts, items, generation, CONTEXT)
        )
    # ``current_cohort`` is not part of schema S3, so the bound check runs only
    # for a planner checkpoint that chose to carry the orchestrator's pointer.
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
    return errors


def _validate_ready_item(record: dict[str, object], entry_context: str) -> list[str]:
    """Validate one item against the readiness gate (invariant P7).

    Args:
        record (dict[str, object]): One object-shaped ``items[]`` entry.
        entry_context (str): Item-scoped context prefix.

    Returns:
        list[str]: One error per violated readiness condition, in field order:
        preparation status, preflight status, the two artifact paths, then the
        blast-radius source.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    preparation_status = record.get("preparation_status")
    if preparation_status != READY_PREPARATION_STATUS:
        errors.append(
            f"{entry_context} preparation_status must be "
            f"{READY_PREPARATION_STATUS!r}; found: {preparation_status!r}."
        )

    preflight_status = record.get("preflight_status")
    if preflight_status != READY_PREFLIGHT_STATUS:
        errors.append(
            f"{entry_context} preflight_status must be "
            f"{READY_PREFLIGHT_STATUS!r}; found: {preflight_status!r}."
        )

    # Both paths must name a produced artifact: an item with no research or no
    # plan has not been prepared, whatever its preparation_status claims.
    for key in READY_ITEM_PATH_KEYS:
        if not is_non_empty_string(record.get(key)):
            errors.append(f"{entry_context} {key} must be a non-empty string.")

    radius = record.get("blast_radius")
    source = (
        cast("dict[str, object]", radius).get("source")
        if isinstance(radius, dict)
        else None
    )
    if source != READY_RADIUS_SOURCE:
        errors.append(
            f"{entry_context} blast_radius.source must be "
            f"{READY_RADIUS_SOURCE!r} for execution readiness; found: {source!r}."
        )
    return errors


def _validate_ready_gate(state: dict[str, object]) -> list[str]:
    """Enforce the structural readiness gate (invariants P6 through P9).

    The gate is structural only. It checks cardinality, per-item preparation,
    the sentinel, and the kickoff PATH; it never opens the kickoff document and
    never consults a repository. Those checks belong to F4.

    Args:
        state (dict[str, object]): The parsed checkpoint object.

    Returns:
        list[str]: The cardinality error, then per-item readiness errors in
        positional order, then the sentinel error, then the kickoff-path error.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    items = state.get("items")
    # A non-list ``items`` already reported its shape, so the gate adds nothing
    # for it; a list is measured against the two-item minimum.
    if isinstance(items, list):
        entries = cast("list[object]", items)
        count = len(entries)
        if count < MINIMUM_READY_ITEMS:
            errors.append(
                f"{CONTEXT} requires at least {MINIMUM_READY_ITEMS} items for "
                f"execution readiness; found: {count}."
            )
        for index, record in _item_records(entries):
            errors.extend(_validate_ready_item(record, item_context(CONTEXT, index)))

    next_step = state.get("next_step")
    if next_step != READY_NEXT_STEP:
        errors.append(
            f"{CONTEXT} next_step must be {READY_NEXT_STEP!r}; found: {next_step!r}."
        )

    expected_kickoff = KICKOFF_PATH_TEMPLATE.format(slug=state.get("parallel_slug"))
    kickoff_prompt_path = state.get("kickoff_prompt_path")
    if kickoff_prompt_path != expected_kickoff:
        errors.append(
            f"{CONTEXT} kickoff_prompt_path must be {expected_kickoff!r}; "
            f"found: {kickoff_prompt_path!r}."
        )
    return errors


def validate_parallel_planner_state_text(
    text: str, *, require_ready_for_execution: bool = False
) -> list[str]:
    """Validate a parallel-planner checkpoint document.

    Args:
        text (str): Raw checkpoint JSON text.
        require_ready_for_execution (bool): When True, additionally enforce the
            structural readiness gate (invariants P6 through P9). When False
            the gate contributes no errors, so a checkpoint written mid-
            preparation validates.

    Returns:
        list[str]: Validation errors for a malformed or unready checkpoint; an
        empty list when the checkpoint is valid. Invalid JSON and a non-object
        root each return a single-element list, because no field check is
        meaningful without a parsed object.

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

    if require_ready_for_execution:
        errors.extend(_validate_ready_gate(state_map))
    return errors
