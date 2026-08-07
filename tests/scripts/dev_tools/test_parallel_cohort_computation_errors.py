"""Malformed-input and slot-filling boundary tests for cohort computation.

This file holds the pre-approved split of
`tests/scripts/dev_tools/test_parallel_cohort_computation.py`: the four
malformed-input modes plus the `max_concurrency` slot-filling boundary
matrix. The coloring tests (ordering, tie-breaks, determinism, graph shapes,
structural invariants) remain in the primary file. The split exists only to
keep both files under the 500-line limit.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools.parallel_cohort_computation import (
    ParallelCohortInputError,
    compute_cohorts,
    compute_concurrency_batches,
)

TWELVE_ITEM_COHORT = [
    501,
    502,
    503,
    504,
    505,
    506,
    507,
    508,
    509,
    510,
    511,
    512,
]
TEN_ITEM_COHORT = [501, 502, 503, 504, 505, 506, 507, 508, 509, 510]

SLOT_FILLING_CASES = [
    pytest.param(
        TWELVE_ITEM_COHORT,
        4,
        [
            [501, 502, 503, 504],
            [505, 506, 507, 508],
            [509, 510, 511, 512],
        ],
        id="exact-divide-12-at-4",
    ),
    pytest.param(
        TEN_ITEM_COHORT,
        4,
        [
            [501, 502, 503, 504],
            [505, 506, 507, 508],
            [509, 510],
        ],
        id="remainder-10-at-4",
    ),
    pytest.param(
        [503, 501, 502],
        1,
        [[501], [502], [503]],
        id="max-concurrency-one-yields-singletons",
    ),
    pytest.param(
        [503, 501, 502],
        3,
        [[501, 502, 503]],
        id="max-concurrency-equals-cohort-size",
    ),
    pytest.param(
        [503, 501, 502],
        99,
        [[501, 502, 503]],
        id="max-concurrency-exceeds-cohort-size",
    ),
    pytest.param([], 4, [], id="empty-cohort-yields-no-batches"),
]


@pytest.mark.parametrize(("cohort", "max_concurrency", "expected"), SLOT_FILLING_CASES)
def test_compute_concurrency_batches_matches_the_expected_batch_layout(
    cohort: list[int],
    max_concurrency: int,
    expected: list[list[int]],
) -> None:
    """Chunk a cohort into batches of at most `max_concurrency` items."""

    assert compute_concurrency_batches(cohort, max_concurrency) == expected


@pytest.mark.parametrize(("cohort", "max_concurrency", "expected"), SLOT_FILLING_CASES)
def test_compute_concurrency_batches_concatenate_to_the_sorted_cohort(
    cohort: list[int],
    max_concurrency: int,
    expected: list[list[int]],
) -> None:
    """Preserve the whole cohort: concatenated batches equal the sorted keys."""

    batches = compute_concurrency_batches(cohort, max_concurrency)

    concatenated = [item_key for batch in batches for item_key in batch]

    assert concatenated == sorted(cohort)
    assert batches == expected


MALFORMED_GRAPH_CASES = [
    pytest.param(
        [443, 444, 445],
        [(443, 999)],
        (443, 999),
        "999",
        id="unknown-edge-endpoint",
    ),
    pytest.param(
        [443, 444],
        [(443, 443)],
        443,
        "443",
        id="self-loop-edge",
    ),
    pytest.param(
        [443, 444, 443],
        [],
        443,
        "443",
        id="duplicate-item-key",
    ),
]


@pytest.mark.parametrize(
    ("item_keys", "conflict_edges", "expected_value", "expected_text"),
    MALFORMED_GRAPH_CASES,
)
def test_compute_cohorts_rejects_malformed_graph_input(
    item_keys: list[int],
    conflict_edges: list[tuple[int, int]],
    expected_value: int | tuple[int, int],
    expected_text: str,
) -> None:
    """Raise ParallelCohortInputError for each malformed graph-input mode.

    Each case asserts the exception type, that the message names the
    offending value, and that `offending_value` carries the per-mode value
    fixed by the module contract.
    """

    with pytest.raises(ParallelCohortInputError) as excinfo:
        compute_cohorts(item_keys, conflict_edges)

    assert excinfo.value.offending_value == expected_value
    assert expected_text in str(excinfo.value)


@pytest.mark.parametrize("max_concurrency", [0, -1, -7])
def test_compute_concurrency_batches_rejects_non_positive_max_concurrency(
    max_concurrency: int,
) -> None:
    """Raise ParallelCohortInputError when `max_concurrency` is below 1."""

    with pytest.raises(ParallelCohortInputError) as excinfo:
        compute_concurrency_batches([443, 444], max_concurrency)

    assert excinfo.value.offending_value == max_concurrency
    assert str(max_concurrency) in str(excinfo.value)
    assert ">= 1" in str(excinfo.value)


def test_parallel_cohort_input_error_message_names_the_unknown_key_and_edge() -> None:
    """Name both the unknown key and the offending edge in the message."""

    with pytest.raises(ParallelCohortInputError) as excinfo:
        compute_cohorts([443, 444], [(444, 999)])

    message = str(excinfo.value)

    assert excinfo.value.offending_value == (444, 999)
    assert "999" in message
    assert "(444, 999)" in message


def test_parallel_cohort_input_error_is_catchable_as_value_error() -> None:
    """Allow existing `except ValueError` handlers to catch the exception."""

    with pytest.raises(ValueError, match="max_concurrency must be >= 1"):
        compute_concurrency_batches([443], 0)
