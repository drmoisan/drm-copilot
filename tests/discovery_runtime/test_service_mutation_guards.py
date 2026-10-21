"""Close MG1–MG15 mutation boundaries using captured bytes and real planners."""

from __future__ import annotations

import json
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import service_mutations
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import diagnostic, row
from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.extension_inputs import (
    extension_input_digest,
    extension_manifest_digest,
)
from drm_copilot_discovery.extension_results import merge_extension_inventory
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.mutation_plan import MutationError
from drm_copilot_discovery.operations import OperationContext, OperationFailure
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.source_snapshots import (
    SnapshotExport,
    prepare_snapshot_export,
)

from tests.discovery_runtime.test_decision_rules import decision
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.discovery_runtime.test_service_boundaries import context as context
from tests.discovery_runtime.test_service_publication import seed_contract

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationChange
    from drm_copilot_discovery.service_contracts import DiscoveryResult, Operation

    from tests.discovery_runtime.test_service import MemoryService


def configured_context(
    base: OperationContext,
    operation: Operation,
    inputs: dict[str, object],
    *,
    write: bool = False,
) -> OperationContext:
    """Capture memory inputs for one real operation; return OperationContext.

    base (OperationContext) supplies trusted memory ports; operation (Operation)
    and inputs (dict[str, object]) select the request, write (bool) publication.
    Capture/request errors propagate. No external I/O or publication occurs.
    """
    io = cast("MemoryService", base.io)
    captured = capture_workspace(
        workspace_root=io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=io.disk.store.metadata,
        read_bytes=io.disk.store.read,
        catalog=io.initialization.catalog,
        repository=io.repository,
    )
    return OperationContext(
        replace(
            base.request,
            operation=operation,
            inputs=bounded_object(inputs, limits=base.limits),
            write=write,
        ),
        io=io,
        authority=base.authority,
        runtime=base.runtime,
        baseline=captured,
        reads=base.reads,
        timestamp=base.timestamp,
        analyzer_registry=base.analyzer_registry,
    )


def approval_context(
    base: OperationContext, fault: str = "matching"
) -> tuple[OperationContext, bytes]:
    """Capture an explicit decision proposal without claiming graph approval.

    base (OperationContext) supplies isolated memory ports; fault (str) selects
    pending/owner/evidence disagreement or matching metadata. Return
    tuple[OperationContext, bytes] containing the request and exact proposal.
    Fixture/request errors propagate; only memory setup is changed.
    """
    io = cast("MemoryService", base.io)
    captured = configured_context(base, "profile", {})
    # Exercise the proposal gate without treating authored approval as graph proof.
    document = decision(
        captured.snapshot.profile,
        status="pending" if fault == "pending" else "approved",
    ).document
    assert document is not None
    content = canonical_json(document)
    io.disk.store.put("proposals/original.json", content)
    io.disk.store.put("proposals/update.json", content)
    proof = row(artifact_kind="evidence-reference", id="capture")
    inputs: dict[str, object] = {
        "artifact_kind": "product-decision",
        "artifact_id": "decision",
        "artifact_path": "proposals/original.json",
        "input_path": "proposals/update.json",
        "expected_sha256": sha256(content).hexdigest(),
        "update_action": "approve-decision",
        "approval_owner": "other" if fault == "owner" else "owner-example",
        "approval_evidence_refs": (
            (
                row(artifact_kind="evidence-reference", id="other")
                if fault == "evidence"
                else proof
            ),
        ),
    }
    return configured_context(base, "update-artifact", inputs), content


def extension_context(base: OperationContext, *, blocked: bool) -> OperationContext:
    """Capture a real inert extension result and complete service graph in memory.

    base (OperationContext) supplies trusted ports; blocked (bool) marks the
    external diagnostic. Return OperationContext using public emitter/digests.
    Invalid setup propagates. Only the isolated memory profile/bundle are changed.
    """
    io = cast("MemoryService", base.io)
    manifest_path = "docs/migration/discovery/inventory/external.json"
    member_path = "docs/migration/discovery/inventory/external-member.json"
    # Make the bundle an explicit configured input before deriving its source pin.
    profile = json.loads(io.disk.store.files[DEFAULT_PROFILE])
    profile["analyzers"]["extension_result_manifests"] = [manifest_path]
    io.disk.store.put(DEFAULT_PROFILE, json.dumps(profile).encode("utf-8"))
    source = configured_context(base, "profile", {})
    capture = capture_snapshot(source.snapshot)
    adapter = row(id="external-review", version="1.0")
    # Use the accepted emitter so normalization starts from a real inventory shape.
    emitted = inventory_result(
        capture,
        (Analysis(),),
        analyzer_ids=(),
        extension_adapters=(adapter,),
        timestamp=source.timestamp,
        author_or_agent=source.author(),
        catalog=source.snapshot.catalog,
    )
    member = dict(emitted.document.members)
    member["tool"] = adapter
    content = canonical_json(JsonObject(tuple(member.items())))
    # Bind the external diagnostic and exact member bytes to the captured source.
    problem = diagnostic(
        "external-review",
        None,
        "External review state.",
        analyzer="external-review",
        blocking=blocked,
    )
    manifest = row(
        **{"$schema": "urn:drm-copilot:discovery:2.0.0:extension-result-manifest"},
        schema_version="2.0.0",
        artifact_kind="extension-result-manifest",
        id="external-review",
        adapter=adapter,
        repository=row(
            id=capture.profile.repository.id,
            revision=capture.profile.repository.revision,
        ),
        input_manifest_sha256=extension_input_digest(capture),
        source_inputs=(),
        result_files=(
            row(
                artifact_kind="inventory-snapshot",
                id=emitted.document["id"],
                schema_version="2.0.0",
                path=member_path,
                sha256=sha256(content).hexdigest(),
                size=len(content),
            ),
        ),
        manifest_sha256="0" * 64,
        generated_at=source.timestamp,
        generated_by=source.author(),
        diagnostics=(problem,),
        extensions=row(),
    )
    fields = dict(manifest.members)
    fields["manifest_sha256"] = extension_manifest_digest(manifest)
    io.disk.store.put(member_path, content)
    io.disk.store.put(manifest_path, canonical_json(JsonObject(tuple(fields.items()))))
    return configured_context(
        base, "import-inventory", {"manifest_path": manifest_path}
    )


@pytest.mark.parametrize(
    "boundary", ["authored", "mutation", "transport"], ids=["MG1", "MG7", "MG8"]
)
def test_missing_capture_cannot_authorize_mutation(
    context: OperationContext, service_io: MemoryService, boundary: str
) -> None:
    """Refuse absent capture at the selected boundary (str).

    context (OperationContext) has no baseline; service_io (MemoryService) records
    memory effects. Return None after typed failure and unchanged-byte assertions.
    No external effects occur.
    """
    before = dict(service_io.disk.store.files)
    # Each entry boundary must independently reject missing capture authority.
    if boundary == "authored":
        handler = cast(
            "Callable[[OperationContext], CapturedWorkspace]",
            vars(service_mutations)["_authored"],
        )
    elif boundary == "transport":
        handler = cast(
            "Callable[[OperationContext], DiscoveryResult]",
            vars(service_mutations)["_transport"],
        )
    else:
        handler = service_mutations.mutate
    with pytest.raises(OperationFailure, match="SERVICE_CAPTURE") as refused:
        handler(context)
    assert refused.value.exit_code == 3
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_explicit_identity_and_cas_are_independent_preconditions(
    context: OperationContext, service_io: MemoryService
) -> None:
    """MG2: reject wrong identity then stale CAS using real captured context.

    context (OperationContext) and service_io (MemoryService) are isolated ports.
    Return None; expected typed refusals preserve every byte with no writer call.
    """
    path = seed_contract(service_io)
    original = service_io.disk.store.files[path]
    document = json.loads(original)
    document["name"] = "Proposed replacement"
    service_io.disk.store.put(
        "proposals/update.json", json.dumps(document).encode("utf-8")
    )
    inputs: dict[str, object] = dict(
        artifact_kind="feature-contract",
        artifact_id="other",
        artifact_path=path,
        input_path="proposals/update.json",
        expected_sha256=sha256(original).hexdigest(),
        update_action="replace",
    )
    current = configured_context(context, "update-artifact", inputs)
    before = dict(service_io.disk.store.files)
    with pytest.raises(OperationFailure, match="SERVICE_IDENTITY"):
        service_mutations.mutate(current)
    inputs.update(artifact_id="feature", expected_sha256="0" * 64)
    current = configured_context(context, "update-artifact", inputs)
    with pytest.raises(MutationError, match="MUTATION_PRECONDITION"):
        service_mutations.mutate(current)
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


@pytest.mark.parametrize(
    "fault", ["pending", "owner", "evidence"], ids=["MG3", "MG4", "MG5"]
)
def test_approval_requires_actual_status_owner_and_evidence(
    context: OperationContext, service_io: MemoryService, fault: str
) -> None:
    """Refuse pending, owner or evidence fault (str) in an approval request.

    context (OperationContext) supplies ports; service_io (MemoryService) records
    effects. Return None after SERVICE_APPROVAL and unchanged-byte assertions.
    Only setup changes memory; no external I/O or approval authority is created.
    """
    current, _ = approval_context(context, fault)
    before = dict(service_io.disk.store.files)
    with pytest.raises(OperationFailure, match="SERVICE_APPROVAL"):
        service_mutations.mutate(current)
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_matching_approval_preserves_exact_bounded_proposal(
    context: OperationContext, service_io: MemoryService
) -> None:
    """MG6: preserve explicit proposal fields without claiming validated approval.

    context (OperationContext)/service_io (MemoryService) supply memory only.
    Return None after exact identity, owner, proof, payload and CAS assertions.
    """
    current, content = approval_context(context)
    before = dict(service_io.disk.store.files)
    update = cast(
        "Callable[[OperationContext], tuple[MutationChange, ...]]",
        vars(service_mutations)["_update"],
    )
    changes = update(current)
    assert len(changes) == 1
    change = changes[0]
    assert (change.artifact_kind, change.artifact_id, change.path) == (
        "product-decision",
        "decision",
        "proposals/original.json",
    )
    assert (
        change.content == content
        and change.expected_sha256 == sha256(content).hexdigest()
    )
    proposal = current.document("proposals/update.json")
    approval = cast("JsonObject", proposal["approval"])
    assert approval["owner"] == current.inputs["approval_owner"]
    assert approval["evidence_refs"] == current.inputs["approval_evidence_refs"]
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


@pytest.mark.parametrize("selection", ["unknown", "ambiguous"], ids=["MG9", "MG10"])
def test_export_identity_must_resolve_exactly_once(
    context: OperationContext, service_io: MemoryService, selection: str
) -> None:
    """Reject unknown or ambiguous selection (str) without exporting bytes.

    context (OperationContext) supplies ports; service_io (MemoryService) holds
    captured inputs. Return None after SERVICE_SELECTION; no writer call or
    arbitrary identity choice is permitted. Only setup changes memory.
    """
    path = seed_contract(service_io)
    # Ambiguity requires two actual captured documents with the same identity.
    if selection == "ambiguous":
        service_io.disk.store.put(
            path.replace("feature.json", "duplicate.json"),
            service_io.disk.store.files[path],
        )
    current = configured_context(
        context,
        "snapshot-export",
        {"selected_ids": ["feature" if selection == "ambiguous" else "unknown"]},
    )
    before = dict(service_io.disk.store.files)
    with pytest.raises(OperationFailure, match="SERVICE_SELECTION"):
        service_mutations.mutate(current)
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_captured_snapshot_import_uses_real_planner_and_guarded_writer(
    context: OperationContext, service_io: MemoryService
) -> None:
    """MG11: import a captured bundle through accepted planning and real effects.

    context (OperationContext)/service_io (MemoryService) supply memory ports.
    Return None; assertions bind source pin, manifest, member bytes and originals.
    """
    seed_contract(service_io)
    source = configured_context(context, "profile", {})
    assert source.baseline is not None
    exported = prepare_snapshot_export(
        source.baseline,
        SnapshotExport(
            export_id="incoming",
            artifacts=(("feature-contract", "feature"),),
            exported_at=source.timestamp,
            exported_by=source.author(),
        ),
    )
    prefix = exported.route.manifest.path.rsplit("/", 1)[0]
    # Stage every real member under the configured documentation root unchanged.
    for change in exported.changes:
        service_io.disk.store.put(
            "proposals/incoming" + change.path[len(prefix) :], change.content
        )
    current = configured_context(
        context,
        "snapshot-import",
        {"manifest_path": "proposals/incoming/manifest.json"},
    )
    before = dict(service_io.disk.store.files)
    result = service_mutations.mutate(current)
    assert result.ok and service_io.writer_calls == 1, result.findings
    assert result.input_manifest == current.snapshot.manifest
    # Locate the published manifest to verify its retained source and transport.
    manifest = next(
        item for item in result.artifacts if item.kind == "source-snapshot-manifest"
    )
    document = json.loads(service_io.disk.store.files[manifest.path])
    assert document["source_repository"] == {
        "id": exported.route.source.id,
        "revision": exported.route.source.revision,
    }
    assert document["transport"]["verification_status"] == "verified"
    # Each actual row must match written bytes; copied members retain their originals.
    for item in result.artifacts:
        assert item.status == "created"
        assert sha256(service_io.disk.store.files[item.path]).hexdigest() == item.sha256
    assert before.items() <= service_io.disk.store.files.items()


@pytest.mark.parametrize("blocked", [False, True], ids=["MG12", "MG13"])
def test_extension_preview_retains_normalized_bytes_and_blockers(
    context: OperationContext, service_io: MemoryService, blocked: bool
) -> None:
    """Preview an extension with blocked (bool) controlling its diagnostic.

    context (OperationContext) supplies ports; service_io (MemoryService) records
    effects. Return None after exact normalized-byte, source and diagnostic
    assertions; neither preview invokes the writer or changes files.
    """
    current = extension_context(context, blocked=blocked)
    expected = merge_extension_inventory(
        current.snapshot, timestamp=current.timestamp, author_or_agent=current.author()
    )
    before = dict(service_io.disk.store.files)
    result = service_mutations.mutate(current)
    assert result.exit_code == (1 if blocked else 0) and result.ok is not blocked
    # Preserve the external blocker exactly instead of treating preview as success.
    assert tuple(item.code for item in result.findings) == (
        ("INVENTORY_BLOCKED",) if blocked else ()
    )
    assert len(result.artifacts) == 1 and result.artifacts[0].status == "planned"
    assert result.artifacts[0].content == canonical_json(expected.document).decode(
        "utf-8"
    )
    assert expected.document["repository"] == current.snapshot.profile.repository.id
    assert expected.document["revision"] == current.snapshot.profile.repository.revision
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_extension_write_publishes_real_normalized_inventory(
    context: OperationContext, service_io: MemoryService
) -> None:
    """MG14: publish actual normalized extension bytes through one guarded plan.

    context (OperationContext)/service_io (MemoryService) are isolated memory ports.
    Return None after real file/digest/provenance assertions; no external I/O occurs.
    """
    current = extension_context(context, blocked=False)
    current.request = replace(current.request, write=True)
    expected = merge_extension_inventory(
        current.snapshot, timestamp=current.timestamp, author_or_agent=current.author()
    )
    before = dict(service_io.disk.store.files)
    result = service_mutations.mutate(current)
    assert result.ok and service_io.writer_calls == 1, result.findings
    assert len(result.artifacts) == 1
    artifact = result.artifacts[0]
    assert artifact.kind == "inventory-snapshot" and artifact.status == "created"
    content = canonical_json(expected.document)
    assert service_io.disk.store.files[artifact.path] == content
    assert artifact.sha256 == sha256(content).hexdigest()
    assert before.items() <= service_io.disk.store.files.items()


def test_mutation_dispatch_refuses_another_valid_operation_family(
    context: OperationContext, service_io: MemoryService
) -> None:
    """MG15: refuse profile dispatch from configured context without effects.

    context (OperationContext)/service_io (MemoryService) are memory ports. Return
    None after SERVICE_OPERATION; no plan, writer call or byte change is allowed.
    """
    current = configured_context(context, "profile", {})
    before = dict(service_io.disk.store.files)
    with pytest.raises(OperationFailure, match="SERVICE_OPERATION"):
        service_mutations.mutate(current)
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before
