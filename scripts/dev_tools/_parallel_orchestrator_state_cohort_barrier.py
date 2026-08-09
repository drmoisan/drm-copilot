"""Retrospective cohort-barrier ordering invariant for the parallel checkpoint.

Purpose:
    Own Layer 2 of the two-layer cohort barrier (design section 9): given a
    written ``artifacts/orchestration/parallel-orchestrator-state.json``, report
    every ``conflict_edges[]`` pair the checkpoint shows ran concurrently.
    Layer 1 is the per-call ``PreToolUse`` deterrent
    ``.claude/hooks/enforce-parallel-cohort-barrier.ps1``, which fires once per
    tool call and therefore cannot inspect a batch of concurrent ``Agent``
    calls; this module inspects the recorded batch but only after execution.
    Neither layer alone closes the gap, so both are shipped.

Flow:
    Gate on the presence of ``conflict_edges`` and ``cohorts``; build a union
    reference index over ``items[]`` (primary key ``issue_num``, with the
    ``feature_folder`` hint tolerated per the epic union-index precedent in
    ``scripts/dev_tools/_epic_orchestrator_state_resolution.py``); project the
    current-generation cohort coloring into an item-to-cohort-index map; then
    test each edge under the structural and temporal readings and emit one
    message per violated edge.

Responsibilities:
    This module adds NO checkpoint schema field. It reads only fields F3 already
    defines -- ``cohorts[]``, ``conflict_edges[]``, ``items[].merge_status``,
    and the two optional lifecycle timestamps named by the constants below --
    and consumes F3's enums without extending them. It performs no shape
    validation: a malformed cohort, edge, or item is already reported by
    ``validate_parallel_orchestrator_state.py`` and its helpers, so this module
    silently skips what it cannot read rather than double-reporting it.

Key invariants and constraints:
    The check is key-gated, so a checkpoint written before this invariant
    existed validates byte-identically. The temporal reading degrades to the
    structural-plus-status checks whenever either timestamp is absent or is not
    a string, because F3 neither requires nor validates those fields; no
    timestamp is ever inferred, defaulted, or synthesized. Each violated edge
    contributes exactly one message in the byte-exact form mandated by design
    section 9, which deliberately carries no ``Parallel checkpoint`` context
    prefix and no trailing period.

Raises and side effects:
    None anywhere in this module. Every function is pure: it raises nothing,
    performs no I/O, and reads but never mutates its arguments. Individual
    docstrings therefore omit the ``Raises`` and ``Side Effects`` sections that
    this module-wide statement already covers.
"""

from __future__ import annotations

from typing import cast

from scripts.dev_tools._parallel_state_common import (
    MERGED_MERGE_STATUSES,
    is_non_negative_integer,
    is_positive_integer,
)

# Literal token of the Layer 2 invariant (design section 9). The message form is
# byte-exact and, unlike every other error this validator family emits, carries
# no context prefix and no trailing period.
VIOLATION_PREFIX = "PARALLEL_COHORT_BARRIER_VIOLATION"

# U9 lifecycle timestamp field names, frozen at Phase 0 from the parallel cache
# doctrine and the parallel-status items projection. Both fields are optional and
# unvalidated by F3, which is why the temporal reading must degrade rather than
# require them. There is no F3-guaranteed ``in_flight_at`` or ``started_at``.
ITEM_START_TIMESTAMP_FIELD = "worktree_created_at"
MERGE_CONFIRMATION_TIMESTAMP_FIELD = "merged_at"

# The merge-status value meaning no work has begun. An absent ``merge_status`` is
# treated as this value per F3's schema, so absence never evidences a start.
NOT_STARTED_MERGE_STATUS = "not_started"

# Top-level keys that gate the whole check. Both are required by F3 invariant 1,
# so a checkpoint missing either is already being reported as malformed; running
# the barrier check on it would add noise without adding information.
GATING_KEYS: tuple[str, ...] = ("conflict_edges", "cohorts")

# Lifecycle prefixes a ``feature_folder`` hint may carry, longest first so the
# repository-rooted form is stripped before the bare lifecycle form.
FOLDER_HINT_PREFIXES: tuple[str, ...] = (
    "docs/features/active/",
    "docs/features/completed/",
    "active/",
    "completed/",
)


def _normalize_folder_hint(value: str) -> str:
    """Strip any lifecycle prefix from a ``feature_folder`` reference.

    Args:
        value (str): A raw ``feature_folder`` value or a reference to one, which
            may be a bare basename or may point into a lifecycle folder.

    Returns:
        str: The basename with the first matching prefix removed, so a hint and
        the item's own stored value index to the same key.
    """

    # Check each known lifecycle prefix in order; the first match is stripped.
    for prefix in FOLDER_HINT_PREFIXES:
        if value.startswith(prefix):
            return value[len(prefix) :]
    return value


def _build_reference_index(
    items: object,
) -> tuple[dict[int, dict[str, object]], dict[str, int]]:
    """Index the checkpoint's items by primary key and by folder hint.

    Args:
        items (object): The candidate ``items`` value as deserialized.

    Returns:
        tuple[dict[int, dict[str, object]], dict[str, int]]: The
        ``issue_num``-keyed record map and the normalized-folder-hint map onto
        the same keys. Both are empty when ``items`` is not a list, which leaves
        every reference unresolvable and the whole check silent.
    """

    records: dict[int, dict[str, object]] = {}
    by_folder_hint: dict[str, int] = {}
    if not isinstance(items, list):
        return records, by_folder_hint

    # Index every well-keyed item under both reference forms so a cohort member
    # or an edge endpoint resolves whether it names the primary key or the hint.
    # First occurrence wins: a duplicate key is invariant 5's error to report.
    for entry in cast("list[object]", items):
        if not isinstance(entry, dict):
            continue
        record = cast("dict[str, object]", entry)
        issue_num = record.get("issue_num")
        if not is_positive_integer(issue_num):
            continue
        key = cast("int", issue_num)
        records.setdefault(key, record)
        folder = record.get("feature_folder")
        if isinstance(folder, str) and folder.strip():
            by_folder_hint.setdefault(_normalize_folder_hint(folder), key)
    return records, by_folder_hint


def _resolve_reference(
    reference: object,
    records: dict[int, dict[str, object]],
    by_folder_hint: dict[str, int],
) -> int | None:
    """Resolve one cohort member or edge endpoint to its ``issue_num``.

    Args:
        reference (object): A ``cohorts[].item_keys`` entry or an edge ``a``/``b``
            value as deserialized.
        records (dict[int, dict[str, object]]): The primary-key record map.
        by_folder_hint (dict[str, int]): The normalized-folder-hint map.

    Returns:
        int | None: The resolved ``issue_num``, or None when the reference names
        no declared item. A string is read as a ``feature_folder`` hint and
        anything else as the primary key itself, mirroring the epic resolver.
    """

    # The reference form decides the lookup: F3 requires the integer primary key,
    # while the folder-hint branch exists only so a hint-shaped reference is
    # understood rather than silently treated as an absent item.
    if isinstance(reference, str):
        return by_folder_hint.get(_normalize_folder_hint(reference))
    if is_positive_integer(reference) and cast("int", reference) in records:
        return cast("int", reference)
    return None


def _cohort_index_by_item(
    cohorts: object,
    recolor_generation: object,
    records: dict[int, dict[str, object]],
    by_folder_hint: dict[str, int],
) -> dict[int, int]:
    """Project the current-generation coloring into a member-to-index map.

    Args:
        cohorts (object): The candidate ``cohorts`` value as deserialized.
        recolor_generation (object): The top-level generation counter.
        records (dict[int, dict[str, object]]): The primary-key record map.
        by_folder_hint (dict[str, int]): The normalized-folder-hint map.

    Returns:
        dict[int, int]: Each resolvable current-generation cohort member mapped
        to its cohort ``index``. Empty when ``cohorts`` is not a list or the
        generation counter is unusable, because no row can then be attributed
        to the current coloring.
    """

    assignments: dict[int, int] = {}
    if not isinstance(cohorts, list) or not is_non_negative_integer(recolor_generation):
        return assignments

    # Only current-generation rows are read: a superseded generation records a
    # coloring that no longer governs scheduling, so it cannot imply ordering.
    for entry in cast("list[object]", cohorts):
        if not isinstance(entry, dict):
            continue
        row = cast("dict[str, object]", entry)
        if row.get("generation") != recolor_generation:
            continue
        index = row.get("index")
        item_keys = row.get("item_keys")
        if not is_non_negative_integer(index) or not isinstance(item_keys, list):
            continue
        # Record the first current-generation cohort each member appears in; a
        # second appearance is invariant 13's error to report, not this one's.
        for reference in cast("list[object]", item_keys):
            key = _resolve_reference(reference, records, by_folder_hint)
            if key is not None:
                assignments.setdefault(key, cast("int", index))
    return assignments


def _has_started(record: dict[str, object]) -> bool:
    """Report whether an item has begun work, per the recorded evidence.

    Args:
        record (dict[str, object]): One ``items[]`` entry.

    Returns:
        bool: True when the item carries a non-empty start timestamp string or a
        ``merge_status`` that has left ``not_started``. An absent
        ``merge_status`` means ``not_started`` in F3's schema, so absence never
        evidences a start.
    """

    start = record.get(ITEM_START_TIMESTAMP_FIELD)
    if isinstance(start, str) and start.strip():
        return True
    merge_status = record.get("merge_status")
    return isinstance(merge_status, str) and merge_status != NOT_STARTED_MERGE_STATUS


def _satisfies_barrier(record: dict[str, object]) -> bool:
    """Report whether an item reached a barrier-satisfying terminal status.

    Args:
        record (dict[str, object]): One ``items[]`` entry.

    Returns:
        bool: True when ``merge_status`` is ``merged`` or ``worktree_removed``.
        ``ci_green`` deliberately does not satisfy the barrier: the next cohort
        may branch only from durably merged work.
    """

    return record.get("merge_status") in MERGED_MERGE_STATUSES


def _merge_confirmed_after_start(
    earlier: dict[str, object], later: dict[str, object]
) -> bool:
    """Compare the earlier item's merge confirmation to the later item's start.

    Args:
        earlier (dict[str, object]): The item colored into the earlier cohort.
        later (dict[str, object]): The item colored into the later cohort.

    Returns:
        bool: True when both timestamps are present as strings and the earlier
        item's merge confirmation is chronologically after the later item's
        start, which means the two overlapped. Returns False whenever either
        value is absent or is not a string, which is the mandated degradation to
        the structural-plus-status checks; no value is ever synthesized.
    """

    confirmed = earlier.get(MERGE_CONFIRMATION_TIMESTAMP_FIELD)
    started = later.get(ITEM_START_TIMESTAMP_FIELD)
    if not isinstance(confirmed, str) or not isinstance(started, str):
        return False
    # ISO-8601 timestamps sort correctly as strings, matching the epic
    # wave-barrier precedent's merge_confirmed_at > worktree_created_at compare.
    return confirmed > started


def _violation_endpoints(
    first: int,
    second: int,
    assignments: dict[int, int],
    records: dict[int, dict[str, object]],
) -> tuple[int, int] | None:
    """Decide whether one conflict edge violates the cohort barrier.

    Args:
        first (int): The edge's ``a`` endpoint, already resolved.
        second (int): The edge's ``b`` endpoint, already resolved.
        assignments (dict[int, int]): Member-to-cohort-index projection.
        records (dict[int, dict[str, object]]): The primary-key record map.

    Returns:
        tuple[int, int] | None: The ``(earlier, later)`` endpoints to name in the
        message, or None when the edge is clean or cannot be judged.
    """

    first_index = assignments.get(first)
    second_index = assignments.get(second)
    # Structural reading: conflicting items colored into one current-generation
    # cohort run concurrently by construction, so index equality alone is a
    # violation and the edge's own endpoint order names the message.
    if first_index is not None and first_index == second_index:
        return (first, second)
    # An endpoint outside the current coloring cannot be ordered against the
    # other, so no temporal claim is available and the edge is left unjudged.
    if first_index is None or second_index is None:
        return None

    # Temporal reading: order the endpoints by cohort index, then ask whether the
    # later-cohort item overlapped the earlier one. The status disjunct fires
    # whenever the later item started before the earlier reached a terminal
    # merge; the timestamp disjunct additionally catches an overlap that the
    # statuses have since moved past.
    earlier_key, later_key = (
        (first, second) if first_index < second_index else (second, first)
    )
    earlier = records.get(earlier_key)
    later = records.get(later_key)
    if earlier is None or later is None:
        return None
    status_violation = _has_started(later) and not _satisfies_barrier(earlier)
    if status_violation or _merge_confirmed_after_start(earlier, later):
        return (earlier_key, later_key)
    return None


def validate_cohort_barrier_ordering(state: dict[str, object]) -> list[str]:
    """Report every conflict edge the checkpoint shows ran concurrently.

    Args:
        state (dict[str, object]): The parsed parallel-orchestrator checkpoint.

    Returns:
        list[str]: One byte-exact
        ``PARALLEL_COHORT_BARRIER_VIOLATION: <a> ran concurrently with
        conflicting <b>`` message per violated edge, in ``conflict_edges[]``
        document order, with ``<a>`` the earlier or first endpoint. An empty
        list when the barrier holds, when either gating key is absent
        (backward compatibility), or when no edge can be judged.
    """

    # Key gate: both collections are required by invariant 1, so a checkpoint
    # missing either is already reported malformed and predates this invariant.
    if any(key not in state for key in GATING_KEYS):
        return []
    edges = state.get("conflict_edges")
    if not isinstance(edges, list):
        return []

    records, by_folder_hint = _build_reference_index(state.get("items"))
    assignments = _cohort_index_by_item(
        state.get("cohorts"), state.get("recolor_generation"), records, by_folder_hint
    )

    errors: list[str] = []
    # Judge every edge so one validation pass reports the full set of overlaps,
    # and emit at most one message per edge even when both readings hold.
    for entry in cast("list[object]", edges):
        if not isinstance(entry, dict):
            continue
        edge = cast("dict[str, object]", entry)
        first = _resolve_reference(edge.get("a"), records, by_folder_hint)
        second = _resolve_reference(edge.get("b"), records, by_folder_hint)
        # A self-edge or an unresolved endpoint is invariant 15's error; there is
        # no pair of distinct items here whose ordering could be judged.
        if first is None or second is None or first == second:
            continue
        endpoints = _violation_endpoints(first, second, assignments, records)
        if endpoints is not None:
            errors.append(
                f"{VIOLATION_PREFIX}: {endpoints[0]} ran concurrently with "
                f"conflicting {endpoints[1]}"
            )
    return errors
