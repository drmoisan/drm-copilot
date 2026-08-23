"""Validate version-2 remediation records at the field-schema boundary."""

from __future__ import annotations

import re
from collections.abc import Callable
from datetime import datetime
from typing import Any, cast

REMEDIATION_CYCLES_KEY = "cycles"
REMEDIATION_SCHEMA_VERSION = 2
REMEDIATION_SCHEMA_ERROR = "ORCH_REMEDIATION_SCHEMA"
REMEDIATION_COUNT_ERROR = "ORCH_REMEDIATION_COUNT"
REMEDIATION_SEQUENCE_ERROR = "ORCH_REMEDIATION_SEQUENCE"
REMEDIATION_TRANSITION_ERROR = "ORCH_REMEDIATION_TRANSITION"
REMEDIATION_STAGNATION_ERROR = "ORCH_REMEDIATION_STAGNATION"
EXCEPTION_BINDING_INVALID_ERROR = "ORCH_EXCEPTION_BINDING_INVALID"
EXCEPTION_BINDING_REUSED_ERROR = "ORCH_EXCEPTION_BINDING_REUSED"
VERSIONED_REMEDIATION_REQUIRED_FIELDS = (
    "schema_version",
    "status",
    "max_completed_cycles",
    "attempt_count",
    "completed_cycle_count",
    "last_blocker_fingerprint",
    "attempts",
    REMEDIATION_CYCLES_KEY,
)
VERSIONED_REMEDIATION_MARKER_FIELDS = frozenset(
    VERSIONED_REMEDIATION_REQUIRED_FIELDS
) - {REMEDIATION_CYCLES_KEY}
ATTEMPT_REQUIRED_FIELDS = (
    "attempt_id",
    "source_review_fingerprint",
    "plan_path",
    "preflight",
    "execution_status",
    "candidate_applied",
    "terminal_disposition",
    "started_at",
    "finished_at",
    "exception_binding",
)
CYCLE_REQUIRED_FIELDS = (
    "cycle_id",
    "attempt_id",
    "commit_sha",
    "re_audit_path",
    "review_verdict",
    "remediation_action",
    "blocker_fingerprint_before",
    "blocker_fingerprint_after",
    "blocking_count",
    "exit_condition_met",
    "completed_at",
)
PREFLIGHT_STATUSES = frozenset({"pending", "revisions_required", "clear"})
EXECUTION_STATUSES = frozenset(
    {"not_started", "in_progress", "complete", "failed", "awaiting_ci", "blocked"}
)
TERMINAL_DISPOSITIONS = frozenset(
    {
        "candidate_applied",
        "no_candidate",
        "external_runtime",
        "awaiting_ci",
        "human_decision",
        "execution_failed",
    }
)
REVIEW_VERDICTS = frozenset({"PASS", "BLOCKED"})
REMEDIATION_ACTIONS = frozenset(
    {
        "NONE",
        "AUTONOMOUS",
        "NO_CANDIDATE",
        "EXTERNAL_RUNTIME",
        "AWAITING_CI",
        "HUMAN_DECISION",
    }
)
BLOCKER_FINGERPRINT_PATTERN = re.compile(r"sha256:[0-9a-f]{64}")


def coded_error(code: str, subject: str, requirement: str) -> str:
    """Build a stable remediation diagnostic for one invariant class."""

    return f"{code}: {subject} {requirement}."


def schema_error(subject: str, requirement: str) -> str:
    return coded_error(REMEDIATION_SCHEMA_ERROR, subject, requirement)


def is_positive_int(value: object) -> bool:
    return isinstance(value, int) and not isinstance(value, bool) and value > 0


def is_non_negative_int(value: object) -> bool:
    return isinstance(value, int) and not isinstance(value, bool) and value >= 0


def is_non_empty_string(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip())


def is_fingerprint(value: object) -> bool:
    return (
        isinstance(value, str)
        and BLOCKER_FINGERPRINT_PATTERN.fullmatch(value) is not None
    )


def is_fingerprint_or_none(value: object) -> bool:
    return value == "NONE" or is_fingerprint(value)


def is_iso_timestamp(value: object, *, allow_none: bool = False) -> bool:
    if value is None:
        return allow_none
    if not isinstance(value, str):
        return False
    try:
        parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    except ValueError:
        return False
    return parsed.tzinfo is not None


def _is_preflight(value: object) -> bool:
    return (
        isinstance(value, dict)
        and cast("dict[str, Any]", value).get("final_status") in PREFLIGHT_STATUSES
    )


def _is_execution_status(value: object) -> bool:
    return isinstance(value, str) and value in EXECUTION_STATUSES


def _is_terminal_disposition(value: object) -> bool:
    return isinstance(value, str) and value in TERMINAL_DISPOSITIONS


def _is_review_verdict(value: object) -> bool:
    return isinstance(value, str) and value in REVIEW_VERDICTS


def _is_remediation_action(value: object) -> bool:
    return isinstance(value, str) and value in REMEDIATION_ACTIONS


def _is_bool(value: object) -> bool:
    return isinstance(value, bool)


def _is_optional_iso_timestamp(value: object) -> bool:
    return is_iso_timestamp(value, allow_none=True)


def _is_exception_container(value: object) -> bool:
    return value is None or isinstance(value, dict)


FieldRule = tuple[str, str, Callable[[object], bool], str]
ATTEMPT_FIELD_RULES: tuple[FieldRule, ...] = (
    ("attempt_id", "attempt_id", is_positive_int, "must be a positive integer"),
    (
        "source_review_fingerprint",
        "source_review_fingerprint",
        is_fingerprint,
        "must be sha256 followed by 64 lowercase hexadecimal characters",
    ),
    ("plan_path", "plan_path", is_non_empty_string, "must be a non-empty string"),
    (
        "preflight",
        "preflight.final_status",
        _is_preflight,
        "must be pending, revisions_required, or clear",
    ),
    (
        "execution_status",
        "execution_status",
        _is_execution_status,
        "must be a documented execution status",
    ),
    ("candidate_applied", "candidate_applied", _is_bool, "must be boolean"),
    (
        "terminal_disposition",
        "terminal_disposition",
        _is_terminal_disposition,
        "must be a documented terminal disposition",
    ),
    (
        "started_at",
        "started_at",
        is_iso_timestamp,
        "must be an ISO-8601 timestamp with offset",
    ),
    (
        "finished_at",
        "finished_at",
        _is_optional_iso_timestamp,
        "must be an ISO-8601 timestamp with offset",
    ),
    (
        "exception_binding",
        "exception_binding",
        _is_exception_container,
        "must be an object or null",
    ),
)
CYCLE_FIELD_RULES: tuple[FieldRule, ...] = (
    ("cycle_id", "cycle_id", is_positive_int, "must be a positive integer"),
    ("attempt_id", "attempt_id", is_positive_int, "must be a positive integer"),
    ("commit_sha", "commit_sha", is_non_empty_string, "must be a non-empty string"),
    (
        "re_audit_path",
        "re_audit_path",
        is_non_empty_string,
        "must be a non-empty string",
    ),
    ("review_verdict", "review_verdict", _is_review_verdict, "must be PASS or BLOCKED"),
    (
        "remediation_action",
        "remediation_action",
        _is_remediation_action,
        "must be a documented remediation action",
    ),
    (
        "blocker_fingerprint_before",
        "blocker_fingerprint_before",
        is_fingerprint_or_none,
        "must be NONE or a fingerprint",
    ),
    (
        "blocker_fingerprint_after",
        "blocker_fingerprint_after",
        is_fingerprint_or_none,
        "must be NONE or a fingerprint",
    ),
    (
        "blocking_count",
        "blocking_count",
        is_non_negative_int,
        "must be a non-negative integer",
    ),
    ("exit_condition_met", "exit_condition_met", _is_bool, "must be boolean"),
    (
        "completed_at",
        "completed_at",
        is_iso_timestamp,
        "must be an ISO-8601 timestamp with offset",
    ),
)


def _validate_records(
    value: object,
    *,
    collection_name: str,
    required_fields: tuple[str, ...],
    field_rules: tuple[FieldRule, ...],
) -> list[str]:
    """Apply ordered field rules to every object in a remediation collection."""

    if not isinstance(value, list):
        return []
    errors: list[str] = []
    for index, item in enumerate(cast("list[object]", value)):
        subject = f"remediation_loop.{collection_name}[{index}]"
        if not isinstance(item, dict):
            errors.append(schema_error(subject, "must be an object"))
            continue
        record = cast("dict[str, Any]", item)
        errors.extend(
            schema_error(subject, f"missing required field: {field}")
            for field in required_fields
            if field not in record
        )
        errors.extend(
            schema_error(f"{subject}.{label}", requirement)
            for key, label, predicate, requirement in field_rules
            if key in record and not predicate(record.get(key))
        )
    return errors


def _validate_attempt_sequence(loop_map: dict[str, Any]) -> list[str]:
    attempts = loop_map.get("attempts")
    if not isinstance(attempts, list):
        return []
    attempt_list = cast("list[object]", attempts)
    errors: list[str] = []
    attempt_count = loop_map.get("attempt_count")
    if not is_non_negative_int(attempt_count):
        errors.append(
            coded_error(
                REMEDIATION_COUNT_ERROR,
                "remediation_loop.attempt_count",
                "must be a non-negative integer",
            )
        )
    elif attempt_count != len(attempt_list):
        errors.append(
            coded_error(
                REMEDIATION_COUNT_ERROR,
                "remediation_loop.attempt_count",
                f"must equal attempts length {len(attempt_list)}",
            )
        )
    attempt_ids = [
        cast("dict[str, Any]", attempt).get("attempt_id")
        for attempt in attempt_list
        if isinstance(attempt, dict)
    ]
    if len(attempt_ids) == len(attempt_list) and all(
        is_positive_int(attempt_id) for attempt_id in attempt_ids
    ):
        expected = list(range(1, len(attempt_list) + 1))
        if attempt_ids != expected:
            errors.append(
                coded_error(
                    REMEDIATION_SEQUENCE_ERROR,
                    "remediation_loop attempt_id sequence",
                    f"must be {expected}; received {attempt_ids}",
                )
            )
    return errors


def validate_versioned_schema(loop_map: dict[str, Any]) -> list[str]:
    """Validate required fields, containers, attempt records, and cycle records."""

    errors = [
        schema_error("remediation_loop", f"missing required field: {field}")
        for field in VERSIONED_REMEDIATION_REQUIRED_FIELDS
        if field not in loop_map
    ]
    if (
        "schema_version" in loop_map
        and loop_map.get("schema_version") != REMEDIATION_SCHEMA_VERSION
    ):
        errors.append(
            schema_error(
                "remediation_loop.schema_version",
                f"must be {REMEDIATION_SCHEMA_VERSION}",
            )
        )
    for collection_key in ("attempts", REMEDIATION_CYCLES_KEY):
        if collection_key in loop_map and not isinstance(
            loop_map.get(collection_key), list
        ):
            errors.append(
                schema_error(f"remediation_loop.{collection_key}", "must be an array")
            )
    errors.extend(
        _validate_records(
            loop_map.get("attempts"),
            collection_name="attempts",
            required_fields=ATTEMPT_REQUIRED_FIELDS,
            field_rules=ATTEMPT_FIELD_RULES,
        )
    )
    errors.extend(_validate_attempt_sequence(loop_map))
    errors.extend(
        _validate_records(
            loop_map.get(REMEDIATION_CYCLES_KEY),
            collection_name=REMEDIATION_CYCLES_KEY,
            required_fields=CYCLE_REQUIRED_FIELDS,
            field_rules=CYCLE_FIELD_RULES,
        )
    )
    return errors
