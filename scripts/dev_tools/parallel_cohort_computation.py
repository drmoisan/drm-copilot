"""Compute parallel execution cohorts from an undirected conflict graph.

Purpose:
    Provide the canonical, tested reference implementation of the parallel
    surface's cohort-assignment rule: deterministic greedy graph coloring in
    Welsh-Powell order, plus the `max_concurrency` slot-filling rule. A cohort
    is one color class of the conflict graph, so every cohort is an
    independent set and its members are safe to execute concurrently.
    Optimality is explicitly not the objective; determinism and
    explainability are. Cohort counts at or above the graph's chromatic
    number are the expected outcome of greedy coloring and are not a defect.

Responsibilities:
    Given an explicit item-key set plus an undirected conflict-edge list,
    partition the item keys into an ordered list of cohorts, and chunk a
    single cohort into concurrency-capped batches. This module holds no
    state and persists nothing.

Input reduction from the checkpoint record:
    The checkpoint schema stores conflict edges as records of the shape
    `conflict_edges[] = { a, b, reason }`. This module accepts the normalized
    reduction rather than the record shape; callers perform
    `[(e["a"], e["b"]) for e in conflict_edges]`. `reason` is audit metadata
    with no effect on coloring, and accepting the record shape here would
    couple this module to the checkpoint schema in the wrong direction.

Contention-relation boundary:
    This module does not compute blast radii and never evaluates
    `conflicts(a, b)`. The contention relation and the blast-radius model are
    owned by the blast-radius surface; this module consumes the
    already-computed edge set only.

Caller-owned fields:
    `generation` (the `recolor_generation` counter) and `current_cohort` are
    caller-owned execution state. This module never produces, increments, or
    accepts either value.

Pinned-set boundary:
    There is no pinned-set parameter. Recoloring over a mutated item set is
    performed compositionally by the caller: invoke `compute_cohorts` on the
    induced subgraph of not-yet-started item keys and the edges among them,
    with in-flight (pinned) items excluded by the caller before the call.

Purity contract:
    Both public functions are pure. They perform no file I/O, no network
    access, no clock or RNG access, and no mutation of their input
    arguments. Identical input — including permuted-equivalent input —
    produces identical output.

Usage:
    Callers pass the item-key set and the normalized edge list to
    `compute_cohorts`, wrap each returned inner list with its positional
    cohort index, and then pass a single cohort's key list to
    `compute_concurrency_batches` to cap fan-out.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Iterable, Sequence


class ParallelCohortInputError(ValueError):
    """Raised when cohort computation receives malformed input.

    Purpose:
        Signal that the caller supplied an input that cannot be colored or
        batched deterministically, so the computation fails closed rather
        than silently producing a cohort assignment derived from bad data.

    Responsibilities:
        Carry one stable, literal message per malformed-input mode together
        with the offending value that produced it. The class performs no
        validation itself; the public functions detect each mode and raise
        this exception with the matching message and value.

    Usage:
        Callers catch this exception at the boundary where the conflict
        graph was assembled. Because it subclasses `ValueError`, existing
        `except ValueError` handlers continue to work.

    Key invariants:
        `offending_value` is always populated. Its type depends on the mode:

        - duplicate item key: the duplicated key (`int`)
        - self-loop edge: the self-conflicting key (`int`)
        - unknown edge endpoint: the offending edge (`tuple[int, int]`); the
          message additionally names the unknown key
        - non-positive `max_concurrency`: the invalid integer (`int`)

    Side effects:
        None.

    Attributes:
        offending_value (int | tuple[int, int]): The value that made the
            input malformed, per the mode mapping above. It is populated by
            the constructor and is never `None`.
    """

    offending_value: int | tuple[int, int]

    def __init__(self, message: str, offending_value: int | tuple[int, int]) -> None:
        """Initialize the exception with its message and the offending value.

        Args:
            message (str): The mode-specific, literal failure message. It
                names the offending value so the message alone is
                actionable.
            offending_value (int | tuple[int, int]): The item key, edge, or
                invalid integer that made the input malformed, per the mode
                mapping documented on the class.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Stores `offending_value` on the instance.
        """

        self.offending_value = offending_value
        super().__init__(message)


def _validate_item_keys(item_keys: Iterable[int]) -> list[int]:
    """Materialize the item keys and reject duplicates.

    Duplicate keys break the uniqueness assumption behind the total-order
    sort key `(-degree, item_key)`, so they are rejected rather than
    silently deduplicated.

    Args:
        item_keys (Iterable[int]): The vertex keys of the conflict graph.
            The iterable is consumed once and may be supplied in any order.

    Returns:
        list[int]: The item keys as a list, in the order supplied. Order is
        preserved only for error reporting; the coloring order is derived
        from the sort key, never from this list's order.

    Raises:
        ParallelCohortInputError: If any key appears more than once. The
            message names the duplicated key and `offending_value` is that
            key.

    Side Effects:
        None. The input iterable is read but not mutated.
    """

    materialized = list(item_keys)
    seen: set[int] = set()
    # Walk the supplied keys in order so the first repeat encountered is the
    # key reported, which keeps the message stable for a given input.
    for item_key in materialized:
        if item_key in seen:
            raise ParallelCohortInputError(
                f"Duplicate item key {item_key} in item_keys; item keys must "
                f"be unique because cohort ordering relies on key uniqueness.",
                item_key,
            )
        seen.add(item_key)

    return materialized


def _validate_edge(edge: tuple[int, int], known_keys: set[int]) -> None:
    """Reject a self-loop edge or an edge with an endpoint outside the key set.

    Args:
        edge (tuple[int, int]): One undirected conflict edge as supplied by
            the caller, in either direction.
        known_keys (set[int]): The validated item-key set. Membership only;
            this set is never iterated into ordered output.

    Returns:
        None. The function returns normally when the edge is well formed.

    Raises:
        ParallelCohortInputError: If the edge is a self-loop, or if either
            endpoint is not a member of `known_keys`.

    Side Effects:
        None.
    """

    first, second = edge
    # Check the self-loop first: the contention relation is defined over
    # distinct items, so a self-edge can only come from an upstream defect
    # and reporting it as such is more actionable than reporting a possibly
    # unknown endpoint for the same edge.
    if first == second:
        raise ParallelCohortInputError(
            f"Self-loop edge on item key {first}; the conflict relation is "
            f"defined over distinct items, so an item cannot conflict with "
            f"itself.",
            first,
        )

    # Both endpoints must be declared vertices. An undeclared endpoint means
    # the caller's key set and edge list disagree, which would silently drop
    # a real conflict if it were tolerated.
    for endpoint in (first, second):
        if endpoint not in known_keys:
            raise ParallelCohortInputError(
                f"Conflict edge {edge} names item key {endpoint}, which is "
                f"not a member of item_keys; every edge endpoint must be a "
                f"declared item key.",
                edge,
            )


def _build_adjacency(
    item_keys: list[int],
    conflict_edges: Iterable[tuple[int, int]],
) -> dict[int, set[int]]:
    """Build symmetric adjacency, normalizing edge direction and duplicates.

    Storing each vertex's neighbors as a `set[int]` normalizes the edge list
    by construction: an edge supplied as `(a, b)`, as `(b, a)`, or supplied
    repeatedly collapses to the same single neighbor entry on both sides.
    A vertex's degree is therefore `len(adjacency[key])` — its number of
    distinct neighbors after normalization.

    Args:
        item_keys (list[int]): The validated, duplicate-free item keys. Every
            key gets an adjacency entry, so an isolated vertex is present
            with an empty neighbor set rather than being absent.
        conflict_edges (Iterable[tuple[int, int]]): The undirected conflict
            edges, in any direction and with duplicates permitted. The
            iterable is consumed once.

    Returns:
        dict[int, set[int]]: A mapping of `item_key -> distinct neighbors`.
        The neighbor sets are used for membership tests and degree counts
        only; they are never iterated into ordered output.

    Raises:
        ParallelCohortInputError: If any edge is a self-loop or names an
            endpoint that is not a declared item key.

    Side Effects:
        None. Neither input argument is mutated.
    """

    known_keys = set(item_keys)
    # Seed every declared key so isolated vertices survive into the coloring
    # step; inferring vertices from the edge list alone would drop them.
    adjacency: dict[int, set[int]] = {item_key: set() for item_key in item_keys}

    # Record each conflict on both endpoints, which is what makes direction
    # and repetition irrelevant: the same undirected conflict lands in the
    # same two sets no matter how the caller wrote it.
    for edge in conflict_edges:
        _validate_edge(edge, known_keys)
        first, second = edge
        adjacency[first].add(second)
        adjacency[second].add(first)

    return adjacency


def _welsh_powell_order(adjacency: dict[int, set[int]]) -> list[int]:
    """Order vertices by descending degree, ties broken by ascending item key.

    The composite key `(-degree, item_key)` sorted ascending is a total order
    because item keys are unique. That is the single load-bearing determinism
    guard: the visit order depends on the graph alone, never on the caller's
    iteration order and never on Python's sort stability. Sorting by degree
    alone and letting a stable sort settle ties would leak input order into
    equal-degree groups.

    Args:
        adjacency (dict[int, set[int]]): The normalized adjacency mapping.
            Its keys are the graph's vertices and each value's length is that
            vertex's distinct-neighbor degree.

    Returns:
        list[int]: The item keys in Welsh-Powell visit order.

    Raises:
        None.

    Side Effects:
        None. The input mapping is not mutated.
    """

    # Sort the key view rather than iterating the mapping, so the result is
    # derived from the composite key alone and not from insertion order.
    return sorted(
        adjacency,
        key=lambda item_key: (-len(adjacency[item_key]), item_key),
    )


def _assign_cohort_indices(
    ordered_keys: list[int],
    adjacency: dict[int, set[int]],
) -> dict[int, int]:
    """Greedily assign each vertex the lowest cohort index free among neighbors.

    Args:
        ordered_keys (list[int]): The vertices in Welsh-Powell visit order.
            Visit order determines the assignment, so this ordering must
            already be the deterministic one.
        adjacency (dict[int, set[int]]): The normalized adjacency mapping,
            consulted for neighbor membership only.

    Returns:
        dict[int, int]: A mapping of `item_key -> cohort_index`. Because a
        vertex never takes an index already held by a neighbor, each index
        class is an independent set of the conflict graph.

    Raises:
        None.

    Side Effects:
        None. Neither input argument is mutated.
    """

    cohort_index_by_key: dict[int, int] = {}

    # Visit vertices in Welsh-Powell order; each vertex takes the smallest
    # index its already-assigned neighbors have not taken, which is what keeps
    # every index class an independent set.
    for item_key in ordered_keys:
        # Collecting the neighbors' indices into a set is order-insensitive,
        # so iterating the adjacency set here cannot affect the outcome.
        neighbor_indices = {
            cohort_index_by_key[neighbor]
            for neighbor in adjacency[item_key]
            if neighbor in cohort_index_by_key
        }

        # Scan upward from zero for the first free index. Isolated vertices
        # and the first-visited vertex have no assigned neighbors, so both
        # land in cohort 0.
        candidate_index = 0
        while candidate_index in neighbor_indices:
            candidate_index += 1

        cohort_index_by_key[item_key] = candidate_index

    return cohort_index_by_key


def compute_cohorts(
    item_keys: Iterable[int],
    conflict_edges: Iterable[tuple[int, int]],
) -> list[list[int]]:
    """Partition item keys into cohorts by deterministic greedy graph coloring.

    Vertices are visited in Welsh-Powell order — sorted by the composite key
    `(-degree, item_key)` ascending, that is descending distinct-neighbor
    degree with ties broken by ascending item key — and each vertex is
    assigned the lowest cohort index not already held by one of its
    neighbors. The algorithm is greedy, not optimal: the cohort count is at
    or above the graph's chromatic number, which is the accepted trade for
    determinism and explainability.

    The alternative `item_key -> cohort_index` view is derived in one line
    from the returned list:
    `{key: index for index, cohort in enumerate(cohorts) for key in cohort}`.
    This function returns the cohort-list shape only.

    Args:
        item_keys (Iterable[int]): The graph's vertices. Keys must be `int`
            and unique. A key that appears in no edge is an isolated vertex
            and lands in cohort 0. The iterable is consumed once and its
            order does not affect the result.
        conflict_edges (Iterable[tuple[int, int]]): The undirected conflict
            edges as `(a, b)` pairs. Direction is irrelevant and repeated
            edges are collapsed. Every endpoint must be a member of
            `item_keys`. The iterable is consumed once and its order does not
            affect the result.

    Returns:
        list[list[int]]: The cohorts, where list position is the cohort index
        and each inner list holds that cohort's item keys sorted ascending.
        Empty input returns `[]`. Every cohort is an independent set of the
        conflict graph, and the concatenation of all cohorts covers
        `item_keys` exactly once.

    Raises:
        ParallelCohortInputError: If `item_keys` contains a duplicate key, or
            if any edge is a self-loop or names an endpoint outside
            `item_keys`. All validation runs before any coloring work.

    Side Effects:
        None. This function is pure: no file I/O, no network, no clock or
        RNG access, and no mutation of either input argument.
    """

    validated_keys = _validate_item_keys(item_keys)
    adjacency = _build_adjacency(validated_keys, conflict_edges)
    ordered_keys = _welsh_powell_order(adjacency)
    cohort_index_by_key = _assign_cohort_indices(ordered_keys, adjacency)

    # An empty graph has no cohorts at all, so short-circuit before deriving a
    # cohort count from an empty assignment mapping.
    if not cohort_index_by_key:
        return []

    cohort_count = max(cohort_index_by_key.values()) + 1
    cohorts: list[list[int]] = [[] for _ in range(cohort_count)]

    # Fill cohort membership by walking the sorted key view of the assignment
    # mapping, never the mapping's insertion order, so each cohort's keys come
    # out ascending regardless of how the caller ordered its input.
    for item_key in sorted(cohort_index_by_key):
        cohorts[cohort_index_by_key[item_key]].append(item_key)

    return cohorts


def compute_concurrency_batches(
    cohort_item_keys: Sequence[int],
    max_concurrency: int,
) -> list[list[int]]:
    """Chunk one cohort into concurrency-capped batches in ascending key order.

    `max_concurrency` caps fan-out independently of cohort size. The cohort's
    keys are sorted ascending inside this function rather than trusting the
    caller's ordering, so determinism does not depend on caller discipline.
    The sorted keys are then chunked into consecutive batches of at most
    `max_concurrency` items: every batch is exactly `max_concurrency` long
    except a possibly smaller final batch.

    Args:
        cohort_item_keys (Sequence[int]): One cohort's item keys, in any
            order. Typically an inner list returned by `compute_cohorts`, but
            any sequence of ints is accepted.
        max_concurrency (int): The maximum number of items in one batch. Must
            be at least 1.

    Returns:
        list[list[int]]: The batches in order. Concatenating them yields the
        ascending-sorted cohort. An empty cohort yields `[]`.

    Raises:
        ParallelCohortInputError: If `max_concurrency` is less than 1. The
            message states the invalid value and the `>= 1` requirement, and
            `offending_value` is the invalid integer.

    Side Effects:
        None. This function is pure: no file I/O, no network, no clock or
        RNG access, and no mutation of `cohort_item_keys`.
    """

    # A cap below 1 would admit no items into any batch, so the cohort could
    # never drain; reject it rather than returning an unusable schedule.
    if max_concurrency < 1:
        raise ParallelCohortInputError(
            f"max_concurrency must be >= 1; received {max_concurrency}.",
            max_concurrency,
        )

    ordered_keys = sorted(cohort_item_keys)

    # Walk the sorted keys in fixed-size strides so slot filling follows
    # ascending key order and the batch boundaries are reproducible.
    return [
        ordered_keys[start : start + max_concurrency]
        for start in range(0, len(ordered_keys), max_concurrency)
    ]
