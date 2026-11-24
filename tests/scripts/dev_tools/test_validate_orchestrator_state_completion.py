"""Completion and strict-routing tests for orchestrator-state validation."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.validate_orchestrator_state_test_support import (
    build_complete_small_state,
    build_valid_orchestrator_state,
)

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
CHILD_CI_CORPUS_DIR = (
    Path(__file__).resolve().parents[3]
    / "tests"
    / "fixtures"
    / "orchestrator_state_child_ci"
)
# Floor on the shared child CI corpus (issue #1233), matching the TypeScript and
# PowerShell readers, so an empty or partial glob cannot pass vacuously.
CHILD_CI_MINIMUM_CORPUS_COUNT = 13
CHILD_CI_CORPUS_PATHS = tuple(sorted(CHILD_CI_CORPUS_DIR.glob("*.json")))
CHILD_CI_REVIEWED_HEAD = "3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f"
CI_GATE_SHAPE_ERROR = (
    "Checkpoint completion validation failed: ci_gate must be an object with keys: "
    "conclusion, head_sha, verified_at."
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


def _load_child_ci_fixture(path: Path) -> dict[str, Any]:
    """Read one committed child CI corpus file.

    Args:
        path (Path): Absolute path to a corpus file.

    Returns:
        dict[str, Any]: The parsed fixture with `name`, `checkpoint`, and
        `expected_errors`.
    """
    return cast("dict[str, Any]", json.loads(path.read_text(encoding="utf-8")))


def _child_ci_gate_errors(errors: list[str]) -> list[str]:
    """Return the completion gate errors of either gate check.

    Args:
        errors (list[str]): Validator errors.

    Returns:
        list[str]: The errors that name `ci_gate`, `local_qc_gate`, or `child_ci`.
    """
    return [
        error
        for error in errors
        if "ci_gate" in error or "local_qc_gate" in error or "child_ci" in error
    ]


def _build_opted_out_complete_state() -> dict[str, object]:
    """Return a completion-safe small-route checkpoint that opts out of child CI.

    Returns:
        dict[str, object]: The checkpoint with the opt-out keys, a concurrent
        PASS review at the reviewed head, and a valid `local_qc_gate`.
    """
    state = build_complete_small_state()
    state.pop("ci_gate", None)
    state["epic_mode"] = True
    state["child_ci"] = "integration_only"
    state["review_mode"] = "concurrent"
    state["remediation_loop"] = {
        "review_outcomes": [{"verdict": "PASS", "head_sha": CHILD_CI_REVIEWED_HEAD}]
    }
    state["local_qc_gate"] = {
        "conclusion": "success",
        "head_sha": CHILD_CI_REVIEWED_HEAD,
        "evidence_path": (
            ".dev/active/feature-1/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md"
        ),
        "verified_at": "2026-11-24T05:00:00Z",
    }
    return state


@pytest.mark.parametrize(
    "path", CHILD_CI_CORPUS_PATHS, ids=[path.stem for path in CHILD_CI_CORPUS_PATHS]
)
def test_child_ci_corpus_matches_expected_errors(path: Path) -> None:
    """Assert the gate selection returns exactly the ordered corpus errors.

    Args:
        path (Path): One child CI corpus file.
    """
    # Arrange
    fixture = _load_child_ci_fixture(path)

    # Act
    observed = state_validator.validate_completion_gate_evidence(fixture["checkpoint"])

    # Assert
    assert fixture["name"] == path.stem
    assert observed == fixture["expected_errors"]


def test_child_ci_corpus_count_meets_floor() -> None:
    """Guard the parametrized child CI cases against an empty corpus glob."""

    # Arrange and act
    discovered = len(CHILD_CI_CORPUS_PATHS)

    # Assert
    assert discovered >= CHILD_CI_MINIMUM_CORPUS_COUNT


def test_require_complete_accepts_opted_out_child_without_ci_gate() -> None:
    """Accept an opted-out child at completion with no ci_gate error."""

    # Arrange
    state = _build_opted_out_complete_state()

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert
    assert _child_ci_gate_errors(errors) == []


def test_require_complete_reports_ci_gate_error_without_opt_out() -> None:
    """Report the existing ci_gate error once the opt-out key is removed."""

    # Arrange
    state = _build_opted_out_complete_state()
    state.pop("child_ci")

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert
    assert _child_ci_gate_errors(errors) == [CI_GATE_SHAPE_ERROR]
