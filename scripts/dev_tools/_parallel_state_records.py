"""Append-only audit-record validators for the parallel checkpoint.

Purpose:
    Enforce spec invariants 16, 17, and 18 -- the full ``mutations[]`` shape
    (schema S5) including the in-flight-removal disposition rule, and the full
    ``drift_events[]`` shape (schema S6) -- and, presence-gated, the recorded
    scheduling estimates, verdicts, access lists, and precedence kinds (#1164).

Responsibilities and usage:
    Validate shape, enum membership, op-specific null rules, and item-key
    resolution. State-transition legality -- which item state may follow which
    -- is deliberately NOT checked here: that is F6 behavior, not F3 schema
    (spec S5). This module is a private implementation detail of
    ``scripts/dev_tools/_parallel_state_structures.py``, which re-exports both
    public functions; callers import from that module, not this one. It lives
    apart only so neither file exceeds the repository's 500-line limit.

Key invariants and constraints:
    ``item_key`` is an ``items[].issue_num`` (assumption A4) for every op
    except ``close``, which is a run-level operation and therefore carries a
    null key. Invariant 17 is stricter than the S5 table's ``disposition`` row
    and is the behavior implemented: a disposition is required only for an
    in-flight removal and must be null on every other entry.

Raises and side effects:
    None anywhere in this module. Every function is pure: it raises nothing,
    performs no I/O, and reads but never mutates its arguments. Individual
    docstrings therefore omit the ``Raises`` and ``Side Effects`` sections that
    this module-wide statement already covers.
"""

from __future__ import annotations

from typing import cast

from scripts.dev_tools._parallel_state_common import (
    VALID_DISPOSITIONS,
    VALID_DRIFT_ACTIONS,
    VALID_EDGE_REASONS,
    VALID_ITEM_STATES,
    VALID_MUTATION_OPS,
    enum_error,
    is_non_empty_string,
    is_non_negative_integer,
    is_string_list,
    item_context,
)

# Issue #1164: a tolerated overlap never carries a hard reason (issue #722); a
# cost ordering is re-tested while a correctness ordering carries a reason; and
# an item may carry two access lists beside its blast_radius block.
HARD_EDGE_REASONS: tuple[str, ...] = ("shared_surface_overlap", "contract_dependency")
VALID_PRECEDENCE_KINDS: tuple[str, ...] = ("cost", "correctness")
ACCESS_LIST_FIELDS: tuple[str, ...] = ("read_paths", "separable_paths")

# Operations that act on one tracked item and therefore need a resolving key.
OPS_REQUIRING_ITEM_KEY: tuple[str, ...] = tuple("add remove requeue".split())

# Operations for which ``prior_state`` must be null: ``add`` introduces an item
# that had no prior state, and ``close`` is a run-level record (schema S5).
OPS_REQUIRING_NULL_PRIOR_STATE: tuple[str, ...] = tuple("add close".split())

# Operations for which ``new_state`` must be null; only the run-level close.
OPS_REQUIRING_NULL_NEW_STATE: tuple[str, ...] = ("close",)


def _resolves(value: object, issue_nums: set[int]) -> bool:
    """Report whether a value is an integer naming a declared item.

    Args:
        value (object): The candidate key as deserialized.
        issue_nums (set[int]): Resolvable primary keys.

    Returns:
        bool: True when the value is a non-boolean ``int`` present in the set.
    """

    return (
        isinstance(value, int) and not isinstance(value, bool) and value in issue_nums
    )


def _validate_mutation_item_key(
    entry: dict[str, object], entry_context: str, op: object, issue_nums: set[int]
) -> list[str]:
    """Validate ``item_key`` against the op-specific rule in schema S5.

    Args:
        entry (dict[str, object]): One object-shaped mutation record.
        entry_context (str): Context prefix naming this entry.
        op (object): The entry's ``op`` value, already read by the caller.
        issue_nums (set[int]): Resolvable primary keys.

    Returns:
        list[str]: At most one error. An out-of-enum ``op`` produces none,
        because the key rule is undefined for an operation that does not exist.
    """

    item_key = entry.get("item_key")
    # The two branches split on whether the operation is item-scoped: close is
    # a run-level record and must carry no key, while add, remove, and requeue
    # each name exactly one tracked item.
    if op == "close":
        if item_key is not None:
            return [
                f"{entry_context} item_key must be null for op 'close'; "
                f"found: {item_key!r}."
            ]
        return []
    if op in OPS_REQUIRING_ITEM_KEY and not _resolves(item_key, issue_nums):
        return [
            f"{entry_context} item_key {item_key!r} does not resolve to an "
            f"items[].issue_num."
        ]
    return []


def _validate_mutation_state_field(
    entry: dict[str, object],
    entry_context: str,
    field: str,
    op: object,
    null_ops: tuple[str, ...],
) -> list[str]:
    """Validate ``prior_state`` or ``new_state`` against schema S5.

    Args:
        entry (dict[str, object]): One object-shaped mutation record.
        entry_context (str): Context prefix naming this entry.
        field (str): Either ``prior_state`` or ``new_state``.
        op (object): The entry's ``op`` value.
        null_ops (tuple[str, ...]): Operations for which the field must be null.

    Returns:
        list[str]: At most one error. Null always satisfies the field's type;
        the op-specific rule is checked before enum membership so an ``add``
        carrying a valid state reports the rule it actually broke.
    """

    value = entry.get(field)
    if value is None:
        return []
    if op in null_ops:
        return [
            f"{entry_context} {field} must be null for op {op!r}; found: {value!r}."
        ]
    if value not in VALID_ITEM_STATES:
        return [
            f"{entry_context} {field} must be null or one of "
            f"{', '.join(VALID_ITEM_STATES)}; found: {value!r}."
        ]
    return []


def _validate_mutation_disposition(
    entry: dict[str, object], entry_context: str, op: object
) -> list[str]:
    """Validate ``disposition`` against invariant 17.

    Args:
        entry (dict[str, object]): One object-shaped mutation record.
        entry_context (str): Context prefix naming this entry.
        op (object): The entry's ``op`` value.

    Returns:
        list[str]: At most one error. An in-flight removal must record how the
        running work was disposed of; every other entry must leave the field
        null, so a stray disposition cannot imply a decision never taken.
    """

    disposition = entry.get("disposition")
    if op == "remove" and entry.get("prior_state") == "in_flight":
        if disposition not in VALID_DISPOSITIONS:
            return [
                f"{entry_context} disposition must be one of "
                f"{', '.join(VALID_DISPOSITIONS)} for an in-flight removal; "
                f"found: {disposition!r}."
            ]
        return []
    if disposition is not None:
        return [
            f"{entry_context} disposition must be null unless op is 'remove' "
            f"with prior_state 'in_flight'; found: {disposition!r}."
        ]
    return []


def _validate_mutation_generation(
    entry: dict[str, object], entry_context: str, recolor_generation: object
) -> list[str]:
    """Validate a mutation's ``recolor_generation`` against schema S5.

    Args:
        entry (dict[str, object]): One object-shaped mutation record.
        entry_context (str): Context prefix naming this entry.
        recolor_generation (object): The top-level generation counter.

    Returns:
        list[str]: At most one error. The upper-bound comparison is skipped
        when the top-level counter is itself malformed, so one underlying
        defect is not reported twice.
    """

    generation = entry.get("recolor_generation")
    if not is_non_negative_integer(generation):
        return [
            f"{entry_context} recolor_generation must be a non-negative "
            f"integer; found: {generation!r}."
        ]
    if is_non_negative_integer(recolor_generation) and cast("int", generation) > cast(
        "int", recolor_generation
    ):
        return [
            f"{entry_context} recolor_generation {generation} must not exceed "
            f"recolor_generation {recolor_generation}."
        ]
    return []


def validate_mutations(
    mutations: object, issue_nums: set[int], recolor_generation: object, context: str
) -> list[str]:
    """Validate ``mutations[]`` against invariants 16 and 17 (schema S5).

    Args:
        mutations (object): The candidate ``mutations`` value as deserialized.
        issue_nums (set[int]): Resolvable primary keys.
        recolor_generation (object): The top-level generation counter.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: One error per violated condition, in field order per entry.
        A non-list value yields exactly one error; an empty list is valid,
        because a run that has never mutated records no entries.
    """

    if not isinstance(mutations, list):
        return [f"{context} mutations must be a list."]

    errors: list[str] = []
    # Validate every record: the mutation log is the audit trail for admissions
    # and removals, so a single malformed entry must not mask later ones.
    for position, entry in enumerate(cast("list[object]", mutations)):
        entry_context = f"{context} mutations[{position}]"
        if not isinstance(entry, dict):
            errors.append(f"{entry_context} must be an object.")
            continue
        record = cast("dict[str, object]", entry)

        op = record.get("op")
        if op not in VALID_MUTATION_OPS:
            errors.append(enum_error(entry_context, "op", VALID_MUTATION_OPS, op))
        errors.extend(
            _validate_mutation_item_key(record, entry_context, op, issue_nums)
        )
        if not is_non_empty_string(record.get("at")):
            errors.append(f"{entry_context} at must be a non-empty string.")
        errors.extend(
            _validate_mutation_state_field(
                record, entry_context, "prior_state", op, OPS_REQUIRING_NULL_PRIOR_STATE
            )
        )
        errors.extend(
            _validate_mutation_state_field(
                record, entry_context, "new_state", op, OPS_REQUIRING_NULL_NEW_STATE
            )
        )
        errors.extend(_validate_mutation_disposition(record, entry_context, op))
        errors.extend(
            _validate_mutation_generation(record, entry_context, recolor_generation)
        )
    return errors


def validate_drift_events(
    events: object, issue_nums: set[int], context: str
) -> list[str]:
    """Validate ``drift_events[]`` against invariant 18 (schema S6).

    Args:
        events (object): The candidate ``drift_events`` value as deserialized.
        issue_nums (set[int]): Resolvable primary keys.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: One error per violated condition, in field order per entry.
        A non-list value yields exactly one error; an empty list is valid,
        because a run with no drift records no events.
    """

    if not isinstance(events, list):
        return [f"{context} drift_events must be a list."]

    errors: list[str] = []
    # Validate every event: each one is the evidence behind a blocking finding
    # or a halt, so partial reporting would hide part of the audit trail.
    for position, entry in enumerate(cast("list[object]", events)):
        entry_context = f"{context} drift_events[{position}]"
        if not isinstance(entry, dict):
            errors.append(f"{entry_context} must be an object.")
            continue
        record = cast("dict[str, object]", entry)

        item_key = record.get("item_key")
        if not _resolves(item_key, issue_nums):
            errors.append(
                f"{entry_context} item_key {item_key!r} does not resolve to an "
                f"items[].issue_num."
            )
        # declared and observed are the two path sets compared at detection
        # time; both may legitimately be empty, unlike escaped_paths.
        for field in ("declared", "observed"):
            if not is_string_list(record.get(field)):
                errors.append(
                    f"{entry_context} {field} must be a list of non-empty strings."
                )

        escaped_paths = record.get("escaped_paths")
        if not is_string_list(escaped_paths) or not escaped_paths:
            errors.append(
                f"{entry_context} escaped_paths must be a non-empty list of "
                f"non-empty strings."
            )
        if not is_non_empty_string(record.get("at")):
            errors.append(f"{entry_context} at must be a non-empty string.")

        action = record.get("action")
        if action not in VALID_DRIFT_ACTIONS:
            errors.append(
                enum_error(entry_context, "action", VALID_DRIFT_ACTIONS, action)
            )
    return errors


def _estimate_errors(record: dict[str, object], entry_context: str) -> list[str]:
    """Reject a present ``cost`` or ``benefit`` that is not a non-negative integer."""
    return [
        f"{entry_context} {field} must be a non-negative integer; "
        f"found: {record[field]!r}."
        for field in ("cost", "benefit")
        if field in record and not is_non_negative_integer(record[field])
    ]


def _overlap_pair(
    record: dict[str, object], entry_context: str, issue_nums: set[int]
) -> tuple[list[str], tuple[int, int] | None]:
    """Return a tolerated overlap's endpoint errors and its canonical pair, or None."""
    errors: list[str] = []
    endpoints: list[int] = []
    for field in ("a", "b"):
        value = record.get(field)
        if _resolves(value, issue_nums):
            endpoints.append(cast("int", value))
        else:
            errors.append(
                f"{entry_context} {field} {value!r} does not resolve to an "
                f"items[].issue_num."
            )
    if len(endpoints) != 2:
        return errors, None
    first, second = endpoints
    if first == second:
        return [f"{entry_context} endpoints must be distinct; found: {first}."], None
    if first > second:
        return [
            f"{entry_context} must be normalized with a < b; "
            f"found: ({first}, {second})."
        ], None
    return errors, (first, second)


def _reason_errors(reasons: object, entry_context: str) -> list[str]:
    """Check a tolerated overlap's ``reasons``: non-empty, in the enum, never hard."""
    entries = cast("list[object]", reasons) if isinstance(reasons, list) else []
    if not entries or any(entry not in VALID_EDGE_REASONS for entry in entries):
        rule = f"must be a non-empty list drawn from {', '.join(VALID_EDGE_REASONS)}"
    elif any(entry in HARD_EDGE_REASONS for entry in entries):
        rule = "must not contain a hard reason"
    else:
        return []
    return [f"{entry_context} reasons {rule}; found: {reasons!r}."]


def _validate_tolerated_overlaps(
    overlaps: object, issue_nums: set[int], context: str
) -> tuple[list[str], set[tuple[int, int]]]:
    """Validate ``tolerated_overlaps[]`` and collect its canonical pairs."""
    if not isinstance(overlaps, list):
        return [f"{context} tolerated_overlaps must be a list."], set()
    errors: list[str] = []
    pairs: set[tuple[int, int]] = set()
    # Validate every entry in field order so one malformed entry hides no other.
    for position, entry in enumerate(cast("list[object]", overlaps)):
        entry_context = f"{context} tolerated_overlaps[{position}]"
        if not isinstance(entry, dict):
            errors.append(f"{entry_context} must be an object.")
            continue
        record = cast("dict[str, object]", entry)
        endpoint_errors, pair = _overlap_pair(record, entry_context, issue_nums)
        errors.extend(endpoint_errors)
        errors.extend(_reason_errors(record.get("reasons"), entry_context))
        errors.extend(_estimate_errors(record, entry_context))
        if pair is not None:
            pairs.add(pair)
    return errors, pairs


def _edge_errors(edges: object, context: str) -> tuple[list[str], set[tuple[int, int]]]:
    """Check the optional edge estimates and collect each edge's unordered pair."""
    errors: list[str] = []
    pairs: set[tuple[int, int]] = set()
    entries = cast("list[object]", edges) if isinstance(edges, list) else []
    # validate_conflict_edges owns the edge shape; only object entries are read.
    for position, entry in enumerate(entries):
        if not isinstance(entry, dict):
            continue
        record = cast("dict[str, object]", entry)
        entry_context = f"{context} conflict_edges[{position}]"
        if "hard" in record and not isinstance(record["hard"], bool):
            errors.append(f"{entry_context} hard must be a boolean.")
        errors.extend(_estimate_errors(record, entry_context))
        a, b = record.get("a"), record.get("b")
        if is_non_negative_integer(a) and is_non_negative_integer(b) and a != b:
            low, high = sorted((cast("int", a), cast("int", b)))
            pairs.add((low, high))
    return errors, pairs


def _access_list_errors(items: object, context: str) -> list[str]:
    """Check each item's optional access lists against its ``blast_radius.paths``."""
    errors: list[str] = []
    entries = cast("list[object]", items) if isinstance(items, list) else []
    for index, entry in enumerate(entries):
        record = cast("dict[str, object]", entry) if isinstance(entry, dict) else {}
        raw = record.get("blast_radius")
        radius = cast("dict[str, object]", raw) if isinstance(raw, dict) else {}
        paths = radius.get("paths")
        declared = cast("list[object]", paths) if isinstance(paths, list) else []
        for field in (name for name in ACCESS_LIST_FIELDS if name in record):
            prefix = f"{item_context(context, index)} {field}"
            if not is_string_list(record[field]):
                errors.append(f"{prefix} must be a list of non-empty strings.")
                continue
            # A declaration never narrows a radius (spec B5.1, B5.4).
            errors.extend(
                f"{prefix} entry {path!r} is not in blast_radius.paths."
                for path in cast("list[str]", record[field])
                if path not in declared
            )
    return errors


def _precedence_errors(precedence: object, context: str) -> list[str]:
    """Check each precedence entry's optional ``kind`` and its ``reason`` rule."""
    errors: list[str] = []
    entries = cast("list[object]", precedence) if isinstance(precedence, list) else []
    for position, entry in enumerate(entries):
        if not isinstance(entry, dict) or "kind" not in entry:
            continue
        record = cast("dict[str, object]", entry)
        entry_context, kind = f"{context} precedence[{position}]", record["kind"]
        if kind not in VALID_PRECEDENCE_KINDS:
            errors.append(
                enum_error(entry_context, "kind", VALID_PRECEDENCE_KINDS, kind)
            )
        elif kind == "correctness" and not is_non_empty_string(record.get("reason")):
            errors.append(
                f"{entry_context} reason must be a non-empty string when kind is "
                f"'correctness'."
            )
    return errors


def validate_scheduling_decisions(
    state: dict[str, object], issue_nums: set[int], context: str
) -> list[str]:
    """Validate the recorded scheduling estimates and verdicts (issue #1164, B10.1).

    Every check is presence-gated, so a checkpoint without the fields yields no
    error (B10.2). Returns edge estimate errors, tolerated-overlap errors, one
    both-lists error per shared unordered pair in ascending order, item
    access-list errors, then precedence ``kind`` and ``reason`` errors.
    """
    errors, edge_pairs = _edge_errors(state.get("conflict_edges"), context)
    overlap_pairs: set[tuple[int, int]] = set()
    if "tolerated_overlaps" in state:
        overlap_errors, overlap_pairs = _validate_tolerated_overlaps(
            state["tolerated_overlaps"], issue_nums, context
        )
        errors.extend(overlap_errors)
    # A pair is either an edge or tolerated, never both (spec Data & State).
    errors.extend(
        f"{context} pair ({first}, {second}) is in both conflict_edges and "
        f"tolerated_overlaps."
        for first, second in sorted(edge_pairs & overlap_pairs)
    )
    errors.extend(_access_list_errors(state.get("items"), context))
    errors.extend(_precedence_errors(state.get("precedence"), context))
    return errors
