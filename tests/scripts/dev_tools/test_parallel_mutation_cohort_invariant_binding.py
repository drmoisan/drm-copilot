"""Bind the corrected recolor output to F3's LANDED checkpoint validator.

Spec 1.2 correction C2 asserts that F3 invariants 13 (every non-withdrawn item
appears in exactly one current-generation cohort, with unique current-generation
``cohorts[].index`` values) and 14 (``current_cohort`` must not exceed the maximum
current-generation index) remain satisfiable under the pinned-barrier offset. This
module PROVES that by execution rather than by assertion: it runs the real
``validate_parallel_orchestrator_state_text`` over a checkpoint constructed from
``recolor_unstarted``'s actual return value and asserts the error list is empty.

The checkpoint is built as an in-memory JSON string. No temporary file is created,
no fixture file is read, no live ``git`` or ``gh`` is invoked, and no F3 field or
enum member is added anywhere in the constructed document.

The consumer merge obligation is load-bearing here. When the offset is NOT applied
the returned keys sit at index ``current_cohort``, and those keys are MERGED into
the single existing current-generation cohort entry at that index alongside its
pinned members. Writing them as a second entry with the same index would violate
invariant 13. This module proves that obligation both SUFFICIENT (the four positive
cases validate cleanly) and NECESSARY (the negative case, which writes two entries
at ``current_cohort``, produces a duplicate-index error).
"""

from __future__ import annotations

import json

from scripts.dev_tools.parallel_mutation_protocol import recolor_unstarted
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)

# The generation the recolor starts from; the returned generation is this plus one.
START_GENERATION = 3

# The pinned item and the two unstarted items every case uses. Positive ``int``
# keys, matching F3's ``items[].issue_num`` primary key.
PINNED_KEY = 442
UNSTARTED_KEYS = (444, 445)


def build_blast_radius() -> dict[str, object]:
    """Return a minimally valid, planner-declared blast-radius block."""

    return {
        "paths": ["scripts/dev_tools/**"],
        "modules": ["scripts"],
        "shared_surfaces": [],
        "contracts": [],
        "source": "declared",
        "computed_at": "2026-08-07T10-00",
    }


def build_item(issue_num: int, state: str) -> dict[str, object]:
    """Return one ``items[]`` entry in F3's shape.

    Args:
        issue_num (int): The item's primary key.
        state (str): An F3 item-state enum member.

    Returns:
        dict[str, object]: The item entry.
    """

    return {
        "issue_num": issue_num,
        "feature_folder": f"2026-08-07-parallel-item-{issue_num}",
        "state": state,
        "blast_radius": build_blast_radius(),
    }


def build_cohorts(
    assignments: dict[int, int], pinned_index: int, pinned_keys: list[int]
) -> list[dict[str, object]]:
    """Build ``cohorts[]`` with exactly ONE entry per distinct index.

    Each entry's ``item_keys`` is the union of the pinned members at that index and
    the recolor's returned keys at that index. In the no-offset case this yields a
    SINGLE entry at ``pinned_index`` holding both the pinned members and the
    returned keys, rather than two entries sharing that index, which is exactly the
    consumer merge obligation F3 invariant 13 requires.

    Args:
        assignments (dict[int, int]): The recolor's ``item_key -> cohort_index``.
        pinned_index (int): The index the pinned items occupy (``current_cohort``).
        pinned_keys (list[int]): The pinned item keys.

    Returns:
        list[dict[str, object]]: One cohort entry per occupied index, ascending.
    """

    # Seed the map with the pinned members so a returned key landing on their index
    # joins them instead of forming a duplicate-index entry.
    by_index: dict[int, list[int]] = {pinned_index: list(pinned_keys)}
    for key, index in assignments.items():
        by_index.setdefault(index, []).append(key)

    return [
        {"index": index, "generation": generation_of(), "item_keys": sorted(keys)}
        for index, keys in sorted(by_index.items())
    ]


def generation_of() -> int:
    """Return the current generation every cohort entry carries.

    A recolor returns ``START_GENERATION + 1``, and every cohort entry this module
    writes belongs to that current generation, so ``recolor_generation`` and every
    ``cohorts[].generation`` agree.

    Returns:
        int: ``START_GENERATION + 1``.
    """

    return START_GENERATION + 1


def build_checkpoint(
    cohorts: list[dict[str, object]],
    current_cohort: int,
    edges: list[tuple[int, int]],
    unstarted: list[int],
) -> str:
    """Serialize a complete parallel-orchestrator checkpoint as JSON text.

    Carries every key F3 invariant 1 requires. ``conflict_edges[]`` entries are
    normalized ``a < b`` with a valid ``reason``.

    Args:
        cohorts (list[dict[str, object]]): The cohort table.
        current_cohort (int): The index the pinned items occupy.
        edges (list[tuple[int, int]]): The conflict edges to record.
        unstarted (list[int]): The unstarted item keys to record in ``items[]``.

    Returns:
        str: The checkpoint document as JSON text.
    """

    items = [build_item(PINNED_KEY, "in_flight")]
    # Every unstarted key is recorded as `scheduled`, an unstarted state, so
    # invariant 13's "exactly one current-generation cohort" clause applies to it.
    items.extend(build_item(key, "scheduled") for key in unstarted)

    checkpoint = {
        "objective": "prove F3 invariants 13 and 14 hold under the offset",
        "completed_steps": ["manifest_parsed"],
        "next_step": "cohort_launch",
        "last_updated": "2026-08-07T10-00",
        "route_id": "parallel",
        "parallel_slug": "wave-four",
        "parallel_manifest_path": "docs/features/parallel/wave-four/parallel.md",
        "parallel_status_doc_path": (
            "docs/features/parallel/wave-four/parallel-status.md"
        ),
        "mode": "closed",
        "max_concurrency": 4,
        "current_cohort": current_cohort,
        "recolor_generation": generation_of(),
        "cohorts": cohorts,
        "items": items,
        "conflict_edges": [
            {"a": min(first, second), "b": max(first, second), "reason": "path_overlap"}
            for first, second in edges
        ],
        "mutations": [],
        "drift_events": [],
    }
    return json.dumps(checkpoint)


def validate_recolor(
    current_cohort: int, edges: list[tuple[int, int]], unstarted: list[int]
) -> list[str]:
    """Recolor, build the merged checkpoint, and return the validator's errors.

    Args:
        current_cohort (int): The index the pinned items occupy.
        edges (list[tuple[int, int]]): The full conflict edge list.
        unstarted (list[int]): The unstarted item keys.

    Returns:
        list[str]: The validator's error list for the constructed checkpoint.
    """

    result = recolor_unstarted(
        unstarted,
        edges,
        frozenset({PINNED_KEY}),
        START_GENERATION,
        current_cohort=current_cohort,
        highest_pinned_cohort=current_cohort,
    )
    cohorts = build_cohorts(
        dict(result.cohort_assignments), current_cohort, [PINNED_KEY]
    )
    text = build_checkpoint(cohorts, current_cohort, edges, unstarted)
    return validate_parallel_orchestrator_state_text(text)


def assert_no_cohort_or_bound_error(errors: list[str]) -> None:
    """Assert the error list mentions no invariant 13 or invariant 14 failure.

    Args:
        errors (list[str]): The validator's error list.
    """

    joined = " ".join(errors).lower()
    assert "index" not in joined, f"a cohort-index error was reported: {errors}"
    assert "current_cohort" not in joined, f"a current-cohort error: {errors}"
    assert "exactly one" not in joined, f"a coverage error was reported: {errors}"


class TestOffsetAppliedSatisfiesF3Invariants:
    """Bind invariants 12, 13, and 14 when the pinned-barrier offset IS applied.

    An unstarted-to-pinned conflict edge is present, so every unstarted index is
    strictly above ``current_cohort`` and the pinned entry at ``current_cohort``
    holds only its pinned member.
    """

    def test_offset_at_zero_validates_cleanly(self) -> None:
        """Binds invariants 13 and 14 at ``current_cohort = 0`` with the offset."""

        errors = validate_recolor(
            0, [(PINNED_KEY, UNSTARTED_KEYS[1])], list(UNSTARTED_KEYS)
        )

        assert errors == [], f"validator reported errors: {errors}"
        assert_no_cohort_or_bound_error(errors)

    def test_offset_at_a_non_zero_base_validates_cleanly(self) -> None:
        """Binds invariants 13 and 14 at a non-zero base with the offset applied."""

        errors = validate_recolor(
            3, [(PINNED_KEY, UNSTARTED_KEYS[1])], list(UNSTARTED_KEYS)
        )

        assert errors == [], f"validator reported errors: {errors}"
        assert_no_cohort_or_bound_error(errors)


class TestOffsetNotAppliedSatisfiesF3Invariants:
    """Bind invariants 13 and 14 when the offset is NOT applied.

    With no unstarted-to-pinned edge the lowest returned index equals
    ``current_cohort``, so the returned keys MERGE into the single existing cohort
    entry at that index alongside the pinned member. This is the case the merge
    obligation exists for.
    """

    def test_merged_entry_at_current_cohort_validates_cleanly(self) -> None:
        """Binds invariant 13's unique-index clause via the merge obligation."""

        errors = validate_recolor(3, [UNSTARTED_KEYS], list(UNSTARTED_KEYS))

        assert errors == [], f"validator reported errors: {errors}"
        assert_no_cohort_or_bound_error(errors)

    def test_empty_unstarted_set_validates_cleanly(self) -> None:
        """Binds invariant 14 when the recolor returns an empty assignment.

        The pinned items' cohort at ``current_cohort`` is then itself the maximum
        current-generation index, giving equality rather than an excess.
        """

        errors = validate_recolor(2, [], [])

        assert errors == [], f"validator reported errors: {errors}"
        assert_no_cohort_or_bound_error(errors)


class TestMergeObligationIsNecessary:
    """Prove the merge obligation is NECESSARY, not merely sufficient.

    Without this case a consumer could satisfy the positive tests while writing
    duplicate-index entries. Writing the returned keys as a SECOND
    current-generation entry at ``current_cohort``, instead of merging them into the
    one existing entry, must be rejected by F3 invariant 13.
    """

    def test_two_current_generation_entries_at_current_cohort_are_rejected(
        self,
    ) -> None:
        """A duplicate current-generation ``cohorts[].index`` must be an error."""

        # Arrange: the offset-not-applied case, so the returned keys land on
        # ``current_cohort`` and a naive consumer would append a second entry.
        current_cohort = 3
        unstarted: list[int] = list(UNSTARTED_KEYS)
        result = recolor_unstarted(
            unstarted,
            [UNSTARTED_KEYS],
            frozenset({PINNED_KEY}),
            START_GENERATION,
            current_cohort=current_cohort,
            highest_pinned_cohort=current_cohort,
        )
        assignments = dict(result.cohort_assignments)
        assert (
            min(assignments.values()) == current_cohort
        ), "fixture precondition failed: the offset should not be applied here"

        # Act: deliberately write the pinned entry and the returned keys as TWO
        # separate entries sharing index ``current_cohort``.
        duplicated: list[dict[str, object]] = [
            {
                "index": current_cohort,
                "generation": generation_of(),
                "item_keys": [PINNED_KEY],
            }
        ]
        by_index: dict[int, list[int]] = {}
        for key, index in assignments.items():
            by_index.setdefault(index, []).append(key)
        duplicated.extend(
            {"index": index, "generation": generation_of(), "item_keys": sorted(keys)}
            for index, keys in sorted(by_index.items())
        )

        text = build_checkpoint(duplicated, current_cohort, [UNSTARTED_KEYS], unstarted)
        errors = validate_parallel_orchestrator_state_text(text)

        # Assert: the validator must reject the duplicate index.
        assert errors, "duplicate current-generation index was not rejected"
        joined = " ".join(errors).lower()
        assert "index" in joined, f"no index-related error reported: {errors}"
