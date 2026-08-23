"""Validate Codex deployment receipts in orchestrator checkpoints."""

from __future__ import annotations

from typing import Any, cast

from scripts.dev_tools.compute_complexity_floor import BAND_ORDER, ComplexityBand
from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment

CODEX_MODEL_ROUTING_RECEIPTS_KEY = "codex_model_routing_receipts"
_REQUIRED_KEYS = (
    "logical_agent",
    "deployment_agent",
    "phase",
    "complexity_band",
    "execution_context",
    "orchestration_complexity_ceiling",
    "c3_overlay_applied",
    "c3_overlay_reason",
    "model",
    "model_reasoning_effort",
)
_RESOLVED_KEYS = tuple(key for key in _REQUIRED_KEYS if key != "phase")
_REQUIRED_KEY_SET = frozenset(_REQUIRED_KEYS)
_ModelInputKey = tuple[str, str, str, str]


def _validate_ceiling_transition(
    receipt: dict[str, Any],
    *,
    prefix: str,
    previous: ComplexityBand | None,
    current: ComplexityBand,
) -> list[str]:
    """Require transition evidence whenever the orchestration ceiling rises."""

    transition = receipt.get("ceiling_transition")
    if previous is None or current == previous:
        if transition is not None:
            return [
                f"{prefix}.ceiling_transition must be absent unless the ceiling rises."
            ]
        return []
    if not isinstance(transition, dict):
        return [f"{prefix}.ceiling_transition must record a ceiling increase."]
    transition_map = cast("dict[str, Any]", transition)
    affected = transition_map.get("affected_delegation_ids")
    errors: list[str] = []
    if transition_map.get("from") != previous or transition_map.get("to") != current:
        errors.append(
            f"{prefix}.ceiling_transition must record {previous} to {current}."
        )
    affected_items = (
        cast("list[object]", affected) if isinstance(affected, list) else []
    )
    if (
        not affected_items
        or any(not isinstance(item, str) or not item.strip() for item in affected_items)
        or len(set(cast("list[str]", affected_items))) != len(affected_items)
    ):
        errors.append(
            f"{prefix}.ceiling_transition.affected_delegation_ids must be a "
            "non-empty unique string list."
        )
    return errors


def validate_codex_model_routing_receipts(value: object) -> list[str]:
    """Validate every present receipt against the canonical Codex resolver."""

    if not isinstance(value, list):
        return [
            "Checkpoint "
            f"{CODEX_MODEL_ROUTING_RECEIPTS_KEY} must be a list when present."
        ]

    errors: list[str] = []
    previous_ceiling: ComplexityBand | None = None
    validated_receipts: dict[
        _ModelInputKey, tuple[dict[str, object], ComplexityBand]
    ] = {}
    validated_templates: dict[str, tuple[dict[str, Any], ComplexityBand]] = {}
    items = cast("list[object]", value)
    for index, item in enumerate(items):
        receipt_error_count = len(errors)
        prefix = f"Checkpoint {CODEX_MODEL_ROUTING_RECEIPTS_KEY}[{index}]"
        if not isinstance(item, dict):
            errors.append(f"{prefix} must be an object.")
            continue
        receipt = cast("dict[str, Any]", item)
        phase = receipt.get("phase")
        logical_agent = receipt.get("logical_agent")
        cached_template = (
            validated_templates.get(logical_agent)
            if isinstance(logical_agent, str)
            else None
        )
        if isinstance(phase, str) and phase.strip() and cached_template is not None:
            expected_receipt, current_ceiling = cached_template
            expected_receipt["phase"] = phase
            if (
                receipt == expected_receipt
                and previous_ceiling == current_ceiling
                and receipt.get("ceiling_transition") is None
            ):
                previous_ceiling = current_ceiling
                continue
        if not _REQUIRED_KEY_SET <= receipt.keys():
            missing = [key for key in _REQUIRED_KEYS if key not in receipt]
            errors.append(f"{prefix} missing required keys: {', '.join(missing)}.")
            continue
        if not isinstance(phase, str) or not phase.strip():
            errors.append(f"{prefix}.phase must be a non-empty string.")

        input_key: _ModelInputKey = (
            str(receipt["logical_agent"]),
            str(receipt["complexity_band"]),
            str(receipt["execution_context"]),
            str(receipt["orchestration_complexity_ceiling"]),
        )
        cached_expected = validated_receipts.get(input_key)
        if cached_expected is None:
            try:
                expected = resolve_codex_deployment(*input_key)
            except ValueError as exc:
                errors.append(f"{prefix} has invalid routing inputs: {exc}")
                continue

            current_ceiling = expected["orchestration_complexity_ceiling"]
            expected_map = cast("dict[str, object]", expected)
            validated_receipts[input_key] = expected_map, current_ceiling
        else:
            expected_map, current_ceiling = cached_expected

        for key in _RESOLVED_KEYS:
            if receipt.get(key) != expected_map[key]:
                errors.append(
                    f"{prefix}.{key} must be {expected_map[key]!r}, "
                    f"found {receipt.get(key)!r}."
                )

        if (
            previous_ceiling == current_ceiling
            and receipt.get("ceiling_transition") is None
        ):
            pass
        elif previous_ceiling is not None and BAND_ORDER.index(
            current_ceiling
        ) < BAND_ORDER.index(previous_ceiling):
            errors.append(
                f"{prefix}.orchestration_complexity_ceiling must be monotonic; "
                f"found {current_ceiling} after {previous_ceiling}."
            )
        elif previous_ceiling is not None:
            errors.extend(
                _validate_ceiling_transition(
                    receipt,
                    prefix=prefix,
                    previous=previous_ceiling,
                    current=current_ceiling,
                )
            )
        else:
            errors.extend(
                _validate_ceiling_transition(
                    receipt, prefix=prefix, previous=None, current=current_ceiling
                )
            )
        previous_ceiling = current_ceiling
        if len(errors) == receipt_error_count and isinstance(logical_agent, str):
            validated_templates[logical_agent] = dict(receipt), current_ceiling
    return errors


def _delegated_agent_names(state: dict[str, Any]) -> set[str]:
    """Collect logical or deployed names from delegation receipts."""

    result: set[str] = set()
    receipts = state.get("delegation_receipts")
    if isinstance(receipts, dict):
        receipts = cast("dict[str, object]", receipts).get("agents")
    if not isinstance(receipts, list):
        return result
    for item in cast("list[object]", receipts):
        if not isinstance(item, dict):
            continue
        agent_name = cast("dict[str, Any]", item).get("agent_name")
        if isinstance(agent_name, str) and agent_name.strip():
            result.add(agent_name)
    return result


def validate_codex_model_routing_gate(state: dict[str, Any]) -> list[str]:
    """Require a valid Codex deployment receipt for every recorded delegation."""

    delegated = _delegated_agent_names(state)
    if not delegated:
        return []

    value = state.get(CODEX_MODEL_ROUTING_RECEIPTS_KEY)
    errors = validate_codex_model_routing_receipts(value)
    if not isinstance(value, list):
        return errors

    logical_agents: set[str] = set()
    deployment_agents: set[str] = set()
    for item in cast("list[object]", value):
        if not isinstance(item, dict):
            continue
        receipt = cast("dict[str, Any]", item)
        logical = receipt.get("logical_agent")
        deployment = receipt.get("deployment_agent")
        if isinstance(logical, str):
            logical_agents.add(logical)
        if isinstance(deployment, str):
            deployment_agents.add(deployment)

    for agent in sorted(delegated):
        if agent not in logical_agents and agent not in deployment_agents:
            errors.append(
                f"Checkpoint {CODEX_MODEL_ROUTING_RECEIPTS_KEY} is missing a "
                f"receipt for delegated agent: {agent}."
            )
    return errors
