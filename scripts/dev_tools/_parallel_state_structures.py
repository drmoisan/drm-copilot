"""Collection validators for the parallel-orchestration checkpoint structures.

Purpose:
    Enforce the shape of the four checkpoint collections that carry scheduling
    and audit state -- ``cohorts[]``, ``conflict_edges[]``, ``mutations[]``, and
    ``drift_events[]`` -- plus the loose receipt-array check, covering spec
    invariants 12 through 19. F3 owns these shapes in full so the wave-4
    features F6, F7, and F8 add behavior without adding schema fields.

Responsibilities and usage:
    Validate shape, enum membership, and item-key resolution only. Cohort
    assignment itself is computed by
    ``scripts/dev_tools/parallel_cohort_computation.py`` and is never recomputed
    here; state-transition legality is F6 behavior and is likewise not checked.
    Callers pass the deserialized collection, the resolvable ``issue_num`` set
    from ``collect_issue_numbers``, and their own literal context prefix.

Key invariants and constraints:
    ``issue_num`` is the primary key (assumption A4), so every ``item_keys``
    entry, edge endpoint, mutation ``item_key``, and drift ``item_key`` is an
    integer that must resolve to an ``items[].issue_num``. Errors that
    aggregate across entries (duplicate cohort index, duplicate edge pair) are
    emitted in ascending key order so the sequence is reproducible.

Raises and side effects:
    None anywhere in this module. Every function is pure: it raises nothing,
    performs no I/O, and reads but never mutates its arguments. Individual
    docstrings therefore omit the ``Raises`` and ``Side Effects`` sections that
    this module-wide statement already covers.
"""

from __future__ import annotations

from typing import cast

from scripts.dev_tools._parallel_state_common import (
    VALID_EDGE_REASONS,
    enum_error,
    is_non_negative_integer,
)
from scripts.dev_tools._parallel_state_records import (
    validate_drift_events,
    validate_mutations,
)

# The mutations and drift-event validators live in
# ``scripts/dev_tools/_parallel_state_records.py`` so neither file exceeds the
# repository's 500-line limit, and are re-exported here so callers depend on
# this one module for every checkpoint-collection validator.
__all__ = [
    "COHORT_COVERAGE_EXEMPT_STATES",
    "RECEIPT_ARRAY_KEYS",
    "collect_issue_numbers",
    "collect_item_keys_and_states",
    "validate_cohort_shapes",
    "validate_conflict_edges",
    "validate_current_cohort_bound",
    "validate_current_generation_cohorts",
    "validate_drift_events",
    "validate_mutations",
    "validate_receipt_arrays",
]

# Item states exempt from current-generation cohort coverage (invariant 13).
# A withdrawn item left the run; a merged or blocked item is terminal, so
# neither is scheduled into the next cohort barrier.
COHORT_COVERAGE_EXEMPT_STATES: tuple[str, ...] = tuple(
    "withdrawn merged blocked".split()
)

# Optional receipt arrays validated for list type only (invariant 19), matching
# the loose tolerance of the standard checkpoint validators.
RECEIPT_ARRAY_KEYS: tuple[str, ...] = tuple(
    "delegation_receipts skill_receipts mcp_call_receipts".split()
)


def collect_item_keys_and_states(items: object) -> list[tuple[int, object]]:
    """Extract the primary key and state of every well-formed ``items[]`` entry.

    Args:
        items (object): The candidate ``items`` value. A non-list yields an
            empty result; its shape error belongs to the item validator.

    Returns:
        list[tuple[int, object]]: One ``(issue_num, state)`` pair per
        object-shaped entry with a positive integer key, in document order.
        ``state`` is unvalidated so callers can render it verbatim.
    """

    pairs: list[tuple[int, object]] = []
    if not isinstance(items, list):
        return pairs
    # Skip entries whose primary key is unusable: without a key they cannot
    # participate in cohort coverage or edge resolution at all.
    for entry in cast("list[object]", items):
        if not isinstance(entry, dict):
            continue
        record = cast("dict[str, object]", entry)
        issue_num = record.get("issue_num")
        if isinstance(issue_num, int) and not isinstance(issue_num, bool):
            if issue_num > 0:
                pairs.append((issue_num, record.get("state")))
    return pairs


def collect_issue_numbers(items: object) -> set[int]:
    """Return the set of resolvable ``issue_num`` primary keys.

    Args:
        items (object): The candidate ``items`` value as deserialized.

    Returns:
        set[int]: Every positive integer ``issue_num`` present on an
        object-shaped entry. Membership in this set is what "resolves to an
        ``items[].issue_num``" means throughout invariants 12, 15, 16, and 18.
    """

    return {issue_num for issue_num, _state in collect_item_keys_and_states(items)}


def validate_cohort_shapes(
    cohorts: object, issue_nums: set[int], recolor_generation: object, context: str
) -> list[str]:
    """Validate ``recolor_generation`` and ``cohorts[]`` shape (invariant 12).

    Args:
        cohorts (object): The candidate ``cohorts`` value as deserialized.
        issue_nums (set[int]): Resolvable primary keys from
            ``collect_issue_numbers``.
        recolor_generation (object): The top-level generation counter, which
            bounds each cohort's own ``generation``.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: One error per violated condition. A non-list ``cohorts``
        yields exactly one collection-level error; an empty list is valid,
        because a run may be checkpointed before its first coloring.
    """

    errors: list[str] = []
    generation_ok = is_non_negative_integer(recolor_generation)
    if not generation_ok:
        errors.append(
            f"{context} recolor_generation must be a non-negative integer; "
            f"found: {recolor_generation!r}."
        )

    if not isinstance(cohorts, list):
        errors.append(f"{context} cohorts must be a list.")
        return errors

    # Validate every entry rather than stopping at the first malformed one, so
    # a single pass reports the whole coloring's defects.
    for position, entry in enumerate(cast("list[object]", cohorts)):
        entry_context = f"{context} cohorts[{position}]"
        if not isinstance(entry, dict):
            errors.append(f"{entry_context} must be an object.")
            continue
        errors.extend(
            _validate_cohort_entry(
                cast("dict[str, object]", entry),
                entry_context,
                issue_nums,
                recolor_generation if generation_ok else None,
            )
        )
    return errors


def _validate_cohort_entry(
    entry: dict[str, object],
    entry_context: str,
    issue_nums: set[int],
    recolor_generation: object,
) -> list[str]:
    """Validate one ``cohorts[]`` entry against invariant 12.

    Args:
        entry (dict[str, object]): One object-shaped cohort record.
        entry_context (str): Context prefix naming this entry.
        issue_nums (set[int]): Resolvable primary keys.
        recolor_generation (object): The validated top-level counter, or None
            when the counter itself was malformed. The generation-bound check
            is skipped for None, because comparing against a malformed counter
            would report a second error for one underlying defect.

    Returns:
        list[str]: One error per violated condition on this entry.
    """

    errors: list[str] = []
    index = entry.get("index")
    if not is_non_negative_integer(index):
        errors.append(
            f"{entry_context} index must be a non-negative integer; found: {index!r}."
        )

    generation = entry.get("generation")
    if not is_non_negative_integer(generation):
        errors.append(
            f"{entry_context} generation must be a non-negative integer; "
            f"found: {generation!r}."
        )
    elif isinstance(recolor_generation, int) and cast("int", generation) > (
        recolor_generation
    ):
        errors.append(
            f"{entry_context} generation {generation} must not exceed "
            f"recolor_generation {recolor_generation}."
        )

    item_keys = entry.get("item_keys")
    if not isinstance(item_keys, list):
        errors.append(f"{entry_context} item_keys must be a list.")
        return errors

    # Every member key must name a declared item; an unresolved key would
    # silently schedule work that the run does not track.
    for key in cast("list[object]", item_keys):
        if not isinstance(key, int) or isinstance(key, bool) or key not in issue_nums:
            errors.append(
                f"{entry_context} item_keys entry {key!r} does not resolve to "
                f"an items[].issue_num."
            )
    return errors


def _current_generation_cohorts(
    cohorts: object, recolor_generation: object
) -> list[dict[str, object]]:
    """Select the ``cohorts[]`` entries belonging to the current generation.

    Args:
        cohorts (object): The candidate ``cohorts`` value as deserialized.
        recolor_generation (object): The top-level generation counter.

    Returns:
        list[dict[str, object]]: Object-shaped entries whose ``generation``
        equals the counter, in document order. Empty when the counter is
        malformed, because no entry can be attributed to a non-numeric
        generation.
    """

    if not is_non_negative_integer(recolor_generation) or not isinstance(cohorts, list):
        return []
    # Non-object entries are skipped: their shape error is already reported by
    # validate_cohort_shapes, and they carry no usable generation.
    records = [
        cast("dict[str, object]", entry)
        for entry in cast("list[object]", cohorts)
        if isinstance(entry, dict)
    ]
    return [r for r in records if r.get("generation") == recolor_generation]


def validate_current_generation_cohorts(
    cohorts: object, items: object, recolor_generation: object, context: str
) -> list[str]:
    """Validate current-generation index uniqueness and coverage (invariant 13).

    The coverage rule is "exactly one" (spec decision, research R5): the
    coloring is a pure function over the unstarted subgraph, so a partial
    coloring means the checkpoint was written mid-recompute.

    Args:
        cohorts (object): The candidate ``cohorts`` value as deserialized.
        items (object): The candidate ``items`` value as deserialized.
        recolor_generation (object): The top-level generation counter.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: Duplicate-index errors in ascending index order, then
        coverage errors in ascending ``issue_num`` order. An item absent from
        every current-generation cohort is accepted only in state
        ``withdrawn``, ``merged``, or ``blocked``.
    """

    current = _current_generation_cohorts(cohorts, recolor_generation)
    errors: list[str] = []

    seen_indices: set[int] = set()
    duplicate_indices: set[int] = set()
    membership_counts: dict[int, int] = {}
    # One pass builds both aggregates: the index multiset for uniqueness and
    # the per-item appearance count for the exactly-one coverage rule.
    for entry in current:
        index = entry.get("index")
        if is_non_negative_integer(index):
            index_value = cast("int", index)
            if index_value in seen_indices:
                duplicate_indices.add(index_value)
            seen_indices.add(index_value)
        item_keys = entry.get("item_keys")
        if not isinstance(item_keys, list):
            continue
        for key in cast("list[object]", item_keys):
            if isinstance(key, int) and not isinstance(key, bool):
                membership_counts[key] = membership_counts.get(key, 0) + 1

    for index_value in sorted(duplicate_indices):
        errors.append(
            f"{context} has duplicate current-generation cohorts[].index: "
            f"{index_value}."
        )

    # Compare declared items against the coloring: a non-exempt item must land
    # in exactly one cohort, and no item may land in more than one.
    for issue_num, state in sorted(
        collect_item_keys_and_states(items), key=lambda pair: pair[0]
    ):
        count = membership_counts.get(issue_num, 0)
        if count == 1:
            continue
        if count == 0 and state in COHORT_COVERAGE_EXEMPT_STATES:
            continue
        errors.append(
            f"{context} item {issue_num} in state {state!r} must appear in "
            f"exactly one current-generation cohort; found {count}."
        )
    return errors


def validate_current_cohort_bound(
    current_cohort: object, cohorts: object, recolor_generation: object, context: str
) -> list[str]:
    """Validate the ``current_cohort`` pointer against invariant 14.

    Args:
        current_cohort (object): The candidate pointer as deserialized.
        cohorts (object): The candidate ``cohorts`` value as deserialized.
        recolor_generation (object): The top-level generation counter.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: At most one error. The bound check runs only when at least
        one current-generation cohort carries a usable ``index``; with no
        current-generation coloring there is no maximum to compare against.
    """

    if not is_non_negative_integer(current_cohort):
        errors = [
            f"{context} current_cohort must be a non-negative integer; "
            f"found: {current_cohort!r}."
        ]
        return errors

    indices = [
        cast("int", entry.get("index"))
        for entry in _current_generation_cohorts(cohorts, recolor_generation)
        if is_non_negative_integer(entry.get("index"))
    ]
    if not indices:
        return []

    highest = max(indices)
    if cast("int", current_cohort) > highest:
        return [
            f"{context} current_cohort {current_cohort} must not exceed the "
            f"maximum current-generation cohorts[].index {highest}."
        ]
    return []


def _validate_edge_endpoints(
    entry: dict[str, object], entry_context: str, issue_nums: set[int]
) -> tuple[list[str], tuple[int, int] | None]:
    """Validate one edge's ``a`` and ``b`` endpoints against invariant 15.

    Args:
        entry (dict[str, object]): One object-shaped ``conflict_edges[]`` entry.
        entry_context (str): Context prefix naming this entry.
        issue_nums (set[int]): Resolvable primary keys.

    Returns:
        tuple[list[str], tuple[int, int] | None]: The endpoint errors, and the
        canonical ``(a, b)`` pair when both endpoints resolved, are distinct,
        and are normalized. The pair is None otherwise, so the caller only
        counts well-formed edges toward duplicate detection.
    """

    errors: list[str] = []
    endpoints: dict[str, int] = {}
    # Resolve both endpoints before comparing them: distinctness and the a < b
    # normalization are only meaningful once each side names a real item.
    for field in ("a", "b"):
        value = entry.get(field)
        if (
            isinstance(value, int)
            and not isinstance(value, bool)
            and value in issue_nums
        ):
            endpoints[field] = value
        else:
            errors.append(
                f"{entry_context} {field} {value!r} does not resolve to an "
                f"items[].issue_num."
            )
    if len(endpoints) != 2:
        return errors, None

    first, second = endpoints["a"], endpoints["b"]
    # A self-edge is reported on its own because the contention relation is
    # defined over distinct items, which is a different defect from ordering.
    if first == second:
        errors.append(f"{entry_context} endpoints must be distinct; found: {first}.")
        return errors, None
    if first > second:
        errors.append(
            f"{entry_context} must be normalized with a < b; "
            f"found: ({first}, {second})."
        )
        return errors, None
    return errors, (first, second)


def validate_conflict_edges(
    edges: object, issue_nums: set[int], context: str
) -> list[str]:
    """Validate ``conflict_edges[]`` against invariant 15 and schema S7.

    Args:
        edges (object): The candidate ``conflict_edges`` value as deserialized.
        issue_nums (set[int]): Resolvable primary keys.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: Per-entry errors in positional order, then one
        duplicate-pair error per repeated canonical pair in ascending pair
        order. A non-list value yields exactly one error; an empty list is
        valid, because a run whose items never overlap has no edges.
    """

    if not isinstance(edges, list):
        return [f"{context} conflict_edges must be a list."]

    errors: list[str] = []
    seen: set[tuple[int, int]] = set()
    duplicates: set[tuple[int, int]] = set()
    # Validate each edge in place and accumulate canonical pairs in the same
    # pass, so edge identity is decided without a second traversal.
    for position, entry in enumerate(cast("list[object]", edges)):
        entry_context = f"{context} conflict_edges[{position}]"
        if not isinstance(entry, dict):
            errors.append(f"{entry_context} must be an object.")
            continue
        record = cast("dict[str, object]", entry)
        endpoint_errors, pair = _validate_edge_endpoints(
            record, entry_context, issue_nums
        )
        errors.extend(endpoint_errors)

        reason = record.get("reason")
        if reason not in VALID_EDGE_REASONS:
            errors.append(
                enum_error(entry_context, "reason", VALID_EDGE_REASONS, reason)
            )
        if pair is None:
            continue
        if pair in seen:
            duplicates.add(pair)
        seen.add(pair)

    # Report duplicate pairs in ascending order so the message sequence does
    # not depend on where the repeats appeared in the document.
    for pair in sorted(duplicates):
        errors.append(
            f"{context} has duplicate conflict_edges[] pair: ({pair[0]}, {pair[1]})."
        )
    return errors


def validate_receipt_arrays(state: dict[str, object], context: str) -> list[str]:
    """Validate the optional receipt arrays against invariant 19.

    The check is presence-gated: an absent receipt array is the backward
    compatible shape and contributes no error. Per-receipt content is
    deliberately not inspected, matching the loose tolerance the standard
    checkpoint validators already apply to receipt records.

    Args:
        state (dict[str, object]): The parsed checkpoint object.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: One error per present receipt key whose value is not a list,
        in ``RECEIPT_ARRAY_KEYS`` order.
    """

    errors: list[str] = []
    # Check each optional array independently so a caller that records only
    # one receipt kind is not penalized for the two it omitted.
    for key in RECEIPT_ARRAY_KEYS:
        if key in state and not isinstance(state[key], list):
            errors.append(f"{context} {key} must be a list when present.")
    return errors
