from __future__ import annotations

import json
import re
from dataclasses import asdict, dataclass
from typing import TYPE_CHECKING, Final, Literal, cast

from scripts.dev_tools.orchestration_handoff_contract_support import (
    HandoffContractError,
    normalize_repository_relative_path,
    raw_sha256,
)
from scripts.dev_tools.orchestration_handoff_contract_support import (
    SemanticMcpIdentity as SemanticMcpIdentity,
)
from scripts.dev_tools.orchestration_handoff_contract_support import (
    parse_semantic_mcp_identity as parse_semantic_mcp_identity,
)
from scripts.dev_tools.orchestration_handoff_contract_support import (
    raw_file_sha256 as raw_file_sha256,
)
from scripts.dev_tools.orchestration_handoff_contract_support import (
    read_legacy_v1 as read_legacy_v1,
)
from scripts.dev_tools.orchestration_handoff_contract_support import (
    resolve_pinned_plan_path as resolve_pinned_plan_path,
)
from scripts.dev_tools.orchestration_handoff_contract_support import (
    validate_bounded_scheduler_return as _validate_bounded_scheduler_return,
)

if TYPE_CHECKING:
    from collections.abc import Iterable

Provider = Literal["claude", "codex"]
SchedulerKind = Literal["ordinary", "parallel", "epic"]
Bindings = dict[str, object]

SHA256_PATTERN: Final = re.compile(r"^[a-f0-9]{64}$")
GIT_SHA_PATTERN: Final = re.compile(r"^[a-f0-9]{40}$")
SCHEMA_VERSION_PATTERN: Final = re.compile(r"^[0-9]+\.[0-9]+\.[0-9]+$")
HANDOFF_ID_PATTERN: Final = re.compile(r"^[A-Za-z0-9][A-Za-z0-9._:-]{2,127}$")
PHASE_ORDER: Final = tuple(
    "intake promotion research feature_documents atomic_planning preflight "
    "atomic_execution qa feature_review pr_creation ci_verification completion".split()
)
WORK_MODES: Final = frozenset({"minor-audit", "full-feature", "full-bug"})
COMPLEXITIES: Final = frozenset({"C1", "C2", "C3", "C4"})
ROUTE_INTENTS: Final = frozenset(
    {"prepared_to_ordinary_execution", "prepared_child_to_ordinary_execution"}
)
HISTORY_STATUSES: Final = frozenset(
    {"requested", "validated", "materialized", "blocked", "returned"}
)
SUPPORTED_SCHEMA_MAJOR: Final = 2
SUPPORTED_VOCABULARIES: Final = frozenset({"portable-orchestration-handoff-core-v1"})
SOURCE_ARCHIVE_PREFIX: Final = "artifacts/orchestration/handoffs/sources/sha256/"
REGISTERED_TRANSITIONS: Final = {
    "migrate_legacy": frozenset({"legacy_v1"}),
    "prepared_to_atomic_execution": frozenset({"preparation_complete"}),
    "materialize_destination": frozenset({"validated"}),
    "atomic_execution": frozenset({"materialized"}),
    "return_to_scheduler": frozenset(
        {"atomic_execution", "qa", "feature_review", "completion"}
    ),
}
FAILURE_PRECEDENCE: Final = tuple(
    "HANDOFF_UNSUPPORTED_VERSION HANDOFF_SOURCE_HASH_MISMATCH "
    "HANDOFF_HISTORY_INVALID HANDOFF_REPOSITORY_MISMATCH "
    "HANDOFF_WORKSPACE_MISMATCH HANDOFF_ISSUE_FEATURE_MISMATCH "
    "HANDOFF_BRANCH_LINEAGE_MISMATCH HANDOFF_PLAN_PATH_INVALID "
    "HANDOFF_PLAN_HASH_MISMATCH HANDOFF_SCHEDULER_BINDING_MISMATCH "
    "HANDOFF_TRANSITION_NOT_ALLOWED HANDOFF_CAPABILITY_UNAVAILABLE "
    "HANDOFF_VALIDATOR_UNAVAILABLE HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE "
    "HANDOFF_PROVIDER_ROUTING_UNAVAILABLE HANDOFF_DIRTY_WORKTREE".split()
)


def _require(condition: bool, field: str, message: str = "is invalid") -> None:
    if not condition:
        raise HandoffContractError(field, message)


def _require_text(value: object, field: str) -> None:
    valid = isinstance(value, str) and bool(value.strip())
    _require(valid, field, "must be a non-empty string")


def _require_sha256(value: object, field: str) -> None:
    valid = isinstance(value, str) and SHA256_PATTERN.fullmatch(value) is not None
    _require(valid, field, "must be a lowercase SHA-256 digest")


def _require_provider(value: str, field: str) -> None:
    _require(value in {"claude", "codex"}, field, "must be 'claude' or 'codex'")


def _require_unique(values: tuple[str, ...], field: str) -> None:
    _require(len(values) == len(set(values)), field, "must not contain duplicates")


class _ValidatedValue:
    def __post_init__(self) -> None:
        _validate_value(self)


@dataclass(frozen=True, slots=True)
class ObjectiveIdentity(_ValidatedValue):
    objective_id: str
    issue_number: int
    feature_folder: str
    work_mode: str


@dataclass(frozen=True, slots=True)
class WorkspaceBinding(_ValidatedValue):
    repository_id: str
    workspace_root: str
    branch: str
    source_head_sha: str
    allowed_head_relationship: str


@dataclass(frozen=True, slots=True)
class PlanIdentity(_ValidatedValue):
    path: str
    sha256: str
    contract_version: str


@dataclass(frozen=True, slots=True)
class ReceiptReference(_ValidatedValue):
    path: str
    sha256: str


@dataclass(frozen=True, slots=True)
class ProviderProvenance(_ValidatedValue):
    provider: Provider
    checkpoint_path: str
    checkpoint_sha256: str
    archive_path: str
    expression_schema_id: str
    expression_schema_version: str
    receipt_references: tuple[ReceiptReference, ...] = ()


@dataclass(frozen=True, slots=True)
class LifecycleState(_ValidatedValue):
    logical_complexity: str
    route_intent: str
    completed_phases: tuple[str, ...]
    next_transition: str
    replay_policy: str = "forbid_completed_phases"


@dataclass(frozen=True, slots=True)
class CapabilityRequirements(_ValidatedValue):
    vocabularies: tuple[str, ...]
    required: tuple[str, ...]


@dataclass(frozen=True, slots=True)
class SchedulerContext(_ValidatedValue):
    kind: SchedulerKind
    run_id: str | None = None
    item_id: str | None = None
    kickoff_or_manifest_path: str | None = None
    kickoff_or_manifest_sha256: str | None = None
    parent_checkpoint_path: str | None = None
    parent_checkpoint_sha256: str | None = None
    cohort_or_wave: str | int | None = None
    scheduler_owner: str | None = None
    child_execution_owner: str | None = None
    return_contract: str | None = None


@dataclass(frozen=True, slots=True)
class HistoryEntry(_ValidatedValue):
    sequence: int
    from_provider: Provider
    to_provider: Provider
    source_checkpoint_sha256: str
    envelope_sha256: str
    requested_at: str
    previous_entry_sha256: str | None
    entry_sha256: str
    status: str
    adapter_id: str
    adapter_version: str
    target_checkpoint_sha256: str | None = None
    failure_code: str | None = None


@dataclass(frozen=True, slots=True)
class HandoffEnvelope(_ValidatedValue):
    schema_version: str
    kind: str
    handoff_id: str
    identity: ObjectiveIdentity
    binding: WorkspaceBinding
    source: ProviderProvenance
    destination_provider: Provider
    destination_checkpoint_path: str
    plan: PlanIdentity
    lifecycle: LifecycleState
    capabilities: CapabilityRequirements
    scheduler_context: SchedulerContext
    handoff_history: tuple[HistoryEntry, ...]


def _validate_value(value: _ValidatedValue) -> None:
    if isinstance(value, ObjectiveIdentity):
        _require_text(value.objective_id, "identity.objective_id")
        _require(value.issue_number > 0, "identity.issue_number", "must be positive")
        _require_text(value.feature_folder, "identity.feature_folder")
        _require(value.work_mode in WORK_MODES, "identity.work_mode")
    elif isinstance(value, WorkspaceBinding):
        for field in ("repository_id", "workspace_root", "branch"):
            _require_text(cast("str", getattr(value, field)), f"binding.{field}")
        valid_sha = GIT_SHA_PATTERN.fullmatch(value.source_head_sha) is not None
        _require(valid_sha, "binding.source_head_sha")
        allowed = value.allowed_head_relationship in {"equal", "equal_or_descendant"}
        _require(allowed, "binding.allowed_head_relationship")
    elif isinstance(value, PlanIdentity):
        normalize_repository_relative_path(value.path, field="plan.path")
        _require_sha256(value.sha256, "plan.sha256")
        contract = re.fullmatch(r"atomic-plan-v[0-9]+", value.contract_version)
        _require(contract is not None, "plan.contract_version")
    elif isinstance(value, ReceiptReference):
        _require_text(value.path, "source.expression.historical_receipts.path")
        _require_sha256(value.sha256, "source.expression.historical_receipts.sha256")
    elif isinstance(value, ProviderProvenance):
        _require_provider(value.provider, "source.provider")
        _require_sha256(value.checkpoint_sha256, "source.checkpoint.sha256")
        archive = f"{SOURCE_ARCHIVE_PREFIX}{value.checkpoint_sha256}.json"
        _require(value.archive_path == archive, "source.checkpoint.archive_path")
        fields = "checkpoint_path archive_path expression_schema_id"
        for field in f"{fields} expression_schema_version".split():
            _require_text(cast("str", getattr(value, field)), f"source.{field}")
    elif isinstance(value, LifecycleState):
        valid_complexity = value.logical_complexity in COMPLEXITIES
        _require(valid_complexity, "lifecycle.logical_complexity")
        _require(value.route_intent in ROUTE_INTENTS, "lifecycle.route_intent")
        _require_unique(value.completed_phases, "lifecycle.completed_phases")
        phases_known = all(phase in PHASE_ORDER for phase in value.completed_phases)
        _require(phases_known, "lifecycle.completed_phases")
        indexes = [PHASE_ORDER.index(phase) for phase in value.completed_phases]
        _require(indexes == sorted(indexes), "lifecycle.completed_phases")
        _require(value.next_transition in PHASE_ORDER, "lifecycle.next_transition")
        no_replay = value.next_transition not in value.completed_phases
        _require(no_replay, "lifecycle.next_transition")
        _require(
            value.replay_policy == "forbid_completed_phases", "lifecycle.replay_policy"
        )
    elif isinstance(value, CapabilityRequirements):
        _require(bool(value.vocabularies and value.required), "capabilities")
        for field, entries in (
            ("vocabularies", value.vocabularies),
            ("required", value.required),
        ):
            _require_unique(entries, f"capabilities.{field}")
            _require(all(entry.strip() for entry in entries), f"capabilities.{field}")
    elif isinstance(value, SchedulerContext):
        _require(
            value.kind in {"ordinary", "parallel", "epic"}, "scheduler_context.kind"
        )
        scheduled = tuple(asdict(value).values())[1:]
        if value.kind == "ordinary":
            has_parent_claim = any(item is not None for item in scheduled)
            _require(not has_parent_claim, "scheduler_context")
        else:
            _require(not any(item is None for item in scheduled), "scheduler_context")
            for field in "run_id item_id".split():
                _require_text(getattr(value, field), f"scheduler_context.{field}")
            for field in "kickoff_or_manifest_path parent_checkpoint_path".split():
                path = cast("str", getattr(value, field))
                normalize_repository_relative_path(
                    path, field=f"scheduler_context.{field}"
                )
            for field in "kickoff_or_manifest_sha256 parent_checkpoint_sha256".split():
                _require_sha256(getattr(value, field), f"scheduler_context.{field}")
            cohort = value.cohort_or_wave
            valid_cohort = (isinstance(cohort, str) and bool(cohort.strip())) or (
                isinstance(cohort, int) and not isinstance(cohort, bool)
            )
            _require(valid_cohort, "scheduler_context.cohort_or_wave")
            expected = {
                "scheduler_owner": f"{value.kind}_orchestrator",
                "child_execution_owner": "ordinary_orchestrator",
                "return_contract": "portable_child_result-v1",
            }
            for field, expected_value in expected.items():
                matches = getattr(value, field) == expected_value
                _require(matches, f"scheduler_context.{field}")
    elif isinstance(value, HistoryEntry):
        _require(value.sequence > 0, "handoff_history.sequence")
        _require_provider(value.from_provider, "handoff_history.from_provider")
        _require_provider(value.to_provider, "handoff_history.to_provider")
        providers_differ = value.from_provider != value.to_provider
        _require(providers_differ, "handoff_history.to_provider")
        for field in "source_checkpoint_sha256 envelope_sha256 entry_sha256".split():
            _require_sha256(
                cast("str", getattr(value, field)), f"handoff_history.{field}"
            )
        for field in "previous_entry_sha256 target_checkpoint_sha256".split():
            digest = cast("str | None", getattr(value, field))
            if digest is not None:
                _require_sha256(digest, f"handoff_history.{field}")
        for field in "requested_at adapter_id adapter_version".split():
            _require_text(
                cast("str", getattr(value, field)), f"handoff_history.{field}"
            )
        _require(value.status in HISTORY_STATUSES, "handoff_history.status")
        _require(
            value.failure_code is None
            or re.fullmatch(r"HANDOFF_[A-Z0-9_]+", value.failure_code) is not None,
            "handoff_history.failure_code",
        )
    elif isinstance(value, HandoffEnvelope):
        version = SCHEMA_VERSION_PATTERN.fullmatch(value.schema_version)
        _require(version is not None, "schema_version")
        _require(value.kind == "portable_orchestration_handoff", "kind")
        valid_id = HANDOFF_ID_PATTERN.fullmatch(value.handoff_id) is not None
        _require(valid_id, "handoff_id")
        _require_provider(value.destination_provider, "destination.provider")
        providers_differ = value.destination_provider != value.source.provider
        _require(providers_differ, "destination.provider")
        path = "artifacts/orchestration/orchestrator-state.json"
        _require(
            value.destination_checkpoint_path == path, "destination.checkpoint_path"
        )
        _require(bool(value.handoff_history), "handoff_history")
        first = value.handoff_history[0]
        expected = {
            "from_provider": value.source.provider,
            "to_provider": value.destination_provider,
            "source_checkpoint_sha256": value.source.checkpoint_sha256,
        }
        for field, expected_value in expected.items():
            matches = getattr(first, field) == expected_value
            _require(matches, f"handoff_history.{field}")


def select_primary_failure(failures: Iterable[str]) -> str | None:
    found = set(failures)
    unknown = found.difference(FAILURE_PRECEDENCE)
    if unknown:
        raise HandoffContractError("failures", "contains an unknown code")
    return next((code for code in FAILURE_PRECEDENCE if code in found), None)


def validate_bindings(envelope: HandoffEnvelope, observed: Bindings) -> str | None:
    if observed.get("repository_id") != envelope.binding.repository_id:
        return "HANDOFF_REPOSITORY_MISMATCH"
    if observed.get("workspace_root") != envelope.binding.workspace_root:
        return "HANDOFF_WORKSPACE_MISMATCH"
    if observed.get("issue_number") != envelope.identity.issue_number:
        return "HANDOFF_ISSUE_FEATURE_MISMATCH"
    if observed.get("feature_folder") != envelope.identity.feature_folder:
        return "HANDOFF_ISSUE_FEATURE_MISMATCH"
    if observed.get("branch") != envelope.binding.branch:
        return "HANDOFF_BRANCH_LINEAGE_MISMATCH"
    if observed.get("plan_sha256") != envelope.plan.sha256:
        return "HANDOFF_PLAN_HASH_MISMATCH"
    return None


def validate_return_to_scheduler(
    envelope: HandoffEnvelope,
    result: Bindings,
    *,
    child_checkpoint_sha256: str,
    result_sha256: str,
) -> str | None:
    """Accept only the exact bounded result authorized by a scheduled child."""

    scheduler = envelope.scheduler_context
    fields = "run_id item_id parent_checkpoint_path parent_checkpoint_sha256 "
    fields += "scheduler_owner child_execution_owner return_contract"
    expected = {field: getattr(scheduler, field) for field in fields.split()}
    return _validate_bounded_scheduler_return(
        result,
        scheduler_kind=scheduler.kind,
        expected_bindings=expected,
        plan_sha256=envelope.plan.sha256,
        child_checkpoint_sha256=child_checkpoint_sha256,
        result_sha256=result_sha256,
    )


def validate_semantic_contract(
    envelope: HandoffEnvelope,
    *,
    requested_transition: str,
    transition_state: str,
    requested_phase: str,
    supported_capabilities: Iterable[str],
    supported_vocabularies: Iterable[str] = SUPPORTED_VOCABULARIES,
    expected_scheduler_context: SchedulerContext | None = None,
    validator_available: bool = True,
    topology_resolver_available: bool = True,
    provider_routing_available: bool = True,
    failures: Iterable[str] = (),
) -> str | None:
    found = set(failures)
    schema_major = int(envelope.schema_version.partition(".")[0])
    if schema_major != SUPPORTED_SCHEMA_MAJOR or not set(
        envelope.capabilities.vocabularies
    ).issubset(supported_vocabularies):
        found.add("HANDOFF_UNSUPPORTED_VERSION")

    supported_capability_set = set(supported_capabilities)
    declared_capability_set = set(envelope.capabilities.required)
    scheduler_kind = envelope.scheduler_context.kind
    scheduler_suffix = (
        scheduler_kind if scheduler_kind == "ordinary" else f"{scheduler_kind}-child"
    )
    mandatory = {
        f"handoff-schema:{schema_major}",
        f"plan-contract:{envelope.plan.contract_version}",
        f"scheduler-context:{scheduler_suffix}",
    }
    transition_capability = f"transition:{requested_transition}"
    if transition_capability in supported_capability_set:
        mandatory.add(transition_capability)
    if not declared_capability_set.issubset(
        supported_capability_set
    ) or not mandatory.issubset(declared_capability_set):
        found.add("HANDOFF_CAPABILITY_UNAVAILABLE")

    allowed_sources = REGISTERED_TRANSITIONS.get(requested_transition)
    if (
        allowed_sources is None
        or transition_state not in allowed_sources
        or requested_phase != envelope.lifecycle.next_transition
        or requested_phase in envelope.lifecycle.completed_phases
    ):
        found.add("HANDOFF_TRANSITION_NOT_ALLOWED")

    expected_route = (
        "prepared_to_ordinary_execution"
        if scheduler_kind == "ordinary"
        else "prepared_child_to_ordinary_execution"
    )
    if (
        expected_scheduler_context is not None
        and envelope.scheduler_context != expected_scheduler_context
    ) or envelope.lifecycle.route_intent != expected_route:
        found.add("HANDOFF_SCHEDULER_BINDING_MISMATCH")
    found.update(("HANDOFF_VALIDATOR_UNAVAILABLE",) if not validator_available else ())
    if not topology_resolver_available:
        found.add("HANDOFF_TOPOLOGY_RESOLVER_UNAVAILABLE")
    if not provider_routing_available:
        found.add("HANDOFF_PROVIDER_ROUTING_UNAVAILABLE")
    return select_primary_failure(found)


def history_entry_digest(entry: HistoryEntry) -> str:
    payload = asdict(entry)
    del payload["entry_sha256"]
    encoded = json.dumps(payload, sort_keys=True, separators=(",", ":")).encode()
    return raw_sha256(encoded)


def validate_history_chain(entries: tuple[HistoryEntry, ...]) -> None:
    previous: str | None = None
    for expected_sequence, entry in enumerate(entries, start=1):
        if entry.sequence != expected_sequence:
            raise HandoffContractError("handoff_history.sequence", "is not monotonic")
        if entry.previous_entry_sha256 != previous:
            raise HandoffContractError(
                "handoff_history.previous_entry_sha256",
                "does not link to its predecessor",
            )
        if history_entry_digest(entry) != entry.entry_sha256:
            raise HandoffContractError("handoff_history.entry_sha256", "is invalid")
        previous = entry.entry_sha256


def validate_provenance_bytes(
    provenance: ProviderProvenance,
    source_bytes: bytes,
    receipt_bytes: tuple[bytes, ...],
) -> None:
    if raw_sha256(source_bytes) != provenance.checkpoint_sha256:
        raise HandoffContractError("source.checkpoint.sha256", "does not match bytes")
    if len(receipt_bytes) != len(provenance.receipt_references):
        raise HandoffContractError(
            "source.expression.historical_receipts", "is incomplete"
        )
    for reference, content in zip(
        provenance.receipt_references, receipt_bytes, strict=True
    ):
        if raw_sha256(content) != reference.sha256:
            raise HandoffContractError(
                "source.expression.historical_receipts.sha256", "does not match bytes"
            )
