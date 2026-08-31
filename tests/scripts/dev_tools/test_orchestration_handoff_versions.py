"""Version, capability, transition, and replay tests for portable handoff."""

from __future__ import annotations

import json
from dataclasses import replace
from pathlib import Path
from typing import cast

from scripts.dev_tools.orchestration_handoff_contract import (
    CapabilityRequirements,
    HandoffEnvelope,
    HistoryEntry,
    LifecycleState,
    ObjectiveIdentity,
    PlanIdentity,
    ProviderProvenance,
    SchedulerContext,
    WorkspaceBinding,
    read_legacy_v1,
    validate_semantic_contract,
)

ROOT = Path(__file__).parents[3]
FIXTURES = ROOT / "tests" / "fixtures" / "orchestration-handoff" / "contract"
REGISTRY = json.loads(
    (ROOT / "config" / "orchestration-handoff-registry.json").read_text(
        encoding="utf-8"
    )
)
SUPPORTED_CAPABILITIES = tuple(REGISTRY["capabilities"]["supported"])
CORE_VOCABULARY = "portable-orchestration-handoff-core-v1"
ZERO_SHA256 = "0" * 64


def _envelope() -> HandoffEnvelope:
    provenance = ProviderProvenance(
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
    lifecycle = LifecycleState(
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
    )
    return HandoffEnvelope(
        "2.0.0",
        "portable_orchestration_handoff",
        "handoff-614-versions",
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
        provenance,
        "codex",
        "artifacts/orchestration/orchestrator-state.json",
        PlanIdentity(
            "docs/features/active/portable-handoff-614/plan.md",
            ZERO_SHA256,
            "atomic-plan-v1",
        ),
        lifecycle,
        CapabilityRequirements(
            (CORE_VOCABULARY,),
            (
                "handoff-schema:2",
                "plan-contract:atomic-plan-v1",
                "scheduler-context:ordinary",
                "transition:prepared_to_atomic_execution",
            ),
        ),
        SchedulerContext("ordinary"),
        (history,),
    )


def _validate(
    envelope: HandoffEnvelope,
    *,
    transition: str = "prepared_to_atomic_execution",
    phase: str = "atomic_execution",
) -> str | None:
    return validate_semantic_contract(
        envelope,
        requested_transition=transition,
        transition_state="preparation_complete",
        requested_phase=phase,
        supported_capabilities=SUPPORTED_CAPABILITIES,
    )


def test_legacy_v1_accepts_only_explicit_migration_facts() -> None:
    envelope = _envelope()
    raw = b'{"status":"planning_complete","next_step":"atomic_execution"}\r\n'
    result = read_legacy_v1(
        raw,
        source_provider="claude",
        plan=envelope.plan,
        lifecycle=envelope.lifecycle,
        scheduler_context=envelope.scheduler_context,
    )
    assert result is raw


def test_supported_newer_minor_version_is_accepted() -> None:
    assert _validate(replace(_envelope(), schema_version="2.99.0")) is None


def test_unknown_major_version_has_deterministic_code() -> None:
    cases = cast(
        "list[dict[str, object]]",
        json.loads((FIXTURES / "invalid-contract-cases.json").read_text()),
    )
    case = next(item for item in cases if item["id"] == "unknown-major")
    assert (FIXTURES / cast("str", case["base"])).is_file()
    assert (
        _validate(replace(_envelope(), schema_version=cast("str", case["value"])))
        == case["expected"]
    )


def test_unknown_vocabulary_has_deterministic_code() -> None:
    envelope = _envelope()
    capabilities = replace(envelope.capabilities, vocabularies=("unknown-v1",))
    assert (
        _validate(replace(envelope, capabilities=capabilities))
        == "HANDOFF_UNSUPPORTED_VERSION"
    )


def test_unknown_capability_has_deterministic_code() -> None:
    envelope = _envelope()
    capabilities = replace(
        envelope.capabilities,
        required=(*envelope.capabilities.required, "unknown-capability"),
    )
    assert (
        _validate(replace(envelope, capabilities=capabilities))
        == "HANDOFF_CAPABILITY_UNAVAILABLE"
    )


def test_invalid_transition_has_deterministic_code() -> None:
    assert (
        _validate(_envelope(), transition="unknown") == "HANDOFF_TRANSITION_NOT_ALLOWED"
    )


def test_completed_phase_replay_has_deterministic_code() -> None:
    assert _validate(_envelope(), phase="preflight") == "HANDOFF_TRANSITION_NOT_ALLOWED"
