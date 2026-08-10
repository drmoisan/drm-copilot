"""Pure decision engine for the parallel mutation protocol (spec FR1-FR7).

Purpose:
    Decide what a ``/parallel-add``, ``/parallel-remove``, ``/parallel-close``,
    or drift-induced requeue does to a parallel run, and construct the single
    ``mutations[]`` record each successful operation appends. Every function
    here is a pure function of its arguments.

    This module is the feature's single public entry point. The four decision
    functions are defined here; the four mutation-entry constructors are defined
    in ``scripts/dev_tools/_parallel_mutation_entries.py`` and re-exported
    through ``__all__``, and the value objects and exceptions live in
    ``scripts/dev_tools/_parallel_mutation_models.py`` and
    ``scripts/dev_tools/_parallel_mutation_errors.py``. The split exists only to
    keep each file inside the repository's 500-line limit, the same arrangement
    F1 uses for ``_blast_radius_conflicts.py`` and F3 for
    ``_parallel_state_records.py``.

Responsibilities and boundaries:
    This module DECIDES; it never applies. It writes no checkpoint, runs no
    ``git`` or ``gh`` command, and performs no side effect. Applying a decision
    to the checkpoint is the orchestrator's work, and the destructive abandon
    side effects belong to ``scripts/dev_tools/parallel_mutation_abandon_cli.py``.

    It also never colors a graph. Cohort assignment is delegated in full to F2's
    landed Welsh-Powell entry point ``compute_cohorts`` in
    ``scripts/dev_tools/parallel_cohort_computation.py``; this module supplies
    the induced subgraph and derives the ``item_key -> cohort_index`` view from
    the returned cohort list. No part of the coloring, the vertex ordering, or
    the ``(-degree, item_key)`` tie-break is reimplemented here, and the sibling
    ``compute_concurrency_batches`` is not called.

    Conflict edges are an INPUT. The caller produces them over ALL items,
    including in-flight ones, by invoking F1's landed relation
    ``conflicts(a, b, config)`` and mapping each conflicting pair onto an
    ``(int, int)`` tuple of ``items[].issue_num`` values. No function here calls
    ``conflicts``.

Key invariants and constraints:
    Pinning (spec FR4): items in state ``in_flight`` are pinned. Recoloring runs
    over the unstarted subgraph only and never assigns or moves a pinned item,
    so a mutation cannot disturb work already running. It also places unstarted
    items at ABSOLUTE cohort indices at or above the pinned items' index
    (``current_cohort``), and strictly above it whenever an unstarted-to-pinned
    conflict exists, so a deferred candidate cannot be returned to the cohort of
    the pinned item it conflicts with.

    Item keys are ``int`` throughout -- F3's ``items[].issue_num``
    (``.claude/rules/parallel-orchestration.md`` invariant 5). No signature here
    accepts or returns a ``str`` key.

    Recompute boundary (spec ``Recompute Boundary and Mutation-Log Entry
    Contents``): a deferred add, a removal of an unstarted item, and a
    drift-induced requeue each increment ``recolor_generation`` by exactly one.
    A no-conflict admit, a ``detach``, an ``abandon``, and a ``close`` stamp the
    current generation unchanged. A sequence of N operations from generation
    ``g`` therefore ends at exactly ``g + (number of recompute operations)``.

    The nine parallel enums are F3's and are consumed, never extended.

Raises and side effects:
    Rejections raise the dedicated exceptions re-exported by
    ``scripts/dev_tools/_parallel_mutation_models.py``; a rejected operation
    constructs no entry and changes no state. Every ``mutations[].at`` timestamp
    comes from an injected ``clock: Callable[[], datetime]`` seam, so no function
    here reads the wall clock. Nothing performs file I/O, network access, or RNG
    access, and nothing mutates a caller's argument. Individual docstrings
    therefore omit the ``Side Effects`` section this statement already covers,
    following the convention of ``_parallel_state_records.py``.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools._parallel_mutation_entries import (
    build_add_entry,
    build_close_entry,
    build_remove_entry,
    build_requeue_entry,
)
from scripts.dev_tools._parallel_mutation_models import (
    PINNED_ITEM_STATE,
    AdmissionDecision,
    AdmissionOutcome,
    CloseWhileInFlightRejectedError,
    InFlightRemovalRequiresDispositionError,
    ItemRecord,
    MergedItemRemovalRejectedError,
    RecolorResult,
    RemovalDecision,
    UnknownEnumMemberError,
    UnknownItemError,
)
from scripts.dev_tools._parallel_state_common import VALID_DISPOSITIONS
from scripts.dev_tools.parallel_cohort_computation import (
    ParallelCohortInputError,
    compute_cohorts,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

# The engine's public surface: the four decision functions defined here plus the
# four entry constructors re-exported from
# ``scripts/dev_tools/_parallel_mutation_entries.py``. Callers import every name
# below from this module, so the private split is invisible to them.
__all__ = [
    "build_add_entry",
    "build_close_entry",
    "build_remove_entry",
    "build_requeue_entry",
    "decide_admission",
    "decide_close",
    "decide_removal",
    "is_closed_mode_complete",
    "recolor_unstarted",
]


def decide_admission(
    candidate: int,
    conflict_edges: Sequence[tuple[int, int]],
    in_flight: frozenset[int],
    *,
    current_cohort_members: frozenset[int],
) -> AdmissionDecision:
    """Decide whether a candidate joins the current cohort or is deferred.

    Implements spec FR1 step 4 as amended by spec 1.2 design correction C1: the
    candidate is admitted into the current cohort if and only if it shares no
    conflict edge with any member of the current cohort -- both the ``in_flight``
    (pinned) members and the scheduled/unstarted members. Any conflict with a
    current-cohort member defers the candidate, because admitting it would
    schedule contending work into the cohort the next ``max_concurrency`` batch
    launches together, and the deferral is what makes the recolor necessary.

    A conflict with an unstarted item OUTSIDE the current cohort is not a
    deferral: the cohort barrier prevents two items in different cohorts from
    running concurrently, so their conflict is already resolved by the ordering.

    The recolor the deferral triggers is ``recolor_unstarted``, which applies the
    pinned-barrier offset so the deferred candidate cannot be placed back into
    the pinned items' own cohort index.

    Args:
        candidate (int): The candidate's ``items[].issue_num``.
        conflict_edges (Sequence[tuple[int, int]]): Conflict edges over ALL
            items including in-flight ones, each an ``(int, int)`` pair of
            ``items[].issue_num`` values. Produced by the caller from F1's
            ``conflicts(a, b, config)`` relation; this function never calls it.
            Edge direction is irrelevant and the sequence is only read.
        in_flight (frozenset[int]): The pinning set -- keys whose items are in
            state ``in_flight``.
        current_cohort_members (frozenset[int]): The FULL membership of the
            current cohort, including both its pinned members and its
            not-yet-launched ``scheduled`` members. Required and keyword-only:
            a default would silently restore the defective in-flight-only rule,
            and keyword-only placement makes it impossible to pass a different
            set positionally. ``in_flight`` is retained separately because the
            two are semantically distinct -- one is the pinning set, the other is
            cohort membership -- and conflating them in the signature would lose
            that distinction; they are unioned only in the decision below. The
            caller derives this set from re-verified durable state, not from a
            possibly stale checkpoint.

    Returns:
        AdmissionDecision: ``ADMIT_CURRENT_COHORT`` when no edge joins the
        candidate to any key in ``in_flight | current_cohort_members``,
        otherwise ``DEFER_AND_RECOLOR``.

    Raises:
        None. Admission has no rejection branch: an unknown candidate simply
        shares no edge, and rejecting one here would duplicate the caller's own
        resolution of the key against ``items[]``.
    """

    # The candidate may join the current cohort only if it is disjoint from that
    # cohort's WHOLE membership. The union is formed here rather than in the
    # signature so the two sets stay semantically distinct to callers:
    # ``in_flight`` is the pinning set, ``current_cohort_members`` is cohort
    # membership, and every pinned item is also a current-cohort member.
    blocking_keys = in_flight | current_cohort_members

    # Scan every edge for one joining the candidate to a blocking key. Both
    # endpoint positions are checked because edge direction carries no meaning;
    # the first such edge settles the decision, so the scan stops there.
    for first, second in conflict_edges:
        # Either endpoint may be the candidate; a conflict with any blocking key
        # defers, because admitting would schedule contending work into the same
        # cohort that the next max-concurrency batch launches together.
        if first == candidate and second in blocking_keys:
            return AdmissionDecision(candidate, AdmissionOutcome.DEFER_AND_RECOLOR)
        if second == candidate and first in blocking_keys:
            return AdmissionDecision(candidate, AdmissionOutcome.DEFER_AND_RECOLOR)

    return AdmissionDecision(candidate, AdmissionOutcome.ADMIT_CURRENT_COHORT)


def recolor_unstarted(
    unstarted_items: Sequence[int],
    conflict_edges: Sequence[tuple[int, int]],
    pinned: frozenset[int],
    current_generation: int,
    *,
    current_cohort: int,
) -> RecolorResult:
    """Recolor the unstarted subgraph, leaving every pinned item untouched.

    Implements the pinning invariant of spec FR4 as amended by spec 1.2 design
    correction C2: recoloring is a pure function of
    ``(remaining subgraph, pinned set, pinned cohort index)``.

    The pinning guarantee has two parts and the induced subgraph delivers only
    the first. Dropping every edge with an endpoint outside ``unstarted_items``
    excludes pinned VERTICES from the coloring input, so a pinned item is absent
    from the result rather than reassigned, and that absence is what keeps a
    mutation from moving work already running. It does NOT honour the pinned
    CONSTRAINT: an edge joining an unstarted key to a pinned key is dropped along
    with its pinned endpoint, and F2 then treats a candidate with no surviving
    edge as an isolated vertex in local class 0. The pinned constraint is
    honoured separately, by the pinned-barrier offset: ``crosses_pinned`` is
    computed from the FULL edge list before the restriction, and every unstarted
    index is shifted to ``current_cohort + 1`` or above whenever an
    unstarted-to-pinned conflict exists.

    Coloring is DELEGATED IN FULL to F2's landed Welsh-Powell entry point
    ``compute_cohorts``. This function reimplements no part of the coloring, the
    vertex ordering, or the ``(-degree, item_key)`` tie-break, and does not call
    the sibling ``compute_concurrency_batches``. The ``item_key -> cohort_index``
    view is derived from the returned ``list[list[int]]`` in one comprehension.

    The offset is a single uniform shift applied to every color class, so the map
    from F2's local index to the absolute index is injective: two unstarted items
    F2 placed in different classes remain in different cohorts, and two it placed
    in the same class share no edge by F2's own guarantee. F3 invariants 13 and 14
    therefore remain satisfiable, which
    ``tests/scripts/dev_tools/test_parallel_mutation_cohort_invariant_binding.py``
    proves by running F3's landed validator over a constructed checkpoint.

    Args:
        unstarted_items (Sequence[int]): Keys whose items are in an unstarted
            state (``proposed``, ``admitted``, ``prepared``, or ``scheduled``).
            These are the only vertices colored. Keys must be unique.
        conflict_edges (Sequence[tuple[int, int]]): Conflict edges over ALL
            items; the induced subgraph is taken here, so the caller passes the
            full edge list unchanged.
        pinned (frozenset[int]): Keys whose items are ``in_flight``. Used both to
            assert the exclusion the induced subgraph performs -- so a pinned key
            that also appeared in ``unstarted_items`` is caught rather than
            silently colored -- and to compute ``crosses_pinned``.
        current_generation (int): The run's generation before this recolor.
        current_cohort (int): F3's top-level ``current_cohort`` field. This is
            the index the pinned items occupy for as long as they run, because
            the cohort barrier increments ``current_cohort`` only on durable
            confirmation that every cohort item is ``merged`` or
            ``worktree_removed`` and an ``in_flight`` item is neither. Required
            and keyword-only: a default would silently restore the defective
            re-index-from-zero behavior, and keyword-only placement prevents a
            silent transposition with ``current_generation``, the other ``int``
            parameter. It must be derived from re-verified durable state, never
            from a possibly stale checkpoint.

    Returns:
        RecolorResult: Cohort assignments for unstarted items only -- the
        mapping's key set equals the ``unstarted_items`` set exactly and is
        disjoint from ``pinned`` -- with ``generation`` equal to
        ``current_generation + 1``. The assigned indices are ABSOLUTE checkpoint
        cohort indices, not zero-based local color indices: every index is at or
        above ``current_cohort``, and strictly above ``current_cohort`` whenever
        any unstarted item conflicts with a pinned item. The caller writes them
        verbatim into ``cohorts[].index`` without re-basing them.

    Raises:
        UnknownItemError: If a key appears in both ``unstarted_items`` and
            ``pinned``, since it cannot be both a colored vertex and pinned.
        ParallelCohortInputError: If ``current_cohort`` is negative, since F3
            invariant 12 requires a non-negative ``cohorts[].index``; also
            propagated from ``compute_cohorts`` if ``unstarted_items`` holds a
            duplicate key.
    """

    unstarted_keys = frozenset(unstarted_items)
    overlap = unstarted_keys & pinned
    if overlap:
        raise UnknownItemError(min(overlap))

    # A negative index cannot name a cohort: F3 invariant 12 requires every
    # cohorts[].index to be a non-negative integer, so a negative base would
    # produce an unwritable assignment. Reject it with F2's existing input error
    # rather than shifting the whole assignment into invalid territory.
    if current_cohort < 0:
        raise ParallelCohortInputError(
            f"current_cohort must be >= 0 per F3 invariant 12; "
            f"received {current_cohort}.",
            current_cohort,
        )

    # Decide the pinned barrier BEFORE the induced restriction discards the
    # candidate-to-pinned edges: those edges carry a real constraint even though
    # their pinned endpoint is not a colored vertex.
    crosses_pinned = any(
        (first in unstarted_keys and second in pinned)
        or (second in unstarted_keys and first in pinned)
        for first, second in conflict_edges
    )

    # Take the induced subgraph: an edge survives only when BOTH endpoints are
    # unstarted vertices, which restricts the COLORED VERTEX SET to unstarted
    # keys. The dropped edges still carry a constraint; that constraint is not
    # discarded here but honoured separately by ``crosses_pinned`` above and the
    # ``cohort_offset`` barrier below.
    induced_edges = [
        (first, second)
        for first, second in conflict_edges
        if first in unstarted_keys and second in unstarted_keys
    ]

    cohorts = compute_cohorts(unstarted_items, induced_edges)

    # The pinned items hold index ``current_cohort`` for as long as they run, so
    # an unstarted item conflicting with one of them must start strictly above
    # that index. With no such conflict there is nothing to protect, so the
    # unstarted items may share the running cohort and max-concurrency slot
    # filling is preserved. The shift is uniform, keeping the local-to-absolute
    # map injective so F2's distinct color classes stay distinct cohorts.
    cohort_offset = current_cohort + 1 if crosses_pinned else current_cohort

    # Derive the mapping view from F2's cohort list; list position is the local
    # color index, so enumerating it and adding the offset yields the absolute
    # assignment without any recoloring.
    assignments = {
        key: cohort_offset + index
        for index, cohort in enumerate(cohorts)
        for key in cohort
    }

    return RecolorResult(
        cohort_assignments=assignments,
        generation=current_generation + 1,
    )


def decide_removal(
    item_key: int,
    items: Mapping[int, ItemRecord],
    disposition: str | None = None,
) -> RemovalDecision:
    """Decide the outcome of removing one item, per the spec FR2 table.

    The routing table below is the normative FR2 behavior table, one branch per
    row. The decision criteria are the item's current state and, for a pinned
    item only, the caller's explicit disposition:

    - ``proposed``, ``admitted``, ``prepared``, ``scheduled`` -- the item has not
      started, so it is marked ``withdrawn``, its vertex is dropped, and the
      remaining unstarted subgraph is recolored (a recompute).
    - ``in_flight`` with no disposition -- REJECTED. A default is never
      inferred, because the choice between letting running work finish and
      destroying it must be made by the caller (spec constraint 2).
    - ``in_flight`` with ``detach`` -- the item finishes and merges on its own
      and the run stops tracking it; new state ``withdrawn``, no recompute.
    - ``in_flight`` with ``abandon`` -- the same state change, but the caller
      must then execute the destructive side effects through the abandon CLI;
      no recompute. This function performs no side effect.
    - ``merged`` -- REJECTED; the change is already in ``main``.
    - ``withdrawn`` or ``blocked`` -- REJECTED as an unknown removal target,
      since neither is a tracked-and-running item to remove.

    Neither ``detach`` nor ``abandon`` recomputes: the removed item was pinned
    and therefore was never a vertex of the unstarted subgraph, so its departure
    cannot change the induced subgraph. An unstarted item previously deferred
    because of a conflict with it keeps its cohort, which stays valid and only
    potentially conservative; no opportunistic recompute is performed.

    Args:
        item_key (int): The ``items[].issue_num`` to remove.
        items (Mapping[int, ItemRecord]): The run's items keyed by
            ``issue_num``. Read only.
        disposition (str | None): ``detach`` or ``abandon`` for a pinned item;
            None otherwise. Supplying one for an unstarted item is ignored,
            because the disposition disambiguates running work only and F3
            requires it null on any entry that is not an in-flight removal.

    Returns:
        RemovalDecision: The new state, the disposition to record, and whether
        the removal triggers a recompute.

    Raises:
        UnknownItemError: If ``item_key`` names no tracked item, or names an
            item already ``withdrawn`` or ``blocked``.
        InFlightRemovalRequiresDispositionError: If the item is ``in_flight``
            and no disposition was supplied.
        MergedItemRemovalRejectedError: If the item is already ``merged``.
        UnknownEnumMemberError: If a pinned removal's ``disposition`` is outside
            F3's ``{detach, abandon}``.
    """

    record = items.get(item_key)
    if record is None:
        raise UnknownItemError(item_key)

    # An unstarted item is a vertex of the recolored subgraph, so dropping it
    # changes the induced subgraph and the removal recomputes.
    if record.is_unstarted:
        return RemovalDecision(
            item_key=item_key,
            prior_state=record.state,
            new_state="withdrawn",
            disposition=None,
            triggers_recompute=True,
        )

    if record.is_pinned:
        if disposition is None:
            raise InFlightRemovalRequiresDispositionError(item_key)
        if disposition not in VALID_DISPOSITIONS:
            raise UnknownEnumMemberError(item_key, "disposition", disposition)
        return RemovalDecision(
            item_key=item_key,
            prior_state=PINNED_ITEM_STATE,
            new_state="withdrawn",
            disposition=disposition,
            triggers_recompute=False,
        )

    if record.state == "merged":
        raise MergedItemRemovalRejectedError(item_key)

    # Only withdrawn and blocked remain: neither is a live removal target, so
    # the request names nothing this run can remove.
    raise UnknownItemError(item_key)


def decide_close(items: Mapping[int, ItemRecord]) -> None:
    """Gate a run close on no item being in flight (spec FR3).

    A close terminates an ``open``-mode run's admissions, so it is rejected
    while work is still running rather than abandoning that work implicitly. All
    in-flight keys are collected before raising, so the caller can report every
    blocking item at once instead of discovering them one close at a time.

    A rejected close appends no ``mutations[]`` entry and changes no state,
    which is why this function returns nothing on success: the caller builds the
    single run-scoped entry itself via ``build_close_entry``.

    Args:
        items (Mapping[int, ItemRecord]): The run's items keyed by
            ``issue_num``. Read only.

    Returns:
        None. Returning normally means the close is permitted.

    Raises:
        CloseWhileInFlightRejectedError: If any item is ``in_flight``, carrying
            every blocking key.
    """

    # Collect every pinned key rather than stopping at the first, so the
    # rejection names all the work that must finish before the run can close.
    in_flight_keys = tuple(key for key, record in items.items() if record.is_pinned)
    if in_flight_keys:
        raise CloseWhileInFlightRejectedError(in_flight_keys)


def is_closed_mode_complete(items: Mapping[int, ItemRecord]) -> bool:
    """Report whether a ``closed``-mode run has reached completion (spec FR7).

    The predicate mirrors F3's completion gate (invariant 20): every
    non-withdrawn item must carry a terminal ``merge_status`` of ``merged`` or
    ``worktree_removed``. A withdrawn item is exempt because it left the run
    before reaching a merge outcome, so requiring a terminal status of it would
    make every run that dropped an item permanently incompletable.

    This predicate answers the ``closed``-mode question only. An ``open``-mode
    run never auto-completes and terminates solely through ``/parallel-close``,
    so the caller must not consult this function to complete an open run; the
    FR9 validator helper enforces that separation on the checkpoint.

    Args:
        items (Mapping[int, ItemRecord]): The run's items keyed by
            ``issue_num``. Read only.

    Returns:
        bool: True when every non-withdrawn item has a terminal merge status.
        An empty mapping returns True, since a run tracking no item has no
        outstanding work.

    Raises:
        None.
    """

    # Check every non-withdrawn item; one item short of a terminal status is
    # enough to keep the run open, so the scan can stop at the first such item.
    return all(
        record.has_terminal_merge_status
        for record in items.values()
        if record.state != "withdrawn"
    )
