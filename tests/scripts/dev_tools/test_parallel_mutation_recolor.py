"""Unit tests for ``recolor_unstarted`` under the pinned-barrier offset.

Covers spec Test Strategy scenario 1 (pinned items never move) and scenario 9
(the pinned-barrier offset), and carries the C2 regression test for the design
correction adjudicated into remediation cycle 1.

The defect this module binds: ``recolor_unstarted`` built its induced subgraph by
keeping an edge only when BOTH endpoints are unstarted. Dropping the
candidate-to-pinned edges removes the pinned VERTICES from the coloring input,
which is correct, but it also removes the pinned CONSTRAINT, which is not. F2's
``compute_cohorts`` places a key that appears in no edge in cohort 0, and the
cohort barrier cannot advance ``current_cohort`` while any item is ``in_flight``
because an in-flight item is neither ``merged`` nor ``worktree_removed``.
Composing those facts: a candidate deferred BECAUSE it conflicts with an
in-flight item has that edge dropped, becomes an isolated vertex, and is assigned
cohort index 0 -- which IS the current cohort when ``current_cohort == 0``. The
candidate therefore rejoins the very pinned item it conflicts with, and the
deferral accomplishes nothing on its primary trigger.

In the fixture below, **0 is the pinned items' cohort index**. Item 300 was
deferred precisely because of its conflict with the in-flight item 100, and
co-scheduling 300 with 100 is the contention violation this test forbids.

Every fixture is a literal ``int``-keyed value, matching F3's positive-integer
``items[].issue_num`` primary key. No test creates a temporary file, starts a
subprocess, or invokes ``git`` or ``gh``.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools._parallel_mutation_models import ItemRecord, UnknownItemError
from scripts.dev_tools.parallel_cohort_computation import ParallelCohortInputError
from scripts.dev_tools.parallel_mutation_protocol import recolor_unstarted

# The generation every test in this module starts from. A non-zero value makes an
# accidental "return 0" or "return 1" implementation defect visible.
START_GENERATION = 7


class TestPinnedBarrierOffsetRegression:
    """The C2 regression: a deferred candidate must not rejoin its pinned conflict.

    Purpose:
        Bind the pinned-barrier offset so the defect cannot return. The single
        test here is the behavioral demonstration that the pre-fix engine
        assigned the deferred candidate the pinned items' own cohort index.

    Responsibilities:
        This class asserts the returned cohort INDEX of the deferred candidate
        relative to the pinned items' index. It does not assert the admission
        verdict, which is ``decide_admission``'s contract and is bound by
        ``tests/scripts/dev_tools/test_parallel_mutation_admission.py``.

    Usage:
        Executed by pytest with no fixture setup; the scenario is expressed
        entirely in literal arguments.

    Key invariants:
        The expectation is the CORRECTED one, so this test fails against the
        pre-fix engine and passes after the offset is added. It must never be
        weakened to accommodate the pre-fix behavior.
    """

    def test_deferred_candidate_is_not_placed_in_the_pinned_cohort(self) -> None:
        """Keep a pinned-conflicting candidate out of the pinned items' cohort.

        Scenario: item 100 is ``in_flight`` and occupies cohort index 0, which is
        the current cohort; items 200 (``scheduled``) and 300 (the candidate just
        deferred) are unstarted; the only conflict edge is ``(100, 300)``.

        The pre-fix engine drops edge ``(100, 300)`` as non-induced, so 200 and
        300 are both isolated vertices that F2 colors into cohort 0 -- the pinned
        items' index -- and the deferral is undone. The corrected engine must
        assign 300 an index other than the pinned index 0.
        """

        # Arrange: 0 is the pinned items' cohort index in this fixture. The only
        # edge is candidate-to-pinned, which is exactly the edge the induced
        # subgraph drops.
        unstarted = [200, 300]
        conflict_edges = [(100, 300)]
        pinned = frozenset({100})
        pinned_cohort_index = 0

        # Act
        result = recolor_unstarted(
            unstarted,
            conflict_edges,
            pinned,
            START_GENERATION,
            current_cohort=pinned_cohort_index,
            highest_pinned_cohort=pinned_cohort_index,
        )

        # Assert: the deferred candidate must not share the pinned items' cohort.
        assert result.cohort_assignments[300] != pinned_cohort_index


class TestPinnedItemsNeverMove:
    """Scenario 1 -- the pinning invariant of spec FR4.

    Relocated from ``tests/scripts/dev_tools/test_parallel_mutation_protocol.py``
    so neither module exceeds the 500-line limit. Every assertion is preserved
    verbatim; only the added ``current_cohort`` keyword argument and the resulting
    call wrapping differ from the original.
    """

    def test_recolor_assigns_no_pinned_item(self) -> None:
        """A pinned item receives no cohort assignment from a recolor."""

        # Arrange: two unstarted items and two pinned items, all interconnected.
        unstarted = [11, 12]
        pinned = frozenset({21, 22})
        edges = [(11, 12), (11, 21), (12, 22), (21, 22)]

        # Act
        result = recolor_unstarted(
            unstarted,
            edges,
            pinned,
            START_GENERATION,
            current_cohort=0,
            highest_pinned_cohort=0,
        )

        # Assert
        assert set(result.cohort_assignments).isdisjoint(pinned)

    def test_recolor_key_set_equals_the_unstarted_set_exactly(self) -> None:
        """The result assigns every unstarted item and nothing else."""

        # Arrange
        unstarted = [11, 12, 13]
        edges = [(11, 12), (12, 99), (99, 13)]

        # Act
        result = recolor_unstarted(
            unstarted,
            edges,
            frozenset({99}),
            START_GENERATION,
            current_cohort=0,
            highest_pinned_cohort=0,
        )

        # Assert
        assert set(result.cohort_assignments) == set(unstarted)

    def test_applying_a_recolor_leaves_pinned_state_and_cohort_unchanged(self) -> None:
        """Applying the result changes no pinned item's state or cohort index."""

        # Arrange: a cohort table and item table holding one pinned item.
        items = {11: ItemRecord(11, "scheduled"), 21: ItemRecord(21, "in_flight")}
        cohort_by_key = {11: 0, 21: 0}
        pinned_state_before = items[21].state
        pinned_cohort_before = cohort_by_key[21]

        # Act: recolor the unstarted subgraph and apply only its assignments.
        result = recolor_unstarted(
            [11],
            [(11, 21)],
            frozenset({21}),
            START_GENERATION,
            current_cohort=0,
            highest_pinned_cohort=0,
        )
        for key, index in result.cohort_assignments.items():
            cohort_by_key[key] = index

        # Assert
        assert items[21].state == pinned_state_before
        assert cohort_by_key[21] == pinned_cohort_before

    def test_recolor_rejects_a_key_that_is_both_unstarted_and_pinned(self) -> None:
        """A key cannot be a colored vertex and pinned at the same time."""

        # Arrange / Act / Assert
        with pytest.raises(UnknownItemError):
            recolor_unstarted(
                [11, 21],
                [(11, 21)],
                frozenset({21}),
                START_GENERATION,
                current_cohort=0,
                highest_pinned_cohort=0,
            )

    def test_recolor_does_not_mutate_its_inputs(self) -> None:
        """A recolor leaves the caller's vertex list and edge list unchanged."""

        # Arrange
        unstarted = [11, 12]
        edges = [(11, 12), (11, 21)]

        # Act
        recolor_unstarted(
            unstarted,
            edges,
            frozenset({21}),
            START_GENERATION,
            current_cohort=0,
            highest_pinned_cohort=0,
        )

        # Assert
        assert unstarted == [11, 12]
        assert edges == [(11, 12), (11, 21)]

    def test_recolor_result_mapping_is_read_only(self) -> None:
        """The returned assignment mapping cannot be mutated by a caller."""

        # Arrange
        result = recolor_unstarted(
            [11],
            [],
            frozenset(),
            START_GENERATION,
            current_cohort=0,
            highest_pinned_cohort=0,
        )

        # Act / Assert
        with pytest.raises(TypeError):
            result.cohort_assignments[11] = 99  # type: ignore[index]


class TestPinnedBarrierOffset:
    """Scenario 9 -- the pinned-barrier offset of spec FR4 (correction C2).

    Each test here fails if the offset is REMOVED (indices fall back onto the
    pinned index) or if it is made UNCONDITIONAL (the no-conflict case stops
    starting at ``current_cohort``), so the pair binds the offset rule in both
    directions rather than only asserting that some shift occurred.
    """

    def test_pinned_conflict_forces_an_index_above_current_cohort_at_zero(self) -> None:
        """An unstarted-to-pinned conflict pushes every index above index 0.

        Fails if the offset is removed: without it item 300 lands on index 0,
        the pinned index.
        """

        result = recolor_unstarted(
            [200, 300],
            [(100, 300)],
            frozenset({100}),
            START_GENERATION,
            current_cohort=0,
            highest_pinned_cohort=0,
        )

        assert min(result.cohort_assignments.values()) == 1
        assert all(index > 0 for index in result.cohort_assignments.values())

    def test_pinned_conflict_forces_an_index_above_a_non_zero_current_cohort(
        self,
    ) -> None:
        """The barrier is relative to ``current_cohort``, not to zero.

        Fails if the offset is removed or if it re-bases to zero: at
        ``current_cohort = 3`` the lowest index must be 4, not 0 and not 1.
        """

        result = recolor_unstarted(
            [200, 300],
            [(100, 300)],
            frozenset({100}),
            START_GENERATION,
            current_cohort=3,
            highest_pinned_cohort=3,
        )

        assert min(result.cohort_assignments.values()) == 4
        assert all(index > 3 for index in result.cohort_assignments.values())

    def test_no_pinned_conflict_starts_exactly_at_current_cohort(self) -> None:
        """With no unstarted-to-pinned edge the lowest index equals current_cohort.

        Fails if the offset is made UNCONDITIONAL: an unconditional ``+1`` would
        report 4 here and needlessly evacuate the running cohort of its
        not-yet-launched members.
        """

        result = recolor_unstarted(
            [200, 300],
            [(200, 300)],
            frozenset({100}),
            START_GENERATION,
            current_cohort=3,
            highest_pinned_cohort=3,
        )

        assert min(result.cohort_assignments.values()) == 3

    def test_offset_is_uniform_so_conflicting_items_stay_distinct(self) -> None:
        """The shift is uniform, so F2's distinct color classes stay distinct.

        Items 200 and 300 conflict with each other AND 300 conflicts with the
        pinned 100, so both the induced edge and the barrier are active. The two
        must occupy different indices separated by exactly one, the same
        separation their local color classes had.
        """

        result = recolor_unstarted(
            [200, 300],
            [(200, 300), (100, 300)],
            frozenset({100}),
            START_GENERATION,
            current_cohort=2,
            highest_pinned_cohort=2,
        )

        first = result.cohort_assignments[200]
        second = result.cohort_assignments[300]
        assert first != second
        assert abs(first - second) == 1
        assert min(first, second) == 3

    def test_negative_current_cohort_is_rejected(self) -> None:
        """A negative index cannot name a cohort under F3 invariant 12."""

        with pytest.raises(ParallelCohortInputError) as excinfo:
            recolor_unstarted(
                [200],
                [],
                frozenset({100}),
                START_GENERATION,
                current_cohort=-1,
                highest_pinned_cohort=-1,
            )

        assert excinfo.value.offending_value == -1

    def test_pinned_free_run_at_zero_matches_the_pre_fix_assignment(self) -> None:
        """With no pinned set and ``current_cohort == 0`` the result is unchanged.

        Backward compatibility: every pinned-free scenario keeps the exact
        zero-based assignment the pre-fix engine produced for the same graph.
        """

        result = recolor_unstarted(
            [11, 12, 13],
            [(11, 12)],
            frozenset(),
            START_GENERATION,
            current_cohort=0,
            highest_pinned_cohort=0,
        )

        assert dict(result.cohort_assignments) == {11: 0, 12: 1, 13: 0}


class TestHighestPinnedCohortOffset:
    """The per-edge-barrier generalization of the pinned-barrier offset (D1).

    Purpose:
        Bind the offset to the HIGHEST current-generation cohort index occupied
        by any pinned item rather than to ``current_cohort``. Under the per-edge
        barrier an item starts as soon as its own conflicting prior-cohort
        neighbours are terminal, so in-flight items are not confined to one
        index and the pinned frontier can span several cohorts.

    Scope:
        Two directions are bound. The multi-cohort case proves the offset clears
        the highest pinned index, and the single-frontier case proves the
        generalization is behaviour-identical wherever
        ``highest_pinned_cohort == current_cohort`` -- every state reachable
        before D1 landed.
    """

    def test_multi_cohort_pinned_frontier_pushes_above_the_highest_pinned_index(
        self,
    ) -> None:
        """A candidate conflicting with an index-1 pinned item lands above index 1.

        Pinned items occupy current-generation indices {0, 1} while
        ``current_cohort`` is still 0, which the per-edge barrier permits: the
        index-1 item started because its own prior-cohort neighbours were
        terminal, not because the whole cohort 0 had drained. The pre-D1 offset
        ``current_cohort + 1`` would place the deferred candidate at index 1 --
        the very index its pinned conflict occupies -- so this test fails
        against the previous expression.
        """

        # Arrange: 100 is pinned at index 0 and 101 is pinned at index 1, so the
        # pinned frontier spans two cohorts while current_cohort is still 0. The
        # only edge is candidate-to-pinned against the HIGHER pinned index.
        unstarted = [200, 300]
        conflict_edges = [(101, 300)]
        pinned = frozenset({100, 101})

        # Act
        result = recolor_unstarted(
            unstarted,
            conflict_edges,
            pinned,
            START_GENERATION,
            current_cohort=0,
            highest_pinned_cohort=1,
        )

        # Assert: the deferred candidate must clear the highest pinned index.
        assert result.cohort_assignments[300] > 1
        assert min(result.cohort_assignments.values()) == 2

    def test_single_frontier_offset_matches_the_previous_behavior(self) -> None:
        """With one pinned frontier the generalized offset reproduces the old one.

        Identity regression for spec AC13: whenever every pinned item occupies
        ``current_cohort`` -- every state reachable before D1 -- the generalized
        expression ``highest_pinned_cohort + 1`` equals the previous
        ``current_cohort + 1``, and the no-conflict path is untouched at
        ``current_cohort``.
        """

        # Arrange: one pinned item at index 3, so the frontier is a single index.
        current_cohort = 3
        pinned = frozenset({100})
        crossing_edges = [(100, 300)]
        non_crossing_edges = [(200, 300)]

        # Act: recolor once with a pinned conflict and once without.
        crossing = recolor_unstarted(
            [200, 300],
            crossing_edges,
            pinned,
            START_GENERATION,
            current_cohort=current_cohort,
            highest_pinned_cohort=current_cohort,
        )
        non_crossing = recolor_unstarted(
            [200, 300],
            non_crossing_edges,
            pinned,
            START_GENERATION,
            current_cohort=current_cohort,
            highest_pinned_cohort=current_cohort,
        )

        # Assert: both bases equal the pre-D1 rule computed from current_cohort
        # alone, so no reachable pre-D1 recoloring changed.
        assert min(crossing.cohort_assignments.values()) == current_cohort + 1
        assert min(non_crossing.cohort_assignments.values()) == current_cohort
        assert dict(crossing.cohort_assignments) == {200: 4, 300: 4}
        assert dict(non_crossing.cohort_assignments) == {200: 3, 300: 4}
