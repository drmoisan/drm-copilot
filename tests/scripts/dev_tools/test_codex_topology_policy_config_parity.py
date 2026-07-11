"""Static parity tests for the Codex topology policy and Python resolver."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

from scripts.dev_tools.resolve_codex_topology import (
    EPIC_CHILD_CONTEXTS,
    ESCALATION_PRECEDENCE,
    FORCED_ROOT_PERSONAS,
    LANGUAGE_BUDGETS,
    ORCHESTRATOR_LOGICAL_AGENT,
    VALID_EXECUTION_CONTEXTS,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
CONFIG_PATH = REPO_ROOT / "config" / "orchestration-routing.json"
BUNDLED_CONFIG_PATH = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "config"
    / "orchestration-routing.json"
)


def _load_document() -> dict[str, Any]:
    """Load the canonical routing document."""

    return cast("dict[str, Any]", json.loads(CONFIG_PATH.read_text(encoding="utf-8")))


def test_language_budgets_match_canonical_config() -> None:
    """Keep direct-mode bounds and engineer families centrally synchronized."""

    policy = _load_document()["codex_topology_policy"]

    assert policy["language_budgets"] == LANGUAGE_BUDGETS


def test_contexts_and_forced_routes_match_canonical_config() -> None:
    """Keep epic overrides and escalation precedence synchronized."""

    policy = _load_document()["codex_topology_policy"]

    assert set(policy["execution_contexts"]) == VALID_EXECUTION_CONTEXTS
    assert set(policy["epic_child_contexts"]) == EPIC_CHILD_CONTEXTS
    assert set(policy["forced_root_personas"]) == FORCED_ROOT_PERSONAS
    assert policy["orchestrator_logical_agent"] == ORCHESTRATOR_LOGICAL_AGENT
    assert tuple(policy["escalation_precedence"]) == ESCALATION_PRECEDENCE
    assert policy["receipt_key"] == "codex_topology_receipts"


def test_small_route_requires_resolved_typed_engineer_receipt() -> None:
    """Keep the small-route actor mechanical instead of a fixed agent list."""

    requirement = _load_document()["routes"]["small"]["codex_topology_requirement"]

    assert requirement == {
        "receipt_key": "codex_topology_receipts",
        "required_execution_context": "standalone",
        "required_route": "small",
        "delegation_agent_source": "resolved_language_typed_engineer",
    }


def test_tracked_and_bundled_routing_configs_are_byte_identical() -> None:
    """Prevent runtime bundle drift from the tracked canonical policy."""

    assert CONFIG_PATH.read_bytes() == BUNDLED_CONFIG_PATH.read_bytes()
