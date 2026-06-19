"""Routing and mandatory handoff invariants for orchestrator checkpoints."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

ROUTING_MATRIX_PATH = (
    Path(__file__).resolve().parents[2] / "config" / "orchestration-routing.json"
)


def load_routing_matrix(path: Path = ROUTING_MATRIX_PATH) -> dict[str, Any]:
    """Load the repository routing matrix from disk."""

    loaded: object = json.loads(path.read_text(encoding="utf-8"))
    return cast("dict[str, Any]", loaded)


def _string_list(value: object) -> list[str] | None:
    """Return a list of strings only when the value has that exact shape."""

    if not isinstance(value, list):
        return None
    values = cast("list[object]", value)
    if not all(isinstance(item, str) and item.strip() for item in values):
        return None
    return cast("list[str]", values)


def _route_list(route: dict[str, Any], key: str) -> list[str]:
    """Read a required string-list field from one route entry."""

    value = _string_list(route.get(key))
    return [] if value is None else value


def _state_list(
    state: dict[str, Any], key: str, route_id: str, expected: list[str]
) -> list[str] | None:
    """Validate a state list against the routing matrix list."""

    value = _string_list(state.get(key))
    if value is None:
        return None
    if value != expected:
        return None
    return value


def _list_receipts(receipts: object) -> list[dict[str, Any]]:
    """Return legacy list delegation receipts as typed dictionaries."""

    if not isinstance(receipts, list):
        return []
    receipt_list = cast("list[object]", receipts)
    return [
        cast("dict[str, Any]", item) for item in receipt_list if isinstance(item, dict)
    ]


def _receipt_agents(state: dict[str, Any]) -> set[str]:
    """Collect agent names from delegation receipts."""

    agents: set[str] = set()
    for receipt in _list_receipts(state.get("delegation_receipts")):
        agent_name = receipt.get("agent_name")
        if isinstance(agent_name, str) and agent_name.strip():
            agents.add(agent_name)
    return agents


def _receipt_skills(state: dict[str, Any]) -> set[str]:
    """Collect acknowledged skill names from skill receipts."""

    skills: set[str] = set()
    receipts = state.get("skill_receipts")
    if not isinstance(receipts, list):
        return skills
    for receipt in cast("list[object]", receipts):
        if not isinstance(receipt, dict):
            continue
        receipt_map = cast("dict[str, object]", receipt)
        skill = receipt_map.get("skill")
        required = receipt_map.get("required")
        evidence = receipt_map.get("evidence")
        if (
            isinstance(skill, str)
            and skill.strip()
            and required is True
            and isinstance(evidence, str)
            and evidence.strip()
        ):
            skills.add(skill)
    return skills


def _mcp_tools(state: dict[str, Any]) -> set[str]:
    """Collect successful MCP tool receipts from checkpoint state."""

    tools: set[str] = set()
    receipts = state.get("mcp_call_receipts")
    if not isinstance(receipts, list):
        return tools
    for receipt in cast("list[object]", receipts):
        if not isinstance(receipt, dict):
            continue
        receipt_map = cast("dict[str, object]", receipt)
        tool = receipt_map.get("tool")
        ok = receipt_map.get("ok")
        evidence = receipt_map.get("evidence")
        if (
            isinstance(tool, str)
            and tool.strip()
            and ok is True
            and isinstance(evidence, str)
            and evidence.strip()
        ):
            tools.add(tool)
    return tools


def _validate_empty_list_field(state: dict[str, Any], key: str) -> list[str]:
    """Require a checkpoint field to exist as an empty list."""

    value = state.get(key)
    if not isinstance(value, list):
        return [f"Checkpoint {key} must be an empty list at completion."]
    if value:
        return [f"Checkpoint {key} must be empty at completion."]
    return []


def _validate_lifecycle_operations(state: dict[str, Any]) -> list[str]:
    """Reject lifecycle-operation records that did not use MCP."""

    operations = state.get("lifecycle_operations")
    if operations is None:
        return []
    if not isinstance(operations, list):
        return ["Checkpoint lifecycle_operations must be a list when present."]
    errors: list[str] = []
    for index, operation in enumerate(cast("list[object]", operations)):
        if not isinstance(operation, dict):
            errors.append(
                f"Checkpoint lifecycle_operations #{index} must be an object."
            )
            continue
        operation_map = cast("dict[str, object]", operation)
        if operation_map.get("surface") != "mcp":
            errors.append(
                f"Checkpoint lifecycle_operations #{index} did not use MCP surface."
            )
    return errors


def validate_routing_contract(
    state: dict[str, Any], *, routing_matrix: dict[str, Any] | None = None
) -> list[str]:
    """Validate mandatory route, handoff, skill, and MCP completion evidence."""

    matrix = routing_matrix if routing_matrix is not None else load_routing_matrix()
    raw_routes = matrix.get("routes")
    if not isinstance(raw_routes, dict):
        return ["Routing matrix missing routes object."]
    routes = cast("dict[str, object]", raw_routes)

    route_id = state.get("route_id", state.get("path_selected"))
    if not isinstance(route_id, str) or not route_id.strip():
        return ["Checkpoint route_id or path_selected must select a route."]
    raw_route = routes.get(route_id)
    if not isinstance(raw_route, dict):
        return [f"Checkpoint selected route has no routing-matrix entry: {route_id}."]
    route_map = cast("dict[str, Any]", raw_route)

    errors: list[str] = []
    required_agents = _route_list(route_map, "required_agents")
    required_skills = _route_list(route_map, "required_skills")
    required_mcp_tools = _route_list(route_map, "required_mcp_tools")

    if _state_list(state, "required_agents", route_id, required_agents) is None:
        errors.append(
            "Checkpoint required_agents must match routing matrix for route "
            f"{route_id}."
        )
    if _state_list(state, "required_skills", route_id, required_skills) is None:
        errors.append(
            "Checkpoint required_skills must match routing matrix for route "
            f"{route_id}."
        )
    if _state_list(state, "required_mcp_tools", route_id, required_mcp_tools) is None:
        errors.append(
            "Checkpoint required_mcp_tools must match routing matrix for route "
            f"{route_id}."
        )

    actual_agents = _receipt_agents(state)
    for agent in required_agents:
        if agent not in actual_agents:
            errors.append(f"Checkpoint missing required agent receipt: {agent}.")

    actual_skills = _receipt_skills(state)
    for skill in required_skills:
        if skill not in actual_skills:
            errors.append(f"Checkpoint missing required skill receipt: {skill}.")

    actual_tools = _mcp_tools(state)
    for tool in required_mcp_tools:
        if tool not in actual_tools:
            errors.append(f"Checkpoint missing successful MCP receipt: {tool}.")

    errors.extend(_validate_empty_list_field(state, "local_execution_overrides"))
    errors.extend(_validate_empty_list_field(state, "delegation_bypasses"))
    errors.extend(_validate_lifecycle_operations(state))
    return errors
