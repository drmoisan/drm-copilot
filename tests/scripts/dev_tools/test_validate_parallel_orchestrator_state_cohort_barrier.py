"""Tests for the Layer 2 cohort-barrier ordering invariant of the checkpoint.

Every case drives the invariant through the public entry point
``validate_parallel_orchestrator_state_text`` with an inline JSON document, and
no case imports the helper module. That is deliberate: exercising the entry
point is what proves the helper (the producer) and the validator (the consumer)
are bound at run time, which a helper-only test cannot show. The expected
message is written as a literal here rather than imported, so the byte-exact
form is asserted against the specification text and not against the
implementation's own constant.

Fixtures are built in memory and serialized with ``json.dumps``; no temporary
file, filesystem read, or network call is involved. Checkpoints are otherwise
schema-valid wherever possible so an assertion can compare the whole error list;
the cases that deliberately malform a collection filter the barrier messages out
of the shape errors F3's own invariants report for that malformation.
"""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)

# Literal invariant token, restated from design section 9 rather than imported.
VIOLATION_LABEL = "PARALLEL_COHORT_BARRIER_VIOLATION"


def expected_violation(earlier: int, later: int) -> str:
    """Render the mandated message for one violated edge, earlier endpoint first."""

    return f"{VIOLATION_LABEL}: {earlier} ran concurrently with conflicting {later}"


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


def build_item(
    issue_num: int,
    *,
    state: str = "scheduled",
    merge_status: str | None = None,
    started_at: str | None = None,
    merged_at: str | None = None,
) -> dict[str, object]:
    """Return one schema-valid ``items[]`` entry carrying only F3-defined fields.

    Each optional argument is omitted from the record when None, because absence
    is precisely the case the temporal degradation rule turns on: an absent
    ``merge_status`` reads as ``not_started`` and an absent timestamp must not be
    synthesized. ``started_at`` populates ``worktree_created_at``.
    """

    record: dict[str, object] = {
        "issue_num": issue_num,
        "feature_folder": f"2026-08-07-parallel-item-{issue_num}",
        "state": state,
        "blast_radius": build_blast_radius(),
    }
    if merge_status is not None:
        record["merge_status"] = merge_status
    if started_at is not None:
        record["worktree_created_at"] = started_at
    if merged_at is not None:
        record["merged_at"] = merged_at
    return record


def build_state(
    items: list[dict[str, object]],
    cohorts: object,
    edges: object,
    *,
    recolor_generation: object = 0,
    current_cohort: int = 0,
) -> dict[str, object]:
    """Return a checkpoint satisfying F3's required-key set around the given data.

    ``cohorts``, ``edges``, and ``recolor_generation`` are deliberately typed as
    ``object`` so a malformed value can be injected without a cast at each site.
    """

    return {
        "objective": "deliver parallel-enforcement-hooks-440",
        "completed_steps": ["manifest_parsed"],
        "next_step": "cohort_0_launch",
        "last_updated": "2026-08-08T10-00",
        "route_id": "parallel",
        "parallel_slug": "wave-four",
        "parallel_manifest_path": "docs/features/parallel/wave-four/parallel.md",
        "parallel_status_doc_path": (
            "docs/features/parallel/wave-four/parallel-status.md"
        ),
        "mode": "closed",
        "max_concurrency": 4,
        "current_cohort": current_cohort,
        "recolor_generation": recolor_generation,
        "cohorts": cohorts,
        "items": items,
        "conflict_edges": edges,
        "mutations": [],
        "drift_events": [],
    }


def validate(state: dict[str, object]) -> list[str]:
    """Serialize a checkpoint and return the entry point's full error list."""

    return validate_parallel_orchestrator_state_text(json.dumps(state))


def barrier_errors(state: dict[str, object]) -> list[str]:
    """Return only the barrier messages, isolating them from F3 shape errors."""

    return [error for error in validate(state) if error.startswith(VIOLATION_LABEL)]


def build_clean_two_cohort_state() -> dict[str, object]:
    """Return a barrier-satisfying two-cohort checkpoint carrying one edge."""

    return build_state(
        [
            build_item(444, state="merged", merge_status="merged"),
            build_item(445, state="in_flight", merge_status="worktree_created"),
        ],
        [
            {"index": 0, "generation": 0, "item_keys": [444]},
            {"index": 1, "generation": 0, "item_keys": [445]},
        ],
        [{"a": 444, "b": 445, "reason": "path_overlap"}],
        current_cohort=1,
    )


def build_same_cohort_state() -> dict[str, object]:
    """Return a checkpoint whose conflicting pair shares one cohort index."""

    return build_state(
        [build_item(444), build_item(445)],
        [{"index": 0, "generation": 0, "item_keys": [444, 445]}],
        [{"a": 444, "b": 445, "reason": "path_overlap"}],
    )


def build_timestamp_overlap_state(
    *, merged_at: str | None, started_at: str | None
) -> dict[str, object]:
    """Return a status-clean cross-cohort pair carrying the given timestamps.

    The earlier item is terminally merged and the later item has started, so the
    status disjunct never fires and any reported violation must come from the
    timestamp comparison alone.
    """

    return build_state(
        [
            build_item(444, state="merged", merge_status="merged", merged_at=merged_at),
            build_item(
                445,
                state="in_flight",
                merge_status="worktree_created",
                started_at=started_at,
            ),
        ],
        [
            {"index": 0, "generation": 0, "item_keys": [444]},
            {"index": 1, "generation": 0, "item_keys": [445]},
        ],
        [{"a": 444, "b": 445, "reason": "shared_surface_overlap"}],
        current_cohort=1,
    )


def test_clean_multi_cohort_checkpoint_yields_no_barrier_errors() -> None:
    """A conflicting pair split across cohorts, merged in order, validates."""

    assert validate(build_clean_two_cohort_state()) == []


@pytest.mark.parametrize(
    "dropped", [("conflict_edges",), ("cohorts",), ("conflict_edges", "cohorts")]
)
def test_checkpoint_without_a_gating_key_emits_no_violation(
    dropped: tuple[str, ...],
) -> None:
    """The invariant is key-gated, so an older checkpoint shape is unaffected."""

    state = build_same_cohort_state()
    for key in dropped:
        del state[key]

    errors = validate(state)

    assert [error for error in errors if error.startswith(VIOLATION_LABEL)] == []
    assert f"Parallel checkpoint missing required key: {dropped[0]}." in errors


def test_same_cohort_conflicting_pair_reports_one_structural_violation() -> None:
    """Conflicting items colored into one cohort run concurrently by design."""

    assert validate(build_same_cohort_state()) == [expected_violation(444, 445)]


def test_violation_message_matches_the_exact_literal_form() -> None:
    """The message is byte-exact, with no context prefix and no trailing period."""

    assert validate(build_same_cohort_state()) == [
        "PARALLEL_COHORT_BARRIER_VIOLATION: 444 ran concurrently with conflicting 445"
    ]


def test_cross_cohort_start_before_terminal_merge_reports_a_violation() -> None:
    """A later-cohort item that started while the earlier is non-terminal fails."""

    state = build_state(
        [
            build_item(444, state="in_flight", merge_status="pr_open"),
            build_item(445, state="in_flight", merge_status="worktree_created"),
        ],
        [
            {"index": 0, "generation": 0, "item_keys": [444]},
            {"index": 1, "generation": 0, "item_keys": [445]},
        ],
        [{"a": 444, "b": 445, "reason": "module_overlap"}],
        current_cohort=1,
    )

    assert validate(state) == [expected_violation(444, 445)]


def test_ci_green_earlier_item_does_not_satisfy_the_barrier() -> None:
    """Only a durable merge releases the barrier; ``ci_green`` does not."""

    state = build_state(
        [
            build_item(444, state="in_flight", merge_status="ci_green"),
            build_item(445, state="in_flight", merge_status="worktree_created"),
        ],
        [
            {"index": 0, "generation": 0, "item_keys": [444]},
            {"index": 1, "generation": 0, "item_keys": [445]},
        ],
        [{"a": 444, "b": 445, "reason": "path_overlap"}],
        current_cohort=1,
    )

    assert validate(state) == [expected_violation(444, 445)]


def test_start_timestamp_alone_evidences_a_start() -> None:
    """A recorded worktree creation evidences a start even at ``not_started``."""

    state = build_state(
        [
            build_item(444, state="in_flight", merge_status="pr_open"),
            build_item(445, merge_status="not_started", started_at="2026-08-08T10-00"),
        ],
        [
            {"index": 0, "generation": 0, "item_keys": [444]},
            {"index": 1, "generation": 0, "item_keys": [445]},
        ],
        [{"a": 444, "b": 445, "reason": "path_overlap"}],
        current_cohort=1,
    )

    assert validate(state) == [expected_violation(444, 445)]


def test_merge_confirmed_after_later_start_reports_a_temporal_violation() -> None:
    """Merge confirmation after the later item's start proves an overlap."""

    state = build_timestamp_overlap_state(
        merged_at="2026-08-08T12-00", started_at="2026-08-08T10-00"
    )

    assert validate(state) == [expected_violation(444, 445)]


def test_merge_confirmed_before_later_start_is_clean() -> None:
    """Merge confirmation before the later item's start satisfies the barrier."""

    state = build_timestamp_overlap_state(
        merged_at="2026-08-08T10-00", started_at="2026-08-08T12-00"
    )

    assert validate(state) == []


@pytest.mark.parametrize(
    ("merged_at", "started_at"),
    [(None, None), ("2026-08-08T12-00", None), (None, "2026-08-08T10-00")],
)
def test_absent_timestamps_degrade_to_structural_plus_status(
    merged_at: str | None, started_at: str | None
) -> None:
    """An absent timestamp degrades the check instead of inferring a value.

    Each case would be a timestamp violation if the missing value were
    synthesized, and each is status-clean, so a clean result proves degradation.
    """

    state = build_timestamp_overlap_state(merged_at=merged_at, started_at=started_at)

    assert validate(state) == []


def test_non_string_timestamps_degrade_to_structural_plus_status() -> None:
    """A non-string timestamp is unusable and must not be coerced."""

    state = build_timestamp_overlap_state(
        merged_at="2026-08-08T12-00", started_at="2026-08-08T10-00"
    )
    items = cast("list[dict[str, object]]", state["items"])
    items[0]["merged_at"] = 20260808
    items[1]["worktree_created_at"] = None

    assert validate(state) == []


def test_multiple_violated_edges_each_report_exactly_one_message() -> None:
    """Three conflicting items in one cohort report one message per edge."""

    state = build_state(
        [build_item(444), build_item(445), build_item(446)],
        [{"index": 0, "generation": 0, "item_keys": [444, 445, 446]}],
        [
            {"a": 444, "b": 445, "reason": "path_overlap"},
            {"a": 444, "b": 446, "reason": "module_overlap"},
            {"a": 445, "b": 446, "reason": "contract_dependency"},
        ],
    )

    assert validate(state) == [
        expected_violation(444, 445),
        expected_violation(444, 446),
        expected_violation(445, 446),
    ]


def test_earlier_cohort_endpoint_is_named_first() -> None:
    """The message names the earlier endpoint even when it is the edge's ``b``."""

    state = build_state(
        [
            build_item(444, state="in_flight", merge_status="worktree_created"),
            build_item(445, state="in_flight", merge_status="pr_open"),
        ],
        [
            {"index": 0, "generation": 0, "item_keys": [445]},
            {"index": 1, "generation": 0, "item_keys": [444]},
        ],
        [{"a": 444, "b": 445, "reason": "path_overlap"}],
        current_cohort=1,
    )

    assert validate(state) == [expected_violation(445, 444)]


def test_superseded_generation_cohorts_are_ignored() -> None:
    """Only rows at ``recolor_generation`` inform the ordering projection."""

    state = build_state(
        [
            build_item(444, state="merged", merge_status="merged"),
            build_item(445, state="in_flight", merge_status="worktree_created"),
        ],
        [
            {"index": 0, "generation": 0, "item_keys": [444, 445]},
            {"index": 0, "generation": 1, "item_keys": [444]},
            {"index": 1, "generation": 1, "item_keys": [445]},
        ],
        [{"a": 444, "b": 445, "reason": "path_overlap"}],
        recolor_generation=1,
        current_cohort=1,
    )

    assert validate(state) == []


def test_feature_folder_hint_cohort_membership_resolves() -> None:
    """A folder-hint cohort member still resolves for the barrier projection."""

    state = build_state(
        [build_item(444), build_item(445)],
        [
            {
                "index": 0,
                "generation": 0,
                "item_keys": [
                    "docs/features/active/2026-08-07-parallel-item-444",
                    "2026-08-07-parallel-item-445",
                ],
            }
        ],
        [{"a": 444, "b": 445, "reason": "path_overlap"}],
    )

    assert barrier_errors(state) == [expected_violation(444, 445)]


def test_unresolved_edge_endpoint_reports_no_barrier_violation() -> None:
    """An endpoint naming no declared item cannot be ordered against another."""

    state = build_same_cohort_state()
    cast("list[dict[str, object]]", state["conflict_edges"])[0]["b"] = 999

    assert barrier_errors(state) == []


def test_self_edge_reports_no_barrier_violation() -> None:
    """A self-edge is invariant 15's defect, not a concurrency violation."""

    state = build_same_cohort_state()
    cast("list[dict[str, object]]", state["conflict_edges"])[0]["b"] = 444

    assert barrier_errors(state) == []


@pytest.mark.parametrize("edges", [{}, ["444-445"], [None]])
def test_malformed_conflict_edges_report_no_barrier_violation(edges: object) -> None:
    """A non-list value or a non-object entry is skipped, not judged."""

    state = build_same_cohort_state()
    state["conflict_edges"] = edges

    assert barrier_errors(state) == []


@pytest.mark.parametrize("cohorts", [{}, ["cohort-zero"], [{"index": 0}]])
def test_malformed_cohorts_report_no_barrier_violation(cohorts: object) -> None:
    """Without a readable coloring no endpoint pair can be ordered."""

    state = build_same_cohort_state()
    state["cohorts"] = cohorts

    assert barrier_errors(state) == []


def test_malformed_recolor_generation_reports_no_barrier_violation() -> None:
    """A non-integer generation counter attributes no row to the coloring."""

    state = build_same_cohort_state()
    state["recolor_generation"] = "zero"

    assert barrier_errors(state) == []


def test_malformed_items_report_no_barrier_violation() -> None:
    """With no readable item records no endpoint resolves and nothing is judged."""

    state = build_same_cohort_state()
    state["items"] = {}

    assert barrier_errors(state) == []


def test_item_outside_the_current_coloring_is_left_unjudged() -> None:
    """An endpoint in no current-generation cohort yields no barrier claim."""

    state = build_state(
        [
            build_item(444, state="withdrawn"),
            build_item(445, state="in_flight", merge_status="worktree_created"),
        ],
        [{"index": 0, "generation": 0, "item_keys": [445]}],
        [{"a": 444, "b": 445, "reason": "path_overlap"}],
    )

    assert validate(state) == []


def test_validation_does_not_mutate_the_checkpoint() -> None:
    """The invariant reads the parsed document and never writes to it."""

    state = build_same_cohort_state()
    snapshot = copy.deepcopy(state)

    validate(state)

    assert state == snapshot
