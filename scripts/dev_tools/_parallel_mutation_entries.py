"""Mutation-entry constructors and generation accounting (spec FR6).

Purpose, responsibilities, and usage:
    Build the single ``mutations[]`` record each successful parallel mutation
    appends, and stamp it with the correct ``recolor_generation`` per the spec's
    recompute boundary. One constructor covers each ``op``; between them they
    cover all seven op cases of the spec's per-op entry-contents table, because
    ``add`` splits on ``deferred`` and ``remove`` reads the three accepted rows
    off the ``RemovalDecision`` it is given.

    This module is a private implementation detail of
    ``scripts/dev_tools/parallel_mutation_protocol.py``, which re-exports all
    four constructors; callers import from that module, not this one. It lives
    apart only so neither file exceeds the repository's 500-line limit, the same
    arrangement F1 uses for ``_blast_radius_conflicts.py``.

Key invariants and constraints:
    Generation accounting is centralized in ``_stamped_generation``: a recompute
    op stamps ``g + 1`` and a non-recompute op stamps ``g`` unchanged, so a
    sequence of N ops from ``g`` ends at exactly
    ``g + (number of recompute ops)``.

    Recompute ops: deferred add, removal of an unstarted item, drift-induced
    requeue. Non-recompute ops: no-conflict admit, ``detach``, ``abandon``,
    ``close``.

    Both ``add`` cases construct ``prior_state=None``, which is F3's landed rule
    (``.claude/rules/parallel-orchestration.md`` invariant 16 and
    ``_parallel_state_records.OPS_REQUIRING_NULL_PRIOR_STATE``). No field and no
    enum member is added to ``mutations[]`` here.

Raises and side effects:
    ``MutationEntry`` validates every record at construction and raises on a
    contract violation. Every ``at`` timestamp comes from the injected
    ``clock: Callable[[], datetime]`` seam, which is a REQUIRED parameter on
    every constructor, so no function here can read the wall clock. Nothing
    performs file I/O, network access, or RNG access, and nothing mutates a
    caller's argument. Individual docstrings therefore omit the ``Side Effects``
    section this statement already covers.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools._parallel_mutation_models import (
    PINNED_ITEM_STATE,
    MutationEntry,
)

if TYPE_CHECKING:
    from collections.abc import Callable
    from datetime import datetime

    from scripts.dev_tools._parallel_mutation_models import RemovalDecision


def _stamped_generation(current_generation: int, *, recompute: bool) -> int:
    """Return the generation a mutation entry stamps.

    Centralizing the increment keeps the recompute boundary in one place, so a
    recompute op cannot forget to increment and a non-recompute op cannot
    increment by accident.

    Args:
        current_generation (int): The run's generation before the operation.
        recompute (bool): Whether the operation recolors the unstarted subgraph.

    Returns:
        int: ``current_generation + 1`` for a recompute, otherwise
        ``current_generation`` unchanged.

    Raises:
        None.
    """

    return current_generation + 1 if recompute else current_generation


def build_add_entry(
    item_key: int,
    *,
    deferred: bool,
    current_generation: int,
    clock: Callable[[], datetime],
) -> MutationEntry:
    """Build the single ``mutations[]`` entry for an accepted add.

    Covers both add rows of the spec's per-op table. They differ only in the
    generation stamp: a deferred add recolors and stamps ``g + 1``, while a
    no-conflict admit changes no cohort assignment and stamps ``g`` unchanged.

    Both rows construct ``prior_state=None``. This is F3's landed rule
    (``.claude/rules/parallel-orchestration.md`` invariant 16 and
    ``_parallel_state_records.OPS_REQUIRING_NULL_PRIOR_STATE``): ``add`` denotes
    item introduction, so an added item has no prior state to record, and the
    landed validator rejects a non-null value with ``prior_state must be null
    for op 'add'``. The ``prepared -> scheduled`` transition that accompanies the
    admission decision is NOT lost -- it is recorded as an item-state update in
    the checkpoint's ``items[]`` with F3 lifecycle timestamps, the same mechanism
    that records the earlier ``proposed -> admitted -> prepared`` transitions.
    The entry records only the admission outcome and the generation stamp.

    Args:
        item_key (int): The admitted item's ``items[].issue_num``.
        deferred (bool): True for the deferred row (a conflict with a member of
            the current cohort, pinned or unstarted, forced a recolor), False for
            the no-conflict admit row.
        current_generation (int): The run's generation before the add.
        clock (Callable[[], datetime]): Injected clock seam supplying ``at``.
            Required, so this function can never read the wall clock.

    Returns:
        MutationEntry: An ``add`` entry with null ``prior_state``, ``new_state``
        ``scheduled``, null ``disposition``, and the stamped generation.

    Raises:
        MutationEntryContractError: Propagated from ``MutationEntry`` if
            ``item_key`` is not a positive ``int``.
    """

    return MutationEntry(
        op="add",
        item_key=item_key,
        at=clock(),
        prior_state=None,
        new_state="scheduled",
        disposition=None,
        recolor_generation=_stamped_generation(current_generation, recompute=deferred),
    )


def build_remove_entry(
    decision: RemovalDecision,
    *,
    current_generation: int,
    clock: Callable[[], datetime],
) -> MutationEntry:
    """Build the single ``mutations[]`` entry for an accepted removal.

    Covers all three accepted remove rows of the per-op table -- unstarted,
    ``detach``, and ``abandon`` -- from the decision ``decide_removal`` already
    made, so the generation stamp and the disposition cannot disagree with the
    decision that produced them. An unstarted removal recomputes and stamps
    ``g + 1``; ``detach`` and ``abandon`` stamp ``g`` unchanged because the
    removed item was pinned and was never a vertex of the unstarted subgraph.

    Args:
        decision (RemovalDecision): The accepted removal. A rejected removal
            never reaches here, because ``decide_removal`` raises instead of
            returning one.
        current_generation (int): The run's generation before the removal.
        clock (Callable[[], datetime]): Injected clock seam supplying ``at``.

    Returns:
        MutationEntry: A ``remove`` entry carrying the decision's
        ``prior_state``, ``new_state`` ``withdrawn``, the decision's
        ``disposition``, and the stamped generation.

    Raises:
        MutationEntryContractError: Propagated from ``MutationEntry`` if the
            decision's disposition and prior state violate F3 invariant 17.
    """

    return MutationEntry(
        op="remove",
        item_key=decision.item_key,
        at=clock(),
        prior_state=decision.prior_state,
        new_state=decision.new_state,
        disposition=decision.disposition,
        recolor_generation=_stamped_generation(
            current_generation, recompute=decision.triggers_recompute
        ),
    )


def build_close_entry(
    *,
    current_generation: int,
    clock: Callable[[], datetime],
) -> MutationEntry:
    """Build the single run-scoped ``mutations[]`` entry for an accepted close.

    The close row of the per-op table is entirely null except for ``op``, ``at``,
    and the generation: a close is a run-level record, so it names no item, and
    it changes no cohort assignment, so it stamps ``g`` unchanged. F3 requires
    exactly those nulls for ``op == 'close'``.

    Args:
        current_generation (int): The run's generation, stamped unchanged.
        clock (Callable[[], datetime]): Injected clock seam supplying ``at``.

    Returns:
        MutationEntry: A ``close`` entry with null ``item_key``,
        ``prior_state``, ``new_state``, and ``disposition``.

    Raises:
        None.
    """

    return MutationEntry(
        op="close",
        item_key=None,
        at=clock(),
        prior_state=None,
        new_state=None,
        disposition=None,
        recolor_generation=_stamped_generation(current_generation, recompute=False),
    )


def build_requeue_entry(
    item_key: int,
    *,
    current_generation: int,
    clock: Callable[[], datetime],
) -> MutationEntry:
    """Build the single ``mutations[]`` entry for a drift-induced requeue.

    This is the append-and-recolor contract F8 (drift detection, issue 446)
    invokes: the later-started item of a newly conflicting pair is halted and
    requeued into a future cohort. The requeue recolors, so it stamps ``g + 1``,
    and it moves the item from ``in_flight`` to ``blocked`` -- the item state F3
    pairs with ``merge_status`` ``blocked_drift``. ``disposition`` stays null
    because F3 permits a disposition only on a ``remove``.

    Args:
        item_key (int): The requeued item's ``items[].issue_num``.
        current_generation (int): The run's generation before the requeue.
        clock (Callable[[], datetime]): Injected clock seam supplying ``at``.

    Returns:
        MutationEntry: A ``requeue`` entry with ``prior_state`` ``in_flight``,
        ``new_state`` ``blocked``, null ``disposition``, and ``g + 1``.

    Raises:
        MutationEntryContractError: Propagated from ``MutationEntry`` if
            ``item_key`` is not a positive ``int``.
    """

    return MutationEntry(
        op="requeue",
        item_key=item_key,
        at=clock(),
        prior_state=PINNED_ITEM_STATE,
        new_state="blocked",
        disposition=None,
        recolor_generation=_stamped_generation(current_generation, recompute=True),
    )
