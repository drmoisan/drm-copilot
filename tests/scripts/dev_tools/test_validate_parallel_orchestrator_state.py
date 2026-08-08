"""Tests for the parallel-orchestrator checkpoint validator, invariants 1-11.

Covers spec invariants 1 through 11 and invariant 19 (the optional receipt
arrays), plus the invalid-JSON, non-object-root, and absent-optional-key
backward-compatibility cases. Invariants 12 through 17 are covered by
``test_validate_parallel_orchestrator_state_structures.py`` and invariants 18,
20, and 21 by ``test_validate_parallel_orchestrator_state_completion.py``. The
three files are partitioned to stay under the 500-line limit and share the
builder and accessors defined here.
"""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools._parallel_state_common import (
    VALID_ITEM_STATES,
    VALID_MERGE_STATUS,
    VALID_SOURCES,
)
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    REQUIRED_KEYS,
    validate_parallel_orchestrator_state_text,
)


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


def build_valid_parallel_state() -> dict[str, object]:
    """Return a minimally valid parallel-orchestrator checkpoint payload.

    Two scheduled items sit in one current-generation cohort with empty edge,
    mutation, and drift logs, so a test can mutate one field and attribute any
    resulting error to that mutation.
    """

    return {
        "objective": "deliver parallel-schema-validators-444",
        "completed_steps": ["manifest_parsed"],
        "next_step": "cohort_0_launch",
        "last_updated": "2026-08-07T10-00",
        "route_id": "parallel",
        "parallel_slug": "wave-one",
        "parallel_manifest_path": "docs/features/parallel/wave-one/parallel.md",
        "parallel_status_doc_path": (
            "docs/features/parallel/wave-one/parallel-status.md"
        ),
        "mode": "closed",
        "max_concurrency": 4,
        "current_cohort": 0,
        "recolor_generation": 0,
        "cohorts": [{"index": 0, "generation": 0, "item_keys": [444, 445]}],
        "items": [
            {
                "issue_num": 444,
                "feature_folder": "2026-08-07-parallel-schema-validators-444",
                "state": "scheduled",
                "blast_radius": build_blast_radius(),
            },
            {
                "issue_num": 445,
                "feature_folder": "2026-08-07-parallel-cohort-scheduler-445",
                "state": "scheduled",
                "blast_radius": build_blast_radius(),
            },
        ],
        "conflict_edges": [],
        "mutations": [],
        "drift_events": [],
    }


def item_at(state: dict[str, object], index: int) -> dict[str, object]:
    """Return one ``items[]`` entry of a builder-produced checkpoint."""

    return cast("list[dict[str, object]]", state["items"])[index]


def radius_of(state: dict[str, object], index: int) -> dict[str, object]:
    """Return one item's ``blast_radius`` block of a builder checkpoint."""

    return cast("dict[str, object]", item_at(state, index)["blast_radius"])


def validate(state: dict[str, object], *, require_complete: bool = False) -> list[str]:
    """Serialize a checkpoint dict and return the validator's error list."""

    return validate_parallel_orchestrator_state_text(
        json.dumps(state), require_complete=require_complete
    )


def test_valid_checkpoint_yields_no_errors() -> None:
    """A checkpoint satisfying every invariant validates cleanly."""

    assert validate(build_valid_parallel_state()) == []


def test_validator_does_not_mutate_its_input() -> None:
    """Validation leaves the caller's parsed payload untouched."""

    state = build_valid_parallel_state()
    snapshot = copy.deepcopy(state)
    validate_parallel_orchestrator_state_text(json.dumps(state))

    assert state == snapshot


def test_invalid_json_returns_single_error() -> None:
    """Unparseable text yields exactly one prefixed error."""

    errors = validate_parallel_orchestrator_state_text("{not json")

    assert len(errors) == 1
    assert errors[0].startswith("Parallel checkpoint is not valid JSON: ")


def test_non_object_root_is_rejected() -> None:
    """A JSON array root yields exactly one root-shape error."""

    assert validate_parallel_orchestrator_state_text("[]") == [
        "Parallel checkpoint root must be a JSON object."
    ]


@pytest.mark.parametrize("key", REQUIRED_KEYS)
def test_invariant_1_reports_each_missing_required_key(key: str) -> None:
    """Removing any required key yields that key's own missing-key error."""

    state = build_valid_parallel_state()
    del state[key]

    assert f"Parallel checkpoint missing required key: {key}." in validate(state)


def test_invariant_1_empty_object_reports_every_required_key() -> None:
    """An empty object reports exactly one error per required key."""

    assert len(validate_parallel_orchestrator_state_text("{}")) == len(REQUIRED_KEYS)


def test_invariant_2_rejects_foreign_route_id() -> None:
    """A checkpoint claiming another route is rejected."""

    state = build_valid_parallel_state()
    state["route_id"] = "epic"

    assert (
        "Parallel checkpoint route_id must be 'parallel'; found: 'epic'."
        in validate(state)
    )


@pytest.mark.parametrize("mode", ["closed", "open"])
def test_invariant_3_accepts_each_mode(mode: str) -> None:
    """Both declared run modes validate."""

    state = build_valid_parallel_state()
    state["mode"] = mode

    assert validate(state) == []


def test_invariant_3_rejects_unknown_mode() -> None:
    """A mode outside the two-value enum is rejected."""

    state = build_valid_parallel_state()
    state["mode"] = "half-open"

    assert (
        "Parallel checkpoint mode must be one of closed, open; found: 'half-open'."
        in validate(state)
    )


@pytest.mark.parametrize("concurrency", [1, 4, 8])
def test_invariant_4_accepts_in_range_concurrency(concurrency: int) -> None:
    """Concurrency at both bounds and in the middle validates."""

    state = build_valid_parallel_state()
    state["max_concurrency"] = concurrency

    assert validate(state) == []


@pytest.mark.parametrize("concurrency", [0, 9, -1, True, "4", 4.0, None])
def test_invariant_4_rejects_out_of_range_concurrency(concurrency: object) -> None:
    """Out-of-range, boolean, and non-integer concurrency values are rejected."""

    state = build_valid_parallel_state()
    state["max_concurrency"] = concurrency

    assert any(
        error.startswith(
            "Parallel checkpoint max_concurrency must be an integer from 1 through 8;"
        )
        for error in validate(state)
    )


@pytest.mark.parametrize(
    ("items", "expected"),
    [
        ({}, "Parallel checkpoint items must be a list."),
        (["not-an-object"], "Parallel checkpoint items[0] must be an object."),
    ],
)
def test_invariant_5_rejects_malformed_items_container(
    items: object, expected: str
) -> None:
    """A non-list items value and a non-object entry are each rejected."""

    state = build_valid_parallel_state()
    state["items"] = items

    assert expected in validate(state)


@pytest.mark.parametrize("issue_num", [0, -3, True, "444", None])
def test_invariant_5_rejects_non_positive_issue_num(issue_num: object) -> None:
    """A primary key that is not a positive integer is rejected."""

    state = build_valid_parallel_state()
    item_at(state, 0)["issue_num"] = issue_num

    assert (
        f"Parallel checkpoint items[0] issue_num must be a positive integer; "
        f"found: {issue_num!r}." in validate(state)
    )


def test_invariant_5_rejects_duplicate_issue_num() -> None:
    """A repeated primary key is reported once, naming the duplicated value."""

    state = build_valid_parallel_state()
    item_at(state, 1)["issue_num"] = 444
    state["cohorts"] = [{"index": 0, "generation": 0, "item_keys": [444]}]

    assert "Parallel checkpoint has duplicate items[].issue_num: 444." in validate(
        state
    )


def test_invariant_5_rejects_empty_feature_folder() -> None:
    """A blank feature_folder carries no resolvable hint and is rejected."""

    state = build_valid_parallel_state()
    item_at(state, 0)["feature_folder"] = "   "

    assert (
        "Parallel checkpoint items[0] feature_folder must be a non-empty string."
        in validate(state)
    )


@pytest.mark.parametrize("state_value", VALID_ITEM_STATES)
def test_invariant_6_accepts_every_item_state(state_value: str) -> None:
    """Each of the eight declared item states is accepted for its own field."""

    state = build_valid_parallel_state()
    item_at(state, 0)["state"] = state_value

    assert not [error for error in validate(state) if "items[0] state" in error]


def test_invariant_6_rejects_unknown_item_state() -> None:
    """An item state outside the eight-value enum is rejected."""

    state = build_valid_parallel_state()
    item_at(state, 0)["state"] = "parked"

    assert any(
        error.startswith("Parallel checkpoint items[0] state must be one of ")
        and error.endswith("found: 'parked'.")
        for error in validate(state)
    )


def test_invariant_7_absent_merge_status_yields_no_error() -> None:
    """An item with no merge_status is the backward-compatible shape."""

    state = build_valid_parallel_state()

    assert "merge_status" not in item_at(state, 0)
    assert validate(state) == []


@pytest.mark.parametrize("merge_status", ["not_started", "worktree_created", "pr_open"])
def test_invariant_7_accepts_non_terminal_merge_status(merge_status: str) -> None:
    """Non-terminal merge statuses place no constraint on item state."""

    state = build_valid_parallel_state()
    item_at(state, 0)["merge_status"] = merge_status

    assert validate(state) == []


def test_invariant_7_rejects_unknown_merge_status() -> None:
    """A merge_status outside the eight-value enum is rejected."""

    state = build_valid_parallel_state()
    item_at(state, 0)["merge_status"] = "merge_conflict"

    assert any(
        error.startswith("Parallel checkpoint items[0] merge_status must be one of ")
        and error.endswith("found: 'merge_conflict'.")
        for error in validate(state)
    )


def test_invariants_6_and_7_enums_match_the_spec_member_sets() -> None:
    """Both item vocabularies match spec S4, with the S8 replacements applied."""

    assert len(VALID_ITEM_STATES) == 8
    assert len(VALID_MERGE_STATUS) == 8
    assert "merge_conflict" not in VALID_MERGE_STATUS
    assert "blocked_conflict_loop_limit" not in VALID_MERGE_STATUS
    assert "blocked_drift" in VALID_MERGE_STATUS
    assert "blocked_ci_loop_limit" in VALID_MERGE_STATUS


@pytest.mark.parametrize("merge_status", ["merged", "worktree_removed"])
def test_invariant_8_terminal_merge_status_requires_merged_state(
    merge_status: str,
) -> None:
    """A terminal merge status disagreeing with item state is rejected."""

    state = build_valid_parallel_state()
    item_at(state, 0)["merge_status"] = merge_status

    assert (
        f"Parallel checkpoint items[0] merge_status {merge_status!r} requires "
        f"state 'merged'; found: 'scheduled'." in validate(state)
    )


@pytest.mark.parametrize("merge_status", ["blocked_drift", "blocked_ci_loop_limit"])
def test_invariant_8_blocked_merge_status_requires_blocked_state(
    merge_status: str,
) -> None:
    """A blocked merge status disagreeing with item state is rejected."""

    state = build_valid_parallel_state()
    item_at(state, 0)["merge_status"] = merge_status

    assert (
        f"Parallel checkpoint items[0] merge_status {merge_status!r} requires "
        f"state 'blocked'; found: 'scheduled'." in validate(state)
    )


def test_invariant_8_accepts_consistent_terminal_pairing() -> None:
    """A merged item whose state agrees with its merge status validates."""

    state = build_valid_parallel_state()
    item_at(state, 0)["state"] = "merged"
    item_at(state, 0)["merge_status"] = "merged"

    assert validate(state) == []


def test_invariant_9_rejects_non_object_blast_radius() -> None:
    """A non-object blast radius yields exactly one shape error."""

    state = build_valid_parallel_state()
    item_at(state, 0)["blast_radius"] = "scripts/**"

    assert "Parallel checkpoint items[0] blast_radius must be an object." in validate(
        state
    )


@pytest.mark.parametrize("field", ["paths", "modules", "shared_surfaces", "contracts"])
def test_invariant_9_rejects_malformed_radius_collection(field: str) -> None:
    """Each blast-radius collection must be a list of non-empty strings."""

    state = build_valid_parallel_state()
    radius_of(state, 0)[field] = [""]

    assert (
        f"Parallel checkpoint items[0] blast_radius.{field} must be a list of "
        f"non-empty strings." in validate(state)
    )


@pytest.mark.parametrize("source", VALID_SOURCES)
def test_invariant_9_accepts_every_radius_source(source: str) -> None:
    """All three confidence sources are accepted on the checkpoint surface."""

    state = build_valid_parallel_state()
    radius_of(state, 0)["source"] = source

    assert validate(state) == []


def test_invariant_9_rejects_unknown_radius_source() -> None:
    """A confidence source outside the three-value enum is rejected."""

    state = build_valid_parallel_state()
    radius_of(state, 0)["source"] = "guessed"

    assert (
        "Parallel checkpoint items[0] blast_radius.source must be one of "
        "derived, declared, observed; found: 'guessed'." in validate(state)
    )


def test_invariant_9_rejects_blank_computed_at() -> None:
    """A blank radius timestamp is rejected."""

    state = build_valid_parallel_state()
    radius_of(state, 0)["computed_at"] = ""

    assert (
        "Parallel checkpoint items[0] blast_radius.computed_at must be a "
        "non-empty string." in validate(state)
    )


@pytest.mark.parametrize("key", ["depends_on", "integration_branch", "epic_merge_pr"])
def test_invariants_10_and_11_reject_prohibited_top_level_keys(key: str) -> None:
    """Ordering edges and integration-branch fields are rejected at the root."""

    state = build_valid_parallel_state()
    state[key] = "value"

    assert f"Parallel checkpoint carries prohibited key '{key}' at <root>." in validate(
        state
    )


def test_invariant_10_rejects_nested_depends_on() -> None:
    """A depends_on nested inside an item is rejected and located by path."""

    state = build_valid_parallel_state()
    item_at(state, 1)["depends_on"] = [444]

    assert (
        "Parallel checkpoint carries prohibited key 'depends_on' at items[1]."
        in validate(state)
    )


def test_invariant_11_rejects_deeply_nested_epic_merge_pr() -> None:
    """An epic_merge_pr block nested two levels down is still rejected."""

    state = build_valid_parallel_state()
    item_at(state, 0)["metadata"] = {"epic_merge_pr": {"merge_commit_sha": "abc"}}

    assert (
        "Parallel checkpoint carries prohibited key 'epic_merge_pr' at "
        "items[0].metadata." in validate(state)
    )


def test_invariant_19_absent_receipt_arrays_yield_no_errors() -> None:
    """Every receipt array is optional; absence is backward compatible."""

    state = build_valid_parallel_state()

    assert "delegation_receipts" not in state
    assert validate(state) == []


def test_invariant_19_accepts_a_present_receipt_list() -> None:
    """A present receipt array validates when it is a list, whatever it holds."""

    state = build_valid_parallel_state()
    state["delegation_receipts"] = [{"anything": "tolerated"}]

    assert validate(state) == []
