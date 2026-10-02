"""Route-selection and completion-gate helpers for orchestrator checkpoints.

Purpose:
    Hold the routing-matrix loader, the selected-route resolution rule, the
    per-route PR-gate and CI-gate predicates, route-membership and
    mandatory-phase validation, and the PR-gate completion check. These were
    moved verbatim from the routing-contract module so that module stays
    within the repository's 500-line file limit.

Usage:
    Import the names listed in ``__all__`` from this module. The
    routing-contract module re-exports every one of them, so existing callers
    continue to resolve them from their original import location unchanged.

Invariants / Constraints:
    - ``ROUTING_MATRIX_PATH`` resolves to ``config/orchestration-routing.json``
      at the repository root.
    - This module imports nothing from ``scripts.dev_tools``.

Side Effects:
    ``load_routing_matrix`` and the validators that default to it read the
    routing matrix from disk when no pre-loaded matrix is supplied.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

# Declare the module's intended exported surface. Listing the private helpers
# here marks them as deliberate re-exports consumed by the routing-contract
# module, so static analysis does not flag them as unused locally or as
# private-usage when imported across the module boundary.
__all__ = [
    "ROUTING_MATRIX_PATH",
    "PR_GATE_KEYS",
    "MANDATORY_ROUTE_PHASES",
    "load_routing_matrix",
    "_selected_route_id",
    "route_requires_pr_gate",
    "route_requires_ci_gate",
    "validate_route_membership",
    "validate_phase_completeness",
    "_missing_pr_gate_keys",
    "validate_completion_pr_gate",
    "_string_list",
]

ROUTING_MATRIX_PATH = (
    Path(__file__).resolve().parents[2] / "config" / "orchestration-routing.json"
)
PR_GATE_KEYS = ("pr_number", "pr_url", "head_branch", "head_sha")
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
