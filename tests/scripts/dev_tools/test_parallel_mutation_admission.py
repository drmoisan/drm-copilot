"""Unit tests for ``decide_admission`` under the corrected current-cohort rule.

Covers spec Test Strategy scenario 4 (admission computed over ALL items) as
amended by spec 1.2 design correction C1, and carries the C1 regression test for
remediation finding R1 / policy-audit finding B1 / feature-audit discrepancy D1.

The defect these tests bind: the pre-1.2 rule checked the ``in_flight`` subset
only, but ``max_concurrency`` caps in-flight items independently of cohort size and
refills each freed slot from the SAME current cohort
(``.claude/skills/parallel-orchestrate/SKILL.md`` section
``## Cohort Barrier and Max-Concurrency Slot Filling``), so the current cohort
durably holds not-yet-launched ``scheduled`` members. Admitting a candidate that
conflicts with one lets the next batch launch two contending items together. Full
rationale: ``<FEATURE>/spec.md`` section ``### Design corrections (spec 1.2)``.

``TestAdmissionOverAllItems`` is relocated here from
``tests/scripts/dev_tools/test_parallel_mutation_protocol.py`` so neither module
exceeds the 500-line limit. In every fixture the current cohort holds its pinned
members, so ``current_cohort_members`` is a superset of ``in_flight``, mirroring
the production derivation. Every fixture is a literal ``int`` key matching F3's
``items[].issue_num``. No test creates a temporary file, starts a subprocess, or
invokes ``git`` or ``gh``.
"""

from __future__ import annotations

from datetime import datetime, timezone

import pytest

from scripts.dev_tools._parallel_mutation_models import AdmissionOutcome
from scripts.dev_tools.parallel_mutation_protocol import (
    build_add_entry,
    decide_admission,
)

# The single timestamp every entry in this module records, so a test can assert
# the value came from the injected seam rather than from the wall clock.
FIXED_NOW = datetime(2026, 8, 8, 10, 15, tzinfo=timezone.utc)

# The generation every test starts from. A non-zero value makes an accidental
# "return 0" or "return 1" implementation defect visible.
START_GENERATION = 7


def fixed_clock() -> datetime:
    """Return the module's fixed timestamp.

    Returns:
        datetime: ``FIXED_NOW``, so every constructed entry is deterministic.
    """

    return FIXED_NOW


class TestCohortIndependenceRegression:
    """The C1 regression for finding R1 / B1 / D1 (see the module docstring).

    Asserts the admission VERDICT only; cohort indices are
    ``recolor_unstarted``'s contract, asserted in
    ``tests/scripts/dev_tools/test_parallel_mutation_recolor.py``. The expectation
    is the CORRECTED one, so this test failed against the pre-fix engine and must
    never be weakened to accommodate it.
    """

    def test_conflict_with_an_unstarted_current_cohort_member_defers(self) -> None:
        """Defer a candidate conflicting with a ``scheduled`` cohort member.

        The reproduction premise of finding R1 / B1 / D1: item 100 is
        ``in_flight``; item 200 is ``scheduled``, a current-cohort member not yet
        launched; candidate 300 conflicts with 200 only, and with nothing in
        flight. Admitting 300 would let the next max-concurrency batch launch it
        concurrently with 200 on overlapping blast radius.
        """

        # Arrange: the only edge joins the candidate to the unstarted
        # current-cohort member 200, not to the pinned item 100.
        in_flight = frozenset({100})
        current_cohort_members = frozenset({100, 200})

        # Act
        decision = decide_admission(
            300, [(200, 300)], in_flight, current_cohort_members=current_cohort_members
        )

        # Assert: the corrected rule defers on any current-cohort conflict.
        assert decision.outcome is AdmissionOutcome.DEFER_AND_RECOLOR
        assert decision.triggers_recompute is True


class TestAdmissionOverAllItems:
    """Scenario 4 -- admission decided against ALL members of the current cohort.

    Relocated from ``test_parallel_mutation_protocol.py`` with every call
    migrated to the required keyword-only ``current_cohort_members`` argument.
    Asserts admission verdicts only.
    """

    def test_conflict_only_with_an_in_flight_item_defers(self) -> None:
        """An in-flight conflict defers the candidate and forces a recolor."""

        decision = decide_admission(
            11, [(11, 21)], frozenset({21}), current_cohort_members=frozenset({21})
        )

        assert decision.outcome is AdmissionOutcome.DEFER_AND_RECOLOR
        assert decision.triggers_recompute is True

    def test_conflict_only_with_an_unstarted_item_admits(self) -> None:
        """Admit on an unstarted conflict OUTSIDE the current cohort.

        Item 12 is unstarted but not a cohort member, so the barrier separates it.
        """

        decision = decide_admission(
            11, [(11, 12)], frozenset({21}), current_cohort_members=frozenset({21})
        )

        assert decision.outcome is AdmissionOutcome.ADMIT_CURRENT_COHORT

    def test_conflict_with_an_unstarted_current_cohort_member_defers(self) -> None:
        """Defer on an unstarted CURRENT-COHORT conflict (item 12 is a member).

        First half of the replacement for the removed
        ``test_unstarted_conflict_is_placed_by_the_coloring_not_rejected``.
        """

        decision = decide_admission(
            11, [(11, 12)], frozenset({21}), current_cohort_members=frozenset({12, 21})
        )

        assert decision.outcome is AdmissionOutcome.DEFER_AND_RECOLOR
        assert decision.triggers_recompute is True

    def test_conflict_with_an_unstarted_item_outside_the_cohort_admits(self) -> None:
        """Admit when the unstarted conflict partner sits in another cohort.

        Second half of that replacement. This case distinguishes the corrected
        rule from a blanket "any unstarted conflict defers" rule, which would
        serialize work the cohort barrier already separates.
        """

        decision = decide_admission(
            11, [(11, 13)], frozenset({21}), current_cohort_members=frozenset({12, 21})
        )

        assert decision.outcome is AdmissionOutcome.ADMIT_CURRENT_COHORT
        assert decision.triggers_recompute is False

    def test_no_conflicts_admits_with_no_generation_change(self) -> None:
        """With no conflict at all the candidate joins the current cohort."""

        # Arrange / Act
        decision = decide_admission(
            11, [(12, 13)], frozenset({21}), current_cohort_members=frozenset({21})
        )
        entry = build_add_entry(
            11,
            deferred=decision.triggers_recompute,
            current_generation=START_GENERATION,
            clock=fixed_clock,
        )

        # Assert
        assert decision.outcome is AdmissionOutcome.ADMIT_CURRENT_COHORT
        assert entry.recolor_generation == START_GENERATION

    @pytest.mark.parametrize("edge", [(11, 21), (21, 11)])
    def test_edge_direction_does_not_affect_the_decision(
        self, edge: tuple[int, int]
    ) -> None:
        """Conflict edges are undirected, so either endpoint order defers."""

        decision = decide_admission(
            11, [edge], frozenset({21}), current_cohort_members=frozenset({21})
        )

        assert decision.outcome is AdmissionOutcome.DEFER_AND_RECOLOR

    def test_candidate_key_is_recorded_on_the_decision(self) -> None:
        """The decision names the candidate it applies to."""

        decision = decide_admission(
            11, [], frozenset(), current_cohort_members=frozenset()
        )

        assert decision.candidate == 11

    def test_admission_does_not_mutate_its_inputs(self) -> None:
        """Deciding admission leaves the caller's edge list unchanged."""

        # Arrange
        edges = [(11, 21), (12, 13)]

        # Act
        decide_admission(
            11, edges, frozenset({21}), current_cohort_members=frozenset({21})
        )

        # Assert
        assert edges == [(11, 21), (12, 13)]

    def test_admission_is_deterministic_for_equal_inputs(self) -> None:
        """Two calls with equal inputs return equal decisions."""

        edges = [(11, 21)]
        pinned = frozenset({21})

        assert decide_admission(
            11, edges, pinned, current_cohort_members=pinned
        ) == decide_admission(11, edges, pinned, current_cohort_members=pinned)

    def test_empty_edge_list_admits(self) -> None:
        """A run with no conflict edges admits every candidate."""

        decision = decide_admission(
            11, [], frozenset({21}), current_cohort_members=frozenset({21})
        )

        assert decision.outcome is AdmissionOutcome.ADMIT_CURRENT_COHORT
