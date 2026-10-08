"""Re-export identity tests for the split orchestrator-state routing module.

The routing-contract module was split so that the route-gate helpers and the
promotion-entry tool helpers live in their own modules. These tests pin that
every moved name is still importable from the routing-contract module as the
identical object, that every moved name is listed in its ``__all__``, and that
the receipt harvesters remain defined in the routing-contract module itself.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import _orchestrator_state_promotion_tools as promotion_tools
from scripts.dev_tools import _orchestrator_state_route_gates as route_gates
from scripts.dev_tools import _orchestrator_state_routing as routing

if TYPE_CHECKING:
    from types import ModuleType

REEXPORTED_NAMES: tuple[tuple[str, ModuleType], ...] = (
    ("ROUTING_MATRIX_PATH", route_gates),
    ("PR_GATE_KEYS", route_gates),
    ("MANDATORY_ROUTE_PHASES", route_gates),
    ("load_routing_matrix", route_gates),
    ("_selected_route_id", route_gates),
    ("route_requires_pr_gate", route_gates),
    ("route_requires_ci_gate", route_gates),
    ("validate_route_membership", route_gates),
    ("validate_phase_completeness", route_gates),
    ("_missing_pr_gate_keys", route_gates),
    ("validate_completion_pr_gate", route_gates),
    ("_string_list", route_gates),
    ("FEATURE_PROMOTION_ENTRY_TOOL", promotion_tools),
    ("BUG_PROMOTION_ENTRY_TOOL", promotion_tools),
    ("_resolve_promotion_entry_tools", promotion_tools),
)

HARVESTER_NAMES: tuple[str, ...] = ("_receipt_agents", "_receipt_skills", "_mcp_tools")


@pytest.mark.parametrize(
    ("name", "source_module"),
    REEXPORTED_NAMES,
    ids=[name for name, _ in REEXPORTED_NAMES],
)
def test_reexported_name_is_the_identical_object(
    name: str, source_module: ModuleType
) -> None:
    """A moved name resolves from the routing module to the same object.

    Expected outcome: the routing module attribute is the identical object
    defined in the module the name was moved into.
    """

    # Arrange
    expected = getattr(source_module, name)

    # Act
    actual = getattr(routing, name)

    # Assert
    assert (
        actual is expected
    ), f"routing.{name} is not the object defined in {source_module.__name__}"


@pytest.mark.parametrize("name", [name for name, _ in REEXPORTED_NAMES])
def test_reexported_name_is_listed_in_all(name: str) -> None:
    """A moved name is part of the routing module's declared export surface.

    Expected outcome: the name appears in the routing module's ``__all__``.
    """

    # Arrange
    exported = set(routing.__all__)

    # Act
    is_listed = name in exported

    # Assert
    assert is_listed, f"{name} is missing from routing.__all__"


@pytest.mark.parametrize("name", HARVESTER_NAMES)
def test_receipt_harvester_is_defined_in_routing_module(name: str) -> None:
    """A receipt harvester stays defined in the routing-contract module.

    Expected outcome: the function's ``__module__`` names the routing module,
    so documentation stating where the harvesters live remains accurate.
    """

    # Arrange
    harvester = getattr(routing, name)

    # Act
    defining_module = harvester.__module__

    # Assert
    assert (
        defining_module == "scripts.dev_tools._orchestrator_state_routing"
    ), f"{name} is defined in {defining_module}, not the routing module"
