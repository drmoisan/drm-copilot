"""Verify exact transport manifests, immutable export routes and replica identity."""

from __future__ import annotations

import json
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.claim_rules import ClaimContext
from drm_copilot_discovery.evidence_linking import evidence_changes
from drm_copilot_discovery.evidence_rules import EvidenceValidation
from drm_copilot_discovery.models import ParseLimits, canonical_json
from drm_copilot_discovery.mutation_plan import (
    MutationError,
    plan_mutation,
)
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.path_policy import PathPolicy
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.source_snapshots import prepare_snapshot_export
from drm_copilot_discovery.transport_manifest import (
    bind_transport,
    replica_aliases,
    transport_digest,
)

from tests.discovery_runtime.evidence_test_support import request_for
from tests.discovery_runtime.mutation_test_support import capture, grants_for
from tests.discovery_runtime.mutation_test_support import (
    mutation_catalog as mutation_catalog,
)
from tests.discovery_runtime.source_snapshot_test_support import (
    changed_header,
    evidence_capture,
    export_fault,
    export_request,
    transport_case,
    unit_transport,
    with_files,
)
from tests.discovery_runtime.source_snapshot_test_support import (
    source_capture as source_capture,
)
from tests.discovery_runtime.test_references import immutable
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace


def test_manifest_binds_exact_bytes_and_excludes_only_importer_verification(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Authored success flags cannot replace raw digest/member validation."""
    route = unit_transport(mutation_catalog)
    # Build the complete inert byte set so membership checks exercise no graph loader.
    route.check_files(
        tuple(
            SnapshotFile(
                path=item.grant.path,
                content=route.manifest.content if item.origin is None else b"{}",
                category="artifact",
            )
            for item in route.members
        )
    )
    transport = as_object(json.loads(route.manifest.content))["transport"]
    as_object(transport).update(
        verification_status="verified",
        verified_at="2026-01-01T00:00:00Z",
        verified_by={"kind": "human", "id": "reviewer"},
    )
    changed = bind_transport(
        route.manifest.path,
        changed_header(route, {"transport": transport}, digest=False),
        catalog=mutation_catalog,
        limits=ParseLimits(),
    )
    assert transport_digest(changed.document) == transport_digest(route.document)
    assert changed.manifest.sha256 != route.manifest.sha256
    assert [item.grant for item in changed.members] == [
        item.grant for item in route.members
    ]


@pytest.mark.parametrize(
    "updates,digest,match",
    [
        ({"schema_version": "3.0.0"}, False, "unsupported"),
        ({"manifest_sha256": "0" * 64}, False, "checksum"),
        (
            {"source_repository": {"id": "source", "revision": None}},
            True,
            "unsupported",
        ),
        (
            {"source_repository": {"id": "source", "revision": "main"}},
            True,
            "unsupported",
        ),
    ],
)
def test_bad_manifest_identity_version_and_digest_are_rejected(
    updates: dict[str, object],
    digest: bool,
    match: str,
    mutation_catalog: SchemaCatalog,
) -> None:
    """Invalid declarations fail before becoming a route or a write plan."""
    route = unit_transport(mutation_catalog)
    with pytest.raises(ValueError, match=match):
        bind_transport(
            route.manifest.path,
            changed_header(route, updates, digest=digest),
            catalog=mutation_catalog,
            limits=ParseLimits(),
        )


@pytest.mark.parametrize(
    "fault",
    [
        "counts",
        "duplicate-id",
        "duplicate-path",
        "escape",
        "manifest",
        "ancestor",
        "oversize",
    ],
)
def test_manifest_member_conflicts_and_bounds_are_rejected(
    fault: str, mutation_catalog: SchemaCatalog
) -> None:
    """Reject aliases, conflicting identities and oversized transport members."""
    route = unit_transport(mutation_catalog)
    document = as_object(json.loads(route.manifest.content))
    rows = cast("list[dict[str, object]]", document["artifacts"])
    # Each branch violates one independent envelope invariant before rebinding.
    if fault == "counts":
        as_object(document["transport"])["payload_count"] = 1
    elif fault == "duplicate-id":
        rows[1].update(artifact_kind=rows[0]["artifact_kind"], id=rows[0]["id"])
    elif fault == "duplicate-path":
        rows[1]["path"] = rows[0]["path"]
    elif fault == "escape":
        rows[0]["path"] = "../escape.json"
    elif fault == "manifest":
        rows[0]["path"] = "nested/manifest.json"
    elif fault == "ancestor":
        rows[1]["path"] = str(rows[0]["path"]) + "/child.json"
    else:
        rows[0]["size"] = 67108865
    document["manifest_sha256"] = transport_digest(immutable(document))
    with pytest.raises(ValueError):
        bind_transport(
            route.manifest.path,
            canonical_json(immutable(document)),
            catalog=mutation_catalog,
            limits=ParseLimits(),
        )


def test_transport_route_is_exact_and_ordinary_policy_remains_closed(
    mutation_catalog: SchemaCatalog,
) -> None:
    """An authenticated member grant still needs the explicit transport context."""
    _, baseline, route, _ = transport_case(mutation_catalog)
    grant = route.members[0].grant
    policy = PathPolicy(
        baseline.snapshot.profile,
        workspace_root=baseline.workspace_root,
        metadata=baseline.inspect,
    )
    with pytest.raises(PathPolicyError, match="PATH_WRITE_DENIED"):
        policy.resolve_write(grant.path, grant=grant)
    policy = PathPolicy(
        baseline.snapshot.profile,
        workspace_root=baseline.workspace_root,
        metadata=baseline.inspect,
        transport=route,
    )
    assert policy.resolve_write(grant.path, grant=grant).grant == grant
    with pytest.raises(PathPolicyError, match="PATH_WRITE_DENIED"):
        policy.resolve_write(grant.path, grant=replace(grant, artifact_id="wrong"))
    assert not route.allows(grant, root="elsewhere")


def test_real_planner_accepts_exact_export_replicas_and_publishes_header_last(
    mutation_catalog: SchemaCatalog,
) -> None:
    """The complete graph retains original/import bytes without duplicate aliases."""
    _, baseline, route, changes = transport_case(mutation_catalog)
    request = replace(request_for(baseline), artifact_id="alpha")
    before = evidence_changes(baseline, request)
    plan = plan_mutation(
        baseline, changes, grants=grants_for(*changes), transport=route
    )
    assert plan.validation.ok and plan.writes[-1].change.path == route.manifest.path
    aliases = replica_aliases(plan.prospective)
    assert set(aliases.values()) == {item.path for item in baseline.snapshot.artifacts}
    assert len(plan.prospective.artifacts) == len(baseline.snapshot.artifacts) * 2 + 1
    index = index_references(plan.prospective)
    assert not index.findings
    # Export cannot alter any captured source file while adding its immutable replica.
    assert all(
        plan.prospective.file(item.path).content == item.content
        for item in baseline.snapshot.manifest.files
    )
    # Projection remains local; divergent same-pin writes still require validation.
    assert (
        evidence_changes(replace(baseline, snapshot=plan.prospective), request)
        == before
    )
    local = index.candidates("feature-contract", "alpha")[0]
    assert local.artifact.origin_path is None
    reference = immutable(
        dict(
            artifact_kind=local.kind,
            repository_id=local.repository,
            revision=local.artifact.repository.revision,
            artifact_path=local.path,
            artifact_sha256=plan.prospective.file(local.artifact.path).sha256,
            feature_id=local.document["feature_id"],
            schema_version="2.0.0",
        )
    )
    resolved = index.resolve(reference, source=local, pointer="/source_contract_ref")
    assert not resolved.findings and resolved.target is not None
    assert resolved.target.artifact.origin_path == local.path
    assert aliases[resolved.target.artifact.path] == local.artifact.path
    context = ClaimContext(index, EvidenceValidation(assessments=(), findings=()), 1000)
    assert context.targets(local, "")
    assert context.targets(resolved.target, "") == context.targets(local, "")
    assert resolved.target not in index.records
    # Every manifest link must select that manifest's physical imported member.
    for link in index.links:
        if link.source.kind == "source-snapshot-manifest":
            assert link.target is not None and link.target.artifact.origin_path
            assert link.target.artifact.path == (
                route.manifest.path.rsplit("/", 1)[0]
                + "/"
                + str(link.reference["path"])
            )


@pytest.mark.parametrize(
    "fault",
    ["unbound", "changed-bytes", "changed-pin", "changed-origin", "changed-header"],
)
def test_unbound_or_conflicting_copies_keep_duplicate_errors(
    fault: str, mutation_catalog: SchemaCatalog
) -> None:
    """Only actual manifest-provenance-bound raw replicas can share lookup identity."""
    store, baseline, route, changes = transport_case(mutation_catalog)
    # Capture the real complete export before corrupting one provenance constraint.
    for item in changes:
        store.put(item.path, item.content)
    snapshot = capture(store, mutation_catalog).snapshot
    imported = next(item for item in snapshot.artifacts if item.origin_path)
    # Matching IDs never compensate for missing provenance, changed pin or byte drift.
    if fault == "unbound":
        # Remove only provenance; the physical imported files remain present.
        snapshot = replace(
            snapshot,
            artifacts=tuple(
                item for item in snapshot.artifacts if item.path != route.manifest.path
            ),
        )
    elif fault == "changed-pin":
        # Alter one captured repository pin while keeping identical content and IDs.
        snapshot = replace(
            snapshot,
            artifacts=tuple(
                (
                    replace(
                        item, repository=replace(item.repository, revision="b" * 40)
                    )
                    if item == imported
                    else item
                )
                for item in snapshot.artifacts
            ),
        )
    elif fault == "changed-origin":
        # Origin equality is required independently of content or repository identity.
        snapshot = replace(
            snapshot,
            artifacts=tuple(
                replace(item, origin_path="other.json") if item == imported else item
                for item in snapshot.artifacts
            ),
        )
    else:
        path = imported.path if fault == "changed-bytes" else route.manifest.path
        # Mutate one physical input without hiding it from complete snapshot capture.
        snapshot = replace(
            snapshot,
            manifest=replace(
                snapshot.manifest,
                files=tuple(
                    (
                        replace(item, content=item.content + b" ")
                        if item.path == path
                        else item
                    )
                    for item in snapshot.manifest.files
                ),
            ),
        )
        if fault == "changed-header":
            document = as_object(json.loads(snapshot.file(path).content))
            document["manifest_sha256"] = "0" * 64
            # Preserve a parseable header whose canonical digest no longer agrees.
            snapshot = replace(
                snapshot,
                manifest=replace(
                    snapshot.manifest,
                    files=tuple(
                        (
                            replace(item, content=json.dumps(document).encode())
                            if item.path == path
                            else item
                        )
                        for item in snapshot.manifest.files
                    ),
                ),
            )
    assert any(
        item.code == "DUPLICATE_ID" for item in index_references(snapshot).findings
    )
    assert len(snapshot.manifest.files) >= len(baseline.snapshot.manifest.files)


def test_ordinary_same_byte_duplicates_are_not_transport_replicas(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Matching content alone cannot exempt two ordinary declarations."""
    store, baseline, _, _ = transport_case(mutation_catalog)
    feature = next(
        item
        for item in baseline.snapshot.artifacts
        if item.expected_kind == "feature-contract"
    )
    store.put(feature.path.replace("alpha", "copy"), store.files[feature.path])
    snapshot = capture(store, mutation_catalog).snapshot
    assert not replica_aliases(snapshot)
    assert any(
        item.code == "DUPLICATE_ID" for item in index_references(snapshot).findings
    )


def test_transport_rejects_incomplete_or_forged_bindings(
    mutation_catalog: SchemaCatalog,
) -> None:
    """Membership and route reconstruction cannot be replaced by result flags."""
    _, baseline, route, changes = transport_case(mutation_catalog)
    with pytest.raises(MutationError, match="exact complete"):
        plan_mutation(
            baseline, changes[:-1], grants=grants_for(*changes), transport=route
        )
    with pytest.raises(ValueError, match="original manifest"):
        replace(route, members=route.members[:-1]).revalidate(
            catalog=mutation_catalog, limits=ParseLimits()
        )
    with pytest.raises(ValueError, match="checksum"):
        route.check(route.members[0].grant, b"substituted")
    with pytest.raises(ValueError, match="complete declared"):
        route.check_files((route.manifest,))


def test_export_projection_is_deterministic_complete_and_read_only(
    source_capture: CapturedWorkspace,
) -> None:
    """Selected contracts keep unknown claims and bring their linked questions."""
    original = source_capture.snapshot.sha256
    first = prepare_snapshot_export(source_capture, export_request())
    assert first == prepare_snapshot_export(source_capture, export_request())
    assert len(first.changes) == 3
    assert first.route.source.revision == "a" * 40
    assert first.route.manifest.path.endswith("/release-alpha/manifest.json")
    assert first.route.document["manifest_sha256"] == transport_digest(
        first.route.document
    )
    transport = as_object(
        as_object(json.loads(first.route.manifest.content))["transport"]
    )
    assert transport["verification_status"] == "pending"
    # Relocated artifacts retain raw bytes, including unknown observation state.
    for member, change in zip(first.route.members, first.changes, strict=True):
        if member.origin is not None:
            assert change.content == source_capture.snapshot.file(member.origin).content
    assert source_capture.snapshot.sha256 == original


@pytest.mark.parametrize(
    "kind",
    [
        "source",
        "test",
        "runtime",
        "observation",
        "documentation",
        "decision",
        "inventory",
    ],
)
def test_export_retains_verified_evidence_and_exact_payload_bytes(
    source_capture: CapturedWorkspace,
    kind: str,
) -> None:
    """A transported checksum binds the same bytes as accepted local evidence."""
    baseline = evidence_capture(source_capture, kind)
    proposal = prepare_snapshot_export(baseline, export_request())
    payloads = cast("tuple[object, ...]", proposal.route.document["payloads"])
    assert len(payloads) == 1
    proof = next(
        item for item in proposal.changes if item.artifact_kind == "evidence-reference"
    )
    payload = next(
        item for item in proposal.changes if item.artifact_kind == "evidence-payload"
    )
    record = as_object(json.loads(proof.content))
    assert as_object(record["checksum"])["value"] == sha256(payload.content).hexdigest()
    assert record["revision"] == ("a" * 40 if kind in {"source", "test"} else None)
    assert len(proposal.changes) == 5


@pytest.mark.parametrize(
    "fault", ["empty", "duplicate", "missing", "imported", "unresolved", "malformed"]
)
def test_export_rejects_invalid_selection_or_incomplete_source_closure(
    source_capture: CapturedWorkspace,
    fault: str,
) -> None:
    """Export cannot hide an absent, malformed, foreign or unresolved dependency."""
    baseline, request = export_fault(source_capture, fault)
    with pytest.raises(MutationError):
        prepare_snapshot_export(baseline, request)


@pytest.mark.parametrize("fault", ["checksum", "missing-object"])
def test_export_never_substitutes_unverified_or_working_tree_source_bytes(
    source_capture: CapturedWorkspace,
    fault: str,
) -> None:
    """Checksum failures and unavailable immutable objects cannot enter a bundle."""
    baseline = evidence_capture(source_capture, "source")
    objects = baseline.snapshot.repository_files
    if fault == "checksum":
        objects = tuple(replace(item, content=b"different") for item in objects)
    else:
        objects = ()
    baseline = replace(
        baseline, snapshot=replace(baseline.snapshot, repository_files=objects)
    )
    with pytest.raises(MutationError, match="locally verified"):
        prepare_snapshot_export(baseline, export_request())


def test_export_repeat_binds_original_hash_and_conflicting_bytes_are_not_replaced(
    source_capture: CapturedWorkspace,
) -> None:
    """Repeated projection skips identical immutable files and rejects replacements."""
    proposal = prepare_snapshot_export(source_capture, export_request())
    # Model persisted immutable bytes without invoking actual publication in this unit.
    files = tuple(
        SnapshotFile(path=item.path, content=item.content, category="source-snapshot")
        for item in proposal.changes
    )
    baseline = with_files(
        source_capture, (*source_capture.snapshot.manifest.files, *files)
    )
    repeated = prepare_snapshot_export(baseline, export_request())
    # Every skipped destination must retain its original-byte CAS precondition.
    assert all(
        item.expected_sha256 == sha256(item.content).hexdigest()
        for item in repeated.changes
    )
    changed = replace(files[0], content=b"changed")
    baseline = with_files(
        baseline, (*source_capture.snapshot.manifest.files, changed, *files[1:])
    )
    with pytest.raises(MutationError, match="destination bytes"):
        prepare_snapshot_export(baseline, export_request())
