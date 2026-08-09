"""Pure radius-drift detection for the parallel orchestration surface.

Purpose:
    Provide the execution-time half of the paired under-reporting mitigation of
    design section 13.1: compare an item's observed diff against its declared
    blast radius, recompute contention with the observed radius, and build the
    records the parent writes into the parallel checkpoint. F1's plan-time
    coverage validation is the other half and is never re-derived here.

Responsibilities:
    Escape detection, ``drift_events[]`` record construction, the derived
    quiesce predicate, and conflict recomputation against an observed radius.
    Halt selection and the requeue seam live in ``parallel_drift_halt`` and are
    re-exported here, so callers keep one public import location. This module
    owns no schema: F3 owns every enum and field name, and the vocabularies are
    imported from ``_parallel_state_common`` rather than restated, so producer
    and consumer cannot desynchronize.

Boundaries:
    Path subsumption is F1's ``is_path_subsumed`` (IC-1a) and the contention
    relation is F1's ``conflicts`` (IC-1b); neither is reimplemented, and no
    ``fnmatch`` fallback is used. Observed radii come from
    ``parallel_drift_resolution.build_observed_radius``, whose module docstring
    records the IC-1b hand-construction prohibition.
    ``conflict_edges[]`` is read only, and no ``depends_on`` or
    ``integration_branch`` field is produced anywhere (invariants 10, 11).

Raises and side effects:
    Every function is pure: no filesystem, subprocess, network, or wall-clock
    access, and no argument is mutated. Every timestamp is an input, so identical
    inputs produce identical outputs. Individual docstrings therefore omit the
    ``Side Effects`` section this module-wide statement already covers.
"""

from __future__ import annotations

from collections.abc import Mapping
from typing import TYPE_CHECKING, cast

from scripts.dev_tools._blast_radius_glob import is_path_subsumed
from scripts.dev_tools._parallel_drift_shape import (
    ParallelDriftInputError,
    as_item_key,
    canonical_pair,
    is_later_canonical_timestamp,
    record_paths,
    require_enum_member,
    require_item_key,
    require_paths,
    require_text,
)
from scripts.dev_tools._parallel_state_common import (
    VALID_DRIFT_ACTIONS,
    VALID_ITEM_STATES,
    is_positive_integer,
)
from scripts.dev_tools.compute_blast_radius import (
    RADIUS_SOURCE_OBSERVED,
    BlastRadius,
    conflicts,
)
from scripts.dev_tools.parallel_drift_halt import (
    ITEM_STATE_IN_FLIGHT,
    ItemStart,
    RequeueRequest,
    request_requeue_via_recolor,
    select_halted_item,
)
from scripts.dev_tools.parallel_drift_resolution import build_observed_radius

if TYPE_CHECKING:
    from collections.abc import Sequence

__all__ = [
    "DRIFT_ACTION_HALTED_LATER_STARTED_ITEM",
    "DRIFT_ACTION_RAISED_BLOCKING_FINDING",
    "DRIFT_EVENT_KEYS",
    "ITEM_STATE_IN_FLIGHT",
    "ItemStart",
    "ParallelDriftInputError",
    "RequeueRequest",
    "build_drift_event",
    "detect_escaped_paths",
    "has_unresolved_drift",
    "recompute_conflicts_with_observed",
    "request_requeue_via_recolor",
    "select_halted_item",
    "unresolved_drift_item_keys",
]

# The six ``drift_events[]`` fields of design section 12, in serialization order.
# F3's invariant 18 fixes this key set; F8 adds nothing to it.
DRIFT_EVENT_KEYS: tuple[str, ...] = tuple(
    "item_key declared observed escaped_paths at action".split()
)

# The two action members F3 defines, checked against ``VALID_DRIFT_ACTIONS`` at use
# time. There is no ``resolved`` member: resolution is derived (see
# ``unresolved_drift_item_keys``), never recorded.
DRIFT_ACTION_RAISED_BLOCKING_FINDING = "raised_blocking_finding"
DRIFT_ACTION_HALTED_LATER_STARTED_ITEM = "halted_later_started_item"


def detect_escaped_paths(
    changed: Sequence[str], declared: Sequence[str]
) -> tuple[str, ...]:
    """Return the changed paths not subsumed by a declared blast radius.

    Each changed path is tested independently against the declared entries with
    F1's ``is_path_subsumed`` (IC-1a), the same coverage relation F1's V1 rule
    applies at plan time; one predicate at both times is what keeps plan-time
    validation and execution-time drift from disagreeing. A rename appears in a
    diff as two paths, so old and new are each tested and either one escaping is
    reported, which is the fail-closed direction.

    Args:
        changed (Sequence[str]): Observed repository-relative paths, typically
            ``git diff --name-only`` output against the merge base. Entries must be
            non-empty strings; the collection may be empty.
        declared (Sequence[str]): The item's declared ``blast_radius.paths``, which
            may mix concrete paths, listed directories, and globs. An empty
            collection covers nothing, so every changed path escapes.

    Returns:
        tuple[str, ...]: The escaping paths, deduplicated and ordinally sorted.
        Every member is a member of ``changed``; empty means no escape.

    Raises:
        ParallelDriftInputError: If either argument is a bare string or holds a
            blank or non-string entry.
    """
    changed_paths = require_paths(changed, "changed", allow_empty=True)
    declared_paths = require_paths(declared, "declared", allow_empty=True)

    # Keep the paths no declared entry covers; the declared collection is passed
    # whole so the predicate applies all three of its coverage rules.
    return tuple(
        path for path in changed_paths if not is_path_subsumed(path, declared_paths)
    )


def build_drift_event(
    *,
    item_key: int,
    declared: Sequence[str],
    observed: Sequence[str],
    escaped_paths: Sequence[str],
    at: str,
    action: str,
) -> dict[str, object]:
    """Build one ``drift_events[]`` record in the design section 12 shape.

    Per the A8 recording rule the caller appends exactly one record per drift
    occurrence, carrying the strongest action: ``halted_later_started_item``
    subsumes ``raised_blocking_finding``, so an occurrence that halted a
    later-started item produces this record only, and no finding record beside it.

    Args:
        item_key (int): The item's ``issue_num``; a positive, non-boolean integer.
        declared (Sequence[str]): The declared ``blast_radius.paths`` compared at
            detection time. May be empty.
        observed (Sequence[str]): The observed changed-path set compared at
            detection time. May be empty.
        escaped_paths (Sequence[str]): The escaping paths; must be non-empty
            because an event with zero escapes is not a drift event
            (F3 invariant 18).
        at (str): Caller-supplied ISO-8601 timestamp; must be non-empty.
        action (str): A member of F3's ``VALID_DRIFT_ACTIONS``.

    Returns:
        dict[str, object]: A new mapping whose key set is exactly
        ``DRIFT_EVENT_KEYS``, with the three path collections rendered as
        deduplicated, ordinally sorted lists so the record is JSON-serializable
        and byte-stable.

    Raises:
        ParallelDriftInputError: If ``item_key``, ``at``, or a path collection is
            malformed, if ``escaped_paths`` is empty, or if ``action`` is outside
            ``VALID_DRIFT_ACTIONS``.
    """
    return {
        "item_key": require_item_key(item_key, "item_key"),
        "declared": list(require_paths(declared, "declared", allow_empty=True)),
        "observed": list(require_paths(observed, "observed", allow_empty=True)),
        "escaped_paths": list(
            require_paths(escaped_paths, "escaped_paths", allow_empty=False)
        ),
        "at": require_text(at, "at"),
        "action": require_enum_member(action, VALID_DRIFT_ACTIONS, "action"),
    }


def unresolved_drift_item_keys(
    events: Sequence[Mapping[str, object]],
    items: Sequence[Mapping[str, object]],
) -> tuple[int, ...]:
    """Return the item keys whose latest drift event is still unresolved.

    F3's action enum has no ``resolved`` member and rejects an event with zero
    escaped paths, so a clean re-evaluation cannot be recorded as an event at all.
    Resolution is therefore derived from the item's currently recorded
    ``blast_radius``. The latest event for an item key is the one with the greatest
    ``at``, ties broken by append order. It counts as resolved when either
    disjunct holds: the radius widened to cover the escape, so every
    ``escaped_paths`` entry is subsumed by the item's current
    ``blast_radius.paths`` under ``is_path_subsumed``; or the radius was
    re-recorded from a later diff, so ``blast_radius.source == 'observed'`` and its
    ``computed_at`` is strictly greater than the event's ``at``, covering
    remediation that narrowed the diff instead of widening the radius. Both
    timestamps in that second disjunct must carry the canonical
    ``yyyy-MM-ddTHH-mm`` shape of ``CANONICAL_TIMESTAMP_RE``; a non-conforming
    value on either side leaves the item unresolved rather than comparing
    ordinally against a differently shaped string. The derivation fails closed: no
    resolvable radius means unresolved.

    Args:
        events (Sequence[Mapping[str, object]]): ``drift_events[]`` in append
            order. An empty sequence yields an empty result.
        items (Sequence[Mapping[str, object]]): The checkpoint's ``items[]``,
            read for ``issue_num`` and ``blast_radius`` only.

    Returns:
        tuple[int, ...]: The unresolved item keys, ordinally sorted.

    Raises:
        ParallelDriftInputError: If an event's ``item_key``, ``at``, or
            ``escaped_paths`` is malformed. Item records are never rejected; an
            unreadable item is treated as unresolved instead.
    """
    latest = _latest_events_by_item(events)
    radii = _radii_by_item_key(items)

    # Keep the drifted items no disjunct clears, sorted for determinism.
    unresolved: list[int] = []
    for item_key, (at, escaped_paths) in latest.items():
        if not _is_drift_resolved(radii.get(item_key), at, escaped_paths):
            unresolved.append(item_key)
    return tuple(sorted(unresolved))


def has_unresolved_drift(
    events: Sequence[Mapping[str, object]],
    items: Sequence[Mapping[str, object]],
) -> bool:
    """Report whether any item carries an unresolved drift event.

    This is the single quiesce predicate F6's admission control consults
    (IC-6a): admission into the current cohort is suspended while it returns
    ``True``. Quiesce is derived state only; no quiesce field is written to the
    checkpoint. The predicate needs the item records as well as the event log
    because resolution is derived from each item's currently recorded
    ``blast_radius`` — see ``unresolved_drift_item_keys`` for the derivation.

    Args:
        events (Sequence[Mapping[str, object]]): ``drift_events[]``, append order.
        items (Sequence[Mapping[str, object]]): The checkpoint's ``items[]``.

    Returns:
        bool: ``True`` while at least one item's latest drift event is unresolved,
        and for a malformed event log; ``False`` otherwise.
    """
    # A malformed event log cannot be shown resolved, so the predicate reports drift
    # rather than propagating: quiesce is the safe verdict, and the shape error is
    # reported by the checkpoint validator.
    try:
        return bool(unresolved_drift_item_keys(events, items))
    except ParallelDriftInputError:
        return True


def recompute_conflicts_with_observed(
    items: Sequence[Mapping[str, object]],
    drifting_item_key: int,
    observed_paths: Sequence[str],
    conflict_edges: Sequence[Mapping[str, object]],
    config: Mapping[str, object],
    *,
    computed_at: str,
) -> tuple[tuple[int, int], ...]:
    """Return the pairs that newly conflict once the observed radius is used.

    Design section 7 step 4: substitute the drifting item's observed radius for
    its declared one and re-evaluate F1's contention relation against every
    concurrently in-flight peer. The observed radius comes from
    ``build_observed_radius``. ``conflict_edges[]`` is read only, for edge identity
    alone, and gains no field. Identity is the canonical ``(a, b)`` pair with
    ``a < b`` (F3 invariant 15), normalized before comparison so an edge recorded
    in either order is recognized as already known. The recomputation fails
    closed twice over: a peer whose ``blast_radius`` cannot be evaluated counts
    as conflicting, and an unreadable existing edge is treated as absent so a
    conflict over that pair is still reported.

    Args:
        items (Sequence[Mapping[str, object]]): The checkpoint's ``items[]``.
            Only entries whose ``state`` is ``in_flight`` and whose ``issue_num``
            differs from ``drifting_item_key`` are evaluated.
        drifting_item_key (int): ``issue_num`` of the item whose diff escaped.
        observed_paths (Sequence[str]): The observed changed-path set. May be
            empty; an empty radius conflicts with nothing.
        conflict_edges (Sequence[Mapping[str, object]]): The checkpoint's
            ``conflict_edges[]``, read for already-known pairs only.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``,
            forwarded to the library. Passing it in keeps this function pure.
        computed_at (str): ISO-8601 timestamp recorded on the observed radius.

    Returns:
        tuple[tuple[int, int], ...]: The newly conflicting canonical pairs,
        ordinally sorted; empty when the escape introduces no new conflict. Each
        pair is an input to ``select_halted_item``.

    Raises:
        ParallelDriftInputError: If ``drifting_item_key``, ``computed_at``,
            ``observed_paths``, or an ``items[].issue_num`` is malformed.
        TypeError: If ``config`` is not a mapping, raised by the library.
    """
    drifting = require_item_key(drifting_item_key, "drifting_item_key")
    in_flight = require_enum_member(
        ITEM_STATE_IN_FLIGHT, VALID_ITEM_STATES, "items[].state"
    )
    observed_radius = build_observed_radius(
        observed_paths, config, computed_at=computed_at
    )
    existing = _existing_edge_pairs(conflict_edges)

    # Evaluate the observed radius against every concurrently in-flight peer,
    # skipping the drifting item and any pair the checkpoint already records, so
    # only newly introduced contention is returned.
    newly_conflicting: set[tuple[int, int]] = set()
    for index, item in enumerate(items):
        item_key = require_item_key(item.get("issue_num"), f"items[{index}].issue_num")
        if item_key == drifting or item.get("state") != in_flight:
            continue
        pair = canonical_pair(drifting, item_key)
        if pair in existing:
            continue
        if _observed_contends(observed_radius, item.get("blast_radius"), config):
            newly_conflicting.add(pair)
    return tuple(sorted(newly_conflicting))


def _latest_events_by_item(
    events: Sequence[Mapping[str, object]],
) -> dict[int, tuple[str, tuple[str, ...]]]:
    """Reduce a drift-event log to the latest event of each item.

    Args:
        events (Sequence[Mapping[str, object]]): ``drift_events[]`` in append
            order. Each entry must carry a positive integer ``item_key``, a
            non-empty ``at``, and a non-empty ``escaped_paths`` string list.

    Returns:
        dict[int, tuple[str, tuple[str, ...]]]: Item key mapped to its latest
        event's ``at`` and escaped paths, latest meaning the greatest ``at`` with
        ties broken by append order so the later-appended record wins.

    Raises:
        ParallelDriftInputError: If an entry's ``item_key``, ``at``, or
            ``escaped_paths`` is malformed.
    """
    # Track the winning rank beside the payload so one pass over the append-ordered
    # log resolves the latest event for every item.
    ranked: dict[int, tuple[tuple[str, int], str, tuple[str, ...]]] = {}
    for index, event in enumerate(events):
        context = f"drift_events[{index}]"
        item_key = require_item_key(event.get("item_key"), f"{context}.item_key")
        at = require_text(event.get("at"), f"{context}.at")
        escaped_paths = record_paths(event.get("escaped_paths"))
        if not escaped_paths:
            raise ParallelDriftInputError(
                f"{context}.escaped_paths must be a non-empty list of "
                f"non-empty strings; found: {event.get('escaped_paths')!r}."
            )
        rank = (at, index)
        current = ranked.get(item_key)
        if current is None or rank > current[0]:
            ranked[item_key] = (rank, at, escaped_paths)

    return {item_key: (at, paths) for item_key, (_, at, paths) in ranked.items()}


def _radii_by_item_key(
    items: Sequence[Mapping[str, object]],
) -> dict[int, Mapping[str, object]]:
    """Index the readable ``blast_radius`` blocks by item key.

    Args:
        items (Sequence[Mapping[str, object]]): The checkpoint's ``items[]``.

    Returns:
        dict[int, Mapping[str, object]]: Item key mapped to its radius block. An
        item with an unreadable ``issue_num`` or a non-mapping ``blast_radius``
        is omitted, and the caller treats absence as unresolved (fail closed).
    """
    # Skip rather than reject an unreadable record: the derivation fails closed on
    # absence, and shape reporting belongs to the validator.
    radii: dict[int, Mapping[str, object]] = {}
    for item in items:
        item_key = item.get("issue_num")
        radius = item.get("blast_radius")
        if is_positive_integer(item_key) and isinstance(radius, Mapping):
            radii[cast("int", item_key)] = cast("Mapping[str, object]", radius)
    return radii


def _is_drift_resolved(
    radius: Mapping[str, object] | None,
    at: str,
    escaped_paths: tuple[str, ...],
) -> bool:
    """Apply the two resolution disjuncts to one item's latest drift event.

    Args:
        radius (Mapping[str, object] | None): The item's recorded
            ``blast_radius``, or ``None`` when no readable radius exists.
        at (str): The latest drift event's ``at`` timestamp. Disjunct (b) requires
            it to carry the canonical ``yyyy-MM-ddTHH-mm`` shape.
        escaped_paths (tuple[str, ...]): The latest drift event's escaped paths.

    Returns:
        bool: ``True`` when the radius widened to cover every escaped path, or was
        re-recorded from a later observed diff. ``False`` otherwise, including for
        a missing or malformed radius, and including whenever either
        ``computed_at`` or ``at`` is not canonically formatted — a non-conforming
        value is unresolved rather than compared ordinally against a differently
        shaped string, which would otherwise fail open.
    """
    if radius is None:
        return False

    # Disjunct (a): the recorded radius now covers everything that escaped.
    declared = record_paths(radius.get("paths"))
    if declared is not None and all(
        is_path_subsumed(path, declared) for path in escaped_paths
    ):
        return True

    # Disjunct (b): the radius was re-recorded from a diff taken after the event.
    # The comparison runs through the canonical-shape predicate rather than a raw
    # ``>``, because ordinally ``-`` sorts below ``:``, so a colon-bearing
    # ``computed_at`` compares greater than a same-instant hyphen-bearing ``at``
    # and an ungated comparison would resolve the drift spuriously.
    return radius.get("source") == RADIUS_SOURCE_OBSERVED and (
        is_later_canonical_timestamp(radius.get("computed_at"), at)
    )


def _existing_edge_pairs(
    conflict_edges: Sequence[Mapping[str, object]],
) -> frozenset[tuple[int, int]]:
    """Collect the canonical pairs already recorded as conflict edges.

    Args:
        conflict_edges (Sequence[Mapping[str, object]]): ``conflict_edges[]``,
            read only; no field is added or changed.

    Returns:
        frozenset[tuple[int, int]]: Canonical ``(a, b)`` pairs with ``a < b``, so
        an edge recorded in either order matches. An edge with unreadable or
        identical endpoints is omitted, leaving a conflict over that pair
        reportable as new (fail closed).
    """
    # Normalize before collecting so a reversed pair is never misread as new.
    pairs: set[tuple[int, int]] = set()
    for edge in conflict_edges:
        first = as_item_key(edge.get("a"))
        second = as_item_key(edge.get("b"))
        if first is None or second is None or first == second:
            continue
        pairs.add(canonical_pair(first, second))
    return frozenset(pairs)


def _observed_contends(
    observed_radius: BlastRadius,
    raw_radius: object,
    config: Mapping[str, object],
) -> bool:
    """Evaluate F1's contention relation between an observed and a peer radius.

    Args:
        observed_radius (BlastRadius): The drifting item's observed radius.
        raw_radius (object): The peer's recorded ``blast_radius`` block.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``.

    Returns:
        bool: The relation's verdict, or ``True`` when the peer radius cannot be
        evaluated. Failing closed matters because the relation reports no conflict
        for an empty radius, so an unevaluable peer would otherwise look safe.

    Raises:
        TypeError: If ``config`` is not a mapping, raised by the library.
    """
    if not isinstance(raw_radius, Mapping):
        return True
    try:
        peer = BlastRadius.from_dict(cast("Mapping[str, object]", raw_radius))
    except (TypeError, ValueError):
        return True
    return conflicts(observed_radius, peer, config).conflict
