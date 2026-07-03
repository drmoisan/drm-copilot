"""Tests for the ``model_routing_receipts`` checkpoint validator.

Well-formed receipts are built from the ``resolve_delegation_model`` reference
implementation so the fixtures stay consistent with the canonical formula.
Each failure test asserts the literal, checkpoint-context-prefixed message.
"""

from __future__ import annotations

import json
from typing import Any

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_model_routing import (
    MODEL_ROUTING_RECEIPTS_KEY,
    _validate_model_routing_receipts,
)
from scripts.dev_tools.resolve_delegation_model import resolve_delegation_model
from tests.scripts.dev_tools.test_validate_orchestrator_state_remediation_loop import (
    build_valid_orchestrator_state,
)


def _receipt(agent: str, band: str, fable_policy: str) -> dict[str, Any]:
    """Build a self-consistent receipt from the reference implementation.

    Args:
        agent (str): The delegate agent name.
        band (str): The complexity band.
        fable_policy (str): The session fable policy.

    Returns:
        dict[str, Any]: A receipt whose ``table_model``, ``model``, and
        ``clamped_from`` fields are exactly the resolver output.

    Raises:
        None.

    Side Effects:
        None.
    """

    resolved = resolve_delegation_model(agent, band, fable_policy)
    return {
        "agent": agent,
        "phase": "P1",
        "complexity_band": band,
        "fable_policy": fable_policy,
        "table_model": resolved["table_model"],
        "clamped_from": resolved["clamped_from"],
        "model": resolved["model"],
    }


def test_well_formed_receipts_pass() -> None:
    """A batch of self-consistent receipts produces zero errors."""

    # Arrange: receipts spanning available base cells and a disabled clamp.
    receipts = [
        _receipt("atomic-executor", "C1", "available"),
        _receipt("atomic-executor", "C3", "disabled"),
        _receipt("atomic-executor", "C4", "disabled"),
        _receipt("atomic-planner", "C3", "preferred"),
    ]

    # Act: validate the array.
    errors = _validate_model_routing_receipts(receipts)

    # Assert: every receipt matches its resolution.
    assert errors == []


def test_model_mismatch_reported() -> None:
    """A ``model != resolve_delegation_model(...)`` receipt is reported."""

    # Arrange: C1 available resolves to haiku, but the receipt records sonnet.
    receipt = _receipt("atomic-executor", "C1", "available")
    receipt["model"] = "sonnet"

    # Act: validate the array.
    errors = _validate_model_routing_receipts([receipt])

    # Assert: the mismatch message names the recorded and expected models.
    assert any(
        "model_routing_receipts #0 model sonnet does not equal "
        "resolve_delegation_model(agent, complexity_band, fable_policy) haiku." in error
        for error in errors
    )


def test_disabled_mode_model_fable_reported() -> None:
    """A ``disabled``-mode receipt recording ``model == fable`` is reported."""

    # Arrange: force a fable model under disabled, which is prohibited.
    receipt = _receipt("atomic-executor", "C4", "disabled")
    receipt["table_model"] = "fable"
    receipt["clamped_from"] = "fable"
    receipt["model"] = "fable"

    # Act: validate the array.
    errors = _validate_model_routing_receipts([receipt])

    # Assert: the disabled-mode fable-prohibition message is present.
    assert any(
        "model_routing_receipts #0 model must not be fable under fable_policy "
        "disabled." in error
        for error in errors
    )


def test_disabled_mode_fable_cell_without_clamp_reported() -> None:
    """A ``disabled`` fable cell not recording the clamp is reported."""

    # Arrange: table_model fable and model opus, but clamped_from omitted.
    receipt = _receipt("atomic-executor", "C4", "disabled")
    receipt["table_model"] = "fable"
    receipt["model"] = "opus"
    receipt["clamped_from"] = None

    # Act: validate the array.
    errors = _validate_model_routing_receipts([receipt])

    # Assert: the missing-clamp-provenance message is present.
    assert any(
        "model_routing_receipts #0 table_model fable under fable_policy "
        "disabled must record clamped_from fable and model opus." in error
        for error in errors
    )


def test_band_enum_violation_reported() -> None:
    """An out-of-enum complexity_band is reported before resolution runs."""

    # Arrange: a receipt whose band is outside C1..C4.
    receipt = _receipt("atomic-executor", "C1", "available")
    receipt["complexity_band"] = "C9"

    # Act: validate the array.
    errors = _validate_model_routing_receipts([receipt])

    # Assert: the band-enum message is present.
    assert any(
        "model_routing_receipts #0 complexity_band must be one of C1, C2, C3, "
        "C4; got: C9." in error
        for error in errors
    )


def test_non_list_value_reported() -> None:
    """A present-but-non-list value is reported as a malformed block."""

    # Arrange / Act: a non-list value under the key.
    errors = _validate_model_routing_receipts({"not": "a list"})

    # Assert: the malformed-block message is present.
    assert any(
        "model_routing_receipts must be a list when present." in error
        for error in errors
    )


def test_non_object_entry_reported() -> None:
    """A non-object receipt entry is reported with its index."""

    # Arrange / Act: an array whose sole entry is not an object.
    errors = _validate_model_routing_receipts(["not-an-object"])

    # Assert: the per-index object message is present.
    assert any(
        "model_routing_receipts #0 must be an object." in error for error in errors
    )


def _state_with_receipts(receipts: object) -> str:
    """Return checkpoint JSON carrying a top-level ``model_routing_receipts``.

    Args:
        receipts (object): The value to embed under the key.

    Returns:
        str: Serialized checkpoint JSON including the additive key.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk (via the base checkpoint fixture).
    """

    state = build_valid_orchestrator_state()
    state["model_routing_receipts"] = receipts
    return json.dumps(state)


def test_no_model_routing_receipts_is_backward_compatible() -> None:
    """A checkpoint with no model_routing_receipts validates exactly as before."""

    # Arrange: a valid step-based checkpoint that omits the additive key.
    state = build_valid_orchestrator_state()
    assert "model_routing_receipts" not in state

    # Act: validate the checkpoint through the public validator.
    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    # Assert: no errors at all, and no model_routing_receipts error text.
    assert errors == []
    assert not any("model_routing_receipts" in error for error in errors)


def test_present_well_formed_receipts_wired_through_public_validator() -> None:
    """A present well-formed array produces no model_routing_receipts errors."""

    # Arrange / Act: embed a well-formed receipt and validate end to end.
    errors = state_validator.validate_orchestrator_state_text(
        _state_with_receipts([_receipt("atomic-executor", "C1", "available")])
    )

    # Assert: the key-gated block runs but reports no error for valid data.
    assert not any("model_routing_receipts" in error for error in errors)


def test_present_malformed_receipts_caught_by_public_validator() -> None:
    """A present malformed array is caught through the public validator."""

    # Arrange: a receipt whose model contradicts its resolution.
    receipt = _receipt("atomic-executor", "C1", "available")
    receipt["model"] = "sonnet"

    # Act: validate through the public validator.
    errors = state_validator.validate_orchestrator_state_text(
        _state_with_receipts([receipt])
    )

    # Assert: the malformed data is reported via the wired block.
    assert any(
        "model_routing_receipts #0 model sonnet does not equal" in error
        for error in errors
    )


def test_key_constant_value() -> None:
    """The exported key constant matches the checkpoint field name."""

    # Assert: the constant is the expected checkpoint key.
    assert MODEL_ROUTING_RECEIPTS_KEY == "model_routing_receipts"
