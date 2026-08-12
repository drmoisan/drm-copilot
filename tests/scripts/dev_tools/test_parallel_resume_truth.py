"""In-memory live-truth reconciliation tests for parallel child resume."""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)
from tests.scripts.dev_tools.test_validate_parallel_orchestrator_state import (
    build_valid_parallel_state,
)

HEAD_A = "a" * 40
HEAD_B = "b" * 40
SPEC_A = "c" * 64
SPEC_B = "d" * 64
CHECKPOINT_A = "e" * 64
CHECKPOINT_B = "f" * 64


def _items(state: dict[str, object]) -> list[dict[str, object]]:
    """Return mutable object-shaped checkpoint items."""

    value = state["items"]
    if not isinstance(value, list):
        raise TypeError("fixture items must be a list")
    return cast("list[dict[str, object]]", value)


def _bind_item(
    item: dict[str, object],
    *,
    batch: int,
    head: str,
    spec_hash: str,
    checkpoint_hash: str,
) -> None:
    """Attach one distinct persisted resume identity to an item."""

    key = cast("int", item["issue_num"])
    branch = f"feature/parallel-item-{key}"
    worktree = f"C:/worktrees/parallel-item-{key}"
    item.update(
        {
            "state": "in_flight" if batch == 0 else "scheduled",
            "merge_status": "ci_green" if batch == 0 else "not_started",
            "cohort": 0,
            "batch": batch,
            "repository": "owner/repository",
            "origin_main_head": HEAD_A,
            "worktree_path": worktree,
            "branch_name": branch,
            "checked_head": head,
            "launch_id": f"parallel-{key}",
            "spec_sha256": spec_hash,
            "checkpoint_sha256": checkpoint_hash,
            "pr_number": key,
            "pr_base_branch": "main",
            "pr_head_branch": branch,
            "pr_head_sha": head,
            "pr_state": "OPEN",
            "checks_head_sha": head,
            "checks_conclusion": "success",
            "authority_receipt_path": (
                f"artifacts/orchestration/parallel/{key}-authority.json"
            ),
            "delegation_receipt_path": (
                f"artifacts/orchestration/parallel/{key}-delegation.json"
            ),
            "topology_receipt_path": (
                f"artifacts/orchestration/parallel/{key}-topology.json"
            ),
            "model_routing_receipt_path": (
                f"artifacts/orchestration/parallel/{key}-model-routing.json"
            ),
            "deployment_agent": "orchestrator-c3-elevated",
            "model": "gpt-5.6-sol",
            "model_reasoning_effort": "high",
            "permissions": "orchestrator-workspace",
            "child_status_path": f"artifacts/orchestration/parallel/{key}-status.json",
            "child_status_pid": 3210 + batch,
        }
    )


def _resume_state() -> dict[str, object]:
    """Build a valid resume-required checkpoint and matching live truth."""

    state = build_valid_parallel_state()
    first, second = _items(state)
    _bind_item(
        first,
        batch=0,
        head=HEAD_A,
        spec_hash=SPEC_A,
        checkpoint_hash=CHECKPOINT_A,
    )
    _bind_item(
        second,
        batch=1,
        head=HEAD_B,
        spec_hash=SPEC_B,
        checkpoint_hash=CHECKPOINT_B,
    )
    state["resume_required"] = True
    state["resume_truth"] = {
        "schema_version": 1,
        "selected_issue_num": first["issue_num"],
        "repository": first["repository"],
        "origin_main_head": first["origin_main_head"],
        "worktree_path": first["worktree_path"],
        "branch_name": first["branch_name"],
        "worktree_head": first["checked_head"],
        "pr_number": first["pr_number"],
        "pr_base_branch": first["pr_base_branch"],
        "pr_head_branch": first["pr_head_branch"],
        "pr_head_sha": first["pr_head_sha"],
        "pr_state": first["pr_state"],
        "checks_head_sha": first["checks_head_sha"],
        "checks_conclusion": first["checks_conclusion"],
        "launch_id": first["launch_id"],
        "spec_sha256": first["spec_sha256"],
        "checkpoint_sha256": first["checkpoint_sha256"],
        "latest_mutation_sequence": 0,
        "recolor_generation": state["recolor_generation"],
        "drift_resolution_generation": state["recolor_generation"],
        "unresolved_drift": False,
        "authority_receipt_path": first["authority_receipt_path"],
        "delegation_receipt_path": first["delegation_receipt_path"],
        "topology_receipt_path": first["topology_receipt_path"],
        "model_routing_receipt_path": first["model_routing_receipt_path"],
        "deployment_agent": first["deployment_agent"],
        "model": first["model"],
        "model_reasoning_effort": first["model_reasoning_effort"],
        "permissions": first["permissions"],
        "child_status_path": first["child_status_path"],
        "child_status_launch_id": first["launch_id"],
        "child_status_pid": first["child_status_pid"],
        "live_process_pid": first["child_status_pid"],
        "live_process_running": False,
        "cached_child_status_state": "running",
        "should_relaunch": True,
    }
    return state


def _truth(state: dict[str, object]) -> dict[str, object]:
    """Return the mutable object-shaped live-truth record."""

    value = state["resume_truth"]
    if not isinstance(value, dict):
        raise TypeError("fixture resume_truth must be an object")
    return cast("dict[str, object]", value)


def _resume_errors(state: dict[str, object]) -> list[str]:
    """Return only stable parallel-resume diagnostics from the public validator."""

    errors = validate_parallel_orchestrator_state_text(json.dumps(state))
    return [error for error in errors if error.startswith("PARALLEL_RESUME_")]


def test_legacy_checkpoint_without_resume_gate_remains_compatible() -> None:
    """Resume reconciliation is additive until explicitly requested."""

    assert _resume_errors(build_valid_parallel_state()) == []


def test_matching_live_truth_is_accepted_without_mutating_input() -> None:
    """One fully bound interrupted item may resume deterministically."""

    state = _resume_state()
    snapshot = copy.deepcopy(state)

    assert _resume_errors(state) == []
    assert state == snapshot


@pytest.mark.parametrize(
    ("field", "value", "reason_code"),
    [
        ("origin_main_head", HEAD_B, "PARALLEL_RESUME_GIT_MISMATCH"),
        ("worktree_path", "C:/worktrees/wrong", "PARALLEL_RESUME_WORKTREE_MISMATCH"),
        ("pr_head_sha", HEAD_B, "PARALLEL_RESUME_GITHUB_MISMATCH"),
        ("spec_sha256", SPEC_B, "PARALLEL_RESUME_LAUNCH_MISMATCH"),
        ("latest_mutation_sequence", 1, "PARALLEL_RESUME_MUTATION_MISMATCH"),
        ("unresolved_drift", True, "PARALLEL_RESUME_DRIFT_UNRESOLVED"),
        ("model", "gpt-5.6-terra", "PARALLEL_RESUME_ROUTING_MISMATCH"),
        ("child_status_pid", 9999, "PARALLEL_RESUME_CHILD_STATUS_MISMATCH"),
        ("selected_issue_num", 445, "PARALLEL_RESUME_ORDER_MISMATCH"),
    ],
)
def test_each_authority_mismatch_has_a_stable_reason_code(
    field: str, value: object, reason_code: str
) -> None:
    """Every authoritative source fails with its assigned reason code."""

    state = _resume_state()
    _truth(state)[field] = value

    assert reason_code in _resume_errors(state)


@pytest.mark.parametrize(
    "field",
    ["launch_id", "worktree_path", "branch_name", "pr_number"],
)
def test_duplicate_item_identity_is_rejected(field: str) -> None:
    """Resume cannot duplicate an existing launch, worktree, branch, or PR."""

    state = _resume_state()
    first, second = _items(state)
    second[field] = first[field]

    assert "PARALLEL_RESUME_IDENTITY_DUPLICATE" in _resume_errors(state)


def test_missing_truth_and_fan_in_state_fail_closed() -> None:
    """An explicit resume gate requires standalone live truth."""

    state = _resume_state()
    del state["resume_truth"]
    assert _resume_errors(state) == ["PARALLEL_RESUME_TRUTH_REQUIRED"]

    state = _resume_state()
    _truth(state)["fan_in_pr"] = 9001
    assert "PARALLEL_RESUME_FAN_IN_FORBIDDEN" in _resume_errors(state)


def test_live_process_truth_overrides_cached_child_status() -> None:
    """Live process truth overrides a stale cached running status."""

    state = _resume_state()
    assert _truth(state)["cached_child_status_state"] == "running"
    assert _resume_errors(state) == []

    _truth(state)["live_process_running"] = True
    assert "PARALLEL_RESUME_PROCESS_RUNNING" in _resume_errors(state)
