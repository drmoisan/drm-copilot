"""Verify TaskMaster #469 portable handoff fixtures end to end."""

from __future__ import annotations

import hashlib
from dataclasses import asdict, replace
from typing import cast

import pytest

from scripts.dev_tools.orchestration_handoff_adapters import (
    EPIC_SCHEDULER_AUTHORITIES,
    PARALLEL_SCHEDULER_AUTHORITIES,
    ProviderExecutionEvidence,
    record_first_destination_delegation,
)
from scripts.dev_tools.orchestration_handoff_contract import (
    HandoffContractError,
    HandoffEnvelope,
    PlanIdentity,
    SchedulerContext,
    SchedulerKind,
    read_legacy_v1,
    select_primary_failure,
    validate_bindings,
    validate_history_chain,
    validate_provenance_bytes,
    validate_return_to_scheduler,
    validate_semantic_contract,
)
from tests.scripts.dev_tools.orchestration_handoff_taskmaster_469_test_support import (
    CASES,
    FixtureCase,
    bounded_result,
    build_envelope,
    fixture_bytes,
    load_fixture,
    mapping,
    projection_facts,
    scheduled_envelope,
)

NEGATIVE_SCENARIOS = (
    ("unsupported-major", "HANDOFF_UNSUPPORTED_VERSION"),
    ("unsupported-vocabulary", "HANDOFF_UNSUPPORTED_VERSION"),
    ("source-tamper", "HANDOFF_SOURCE_HASH_MISMATCH"),
    ("history-tamper", "HANDOFF_HISTORY_INVALID"),
    ("plan-path-traversal", "HANDOFF_PLAN_PATH_INVALID"),
    ("plan-path-absolute", "HANDOFF_PLAN_PATH_INVALID"),
    ("repository-binding", "HANDOFF_REPOSITORY_MISMATCH"),
    ("workspace-binding", "HANDOFF_WORKSPACE_MISMATCH"),
    ("issue-binding", "HANDOFF_ISSUE_FEATURE_MISMATCH"),
    ("feature-binding", "HANDOFF_ISSUE_FEATURE_MISMATCH"),
    ("branch-binding", "HANDOFF_BRANCH_LINEAGE_MISMATCH"),
    ("plan-hash-binding", "HANDOFF_PLAN_HASH_MISMATCH"),
    ("scheduler-binding", "HANDOFF_SCHEDULER_BINDING_MISMATCH"),
    ("completed-phase-replay", "HANDOFF_TRANSITION_NOT_ALLOWED"),
    ("capability-authority", "HANDOFF_CAPABILITY_UNAVAILABLE"),
    ("validator-authority", "HANDOFF_VALIDATOR_UNAVAILABLE"),
    ("topology-authority", "HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE"),
    ("routing-authority", "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE"),
)


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_taskmaster_469_fixture_hashes_and_source_history_are_pinned(
    case: FixtureCase,
) -> None:
    """Fixture bytes match metadata and contain no destination-provider receipt."""

    fixture = load_fixture(case)
    source = mapping(fixture["source_checkpoint"], "source_checkpoint")
    plan = mapping(fixture["plan"], "plan")
    source_bytes, plan_bytes = fixture_bytes(case, fixture)

    assert hashlib.sha256(source_bytes).hexdigest() == source["sha256"]
    assert hashlib.sha256(plan_bytes).hexdigest() == plan["sha256"]
    assert case.destination_provider.encode() not in source_bytes.lower()


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_taskmaster_469_ordinary_dry_run_is_execution_ready_and_non_mutating(
    case: FixtureCase,
) -> None:
    """Both directions project the exact execution resume without writes."""

    fixture = load_fixture(case)
    source_before, plan_before = fixture_bytes(case, fixture)
    envelope = build_envelope(case)

    failure = validate_semantic_contract(
        envelope,
        requested_transition="prepared_to_atomic_execution",
        transition_state="preparation_complete",
        requested_phase="atomic_execution",
        supported_capabilities=envelope.capabilities.required,
    )
    projection = case.adapter.project(envelope, projection_facts(envelope))

    assert failure is None
    assert projection.provider == case.destination_provider
    assert projection.checkpoint["plan-path"] == envelope.plan.path
    assert projection.checkpoint["next_step"] == "atomic_execution"
    assert projection.checkpoint["destination_evidence"] == {
        "status": "pending_first_delegation",
        "receipts": [],
    }
    assert fixture_bytes(case, fixture) == (source_before, plan_before)


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_taskmaster_469_materialized_projection_adds_only_new_provider_evidence(
    case: FixtureCase,
) -> None:
    """Materialization retains source evidence and records only delegation one."""

    envelope = build_envelope(case)
    projection = case.adapter.project(envelope, projection_facts(envelope))
    portable_before = projection.checkpoint["portable_handoff"]
    evidence = ProviderExecutionEvidence(
        routing={"provider": case.destination_provider},
        topology={"provider": case.destination_provider},
        model={"provider": case.destination_provider},
        receipts=({"provider": case.destination_provider, "delegation_sequence": 1},),
    )

    materialized = record_first_destination_delegation(
        projection,
        evidence,
        checkpoint_materialized=True,
        delegation_sequence=1,
    )

    assert materialized.checkpoint["portable_handoff"] == portable_before
    assert materialized.destination_evidence == evidence
    assert materialized.checkpoint["destination_evidence"] == {
        "status": "first_delegation_recorded",
        "delegation_sequence": 1,
        "routing": evidence.routing,
        "topology": evidence.topology,
        "model": evidence.model,
        "receipts": list(evidence.receipts),
    }


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_taskmaster_469_completed_preparation_phases_cannot_replay(
    case: FixtureCase,
) -> None:
    """Every completed phase is rejected without mutating the envelope."""

    envelope = build_envelope(case)
    original = asdict(envelope)

    for phase in envelope.lifecycle.completed_phases:
        failure = validate_semantic_contract(
            envelope,
            requested_transition="prepared_to_atomic_execution",
            transition_state="preparation_complete",
            requested_phase=phase,
            supported_capabilities=envelope.capabilities.required,
        )
        assert failure == "HANDOFF_TRANSITION_NOT_ALLOWED", phase
        assert asdict(envelope) == original


def _assert_scheduled_child(
    case: FixtureCase,
    kind: SchedulerKind,
    retained_authorities: tuple[str, ...],
) -> None:
    """Verify a child executes and returns without taking parent authority."""

    envelope = scheduled_envelope(case, kind)
    scheduler_before = asdict(envelope.scheduler_context)
    failure = validate_semantic_contract(
        envelope,
        requested_transition="prepared_to_atomic_execution",
        transition_state="preparation_complete",
        requested_phase="atomic_execution",
        supported_capabilities=envelope.capabilities.required,
        expected_scheduler_context=envelope.scheduler_context,
    )
    projection = case.adapter.project(envelope, projection_facts(envelope))
    portable = mapping(projection.checkpoint["portable_handoff"], "portable_handoff")
    scheduler = mapping(portable["scheduler_context"], "scheduler_context")
    authority = mapping(scheduler["authority"], "scheduler_context.authority")
    result = bounded_result(envelope)

    assert failure is None
    assert authority["execution_owner"] == "ordinary_orchestrator"
    assert authority["execution_scope"] == [
        "ordinary_execution",
        "bounded_result_return",
    ]
    assert tuple(cast("list[str]", authority["scheduler_retains"])) == (
        retained_authorities
    )
    assert (
        validate_return_to_scheduler(
            envelope,
            result,
            child_checkpoint_sha256="c" * 64,
            result_sha256="d" * 64,
        )
        is None
    )
    assert (
        validate_return_to_scheduler(
            envelope,
            {**result, "run_completion": True},
            child_checkpoint_sha256="c" * 64,
            result_sha256="d" * 64,
        )
        == "HANDOFF_SCHEDULER_BINDING_MISMATCH"
    )
    assert asdict(envelope.scheduler_context) == scheduler_before


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_taskmaster_469_parallel_child_executes_and_returns_without_parent_power(
    case: FixtureCase,
) -> None:
    """Parallel fixtures retain ordering and fan-in at the parent."""

    _assert_scheduled_child(case, "parallel", PARALLEL_SCHEDULER_AUTHORITIES)


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_taskmaster_469_epic_child_executes_and_returns_without_parent_power(
    case: FixtureCase,
) -> None:
    """Epic fixtures retain wave and integration authority at the parent."""

    _assert_scheduled_child(case, "epic", EPIC_SCHEDULER_AUTHORITIES)


def _semantic_failure(
    envelope: HandoffEnvelope,
    *,
    phase: str = "atomic_execution",
    supported_capabilities: tuple[str, ...] | None = None,
    expected_scheduler_context: SchedulerContext | None = None,
    validator_available: bool = True,
    topology_resolver_available: bool = True,
    provider_routing_available: bool = True,
) -> str | None:
    """Run the semantic gate with explicit destination authority inputs."""

    return validate_semantic_contract(
        envelope,
        requested_transition="prepared_to_atomic_execution",
        transition_state="preparation_complete",
        requested_phase=phase,
        supported_capabilities=(
            envelope.capabilities.required
            if supported_capabilities is None
            else supported_capabilities
        ),
        expected_scheduler_context=expected_scheduler_context,
        validator_available=validator_available,
        topology_resolver_available=topology_resolver_available,
        provider_routing_available=provider_routing_available,
    )


def _binding_failure(envelope: HandoffEnvelope, scenario: str) -> str | None:
    """Return the exact mismatch for one observed TaskMaster binding."""

    observed: dict[str, object] = {
        "repository_id": envelope.binding.repository_id,
        "workspace_root": envelope.binding.workspace_root,
        "branch": envelope.binding.branch,
        "issue_number": envelope.identity.issue_number,
        "feature_folder": envelope.identity.feature_folder,
        "plan_sha256": envelope.plan.sha256,
    }
    field = scenario.removesuffix("-binding").replace("plan-hash", "plan_sha256")
    field = field.replace("repository", "repository_id")
    field = field.replace("workspace", "workspace_root")
    field = field.replace("issue", "issue_number")
    field = field.replace("feature", "feature_folder")
    observed[field] = 999 if field == "issue_number" else "mismatch"
    return validate_bindings(envelope, observed)


def _negative_failure(case: FixtureCase, scenario: str) -> str | None:
    """Evaluate one TaskMaster negative case through its contract boundary."""

    envelope = build_envelope(case)
    if scenario == "unsupported-major":
        return _semantic_failure(replace(envelope, schema_version="3.0.0"))
    if scenario == "unsupported-vocabulary":
        capabilities = replace(envelope.capabilities, vocabularies=("unknown-v1",))
        return _semantic_failure(replace(envelope, capabilities=capabilities))
    if scenario == "source-tamper":
        try:
            validate_provenance_bytes(envelope.source, b"tampered", ())
        except HandoffContractError:
            return "HANDOFF_SOURCE_HASH_MISMATCH"
    if scenario == "history-tamper":
        tampered = replace(envelope.handoff_history[0], entry_sha256="f" * 64)
        try:
            validate_history_chain((tampered,))
        except HandoffContractError:
            return "HANDOFF_HISTORY_INVALID"
    if scenario.startswith("plan-path-"):
        invalid_path = (
            "../plan.md" if scenario.endswith("traversal") else "C:/absolute/plan.md"
        )
        try:
            PlanIdentity(
                path=invalid_path,
                sha256=envelope.plan.sha256,
                contract_version=envelope.plan.contract_version,
            )
        except HandoffContractError:
            return "HANDOFF_PLAN_PATH_INVALID"
    if scenario.endswith("-binding") and scenario != "scheduler-binding":
        return _binding_failure(envelope, scenario)
    if scenario == "scheduler-binding":
        scheduled = scheduled_envelope(case, "parallel")
        mismatched = replace(scheduled.scheduler_context, item_id="other-item")
        return _semantic_failure(
            scheduled,
            expected_scheduler_context=mismatched,
        )
    if scenario == "completed-phase-replay":
        return _semantic_failure(envelope, phase=envelope.lifecycle.completed_phases[0])
    if scenario == "capability-authority":
        return _semantic_failure(envelope, supported_capabilities=())
    if scenario == "validator-authority":
        return _semantic_failure(envelope, validator_available=False)
    if scenario == "topology-authority":
        return _semantic_failure(envelope, topology_resolver_available=False)
    if scenario == "routing-authority":
        return _semantic_failure(envelope, provider_routing_available=False)
    raise AssertionError(f"unhandled negative scenario: {scenario}")


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
@pytest.mark.parametrize(
    ("scenario", "expected"),
    NEGATIVE_SCENARIOS,
    ids=[scenario for scenario, _expected in NEGATIVE_SCENARIOS],
)
def test_taskmaster_469_negative_contract_matrix_is_ordered_and_non_mutating(
    case: FixtureCase,
    scenario: str,
    expected: str,
) -> None:
    """Every contract failure is exact and leaves pinned fixture bytes unchanged."""

    fixture = load_fixture(case)
    before = fixture_bytes(case, fixture)

    assert _negative_failure(case, scenario) == expected
    assert fixture_bytes(case, fixture) == before


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_taskmaster_469_dirty_worktree_is_last_and_preserves_unrelated_paths(
    case: FixtureCase,
) -> None:
    """Sixteen unrelated project changes surface only after valid authorities."""

    fixture = load_fixture(case)
    before = fixture_bytes(case, fixture)
    affected = tuple(
        f"src/Project{index:02d}/Project{index:02d}.csproj" for index in range(16)
    )
    unrelated = {
        path: f"unchanged-{index}".encode() for index, path in enumerate(affected)
    }
    unrelated_before = dict(unrelated)
    envelope = build_envelope(case)

    assert _semantic_failure(envelope) is None
    assert select_primary_failure(("HANDOFF_DIRTY_WORKTREE",)) == (
        "HANDOFF_DIRTY_WORKTREE"
    )
    assert len(affected) == 16
    assert unrelated == unrelated_before
    assert fixture_bytes(case, fixture) == before


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
@pytest.mark.parametrize("stage", ("candidate_validation", "atomic_replacement"))
def test_taskmaster_469_materialization_failure_retains_source_authority(
    case: FixtureCase,
    stage: str,
) -> None:
    """Candidate or replacement failure retains the source and requested history."""

    fixture = load_fixture(case)
    before = fixture_bytes(case, fixture)
    envelope = build_envelope(case)
    affected_path = (
        f"{envelope.destination_checkpoint_path}.handoff-candidate.json"
        if stage == "candidate_validation"
        else envelope.destination_checkpoint_path
    )

    failure = select_primary_failure(
        ("HANDOFF_VALIDATOR_UNAVAILABLE", "HANDOFF_DIRTY_WORKTREE")
    )

    assert failure == "HANDOFF_VALIDATOR_UNAVAILABLE"
    assert affected_path.startswith("artifacts/orchestration/")
    assert all(entry.status == "requested" for entry in envelope.handoff_history)
    assert fixture_bytes(case, fixture) == before


@pytest.mark.parametrize("case", CASES, ids=lambda case: case.name)
def test_taskmaster_469_legacy_migration_never_infers_missing_portable_facts(
    case: FixtureCase,
) -> None:
    """Each absent legacy fact blocks while preserving the raw checkpoint bytes."""

    fixture = load_fixture(case)
    source_before, plan_before = fixture_bytes(case, fixture)
    envelope = build_envelope(case)
    facts: dict[str, object | None] = {
        "source_provider": case.source_provider,
        "plan": envelope.plan,
        "lifecycle": envelope.lifecycle,
        "scheduler_context": envelope.scheduler_context,
    }

    for missing in facts:
        incomplete = {**facts, missing: None}
        with pytest.raises(HandoffContractError):
            read_legacy_v1(
                source_before,
                source_provider=cast("str | None", incomplete["source_provider"]),
                plan=incomplete["plan"],
                lifecycle=incomplete["lifecycle"],
                scheduler_context=incomplete["scheduler_context"],
            )
        assert fixture_bytes(case, fixture) == (source_before, plan_before)
