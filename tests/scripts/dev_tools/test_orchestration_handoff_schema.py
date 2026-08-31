"""Contract tests for valid portable orchestration handoff envelopes."""

from __future__ import annotations

import json
from dataclasses import asdict, replace
from pathlib import Path
from typing import Any

import pytest

from scripts.dev_tools.orchestration_handoff_contract import (
    HistoryEntry,
    Provider,
    SchedulerKind,
    history_entry_digest,
)
from scripts.dev_tools.validate_orchestrator_state import (
    validate_orchestrator_state_text,
)

ROOT = Path(__file__).parents[3]
FIXTURES = ROOT / "tests" / "fixtures" / "orchestration-handoff" / "contract"
SCHEMA = json.loads(
    (ROOT / "config" / "orchestration-handoff.schema.json").read_text(encoding="utf-8")
)
JSON_SCHEMA = pytest.importorskip("jsonschema")
VALIDATOR = JSON_SCHEMA.Draft202012Validator(SCHEMA)
ZERO_SHA256 = "0" * 64


def _history_entry(source: Provider, destination: Provider) -> dict[str, object]:
    entry = HistoryEntry(
        1,
        source,
        destination,
        ZERO_SHA256,
        ZERO_SHA256,
        "2026-08-31T08:00:00Z",
        None,
        ZERO_SHA256,
        "requested",
        f"{source}-to-{destination}-v1",
        "1.0.0",
    )
    entry = replace(entry, entry_sha256=history_entry_digest(entry))
    payload = asdict(entry)
    return {
        key: value
        for key, value in payload.items()
        if value is not None or key == "previous_entry_sha256"
    }


def _scheduler_context(kind: SchedulerKind) -> dict[str, object]:
    if kind == "ordinary":
        return {"kind": kind}
    return {
        "kind": kind,
        "run_id": f"{kind}-run-614",
        "item_id": "item-614",
        "kickoff_or_manifest_path": f"artifacts/orchestration/{kind}-kickoff.json",
        "kickoff_or_manifest_sha256": ZERO_SHA256,
        "parent_checkpoint_path": f"artifacts/orchestration/{kind}-state.json",
        "parent_checkpoint_sha256": ZERO_SHA256,
        "cohort_or_wave": "cohort-1" if kind == "parallel" else 1,
        "scheduler_owner": f"{kind}_orchestrator",
        "child_execution_owner": "ordinary_orchestrator",
        "return_contract": "portable_child_result-v1",
    }


def _valid_envelope(
    source: Provider, destination: Provider, kind: SchedulerKind
) -> dict[str, Any]:
    scheduler_capability = "ordinary" if kind == "ordinary" else f"{kind}-child"
    route = (
        "prepared_to_ordinary_execution"
        if kind == "ordinary"
        else "prepared_child_to_ordinary_execution"
    )
    return {
        "$schema": (
            "https://drm-copilot.dev/schemas/" "orchestration-handoff/2.0.0/schema.json"
        ),
        "schema_version": "2.0.0",
        "kind": "portable_orchestration_handoff",
        "handoff_id": f"handoff-614-{source}-to-{destination}-{kind}",
        "identity": {
            "objective_id": "github:drmoisan/drm-copilot#614",
            "issue_number": 614,
            "feature_folder": "docs/features/active/portable-handoff-614",
            "work_mode": "full-feature",
        },
        "binding": {
            "repository_id": "github.com/drmoisan/drm-copilot",
            "workspace_root": "C:/Users/operator/drm-copilot",
            "branch": "feature/portable-handoff-614",
            "source_head_sha": "0" * 40,
            "allowed_head_relationship": "equal_or_descendant",
        },
        "source": {
            "provider": source,
            "checkpoint": {
                "path": "artifacts/orchestration/orchestrator-state.json",
                "sha256": ZERO_SHA256,
                "archive_path": (
                    "artifacts/orchestration/handoffs/sources/sha256/"
                    f"{ZERO_SHA256}.json"
                ),
            },
            "expression": {
                "schema_id": f"{source}.orchestrator-state",
                "schema_version": "legacy-v1",
                "historical_receipts": {"mode": "opaque", "references": []},
            },
        },
        "destination": {
            "provider": destination,
            "checkpoint_path": "artifacts/orchestration/orchestrator-state.json",
        },
        "plan": {
            "path": "docs/features/active/portable-handoff-614/plan.md",
            "sha256": ZERO_SHA256,
            "contract_version": "atomic-plan-v1",
        },
        "lifecycle": {
            "logical_complexity": "C3",
            "route_intent": route,
            "completed_phases": [
                "intake",
                "promotion",
                "research",
                "feature_documents",
                "atomic_planning",
                "preflight",
            ],
            "next_transition": "atomic_execution",
            "replay_policy": "forbid_completed_phases",
        },
        "capabilities": {
            "vocabularies": ["portable-orchestration-handoff-core-v1"],
            "required": [
                "handoff-schema:2",
                "plan-contract:atomic-plan-v1",
                f"scheduler-context:{scheduler_capability}",
                "transition:prepared_to_atomic_execution",
            ],
        },
        "scheduler_context": _scheduler_context(kind),
        "handoff_history": [_history_entry(source, destination)],
    }


def _assert_valid(source: Provider, destination: Provider, kind: SchedulerKind) -> None:
    envelope = _valid_envelope(source, destination, kind)
    VALIDATOR.validate(envelope)
    assert validate_orchestrator_state_text(json.dumps(envelope)) == []


@pytest.mark.parametrize(
    "name",
    [
        "valid-ordinary-claude-to-codex.json",
        "valid-parallel-codex-to-claude.json",
    ],
)
def test_shared_positive_contract_fixture_is_valid(name: str) -> None:
    envelope = json.loads((FIXTURES / name).read_text(encoding="utf-8"))
    VALIDATOR.validate(envelope)
    assert validate_orchestrator_state_text(json.dumps(envelope)) == []


def test_valid_claude_to_codex_ordinary_envelope() -> None:
    _assert_valid("claude", "codex", "ordinary")


def test_valid_codex_to_claude_ordinary_envelope() -> None:
    _assert_valid("codex", "claude", "ordinary")


def test_valid_claude_to_codex_parallel_child_envelope() -> None:
    _assert_valid("claude", "codex", "parallel")


def test_valid_codex_to_claude_parallel_child_envelope() -> None:
    _assert_valid("codex", "claude", "parallel")


def test_valid_claude_to_codex_epic_child_envelope() -> None:
    _assert_valid("claude", "codex", "epic")


def test_valid_codex_to_claude_epic_child_envelope() -> None:
    _assert_valid("codex", "claude", "epic")
