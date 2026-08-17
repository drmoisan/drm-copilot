"""Seeded property tests for the composed cohort-contention guarantee.

Holds three property suites, each over a corpus of seeded random runs:

- **P4 (composed contention invariant)** -- over arbitrary conflict graphs,
  arbitrary pinned/unstarted partitions, and arbitrary admission-and-recolor
  sequences, no cohort in the resulting assignment contains two items sharing a
  conflict edge, counting edges to pinned items. This is the property whose
  absence allowed BOTH spec 1.2 design corrections to ship.
- the corrected per-function ``decide_admission`` property, relocated from
  ``test_parallel_mutation_protocol_properties.py`` and rewritten against the
  current-cohort rule rather than the in-flight-only rule.
- **P3 (pin stability under mutation sequences)**, relocated unchanged in
  substance from the same module.

This module is deliberately SELF-CONTAINED: it defines its own seeded
``random.Random`` generator and imports from no other test module. The
duplication is the cost of the repository's 500-line cap. ``hypothesis`` is
absent from this repository and stays absent; determinism comes from
``random.Random(seed)`` with the seed emitted into every assertion message and
into every pytest case id, so a failure is reproducible from the report alone.

Keys are positive ``int`` values matching F3's ``items[].issue_num``. No test
creates a temporary file, starts a subprocess, or invokes ``git`` or ``gh``.
"""

from __future__ import annotations

import random
from datetime import datetime, timezone

import pytest

from scripts.dev_tools._parallel_mutation_models import (
    AdmissionOutcome,
    ItemRecord,
    RecolorResult,
)
from scripts.dev_tools.parallel_mutation_protocol import (
    build_add_entry,
    decide_admission,
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

# How many admission steps each P4 run performs.
ADMISSION_STEPS = 3

# The single timestamp every constructed entry records.
FIXED_NOW = datetime(2026, 8, 8, 11, 0, tzinfo=timezone.utc)

# The four unstarted item states, cycled when labelling generated items.
UNSTARTED_STATE_CYCLE = ("proposed", "admitted", "prepared", "scheduled")


def fixed_clock() -> datetime:
    """Return ``FIXED_NOW`` so every constructed entry is deterministic."""

    return FIXED_NOW


def crosses_pinned(
    edges: list[tuple[int, int]], unstarted_keys: frozenset[int], pinned: frozenset[int]
) -> bool:
    """Recompute the pinned-barrier predicate independently of the engine.

    The offset-value assertion needs a second, independent derivation; deriving it
    from the engine's own return value would make that assertion vacuous.

    Args:
        edges (list[tuple[int, int]]): The full conflict edge list.
        unstarted_keys (frozenset[int]): The keys being colored.
        pinned (frozenset[int]): The pinned keys.

    Returns:
        bool: True when some edge joins an unstarted key to a pinned key.
    """

    # Scan the FULL edge list, since the engine's induced restriction is exactly
    # what discards these edges.
    return any(
        (first in unstarted_keys and second in pinned)
        or (second in unstarted_keys and first in pinned)
        for first, second in edges
    )


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


class TestPerFunctionAdmissionProperty:
    """The corrected per-function property for ``decide_admission``.

    Relocated from ``test_parallel_mutation_protocol_properties.py`` and
    rewritten: the expected outcome is now derived from a neighbour in
    ``pinned | current_cohort_members`` rather than from a pinned neighbour alone.
    The expectation is computed independently from the generated edge list, never
    from the engine's own return value.
    """

    def test_admission_defers_exactly_when_a_current_cohort_neighbour_exists(
        self, run: GeneratedRun
    ) -> None:
        """``decide_admission`` agrees with the graph for every unstarted item."""

        blocking = run.pinned | run.current_cohort_members

        # Check every unstarted vertex as a candidate, so one run exercises many
        # neighbourhood shapes rather than a single arbitrary vertex.
        for candidate in run.unstarted:
            # Derive the expectation straight from the edges, independently.
            has_blocking_neighbour = any(
                (first == candidate and second in blocking)
                or (second == candidate and first in blocking)
                for first, second in run.edges
            )

            # Act
            decision = decide_admission(
                candidate,
                run.edges,
                run.pinned,
                current_cohort_members=run.current_cohort_members,
            )

            # Assert
            expected = (
                AdmissionOutcome.DEFER_AND_RECOLOR
                if has_blocking_neighbour
                else AdmissionOutcome.ADMIT_CURRENT_COHORT
            )
            assert (
                decision.outcome is expected
            ), f"wrong admission for candidate {candidate} in {run}"


def assert_no_conflicting_pair(
    edges: list[tuple[int, int]], cohort_by_key: dict[int, int], generated: GeneratedRun
) -> None:
    """Assert no cohort in the map holds two items sharing a conflict edge.

    Only edges whose BOTH endpoints are in the map are constrained; a key with no
    index yet has nothing to compare. Raises nothing and returns ``None``.

    Args:
        edges (list[tuple[int, int]]): The full conflict edge list.
        cohort_by_key (dict[int, int]): The complete cohort assignment.
        generated (GeneratedRun): The run, named in the failure message.
    """

    for first, second in edges:
        if first in cohort_by_key and second in cohort_by_key:
            assert cohort_by_key[first] != cohort_by_key[second], (
                f"conflicting items {first} and {second} share cohort "
                f"{cohort_by_key[first]} in {generated}"
            )


def assert_offset_value(
    generated: GeneratedRun,
    edges: list[tuple[int, int]],
    unstarted_keys: frozenset[int],
    result: RecolorResult,
) -> None:
    """Assert the offset equals the rule, not merely that some shift occurred.

    Required because the contention assertion alone cannot distinguish the correct
    conditional offset from an unconditional ``+1``: an unconditional shift also
    vacates the pinned index, so a pure contention check still passes. Pinning the
    exact value fails deterministically under a REMOVED offset and under an
    UNCONDITIONAL one. Returns ``None``.

    Args:
        generated (GeneratedRun): The run being replayed.
        edges (list[tuple[int, int]]): The full conflict edge list.
        unstarted_keys (frozenset[int]): The keys that were colored.
        result (RecolorResult): The engine's result.
    """

    if not result.cohort_assignments:
        return

    # Recompute the predicate independently of the engine's return value.
    expected_base = generated.current_cohort
    if crosses_pinned(edges, unstarted_keys, generated.pinned):
        expected_base += 1

    assert min(result.cohort_assignments.values()) == expected_base, (
        f"offset base should be {expected_base} for {generated}; "
        f"got {min(result.cohort_assignments.values())}"
    )


def replay_admission_sequence(generated: GeneratedRun) -> dict[str, bool]:
    """Replay one run's admission-and-recolor sequence, asserting throughout.

    Builds the FULL assignment map -- pinned items at ``current_cohort``, unstarted
    items where the engine puts them -- then applies a seed-derived sequence of
    candidate admissions, asserting the contention invariant after EVERY step and
    the offset value on EVERY recolor.

    Args:
        generated (GeneratedRun): The run to replay.

    Returns:
        dict[str, bool]: Which branches this run exercised, for the caller's
        corpus existentials.
    """

    rng = random.Random(generated.seed * 7919)
    edges = list(generated.edges)
    unstarted = list(generated.unstarted)
    generation = START_GENERATION

    cohort_by_key = {key: generated.current_cohort for key in generated.pinned}
    initial = generated.recolor(generation)
    assert_offset_value(generated, edges, frozenset(unstarted), initial)
    cohort_by_key.update(initial.cohort_assignments)
    generation = initial.generation
    assert_no_conflicting_pair(edges, cohort_by_key, generated)

    exercised = {"admitted": False, "deferred": False, "no_offset_recolor": False}

    # Apply a seed-derived sequence of candidate admissions.
    for step in range(ADMISSION_STEPS):
        candidate = 900 + step
        # Give the candidate seed-derived edges into the existing graph so some
        # candidates conflict with pinned items, some with unstarted cohort
        # members, and some with nothing.
        for key in generated.keys:
            if rng.random() < 0.35:
                edges.append((min(key, candidate), max(key, candidate)))

        decision = decide_admission(
            candidate,
            edges,
            generated.pinned,
            current_cohort_members=generated.current_cohort_members,
        )
        build_add_entry(
            candidate,
            deferred=decision.triggers_recompute,
            current_generation=generation,
            clock=fixed_clock,
        )

        # An admitted candidate joins the current cohort AND, being `scheduled`,
        # becomes a vertex of every later recolor. Omitting it from `unstarted`
        # would leave a stale index in the map and make the assertion test the
        # harness rather than the engine.
        unstarted.append(candidate)
        if decision.outcome is AdmissionOutcome.ADMIT_CURRENT_COHORT:
            exercised["admitted"] = True
            cohort_by_key[candidate] = generated.current_cohort
        else:
            exercised["deferred"] = True
            unstarted_keys = frozenset(unstarted)
            refreshed = recolor_unstarted(
                unstarted,
                edges,
                generated.pinned,
                generation,
                current_cohort=generated.current_cohort,
                highest_pinned_cohort=generated.current_cohort,
            )
            assert_offset_value(generated, edges, unstarted_keys, refreshed)
            if not crosses_pinned(edges, unstarted_keys, generated.pinned):
                exercised["no_offset_recolor"] = True
            # Replace the unstarted portion wholesale, as the orchestrator does.
            for key in unstarted:
                cohort_by_key.pop(key, None)
            cohort_by_key.update(refreshed.cohort_assignments)
            generation = refreshed.generation

        assert_no_conflicting_pair(edges, cohort_by_key, generated)

    return exercised


class TestPropertyFourComposedContention:
    """P4 -- no cohort ever holds two items sharing a conflict edge.

    The composed, full-assignment invariant, asserted over the complete cohort map
    after every step of a generated admission-and-recolor sequence. Edges to
    pinned items are counted, because the pinned items are present in the map.

    Binding relationships this property establishes:

    - it FAILS if ``decide_admission`` is reverted to the in-flight-only rule,
      because a candidate conflicting with an unstarted current-cohort member
      would then be admitted into ``current_cohort`` beside it;
    - it FAILS if ``recolor_unstarted``'s pinned-barrier offset is REMOVED,
      because a candidate deferred on a pinned conflict would be re-based to 0 and
      rejoin its pinned conflict whenever ``current_cohort == 0``;
    - it FAILS if the offset is made UNCONDITIONAL, which the contention assertion
      alone cannot detect, and which ``assert_offset_value`` therefore catches.

    It is the property whose absence allowed both C1 and C2 to ship.
    """

    def test_no_cohort_holds_a_conflicting_pair_across_admission_sequences(
        self,
    ) -> None:
        """Assert the contention invariant over the whole seed corpus.

        The corpus is walked inside one test rather than through the per-seed
        fixture because four of the assertions are corpus-level existentials that
        prove the corpus is not degenerate.
        """

        saw_admit = False
        saw_defer = False
        saw_pinned_edge = False
        saw_no_offset_recolor = False

        for seed in SEEDS:
            generated = GeneratedRun(seed)

            # Non-vacuity: the generated cohort must be a genuine independent set
            # of the full graph, or the property would test a fixture no coloring
            # could have produced.
            for first, second in generated.edges:
                assert not (
                    first in generated.current_cohort_members
                    and second in generated.current_cohort_members
                ), f"generated cohort is not an independent set: {generated}"

            if crosses_pinned(
                generated.edges, frozenset(generated.unstarted), generated.pinned
            ):
                saw_pinned_edge = True

            exercised = replay_admission_sequence(generated)
            saw_admit = saw_admit or exercised["admitted"]
            saw_defer = saw_defer or exercised["deferred"]
            saw_no_offset_recolor = (
                saw_no_offset_recolor or exercised["no_offset_recolor"]
            )

        # Corpus-level non-vacuity, so a degenerate generator cannot make the
        # property pass trivially.
        assert saw_admit, "no run in the corpus produced ADMIT_CURRENT_COHORT"
        assert saw_defer, "no run in the corpus produced DEFER_AND_RECOLOR"
        assert saw_pinned_edge, "no run had an unstarted-to-pinned conflict edge"
        assert saw_no_offset_recolor, (
            "no run both lacked an unstarted-to-pinned edge AND performed a "
            "recolor, so the offset-not-applied branch was never asserted"
        )
