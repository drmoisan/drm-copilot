"""Validate orchestration checkpoint state artifacts.

Purpose:
    Hold the orchestrator-state validation logic and receipt-namespace rules so
    the stable CLI entrypoint can remain small while preserving the existing
    validator contract.

Usage:
    Import ``validate_orchestrator_state_text`` from
    ``scripts.dev_tools.validate_orchestration_artifacts`` or this module.

Flow:
    Parse the checkpoint JSON, validate required top-level keys and status
    values, then validate the legacy list, top-level promotion, or additive
    ``delegation_receipts.promotion.*`` receipt forms.

Invariants / Constraints:
    - The validator accepts the legacy list, top-level promotion receipts, and
      the additive promotion namespace forms for receipt evidence.
    - Unsupported namespace keys are rejected.
    - The validator returns error strings and never mutates the checkpoint.
"""

from __future__ import annotations

import json
from typing import Any, cast

from scripts.dev_tools._orchestrator_state_complexity import (
    COMPLEXITY_ASSESSMENTS_KEY,
    _validate_complexity_assessments,
)
from scripts.dev_tools._orchestrator_state_human_interaction import (
    HUMAN_INTERACTION_KEY,
    _validate_human_interaction,
)
from scripts.dev_tools._orchestrator_state_model_routing import (
    MODEL_ROUTING_RECEIPTS_KEY,
    _validate_model_routing_receipts,
)
from scripts.dev_tools._orchestrator_state_model_routing_gate import (
    validate_model_routing_gate,
)
from scripts.dev_tools._orchestrator_state_pr_creation_readiness import (
    validate_orchestrator_state_pr_creation_readiness,
)
from scripts.dev_tools._orchestrator_state_routing import (
    validate_completion_pr_gate,
    validate_phase_completeness,
    validate_route_membership,
    validate_routing_contract,
)

REQUIRED_STATE_KEYS = (
    "objective",
    "change_budget_estimate",
    "path_selected",
    "promotion-type",
    "short-name",
    "relativeFile",
    "long-name",
    "issue-num",
    "feature-folder",
    "work-mode",
    "plan-path",
    "completed_steps",
    "next_step",
    "last_updated",
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
    "delegation_receipts",
    "blocked_reason",
)
VALID_STEP_STATUS = {
    "not-applicable",
    "pending",
    "delegated",
    "verified",
    "blocked",
    "not_started",
    "in_progress",
    "completed",
}
VALID_BLOCKED_REASONS = {
    "none",
    "spawn_agent_unavailable",
    "delegation_launch_failed",
    "delegate_no_receipt",
    "delegate_contract_incomplete",
    "validator_failed",
    "user_requested_stop",
}
STEP_STATUS_KEYS = (
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
)
REQUIRED_RECEIPT_KEYS = (
    "step",
    "agent_name",
    "agent_id",
    "skill_source",
    "started_at",
    "completed_at",
    "result_signal",
    "artifact_paths",
)
PROMOTION_RECEIPT_NAMESPACE_KEY = "promotion"
PROMOTION_RECEIPT_KEYS = (
    "potential_entry",
    "issue",
    "feature_folder",
)
CI_GATE_KEYS = ("conclusion", "head_sha", "verified_at")
REMEDIATION_LOOP_KEY = "remediation_loop"
REMEDIATION_CYCLES_KEY = "cycles"
# Execution statuses that may only be recorded once a cycle's preflight gate has
# cleared; recording any of these before preflight clears is a malformed cycle.
EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT = {
    "in_progress",
    "complete",
    "failed",
}
PREFLIGHT_CLEARED_STATUS = "clear"


def _validate_remediation_cycle(index: int, cycle: dict[str, Any]) -> list[str]:
    """Validate the three invariants for one remediation cycle.

    Purpose:
        Enforce the orchestrator-state remediation-cycle invariants documented
        in `.claude/rules/orchestrator-state.md` for a single cycle object:
        non-empty `plan_path`, execution only after a cleared preflight, and a
        satisfied exit gate only with zero blocking findings.

    Args:
        index (int): Zero-based position of this cycle within the
            `remediation_loop.cycles` array, used for error context.
        cycle (dict[str, Any]): The raw cycle object extracted from the
            checkpoint JSON.

    Returns:
        list[str]: One error string per violated invariant; an empty list when
        the cycle satisfies all three invariants.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []

    # Invariant 1: plan_path must be a non-empty, non-whitespace string.
    plan_path = cycle.get("plan_path")
    if not isinstance(plan_path, str) or not plan_path.strip():
        errors.append(
            f"Checkpoint remediation cycle #{index} plan_path must be a "
            "non-empty string."
        )

    # Invariant 2: an execution status in the blocked set requires that the
    # cycle's preflight gate reports exactly the cleared status.
    execution_status = cycle.get("execution_status")
    if execution_status in EXECUTION_STATUSES_REQUIRING_CLEAR_PREFLIGHT:
        preflight = cycle.get("preflight")
        # Read the nested preflight final status defensively; a missing or
        # non-object preflight cannot satisfy the cleared requirement.
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

    # Invariant 3: a satisfied exit gate requires zero blocking findings.
    if cycle.get("exit_condition_met") is True and cycle.get("blocking_count") != 0:
        errors.append(
            f"Checkpoint remediation cycle #{index} exit_condition_met is true "
            "but blocking_count is not 0."
        )

    return errors


def _validate_remediation_loop(remediation_loop: object) -> list[str]:
    errors: list[str] = []

    # A non-object remediation_loop carries no cycles to validate; treat it as
    # nothing to enforce rather than fabricating a structural error here.
    if not isinstance(remediation_loop, dict):
        return errors
    loop_map = cast("dict[str, Any]", remediation_loop)

    cycles = loop_map.get(REMEDIATION_CYCLES_KEY)
    if not isinstance(cycles, list):
        return errors
    cycle_list = cast("list[object]", cycles)

    # Validate each cycle independently so callers receive a complete error
    # list instead of stopping at the first malformed cycle.
    for index, cycle in enumerate(cycle_list):
        if not isinstance(cycle, dict):
            errors.append(f"Checkpoint remediation cycle #{index} must be an object.")
            continue
        errors.extend(_validate_remediation_cycle(index, cast("dict[str, Any]", cycle)))

    return errors


def _missing_object_keys(value: object, keys: tuple[str, ...]) -> list[str]:
    if not isinstance(value, dict):
        return list(keys)
    value_map = cast("dict[str, object]", value)
    missing: list[str] = []
    for key in keys:
        item = value_map.get(key)
        if item is None or (isinstance(item, str) and not item.strip()):
            missing.append(key)
    return missing


def _validate_completion_ci_gate(state: dict[str, Any]) -> list[str]:
    ci_gate = state.get("ci_gate")
    missing = _missing_object_keys(ci_gate, CI_GATE_KEYS)
    if not isinstance(ci_gate, dict):
        return [
            "Checkpoint completion validation failed: ci_gate must be an object "
            f"with keys: {', '.join(CI_GATE_KEYS)}."
        ]
    errors: list[str] = []
    if missing:
        errors.append(
            "Checkpoint completion validation failed: ci_gate missing required "
            f"fields: {', '.join(missing)}."
        )
    ci_map = cast("dict[str, object]", ci_gate)
    if ci_map.get("conclusion") != "success":
        errors.append(
            "Checkpoint completion validation failed: ci_gate.conclusion must be "
            "success."
        )
    pr_gate = state.get("pr_gate")
    if isinstance(pr_gate, dict):
        pr_map = cast("dict[str, object]", pr_gate)
        pr_head_sha = pr_map.get("head_sha")
    else:
        pr_head_sha = None
    if pr_head_sha is not None and ci_map.get("head_sha") != pr_head_sha:
        errors.append(
            "Checkpoint completion validation failed: ci_gate.head_sha must match "
            "pr_gate.head_sha."
        )
    return errors


def _validate_list_delegation_receipts(receipts: list[object]) -> list[str]:
    """Validate the legacy list-based delegation receipt payload.

    Purpose:
        Preserve compatibility with older checkpoints that store delegation
        receipts as a list of receipt objects.

    Args:
        receipts (list[object]): Raw receipt payload extracted from the
            checkpoint JSON.

    Returns:
        list[str]: Validation errors for any malformed receipt objects.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []

    # Validate each legacy receipt independently so callers receive a complete
    # error list instead of stopping at the first malformed item.
    for index, receipt in enumerate(receipts):
        if not isinstance(receipt, dict):
            errors.append(f"Checkpoint delegation receipt #{index} must be an object.")
            continue
        for key in REQUIRED_RECEIPT_KEYS:
            if key not in receipt:
                errors.append(
                    f"Checkpoint delegation receipt #{index} missing key: {key}"
                )
        artifact_paths = cast("dict[str, Any]", receipt).get("artifact_paths")
        if artifact_paths is not None and not isinstance(artifact_paths, list):
            errors.append(
                "Checkpoint delegation receipt "
                f"#{index} artifact_paths must be a list."
            )

    return errors


def _validate_namespaced_delegation_receipts(receipts: dict[str, Any]) -> list[str]:
    """Validate the additive object namespace form of delegation receipts.

    Purpose:
        Enforce the reviewed ``delegation_receipts.promotion.*`` contract while
        keeping the raw receipt payloads opaque to the validator.

    Args:
        receipts (dict[str, Any]): Object-form receipt payload extracted from
            the checkpoint JSON.

    Returns:
        list[str]: Validation errors for unsupported object-shape keys.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    unsupported_keys = sorted(
        key for key in receipts if key != PROMOTION_RECEIPT_NAMESPACE_KEY
    )
    for key in unsupported_keys:
        errors.append(
            f"Checkpoint delegation_receipts object contains unsupported key: {key}"
        )

    promotion_receipts = receipts.get(PROMOTION_RECEIPT_NAMESPACE_KEY)
    if promotion_receipts is None:
        return errors
    if not isinstance(promotion_receipts, dict):
        errors.append(
            "Checkpoint delegation_receipts.promotion must be an object namespace."
        )
        return errors

    promotion_receipt_map = cast("dict[str, Any]", promotion_receipts)
    unsupported_promotion_keys = sorted(
        key for key in promotion_receipt_map if key not in PROMOTION_RECEIPT_KEYS
    )

    # Reject unknown nested keys while leaving the documented raw receipt values
    # untouched and unnormalized.
    for key in unsupported_promotion_keys:
        errors.append(
            "Checkpoint delegation_receipts.promotion contains unsupported key: "
            f"{key}"
        )

    return errors


def validate_orchestrator_state_text(
    text: str,
    *,
    require_complete: bool = False,
    strict_route_membership: bool = False,
    require_pr_creation_ready: bool = False,
    require_model_routing: bool = False,
) -> list[str]:
    """Validate checkpoint schema and completion-state fields.

    Purpose:
        Enforce the repository contract for orchestrator-state artifacts before
        resume or review workflows rely on the checkpoint contents.

    Args:
        text (str): Raw checkpoint JSON text.
        require_complete (bool): When True, require all tracked lifecycle states
            to be completion-safe and verify route phase completeness.
        strict_route_membership (bool): When True, append route-membership
            errors so a checkpoint selecting an unknown route is rejected. When
            False (default), route-membership errors are not appended, preserving
            backward compatibility for checkpoints without `route_id`/
            `path_selected`.
        require_pr_creation_ready (bool): When True, append the result of
            `validate_orchestrator_state_pr_creation_readiness`, a narrower
            pre-PR-creation check independent of `require_complete` that does
            not require `ci_gate`, `pr_gate`, or routing-contract delegation
            receipts. Defaults to False.
        require_model_routing (bool): When True, append
            `validate_model_routing_gate` results, requiring routing receipts and
            complexity assessments once a delegation is recorded. Defaults False.

    Returns:
        list[str]: Validation errors for malformed or incomplete checkpoint
        state.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk when completion/route checks run.
    """

    errors: list[str] = []
    try:
        state = json.loads(text)
    except json.JSONDecodeError as exc:
        return [f"Checkpoint is not valid JSON: {exc}"]

    if not isinstance(state, dict):
        return ["Checkpoint root must be a JSON object."]
    state_map = cast("dict[str, Any]", state)

    # Require the canonical top-level fields before evaluating deeper state and
    # receipt invariants.
    for key in REQUIRED_STATE_KEYS:
        if key not in state_map:
            errors.append(f"Checkpoint missing required key: {key}")

    for key in STEP_STATUS_KEYS:
        value = state_map.get(key)
        if value is not None and value not in VALID_STEP_STATUS:
            errors.append(f"Checkpoint has invalid {key}: {value}")

    blocked_reason = state_map.get("blocked_reason")
    if blocked_reason is not None and blocked_reason not in VALID_BLOCKED_REASONS:
        errors.append(f"Checkpoint has invalid blocked_reason: {blocked_reason}")

    receipts = state_map.get("delegation_receipts")
    if receipts is not None:
        if isinstance(receipts, list):
            errors.extend(
                _validate_list_delegation_receipts(cast("list[object]", receipts))
            )
        elif isinstance(receipts, dict):
            errors.extend(
                _validate_namespaced_delegation_receipts(
                    cast("dict[str, Any]", receipts)
                )
            )
        else:
            errors.append(
                "Checkpoint delegation_receipts must be a list or object namespace."
            )

    # Each additive optional checkpoint block is validated only when its key is
    # present; an absent key contributes zero errors, preserving backward
    # compatibility for checkpoints that predate the block.
    optional_key_validators = (
        (REMEDIATION_LOOP_KEY, _validate_remediation_loop),
        (HUMAN_INTERACTION_KEY, _validate_human_interaction),
        (COMPLEXITY_ASSESSMENTS_KEY, _validate_complexity_assessments),
        (MODEL_ROUTING_RECEIPTS_KEY, _validate_model_routing_receipts),
    )
    for optional_key, optional_validator in optional_key_validators:
        if optional_key in state_map:
            errors.extend(optional_validator(state_map.get(optional_key)))

    # Route membership is evaluated unconditionally so the opt-in strict caller
    # (the completion gate) can reject unknown routes; non-strict callers ignore
    # the result, preserving backward compatibility for legacy checkpoints.
    route_membership_errors = validate_route_membership(state_map)
    if strict_route_membership:
        errors.extend(route_membership_errors)

    if require_complete:
        # Enforce completion-safe lifecycle states only when the caller opts into
        # the stricter completion gate.
        for key in STEP_STATUS_KEYS:
            value = state_map.get(key)
            if value in {"pending", "blocked"}:
                errors.append(
                    f"Checkpoint completion validation failed: {key} is {value}."
                )
        if state_map.get("blocked_reason") not in {None, "none"}:
            errors.append(
                "Checkpoint completion validation failed: blocked_reason is not `none`."
            )
        errors.extend(validate_completion_pr_gate(state_map))
        errors.extend(_validate_completion_ci_gate(state_map))
        errors.extend(validate_phase_completeness(state_map))
        errors.extend(validate_routing_contract(state_map))

    if require_pr_creation_ready:
        # Independent of require_complete: the pre-PR-creation readiness gate
        # never calls the ci_gate/pr_gate/routing-contract checks above.
        errors.extend(validate_orchestrator_state_pr_creation_readiness(state_map))

    if require_model_routing:
        # Fires only once a delegation is recorded; else matches the plain call.
        errors.extend(validate_model_routing_gate(state_map))

    return errors
