"""Deterministic in-memory fixtures for orchestrator-state validator tests."""

from __future__ import annotations

import hashlib
from typing import cast

from scripts.dev_tools._orchestrator_state_routing import (
    ROUTING_MATRIX_PATH,
    load_routing_matrix,
)

__all__ = [
    "BLOCKER_FINGERPRINT_A",
    "BLOCKER_FINGERPRINT_B",
    "_build_complete_small_state",
    "build_exception_binding",
    "build_legacy_remediation_cycle",
    "build_namespaced_orchestrator_state",
    "build_remediation_attempt",
    "build_remediation_cycle",
    "build_remediation_loop",
    "build_valid_orchestrator_state",
]

BLOCKER_FINGERPRINT_A = f"sha256:{'a' * 64}"
BLOCKER_FINGERPRINT_B = f"sha256:{'b' * 64}"


def build_valid_orchestrator_state() -> dict[str, object]:
    """Return a minimally valid orchestrator-state payload for mutation."""

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


def build_namespaced_orchestrator_state() -> dict[str, object]:
    """Return a valid checkpoint payload using the promotion namespace."""

    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = {
        "promotion": {
            "potential_entry": {"path": "docs/features/potential/demo.md"},
            "issue": "https://github.com/drmoisan/drm-copilot/issues/168",
            "feature_folder": {
                "path": (
                    "docs/features/active/2026-04-29-"
                    "harden-feature-promotion-lifecycle-mcp-only-168"
                )
            },
        }
    }
    return state


def build_remediation_attempt(
    *,
    attempt_id: int = 1,
    source_review_fingerprint: str = BLOCKER_FINGERPRINT_A,
    execution_status: str = "complete",
    candidate_applied: bool = True,
    terminal_disposition: str = "candidate_applied",
    exception_binding: dict[str, object] | None = None,
) -> dict[str, object]:
    """Return one canonical version-2 remediation attempt."""

    return {
        "attempt_id": attempt_id,
        "source_review_fingerprint": source_review_fingerprint,
        "plan_path": f"plan-{attempt_id}.md",
        "preflight": {"final_status": "clear"},
        "execution_status": execution_status,
        "candidate_applied": candidate_applied,
        "terminal_disposition": terminal_disposition,
        "started_at": f"2026-08-17T12:{attempt_id:02d}:00Z",
        "finished_at": f"2026-08-17T12:{attempt_id:02d}:30Z",
        "exception_binding": exception_binding,
    }


def build_remediation_cycle(
    *,
    cycle_id: int = 1,
    attempt_id: int = 1,
    review_verdict: str = "PASS",
    remediation_action: str = "NONE",
    blocker_fingerprint_before: str = BLOCKER_FINGERPRINT_A,
    blocker_fingerprint_after: str = "NONE",
    blocking_count: int = 0,
    exit_condition_met: bool = True,
) -> dict[str, object]:
    """Return one canonical version-2 completed remediation cycle."""

    return {
        "cycle_id": cycle_id,
        "attempt_id": attempt_id,
        "commit_sha": f"commit-{attempt_id}",
        "re_audit_path": f"audit-{attempt_id}.md",
        "review_verdict": review_verdict,
        "remediation_action": remediation_action,
        "blocker_fingerprint_before": blocker_fingerprint_before,
        "blocker_fingerprint_after": blocker_fingerprint_after,
        "blocking_count": blocking_count,
        "exit_condition_met": exit_condition_met,
        "completed_at": f"2026-08-17T13:{cycle_id:02d}:00Z",
    }


def build_remediation_loop(
    *,
    status: str = "resolved",
    attempts: list[dict[str, object]] | None = None,
    cycles: list[dict[str, object]] | None = None,
    attempt_count: int | None = None,
    completed_cycle_count: int | None = None,
) -> dict[str, object]:
    """Return a version-2 loop with counts derived unless explicitly supplied."""

    attempt_records = [] if attempts is None else list(attempts)
    cycle_records = [] if cycles is None else list(cycles)
    return {
        "schema_version": 2,
        "status": status,
        "max_completed_cycles": 3,
        "attempt_count": (
            len(attempt_records) if attempt_count is None else attempt_count
        ),
        "completed_cycle_count": (
            len(cycle_records)
            if completed_cycle_count is None
            else completed_cycle_count
        ),
        "last_blocker_fingerprint": BLOCKER_FINGERPRINT_A,
        "attempts": attempt_records,
        "cycles": cycle_records,
    }


def build_exception_binding(
    *, attempt_id: int, exception_id: str = "exception-1"
) -> dict[str, object]:
    """Return one consumed exception bound to the current routing policy."""

    routing_digest = hashlib.sha256(ROUTING_MATRIX_PATH.read_bytes()).hexdigest()
    return {
        "exception_id": exception_id,
        "issue_number": "1",
        "blocker_fingerprint": BLOCKER_FINGERPRINT_A,
        "routing_policy_sha256": f"sha256:{routing_digest}",
        "allowed_transition": "blocked_stagnation_to_active",
        "single_use": True,
        "consumed_at": "2026-08-17T14:00:00Z",
        "consumed_by_attempt_id": attempt_id,
    }


def build_legacy_remediation_cycle() -> dict[str, object]:
    """Return one loop cycle using the pre-version-2 compatibility shape."""

    return {
        "plan_path": "legacy-plan.md",
        "preflight": {"final_status": "clear"},
        "execution_status": "complete",
        "exit_condition_met": False,
        "blocking_count": 1,
    }


def _build_complete_small_state() -> dict[str, object]:
    """Return a completion-safe small-route checkpoint for mutation."""

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
