"""Verify provider adapters preserve portable orchestration facts."""

from __future__ import annotations

from dataclasses import asdict, replace
from typing import TYPE_CHECKING, Any, cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools.orchestration_handoff_adapters import (
    EPIC_SCHEDULER_AUTHORITIES,
    PARALLEL_SCHEDULER_AUTHORITIES,
    ClaudeToCodexAdapter,
    CodexToClaudeAdapter,
    PortableProjectionFacts,
    ProviderAdapterProtocol,
    ProviderExecutionEvidence,
    record_first_destination_delegation,
)
from scripts.dev_tools.orchestration_handoff_contract import (
    HandoffEnvelope,
    Provider,
    SchedulerContext,
    SchedulerKind,
    history_entry_digest,
    validate_return_to_scheduler,
    validate_semantic_contract,
)
from tests.scripts.dev_tools.validate_orchestrator_state_test_support import (
    build_portable_envelope,
)

if TYPE_CHECKING:
    from collections.abc import Callable

BUILD_ENVELOPE = cast(
    "Callable[[dict[str, Any]], HandoffEnvelope]",
    vars(state_validator)["_build_portable_envelope"],
)
ADAPTER_CASES: tuple[tuple[Provider, Provider, str, ProviderAdapterProtocol], ...] = (
    ("claude", "codex", "claude-to-codex-v1", ClaudeToCodexAdapter()),
    ("codex", "claude", "codex-to-claude-v1", CodexToClaudeAdapter()),
)
COMPLETED_PREPARATION_PHASES = (
    "intake",
    "promotion",
    "research",
    "feature_documents",
    "atomic_planning",
    "preflight",
)
SCHEDULED_CASES: tuple[tuple[SchedulerKind, str | int, tuple[str, ...]], ...] = (
    ("parallel", "cohort-1", PARALLEL_SCHEDULER_AUTHORITIES),
    ("epic", 1, EPIC_SCHEDULER_AUTHORITIES),
)


def _ordinary_envelope(
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
) -> HandoffEnvelope:
    base = BUILD_ENVELOPE(cast("dict[str, Any]", build_portable_envelope()))
    source = replace(
        base.source,
        provider=source_provider,
        expression_schema_id=f"{source_provider}.orchestrator-state",
    )
    history = replace(
        base.handoff_history[0],
        from_provider=source_provider,
        to_provider=destination_provider,
        adapter_id=adapter_id,
        entry_sha256="0" * 64,
    )
    history = replace(history, entry_sha256=history_entry_digest(history))
    lifecycle = replace(
        base.lifecycle,
        completed_phases=COMPLETED_PREPARATION_PHASES,
    )
    return replace(
        base,
        source=source,
        destination_provider=destination_provider,
        lifecycle=lifecycle,
        handoff_history=(history,),
    )


def _projection_facts(envelope: HandoffEnvelope) -> PortableProjectionFacts:
    return PortableProjectionFacts(
        plan=envelope.plan,
        lifecycle=envelope.lifecycle,
        scheduler_context=envelope.scheduler_context,
        envelope_sha256="b" * 64,
        history_entry_sha256=envelope.handoff_history[-1].entry_sha256,
    )


def _scheduled_envelope(
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
    scheduler_kind: SchedulerKind,
    cohort_or_wave: str | int,
) -> HandoffEnvelope:
    envelope = _ordinary_envelope(
        source_provider,
        destination_provider,
        adapter_id,
    )
    digest = "a" * 64
    scheduler = SchedulerContext(
        kind=scheduler_kind,
        run_id=f"{scheduler_kind}-run-614",
        item_id="item-614",
        kickoff_or_manifest_path=(
            f"artifacts/orchestration/{scheduler_kind}-kickoff.json"
        ),
        kickoff_or_manifest_sha256=digest,
        parent_checkpoint_path=(f"artifacts/orchestration/{scheduler_kind}-state.json"),
        parent_checkpoint_sha256=digest,
        cohort_or_wave=cohort_or_wave,
        scheduler_owner=f"{scheduler_kind}_orchestrator",
        child_execution_owner="ordinary_orchestrator",
        return_contract="portable_child_result-v1",
    )
    return replace(
        envelope,
        lifecycle=replace(
            envelope.lifecycle,
            route_intent="prepared_child_to_ordinary_execution",
        ),
        scheduler_context=scheduler,
    )


def _bounded_result(envelope: HandoffEnvelope) -> dict[str, object]:
    scheduler = envelope.scheduler_context
    return {
        "run_id": scheduler.run_id,
        "item_id": scheduler.item_id,
        "parent_checkpoint_path": scheduler.parent_checkpoint_path,
        "parent_checkpoint_sha256": scheduler.parent_checkpoint_sha256,
        "scheduler_owner": scheduler.scheduler_owner,
        "child_execution_owner": scheduler.child_execution_owner,
        "return_contract": scheduler.return_contract,
        "plan_sha256": envelope.plan.sha256,
        "child_checkpoint_sha256": "d" * 64,
        "result_sha256": "e" * 64,
    }


@pytest.mark.parametrize(
    ("source_provider", "destination_provider", "adapter_id", "adapter"),
    ADAPTER_CASES,
    ids=("claude-to-codex", "codex-to-claude"),
)
def test_ordinary_projection_preserves_portable_facts_without_provider_evidence(
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
    adapter: ProviderAdapterProtocol,
) -> None:
    """Both ordinary directions preserve plan, route, ownership, and timing."""

    envelope = _ordinary_envelope(
        source_provider,
        destination_provider,
        adapter_id,
    )

    projection = adapter.project(envelope, _projection_facts(envelope))

    portable = cast("dict[str, Any]", projection.checkpoint["portable_handoff"])
    destination_evidence = projection.checkpoint["destination_evidence"]
    assert projection.provider == destination_provider
    assert projection.checkpoint["plan-path"] == envelope.plan.path
    assert projection.checkpoint["next_step"] == envelope.lifecycle.next_transition
    assert portable["plan"] == asdict(envelope.plan)
    assert portable["lifecycle"] == asdict(envelope.lifecycle)
    assert portable["identity"] == asdict(envelope.identity)
    assert portable["binding"] == asdict(envelope.binding)
    assert portable["scheduler_context"] == {"kind": "ordinary"}
    assert portable["selected_adapter"] == adapter_id
    assert portable["source"]["expression"]["historical_receipts"]["mode"] == ("opaque")
    assert destination_evidence == {
        "status": "pending_first_delegation",
        "receipts": [],
    }
    assert projection.destination_evidence == ProviderExecutionEvidence()


@pytest.mark.parametrize(
    ("source_provider", "destination_provider", "adapter_id", "adapter"),
    ADAPTER_CASES,
    ids=("claude-to-codex", "codex-to-claude"),
)
def test_adapter_rejects_the_opposite_provider_direction(
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
    adapter: ProviderAdapterProtocol,
) -> None:
    """Each adapter rejects an envelope owned by the opposite provider."""

    envelope = _ordinary_envelope(
        destination_provider,
        source_provider,
        adapter_id,
    )

    with pytest.raises(ValueError, match="does not select"):
        adapter.validate_source(envelope)


@pytest.mark.parametrize("phase", COMPLETED_PREPARATION_PHASES)
@pytest.mark.parametrize(
    ("source_provider", "destination_provider", "adapter_id", "adapter"),
    ADAPTER_CASES,
    ids=("claude-to-codex", "codex-to-claude"),
)
def test_completed_phase_replay_is_rejected_before_projection_mutation(
    phase: str,
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
    adapter: ProviderAdapterProtocol,
) -> None:
    """Every completed preparation phase fails before a projection can begin."""

    envelope = _ordinary_envelope(
        source_provider,
        destination_provider,
        adapter_id,
    )
    original = asdict(envelope)
    adapter.validate_source(envelope)

    failure = validate_semantic_contract(
        envelope,
        requested_transition="prepared_to_atomic_execution",
        transition_state="preparation_complete",
        requested_phase=phase,
        supported_capabilities=envelope.capabilities.required,
    )

    assert failure == "HANDOFF_TRANSITION_NOT_ALLOWED"
    assert asdict(envelope) == original


@pytest.mark.parametrize(
    ("scheduler_kind", "cohort_or_wave", "retained_authorities"),
    SCHEDULED_CASES,
    ids=("parallel-child", "epic-child"),
)
@pytest.mark.parametrize(
    ("source_provider", "destination_provider", "adapter_id", "adapter"),
    ADAPTER_CASES,
    ids=("claude-to-codex", "codex-to-claude"),
)
def test_scheduled_child_projection_retains_parent_scheduler_authority(
    scheduler_kind: SchedulerKind,
    cohort_or_wave: str | int,
    retained_authorities: tuple[str, ...],
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
    adapter: ProviderAdapterProtocol,
) -> None:
    """Both directions retain parallel or epic authority at the parent."""

    envelope = _scheduled_envelope(
        source_provider,
        destination_provider,
        adapter_id,
        scheduler_kind,
        cohort_or_wave,
    )

    projection = adapter.project(envelope, _projection_facts(envelope))

    portable = cast("dict[str, Any]", projection.checkpoint["portable_handoff"])
    scheduler = cast("dict[str, Any]", portable["scheduler_context"])
    authority = cast("dict[str, Any]", scheduler["authority"])
    assert scheduler["kind"] == scheduler_kind
    assert scheduler["cohort_or_wave"] == cohort_or_wave
    assert authority["execution_owner"] == "ordinary_orchestrator"
    assert authority["execution_scope"] == [
        "ordinary_execution",
        "bounded_result_return",
    ]
    assert authority["scheduler_owner"] == f"{scheduler_kind}_orchestrator"
    assert tuple(authority["scheduler_retains"]) == retained_authorities
    assert set(authority["execution_scope"]).isdisjoint(retained_authorities)
    assert projection.destination_evidence == ProviderExecutionEvidence()


@pytest.mark.parametrize(
    ("scheduler_kind", "cohort_or_wave", "_retained_authorities"),
    SCHEDULED_CASES,
    ids=("parallel-child", "epic-child"),
)
@pytest.mark.parametrize(
    ("source_provider", "destination_provider", "adapter_id", "_adapter"),
    ADAPTER_CASES,
    ids=("claude-to-codex", "codex-to-claude"),
)
def test_scheduled_child_return_is_bounded_to_matching_evidence(
    scheduler_kind: SchedulerKind,
    cohort_or_wave: str | int,
    _retained_authorities: tuple[str, ...],
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
    _adapter: ProviderAdapterProtocol,
) -> None:
    """Both directions accept only the scheduler-bound child result."""

    envelope = _scheduled_envelope(
        source_provider,
        destination_provider,
        adapter_id,
        scheduler_kind,
        cohort_or_wave,
    )
    result = _bounded_result(envelope)

    failure = validate_return_to_scheduler(
        envelope,
        result,
        child_checkpoint_sha256="d" * 64,
        result_sha256="e" * 64,
    )

    assert failure is None
    for field in result:
        invalid = {**result, field: "mismatch"}
        assert (
            validate_return_to_scheduler(
                envelope,
                invalid,
                child_checkpoint_sha256="d" * 64,
                result_sha256="e" * 64,
            )
            is not None
        ), field
    assert (
        validate_return_to_scheduler(
            envelope,
            {**result, "scheduler_completion": True},
            child_checkpoint_sha256="d" * 64,
            result_sha256="e" * 64,
        )
        == "HANDOFF_SCHEDULER_BINDING_MISMATCH"
    )


@pytest.mark.parametrize(
    ("source_provider", "destination_provider", "adapter_id", "adapter"),
    ADAPTER_CASES,
    ids=("claude-to-codex", "codex-to-claude"),
)
def test_destination_evidence_waits_for_first_post_materialization_delegation(
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
    adapter: ProviderAdapterProtocol,
) -> None:
    """Routing, topology, and model evidence cannot precede materialization."""

    envelope = _ordinary_envelope(
        source_provider,
        destination_provider,
        adapter_id,
    )
    projection = adapter.project(envelope, _projection_facts(envelope))
    original = asdict(projection)
    evidence = ProviderExecutionEvidence(
        routing={"provider": destination_provider},
        topology={"provider": destination_provider},
        model={"provider": destination_provider},
        receipts=({"provider": destination_provider, "delegation_sequence": 1},),
    )

    with pytest.raises(ValueError, match="first new delegation"):
        record_first_destination_delegation(
            projection,
            evidence,
            checkpoint_materialized=False,
            delegation_sequence=1,
        )
    with pytest.raises(ValueError, match="first new delegation"):
        record_first_destination_delegation(
            projection,
            evidence,
            checkpoint_materialized=True,
            delegation_sequence=2,
        )
    assert asdict(projection) == original


@pytest.mark.parametrize(
    ("source_provider", "destination_provider", "adapter_id", "adapter"),
    ADAPTER_CASES,
    ids=("claude-to-codex", "codex-to-claude"),
)
def test_first_post_materialization_delegation_records_destination_evidence_once(
    source_provider: Provider,
    destination_provider: Provider,
    adapter_id: str,
    adapter: ProviderAdapterProtocol,
) -> None:
    """The first new delegation records destination-owned evidence exactly once."""

    envelope = _ordinary_envelope(
        source_provider,
        destination_provider,
        adapter_id,
    )
    projection = adapter.project(envelope, _projection_facts(envelope))
    evidence = ProviderExecutionEvidence(
        routing={"provider": destination_provider},
        topology={"provider": destination_provider},
        model={"provider": destination_provider},
        receipts=({"provider": destination_provider, "delegation_sequence": 1},),
    )

    recorded = record_first_destination_delegation(
        projection,
        evidence,
        checkpoint_materialized=True,
        delegation_sequence=1,
    )

    destination_evidence = cast(
        "dict[str, Any]", recorded.checkpoint["destination_evidence"]
    )
    assert destination_evidence["status"] == "first_delegation_recorded"
    assert destination_evidence["routing"] == evidence.routing
    assert destination_evidence["topology"] == evidence.topology
    assert destination_evidence["model"] == evidence.model
    assert recorded.destination_evidence == evidence
    with pytest.raises(ValueError, match="first new delegation"):
        record_first_destination_delegation(
            recorded,
            evidence,
            checkpoint_materialized=True,
            delegation_sequence=1,
        )
