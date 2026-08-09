"""Tests for later-started halt selection and the single requeue seam.

This file mirrors `scripts/dev_tools/parallel_drift_halt.py`, which was split out
of the detection module under that plan's documented contingency. It covers the
four tie-break branches of `select_halted_item` (distinct timestamps, equal
timestamps, exactly one missing timestamp, both missing), the antisymmetry and
totality property of the selection, and the requeue seam's requested mutation
shape, generation increment, and joint `merge_status`/`state` write.
"""

from __future__ import annotations

import ast
from itertools import combinations
from pathlib import Path

import pytest

from scripts.dev_tools import parallel_drift_halt
from scripts.dev_tools._parallel_drift_shape import ParallelDriftInputError
from scripts.dev_tools._parallel_state_common import (
    VALID_ITEM_STATES,
    VALID_MERGE_STATUS,
    VALID_MUTATION_OPS,
)
from scripts.dev_tools.parallel_drift_halt import (
    ITEM_STATE_BLOCKED,
    ITEM_STATE_IN_FLIGHT,
    MERGE_STATUS_BLOCKED_DRIFT,
    MUTATION_OP_REQUEUE,
    ItemStart,
    RequeueRequest,
    request_requeue_via_recolor,
    select_halted_item,
)

# Markers used by the antisymmetry property below: two distinct timestamps, an
# equal timestamp shared with another marker, and two unknown starts.
PROPERTY_MARKERS: tuple[ItemStart, ...] = (
    ItemStart(item_key=441, worktree_created_at="2026-08-08T09-00"),
    ItemStart(item_key=442, worktree_created_at="2026-08-08T10-00"),
    ItemStart(item_key=443, worktree_created_at="2026-08-08T10-00"),
    ItemStart(item_key=444, worktree_created_at=None),
    ItemStart(item_key=445, worktree_created_at=""),
)


def test_emitted_enum_members_belong_to_the_f3_owned_vocabularies() -> None:
    """Bind every emitted member to F3's enums so a rename fails here."""

    assert MERGE_STATUS_BLOCKED_DRIFT in VALID_MERGE_STATUS
    assert ITEM_STATE_BLOCKED in VALID_ITEM_STATES
    assert ITEM_STATE_IN_FLIGHT in VALID_ITEM_STATES
    assert MUTATION_OP_REQUEUE in VALID_MUTATION_OPS


def test_select_halted_item_halts_the_later_timestamped_item() -> None:
    """Halt the item whose recorded start is later when the starts differ."""

    earlier = ItemStart(item_key=445, worktree_created_at="2026-08-08T09-00")
    later = ItemStart(item_key=441, worktree_created_at="2026-08-08T11-00")

    halted = select_halted_item(earlier, later)

    assert halted == 441


def test_select_halted_item_ignores_argument_order_for_distinct_timestamps() -> None:
    """Produce the same verdict whichever position each marker occupies."""

    earlier = ItemStart(item_key=445, worktree_created_at="2026-08-08T09-00")
    later = ItemStart(item_key=441, worktree_created_at="2026-08-08T11-00")

    assert select_halted_item(later, earlier) == select_halted_item(earlier, later)


def test_select_halted_item_equal_timestamps_halt_the_larger_issue_number() -> None:
    """Deem the larger `issue_num` later-started, so the smaller key survives.

    Equal timestamps are the normal case for a same-minute cohort fan-out, so
    this branch decides most real halts.
    """

    first = ItemStart(item_key=443, worktree_created_at="2026-08-08T10-00")
    second = ItemStart(item_key=446, worktree_created_at="2026-08-08T10-00")

    assert select_halted_item(first, second) == 446


def test_select_halted_item_missing_timestamp_makes_the_timestamped_item_earlier() -> (
    None
):
    """Halt the item of unknown start when exactly one start is recorded.

    The timestamped item is deemed earlier-started, so the item whose worktree
    timestamp is absent is the one halted, even when its key is smaller.
    """

    timestamped = ItemStart(item_key=446, worktree_created_at="2026-08-08T10-00")
    unknown = ItemStart(item_key=441, worktree_created_at=None)

    assert select_halted_item(timestamped, unknown) == 441
    assert select_halted_item(unknown, timestamped) == 441


def test_select_halted_item_treats_a_blank_timestamp_as_missing() -> None:
    """Treat a whitespace-only timestamp as an unknown start, not as a value."""

    timestamped = ItemStart(item_key=446, worktree_created_at="2026-08-08T10-00")
    blank = ItemStart(item_key=441, worktree_created_at="   ")

    assert select_halted_item(timestamped, blank) == 441


def test_select_halted_item_both_timestamps_missing_falls_through_to_the_key() -> None:
    """Fall back to the item-key tie-break when neither start is recorded."""

    first = ItemStart(item_key=441, worktree_created_at=None)
    second = ItemStart(item_key=446, worktree_created_at=None)

    assert select_halted_item(first, second) == 446


def test_select_halted_item_rejects_a_pair_of_identical_item_keys() -> None:
    """Reject a degenerate pair; a conflicting pair is two distinct items."""

    marker = ItemStart(item_key=446, worktree_created_at="2026-08-08T10-00")

    with pytest.raises(ParallelDriftInputError, match="two distinct items"):
        select_halted_item(marker, marker)


def test_select_halted_item_is_total_and_order_independent_over_every_pair() -> None:
    """Assert the selection property across every pair of the marker matrix.

    Property: the verdict is always one of the two supplied keys (totality) and
    never depends on argument order (antisymmetry of the underlying ordering).
    """

    # Every unordered pair of the fixed marker set exercises all four tie-break
    # branches at least once, so the property covers the whole rule.
    for left, right in combinations(PROPERTY_MARKERS, 2):
        forward = select_halted_item(left, right)
        reverse = select_halted_item(right, left)

        context = f"left={left} right={right}"
        assert forward in {left.item_key, right.item_key}, context
        assert forward == reverse, context


def test_item_start_rejects_a_malformed_item_key() -> None:
    """Enforce the primary-key invariant at construction, not at comparison."""

    with pytest.raises(ParallelDriftInputError, match="positive integer issue_num"):
        ItemStart(item_key=0, worktree_created_at="2026-08-08T10-00")


def test_item_start_rejects_a_non_string_timestamp() -> None:
    """Reject a timestamp of the wrong type with a message naming the field."""

    with pytest.raises(ParallelDriftInputError, match="worktree_created_at"):
        ItemStart(
            item_key=446,
            worktree_created_at=20260808,  # pyright: ignore[reportArgumentType]
        )


def test_request_requeue_via_recolor_requests_exactly_one_mutation_entry() -> None:
    """Return one `mutations[]` entry in the invariant-16 shape."""

    request = request_requeue_via_recolor(
        halted_item_key=446,
        at="2026-08-08T21-19",
        current_recolor_generation=3,
    )

    assert request.mutation == {
        "op": "requeue",
        "item_key": 446,
        "at": "2026-08-08T21-19",
        "prior_state": "in_flight",
        "new_state": "blocked",
        "disposition": None,
        "recolor_generation": 4,
    }


def test_request_requeue_via_recolor_increments_the_generation_by_exactly_one() -> None:
    """Increment `recolor_generation` by one, in both the request and the entry."""

    request = request_requeue_via_recolor(
        halted_item_key=446,
        at="2026-08-08T21-19",
        current_recolor_generation=0,
    )

    assert request.recolor_generation == 1
    assert request.mutation["recolor_generation"] == 1


def test_request_requeue_via_recolor_requests_the_joint_blocked_drift_write() -> None:
    """Request `blocked_drift` together with item state `blocked`.

    F3 invariant 8 requires the two to travel together, so the seam names both
    rather than leaving the caller to infer the state.
    """

    request = request_requeue_via_recolor(
        halted_item_key=446,
        at="2026-08-08T21-19",
        current_recolor_generation=1,
    )

    assert request.merge_status == "blocked_drift"
    assert request.state == "blocked"
    assert request.item_key == 446


def test_request_requeue_via_recolor_keeps_blocked_drift_out_of_the_state_slots() -> (
    None
):
    """Keep the merge-status value out of `prior_state` and `new_state`.

    `mutations[].new_state` validates against the item-state enum, so recording
    `blocked_drift` there would be rejected by F3 invariant 16.
    """

    request = request_requeue_via_recolor(
        halted_item_key=446,
        at="2026-08-08T21-19",
        current_recolor_generation=1,
    )

    assert request.mutation["prior_state"] in VALID_ITEM_STATES
    assert request.mutation["new_state"] in VALID_ITEM_STATES
    assert request.mutation["new_state"] != MERGE_STATUS_BLOCKED_DRIFT


def test_request_requeue_via_recolor_leaves_the_disposition_null() -> None:
    """Leave `disposition` null; invariant 17 permits it only on a removal."""

    request = request_requeue_via_recolor(
        halted_item_key=446,
        at="2026-08-08T21-19",
        current_recolor_generation=1,
    )

    assert request.mutation["disposition"] is None


def test_request_requeue_via_recolor_is_deterministic_and_returns_fresh_data() -> None:
    """Produce equal requests for equal inputs without aliasing the mutation."""

    first = request_requeue_via_recolor(
        halted_item_key=446, at="2026-08-08T21-19", current_recolor_generation=2
    )
    second = request_requeue_via_recolor(
        halted_item_key=446, at="2026-08-08T21-19", current_recolor_generation=2
    )

    assert first == second
    assert first.mutation is not second.mutation


@pytest.mark.parametrize("item_key", [0, -5, True, "446", None])
def test_request_requeue_via_recolor_rejects_a_malformed_item_key(
    item_key: object,
) -> None:
    """Reject a malformed halted-item key rather than requesting a bad mutation."""

    with pytest.raises(ParallelDriftInputError, match="positive integer issue_num"):
        request_requeue_via_recolor(
            halted_item_key=item_key,  # pyright: ignore[reportArgumentType]
            at="2026-08-08T21-19",
            current_recolor_generation=1,
        )


@pytest.mark.parametrize("generation", [-1, True, "3", None, 2.0])
def test_request_requeue_via_recolor_rejects_a_malformed_generation(
    generation: object,
) -> None:
    """Reject a generation that is negative, boolean, or not an integer."""

    with pytest.raises(ParallelDriftInputError, match="non-negative integer"):
        request_requeue_via_recolor(
            halted_item_key=446,
            at="2026-08-08T21-19",
            current_recolor_generation=generation,  # pyright: ignore[reportArgumentType]
        )


def test_request_requeue_via_recolor_rejects_a_blank_timestamp() -> None:
    """Reject a blank `at`; the mutation record requires a non-empty timestamp."""

    with pytest.raises(ParallelDriftInputError, match="at must be a non-empty string"):
        request_requeue_via_recolor(
            halted_item_key=446, at="  ", current_recolor_generation=1
        )


def test_requeue_request_is_frozen_so_the_requested_intent_cannot_be_edited() -> None:
    """Keep the request immutable; the seam requests and never applies."""

    request = request_requeue_via_recolor(
        halted_item_key=446, at="2026-08-08T21-19", current_recolor_generation=1
    )

    assert isinstance(request, RequeueRequest)
    with pytest.raises(AttributeError):
        request.item_key = 447  # pyright: ignore[reportAttributeAccessIssue]


def test_halt_module_contains_no_graph_coloring_logic() -> None:
    """Assert the seam performs no recolor of its own.

    The plan requires the seam to hold no Welsh-Powell ordering, cohort
    assignment, or graph-coloring logic; F6 (issue #442) owns that engine. The
    check is structural rather than textual — it reads the module's own syntax
    tree — so the prose that documents the boundary cannot satisfy or break it.
    """

    tree = ast.parse(
        Path(str(parallel_drift_halt.__file__)).read_text(encoding="utf-8")
    )
    imported_modules = {
        node.module
        for node in ast.walk(tree)
        if isinstance(node, ast.ImportFrom) and node.module is not None
    }
    defined_functions = {
        node.name
        for node in ast.walk(tree)
        if isinstance(node, (ast.FunctionDef, ast.AsyncFunctionDef))
    }
    called_names = {
        node.func.id
        for node in ast.walk(tree)
        if isinstance(node, ast.Call) and isinstance(node.func, ast.Name)
    }

    assert "scripts.dev_tools.parallel_cohort_computation" not in imported_modules
    assert "compute_cohorts" not in called_names
    assert "compute_concurrency_batches" not in called_names
    assert defined_functions == {
        "__post_init__",
        "select_halted_item",
        "request_requeue_via_recolor",
        "_start_rank",
    }
