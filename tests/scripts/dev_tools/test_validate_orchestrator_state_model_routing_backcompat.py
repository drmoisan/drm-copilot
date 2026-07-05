"""Backward-compatibility regression guard for the require_model_routing gate.

These tests assert that adding the `require_model_routing` mode does not perturb
any existing call form. The plain, `require_complete`, and
`require_pr_creation_ready` calls must return byte-identical error lists whether
or not the optional `model_routing_receipts` / `complexity_assessments` arrays
are present, and the model-routing gate must not fire unless the caller passes
`require_model_routing=True`. The valid base checkpoint is reused from the
remediation-loop test module.
"""

from __future__ import annotations

import json

import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.test_validate_orchestrator_state_remediation_loop import (
    build_valid_orchestrator_state,
)

# Substrings that only the require_model_routing gate produces; their absence in
# a non-flag call proves the gate did not fire.
_GATE_ONLY_SUBSTRINGS = (
    "missing a receipt for delegated agent",
    "complexity_assessments is missing an entry for phase",
)


def _consistent_routing_arrays() -> dict[str, object]:
    """Return the routing arrays consistent with the base delegation.

    Purpose:
        Provide a `model_routing_receipts` / `complexity_assessments` pair
        consistent with the base checkpoint's single `atomic-planner` step-7
        delegation, so adding them introduces no per-entry errors.

    Args:
        None.

    Returns:
        dict[str, object]: A mapping with both routing arrays.

    Raises:
        None.

    Side Effects:
        None.
    """

    return {
        "model_routing_receipts": [
            {
                "agent": "atomic-planner",
                "phase": "7",
                "complexity_band": "C3",
                "fable_policy": "disabled",
                "table_model": "opus",
                "clamped_from": None,
                "model": "opus",
            }
        ],
        "complexity_assessments": [
            {
                "phase": "7",
                "band": "C3",
                "floor": "C3",
                "signals_present": ["cross_module_contract_change"],
                "rationale": "cross-module contract change",
                "assessed_at": "2026-07-04T09:00:00-04:00",
            }
        ],
    }


def _with_arrays_text() -> str:
    """Return checkpoint JSON that includes the consistent routing arrays.

    Args:
        None.

    Returns:
        str: Serialized checkpoint text with both routing arrays present.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state.update(_consistent_routing_arrays())
    return json.dumps(state)


def _without_arrays_text() -> str:
    """Return checkpoint JSON that omits the routing arrays.

    Args:
        None.

    Returns:
        str: Serialized checkpoint text without the routing arrays.

    Raises:
        None.

    Side Effects:
        None.
    """

    return json.dumps(build_valid_orchestrator_state())


def test_plain_call_byte_identical_with_and_without_arrays() -> None:
    """Plain calls return identical errors regardless of the routing arrays.

    Purpose:
        Confirm that adding consistent routing arrays does not change the plain
        validator output.

    Args:
        None.

    Returns:
        None: Assertions verify list equality.

    Raises:
        None.

    Side Effects:
        None.
    """

    assert state_validator.validate_orchestrator_state_text(
        _with_arrays_text()
    ) == state_validator.validate_orchestrator_state_text(_without_arrays_text())


def test_require_complete_byte_identical_with_and_without_arrays() -> None:
    """`require_complete` calls are unchanged by the routing arrays.

    Purpose:
        Confirm the completion gate output is identical whether or not the
        optional routing arrays are present.

    Args:
        None.

    Returns:
        None: Assertions verify list equality.

    Raises:
        None.

    Side Effects:
        None.
    """

    assert state_validator.validate_orchestrator_state_text(
        _with_arrays_text(), require_complete=True
    ) == state_validator.validate_orchestrator_state_text(
        _without_arrays_text(), require_complete=True
    )


def test_require_pr_creation_ready_byte_identical_with_and_without_arrays() -> None:
    """`require_pr_creation_ready` calls are unchanged by the routing arrays.

    Purpose:
        Confirm the pre-PR-creation readiness output is identical whether or not
        the optional routing arrays are present.

    Args:
        None.

    Returns:
        None: Assertions verify list equality.

    Raises:
        None.

    Side Effects:
        None.
    """

    assert state_validator.validate_orchestrator_state_text(
        _with_arrays_text(), require_pr_creation_ready=True
    ) == state_validator.validate_orchestrator_state_text(
        _without_arrays_text(), require_pr_creation_ready=True
    )


def test_gate_does_not_fire_without_flag_on_delegation_bearing_checkpoint() -> None:
    """The gate stays inert unless `require_model_routing` is passed.

    Purpose:
        Confirm a delegation-bearing checkpoint that lacks routing arrays emits
        no gate-specific error under the plain, `require_complete`, and
        `require_pr_creation_ready` forms.

    Args:
        None.

    Returns:
        None: Assertions verify no gate-only substring appears.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = _without_arrays_text()

    # Exercise each legacy form; none may surface a gate-only error string.
    for errors in (
        state_validator.validate_orchestrator_state_text(text),
        state_validator.validate_orchestrator_state_text(text, require_complete=True),
        state_validator.validate_orchestrator_state_text(
            text, require_pr_creation_ready=True
        ),
    ):
        assert not any(
            substring in error
            for error in errors
            for substring in _GATE_ONLY_SUBSTRINGS
        )


def test_require_model_routing_false_equals_omitted() -> None:
    """Passing `require_model_routing=False` equals omitting it entirely.

    Purpose:
        Document and guard the default-off contract: the explicit False and the
        omitted keyword produce byte-identical results across call forms.

    Args:
        None.

    Returns:
        None: Assertions verify list equality for each form.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = _with_arrays_text()

    assert state_validator.validate_orchestrator_state_text(
        text, require_model_routing=False
    ) == state_validator.validate_orchestrator_state_text(text)
    assert state_validator.validate_orchestrator_state_text(
        text, require_complete=True, require_model_routing=False
    ) == state_validator.validate_orchestrator_state_text(text, require_complete=True)
