"""Tests for the per-step-key additive step-status vocabulary.

These tests cover the additive extra-status mechanism layered on the unchanged
shared ``VALID_STEP_STATUS`` set: ``step9_status`` additionally accepts
``passed``, ``failed_remediation_required``, and ``blocked_ci_loop_limit``;
``step6_status`` additionally accepts ``blocked_remediation_loop_limit``. The
same values written to any other ``stepN_status`` key remain rejected with the
existing message form ``Checkpoint has invalid <key>: <value>``. The
``require_complete`` gate additionally rejects the three failure values while
``passed`` never blocks completion.

Kept in a sibling module (not an extension of
`test_validate_orchestrator_state.py`, which is already 735 lines) to respect
the repository's 500-line file-size cap on the test surface.
"""

from __future__ import annotations

import json
from typing import Any, cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_routing import load_routing_matrix
from tests.scripts.dev_tools.test_validate_orchestrator_state_remediation_loop import (
    build_valid_orchestrator_state,
)

# The full step-status key surface the validator checks, mirrored here so the
# per-key rejection matrix can enumerate every non-owning key.
ALL_STEP_STATUS_KEYS = (
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
)
# The documented per-key additive vocabulary under test.
STEP9_EXTRA_STATUSES = (
    "passed",
    "failed_remediation_required",
    "blocked_ci_loop_limit",
)
STEP6_EXTRA_STATUSES = ("blocked_remediation_loop_limit",)
# (owning key, extra value) pairs used to build the acceptance and the
# non-owning-key rejection matrices.
OWNED_EXTRA_STATUSES = tuple(
    [("step9_status", value) for value in STEP9_EXTRA_STATUSES]
    + [("step6_status", value) for value in STEP6_EXTRA_STATUSES]
)
# Every (owning key, value, non-owning key) triple: the same value on a key that
# does not own it must still be rejected.
NON_OWNING_KEY_MATRIX = tuple(
    (owner, value, other)
    for owner, value in OWNED_EXTRA_STATUSES
    for other in ALL_STEP_STATUS_KEYS
    if other != owner
)


def build_complete_small_state() -> dict[str, object]:
    """Return a small-route checkpoint that satisfies the completion gate.

    Purpose:
        Provide a checkpoint that produces zero errors under
        ``require_complete=True`` so a single mutated step status is the only
        possible source of a completion error in each test below.

    Args:
        None.

    Returns:
        dict[str, object]: A completion-safe small-route checkpoint payload
        carrying the routing, phase, PR-gate, and CI-gate evidence the
        completion gate requires.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk.
    """

    matrix = load_routing_matrix()
    routes = cast("dict[str, Any]", matrix["routes"])
    small = cast("dict[str, Any]", routes["small"])
    agents = cast("list[str]", small["required_agents"])
    skills = cast("list[str]", small["required_skills"])
    tools = cast("list[str]", small["required_mcp_tools"])
    return {
        "objective": "obj",
        "change_budget_estimate": "small",
        "route_id": "small",
        "path_selected": "small",
        "promotion-type": "feature",
        "short-name": "short",
        "relativeFile": "docs/features/potential/x.md",
        "long-name": "feature-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/feature-1",
        "work-mode": "minor-audit",
        "plan-path": "docs/features/active/feature-1/plan.md",
        "completed_steps": ["S3_promotion", "S4_atomic_planning"],
        "next_step": "done",
        "last_updated": "2026-04-07T10:00:00-04:00",
        "step5_status": "not-applicable",
        "step6_status": "verified",
        "step7_status": "verified",
        "step8_status": "verified",
        "step9_status": "verified",
        "step10_status": "not-applicable",
        "required_agents": agents,
        "required_skills": skills,
        "required_mcp_tools": tools,
        "delegation_receipts": [
            {
                "step": f"handoff-{index}",
                "agent_name": agent,
                "agent_id": f"{agent}-1",
                "skill_source": "orchestrate",
                "started_at": "2026-04-07T09:00:00-04:00",
                "completed_at": "2026-04-07T09:05:00-04:00",
                "result_signal": "COMPLETE",
                "artifact_paths": [f"artifacts/orchestration/{agent}.receipt.json"],
            }
            for index, agent in enumerate(agents, start=1)
        ],
        "skill_receipts": [
            {
                "skill": skill,
                "required": True,
                "acknowledged_at_phase": "completion",
                "evidence": f"artifact:{skill}",
            }
            for skill in skills
        ],
        "mcp_call_receipts": [
            {"tool": tool, "ok": True, "evidence": f"mcp_call:{tool}"} for tool in tools
        ],
        "local_execution_overrides": [],
        "delegation_bypasses": [],
        "lifecycle_operations": [{"name": tool, "surface": "mcp"} for tool in tools],
        "pr_gate": {
            "pr_number": 1,
            "pr_url": "https://github.com/drmoisan/drm-copilot/pull/1",
            "head_sha": "abc123",
            "base_branch": "main",
            "verified_at": "2026-04-07T10:00:00-04:00",
        },
        "ci_gate": {
            "conclusion": "success",
            "head_sha": "abc123",
            "verified_at": "2026-04-07T10:00:00-04:00",
        },
        "blocked_reason": "none",
    }


@pytest.mark.parametrize("value", STEP9_EXTRA_STATUSES)
def test_plain_validation_accepts_step9_extra_status(value: str) -> None:
    """Plain validation accepts each documented extra ``step9_status`` value."""

    # Arrange: an otherwise-valid checkpoint carrying the extra S9 status.
    state = build_valid_orchestrator_state()
    state["step9_status"] = value

    # Act: run plain validation.
    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    # Assert: the value is accepted and no step-status error is produced.
    assert errors == []


def test_plain_validation_accepts_step6_blocked_remediation_loop_limit() -> None:
    """Plain validation accepts ``step6_status: blocked_remediation_loop_limit``."""

    # Arrange: an otherwise-valid checkpoint carrying the extra S6 status.
    state = build_valid_orchestrator_state()
    state["step6_status"] = "blocked_remediation_loop_limit"

    # Act: run plain validation.
    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    # Assert: the value is accepted on its owning key.
    assert errors == []


@pytest.mark.parametrize(("owner", "value", "other_key"), NON_OWNING_KEY_MATRIX)
def test_extra_status_rejected_on_non_owning_key(
    owner: str, value: str, other_key: str
) -> None:
    """A per-key extra value on a key that does not own it is still rejected."""

    # Arrange: write the extra value to a step key that does not own it.
    assert other_key != owner
    state = build_valid_orchestrator_state()
    state[other_key] = value

    # Act: run plain validation.
    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    # Assert: the existing message form reports the non-owning key rejection.
    assert errors == [f"Checkpoint has invalid {other_key}: {value}"]


@pytest.mark.parametrize(
    ("key", "value"),
    [
        ("step9_status", "failed_remediation_required"),
        ("step9_status", "blocked_ci_loop_limit"),
        ("step6_status", "blocked_remediation_loop_limit"),
    ],
)
def test_require_complete_rejects_failure_step_status(key: str, value: str) -> None:
    """The completion gate rejects each documented failure step status."""

    # Arrange: a completion-safe checkpoint carrying one failure step status.
    state = build_complete_small_state()
    state[key] = value

    # Act: run the completion gate.
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert: the completion-validation message names the key and value.
    assert f"Checkpoint completion validation failed: {key} is {value}." in errors


def test_require_complete_accepts_step9_passed() -> None:
    """``step9_status: passed`` never blocks an otherwise-complete checkpoint."""

    # Arrange: a completion-safe checkpoint recording the documented S9 success.
    state = build_complete_small_state()
    state["step9_status"] = "passed"

    # Act: run the completion gate.
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert: the checkpoint completes cleanly with no step-status error.
    assert errors == []


def test_epic_mode_checkpoint_with_step9_passed_validates() -> None:
    """An epic-mode checkpoint recording ``step9_status: passed`` validates.

    Purpose:
        Cover the regression scenario behind the authoritative-side ruling:
        `.claude/hooks/enforce-epic-merge-gate.ps1` requires a child checkpoint
        whose `step9_status` is `passed`, so such a checkpoint must survive
        plain validation with no edit to that hook.

    Args:
        None.

    Returns:
        None: Assertions verify the checkpoint validates cleanly.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: an epic-mode checkpoint recording the documented S9 success.
    state = build_valid_orchestrator_state()
    state["epic_mode"] = True
    state["step9_status"] = "passed"

    # Act: run plain validation.
    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    # Assert: the epic-merge-gate scenario is representable.
    assert errors == []
