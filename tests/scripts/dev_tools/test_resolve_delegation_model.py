"""Tests for the ``resolve_delegation_model`` reference implementation.

These tests exercise the delegation-model selection formula: the base
``complexity_to_model`` table, the ``available`` policy leaving ``fable`` cells
intact, the ``disabled`` clamp of every ``fable`` cell to ``opus`` with
``clamped_from == "fable"``, and the ``preferred`` overlay redirecting the C3
cell to ``fable`` for the four overlay agents while leaving
``atomic-executor`` and ``pr-author`` C3 cells at ``opus``.

The base table and overlay agent set are read from the live routing matrix
(`load_routing_matrix()["model_policy"]`), so the tests track the
``model_policy`` block in ``config/orchestration-routing.json`` rather than
hardcoding the table or the overlay agent set.
"""

from __future__ import annotations

from typing import Any, cast

import pytest

from scripts.dev_tools._orchestrator_state_routing import load_routing_matrix
from scripts.dev_tools.resolve_delegation_model import resolve_delegation_model


def _model_policy() -> dict[str, Any]:
    """Return the ``model_policy`` block from the live routing matrix.

    Returns:
        dict[str, Any]: The parsed ``model_policy`` block.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk.
    """

    matrix = load_routing_matrix()
    return cast("dict[str, Any]", matrix["model_policy"])


# Live reads of the base table and overlay agent set from the routing matrix.
_LOCAL_BASE_TABLE = cast("dict[str, str]", _model_policy()["complexity_to_model"])
_LOCAL_OVERLAY_AGENTS = tuple(
    str(agent) for agent in _model_policy()["preferred_overlay"]["agents"]
)
_NON_OVERLAY_AGENTS = ("atomic-executor", "pr-author")


@pytest.mark.parametrize(
    ("band", "expected_model"),
    [("C1", "haiku"), ("C2", "sonnet"), ("C3", "opus"), ("C4", "fable")],
)
def test_base_table_per_band_under_available(band: str, expected_model: str) -> None:
    """Under ``available`` each band resolves to its base table model."""

    # Arrange / Act: resolve a non-overlay-affecting agent under available.
    result = resolve_delegation_model("atomic-executor", band, "available")

    # Assert: model and table_model both equal the base table lookup; no clamp.
    assert result["model"] == expected_model
    assert result["table_model"] == expected_model
    assert result["clamped_from"] is None
    assert result["clamp_reason"] is None


def test_available_leaves_fable_cell_intact() -> None:
    """The ``available`` policy resolves a ``fable`` cell to ``fable`` (no clamp)."""

    # Arrange / Act: C4 resolves to fable under available for any agent.
    result = resolve_delegation_model("atomic-planner", "C4", "available")

    # Assert: fable is preserved and no clamp provenance is recorded.
    assert result["model"] == "fable"
    assert result["clamped_from"] is None


@pytest.mark.parametrize("agent", [*_LOCAL_OVERLAY_AGENTS, *_NON_OVERLAY_AGENTS])
def test_disabled_clamps_fable_cell_to_opus(agent: str) -> None:
    """Under ``disabled`` every ``fable`` cell clamps to ``opus`` with provenance."""

    # Arrange / Act: C4 is a fable cell for every agent; disabled clamps it.
    result = resolve_delegation_model(agent, "C4", "disabled")

    # Assert: table_model records the pre-clamp fable; model is the opus clamp.
    assert result["table_model"] == "fable"
    assert result["model"] == "opus"
    assert result["clamped_from"] == "fable"
    assert result["clamp_reason"] == "fable_disabled"


def test_disabled_does_not_apply_preferred_overlay() -> None:
    """Under ``disabled`` an overlay agent's C3 cell stays ``opus`` (no overlay)."""

    # Arrange / Act: an overlay agent at C3 under disabled; overlay is inert.
    result = resolve_delegation_model("atomic-planner", "C3", "disabled")

    # Assert: base C3 opus, no fable, no clamp (table_model was never fable).
    assert result["table_model"] == "opus"
    assert result["model"] == "opus"
    assert result["clamped_from"] is None


@pytest.mark.parametrize("agent", _LOCAL_OVERLAY_AGENTS)
def test_preferred_resolves_overlay_agent_c3_to_fable(agent: str) -> None:
    """Under ``preferred`` each overlay agent's C3 cell resolves to ``fable``."""

    # Arrange / Act: overlay agent at C3 under preferred.
    result = resolve_delegation_model(agent, "C3", "preferred")

    # Assert: the overlay redirects C3 to fable, with no clamp under preferred.
    assert result["table_model"] == "fable"
    assert result["model"] == "fable"
    assert result["clamped_from"] is None


@pytest.mark.parametrize("agent", _NON_OVERLAY_AGENTS)
def test_preferred_leaves_non_overlay_agent_c3_at_opus(agent: str) -> None:
    """Under ``preferred`` ``atomic-executor``/``pr-author`` C3 stays ``opus``."""

    # Arrange / Act: non-overlay agent at C3 under preferred.
    result = resolve_delegation_model(agent, "C3", "preferred")

    # Assert: the overlay does not apply; C3 stays at the base opus.
    assert result["table_model"] == "opus"
    assert result["model"] == "opus"


def test_determinism_across_repeated_calls() -> None:
    """Identical inputs yield identical output across repeated calls."""

    # Arrange: a fixed input triple.
    calls = [
        resolve_delegation_model("atomic-planner", "C3", "preferred") for _ in range(5)
    ]

    # Assert: every call returns an identical mapping.
    # Compare successive results to the first to prove deterministic output.
    for result in calls:
        assert result == calls[0]


def test_base_table_matches_local_fixture_under_available() -> None:
    """Every base table entry is reproduced by ``resolve`` under ``available``."""

    # Walk each band in the base table and confirm the resolver reproduces it.
    for band, expected_model in _LOCAL_BASE_TABLE.items():
        result = resolve_delegation_model("atomic-executor", band, "available")
        assert result["model"] == expected_model
