"""Negative path and binding tests for portable handoff validation."""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

from scripts.dev_tools.orchestration_handoff_contract import (
    CapabilityRequirements,
    HandoffContractError,
    HandoffEnvelope,
    HistoryEntry,
    LifecycleState,
    ObjectiveIdentity,
    PlanIdentity,
    ProviderProvenance,
    SchedulerContext,
    WorkspaceBinding,
    normalize_repository_relative_path,
    resolve_pinned_plan_path,
    validate_bindings,
)

ROOT = Path(__file__).parents[3]
FIXTURES = ROOT / "tests" / "fixtures" / "orchestration-handoff" / "contract"
ZERO_SHA256 = "0" * 64


@pytest.fixture
def deny_write_boundaries(monkeypatch: pytest.MonkeyPatch) -> None:
    def fail_write(*_args: object, **_kwargs: object) -> None:
        raise AssertionError("validation crossed a write boundary")

    for method in ("write_text", "write_bytes", "replace"):
        monkeypatch.setattr(Path, method, fail_write)


def _envelope() -> HandoffEnvelope:
    source = ProviderProvenance(
        "claude",
        "artifacts/orchestration/orchestrator-state.json",
        ZERO_SHA256,
        f"artifacts/orchestration/handoffs/sources/sha256/{ZERO_SHA256}.json",
        "claude.orchestrator-state",
        "legacy-v1",
    )
    history = HistoryEntry(
        1,
        "claude",
        "codex",
        ZERO_SHA256,
        ZERO_SHA256,
        "2026-08-31T08:00:00Z",
        None,
        ZERO_SHA256,
        "requested",
        "claude-to-codex-v1",
        "1.0.0",
    )
    return HandoffEnvelope(
        "2.0.0",
        "portable_orchestration_handoff",
        "handoff-614-paths",
        ObjectiveIdentity(
            "github:drmoisan/drm-copilot#614",
            614,
            "docs/features/active/portable-handoff-614",
            "full-feature",
        ),
        WorkspaceBinding(
            "github.com/drmoisan/drm-copilot",
            "C:/Users/operator/drm-copilot",
            "feature/portable-handoff-614",
            "0" * 40,
            "equal_or_descendant",
        ),
        source,
        "codex",
        "artifacts/orchestration/orchestrator-state.json",
        PlanIdentity(
            "docs/features/active/portable-handoff-614/plan.md",
            ZERO_SHA256,
            "atomic-plan-v1",
        ),
        LifecycleState(
            "C3",
            "prepared_to_ordinary_execution",
            (
                "intake",
                "promotion",
                "research",
                "feature_documents",
                "atomic_planning",
                "preflight",
            ),
            "atomic_execution",
        ),
        CapabilityRequirements(
            ("portable-orchestration-handoff-core-v1",),
            (
                "handoff-schema:2",
                "plan-contract:atomic-plan-v1",
                "scheduler-context:ordinary",
            ),
        ),
        SchedulerContext("ordinary"),
        (history,),
    )


def _observed_bindings() -> dict[str, object]:
    envelope = _envelope()
    return {
        "repository_id": envelope.binding.repository_id,
        "workspace_root": envelope.binding.workspace_root,
        "branch": envelope.binding.branch,
        "issue_number": envelope.identity.issue_number,
        "feature_folder": envelope.identity.feature_folder,
        "plan_sha256": envelope.plan.sha256,
    }


@pytest.mark.parametrize(
    "value",
    [
        "/absolute/plan.md",
        "C:/absolute/plan.md",
        "docs/features/../plan.md",
        "docs\\features\\plan.md",
        "docs//features/plan.md",
    ],
)
def test_invalid_plan_path_blocks_before_write(
    value: str, deny_write_boundaries: None
) -> None:
    with pytest.raises(HandoffContractError):
        normalize_repository_relative_path(value, field="plan.path")


def test_plan_directory_rediscovery_blocks_before_write(
    deny_write_boundaries: None,
) -> None:
    with pytest.raises(HandoffContractError):
        resolve_pinned_plan_path(ROOT, "docs/features/active")


def test_shared_traversal_fixture_blocks_before_write(
    deny_write_boundaries: None,
) -> None:
    cases = cast(
        "list[dict[str, object]]",
        json.loads((FIXTURES / "invalid-contract-cases.json").read_text()),
    )
    case = next(item for item in cases if item["id"] == "plan-path-traversal")
    envelope = cast(
        "dict[str, Any]",
        json.loads((FIXTURES / cast("str", case["base"])).read_text()),
    )
    plan = cast("dict[str, object]", envelope["plan"])
    plan["path"] = case["value"]
    with pytest.raises(HandoffContractError):
        normalize_repository_relative_path(cast("str", plan["path"]), field="plan.path")


@pytest.mark.parametrize(
    ("field", "value", "failure"),
    [
        ("repository_id", "github.com/other/repository", "HANDOFF_REPOSITORY_MISMATCH"),
        ("workspace_root", "C:/Users/operator/other", "HANDOFF_WORKSPACE_MISMATCH"),
        ("branch", "feature/other", "HANDOFF_BRANCH_LINEAGE_MISMATCH"),
        ("issue_number", 999, "HANDOFF_ISSUE_FEATURE_MISMATCH"),
        (
            "feature_folder",
            "docs/features/active/other",
            "HANDOFF_ISSUE_FEATURE_MISMATCH",
        ),
    ],
)
def test_wrong_binding_blocks_before_write(
    field: str,
    value: object,
    failure: str,
    deny_write_boundaries: None,
) -> None:
    observed = _observed_bindings()
    observed[field] = value
    assert validate_bindings(_envelope(), observed) == failure


def test_stale_plan_hash_blocks_before_write(deny_write_boundaries: None) -> None:
    observed = _observed_bindings()
    observed["plan_sha256"] = "f" * 64
    assert validate_bindings(_envelope(), observed) == "HANDOFF_PLAN_HASH_MISMATCH"
