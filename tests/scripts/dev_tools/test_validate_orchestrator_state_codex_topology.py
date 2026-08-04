"""Tests for Codex topology receipts in ordinary orchestrator checkpoints."""

from __future__ import annotations

import json
from typing import Any

from scripts.dev_tools._orchestrator_state_codex_topology import (
    validate_codex_topology_gate,
    validate_codex_topology_receipts,
)
from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology
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


def _base_state(agent_name: str | None = "python-typed-engineer") -> dict[str, Any]:
    """Build a small-path checkpoint for opt-in topology validation."""

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


def _topology_receipt(
    *,
    language: str = "python",
    production_files: int = 2,
    test_files: int = 2,
    context: str = "standalone",
) -> dict[str, object]:
    """Build a resolver-derived topology receipt with its phase."""

    receipt: dict[str, object] = dict(
        resolve_codex_topology([language], production_files, test_files, context)
    )
    receipt["phase"] = "S5_atomic_execution"
    return receipt


def _model_receipt() -> dict[str, object]:
    """Build a valid exact deployment receipt for the Python engineer."""

    receipt: dict[str, object] = dict(
        resolve_codex_deployment("python-typed-engineer", "C3", "standalone", "C3")
    )
    receipt["phase"] = "S5_atomic_execution"
    return receipt


def _validate(state: dict[str, Any]) -> list[str]:
    """Run the opt-in topology gate against serialized state."""

    return validate_orchestrator_state_text(
        json.dumps(state), require_codex_topology=True
    )


def test_small_standalone_receipt_requires_exact_typed_engineer() -> None:
    """Accept a small route only with its resolved language engineer."""

    state = _base_state()
    state["codex_topology_receipts"] = [_topology_receipt()]

    assert _validate(state) == []


def test_mixed_receipts_require_codex_topology_evidence() -> None:
    """Enforce topology receipts for canonical object-form agent delegations."""

    state = _base_state()
    state["delegation_receipts"] = {
        "agents": [_delegation_receipt("python-typed-engineer")],
        "promotion": {"issue": {"opaque": "payload"}},
    }
    state["codex_topology_receipts"] = [_topology_receipt()]
    assert _validate(state) == []

    state["codex_topology_receipts"] = []
    assert any("child topology receipt" in error for error in _validate(state))


def test_generated_deployment_name_satisfies_topology_gate() -> None:
    """Accept an exact generated profile backed by a valid model receipt."""

    model_receipt = _model_receipt()
    state = _base_state(str(model_receipt["deployment_agent"]))
    state["codex_model_routing_receipts"] = [model_receipt]
    state["codex_topology_receipts"] = [_topology_receipt()]

    assert _validate(state) == []


def test_invalid_model_receipt_does_not_authorize_variant_name() -> None:
    """Do not trust an unvalidated deployment mapping during topology checks."""

    model_receipt = _model_receipt()
    state = _base_state(str(model_receipt["deployment_agent"]))
    model_receipt["model"] = "gpt-5.6-sol"
    state["codex_model_routing_receipts"] = [model_receipt]
    state["codex_topology_receipts"] = [_topology_receipt()]

    errors = _validate(state)

    assert any(".model must be" in error for error in errors)
    assert any("missing the exact resolved topology agent" in error for error in errors)


def test_missing_topology_receipt_is_rejected_after_delegation() -> None:
    """Require topology resolution before a recorded implementation delegation."""

    errors = _validate(_base_state())

    assert any("must be a list" in error for error in errors)


def test_small_receipt_rejects_orchestrator_delegation() -> None:
    """Prevent the small route from bypassing the typed-engineer delegation."""

    state = _base_state("orchestrator")
    state["codex_topology_receipts"] = [_topology_receipt()]

    errors = _validate(state)

    assert any("python-typed-engineer" in error for error in errors)


def test_receipt_route_must_match_checkpoint_route() -> None:
    """Reject a large topology decision recorded on a small-path checkpoint."""

    state = _base_state("orchestrator")
    state["codex_topology_receipts"] = [
        _topology_receipt(production_files=4, test_files=2)
    ]

    errors = _validate(state)

    assert any("path_selected 'small' does not match" in error for error in errors)


def test_present_receipt_is_validated_without_gate_flag() -> None:
    """Preserve compatibility while rejecting malformed optional receipt data."""

    state = _base_state(agent_name=None)
    receipt = _topology_receipt()
    receipt["logical_agent"] = "orchestrator"
    state["codex_topology_receipts"] = [receipt]

    errors = validate_orchestrator_state_text(json.dumps(state))

    assert any(
        ".logical_agent must be 'python-typed-engineer'" in error for error in errors
    )


def test_delegation_free_checkpoint_does_not_require_receipt() -> None:
    """Keep the explicit gate backward compatible before any delegation."""

    assert _validate(_base_state(agent_name=None)) == []


def test_receipt_validator_reports_structural_and_typed_errors() -> None:
    """Report malformed entries before attempting deterministic resolution."""

    assert any(
        "must be an object" in error
        for error in validate_codex_topology_receipts([None])
    )
    empty_receipt: dict[str, object] = {}
    assert any(
        "missing required keys" in error
        for error in validate_codex_topology_receipts([empty_receipt])
    )

    blank_phase = _topology_receipt()
    blank_phase["phase"] = ""
    assert any(
        "phase must be" in error
        for error in validate_codex_topology_receipts([blank_phase])
    )

    invalid_inputs = _topology_receipt()
    invalid_inputs["languages"] = [1]
    invalid_inputs["production_file_count"] = "2"
    invalid_inputs["test_file_count"] = True
    invalid_inputs["cross_cutting"] = "false"
    invalid_inputs["execution_context"] = 1
    invalid_inputs["root_persona"] = "unknown"
    errors = validate_codex_topology_receipts([invalid_inputs])
    assert any("languages must be" in error for error in errors)
    assert sum("must be an integer" in error for error in errors) == 2
    assert any("cross_cutting must be" in error for error in errors)
    assert any("execution_context must be" in error for error in errors)
    assert any("root_persona must be" in error for error in errors)


def test_receipt_validator_reports_invalid_context_from_resolver() -> None:
    """Surface semantic resolver errors after receipt types pass."""

    receipt = _topology_receipt()
    receipt["execution_context"] = "unknown"

    errors = validate_codex_topology_receipts([receipt])

    assert any("invalid routing inputs" in error for error in errors)


def test_gate_ignores_invalid_entries_when_matching_valid_receipt() -> None:
    """Do not let malformed list entries prevent inspection of valid evidence."""

    model_receipt = _model_receipt()
    state = _base_state(str(model_receipt["deployment_agent"]))
    state["delegation_receipts"] = [
        None,
        _delegation_receipt(str(model_receipt["deployment_agent"])),
    ]
    state["codex_model_routing_receipts"] = [None, model_receipt]
    state["codex_topology_receipts"] = [None, {}, _topology_receipt()]

    errors = _validate(state)

    assert any(
        "codex_topology_receipts[0] must be an object" in error for error in errors
    )
    assert any(
        "codex_topology_receipts[1] missing required keys" in error for error in errors
    )


def test_gate_treats_non_list_delegation_namespace_as_delegation_free() -> None:
    """Preserve compatibility for non-list receipt namespaces."""

    assert validate_codex_topology_gate({"delegation_receipts": {}}) == []
