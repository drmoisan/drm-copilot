"""Validate provider-native and portable orchestration checkpoint artifacts."""

from __future__ import annotations

import json
from typing import Any, cast

from scripts.dev_tools import _orchestrator_state_codex_topology as codex_topology
from scripts.dev_tools import orchestration_handoff_contract as handoff
from scripts.dev_tools._orchestrator_state_blocked_reason import VALID_BLOCKED_REASONS
from scripts.dev_tools._orchestrator_state_codex_model_routing import (
    CODEX_MODEL_ROUTING_RECEIPTS_KEY,
    validate_codex_model_routing_gate,
    validate_codex_model_routing_receipts,
)
from scripts.dev_tools._orchestrator_state_complexity import (
    COMPLEXITY_ASSESSMENTS_KEY,
    _validate_complexity_assessments,
)
from scripts.dev_tools._orchestrator_state_concurrent_review import (
    validate_concurrent_review_completion,
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
from scripts.dev_tools._orchestrator_state_remediation_loop import (
    REMEDIATION_LOOP_KEY,
    _validate_remediation_loop,
)
from scripts.dev_tools._orchestrator_state_routing import (
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
LOCAL_QC_GATE_KEYS = ("conclusion", "head_sha", "evidence_path", "verified_at")
CHILD_CI_INTEGRATION_ONLY = "integration_only"


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


def _child_ci_integration_only(state: dict[str, Any]) -> bool:
    """Report whether a checkpoint opts its epic child out of per-child CI.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        bool: True only when `epic_mode` is the JSON boolean true and
        `child_ci` is the exact string `integration_only` (issue #1233).
    """
    child_ci = state.get("child_ci")
    return (
        state.get("epic_mode") is True
        and isinstance(child_ci, str)
        and child_ci == CHILD_CI_INTEGRATION_ONLY
    )


def _last_review_head_sha(state: dict[str, Any]) -> object:
    """Return the `head_sha` of the final `review_outcomes` entry, or None.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        object: The recorded value, or None when the loop, the list, or the
        last object entry is absent.
    """
    loop = state.get("remediation_loop")
    if not isinstance(loop, dict):
        return None
    outcomes = cast("dict[str, object]", loop).get("review_outcomes")
    if not isinstance(outcomes, list) or not outcomes:
        return None
    last = cast("list[object]", outcomes)[-1]
    if not isinstance(last, dict):
        return None
    return cast("dict[str, object]", last).get("head_sha")


def _validate_completion_local_qc_gate(state: dict[str, Any]) -> list[str]:
    """Validate the local final-QC gate of an opted-out epic child.

    Args:
        state (dict[str, Any]): Parsed checkpoint state under the opt-out.

    Returns:
        list[str]: The ordered completion errors: the object-shape error
        alone, otherwise the missing fields, the conclusion, and then either
        the review-mode error or, under concurrent review, the head binding.
    """
    gate = state.get("local_qc_gate")
    if not isinstance(gate, dict):
        return [
            "Checkpoint completion validation failed: child_ci integration_only "
            "requires local_qc_gate to be an object with keys: "
            f"{', '.join(LOCAL_QC_GATE_KEYS)}."
        ]
    errors: list[str] = []
    gate_map = cast("dict[str, object]", gate)
    missing = _missing_object_keys(gate_map, LOCAL_QC_GATE_KEYS)
    if missing:
        errors.append(
            "Checkpoint completion validation failed: local_qc_gate missing "
            f"required fields: {', '.join(missing)}."
        )
    if gate_map.get("conclusion") != "success":
        errors.append(
            "Checkpoint completion validation failed: local_qc_gate.conclusion "
            "must be success."
        )
    if state.get("review_mode") != "concurrent":
        errors.append(
            "Checkpoint completion validation failed: child_ci integration_only "
            "requires review_mode concurrent."
        )
        return errors
    last_head = _last_review_head_sha(state)
    if not isinstance(last_head, str) or gate_map.get("head_sha") != last_head:
        errors.append(
            "Checkpoint completion validation failed: local_qc_gate.head_sha must "
            "match the head_sha of the last review_outcomes entry."
        )
    return errors


def validate_completion_gate_evidence(state: dict[str, Any]) -> list[str]:
    """Select the completion gate check for a CI-gated route (issue #1233).

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        list[str]: The local-QC errors when the checkpoint opts its epic child
        out of per-child CI, otherwise the existing `ci_gate` errors.
    """
    if _child_ci_integration_only(state):
        return _validate_completion_local_qc_gate(state)
    return _validate_completion_ci_gate(state)


def _validate_list_delegation_receipts(receipts: list[object]) -> list[str]:
    """Validate legacy list receipts without normalizing their payloads."""

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
    """Validate namespaced receipts while retaining opaque receipt values."""

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


def _build_portable_envelope(state: dict[str, Any]) -> handoff.HandoffEnvelope:
    source = cast("dict[str, Any]", state["source"])
    checkpoint = cast("dict[str, Any]", source["checkpoint"])
    expression = cast("dict[str, Any]", source["expression"])
    receipt_container = cast("dict[str, Any]", expression["historical_receipts"])
    references = tuple(
        handoff.ReceiptReference(**cast("dict[str, Any]", item))
        for item in cast("list[object]", receipt_container["references"])
    )
    provenance = handoff.ProviderProvenance(
        source["provider"],
        checkpoint["path"],
        checkpoint["sha256"],
        checkpoint["archive_path"],
        expression["schema_id"],
        expression["schema_version"],
        references,
    )
    history = tuple(
        handoff.HistoryEntry(**cast("dict[str, Any]", item))
        for item in cast("list[object]", state["handoff_history"])
    )
    destination = cast("dict[str, Any]", state["destination"])
    return handoff.HandoffEnvelope(
        state["schema_version"],
        state["kind"],
        state["handoff_id"],
        handoff.ObjectiveIdentity(**cast("dict[str, Any]", state["identity"])),
        handoff.WorkspaceBinding(**cast("dict[str, Any]", state["binding"])),
        provenance,
        destination["provider"],
        destination["checkpoint_path"],
        handoff.PlanIdentity(**cast("dict[str, Any]", state["plan"])),
        handoff.LifecycleState(**cast("dict[str, Any]", state["lifecycle"])),
        handoff.CapabilityRequirements(**cast("dict[str, Any]", state["capabilities"])),
        handoff.SchedulerContext(**cast("dict[str, Any]", state["scheduler_context"])),
        history,
    )


def _validate_portable_envelope(state: dict[str, Any]) -> list[str]:
    try:
        envelope = _build_portable_envelope(state)
        handoff.validate_history_chain(envelope.handoff_history)
    except (KeyError, TypeError, ValueError) as exc:
        return [f"Portable handoff envelope is invalid: {exc}"]
    return []


def _validate_portable_projection(state: dict[str, Any]) -> list[str]:
    try:
        link = cast("dict[str, Any]", state["portable_handoff"])
        plan = handoff.PlanIdentity(**cast("dict[str, Any]", link["plan"]))
        lifecycle = handoff.LifecycleState(**cast("dict[str, Any]", link["lifecycle"]))
        handoff.SchedulerContext(**cast("dict[str, Any]", link["scheduler_context"]))
        for key in ("envelope_sha256", "history_entry_sha256"):
            if handoff.SHA256_PATTERN.fullmatch(link[key]) is None:
                raise handoff.HandoffContractError(f"portable_handoff.{key}", "invalid")
        if (
            state.get("plan-path") != plan.path
            or state.get("next_step") != lifecycle.next_transition
        ):
            raise handoff.HandoffContractError("portable_handoff", "projection drift")
    except (KeyError, TypeError, ValueError) as exc:
        return [f"Portable destination projection is invalid: {exc}"]
    return []


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
    """Validate checkpoint structure and opt-in completion/routing gates.

    The Codex flag requires deployment receipts once a delegation is recorded;
    the existing model-routing flag preserves the independent Claude policy.
    Route checks may read the central routing matrix. The input is never mutated.
    """

    errors: list[str] = []
    try:
        state = json.loads(text)
    except json.JSONDecodeError as exc:
        return [f"Checkpoint is not valid JSON: {exc}"]

    if not isinstance(state, dict):
        return ["Checkpoint root must be a JSON object."]
    state_map = cast("dict[str, Any]", state)
    if state_map.get("kind") == "portable_orchestration_handoff":
        return _validate_portable_envelope(state_map)
    if "portable_handoff" in state_map:
        errors.extend(_validate_portable_projection(state_map))

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
    if blocked_reason is not None and (
        not isinstance(blocked_reason, str)
        or blocked_reason not in VALID_BLOCKED_REASONS
    ):
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

    optional_key_validators = (
        (REMEDIATION_LOOP_KEY, _validate_remediation_loop),
        (HUMAN_INTERACTION_KEY, _validate_human_interaction),
        (COMPLEXITY_ASSESSMENTS_KEY, _validate_complexity_assessments),
        (MODEL_ROUTING_RECEIPTS_KEY, _validate_model_routing_receipts),
        (
            CODEX_MODEL_ROUTING_RECEIPTS_KEY,
            validate_codex_model_routing_receipts,
        ),
        (
            codex_topology.CODEX_TOPOLOGY_RECEIPTS_KEY,
            codex_topology.validate_codex_topology_receipts,
        ),
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
            errors.extend(validate_completion_gate_evidence(state_map))
        errors.extend(validate_phase_completeness(state_map))
        errors.extend(validate_routing_contract(state_map))
        errors.extend(validate_preparation_terminal_contract(state_map))
        errors.extend(validate_concurrent_review_completion(state_map))

    if require_pr_creation_ready:
        # Independent of require_complete: the pre-PR-creation readiness gate
        # never calls the ci_gate/pr_gate/routing-contract checks above.
        errors.extend(validate_orchestrator_state_pr_creation_readiness(state_map))

    if require_model_routing:
        # Fires only once a delegation is recorded; else matches the plain call.
        errors.extend(validate_model_routing_gate(state_map))

    if require_codex_model_routing:
        errors.extend(validate_codex_model_routing_gate(state_map))
    if require_codex_topology:
        errors.extend(codex_topology.validate_codex_topology_gate(state_map))

    return errors


if __name__ == "__main__":
    from scripts.dev_tools.validate_orchestrator_state_cli import main

    raise SystemExit(main(validate=validate_orchestrator_state_text))
