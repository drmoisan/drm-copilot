"""Tests for the parallel checkpoint scheduling collections, invariants 12-15.

Covers cohort shape and key resolution (invariant 12), current-generation index
uniqueness and exactly-one coverage (invariant 13), the current-cohort bound
(invariant 14), and conflict-edge shape including ``a < b`` normalization and
duplicate-pair rejection (invariant 15).

The append-only record collections -- ``mutations[]`` (invariants 16 and 17)
and ``drift_events[]`` (invariant 18) -- are covered by
``test_validate_parallel_orchestrator_state_completion.py`` alongside the
completion gate, so each of the three Phase 1 test files stays under the
repository's 500-line limit. The builder and accessors come from
``test_validate_parallel_orchestrator_state``, so every case starts from the
same minimally valid checkpoint.
"""

from __future__ import annotations

from typing import cast

import pytest

from scripts.dev_tools._parallel_state_common import VALID_EDGE_REASONS
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_valid_parallel_state,
    item_at,
    validate,
)


def cohort_at(state: dict[str, object], index: int) -> dict[str, object]:
    """Return one ``cohorts[]`` entry of a builder-produced checkpoint."""

    return cast("list[dict[str, object]]", state["cohorts"])[index]


def state_with_edges(edges: object) -> dict[str, object]:
    """Return a valid checkpoint whose conflict-edge list is replaced.

    The builder places both items in one current-generation cohort, which is a
    coherent graph colouring only while the conflict-edge list is empty. A
    cohort is a colour class of the conflict graph, so two items sharing a
    current-generation cohort index run concurrently by construction; an edge
    injected between them is an invalid colouring and earns a cohort-barrier
    violation on top of whatever edge-shape condition the caller is exercising.
    Split the two items into distinct current-generation cohorts so an injected
    edge is properly coloured and each test observes only its own condition.

    Invariants 13 and 14 continue to hold: indices 0 and 1 are unique within
    the current generation, every non-withdrawn item appears in exactly one
    current-generation cohort, and ``current_cohort`` of 0 does not exceed the
    maximum current-generation index of 1.
    """

    state = build_valid_parallel_state()
    state["cohorts"] = [
        {"index": 0, "generation": 0, "item_keys": [444]},
        {"index": 1, "generation": 0, "item_keys": [445]},
    ]
    state["conflict_edges"] = edges
    return state


def test_invariant_12_accepts_the_builder_cohorts() -> None:
    """The builder's single current-generation cohort validates."""

    assert validate(build_valid_parallel_state()) == []


def test_invariant_12_rejects_non_list_cohorts() -> None:
    """A non-list cohorts value yields one collection-level error."""

    state = build_valid_parallel_state()
    state["cohorts"] = {}

    assert "Parallel checkpoint cohorts must be a list." in validate(state)


def test_invariant_12_rejects_non_object_cohort_entry() -> None:
    """A non-object cohort entry is named by its positional index."""

    state = build_valid_parallel_state()
    state["cohorts"] = ["cohort-0"]

    assert "Parallel checkpoint cohorts[0] must be an object." in validate(state)


@pytest.mark.parametrize("index", [-1, True, "0", None])
def test_invariant_12_rejects_non_integer_cohort_index(index: object) -> None:
    """A cohort index that is not a non-negative integer is rejected."""

    state = build_valid_parallel_state()
    cohort_at(state, 0)["index"] = index

    assert (
        f"Parallel checkpoint cohorts[0] index must be a non-negative integer; "
        f"found: {index!r}." in validate(state)
    )


@pytest.mark.parametrize("generation", [-1, True, "0", None])
def test_invariant_12_rejects_non_integer_cohort_generation(
    generation: object,
) -> None:
    """A cohort generation that is not a non-negative integer is rejected."""

    state = build_valid_parallel_state()
    cohort_at(state, 0)["generation"] = generation

    assert (
        f"Parallel checkpoint cohorts[0] generation must be a non-negative "
        f"integer; found: {generation!r}." in validate(state)
    )


def test_invariant_12_rejects_generation_above_recolor_generation() -> None:
    """A cohort cannot claim a generation the run has not reached."""

    state = build_valid_parallel_state()
    cohort_at(state, 0)["generation"] = 3

    assert (
        "Parallel checkpoint cohorts[0] generation 3 must not exceed "
        "recolor_generation 0." in validate(state)
    )


def test_invariant_12_rejects_malformed_recolor_generation() -> None:
    """The generation counter itself must be a non-negative integer."""

    state = build_valid_parallel_state()
    state["recolor_generation"] = "one"

    assert (
        "Parallel checkpoint recolor_generation must be a non-negative "
        "integer; found: 'one'." in validate(state)
    )


def test_invariant_12_rejects_non_list_item_keys() -> None:
    """A cohort's item_keys must be a list."""

    state = build_valid_parallel_state()
    cohort_at(state, 0)["item_keys"] = 444

    assert "Parallel checkpoint cohorts[0] item_keys must be a list." in validate(state)


@pytest.mark.parametrize("key", [999, "444", True, None])
def test_invariant_12_rejects_unresolved_item_key(key: object) -> None:
    """Every cohort member must name a declared items[].issue_num."""

    state = build_valid_parallel_state()
    cohort_at(state, 0)["item_keys"] = [444, 445, key]

    assert (
        f"Parallel checkpoint cohorts[0] item_keys entry {key!r} does not "
        f"resolve to an items[].issue_num." in validate(state)
    )


def test_invariant_13_rejects_duplicate_current_generation_index() -> None:
    """Two current-generation cohorts cannot share one index."""

    state = build_valid_parallel_state()
    state["cohorts"] = [
        {"index": 0, "generation": 0, "item_keys": [444]},
        {"index": 0, "generation": 0, "item_keys": [445]},
    ]

    assert (
        "Parallel checkpoint has duplicate current-generation cohorts[].index: 0."
        in validate(state)
    )


def test_invariant_13_rejects_item_missing_from_every_cohort() -> None:
    """A scheduled item absent from the current coloring is rejected."""

    state = build_valid_parallel_state()
    cohort_at(state, 0)["item_keys"] = [444]

    assert (
        "Parallel checkpoint item 445 in state 'scheduled' must appear in "
        "exactly one current-generation cohort; found 0." in validate(state)
    )


def test_invariant_13_rejects_item_in_two_cohorts() -> None:
    """An item colored into two current-generation cohorts is rejected."""

    state = build_valid_parallel_state()
    state["cohorts"] = [
        {"index": 0, "generation": 0, "item_keys": [444, 445]},
        {"index": 1, "generation": 0, "item_keys": [445]},
    ]
    state["current_cohort"] = 1

    assert (
        "Parallel checkpoint item 445 in state 'scheduled' must appear in "
        "exactly one current-generation cohort; found 2." in validate(state)
    )


@pytest.mark.parametrize("exempt_state", ["withdrawn", "merged", "blocked"])
def test_invariant_13_exempts_terminal_and_withdrawn_items(
    exempt_state: str,
) -> None:
    """Only withdrawn, merged, and blocked items may sit outside the coloring."""

    state = build_valid_parallel_state()
    cohort_at(state, 0)["item_keys"] = [444]
    item_at(state, 1)["state"] = exempt_state

    assert validate(state) == []


def test_invariant_13_ignores_cohorts_of_an_earlier_generation() -> None:
    """Superseded cohorts do not satisfy current-generation coverage."""

    state = build_valid_parallel_state()
    state["recolor_generation"] = 1
    cohort_at(state, 0)["generation"] = 0

    assert (
        "Parallel checkpoint item 444 in state 'scheduled' must appear in "
        "exactly one current-generation cohort; found 0." in validate(state)
    )


@pytest.mark.parametrize("current_cohort", [-1, True, "0", None, 1.0])
def test_invariant_14_rejects_non_integer_current_cohort(
    current_cohort: object,
) -> None:
    """A current_cohort that is not a non-negative integer is rejected."""

    state = build_valid_parallel_state()
    state["current_cohort"] = current_cohort

    assert (
        f"Parallel checkpoint current_cohort must be a non-negative integer; "
        f"found: {current_cohort!r}." in validate(state)
    )


def test_invariant_14_rejects_pointer_above_maximum_index() -> None:
    """A pointer past the highest current-generation index is rejected."""

    state = build_valid_parallel_state()
    state["current_cohort"] = 3

    assert (
        "Parallel checkpoint current_cohort 3 must not exceed the maximum "
        "current-generation cohorts[].index 0." in validate(state)
    )


def test_invariant_14_allows_any_pointer_without_a_current_coloring() -> None:
    """With no current-generation cohort there is no maximum to exceed."""

    state = build_valid_parallel_state()
    state["cohorts"] = []
    state["current_cohort"] = 7
    for index in (0, 1):
        item_at(state, index)["state"] = "withdrawn"

    assert validate(state) == []


def test_invariant_15_accepts_a_normalized_edge() -> None:
    """A distinct, normalized, in-enum edge validates."""

    assert (
        validate(state_with_edges([{"a": 444, "b": 445, "reason": "path_overlap"}]))
        == []
    )


def test_invariant_15_rejects_non_list_conflict_edges() -> None:
    """A non-list conflict_edges value yields one collection-level error."""

    assert "Parallel checkpoint conflict_edges must be a list." in validate(
        state_with_edges({})
    )


def test_invariant_15_rejects_non_object_edge() -> None:
    """A non-object edge entry is named by its positional index."""

    assert "Parallel checkpoint conflict_edges[0] must be an object." in validate(
        state_with_edges(["444-445"])
    )


def test_invariant_15_rejects_self_edge() -> None:
    """The contention relation is defined over distinct items."""

    errors = validate(
        state_with_edges([{"a": 444, "b": 444, "reason": "path_overlap"}])
    )

    assert (
        "Parallel checkpoint conflict_edges[0] endpoints must be distinct; found: 444."
        in errors
    )


@pytest.mark.parametrize("endpoint", ["a", "b"])
def test_invariant_15_rejects_unresolved_endpoint(endpoint: str) -> None:
    """Both endpoints must name a declared items[].issue_num."""

    edge: dict[str, object] = {"a": 444, "b": 445, "reason": "path_overlap"}
    edge[endpoint] = 999

    assert (
        f"Parallel checkpoint conflict_edges[0] {endpoint} 999 does not "
        f"resolve to an items[].issue_num." in validate(state_with_edges([edge]))
    )


def test_invariant_15_rejects_unnormalized_pair() -> None:
    """Edge identity is canonical only when a is numerically below b."""

    errors = validate(
        state_with_edges([{"a": 445, "b": 444, "reason": "path_overlap"}])
    )

    assert (
        "Parallel checkpoint conflict_edges[0] must be normalized with a < b; "
        "found: (445, 444)." in errors
    )


def test_invariant_15_rejects_duplicate_pair() -> None:
    """A repeated canonical pair is reported once."""

    errors = validate(
        state_with_edges(
            [
                {"a": 444, "b": 445, "reason": "path_overlap"},
                {"a": 444, "b": 445, "reason": "module_overlap"},
            ]
        )
    )

    assert (
        "Parallel checkpoint has duplicate conflict_edges[] pair: (444, 445)." in errors
    )


@pytest.mark.parametrize("reason", VALID_EDGE_REASONS)
def test_invariant_15_accepts_every_edge_reason(reason: str) -> None:
    """All four disjuncts of the contention relation are accepted."""

    assert validate(state_with_edges([{"a": 444, "b": 445, "reason": reason}])) == []


def test_invariant_15_rejects_unknown_edge_reason() -> None:
    """A reason outside the four-value enum is rejected."""

    errors = validate(state_with_edges([{"a": 444, "b": 445, "reason": "vibes"}]))

    assert (
        "Parallel checkpoint conflict_edges[0] reason must be one of "
        "path_overlap, module_overlap, shared_surface_overlap, "
        "contract_dependency; found: 'vibes'." in errors
    )
