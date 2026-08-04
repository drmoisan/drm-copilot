"""Tests for mandatory route, handoff, skill, and MCP checkpoint evidence."""

from __future__ import annotations

import json
from typing import Any, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_routing import (
    load_routing_matrix,
    validate_route_membership,
)


def _large_route() -> dict[str, Any]:
    """Return the large-route entry from the repository routing matrix."""

    matrix = load_routing_matrix()
    routes = cast("dict[str, Any]", matrix["routes"])
    return cast("dict[str, Any]", routes["large"])


def _build_complete_large_state() -> dict[str, object]:
    """Return a completion-safe large-path checkpoint for mutation."""

    route = _large_route()
    required_agents = cast("list[str]", route["required_agents"])
    required_skills = cast("list[str]", route["required_skills"])
    required_mcp_tools = cast("list[str]", route["required_mcp_tools"])
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
        "required_agents": required_agents,
        "required_skills": required_skills,
        "required_mcp_tools": required_mcp_tools,
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
            for tool in required_mcp_tools
        ],
        "local_execution_overrides": [],
        "delegation_bypasses": [],
        "lifecycle_operations": [
            {"name": tool, "surface": "mcp"} for tool in required_mcp_tools
        ],
        "blocked_reason": "none",
    }


def _build_complete_large_bug_state() -> dict[str, object]:
    """Return a completion-safe bug-type large-path checkpoint for validation.

    The feature-type baseline state is transformed into a truthful bug-type
    promotion: the hyphenated ``promotion-type`` is set to ``"bug"`` and every
    occurrence of the feature-type promotion-entry tool ``new_potential_entry``
    is replaced with the bug-type tool ``new_potential_bug_entry`` across the
    recorded ``required_mcp_tools`` list, the successful ``mcp_call_receipts``,
    and the ``lifecycle_operations``. No fabricated ``orchestrator-workflow`` or
    ``repo-automation-adapter`` skill receipts are added; the skill set is
    derived from the corrected routing matrix.
    """

    state = _build_complete_large_state()
    state["promotion-type"] = "bug"
    state["work-mode"] = "full-bug"

    # Swap the feature-type promotion-entry tool for the bug-type tool in the
    # recorded required tool list so it matches what a bug promotion exercises.
    required_mcp_tools = cast("list[str]", state["required_mcp_tools"])
    state["required_mcp_tools"] = [
        "new_potential_bug_entry" if tool == "new_potential_entry" else tool
        for tool in required_mcp_tools
    ]

    # Mirror the substitution in the successful MCP receipts so the bug-type
    # promotion records a truthful new_potential_bug_entry receipt.
    mcp_receipts = cast("list[dict[str, object]]", state["mcp_call_receipts"])
    for receipt in mcp_receipts:
        if receipt.get("tool") == "new_potential_entry":
            receipt["tool"] = "new_potential_bug_entry"
            receipt["evidence"] = "mcp_call:new_potential_bug_entry"

    # Mirror the substitution in the lifecycle operations for consistency.
    lifecycle_operations = cast(
        "list[dict[str, object]]", state["lifecycle_operations"]
    )
    for operation in lifecycle_operations:
        if operation.get("name") == "new_potential_entry":
            operation["name"] = "new_potential_bug_entry"

    return state


def _validate(state: dict[str, object]) -> list[str]:
    """Run completion validation against a serialized checkpoint."""

    return state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )


def test_complete_state_accepts_full_routing_contract_evidence() -> None:
    """Accept a checkpoint that proves all mandatory route evidence."""

    assert _validate(_build_complete_large_state()) == []


def test_complete_state_rejects_missing_required_agent_receipt() -> None:
    """Reject completion when a routing-matrix agent has no receipt."""

    state = _build_complete_large_state()
    state["delegation_receipts"] = cast("list[object]", state["delegation_receipts"])[
        1:
    ]

    errors = _validate(state)

    assert "Checkpoint missing required agent receipt: task-researcher." in errors


def test_complete_state_rejects_missing_required_skill_receipt() -> None:
    """Reject completion when a routing-matrix skill is not acknowledged."""

    state = _build_complete_large_state()
    state["skill_receipts"] = cast("list[object]", state["skill_receipts"])[1:]

    errors = _validate(state)

    assert "Checkpoint missing required skill receipt: orchestrate." in errors


def test_complete_state_rejects_missing_successful_mcp_receipt() -> None:
    """Reject completion when a required MCP tool lacks a successful receipt."""

    state = _build_complete_large_state()
    receipts = cast("list[dict[str, object]]", state["mcp_call_receipts"])
    receipts[0] = {**receipts[0], "ok": False}

    errors = _validate(state)

    assert "Checkpoint missing successful MCP receipt: new_potential_entry." in errors


def test_complete_state_rejects_required_agent_list_mismatch() -> None:
    """Reject completion when checkpoint route requirements differ from matrix."""

    state = _build_complete_large_state()
    state["required_agents"] = ["atomic-planner"]

    errors = _validate(state)

    assert any("required_agents must match routing matrix" in error for error in errors)


def test_complete_state_rejects_local_execution_override() -> None:
    """Reject completion when local execution bypasses are recorded."""

    state = _build_complete_large_state()
    state["local_execution_overrides"] = [{"step": "S8"}]

    errors = _validate(state)

    assert "Checkpoint local_execution_overrides must be empty at completion." in errors


def test_complete_state_rejects_non_mcp_lifecycle_operation() -> None:
    """Reject completion when lifecycle evidence records a non-MCP surface."""

    state = _build_complete_large_state()
    state["lifecycle_operations"] = [
        {"name": "new_active_feature_folder", "surface": "cli"}
    ]

    errors = _validate(state)

    assert "Checkpoint lifecycle_operations #0 did not use MCP surface." in errors


def test_validate_route_membership_accepts_small_route() -> None:
    """Accept a checkpoint whose path_selected is the known `small` route."""

    errors = validate_route_membership({"path_selected": "small"})

    assert errors == []


def test_validate_route_membership_accepts_large_route_via_route_id() -> None:
    """Accept a checkpoint whose route_id is the known `large` route."""

    errors = validate_route_membership({"route_id": "large"})

    assert errors == []


def test_validate_route_membership_rejects_fabricated_route() -> None:
    """Reject a fabricated execution mode that is not a routing-matrix route."""

    errors = validate_route_membership(
        {"path_selected": "direct_powershell_engineer_remediation"}
    )

    assert errors == [
        "Checkpoint selected route is not a routing-matrix route: "
        "direct_powershell_engineer_remediation."
    ]


def test_validate_route_membership_rejects_missing_route_id() -> None:
    """Reject a checkpoint that selects no route via route_id/path_selected."""

    errors = validate_route_membership({})

    assert errors == ["Checkpoint route_id or path_selected must select a route."]


def test_validate_route_membership_rejects_blank_route_id() -> None:
    """Reject a checkpoint whose route id is whitespace-only."""

    errors = validate_route_membership({"route_id": "   "})

    assert errors == ["Checkpoint route_id or path_selected must select a route."]


def test_complete_state_accepts_bug_type_large_route_with_bug_promotion_tool() -> None:
    """Accept a bug-type large-route checkpoint using new_potential_bug_entry.

    Verifies the promotion-type-aware resolution: a bug-type promotion that
    records a truthful `new_potential_bug_entry` MCP receipt (and no fabricated
    `orchestrator-workflow` / `repo-automation-adapter` skill receipts) passes
    `validate_routing_contract` with zero errors.
    """

    # Arrange: a completion-safe bug-type large-route checkpoint.
    state = _build_complete_large_bug_state()

    # Act: run completion validation.
    errors = _validate(state)

    # Assert: the bug-type promotion validates cleanly.
    assert errors == []


def test_complete_state_accepts_feature_type_large_route_with_feature_tool() -> None:
    """Accept the feature-type large-route case with new_potential_entry.

    Regression guard: feature-type behavior is unchanged and still requires the
    feature-type promotion-entry tool `new_potential_entry`.
    """

    # Arrange: the feature-type baseline large-route checkpoint.
    state = _build_complete_large_state()

    # Act: run completion validation.
    errors = _validate(state)

    # Assert: the feature-type promotion validates cleanly.
    assert errors == []
    assert state["promotion-type"] == "feature"
    assert "new_potential_entry" in cast("list[str]", state["required_mcp_tools"])


def test_large_route_required_skills_excludes_removed_dead_names() -> None:
    """Assert the dead skill names are gone from routes.large.required_skills.

    The routing matrix's `routes.large.required_skills` must no longer name
    `orchestrator-workflow` or `repo-automation-adapter`, neither of which has a
    corresponding skill file under `.claude/skills/`.
    """

    # Arrange: read the large-route entry from the repository routing matrix.
    required_skills = cast("list[str]", _large_route()["required_skills"])

    # Act / Assert: the removed dead names are absent.
    assert "orchestrator-workflow" not in required_skills
    assert "repo-automation-adapter" not in required_skills


def test_complete_state_rejects_bug_type_recording_only_feature_tool() -> None:
    """Reject a bug-type checkpoint that records only new_potential_entry.

    A bug-type promotion must exercise `new_potential_bug_entry`. A bug-type
    checkpoint that still records the feature-type `new_potential_entry` fails
    completion because the resolved expected tool is `new_potential_bug_entry`.
    """

    # Arrange: mark the feature-type baseline as a bug promotion without
    # substituting the promotion-entry tool in the recorded evidence.
    state = _build_complete_large_state()
    state["promotion-type"] = "bug"

    # Act: run completion validation.
    errors = _validate(state)

    # Assert: the missing bug-type receipt is reported.
    assert (
        "Checkpoint missing successful MCP receipt: new_potential_bug_entry." in errors
    )


def test_complete_state_reads_agents_from_mixed_receipt_namespace() -> None:
    """Accept canonical object-form delegation receipts during completion."""

    # Arrange: preserve all route evidence while namespacing strict receipts.
    state = _build_complete_large_state()
    state["delegation_receipts"] = {
        "agents": state["delegation_receipts"],
        "promotion": {"issue": {"opaque": "payload"}},
    }

    # Act / Assert: named strict receipts satisfy every required agent.
    assert _validate(state) == []
