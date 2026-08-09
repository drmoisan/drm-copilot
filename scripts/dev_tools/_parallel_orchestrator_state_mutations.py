"""Retrospective mutation-log invariants for the parallel checkpoint (FR9).

Purpose:
    Enforce the three F6 invariants the landed F3 validator does not cover:
    completeness of the seven-field ``mutations[]`` entry shape, monotonically
    non-decreasing ``recolor_generation`` across the log in append order, and
    the mode-dependent completion invariant of spec FR7. Together they make a
    lost update or a mis-stamped generation detectable after the fact from the
    checkpoint alone.

Responsibilities and boundaries:
    This module is F6-owned and is wired into the F3-owned
    ``scripts/dev_tools/validate_parallel_orchestrator_state.py`` by exactly one
    additive import and one call line, following the ``_orchestrator_state_*.py``
    helper convention recorded in ``.claude/rules/orchestrator-state.md``.

    It ADDS to F3 and never restates F3. ``validate_mutations`` in
    ``scripts/dev_tools/_parallel_state_records.py`` already enforces the ``op``
    enum, ``item_key`` resolution against ``items[].issue_num``, the
    ``disposition`` rule of invariant 17, item-state enum membership, the
    generation upper bound, and the NULL side of the nullability rule
    (``prior_state`` null for ``add`` and ``close``, ``new_state`` null for
    ``close``). Restating any of those here would report one defect twice, so
    this module checks only what F3 leaves unchecked: that every one of the
    seven fields is actually PRESENT, that no eighth field was invented, and the
    COMPLETENESS side of the same nullability rule -- a field that F3's rule
    leaves non-null must in fact carry a value. F3 reads absent fields through
    ``dict.get``, so an ``add`` entry that omits ``new_state`` passes F3 today
    and is caught here.

Key invariants and constraints:
    Every check is KEY-GATED. A checkpoint that carries no ``mutations`` key, or
    whose ``mutations`` value is not a list, produces zero errors from this
    module, so an existing checkpoint validates exactly as it did before this
    helper was wired in. The mode-dependent checks additionally require a
    well-formed ``mode`` and a list-shaped ``items``; anything else has already
    produced its own F3 error.

    ``mutations[].item_key`` is an ``int`` resolving to ``items[].issue_num``
    (``.claude/rules/parallel-orchestration.md`` invariant 5); no key is ever a
    ``str``. No field and no enum member is added to ``mutations[]``,
    ``drift_events[]``, ``conflict_edges[]``, or any state or merge-status enum:
    the seven field names and every member set are imported or restated from
    F3's own vocabulary and are consumed, never extended. No JSON Schema file is
    imported or read; enforcement is this logic plus the prose rules.

Mode-dependent completion (spec FR7):
    The third invariant is delegated in full to
    ``scripts/dev_tools/_parallel_orchestrator_state_mode_completion.py``, which
    documents the two completion signals the F3 schema carries -- the run-close
    record and an empty current-generation cohort set -- and the ``open``-mode and
    ``closed``-mode rules expressed over them. The split exists only to keep both
    files inside the 500-line limit; the gate is reached through this module's one
    entry point and is not a separate call site in the F3-owned validator.

Raises and side effects:
    None anywhere in this module. Every function is pure: it raises nothing,
    performs no I/O, and reads but never mutates its arguments. Individual
    docstrings therefore omit the ``Raises`` and ``Side Effects`` sections that
    this module-wide statement already covers, following the convention of
    ``scripts/dev_tools/_parallel_state_records.py``.
"""

from __future__ import annotations

from typing import cast

from scripts.dev_tools._parallel_orchestrator_state_mode_completion import (
    validate_mode_completion,
)
from scripts.dev_tools._parallel_state_common import is_non_negative_integer

# The single entry point the F3-owned validator calls. Listing it here marks the
# re-export as deliberate so static analysis does not read the module as unused.
__all__ = ["validate_mutation_protocol"]

# The one checkpoint key this module gates on directly. Gating on it by name keeps
# every check additive: an absent key is another validator's concern, never an
# error here. The mode-dependent gate reads its own keys in its own module.
MUTATIONS_KEY = "mutations"

# The seven fields of F3's ``mutations[]`` entry (design section 8.6), in
# serialization order. Consumed from F3's shape, never extended.
MUTATION_ENTRY_FIELDS: tuple[str, ...] = tuple(
    "op item_key at prior_state new_state disposition recolor_generation".split()
)

# The run-level operation that carries no ``item_key`` and no state fields.
CLOSE_OP = "close"

# Item-scoped operations, which must carry a resolving ``item_key``.
ITEM_SCOPED_OPS: tuple[str, ...] = tuple("add remove requeue".split())

# Operations whose ``prior_state`` F3 requires to be null; every other operation
# must therefore carry one, which is the completeness side this module checks.
OPS_WITH_NULL_PRIOR_STATE: tuple[str, ...] = tuple("add close".split())

# Operations whose ``new_state`` F3 requires to be null; the run close alone.
OPS_WITH_NULL_NEW_STATE: tuple[str, ...] = (CLOSE_OP,)


def _entry_context(context: str, position: int) -> str:
    """Render the context prefix for one ``mutations[]`` entry.

    The positional index is used rather than ``item_key`` because the index
    exists for every entry, including one whose key is missing, so every error
    names its subject unambiguously. Matches the prefix
    ``_parallel_state_records.py`` emits, so both modules' errors read alike.

    Args:
        context (str): Surface prefix, for example ``Parallel checkpoint``.
        position (int): Zero-based position of the entry within ``mutations``.

    Returns:
        str: The entry-scoped prefix, for example
        ``Parallel checkpoint mutations[0]``.
    """

    return f"{context} mutations[{position}]"


def _validate_entry_field_set(
    record: dict[str, object], entry_context: str
) -> list[str]:
    """Require exactly F3's seven field names on one mutation entry.

    This is the check F3 cannot make: ``validate_mutations`` reads every field
    through ``dict.get``, so an omitted field is indistinguishable there from an
    explicit null and passes. Requiring presence here is what makes a dropped
    field visible, and rejecting an unexpected field is what keeps a wave-4
    feature from quietly widening the F3-owned entry shape.

    Args:
        record (dict[str, object]): One object-shaped mutation entry.
        entry_context (str): Context prefix naming this entry.

    Returns:
        list[str]: One error per missing field in ``MUTATION_ENTRY_FIELDS``
        order, then one error per unexpected field in the entry's own key order
        so the sequence is reproducible.
    """

    errors: list[str] = []
    # Report every missing field rather than the first, so one validation pass
    # tells the author the whole set of fields still to write.
    for field in MUTATION_ENTRY_FIELDS:
        if field not in record:
            errors.append(f"{entry_context} is missing required field: {field}.")

    # Reject anything beyond the seven: the entry shape is F3's and this feature
    # consumes it, so an extra field is an unapproved schema extension.
    for field in record:
        if field not in MUTATION_ENTRY_FIELDS:
            errors.append(
                f"{entry_context} carries unexpected field: {field}; the "
                f"mutations[] entry shape is exactly "
                f"{', '.join(MUTATION_ENTRY_FIELDS)}."
            )
    return errors


def _validate_entry_completeness(
    record: dict[str, object], entry_context: str
) -> list[str]:
    """Require a value wherever F3's nullability rule does not permit null.

    F3 enforces the null side of its own rule -- ``prior_state`` null for ``add``
    and ``close``, ``new_state`` null for ``close``, ``item_key`` null for
    ``close`` -- and stops there, treating a null in any other slot as
    acceptable. This helper enforces the complementary side: an operation whose
    rule leaves a field non-null must actually carry a value, so a lost field is
    reported rather than read as an intentional null.

    The ``item_key`` slot is deliberately omitted: F3 already rejects a null key
    on an item-scoped op as one that "does not resolve to an
    items[].issue_num", and repeating that here would report one defect twice.

    Args:
        record (dict[str, object]): One object-shaped mutation entry.
        entry_context (str): Context prefix naming this entry.

    Returns:
        list[str]: One error per PRESENT field that must carry a value but holds
        null. An absent field yields none here: ``_validate_entry_field_set``
        already reported its absence, and adding a second error would report one
        defect twice. An out-of-enum ``op`` likewise yields none, because the
        rule is undefined for an operation that does not exist and F3 already
        reported the enum violation.
    """

    op = record.get("op")
    # A field is required exactly when this operation is outside the op set for
    # which F3 mandates a null. Both fields share that rule shape and differ
    # only in which op set applies, so one pass keeps them consistent.
    requirements = (
        ("prior_state", OPS_WITH_NULL_PRIOR_STATE),
        ("new_state", OPS_WITH_NULL_NEW_STATE),
    )

    errors: list[str] = []
    for field, null_ops in requirements:
        if op in null_ops or op not in ITEM_SCOPED_OPS:
            continue
        if field in record and record[field] is None:
            errors.append(f"{entry_context} {field} must not be null for op {op!r}.")
    return errors


def _validate_entry_shapes(entries: list[object], context: str) -> list[str]:
    """Apply invariant 1 to every ``mutations[]`` entry (FR9 invariant 1).

    Args:
        entries (list[object]): The checkpoint's ``mutations`` list.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: Per-entry errors in positional order. A non-object entry is
        skipped rather than reported, because F3 already emits
        ``mutations[i] must be an object`` for it and no field of it is readable.
    """

    errors: list[str] = []
    # Check every record: the mutation log is the audit trail for admissions and
    # removals, so one malformed entry must not mask the entries after it.
    for position, entry in enumerate(entries):
        if not isinstance(entry, dict):
            continue
        record = cast("dict[str, object]", entry)
        entry_context = _entry_context(context, position)
        errors.extend(_validate_entry_field_set(record, entry_context))
        errors.extend(_validate_entry_completeness(record, entry_context))
    return errors


def _validate_generation_monotonicity(entries: list[object], context: str) -> list[str]:
    """Require non-decreasing ``recolor_generation`` in append order (FR9 2).

    The mutation log is append-only, and every recompute raises the generation
    by exactly one while every non-recompute operation stamps the current
    generation unchanged. A later entry stamped with an EARLIER generation
    therefore cannot have been produced by that sequence: it is the retrospective
    signature of a lost update, which is why this check exists at all.

    Args:
        entries (list[object]): The checkpoint's ``mutations`` list.
        context (str): Surface prefix, for example ``Parallel checkpoint``.

    Returns:
        list[str]: One error per entry whose generation is below the highest
        generation seen so far, in positional order. Entries whose generation is
        not a non-negative integer are skipped: F3 already reported the shape,
        and comparing against a malformed value would invent a second defect.
    """

    errors: list[str] = []
    highest: int | None = None
    # Walk the log in append order, carrying the highest generation seen. The
    # comparison is against the running maximum rather than the immediately
    # previous entry so a single out-of-order entry does not mask later ones.
    for position, entry in enumerate(entries):
        if not isinstance(entry, dict):
            continue
        generation = cast("dict[str, object]", entry).get("recolor_generation")
        if not is_non_negative_integer(generation):
            continue
        current = cast("int", generation)
        if highest is not None and current < highest:
            errors.append(
                f"{_entry_context(context, position)} recolor_generation "
                f"{current} is below the preceding maximum {highest}; the "
                f"mutation log must be monotonically non-decreasing."
            )
            continue
        highest = current
    return errors


def validate_mutation_protocol(state: dict[str, object], context: str) -> list[str]:
    """Validate the F6 mutation-protocol invariants of a parallel checkpoint.

    This is the single entry point the F3-owned
    ``validate_parallel_orchestrator_state`` module calls, through one additive
    import and one additive call line. It applies the three FR9 invariants:
    completeness of the seven-field ``mutations[]`` entry shape, monotonically
    non-decreasing ``recolor_generation`` in append order, and the
    mode-dependent completion invariant of FR7.

    Args:
        state (dict[str, object]): The parsed checkpoint object. Read only; the
            mapping and every value inside it are left untouched.
        context (str): The surface's literal error prefix, for example
            ``Parallel checkpoint``, supplied by the caller so this module does
            not restate it.

    Returns:
        list[str]: One error string per violated invariant, in invariant order:
        entry-shape errors, then generation-monotonicity errors, then the
        mode-dependent completion errors. An empty list when every invariant
        holds. A checkpoint with no ``mutations`` key, or whose ``mutations``
        value is not a list, returns an empty list: the key gate keeps this
        helper additive, and F3 already reports a non-list value.
    """

    mutations = state.get(MUTATIONS_KEY)
    if MUTATIONS_KEY not in state or not isinstance(mutations, list):
        return []
    entries = cast("list[object]", mutations)

    errors: list[str] = []
    errors.extend(_validate_entry_shapes(entries, context))
    errors.extend(_validate_generation_monotonicity(entries, context))
    errors.extend(validate_mode_completion(state, entries, context))
    return errors
