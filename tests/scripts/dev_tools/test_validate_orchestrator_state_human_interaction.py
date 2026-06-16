"""Tests for the human_interaction branch of the orchestrator-state validator.

These tests cover the additive ``human_interaction`` validation path in
`scripts.dev_tools.validate_orchestrator_state`, including the backward-compatible
no-``human_interaction`` case and the three invariants (required ``requirements``
list, per-requirement ``response`` enum membership, and the
exception-requires-``runbook_path`` conditional). They mirror the structure of
`test_validate_orchestrator_state_remediation_loop.py` and are kept in a sibling
module to respect the 500-line file-size cap.
"""

from __future__ import annotations

import json

import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.test_validate_orchestrator_state_remediation_loop import (
    build_valid_orchestrator_state,
)


def _state_with_human_interaction(human_interaction: object) -> str:
    """Return checkpoint JSON carrying a top-level ``human_interaction`` value.

    Purpose:
        Wrap a ``human_interaction`` value in an otherwise-valid checkpoint so
        the public validator exercises the additive ``human_interaction`` branch.

    Args:
        human_interaction (object): The ``human_interaction`` value to embed
            (object, list, or scalar) for the branch under test.

    Returns:
        str: Serialized checkpoint JSON including the ``human_interaction`` key.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["human_interaction"] = human_interaction
    return json.dumps(state)


def test_no_human_interaction_is_backward_compatible() -> None:
    """A checkpoint with no human_interaction validates exactly as before.

    Purpose:
        Guard the additive change: a valid step-based checkpoint with no
        ``human_interaction`` key must produce no errors and no
        ``human_interaction`` error text.

    Args:
        None.

    Returns:
        None: Assertions verify no errors are produced.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    assert "human_interaction" not in state

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert errors == []
    assert not any("human_interaction" in error for error in errors)


def test_human_interaction_non_object_is_rejected() -> None:
    """A non-object human_interaction value is rejected when the key is present."""

    errors = state_validator.validate_orchestrator_state_text(
        _state_with_human_interaction("not-an-object")
    )

    assert any(
        "human_interaction must be an object when present" in error for error in errors
    )


def test_human_interaction_missing_requirements_is_rejected() -> None:
    """A human_interaction without a requirements list is rejected."""

    errors = state_validator.validate_orchestrator_state_text(
        _state_with_human_interaction({"note": "no requirements here"})
    )

    assert any(
        "human_interaction.requirements must be a list" in error for error in errors
    )


def test_human_interaction_non_object_requirement_is_rejected() -> None:
    """A non-object requirement entry is rejected with the indexed error."""

    errors = state_validator.validate_orchestrator_state_text(
        _state_with_human_interaction({"requirements": ["not-a-requirement"]})
    )

    assert any(
        "human_interaction.requirements #0 must be an object" in error
        for error in errors
    )


def test_human_interaction_response_outside_enum_is_rejected() -> None:
    """A requirement response outside the permitted enum is rejected."""

    errors = state_validator.validate_orchestrator_state_text(
        _state_with_human_interaction({"requirements": [{"response": "maybe"}]})
    )

    assert any(
        "response must be one of scope_change, exception, halt; got: maybe" in error
        for error in errors
    )


def test_human_interaction_exception_without_runbook_path_is_rejected() -> None:
    """An exception response with an empty runbook_path is rejected."""

    errors = state_validator.validate_orchestrator_state_text(
        _state_with_human_interaction(
            {"requirements": [{"response": "exception", "runbook_path": "   "}]}
        )
    )

    assert any(
        "response is exception but runbook_path is missing or empty" in error
        for error in errors
    )


def test_human_interaction_exception_missing_runbook_path_is_rejected() -> None:
    """An exception response with no runbook_path key is rejected."""

    errors = state_validator.validate_orchestrator_state_text(
        _state_with_human_interaction({"requirements": [{"response": "exception"}]})
    )

    assert any(
        "response is exception but runbook_path is missing or empty" in error
        for error in errors
    )


def test_human_interaction_well_formed_produces_no_errors() -> None:
    """A scope_change plus a runbook-backed exception produces no new errors.

    Purpose:
        Confirm a well-formed ``human_interaction`` block - a ``scope_change``
        requirement and an ``exception`` requirement with a non-empty
        ``runbook_path`` - passes all three invariants.

    Args:
        None.

    Returns:
        None: Assertions verify no human_interaction error text appears.

    Raises:
        None.

    Side Effects:
        None.
    """

    human_interaction = {
        "requirements": [
            {"id": "r1", "response": "scope_change"},
            {
                "id": "r2",
                "response": "exception",
                "runbook_path": (
                    "docs/features/active/feature-1/runbooks/admin-consent.runbook.md"
                ),
            },
        ]
    }

    errors = state_validator.validate_orchestrator_state_text(
        _state_with_human_interaction(human_interaction)
    )

    assert not any("human_interaction" in error for error in errors)
