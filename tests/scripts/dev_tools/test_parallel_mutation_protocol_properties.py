"""Determinism and property-based tests for the parallel mutation engine.

This is the feature's primary test obligation: spec FR4 makes the pinning
invariant the core correctness property, and proving it under mutation against a
live in-flight set requires properties over many graphs rather than a handful of
examples.

Properties proved here:

- P1 determinism -- for arbitrary graphs and arbitrary pinned/unstarted
  partitions, ``recolor_unstarted(x) == recolor_unstarted(x)``, every unstarted
  vertex is assigned exactly one cohort, and no pinned vertex is assigned any.
- P2 independent-set validity -- no two items in one recolored cohort share an
  edge.
- P3 pin stability -- for an arbitrary sequence of add and remove operations,
  items in flight at operation time never change cohort or state.

Plus at least one property per pure engine function: ``decide_admission``,
``recolor_unstarted``, ``decide_removal``, ``decide_close``,
``is_closed_mode_complete``, and the four entry constructors.

Mechanism: seeded ``random.Random(seed)`` generation of ``int``-keyed conflict
graphs. The seed appears in every assertion message and in each parametrized
case id, so any failure is reproducible by rerunning that case. ``hypothesis``
is absent from ``pyproject.toml``, is deliberately not imported, and no
dependency is added by this feature.

No test creates a temporary file, starts a subprocess, reads the wall clock, or
invokes ``git`` or ``gh``.
"""

from __future__ import annotations

import random
from datetime import datetime, timezone

import pytest

from scripts.dev_tools._parallel_mutation_models import (
    AdmissionOutcome,
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

# The generation every generated case starts from.
START_GENERATION = 4

# The single timestamp every constructed entry records.
FIXED_NOW = datetime(2026, 8, 8, 11, 0, tzinfo=timezone.utc)

# The four unstarted item states, cycled when labelling generated items.
UNSTARTED_STATE_CYCLE = ("proposed", "admitted", "prepared", "scheduled")


def fixed_clock() -> datetime:
    """Return the module's fixed timestamp.

    Returns:
        datetime: ``FIXED_NOW``, so every constructed entry is deterministic.
    """

    return FIXED_NOW


class GeneratedRun:
    """A randomly generated parallel run, reproducible from its seed.

    Purpose and responsibilities:
        Produce one arbitrary conflict graph plus an arbitrary partition of its
        vertices into pinned (``in_flight``) and unstarted items, so a property
        can be asserted over many shapes. It generates data only; it asserts
        nothing and calls no engine function.

    Usage and invariants:
        Keys are positive ``int`` values, matching F3's ``items[].issue_num``.
        The pinned and unstarted key sets are disjoint and together cover every
        generated key. Edges are normalized to ``(a, b)`` with ``a < b`` and
        deduplicated, matching F3's conflict-edge normalization.

    Attributes:
        seed (int): The seed this run was generated from, reported on failure.
        keys (list[int]): Every generated item key, ascending.
        pinned (frozenset[int]): Keys whose items are ``in_flight``.
        unstarted (list[int]): Keys whose items are unstarted, ascending.
        edges (list[tuple[int, int]]): Normalized, deduplicated conflict edges.
        items (dict[int, ItemRecord]): The item table for this run.
    """

    def __init__(self, seed: int) -> None:
        """Generate one run from a seed.

        Args:
            seed (int): The RNG seed. The same seed always yields the same run,
                so a reported seed reproduces a failure exactly.

        Returns:
            None.

        Side Effects:
            None beyond populating this instance.
        """

        self.seed = seed
        rng = random.Random(seed)  # noqa: S311 - test data generation, not security

        count = rng.randint(MIN_ITEMS, MAX_ITEMS)
        # Offset the keys off 1 so a test cannot pass by assuming 0-based keys.
        self.keys = [100 + index for index in range(count)]

        # Partition the vertices. The pinned share varies with the seed so some
        # runs have no pinned item and others are almost entirely pinned.
        pinned_count = rng.randint(0, count - 1)
        pinned_keys = rng.sample(self.keys, pinned_count)
        self.pinned = frozenset(pinned_keys)
        self.unstarted = [key for key in self.keys if key not in self.pinned]

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
        """Recolor this run's unstarted subgraph.

        A thin wrapper over ``recolor_unstarted`` that binds this run's vertex
        set, edges, and pinned set, so each property reads as one call.

        Args:
            generation (int): The generation to recolor from.

        Returns:
            RecolorResult: The engine's result for this run.
        """

        return recolor_unstarted(self.unstarted, self.edges, self.pinned, generation)

    def __str__(self) -> str:
        """Describe the run compactly for an assertion message.

        Returns:
            str: The seed and the run's shape, so a failure message alone is
            enough to reproduce the case.
        """

        return (
            f"seed={self.seed} keys={self.keys} pinned={sorted(self.pinned)} "
            f"edges={self.edges}"
        )


@pytest.fixture(params=SEEDS, ids=[f"seed{seed}" for seed in SEEDS])
def run(request: pytest.FixtureRequest) -> GeneratedRun:
    """Provide one generated run per seed.

    Args:
        request (pytest.FixtureRequest): Pytest's request object carrying the
            seed parameter.

    Returns:
        GeneratedRun: The run for this seed. The case id names the seed, so a
        failing case is reproducible from the test report alone.
    """

    return GeneratedRun(int(request.param))


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
            shuffled_vertices, shuffled_edges, run.pinned, START_GENERATION
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

    def test_cohort_indices_are_contiguous_from_zero(self, run: GeneratedRun) -> None:
        """Indices form a gapless range, so no cohort position is empty."""

        indices = set(run.recolor().cohort_assignments.values())
        expected = set(range(len(indices)))
        assert indices == expected, f"cohort indices were not contiguous for {run}"


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

    def test_edges_touching_a_pinned_vertex_do_not_constrain_the_coloring(
        self, run: GeneratedRun
    ) -> None:
        """Dropping pinned endpoints is what makes the subgraph induced."""

        # Arrange: recolor with the full edge list and with the induced list.
        induced = [
            edge
            for edge in run.edges
            if edge[0] not in run.pinned and edge[1] not in run.pinned
        ]

        # Act
        from_induced = recolor_unstarted(
            run.unstarted, induced, run.pinned, START_GENERATION
        )

        # Assert
        assert run.recolor() == from_induced, f"pinned edges affected coloring: {run}"


class TestPropertyThreePinStability:
    """P3 -- in-flight items are untouched by an arbitrary mutation sequence."""

    def test_pinned_items_never_change_state_or_cohort_across_a_sequence(
        self, run: GeneratedRun
    ) -> None:
        """Apply a generated add/remove sequence and assert pins never moved."""

        # Arrange: record every pinned item's state and cohort before the run.
        rng = random.Random(run.seed)  # noqa: S311 - test data generation
        items = dict(run.items)
        generation = START_GENERATION
        cohort_by_key = dict(run.recolor(generation).cohort_assignments)
        for key in run.pinned:
            # Pinned items hold a cohort from an earlier generation; model that
            # as index 0, which the recolor must never overwrite.
            cohort_by_key.setdefault(key, 0)
        pinned_states_before = {key: items[key].state for key in run.pinned}
        pinned_cohorts_before = {key: cohort_by_key[key] for key in run.pinned}

        # Act: perform an arbitrary sequence of adds and removes.
        unstarted = list(run.unstarted)
        for step in range(6):
            if unstarted and rng.random() < 0.5:
                target = rng.choice(unstarted)
                try:
                    decision = decide_removal(target, items)
                except ParallelMutationError:
                    continue
                unstarted.remove(target)
                items[target] = ItemRecord(target, decision.new_state)
                generation = build_remove_entry(
                    decision, current_generation=generation, clock=fixed_clock
                ).recolor_generation
            else:
                candidate = 900 + step
                decision = decide_admission(candidate, run.edges, run.pinned)
                unstarted.append(candidate)
                items[candidate] = ItemRecord(candidate, "scheduled")
                generation = build_add_entry(
                    candidate,
                    deferred=decision.triggers_recompute,
                    current_generation=generation,
                    clock=fixed_clock,
                ).recolor_generation

            # Reapply the recolor after each op, as the orchestrator would.
            refreshed = recolor_unstarted(unstarted, run.edges, run.pinned, generation)
            for key, index in refreshed.cohort_assignments.items():
                cohort_by_key[key] = index
            generation = refreshed.generation

        # Assert: every pinned item is exactly as it started.
        for key in run.pinned:
            assert (
                items[key].state == pinned_states_before[key]
            ), f"pinned item {key} changed state for {run}"
            assert (
                cohort_by_key[key] == pinned_cohorts_before[key]
            ), f"pinned item {key} changed cohort for {run}"

    def test_a_pinned_item_is_never_a_removal_target_without_a_disposition(
        self, run: GeneratedRun
    ) -> None:
        """Every pinned item rejects a bare removal, for every generated run."""

        # Act / Assert
        for key in run.pinned:
            with pytest.raises(ParallelMutationError):
                decide_removal(key, run.items)


class TestPerFunctionProperties:
    """At least one property per pure engine function."""

    def test_admission_defers_exactly_when_a_pinned_neighbour_exists(
        self, run: GeneratedRun
    ) -> None:
        """``decide_admission`` agrees with the graph for every unstarted item."""

        # Arrange: derive each vertex's pinned neighbours straight from the edges.
        for candidate in run.unstarted:
            has_pinned_neighbour = any(
                (first == candidate and second in run.pinned)
                or (second == candidate and first in run.pinned)
                for first, second in run.edges
            )

            # Act
            decision = decide_admission(candidate, run.edges, run.pinned)

            # Assert
            expected = (
                AdmissionOutcome.DEFER_AND_RECOLOR
                if has_pinned_neighbour
                else AdmissionOutcome.ADMIT_CURRENT_COHORT
            )
            assert (
                decision.outcome is expected
            ), f"wrong admission for candidate {candidate} in {run}"

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
        decide_admission(run.keys[0], run.edges, run.pinned)
        recolor_unstarted(run.unstarted, run.edges, run.pinned, START_GENERATION)
        is_closed_mode_complete(run.items)

        # Assert
        assert run.keys == keys_before, f"keys mutated for {run}"
        assert run.edges == edges_before, f"edges mutated for {run}"
        assert run.items == items_before, f"items mutated for {run}"
