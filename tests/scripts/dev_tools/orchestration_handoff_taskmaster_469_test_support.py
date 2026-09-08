"""Build typed portable-handoff values from TaskMaster #469 fixtures."""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, replace
from pathlib import Path
from typing import cast

from scripts.dev_tools.orchestration_handoff_adapters import (
    ClaudeToCodexAdapter,
    CodexToClaudeAdapter,
    PortableProjectionFacts,
    ProviderAdapterProtocol,
)
from scripts.dev_tools.orchestration_handoff_contract import (
    CapabilityRequirements,
    HandoffEnvelope,
    HistoryEntry,
    LifecycleState,
    ObjectiveIdentity,
    PlanIdentity,
    Provider,
    ProviderProvenance,
    ReceiptReference,
    SchedulerContext,
    SchedulerKind,
    WorkspaceBinding,
    history_entry_digest,
)

FIXTURE_ROOT = (
    Path(__file__).resolve().parents[2]
    / "fixtures"
    / "orchestration-handoff"
    / "taskmaster-469"
)


@dataclass(frozen=True, slots=True)
class FixtureCase:
    """Bind one fixture direction to its provider adapter."""

    name: str
    source_provider: Provider
    destination_provider: Provider
    adapter_id: str
    adapter: ProviderAdapterProtocol

    @property
    def root(self) -> Path:
        """Return the direction-specific fixture root."""

        return FIXTURE_ROOT / self.name


CASES: tuple[FixtureCase, ...] = (
    FixtureCase(
        name="claude-to-codex",
        source_provider="claude",
        destination_provider="codex",
        adapter_id="claude-to-codex-v1",
        adapter=ClaudeToCodexAdapter(),
    ),
    FixtureCase(
        name="codex-to-claude",
        source_provider="codex",
        destination_provider="claude",
        adapter_id="codex-to-claude-v1",
        adapter=CodexToClaudeAdapter(),
    ),
)


def mapping(value: object, name: str) -> dict[str, object]:
    """Return a typed JSON object or fail with its fixture field name."""

    if not isinstance(value, dict):
        raise ValueError(f"{name} must be an object")
    return cast("dict[str, object]", value)


def _text(value: object, name: str) -> str:
    """Return a non-empty fixture string."""

    if not isinstance(value, str) or not value:
        raise ValueError(f"{name} must be a non-empty string")
    return value


def _strings(value: object, name: str) -> tuple[str, ...]:
    """Return a tuple of non-empty fixture strings."""

    if not isinstance(value, list):
        raise ValueError(f"{name} must be a list of non-empty strings")
    items = cast("list[object]", value)
    if not all(isinstance(item, str) and bool(item) for item in items):
        raise ValueError(f"{name} must be a list of non-empty strings")
    return tuple(cast("list[str]", items))


def load_fixture(case: FixtureCase) -> dict[str, object]:
    """Load one direction's metadata fixture."""

    parsed: object = json.loads((case.root / "fixture.json").read_text("utf-8"))
    return mapping(parsed, "fixture")


def fixture_bytes(case: FixtureCase, fixture: dict[str, object]) -> tuple[bytes, bytes]:
    """Read the immutable source checkpoint and pinned plan bytes."""

    source = mapping(fixture["source_checkpoint"], "source_checkpoint")
    plan = mapping(fixture["plan"], "plan")
    return (
        (case.root / _text(source["file"], "source_checkpoint.file")).read_bytes(),
        (case.root / _text(plan["file"], "plan.file")).read_bytes(),
    )


def _receipt_references(source: dict[str, object]) -> tuple[ReceiptReference, ...]:
    """Build opaque receipt references from fixture metadata."""

    expression = mapping(source["expression"], "source_checkpoint.expression")
    historical = mapping(
        expression["historical_receipts"],
        "source_checkpoint.expression.historical_receipts",
    )
    references = historical["references"]
    if not isinstance(references, list):
        raise ValueError("historical receipt references must be a list")
    receipt_references: list[ReceiptReference] = []
    for item in cast("list[object]", references):
        reference = mapping(item, "receipt reference")
        receipt_references.append(
            ReceiptReference(
                path=_text(reference["path"], "receipt.path"),
                sha256=_text(reference["sha256"], "receipt.sha256"),
            )
        )
    return tuple(receipt_references)


def build_envelope(case: FixtureCase) -> HandoffEnvelope:
    """Build a validated portable envelope from one static fixture."""

    fixture = load_fixture(case)
    source = mapping(fixture["source_checkpoint"], "source_checkpoint")
    plan = mapping(fixture["plan"], "plan")
    identity = mapping(fixture["identity"], "identity")
    binding = mapping(fixture["binding"], "binding")
    lifecycle = mapping(fixture["lifecycle"], "lifecycle")
    capabilities = mapping(fixture["capabilities"], "capabilities")
    source_sha256 = _text(source["sha256"], "source_checkpoint.sha256")
    plan_sha256 = _text(plan["sha256"], "plan.sha256")
    envelope_sha256 = hashlib.sha256(
        f"{source_sha256}:{plan_sha256}:{case.name}".encode()
    ).hexdigest()
    history = HistoryEntry(
        sequence=1,
        from_provider=case.source_provider,
        to_provider=case.destination_provider,
        source_checkpoint_sha256=source_sha256,
        envelope_sha256=envelope_sha256,
        requested_at=_text(fixture["requested_at"], "requested_at"),
        previous_entry_sha256=None,
        entry_sha256="0" * 64,
        status="requested",
        adapter_id=case.adapter_id,
        adapter_version="1.0.0",
    )
    history = replace(history, entry_sha256=history_entry_digest(history))
    issue_number = identity["issue_number"]
    if not isinstance(issue_number, int):
        raise ValueError("identity.issue_number must be an integer")
    expression = mapping(source["expression"], "source_checkpoint.expression")
    return HandoffEnvelope(
        schema_version="2.0.0",
        kind="portable_orchestration_handoff",
        handoff_id=f"taskmaster-469-{case.name}",
        identity=ObjectiveIdentity(
            objective_id=_text(identity["objective_id"], "identity.objective_id"),
            issue_number=issue_number,
            feature_folder=_text(identity["feature_folder"], "identity.feature_folder"),
            work_mode=_text(identity["work_mode"], "identity.work_mode"),
        ),
        binding=WorkspaceBinding(
            repository_id=_text(binding["repository_id"], "binding.repository_id"),
            workspace_root=_text(binding["workspace_root"], "binding.workspace_root"),
            branch=_text(binding["branch"], "binding.branch"),
            source_head_sha=_text(
                binding["source_head_sha"], "binding.source_head_sha"
            ),
            allowed_head_relationship=_text(
                binding["allowed_head_relationship"],
                "binding.allowed_head_relationship",
            ),
        ),
        source=ProviderProvenance(
            provider=case.source_provider,
            checkpoint_path=_text(source["path"], "source_checkpoint.path"),
            checkpoint_sha256=source_sha256,
            archive_path=(
                "artifacts/orchestration/handoffs/sources/sha256/"
                f"{source_sha256}.json"
            ),
            expression_schema_id=_text(
                expression["schema_id"], "source_checkpoint.expression.schema_id"
            ),
            expression_schema_version=_text(
                expression["schema_version"],
                "source_checkpoint.expression.schema_version",
            ),
            receipt_references=_receipt_references(source),
        ),
        destination_provider=case.destination_provider,
        destination_checkpoint_path="artifacts/orchestration/orchestrator-state.json",
        plan=PlanIdentity(
            path=_text(plan["path"], "plan.path"),
            sha256=plan_sha256,
            contract_version=_text(plan["contract_version"], "plan.contract_version"),
        ),
        lifecycle=LifecycleState(
            logical_complexity=_text(
                lifecycle["logical_complexity"], "lifecycle.logical_complexity"
            ),
            route_intent=_text(lifecycle["route_intent"], "lifecycle.route_intent"),
            completed_phases=_strings(
                lifecycle["completed_phases"], "lifecycle.completed_phases"
            ),
            next_transition=_text(
                lifecycle["next_transition"], "lifecycle.next_transition"
            ),
            replay_policy=_text(lifecycle["replay_policy"], "lifecycle.replay_policy"),
        ),
        capabilities=CapabilityRequirements(
            vocabularies=_strings(
                capabilities["vocabularies"], "capabilities.vocabularies"
            ),
            required=_strings(capabilities["required"], "capabilities.required"),
        ),
        scheduler_context=SchedulerContext(kind="ordinary"),
        handoff_history=(history,),
    )


def projection_facts(envelope: HandoffEnvelope) -> PortableProjectionFacts:
    """Return the exact facts authorized for destination projection."""

    return PortableProjectionFacts(
        plan=envelope.plan,
        lifecycle=envelope.lifecycle,
        scheduler_context=envelope.scheduler_context,
        envelope_sha256=envelope.handoff_history[-1].envelope_sha256,
        history_entry_sha256=envelope.handoff_history[-1].entry_sha256,
    )


def scheduled_envelope(case: FixtureCase, kind: SchedulerKind) -> HandoffEnvelope:
    """Bind a TaskMaster fixture to its parallel or epic parent scheduler."""

    if kind not in ("parallel", "epic"):
        raise ValueError("scheduled fixture kind must be parallel or epic")
    envelope = build_envelope(case)
    required = tuple(
        (
            f"scheduler-context:{kind}-child"
            if capability == "scheduler-context:ordinary"
            else capability
        )
        for capability in envelope.capabilities.required
    ) + ("scheduler-return:portable_child_result-v1",)
    scheduler = SchedulerContext(
        kind=kind,
        run_id=f"{kind}-run-469",
        item_id="item-469",
        kickoff_or_manifest_path=f"artifacts/orchestration/{kind}-kickoff.json",
        kickoff_or_manifest_sha256="a" * 64,
        parent_checkpoint_path=f"artifacts/orchestration/{kind}-state.json",
        parent_checkpoint_sha256="b" * 64,
        cohort_or_wave="cohort-469" if kind == "parallel" else 1,
        scheduler_owner=f"{kind}_orchestrator",
        child_execution_owner="ordinary_orchestrator",
        return_contract="portable_child_result-v1",
    )
    return replace(
        envelope,
        lifecycle=replace(
            envelope.lifecycle,
            route_intent="prepared_child_to_ordinary_execution",
        ),
        capabilities=replace(envelope.capabilities, required=required),
        scheduler_context=scheduler,
    )


def bounded_result(envelope: HandoffEnvelope) -> dict[str, object]:
    """Return the result fields authorized by a scheduled child."""

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
        "child_checkpoint_sha256": "c" * 64,
        "result_sha256": "d" * 64,
    }
