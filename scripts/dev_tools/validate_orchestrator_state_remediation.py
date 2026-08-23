"""Validate remediation-loop state embedded in orchestrator checkpoints."""

from __future__ import annotations

import hashlib
import json
import posixpath
from typing import Any, cast

from scripts.dev_tools._orchestrator_state_remediation_schema import (
    REMEDIATION_COUNT_ERROR,
    REMEDIATION_CYCLES_KEY,
    REMEDIATION_SEQUENCE_ERROR,
    REMEDIATION_TRANSITION_ERROR,
    VERSIONED_REMEDIATION_MARKER_FIELDS,
    coded_error,
    is_non_negative_int,
    is_positive_int,
    schema_error,
    validate_versioned_schema,
)
from scripts.dev_tools._orchestrator_state_remediation_transitions import (
    validate_transitions,
)

REMEDIATION_LOOP_KEY = "remediation_loop"
EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT = {
    "in_progress",
    "complete",
    "failed",
}
PREFLIGHT_CLEARED_STATUS = "clear"
_REMEDIATION_PASS_MISSING = object()
_VALIDATION_CONTEXT_MISSING = object()
LEGACY_SUCCESS_STATUS = "PASS"
LEGACY_REVIEW_REMEDIATION_REQUIRED = "REMEDIATION_REQUIRED"
LEGACY_CANONICAL_PASS = ("PASS", "NONE")
LEGACY_CANONICAL_ACTIONABLE = ("BLOCKED", "AUTONOMOUS")


def _is_legacy_artifact_path(value: object) -> bool:
    return isinstance(value, str) and bool(value.strip()) and value.strip() != "NONE"


def _is_legacy_no_path(value: object) -> bool:
    return value is None or (isinstance(value, str) and value.strip() == "NONE")


def map_legacy_review_output(
    review_status: object,
    remediation_inputs_path: object,
    remediation_plan_path: object,
) -> tuple[str, str] | None:
    """Map an exact legacy review result to its canonical verdict and action."""

    inputs_present = _is_legacy_artifact_path(remediation_inputs_path)
    plan_present = _is_legacy_artifact_path(remediation_plan_path)
    if (
        review_status == LEGACY_SUCCESS_STATUS
        and _is_legacy_no_path(remediation_inputs_path)
        and _is_legacy_no_path(remediation_plan_path)
    ):
        return LEGACY_CANONICAL_PASS
    if (
        review_status == LEGACY_REVIEW_REMEDIATION_REQUIRED
        and inputs_present
        and plan_present
    ):
        return LEGACY_CANONICAL_ACTIONABLE
    return None


def is_versioned_remediation_loop(remediation_loop: object) -> bool:
    """Return whether the loop carries any version-2 schema marker."""

    return isinstance(remediation_loop, dict) and any(
        field in remediation_loop for field in VERSIONED_REMEDIATION_MARKER_FIELDS
    )


def validate_legacy_remediation_state(
    *,
    review_status: object,
    remediation_inputs_path: object,
    remediation_plan_path: object,
    remediation_pass: object,
    strict: bool,
    versioned_remediation: bool = False,
) -> list[str]:
    """Validate legacy review aliases and require migration before strict use."""

    mapped = map_legacy_review_output(
        review_status, remediation_inputs_path, remediation_plan_path
    )
    errors: list[str] = []
    has_review_output = (
        review_status is not None
        or not _is_legacy_no_path(remediation_inputs_path)
        or not _is_legacy_no_path(remediation_plan_path)
    )
    if has_review_output and mapped is None:
        if review_status == LEGACY_SUCCESS_STATUS:
            requirement = "PASS maps to PASS/NONE and requires both paths to be NONE"
        elif review_status == LEGACY_REVIEW_REMEDIATION_REQUIRED:
            requirement = (
                "REMEDIATION_REQUIRED maps to BLOCKED/AUTONOMOUS and requires "
                "both remediation paths"
            )
        else:
            requirement = "must be PASS or REMEDIATION_REQUIRED with matching paths"
        errors.append(schema_error("legacy review output", requirement))

    has_legacy_remediation = (
        review_status == LEGACY_REVIEW_REMEDIATION_REQUIRED
        or not _is_legacy_no_path(remediation_inputs_path)
        or not _is_legacy_no_path(remediation_plan_path)
        or is_positive_int(remediation_pass)
    )
    if strict and has_legacy_remediation and not versioned_remediation:
        errors.append(
            schema_error(
                "legacy remediation state",
                "requires evidence-backed schema version 2 migration before "
                "strict validation",
            )
        )
    return errors


def _normalize_fingerprint_text(value: object, *, field: str, index: int) -> str:
    if not isinstance(value, str) or not value.strip():
        raise ValueError(
            f"Blocking finding #{index} {field} must be a non-empty string."
        )
    return " ".join(value.split())


def _normalize_finding_path(
    value: object, workspace_root: str | None, index: int
) -> str:
    path = _normalize_fingerprint_text(value, field="path", index=index).replace(
        "\\", "/"
    )
    normalized = posixpath.normpath(path)
    if workspace_root is not None:
        root = posixpath.normpath(workspace_root.strip().replace("\\", "/")).rstrip("/")
        prefix = f"{root}/"
        if normalized.casefold().startswith(prefix.casefold()):
            normalized = normalized[len(prefix) :]
    while normalized.startswith("./"):
        normalized = normalized[2:]
    return normalized


def canonical_blocker_fingerprint(
    findings: object, *, workspace_root: str | None = None
) -> str:
    """Hash sorted stable blocker fields as compact UTF-8 canonical JSON."""

    if not isinstance(findings, list):
        raise ValueError("Blocking findings must be an array.")
    canonical: list[dict[str, str]] = []
    for index, value in enumerate(cast("list[object]", findings)):
        if not isinstance(value, dict):
            raise ValueError(f"Blocking finding #{index} must be an object.")
        finding = cast("dict[str, Any]", value)
        canonical.append(
            {
                "audit_kind": _normalize_fingerprint_text(
                    finding.get("audit_kind"), field="audit_kind", index=index
                ),
                "rule_id": _normalize_fingerprint_text(
                    finding.get("rule_id"), field="rule_id", index=index
                ),
                "path": _normalize_finding_path(
                    finding.get("path"), workspace_root, index
                ),
                "message": _normalize_fingerprint_text(
                    finding.get("message"), field="message", index=index
                ),
            }
        )
    canonical.sort(
        key=lambda finding: (
            finding["audit_kind"],
            finding["rule_id"],
            finding["path"],
            finding["message"],
        )
    )
    payload = json.dumps(
        canonical, ensure_ascii=False, separators=(",", ":"), sort_keys=True
    ).encode("utf-8")
    return f"sha256:{hashlib.sha256(payload).hexdigest()}"


def _validate_remediation_pass(
    loop_map: dict[str, Any], remediation_pass: object
) -> list[str]:
    """Require a supplied compatibility alias to equal the canonical count."""

    if remediation_pass is _REMEDIATION_PASS_MISSING:
        return []
    completed_count = loop_map.get("completed_cycle_count")
    if not is_non_negative_int(remediation_pass) or remediation_pass != completed_count:
        return [
            coded_error(
                REMEDIATION_COUNT_ERROR,
                "remediation-pass",
                f"must equal remediation_loop.completed_cycle_count {completed_count}",
            )
        ]
    return []


def _validate_cycle_sequence(loop_map: dict[str, Any]) -> list[str]:
    """Validate completed-cycle arithmetic, ordering, and attempt eligibility."""

    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    attempts = loop_map.get("attempts")
    if not isinstance(cycles, list) or not isinstance(attempts, list):
        return []
    cycle_list = cast("list[object]", cycles)
    attempt_list = cast("list[object]", attempts)
    errors: list[str] = []
    completed_count = loop_map.get("completed_cycle_count")
    if not is_non_negative_int(completed_count):
        errors.append(
            coded_error(
                REMEDIATION_COUNT_ERROR,
                "remediation_loop.completed_cycle_count",
                "must be a non-negative integer",
            )
        )
    elif completed_count != len(cycle_list):
        errors.append(
            coded_error(
                REMEDIATION_COUNT_ERROR,
                "remediation_loop.completed_cycle_count",
                f"must equal cycles length {len(cycle_list)}",
            )
        )

    cycle_ids = [
        cast("dict[str, Any]", cycle).get("cycle_id")
        for cycle in cycle_list
        if isinstance(cycle, dict)
    ]
    if len(cycle_ids) == len(cycle_list) and all(
        is_positive_int(cycle_id) for cycle_id in cycle_ids
    ):
        expected = list(range(1, len(cycle_list) + 1))
        if cycle_ids != expected:
            errors.append(
                coded_error(
                    REMEDIATION_SEQUENCE_ERROR,
                    "remediation_loop cycle_id sequence",
                    f"must be {expected}; received {cycle_ids}",
                )
            )

    attempt_by_id = {
        cast("dict[str, Any]", attempt).get("attempt_id"): cast(
            "dict[str, Any]", attempt
        )
        for attempt in attempt_list
        if isinstance(attempt, dict)
        and is_positive_int(cast("dict[str, Any]", attempt).get("attempt_id"))
    }
    references = [
        (index, cast("dict[str, Any]", cycle).get("attempt_id"))
        for index, cycle in enumerate(cycle_list)
        if isinstance(cycle, dict)
        and is_positive_int(cast("dict[str, Any]", cycle).get("attempt_id"))
    ]
    reference_ids = [attempt_id for _, attempt_id in references]
    if len(reference_ids) != len(set(reference_ids)):
        errors.append(
            coded_error(
                REMEDIATION_SEQUENCE_ERROR,
                "remediation_loop cycle attempt references",
                "must be unique",
            )
        )
    for cycle_index, attempt_id in references:
        attempt = attempt_by_id.get(attempt_id)
        subject = f"remediation_loop.cycles[{cycle_index}].attempt_id"
        if attempt is None:
            errors.append(
                coded_error(
                    REMEDIATION_TRANSITION_ERROR,
                    subject,
                    f"references missing attempt {attempt_id}",
                )
            )
            continue
        preflight = attempt.get("preflight")
        preflight_status = (
            cast("dict[str, Any]", preflight).get("final_status")
            if isinstance(preflight, dict)
            else None
        )
        eligibility = (
            (preflight_status == PREFLIGHT_CLEARED_STATUS, "preflight must be clear"),
            (
                attempt.get("execution_status") == "complete",
                "execution_status must be complete",
            ),
            (
                attempt.get("candidate_applied") is True,
                "candidate_applied must be true",
            ),
        )
        errors.extend(
            coded_error(REMEDIATION_TRANSITION_ERROR, subject, requirement)
            for valid, requirement in eligibility
            if not valid
        )
    return errors


def _validate_remediation_cycle(index: int, cycle: dict[str, Any]) -> list[str]:
    """Preserve the three documented invariants for one legacy cycle."""

    errors: list[str] = []
    plan_path = cycle.get("plan_path")
    if not isinstance(plan_path, str) or not plan_path.strip():
        errors.append(
            f"Checkpoint remediation cycle #{index} plan_path must be a "
            "non-empty string."
        )
    execution_status = cycle.get("execution_status")
    if execution_status in EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT:
        preflight = cycle.get("preflight")
        preflight_status: object = (
            cast("dict[str, Any]", preflight).get("final_status")
            if isinstance(preflight, dict)
            else None
        )
        if preflight_status != PREFLIGHT_CLEARED_STATUS:
            errors.append(
                f"Checkpoint remediation cycle #{index} execution_status is "
                f"{execution_status} but preflight.final_status is not 'clear'."
            )
    if cycle.get("exit_condition_met") is True and cycle.get("blocking_count") != 0:
        errors.append(
            f"Checkpoint remediation cycle #{index} exit_condition_met is true "
            "but blocking_count is not 0."
        )
    return errors


def validate_remediation_loop(
    remediation_loop: object,
    *,
    remediation_pass: object = _REMEDIATION_PASS_MISSING,
    issue_number: object = _VALIDATION_CONTEXT_MISSING,
    routing_policy_sha256: object = _VALIDATION_CONTEXT_MISSING,
    strict: bool = False,
) -> list[str]:
    """Validate versioned remediation state or preserve legacy cycle checks."""

    if not isinstance(remediation_loop, dict):
        if strict:
            return [
                schema_error(
                    "legacy remediation_loop",
                    "requires evidence-backed schema version 2 migration before "
                    "strict validation",
                )
            ]
        return []
    loop_map = cast("dict[str, Any]", remediation_loop)
    if is_versioned_remediation_loop(loop_map):
        errors = validate_versioned_schema(loop_map)
        errors.extend(_validate_cycle_sequence(loop_map))
        errors.extend(_validate_remediation_pass(loop_map, remediation_pass))
        errors.extend(
            validate_transitions(
                loop_map,
                issue_number=issue_number,
                routing_policy_sha256=routing_policy_sha256,
            )
        )
        return errors

    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    if not isinstance(cycles, list):
        errors: list[str] = []
    else:
        errors = []
        for index, cycle in enumerate(cast("list[object]", cycles)):
            if not isinstance(cycle, dict):
                errors.append(
                    f"Checkpoint remediation cycle #{index} must be an object."
                )
                continue
            errors.extend(
                _validate_remediation_cycle(index, cast("dict[str, Any]", cycle))
            )
    if strict:
        errors.append(
            schema_error(
                "legacy remediation_loop",
                "requires evidence-backed schema version 2 migration before "
                "strict validation",
            )
        )
    return errors
