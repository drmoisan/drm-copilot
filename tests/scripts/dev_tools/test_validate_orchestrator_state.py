"""Tests for the split orchestrator-state validator."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.validate_orchestrator_state_test_support import (
    build_portable_envelope,
    build_portable_projection,
    build_valid_orchestrator_state,
)

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


def test_require_complete_rejects_pr_gate_required_route_without_pr_gate() -> None:
    """Reject completion when a pr-gate route omits PR evidence.

    Purpose:
        Cover the route-driven completion gate requiring `pr_gate` evidence for
        a route whose `requires_pr_gate` is True (the `large` route), with no
        issue-number special-casing.

    Args:
        None.

    Returns:
        None: Assertions verify that missing PR evidence is reported.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    # Any issue number; route is `large`, which requires the PR gate.
    state["issue-num"] = "999"
    state["blocked_reason"] = "none"

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("pr_gate" in error for error in errors)


def test_require_complete_skips_pr_gate_for_non_pr_gate_route() -> None:
    """Do not require PR evidence for a route without `requires_pr_gate`.

    Purpose:
        Cover the route-driven completion gate returning no `pr_gate` errors for
        the `small` route, which does not opt into the PR gate.

    Args:
        None.

    Returns:
        None: Assertions verify that no `pr_gate` error is produced.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["path_selected"] = "small"
    state["issue-num"] = "123"
    state["blocked_reason"] = "none"
    # Provide ci_gate so any ci-gate errors do not mask the pr_gate assertion.
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("pr_gate" in error for error in errors)


def test_require_complete_emits_no_issue_232_branch_error_for_any_issue() -> None:
    """Confirm no issue-232 branch-name error is produced for any issue number.

    Purpose:
        Cover the removal of the `ISSUE_232_BRANCH` head-branch check; a PR with
        an arbitrary head branch must not produce a branch-name completion error.

    Args:
        None.

    Returns:
        None: Assertions verify that no head_branch branch-name error is
        reported for an arbitrary branch.

    Raises:
        None.

    Side Effects:
        None.
    """

    state = build_valid_orchestrator_state()
    state["issue-num"] = "232"
    state["pr_gate"] = {
        "pr_number": 232,
        "pr_url": "https://github.com/drmoisan/drm-copilot/pull/232",
        "head_branch": "feature/any-arbitrary-branch",
        "head_sha": "current-head-sha",
    }
    state["ci_gate"] = {
        "conclusion": "success",
        "head_sha": "current-head-sha",
        "verified_at": "2026-06-25T07:45:00Z",
    }

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert not any("head_branch" in error for error in errors)


def test_native_orchestrator_state_validation_remains_compatible() -> None:
    """Accept the unchanged provider-native checkpoint representation."""

    state = build_valid_orchestrator_state()

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert errors == []


def test_validate_orchestrator_state_accepts_portable_envelope() -> None:
    """Accept a valid portable envelope as a checkpoint artifact."""

    envelope = build_portable_envelope()

    errors = state_validator.validate_orchestrator_state_text(json.dumps(envelope))

    assert errors == []


def test_validate_orchestrator_state_rejects_malformed_portable_envelope() -> None:
    """Reject a portable envelope that omits its source provenance."""

    envelope = build_portable_envelope()
    del envelope["source"]

    errors = state_validator.validate_orchestrator_state_text(json.dumps(envelope))

    assert any("Portable handoff envelope is invalid" in error for error in errors)


def test_validate_orchestrator_state_accepts_portable_projection() -> None:
    """Accept a native destination checkpoint with a portable handoff link."""

    projection = build_portable_projection()

    errors = state_validator.validate_orchestrator_state_text(json.dumps(projection))

    assert errors == []


def test_validate_orchestrator_state_rejects_invalid_projection_digest() -> None:
    """Reject a portable link with a non-SHA-256 envelope digest."""

    projection = build_portable_projection()
    portable_link = cast("dict[str, object]", projection["portable_handoff"])
    portable_link["envelope_sha256"] = "invalid"

    errors = state_validator.validate_orchestrator_state_text(json.dumps(projection))

    assert any(
        "Portable destination projection is invalid" in error for error in errors
    )


def test_validate_orchestrator_state_rejects_portable_projection_drift() -> None:
    """Reject a portable link whose native next step differs from its lifecycle."""

    projection = build_portable_projection()
    projection["next_step"] = "qa"

    errors = state_validator.validate_orchestrator_state_text(json.dumps(projection))

    assert any(
        "Portable destination projection is invalid" in error for error in errors
    )
