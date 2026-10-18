"""Build immutable transport fixtures and fresh memory stores for task tests."""

from __future__ import annotations

import json
from contextlib import nullcontext
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.evidence_linking import evidence_changes
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import ParseLimits, canonical_json
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationPlan,
    PlannedWrite,
)
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.source_snapshots import (
    SnapshotExport,
    SnapshotImport,
    prepare_snapshot_export,
)
from drm_copilot_discovery.transport_manifest import bind_transport, transport_digest
from drm_copilot_discovery.validation import SnapshotValidation

from tests.discovery_runtime.draft_test_support import add_feature, draft_case
from tests.discovery_runtime.evidence_test_support import add_record, request_for
from tests.discovery_runtime.mutation_test_support import (
    capture,
    grants_for,
    mutation_case,
)
from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import PROFILE_PATH, MemoryStore
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from contextlib import AbstractContextManager

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.path_models import ResolvedPath
    from drm_copilot_discovery.source_snapshots import SnapshotProposal
    from drm_copilot_discovery.transport_manifest import TransportRoute


def transport_case(
    catalog: SchemaCatalog,
) -> tuple[MemoryStore, CapturedWorkspace, TransportRoute, tuple[MutationChange, ...]]:
    """Create a fresh truthful feature/question graph and exact export envelope."""
    store, baseline = draft_case(catalog)
    profile = as_object(json.loads(store.files[PROFILE_PATH]))
    as_object(profile["repository"])["revision"] = "a" * 40
    store.put(PROFILE_PATH, json.dumps(profile).encode())
    baseline = add_feature(store, catalog, "alpha")
    path = (
        baseline.snapshot.profile.artifacts["source_snapshots"]
        + "/export-alpha/manifest.json"
    )
    parent = path.rsplit("/", 1)[0]
    document = load_fixture("source-snapshot-manifest")
    document.update(
        id="export-alpha",
        source_repository={
            "id": baseline.snapshot.profile.repository.id,
            "revision": "a" * 40,
        },
        artifacts=[
            dict(
                artifact_kind=item.expected_kind,
                id=str(item.document["id"]),
                schema_version="2.0.0",
                path=item.path,
                sha256=baseline.snapshot.file(item.path).sha256,
                size=len(baseline.snapshot.file(item.path).content),
            )
            for item in baseline.snapshot.artifacts
            if item.document is not None
        ],
        payloads=[],
    )
    as_object(document["transport"]).update(
        artifact_count=len(baseline.snapshot.artifacts), payload_count=0
    )
    document["manifest_sha256"] = transport_digest(immutable(document))
    route = bind_transport(
        path, canonical_json(immutable(document)), catalog=catalog, limits=ParseLimits()
    )
    contents = {
        parent + "/" + item.path: item.content
        for item in baseline.snapshot.manifest.files
        if item.path != PROFILE_PATH
    }
    contents[path] = route.manifest.content
    changes = tuple(
        MutationChange(
            artifact_kind=member.grant.artifact_kind,
            artifact_id=member.grant.artifact_id,
            path=member.grant.path,
            content=contents[member.grant.path],
            expected_sha256=None,
        )
        for member in route.members
    )
    return store, baseline, route, changes


def unit_transport(catalog: SchemaCatalog) -> TransportRoute:
    """Bind small inert byte declarations for isolated envelope validation cases."""
    document = load_fixture("source-snapshot-manifest")
    document["artifacts"] = [
        dict(
            artifact_kind=kind,
            id=identifier,
            schema_version="2.0.0",
            path=path,
            sha256=sha256(b"{}").hexdigest(),
            size=2,
        )
        for kind, identifier, path in (
            ("feature-contract", "alpha", "contracts/alpha.json"),
            ("unspecified-behavior-collection", "questions", "questions.json"),
        )
    ]
    document["payloads"] = []
    as_object(document["transport"]).update(artifact_count=2, payload_count=0)
    document["manifest_sha256"] = transport_digest(immutable(document))
    return bind_transport(
        "docs/migration/discovery/source-snapshots/export-alpha/manifest.json",
        canonical_json(immutable(document)),
        catalog=catalog,
        limits=ParseLimits(),
    )


def changed_header(
    route: TransportRoute, updates: dict[str, object], *, digest: bool = True
) -> bytes:
    """Produce independent hostile envelopes without mutating the original route."""
    document = as_object(json.loads(route.manifest.content))
    document.update(updates)
    if digest:
        document["manifest_sha256"] = transport_digest(immutable(document))
    return canonical_json(immutable(document))


@pytest.fixture(scope="module")
def source_capture(mutation_catalog: SchemaCatalog) -> CapturedWorkspace:
    """Reuse only immutable captured source inputs; never share a mutable store."""
    return transport_case(mutation_catalog)[1]


def export_request() -> SnapshotExport:
    """Provide fixed caller attribution for deterministic projection assertions."""
    return SnapshotExport(
        export_id="release-alpha",
        artifacts=(("feature-contract", "alpha"),),
        exported_at="2026-01-01T00:00:00Z",
        exported_by=immutable(dict(kind="human", id="owner")),
    )


def evidence_capture(baseline: CapturedWorkspace, kind: str) -> CapturedWorkspace:
    """Attach fresh evidence and exact pinned objects for pure export-unit cases."""
    request = replace(request_for(baseline, kind=kind), artifact_id="alpha")
    result = baseline
    for change in evidence_changes(baseline, request):
        if change.artifact_kind != "evidence-payload":
            result = add_record(
                result, as_object(json.loads(change.content)), path=change.path
            )
    files = tuple(
        SnapshotFile(path=item.path, content=item.content, category="evidence")
        for item in request.payloads
    )
    identity = RepositoryIdentity(
        id=baseline.snapshot.profile.repository.id, revision="a" * 40
    )
    objects = tuple(
        RepositoryFile(repository=identity, path=item.path, content=item.content)
        for item in files
    )
    return replace(
        result,
        snapshot=replace(
            result.snapshot,
            manifest=replace(
                result.snapshot.manifest,
                files=(*result.snapshot.manifest.files, *files),
            ),
            checkout=identity,
            repository_files=objects,
        ),
    )


def import_case(
    catalog: SchemaCatalog,
    proposal: SnapshotProposal,
    *,
    custom: bool = False,
) -> tuple[MemoryStore, CapturedWorkspace, SnapshotImport]:
    """Capture a fresh two-client target plus one complete local staging directory."""
    document = profile_document()
    as_object(document["system"])["role"] = "modernization-target"
    as_object(document["repository"]).update(id="target", revision="b" * 40)
    document["repositories"] = [
        dict(
            id=proposal.route.source.id,
            role="legacy-source",
            revision=proposal.route.source.revision,
            snapshot_manifest=None,
            clients=[],
        )
    ]
    for client in cast("list[dict[str, object]]", document["clients"]):
        client["target_repository"] = "target"
    if custom:
        as_object(document["artifacts"])["source_snapshots"] = "docs/transport"
    store = MemoryStore()
    store.put(PROFILE_PATH, json.dumps(document).encode())
    origin = proposal.route.manifest.path.rsplit("/", 1)[0]
    for change in proposal.changes:
        store.put("docs/incoming/source" + change.path[len(origin) :], change.content)
    baseline = capture(store, catalog)
    request = SnapshotImport(
        manifest_path="docs/incoming/source/manifest.json",
        source=proposal.route.source,
        verified_at="2026-01-02T00:00:00Z",
        verified_by=immutable(dict(kind="human", id="importer")),
    )
    return store, baseline, request


@pytest.fixture(scope="module")
def target_capture(
    source_capture: CapturedWorkspace,
    mutation_catalog: SchemaCatalog,
) -> tuple[CapturedWorkspace, SnapshotImport]:
    """Reuse immutable staging inputs; every test owns its projected modifications."""
    proposal = prepare_snapshot_export(source_capture, export_request())
    _, baseline, request = import_case(mutation_catalog, proposal)
    return baseline, request


def with_files(
    baseline: CapturedWorkspace, files: tuple[SnapshotFile, ...]
) -> CapturedWorkspace:
    """Replace only immutable captured bytes for narrow projection preconditions."""
    return replace(
        baseline,
        snapshot=replace(
            baseline.snapshot, manifest=replace(baseline.snapshot.manifest, files=files)
        ),
    )


def export_fault(
    baseline: CapturedWorkspace, fault: str
) -> tuple[CapturedWorkspace, SnapshotExport]:
    """Construct fresh malformed selection/closure inputs without changing fixtures."""
    request = export_request()
    artifacts = baseline.snapshot.artifacts
    feature = next(
        item for item in artifacts if item.expected_kind == "feature-contract"
    )
    if fault in {"empty", "duplicate", "missing"}:
        selected = (
            ()
            if fault == "empty"
            else (
                request.artifacts * 2
                if fault == "duplicate"
                else (("feature-contract", "missing"),)
            )
        )
        request = replace(request, artifacts=selected)
    elif fault == "malformed":
        baseline = replace(
            baseline,
            snapshot=replace(
                baseline.snapshot,
                findings=(
                    Finding(
                        code="SCHEMA_INVALID",
                        message="bad",
                        artifact_path=feature.path,
                        next_action="Correct the malformed fixture.",
                    ),
                ),
            ),
        )
    else:
        selected_artifacts = tuple(
            (
                replace(item, origin_path="original.json")
                if item == feature and fault == "imported"
                else item
            )
            for item in artifacts
            if fault != "unresolved" or item == feature
        )
        baseline = replace(
            baseline, snapshot=replace(baseline.snapshot, artifacts=selected_artifacts)
        )
    return baseline, request


class RecordingPrimitives:
    """Record one isolated publication request without graph loading or native I/O."""

    def __init__(self) -> None:
        self.calls: list[tuple[ResolvedPath, bytes]] = []

    def guard(self) -> AbstractContextManager[None]:
        return nullcontext()

    def create_exclusive(self, target: ResolvedPath, content: bytes) -> None:
        self.calls.append((target, content))

    def replace_if_digest(
        self, target: ResolvedPath, content: bytes, *, expected_sha256: str
    ) -> None:
        raise AssertionError("An immutable transport must never request replacement")


def isolated_plan(catalog: SchemaCatalog) -> MutationPlan:
    """Build internal values for forwarding tests; never claim graph validation."""
    _, baseline = mutation_case(catalog)
    route = unit_transport(catalog)
    changes = tuple(
        MutationChange(
            artifact_kind=item.grant.artifact_kind,
            artifact_id=item.grant.artifact_id,
            path=item.grant.path,
            content=route.manifest.content if item.origin is None else b"{}",
            expected_sha256=None,
        )
        for item in route.members
    )
    policy = PathPolicy(
        baseline.snapshot.profile,
        workspace_root=baseline.workspace_root,
        metadata=baseline.inspect,
        transport=route,
    )
    return MutationPlan(
        baseline=baseline,
        writes=tuple(
            PlannedWrite(
                change=item,
                target=policy.resolve_write(item.path, grant=grant),
                skipped=False,
                transport=route,
            )
            for item, grant in zip(changes, grants_for(*changes), strict=True)
        ),
        grants=grants_for(*changes),
        prospective=baseline.snapshot,
        transport=route,
        validation=SnapshotValidation(
            mode="structural",
            findings=(),
            input_sha256=baseline.snapshot.sha256,
            validation_result="pass",
        ),
    )
