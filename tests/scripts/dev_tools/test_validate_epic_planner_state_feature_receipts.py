"""Tests for the per-feature receipt key gate in the epic-planner ready gate."""

from __future__ import annotations

import json
from typing import Any

import pytest

from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology
from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)
from tests.scripts.dev_tools.typescript_twin_test_support import (
    literals_missing_from_twin,
)

REPOSITORY_CONTEXT_ERROR = (
    "Execution-ready planner validation requires repository context."
)
MODEL_RECEIPT_OBJECT_ERROR = (
    "Epic planner checkpoint features[0].model_routing_receipt must be an object."
)
TOPOLOGY_RECEIPT_OBJECT_ERROR = (
    "Epic planner checkpoint features[0].topology_receipt must be an object."
)
LOGICAL_AGENT_ERROR = (
    "Epic planner checkpoint features[0].model_routing_receipt.logical_agent "
    "must be 'orchestrator'."
)
SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR = (
    "Epic planner checkpoint features[1].topology_receipt must be an object."
)
FEATURE0_TOPOLOGY_TOKEN = (
    "features[0].topology_receipt"  # noqa: S105 - test fixture data
)
FEATURE0_MODEL_TOKEN = (
    "features[0].model_routing_receipt"  # noqa: S105 - test fixture data
)
ASSERTED_MESSAGES = (
    REPOSITORY_CONTEXT_ERROR,
    MODEL_RECEIPT_OBJECT_ERROR,
    TOPOLOGY_RECEIPT_OBJECT_ERROR,
    LOGICAL_AGENT_ERROR,
    SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR,
    FEATURE0_TOPOLOGY_TOKEN,
    FEATURE0_MODEL_TOKEN,
)


def _claude_feature(
    issue_num: int, *, depends_on: list[int] | None = None
) -> dict[str, Any]:
    """Build one prepared feature carrying only the required feature keys."""

    return {
        "issue_num": issue_num,
        "feature_folder": f"docs/features/active/feature-{issue_num}",
        "depends_on": depends_on or [],
        "wave": 0 if not depends_on else 1,
        "complexity_band": "C3",
        "preparation_status": "prepared",
        "research_path": f"artifacts/research/feature-{issue_num}.md",
        "plan_path": f"docs/features/active/feature-{issue_num}/plan.md",
        "preflight_status": "PREFLIGHT: ALL CLEAR",
    }


def _claude_state() -> dict[str, Any]:
    """Build a Claude-shaped ready checkpoint with no Codex-only evidence."""

    return {
        "objective": "prepare two related features",
        "epic_feature_folder": "sample-epic",
        "epic_manifest_path": "docs/features/epics/sample-epic/epic.md",
        "integration_branch": "epic/sample-epic-integration",
        "max_parallel_features": 4,
        "epic_worthiness": {"verdict": "epic", "rationale": "two features"},
        "features": [_claude_feature(101), _claude_feature(102, depends_on=[101])],
        "kickoff_prompt_path": "artifacts/orchestration/epic-kickoff-sample-epic.md",
        "completed_steps": ["decomposition", "preparation", "fan-in"],
        "next_step": "EPIC_EXECUTION_READY",
        "last_updated": "2026-07-10T10:00:00Z",
    }


def _with_receipts(feature: dict[str, Any]) -> dict[str, Any]:
    """Attach resolved model routing and topology receipts to one feature."""

    issue_num = feature["issue_num"]
    model_receipt: dict[str, object] = dict(
        resolve_codex_deployment("orchestrator", "C3", "epic_preparation_child", "C3")
    )
    model_receipt["phase"] = f"prepare-feature-{issue_num}"
    model_receipt["delegation_id"] = f"prepare-feature-{issue_num}"
    topology_receipt: dict[str, object] = dict(
        resolve_codex_topology(["python"], 1, 1, "epic_preparation_child")
    )
    topology_receipt["phase"] = f"prepare-feature-{issue_num}"
    feature["model_routing_receipt"] = model_receipt
    feature["topology_receipt"] = topology_receipt
    return feature


def _state_with_receipts() -> dict[str, Any]:
    """Build the Claude-shaped checkpoint with both receipts on every feature."""

    state = _claude_state()
    state["features"] = [_with_receipts(feature) for feature in state["features"]]
    return state


def _ready_errors(
    state: dict[str, Any],
    *,
    require_codex_model_routing: bool = False,
    require_codex_topology: bool = False,
) -> list[str]:
    """Validate a checkpoint under the ready gate with no readiness context."""

    return validate_epic_planner_state_text(
        json.dumps(state),
        require_ready_for_execution=True,
        require_codex_model_routing=require_codex_model_routing,
        require_codex_topology=require_codex_topology,
    )


def test_ready_gate_skips_feature_receipts_when_keys_absent() -> None:
    """Skip absent per-feature receipts for a Claude checkpoint without a Codex flag."""

    errors = _ready_errors(_claude_state())

    assert errors == [REPOSITORY_CONTEXT_ERROR]


@pytest.mark.parametrize(
    "flag", ["require_codex_model_routing", "require_codex_topology"]
)
def test_codex_flag_keeps_feature_receipts_unconditional(flag: str) -> None:
    """Require both per-feature receipts when either Codex flag is asserted."""

    state = _state_with_receipts()
    state["features"][0].pop("model_routing_receipt")
    state["features"][0].pop("topology_receipt")

    errors = _ready_errors(
        state,
        require_codex_model_routing=flag == "require_codex_model_routing",
        require_codex_topology=flag == "require_codex_topology",
    )

    assert MODEL_RECEIPT_OBJECT_ERROR in errors
    assert TOPOLOGY_RECEIPT_OBJECT_ERROR in errors


@pytest.mark.parametrize(
    ("key", "expected"),
    [
        ("model_routing_receipt", MODEL_RECEIPT_OBJECT_ERROR),
        ("topology_receipt", TOPOLOGY_RECEIPT_OBJECT_ERROR),
    ],
    ids=["model_routing_receipt", "topology_receipt"],
)
def test_ready_gate_validates_present_null_feature_receipt(
    key: str, expected: str
) -> None:
    """Arm the check for a present null receipt key without a Codex flag."""

    state = _state_with_receipts()
    state["features"][0][key] = None

    errors = _ready_errors(state)

    assert expected in errors


def test_ready_gate_gates_each_feature_receipt_independently() -> None:
    """Validate a present model receipt while skipping an absent topology receipt."""

    state = _state_with_receipts()
    state["features"][0].pop("topology_receipt")
    state["features"][0]["model_routing_receipt"]["logical_agent"] = "planner"

    errors = _ready_errors(state)

    assert LOGICAL_AGENT_ERROR in errors
    assert [error for error in errors if FEATURE0_TOPOLOGY_TOKEN in error] == []


def test_ready_gate_preserves_feature_index_when_receipts_skipped() -> None:
    """Keep the original feature index after skipping a receipt-less feature."""

    state = _state_with_receipts()
    state["features"][0].pop("model_routing_receipt")
    state["features"][0].pop("topology_receipt")
    state["features"][1]["topology_receipt"] = None

    errors = _ready_errors(state)

    assert SECOND_TOPOLOGY_RECEIPT_OBJECT_ERROR in errors
    assert [
        error
        for error in errors
        if FEATURE0_TOPOLOGY_TOKEN in error or FEATURE0_MODEL_TOKEN in error
    ] == []


def test_asserted_messages_match_typescript_twin() -> None:
    """Keep every asserted message identical to its TypeScript twin literal."""

    missing = literals_missing_from_twin(
        ASSERTED_MESSAGES, "lib/validate/epic-planner-state-feature-receipts.test.ts"
    )

    assert missing == []
