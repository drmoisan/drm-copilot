"""Tests for Codex topology receipts in epic-orchestrator checkpoints."""

from __future__ import annotations

import json
from typing import Any

from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology
from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)


def _state(agent_name: str | None = "orchestrator-c3-elevated") -> dict[str, Any]:
    """Build a minimal structurally valid epic checkpoint."""

    state: dict[str, Any] = {
        "objective": "execute prepared epic",
        "route_id": "epic",
        "epic_feature_folder": "sample-epic",
        "integration_branch": "epic/sample-epic-integration",
        "max_parallel_features": 4,
        "completed_steps": ["manifest_parsed"],
        "next_step": "wave_0",
        "last_updated": "2026-07-10T10:00:00Z",
        "waves": [{"wave_number": 0, "feature_folders": ["feature-1"]}],
        "features": [
            {
                "issue_num": 1,
                "feature_folder": "feature-1",
                "depends_on": [],
                "wave_number": 0,
                "merge_status": "not_started",
            }
        ],
        "delegation_receipts": [],
    }
    if agent_name is not None:
        state["delegation_receipts"] = [{"agent_name": agent_name}]
    return state


def _topology_receipt(*, root_persona: str | None = None) -> dict[str, object]:
    """Build a root or child epic topology receipt."""

    if root_persona is not None:
        receipt: dict[str, object] = dict(
            resolve_codex_topology([], 0, 0, "standalone", root_persona=root_persona)
        )
        receipt["phase"] = "epic_start"
        return receipt
    receipt = dict(resolve_codex_topology(["python"], 1, 1, "epic_execution_child"))
    receipt["phase"] = "wave_0"
    return receipt


def _model_receipt() -> dict[str, object]:
    """Build the exact model deployment receipt for the child orchestrator."""

    receipt: dict[str, object] = dict(
        resolve_codex_deployment("orchestrator", "C3", "epic_execution_child", "C3")
    )
    receipt["phase"] = "wave_0"
    return receipt


def _valid_state() -> dict[str, Any]:
    """Build an epic state with forced-root and child topology evidence."""

    model_receipt = _model_receipt()
    state = _state(str(model_receipt["deployment_agent"]))
    state["codex_model_routing_receipts"] = [model_receipt]
    state["codex_topology_receipts"] = [
        _topology_receipt(root_persona="epic-orchestrator"),
        _topology_receipt(),
    ]
    return state


def test_epic_gate_accepts_forced_root_and_child_orchestrator() -> None:
    """Accept the forced epic root plus exact generated child orchestrator."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_valid_state()), require_codex_topology=True
    )

    assert errors == []


def test_epic_gate_requires_forced_epic_orchestrator_receipt() -> None:
    """Reject child-only topology evidence at the epic completion gate."""

    state = _valid_state()
    state["codex_topology_receipts"] = [_topology_receipt()]

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_codex_topology=True
    )

    assert any("forced root persona receipt" in error for error in errors)


def test_epic_gate_requires_child_orchestrator_receipt() -> None:
    """Reject root-only evidence after a child delegation is recorded."""

    state = _valid_state()
    state["codex_topology_receipts"] = [
        _topology_receipt(root_persona="epic-orchestrator")
    ]

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_codex_topology=True
    )

    assert any("missing a child topology receipt" in error for error in errors)


def test_epic_child_receipt_cannot_select_typed_engineer() -> None:
    """Reject a tampered epic-child receipt that bypasses the orchestrator."""

    state = _valid_state()
    child_receipt = _topology_receipt()
    child_receipt["logical_agent"] = "python-typed-engineer"
    state["codex_topology_receipts"] = [
        _topology_receipt(root_persona="epic-orchestrator"),
        child_receipt,
    ]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any(".logical_agent must be 'orchestrator'" in error for error in errors)


def test_epic_present_receipt_is_validated_without_gate_flag() -> None:
    """Validate malformed optional topology data in backward-compatible mode."""

    state = _state(agent_name=None)
    receipt = _topology_receipt(root_persona="epic-orchestrator")
    receipt["route"] = "small"
    state["codex_topology_receipts"] = [receipt]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any(".route must be 'epic'" in error for error in errors)
