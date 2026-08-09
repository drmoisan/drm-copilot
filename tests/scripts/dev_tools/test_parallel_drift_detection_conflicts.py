"""Tests for conflict recomputation against an observed radius.

Split from `tests/scripts/dev_tools/test_parallel_drift_detection.py` to stay
inside the 500-line cap, following the pre-approved split convention of
`test_parallel_cohort_computation*.py`. This file covers
`recompute_conflicts_with_observed` — with F1's relation mocked at the import
location the unit under test uses, and once against the real relation — plus the
end-to-end determinism of the detect, recompute, halt, and requeue path. The
quiesce derivation lives in
`tests/scripts/dev_tools/test_parallel_drift_detection_quiesce.py`. Every
checkpoint here is an in-memory structure; no temporary file is used.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools._blast_radius_conflicts import ConflictReason, ConflictResult
from scripts.dev_tools.parallel_drift_detection import (
    ItemStart,
    ParallelDriftInputError,
    detect_escaped_paths,
    recompute_conflicts_with_observed,
    request_requeue_via_recolor,
    select_halted_item,
)
from scripts.dev_tools.parallel_drift_detection_cli import halted_item_keys
from tests.scripts.dev_tools.parallel_drift_test_support import (
    CONFIG,
    in_flight,
    item,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

    from scripts.dev_tools.compute_blast_radius import BlastRadius

# The two verdicts the mocked relation returns. Building them here keeps each
# test's arrange section to the checkpoint data it actually varies.
CONFLICTING = ConflictResult(
    conflict=True,
    reasons=(ConflictReason(kind="path_overlap", detail="scripts/dev_tools/a.py"),),
)
NOT_CONFLICTING = ConflictResult(conflict=False, reasons=())

RELATION_ATTRIBUTE = "scripts.dev_tools.parallel_drift_detection.conflicts"


def _always_conflicting(
    a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
) -> ConflictResult:
    """Stand in for F1's relation, reporting contention for every pair.

    Args:
        a (BlastRadius): The observed radius the unit under test built.
        b (BlastRadius): The peer radius rebuilt from the checkpoint.
        config (Mapping[str, object]): The forwarded truth table.

    Returns:
        ConflictResult: The fixed conflicting verdict.
    """
    return CONFLICTING


def _never_conflicting(
    a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
) -> ConflictResult:
    """Stand in for F1's relation, reporting no contention for any pair.

    Args:
        a (BlastRadius): The observed radius the unit under test built.
        b (BlastRadius): The peer radius rebuilt from the checkpoint.
        config (Mapping[str, object]): The forwarded truth table.

    Returns:
        ConflictResult: The fixed non-conflicting verdict.
    """
    return NOT_CONFLICTING


def test_recompute_conflicts_reports_nothing_when_no_new_conflict_appears(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Return an empty pair set when the observed radius contends with nobody."""

    monkeypatch.setattr(RELATION_ATTRIBUTE, _never_conflicting)

    pairs = recompute_conflicts_with_observed(
        [item(446, ["scripts/dev_tools/**"]), item(445, ["packages/mcp-server/**"])],
        446,
        ["scripts/dev_tools/a.py"],
        [],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert pairs == ()


def test_recompute_conflicts_reports_the_one_newly_conflicting_pair(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Report exactly the peer the observed radius newly contends with."""

    # Conflict only with 445; 447 is evaluated and found independent.
    def _relation(
        a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
    ) -> ConflictResult:
        return CONFLICTING if "packages/mcp-server/**" in b.paths else NOT_CONFLICTING

    monkeypatch.setattr(RELATION_ATTRIBUTE, _relation)

    pairs = recompute_conflicts_with_observed(
        [
            item(446, ["scripts/dev_tools/**"]),
            item(445, ["packages/mcp-server/**"]),
            item(447, ["docs/**"]),
        ],
        446,
        ["packages/mcp-server/src/index.ts"],
        [],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert pairs == ((445, 446),)


@pytest.mark.parametrize(
    "edge",
    [
        {"a": 445, "b": 446, "reason": "path_overlap"},
        # Recorded in reverse order; canonical normalization must still match.
        {"a": 446, "b": 445, "reason": "path_overlap"},
    ],
)
def test_recompute_conflicts_skips_a_pair_already_recorded_as_an_edge(
    monkeypatch: pytest.MonkeyPatch, edge: Mapping[str, object]
) -> None:
    """Return only newly introduced contention, never an already-known edge."""

    monkeypatch.setattr(RELATION_ATTRIBUTE, _always_conflicting)

    pairs = recompute_conflicts_with_observed(
        [item(446, ["scripts/dev_tools/**"]), item(445, ["packages/mcp-server/**"])],
        446,
        ["packages/mcp-server/src/index.ts"],
        [edge],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert pairs == ()


def test_recompute_conflicts_treats_an_unevaluable_peer_radius_as_conflicting(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Fail closed on a peer whose radius cannot be rebuilt, without consulting F1."""

    calls: list[tuple[str, ...]] = []

    def _relation(
        a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
    ) -> ConflictResult:
        calls.append(tuple(b.paths))
        return NOT_CONFLICTING

    monkeypatch.setattr(RELATION_ATTRIBUTE, _relation)
    broken_peer: dict[str, object] = {
        "issue_num": 445,
        "state": "in_flight",
        "blast_radius": {"paths": ["packages/mcp-server/**"]},
    }

    pairs = recompute_conflicts_with_observed(
        [item(446, ["scripts/dev_tools/**"]), broken_peer],
        446,
        ["scripts/dev_tools/a.py"],
        [],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert pairs == ((445, 446),)
    assert calls == []


def test_recompute_conflicts_treats_a_missing_peer_radius_as_conflicting(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Fail closed when a peer carries no radius block at all."""

    monkeypatch.setattr(RELATION_ATTRIBUTE, _never_conflicting)

    pairs = recompute_conflicts_with_observed(
        [
            item(446, ["scripts/dev_tools/**"]),
            {"issue_num": 445, "state": "in_flight"},
        ],
        446,
        ["scripts/dev_tools/a.py"],
        [],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert pairs == ((445, 446),)


def test_recompute_conflicts_ignores_peers_that_are_not_in_flight(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Evaluate only concurrently in-flight peers; a scheduled item is not one."""

    monkeypatch.setattr(RELATION_ATTRIBUTE, _always_conflicting)

    pairs = recompute_conflicts_with_observed(
        [
            item(446, ["scripts/dev_tools/**"]),
            item(445, ["packages/mcp-server/**"], state="scheduled"),
            item(444, ["docs/**"], state="merged"),
        ],
        446,
        ["packages/mcp-server/src/index.ts"],
        [],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert pairs == ()


def test_recompute_conflicts_builds_the_substituted_radius_from_observed_paths(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Pass F1 an observed-source radius whose modules the library resolved.

    Hand-constructing the radius would drop the module disjunct, so the captured
    left-hand argument is asserted to carry the observed source, the injected
    timestamp, and the resolved module set.
    """

    captured: list[BlastRadius] = []

    def _relation(
        a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
    ) -> ConflictResult:
        captured.append(a)
        return NOT_CONFLICTING

    monkeypatch.setattr(RELATION_ATTRIBUTE, _relation)

    recompute_conflicts_with_observed(
        [item(446, ["scripts/dev_tools/**"]), item(445, ["docs/**"])],
        446,
        ["packages/mcp-server/src/index.ts"],
        [],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert len(captured) == 1
    assert captured[0].source == "observed"
    assert captured[0].computed_at == "2026-08-08T10-00"
    assert captured[0].modules == ("mcp-server",)


def test_recompute_conflicts_ignores_an_unreadable_existing_edge(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Treat a malformed edge as absent so the conflict is still reported."""

    monkeypatch.setattr(RELATION_ATTRIBUTE, _always_conflicting)

    pairs = recompute_conflicts_with_observed(
        [item(446, ["scripts/dev_tools/**"]), item(445, ["packages/mcp-server/**"])],
        446,
        ["packages/mcp-server/src/index.ts"],
        [{"a": 445, "b": None}, {"a": 446, "b": 446}, {"a": "445", "b": 446}],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert pairs == ((445, 446),)


def test_recompute_conflicts_rejects_a_malformed_item_key() -> None:
    """Fail loudly on an item whose primary key cannot name a conflict pair."""

    with pytest.raises(ParallelDriftInputError, match=r"items\[1\].issue_num"):
        recompute_conflicts_with_observed(
            [item(446, ["scripts/dev_tools/**"]), {"issue_num": None}],
            446,
            ["scripts/dev_tools/a.py"],
            [],
            CONFIG,
            computed_at="2026-08-08T10-00",
        )


@pytest.mark.parametrize(
    ("drifting_item_key", "computed_at"),
    [(0, "2026-08-08T10-00"), (446, "")],
)
def test_recompute_conflicts_rejects_malformed_scalar_arguments(
    drifting_item_key: int, computed_at: str
) -> None:
    """Reject a bad drifting key or a blank radius timestamp before evaluating."""

    with pytest.raises(ParallelDriftInputError):
        recompute_conflicts_with_observed(
            [item(446, ["scripts/dev_tools/**"])],
            drifting_item_key,
            ["scripts/dev_tools/a.py"],
            [],
            CONFIG,
            computed_at=computed_at,
        )


def test_recompute_conflicts_uses_the_real_relation_without_mocking() -> None:
    """Detect a real path overlap end to end through F1's imported relation."""

    pairs = recompute_conflicts_with_observed(
        [
            item(446, ["scripts/dev_tools/**"]),
            item(445, ["packages/mcp-server/**"]),
            item(447, ["docs/**"]),
        ],
        446,
        ["packages/mcp-server/src/index.ts"],
        [],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )

    assert pairs == ((445, 446),)


def test_recomputed_pair_feeds_halt_selection_and_yields_later_started_item() -> None:
    """Run the whole path: escape, recomputation, halt selection, requeue request.

    Halt selection is routed through the exclusion-aware call site rather than
    through the bare comparator, because the drifting item is never the one halted.
    Drifting item 446 carries the strictly later `worktree_created_at` here, so the
    bare later-started rule would select it; the call site drops it from candidacy
    and the peer 445 is halted and requeued.
    """

    items = [
        in_flight(446, ["scripts/dev_tools/**"], "2026-08-08T09-00"),
        in_flight(445, ["packages/mcp-server/**"], "2026-08-08T08-00"),
    ]
    escaped = detect_escaped_paths(
        ["scripts/dev_tools/a.py", "packages/mcp-server/src/index.ts"],
        ["scripts/dev_tools/**"],
    )

    pairs = recompute_conflicts_with_observed(
        items,
        446,
        ["scripts/dev_tools/a.py", "packages/mcp-server/src/index.ts"],
        [],
        CONFIG,
        computed_at="2026-08-08T10-00",
    )
    halted = halted_item_keys(items, pairs, 446)
    request = request_requeue_via_recolor(
        halted_item_key=halted[0], at="2026-08-08T10-00", current_recolor_generation=2
    )

    assert escaped == ("packages/mcp-server/src/index.ts",)
    assert pairs == ((445, 446),)
    assert halted == (445,)
    assert request.item_key == 445
    assert request.merge_status == "blocked_drift"
    assert request.state == "blocked"
    assert request.recolor_generation == 3


def test_the_detection_and_halt_path_is_deterministic_across_repeated_calls() -> None:
    """Produce identical escapes, pairs, and halt decisions for identical inputs.

    The path is invoked twice with the same inputs and the same injected
    timestamps; nothing in it reads a clock, so both runs must agree exactly.
    """

    items = [
        item(446, ["scripts/dev_tools/**"]),
        item(445, ["packages/mcp-server/**"]),
        item(447, ["docs/**"]),
    ]
    changed = [
        "packages/mcp-server/src/index.ts",
        "scripts/dev_tools/a.py",
        "packages/mcp-server/src/index.ts",
    ]

    # Two independent passes over the same inputs, compared field by field.
    results: list[tuple[object, ...]] = []
    for _ in range(2):
        escaped = detect_escaped_paths(changed, ["scripts/dev_tools/**"])
        pairs = recompute_conflicts_with_observed(
            items, 446, changed, [], CONFIG, computed_at="2026-08-08T10-00"
        )
        halted = select_halted_item(
            ItemStart(item_key=pairs[0][0], worktree_created_at="2026-08-08T09-00"),
            ItemStart(item_key=pairs[0][1], worktree_created_at="2026-08-08T09-00"),
        )
        request = request_requeue_via_recolor(
            halted_item_key=halted, at="2026-08-08T10-00", current_recolor_generation=1
        )
        results.append((escaped, pairs, halted, request))

    assert results[0] == results[1]
    assert results[0][2] == 446
