"""Tests for Codex deployment receipts in orchestrator checkpoints."""

from __future__ import annotations

import json
from typing import Any

from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.validate_orchestrator_state import (
    validate_orchestrator_state_text,
)


def _delegation_receipt(agent_name: str) -> dict[str, object]:
    """Build one structurally valid delegated-agent receipt."""

    return {
        "step": "S5",
        "agent_name": agent_name,
        "agent_id": "agent-1",
        "skill_source": "orchestrate",
        "started_at": "2026-07-10T10:00:00Z",
        "completed_at": "2026-07-10T10:01:00Z",
        "result_signal": "COMPLETE",
        "artifact_paths": ["artifacts/orchestration/agent-1.json"],
    }


def _base_state(agent_name: str | None = "atomic-executor") -> dict[str, Any]:
    """Build a baseline checkpoint for opt-in Codex routing validation."""

    state: dict[str, Any] = {
        "objective": "execute one feature",
        "change_budget_estimate": "small",
        "path_selected": "small",
        "promotion-type": "feature",
        "short-name": "sample",
        "relativeFile": "docs/features/potential/sample.md",
        "long-name": "sample-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/sample-1",
        "work-mode": "minor-audit",
        "plan-path": "docs/features/active/sample-1/plan.md",
        "completed_steps": [],
        "next_step": "S5_atomic_execution",
        "last_updated": "2026-07-10T10:00:00Z",
        "step5_status": "pending",
        "step6_status": "pending",
        "step7_status": "pending",
        "step8_status": "pending",
        "step9_status": "pending",
        "step10_status": "pending",
        "delegation_receipts": [],
        "blocked_reason": "none",
    }
    if agent_name is not None:
        state["delegation_receipts"] = [_delegation_receipt(agent_name)]
    return state


def _codex_receipt(
    logical_agent: str = "atomic-executor",
    *,
    context: str = "standalone",
    ceiling: str = "C3",
) -> dict[str, object]:
    """Build a resolver-derived checkpoint receipt with its phase field."""

    receipt: dict[str, object] = dict(
        resolve_codex_deployment(logical_agent, "C3", context, ceiling)
    )
    receipt["phase"] = "S5_atomic_execution"
    return receipt


def _validate(state: dict[str, Any]) -> list[str]:
    """Run the Codex routing gate against serialized state."""

    return validate_orchestrator_state_text(
        json.dumps(state), require_codex_model_routing=True
    )


def test_valid_codex_receipt_satisfies_opt_in_gate() -> None:
    """Accept a delegation whose receipt exactly matches the resolver."""

    state = _base_state()
    state["codex_model_routing_receipts"] = [_codex_receipt()]

    assert _validate(state) == []


def test_mixed_receipts_require_codex_model_routing_evidence() -> None:
    """Enforce Codex routing receipts for object-form agent delegations."""

    state = _base_state()
    state["delegation_receipts"] = {
        "agents": [_delegation_receipt("atomic-executor")],
        "promotion": {"issue": {"opaque": "payload"}},
    }
    state["codex_model_routing_receipts"] = [_codex_receipt()]
    assert _validate(state) == []

    state["codex_model_routing_receipts"] = []
    assert any("atomic-executor" in error for error in _validate(state))


def test_variant_agent_name_matches_deployment_agent() -> None:
    """Allow delegation receipts to name the generated deployment profile."""

    state = _base_state("atomic-executor-c3")
    state["codex_model_routing_receipts"] = [_codex_receipt()]

    assert _validate(state) == []


def test_commit_steward_c4_receipt_requires_generated_deployment() -> None:
    """Accept exact C4 stewardship and reject a base-agent substitution."""

    receipt: dict[str, object] = dict(
        resolve_codex_deployment("commit-steward", "C4", "standalone", "C4")
    )
    receipt["phase"] = "S6_commit_steward"
    state = _base_state("commit-steward-c4")
    state["codex_model_routing_receipts"] = [receipt]

    assert _validate(state) == []

    receipt["deployment_agent"] = "commit-steward"
    state["delegation_receipts"] = [_delegation_receipt("commit-steward")]
    errors = _validate(state)

    assert any(
        "deployment_agent must be 'commit-steward-c4'" in error for error in errors
    )


def test_missing_codex_receipt_is_rejected_after_delegation() -> None:
    """Require the deployment decision to be persisted before delegated work."""

    errors = _validate(_base_state())

    assert any("must be a list" in error for error in errors)


def test_delegation_free_checkpoint_preserves_backward_compatibility() -> None:
    """Do not require Codex receipts before any delegation is recorded."""

    assert _validate(_base_state(agent_name=None)) == []


def test_receipt_with_wrong_model_is_rejected() -> None:
    """Reject a receipt whose model differs from the deterministic resolution."""

    state = _base_state()
    receipt = _codex_receipt()
    receipt["model"] = "gpt-5.6-sol"
    state["codex_model_routing_receipts"] = [receipt]

    errors = _validate(state)

    assert any(".model must be 'gpt-5.6-terra'" in error for error in errors)


def test_receipt_with_wrong_c3_overlay_is_rejected() -> None:
    """Reject a Terra receipt when epic context deterministically requires Sol."""

    state = _base_state()
    receipt = _codex_receipt(context="epic_execution_child")
    receipt["deployment_agent"] = "atomic-executor-c3"
    receipt["model"] = "gpt-5.6-terra"
    receipt["c3_overlay_applied"] = False
    receipt["c3_overlay_reason"] = None
    state["codex_model_routing_receipts"] = [receipt]

    errors = _validate(state)

    assert any("deployment_agent" in error for error in errors)
    assert any("c3_overlay_applied" in error for error in errors)


def test_receipt_for_different_agent_does_not_satisfy_gate() -> None:
    """Require a receipt for the actual delegated logical or deployment agent."""

    state = _base_state()
    state["codex_model_routing_receipts"] = [_codex_receipt("atomic-planner")]

    errors = _validate(state)

    assert any("missing a receipt for delegated agent" in error for error in errors)


def test_optional_receipt_block_is_validated_without_gate_flag() -> None:
    """Validate present Codex receipt content even in backward-compatible mode."""

    state = _base_state(agent_name=None)
    receipt = _codex_receipt()
    receipt.pop("model")
    state["codex_model_routing_receipts"] = [receipt]

    errors = validate_orchestrator_state_text(json.dumps(state))

    assert any("missing required keys: model" in error for error in errors)


def test_receipt_ceiling_must_not_decrease_during_run() -> None:
    """Reject a later routing decision that lowers the recorded ceiling."""

    state = _base_state()
    first = _codex_receipt(ceiling="C4")
    second = _codex_receipt(ceiling="C3")
    second["phase"] = "S6_feature_review"
    state["codex_model_routing_receipts"] = [first, second]

    errors = _validate(state)

    assert any("must be monotonic" in error for error in errors)


def test_receipt_ceiling_increase_requires_bound_transition_evidence() -> None:
    """Record affected delegations whenever a later assessment raises the ceiling."""

    state = _base_state()
    first = _codex_receipt(ceiling="C3")
    second = _codex_receipt(ceiling="C4")
    second["phase"] = "S6_feature_review"
    state["codex_model_routing_receipts"] = [first, second]

    missing_errors = _validate(state)
    second["ceiling_transition"] = {
        "from": "C3",
        "to": "C4",
        "affected_delegation_ids": ["agent-1"],
    }

    assert any("must record a ceiling increase" in error for error in missing_errors)
    assert _validate(state) == []
