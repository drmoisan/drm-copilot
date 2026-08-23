"""Validate exact single-use remediation stagnation exceptions."""

from __future__ import annotations

from collections import Counter
from typing import Any, cast

from scripts.dev_tools._orchestrator_state_remediation_schema import (
    EXCEPTION_BINDING_INVALID_ERROR,
    EXCEPTION_BINDING_REUSED_ERROR,
    REMEDIATION_CYCLES_KEY,
    coded_error,
    is_fingerprint,
    is_iso_timestamp,
    is_positive_int,
)

EXCEPTION_BINDING_FIELDS = frozenset(
    {
        "exception_id",
        "issue_number",
        "blocker_fingerprint",
        "routing_policy_sha256",
        "allowed_transition",
        "single_use",
        "consumed_at",
        "consumed_by_attempt_id",
    }
)
STAGNATION_CONTINUATION = "blocked_stagnation_to_active"
WILDCARD_CHARACTERS = frozenset("*?[]")


def _invalid(subject: str, requirement: str) -> str:
    return coded_error(EXCEPTION_BINDING_INVALID_ERROR, subject, requirement)


def _issue_token(value: object) -> str | None:
    if isinstance(value, int) and not isinstance(value, bool) and value > 0:
        return str(value)
    if isinstance(value, str) and value.strip().isdigit():
        return value.strip()
    return None


def _is_exact_string(value: object) -> bool:
    return (
        isinstance(value, str)
        and bool(value.strip())
        and not any(character in value for character in WILDCARD_CHARACTERS)
    )


def _unchanged_cycle_by_next_attempt(
    cycles: list[object],
) -> dict[int, tuple[int, str]]:
    result: dict[int, tuple[int, str]] = {}
    for index, value in enumerate(cycles):
        if not isinstance(value, dict):
            continue
        cycle = cast("dict[str, Any]", value)
        attempt_id = cycle.get("attempt_id")
        before = cycle.get("blocker_fingerprint_before")
        after = cycle.get("blocker_fingerprint_after")
        if (
            cycle.get("review_verdict") == "BLOCKED"
            and is_positive_int(attempt_id)
            and is_fingerprint(before)
            and before == after
        ):
            result[cast("int", attempt_id) + 1] = (index, cast("str", before))
    return result


def validate_exception_bindings(
    loop_map: dict[str, Any],
    *,
    issue_number: object,
    routing_policy_sha256: object,
) -> tuple[list[str], set[int]]:
    """Return ordered binding errors and stagnation cycles authorized once."""

    attempts = loop_map.get("attempts")
    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    if not isinstance(attempts, list) or not isinstance(cycles, list):
        return [], set()
    attempt_list = cast("list[object]", attempts)
    cycle_list = cast("list[object]", cycles)
    expected_issue = _issue_token(issue_number)
    prior_by_attempt = _unchanged_cycle_by_next_attempt(cycle_list)
    errors: list[str] = []
    exception_ids: list[str] = []
    candidates: list[tuple[str, int]] = []
    for index, value in enumerate(attempt_list):
        if not isinstance(value, dict):
            continue
        attempt = cast("dict[str, Any]", value)
        binding_value = attempt.get("exception_binding")
        if binding_value is None or not isinstance(binding_value, dict):
            continue
        binding = cast("dict[str, Any]", binding_value)
        subject = f"remediation_loop.attempts[{index}].exception_binding"
        local_errors: list[str] = []
        if frozenset(binding) != EXCEPTION_BINDING_FIELDS:
            local_errors.append(
                _invalid(subject, "must contain exactly the canonical fields")
            )
        exception_id = binding.get("exception_id")
        if not _is_exact_string(exception_id):
            local_errors.append(_invalid(f"{subject}.exception_id", "must be exact"))
        else:
            exception_ids.append(cast("str", exception_id))
        attempt_id = attempt.get("attempt_id")
        prior = (
            prior_by_attempt.get(cast("int", attempt_id))
            if is_positive_int(attempt_id)
            else None
        )
        if prior is None:
            local_errors.append(
                _invalid(subject, "must bind the next attempt after unchanged blockers")
            )
        expected_fingerprint = prior[1] if prior is not None else None
        if binding.get("blocker_fingerprint") != expected_fingerprint:
            local_errors.append(
                _invalid(f"{subject}.blocker_fingerprint", "must match both blockers")
            )
        if attempt.get("source_review_fingerprint") != expected_fingerprint:
            local_errors.append(
                _invalid(subject, "must match the consuming attempt source fingerprint")
            )
        if (
            _issue_token(binding.get("issue_number")) != expected_issue
            or expected_issue is None
        ):
            local_errors.append(
                _invalid(f"{subject}.issue_number", "must match the checkpoint issue")
            )
        if (
            not is_fingerprint(routing_policy_sha256)
            or binding.get("routing_policy_sha256") != routing_policy_sha256
        ):
            local_errors.append(
                _invalid(
                    f"{subject}.routing_policy_sha256",
                    "must match the current routing policy",
                )
            )
        if binding.get("allowed_transition") != STAGNATION_CONTINUATION:
            local_errors.append(
                _invalid(
                    f"{subject}.allowed_transition",
                    f"must be {STAGNATION_CONTINUATION}",
                )
            )
        if binding.get("single_use") is not True:
            local_errors.append(_invalid(f"{subject}.single_use", "must be true"))
        consumed_at = binding.get("consumed_at")
        consumed_by = binding.get("consumed_by_attempt_id")
        consumed = consumed_at is not None or consumed_by is not None
        if consumed_at is None and consumed_by is None:
            pass
        elif (
            not is_iso_timestamp(consumed_at)
            or not is_positive_int(consumed_by)
            or consumed_by != attempt_id
        ):
            local_errors.append(
                _invalid(subject, "consumption fields must be paired to this attempt")
            )
        errors.extend(local_errors)
        if (
            not local_errors
            and consumed
            and isinstance(exception_id, str)
            and prior is not None
        ):
            candidates.append((exception_id, prior[0]))

    reused = {item for item, count in Counter(exception_ids).items() if count > 1}
    errors.extend(
        coded_error(
            EXCEPTION_BINDING_REUSED_ERROR,
            f"exception_id {exception_id}",
            "must be consumed only once",
        )
        for exception_id in sorted(reused)
    )
    authorized = {
        cycle_index
        for exception_id, cycle_index in candidates
        if exception_id not in reused
    }
    return errors, authorized
