"""Tests for the preparation route and the route-driven completion CI gate.

The preparation route lets an epic-planner-delegated orchestrator run stop
cleanly after preflight clearance: it opens no PR and runs no CI, so the
routing matrix marks it `requires_ci_gate: false` and the completion gate must
not demand a `ci_gate` object. Every other route keeps the historical
unconditional CI-gate requirement because the flag is absent there.
"""

from __future__ import annotations

import json
from typing import Any, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_routing import (
    load_routing_matrix,
    route_requires_ci_gate,
)


def _route(route_id: str) -> dict[str, Any]:
    """Return one route entry from the repository routing matrix.

    Args:
        route_id (str): The routing-matrix route key to read.

    Returns:
        dict[str, Any]: The parsed route entry.
    """

    matrix = load_routing_matrix()
    routes = cast("dict[str, Any]", matrix["routes"])
    return cast("dict[str, Any]", routes[route_id])


def _build_complete_state(route_id: str) -> dict[str, object]:
    """Return a completion-safe checkpoint for the given route.

    The checkpoint carries every required top-level key, the route's required
    agent/skill/MCP receipt evidence, and the mandatory canonical phases. PR
    and CI gate objects are included only for the large route; the preparation
    route intentionally omits both because preparation never opens a PR.

    Args:
        route_id (str): One of "large" or "preparation".

    Returns:
        dict[str, object]: A mutable checkpoint dictionary for the tests.
    """

    route = _route(route_id)
    required_agents = cast("list[str]", route["required_agents"])
    required_skills = cast("list[str]", route["required_skills"])
    required_mcp_tools = cast("list[str]", route["required_mcp_tools"])
    state: dict[str, object] = {
        "objective": "obj",
        "change_budget_estimate": route_id,
        "route_id": route_id,
        "path_selected": route_id,
        "promotion-type": "feature",
        "short-name": "short",
        "relativeFile": "docs/features/potential/x.md",
        "long-name": "feature-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/feature-1",
        "work-mode": "full-feature",
        "plan-path": "docs/features/active/feature-1/plan.md",
        "completed_steps": ["S3_promotion", "S4_atomic_planning"],
        "next_step": "S5_atomic_execution",
        "last_updated": "2026-07-10T10:00:00-04:00",
        "step5_status": "not-applicable",
        "step6_status": "not-applicable",
        "step7_status": "not-applicable",
        "step8_status": "not-applicable",
        "step9_status": "not-applicable",
        "step10_status": "not-applicable",
        "required_agents": required_agents,
        "required_skills": required_skills,
        "required_mcp_tools": required_mcp_tools,
        # Delegation receipts prove each routing-matrix agent handoff occurred.
        "delegation_receipts": [
            {
                "step": f"handoff-{index}",
                "agent_name": agent,
                "agent_id": f"{agent}-1",
                "skill_source": "orchestrate",
                "started_at": "2026-07-10T09:00:00-04:00",
                "completed_at": "2026-07-10T09:05:00-04:00",
                "result_signal": "COMPLETE",
                "artifact_paths": [f"artifacts/orchestration/{agent}.receipt.json"],
            }
            for index, agent in enumerate(required_agents, start=1)
        ],
        # Skill receipts prove each routing-matrix skill was acknowledged.
        "skill_receipts": [
            {
                "skill": skill,
                "required": True,
                "acknowledged_at_phase": "completion",
                "evidence": f"artifact:{skill}",
            }
            for skill in required_skills
        ],
        # MCP receipts prove each routing-matrix tool call succeeded.
        "mcp_call_receipts": [
            {
                "tool": tool,
                "ok": True,
                "evidence": f"mcp_call:{tool}",
            }
            for tool in required_mcp_tools
        ],
        "local_execution_overrides": [],
        "delegation_bypasses": [],
        # Lifecycle operations must be recorded against the MCP surface.
        "lifecycle_operations": [
            {"name": tool, "surface": "mcp"} for tool in required_mcp_tools
        ],
        "blocked_reason": "none",
    }
    # Only the large route requires PR/CI completion evidence; preparation
    # deliberately carries neither gate object.
    if route_id == "large":
        state["pr_gate"] = {
            "pr_number": 1,
            "pr_url": "https://github.com/drmoisan/drm-copilot/pull/1",
            "head_branch": "feature-1",
            "head_sha": "current-head-sha",
        }
        state["ci_gate"] = {
            "conclusion": "success",
            "head_sha": "current-head-sha",
            "verified_at": "2026-07-10T10:00:00Z",
        }
    return state


def _validate(state: dict[str, object]) -> list[str]:
    """Run completion validation against a serialized checkpoint.

    Args:
        state (dict[str, object]): The checkpoint dictionary to validate.

    Returns:
        list[str]: The validator's error strings.
    """

    return state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )


def test_route_requires_ci_gate_false_for_preparation_route() -> None:
    """The preparation route's explicit requires_ci_gate: false opts out."""

    assert route_requires_ci_gate({"route_id": "preparation"}) is False


def test_route_requires_ci_gate_true_when_flag_absent() -> None:
    """Routes without the flag keep the historical CI-gate requirement."""

    assert route_requires_ci_gate({"route_id": "large"}) is True
    assert route_requires_ci_gate({"route_id": "small"}) is True


def test_route_requires_ci_gate_true_for_missing_or_unknown_route() -> None:
    """A missing or unknown route id fails closed to CI-gate-required."""

    assert route_requires_ci_gate({}) is True
    assert route_requires_ci_gate({"route_id": "fabricated-route"}) is True


def test_route_requires_ci_gate_true_for_malformed_matrix() -> None:
    """A matrix without a routes object fails closed to CI-gate-required."""

    malformed: dict[str, Any] = {"routes": []}
    assert (
        route_requires_ci_gate({"route_id": "preparation"}, routing_matrix=malformed)
        is True
    )


def test_route_requires_ci_gate_true_for_non_boolean_flag() -> None:
    """Only the literal boolean False opts a route out of the CI gate."""

    matrix: dict[str, Any] = {"routes": {"preparation": {"requires_ci_gate": "false"}}}
    assert (
        route_requires_ci_gate({"route_id": "preparation"}, routing_matrix=matrix)
        is True
    )


def test_complete_preparation_state_passes_without_ci_gate() -> None:
    """Accept a preparation checkpoint that carries no pr_gate or ci_gate."""

    assert _validate(_build_complete_state("preparation")) == []


def test_large_route_still_requires_ci_gate_at_completion() -> None:
    """Reject a large-route completion checkpoint that omits ci_gate."""

    state = _build_complete_state("large")
    del state["ci_gate"]

    errors = _validate(state)

    assert any("ci_gate" in error for error in errors)


def test_preparation_route_missing_mandatory_phase_rejected() -> None:
    """Reject preparation completion when S3_promotion was never recorded."""

    state = _build_complete_state("preparation")
    state["completed_steps"] = ["S4_atomic_planning"]

    errors = _validate(state)

    assert any("missing mandatory phase S3_promotion" in error for error in errors)


def test_preparation_route_missing_agent_receipt_rejected() -> None:
    """Reject preparation completion when a required agent has no receipt."""

    state = _build_complete_state("preparation")
    receipts = cast("list[dict[str, object]]", state["delegation_receipts"])
    # Drop the preflight (atomic-executor) receipt to violate the contract.
    state["delegation_receipts"] = [
        receipt for receipt in receipts if receipt["agent_name"] != "atomic-executor"
    ]

    errors = _validate(state)

    assert any(
        "missing required agent receipt: atomic-executor" in error for error in errors
    )


def test_preparation_route_pending_step_status_rejected() -> None:
    """Reject preparation completion while a step status is still pending."""

    state = _build_complete_state("preparation")
    state["step5_status"] = "pending"

    errors = _validate(state)

    assert any("step5_status is pending" in error for error in errors)


def test_preparation_route_requires_atomic_execution_resume_pointer() -> None:
    """Reject preparation state that does not stop at atomic execution."""

    state = _build_complete_state("preparation")
    state["next_step"] = "complete"

    errors = _validate(state)

    assert any("next_step must be 'S5_atomic_execution'" in error for error in errors)


def test_preparation_route_requires_exact_out_of_scope_statuses() -> None:
    """Reject completion-like statuses for work deferred to epic execution."""

    state = _build_complete_state("preparation")
    state["step8_status"] = "completed"

    errors = _validate(state)

    assert any("step8_status must be 'not-applicable'" in error for error in errors)
