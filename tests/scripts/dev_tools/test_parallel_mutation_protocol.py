"""Unit tests for the parallel mutation engine: pinning, generations, admission.

Covers these spec Test Strategy unit scenarios: 1 (pinned items never move),
3 (generation accounting across the recompute boundary), 4 (admission computed
over ALL items including in-flight ones), and 7 (the mode-dependent completion
predicate). The per-op scenarios 5, 6, and 8 -- removal table, close gating, and
mutation-log shape -- live in
``tests/scripts/dev_tools/test_parallel_mutation_protocol_ops.py`` so neither
file exceeds the repository's 500-line limit.

Every fixture is a literal dict keyed by ``int`` item keys, matching F3's
positive-integer ``items[].issue_num`` primary key. The clock is injected as a
fixed callable, so no test reads the wall clock. No test creates a temporary
file, starts a subprocess, or invokes ``git`` or ``gh``.
"""

from __future__ import annotations

from datetime import datetime, timezone

import pytest

from scripts.dev_tools._parallel_mutation_models import (
    PINNED_ITEM_STATE,
    UNSTARTED_ITEM_STATES,
    AdmissionOutcome,
    ItemRecord,
    RecolorResult,
    UnknownEnumMemberError,
    UnknownItemError,
)
from scripts.dev_tools._parallel_state_common import (
    MERGED_MERGE_STATUSES,
    VALID_DISPOSITIONS,
    VALID_ITEM_STATES,
    VALID_MERGE_STATUS,
)
from scripts.dev_tools.parallel_mutation_abandon_cli import ABANDON_DISPOSITION
from scripts.dev_tools.parallel_mutation_protocol import (
    build_add_entry,
    build_close_entry,
    build_remove_entry,
    build_requeue_entry,
    decide_admission,
    decide_removal,
    is_closed_mode_complete,
    recolor_unstarted,
)

# The single timestamp every entry in this module records, so a test can assert
# the value came from the injected seam rather than from the wall clock.
FIXED_NOW = datetime(2026, 8, 8, 10, 15, tzinfo=timezone.utc)

# The generation every test starts from. A non-zero value makes an accidental
# "return 0" or "return 1" implementation defect visible.
START_GENERATION = 7

# Each F3 merge-status member paired with an item state invariant 8 permits
# alongside it. The completion test parametrizes over the enum and looks up this
# table, so adding an F3 member without updating the table fails loudly.
STATE_FOR_MERGE_STATUS = {
    "not_started": "scheduled",
    "worktree_created": "scheduled",
    "pr_open": "in_flight",
    "ci_green": "in_flight",
    "merged": "merged",
    "worktree_removed": "merged",
    "blocked_drift": "blocked",
    "blocked_ci_loop_limit": "blocked",
}


def fixed_clock() -> datetime:
    """Return the module's fixed timestamp.

    Returns:
        datetime: ``FIXED_NOW``, so every constructed entry is deterministic.
    """

    return FIXED_NOW


class TestEnumConsumption:
    """Guard the consume-never-extend rule for the F3 enums this feature reads."""

    def test_unstarted_states_are_all_f3_item_state_members(self) -> None:
        """Every unstarted state must be a member of F3's item-state enum."""

        # Arrange / Act
        unknown = set(UNSTARTED_ITEM_STATES) - set(VALID_ITEM_STATES)

        # Assert
        assert not unknown, f"unstarted states outside F3's enum: {sorted(unknown)}"

    def test_pinned_state_is_an_f3_item_state_member(self) -> None:
        """The pinned state must be a member of F3's item-state enum."""

        assert PINNED_ITEM_STATE in VALID_ITEM_STATES

    def test_abandon_disposition_is_an_f3_disposition_member(self) -> None:
        """The CLI's abandon disposition must be an F3 disposition member."""

        assert ABANDON_DISPOSITION in VALID_DISPOSITIONS

    @pytest.mark.parametrize(
        ("issue_num", "state", "merge_status", "expected"),
        [
            (0, "scheduled", "not_started", UnknownItemError),
            (-1, "scheduled", "not_started", UnknownItemError),
            (True, "scheduled", "not_started", UnknownItemError),
            (11, "paused", "not_started", UnknownEnumMemberError),
            (11, "scheduled", "landed", UnknownEnumMemberError),
        ],
    )
    def test_item_record_rejects_an_invalid_key_or_enum_value(
        self,
        issue_num: int,
        state: str,
        merge_status: str,
        expected: type[Exception],
    ) -> None:
        """``ItemRecord`` validates its key and both enum fields at construction."""

        with pytest.raises(expected):
            ItemRecord(issue_num, state, merge_status)


class TestPinnedItemsNeverMove:
    """Scenario 1 -- the pinning invariant of spec FR4."""

    def test_recolor_assigns_no_pinned_item(self) -> None:
        """A pinned item receives no cohort assignment from a recolor."""

        # Arrange: two unstarted items and two pinned items, all interconnected.
        unstarted = [11, 12]
        pinned = frozenset({21, 22})
        edges = [(11, 12), (11, 21), (12, 22), (21, 22)]

        # Act
        result = recolor_unstarted(unstarted, edges, pinned, START_GENERATION)

        # Assert
        assert set(result.cohort_assignments).isdisjoint(pinned)

    def test_recolor_key_set_equals_the_unstarted_set_exactly(self) -> None:
        """The result assigns every unstarted item and nothing else."""

        # Arrange
        unstarted = [11, 12, 13]
        edges = [(11, 12), (12, 99), (99, 13)]

        # Act
        result = recolor_unstarted(unstarted, edges, frozenset({99}), START_GENERATION)

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
        result = recolor_unstarted([11], [(11, 21)], frozenset({21}), START_GENERATION)
        for key, index in result.cohort_assignments.items():
            cohort_by_key[key] = index

        # Assert
        assert items[21].state == pinned_state_before
        assert cohort_by_key[21] == pinned_cohort_before

    def test_recolor_rejects_a_key_that_is_both_unstarted_and_pinned(self) -> None:
        """A key cannot be a colored vertex and pinned at the same time."""

        # Arrange / Act / Assert
        with pytest.raises(UnknownItemError):
            recolor_unstarted([11, 21], [(11, 21)], frozenset({21}), START_GENERATION)

    def test_recolor_does_not_mutate_its_inputs(self) -> None:
        """A recolor leaves the caller's vertex list and edge list unchanged."""

        # Arrange
        unstarted = [11, 12]
        edges = [(11, 12), (11, 21)]

        # Act
        recolor_unstarted(unstarted, edges, frozenset({21}), START_GENERATION)

        # Assert
        assert unstarted == [11, 12]
        assert edges == [(11, 12), (11, 21)]

    def test_recolor_result_mapping_is_read_only(self) -> None:
        """The returned assignment mapping cannot be mutated by a caller."""

        # Arrange
        result = recolor_unstarted([11], [], frozenset(), START_GENERATION)

        # Act / Assert
        with pytest.raises(TypeError):
            result.cohort_assignments[11] = 99  # type: ignore[index]


class TestGenerationAccounting:
    """Scenario 3 -- the recompute boundary and generation stamping."""

    def test_recolor_result_generation_is_current_plus_one(self) -> None:
        """A recolor always yields exactly one generation beyond the current."""

        result = recolor_unstarted([11], [], frozenset(), START_GENERATION)

        assert result.generation == START_GENERATION + 1

    def test_deferred_add_increments_the_generation(self) -> None:
        """A deferred add recomputes, so its entry stamps ``g + 1``."""

        entry = build_add_entry(
            11, deferred=True, current_generation=START_GENERATION, clock=fixed_clock
        )

        assert entry.recolor_generation == START_GENERATION + 1

    def test_unstarted_removal_increments_the_generation(self) -> None:
        """Removing an unstarted item recomputes, so its entry stamps ``g + 1``."""

        items = {11: ItemRecord(11, "scheduled")}
        entry = build_remove_entry(
            decide_removal(11, items),
            current_generation=START_GENERATION,
            clock=fixed_clock,
        )

        assert entry.recolor_generation == START_GENERATION + 1

    def test_requeue_increments_the_generation(self) -> None:
        """A drift-induced requeue recomputes, so its entry stamps ``g + 1``."""

        entry = build_requeue_entry(
            21, current_generation=START_GENERATION, clock=fixed_clock
        )

        assert entry.recolor_generation == START_GENERATION + 1

    def test_no_conflict_admit_stamps_the_current_generation(self) -> None:
        """A no-conflict admit changes no cohort, so it stamps ``g`` unchanged."""

        entry = build_add_entry(
            11, deferred=False, current_generation=START_GENERATION, clock=fixed_clock
        )

        assert entry.recolor_generation == START_GENERATION

    @pytest.mark.parametrize("disposition", ["detach", "abandon"])
    def test_in_flight_removal_stamps_the_current_generation(
        self, disposition: str
    ) -> None:
        """A pinned removal was never an unstarted vertex, so it stamps ``g``."""

        items = {21: ItemRecord(21, "in_flight")}
        entry = build_remove_entry(
            decide_removal(21, items, disposition),
            current_generation=START_GENERATION,
            clock=fixed_clock,
        )

        assert entry.recolor_generation == START_GENERATION

    def test_close_stamps_the_current_generation(self) -> None:
        """A close terminates the run without changing any cohort assignment."""

        entry = build_close_entry(
            current_generation=START_GENERATION, clock=fixed_clock
        )

        assert entry.recolor_generation == START_GENERATION

    def test_sequence_of_ops_ends_at_start_plus_recompute_count(self) -> None:
        """N ops from ``g`` end at exactly ``g + (number of recompute ops)``."""

        # Arrange: five ops of which three recompute (two deferred adds, one
        # requeue); the two plain admits must not advance the generation.
        generation = START_GENERATION
        recompute_flags = [True, False, True, False]

        # Act: thread each entry's stamped generation into the next op.
        for deferred in recompute_flags:
            generation = build_add_entry(
                11,
                deferred=deferred,
                current_generation=generation,
                clock=fixed_clock,
            ).recolor_generation
        generation = build_requeue_entry(
            21, current_generation=generation, clock=fixed_clock
        ).recolor_generation

        # Assert: three recompute ops occurred among the five.
        assert generation == START_GENERATION + 3

    def test_generation_is_monotonically_non_decreasing_across_a_sequence(self) -> None:
        """No op ever lowers the generation, which F3 invariant checks rely on."""

        # Arrange
        generation = START_GENERATION
        observed: list[int] = []

        # Act: alternate recompute and non-recompute adds.
        for deferred in (False, True, False, True):
            generation = build_add_entry(
                11,
                deferred=deferred,
                current_generation=generation,
                clock=fixed_clock,
            ).recolor_generation
            observed.append(generation)

        # Assert
        assert observed == sorted(observed)


class TestAdmissionOverAllItems:
    """Scenario 4 -- admission decided against ALL items including in-flight."""

    def test_conflict_only_with_an_in_flight_item_defers(self) -> None:
        """An in-flight conflict defers the candidate and forces a recolor."""

        decision = decide_admission(11, [(11, 21)], frozenset({21}))

        assert decision.outcome is AdmissionOutcome.DEFER_AND_RECOLOR
        assert decision.triggers_recompute is True

    def test_conflict_only_with_an_unstarted_item_admits(self) -> None:
        """An unstarted-only conflict is resolved by coloring, not by deferral."""

        decision = decide_admission(11, [(11, 12)], frozenset({21}))

        assert decision.outcome is AdmissionOutcome.ADMIT_CURRENT_COHORT

    def test_unstarted_conflict_is_placed_by_the_coloring_not_rejected(self) -> None:
        """The contending unstarted pair lands in different cohorts."""

        # Arrange / Act
        result = recolor_unstarted([11, 12], [(11, 12)], frozenset(), START_GENERATION)

        # Assert: both placed, and not in the same cohort.
        assert set(result.cohort_assignments) == {11, 12}
        assert result.cohort_assignments[11] != result.cohort_assignments[12]

    def test_no_conflicts_admits_with_no_generation_change(self) -> None:
        """With no conflict at all the candidate joins the current cohort."""

        # Arrange / Act
        decision = decide_admission(11, [(12, 13)], frozenset({21}))
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

        decision = decide_admission(11, [edge], frozenset({21}))

        assert decision.outcome is AdmissionOutcome.DEFER_AND_RECOLOR

    def test_candidate_key_is_recorded_on_the_decision(self) -> None:
        """The decision names the candidate it applies to."""

        assert decide_admission(11, [], frozenset()).candidate == 11

    def test_admission_does_not_mutate_its_inputs(self) -> None:
        """Deciding admission leaves the caller's edge list unchanged."""

        # Arrange
        edges = [(11, 21), (12, 13)]

        # Act
        decide_admission(11, edges, frozenset({21}))

        # Assert
        assert edges == [(11, 21), (12, 13)]

    def test_admission_is_deterministic_for_equal_inputs(self) -> None:
        """Two calls with equal inputs return equal decisions."""

        edges = [(11, 21)]
        pinned = frozenset({21})

        assert decide_admission(11, edges, pinned) == decide_admission(
            11, edges, pinned
        )

    def test_empty_edge_list_admits(self) -> None:
        """A run with no conflict edges admits every candidate."""

        decision = decide_admission(11, [], frozenset({21}))

        assert decision.outcome is AdmissionOutcome.ADMIT_CURRENT_COHORT


class TestCompletionPredicate:
    """Scenario 7 -- the mode-dependent completion predicate of spec FR7."""

    @pytest.mark.parametrize("merge_status", VALID_MERGE_STATUS)
    def test_completion_fires_only_for_terminal_merge_statuses(
        self, merge_status: str
    ) -> None:
        """Parametrized over F3's whole enum: only the two terminal values pass."""

        # Arrange: the pairing table covers the enum, so a new F3 member raises
        # KeyError here rather than silently going untested.
        items = {11: ItemRecord(11, STATE_FOR_MERGE_STATUS[merge_status], merge_status)}

        # Act
        complete = is_closed_mode_complete(items)

        # Assert
        assert complete is (merge_status in MERGED_MERGE_STATUSES)

    def test_completion_fires_when_every_non_withdrawn_item_is_terminal(self) -> None:
        """The gate passes with a mix of both terminal statuses."""

        items = {
            11: ItemRecord(11, "merged", "merged"),
            12: ItemRecord(12, "merged", "worktree_removed"),
        }

        assert is_closed_mode_complete(items) is True

    def test_a_withdrawn_item_is_exempt_from_the_gate(self) -> None:
        """A withdrawn item left the run, so it cannot block completion."""

        items = {
            11: ItemRecord(11, "merged", "merged"),
            12: ItemRecord(12, "withdrawn", "not_started"),
        }

        assert is_closed_mode_complete(items) is True

    def test_one_outstanding_item_keeps_the_run_open(self) -> None:
        """A single non-terminal item is enough to keep the gate closed."""

        items = {
            11: ItemRecord(11, "merged", "merged"),
            21: ItemRecord(21, "in_flight", "pr_open"),
        }

        assert is_closed_mode_complete(items) is False

    def test_a_run_tracking_no_item_is_complete(self) -> None:
        """An empty run has no outstanding work."""

        assert is_closed_mode_complete({}) is True

    def test_an_item_with_a_default_merge_status_is_not_complete(self) -> None:
        """An absent merge status reads as ``not_started``, which is not terminal."""

        assert is_closed_mode_complete({11: ItemRecord(11, "scheduled")}) is False


class TestRecolorResultValueObject:
    """Behavior of the recolor result that callers depend on directly."""

    def test_equal_assignments_and_generation_compare_equal(self) -> None:
        """Two results with the same content are equal, which properties rely on."""

        assert RecolorResult({11: 0, 12: 1}, 3) == RecolorResult({11: 0, 12: 1}, 3)

    def test_a_different_generation_compares_unequal(self) -> None:
        """The generation participates in equality."""

        assert RecolorResult({11: 0}, 3) != RecolorResult({11: 0}, 4)

    def test_constructing_copies_the_caller_mapping(self) -> None:
        """Later mutation of the caller's dict does not change the result."""

        # Arrange
        source = {11: 0}
        result = RecolorResult(source, 3)

        # Act
        source[12] = 1

        # Assert
        assert dict(result.cohort_assignments) == {11: 0}
