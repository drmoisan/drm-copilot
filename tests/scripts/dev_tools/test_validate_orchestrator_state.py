"""Tests for the split orchestrator-state validator."""

from __future__ import annotations

import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.orchestrator_state_test_support import (
    BLOCKER_FINGERPRINT_A,
    BLOCKER_FINGERPRINT_B,
    build_exception_binding,
    build_legacy_remediation_cycle,
    build_remediation_attempt,
    build_remediation_cycle,
    build_remediation_loop,
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

SHARED_REMEDIATION_FIXTURE_DIR = (
    Path(__file__).resolve().parents[2]
    / "fixtures"
    / "orchestration"
    / "remediation-loop-v2"
)


def _load_shared_remediation_fixtures() -> list[dict[str, object]]:
    """Load the committed cross-runtime remediation corpus in name order."""

    fixtures: list[dict[str, object]] = []
    for fixture_path in sorted(SHARED_REMEDIATION_FIXTURE_DIR.glob("*.json")):
        value = json.loads(fixture_path.read_text(encoding="utf-8"))
        assert isinstance(value, dict)
        fixtures.append(cast("dict[str, object]", value))
    assert fixtures
    return fixtures


def test_validate_list_delegation_receipts_rejects_non_object_entry() -> None:
    """Reject legacy receipt arrays that contain scalar items."""

    errors = validate_list_delegation_receipts(["invalid"])

    assert errors == ["Checkpoint delegation receipt #0 must be an object."]


def test_validate_namespaced_delegation_receipts_rejects_unsupported_top_level_key(
    *_unused: object,
) -> None:
    """Reject namespaced receipts with unsupported top-level keys."""

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
    """Reject non-object promotion namespaces in additive receipts."""

    errors = validate_namespaced_delegation_receipts({"promotion": "invalid"})

    assert _unused == ()

    assert errors == [
        "Checkpoint delegation_receipts.promotion must be an object namespace."
    ]


def test_validate_orchestrator_state_text_rejects_invalid_step_status() -> None:
    """Reject checkpoints that use unsupported lifecycle step statuses."""

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


def test_non_actionable_review_does_not_create_cycle() -> None:
    """Keep non-actionable review results outside completed cycles."""

    valid_state = build_valid_orchestrator_state()
    valid_state["remediation_loop"] = build_remediation_loop(
        status="blocked_external_runtime"
    )
    invalid_state = build_valid_orchestrator_state()
    invalid_state["remediation_loop"] = build_remediation_loop(
        status="blocked_external_runtime",
        cycles=[
            build_remediation_cycle(
                review_verdict="BLOCKED",
                remediation_action="EXTERNAL_RUNTIME",
                blocker_fingerprint_after=BLOCKER_FINGERPRINT_B,
                blocking_count=1,
                exit_condition_met=False,
            )
        ],
    )

    valid_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(valid_state)
    )
    invalid_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(invalid_state)
    )

    assert valid_errors == []
    assert invalid_errors == [
        "ORCH_REMEDIATION_TRANSITION: remediation_loop.cycles[0].attempt_id "
        "references missing attempt 1."
    ]


def test_no_candidate_attempt_does_not_complete_cycle() -> None:
    """Keep a no-candidate attempt outside completed cycles."""

    attempt = build_remediation_attempt(
        candidate_applied=False,
        terminal_disposition="no_candidate",
    )
    valid_state = build_valid_orchestrator_state()
    valid_state["remediation_loop"] = build_remediation_loop(
        status="blocked_no_candidate", attempts=[attempt]
    )
    invalid_state = build_valid_orchestrator_state()
    invalid_state["remediation_loop"] = build_remediation_loop(
        status="blocked_no_candidate",
        attempts=[attempt],
        cycles=[
            build_remediation_cycle(
                review_verdict="BLOCKED",
                remediation_action="NO_CANDIDATE",
                blocker_fingerprint_after=BLOCKER_FINGERPRINT_B,
                blocking_count=1,
                exit_condition_met=False,
            )
        ],
    )

    valid_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(valid_state)
    )
    invalid_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(invalid_state)
    )

    assert valid_errors == []
    assert invalid_errors == [
        "ORCH_REMEDIATION_TRANSITION: remediation_loop.cycles[0].attempt_id "
        "candidate_applied must be true."
    ]


def test_completed_cycle_counts_and_sequences_are_canonical() -> None:
    """Report noncanonical counts and identifiers in deterministic order."""

    state = build_valid_orchestrator_state()
    state["remediation_loop"] = build_remediation_loop(
        attempts=[build_remediation_attempt(attempt_id=2)],
        cycles=[build_remediation_cycle(cycle_id=2, attempt_id=2)],
        attempt_count=2,
        completed_cycle_count=2,
    )

    errors = state_validator.validate_orchestrator_state_text(json.dumps(state))

    assert errors == [
        "ORCH_REMEDIATION_COUNT: remediation_loop.attempt_count must equal "
        "attempts length 1.",
        "ORCH_REMEDIATION_SEQUENCE: remediation_loop attempt_id sequence must "
        "be [1]; received [2].",
        "ORCH_REMEDIATION_COUNT: remediation_loop.completed_cycle_count must "
        "equal cycles length 1.",
        "ORCH_REMEDIATION_SEQUENCE: remediation_loop cycle_id sequence must be "
        "[1]; received [2].",
    ]


def test_unchanged_fingerprint_stops_for_stagnation() -> None:
    """Require the stagnation terminal status for unchanged blockers."""

    attempt = build_remediation_attempt()
    cycle = build_remediation_cycle(
        review_verdict="BLOCKED",
        remediation_action="AUTONOMOUS",
        blocker_fingerprint_after=BLOCKER_FINGERPRINT_A,
        blocking_count=1,
        exit_condition_met=False,
    )
    invalid_state = build_valid_orchestrator_state()
    invalid_state["remediation_loop"] = build_remediation_loop(
        status="active", attempts=[attempt], cycles=[cycle]
    )
    valid_state = build_valid_orchestrator_state()
    valid_state["remediation_loop"] = build_remediation_loop(
        status="blocked_stagnation", attempts=[attempt], cycles=[cycle]
    )

    invalid_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(invalid_state)
    )
    valid_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(valid_state)
    )

    assert invalid_errors == [
        "ORCH_REMEDIATION_STAGNATION: remediation_loop.status must be "
        "blocked_stagnation for unchanged blockers."
    ]
    assert valid_errors == []


def test_exception_binding_is_single_use() -> None:
    """Reject reused exception identifiers in deterministic error order."""

    first_attempt = build_remediation_attempt()
    first_cycle = build_remediation_cycle(
        review_verdict="BLOCKED",
        remediation_action="AUTONOMOUS",
        blocker_fingerprint_after=BLOCKER_FINGERPRINT_A,
        blocking_count=1,
        exit_condition_met=False,
    )
    second_attempt = build_remediation_attempt(
        attempt_id=2,
        exception_binding=build_exception_binding(attempt_id=2),
    )
    valid_state = build_valid_orchestrator_state()
    valid_state["remediation_loop"] = build_remediation_loop(
        status="active",
        attempts=[first_attempt, second_attempt],
        cycles=[first_cycle],
    )
    second_cycle = build_remediation_cycle(
        cycle_id=2,
        attempt_id=2,
        review_verdict="BLOCKED",
        remediation_action="AUTONOMOUS",
        blocker_fingerprint_after=BLOCKER_FINGERPRINT_A,
        blocking_count=1,
        exit_condition_met=False,
    )
    third_attempt = build_remediation_attempt(
        attempt_id=3,
        exception_binding=build_exception_binding(attempt_id=3),
    )
    invalid_state = build_valid_orchestrator_state()
    invalid_state["remediation_loop"] = build_remediation_loop(
        status="active",
        attempts=[first_attempt, second_attempt, third_attempt],
        cycles=[first_cycle, second_cycle],
    )

    valid_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(valid_state)
    )
    invalid_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(invalid_state)
    )

    assert valid_errors == []
    assert invalid_errors == [
        "ORCH_EXCEPTION_BINDING_REUSED: exception_id exception-1 must be "
        "consumed only once.",
        "ORCH_REMEDIATION_STAGNATION: remediation_loop.cycles[0] unchanged "
        "blockers forbid another attempt or cycle.",
        "ORCH_REMEDIATION_STAGNATION: remediation_loop.cycles[1] unchanged "
        "blockers forbid another attempt or cycle.",
    ]


def test_legacy_remediation_requires_evidence_backed_migration() -> None:
    """Require version-2 migration only when strict validation is selected."""

    state = build_valid_orchestrator_state()
    state["remediation_loop"] = {"cycles": [build_legacy_remediation_cycle()]}

    compatible_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state)
    )
    strict_errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), strict_route_membership=True
    )

    assert compatible_errors == []
    assert strict_errors == [
        "ORCH_REMEDIATION_SCHEMA: legacy remediation_loop requires evidence-backed "
        "schema version 2 migration before strict validation."
    ]


def test_shared_remediation_loop_v2_results_are_byte_stable() -> None:
    """Match shared success and error records byte-for-byte across runtimes."""

    for fixture in _load_shared_remediation_fixtures():
        name = fixture["name"]
        expected_errors = fixture["expected_errors"]
        assert isinstance(name, str)
        assert isinstance(expected_errors, list)
        assert all(
            isinstance(error, str) for error in cast("list[object]", expected_errors)
        )
        typed_expected_errors = cast("list[str]", expected_errors)
        state = build_valid_orchestrator_state()
        state["remediation_loop"] = fixture["loop"]

        errors = state_validator.validate_orchestrator_state_text(json.dumps(state))
        normalized = json.dumps({"name": name, "errors": errors}, separators=(",", ":"))

        assert errors == typed_expected_errors
        assert normalized == fixture["expected_normalized"]
