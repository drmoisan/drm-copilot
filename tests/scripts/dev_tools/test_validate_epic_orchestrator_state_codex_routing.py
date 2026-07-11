"""Codex deployment-receipt tests for epic-orchestrator checkpoints."""

from __future__ import annotations

import json
from typing import Any

from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
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


def _receipt() -> dict[str, object]:
    """Build the deterministic epic-child orchestrator receipt."""

    receipt: dict[str, object] = dict(
        resolve_codex_deployment("orchestrator", "C3", "epic_execution_child", "C3")
    )
    receipt["phase"] = "wave_0"
    return receipt


def test_epic_codex_routing_gate_accepts_matching_deployment() -> None:
    """Accept a generated child orchestrator backed by its exact receipt."""

    state = _state()
    state["codex_model_routing_receipts"] = [_receipt()]

    errors = validate_epic_orchestrator_state_text(
        json.dumps(state), require_codex_model_routing=True
    )

    assert errors == []


def test_epic_codex_routing_gate_rejects_missing_receipt() -> None:
    """Reject epic child delegation when no Codex deployment was persisted."""

    errors = validate_epic_orchestrator_state_text(
        json.dumps(_state()), require_codex_model_routing=True
    )

    assert any("must be a list" in error for error in errors)


def test_epic_validator_checks_present_receipt_without_gate_flag() -> None:
    """Reject a malformed present receipt in backward-compatible mode."""

    state = _state(agent_name=None)
    receipt = _receipt()
    receipt["model_reasoning_effort"] = "low"
    state["codex_model_routing_receipts"] = [receipt]

    errors = validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("model_reasoning_effort" in error for error in errors)
