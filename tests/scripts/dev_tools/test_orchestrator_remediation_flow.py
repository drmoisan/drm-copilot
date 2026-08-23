"""In-process integration coverage for orchestrator remediation transitions."""

from __future__ import annotations

import copy
import json
from typing import cast

import pytest

from scripts.dev_tools._orchestrator_state_remediation_transitions import (
    FALSE_CANDIDATE_EXECUTION_BY_DISPOSITION,
    FALSE_CANDIDATE_STATUS_BY_DISPOSITION,
    NON_ACTIONABLE_STATUS_BY_ACTION,
)
from scripts.dev_tools.validate_orchestrator_state import (
    validate_orchestrator_state_text,
)
from tests.scripts.dev_tools.orchestrator_state_test_support import (
    BLOCKER_FINGERPRINT_A,
    BLOCKER_FINGERPRINT_B,
    build_exception_binding,
    build_remediation_attempt,
    build_remediation_cycle,
    build_remediation_loop,
    build_valid_orchestrator_state,
)

PROHIBITED_TOP_LEVEL_OUTPUTS = frozenset(
    {
        "remediation-inputs-path",
        "remediation-plan-path",
        "staged-paths",
        "commit-context-path",
        "commit-sha",
        "re-audit-path",
        "spawned-mcp-output",
    }
)


def _validate_without_mutation(state: dict[str, object]) -> list[str]:
    """Validate serialized state and prove the imported validator stays pure."""

    before = copy.deepcopy(state)
    errors = validate_orchestrator_state_text(json.dumps(state))
    assert state == before
    return errors


def _assert_no_top_level_outputs(state: dict[str, object]) -> None:
    """Reject orchestration side-effect fields in pre-mutation scenarios."""

    assert PROHIBITED_TOP_LEVEL_OUTPUTS.isdisjoint(state)


def test_pass_none_does_not_create_remediation_outputs() -> None:
    """Leave PASS/NONE resolved without a plan, attempt, cycle, or side effect."""

    state = build_valid_orchestrator_state()
    state["remediation_loop"] = build_remediation_loop(status="resolved")

    errors = _validate_without_mutation(state)

    loop = state["remediation_loop"]
    assert errors == []
    assert loop["attempt_count"] == 0
    assert loop["completed_cycle_count"] == 0
    assert loop["attempts"] == []
    assert loop["cycles"] == []
    _assert_no_top_level_outputs(state)


@pytest.mark.parametrize(
    ("action", "status"),
    (
        ("NO_CANDIDATE", "blocked_no_candidate"),
        ("EXTERNAL_RUNTIME", "blocked_external_runtime"),
        ("AWAITING_CI", "awaiting_ci"),
        ("HUMAN_DECISION", "blocked_human_decision"),
    ),
)
def test_non_actionable_review_stops_before_r1_without_outputs(
    action: str, status: str
) -> None:
    """Keep each non-actionable BLOCKED action outside remediation execution."""

    state = build_valid_orchestrator_state()
    state["remediation_loop"] = build_remediation_loop(status=status)

    errors = _validate_without_mutation(state)

    loop = state["remediation_loop"]
    assert NON_ACTIONABLE_STATUS_BY_ACTION[action] == status
    assert errors == []
    assert loop["attempt_count"] == 0
    assert loop["completed_cycle_count"] == 0
    assert loop["attempts"] == []
    assert loop["cycles"] == []
    _assert_no_top_level_outputs(state)


@pytest.mark.parametrize(
    ("disposition", "execution_status", "status"),
    (
        ("no_candidate", "complete", "blocked_no_candidate"),
        ("external_runtime", "blocked", "blocked_external_runtime"),
        ("awaiting_ci", "awaiting_ci", "awaiting_ci"),
        ("human_decision", "blocked", "blocked_human_decision"),
        ("execution_failed", "failed", "blocked_no_candidate"),
    ),
)
def test_false_candidate_records_attempt_without_post_candidate_outputs(
    disposition: str, execution_status: str, status: str
) -> None:
    """Record a terminal R3 attempt without staging, commit, R4, or a cycle."""

    attempt = build_remediation_attempt(
        execution_status=execution_status,
        candidate_applied=False,
        terminal_disposition=disposition,
    )
    state = build_valid_orchestrator_state()
    state["remediation_loop"] = build_remediation_loop(
        status=status, attempts=[attempt]
    )

    errors = _validate_without_mutation(state)

    loop = state["remediation_loop"]
    assert FALSE_CANDIDATE_EXECUTION_BY_DISPOSITION[disposition] == execution_status
    assert FALSE_CANDIDATE_STATUS_BY_DISPOSITION[disposition] == status
    assert errors == []
    assert loop["attempt_count"] == 1
    assert loop["completed_cycle_count"] == 0
    assert loop["cycles"] == []
    assert "commit_sha" not in attempt
    assert "re_audit_path" not in attempt
    _assert_no_top_level_outputs(state)


def test_applied_candidate_completes_cycle_only_after_commit_and_r4() -> None:
    """Link one cycle only after its applied attempt has commit and R4 evidence."""

    attempt = build_remediation_attempt()
    attempt_only = build_valid_orchestrator_state()
    attempt_only["remediation_loop"] = build_remediation_loop(
        status="active", attempts=[attempt]
    )
    cycle = build_remediation_cycle(attempt_id=1)
    completed = build_valid_orchestrator_state()
    completed["remediation_loop"] = build_remediation_loop(
        status="resolved", attempts=[attempt], cycles=[cycle]
    )

    attempt_only_errors = _validate_without_mutation(attempt_only)
    completed_errors = _validate_without_mutation(completed)

    attempt_only_loop = attempt_only["remediation_loop"]
    completed_loop = completed["remediation_loop"]
    assert attempt_only_errors == []
    assert attempt_only_loop["attempt_count"] == 1
    assert attempt_only_loop["completed_cycle_count"] == 0
    assert attempt_only_loop["cycles"] == []
    assert completed_errors == []
    assert completed_loop["attempt_count"] == 1
    assert completed_loop["completed_cycle_count"] == 1
    assert cycle["attempt_id"] == attempt["attempt_id"] == 1
    assert cycle["commit_sha"] == "commit-1"
    assert cycle["re_audit_path"] == "audit-1.md"

    for evidence_field in ("commit_sha", "re_audit_path"):
        invalid_cycle = copy.deepcopy(cycle)
        invalid_cycle[evidence_field] = ""
        invalid = build_valid_orchestrator_state()
        invalid["remediation_loop"] = build_remediation_loop(
            status="resolved", attempts=[attempt], cycles=[invalid_cycle]
        )

        evidence_errors = _validate_without_mutation(invalid)

        assert any(evidence_field in error for error in evidence_errors)


def test_changed_fingerprint_reenters_r1() -> None:
    """Permit a new attempt when R4 reports a changed blocker fingerprint."""

    first_attempt = build_remediation_attempt()
    changed_cycle = build_remediation_cycle(
        review_verdict="BLOCKED",
        remediation_action="AUTONOMOUS",
        blocker_fingerprint_after=BLOCKER_FINGERPRINT_B,
        blocking_count=1,
        exit_condition_met=False,
    )
    second_attempt = build_remediation_attempt(
        attempt_id=2,
        source_review_fingerprint=BLOCKER_FINGERPRINT_B,
    )
    state = build_valid_orchestrator_state()
    state["remediation_loop"] = build_remediation_loop(
        status="active",
        attempts=[first_attempt, second_attempt],
        cycles=[changed_cycle],
    )

    errors = _validate_without_mutation(state)

    loop = state["remediation_loop"]
    assert errors == []
    assert changed_cycle["blocker_fingerprint_before"] == BLOCKER_FINGERPRINT_A
    assert changed_cycle["blocker_fingerprint_after"] == BLOCKER_FINGERPRINT_B
    assert second_attempt["source_review_fingerprint"] == BLOCKER_FINGERPRINT_B
    assert loop["attempt_count"] == 2
    assert loop["completed_cycle_count"] == 1


def test_unchanged_fingerprint_without_exception_stops_for_stagnation() -> None:
    """Stop an unchanged blocker after R4 when no exception authorizes R1."""

    attempt = build_remediation_attempt()
    unchanged_cycle = build_remediation_cycle(
        review_verdict="BLOCKED",
        remediation_action="AUTONOMOUS",
        blocker_fingerprint_after=BLOCKER_FINGERPRINT_A,
        blocking_count=1,
        exit_condition_met=False,
    )
    state = build_valid_orchestrator_state()
    state["remediation_loop"] = build_remediation_loop(
        status="blocked_stagnation",
        attempts=[attempt],
        cycles=[unchanged_cycle],
    )

    errors = _validate_without_mutation(state)

    loop = state["remediation_loop"]
    assert errors == []
    assert unchanged_cycle["blocker_fingerprint_before"] == BLOCKER_FINGERPRINT_A
    assert unchanged_cycle["blocker_fingerprint_after"] == BLOCKER_FINGERPRINT_A
    assert attempt["exception_binding"] is None
    assert loop["attempt_count"] == 1
    assert loop["completed_cycle_count"] == 1


def test_unchanged_fingerprint_consumes_exact_exception_once() -> None:
    """Permit exactly one exception-bound attempt after unchanged blockers."""

    first_attempt = build_remediation_attempt()
    unchanged_cycle = build_remediation_cycle(
        review_verdict="BLOCKED",
        remediation_action="AUTONOMOUS",
        blocker_fingerprint_after=BLOCKER_FINGERPRINT_A,
        blocking_count=1,
        exit_condition_met=False,
    )
    binding = build_exception_binding(attempt_id=2)
    second_attempt = build_remediation_attempt(
        attempt_id=2,
        exception_binding=binding,
    )
    state = build_valid_orchestrator_state()
    state["remediation_loop"] = build_remediation_loop(
        status="active",
        attempts=[first_attempt, second_attempt],
        cycles=[unchanged_cycle],
    )

    errors = _validate_without_mutation(state)

    loop = state["remediation_loop"]
    attempts = cast("list[dict[str, object]]", loop["attempts"])
    routing_policy_sha256 = cast("str", binding["routing_policy_sha256"])
    assert errors == []
    assert binding["issue_number"] == state["issue-num"] == "1"
    assert binding["blocker_fingerprint"] == BLOCKER_FINGERPRINT_A
    assert routing_policy_sha256.startswith("sha256:")
    assert binding["allowed_transition"] == "blocked_stagnation_to_active"
    assert binding["single_use"] is True
    assert binding["consumed_by_attempt_id"] == second_attempt["attempt_id"] == 2
    assert loop["attempt_count"] == 2
    assert loop["completed_cycle_count"] == 1
    assert sum(item["exception_binding"] is not None for item in attempts) == 1


def test_consumed_exception_reuse_is_rejected() -> None:
    """Reject a consumed exception identifier without adding later records."""

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
    state = build_valid_orchestrator_state()
    state["remediation_loop"] = build_remediation_loop(
        status="active",
        attempts=[first_attempt, second_attempt, third_attempt],
        cycles=[first_cycle, second_cycle],
    )

    errors = _validate_without_mutation(state)

    loop = state["remediation_loop"]
    attempts = cast("list[dict[str, object]]", loop["attempts"])
    cycles = cast("list[dict[str, object]]", loop["cycles"])
    assert errors[0].startswith("ORCH_EXCEPTION_BINDING_REUSED")
    assert len(errors) == 3
    assert all(error.startswith("ORCH_") for error in errors)
    assert loop["attempt_count"] == 3
    assert loop["completed_cycle_count"] == 2
    assert len(attempts) == 3
    assert len(cycles) == 2
