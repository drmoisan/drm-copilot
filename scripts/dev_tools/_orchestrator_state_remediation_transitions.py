"""Validate version-2 remediation result and terminal-state transitions."""

from __future__ import annotations

from typing import Any, cast

from scripts.dev_tools._orchestrator_state_remediation_exceptions import (
    validate_exception_bindings,
)
from scripts.dev_tools._orchestrator_state_remediation_schema import (
    REMEDIATION_CYCLES_KEY,
    REMEDIATION_STAGNATION_ERROR,
    REMEDIATION_TRANSITION_ERROR,
    coded_error,
    is_fingerprint,
    is_positive_int,
    schema_error,
)

REMEDIATION_STATUSES = frozenset(
    {
        "idle",
        "active",
        "awaiting_ci",
        "blocked_no_candidate",
        "blocked_external_runtime",
        "blocked_human_decision",
        "blocked_stagnation",
        "blocked_remediation_loop_limit",
        "resolved",
    }
)
NON_ACTIONABLE_STATUS_BY_ACTION = {
    "NO_CANDIDATE": "blocked_no_candidate",
    "EXTERNAL_RUNTIME": "blocked_external_runtime",
    "AWAITING_CI": "awaiting_ci",
    "HUMAN_DECISION": "blocked_human_decision",
}
FALSE_CANDIDATE_EXECUTION_BY_DISPOSITION = {
    "no_candidate": "complete",
    "external_runtime": "blocked",
    "awaiting_ci": "awaiting_ci",
    "human_decision": "blocked",
    "execution_failed": "failed",
}
FALSE_CANDIDATE_STATUS_BY_DISPOSITION = {
    "no_candidate": "blocked_no_candidate",
    "external_runtime": "blocked_external_runtime",
    "awaiting_ci": "awaiting_ci",
    "human_decision": "blocked_human_decision",
    "execution_failed": "blocked_no_candidate",
}


def _transition_error(subject: str, requirement: str) -> str:
    return coded_error(REMEDIATION_TRANSITION_ERROR, subject, requirement)


def _stagnation_error(subject: str, requirement: str) -> str:
    return coded_error(REMEDIATION_STAGNATION_ERROR, subject, requirement)


def _validate_review_transitions(loop_map: dict[str, Any]) -> list[str]:
    """Validate every completed review's verdict/action and blocker tuple."""

    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    if not isinstance(cycles, list):
        return []
    errors: list[str] = []
    for index, value in enumerate(cast("list[object]", cycles)):
        if not isinstance(value, dict):
            continue
        cycle = cast("dict[str, Any]", value)
        verdict = cycle.get("review_verdict")
        action = cycle.get("remediation_action")
        blocking_count = cycle.get("blocking_count")
        fingerprint_before = cycle.get("blocker_fingerprint_before")
        fingerprint_after = cycle.get("blocker_fingerprint_after")
        subject = f"remediation_loop.cycles[{index}]"
        if not is_fingerprint(fingerprint_before):
            errors.append(
                _transition_error(
                    f"{subject}.blocker_fingerprint_before",
                    "must identify the actionable source review",
                )
            )
        if verdict == "PASS":
            if action != "NONE":
                errors.append(
                    _transition_error(subject, "PASS requires remediation_action NONE")
                )
            if fingerprint_after != "NONE" or blocking_count != 0:
                errors.append(
                    _transition_error(
                        subject,
                        "PASS requires fingerprint NONE and blocking_count 0",
                    )
                )
        elif verdict == "BLOCKED":
            if not isinstance(action, str) or action not in {
                "AUTONOMOUS",
                *NON_ACTIONABLE_STATUS_BY_ACTION,
            }:
                errors.append(
                    _transition_error(
                        subject,
                        "BLOCKED requires a documented blocked remediation action",
                    )
                )
            if not is_fingerprint(fingerprint_after) or not is_positive_int(
                blocking_count
            ):
                errors.append(
                    _transition_error(
                        subject,
                        "BLOCKED requires a fingerprint and positive blocking_count",
                    )
                )
    return errors


def _validate_exit_conditions(loop_map: dict[str, Any]) -> list[str]:
    """Require the exit flag to exactly represent the PASS/NONE/zero tuple."""

    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    if not isinstance(cycles, list):
        return []
    errors: list[str] = []
    for index, value in enumerate(cast("list[object]", cycles)):
        if not isinstance(value, dict):
            continue
        cycle = cast("dict[str, Any]", value)
        exit_condition = cycle.get("exit_condition_met")
        if not isinstance(exit_condition, bool):
            continue
        expected = (
            cycle.get("review_verdict") == "PASS"
            and cycle.get("remediation_action") == "NONE"
            and cycle.get("blocking_count") == 0
        )
        if exit_condition != expected:
            errors.append(
                _transition_error(
                    f"remediation_loop.cycles[{index}].exit_condition_met",
                    "must be true exactly for PASS/NONE with blocking_count 0",
                )
            )
    return errors


def _validate_stagnation(
    loop_map: dict[str, Any], authorized_cycle_indices: set[int]
) -> list[str]:
    """Stop unchanged blocker sets and reject continuation past that boundary."""

    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    attempts = loop_map.get("attempts")
    if not isinstance(cycles, list) or not isinstance(attempts, list):
        return []
    cycle_list = cast("list[object]", cycles)
    attempt_list = cast("list[object]", attempts)
    errors: list[str] = []
    for index, value in enumerate(cycle_list):
        if not isinstance(value, dict):
            continue
        cycle = cast("dict[str, Any]", value)
        if cycle.get("review_verdict") != "BLOCKED":
            continue
        before = cycle.get("blocker_fingerprint_before")
        after = cycle.get("blocker_fingerprint_after")
        if not is_fingerprint(before) or not is_fingerprint(after):
            continue
        unchanged = before == after
        attempt_id = cycle.get("attempt_id")
        later_attempt = is_positive_int(attempt_id) and len(attempt_list) > cast(
            "int", attempt_id
        )
        later_cycle = index < len(cycle_list) - 1
        authorized = index in authorized_cycle_indices
        if unchanged and (later_attempt or later_cycle) and not authorized:
            errors.append(
                _stagnation_error(
                    f"remediation_loop.cycles[{index}]",
                    "unchanged blockers forbid another attempt or cycle",
                )
            )
        elif index == len(cycle_list) - 1 and not authorized:
            status = loop_map.get("status")
            if unchanged and status != "blocked_stagnation":
                errors.append(
                    _stagnation_error(
                        "remediation_loop.status",
                        "must be blocked_stagnation for unchanged blockers",
                    )
                )
            elif not unchanged and status == "blocked_stagnation":
                errors.append(
                    _stagnation_error(
                        "remediation_loop.status",
                        "cannot be blocked_stagnation for changed blockers",
                    )
                )
    return errors


def _validate_candidate_transitions(loop_map: dict[str, Any]) -> list[str]:
    """Validate completed and false-candidate executor result combinations."""

    attempts = loop_map.get("attempts")
    if not isinstance(attempts, list):
        return []
    attempt_list = cast("list[object]", attempts)
    errors: list[str] = []
    for index, value in enumerate(attempt_list):
        if not isinstance(value, dict):
            continue
        attempt = cast("dict[str, Any]", value)
        subject = f"remediation_loop.attempts[{index}]"
        candidate_applied = attempt.get("candidate_applied")
        execution_status = attempt.get("execution_status")
        disposition = attempt.get("terminal_disposition")
        if candidate_applied is True:
            if execution_status != "complete" or disposition != "candidate_applied":
                errors.append(
                    _transition_error(
                        subject,
                        "an applied candidate requires complete/candidate_applied",
                    )
                )
        elif candidate_applied is False and isinstance(disposition, str):
            expected_execution = FALSE_CANDIDATE_EXECUTION_BY_DISPOSITION.get(
                disposition
            )
            if expected_execution is None or execution_status != expected_execution:
                errors.append(
                    _transition_error(
                        subject,
                        "a false candidate requires its matching terminal execution",
                    )
                )
            if index != len(attempt_list) - 1:
                errors.append(
                    _transition_error(
                        subject, "a false candidate cannot precede another attempt"
                    )
                )
        if isinstance(candidate_applied, bool) and attempt.get("finished_at") is None:
            errors.append(
                _transition_error(subject, "a terminal candidate requires finished_at")
            )
    return errors


def _allowed_terminal_statuses(loop_map: dict[str, Any]) -> set[str]:
    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    attempts = loop_map.get("attempts")
    if not isinstance(cycles, list) or not isinstance(attempts, list):
        return set(REMEDIATION_STATUSES)
    cycle_list = cast("list[object]", cycles)
    attempt_list = cast("list[object]", attempts)
    referenced_ids = {
        cast("dict[str, Any]", cycle).get("attempt_id")
        for cycle in cycle_list
        if isinstance(cycle, dict)
        and is_positive_int(cast("dict[str, Any]", cycle).get("attempt_id"))
    }
    if attempt_list and isinstance(attempt_list[-1], dict):
        last_attempt = cast("dict[str, Any]", attempt_list[-1])
        last_attempt_id = last_attempt.get("attempt_id")
        if (
            not is_positive_int(last_attempt_id)
            or last_attempt_id not in referenced_ids
        ):
            if last_attempt.get("candidate_applied") is True:
                return {"active"}
            disposition = last_attempt.get("terminal_disposition")
            expected = (
                FALSE_CANDIDATE_STATUS_BY_DISPOSITION.get(disposition)
                if isinstance(disposition, str)
                else None
            )
            return {expected} if expected is not None else set()
    if cycle_list and isinstance(cycle_list[-1], dict):
        last_cycle = cast("dict[str, Any]", cycle_list[-1])
        verdict = last_cycle.get("review_verdict")
        action = last_cycle.get("remediation_action")
        if verdict == "PASS" and action == "NONE":
            return {"resolved"}
        non_actionable = (
            NON_ACTIONABLE_STATUS_BY_ACTION.get(action)
            if isinstance(action, str)
            else None
        )
        if verdict == "BLOCKED" and non_actionable is not None:
            return {non_actionable, "blocked_stagnation"}
        if verdict == "BLOCKED" and action == "AUTONOMOUS":
            completed_count = loop_map.get("completed_cycle_count")
            max_count = loop_map.get("max_completed_cycles")
            if completed_count == max_count == 3:
                return {"blocked_stagnation", "blocked_remediation_loop_limit"}
            return {"active", "blocked_stagnation"}
        return set()
    return {
        "idle",
        "active",
        "awaiting_ci",
        "blocked_no_candidate",
        "blocked_external_runtime",
        "blocked_human_decision",
        "resolved",
    }


def _validate_loop_transition(loop_map: dict[str, Any]) -> list[str]:
    """Validate top-level status and its latest attempt or cycle outcome."""

    errors: list[str] = []
    status = loop_map.get("status")
    if not isinstance(status, str) or status not in REMEDIATION_STATUSES:
        return [schema_error("remediation_loop.status", "must be a documented status")]
    max_count = loop_map.get("max_completed_cycles")
    if not is_positive_int(max_count) or cast("int", max_count) > 3:
        errors.append(
            schema_error(
                "remediation_loop.max_completed_cycles",
                "must be a positive integer no greater than 3",
            )
        )
    last_fingerprint = loop_map.get("last_blocker_fingerprint")
    if last_fingerprint is not None and not is_fingerprint(last_fingerprint):
        errors.append(
            schema_error(
                "remediation_loop.last_blocker_fingerprint",
                "must be null or a fingerprint",
            )
        )
    allowed = _allowed_terminal_statuses(loop_map)
    if status not in allowed:
        errors.append(
            _transition_error(
                "remediation_loop.status",
                f"{status} does not match the latest remediation outcome",
            )
        )
    return errors


def validate_transitions(
    loop_map: dict[str, Any],
    *,
    issue_number: object,
    routing_policy_sha256: object,
) -> list[str]:
    """Return ordered review, candidate, and loop-status transition errors."""

    errors = _validate_review_transitions(loop_map)
    errors.extend(_validate_exit_conditions(loop_map))
    binding_errors, authorized_cycles = validate_exception_bindings(
        loop_map,
        issue_number=issue_number,
        routing_policy_sha256=routing_policy_sha256,
    )
    errors.extend(binding_errors)
    errors.extend(_validate_stagnation(loop_map, authorized_cycles))
    errors.extend(_validate_candidate_transitions(loop_map))
    errors.extend(_validate_loop_transition(loop_map))
    return errors
