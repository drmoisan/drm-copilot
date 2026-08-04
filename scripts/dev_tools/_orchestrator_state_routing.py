"""Routing and mandatory handoff invariants for orchestrator checkpoints."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

ROUTING_MATRIX_PATH = (
    Path(__file__).resolve().parents[2] / "config" / "orchestration-routing.json"
)
PR_GATE_KEYS = ("pr_number", "pr_url", "head_branch", "head_sha")
# The routing matrix records the feature-type promotion-entry MCP tool in every
# route's `required_mcp_tools`. A bug-type promotion genuinely exercises the
# bug-type tool instead, so the validator resolves the promotion-entry tool from
# the checkpoint's `promotion-type` rather than treating the matrix value as
# literal for every promotion type.
FEATURE_PROMOTION_ENTRY_TOOL = "new_potential_entry"
BUG_PROMOTION_ENTRY_TOOL = "new_potential_bug_entry"
# Mandatory canonical phases that must appear in `completed_steps` for a given
# route before completion. Routes absent from this map impose no phase-completeness
# requirement, preserving backward compatibility for routes without a defined set.
MANDATORY_ROUTE_PHASES: dict[str, tuple[str, ...]] = {
    "small": ("S3_promotion", "S4_atomic_planning"),
    "preparation": ("S3_promotion", "S4_atomic_planning"),
}


def load_routing_matrix(path: Path = ROUTING_MATRIX_PATH) -> dict[str, Any]:
    """Load the repository routing matrix from disk."""

    loaded: object = json.loads(path.read_text(encoding="utf-8"))
    return cast("dict[str, Any]", loaded)


def _selected_route_id(state: dict[str, Any]) -> str | None:
    """Return the checkpoint's selected route id, or None when unusable.

    Purpose:
        Resolve the route identifier used by routing checks from `route_id`,
        falling back to `path_selected`, so callers share one resolution rule.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.

    Returns:
        str | None: The non-empty route id string, or None when the value is
        absent, not a string, or empty/whitespace-only.

    Raises:
        None.

    Side Effects:
        None.
    """

    route_id = state.get("route_id", state.get("path_selected"))
    if not isinstance(route_id, str) or not route_id.strip():
        return None
    return route_id


def route_requires_pr_gate(
    state: dict[str, Any], *, routing_matrix: dict[str, Any] | None = None
) -> bool:
    """Report whether the checkpoint's route requires a PR gate.

    Purpose:
        Drive the PR-gate completion requirement from the routing matrix's
        per-route `requires_pr_gate` field instead of an issue-number literal.

    Args:
        state (dict[str, Any]): Parsed checkpoint state. The selected route is
            read from `route_id`, falling back to `path_selected`.
        routing_matrix (dict[str, Any] | None): Optional pre-loaded routing
            matrix. When None, the repository routing matrix is loaded from disk.

    Returns:
        bool: True only when the selected route exists in the matrix and its
        `requires_pr_gate` value is exactly the boolean True. A missing route id,
        an unknown route, or a missing/false `requires_pr_gate` returns False.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk when `routing_matrix` is None.
    """

    route_id = _selected_route_id(state)
    if route_id is None:
        return False

    matrix = routing_matrix if routing_matrix is not None else load_routing_matrix()
    raw_routes = matrix.get("routes")
    if not isinstance(raw_routes, dict):
        return False
    routes = cast("dict[str, object]", raw_routes)

    raw_route = routes.get(route_id)
    if not isinstance(raw_route, dict):
        return False
    route_map = cast("dict[str, Any]", raw_route)
    return route_map.get("requires_pr_gate") is True


def route_requires_ci_gate(
    state: dict[str, Any], *, routing_matrix: dict[str, Any] | None = None
) -> bool:
    """Report whether the checkpoint's route requires a CI gate at completion.

    Purpose:
        Let a route opt out of the completion `ci_gate` requirement via a
        per-route `requires_ci_gate: false` field, so preparation-scope routes
        that never open a PR (and therefore never run CI) can complete cleanly.

    Args:
        state (dict[str, Any]): Parsed checkpoint state. The selected route is
            read from `route_id`, falling back to `path_selected`.
        routing_matrix (dict[str, Any] | None): Optional pre-loaded routing
            matrix. When None, the repository routing matrix is loaded from disk.

    Returns:
        bool: False only when the selected route exists in the matrix and its
        `requires_ci_gate` value is exactly the boolean False. A missing route
        id, an unknown route, a malformed matrix, or an absent flag returns
        True, preserving the historical unconditional CI-gate requirement for
        every existing route.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk when `routing_matrix` is None.
    """

    route_id = _selected_route_id(state)
    if route_id is None:
        return True

    matrix = routing_matrix if routing_matrix is not None else load_routing_matrix()
    raw_routes = matrix.get("routes")
    if not isinstance(raw_routes, dict):
        return True
    routes = cast("dict[str, object]", raw_routes)

    raw_route = routes.get(route_id)
    if not isinstance(raw_route, dict):
        return True
    route_map = cast("dict[str, Any]", raw_route)
    # Only an explicit boolean False opts a route out; any other value keeps
    # the CI gate required so the exemption cannot be enabled by accident.
    return route_map.get("requires_ci_gate") is not False


def validate_route_membership(
    state: dict[str, Any], *, routing_matrix: dict[str, Any] | None = None
) -> list[str]:
    """Validate that the checkpoint's selected route exists in the matrix.

    Purpose:
        Reject a checkpoint whose `route_id` (falling back to `path_selected`)
        is absent, malformed, or not a known routing-matrix route, so fabricated
        execution modes such as `direct_powershell_engineer_remediation` are
        caught.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.
        routing_matrix (dict[str, Any] | None): Optional pre-loaded routing
            matrix. When None, the repository routing matrix is loaded from disk.

    Returns:
        list[str]: A single-element error list when the route id is missing,
        not a string, empty/whitespace-only, or not a key in `matrix["routes"]`;
        an empty list when the route id names a known route.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk when `routing_matrix` is None.
    """

    route_id = _selected_route_id(state)
    if route_id is None:
        return ["Checkpoint route_id or path_selected must select a route."]

    matrix = routing_matrix if routing_matrix is not None else load_routing_matrix()
    raw_routes = matrix.get("routes")
    if not isinstance(raw_routes, dict):
        return ["Routing matrix missing routes object."]
    routes = cast("dict[str, object]", raw_routes)

    # An unknown route id is the fabricated-route failure mode; name the route.
    if route_id not in routes:
        return [
            "Checkpoint selected route is not a routing-matrix route: " f"{route_id}."
        ]
    return []


def validate_phase_completeness(
    state: dict[str, Any], *, routing_matrix: dict[str, Any] | None = None
) -> list[str]:
    """Validate that the route's mandatory canonical phases were completed.

    Purpose:
        Verify that `completed_steps` contains every mandatory canonical phase
        for the selected route (for the `small` route: `S3_promotion` and
        `S4_atomic_planning`), so a route cannot reach completion while skipping
        a mandatory phase.

    Args:
        state (dict[str, Any]): Parsed checkpoint state. The selected route is
            read from `route_id`, falling back to `path_selected`. Completed
            phases are read from `completed_steps`.
        routing_matrix (dict[str, Any] | None): Accepted for interface symmetry
            with the other routing validators; the mandatory-phase set is read
            from `MANDATORY_ROUTE_PHASES`, not the matrix file.

    Returns:
        list[str]: One error string per missing mandatory phase. Returns an
        empty list when all mandatory phases are present, the route is unknown
        (route membership is validated separately), or the route imposes no
        mandatory-phase requirement.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Route membership and matrix loading are validated by the dedicated
    # functions; this check only consults the static mandatory-phase map.
    del routing_matrix

    route_id = _selected_route_id(state)
    if route_id is None:
        return []
    mandatory = MANDATORY_ROUTE_PHASES.get(route_id)
    if not mandatory:
        return []

    completed = _string_list(state.get("completed_steps"))
    present: set[str] = set(completed) if completed is not None else set()

    # Report each mandatory phase that the checkpoint did not record as complete.
    errors: list[str] = []
    for phase in mandatory:
        if phase not in present:
            errors.append(
                "Checkpoint completion validation failed: route "
                f"{route_id} is missing mandatory phase {phase}."
            )
    return errors


def _missing_pr_gate_keys(value: object) -> list[str]:
    """Return the PR-gate keys missing from a pr_gate object.

    Purpose:
        Identify which required PR-gate fields are absent or blank so the
        completion gate can name them in its error message.

    Args:
        value (object): The candidate pr_gate value from the checkpoint.

    Returns:
        list[str]: Missing key names. When `value` is not an object, every
        required key is reported as missing.

    Raises:
        None.

    Side Effects:
        None.
    """

    if not isinstance(value, dict):
        return list(PR_GATE_KEYS)
    value_map = cast("dict[str, object]", value)
    missing: list[str] = []
    # Treat absent values and blank strings as missing so the gate cannot be
    # satisfied by placeholder fields.
    for key in PR_GATE_KEYS:
        item = value_map.get(key)
        if item is None or (isinstance(item, str) and not item.strip()):
            missing.append(key)
    return missing


def validate_completion_pr_gate(
    state: dict[str, Any], *, routing_matrix: dict[str, Any] | None = None
) -> list[str]:
    """Validate PR-gate completion evidence when the route requires it.

    Purpose:
        Enforce the `pr_gate` completion contract only for routes whose
        `requires_pr_gate` field is True, replacing the prior issue-`232`
        special-casing with route-driven enforcement.

    Args:
        state (dict[str, Any]): Parsed checkpoint state.
        routing_matrix (dict[str, Any] | None): Optional pre-loaded routing
            matrix forwarded to the route lookup.

    Returns:
        list[str]: PR-gate validation errors. Returns an empty list when the
        route does not require a PR gate.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk when `routing_matrix` is None.
    """

    # The PR gate is only a completion requirement for routes that opt in via
    # the routing matrix; other routes return no pr_gate errors.
    if not route_requires_pr_gate(state, routing_matrix=routing_matrix):
        return []

    pr_gate: object = state.get("pr_gate")
    missing = _missing_pr_gate_keys(pr_gate)
    if not isinstance(pr_gate, dict):
        return [
            "Checkpoint completion validation failed: pr_gate must be an object "
            f"with keys: {', '.join(PR_GATE_KEYS)}."
        ]
    if missing:
        return [
            "Checkpoint completion validation failed: pr_gate missing required "
            f"fields: {', '.join(missing)}."
        ]
    return []


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


def _resolve_promotion_entry_tools(
    required_mcp_tools: list[str], state: dict[str, Any]
) -> list[str]:
    """Resolve the promotion-entry MCP tool to the checkpoint's promotion type.

    Purpose:
        The routing matrix records the feature-type promotion-entry tool
        (`new_potential_entry`) in every route's `required_mcp_tools`. A bug-type
        promotion genuinely exercises `new_potential_bug_entry` instead, so a
        bug-type checkpoint can never truthfully record a `new_potential_entry`
        receipt. This helper substitutes the bug-type promotion-entry tool for
        the feature-type one when, and only when, the checkpoint's hyphenated
        `promotion-type` key is exactly `"bug"`, leaving every other required
        tool untouched and preserving matrix order.

    Args:
        required_mcp_tools (list[str]): The route's declared `required_mcp_tools`
            list from the routing matrix, in matrix order.
        state (dict[str, Any]): Parsed checkpoint state. The promotion type is
            read from the hyphenated `promotion-type` key.

    Returns:
        list[str]: A new list in the same order as `required_mcp_tools`. When the
        checkpoint's `promotion-type` is exactly `"bug"`, each occurrence of
        `new_potential_entry` is replaced by `new_potential_bug_entry`. For a
        `feature` promotion type, an absent key, a non-string value, or any other
        value, the list is returned unchanged so feature and legacy checkpoints
        validate exactly as before.

    Raises:
        None.

    Side Effects:
        None.
    """

    promotion_type = state.get("promotion-type")
    # Only an explicit bug-type promotion swaps the promotion-entry tool.
    # Feature, absent, and any non-"bug" value keep the matrix list unchanged so
    # feature-type and legacy/absent checkpoints validate byte-identically to
    # the prior behavior.
    if promotion_type != "bug":
        return list(required_mcp_tools)

    # Substitute the bug-type promotion-entry tool for the feature-type one while
    # preserving matrix order and every other required tool exactly.
    return [
        BUG_PROMOTION_ENTRY_TOOL if tool == FEATURE_PROMOTION_ENTRY_TOOL else tool
        for tool in required_mcp_tools
    ]


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
    """Return legacy or namespaced strict receipts as typed dictionaries."""

    if isinstance(receipts, dict):
        receipts = cast("dict[str, object]", receipts).get("agents")
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
    # Resolve the promotion-entry MCP tool to the checkpoint's promotion type so
    # a bug-type promotion is validated against `new_potential_bug_entry` rather
    # than the matrix's feature-type `new_potential_entry`. The resolved list is
    # applied to both the exact-match check below and the receipt-presence loop
    # further down, keeping the expected tool set consistent between them.
    required_mcp_tools = _resolve_promotion_entry_tools(
        _route_list(route_map, "required_mcp_tools"), state
    )

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
