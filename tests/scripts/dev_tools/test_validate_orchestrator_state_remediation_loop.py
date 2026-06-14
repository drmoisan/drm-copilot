"""Tests for the remediation-loop branch of the orchestrator-state validator.

These tests cover the additive `remediation_loop.cycles` validation path in
`scripts.dev_tools.validate_orchestrator_state`, including the backward-compatible
no-remediation-loop case and the malformed-`cycles` pass-through behavior. They
were split out of `test_validate_orchestrator_state.py` to keep both modules under
the 500-line file-size cap.
"""

from __future__ import annotations

import json

import scripts.dev_tools.validate_orchestrator_state as state_validator


def build_valid_orchestrator_state() -> dict[str, object]:
    """Return a minimally valid orchestrator-state payload for mutation.

    Purpose:
        Provide a reusable checkpoint payload so focused tests can mutate one
        validation branch at a time without duplicating unrelated setup.

    Args:
        None.

    Returns:
        dict[str, object]: A valid checkpoint payload.

    Raises:
        None.

    Side Effects:
        None.
    """

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


def _build_cycle() -> dict[str, object]:
    """Return a single well-formed remediation cycle for mutation.

    Purpose:
        Provide a valid cycle so each invariant test can mutate one field at a
        time without duplicating unrelated cycle setup.

    Args:
        None.

    Returns:
        dict[str, object]: A cycle satisfying all three remediation-cycle
        invariants.

    Raises:
        None.

    Side Effects:
        None.
    """

    return {
        "plan_path": "docs/features/active/feature-1/remediation-plan.md",
        "preflight": {"final_status": "clear"},
        "execution_status": "complete",
        "exit_condition_met": True,
        "blocking_count": 0,
    }


def _state_with_cycle(cycle: dict[str, object]) -> str:
    """Return checkpoint JSON carrying a single-cycle remediation loop.

    Purpose:
        Wrap one cycle in an otherwise-valid checkpoint so the public
        validator exercises the additive remediation-loop branch.

    Args:
        cycle (dict[str, object]): The cycle object to embed.

    Returns:
        str: Serialized checkpoint JSON including the cycle.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["remediation_loop"] = {"cycles": [cycle]}
    return json.dumps(state)


def test_no_remediation_loop_is_backward_compatible() -> None:
    """A checkpoint with no remediation_loop validates exactly as before.

    Purpose:
        Guard the additive change: the pre-change error set for a valid
        step-based checkpoint must be unchanged when no remediation_loop key is
        present.

    Args:
        None.

    Returns:
        None: Assertions verify no errors are produced and no remediation-cycle
        error text appears.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    assert "remediation_loop" not in state

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert errors == []
    assert not any("remediation cycle" in error for error in errors)


def test_remediation_cycle_empty_plan_path_is_rejected() -> None:
    """A whitespace-only plan_path produces the non-empty-string error."""

    cycle = _build_cycle()
    cycle["plan_path"] = "   "

    errors = state_validator.validate_orchestrator_state_text(_state_with_cycle(cycle))

    assert any(
        "remediation cycle #0 plan_path must be a non-empty string" in error
        for error in errors
    )


def test_remediation_cycle_valid_plan_path_has_no_error() -> None:
    """A non-empty plan_path produces no plan_path error."""

    errors = state_validator.validate_orchestrator_state_text(
        _state_with_cycle(_build_cycle())
    )

    assert not any("plan_path" in error for error in errors)


def test_remediation_cycle_execution_without_clear_preflight_is_rejected() -> None:
    """An in_progress execution with non-clear preflight is rejected."""

    cycle = _build_cycle()
    cycle["execution_status"] = "in_progress"
    cycle["preflight"] = {"final_status": "pending"}

    errors = state_validator.validate_orchestrator_state_text(_state_with_cycle(cycle))

    assert any(
        "execution_status is in_progress but preflight.final_status is not 'clear'"
        in error
        for error in errors
    )


def test_remediation_cycle_execution_with_clear_preflight_has_no_error() -> None:
    """An execution status with a cleared preflight produces no preflight error."""

    cycle = _build_cycle()
    cycle["execution_status"] = "in_progress"
    cycle["preflight"] = {"final_status": "clear"}

    errors = state_validator.validate_orchestrator_state_text(_state_with_cycle(cycle))

    assert not any("preflight.final_status" in error for error in errors)


def test_remediation_cycle_exit_with_blocking_findings_is_rejected() -> None:
    """exit_condition_met true with non-zero blocking_count is rejected."""

    cycle = _build_cycle()
    cycle["exit_condition_met"] = True
    cycle["blocking_count"] = 2

    errors = state_validator.validate_orchestrator_state_text(_state_with_cycle(cycle))

    assert any(
        "exit_condition_met is true but blocking_count is not 0" in error
        for error in errors
    )


def test_remediation_cycle_exit_with_zero_blocking_has_no_error() -> None:
    """exit_condition_met true with blocking_count 0 produces no exit-gate error."""

    cycle = _build_cycle()
    cycle["exit_condition_met"] = True
    cycle["blocking_count"] = 0

    errors = state_validator.validate_orchestrator_state_text(_state_with_cycle(cycle))

    assert not any("blocking_count" in error for error in errors)


def test_remediation_cycle_non_dict_entry_is_rejected() -> None:
    """A non-dict cycle entry is rejected with the must-be-an-object error.

    Purpose:
        Cover the validator branch that rejects a `cycles` list element that is
        not an object (validator lines ~209-211), ensuring each malformed cycle
        produces an explicit, indexed error.

    Args:
        None.

    Returns:
        None: Assertions verify the indexed must-be-an-object error is present.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["remediation_loop"] = {"cycles": ["not-a-cycle"]}

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert any("remediation cycle #0 must be an object" in error for error in errors)


def test_remediation_cycle_non_list_cycles_string_produces_no_cycle_errors() -> None:
    """A string `cycles` value produces no cycle errors (intentional pass-through).

    Purpose:
        Cover the validator branch that returns early when `cycles` is not a
        list (validator lines ~202-203). A non-list `cycles` carries no cycle
        objects to validate, so the validator intentionally produces no
        remediation-cycle errors.

    Args:
        None.

    Returns:
        None: Assertions verify no remediation-cycle error text appears.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["remediation_loop"] = {"cycles": "not-a-list"}

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert not any("remediation cycle" in error for error in errors)


def test_remediation_cycle_non_list_cycles_dict_produces_no_cycle_errors() -> None:
    """A dict `cycles` value produces no cycle errors (intentional pass-through).

    Purpose:
        Cover the validator branch that returns early when `cycles` is not a
        list (validator lines ~202-203) using a dict value. A non-list `cycles`
        carries no cycle objects to validate, so the validator intentionally
        produces no remediation-cycle errors.

    Args:
        None.

    Returns:
        None: Assertions verify no remediation-cycle error text appears.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["remediation_loop"] = {"cycles": {"unexpected": "object"}}

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert not any("remediation cycle" in error for error in errors)
