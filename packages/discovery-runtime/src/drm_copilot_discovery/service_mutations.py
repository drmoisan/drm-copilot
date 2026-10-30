"""Adapt fixed creation, replacement and transport requests to existing planners."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.agent_output import REPORT_KINDS
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.mutation_plan import MutationChange
from drm_copilot_discovery.operations import OperationContext, OperationFailure

if TYPE_CHECKING:
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.service_contracts import DiscoveryResult


def _authored(context: OperationContext) -> CapturedWorkspace:
    """Return a pure proposal view excluding derived report descriptors.

    context (OperationContext) retains the complete captured baseline. Only this
    index/proposal view omits REPORT_KINDS, matching the public validator's
    authored identity boundary. All bytes/pins remain; actual planning and CAS
    use the complete original context. Missing capture raises OperationFailure.
    """
    if context.baseline is None:
        raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
    context.budget.work(len(context.snapshot.artifacts))
    # Derived outputs cannot supply authored graph identities to accepted indexers.
    artifacts = tuple(
        item
        for item in context.snapshot.artifacts
        if item.expected_kind not in REPORT_KINDS
    )
    return replace(
        context.baseline, snapshot=replace(context.snapshot, artifacts=artifacts)
    )


def _update(context: OperationContext) -> tuple[MutationChange, ...]:
    """Return one exact replacement from context, checking explicit approval metadata.

    context (OperationContext) contains the captured replacement and expected
    original digest. Existing schema/prospective validators own semantics.
    Approval merely checks supplied fields; no timestamp/evidence is fabricated.
    Invalid identity/approval raises OperationFailure before any write.
    """
    kind, path = context.text("artifact_kind"), context.text("artifact_path")
    source = context.text("input_path")
    document = context.document(source)
    identifier = document.get("id")
    if type(identifier) is not str or document.get("artifact_kind") != kind:
        raise OperationFailure("SERVICE_IDENTITY")
    if "artifact_id" in context.inputs and context.text("artifact_id") != identifier:
        raise OperationFailure("SERVICE_IDENTITY")
    if context.text("update_action") == "approve-decision":
        approval = document.get("approval")
        if (
            kind != "product-decision"
            or document.get("status") != "approved"
            or type(approval) is not JsonObject
        ):
            raise OperationFailure("SERVICE_APPROVAL")
        if (
            approval.get("owner") != context.text("approval_owner")
            or approval.get("evidence_refs") != context.inputs["approval_evidence_refs"]
        ):
            raise OperationFailure("SERVICE_APPROVAL")
    return (
        MutationChange(
            artifact_kind=kind,
            artifact_id=identifier,
            path=path,
            content=context.read(source),
            expected_sha256=cast("str | None", context.inputs["expected_sha256"]),
        ),
    )


def _transport(context: OperationContext) -> DiscoveryResult:
    """Prepare and publish one root-only captured transport; return real results.

    context supplies exact selectors and trusted attribution. Export resolves
    unique indexed identities; import validates its captured manifest and source.
    Existing transport planners own member/hash rules. No network or arbitrary
    sibling reads occur. Selection, transport and mutation errors propagate.
    """
    from drm_copilot_discovery.references import index_references
    from drm_copilot_discovery.source_snapshots import (
        SnapshotExport,
        SnapshotImport,
        prepare_snapshot_export,
        prepare_snapshot_import,
    )
    from drm_copilot_discovery.transport_manifest import bind_transport

    if context.baseline is None:
        raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
    if context.request.operation == "snapshot-export":
        baseline = _authored(context)
        records = index_references(baseline.snapshot).records
        selected, paths = context.strings("selected_ids"), context.strings("paths")
        context.budget.work(len(records) * (len(selected) + len(paths) + 1))
        by_id: dict[str, list[tuple[str, str]]] = {}
        # Reserve identifier/path characters before hashing the bounded record index.
        for record in records:
            context.budget.work(len(record.document) + len(record.path))
            identifier = record.id
            context.budget.work(len(identifier))
            by_id.setdefault(identifier, []).append((record.kind, record.path))
        context.budget.work(
            sum(len(path) for path in paths) + sum(len(value) for value in selected)
        )
        allowed = set(paths)
        resolved: list[tuple[str, str]] = []
        # Every requested identity must resolve once within the optional exact paths.
        for identifier in selected:
            candidates = tuple(
                pair
                for pair in by_id.get(identifier, ())
                if not allowed or pair[1] in allowed
            )
            if len(candidates) != 1:
                raise OperationFailure("SERVICE_SELECTION")
            resolved.append((candidates[0][0], identifier))
        proposal = prepare_snapshot_export(
            baseline,
            SnapshotExport(
                export_id=context.request.id,
                artifacts=tuple(resolved),
                exported_at=context.timestamp,
                exported_by=context.author(),
            ),
        )
    else:
        path = context.text("manifest_path")
        try:
            route = bind_transport(
                path,
                context.read(path),
                catalog=context.snapshot.catalog,
                limits=context.limits,
            )
        except ValueError as error:
            raise OperationFailure("SERVICE_TRANSPORT") from error
        proposal = prepare_snapshot_import(
            context.baseline,
            SnapshotImport(
                manifest_path=path,
                source=route.source,
                verified_at=context.timestamp,
                verified_by=context.author(),
            ),
        )
    return context.publish(context.plan(proposal.changes, transport=proposal.route))


def mutate(context: OperationContext) -> DiscoveryResult:
    """Dispatch only the approved creation/replacement/transport family.

    context is an authenticated OperationContext. Returns DiscoveryResult from
    accepted planners and guarded commit; no request-selected callbacks exist.
    Unknown operations and invalid inputs raise before publication.
    """
    from drm_copilot_discovery.draft_contracts import ContractDraft, contract_changes
    from drm_copilot_discovery.draft_scenarios import ScenarioDraft, scenario_changes
    from drm_copilot_discovery.evidence_linking import EvidenceLink, evidence_changes
    from drm_copilot_discovery.extension_results import merge_extension_inventory

    operation = context.request.operation
    if operation in ("init", "configure", "migrate"):
        from drm_copilot_discovery.service_bootstrap import bootstrap

        return bootstrap(context)
    if operation in ("snapshot-export", "snapshot-import"):
        return _transport(context)
    if context.baseline is None:
        raise OperationFailure("SERVICE_CAPTURE", exit_code=3)
    if operation == "new-contract":
        fields = (
            context.document(context.text("input_path"))
            if "input_path" in context.inputs
            else JsonObject(())
        )
        changes = contract_changes(
            context.baseline,
            ContractDraft(
                feature_id=context.text("feature_id"),
                name=context.text("name"),
                capability_group=context.text("capability_group", "unclassified"),
                fields=fields,
            ),
        )
    elif operation == "new-scenario":
        changes = scenario_changes(
            context.baseline,
            ScenarioDraft(
                scenario_id=context.text("scenario_id"),
                feature_ids=context.strings("feature_ids"),
                fields=context.document(context.text("input_path")),
            ),
        )
    elif operation == "update-artifact":
        changes = _update(context)
    elif operation == "link-evidence":
        changes = evidence_changes(
            _authored(context),
            EvidenceLink(
                artifact_kind=context.text("artifact_kind"),
                artifact_id=context.text("artifact_id"),
                expected_sha256=context.text("expected_sha256"),
                record=context.document(context.text("evidence_path")),
            ),
        )
    elif operation == "import-inventory":
        result = merge_extension_inventory(
            context.snapshot,
            timestamp=context.timestamp,
            author_or_agent=context.author(),
            manifest_paths=(context.text("manifest_path"),),
        )
        context.budget.check(result.document)
        identifier = cast("str", result.document["id"])
        changes = (
            context.change(
                "inventory-snapshot",
                identifier,
                context.snapshot.profile.artifacts["inventory"]
                + "/"
                + identifier
                + ".json",
                canonical_json(result.document),
            ),
        )
        if not context.request.write:
            from drm_copilot_discovery.operations import operation_problem

            diagnostics = cast("tuple[JsonObject, ...]", result.document["diagnostics"])
            blocked = any(item["blocking"] for item in diagnostics)
            return context.result(
                artifacts=context.projected(changes),
                findings=(operation_problem("INVENTORY_BLOCKED"),) if blocked else (),
            )
    else:
        raise OperationFailure("SERVICE_OPERATION")
    return context.publish(context.plan(changes))
