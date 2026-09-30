"""Regression tests for adopting a pre-existing GitHub issue at completion.

A checkpoint whose GitHub issue already existed before orchestration never
calls ``potential_to_issue``, so it can never record a successful receipt for
that tool. These tests pin that a valid ``issue_adoption`` record waives that
receipt requirement at completion, that an invalid record fails closed with its
error ordered before the ``local_execution_overrides`` error, that the declared
``required_mcp_tools`` equality check is unchanged, and that a checkpoint
without the key validates exactly as before.
"""

from __future__ import annotations

import json
from typing import Any, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_routing import (
    load_routing_matrix,
    validate_routing_contract,
)

POTENTIAL_TO_ISSUE = "potential_to_issue"
MISSING_POTENTIAL_TO_ISSUE_RECEIPT = (
    "Checkpoint missing successful MCP receipt: potential_to_issue."
)
UNKNOWN_ORIGIN_ERROR = (
    "Checkpoint issue_adoption.origin must be one of transferred, "
    "filed_before_orchestration, epic_decomposition."
)
LOCAL_EXECUTION_OVERRIDES_ERROR = (
    "Checkpoint local_execution_overrides must be empty at completion."
)
LARGE_ROUTE_TOOLS_EQUALITY_ERROR = (
    "Checkpoint required_mcp_tools must match routing matrix for route large."
)


def _large_route() -> dict[str, Any]:
    """Return the large-route entry from the repository routing matrix."""

    matrix = load_routing_matrix()
    routes = cast("dict[str, Any]", matrix["routes"])
    return cast("dict[str, Any]", routes["large"])


def _build_adopted_large_state() -> dict[str, Any]:
    """Return a completion-safe large checkpoint lacking a potential_to_issue receipt.

    The state mirrors the completion-safe large checkpoint used by the routing
    contract suite, with the ``potential_to_issue`` entry removed from both
    ``mcp_call_receipts`` and ``lifecycle_operations``, as it is for a
    checkpoint whose issue already existed before orchestration.
    """

    route = _large_route()
    required_agents = cast("list[str]", route["required_agents"])
    required_skills = cast("list[str]", route["required_skills"])
    required_mcp_tools = cast("list[str]", route["required_mcp_tools"])
    received_tools = [tool for tool in required_mcp_tools if tool != POTENTIAL_TO_ISSUE]
    return {
        "objective": "obj",
        "change_budget_estimate": "large",
        "route_id": "large",
        "path_selected": "large",
        "promotion-type": "feature",
        "short-name": "short",
        "relativeFile": "docs/features/potential/x.md",
        "long-name": "feature-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/feature-1",
        "work-mode": "full-feature",
        "plan-path": "docs/features/active/feature-1/plan.md",
        "completed_steps": ["S7", "S8", "S9"],
        "next_step": "done",
        "last_updated": "2026-04-07T10:00:00-04:00",
        "step5_status": "not-applicable",
        "step6_status": "not-applicable",
        "step7_status": "verified",
        "step8_status": "verified",
        "step9_status": "verified",
        "step10_status": "not-applicable",
        "pr_gate": {
            "pr_number": 1,
            "pr_url": "https://github.com/drmoisan/drm-copilot/pull/1",
            "head_branch": "feature-1",
            "head_sha": "current-head-sha",
        },
        "ci_gate": {
            "conclusion": "success",
            "head_sha": "current-head-sha",
            "verified_at": "2026-04-07T10:00:00Z",
        },
        "required_agents": list(required_agents),
        "required_skills": list(required_skills),
        "required_mcp_tools": list(required_mcp_tools),
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
            for index, agent in enumerate(required_agents, start=1)
        ],
        "skill_receipts": [
            {
                "skill": skill,
                "required": True,
                "acknowledged_at_phase": "completion",
                "evidence": f"artifact:{skill}",
            }
            for skill in required_skills
        ],
        "mcp_call_receipts": [
            {
                "tool": tool,
                "ok": True,
                "evidence": f"mcp_call:{tool}",
            }
            for tool in received_tools
        ],
        "local_execution_overrides": [],
        "delegation_bypasses": [],
        "lifecycle_operations": [
            {"name": tool, "surface": "mcp"} for tool in received_tools
        ],
        "blocked_reason": "none",
    }


def _valid_issue_adoption() -> dict[str, Any]:
    """Return a valid issue_adoption record for issue 1 waiving potential_to_issue."""

    return {
        "issue_num": "1",
        "issue_url": "https://github.com/drmoisan/drm-copilot/issues/1",
        "origin": "transferred",
        "verified_via": "gh_issue_view",
        "verified_at": "2026-09-29T15:15:00Z",
        "evidence": "gh issue view 509 --json number,state,url: number 509, state OPEN",
        "waived_tools": [POTENTIAL_TO_ISSUE],
    }


def test_large_checkpoint_with_valid_issue_adoption_completes_without_potential_to_issue_receipt() -> (
    None
):
    """A valid adoption waives the potential_to_issue receipt at completion.

    Expected outcome: the full validator with ``require_complete`` returns no
    errors for a large checkpoint that has no potential_to_issue receipt.
    """

    # Arrange
    state = _build_adopted_large_state()
    state["issue_adoption"] = _valid_issue_adoption()

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    # Assert
    assert errors == [], f"expected no completion errors, observed {errors}"


def test_adoption_error_fails_closed_and_orders_errors_before_local_execution_overrides() -> (
    None
):
    """An invalid adoption waives nothing and its error precedes the overrides error.

    Expected outcome: the missing-receipt error, then the unknown-origin
    adoption error, then the local_execution_overrides error, in that order.
    """

    # Arrange
    state = _build_adopted_large_state()
    adoption = _valid_issue_adoption()
    adoption["origin"] = "imported"
    state["issue_adoption"] = adoption
    state["local_execution_overrides"] = ["manual-step"]

    # Act
    errors = validate_routing_contract(state)

    # Assert
    assert errors == [
        MISSING_POTENTIAL_TO_ISSUE_RECEIPT,
        UNKNOWN_ORIGIN_ERROR,
        LOCAL_EXECUTION_OVERRIDES_ERROR,
    ], f"unexpected routing errors: {errors}"


def test_declared_required_mcp_tools_equality_is_unchanged_under_adoption() -> None:
    """A valid adoption does not relax the declared required_mcp_tools equality.

    Expected outcome: only the existing equality error for route large, because
    the adoption waives the missing potential_to_issue receipt.
    """

    # Arrange
    state = _build_adopted_large_state()
    state["issue_adoption"] = _valid_issue_adoption()
    declared = cast("list[str]", state["required_mcp_tools"])
    state["required_mcp_tools"] = [
        tool for tool in declared if tool != POTENTIAL_TO_ISSUE
    ]

    # Act
    errors = validate_routing_contract(state)

    # Assert
    assert errors == [
        LARGE_ROUTE_TOOLS_EQUALITY_ERROR
    ], f"unexpected routing errors: {errors}"


def test_absent_issue_adoption_keeps_routing_contract_output_unchanged() -> None:
    """Without the key, the missing potential_to_issue receipt is still reported.

    Expected outcome: exactly the existing missing-receipt error.
    """

    # Arrange
    state = _build_adopted_large_state()

    # Act
    errors = validate_routing_contract(state)

    # Assert
    assert errors == [
        MISSING_POTENTIAL_TO_ISSUE_RECEIPT
    ], f"unexpected routing errors: {errors}"
