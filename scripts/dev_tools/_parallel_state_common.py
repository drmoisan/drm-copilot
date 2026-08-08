"""Shared enums and shape helpers for the parallel-orchestration validators.

Purpose:
    Own the S4 enumerations of the parallel schema together with the shape
    checks that more than one parallel validator needs: the ``blast_radius``
    block, the per-item record, and the prohibited-key scan. F3 owns these
    vocabularies; F6, F7, and F8 consume them and never extend them.

Responsibilities and usage:
    Provide pure predicates and error-string builders only. This module parses
    nothing, reads nothing from disk, and defines no entry point. Each caller
    supplies its own literal context prefix (``Parallel checkpoint``,
    ``Parallel planner checkpoint``, or ``Parallel manifest``) -- typically via
    ``item_context(prefix, index)`` for an ``items[]`` entry -- so one
    implementation serves all three surfaces, and appends the returned list to
    its own accumulating error list.

Key invariants and constraints:
    Every enum constant is an ordered ``tuple[str, ...]``, not a set: member
    order is load-bearing because ``enum_error`` renders it into the error
    text and the TypeScript parity port must reproduce that text byte for
    byte. Booleans are never accepted where an integer is required, because
    ``bool`` subclasses ``int`` in Python and a boolean in a numeric slot is
    malformed data rather than a value to coerce.

Raises and side effects:
    None anywhere in this module. Every function -- public and private,
    predicate and validator -- is pure: it raises nothing, performs no I/O, and
    reads but never mutates its arguments. Individual docstrings therefore omit
    the ``Raises`` and ``Side Effects`` sections that this module-wide
    statement already covers.
"""

from __future__ import annotations

from typing import cast

# Item lifecycle states (spec S4, design sections 8.2 and 11).
VALID_ITEM_STATES: tuple[str, ...] = tuple(
    "proposed admitted prepared scheduled in_flight merged withdrawn blocked".split()
)

# Per-item merge lifecycle (spec S4, design section 12). The parallel surface
# replaces the epic surface's merge-conflict values with the drift and per-item
# CI-loop failure modes, because a parallel run has no fan-in merge.
VALID_MERGE_STATUS: tuple[str, ...] = tuple(
    (
        "not_started worktree_created pr_open ci_green merged worktree_removed "
        "blocked_drift blocked_ci_loop_limit"
    ).split()
)

# Blast-radius confidence sources (spec S4, design section 5.2). Mirrors
# ``RADIUS_SOURCES`` in ``scripts/dev_tools/compute_blast_radius.py``.
VALID_SOURCES: tuple[str, ...] = ("derived", "declared", "observed")

# Work-item kinds carried by the manifest and the planner checkpoint (spec S4).
VALID_KINDS: tuple[str, ...] = ("feature", "bug")

# Run modes (spec S4, design sections 3 and 8.7); ``closed`` is the default.
VALID_MODES: tuple[str, ...] = ("closed", "open")

# Mutation operations recorded in ``mutations[]`` (spec S4, design section 8.6).
VALID_MUTATION_OPS: tuple[str, ...] = ("add", "remove", "close", "requeue")

# Dispositions for an in-flight removal (spec S4, design section 8.4). A null
# disposition is expressed by absence, not by an enum member.
VALID_DISPOSITIONS: tuple[str, ...] = ("detach", "abandon")

# Conflict-edge reasons, one per disjunct of the design section 5.4 contention
# relation (spec S4, assumption A2), in disjunct evaluation order.
VALID_EDGE_REASONS: tuple[str, ...] = tuple(
    "path_overlap module_overlap shared_surface_overlap contract_dependency".split()
)

# Drift-response actions (spec S4, assumption A8). One event carries the
# strongest action taken; ``halted_later_started_item`` subsumes the finding.
VALID_DRIFT_ACTIONS: tuple[str, ...] = tuple(
    "raised_blocking_finding halted_later_started_item".split()
)

# Merge-status values meaning the item reached a terminal merged outcome; used
# by invariant 8 (state consistency) and invariant 20 (completion gate).
MERGED_MERGE_STATUSES: tuple[str, ...] = ("merged", "worktree_removed")

# Merge-status values meaning the item is blocked, which invariant 8 requires to
# agree with item state ``blocked``.
BLOCKED_MERGE_STATUSES: tuple[str, ...] = ("blocked_drift", "blocked_ci_loop_limit")

# The four ``blast_radius`` collection fields in serialization order, mirroring
# the first four entries of ``RADIUS_KEYS`` in ``compute_blast_radius.py``.
BLAST_RADIUS_LIST_FIELDS: tuple[str, ...] = tuple(
    "paths modules shared_surfaces contracts".split()
)

# Keys the checkpoint schemas reject wherever they appear. ``depends_on`` is
# rejected because ordering is derived from blast-radius overlap and never
# declared; the integration-branch keys are rejected because each parallel item
# opens its own pull request against ``main`` (spec S8, design section 4).
PROHIBITED_ANY_LEVEL_KEYS: tuple[str, ...] = tuple(
    "depends_on integration_branch epic_merge_pr".split()
)

# Path label for the document root in prohibited-key error strings.
ROOT_PATH = "<root>"


def is_non_empty_string(value: object) -> bool:
    """Report whether a value is a string carrying a non-space character.

    Args:
        value (object): Any deserialized JSON or YAML value.

    Returns:
        bool: True for a ``str`` whose stripped form is non-empty. A
        whitespace-only string is rejected because it carries no identifier.
    """

    return isinstance(value, str) and bool(value.strip())


def is_integer(value: object) -> bool:
    """Report whether a value is a genuine integer rather than a boolean.

    Args:
        value (object): Any deserialized JSON or YAML value.

    Returns:
        bool: True for a non-boolean ``int``. The boolean exclusion matters
        because ``bool`` subclasses ``int``, so an unguarded check would admit
        ``true`` in a numeric slot.
    """

    return isinstance(value, int) and not isinstance(value, bool)


def is_positive_integer(value: object) -> bool:
    """Report whether a value is a non-boolean integer greater than zero.

    Args:
        value (object): Any deserialized JSON or YAML value.

    Returns:
        bool: True for an ``int`` above zero. Used for ``issue_num``, the
        parallel schema's primary key, and for ``pr_number``.
    """

    return isinstance(value, int) and not isinstance(value, bool) and value > 0


def is_non_negative_integer(value: object) -> bool:
    """Report whether a value is a non-boolean integer of zero or more.

    Args:
        value (object): Any deserialized JSON or YAML value.

    Returns:
        bool: True for an ``int`` of zero or more. Used for cohort indices,
        generations, ``recolor_generation``, and ``current_cohort``.
    """

    return isinstance(value, int) and not isinstance(value, bool) and value >= 0


def is_string_list(value: object) -> bool:
    """Report whether a value is a list whose every entry is a non-empty string.

    An empty list satisfies the predicate: every blast-radius collection other
    than ``paths`` is legitimately empty for an item that touches no module,
    shared surface, or contract.

    Args:
        value (object): Any deserialized JSON or YAML value.

    Returns:
        bool: True when the value is a ``list`` and every entry passes
        ``is_non_empty_string``. A blank entry fails the whole list because it
        would silently widen a radius and under-report contention.
    """

    if not isinstance(value, list):
        return False
    entries = cast("list[object]", value)
    return all(is_non_empty_string(entry) for entry in entries)


def in_bounded_range(value: object, minimum: int, maximum: int) -> bool:
    """Report whether a value is an integer inside an inclusive numeric range.

    Args:
        value (object): Any deserialized JSON or YAML value.
        minimum (int): Inclusive lower bound.
        maximum (int): Inclusive upper bound.

    Returns:
        bool: True for a non-boolean ``int`` within the bounds. Used for
        ``max_concurrency``, whose accepted range is 1 through 8 (A7).
    """

    if not isinstance(value, int) or isinstance(value, bool):
        return False
    return minimum <= value <= maximum


def enum_error(
    context: str, field: str, members: tuple[str, ...], value: object
) -> str:
    """Build the standard out-of-enum error string for a field.

    All parallel validators render enum violations through this one builder so
    the wording cannot drift between the orchestrator, planner, and manifest
    surfaces and the TypeScript port has a single template to mirror.

    Args:
        context (str): Context prefix naming the object under inspection.
        field (str): Dotted field name relative to that context, for example
            ``state`` or ``blast_radius.source``.
        members (tuple[str, ...]): Accepted values in canonical order; the
            order is rendered into the message and is load-bearing.
        value (object): The offending value, rendered with ``repr`` so a string
            is visibly quoted and ``None`` is distinguishable from ``'None'``.

    Returns:
        str: The complete error string.
    """

    return f"{context} {field} must be one of {', '.join(members)}; found: {value!r}."


def item_context(context: str, index: int) -> str:
    """Render the context prefix for one ``items[]`` entry.

    The positional index is used rather than ``issue_num`` because the index
    exists for every entry, including one whose ``issue_num`` is missing or
    malformed, so every item error names its subject unambiguously.

    Args:
        context (str): Surface prefix, for example ``Parallel checkpoint``.
        index (int): Zero-based position of the entry within ``items``.

    Returns:
        str: The item-scoped prefix, for example
        ``Parallel checkpoint items[0]``.
    """

    return f"{context} items[{index}]"


def validate_blast_radius_block(radius: object, context: str) -> list[str]:
    """Validate one ``blast_radius`` block against spec invariant 9.

    Enforces the serialized shape emitted by
    ``scripts/dev_tools/compute_blast_radius.py`` -- the four collection
    fields, the confidence ``source``, and ``computed_at`` -- wherever a radius
    appears: manifest items, planner items, and checkpoint items.

    Args:
        radius (object): The candidate ``blast_radius`` value as deserialized.
        context (str): Context prefix naming the owning object, for example
            ``Parallel checkpoint items[0]``.

    Returns:
        list[str]: One error per violated condition, in field order: the four
        list fields, then ``source``, then ``computed_at``. A non-object block
        yields exactly one error, because no field check is meaningful without
        a mapping to read fields from. An empty list means invariant 9 holds.
    """

    if not isinstance(radius, dict):
        return [f"{context} blast_radius must be an object."]
    block = cast("dict[str, object]", radius)

    errors: list[str] = []
    # Report every malformed collection field rather than stopping at the
    # first, so one validation pass tells the author everything to fix.
    for field in BLAST_RADIUS_LIST_FIELDS:
        if not is_string_list(block.get(field)):
            errors.append(
                f"{context} blast_radius.{field} must be a list of "
                f"non-empty strings."
            )

    source = block.get("source")
    if source not in VALID_SOURCES:
        errors.append(enum_error(context, "blast_radius.source", VALID_SOURCES, source))

    if not is_non_empty_string(block.get("computed_at")):
        errors.append(f"{context} blast_radius.computed_at must be a non-empty string.")

    return errors


def _validate_merge_status(
    record: dict[str, object], context: str, state: object
) -> list[str]:
    """Validate ``merge_status`` membership and its agreement with item state.

    Absence is the backward-compatible case: an item with no ``merge_status``
    is treated as ``not_started`` (spec S2) and yields no error, so the check
    is presence-gated rather than requirement-gated.

    Args:
        record (dict[str, object]): One ``items[]`` entry.
        context (str): Item-scoped context prefix.
        state (object): The entry's ``state`` value, already read by the
            caller so a single malformed state is reported only once.

    Returns:
        list[str]: At most one error. An out-of-enum value short-circuits the
        consistency rule, because agreement with state is meaningless for a
        value that is not a merge status at all.
    """

    if "merge_status" not in record:
        return []
    merge_status = record["merge_status"]
    if merge_status not in VALID_MERGE_STATUS:
        return [enum_error(context, "merge_status", VALID_MERGE_STATUS, merge_status)]

    # Invariant 8 pins the two terminal families to their item states: a merged
    # or removed worktree implies state 'merged', and either blocked status
    # implies state 'blocked'. Every other status places no constraint.
    if merge_status in MERGED_MERGE_STATUSES and state != "merged":
        return [
            f"{context} merge_status {merge_status!r} requires state "
            f"'merged'; found: {state!r}."
        ]
    if merge_status in BLOCKED_MERGE_STATUSES and state != "blocked":
        return [
            f"{context} merge_status {merge_status!r} requires state "
            f"'blocked'; found: {state!r}."
        ]
    return []


def validate_item_record(
    item: object, context: str, *, require_kind: bool = False
) -> list[str]:
    """Validate one work-item record against spec invariants 5 through 9.

    Args:
        item (object): One ``items[]`` entry as deserialized.
        context (str): Item-scoped context prefix from ``item_context``.
        require_kind (bool): When True, also require ``kind`` in the S4 kind
            enum. The manifest and planner surfaces carry ``kind``; the
            orchestrator checkpoint does not (spec S1, S2, and S3).

    Returns:
        list[str]: One error per violated condition. A non-object entry yields
        exactly one error, because no field is readable without a mapping.
    """

    if not isinstance(item, dict):
        return [f"{context} must be an object."]
    record = cast("dict[str, object]", item)

    errors: list[str] = []
    issue_num = record.get("issue_num")
    if not is_positive_integer(issue_num):
        errors.append(
            f"{context} issue_num must be a positive integer; found: {issue_num!r}."
        )
    if not is_non_empty_string(record.get("feature_folder")):
        errors.append(f"{context} feature_folder must be a non-empty string.")

    state = record.get("state")
    if state not in VALID_ITEM_STATES:
        errors.append(enum_error(context, "state", VALID_ITEM_STATES, state))

    if require_kind:
        kind = record.get("kind")
        if kind not in VALID_KINDS:
            errors.append(enum_error(context, "kind", VALID_KINDS, kind))

    errors.extend(_validate_merge_status(record, context, state))
    errors.extend(validate_blast_radius_block(record.get("blast_radius"), context))
    return errors


def validate_items(
    items: object, context: str, *, require_kind: bool = False
) -> list[str]:
    """Validate the ``items`` collection, including ``issue_num`` uniqueness.

    Args:
        items (object): The candidate ``items`` value as deserialized.
        context (str): Surface prefix, for example ``Parallel checkpoint``.
        require_kind (bool): Forwarded to ``validate_item_record``.

    Returns:
        list[str]: Per-entry errors in positional order, followed by one
        duplicate-key error per repeated ``issue_num`` in ascending key order.
        A non-list value yields exactly one error. An empty list is valid: a
        manifest may be authored before any item is admitted (spec S1).
    """

    if not isinstance(items, list):
        return [f"{context} items must be a list."]
    entries = cast("list[object]", items)

    errors: list[str] = []
    seen: set[int] = set()
    duplicates: set[int] = set()
    # Validate each entry in place, and in the same pass accumulate the primary
    # keys so uniqueness is decided without a second traversal.
    for index, entry in enumerate(entries):
        errors.extend(
            validate_item_record(
                entry, item_context(context, index), require_kind=require_kind
            )
        )
        if not isinstance(entry, dict):
            continue
        issue_num = cast("dict[str, object]", entry).get("issue_num")
        if not isinstance(issue_num, int) or isinstance(issue_num, bool):
            continue
        if issue_num in seen:
            duplicates.add(issue_num)
        seen.add(issue_num)

    # Report duplicates in ascending key order so the message sequence is
    # reproducible regardless of the order the entries appeared in.
    for issue_num in sorted(duplicates):
        errors.append(f"{context} has duplicate items[].issue_num: {issue_num}.")
    return errors


def _prohibited_key_errors(
    value: object, path: str, context: str, keys: tuple[str, ...]
) -> list[str]:
    """Walk one deserialized subtree and report prohibited keys inside it.

    Args:
        value (object): The subtree to inspect; only dicts and lists recurse.
        path (str): Path of ``value``, ``ROOT_PATH`` at the document root.
        context (str): Surface prefix used in every emitted error.
        keys (tuple[str, ...]): Key names rejected anywhere in this subtree.

    Returns:
        list[str]: One error per prohibited key found, in document order
        (depth-first, mapping keys in insertion order), so the sequence is
        reproducible in the TypeScript parity port.
    """

    errors: list[str] = []
    # Mappings are the only place a key can appear, and lists are traversed
    # only to reach the mappings nested inside them.
    if isinstance(value, dict):
        for key, child in cast("dict[str, object]", value).items():
            if key in keys:
                errors.append(f"{context} carries prohibited key '{key}' at {path}.")
            child_path = key if path == ROOT_PATH else f"{path}.{key}"
            errors.extend(_prohibited_key_errors(child, child_path, context, keys))
    elif isinstance(value, list):
        for index, entry in enumerate(cast("list[object]", value)):
            errors.extend(
                _prohibited_key_errors(entry, f"{path}[{index}]", context, keys)
            )
    return errors


def scan_prohibited_keys(
    root: object,
    context: str,
    *,
    deep_keys: tuple[str, ...] = PROHIBITED_ANY_LEVEL_KEYS,
    top_level_keys: tuple[str, ...] = (),
) -> list[str]:
    """Reject prohibited keys per spec invariants 10 and 11 (manifest M7).

    Args:
        root (object): The whole deserialized artifact.
        context (str): Surface prefix, for example ``Parallel checkpoint``.
        deep_keys (tuple[str, ...]): Keys rejected at any nesting level. The
            checkpoint surfaces use the default; the manifest passes only
            ``depends_on``.
        top_level_keys (tuple[str, ...]): Keys rejected at the document root
            only. Empty for the checkpoint surfaces.

    Returns:
        list[str]: One error per prohibited key occurrence: the deep results in
        document order, then the top-level results in ``top_level_keys`` order.
    """

    errors = _prohibited_key_errors(root, ROOT_PATH, context, deep_keys)
    # The shallow pass exists because manifest M7 bans integration_branch at the
    # top level only, where a nested occurrence is legitimate child data.
    if isinstance(root, dict) and top_level_keys:
        mapping = cast("dict[str, object]", root)
        for key in top_level_keys:
            if key in mapping:
                errors.append(
                    f"{context} carries prohibited key '{key}' at {ROOT_PATH}."
                )
    return errors
