"""Tests for the per-feature receipt key gate in the epic-planner ready gate."""

from __future__ import annotations

import json
from typing import Any

from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)

REPOSITORY_CONTEXT_ERROR = (
    "Execution-ready planner validation requires repository context."
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
