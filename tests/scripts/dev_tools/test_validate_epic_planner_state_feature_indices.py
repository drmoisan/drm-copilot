"""Tests for original feature indices in epic-planner validation prefixes."""

from __future__ import annotations

import json
from typing import Any

import pytest

from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)
from tests.scripts.dev_tools.typescript_twin_test_support import (
    literals_missing_from_twin,
)

REPOSITORY_CONTEXT_ERROR = (
    "Execution-ready planner validation requires repository context."
)
NON_OBJECT_ERROR = "Epic planner checkpoint features[0] must be an object."
SHIFTED_PREPARATION_ERROR = (
    "Epic planner checkpoint features[2].preparation_status must be 'prepared'."
)
UNSHIFTED_PREPARATION_ERROR = (
    "Epic planner checkpoint features[1].preparation_status must be 'prepared'."
)
SHIFTED_MODEL_RECEIPT_ERROR = (
    "Epic planner checkpoint features[2].model_routing_receipt must be an object."
)
SHIFTED_TOPOLOGY_RECEIPT_ERROR = (
    "Epic planner checkpoint features[2].topology_receipt must be an object."
)
DUPLICATE_FOLDER_ERROR = (
    "Epic planner checkpoint features[2].feature_folder must be unique: "
    "'docs/features/active/feature-101'."
)
DUPLICATE_ISSUE_ERROR = (
    "Epic planner checkpoint features[2].issue_num must be unique: 101."
)
UNRESOLVED_DEPENDENCY_ERROR = (
    "Epic planner checkpoint features[3].depends_on contains unresolved reference: 999."
)
SHIFTED_WAVE_ERROR = (
    "Epic planner checkpoint features[3].wave must be 0 "
    "from the dependency graph, found 1."
)
SHIFTED_LAUNCH_BINDING_ERROR = (
    "Epic planner checkpoint features[2] launch binding.branch_name "
    "must be a non-empty unique string."
)
ASSERTED_MESSAGES = (
    REPOSITORY_CONTEXT_ERROR,
    NON_OBJECT_ERROR,
    SHIFTED_PREPARATION_ERROR,
    UNSHIFTED_PREPARATION_ERROR,
    SHIFTED_MODEL_RECEIPT_ERROR,
    SHIFTED_TOPOLOGY_RECEIPT_ERROR,
    DUPLICATE_FOLDER_ERROR,
    DUPLICATE_ISSUE_ERROR,
    UNRESOLVED_DEPENDENCY_ERROR,
    SHIFTED_WAVE_ERROR,
    SHIFTED_LAUNCH_BINDING_ERROR,
)


def _claude_feature(
    issue_num: int,
    *,
    depends_on: list[int] | None = None,
    preparation_status: str = "prepared",
) -> dict[str, Any]:
    """Build one feature carrying only the required feature keys."""

    return {
        "issue_num": issue_num,
        "feature_folder": f"docs/features/active/feature-{issue_num}",
        "depends_on": depends_on or [],
        "wave": 0 if not depends_on else 1,
        "complexity_band": "C3",
        "preparation_status": preparation_status,
        "research_path": f"artifacts/research/feature-{issue_num}.md",
        "plan_path": f"docs/features/active/feature-{issue_num}/plan.md",
        "preflight_status": "PREFLIGHT: ALL CLEAR",
    }


def _claude_state(features: list[object]) -> dict[str, Any]:
    """Build a Claude-shaped ready checkpoint around the given feature entries."""

    return {
        "objective": "prepare two related features",
        "epic_feature_folder": "sample-epic",
        "epic_manifest_path": "docs/features/epics/sample-epic/epic.md",
        "integration_branch": "epic/sample-epic-integration",
        "max_parallel_features": 4,
        "epic_worthiness": {"verdict": "epic", "rationale": "two features"},
        "features": features,
        "kickoff_prompt_path": "artifacts/orchestration/epic-kickoff-sample-epic.md",
        "completed_steps": ["decomposition", "preparation", "fan-in"],
        "next_step": "EPIC_EXECUTION_READY",
        "last_updated": "2026-07-10T10:00:00Z",
    }


def _ready_errors(
    state: dict[str, Any], *, require_codex_model_routing: bool = False
) -> list[str]:
    """Validate a checkpoint under the ready gate with no readiness context."""

    return validate_epic_planner_state_text(
        json.dumps(state),
        require_ready_for_execution=True,
        require_codex_model_routing=require_codex_model_routing,
    )


@pytest.mark.parametrize(
    "entry",
    ["not-a-feature", None, 7, ["not-a-feature"]],
    ids=["string", "null", "number", "list"],
)
def test_ready_gate_prefix_uses_original_index_after_non_object_entry(
    entry: object,
) -> None:
    """Use the original index in ready-gate prefixes after a non-object entry."""

    state = _claude_state(
        [
            entry,
            _claude_feature(101),
            _claude_feature(102, depends_on=[101], preparation_status="pending"),
        ]
    )

    errors = _ready_errors(state)

    assert errors == [
        NON_OBJECT_ERROR,
        SHIFTED_PREPARATION_ERROR,
        REPOSITORY_CONTEXT_ERROR,
    ]


def test_ready_gate_receipt_prefix_uses_original_index_under_codex_flag() -> None:
    """Use the original index in receipt prefixes when a Codex flag is set."""

    state = _claude_state(
        ["not-a-feature", _claude_feature(101), _claude_feature(102, depends_on=[101])]
    )

    errors = _ready_errors(state, require_codex_model_routing=True)

    assert SHIFTED_MODEL_RECEIPT_ERROR in errors
    assert SHIFTED_TOPOLOGY_RECEIPT_ERROR in errors


def test_dependency_wave_prefixes_use_original_index_after_non_object_entry() -> None:
    """Use the original index in all three dependency-wave loop prefixes."""

    state = _claude_state(
        [
            "not-a-feature",
            _claude_feature(101),
            _claude_feature(101),
            _claude_feature(102, depends_on=[999]),
        ]
    )

    errors = validate_epic_planner_state_text(json.dumps(state))

    assert errors == [
        NON_OBJECT_ERROR,
        DUPLICATE_FOLDER_ERROR,
        DUPLICATE_ISSUE_ERROR,
        UNRESOLVED_DEPENDENCY_ERROR,
        SHIFTED_WAVE_ERROR,
    ]


def test_launch_binding_prefix_uses_original_index_under_codex_flag() -> None:
    """Use the original index in planner launch-binding prefixes."""

    state = _claude_state(
        ["not-a-feature", _claude_feature(101), _claude_feature(102, depends_on=[101])]
    )

    errors = _ready_errors(state, require_codex_model_routing=True)

    assert SHIFTED_LAUNCH_BINDING_ERROR in errors


def test_ready_gate_prefix_unchanged_without_non_object_entries() -> None:
    """Keep the ready-gate prefix index unchanged when every entry is an object."""

    state = _claude_state(
        [
            _claude_feature(101),
            _claude_feature(102, depends_on=[101], preparation_status="pending"),
        ]
    )

    errors = _ready_errors(state)

    assert errors == [UNSHIFTED_PREPARATION_ERROR, REPOSITORY_CONTEXT_ERROR]


def test_asserted_messages_match_typescript_twin() -> None:
    """Keep every asserted message identical to its TypeScript twin literal."""

    missing = literals_missing_from_twin(
        ASSERTED_MESSAGES, "lib/validate/epic-planner-state-feature-indices.test.ts"
    )

    assert missing == []
