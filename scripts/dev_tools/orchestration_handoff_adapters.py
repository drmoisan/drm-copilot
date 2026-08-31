"""Typed provider-adapter boundaries for portable orchestration handoffs."""

from __future__ import annotations

from dataclasses import asdict, dataclass, field, replace
from typing import Literal, Protocol, cast

from scripts.dev_tools import orchestration_handoff_contract as handoff

ProviderEvidenceValue = dict[str, object]
PARALLEL_SCHEDULER_AUTHORITIES = (
    "cohort_ordering",
    "barriers",
    "fan_in",
    "integration",
    "worktree_cleanup",
    "run_completion",
)
EPIC_SCHEDULER_AUTHORITIES = (
    "wave_ordering",
    "barriers",
    "fan_in",
    "integration",
    "worktree_cleanup",
    "run_completion",
)


@dataclass(frozen=True, slots=True)
class PortableProjectionFacts:
    """Provider-neutral plan, lifecycle, scheduler, and integrity facts."""

    plan: handoff.PlanIdentity
    lifecycle: handoff.LifecycleState
    scheduler_context: handoff.SchedulerContext
    envelope_sha256: str
    history_entry_sha256: str


@dataclass(frozen=True, slots=True)
class ProviderExecutionEvidence:
    """Destination-owned evidence created only by destination execution."""

    routing: ProviderEvidenceValue | None = None
    model: ProviderEvidenceValue | None = None
    profile: ProviderEvidenceValue | None = None
    topology: ProviderEvidenceValue | None = None
    launch: ProviderEvidenceValue | None = None
    receipts: tuple[ProviderEvidenceValue, ...] = ()


@dataclass(frozen=True, slots=True)
class ProviderCheckpointProjection:
    """A destination checkpoint projection with evidence kept out of portable facts."""

    provider: handoff.Provider
    checkpoint_expression: str
    destination_projector: str
    checkpoint: dict[str, object]
    portable: PortableProjectionFacts
    destination_evidence: ProviderExecutionEvidence = field(
        default_factory=ProviderExecutionEvidence
    )


def record_first_destination_delegation(
    projection: ProviderCheckpointProjection,
    evidence: ProviderExecutionEvidence,
    *,
    checkpoint_materialized: bool,
    delegation_sequence: int,
) -> ProviderCheckpointProjection:
    """Record destination evidence only for delegation one after materialization."""

    pending: dict[str, object] = {
        "status": "pending_first_delegation",
        "receipts": [],
    }
    required = (evidence.routing, evidence.topology, evidence.model)
    if (
        not checkpoint_materialized
        or delegation_sequence != 1
        or projection.checkpoint.get("destination_evidence") != pending
        or projection.destination_evidence != ProviderExecutionEvidence()
        or any(item is None for item in required)
        or not evidence.receipts
    ):
        raise handoff.HandoffContractError(
            "destination_evidence",
            "requires the first new delegation after materialization",
        )
    destination_evidence: dict[str, object] = {
        "status": "first_delegation_recorded",
        "delegation_sequence": delegation_sequence,
        "routing": evidence.routing,
        "topology": evidence.topology,
        "model": evidence.model,
        "receipts": list(evidence.receipts),
    }
    checkpoint = {
        **projection.checkpoint,
        "destination_evidence": destination_evidence,
    }
    return replace(
        projection,
        checkpoint=checkpoint,
        destination_evidence=evidence,
    )


class ProviderAdapterProtocol(Protocol):
    """Shared typed contract implemented by each provider-direction adapter."""

    @property
    def adapter_id(self) -> str:
        """Return the stable provider-direction adapter identity."""

        ...

    @property
    def source_provider(self) -> handoff.Provider:
        """Return the provider whose native checkpoint is authoritative."""

        ...

    @property
    def destination_provider(self) -> handoff.Provider:
        """Return the provider that will own the projected checkpoint."""

        ...

    def validate_source(self, envelope: handoff.HandoffEnvelope) -> None:
        """Validate source expression and adapter identity without mutation."""

        ...

    def project(
        self,
        envelope: handoff.HandoffEnvelope,
        facts: PortableProjectionFacts,
    ) -> ProviderCheckpointProjection:
        """Project portable facts without creating destination execution evidence."""

        ...


class ClaudeToCodexAdapterProtocol(ProviderAdapterProtocol, Protocol):
    """Typed Claude-source to Codex-destination adapter contract."""

    @property
    def adapter_id(self) -> Literal["claude-to-codex-v1"]:
        """Return the registered Claude-to-Codex adapter identity."""

        ...

    @property
    def source_provider(self) -> Literal["claude"]:
        """Return the Claude source-provider identity."""

        ...

    @property
    def destination_provider(self) -> Literal["codex"]:
        """Return the Codex destination-provider identity."""

        ...


class CodexToClaudeAdapterProtocol(ProviderAdapterProtocol, Protocol):
    """Typed Codex-source to Claude-destination adapter contract."""

    @property
    def adapter_id(self) -> Literal["codex-to-claude-v1"]:
        """Return the registered Codex-to-Claude adapter identity."""

        ...

    @property
    def source_provider(self) -> Literal["codex"]:
        """Return the Codex source-provider identity."""

        ...

    @property
    def destination_provider(self) -> Literal["claude"]:
        """Return the Claude destination-provider identity."""

        ...


def _validate_projection_facts(
    envelope: handoff.HandoffEnvelope,
    facts: PortableProjectionFacts,
) -> None:
    if facts.plan != envelope.plan:
        raise handoff.HandoffContractError("projection.plan", "does not match envelope")
    if facts.lifecycle != envelope.lifecycle:
        raise handoff.HandoffContractError(
            "projection.lifecycle", "does not match envelope"
        )
    if facts.scheduler_context != envelope.scheduler_context:
        raise handoff.HandoffContractError(
            "projection.scheduler_context", "does not match envelope"
        )
    for field_name, digest in (
        ("envelope_sha256", facts.envelope_sha256),
        ("history_entry_sha256", facts.history_entry_sha256),
    ):
        if handoff.SHA256_PATTERN.fullmatch(digest) is None:
            raise handoff.HandoffContractError(
                f"projection.{field_name}", "is not a SHA-256 digest"
            )
    last_history = envelope.handoff_history[-1]
    if facts.history_entry_sha256 != last_history.entry_sha256:
        raise handoff.HandoffContractError(
            "projection.history_entry_sha256", "does not match envelope history"
        )


def _scheduler_mapping(
    scheduler: handoff.SchedulerContext,
) -> dict[str, object]:
    projection = {
        key: value
        for key, value in cast("dict[str, object]", asdict(scheduler)).items()
        if value is not None
    }
    if scheduler.kind == "parallel":
        projection["authority"] = {
            "execution_owner": scheduler.child_execution_owner,
            "execution_scope": ["ordinary_execution", "bounded_result_return"],
            "scheduler_owner": scheduler.scheduler_owner,
            "scheduler_retains": list(PARALLEL_SCHEDULER_AUTHORITIES),
        }
    elif scheduler.kind == "epic":
        projection["authority"] = {
            "execution_owner": scheduler.child_execution_owner,
            "execution_scope": ["ordinary_execution", "bounded_result_return"],
            "scheduler_owner": scheduler.scheduler_owner,
            "scheduler_retains": list(EPIC_SCHEDULER_AUTHORITIES),
        }
    return projection


def _portable_link(
    envelope: handoff.HandoffEnvelope,
    facts: PortableProjectionFacts,
    *,
    adapter_id: str,
    source_validator: str,
) -> dict[str, object]:
    source = envelope.source
    return {
        "handoff_id": envelope.handoff_id,
        "envelope_sha256": facts.envelope_sha256,
        "history_entry_sha256": facts.history_entry_sha256,
        "selected_adapter": adapter_id,
        "source_validator": source_validator,
        "identity": asdict(envelope.identity),
        "binding": asdict(envelope.binding),
        "source": {
            "provider": source.provider,
            "checkpoint_path": source.checkpoint_path,
            "checkpoint_sha256": source.checkpoint_sha256,
            "archive_path": source.archive_path,
            "expression": {
                "schema_id": source.expression_schema_id,
                "schema_version": source.expression_schema_version,
                "historical_receipts": {
                    "mode": "opaque",
                    "references": [
                        {"path": reference.path, "sha256": reference.sha256}
                        for reference in source.receipt_references
                    ],
                },
            },
        },
        "plan": asdict(facts.plan),
        "lifecycle": asdict(facts.lifecycle),
        "capabilities": asdict(envelope.capabilities),
        "scheduler_context": _scheduler_mapping(facts.scheduler_context),
    }


@dataclass(frozen=True, slots=True)
class ClaudeToCodexAdapter:
    """Project an authoritative Claude checkpoint into a Codex checkpoint."""

    @property
    def adapter_id(self) -> Literal["claude-to-codex-v1"]:
        """Return the registered Claude-to-Codex adapter identity."""

        return "claude-to-codex-v1"

    @property
    def source_provider(self) -> Literal["claude"]:
        """Return the Claude source-provider identity."""

        return "claude"

    @property
    def destination_provider(self) -> Literal["codex"]:
        """Return the Codex destination-provider identity."""

        return "codex"

    def validate_source(self, envelope: handoff.HandoffEnvelope) -> None:
        """Validate the Claude source expression and history adapter identity."""

        first_history = envelope.handoff_history[0]
        if (
            envelope.source.provider != self.source_provider
            or envelope.destination_provider != self.destination_provider
            or envelope.source.expression_schema_id != "claude.orchestrator-state"
            or first_history.adapter_id != self.adapter_id
            or first_history.adapter_version != "1.0.0"
        ):
            raise handoff.HandoffContractError(
                "source.expression", "does not select claude-to-codex-v1"
            )

    def project(
        self,
        envelope: handoff.HandoffEnvelope,
        facts: PortableProjectionFacts,
    ) -> ProviderCheckpointProjection:
        """Produce a Codex checkpoint without pre-delegation Codex evidence."""

        self.validate_source(envelope)
        _validate_projection_facts(envelope, facts)
        portable_link = _portable_link(
            envelope,
            facts,
            adapter_id=self.adapter_id,
            source_validator="claude-source-v1",
        )
        destination_evidence: dict[str, object] = {
            "status": "pending_first_delegation",
            "receipts": [],
        }
        checkpoint: dict[str, object] = {
            "provider": self.destination_provider,
            "checkpoint_expression": "codex.orchestrator-state",
            "destination_projector": "portable-to-codex-v1",
            "plan-path": facts.plan.path,
            "next_step": facts.lifecycle.next_transition,
            "portable_handoff": portable_link,
            "destination_evidence": destination_evidence,
        }
        return ProviderCheckpointProjection(
            provider=self.destination_provider,
            checkpoint_expression="codex.orchestrator-state",
            destination_projector="portable-to-codex-v1",
            checkpoint=checkpoint,
            portable=facts,
        )


@dataclass(frozen=True, slots=True)
class CodexToClaudeAdapter:
    """Project an authoritative Codex checkpoint into a Claude checkpoint."""

    @property
    def adapter_id(self) -> Literal["codex-to-claude-v1"]:
        """Return the registered Codex-to-Claude adapter identity."""

        return "codex-to-claude-v1"

    @property
    def source_provider(self) -> Literal["codex"]:
        """Return the Codex source-provider identity."""

        return "codex"

    @property
    def destination_provider(self) -> Literal["claude"]:
        """Return the Claude destination-provider identity."""

        return "claude"

    def validate_source(self, envelope: handoff.HandoffEnvelope) -> None:
        """Validate the Codex source expression and history adapter identity."""

        first_history = envelope.handoff_history[0]
        if (
            envelope.source.provider != self.source_provider
            or envelope.destination_provider != self.destination_provider
            or envelope.source.expression_schema_id != "codex.orchestrator-state"
            or first_history.adapter_id != self.adapter_id
            or first_history.adapter_version != "1.0.0"
        ):
            raise handoff.HandoffContractError(
                "source.expression", "does not select codex-to-claude-v1"
            )

    def project(
        self,
        envelope: handoff.HandoffEnvelope,
        facts: PortableProjectionFacts,
    ) -> ProviderCheckpointProjection:
        """Produce a Claude checkpoint without pre-delegation Claude evidence."""

        self.validate_source(envelope)
        _validate_projection_facts(envelope, facts)
        portable_link = _portable_link(
            envelope,
            facts,
            adapter_id=self.adapter_id,
            source_validator="codex-source-v1",
        )
        destination_evidence: dict[str, object] = {
            "status": "pending_first_delegation",
            "receipts": [],
        }
        checkpoint: dict[str, object] = {
            "provider": self.destination_provider,
            "checkpoint_expression": "claude.orchestrator-state",
            "destination_projector": "portable-to-claude-v1",
            "plan-path": facts.plan.path,
            "next_step": facts.lifecycle.next_transition,
            "portable_handoff": portable_link,
            "destination_evidence": destination_evidence,
        }
        return ProviderCheckpointProjection(
            provider=self.destination_provider,
            checkpoint_expression="claude.orchestrator-state",
            destination_projector="portable-to-claude-v1",
            checkpoint=checkpoint,
            portable=facts,
        )
