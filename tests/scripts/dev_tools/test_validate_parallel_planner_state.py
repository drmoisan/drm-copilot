"""Tests for the parallel-planner checkpoint validator, invariants P1 to P9.

Covers the unconditional structural invariants P1 through P4 and the
structural readiness gate P6 through P9, including the
``PARALLEL_EXECUTION_READY`` sentinel and the kickoff-PATH convention.
Shared helper modules have focused coverage in the Phase 1 checkpoint tests.
The deliberate omission recorded as spec P5 is asserted as an absence. Data is
dictionaries and serialized with ``json.dumps``; no temporary file is created.
"""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools._parallel_state_common import VALID_MODES
from scripts.dev_tools.validate_parallel_planner_state import (
    REQUIRED_ITEM_KEYS,
    REQUIRED_KEYS,
    VALID_COMPLEXITY_BANDS,
    validate_parallel_planner_state_text,
)
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_blast_radius,
)

CONTEXT = "Parallel planner checkpoint"

# The kickoff path invariant P9 pins for the builder's slug (assumption A6).
EXPECTED_KICKOFF = "docs/features/parallel/wave-one/parallel-kickoff.md"

# Error-string prefix for the second builder item, which the readiness-gate
# cases mutate so a reported error is unambiguously attributable to them.
ITEM1 = f"{CONTEXT} items[1]"


def build_item(issue_num: int, slug: str) -> dict[str, object]:
    """Return one fully prepared, preflight-cleared planner item."""

    return {
        "issue_num": issue_num,
        "feature_folder": f"2026-08-07-{slug}-{issue_num}",
        "kind": "feature",
        "state": "prepared",
        "blast_radius": build_blast_radius(),
        "preparation_status": "prepared",
        "research_path": f"docs/features/active/{slug}/research.md",
        "plan_path": f"docs/features/active/{slug}/plan.md",
        "preflight_status": "PREFLIGHT: ALL CLEAR",
    }


def build_valid_planner_state() -> dict[str, object]:
    """Return a minimally valid, execution-ready planner checkpoint payload.

    Two prepared items sit in one current-generation cohort with no conflict
    edges, so a test can mutate one field and attribute any resulting error to
    that mutation. The payload also satisfies the readiness gate, so the same
    builder serves both the gate-off and gate-on cases.
    """

    return {
        "objective": "prepare parallel run wave-one",
        "parallel_slug": "wave-one",
        "parallel_manifest_path": "docs/features/parallel/wave-one/parallel.md",
        "mode": "closed",
        "max_concurrency": 4,
        "items": [
            build_item(444, "parallel-schema-validators"),
            build_item(445, "parallel-cohort-scheduler"),
        ],
        "cohorts": [{"index": 0, "generation": 0, "item_keys": [444, 445]}],
        "conflict_edges": [],
        "recolor_generation": 0,
        "completed_steps": ["manifest_parsed"],
        "next_step": "PARALLEL_EXECUTION_READY",
        "last_updated": "2026-08-07T10-00",
        "kickoff_prompt_path": EXPECTED_KICKOFF,
    }


def item_at(state: dict[str, object], index: int) -> dict[str, object]:
    """Return one ``items[]`` entry of a builder-produced checkpoint."""

    return cast("list[dict[str, object]]", state["items"])[index]


def radius_of(state: dict[str, object], index: int) -> dict[str, object]:
    """Return one item's ``blast_radius`` block of a builder checkpoint."""

    return cast("dict[str, object]", item_at(state, index)["blast_radius"])


def cohort_at(state: dict[str, object], index: int) -> dict[str, object]:
    """Return one ``cohorts[]`` entry of a builder-produced checkpoint."""

    return cast("list[dict[str, object]]", state["cohorts"])[index]


def validate(state: dict[str, object], *, ready: bool = False) -> list[str]:
    """Serialize a checkpoint dict and return the validator's error list."""

    return validate_parallel_planner_state_text(
        json.dumps(state), require_ready_for_execution=ready
    )


def assert_error(
    state: dict[str, object], expected: str, *, ready: bool = False
) -> None:
    """Assert that validating a checkpoint reports one exact error string."""

    assert expected in validate(state, ready=ready)


@pytest.mark.parametrize("ready", [False, True])
def test_valid_checkpoint_yields_no_errors(ready: bool) -> None:
    """The explicit gate adds only the missing external-evidence error."""

    expected = [f"{CONTEXT} Codex readiness evidence is required."] if ready else []
    assert validate(build_valid_planner_state(), ready=ready) == expected


def test_validator_does_not_mutate_its_input() -> None:
    """Validation leaves the caller's parsed payload untouched."""

    state = build_valid_planner_state()
    snapshot = copy.deepcopy(state)
    validate_parallel_planner_state_text(json.dumps(state))

    assert state == snapshot


def test_invalid_json_returns_single_error() -> None:
    """Unparseable text yields exactly one prefixed error."""

    errors = validate_parallel_planner_state_text("{not json")

    assert len(errors) == 1
    assert errors[0].startswith(f"{CONTEXT} is not valid JSON: ")


def test_non_object_root_is_rejected() -> None:
    """A JSON array root yields exactly one root-shape error."""

    assert validate_parallel_planner_state_text("[]") == [
        f"{CONTEXT} root must be a JSON object."
    ]


@pytest.mark.parametrize("key", REQUIRED_KEYS)
def test_invariant_p1_reports_each_missing_required_key(key: str) -> None:
    """Removing any required key yields that key's own missing-key error."""

    state = build_valid_planner_state()
    del state[key]

    assert_error(state, f"{CONTEXT} missing required key: {key}.")


def test_invariant_p1_empty_object_reports_every_required_key() -> None:
    """An empty object reports exactly one error per required key."""

    assert len(validate_parallel_planner_state_text("{}")) == len(REQUIRED_KEYS)


def test_optional_keys_are_absent_from_the_builder_and_yield_no_errors() -> None:
    """``kickoff_prompt_path`` and ``complexity_band`` are optional off the gate."""

    state = build_valid_planner_state()
    del state["kickoff_prompt_path"]

    assert "complexity_band" not in item_at(state, 0)
    assert validate(state) == []


@pytest.mark.parametrize("key", ["parallel_slug", "parallel_manifest_path"])
@pytest.mark.parametrize("value", ["", "   ", 5, None])
def test_invariant_p2_rejects_blank_identity_fields(key: str, value: object) -> None:
    """The slug and manifest path must each be a non-empty string."""

    state = build_valid_planner_state()
    state[key] = value

    assert_error(state, f"{CONTEXT} {key} must be a non-empty string.")


@pytest.mark.parametrize("mode", VALID_MODES)
def test_invariant_p2_accepts_every_mode_member(mode: str) -> None:
    """Each declared mode enum member validates cleanly."""

    state = build_valid_planner_state()
    state["mode"] = mode

    assert validate(state) == []


def test_invariant_p2_rejects_an_out_of_enum_mode() -> None:
    """A mode outside the enum yields the shared enum error."""

    state = build_valid_planner_state()
    state["mode"] = "ajar"

    assert_error(state, f"{CONTEXT} mode must be one of closed, open; found: 'ajar'.")


@pytest.mark.parametrize("concurrency", [0, -1, 9, "4", 1.5, True, None])
def test_invariant_p2_rejects_out_of_bound_concurrency(concurrency: object) -> None:
    """Out-of-range, non-integer, and boolean concurrency values are rejected."""

    state = build_valid_planner_state()
    state["max_concurrency"] = concurrency

    assert_error(
        state,
        f"{CONTEXT} max_concurrency must be an integer from 1 through 8; "
        f"found: {concurrency!r}.",
    )


@pytest.mark.parametrize("key", REQUIRED_ITEM_KEYS)
def test_invariant_p3_reports_each_missing_item_key(key: str) -> None:
    """Removing any required per-item key yields its own missing-key error."""

    state = build_valid_planner_state()
    del item_at(state, 0)[key]

    assert_error(state, f"{CONTEXT} items[0] missing required key: {key}.")


def test_invariant_p3_rejects_duplicate_issue_numbers() -> None:
    """Two items sharing the primary key are rejected."""

    state = build_valid_planner_state()
    item_at(state, 1)["issue_num"] = 444
    cohort_at(state, 0)["item_keys"] = [444]

    assert_error(state, f"{CONTEXT} has duplicate items[].issue_num: 444.")


def test_invariant_p3_rejects_an_out_of_enum_kind() -> None:
    """The planner surface requires the S4 kind enum on every item."""

    state = build_valid_planner_state()
    item_at(state, 0)["kind"] = "chore"

    assert_error(
        state,
        f"{CONTEXT} items[0] kind must be one of feature, bug; found: 'chore'.",
    )


def test_invariant_p3_rejects_a_non_object_blast_radius() -> None:
    """A non-object radius yields exactly one shape error for that item."""

    state = build_valid_planner_state()
    item_at(state, 0)["blast_radius"] = ["scripts/**"]

    assert_error(state, f"{CONTEXT} items[0] blast_radius must be an object.")


@pytest.mark.parametrize("band", VALID_COMPLEXITY_BANDS)
def test_invariant_p3_accepts_every_complexity_band(band: str) -> None:
    """Each declared complexity band validates cleanly."""

    state = build_valid_planner_state()
    item_at(state, 0)["complexity_band"] = band

    assert validate(state) == []


def test_invariant_p3_rejects_an_out_of_enum_complexity_band() -> None:
    """A band outside C1..C4 yields the shared enum error."""

    state = build_valid_planner_state()
    item_at(state, 0)["complexity_band"] = "C9"

    assert_error(
        state,
        f"{CONTEXT} items[0] complexity_band must be one of C1, C2, C3, C4; "
        f"found: 'C9'.",
    )


def test_invariant_p3_rejects_a_non_list_items_value() -> None:
    """A non-list items value yields one shape error and no gate item errors."""

    state = build_valid_planner_state()
    state["items"] = {"444": {}}

    assert_error(state, f"{CONTEXT} items must be a list.", ready=True)


@pytest.mark.parametrize("key", ["depends_on", "integration_branch", "epic_merge_pr"])
def test_invariant_p3_rejects_top_level_prohibited_keys(key: str) -> None:
    """Declared ordering and integration-branch keys are rejected at the root."""

    state = build_valid_planner_state()
    state[key] = "value"

    assert_error(state, f"{CONTEXT} carries prohibited key '{key}' at <root>.")


def test_invariant_p3_rejects_item_level_depends_on() -> None:
    """A per-item dependency declaration is rejected with its path."""

    state = build_valid_planner_state()
    item_at(state, 1)["depends_on"] = [444]

    assert_error(state, f"{CONTEXT} carries prohibited key 'depends_on' at items[1].")


def test_invariant_p4_requires_exactly_one_current_generation_cohort() -> None:
    """A prepared item colored into no current cohort is rejected."""

    state = build_valid_planner_state()
    cohort_at(state, 0)["item_keys"] = [444]

    assert_error(
        state,
        f"{CONTEXT} item 445 in state 'prepared' must appear in exactly one "
        f"current-generation cohort; found 0.",
    )


def test_invariant_p4_rejects_a_negative_recolor_generation() -> None:
    """The generation counter must be a non-negative integer."""

    state = build_valid_planner_state()
    state["recolor_generation"] = -1

    assert_error(
        state,
        f"{CONTEXT} recolor_generation must be a non-negative integer; found: -1.",
    )


def test_invariant_p4_rejects_an_unnormalized_conflict_edge() -> None:
    """Conflict edges must be normalized with a < b for canonical identity."""

    state = build_valid_planner_state()
    state["conflict_edges"] = [{"a": 445, "b": 444, "reason": "path_overlap"}]

    assert_error(
        state,
        f"{CONTEXT} conflict_edges[0] must be normalized with a < b; "
        f"found: (445, 444).",
    )


def test_invariant_p4_checks_an_optional_current_cohort_pointer() -> None:
    """A checkpoint carrying the pointer has it bounded by the coloring."""

    state = build_valid_planner_state()
    state["current_cohort"] = 3

    assert_error(
        state,
        f"{CONTEXT} current_cohort 3 must not exceed the maximum "
        f"current-generation cohorts[].index 0.",
    )


def test_invariant_p5_does_not_recompute_the_coloring() -> None:
    """A consistent but non-canonical coloring is accepted (F4 owns parity)."""

    state = build_valid_planner_state()
    state["cohorts"] = [
        {"index": 0, "generation": 0, "item_keys": [444]},
        {"index": 1, "generation": 0, "item_keys": [445]},
    ]

    assert validate(state) == []


def test_invariant_p6_requires_at_least_two_items() -> None:
    """A single-item run is not worth scheduling in parallel."""

    state = build_valid_planner_state()
    state["items"] = [build_item(444, "parallel-schema-validators")]
    cohort_at(state, 0)["item_keys"] = [444]

    assert validate(state, ready=True) == [
        f"{CONTEXT} requires at least 2 items for execution readiness; found: 1.",
        f"{CONTEXT} Codex readiness evidence is required.",
    ]


@pytest.mark.parametrize(
    ("key", "value", "expected"),
    [
        (
            "preparation_status",
            "in_progress",
            f"{ITEM1} preparation_status must be 'prepared'; found: 'in_progress'.",
        ),
        (
            "preflight_status",
            "PREFLIGHT: REVISIONS REQUIRED",
            f"{ITEM1} preflight_status must be 'PREFLIGHT: ALL CLEAR'; "
            f"found: 'PREFLIGHT: REVISIONS REQUIRED'.",
        ),
        ("research_path", "", f"{ITEM1} research_path must be a non-empty string."),
        ("plan_path", None, f"{ITEM1} plan_path must be a non-empty string."),
    ],
)
def test_invariant_p7_rejects_an_unprepared_item(
    key: str, value: object, expected: str
) -> None:
    """Each per-item readiness condition has its own literal error."""

    state = build_valid_planner_state()
    item_at(state, 1)[key] = value

    assert_error(state, expected, ready=True)


@pytest.mark.parametrize(
    ("radius", "source"),
    [
        ({**build_blast_radius(), "source": "derived"}, "derived"),
        ({**build_blast_radius(), "source": "observed"}, "observed"),
        ("scripts/dev_tools/**", None),
    ],
)
def test_invariant_p7_requires_a_declared_blast_radius(
    radius: object, source: object
) -> None:
    """Only the planner-computed radius is authoritative for scheduling.

    The non-object radius case also proves the gate reports its own condition
    for an item whose radius carries no readable source at all.
    """

    state = build_valid_planner_state()
    item_at(state, 1)["blast_radius"] = radius

    assert_error(
        state,
        f"{ITEM1} blast_radius.source must be 'declared' for execution "
        f"readiness; found: {source!r}.",
        ready=True,
    )


@pytest.mark.parametrize("next_step", ["cohort_0_launch", "", None])
def test_invariant_p8_requires_the_readiness_sentinel(next_step: object) -> None:
    """The gate requires the exact PARALLEL_EXECUTION_READY sentinel."""

    state = build_valid_planner_state()
    state["next_step"] = next_step

    assert_error(
        state,
        f"{CONTEXT} next_step must be 'PARALLEL_EXECUTION_READY'; "
        f"found: {next_step!r}.",
        ready=True,
    )


@pytest.mark.parametrize(
    "kickoff",
    [
        "docs/features/parallel/other/parallel-kickoff.md",
        "artifacts/orchestration/epic-kickoff-wave-one.md",
        "",
        None,
    ],
)
def test_invariant_p9_requires_the_conventional_kickoff_path(kickoff: object) -> None:
    """The gate pins the kickoff PATH; it never reads the kickoff document."""

    state = build_valid_planner_state()
    state["kickoff_prompt_path"] = kickoff

    assert_error(
        state,
        f"{CONTEXT} kickoff_prompt_path must be {EXPECTED_KICKOFF!r}; "
        f"found: {kickoff!r}.",
        ready=True,
    )


def test_readiness_gate_contributes_no_errors_when_disabled() -> None:
    """Every gate condition may be violated while the flag is False."""

    state = build_valid_planner_state()
    state["items"] = [build_item(444, "parallel-schema-validators")]
    cohort_at(state, 0)["item_keys"] = [444]
    item_at(state, 0)["preparation_status"] = "in_progress"
    item_at(state, 0)["preflight_status"] = "PREFLIGHT: REVISIONS REQUIRED"
    radius_of(state, 0)["source"] = "derived"
    state["next_step"] = "awaiting_research"
    del state["kickoff_prompt_path"]

    assert validate(state) == []
