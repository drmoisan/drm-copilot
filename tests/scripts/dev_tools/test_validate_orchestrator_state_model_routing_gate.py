"""Tests for the require_model_routing existence gate of the state validator.

These tests exercise the additive `require_model_routing` mode in
`scripts.dev_tools.validate_orchestrator_state`, implemented in the delegate
`scripts.dev_tools._orchestrator_state_model_routing_gate`. They cover
strict-mode missing-entry rejection, present-and-consistent acceptance,
present-but-model-mismatch rejection (delegating to the reused per-entry
validator), and the backward-compatible no-delegation case. The valid base
checkpoint is reused from the remediation-loop test module to avoid duplicating
unrelated setup.
"""

from __future__ import annotations

import json

import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.test_validate_orchestrator_state_remediation_loop import (
    build_valid_orchestrator_state,
)


def _delegation(agent: str, step: str = "7") -> dict[str, object]:
    """Return a well-formed list delegation receipt for one agent.

    Args:
        agent (str): The delegated agent name recorded as `agent_name`.
        step (str): The lifecycle step the delegation belongs to.

    Returns:
        dict[str, object]: A delegation receipt with all required keys.

    Raises:
        None.

    Side Effects:
        None.
    """

    return {
        "step": step,
        "agent_name": agent,
        "agent_id": "a1",
        "skill_source": "orchestrator-workflow",
        "started_at": "2026-07-04T09:00:00-04:00",
        "completed_at": "2026-07-04T09:05:00-04:00",
        "result_signal": "PREFLIGHT: ALL CLEAR",
        "artifact_paths": ["docs/features/active/feature-1/plan.md"],
    }


def _receipt(
    agent: str,
    phase: str = "7",
    *,
    band: str = "C3",
    fable_policy: str = "disabled",
    table_model: str = "opus",
    clamped_from: str | None = None,
    model: str = "opus",
) -> dict[str, object]:
    """Return a model-routing receipt consistent with the reference formula.

    Args:
        agent (str): The receipt's `agent`.
        phase (str): The receipt's `phase`.
        band (str): The `complexity_band`.
        fable_policy (str): The session `fable_policy`.
        table_model (str): The pre-clamp `table_model`.
        clamped_from (str | None): The clamp provenance, or None.
        model (str): The post-clamp `model`.

    Returns:
        dict[str, object]: A model-routing-receipt object.

    Raises:
        None.

    Side Effects:
        None.
    """

    return {
        "agent": agent,
        "phase": phase,
        "complexity_band": band,
        "fable_policy": fable_policy,
        "table_model": table_model,
        "clamped_from": clamped_from,
        "model": model,
    }


def _assessment(phase: str = "7") -> dict[str, object]:
    """Return a complexity assessment consistent with the floor formula.

    Args:
        phase (str): The assessment's `phase`.

    Returns:
        dict[str, object]: A complexity-assessment object whose `floor` equals
        `compute_complexity_floor(signals_present)` (C3 for one floor signal).

    Raises:
        None.

    Side Effects:
        None.
    """

    return {
        "phase": phase,
        "band": "C3",
        "floor": "C3",
        "signals_present": ["cross_module_contract_change"],
        "rationale": "cross-module contract change",
        "assessed_at": "2026-07-04T09:00:00-04:00",
    }


def test_missing_routing_receipt_for_delegated_agent_is_rejected() -> None:
    """Reject a checkpoint whose delegated agent has no routing receipt.

    Purpose:
        Verify strict-mode rejection when `delegation_receipts` names agents X
        and Y but `model_routing_receipts` omits Y.

    Args:
        None.

    Returns:
        None: Assertions verify the missing-agent error is present.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: delegate to two agents but record a routing receipt for only one.
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = [
        _delegation("atomic-planner", "7"),
        _delegation("atomic-executor", "8"),
    ]
    state["model_routing_receipts"] = [_receipt("atomic-planner", "7")]
    state["complexity_assessments"] = [_assessment("7")]

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )

    # Assert: the missing agent is flagged and the present agent is not.
    assert any(
        "missing a receipt for delegated agent: atomic-executor" in error
        for error in errors
    )
    assert not any("atomic-planner" in error for error in errors)


def test_present_and_consistent_yields_no_errors() -> None:
    """Accept a checkpoint whose delegations all have consistent receipts.

    Purpose:
        Verify zero errors when every delegated agent has a matching receipt
        and each matched phase has a self-consistent complexity assessment.

    Args:
        None.

    Returns:
        None: Assertions verify an empty error list.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: one delegation with a consistent receipt and assessment.
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = [_delegation("atomic-planner", "7")]
    state["model_routing_receipts"] = [_receipt("atomic-planner", "7")]
    state["complexity_assessments"] = [_assessment("7")]

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )

    # Assert
    assert errors == []


def test_present_but_model_mismatch_is_rejected() -> None:
    """Reject a receipt whose model diverges from the reference resolution.

    Purpose:
        Verify the gate's reuse of `_validate_model_routing_receipts` catches a
        receipt whose `model` does not equal `resolve_delegation_model(...)`.

    Args:
        None.

    Returns:
        None: Assertions verify the mismatch error is present.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: C3 under disabled resolves to opus; record sonnet to force a
    # mismatch through the reused per-entry validator.
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = [_delegation("atomic-planner", "7")]
    state["model_routing_receipts"] = [_receipt("atomic-planner", "7", model="sonnet")]
    state["complexity_assessments"] = [_assessment("7")]

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )

    # Assert
    assert any("does not equal resolve_delegation_model" in error for error in errors)


def test_no_delegation_passes_under_flag() -> None:
    """Accept a delegation-free checkpoint even under the flag.

    Purpose:
        Verify backward compatibility: a checkpoint with no delegations and a
        non-delegating `next_step` imposes no routing-receipt requirement.

    Args:
        None.

    Returns:
        None: Assertions verify an empty error list.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: no delegation receipts and a non-delegating next_step.
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = []
    state["next_step"] = "done"

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )

    # Assert
    assert errors == []


def test_missing_complexity_assessment_for_matched_phase_is_rejected() -> None:
    """Reject a matched routing receipt whose phase lacks an assessment.

    Purpose:
        Verify the phase-pairing invariant: a routing receipt for a delegated
        agent requires a `complexity_assessments[]` entry for its phase.

    Args:
        None.

    Returns:
        None: Assertions verify the missing-phase error is present.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: a consistent receipt but no complexity assessment for its phase.
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = [_delegation("atomic-planner", "7")]
    state["model_routing_receipts"] = [_receipt("atomic-planner", "7")]
    state["complexity_assessments"] = []

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )

    # Assert
    assert any(
        "complexity_assessments is missing an entry for phase 7" in error
        for error in errors
    )


def test_next_step_naming_delegating_agent_requires_receipt() -> None:
    """Treat a `next_step` that names a delegating agent as a delegation.

    Purpose:
        Verify the gate fires for an upcoming delegation named only by
        `next_step` (no receipt yet), and that a matching routing receipt plus
        assessment satisfy it.

    Args:
        None.

    Returns:
        None: Assertions verify both the missing and satisfied cases.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: no delegation receipts, but next_step names a delegating agent.
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = []
    state["next_step"] = "atomic-executor"

    # Act / Assert: missing receipt is flagged for the next_step agent.
    missing = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )
    assert any("delegated agent: atomic-executor" in error for error in missing)

    # Act / Assert: adding the receipt and assessment satisfies the gate.
    state["model_routing_receipts"] = [_receipt("atomic-executor", "8")]
    state["complexity_assessments"] = [_assessment("8")]
    satisfied = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )
    assert satisfied == []


def test_namespaced_delegation_receipts_impose_no_requirement() -> None:
    """A promotion-namespace `delegation_receipts` yields no delegated agents.

    Purpose:
        Verify the object (namespace) form of `delegation_receipts` contributes
        no delegated agents, so with a non-delegating `next_step` the gate does
        not fire.

    Args:
        None.

    Returns:
        None: Assertions verify an empty error list.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: object-namespace receipts and a non-delegating next_step.
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = {"promotion": {}}
    state["next_step"] = "done"

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )

    # Assert: the gate produces no missing-receipt error.
    assert not any("delegated agent" in error for error in errors)


def test_malformed_delegation_and_receipt_entries_are_skipped_by_gate() -> None:
    """Ignore non-object and blank-agent entries when deriving the sets.

    Purpose:
        Verify the gate's defensive skips: a non-object delegation receipt, a
        blank `agent_name`, a non-object routing receipt, and a blank routing
        `agent` are ignored when deriving the delegated-agent and receipt-agent
        sets, so only the one well-formed delegation is enforced.

    Args:
        None.

    Returns:
        None: Assertions verify the well-formed agent is enforced and matched.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: a blank-agent receipt is well-formed for the list validator (all
    # keys present) but is skipped by the gate; the non-object routing entry is
    # skipped too. atomic-planner is the only real delegation.
    blank = _delegation("atomic-planner", "7")
    blank["agent_name"] = "   "
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = [blank, _delegation("atomic-planner", "7")]
    state["model_routing_receipts"] = [
        "not-an-object",
        {"agent": "   ", "phase": "7"},
        _receipt("atomic-planner", "7"),
    ]
    state["complexity_assessments"] = [_assessment("7")]

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )

    # Assert: no missing-agent error for atomic-planner (its receipt matched).
    assert not any("delegated agent: atomic-planner" in error for error in errors)


def test_non_list_routing_arrays_flag_missing_receipt() -> None:
    """Non-list routing arrays yield no receipt/assessment coverage.

    Purpose:
        Verify that when `model_routing_receipts` and `complexity_assessments`
        are present but not lists, the gate reports the delegated agent as
        missing a receipt (the harvest helpers return empty sets).

    Args:
        None.

    Returns:
        None: Assertions verify the missing-receipt error is present.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Arrange: present-but-non-list routing arrays with one delegation.
    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = [_delegation("atomic-planner", "7")]
    state["model_routing_receipts"] = "not-a-list"
    state["complexity_assessments"] = "not-a-list"

    # Act
    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_model_routing=True
    )

    # Assert
    assert any("delegated agent: atomic-planner" in error for error in errors)
