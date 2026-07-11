"""Tests for epic-planner preparation-child launch binding."""

from __future__ import annotations

import json
from typing import Any

import pytest

from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology
from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)


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


def _ready_errors(state: dict[str, Any]) -> list[str]:
    """Validate execution readiness without repository context."""

    return validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True
    )


def test_complete_launch_evidence_reaches_repository_context_gate() -> None:
    """Accept canonical bindings even when their former worktrees no longer exist."""

    assert _ready_errors(_state()) == [
        "Execution-ready planner validation requires repository context."
    ]


def test_launch_evidence_is_required_only_for_execution_readiness() -> None:
    """Keep planning checkpoints valid before the execution-readiness gate."""

    state = _state()
    feature = state["features"][0]
    for key in (
        "branch_name",
        "worktree_path",
        "delegation_receipt",
        "launch_receipt_path",
        "launch_status_path",
    ):
        feature.pop(key)

    assert validate_epic_planner_state_text(json.dumps(state)) == []
    errors = _ready_errors(state)
    assert any("features[0] launch binding.branch_name" in error for error in errors)
    assert any(
        "features[0] launch binding.delegation_receipt must be an object" in error
        for error in errors
    )


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
