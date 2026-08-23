"""Validate deterministic Codex topology receipts in checkpoints."""

from __future__ import annotations

from typing import Any, TypedDict, cast

from scripts.dev_tools._orchestrator_state_codex_model_routing import (
    CODEX_MODEL_ROUTING_RECEIPTS_KEY,
    validate_codex_model_routing_receipts,
)
from scripts.dev_tools.resolve_codex_topology import (
    FORCED_ROOT_PERSONAS,
    CodexTopologyReceipt,
    resolve_codex_topology,
)

CODEX_TOPOLOGY_RECEIPTS_KEY = "codex_topology_receipts"
_REQUIRED_KEYS = (
    "phase",
    "execution_context",
    "languages",
    "production_file_count",
    "test_file_count",
    "cross_cutting",
    "root_persona",
    "route",
    "topology",
    "logical_agent",
    "routing_reason",
    "max_production_files",
    "max_test_files",
)
_RESOLVED_KEYS = tuple(key for key in _REQUIRED_KEYS if key != "phase")
_REQUIRED_KEY_SET = frozenset(_REQUIRED_KEYS)
_TopologyInputKey = tuple[tuple[str, ...], int, int, str, bool, str | None]


class _TopologyResolverInputs(TypedDict):
    """Type-safe resolver arguments extracted from a checkpoint receipt."""

    languages: list[str]
    production_file_count: int
    test_file_count: int
    execution_context: str
    cross_cutting: bool
    root_persona: str | None


def _receipt_inputs(
    receipt: dict[str, Any], prefix: str
) -> tuple[list[str], _TopologyResolverInputs | None]:
    """Validate resolver input types and return normalized invocation data."""

    errors: list[str] = []
    languages = receipt.get("languages")
    if not isinstance(languages, list) or any(
        not isinstance(language, str) or not language.strip()
        for language in cast("list[object]", languages)
    ):
        errors.append(f"{prefix}.languages must be a list of non-empty strings.")
    for key in ("production_file_count", "test_file_count"):
        value = receipt.get(key)
        if isinstance(value, bool) or not isinstance(value, int):
            errors.append(f"{prefix}.{key} must be an integer.")
    if not isinstance(receipt.get("cross_cutting"), bool):
        errors.append(f"{prefix}.cross_cutting must be a boolean.")
    if not isinstance(receipt.get("execution_context"), str):
        errors.append(f"{prefix}.execution_context must be a string.")
    root_persona = receipt.get("root_persona")
    if root_persona is not None and root_persona not in FORCED_ROOT_PERSONAS:
        errors.append(
            f"{prefix}.root_persona must be null or one of "
            f"{tuple(sorted(FORCED_ROOT_PERSONAS))}."
        )
    if errors:
        return errors, None
    return errors, {
        "languages": cast("list[str]", languages),
        "production_file_count": cast("int", receipt["production_file_count"]),
        "test_file_count": cast("int", receipt["test_file_count"]),
        "execution_context": cast("str", receipt["execution_context"]),
        "cross_cutting": cast("bool", receipt["cross_cutting"]),
        "root_persona": cast("str | None", root_persona),
    }


def validate_codex_topology_receipts(value: object) -> list[str]:
    """Validate every present receipt against the canonical topology resolver."""

    if not isinstance(value, list):
        return [
            f"Checkpoint {CODEX_TOPOLOGY_RECEIPTS_KEY} must be a list when present."
        ]

    errors: list[str] = []
    validated_receipts: dict[_TopologyInputKey, dict[str, object]] = {}
    last_valid_receipt: dict[str, Any] | None = None
    items = cast("list[object]", value)
    for index, item in enumerate(items):
        prefix = f"Checkpoint {CODEX_TOPOLOGY_RECEIPTS_KEY}[{index}]"
        if not isinstance(item, dict):
            errors.append(f"{prefix} must be an object.")
            continue
        receipt = cast("dict[str, Any]", item)
        phase = receipt.get("phase")
        if isinstance(phase, str) and phase.strip() and last_valid_receipt is not None:
            last_valid_receipt["phase"] = phase
            if receipt == last_valid_receipt:
                continue
        if not _REQUIRED_KEY_SET <= receipt.keys():
            missing = [key for key in _REQUIRED_KEYS if key not in receipt]
            errors.append(f"{prefix} missing required keys: {', '.join(missing)}.")
            continue
        if not isinstance(phase, str) or not phase.strip():
            errors.append(f"{prefix}.phase must be a non-empty string.")

        input_errors, inputs = _receipt_inputs(receipt, prefix)
        errors.extend(input_errors)
        if inputs is None:
            continue
        input_key: _TopologyInputKey = (
            tuple(inputs["languages"]),
            inputs["production_file_count"],
            inputs["test_file_count"],
            inputs["execution_context"],
            inputs["cross_cutting"],
            inputs["root_persona"],
        )
        expected_map = validated_receipts.get(input_key)
        if expected_map is None:
            try:
                expected = resolve_codex_topology(**inputs)
            except ValueError as exc:
                errors.append(f"{prefix} has invalid routing inputs: {exc}")
                continue
            expected_map = cast("dict[str, object]", expected)
            validated_receipts[input_key] = expected_map
        matches_expected = True
        for key in _RESOLVED_KEYS:
            if receipt.get(key) != expected_map[key]:
                matches_expected = False
                errors.append(
                    f"{prefix}.{key} must be {expected_map[key]!r}, "
                    f"found {receipt.get(key)!r}."
                )
        if matches_expected and isinstance(phase, str) and phase.strip():
            last_valid_receipt = dict(receipt)
    return errors


def _delegated_agent_names(state: dict[str, Any]) -> set[str]:
    """Collect exact names from legacy or object-form delegation receipts."""

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


def _model_deployments(state: dict[str, Any], logical_agent: str) -> set[str]:
    """Return exact, independently validated deployments for a logical agent."""

    result: set[str] = set()
    receipts = state.get(CODEX_MODEL_ROUTING_RECEIPTS_KEY)
    if not isinstance(receipts, list):
        return result
    for item in cast("list[object]", receipts):
        if not isinstance(item, dict):
            continue
        receipt = cast("dict[str, Any]", item)
        if validate_codex_model_routing_receipts([receipt]):
            continue
        if receipt.get("logical_agent") == logical_agent:
            deployment = receipt.get("deployment_agent")
            if isinstance(deployment, str):
                result.add(deployment)
    return result


def _valid_receipts(value: list[object]) -> list[CodexTopologyReceipt]:
    """Return structurally and deterministically valid receipt objects."""

    result: list[CodexTopologyReceipt] = []
    for item in value:
        if not isinstance(item, dict):
            continue
        receipt = cast("dict[str, Any]", item)
        if validate_codex_topology_receipts([receipt]):
            continue
        result.append(cast("CodexTopologyReceipt", receipt))
    return result


def validate_codex_topology_gate(
    state: dict[str, Any], *, required_root_persona: str | None = None
) -> list[str]:
    """Require topology receipts and exact initial-agent delegations."""

    delegated = _delegated_agent_names(state)
    if not delegated and required_root_persona is None:
        return []

    value = state.get(CODEX_TOPOLOGY_RECEIPTS_KEY)
    errors = validate_codex_topology_receipts(value)
    if not isinstance(value, list):
        return errors
    receipts = _valid_receipts(cast("list[object]", value))

    if required_root_persona is not None and not any(
        receipt["root_persona"] == required_root_persona for receipt in receipts
    ):
        errors.append(
            f"Checkpoint {CODEX_TOPOLOGY_RECEIPTS_KEY} is missing the forced "
            f"root persona receipt for {required_root_persona}."
        )

    non_root_receipts = [
        receipt for receipt in receipts if receipt["root_persona"] is None
    ]
    if delegated and not non_root_receipts:
        errors.append(
            f"Checkpoint {CODEX_TOPOLOGY_RECEIPTS_KEY} is missing a child "
            "topology receipt for recorded delegations."
        )
    for receipt in non_root_receipts:
        logical_agent = receipt["logical_agent"]
        selected_route = state.get("path_selected")
        if (
            receipt["execution_context"] == "standalone"
            and selected_route in {"small", "large"}
            and receipt["route"] != selected_route
        ):
            errors.append(
                f"Checkpoint path_selected {selected_route!r} does not match "
                f"the resolved Codex topology route {receipt['route']!r}."
            )
        allowed_names = {logical_agent} | _model_deployments(state, logical_agent)
        if delegated.isdisjoint(allowed_names):
            errors.append(
                f"Checkpoint delegation_receipts is missing the exact resolved "
                f"topology agent for {logical_agent}: "
                f"{', '.join(sorted(allowed_names))}."
            )
    return errors
