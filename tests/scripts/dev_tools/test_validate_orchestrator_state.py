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
