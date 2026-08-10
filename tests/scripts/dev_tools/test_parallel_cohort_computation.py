"""Tests for the parallel cohort-computation reference implementation.

This file covers the coloring behavior: graph shapes, Welsh-Powell ordering,
the ascending tie-break, determinism under fixed literal permutations, edge
symmetry, and the structural invariants. The malformed-input modes and the
`max_concurrency` slot-filling boundary matrix live in the pre-approved split
file `tests/scripts/dev_tools/test_parallel_cohort_computation_errors.py`.
"""

from __future__ import annotations

from itertools import combinations

from scripts.dev_tools.parallel_cohort_computation import (
    ParallelCohortInputError,
    compute_cohorts,
    compute_concurrency_batches,
)


def test_module_public_surface_is_importable() -> None:
    """Expose the two public functions and the dedicated exception class."""

    assert callable(compute_cohorts)
    assert callable(compute_concurrency_batches)
    assert issubclass(ParallelCohortInputError, ValueError)


def test_compute_cohorts_user_story_scenario_splits_the_conflicting_items() -> None:
    """Reproduce the user-story scenario: 443 conflicts with 445 and 446.

    443 has degree 2 and is visited first, taking cohort 0. The unconflicted
    444 also lands in cohort 0; 445 and 446 are pushed to cohort 1.
    """

    cohorts = compute_cohorts([443, 444, 445, 446], [(443, 445), (443, 446)])

    assert cohorts == [[443, 444], [445, 446]]


def test_compute_cohorts_empty_input_returns_no_cohorts() -> None:
    """Return an empty cohort list when there are no items to schedule."""

    assert compute_cohorts([], []) == []


def test_compute_cohorts_single_vertex_returns_one_singleton_cohort() -> None:
    """Place a lone item in cohort 0 as the first-visited vertex."""

    assert compute_cohorts([443], []) == [[443]]


def test_compute_cohorts_all_isolated_vertices_share_one_cohort() -> None:
    """Place every conflict-free item in cohort 0, sorted ascending.

    The keys are supplied out of ascending order to show that cohort
    membership is emitted sorted rather than in arrival order.
    """

    cohorts = compute_cohorts([446, 443, 445, 444], [])

    assert cohorts == [[443, 444, 445, 446]]


def test_compute_cohorts_complete_graph_returns_one_singleton_cohort_per_vertex() -> (
    None
):
    """Serialize a complete graph into one singleton cohort per vertex.

    Every vertex conflicts with every other, so no two items may share a
    cohort. The four vertices have equal degree, so the ascending tie-break
    also fixes the cohort order.
    """

    cohorts = compute_cohorts(
        [443, 444, 445, 446],
        [
            (443, 444),
            (443, 445),
            (443, 446),
            (444, 445),
            (444, 446),
            (445, 446),
        ],
    )

    assert cohorts == [[443], [444], [445], [446]]


def test_compute_cohorts_uses_degree_order_not_the_supplied_item_key_order() -> None:
    """Color by descending degree, which beats the supplied ordering here.

    The fixture is a six-vertex crown graph (701/702/703 against
    704/705/706, each left vertex conflicting with the two right vertices it
    is not paired with) plus a pendant 707 attached to 701. `item_keys` is
    supplied in the interleaved order 701, 704, 702, 705, 703, 706, 707,
    which is exactly the order that makes greedy coloring perform badly.

    Visiting in that supplied order yields three cohorts,
    `[[701, 704], [702, 705, 707], [703, 706]]`, because each interleaved
    vertex sees one neighbor already holding cohort 0 and the next already
    holding cohort 1. Welsh-Powell instead visits 701 first (degree 3), then
    the degree-2 vertices in ascending key order, and finds the two-cohort
    bipartition. This test therefore fails under insertion-order coloring.
    """

    cohorts = compute_cohorts(
        [701, 704, 702, 705, 703, 706, 707],
        [
            (701, 705),
            (701, 706),
            (702, 704),
            (702, 706),
            (703, 704),
            (703, 705),
            (701, 707),
        ],
    )

    assert cohorts == [[701, 702, 703], [704, 705, 706, 707]]


def test_compute_cohorts_breaks_degree_ties_by_ascending_item_key() -> None:
    """Break equal-degree ties by ascending item key, not descending.

    The fixture is a five-cycle 901-902-903-904-905-901, so every vertex has
    degree 2 and the visit order is decided entirely by the tie-break. The
    ascending tie-break visits 901 first and produces
    `[[901, 903], [902, 904], [905]]`. A descending tie-break visits 905
    first and produces `[[903, 905], [902, 904], [901]]`, so this exact-output
    assertion fails if the tie-break direction is ever inverted.
    """

    cohorts = compute_cohorts(
        [901, 902, 903, 904, 905],
        [(901, 902), (902, 903), (903, 904), (904, 905), (905, 901)],
    )

    assert cohorts == [[901, 903], [902, 904], [905]]


CANONICAL_ITEM_KEYS = [443, 444, 445, 446, 447]
CANONICAL_CONFLICT_EDGES = [(443, 445), (443, 446), (444, 447), (445, 446)]
CANONICAL_COHORTS = [[443, 444], [445, 447], [446]]


def test_compute_cohorts_repeated_invocation_returns_identical_cohorts() -> None:
    """Return the same cohorts when the same input is colored twice."""

    first = compute_cohorts(CANONICAL_ITEM_KEYS, CANONICAL_CONFLICT_EDGES)
    second = compute_cohorts(CANONICAL_ITEM_KEYS, CANONICAL_CONFLICT_EDGES)

    assert first == CANONICAL_COHORTS
    assert second == first


def test_compute_cohorts_is_unaffected_by_permuted_item_keys() -> None:
    """Ignore the arrival order of `item_keys` when assigning cohorts.

    The permutation is a fixed literal rather than a generated or randomized
    ordering, so the test is reproducible without a seeded RNG.
    """

    permuted_keys = [447, 444, 446, 443, 445]

    cohorts = compute_cohorts(permuted_keys, CANONICAL_CONFLICT_EDGES)

    assert cohorts == CANONICAL_COHORTS


def test_compute_cohorts_is_unaffected_by_permuted_and_flipped_edges() -> None:
    """Ignore edge order and edge direction when assigning cohorts.

    Every canonical edge is reversed and the list is reordered, using fixed
    literals. Normalization must collapse this to the same conflict graph.
    """

    permuted_flipped_edges = [(446, 445), (447, 444), (446, 443), (445, 443)]

    cohorts = compute_cohorts(CANONICAL_ITEM_KEYS, permuted_flipped_edges)

    assert cohorts == CANONICAL_COHORTS


def test_compute_cohorts_treats_a_reversed_edge_as_the_same_conflict() -> None:
    """Treat `(b, a)` as the same undirected conflict as `(a, b)`."""

    normalized = compute_cohorts([443, 444, 445], [(443, 445)])
    reversed_direction = compute_cohorts([443, 444, 445], [(445, 443)])

    assert normalized == [[443, 444], [445]]
    assert reversed_direction == normalized


def test_compute_cohorts_collapses_duplicated_edges_into_one_conflict() -> None:
    """Count a repeated edge once, so degrees and cohorts are unchanged.

    The duplicated list repeats the 443-445 conflict in both directions. If
    duplicates inflated 443's degree, the visit order and therefore the
    cohort assignment could change.
    """

    normalized = compute_cohorts([443, 444, 445], [(443, 445)])
    duplicated = compute_cohorts(
        [443, 444, 445],
        [(443, 445), (445, 443), (443, 445)],
    )

    assert normalized == [[443, 444], [445]]
    assert duplicated == normalized


INVARIANT_ITEM_KEYS = [801, 802, 803, 804, 805, 806]
INVARIANT_CONFLICT_EDGES = [
    (801, 802),
    (802, 803),
    (803, 801),
    (804, 805),
    (801, 806),
    (802, 806),
]
INVARIANT_COHORTS = [[801, 804], [802, 805], [803, 806]]


def test_compute_cohorts_never_places_two_conflicting_items_in_one_cohort() -> None:
    """Emit cohorts that are independent sets of the conflict graph."""

    cohorts = compute_cohorts(INVARIANT_ITEM_KEYS, INVARIANT_CONFLICT_EDGES)

    assert cohorts == INVARIANT_COHORTS
    conflicts = {frozenset(edge) for edge in INVARIANT_CONFLICT_EDGES}
    # Check every unordered pair inside every cohort against the conflict set,
    # which is the direct statement of the independent-set invariant.
    for index, cohort in enumerate(cohorts):
        for first, second in combinations(cohort, 2):
            assert frozenset((first, second)) not in conflicts, (
                f"Cohort {index} contains the conflicting pair "
                f"({first}, {second}); cohorts must be independent sets."
            )


def test_compute_cohorts_covers_every_item_key_exactly_once() -> None:
    """Partition the item keys: every key appears in exactly one cohort."""

    cohorts = compute_cohorts(INVARIANT_ITEM_KEYS, INVARIANT_CONFLICT_EDGES)

    assigned_keys = [item_key for cohort in cohorts for item_key in cohort]

    assert sorted(assigned_keys) == sorted(INVARIANT_ITEM_KEYS), (
        "Concatenated cohorts must cover item_keys exactly once; got "
        f"{sorted(assigned_keys)}."
    )
    assert len(assigned_keys) == len(
        set(assigned_keys)
    ), f"An item key was assigned to more than one cohort: {assigned_keys}."


def test_compute_cohorts_emits_each_cohort_sorted_ascending() -> None:
    """Emit each cohort's item keys in ascending order.

    The keys are supplied in a scrambled fixed order so a result that merely
    echoed arrival order would not be ascending.
    """

    cohorts = compute_cohorts(
        [806, 803, 801, 805, 802, 804],
        INVARIANT_CONFLICT_EDGES,
    )

    # Assert per cohort so a failure identifies which cohort is unordered.
    for index, cohort in enumerate(cohorts):
        assert cohort == sorted(
            cohort
        ), f"Cohort {index} is not sorted ascending: {cohort}."
    assert cohorts == INVARIANT_COHORTS


def test_compute_cohorts_does_not_mutate_its_input_arguments() -> None:
    """Leave the caller's `item_keys` and `conflict_edges` objects unchanged."""

    item_keys = [806, 803, 801, 805, 802, 804]
    conflict_edges = list(INVARIANT_CONFLICT_EDGES)
    item_keys_before = list(item_keys)
    conflict_edges_before = list(conflict_edges)

    compute_cohorts(item_keys, conflict_edges)

    assert (
        item_keys == item_keys_before
    ), f"compute_cohorts mutated item_keys: {item_keys}."
    assert (
        conflict_edges == conflict_edges_before
    ), f"compute_cohorts mutated conflict_edges: {conflict_edges}."


def test_compute_concurrency_batches_does_not_mutate_its_input_sequence() -> None:
    """Leave the caller's `cohort_item_keys` sequence unchanged.

    The function sorts its own input, so it must sort a copy rather than
    sorting the caller's list in place.
    """

    cohort_item_keys = [806, 803, 801, 805, 802, 804]
    cohort_item_keys_before = list(cohort_item_keys)

    compute_concurrency_batches(cohort_item_keys, 2)

    assert cohort_item_keys == cohort_item_keys_before, (
        f"compute_concurrency_batches mutated cohort_item_keys: " f"{cohort_item_keys}."
    )
