"""Validate canonical orchestrator checkpoint and remediation state.

Version 2 requires ``status``, cycle limits/counts, last fingerprint, attempts,
and cycles. ``REVIEW_VERDICT``, ``REMEDIATION_ACTION``, fingerprint, and path
fields drive pre-R1 terminal handling;
candidate application gates commit and R4, and only a completed R4 adds a cycle.
An unchanged fingerprint stops at ``blocked_stagnation`` unless one exact unused
exception applies. The third unresolved cycle uses only
``blocked_remediation_loop_limit``; ``blocked_cycle_limit`` is rejected legacy
input. Stable ``ORCH_*`` diagnostics preserve independent routing-gate identity.

Research belongs below a tracked feature ``research/`` folder or
``docs/research/``. ``require_pr_creation_ready`` excludes PR, CI, and pr-author
gates; ``require_complete`` retains those final lifecycle gates. Source, built,
and locally packed
candidates must agree before release; an incompatible published runtime is an
external-runtime result, not local parity or authorization to publish or pin.
"""

from __future__ import annotations

import hashlib
import json
from typing import Any, cast

from scripts.dev_tools import _orchestrator_state_codex_topology as codex_topology
from scripts.dev_tools._orchestrator_state_codex_model_routing import (
    CODEX_MODEL_ROUTING_RECEIPTS_KEY,
    validate_codex_model_routing_gate,
    validate_codex_model_routing_receipts,
)
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
from scripts.dev_tools._orchestrator_state_preparation_terminal import (
    validate_preparation_terminal_contract,
)
from scripts.dev_tools._orchestrator_state_routing import (
    ROUTING_MATRIX_PATH,
    route_requires_ci_gate,
    validate_completion_pr_gate,
    validate_phase_completeness,
    validate_route_membership,
    validate_routing_contract,
)
from scripts.dev_tools._orchestrator_state_step_status import (
    STEP_STATUS_KEYS,
    collect_completion_blocking_step_errors,
    collect_step_status_errors,
)
from scripts.dev_tools.validate_orchestrator_state_remediation import (
    REMEDIATION_LOOP_KEY,
    is_versioned_remediation_loop,
    validate_legacy_remediation_state,
    validate_remediation_loop,
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
AGENT_RECEIPT_NAMESPACE_KEY = "agents"
PROMOTION_RECEIPT_KEYS = (
    "potential_entry",
    "issue",
    "feature_folder",
)
CI_GATE_KEYS = ("conclusion", "head_sha", "verified_at")
ROUTING_GATE_LEGACY_ERROR = "ORCH_ROUTING_GATE_LEGACY"
ROUTING_GATE_CODEX_MODEL_ERROR = "ORCH_ROUTING_GATE_CODEX_MODEL"
ROUTING_GATE_CODEX_TOPOLOGY_ERROR = "ORCH_ROUTING_GATE_CODEX_TOPOLOGY"


def _coded_routing_gate_errors(code: str, errors: list[str]) -> list[str]:
    """Prefix one selected routing gate's diagnostics with its stable code."""

    return [f"{code}: {error}" for error in errors]


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
        key
        for key in receipts
        if key not in {AGENT_RECEIPT_NAMESPACE_KEY, PROMOTION_RECEIPT_NAMESPACE_KEY}
    )
    for key in unsupported_keys:
        errors.append(
            f"Checkpoint delegation_receipts object contains unsupported key: {key}"
        )

    if AGENT_RECEIPT_NAMESPACE_KEY in receipts:
        agent_receipts = receipts[AGENT_RECEIPT_NAMESPACE_KEY]
        if not isinstance(agent_receipts, list):
            errors.append("Checkpoint delegation_receipts.agents must be a list.")
        else:
            errors.extend(
                _validate_list_delegation_receipts(cast("list[object]", agent_receipts))
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
    require_codex_model_routing: bool = False,
    require_codex_topology: bool = False,
) -> list[str]:
    """Validate v2 remediation plus independent readiness, completion, and routing."""

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

    errors.extend(
        collect_step_status_errors(
            state_map, STEP_STATUS_KEYS, shared=VALID_STEP_STATUS
        )
    )

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

    strict_remediation = any(
        (
            require_complete,
            strict_route_membership,
            require_pr_creation_ready,
            require_model_routing,
            require_codex_model_routing,
            require_codex_topology,
        )
    )
    errors.extend(
        validate_legacy_remediation_state(
            review_status=state_map.get("review-status"),
            remediation_inputs_path=state_map.get("remediation-inputs-path"),
            remediation_plan_path=state_map.get("remediation-plan-path"),
            remediation_pass=state_map.get("remediation-pass"),
            strict=strict_remediation,
            versioned_remediation=is_versioned_remediation_loop(
                state_map.get(REMEDIATION_LOOP_KEY)
            ),
        )
    )

    if REMEDIATION_LOOP_KEY in state_map:
        remediation_pass = state_map.get("remediation-pass")
        routing_policy_sha256 = (
            f"sha256:{hashlib.sha256(ROUTING_MATRIX_PATH.read_bytes()).hexdigest()}"
        )
        if "remediation-pass" in state_map:
            errors.extend(
                validate_remediation_loop(
                    state_map.get(REMEDIATION_LOOP_KEY),
                    remediation_pass=remediation_pass,
                    issue_number=state_map.get("issue-num"),
                    routing_policy_sha256=routing_policy_sha256,
                    strict=strict_remediation,
                )
            )
        else:
            errors.extend(
                validate_remediation_loop(
                    state_map.get(REMEDIATION_LOOP_KEY),
                    issue_number=state_map.get("issue-num"),
                    routing_policy_sha256=routing_policy_sha256,
                    strict=strict_remediation,
                )
            )

    optional_key_validators = (
        (HUMAN_INTERACTION_KEY, _validate_human_interaction, False),
        (
            COMPLEXITY_ASSESSMENTS_KEY,
            _validate_complexity_assessments,
            require_model_routing,
        ),
        (
            MODEL_ROUTING_RECEIPTS_KEY,
            _validate_model_routing_receipts,
            require_model_routing,
        ),
        (
            CODEX_MODEL_ROUTING_RECEIPTS_KEY,
            validate_codex_model_routing_receipts,
            require_codex_model_routing,
        ),
        (
            codex_topology.CODEX_TOPOLOGY_RECEIPTS_KEY,
            codex_topology.validate_codex_topology_receipts,
            require_codex_topology,
        ),
    )
    for optional_key, optional_validator, selected in optional_key_validators:
        if optional_key in state_map and not selected:
            errors.extend(optional_validator(state_map.get(optional_key)))

    # The opt-in strict caller evaluates route membership so the completion gate
    # can reject unknown routes; non-strict legacy validation skips this work.
    if strict_route_membership:
        errors.extend(validate_route_membership(state_map))

    if require_complete:
        # Enforce completion-safe lifecycle states only when the caller opts into
        # the stricter completion gate.
        errors.extend(
            collect_completion_blocking_step_errors(state_map, STEP_STATUS_KEYS)
        )
        if state_map.get("blocked_reason") not in {None, "none"}:
            errors.append(
                "Checkpoint completion validation failed: blocked_reason is not `none`."
            )
        errors.extend(validate_completion_pr_gate(state_map))
        # The CI gate is route-driven: a route may opt out via
        # requires_ci_gate: false in the routing matrix (preparation-scope
        # routes never open a PR, so no CI run exists to verify). An absent
        # flag keeps the gate required, preserving prior behavior.
        if route_requires_ci_gate(state_map):
            errors.extend(_validate_completion_ci_gate(state_map))
        errors.extend(validate_phase_completeness(state_map))
        errors.extend(validate_routing_contract(state_map))
        errors.extend(validate_preparation_terminal_contract(state_map))

    if require_pr_creation_ready:
        # Independent of require_complete: the pre-PR-creation readiness gate
        # never calls the ci_gate/pr_gate/routing-contract checks above.
        errors.extend(validate_orchestrator_state_pr_creation_readiness(state_map))

    if require_model_routing:
        # Fires only once a delegation is recorded; else matches the plain call.
        errors.extend(
            _coded_routing_gate_errors(
                ROUTING_GATE_LEGACY_ERROR,
                validate_model_routing_gate(state_map),
            )
        )

    if require_codex_model_routing:
        errors.extend(
            _coded_routing_gate_errors(
                ROUTING_GATE_CODEX_MODEL_ERROR,
                validate_codex_model_routing_gate(state_map),
            )
        )
    if require_codex_topology:
        errors.extend(
            _coded_routing_gate_errors(
                ROUTING_GATE_CODEX_TOPOLOGY_ERROR,
                codex_topology.validate_codex_topology_gate(state_map),
            )
        )

    return errors
