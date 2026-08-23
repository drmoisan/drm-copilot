"""Completion and route-membership tests for orchestrator-state validation."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator
import tests.scripts.dev_tools.orchestrator_state_test_support as state_test_support
from tests.scripts.dev_tools.orchestrator_state_test_support import (
    build_valid_orchestrator_state,
)

if TYPE_CHECKING:
    from collections.abc import Callable

    import pytest

_build_complete_small_state = cast(
    "Callable[[], dict[str, object]]",
    vars(state_test_support)["_build_complete_small_state"],
)


def test_require_complete_rejects_pr_gate_required_route_without_pr_gate() -> None:
    """Reject completion when a pr-gate route omits PR evidence.

    Purpose:
        Cover the route-driven completion gate requiring `pr_gate` evidence for
        a route whose `requires_pr_gate` is True (the `large` route), with no
        issue-number special-casing.

    Args:
        None.

    Returns:
        None: Assertions verify that missing PR evidence is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    # Any issue number; route is `large`, which requires the PR gate.
    state["issue-num"] = "999"
    state["blocked_reason"] = "none"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("pr_gate" in error for error in errors)


def test_require_complete_skips_pr_gate_for_non_pr_gate_route() -> None:
    """Do not require PR evidence for a route without `requires_pr_gate`.

    Purpose:
        Cover the route-driven completion gate returning no `pr_gate` errors for
        the `small` route, which does not opt into the PR gate.

    Args:
        None.

    Returns:
        None: Assertions verify that no `pr_gate` error is produced.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["path_selected"] = "small"
    state["issue-num"] = "123"
    state["blocked_reason"] = "none"
    # Provide ci_gate so any ci-gate errors do not mask the pr_gate assertion.
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("pr_gate" in error for error in errors)


def test_require_complete_emits_no_issue_232_branch_error_for_any_issue() -> None:
    """Confirm no issue-232 branch-name error is produced for any issue number.

    Purpose:
        Cover the removal of the `ISSUE_232_BRANCH` head-branch check; a PR with
        an arbitrary head branch must not produce a branch-name completion error.

    Args:
        None.

    Returns:
        None: Assertions verify that no head_branch branch-name error is
        reported for an arbitrary branch.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["issue-num"] = "232"
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/any-arbitrary-branch",
        "head_sha": "current-head-sha",
    }
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("head_branch" in error for error in errors)


def test_require_complete_rejects_missing_ci_gate() -> None:
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
    """Reject completion when CI head_sha does not match PR head_sha.

    Purpose:
        Cover the preserved `ci_gate.head_sha` / `pr_gate.head_sha` match check
        for a route that requires the PR gate (the `large` route).

    Args:
        None.

    Returns:
        None: Assertions verify that the stale-head error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

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
    """Reject an unknown route when strict_route_membership is enabled.

    Purpose:
        Cover the opt-in strict route-membership gate appending an error for a
        checkpoint that selects a fabricated route.

    Args:
        None.

    Returns:
        None: Assertions verify the unknown-route error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["path_selected"] = "direct_powershell_engineer_remediation"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), strict_route_membership=True
    )

    assert any(
        "is not a routing-matrix route: direct_powershell_engineer_remediation" in error
        for error in errors
    )


def test_non_strict_route_membership_skips_validation(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Skip route-membership evaluation when strict mode is not requested."""

    calls = 0
    sentinel = "sentinel route-membership diagnostic"

    def recording_validator(_state: dict[str, object]) -> list[str]:
        nonlocal calls
        calls += 1
        return [sentinel]

    monkeypatch.setattr(
        state_validator, "validate_route_membership", recording_validator
    )

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(build_valid_orchestrator_state())
    )

    assert calls == 0
    assert sentinel not in errors


def test_strict_route_membership_invokes_validation_and_preserves_diagnostics(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Invoke strict route membership once and preserve diagnostic ordering."""

    calls = 0
    sentinels = [
        "first route-membership diagnostic",
        "second route-membership diagnostic",
    ]

    def recording_validator(_state: dict[str, object]) -> list[str]:
        nonlocal calls
        calls += 1
        return sentinels

    monkeypatch.setattr(
        state_validator, "validate_route_membership", recording_validator
    )

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(build_valid_orchestrator_state()), strict_route_membership=True
    )

    assert calls == 1
    assert errors == sentinels


def test_non_strict_route_membership_allows_missing_route_id() -> None:
    """Do not reject a checkpoint missing route_id/path_selected by default.

    Purpose:
        Cover the backward-compatibility default where route-membership errors
        are not appended for a checkpoint that selects no route.

    Args:
        None.

    Returns:
        None: Assertions verify no route-membership error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    del state["path_selected"]

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert not any("must select a route" in error for error in errors)
    assert not any("routing-matrix route" in error for error in errors)


def test_require_complete_accepts_small_route_with_all_mandatory_phases() -> None:
    """Accept a small-route checkpoint that records all mandatory phases.

    Purpose:
        Cover the phase-completeness pass case under require_complete for the
        `small` route whose mandatory phases are both present.

    Args:
        None.

    Returns:
        None: Assertions verify no phase-completeness error is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = _build_complete_small_state()

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("mandatory phase" in error for error in errors)


def test_require_complete_rejects_small_route_missing_promotion_phase() -> None:
    """Reject a small-route checkpoint missing the S3_promotion phase.

    Purpose:
        Cover the phase-completeness fail case under require_complete when the
        `small` route omits a mandatory phase.

    Args:
        None.

    Returns:
        None: Assertions verify the missing-phase error names S3_promotion.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = _build_complete_small_state()
    state["completed_steps"] = ["S4_atomic_planning"]

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("missing mandatory phase S3_promotion" in error for error in errors)
