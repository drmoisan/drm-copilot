"""Seeded property test P3 -- pin stability under arbitrary mutation sequences.

Property P3: for an arbitrary sequence of add/remove operations against a live
in-flight set, items in flight at operation time never change cohort or state as a
result of the operation. Relocated from
``tests/scripts/dev_tools/test_parallel_mutation_protocol_properties.py`` with both
engine call sites migrated to the spec 1.2 signatures; every assertion is preserved.

This module is deliberately SELF-CONTAINED: it defines its own seeded
``random.Random`` generator and imports from no other test module. The generator
duplication is deliberate and is the cost of the repository's 500-line cap, the same
trade the sibling contention-property module makes. ``hypothesis`` is absent from
this repository and stays absent; determinism comes from ``random.Random(seed)``
with the seed emitted into every assertion message and into every pytest case id, so
a failure is reproducible from the report alone.

Keys are positive ``int`` values matching F3's ``items[].issue_num``. No test
creates a temporary file, starts a subprocess, or invokes ``git`` or ``gh``.
"""

from __future__ import annotations

import random
from datetime import datetime, timezone

import pytest

from scripts.dev_tools._parallel_mutation_errors import ParallelMutationError
from scripts.dev_tools._parallel_mutation_models import ItemRecord, RecolorResult
from scripts.dev_tools.parallel_mutation_protocol import (
    build_add_entry,
    build_remove_entry,
    decide_admission,
    decide_removal,
    recolor_unstarted,
)

# A fixed seed corpus. Twelve seeds keep the suite fast while covering many graph
# shapes; the seed appears in each case id and in every assertion message.
SEEDS = (1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233)

# Bounds on generated graphs. Small graphs stay fast while still producing
# pinned/unstarted partitions, isolated vertices, and dense cliques.
MIN_ITEMS = 3
MAX_ITEMS = 10

# The generation every generated case starts from.
START_GENERATION = 4

# The single timestamp every constructed entry records.
FIXED_NOW = datetime(2026, 8, 8, 11, 0, tzinfo=timezone.utc)

# The four unstarted item states, cycled when labelling generated items.
UNSTARTED_STATE_CYCLE = ("proposed", "admitted", "prepared", "scheduled")


def fixed_clock() -> datetime:
    """Return ``FIXED_NOW`` so every constructed entry is deterministic."""

    return FIXED_NOW


class GeneratedRun:
    """A randomly generated parallel run, reproducible from its seed.

    Produces one arbitrary conflict graph, an arbitrary pinned/unstarted partition,
    a current cohort that is a genuine independent set of the FULL graph, and the
    index that cohort occupies. It generates data only and asserts nothing.

    ``current_cohort_members`` is built by scanning keys in a seed-derived order and
    admitting a key only when it has no edge to a key already in the set, which is
    the shape F2's coloring produces. ``pinned`` is a subset of that cohort,
    mirroring production, where every pinned item occupies the cohort at
    ``current_cohort``; the remaining members are its not-yet-launched ``scheduled``
    members. Keys are positive ``int`` values.

    Attributes:
        seed (int): The seed this run was generated from, reported on failure.
        keys (list[int]): Every generated item key, ascending.
        edges (list[tuple[int, int]]): Normalized, deduplicated conflict edges.
        current_cohort (int): The index the pinned items occupy.
        current_cohort_members (frozenset[int]): The cohort's full membership.
        pinned (frozenset[int]): Keys whose items are ``in_flight``.
        unstarted (list[int]): Keys whose items are unstarted, ascending.
        items (dict[int, ItemRecord]): The item table for this run.
    """

    def __init__(self, seed: int) -> None:
        """Generate one run from ``seed``; the same seed always yields the same run."""

        self.seed = seed
        # Deterministic test-data generation with the seed printed on failure, as
        # required by the repository's determinism rules.
        rng = random.Random(seed)

        count = rng.randint(MIN_ITEMS, MAX_ITEMS)
        # Offset the keys off 1 so a test cannot pass by assuming 0-based keys.
        self.keys = [100 + index for index in range(count)]

        # Generate edges over ALL vertices, including the ones that become
        # pinned, because admission is decided against the full graph.
        density = rng.random()
        edge_set: set[tuple[int, int]] = set()
        for first_index, first in enumerate(self.keys):
            for second in self.keys[first_index + 1 :]:
                if rng.random() < density:
                    edge_set.add((first, second))
        self.edges = sorted(edge_set)

        neighbours = self._build_adjacency()

        # Build the current cohort as a genuine independent set of the FULL
        # graph, scanning in a seed-derived order and admitting a key only when
        # it conflicts with nothing already admitted. This is the shape F2's
        # coloring produces, so the property tests the engine rather than an
        # impossible fixture.
        scan_order = list(self.keys)
        rng.shuffle(scan_order)
        cohort: set[int] = set()
        for key in scan_order:
            if neighbours[key].isdisjoint(cohort):
                cohort.add(key)
        self.current_cohort_members = frozenset(cohort)

        # The pinned items are a subset of the cohort, because a running item
        # occupies the cohort at ``current_cohort``.
        cohort_list = sorted(cohort)
        pinned_count = rng.randint(0, len(cohort_list))
        self.pinned = frozenset(rng.sample(cohort_list, pinned_count))
        self.unstarted = [key for key in self.keys if key not in self.pinned]

        # Vary the base index so no assertion can pass by assuming zero.
        self.current_cohort = rng.randint(0, 4)

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

    def _build_adjacency(self) -> dict[int, set[int]]:
        """Map each key to its conflict neighbours over the full generated graph."""

        # Both endpoint directions are recorded because edges are undirected.
        neighbours: dict[int, set[int]] = {key: set() for key in self.keys}
        for first, second in self.edges:
            neighbours[first].add(second)
            neighbours[second].add(first)
        return neighbours

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
            highest_pinned_cohort=self.current_cohort,
        )

    def __str__(self) -> str:
        """Report the seed and shape, so a failure message alone reproduces it."""

        return (
            f"seed={self.seed} keys={self.keys} pinned={sorted(self.pinned)} "
            f"cohort={sorted(self.current_cohort_members)} "
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


class TestPropertyThreePinStability:
    """P3 -- in-flight items are untouched by an arbitrary mutation sequence.

    Relocated from ``test_parallel_mutation_protocol_properties.py`` with both
    call sites migrated to the new signatures and bound to this module's own
    generator. Every assertion is preserved.
    """

    def test_pinned_items_never_change_state_or_cohort_across_a_sequence(
        self, run: GeneratedRun
    ) -> None:
        """Apply a generated add/remove sequence and assert pins never moved."""

        # Arrange: record every pinned item's state and cohort before the run.
        rng = random.Random(run.seed)
        items = dict(run.items)
        generation = START_GENERATION
        cohort_by_key = dict(run.recolor(generation).cohort_assignments)
        for key in run.pinned:
            # Pinned items hold the cohort at ``current_cohort``, which the
            # recolor must never overwrite.
            cohort_by_key.setdefault(key, run.current_cohort)
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
                admission = decide_admission(
                    candidate,
                    run.edges,
                    run.pinned,
                    current_cohort_members=run.current_cohort_members,
                )
                unstarted.append(candidate)
                items[candidate] = ItemRecord(candidate, "scheduled")
                generation = build_add_entry(
                    candidate,
                    deferred=admission.triggers_recompute,
                    current_generation=generation,
                    clock=fixed_clock,
                ).recolor_generation

            # Reapply the recolor after each op, as the orchestrator would.
            refreshed = recolor_unstarted(
                unstarted,
                run.edges,
                run.pinned,
                generation,
                current_cohort=run.current_cohort,
                highest_pinned_cohort=run.current_cohort,
            )
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
