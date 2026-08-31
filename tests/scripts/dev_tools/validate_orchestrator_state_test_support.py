"""Reusable payload builders for orchestrator-state validator tests."""

from __future__ import annotations

from dataclasses import asdict, replace
from typing import cast

from scripts.dev_tools import orchestration_handoff_contract as handoff


def build_valid_orchestrator_state() -> dict[str, object]:
    """Return a minimally valid provider-native checkpoint for mutation."""

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
        "next_step": "done",
        "last_updated": "2026-04-07T10:00:00-04:00",
        "step5_status": "not-applicable",
        "step6_status": "not-applicable",
        "step7_status": "verified",
        "step8_status": "not-applicable",
        "step9_status": "verified",
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


def build_complete_small_state() -> dict[str, object]:
    """Return a completion-safe small-route checkpoint for mutation."""

    from scripts.dev_tools._orchestrator_state_routing import load_routing_matrix

    matrix = load_routing_matrix()
    small = cast(
        "dict[str, object]", cast("dict[str, object]", matrix["routes"])["small"]
    )
    required_agents = cast("list[str]", small["required_agents"])
    required_skills = cast("list[str]", small["required_skills"])
    required_mcp_tools = cast("list[str]", small["required_mcp_tools"])
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
        "step6_status": "not-applicable",
        "step7_status": "verified",
        "step8_status": "verified",
        "step9_status": "verified",
        "step10_status": "not-applicable",
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
            {"tool": tool, "ok": True, "evidence": f"mcp_call:{tool}"}
            for tool in required_mcp_tools
        ],
        "local_execution_overrides": [],
        "delegation_bypasses": [],
        "lifecycle_operations": [
            {"name": tool, "surface": "mcp"} for tool in required_mcp_tools
        ],
        "blocked_reason": "none",
    }


def build_portable_envelope() -> dict[str, object]:
    """Return a portable envelope with a valid single-entry history chain."""

    source_sha256 = "a" * 64
    envelope_sha256 = "b" * 64
    history_entry = handoff.HistoryEntry(
        sequence=1,
        from_provider="claude",
        to_provider="codex",
        source_checkpoint_sha256=source_sha256,
        envelope_sha256=envelope_sha256,
        requested_at="2026-08-31T08:00:00Z",
        previous_entry_sha256=None,
        entry_sha256="0" * 64,
        status="requested",
        adapter_id="claude-to-codex-v1",
        adapter_version="1.0.0",
    )
    history_entry = replace(
        history_entry, entry_sha256=handoff.history_entry_digest(history_entry)
    )
    history = cast("dict[str, object]", asdict(history_entry))
    return {
        "schema_version": "2.0.0",
        "kind": "portable_orchestration_handoff",
        "handoff_id": "handoff-614",
        "identity": {
            "objective_id": "github:drmoisan/drm-copilot#614",
            "issue_number": 614,
            "feature_folder": "docs/features/active/portable-handoff-614",
            "work_mode": "full-feature",
        },
        "binding": {
            "repository_id": "github.com/drmoisan/drm-copilot",
            "workspace_root": "C:/workspace",
            "branch": "feature/portable-handoff-614",
            "source_head_sha": "0" * 40,
            "allowed_head_relationship": "equal_or_descendant",
        },
        "source": {
            "provider": "claude",
            "checkpoint": {
                "path": "artifacts/orchestration/orchestrator-state.json",
                "sha256": source_sha256,
                "archive_path": (
                    "artifacts/orchestration/handoffs/sources/sha256/"
                    f"{source_sha256}.json"
                ),
            },
            "expression": {
                "schema_id": "claude.orchestrator-state",
                "schema_version": "legacy-v1",
                "historical_receipts": {"references": []},
            },
        },
        "destination": {
            "provider": "codex",
            "checkpoint_path": "artifacts/orchestration/orchestrator-state.json",
        },
        "plan": {
            "path": "docs/features/active/portable-handoff-614/plan.md",
            "sha256": "c" * 64,
            "contract_version": "atomic-plan-v1",
        },
        "lifecycle": {
            "logical_complexity": "C3",
            "route_intent": "prepared_to_ordinary_execution",
            "completed_phases": ["promotion", "preflight"],
            "next_transition": "atomic_execution",
            "replay_policy": "forbid_completed_phases",
        },
        "capabilities": {
            "vocabularies": ["portable-orchestration-handoff-core-v1"],
            "required": ["handoff-schema:2"],
        },
        "scheduler_context": {"kind": "ordinary"},
        "handoff_history": [history],
    }


def build_portable_projection() -> dict[str, object]:
    """Return a provider-native checkpoint with a valid portable link."""

    state = build_valid_orchestrator_state()
    state["next_step"] = "atomic_execution"
    state["portable_handoff"] = {
        "envelope_sha256": "b" * 64,
        "history_entry_sha256": "d" * 64,
        "plan": {
            "path": state["plan-path"],
            "sha256": "c" * 64,
            "contract_version": "atomic-plan-v1",
        },
        "lifecycle": {
            "logical_complexity": "C3",
            "route_intent": "prepared_to_ordinary_execution",
            "completed_phases": ["promotion", "preflight"],
            "next_transition": "atomic_execution",
            "replay_policy": "forbid_completed_phases",
        },
        "scheduler_context": {"kind": "ordinary"},
    }
    return state
