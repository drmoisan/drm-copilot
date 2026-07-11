"""Tests for epic-planner checkpoint and kickoff validation."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, Any

import pytest

import scripts.dev_tools.validate_orchestration_artifacts as dispatcher
from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment
from scripts.dev_tools.resolve_codex_topology import resolve_codex_topology
from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_kickoff_text,
    validate_epic_planner_state_text,
)

if TYPE_CHECKING:
    from pathlib import Path

    from pytest import MonkeyPatch


def _feature(issue_num: int, *, depends_on: list[int] | None = None) -> dict[str, Any]:
    """Build one fully prepared planner feature record."""

    model_receipt: dict[str, object] = dict(
        resolve_codex_deployment("orchestrator", "C3", "epic_preparation_child", "C3")
    )
    delegation_id = f"prepare-feature-{issue_num}"
    deployment_agent = str(model_receipt["deployment_agent"])
    launch_root = "artifacts/orchestration/epic-child-launches/preparation"
    model_receipt["phase"] = f"prepare-feature-{issue_num}"
    model_receipt["delegation_id"] = delegation_id
    topology_receipt: dict[str, object] = dict(
        resolve_codex_topology(["python"], 1, 1, "epic_preparation_child")
    )
    topology_receipt["phase"] = f"prepare-feature-{issue_num}"
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
        "branch_name": f"feature/feature-{issue_num}",
        "worktree_path": f"/repo/worktrees/feature-{issue_num}",
        "delegation_receipt": {
            "delegation_id": delegation_id,
            "feature_folder": f"docs/features/active/feature-{issue_num}",
            "issue_num": issue_num,
            "agent_name": deployment_agent,
        },
        "model_routing_receipt": model_receipt,
        "launch_receipt_path": f"{launch_root}/feature-{issue_num}.receipt.json",
        "launch_status_path": f"{launch_root}/wave.status.json",
        "topology_receipt": topology_receipt,
    }


def _ready_state() -> dict[str, Any]:
    """Build a complete planner checkpoint ready for execution."""

    topology_receipt: dict[str, object] = dict(
        resolve_codex_topology([], 0, 0, "standalone", root_persona="epic-planner")
    )
    topology_receipt["phase"] = "epic_planning"
    return {
        "objective": "prepare two related features",
        "epic_feature_folder": "sample-epic",
        "epic_manifest_path": "docs/features/epics/sample-epic/epic.md",
        "integration_branch": "epic/sample-epic-integration",
        "max_parallel_features": 4,
        "epic_worthiness": {"verdict": "epic", "rationale": "two features"},
        "features": [_feature(101), _feature(102, depends_on=[101])],
        "kickoff_prompt_path": "artifacts/orchestration/epic-kickoff-sample-epic.md",
        "completed_steps": ["decomposition", "preparation", "fan-in"],
        "next_step": "EPIC_EXECUTION_READY",
        "last_updated": "2026-07-10T10:00:00Z",
        "topology_receipt": topology_receipt,
    }


def test_ready_checkpoint_passes_execution_readiness() -> None:
    """Require repository context in addition to structural readiness."""

    errors = validate_epic_planner_state_text(
        json.dumps(_ready_state()), require_ready_for_execution=True
    )

    assert errors == ["Execution-ready planner validation requires repository context."]


@pytest.mark.parametrize("value", [0, 9, True, 1.5, "4"])
def test_max_parallel_features_must_be_an_integer_from_one_to_eight(
    value: object,
) -> None:
    """Reject invalid planner concurrency limits."""

    state = _ready_state()
    state["max_parallel_features"] = value

    errors = validate_epic_planner_state_text(json.dumps(state))

    assert any("max_parallel_features" in error for error in errors)


def test_non_epic_recommendation_passes_plain_validation() -> None:
    """Allow a planner to stop with a single-feature recommendation."""

    state = _ready_state()
    state["epic_worthiness"] = {
        "verdict": "non_epic",
        "rationale": "one independently mergeable feature",
    }
    state["features"] = [_feature(101)]
    state["next_step"] = "NON_EPIC_RECOMMENDED"

    assert validate_epic_planner_state_text(json.dumps(state)) == []


def test_planner_state_rejects_invalid_json_and_root_shapes() -> None:
    """Report malformed JSON and non-object checkpoints without raising."""

    assert "not valid JSON" in validate_epic_planner_state_text("{")[0]
    assert validate_epic_planner_state_text("[]") == [
        "Epic planner checkpoint root must be a JSON object."
    ]


def test_planner_state_rejects_invalid_worthiness_and_feature_shapes() -> None:
    """Report non-object worthiness and non-list feature collections."""

    state = _ready_state()
    state["epic_worthiness"] = None
    state["features"] = "invalid"

    errors = validate_epic_planner_state_text(json.dumps(state))

    assert any("epic_worthiness must be an object" in error for error in errors)
    assert any("features must be a list" in error for error in errors)


def test_non_epic_recommendation_cannot_pass_execution_readiness() -> None:
    """Prevent a failed worthiness gate from becoming executable epic state."""

    state = _ready_state()
    state["epic_worthiness"]["verdict"] = "non_epic"
    state["next_step"] = "NON_EPIC_RECOMMENDED"

    errors = validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True
    )

    assert any("verdict 'epic'" in error for error in errors)


def test_readiness_requires_preflight_clearance_and_resolved_issue() -> None:
    """Reject unresolved placeholders or non-clear child preflight state."""

    state = _ready_state()
    state["features"][0]["issue_num"] = None
    state["features"][1]["preflight_status"] = "PREFLIGHT: REVISIONS REQUIRED"

    errors = validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True
    )

    assert any("issue_num must be a positive integer" in error for error in errors)
    assert any("preflight_status" in error for error in errors)


def test_readiness_requires_resolved_child_model_receipt() -> None:
    """Reject missing or mismatched model routing on a prepared child."""

    state = _ready_state()
    state["features"][0].pop("model_routing_receipt")
    state["features"][1]["model_routing_receipt"]["model"] = "gpt-5.6-terra"

    errors = validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True
    )

    assert any("model_routing_receipt must be an object" in error for error in errors)
    assert any(".model must be 'gpt-5.6-sol'" in error for error in errors)


def test_readiness_cross_binds_feature_complexity_and_model_context() -> None:
    """Reject a valid model receipt for the wrong band or execution context."""

    state = _ready_state()
    state["features"][0]["complexity_band"] = "C4"
    standalone_receipt: dict[str, object] = dict(
        resolve_codex_deployment("orchestrator", "C3", "standalone", "C3")
    )
    standalone_receipt["phase"] = "prepare-feature-102"
    state["features"][1]["model_routing_receipt"] = standalone_receipt

    errors = validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True
    )

    assert any("complexity_band must match" in error for error in errors)
    assert any(
        "execution_context must be 'epic_preparation_child'" in error
        for error in errors
    )


def test_readiness_requires_epic_preparation_topology_receipts() -> None:
    """Require the forced planner and child-orchestrator topology decisions."""

    state = _ready_state()
    state.pop("topology_receipt")
    state["features"][0].pop("topology_receipt")
    state["features"][1]["topology_receipt"]["execution_context"] = "standalone"

    errors = validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True
    )

    assert any(
        "Epic planner topology_receipt must be an object" in error for error in errors
    )
    assert any(
        "features[0].topology_receipt must be an object" in error for error in errors
    )
    assert any(
        "execution_context must be 'epic_preparation_child'" in error
        for error in errors
    )


def test_readiness_requires_forced_epic_planner_persona() -> None:
    """Reject another root persona in the planner's top-level receipt."""

    state = _ready_state()
    replacement: dict[str, object] = dict(
        resolve_codex_topology([], 0, 0, "standalone", root_persona="epic-orchestrator")
    )
    replacement["phase"] = "epic_planning"
    state["topology_receipt"] = replacement

    errors = validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True
    )

    assert any("root_persona must be 'epic-planner'" in error for error in errors)


def test_readiness_requires_canonical_kickoff_path() -> None:
    """Require the ignored slug-based kickoff path recorded by the planner."""

    state = _ready_state()
    state["kickoff_prompt_path"] = "artifacts/orchestration/other.md"

    errors = validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=True
    )

    assert any("kickoff_prompt_path" in error for error in errors)


def test_dependency_cycle_is_rejected() -> None:
    """Prevent execution readiness when child dependencies are cyclic."""

    state = _ready_state()
    state["features"][0]["depends_on"] = [102]

    errors = validate_epic_planner_state_text(json.dumps(state))

    assert any("cycle" in error.lower() for error in errors)


def test_dependency_references_and_waves_are_recomputed() -> None:
    """Reject unresolved dependencies and stale wave assignments."""

    state = _ready_state()
    state["features"][0]["depends_on"] = [999]
    state["features"][1]["wave"] = 0

    errors = validate_epic_planner_state_text(json.dumps(state))

    assert any("unresolved reference: 999" in error for error in errors)
    assert any(".wave must be 1" in error for error in errors)


def test_feature_identifiers_must_be_unique() -> None:
    """Reject duplicate issue and folder identifiers in the planner graph."""

    state = _ready_state()
    state["features"][1]["issue_num"] = 101
    state["features"][1]["feature_folder"] = state["features"][0]["feature_folder"]

    errors = validate_epic_planner_state_text(json.dumps(state))

    assert any("issue_num must be unique" in error for error in errors)
    assert any("feature_folder must be unique" in error for error in errors)


def test_kickoff_contract_requires_all_execution_handoff_sections() -> None:
    """Validate the stable kickoff headings and execution-resume language."""

    valid = "\n".join(
        [
            "# Epic Kickoff: sample-epic",
            "## Invocation Prompt",
            "Run `/epic-run sample-epic` to execute this epic.",
            "Use the epic-orchestrator subagent to execute the prepared epic at",
            "docs/features/epics/sample-epic/epic.md. "
            "Reuse epic/sample-epic-integration.",
            "Every child resumes at atomic execution from its committed plan-path;",
            "do not repeat planning or preflight.",
            "## Feature Summary",
            "| issue_num | feature_folder | wave | complexity | plan-path |",
            "| --- | --- | --- | --- | --- |",
            "| 101 | docs/features/active/feature-101 | 0 | C3 | "
            "docs/features/active/feature-101/plan.md |",
        ]
    )

    assert validate_epic_kickoff_text(valid) == []
    assert validate_epic_kickoff_text("# Epic Kickoff: incomplete")


def test_cli_dispatches_planner_readiness_flag(monkeypatch: MonkeyPatch) -> None:
    """Expose planner readiness through the shared artifact validator CLI."""

    captured: dict[str, object] = {}

    def _read_text_stub(_path: Path) -> str:
        return "{}"

    def _validator_stub(
        _text: str,
        *,
        require_ready_for_execution: bool = False,
        readiness_context: object | None = None,
    ) -> list[str]:
        captured["ready"] = require_ready_for_execution
        captured["context"] = readiness_context
        return []

    monkeypatch.setattr(dispatcher, "_read_text", _read_text_stub)
    monkeypatch.setattr(dispatcher, "validate_epic_planner_state_text", _validator_stub)

    result = dispatcher.main(
        [
            "epic-planner-state",
            "ignored.json",
            "--require-ready-for-execution",
        ]
    )

    assert result == 0
    assert captured["ready"] is True
    assert captured["context"] is not None
