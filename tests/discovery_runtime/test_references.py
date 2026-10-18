"""Resolve typed graph links using immutable snapshots and isolated memory data."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.snapshot import (
    ArtifactSnapshot,
    DiscoverySnapshot,
    InputManifest,
    SnapshotFile,
)

from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2


def immutable(document: Mapping[str, object]) -> JsonObject:
    """Parse a fresh memory document through the accepted immutable boundary."""
    result = parse_document(json.dumps(document), format="json")
    assert result.value is not None, result.findings
    return result.value


def artifact(
    kind: str,
    identifier: str,
    *,
    repository: str = "local",
    path: str | None = None,
    origin: str | None = None,
    fields: dict[str, object] | None = None,
) -> ArtifactSnapshot:
    """Create a narrow graph fixture without disk reads or schema revalidation."""
    document: dict[str, object] = {"artifact_kind": kind, "id": identifier}
    document.update(fields or {})
    return ArtifactSnapshot(
        path=path or f"docs/{repository}/{kind}/{identifier}.json",
        expected_kind=kind,
        repository=RepositoryIdentity(id=repository, revision="a" * 40),
        document=immutable(document),
        origin_path=origin,
    )


def graph(
    profile: ProfileV2, catalog: SchemaCatalog, *artifacts: ArtifactSnapshot
) -> DiscoverySnapshot:
    """Bind every synthetic document to retained bytes in one complete manifest."""
    files = tuple(
        SnapshotFile(
            path=item.path, content=canonical_json(item.document), category="artifact"
        )
        for item in artifacts
    )
    return DiscoverySnapshot(
        profile=profile,
        catalog=catalog,
        manifest=InputManifest(files=files),
        artifacts=artifacts,
    )


def reference(kind: str, identifier: str, **fields: object) -> dict[str, object]:
    """Construct a fresh common typed link for positive and negative probes."""
    return {"artifact_kind": kind, "id": identifier, **fields}


def source_reference(target: ArtifactSnapshot) -> dict[str, object]:
    """Retain source feature identity separately from the artifact document ID."""
    assert target.document is not None
    return {
        "artifact_kind": "feature-contract",
        "repository_id": target.repository.id,
        "revision": "b" * 40,
        "artifact_path": target.origin_path or target.path,
        "artifact_sha256": "f" * 64,
        "feature_id": target.document["feature_id"],
        "schema_version": "2.0.0",
    }


@pytest.mark.parametrize(
    "field,kind",
    [
        ("source_evidence_refs", "evidence-reference"),
        ("runtime_evidence_refs", "evidence-reference"),
        ("product_decision_refs", "product-decision"),
        ("unresolved_behavior_refs", "unspecified-behavior"),
    ],
)
def test_feature_reference_fields_resolve_exact_typed_identity(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, field: str, kind: str
) -> None:
    """Every feature link uses its schema's expected kind and preserves its pointer."""
    target = artifact(kind, "target")
    source = artifact(
        "feature-contract", "feature", fields={field: [reference(kind, "target")]}
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, source, target))
    assert index.findings == ()
    assert len(index.links) == 1
    assert index.links[0].pointer == f"/{field}/0"
    assert index.links[0].target is not None
    assert index.links[0].target.artifact == target


@pytest.mark.parametrize(
    "kind,fields,pointer",
    [
        (
            "feature-contract",
            {
                "trigger": {
                    "evidence_refs": [reference("evidence-reference", "capture")]
                }
            },
            "/trigger/evidence_refs/0",
        ),
        (
            "feature-contract",
            {
                "state_transitions": {
                    "entries": [
                        {
                            "id": "transition",
                            "before": {
                                "evidence_refs": [
                                    reference("evidence-reference", "capture")
                                ]
                            },
                        }
                    ]
                }
            },
            "/state_transitions/entries/0/before/evidence_refs/0",
        ),
        (
            "feature-contract",
            {
                "acceptance_criteria": [
                    {
                        "id": "criterion",
                        "evidence_refs": [reference("evidence-reference", "capture")],
                    }
                ]
            },
            "/acceptance_criteria/0/evidence_refs/0",
        ),
        (
            "runtime-characterization-scenario",
            {
                "runs": [
                    {
                        "id": "run",
                        "post_state_capture": {
                            "evidence_refs": [
                                reference("evidence-reference", "capture")
                            ]
                        },
                    }
                ]
            },
            "/runs/0/post_state_capture/evidence_refs/0",
        ),
        (
            "product-decision",
            {
                "approval": {
                    "evidence_refs": [reference("evidence-reference", "capture")]
                }
            },
            "/approval/evidence_refs/0",
        ),
        (
            "unspecified-behavior",
            {
                "competing_interpretations": [
                    {
                        "id": "interpretation",
                        "evidence_refs": [reference("evidence-reference", "capture")],
                    }
                ]
            },
            "/competing_interpretations/0/evidence_refs/0",
        ),
        (
            "implementation-record",
            {
                "test_references": [
                    {"evidence_refs": [reference("evidence-reference", "capture")]}
                ]
            },
            "/test_references/0/evidence_refs/0",
        ),
        (
            "scope",
            {
                "confirmed_by": {
                    "evidence_refs": [reference("evidence-reference", "capture")]
                }
            },
            "/confirmed_by/evidence_refs/0",
        ),
    ],
)
def test_nested_core_references_follow_catalog_shapes(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    kind: str,
    fields: dict[str, object],
    pointer: str,
) -> None:
    """Nested core references resolve without flattening arbitrary application data."""
    source = artifact(kind, "source", fields=fields)
    target = artifact("evidence-reference", "capture")
    index = index_references(graph(snapshot_profile, snapshot_catalog, source, target))
    assert index.findings == ()
    assert [link.pointer for link in index.links] == [pointer]


@pytest.mark.parametrize(
    "field,wrong_kind",
    [
        ("source_evidence_refs", "feature-contract"),
        ("product_decision_refs", "evidence-reference"),
        ("unresolved_behavior_refs", "product-decision"),
    ],
)
def test_typed_field_cannot_select_an_existing_wrong_kind(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    wrong_kind: str,
) -> None:
    """A resolvable ID does not override the kind constraint of its source field."""
    source = artifact(
        "feature-contract", "source", fields={field: [reference(wrong_kind, "target")]}
    )
    target = artifact(wrong_kind, "target")
    index = index_references(graph(snapshot_profile, snapshot_catalog, source, target))
    assert [finding.code for finding in index.findings] == ["REFERENCE_KIND"]
    assert index.links[0].target is None


@pytest.mark.parametrize(
    "fields,code",
    [
        ({"id": "absent"}, "REFERENCE_MISSING"),
        ({"artifact_kind": "scope"}, "REFERENCE_KIND"),
        ({"path": "docs/wrong.json"}, "REFERENCE_PATH"),
        ({"repository": "foreign"}, "REFERENCE_MISSING"),
        ({"id": None}, "REFERENCE_INVALID"),
        ({"artifact_kind": None}, "REFERENCE_INVALID"),
    ],
)
def test_resolver_blocks_mismatched_identity_fields(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    fields: dict[str, object],
    code: str,
) -> None:
    """Wrong kind, owner, path and malformed or missing IDs fail explicitly."""
    target = artifact("feature-contract", "target")
    index = index_references(graph(snapshot_profile, snapshot_catalog, target))
    result = index.resolve(
        immutable(reference("feature-contract", "target", **fields)),
        source=index.records[0],
        pointer="/link",
    )
    assert result.target is None
    assert result.findings[0].code == code
    assert result.findings[0].pointer == "/link"


def test_imported_reference_uses_origin_and_feature_alias_without_hash_rules(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Source links resolve by feature ID/origin; hash and pin integrity is deferred."""
    target = artifact(
        "feature-contract",
        "document-id",
        repository="foreign",
        origin="contracts/source.json",
        fields={"feature_id": "behavior"},
    )
    source = artifact(
        "parity-matrix",
        "parity",
        fields={
            "entries": [
                {
                    "id": "row",
                    "feature_id": "behavior",
                    "source_contract_ref": source_reference(target),
                }
            ]
        },
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, source, target))
    assert index.findings == ()
    assert index.links[0].target is not None
    assert index.links[0].target.id == "document-id"
    assert index.links[0].target.path == "contracts/source.json"
    assert index.candidates("feature-contract", "behavior") == ()


@pytest.mark.parametrize(
    "manifest_kind,field,owner_field,target_kind",
    [
        (
            "source-snapshot-manifest",
            "artifacts",
            "source_repository",
            "feature-contract",
        ),
        (
            "extension-result-manifest",
            "result_files",
            "repository",
            "inventory-snapshot",
        ),
    ],
)
def test_transport_entries_resolve_their_declared_repository(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    manifest_kind: str,
    field: str,
    owner_field: str,
    target_kind: str,
) -> None:
    """Manifest rows bind captured files without treating the rows as new artifacts."""
    target = artifact(
        target_kind, "target", repository="foreign", origin="artifact.json"
    )
    source = artifact(
        manifest_kind,
        "manifest",
        fields={
            owner_field: {"id": "foreign"},
            field: [reference(target_kind, "target", path="artifact.json")],
        },
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, source, target))
    assert index.findings == ()
    assert len(index.records) == 2
    assert index.links[0].target is not None
    assert index.links[0].target.repository == "foreign"


def test_inventory_and_coverage_component_linkage_is_contextual(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Inventory links and coverage/scope selectors use explicit inventory context."""
    inventory = artifact(
        "inventory-snapshot",
        "inventory",
        fields={
            "components": [{"component_id": "component"}],
            "findings": [{"finding_id": "finding", "component_id": "component"}],
            "relationships": [
                {
                    "relationship_id": "relationship",
                    "from_component_id": "component",
                    "to_component_id": None,
                }
            ],
            "diagnostics": [{"id": "diagnostic"}],
            "files": [{"diagnostic_ids": ["diagnostic"]}],
        },
    )
    scope = artifact(
        "scope",
        "scope",
        fields={
            "included_components": ["component"],
            "inventory_snapshot_refs": [reference("inventory-snapshot", "inventory")],
        },
    )
    ledger = artifact(
        "coverage-ledger",
        "ledger",
        fields={
            "components": [
                {
                    "component_id": "component",
                    "exclusion_scope_ref": reference("scope", "scope"),
                }
            ],
            "inventory_snapshot_refs": [reference("inventory-snapshot", "inventory")],
            "scope_ref": reference("scope", "scope"),
        },
    )
    index = index_references(
        graph(snapshot_profile, snapshot_catalog, ledger, scope, inventory)
    )
    assert index.findings == ()
    assert len(index.links) == 4


@pytest.mark.parametrize("criterion_owner", ["source", "decision"])
def test_acceptance_links_bind_feature_and_criterion_without_claiming_readiness(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, criterion_owner: str
) -> None:
    """Criteria may originate from a linked source or decision; approval is separate."""
    criteria = [{"id": "criterion"}]
    feature = artifact(
        "feature-contract",
        "contract",
        fields={
            "feature_id": "feature",
            "acceptance_criteria": criteria if criterion_owner == "source" else [],
        },
    )
    decision = artifact(
        "product-decision",
        "decision",
        fields={
            "resulting_acceptance_criteria": (
                criteria if criterion_owner == "decision" else []
            )
        },
    )
    acceptance = artifact(
        "acceptance-specification",
        "acceptance",
        fields={
            "feature_id": "feature",
            "criterion_id": "criterion",
            "source_contract_refs": [source_reference(feature)],
            "product_decision_refs": [reference("product-decision", "decision")],
        },
    )
    index = index_references(
        graph(snapshot_profile, snapshot_catalog, feature, decision, acceptance)
    )
    assert index.findings == ()
    assert len(index.links) == 2
