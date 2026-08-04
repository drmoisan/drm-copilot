"""Regression tests for mixed delegation-receipt namespaces."""

from __future__ import annotations

import json

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.test_validate_orchestrator_state_remediation_loop import (
    build_valid_orchestrator_state,
)


def _agent_receipt() -> dict[str, object]:
    """Return a strict delegation receipt accepted by the legacy list form."""

    return {
        "step": "S4_atomic_planning",
        "agent_name": "atomic-planner",
        "agent_id": "agent-1",
        "skill_source": "orchestrator-workflow",
        "started_at": "2026-08-04T10:00:00Z",
        "completed_at": "2026-08-04T10:01:00Z",
        "result_signal": "PREFLIGHT: ALL CLEAR",
        "artifact_paths": ["docs/features/active/example/plan.md"],
    }


def _validate(receipts: object) -> list[str]:
    """Validate a standard checkpoint after replacing delegation receipts."""

    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = receipts
    return state_validator.validate_orchestrator_state_text(json.dumps(state))


def test_accepts_canonical_mixed_delegation_receipts() -> None:
    """Accept strict agents and opaque promotion payloads in one object."""

    errors = _validate(
        {
            "agents": [_agent_receipt()],
            "promotion": {
                "potential_entry": {"opaque": "potential"},
                "issue": "opaque issue value",
                "feature_folder": ["opaque", "folder", "value"],
            },
        }
    )

    assert errors == []


@pytest.mark.parametrize(
    "receipts",
    [
        [_agent_receipt()],
        {"promotion": {"potential_entry": {"opaque": "payload"}}},
    ],
)
def test_retains_legacy_list_and_promotion_only_compatibility(receipts: object) -> None:
    """Accept each legacy representation without requiring the other namespace."""

    assert _validate(receipts) == []


@pytest.mark.parametrize(
    ("receipts", "expected"),
    [
        (
            {"agents": "not-a-list"},
            "Checkpoint delegation_receipts.agents must be a list.",
        ),
        (
            {"agents": [{"agent_name": "atomic-planner"}]},
            "Checkpoint delegation receipt #0 missing key: step",
        ),
        (
            {"agents": [], "unexpected": {}},
            (
                "Checkpoint delegation_receipts object contains unsupported key: "
                "unexpected"
            ),
        ),
        (
            {"promotion": {"unexpected": {}}},
            (
                "Checkpoint delegation_receipts.promotion contains unsupported key: "
                "unexpected"
            ),
        ),
    ],
)
def test_rejects_invalid_mixed_delegation_receipt_shapes(
    receipts: object, expected: str
) -> None:
    """Reject invalid agent, object-key, and promotion-key shapes explicitly."""

    assert expected in _validate(receipts)
