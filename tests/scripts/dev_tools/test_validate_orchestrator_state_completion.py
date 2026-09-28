"""Completion and strict-routing tests for orchestrator-state validation."""

from __future__ import annotations

import json

import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.validate_orchestrator_state_test_support import (
    build_complete_small_state,
    build_valid_orchestrator_state,
)


def test_require_complete_rejects_missing_ci_gate() -> None:
    """Reject a PR-gated completion that omits its CI gate."""

    state = build_valid_orchestrator_state()
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/harden-orchestrate-skill-232",
        "head_sha": "current-head-sha",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("ci_gate" in error for error in errors)


def test_require_complete_rejects_failed_ci_gate() -> None:
    """Reject a PR-gated completion whose CI conclusion is failure."""

    state = build_valid_orchestrator_state()
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/harden-orchestrate-skill-232",
        "head_sha": "current-head-sha",
    }
    state["ci_gate"] = {
        "conclusion": "failure",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("ci_gate.conclusion" in error for error in errors)


def test_require_complete_rejects_stale_ci_head_sha_for_pr_gate_route() -> None:
    """Reject completion when the CI and PR head SHAs differ."""

    state = build_valid_orchestrator_state()
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/any-branch",
        "head_sha": "current-head-sha",
    }
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "stale-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any(
        "ci_gate.head_sha" in error and "pr_gate.head_sha" in error for error in errors
    )


def test_strict_route_membership_rejects_unknown_route() -> None:
    """Reject an unknown route when strict route membership is enabled."""

    state = build_valid_orchestrator_state()
    state["path_selected"] = "direct_powershell_engineer_remediation"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), strict_route_membership=True
    )

    assert any(
        "is not a routing-matrix route: direct_powershell_engineer_remediation" in error
        for error in errors
    )


def test_non_strict_route_membership_allows_missing_route_id() -> None:
    """Allow a checkpoint without route identity under the default gate."""

    state = build_valid_orchestrator_state()
    del state["path_selected"]

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert not any("must select a route" in error for error in errors)
    assert not any("routing-matrix route" in error for error in errors)


def test_require_complete_accepts_small_route_with_all_mandatory_phases() -> None:
    """Accept a small route that records every mandatory phase."""

    state = build_complete_small_state()

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("mandatory phase" in error for error in errors)


def test_require_complete_rejects_small_route_missing_promotion_phase() -> None:
    """Reject a small route that omits its promotion phase."""

    state = build_complete_small_state()
    state["completed_steps"] = ["S4_atomic_planning"]

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("missing mandatory phase S3_promotion" in error for error in errors)
