"""Tests for the additive PR-creation-readiness branch of the orchestrator-state
validator.

These tests cover ``validate_orchestrator_state_pr_creation_readiness`` and the
``require_pr_creation_ready`` keyword on ``validate_orchestrator_state_text``: a
pre-PR-creation readiness contract that is deliberately narrower than
``require_complete``. It checks only that upstream steps 5-8 are not
pending/blocked, ``blocked_reason`` is clear, and the two override lists are
empty when present, without requiring ``ci_gate``, ``pr_gate``, or routing-
contract delegation receipts. Kept in a sibling module (not an extension of
`test_validate_orchestrator_state.py`) to respect the repository's 500-line
file-size cap on both the production and test surfaces.
"""

from __future__ import annotations

import json
from typing import cast

import scripts.dev_tools.validate_orchestrator_state as state_validator


def build_pr_creation_ready_state() -> dict[str, object]:
    """Return a checkpoint payload that satisfies PR-creation readiness.

    Purpose:
        Provide a reusable, large-route checkpoint payload representing a
        real, in-flight session immediately before the first `gh pr create`
        of a branch: upstream steps 5-8 are all non-pending/non-blocked,
        `blocked_reason` is clear, and no `ci_gate`, `pr_gate`, or `pr-author`
        delegation receipt exists yet, because those cannot exist before PR
        creation has already succeeded.

    Args:
        None.

    Returns:
        dict[str, object]: A checkpoint payload that passes
        `require_pr_creation_ready=True` and satisfies all unconditional
        `REQUIRED_STATE_KEYS` checks.

    Raises:
        None.

    Side Effects:
        None.
    """

    return {
        "objective": "obj",
        "change_budget_estimate": "large",
        "path_selected": "large",
        "promotion-type": "feature",
        "short-name": "short",
        "relativeFile": "docs/features/potential/x.md",
        "long-name": "feature-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/feature-1",
        "work-mode": "full-feature",
        "plan-path": "docs/features/active/feature-1/plan.md",
        "completed_steps": [],
        "next_step": "pr_creation",
        "last_updated": "2026-07-02T22:05:00Z",
        "step5_status": "completed",
        "step6_status": "verified",
        "step7_status": "completed",
        "step8_status": "not-applicable",
        "step9_status": "pending",
        "step10_status": "not-applicable",
        "delegation_receipts": [
            {
                "step": "7",
                "agent_name": "atomic-planner",
                "agent_id": "a1",
                "skill_source": "orchestrator-workflow",
                "started_at": "2026-04-07T09:00:00-04:00",
                "completed_at": "2026-04-07T09:05:00-04:00",
                "result_signal": "PREFLIGHT: ALL CLEAR",
                "artifact_paths": ["docs/features/active/feature-1/plan.md"],
            }
        ],
        "blocked_reason": "none",
    }


def test_pr_creation_readiness_accepts_valid_pre_pr_checkpoint() -> None:
    """A ready pre-PR checkpoint produces no errors under the new flag."""

    state = build_pr_creation_ready_state()

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert errors == []


def test_pr_creation_readiness_accepts_explicit_empty_override_lists() -> None:
    """Explicit empty override lists remain valid under the new flag."""

    state = build_pr_creation_ready_state()
    state["local_execution_overrides"] = []
    state["delegation_bypasses"] = []

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert errors == []


def test_pr_creation_readiness_rejects_pending_step6() -> None:
    """A pending step6_status is rejected by the readiness check."""

    state = build_pr_creation_ready_state()
    state["step6_status"] = "pending"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert any("step6_status is pending" in error for error in errors)


def test_pr_creation_readiness_rejects_blocked_step8() -> None:
    """A blocked step8_status is rejected by the readiness check."""

    state = build_pr_creation_ready_state()
    state["step8_status"] = "blocked"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert any("step8_status is blocked" in error for error in errors)


def test_pr_creation_readiness_rejects_step6_blocked_remediation_loop_limit() -> None:
    """A step6_status of `blocked_remediation_loop_limit` is rejected.

    Purpose:
        Cover the additive readiness blocklist entry: the third-remediation-pass
        halt value documented for `step6_status` is valid in plain mode on its
        owning key but must block the first `gh pr create` of a branch.

    Args:
        None.

    Returns:
        None: Assertions verify the readiness error names the key and value.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_pr_creation_ready_state()
    state["step6_status"] = "blocked_remediation_loop_limit"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert (
        "Checkpoint PR-creation readiness validation failed: step6_status is "
        "blocked_remediation_loop_limit." in errors
    )


def test_pr_creation_readiness_rejects_non_none_blocked_reason() -> None:
    """A non-`none` blocked_reason is rejected by the readiness check."""

    state = build_pr_creation_ready_state()
    state["blocked_reason"] = "delegate_no_receipt"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert any("blocked_reason is not" in error for error in errors)


def test_pr_creation_readiness_rejects_nonempty_local_execution_overrides() -> None:
    """A non-empty local_execution_overrides list is rejected."""

    state = build_pr_creation_ready_state()
    state["local_execution_overrides"] = ["x"]

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert any(
        "local_execution_overrides must be an empty list" in error for error in errors
    )


def test_pr_creation_readiness_rejects_nonempty_delegation_bypasses() -> None:
    """A non-empty delegation_bypasses list is rejected."""

    state = build_pr_creation_ready_state()
    state["delegation_bypasses"] = ["y"]

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert any("delegation_bypasses must be an empty list" in error for error in errors)


def test_pr_creation_readiness_still_requires_top_level_keys() -> None:
    """The unconditional REQUIRED_STATE_KEYS check still applies under the new flag."""

    state = build_pr_creation_ready_state()
    del state["relativeFile"]

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert any(
        "Checkpoint missing required key: relativeFile" in error for error in errors
    )


def test_pr_creation_readiness_excludes_ci_pr_gate_and_pr_author_receipt() -> None:
    """The readiness check never demands ci_gate, pr_gate, or a pr-author receipt.

    Purpose:
        Confirm the pass-case checkpoint (no `ci_gate`, no `pr_gate`, and no
        `pr-author` delegation receipt) validates cleanly under
        `require_pr_creation_ready=True`, and that no returned error string
        references any of those three completion-only concepts.

    Args:
        None.

    Returns:
        None: Assertions verify an empty error list and the absence of
        completion-only error text.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_pr_creation_ready_state()
    assert "ci_gate" not in state
    assert "pr_gate" not in state
    receipts = cast("list[dict[str, object]]", state["delegation_receipts"])
    assert all(receipt.get("agent_name") != "pr-author" for receipt in receipts)

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_pr_creation_ready=True
    )

    assert errors == []
    assert not any("ci_gate" in error for error in errors)
    assert not any("pr_gate" in error for error in errors)
    assert not any("pr-author" in error for error in errors)
