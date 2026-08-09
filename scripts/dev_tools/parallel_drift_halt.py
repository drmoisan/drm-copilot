"""Later-started halt selection and the single drift requeue seam.

Purpose:
    Decide which item of a newly conflicting pair is halted, and express the
    resulting requeue as data. Split out of ``parallel_drift_detection`` under
    that plan's documented contingency so every drift module stays inside the
    500-line file cap; ``parallel_drift_detection`` re-exports this surface, so
    callers still have one public import location.

Responsibilities:
    Own the start-marker value object, the halt-selection rule with its three
    tie-breaks, and the requeue-request value object plus the seam that builds
    it. This module owns no schema: the item-state, merge-status, and
    mutation-op vocabularies are imported from ``_parallel_state_common``, which
    F3 owns.

Key invariants:
    The LATER-STARTED item of a pair is the one halted, never the drifting item,
    because the drifting item's work is already broader than planned and is more
    expensive to unwind (design section 7). ``select_halted_item`` receives no
    drift information at all, so the rule cannot be inverted by a caller. The
    requeue seam requests a mutation and never performs one (IC-6b).

Raises and side effects:
    Every function is pure: no filesystem, subprocess, network, or wall-clock
    access, and no argument is mutated. Timestamps are inputs. Individual
    docstrings therefore omit the ``Side Effects`` section this module-wide
    statement already covers.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING, cast

from scripts.dev_tools._parallel_drift_shape import (
    ParallelDriftInputError,
    require_enum_member,
    require_generation,
    require_item_key,
    require_text,
)
from scripts.dev_tools._parallel_state_common import (
    VALID_ITEM_STATES,
    VALID_MERGE_STATUS,
    VALID_MUTATION_OPS,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

__all__ = [
    "ITEM_STATE_BLOCKED",
    "ITEM_STATE_IN_FLIGHT",
    "MERGE_STATUS_BLOCKED_DRIFT",
    "MUTATION_OP_REQUEUE",
    "ItemStart",
    "RequeueRequest",
    "request_requeue_via_recolor",
    "select_halted_item",
]

# Enum members this module emits. Each is checked against the F3-owned
# vocabulary at use time by ``require_enum_member``, so a member F3 renamed or
# removed fails at the producer instead of reaching the checkpoint.
ITEM_STATE_IN_FLIGHT = "in_flight"
ITEM_STATE_BLOCKED = "blocked"
MERGE_STATUS_BLOCKED_DRIFT = "blocked_drift"
MUTATION_OP_REQUEUE = "requeue"


@dataclass(frozen=True)
class ItemStart:
    """Start-of-execution marker for one parallel item.

    Purpose:
        Carry the two values halt selection compares, so the selection function
        takes no checkpoint mapping and reads no clock.

    Responsibilities:
        Hold the item's primary key and its start timestamp, and validate both
        at construction. The class applies no ordering rule of its own.

    Key invariants:
        ``item_key`` is a positive, non-boolean integer ``issue_num``.
        ``worktree_created_at`` is the F3 lifecycle field adopted as the start
        marker (IC-3a). F3 marks it optional, so ``None`` and a blank string are
        both accepted and both mean "start unknown".

    Side Effects:
        None; the instance is frozen.

    Attributes:
        item_key (int): The item's ``issue_num``.
        worktree_created_at (str | None): ISO-8601 start timestamp, or ``None``
            when the checkpoint records no start for the item.
    """

    item_key: int
    worktree_created_at: str | None

    def __post_init__(self) -> None:
        """Validate the primary key and the optional timestamp's type.

        Returns:
            None.

        Raises:
            ParallelDriftInputError: If ``item_key`` is not a positive,
                non-boolean integer, or ``worktree_created_at`` is neither
                ``None`` nor a string.
        """
        require_item_key(self.item_key, "ItemStart.item_key")

        # The annotation cannot be enforced at runtime, and a non-string reaching
        # ``_start_rank`` would fail there with an unrelated message, so the type
        # is checked here through a deliberately widened local.
        timestamp = cast("object", self.worktree_created_at)
        if timestamp is not None and not isinstance(timestamp, str):
            raise ParallelDriftInputError(
                "ItemStart.worktree_created_at must be a string or None; "
                f"found: {timestamp!r}."
            )


@dataclass(frozen=True)
class RequeueRequest:
    """Requested, not performed, state change for a drift-halted item.

    Purpose:
        Express the whole effect of design section 7 step 5 as data, so drift
        detection can name the requeue without owning the recolor. F6 (issue
        #442) owns the recolor engine and the checkpoint write.

    Responsibilities:
        Carry the joint item write F3 invariant 8 requires, the single
        ``mutations[]`` entry, and the incremented generation. The class applies
        nothing and writes nothing.

    Key invariants:
        ``merge_status`` and ``state`` travel together because invariant 8
        requires ``blocked_drift`` to accompany item state ``blocked``.
        ``mutation['new_state']`` is the item-state value ``blocked``, not
        ``blocked_drift``, which is a merge status and would be rejected by
        invariant 16 in that slot. ``recolor_generation`` is exactly the prior
        generation plus one.

    Side Effects:
        None; the instance is frozen.

    Attributes:
        item_key (int): ``issue_num`` of the halted item.
        merge_status (str): ``blocked_drift``, to be written on the item.
        state (str): ``blocked``, written jointly with ``merge_status``.
        mutation (Mapping[str, object]): The one ``mutations[]`` entry to
            append, in the invariant-16 shape.
        recolor_generation (int): The new top-level ``recolor_generation``.
    """

    item_key: int
    merge_status: str
    state: str
    mutation: Mapping[str, object]
    recolor_generation: int


def select_halted_item(a: ItemStart, b: ItemStart) -> int:
    """Return the ``issue_num`` of the later-started item of a pair.

    The later-started item is the one halted (design section 7). Selection is
    ``argmax`` over ``(start_unknown, worktree_created_at, item_key)``, which
    encodes the three documented tie-breaks: equal timestamps deem the larger
    ``issue_num`` later-started so the smaller key survives; a start timestamp
    present on exactly one item makes that timestamped item earlier-started;
    both unknown falls through to the item-key tie-break.

    Args:
        a (ItemStart): One item's start marker.
        b (ItemStart): The other item's start marker. Its ``item_key`` must
            differ from ``a``'s, because a pair is two distinct items.

    Returns:
        int: The ``issue_num`` of the item to halt. The result does not depend on
        argument order.

    Raises:
        ParallelDriftInputError: If both markers carry the same ``item_key``.
    """
    if a.item_key == b.item_key:
        raise ParallelDriftInputError(
            "select_halted_item requires two distinct items; both carry "
            f"item_key {a.item_key!r}."
        )

    return max(_start_rank(a), _start_rank(b))[2]


def request_requeue_via_recolor(
    *,
    halted_item_key: int,
    at: str,
    current_recolor_generation: int,
) -> RequeueRequest:
    """Request the drift-induced requeue of one halted item.

    This is the single recolor seam (IC-6b, design section 8.6). It REQUESTS the
    mutation and does not perform it: F6 (issue #442) owns the recolor engine
    that pins in-flight items, recolors the unstarted subgraph, and writes the
    checkpoint, and F6's entry point is not callable from this module today. The
    seam therefore returns the requested intent for F6 or the parent to apply,
    and contains no Welsh-Powell ordering, no cohort assignment, and no
    graph-coloring logic of any kind. When F6 lands, its entry point replaces
    the application step; the intent is formed only here, so no second recolor
    implementation exists.

    Args:
        halted_item_key (int): ``issue_num`` of the later-started item selected
            by ``select_halted_item``; a positive, non-boolean integer.
        at (str): Caller-supplied ISO-8601 timestamp for the mutation record.
        current_recolor_generation (int): The checkpoint's current top-level
            ``recolor_generation``; a non-negative, non-boolean integer.

    Returns:
        RequeueRequest: The joint ``merge_status``/``state`` write invariant 8
        requires, exactly one ``mutations[]`` entry in the invariant-16 shape,
        and the generation incremented by exactly one.

    Raises:
        ParallelDriftInputError: If an argument is malformed, or if an emitted
            enum member is absent from the F3-owned vocabulary.
    """
    item_key = require_item_key(halted_item_key, "halted_item_key")
    moment = require_text(at, "at")
    generation = require_generation(
        current_recolor_generation, "current_recolor_generation"
    )
    next_generation = generation + 1

    mutation: dict[str, object] = {
        "op": require_enum_member(
            MUTATION_OP_REQUEUE, VALID_MUTATION_OPS, "mutations[].op"
        ),
        "item_key": item_key,
        "at": moment,
        "prior_state": require_enum_member(
            ITEM_STATE_IN_FLIGHT, VALID_ITEM_STATES, "mutations[].prior_state"
        ),
        "new_state": require_enum_member(
            ITEM_STATE_BLOCKED, VALID_ITEM_STATES, "mutations[].new_state"
        ),
        "disposition": None,
        "recolor_generation": next_generation,
    }
    return RequeueRequest(
        item_key=item_key,
        merge_status=require_enum_member(
            MERGE_STATUS_BLOCKED_DRIFT, VALID_MERGE_STATUS, "items[].merge_status"
        ),
        state=require_enum_member(
            ITEM_STATE_BLOCKED, VALID_ITEM_STATES, "items[].state"
        ),
        mutation=mutation,
        recolor_generation=next_generation,
    )


def _start_rank(marker: ItemStart) -> tuple[int, str, int]:
    """Render a start marker as the comparable rank halt selection maximizes.

    Args:
        marker (ItemStart): The item's start marker.

    Returns:
        tuple[int, str, int]: ``(start_unknown, timestamp, item_key)``.
        ``start_unknown`` is ``1`` when no usable timestamp exists, which ranks
        an item of unknown start above every timestamped item and so makes the
        timestamped item earlier-started. The timestamp slot is blank in that
        case, leaving the item-key tie-break to decide.
    """
    timestamp = marker.worktree_created_at
    if timestamp is None or not timestamp.strip():
        return (1, "", marker.item_key)
    return (0, timestamp, marker.item_key)
