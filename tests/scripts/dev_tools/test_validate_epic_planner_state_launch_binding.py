"""Tests for epic-planner preparation-child launch binding."""

from __future__ import annotations

import json
from typing import Any

import pytest

from scripts.dev_tools.epic_planner_readiness import validate_epic_readiness_integrity
from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology
from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)
from tests.scripts.dev_tools.epic_planner_launch_evidence_test_support import (
    launch_evidence_fixture,
)

_LAUNCH_BINDING_KEYS = (
    "branch_name",
    "worktree_path",
    "delegation_receipt",
    "launch_receipt_path",
    "launch_status_path",
)


def _strip_launch_binding(feature: dict[str, Any]) -> None:
    """Remove every launch-binding key to produce a Claude-prepared feature."""

    for key in _LAUNCH_BINDING_KEYS:
        feature.pop(key)


def _feature(issue_num: int) -> dict[str, Any]:
    """Build one prepared feature with complete launch evidence."""

    folder = f"docs/features/active/feature-{issue_num}"
    delegation_id = f"prepare-{issue_num}"
    launch_root = "artifacts/orchestration/epic-child-launches/preparation"
    model = dict(
        resolve_codex_deployment("orchestrator", "C3", "epic_preparation_child", "C3")
    )
    model.update(phase="preparation", delegation_id=delegation_id)
    topology = dict(resolve_codex_topology([], 0, 0, "epic_preparation_child"))
    topology["phase"] = "preparation"
    return {
        "issue_num": issue_num,
        "feature_folder": folder,
        "depends_on": [],
        "wave": 0,
        "complexity_band": "C3",
        "preparation_status": "prepared",
        "research_path": f"artifacts/research/feature-{issue_num}.md",
        "plan_path": f"{folder}/plan.md",
        "preflight_status": "PREFLIGHT: ALL CLEAR",
        "branch_name": f"feature/feature-{issue_num}",
        "worktree_path": f"/removed/worktrees/feature-{issue_num}",
        "delegation_receipt": {
            "delegation_id": delegation_id,
            "feature_folder": folder,
            "issue_num": issue_num,
            "agent_name": model["deployment_agent"],
        },
        "model_routing_receipt": model,
        "launch_receipt_path": f"{launch_root}/feature-{issue_num}.receipt.json",
        "launch_status_path": f"{launch_root}/wave.status.json",
        "topology_receipt": topology,
    }


def _state() -> dict[str, Any]:
    """Build an execution-ready planner checkpoint."""

    topology = dict(
        resolve_codex_topology([], 0, 0, "standalone", root_persona="epic-planner")
    )
    topology["phase"] = "epic_planning"
    return {
        "objective": "prepare an epic",
        "epic_feature_folder": "sample-epic",
        "epic_manifest_path": "docs/features/epics/sample-epic/epic.md",
        "integration_branch": "epic/sample-epic-integration",
        "max_parallel_features": 4,
        "epic_worthiness": {"verdict": "epic", "rationale": "two features"},
        "features": [_feature(101), _feature(102)],
        "kickoff_prompt_path": "artifacts/orchestration/epic-kickoff-sample-epic.md",
        "completed_steps": ["preparation"],
        "next_step": "EPIC_EXECUTION_READY",
        "last_updated": "2026-07-10T10:00:00Z",
        "topology_receipt": topology,
    }


def _ready_errors(
    state: dict[str, Any],
    *,
    require_codex_model_routing: bool = False,
    require_codex_topology: bool = False,
) -> list[str]:
    """Validate execution readiness without repository context."""

    return validate_epic_planner_state_text(
        json.dumps(state),
        require_ready_for_execution=True,
        require_codex_model_routing=require_codex_model_routing,
        require_codex_topology=require_codex_topology,
    )


def _launch_binding_errors(errors: list[str]) -> list[str]:
    """Return only the launch-binding errors."""

    return [error for error in errors if " launch binding" in error]


def test_complete_launch_evidence_reaches_repository_context_gate() -> None:
    """Accept canonical bindings even when their former worktrees no longer exist."""

    assert _ready_errors(_state()) == [
        "Execution-ready planner validation requires repository context."
    ]


def test_launch_evidence_is_required_only_for_execution_readiness() -> None:
    """Require launch evidence at readiness, unconditionally under a Codex flag."""

    state = _state()
    _strip_launch_binding(state["features"][0])

    assert validate_epic_planner_state_text(json.dumps(state)) == []
    errors = _ready_errors(state, require_codex_topology=True)
    assert any("features[0] launch binding.branch_name" in error for error in errors)
    assert any(
        "features[0] launch binding.delegation_receipt must be an object" in error
        for error in errors
    )


def test_ready_gate_skips_launch_binding_for_feature_without_launch_paths() -> None:
    """Skip launch evidence for a keyless feature when no Codex flag is set."""

    # Arrange
    state = _state()
    _strip_launch_binding(state["features"][0])
    context = launch_evidence_fixture()[1]

    # Act
    errors = validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True, readiness_context=context
    )

    # Assert
    assert errors, "readiness integrity must still run and report other errors"
    offending = [
        error
        for error in errors
        if " launch binding" in error or "must identify a launch artifact" in error
    ]
    assert offending == []


def test_ready_gate_rejects_partial_launch_binding() -> None:
    """Validate a feature that carries only one launch path key."""

    # Arrange
    state = _state()
    state["features"][0].pop("launch_status_path")

    # Act
    errors = _ready_errors(state)

    # Assert
    assert _launch_binding_errors(errors) == [
        "Epic planner checkpoint features[0] launch binding.launch_status_path "
        "must be under artifacts/orchestration/epic-child-launches/."
    ]


@pytest.mark.parametrize(
    "flag", ["require_codex_model_routing", "require_codex_topology"]
)
def test_codex_flag_keeps_launch_binding_unconditional(flag: str) -> None:
    """Validate a keyless feature whenever a Codex flag is asserted."""

    # Arrange
    state = _state()
    _strip_launch_binding(state["features"][0])

    # Act
    errors = _ready_errors(state, **{flag: True})

    # Assert
    assert any("features[0] launch binding.branch_name" in error for error in errors)
    assert any(
        "features[0] launch binding.delegation_receipt must be an object" in error
        for error in errors
    )


def test_ready_gate_preserves_feature_index_when_earlier_feature_is_skipped() -> None:
    """Keep the original feature index when an earlier keyless feature is skipped."""

    # Arrange
    state = _state()
    _strip_launch_binding(state["features"][0])
    state["features"][1].pop("launch_status_path")

    # Act
    errors = _ready_errors(state)

    # Assert
    assert _launch_binding_errors(errors) == [
        "Epic planner checkpoint features[1] launch binding.launch_status_path "
        "must be under artifacts/orchestration/epic-child-launches/."
    ]


@pytest.mark.parametrize("value", ["", None])
def test_ready_gate_validates_feature_with_empty_launch_path_value(
    value: object,
) -> None:
    """Treat a present launch path key with an empty value as arming the gate."""

    # Arrange
    state = _state()
    state["features"][0]["launch_status_path"] = value

    # Act
    errors = _ready_errors(state)

    # Assert
    assert _launch_binding_errors(errors) == [
        "Epic planner checkpoint features[0] launch binding.launch_status_path "
        "must be under artifacts/orchestration/epic-child-launches/."
    ]


@pytest.mark.parametrize(
    ("field", "invalid", "expected"),
    [
        ("branch_name", " ", ".branch_name must be a non-empty unique string."),
        (
            "worktree_path",
            "removed/worktrees/feature-101",
            ".worktree_path must be a non-empty canonical absolute path.",
        ),
        (
            "worktree_path",
            "/removed/worktrees/../feature-101",
            ".worktree_path must be a non-empty canonical absolute path.",
        ),
        (
            "launch_receipt_path",
            "artifacts/orchestration/other/receipt.json",
            ".launch_receipt_path must be under "
            "artifacts/orchestration/epic-child-launches/.",
        ),
        (
            "launch_status_path",
            "artifacts/orchestration/epic-child-launches/../status.json",
            ".launch_status_path must be under "
            "artifacts/orchestration/epic-child-launches/.",
        ),
    ],
)
def test_rejects_invalid_branch_or_launch_path(
    field: str, invalid: object, expected: str
) -> None:
    """Reject non-canonical or out-of-namespace launch references."""

    state = _state()
    state["features"][0][field] = invalid

    assert any(error.endswith(expected) for error in _ready_errors(state))


@pytest.mark.parametrize(
    ("field", "invalid", "expected"),
    [
        ("feature_folder", "other", ".feature_folder must match the feature."),
        ("issue_num", 999, ".issue_num must match the feature."),
        (
            "agent_name",
            "atomic-planner-c3-elevated",
            ".agent_name must name a generated orchestrator agent.",
        ),
    ],
)
def test_rejects_invalid_delegation_binding(
    field: str, invalid: object, expected: str
) -> None:
    """Cross-bind the delegation to its feature and generated agent profile."""

    state = _state()
    state["features"][0]["delegation_receipt"][field] = invalid

    assert any(error.endswith(expected) for error in _ready_errors(state))


@pytest.mark.parametrize(
    ("field", "invalid", "expected"),
    [
        (
            "delegation_id",
            "other",
            ".delegation_id must match delegation_receipt.delegation_id.",
        ),
        (
            "deployment_agent",
            "orchestrator-c2",
            ".deployment_agent must match delegation_receipt.agent_name.",
        ),
        (
            "execution_context",
            "epic_execution_child",
            ".execution_context must be 'epic_preparation_child'.",
        ),
    ],
)
def test_rejects_invalid_model_receipt_binding(
    field: str, invalid: object, expected: str
) -> None:
    """Cross-bind the model receipt to the delegation and preparation context."""

    state = _state()
    state["features"][0]["model_routing_receipt"][field] = invalid

    assert any(error.endswith(expected) for error in _ready_errors(state))


def test_requires_unique_branch_and_delegation_identifiers() -> None:
    """Prevent two prepared children from sharing launch identities."""

    state = _state()
    first, second = state["features"]
    second["branch_name"] = first["branch_name"]
    delegation_id = first["delegation_receipt"]["delegation_id"]
    second["delegation_receipt"]["delegation_id"] = delegation_id
    second["model_routing_receipt"]["delegation_id"] = delegation_id

    errors = _ready_errors(state)
    assert any("features[1] launch binding.branch_name" in error for error in errors)
    assert any(
        "features[1] launch binding.delegation_receipt.delegation_id" in error
        for error in errors
    )


def test_readiness_integrity_skips_ignored_kickoff_for_unsafe_path() -> None:
    """Report an escaping kickoff path and skip reading the ignored kickoff."""

    # Arrange
    state = _state()
    state["kickoff_prompt_path"] = "../outside.md"
    context = launch_evidence_fixture()[1]

    # Act
    errors = validate_epic_readiness_integrity(state, json.dumps(state), context)

    # Assert
    assert (
        "Epic planner checkpoint kickoff_prompt_path must stay within the "
        "workspace root."
    ) in errors


def test_readiness_integrity_skips_feature_checks_for_non_list_features() -> None:
    """Skip per-feature checks when the features value is not a list."""

    # Arrange
    state = _state()
    state["features"] = "not-a-list"
    context = launch_evidence_fixture()[1]

    # Act
    errors = validate_epic_readiness_integrity(state, json.dumps(state), context)

    # Assert
    assert [error for error in errors if "features[" in error] == []


def test_readiness_integrity_skips_non_record_feature() -> None:
    """Skip a feature entry that is not a JSON object."""

    # Arrange
    state = _state()
    state["features"] = ["not-a-record"]
    context = launch_evidence_fixture()[1]

    # Act
    errors = validate_epic_readiness_integrity(state, json.dumps(state), context)

    # Assert
    assert [error for error in errors if "features[" in error] == []
