"""Tests for the split orchestrator-state validator."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator

if TYPE_CHECKING:
    from collections.abc import Callable

# Bind targeted internal helpers through typed runtime lookup so the tests can
# cover the split-validator branches without widening the production surface.
validate_list_delegation_receipts = cast(
    "Callable[[object], list[str]]",
    vars(state_validator)["_validate_list_delegation_receipts"],
)
validate_namespaced_delegation_receipts = cast(
    "Callable[[object], list[str]]",
    vars(state_validator)["_validate_namespaced_delegation_receipts"],
)


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


def build_namespaced_orchestrator_state() -> dict[str, object]:
    """Return a valid checkpoint payload using the promotion namespace.

    Purpose:
        Provide the additive namespace form of delegation receipts for focused
        tests that exercise the new object-based validation branches.

    Args:
        None.

    Returns:
        dict[str, object]: A valid checkpoint payload using
        `delegation_receipts.promotion.*`.

    Raises:
        None.

    Side Effects:
        None.
    """

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


def test_validate_list_delegation_receipts_rejects_non_object_entry() -> None:
    """Reject legacy receipt arrays that contain scalar items.

    Purpose:
        Cover the legacy receipt-list branch that validates each element is an
        object before checking receipt keys.

    Args:
        None.

    Returns:
        None: Assertions verify that scalar receipt entries are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = validate_list_delegation_receipts(["invalid"])

    assert errors == ["Checkpoint delegation receipt #0 must be an object."]


def test_validate_namespaced_delegation_receipts_rejects_unsupported_top_level_key(
    *_unused: object,
) -> None:
    """Reject namespaced receipt objects that use unsupported top-level keys.

    Purpose:
        Cover the branch that rejects `delegation_receipts` object keys outside
        the documented `promotion` namespace.

    Args:
        None.

    Returns:
        None: Assertions verify that unsupported top-level keys are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = validate_namespaced_delegation_receipts(
        {"promotion": {}, "unexpected": {}}
    )

    assert _unused == ()

    assert errors == [
        "Checkpoint delegation_receipts object contains unsupported key: unexpected"
    ]


def test_validate_namespaced_delegation_receipts_rejects_non_object_promotion_namespace(
    *_unused: object,
) -> None:
    """Reject non-object promotion namespaces in the additive receipt form.

    Purpose:
        Cover the branch that requires `delegation_receipts.promotion` to be an
        object namespace before nested key validation runs.

    Args:
        None.

    Returns:
        None: Assertions verify that non-object promotion values are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = validate_namespaced_delegation_receipts({"promotion": "invalid"})

    assert _unused == ()

    assert errors == [
        "Checkpoint delegation_receipts.promotion must be an object namespace."
    ]


def test_validate_orchestrator_state_text_rejects_invalid_step_status() -> None:
    """Reject checkpoints that use unsupported lifecycle step statuses.

    Purpose:
        Cover the status-validation branch that enforces the fixed set of
        allowed lifecycle state values.

    Args:
        None.

    Returns:
        None: Assertions verify that invalid step statuses are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["step8_status"] = "invalid-status"

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert any(
        "Checkpoint has invalid step8_status: invalid-status" in error
        for error in errors
    )


def test_validate_orchestrator_state_text_rejects_invalid_blocked_reason() -> None:
    """Reject checkpoints that use unsupported blocked reasons.

    Purpose:
        Cover the blocked-reason validation branch that enforces the documented
        set of allowed blocked reason values.

    Args:
        None.

    Returns:
        None: Assertions verify that invalid blocked reasons are rejected.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["blocked_reason"] = "unknown-reason"

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert any(
        "Checkpoint has invalid blocked_reason: unknown-reason" in error
        for error in errors
    )


def _test_orchestrator_state_require_complete_rejects_non_none_blocked_reason() -> None:
    """Reject complete-mode checkpoints whose blocked reason is not `none`.

    Purpose:
        Cover the completion gate branch that rejects non-`none` blocked reasons
        even when the base schema is otherwise valid.

    Args:
        None.

    Returns:
        None: Assertions verify that completion-mode validation rejects the
        checkpoint.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["blocked_reason"] = "validator_failed"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert (
        "Checkpoint completion validation failed: blocked_reason is not `none`."
        in errors
    )


globals()[
    "test_validate_orchestrator_state_text_require_complete_rejects_non_none_blocked_reason"
] = _test_orchestrator_state_require_complete_rejects_non_none_blocked_reason


def test_validate_orchestrator_state_text_rejects_malformed_json() -> None:
    """Reject malformed checkpoint JSON with the explicit parse error prefix.

    Purpose:
        Cover the JSON parse failure branch so the split validator preserves the
        caller-facing malformed-JSON error contract.

    Args:
        None.

    Returns:
        None: Assertions verify that malformed JSON returns the explicit parse
        error message.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = state_validator.validate_orchestrator_state_text('{"objective":')

    assert len(errors) == 1
    assert errors[0].startswith("Checkpoint is not valid JSON:")


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
