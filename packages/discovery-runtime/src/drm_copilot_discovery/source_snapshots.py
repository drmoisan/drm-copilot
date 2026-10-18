"""Compose immutable local source transport with the shared mutation boundary.

All source bytes come from the supplied complete capture. No function discovers
sibling repositories, fetches revisions or grants native access. Export/import
validate declarations and exact bytes; they never change claim or approval state.
"""

from __future__ import annotations

from dataclasses import dataclass
from hashlib import sha256
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.evidence_rules import assess_evidence
from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
from drm_copilot_discovery.mutation_io import commit_mutation
from drm_copilot_discovery.mutation_plan import (
    MutationChange,
    MutationError,
    plan_mutation,
)
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryIdentity, full_revision
from drm_copilot_discovery.revision_rules import RevisionInputs
from drm_copilot_discovery.snapshot import repository_pins
from drm_copilot_discovery.transport_manifest import bind_transport, transport_digest

if TYPE_CHECKING:
    from drm_copilot_discovery.agent_output import InvocationContext
    from drm_copilot_discovery.mutation_io import MutationResult, MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace, MutationPlan
    from drm_copilot_discovery.path_models import WriteGrant
    from drm_copilot_discovery.references import ArtifactRecord, ReferenceIndex
    from drm_copilot_discovery.transport_manifest import TransportRoute


@dataclass(frozen=True, kw_only=True)
class SnapshotExport:
    """Carry immutable selection and attribution into pure export planning.

    Callers provide distinct kind/ID pairs and an export identity. Projection
    validates them against the capture; this value grants no access or I/O.
    """

    export_id: str
    artifacts: tuple[tuple[str, str], ...]
    exported_at: str
    exported_by: JsonObject


@dataclass(frozen=True, kw_only=True)
class SnapshotImport:
    """Carry a captured bundle path, expected source pin and local attribution.

    Import planning compares these values with configured sources and captured
    bytes. Construction neither reads a repository nor establishes trust.
    """

    manifest_path: str
    source: RepositoryIdentity
    verified_at: str
    verified_by: JsonObject


@dataclass(frozen=True, kw_only=True)
class SnapshotProposal:
    """Pair a checked transport envelope with exact proposed immutable changes.

    Pass this pure projection through shared planning with external grants before
    publication. Its members include the manifest; it grants no native authority.
    """

    route: TransportRoute
    changes: tuple[MutationChange, ...]


def _closure(
    baseline: CapturedWorkspace, selections: tuple[tuple[str, str], ...]
) -> tuple[ReferenceIndex, tuple[ArtifactRecord, ...]]:
    """Return the index and whole-container closure for captured kind/ID selections.

    The capture is unchanged. MutationError identifies ambiguous, foreign,
    malformed or unresolved selections before any proposal is published.
    """
    if not selections or len(set(selections)) != len(selections):
        raise MutationError("SNAPSHOT_SELECTION", "Select distinct nonempty artifacts")
    index = index_references(baseline.snapshot)
    pending: list[ArtifactRecord] = []
    # Resolve each explicit selection before extending it through graph dependencies.
    for kind, identifier in selections:
        matches = index.candidates(
            kind, identifier, repository=baseline.snapshot.profile.repository.id
        )
        if len(matches) != 1:
            raise MutationError(
                "SNAPSHOT_SELECTION", "Select one captured source artifact"
            )
        pending.append(matches[0])
    selected: dict[str, ArtifactRecord] = {}
    # Visit each physical container once so cycles cannot duplicate exported files.
    while pending:
        record = pending.pop()
        artifact = record.artifact
        if artifact.path in selected:
            continue
        if (
            artifact.origin_path is not None
            or artifact.repository.id != baseline.snapshot.profile.repository.id
        ):
            raise MutationError(
                "SNAPSHOT_SOURCE", "Export only this repository's local artifacts"
            )
        # Selected malformed files remain blockers even if their IDs were indexed.
        findings = tuple(
            item
            for item in baseline.snapshot.findings
            if item.artifact_path == artifact.path
        )
        if findings:
            raise MutationError(
                "SNAPSHOT_INPUT",
                "Selected source artifact is malformed",
                findings=findings,
            )
        # A collection is copied intact, so every member's links join the closure.
        selected[artifact.path] = next(
            item
            for item in index.records
            if item.artifact.path == artifact.path and not item.pointer
        )
        # Every reference in a copied container must remain locally resolvable.
        for link in index.links:
            if link.source.artifact.path == artifact.path:
                if link.target is None:
                    raise MutationError(
                        "SNAPSHOT_REFERENCE",
                        "Source dependency is unresolved",
                        findings=link.findings,
                    )
                pending.append(link.target)
    return index, tuple(selected[path] for path in sorted(selected))


def _payloads(
    baseline: CapturedWorkspace, index: ReferenceIndex, paths: set[str]
) -> dict[str, bytes]:
    """Map selected artifact paths to exact locally verified evidence payload bytes.

    The supplied index and capture remain unchanged. MutationError rejects
    unverified evidence, missing captured objects or conflicting payload bytes.
    """
    inputs = RevisionInputs(baseline.snapshot)
    payloads: dict[str, bytes] = {}
    # Export evidence only after the shared rules establish its captured local proof.
    for record in index.records:
        if record.artifact.path not in paths or record.kind != "evidence-reference":
            continue
        assessment = assess_evidence(inputs, record)
        if not assessment.locally_verified:
            raise MutationError(
                "SNAPSHOT_EVIDENCE",
                "Export requires locally verified evidence",
                findings=assessment.findings,
            )
        document = record.document
        locations = {cast("str", document["path"])}
        runtime = document.get("runtime_artifact")
        if isinstance(runtime, JsonObject):
            locations.add(cast("str", runtime["path"]))
        # Runtime evidence may name a separate capture; preserve both exact payloads.
        for path in sorted(locations):
            content = inputs.content(
                record,
                repository=cast("str", document["repository"]),
                revision=cast("str | None", document.get("revision")),
                path=path,
                immutable=document.get("evidence_type") in {"source", "test"},
            )
            if content is None or (path in payloads and payloads[path] != content):
                raise MutationError(
                    "SNAPSHOT_PAYLOAD",
                    "Captured payload bytes are missing or conflicting",
                )
            payloads[path] = content
    return payloads


def _proposal(
    baseline: CapturedWorkspace, route: TransportRoute, contents: dict[str, bytes]
) -> SnapshotProposal:
    """Return exact route changes using original-path contents and captured CAS.

    No inputs are mutated. MutationError rejects different destination bytes;
    route validation rejects any supplied member identity or checksum mismatch.
    """
    files = {item.path: item for item in baseline.snapshot.manifest.files}
    changes: list[MutationChange] = []
    # Preserve original CAS bytes and reject replacement before constructing changes.
    for member in route.members:
        content = (
            route.manifest.content if member.origin is None else contents[member.origin]
        )
        route.check(member.grant, content)
        prior = files.get(member.grant.path)
        if prior is not None and prior.content != content:
            raise MutationError(
                "SNAPSHOT_CONFLICT", "Immutable destination bytes already differ"
            )
        changes.append(
            MutationChange(
                artifact_kind=member.grant.artifact_kind,
                artifact_id=member.grant.artifact_id,
                path=member.grant.path,
                content=content,
                expected_sha256=prior.sha256 if prior else None,
            )
        )
    return SnapshotProposal(route=route, changes=tuple(changes))


def prepare_snapshot_export(
    baseline: CapturedWorkspace, request: SnapshotExport
) -> SnapshotProposal:
    """Project a deterministic source export and complete local dependency closure.

    Source/test evidence requires accepted captured Git objects. Artifact and
    payload bytes are copied unchanged. Complete prospective graph validation is
    performed by plan_snapshot_export; this pure projection performs no writes.
    """
    snapshot = baseline.snapshot
    if snapshot.profile.system.role not in {"legacy-source", "combined"}:
        raise MutationError("SNAPSHOT_ROLE", "Only a configured source role can export")
    revision = full_revision(snapshot.profile.repository.revision or "")
    index, records = _closure(baseline, request.artifacts)
    contents = _payloads(baseline, index, {item.artifact.path for item in records})
    # Stable ordering binds the same selected payload bytes to one canonical digest.
    payload_rows = tuple(
        JsonObject(
            (
                ("path", path),
                ("sha256", sha256(content).hexdigest()),
                ("size", len(content)),
            )
        )
        for path, content in sorted(contents.items())
    )
    rows: list[JsonObject] = []
    # Preserve whole artifact bytes and reject overlap with an evidence payload path.
    for record in records:
        file = snapshot.file(record.artifact.path)
        if file.path in contents:
            raise MutationError(
                "SNAPSHOT_PAYLOAD", "One path cannot be artifact and payload"
            )
        contents[file.path] = file.content
        rows.append(
            JsonObject(
                (
                    ("artifact_kind", record.kind),
                    ("id", record.id),
                    ("schema_version", "2.0.0"),
                    ("path", file.path),
                    ("sha256", file.sha256),
                    ("size", len(file.content)),
                )
            )
        )
    # An export declares pending verification; only a later local import verifies it.
    fields: dict[str, JsonValue] = {
        "$schema": "urn:drm-copilot:discovery:2.0.0:source-snapshot-manifest",
        "schema_version": "2.0.0",
        "artifact_kind": "source-snapshot-manifest",
        "id": request.export_id,
        "source_repository": JsonObject(
            (("id", snapshot.profile.repository.id), ("revision", revision))
        ),
        "schema_versions": ("2.0.0",),
        "tool": JsonObject((("id", "drm-copilot-discovery"), ("version", "2.0.0"))),
        "artifacts": tuple(rows),
        "payloads": payload_rows,
        "transport": JsonObject(
            (
                ("method", "local-files"),
                ("exported_at", request.exported_at),
                ("exported_by", request.exported_by),
                ("verification_status", "pending"),
                ("verified_at", None),
                ("verified_by", None),
                ("artifact_count", len(rows)),
                ("payload_count", len(payload_rows)),
            )
        ),
        "extensions": JsonObject(()),
    }
    fields["manifest_sha256"] = transport_digest(JsonObject(tuple(fields.items())))
    route = bind_transport(
        snapshot.profile.artifacts["source_snapshots"]
        + "/"
        + request.export_id
        + "/manifest.json",
        canonical_json(JsonObject(tuple(fields.items()))),
        catalog=snapshot.catalog,
        limits=snapshot.profile.limits.parse_limits(),
    )
    return _proposal(baseline, route, contents)


def _captured_transport(baseline: CapturedWorkspace, path: str) -> TransportRoute:
    """Bind one complete local bundle from captured files, with no fresh reads."""
    snapshot = baseline.snapshot
    PathPolicy(
        snapshot.profile,
        workspace_root=baseline.workspace_root,
        metadata=baseline.inspect,
    ).resolve_read(path)
    route = bind_transport(
        path,
        snapshot.file(path).content,
        catalog=snapshot.catalog,
        limits=snapshot.profile.limits.parse_limits(),
    )
    parent = path.rsplit("/", 1)[0] + "/"
    # Include every captured file beneath this bundle, so extras cannot be ignored.
    route.check_files(
        tuple(item for item in snapshot.manifest.files if item.path.startswith(parent))
    )
    return route


def prepare_snapshot_import(
    baseline: CapturedWorkspace, request: SnapshotImport
) -> SnapshotProposal:
    """Verify an already captured local transport against configured source pins.

    Inputs may be staged in a configured readable documentation directory. They
    remain in complete-input freshness checks. Identical existing manifests keep
    their original attribution; different identities or bytes never overwrite.
    """
    snapshot = baseline.snapshot
    if snapshot.profile.system.role not in {"modernization-target", "combined"}:
        raise MutationError("SNAPSHOT_ROLE", "Only a target role can import")
    incoming = _captured_transport(baseline, request.manifest_path)
    sources, _ = repository_pins(snapshot.profile)
    if request.source != incoming.source or incoming.source not in sources:
        raise MutationError(
            "SNAPSHOT_SOURCE", "Transport does not match a configured immutable source"
        )
    root = snapshot.profile.artifacts["source_snapshots"]
    path = root + "/" + cast("str", incoming.source.revision) + "/manifest.json"
    # An explicit profile manifest takes precedence over the deterministic default.
    configured = next(
        (
            item.snapshot_manifest
            for item in snapshot.profile.repositories
            if item.id == incoming.source.id and item.snapshot_manifest is not None
        ),
        None,
    )
    path = configured or path
    # Reuse one already imported/exported identical identity, including combined repos.
    existing = tuple(
        item
        for item in snapshot.artifacts
        if item.expected_kind == "source-snapshot-manifest"
        and item.document is not None
        and item.document.get("id") == incoming.document["id"]
    )
    if len(existing) > 1:
        raise MutationError("SNAPSHOT_CONFLICT", "Transport identity is duplicated")
    # Preserve original repository-relative member names when moving the bundle.
    contents = {
        item.origin: snapshot.file(item.grant.path).content
        for item in incoming.members
        if item.origin is not None
    }
    # Identical reimports retain prior attribution; mismatches never replace bytes.
    if existing:
        retained = _captured_transport(baseline, existing[0].path)
        if (
            retained.source != incoming.source
            or transport_digest(retained.document)
            != transport_digest(incoming.document)
            or configured is not None
            and retained.manifest.path != configured
        ):
            raise MutationError(
                "SNAPSHOT_CONFLICT", "Existing transport identity differs"
            )
        return _proposal(baseline, retained, contents)
    # Verification metadata changes only after all captured member bytes were checked.
    transport = dict(cast("JsonObject", incoming.document["transport"]))
    transport.update(
        verification_status="verified",
        verified_at=request.verified_at,
        verified_by=request.verified_by,
    )
    document = dict(incoming.document)
    document["transport"] = JsonObject(tuple(transport.items()))
    route = bind_transport(
        path,
        canonical_json(JsonObject(tuple(document.items()))),
        catalog=snapshot.catalog,
        limits=snapshot.profile.limits.parse_limits(),
    )
    return _proposal(baseline, route, contents)


def plan_snapshot_export(
    baseline: CapturedWorkspace,
    request: SnapshotExport,
    *,
    grants: tuple[WriteGrant, ...],
    invocation: InvocationContext | None = None,
) -> MutationPlan:
    """Validate the export graph with exact external grants and root context."""
    proposal = prepare_snapshot_export(baseline, request)
    return plan_mutation(
        baseline,
        proposal.changes,
        grants=grants,
        invocation=invocation,
        transport=proposal.route,
    )


def plan_snapshot_import(
    baseline: CapturedWorkspace,
    request: SnapshotImport,
    *,
    grants: tuple[WriteGrant, ...],
    invocation: InvocationContext | None = None,
) -> MutationPlan:
    """Validate the complete imported graph; supplied status never grants trust."""
    proposal = prepare_snapshot_import(baseline, request)
    return plan_mutation(
        baseline,
        proposal.changes,
        grants=grants,
        invocation=invocation,
        transport=proposal.route,
    )


def export_snapshot(
    baseline: CapturedWorkspace,
    request: SnapshotExport,
    *,
    grants: tuple[WriteGrant, ...],
    writer: MutationWriter,
    dry_run: bool = False,
    invocation: InvocationContext | None = None,
) -> MutationResult:
    """Commit or dry-run through the existing writer, preserving partial outcomes."""
    return commit_mutation(
        plan_snapshot_export(baseline, request, grants=grants, invocation=invocation),
        writer=writer,
        dry_run=dry_run,
    )


def import_snapshot(
    baseline: CapturedWorkspace,
    request: SnapshotImport,
    *,
    grants: tuple[WriteGrant, ...],
    writer: MutationWriter,
    dry_run: bool = False,
    invocation: InvocationContext | None = None,
) -> MutationResult:
    """Publish only verified matching local bytes without replacement or fetching."""
    return commit_mutation(
        plan_snapshot_import(baseline, request, grants=grants, invocation=invocation),
        writer=writer,
        dry_run=dry_run,
    )
