"""Determinism and property-based tests for the parallel mutation engine.

This is the feature's primary test obligation: spec FR4 makes the pinning invariant
the core correctness property, and proving it under mutation against a live
in-flight set requires properties over many graphs rather than a few examples.

Properties proved here, plus at least one property per pure engine function
(``recolor_unstarted``, ``decide_removal``, ``decide_close``,
``is_closed_mode_complete``, and the four entry constructors):

- P1 determinism -- for arbitrary graphs and arbitrary pinned/unstarted partitions,
  ``recolor_unstarted(x) == recolor_unstarted(x)``, every unstarted vertex is
  assigned exactly one cohort, no pinned vertex is assigned any, and the indices are
  contiguous from the computed pinned-barrier offset.
- P2 independent-set validity -- no two items in one recolored cohort share an edge,
  and pinned edges leave the induced class STRUCTURE intact while shifting the final
  assignment past the pinned index.

Sibling modules hold the rest, so no file exceeds the 500-line limit: P3 pin
stability in ``test_parallel_mutation_pin_stability_properties.py``; P4 composed
contention and the ``decide_admission`` property in
``test_parallel_mutation_contention_properties.py``.

Mechanism: seeded ``random.Random(seed)`` generation of ``int``-keyed conflict
graphs. The seed appears in every assertion message and in each parametrized case
id, so any failure is reproducible by rerunning that case. ``hypothesis`` is absent
from ``pyproject.toml``, is deliberately not imported, and no dependency is added.
No test creates a temporary file, starts a subprocess, reads the wall clock, or
invokes ``git`` or ``gh``.
"""

from __future__ import annotations

import random
from datetime import datetime, timezone
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from collections.abc import Mapping

from scripts.dev_tools._parallel_mutation_models import (
    ItemRecord,
    ParallelMutationError,
    RecolorResult,
)
from scripts.dev_tools.parallel_mutation_protocol import (
    build_add_entry,
    build_close_entry,
    build_remove_entry,
    build_requeue_entry,
    decide_admission,
    decide_close,
    decide_removal,
    is_closed_mode_complete,
    recolor_unstarted,
)

# Seeds driving the generated cases. A fixed list keeps the suite deterministic
# while still covering many graph shapes; the seed appears in each case id.
SEEDS = [1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233]

# Bounds on generated graphs. Small graphs keep the suite fast while still
# producing pinned/unstarted partitions, isolated vertices, and dense cliques.
MIN_ITEMS = 2
MAX_ITEMS = 12

# The generation every generated case starts from, and the single timestamp every
# constructed entry records.
START_GENERATION = 4
FIXED_NOW = datetime(2026, 8, 8, 11, 0, tzinfo=timezone.utc)

# The four unstarted item states, cycled when labelling generated items.
UNSTARTED_STATE_CYCLE = ("proposed", "admitted", "prepared", "scheduled")


def fixed_clock() -> datetime:
    """Return ``FIXED_NOW`` so every constructed entry is deterministic."""

    return FIXED_NOW


class GeneratedRun:
    """A randomly generated parallel run, reproducible from its seed.

    Produces one arbitrary conflict graph plus an arbitrary pinned/unstarted
    partition, so a property can be asserted over many shapes. Keys are positive
    ``int`` values matching F3's ``items[].issue_num``; the pinned and unstarted sets
    are disjoint and cover every generated key; edges are normalized to ``(a, b)``
    with ``a < b`` and deduplicated, matching F3's conflict-edge normalization.

    Attributes:
        seed (int): The seed this run was generated from, reported on failure.
        keys (list[int]): Every generated item key, ascending.
        pinned (frozenset[int]): Keys whose items are ``in_flight``.
        unstarted (list[int]): Keys whose items are unstarted, ascending.
        current_cohort (int): The index the pinned items occupy.
        edges (list[tuple[int, int]]): Normalized, deduplicated conflict edges.
        items (dict[int, ItemRecord]): The item table for this run.
    """

    def __init__(self, seed: int) -> None:
        """Generate one run from ``seed``; the same seed always yields the same run."""

        self.seed = seed
        # Deterministic test data; S311 authorized in pyproject per-file-ignores.
        rng = random.Random(seed)
        # Offset the keys off 1 so a test cannot pass by assuming 0-based keys.
        count = rng.randint(MIN_ITEMS, MAX_ITEMS)
        self.keys = [100 + index for index in range(count)]

        # Partition the vertices. The pinned share varies with the seed so some
        # runs have no pinned item and others are almost entirely pinned. The
        # cohort index is varied off zero so no assertion can pass by assuming a
        # zero-based assignment.
        pinned_count = rng.randint(0, count - 1)
        self.pinned = frozenset(rng.sample(self.keys, pinned_count))
        self.unstarted = [key for key in self.keys if key not in self.pinned]
        self.current_cohort = rng.randint(0, 4)

        # Generate edges over ALL vertices, including pinned ones, because
        # admission is decided against the full graph.
        density = rng.random()
        edge_set: set[tuple[int, int]] = set()
        for first_index, first in enumerate(self.keys):
            for second in self.keys[first_index + 1 :]:
                if rng.random() < density:
                    edge_set.add((first, second))
        self.edges = sorted(edge_set)

        # Label each item with a state consistent with its partition, cycling the
        # unstarted states so every one of the four appears across the suite.
        self.items: dict[int, ItemRecord] = {}
        for index, key in enumerate(self.keys):
            state = (
                "in_flight"
                if key in self.pinned
                else UNSTARTED_STATE_CYCLE[index % len(UNSTARTED_STATE_CYCLE)]
            )
            self.items[key] = ItemRecord(key, state)

    def recolor(self, generation: int = START_GENERATION) -> RecolorResult:
        """Recolor this run's unstarted subgraph at this run's cohort index.

        A thin wrapper binding this run's vertex set, edges, pinned set, and cohort
        index, so each property reads as one call.

        Args:
            generation (int): The generation to recolor from.

        Returns:
            RecolorResult: The engine's result for this run.
        """

        return recolor_unstarted(
            self.unstarted,
            self.edges,
            self.pinned,
            generation,
            current_cohort=self.current_cohort,
        )

    def crosses_pinned(self, edges: list[tuple[int, int]] | None = None) -> bool:
        """Recompute the pinned-barrier predicate independently of the engine.

        Args:
            edges (list[tuple[int, int]] | None): Edge list to test; defaults to
                this run's full edge list.

        Returns:
            bool: True when some edge joins an unstarted key to a pinned key.
        """

        unstarted_keys = frozenset(self.unstarted)
        # Scan the FULL list; the induced restriction is what discards these edges.
        return any(
            (first in unstarted_keys and second in self.pinned)
            or (second in unstarted_keys and first in self.pinned)
            for first, second in (self.edges if edges is None else edges)
        )

    def expected_offset(self, edges: list[tuple[int, int]] | None = None) -> int:
        """Return the absolute base index the offset rule requires.

        Args:
            edges (list[tuple[int, int]] | None): Edge list to test.

        Returns:
            int: ``current_cohort + 1`` when an unstarted-to-pinned edge exists,
            otherwise ``current_cohort``.
        """

        return self.current_cohort + (1 if self.crosses_pinned(edges) else 0)

    def __str__(self) -> str:
        """Report the seed and shape, so a failure message alone reproduces it."""

        return (
            f"seed={self.seed} keys={self.keys} pinned={sorted(self.pinned)} "
            f"current_cohort={self.current_cohort} edges={self.edges}"
        )


@pytest.fixture(params=SEEDS, ids=[f"seed{seed}" for seed in SEEDS])
def run(request: pytest.FixtureRequest) -> GeneratedRun:
    """Provide one generated run per seed; the case id names the seed.

    Args:
        request (pytest.FixtureRequest): Carries the seed parameter.

    Returns:
        GeneratedRun: The run for this seed, reproducible from the report alone.
    """

    return GeneratedRun(int(request.param))


def _classes(assignments: Mapping[int, int]) -> set[frozenset[int]]:
    """Group an assignment into its color classes, discarding the index labels.

    Comparing two assignments' class sets compares their PARTITIONS rather than
    their labels, so a uniform index shift cannot change the comparison.

    Args:
        assignments (Mapping[int, int]): An ``item_key -> cohort_index`` mapping.

    Returns:
        set[frozenset[int]]: One frozen key set per occupied cohort index.
    """

    grouped: dict[int, set[int]] = {}
    # Collect the keys sharing each index, then drop the index value itself.
    for key, index in assignments.items():
        grouped.setdefault(index, set()).add(key)
    return {frozenset(keys) for keys in grouped.values()}


class TestPropertyOneDeterminism:
    """P1 -- recoloring is deterministic and assigns exactly the right vertices."""

    def test_recolor_is_deterministic_for_equal_inputs(self, run: GeneratedRun) -> None:
        """Two recolors of the same graph produce identical results."""

        assert run.recolor() == run.recolor(), f"recolor not deterministic for {run}"

    def test_input_order_does_not_change_the_result(self, run: GeneratedRun) -> None:
        """Shuffling the caller's vertex and edge order cannot change the result."""

        # Arrange: reverse both input orders, which the coloring must ignore.
        shuffled_vertices = list(reversed(run.unstarted))
        shuffled_edges = list(reversed(run.edges))

        # Act
        reordered = recolor_unstarted(
            shuffled_vertices,
            shuffled_edges,
            run.pinned,
            START_GENERATION,
            current_cohort=run.current_cohort,
        )

        # Assert
        assert run.recolor() == reordered, f"result depended on input order for {run}"

    def test_every_unstarted_vertex_is_assigned_exactly_one_cohort(
        self, run: GeneratedRun
    ) -> None:
        """The assignment covers the unstarted set exactly once."""

        assert set(run.recolor().cohort_assignments) == set(
            run.unstarted
        ), f"assignment key set did not equal the unstarted set for {run}"

    def test_no_pinned_vertex_is_assigned_a_cohort(self, run: GeneratedRun) -> None:
        """The pinning invariant: a pinned vertex receives no assignment."""

        assert set(run.recolor().cohort_assignments).isdisjoint(
            run.pinned
        ), f"a pinned vertex was assigned a cohort for {run}"

    def test_generation_is_always_one_beyond_the_current(
        self, run: GeneratedRun
    ) -> None:
        """A recolor advances the generation by exactly one, for every graph."""

        assert (
            run.recolor().generation == START_GENERATION + 1
        ), f"wrong generation for {run}"

    def test_cohort_indices_are_contiguous_from_the_computed_offset(
        self, run: GeneratedRun
    ) -> None:
        """Indices form a gapless range starting at the computed offset.

        Replaces ``test_cohort_indices_are_contiguous_from_zero``, which asserted a
        zero base the pinned-barrier offset replaces. STRICTLY STRONGER: it keeps
        the contiguity claim and adds the offset-value claim, so it fails if the
        offset is removed, re-based to zero, or made unconditional.
        """

        indices = set(run.recolor().cohort_assignments.values())
        if not indices:
            return

        offset = run.expected_offset()

        # Contiguity, now measured from the computed offset rather than zero.
        assert indices == set(
            range(offset, offset + len(indices))
        ), f"cohort indices were not contiguous from offset {offset} for {run}"

        # The offset itself equals the rule in spec FR4, not merely some shift.
        assert min(indices) == offset, f"offset base should be {offset} for {run}"


class TestPropertyTwoIndependentSets:
    """P2 -- every recolored cohort is an independent set of the conflict graph."""

    def test_no_two_items_in_one_cohort_share_a_conflict_edge(
        self, run: GeneratedRun
    ) -> None:
        """The defining property of a valid coloring."""

        # Arrange
        assignments = run.recolor().cohort_assignments

        # Act / Assert: check every edge whose endpoints were both colored.
        for first, second in run.edges:
            if first in assignments and second in assignments:
                assert (
                    assignments[first] != assignments[second]
                ), f"edge ({first}, {second}) fell inside one cohort for {run}"

    def test_pinned_edges_leave_the_class_structure_but_shift_the_assignment(
        self, run: GeneratedRun
    ) -> None:
        """Pinned edges do not constrain the LOCAL coloring but do shift the result.

        Replaces ``test_edges_touching_a_pinned_vertex_do_not_constrain_the_coloring``,
        whose full-versus-induced EQUALITY assertion codified the C2 defect: it can
        only hold if the pinned edges are discarded entirely, constraint included.
        STRICTLY STRONGER, asserting both halves of the corrected statement -- F2
        receives the same induced subgraph so the class STRUCTURE is identical, yet
        the final assignment is SHIFTED past the pinned index whenever an
        unstarted-to-pinned edge exists, which the old equality forbade.
        """

        # Arrange: recolor with the full edge list and with the induced list.
        induced = [
            edge
            for edge in run.edges
            if edge[0] not in run.pinned and edge[1] not in run.pinned
        ]

        # Act
        from_full = run.recolor()
        from_induced = recolor_unstarted(
            run.unstarted,
            induced,
            run.pinned,
            START_GENERATION,
            current_cohort=run.current_cohort,
        )

        # Assert: identical class STRUCTURE. Comparing grouped key sets compares
        # partitions, not labels, so a uniform shift cannot change the comparison.
        assert _classes(from_full.cohort_assignments) == _classes(
            from_induced.cohort_assignments
        ), f"pinned edges changed the induced class structure for {run}"

        if not from_full.cohort_assignments:
            return

        # Assert: the assignment is shifted past the pinned index exactly when an
        # unstarted-to-pinned edge exists.
        full_base = min(from_full.cohort_assignments.values())
        assert (
            full_base == run.expected_offset()
        ), f"full-edge assignment did not carry the pinned barrier for {run}"
        assert (
            min(from_induced.cohort_assignments.values()) == run.current_cohort
        ), f"induced-edge assignment should start at current_cohort for {run}"
        if run.crosses_pinned():
            assert (
                full_base > run.current_cohort
            ), f"a pinned conflict must push the assignment above the index: {run}"


class TestPerFunctionProperties:
    """At least one property per pure engine function."""

    def test_removal_of_an_unstarted_item_always_recomputes_and_withdraws(
        self, run: GeneratedRun
    ) -> None:
        """``decide_removal`` treats every unstarted state identically."""

        for key in run.unstarted:
            decision = decide_removal(key, run.items)

            assert decision.new_state == "withdrawn", f"wrong new state for {run}"
            assert decision.triggers_recompute is True, f"no recompute for {run}"
            assert decision.disposition is None, f"stray disposition for {run}"

    def test_close_is_permitted_exactly_when_no_item_is_pinned(
        self, run: GeneratedRun
    ) -> None:
        """``decide_close`` agrees with the pinned set for every generated run."""

        if run.pinned:
            with pytest.raises(ParallelMutationError):
                decide_close(run.items)
        else:
            assert decide_close(run.items) is None, f"close blocked for {run}"

    def test_completion_is_false_while_any_item_lacks_a_terminal_status(
        self, run: GeneratedRun
    ) -> None:
        """A generated run has no merged item, so it is never complete."""

        assert (
            is_closed_mode_complete(run.items) is False
        ), f"run reported complete with outstanding items: {run}"

    def test_completion_is_true_once_every_item_is_merged(
        self, run: GeneratedRun
    ) -> None:
        """Marking every item merged flips the predicate, for every run shape."""

        # Arrange
        merged = {key: ItemRecord(key, "merged", "merged") for key in run.items}

        # Assert
        assert is_closed_mode_complete(merged) is True, f"run not complete: {run}"

    def test_entry_constructors_are_deterministic_under_a_fixed_clock(
        self, run: GeneratedRun
    ) -> None:
        """Every constructor yields equal entries for equal inputs."""

        # Arrange: one zero-argument factory per constructor.
        key = run.keys[0]
        factories = (
            lambda: build_add_entry(
                key,
                deferred=True,
                current_generation=START_GENERATION,
                clock=fixed_clock,
            ),
            lambda: build_close_entry(
                current_generation=START_GENERATION, clock=fixed_clock
            ),
            lambda: build_requeue_entry(
                key, current_generation=START_GENERATION, clock=fixed_clock
            ),
        )

        # Act / Assert: two calls of each constructor must agree.
        for factory in factories:
            assert factory() == factory(), f"entry not deterministic for {run}"

    def test_remove_entry_is_deterministic_for_every_unstarted_item(
        self, run: GeneratedRun
    ) -> None:
        """``build_remove_entry`` is a pure function of its decision."""

        for key in run.unstarted:
            decision = decide_removal(key, run.items)

            assert build_remove_entry(
                decision, current_generation=START_GENERATION, clock=fixed_clock
            ) == build_remove_entry(
                decision, current_generation=START_GENERATION, clock=fixed_clock
            ), f"remove entry not deterministic for {run}"

    def test_no_engine_call_mutates_the_generated_run(self, run: GeneratedRun) -> None:
        """Purity: the caller's inputs survive a full pass over the engine."""

        # Arrange
        keys_before = list(run.keys)
        edges_before = list(run.edges)
        items_before = dict(run.items)

        # Act: exercise every pure function that takes a container.
        decide_admission(
            run.keys[0], run.edges, run.pinned, current_cohort_members=run.pinned
        )
        recolor_unstarted(
            run.unstarted,
            run.edges,
            run.pinned,
            START_GENERATION,
            current_cohort=run.current_cohort,
        )
        is_closed_mode_complete(run.items)

        # Assert
        assert run.keys == keys_before, f"keys mutated for {run}"
        assert run.edges == edges_before, f"edges mutated for {run}"
        assert run.items == items_before, f"items mutated for {run}"
