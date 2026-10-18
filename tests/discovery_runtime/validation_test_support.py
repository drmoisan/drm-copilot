"""Create isolated immutable snapshots and invocation data without runtime I/O."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING

from drm_copilot_discovery.agent_output import InvocationContext, required_output_digest
from drm_copilot_discovery.coverage_scope_rules import inventory_configuration_digest
from drm_copilot_discovery.models import canonical_json, to_plain_value
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.snapshot import (
    ArtifactSnapshot,
    DiscoverySnapshot,
    InputManifest,
    SnapshotFile,
    repository_pins,
)

from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.discovery_runtime.test_references import immutable, reference
from tests.schemas.discovery.v2_control_test_support import control_fixture
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog

ROOT = "docs/migration/discovery/"


def mode_profile(
    catalog: SchemaCatalog,
    *,
    draft: bool = False,
    planning: str = "discovery-complete",
    **gates: bool,
) -> ProfileV2:
    """Create isolated configuration with one combined source/target identity."""
    value = profile_document()
    value["repositories"] = []
    value["clients"] = [
        {
            "id": "browser",
            "target_repository": "workspace-example",
            "platforms": ["browser"],
            "modes": ["online"],
            "required_feature_dimensions": [],
            "applicability_defaults": {},
        }
    ]
    value["project_entry_points"] = []
    as_object(value["completion_gates"]).update(planning_prerequisite=planning, **gates)
    if draft:
        value["profile_state"] = "draft"
        as_object(value["repository"])["revision"] = None
    return ProfileV2(json.dumps(value), format="json", catalog=catalog)


def captured(
    profile: ProfileV2,
    catalog: SchemaCatalog,
    *records: ArtifactSnapshot,
    payloads: tuple[SnapshotFile, ...] = (),
) -> DiscoverySnapshot:
    """Bind parsed artifacts, raw profile bytes, payloads and role pins exactly."""
    sources, targets = repository_pins(profile)
    files = (
        SnapshotFile(
            path=profile.artifacts["profile"],
            content=canonical_json(profile.document),
            category="profile",
        ),
    )
    files += tuple(
        SnapshotFile(
            path=item.path, content=canonical_json(item.document), category="artifact"
        )
        for item in records
    )
    return DiscoverySnapshot(
        profile=profile,
        catalog=catalog,
        artifacts=records,
        manifest=InputManifest(
            files=files + payloads,
            source_repositories=sources,
            target_repositories=targets,
        ),
    )


def document_record(
    profile: ProfileV2, kind: str, path: str, value: dict[str, object]
) -> ArtifactSnapshot:
    """Create a trusted local expected-kind descriptor over immutable document data."""
    return ArtifactSnapshot(
        path=path,
        expected_kind=kind,
        document=immutable(value),
        repository=RepositoryIdentity(
            id=profile.repository.id, revision=profile.repository.revision
        ),
    )


def no_scope_snapshot(
    catalog: SchemaCatalog, *, profile: ProfileV2 | None = None
) -> DiscoverySnapshot:
    """Build a schema-valid confirmed empty scope with retained confirmation proof."""
    profile = profile or mode_profile(catalog)
    owner, pin = profile.repository.id, profile.repository.revision
    inventory = load_fixture("inventory-snapshot")
    inventory.update(
        id="inventory",
        repository=owner,
        revision=pin,
        scan_configuration_sha256=inventory_configuration_digest(profile),
        files=[],
        components=[],
        findings=[],
        relationships=[],
        diagnostics=[],
        exclusions=[],
    )
    scope = load_fixture("scope")
    scope.update(
        id="scope",
        repository={"id": owner, "revision": pin},
        included_roots=[],
        included_components=[],
        included_features=[],
        exclusions=[],
        inventory_snapshot_refs=[reference("inventory-snapshot", "inventory")],
        required_coverage={"feature_refs": [], "client_ids": [], "modes": []},
        disposition="no-scope",
        no_scope_rationale="The inspected selection contains no migration behavior.",
    )
    as_object(scope["confirmed_by"])["evidence_refs"] = [
        reference("evidence-reference", "confirmation")
    ]
    ledger = load_fixture("coverage-ledger")
    ledger.update(
        repository=owner,
        revision=pin,
        components=[],
        scope_ref=reference("scope", "scope"),
        inventory_snapshot_refs=[reference("inventory-snapshot", "inventory")],
    )
    proof = load_fixture("evidence-reference")
    payload = SnapshotFile(
        path=ROOT + "evidence/confirmation.txt",
        content=b"Confirmed empty scope.",
        category="evidence",
    )
    proof.update(
        id="confirmation",
        evidence_id="confirmation",
        evidence_type="decision",
        repository=owner,
        revision=pin,
        path=payload.path,
        runtime_artifact=None,
        checksum={"algorithm": "sha256", "value": payload.sha256},
    )
    records = tuple(
        document_record(profile, kind, path, value)
        for kind, path, value in (
            ("scope", profile.artifacts["scope"], scope),
            ("inventory-snapshot", ROOT + "inventory/empty.json", inventory),
            ("coverage-ledger", profile.artifacts["coverage_ledger"], ledger),
            ("evidence-reference", ROOT + "evidence/confirmation.json", proof),
        )
    )
    return captured(profile, catalog, *records, payloads=(payload,))


def replace_document(
    snapshot: DiscoverySnapshot, path: str, value: dict[str, object]
) -> DiscoverySnapshot:
    """Update a prospective document and its bytes without shared mutation."""
    document = immutable(value)
    return replace(
        snapshot,
        artifacts=tuple(
            replace(item, document=document) if item.path == path else item
            for item in snapshot.artifacts
        ),
        manifest=replace(
            snapshot.manifest,
            files=tuple(
                (
                    replace(item, content=canonical_json(document))
                    if item.path == path
                    else item
                )
                for item in snapshot.manifest.files
            ),
        ),
    )


def output_context(
    baseline: DiscoverySnapshot,
    role: str = "legacy-parity-analyst",
    *,
    outputs: tuple[ArtifactSnapshot, ...] = (),
    payloads: tuple[SnapshotFile, ...] = (),
    review_mode: str | None = None,
    selected: tuple[str, ...] = (),
) -> tuple[DiscoverySnapshot, InvocationContext]:
    """Create a separately supplied invocation and exact prospective output set."""
    workspace = {
        "workspace_root": "/workspace/synthetic",
        "workspace_sha256": "c" * 64,
        "profile_path": baseline.profile.artifacts["profile"],
        "profile_sha256": baseline.file(baseline.profile.artifacts["profile"]).sha256,
    }
    manifest = control_fixture("required-output-manifest")
    path = ROOT + "reports/required.json"
    rows: list[dict[str, object]] = []
    for item in outputs:
        assert item.document is not None
        rows.append(
            {
                "artifact_kind": item.expected_kind,
                "id": item.document["id"],
                "path": item.path,
                "format": "yaml" if item.path.endswith((".yaml", ".yml")) else "json",
                "expected_sha256": next(
                    (
                        file.sha256
                        for file in baseline.manifest.files
                        if file.path == item.path
                    ),
                    None,
                ),
            }
        )
    for file in payloads:
        rows.append(
            {
                "artifact_kind": "evidence-payload",
                "id": "payload",
                "path": file.path,
                "format": "binary",
                "expected_sha256": next(
                    (
                        item.sha256
                        for item in baseline.manifest.files
                        if item.path == file.path
                    ),
                    None,
                ),
            }
        )
    rows.append(
        {
            "artifact_kind": "required-output-manifest",
            "id": manifest["id"],
            "path": path,
            "format": "json",
            "expected_sha256": next(
                (file.sha256 for file in baseline.manifest.files if file.path == path),
                None,
            ),
        }
    )
    manifest.update(role=role, workspace=workspace, outputs=rows)
    manifest["manifest_sha256"] = required_output_digest(immutable(manifest))
    context = InvocationContext(
        baseline=baseline,
        role=role,
        invocation_id=str(manifest["invocation_id"]),
        workspace=immutable(workspace),
        required_outputs=immutable(manifest),
        review_mode=review_mode,
        selected_ids=selected,
    )
    stored = document_record(
        baseline.profile, "required-output-manifest", path, manifest
    )
    records = {item.path: item for item in baseline.artifacts}
    records.update({item.path: item for item in (*outputs, stored)})
    files = {item.path: item for item in baseline.manifest.files}
    files.update(
        {
            item.path: SnapshotFile(
                path=item.path,
                content=canonical_json(item.document),
                category="artifact",
            )
            for item in (*outputs, stored)
        }
    )
    files.update({item.path: item for item in payloads})
    return (
        replace(
            baseline,
            artifacts=tuple(records.values()),
            manifest=replace(baseline.manifest, files=tuple(files.values())),
        ),
        context,
    )


def alter_manifest(
    snapshot: DiscoverySnapshot, context: InvocationContext, **changes: object
) -> tuple[DiscoverySnapshot, InvocationContext]:
    """Change authored manifest fields while retaining separate caller context by
    default.
    """
    value = as_object(to_plain_value(context.required_outputs))
    value.update(changes)
    value["manifest_sha256"] = required_output_digest(immutable(value))
    path = next(
        item.path
        for item in snapshot.artifacts
        if item.expected_kind == "required-output-manifest"
    )
    return replace_document(snapshot, path, value), replace(
        context, required_outputs=immutable(value)
    )
