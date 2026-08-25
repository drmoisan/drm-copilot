"""In-memory launch-binding tests for the epic checkpoint validator."""

from __future__ import annotations

import json
from typing import Any

import pytest

from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)


def _feature(
    issue_num: int = 101,
    folder: str = "child-a",
    *,
    merge_status: str = "worktree_created",
) -> dict[str, Any]:
    """Build one feature with complete durable launch evidence."""

    delegation_id = f"delegate-{folder}"
    deployment_agent = "orchestrator-c3-elevated"
    artifact_root = f"artifacts/orchestration/epic-child-launches/wave-0/{folder}"
    return {
        "issue_num": issue_num,
        "feature_folder": folder,
        "depends_on": [],
        "wave_number": 0,
        "merge_status": merge_status,
        "branch_name": f"feature/{folder}",
        "worktree_path": f"/repo/worktrees/{folder}",
        "delegation_receipt": {
            "delegation_id": delegation_id,
            "feature_folder": folder,
            "issue_num": issue_num,
            "agent_name": deployment_agent,
        },
        "model_routing_receipt": {
            "delegation_id": delegation_id,
            "deployment_agent": deployment_agent,
            "execution_context": "epic_execution_child",
        },
        "launch_receipt_path": f"{artifact_root}.receipt.json",
        "launch_status_path": f"{artifact_root}.status.json",
    }


def _state(*features: dict[str, Any]) -> dict[str, Any]:
    """Build a structurally valid epic checkpoint around the supplied features."""

    return {
        "objective": "execute prepared epic",
        "route_id": "epic",
        "epic_feature_folder": "sample-epic",
        "integration_branch": "epic/sample-epic-integration",
        "max_parallel_features": 4,
        "completed_steps": ["manifest_parsed"],
        "next_step": "wave_0",
        "last_updated": "2026-07-10T10:00:00Z",
        "waves": [
            {
                "wave_number": 0,
                "feature_folders": [feature["feature_folder"] for feature in features],
            }
        ],
        "features": list(features),
    }


def _launch_errors(errors: list[str]) -> list[str]:
    """Select errors emitted by the launch-binding helper."""

    return [error for error in errors if " launch binding" in error]


def test_model_routing_gate_accepts_complete_launch_binding() -> None:
    """Accept durable evidence for a feature that has launched."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(_feature())), require_codex_model_routing=True
    )

    assert errors == []


def test_topology_gate_activates_launch_binding_validation() -> None:
    """Activate launch binding when only the topology gate is requested."""

    feature = _feature()
    feature.pop("delegation_receipt")

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(feature)), require_codex_topology=True
    )

    assert (
        "Epic checkpoint feature 'child-a' launch binding.delegation_receipt "
        "must be an object." in errors
    )


def test_unlaunched_feature_does_not_require_binding_under_routing_gate() -> None:
    """Do not require launch evidence before an execution child is launched."""

    feature = _feature(merge_status="not_started")
    for key in (
        "branch_name",
        "worktree_path",
        "delegation_receipt",
        "model_routing_receipt",
        "launch_receipt_path",
        "launch_status_path",
    ):
        feature.pop(key)

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(feature)), require_codex_model_routing=True
    )

    assert errors == []


def test_launch_binding_is_dormant_without_an_enforcement_gate() -> None:
    """Preserve compatibility when no routing or completion gate is requested."""

    feature = _feature()
    feature.pop("delegation_receipt")

    errors = validate_epic_orchestrator_state_text(json.dumps(_state(feature)))

    assert errors == []


def test_require_complete_skips_feature_without_launch_paths() -> None:
    """Skip launch binding for a feature that records no launch evidence."""

    # Arrange: a merged feature in the Claude shape, which records no launch
    # receipt, no launch status, and neither per-feature receipt.
    feature = _feature(merge_status="merged")
    for key in (
        "launch_receipt_path",
        "launch_status_path",
        "delegation_receipt",
        "model_routing_receipt",
    ):
        feature.pop(key)
    state = _state(feature)
    state["epic_merge_pr"] = {"merge_commit_sha": "abc123"}

    # Act: request completion only, leaving both Codex gates at their defaults.
    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert: a complete epic with no launch evidence satisfies the gate.
    assert errors == []


def test_require_complete_rejects_partial_launch_binding() -> None:
    """Reject a half-written launch binding that records only one launch path."""

    # Arrange: a merged feature keeping launch_receipt_path but not
    # launch_status_path, which is the partial binding the either-key
    # presence test is designed to catch.
    feature = _feature(merge_status="merged")
    feature.pop("launch_status_path")
    state = _state(feature)
    state["epic_merge_pr"] = {"merge_commit_sha": "abc123"}

    # Act: request completion only, leaving both Codex gates at their defaults.
    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert: the one absent launch path key produces exactly its own error.
    assert _launch_errors(errors) == [
        "Epic checkpoint feature 'child-a' launch binding.launch_status_path "
        "must be under artifacts/orchestration/epic-child-launches/."
    ]


def test_require_complete_accepts_complete_persisted_binding() -> None:
    """Accept fully merged state when all launch evidence remains persisted."""

    state = _state(_feature(merge_status="merged"))
    state["epic_merge_pr"] = {"merge_commit_sha": "abc123"}

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert errors == []


def test_require_complete_rejects_unmerged_feature() -> None:
    """Retain the completion failure for a launched but unmerged feature."""

    state = _state(_feature())
    state["epic_merge_pr"] = {"merge_commit_sha": "abc123"}

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any(
        "feature 'child-a' merge_status is not merged/worktree_removed" in error
        for error in errors
    )


def test_require_complete_rejects_missing_merge_commit_sha() -> None:
    """Retain the completion failure when merge-commit evidence is absent."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(_feature(merge_status="merged"))), require_complete=True
    )

    assert any(
        "epic_merge_pr.merge_commit_sha is missing or empty" in error
        for error in errors
    )


def test_require_complete_remains_disabled_by_default() -> None:
    """Preserve backward compatibility when completion is not requested."""

    errors = validate_epic_orchestrator_state_text(json.dumps(_state(_feature())))

    assert errors == []


@pytest.mark.parametrize(
    ("field", "value", "expected"),
    [
        (
            "branch_name",
            " ",
            "Epic checkpoint feature 'child-a' launch binding.branch_name "
            "must be a non-empty unique string.",
        ),
        (
            "worktree_path",
            "repo/worktrees/child-a",
            "Epic checkpoint feature 'child-a' launch binding.worktree_path "
            "must be a non-empty canonical absolute path.",
        ),
        (
            "worktree_path",
            "/repo/worktrees/../child-a",
            "Epic checkpoint feature 'child-a' launch binding.worktree_path "
            "must be a non-empty canonical absolute path.",
        ),
        (
            "launch_receipt_path",
            "artifacts/orchestration/other/child-a.receipt.json",
            "Epic checkpoint feature 'child-a' launch binding.launch_receipt_path "
            "must be under artifacts/orchestration/epic-child-launches/.",
        ),
        (
            "launch_status_path",
            "artifacts/orchestration/epic-child-launches/../outside.json",
            "Epic checkpoint feature 'child-a' launch binding.launch_status_path "
            "must be under artifacts/orchestration/epic-child-launches/.",
        ),
    ],
)
def test_rejects_invalid_branch_worktree_or_artifact_path(
    field: str, value: object, expected: str
) -> None:
    """Reject malformed direct launch-binding fields with parity errors."""

    feature = _feature()
    feature[field] = value

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(feature)), require_codex_model_routing=True
    )

    assert expected in errors


@pytest.mark.parametrize(
    ("field", "value", "expected_suffix"),
    [
        ("feature_folder", "other", "feature_folder must match the feature."),
        ("issue_num", 999, "issue_num must match the feature."),
        ("agent_name", "", "agent_name must be a non-empty string."),
    ],
)
def test_rejects_delegation_binding_mismatch(
    field: str, value: object, expected_suffix: str
) -> None:
    """Reject a delegation receipt not bound exactly to its feature."""

    feature = _feature()
    receipt = feature["delegation_receipt"]
    assert isinstance(receipt, dict)
    receipt[field] = value

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(feature)), require_codex_model_routing=True
    )

    assert any(error.endswith(expected_suffix) for error in errors)


@pytest.mark.parametrize(
    ("field", "value", "expected_suffix"),
    [
        (
            "delegation_id",
            "different",
            "delegation_id must match delegation_receipt.delegation_id.",
        ),
        (
            "deployment_agent",
            "orchestrator-c2",
            "deployment_agent must match delegation_receipt.agent_name.",
        ),
        (
            "execution_context",
            "standalone",
            "execution_context must be 'epic_execution_child'.",
        ),
    ],
)
def test_rejects_model_receipt_binding_mismatch(
    field: str, value: object, expected_suffix: str
) -> None:
    """Reject a singular model receipt not bound to its delegation."""

    feature = _feature()
    receipt = feature["model_routing_receipt"]
    assert isinstance(receipt, dict)
    receipt[field] = value

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(feature)), require_codex_model_routing=True
    )

    assert any(error.endswith(expected_suffix) for error in errors)


def test_requires_singular_delegation_and_model_receipts() -> None:
    """Reject list-shaped receipts because each feature has one launch binding."""

    feature = _feature()
    feature["delegation_receipt"] = []
    feature["model_routing_receipt"] = []

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(feature)), require_codex_model_routing=True
    )

    assert _launch_errors(errors) == [
        "Epic checkpoint feature 'child-a' launch binding.delegation_receipt "
        "must be an object.",
        "Epic checkpoint feature 'child-a' launch binding.model_routing_receipt "
        "must be an object.",
    ]


def test_requires_unique_branch_and_delegation_id() -> None:
    """Reject reuse of a branch or delegation identifier across launched features."""

    first = _feature()
    second = _feature(102, "child-b")
    second["branch_name"] = first["branch_name"]
    first_delegation = first["delegation_receipt"]
    second_delegation = second["delegation_receipt"]
    second_model = second["model_routing_receipt"]
    assert isinstance(first_delegation, dict)
    assert isinstance(second_delegation, dict)
    assert isinstance(second_model, dict)
    second_delegation["delegation_id"] = first_delegation["delegation_id"]
    second_model["delegation_id"] = first_delegation["delegation_id"]

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(first, second)), require_codex_model_routing=True
    )

    assert (
        "Epic checkpoint feature 'child-b' launch binding.branch_name must be "
        "a non-empty unique string." in errors
    )
    assert (
        "Epic checkpoint feature 'child-b' launch binding.delegation_receipt."
        "delegation_id must be a non-empty unique string." in errors
    )


@pytest.mark.parametrize("maximum", [0, 9, True])
def test_cross_checks_max_parallel_features(maximum: object) -> None:
    """Retain the bounded one-through-eight concurrency contract under the gate."""

    state = _state(_feature())
    state["max_parallel_features"] = maximum

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_codex_model_routing=True
    )

    assert (
        "Epic checkpoint max_parallel_features must be an integer from 1 through 8."
        in errors
    )


def test_accepts_canonical_windows_worktree_and_absolute_artifacts() -> None:
    """Accept launcher-produced absolute Windows paths after normalization checks."""

    feature = _feature()
    feature["worktree_path"] = r"C:\repo\worktrees\child-a"
    feature["launch_receipt_path"] = (
        r"C:\repo\artifacts\orchestration\epic-child-launches\wave-0\child-a.receipt.json"
    )
    feature["launch_status_path"] = (
        r"C:\repo\artifacts\orchestration\epic-child-launches\wave-0\wave.status.json"
    )

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state(feature)), require_codex_model_routing=True
    )

    assert errors == []
