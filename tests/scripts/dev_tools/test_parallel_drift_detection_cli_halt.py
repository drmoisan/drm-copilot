"""Tests for the halt-selection call site of the parallel radius-drift command line.

Covers `halted_item_keys` and the `_start_markers` it consumes in
`scripts/dev_tools/parallel_drift_detection_cli.py`: which member of a newly
conflicting pair is halted, and the exclusion of the drifting item from halt
candidacy. Split out of `test_parallel_drift_detection_cli.py`, which had too
little file-size headroom to absorb the added cases. Every checkpoint is in
memory, so no temporary file and no subprocess is used.

The drifting item is never halted. That prohibition is stated unconditionally by
`spec.md` and by `user-story.md`, and it is independently necessary: the drifting
item is mid-remediation on its own R1 through R5 loop for the drift finding, so
halting it would deadlock the remediation that resolves the drift.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from scripts.dev_tools.parallel_drift_detection_cli import (
    RESULT_HALT_REQUIRED,
    halted_item_keys,
)
from tests.scripts.dev_tools.parallel_drift_test_support import (
    checkpoint,
    evaluate,
    in_flight,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

# The drifting item every test in this file evaluates.
DRIFTING = 446


def test_evaluate_drift_halts_the_later_started_item_of_a_new_conflict() -> None:
    """Halt the peer, not the drifting item, and record the halt action.

    The drifting item 446 carries the strictly later `worktree_created_at`, so the
    bare later-started rule would select it. The call-site exclusion drops it from
    candidacy first, leaving peer 445 as the only candidate.
    """

    state = checkpoint(
        [
            in_flight(DRIFTING, ["docs/**"], "2026-08-08T09-00"),
            in_flight(445, ["packages/mcp-server/**"], "2026-08-08T08-00"),
        ]
    )

    result = evaluate(state, ["packages/mcp-server/src/index.ts"])
    event = cast("Mapping[str, object]", result["drift_event"])

    assert result["result"] == RESULT_HALT_REQUIRED
    assert result["newly_conflicting_pairs"] == [[445, 446]]
    assert result["halted_item_keys"] == [445]
    assert event["action"] == "halted_later_started_item"


def test_evaluate_drift_selects_one_halted_item_per_newly_conflicting_pair() -> None:
    """Halt one item per pair, excluding the drifting item from every pair."""

    state = checkpoint(
        [
            in_flight(DRIFTING, ["docs/**"], "2026-08-08T09-00"),
            in_flight(445, ["packages/mcp-server/**"], "2026-08-08T08-00"),
            in_flight(447, ["scripts/dev_tools/**"], "2026-08-08T10-00"),
        ]
    )

    result = evaluate(
        state, ["packages/mcp-server/src/index.ts", "scripts/dev_tools/a.py"]
    )

    # Two pairs, so two halted keys: one per pair, each the pair's non-drifting
    # member. The drifting item 446 appears in both pairs and in neither result.
    assert result["newly_conflicting_pairs"] == [[445, 446], [446, 447]]
    assert result["halted_item_keys"] == [445, 447]
    assert DRIFTING not in cast("list[int]", result["halted_item_keys"])


def test_the_drifting_item_is_never_halted_even_when_it_started_later() -> None:
    """Exclude the drifting item under both tie-breaks that would select it.

    Case one: the drifting item carries the strictly later `worktree_created_at`,
    so the timestamp comparison deems it later-started. Case two: both timestamps
    are equal and the drifting item carries the larger `issue_num`, so the
    item-key tie-break deems it later-started. The bare later-started rule selects
    the drifting item in both; the exclusion must return the peer in both.
    """

    # Case one: later by timestamp.
    later_by_timestamp = checkpoint(
        [
            in_flight(DRIFTING, ["docs/**"], "2026-08-08T09-00"),
            in_flight(445, ["packages/mcp-server/**"], "2026-08-08T08-00"),
        ]
    )
    by_timestamp = evaluate(later_by_timestamp, ["packages/mcp-server/src/index.ts"])

    assert by_timestamp["newly_conflicting_pairs"] == [[445, 446]]
    assert DRIFTING not in cast("list[int]", by_timestamp["halted_item_keys"])
    assert by_timestamp["halted_item_keys"] == [445]

    # Case two: equal timestamps, later by the larger issue_num.
    later_by_item_key = checkpoint(
        [
            in_flight(DRIFTING, ["docs/**"], "2026-08-08T08-00"),
            in_flight(445, ["packages/mcp-server/**"], "2026-08-08T08-00"),
        ]
    )
    by_item_key = evaluate(later_by_item_key, ["packages/mcp-server/src/index.ts"])

    assert by_item_key["newly_conflicting_pairs"] == [[445, 446]]
    assert DRIFTING not in cast("list[int]", by_item_key["halted_item_keys"])
    assert by_item_key["halted_item_keys"] == [445]


def test_halted_item_keys_applies_the_comparator_to_a_pair_without_the_drifter() -> (
    None
):
    """Keep the comparator path live for a pair the drifting key is absent from.

    Conflict recomputation always returns pairs containing the drifting item, so
    the two-remaining-candidate branch of `halted_item_keys` is exercised here by
    calling the helper directly with a pair of peers. Peer 448 started later than
    peer 447, so the comparator must return 448.
    """

    items = [
        in_flight(DRIFTING, ["docs/**"], "2026-08-08T09-00"),
        in_flight(447, ["packages/mcp-server/**"], "2026-08-08T08-00"),
        in_flight(448, ["scripts/dev_tools/**"], "2026-08-08T10-00"),
    ]

    halted = halted_item_keys(items, [(447, 448)], DRIFTING)

    assert halted == (448,)
    assert DRIFTING not in halted
