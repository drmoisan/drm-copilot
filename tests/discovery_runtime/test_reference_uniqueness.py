"""Enforce repository/kind identity namespaces and deterministic duplicate failures."""

from __future__ import annotations

import itertools
from dataclasses import FrozenInstanceError, replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.references import index_references

from tests.discovery_runtime.test_references import (
    artifact,
    graph,
    immutable,
    reference,
    source_reference,
)
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2


@pytest.mark.parametrize(
    "kind,alias",
    [
        ("feature-contract", "feature_id"),
        ("runtime-characterization-scenario", "scenario_id"),
        ("acceptance-specification", "scenario_id"),
        ("evidence-reference", "evidence_id"),
        ("product-decision", "decision_id"),
        ("unspecified-behavior", "behavior_id"),
    ],
)
def test_domain_identity_aliases_are_unique_within_repository_and_kind(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str, alias: str
) -> None:
    """Different artifact document IDs cannot conceal duplicate domain identities."""
    first = artifact(kind, "one", fields={alias: "same"})
    second = artifact(kind, "two", fields={alias: "same"})
    index = index_references(graph(snapshot_profile, snapshot_catalog, first, second))
    assert len(index.findings) == 2
    assert all(
        item.code == "DUPLICATE_ID" and item.pointer == f"/{alias}"
        for item in index.findings
    )
    assert len(index.candidates(kind, "same", identity_field=alias)) == 2


def test_duplicate_artifact_ids_block_resolution_even_with_a_path(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """An explicit path cannot authorize one of two duplicate repository identities."""
    first = artifact("feature-contract", "same", path="docs/one.json")
    second = artifact("feature-contract", "same", path="docs/two.json")
    index = index_references(graph(snapshot_profile, snapshot_catalog, first, second))
    result = index.resolve(
        immutable(
            reference("feature-contract", "same", repository="local", path=first.path)
        ),
        source=index.records[0],
        pointer="/link",
    )
    assert [item.code for item in index.findings] == ["DUPLICATE_ID", "DUPLICATE_ID"]
    assert result.findings[0].code == "REFERENCE_AMBIGUOUS"
    assert result.target is None


def test_same_id_in_distinct_kind_and_repository_namespaces_is_valid(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """ID uniqueness is case-sensitive within each repository/kind namespace."""
    values = (
        artifact("feature-contract", "same"),
        artifact("scope", "same"),
        artifact("feature-contract", "same", repository="foreign"),
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, *values))
    assert index.findings == ()
    assert len(index.candidates("feature-contract", "same")) == 2
    assert len(index.candidates("feature-contract", "same", repository="foreign")) == 1
    assert index.candidates("feature-contract", "Same") == ()
    assert index.candidates("scope", "same")[0].kind == "scope"


def test_bare_foreign_id_is_ambiguous_but_explicit_repository_selects_one(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A local match never takes precedence over another repository's same ID."""
    local = artifact("feature-contract", "feature")
    foreign = artifact(
        "feature-contract", "feature", repository="foreign", origin="contracts/a.json"
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, local, foreign))
    source = index.records[0]
    bare = index.resolve(
        immutable(reference("feature-contract", "feature")),
        source=source,
        pointer="/bare",
    )
    pinned = index.resolve(
        immutable(
            reference(
                "feature-contract",
                "feature",
                repository="foreign",
                path="contracts/a.json",
            )
        ),
        source=source,
        pointer="/pinned",
    )
    assert bare.findings[0].code == "REFERENCE_AMBIGUOUS"
    assert pinned.target is not None and pinned.target.artifact == foreign
    assert pinned.findings == ()


@pytest.mark.parametrize(
    "kind,alias",
    [("product-decision", "decision_id"), ("unspecified-behavior", "behavior_id")],
)
def test_collection_members_share_standalone_namespaces_and_keep_container_paths(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str, alias: str
) -> None:
    """Embedded records resolve as ordinary artifacts with exact container pointers."""
    member = {"artifact_kind": kind, "id": "member", alias: "domain"}
    collection = artifact(
        kind + "-collection", "collection", fields={"records": [member]}
    )
    source = artifact(
        "feature-contract",
        "feature",
        fields={
            (
                "product_decision_refs"
                if kind == "product-decision"
                else "unresolved_behavior_refs"
            ): [reference(kind, "member")]
        },
    )
    index = index_references(
        graph(snapshot_profile, snapshot_catalog, collection, source)
    )
    assert index.findings == ()
    target = index.candidates(kind, "member")[0]
    assert target.pointer == "/records/0"
    assert target.artifact == collection
    assert target.document == immutable(member)
    duplicate = artifact(kind, "member", fields={alias: "other"})
    duplicates = index_references(
        graph(snapshot_profile, snapshot_catalog, collection, duplicate)
    )
    assert {item.pointer for item in duplicates.findings} == {"/id", "/records/0/id"}
    assert all(item.code == "DUPLICATE_ID" for item in duplicates.findings)


def test_collection_member_links_and_invalid_member_headers_use_full_pointers(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Collection diagnostics retain member context for links and identities."""
    collection = artifact(
        "product-decision-collection",
        "collection",
        fields={
            "records": [
                {
                    "artifact_kind": "product-decision",
                    "id": "valid",
                    "feature_refs": [reference("feature-contract", "missing")],
                },
                {"artifact_kind": "scope", "id": "wrong"},
                {"artifact_kind": "product-decision", "id": None},
                None,
            ]
        },
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, collection))
    assert [(item.code, item.pointer) for item in index.findings] == [
        ("REFERENCE_MISSING", "/records/0/feature_refs/0"),
        ("ARTIFACT_KIND", "/records/1/artifact_kind"),
        ("ARTIFACT_ID", "/records/2/id"),
    ]


@pytest.mark.parametrize(
    "field,identity,kind",
    [
        ("runs", "id", "runtime-characterization-scenario"),
        ("observation_plan", "id", "runtime-characterization-scenario"),
        ("acceptance_criteria", "id", "feature-contract"),
        ("entries", "id", "parity-matrix"),
        ("components", "component_id", "inventory-snapshot"),
        ("findings", "finding_id", "inventory-snapshot"),
        ("relationships", "relationship_id", "inventory-snapshot"),
        ("diagnostics", "id", "inventory-snapshot"),
        ("alternatives", "id", "product-decision"),
        ("resulting_acceptance_criteria", "id", "product-decision"),
        ("competing_interpretations", "id", "unspecified-behavior"),
    ],
)
def test_collection_record_ids_reject_duplicates_with_different_content(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    identity: str,
    kind: str,
) -> None:
    """Different row bodies do not make duplicate record IDs unique."""
    value = artifact(
        kind,
        "artifact",
        fields={
            field: [
                {identity: "same", "description": "one"},
                {identity: "same", "description": "two"},
            ]
        },
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, value))
    assert [(item.code, item.pointer) for item in index.findings] == [
        ("DUPLICATE_RECORD_ID", f"/{field}/1/{identity}")
    ]


def test_nested_record_ids_are_local_to_their_parent_artifact(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Unrelated contracts can each use their own criterion and transition ID."""
    values = tuple(
        artifact(
            "feature-contract",
            name,
            fields={
                "acceptance_criteria": [{"id": "criterion"}],
                "state_transitions": {"entries": [{"id": "transition"}]},
            },
        )
        for name in ("one", "two")
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, *values))
    assert index.findings == ()
    assert len(index.records) == 2


def test_diagnostic_order_and_targets_are_invariant_under_artifact_permutations(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Every artifact arrival order produces the same duplicate diagnostics."""
    values = (
        artifact("feature-contract", "same", path="docs/a.json"),
        artifact("feature-contract", "same", path="docs/b.json"),
        artifact(
            "runtime-characterization-scenario",
            "scenario",
            fields={"feature_refs": [reference("feature-contract", "same")]},
        ),
    )
    expected = index_references(graph(snapshot_profile, snapshot_catalog, *values))
    # Exhaust the small input permutation set without global state or random seeds.
    for permutation in itertools.permutations(values):
        actual = index_references(
            graph(snapshot_profile, snapshot_catalog, *permutation)
        )
        assert actual == expected
    assert expected.findings[0].related_paths == ("docs/a.json", "docs/b.json")


def test_index_snapshots_do_not_share_mutable_documents_or_findings(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A later independently built graph cannot mutate previously resolved records."""
    original = index_references(
        graph(
            snapshot_profile, snapshot_catalog, artifact("feature-contract", "feature")
        )
    )
    changed = index_references(
        graph(
            snapshot_profile,
            snapshot_catalog,
            artifact("feature-contract", "different"),
        )
    )
    assert original.records[0].id == "feature"
    assert changed.records[0].id == "different"
    with pytest.raises(FrozenInstanceError):
        object.__getattribute__(original, "__setattr__")("records", ())
    with pytest.raises(TypeError):
        cast("dict[str, object]", original.records[0].document)["id"] = "changed"


def test_foreign_storage_path_cannot_replace_the_source_origin(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Qualified source contracts are checked against original repository paths."""
    target = artifact(
        "feature-contract",
        "contract",
        repository="foreign",
        origin="source/contract.json",
        fields={"feature_id": "feature"},
    )
    source = artifact(
        "parity-matrix",
        "parity",
        fields={
            "entries": [
                {
                    "id": "row",
                    "source_contract_ref": {
                        **source_reference(target),
                        "artifact_path": target.path,
                    },
                }
            ]
        },
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, target, source))
    assert [item.code for item in index.findings] == ["REFERENCE_PATH"]


def test_invalid_header_cannot_index_under_its_self_selected_kind(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """The configured snapshot kind remains authoritative when a document lies."""
    invalid = artifact("feature-contract", "feature", fields={"artifact_kind": "scope"})
    missing_id = replace(
        artifact("scope", "scope"), document=immutable({"artifact_kind": "scope"})
    )
    index = index_references(
        graph(snapshot_profile, snapshot_catalog, invalid, missing_id)
    )
    assert index.records == ()
    assert {item.code for item in index.findings} == {"ARTIFACT_KIND", "ARTIFACT_ID"}


@pytest.mark.parametrize(
    "field,value,pointer",
    [
        (
            "findings",
            [{"finding_id": "finding", "component_id": "missing"}],
            "/findings/0/component_id",
        ),
        (
            "relationships",
            [{"relationship_id": "link", "from_component_id": "missing"}],
            "/relationships/0/from_component_id",
        ),
        (
            "relationships",
            [{"relationship_id": "link", "to_component_id": "missing"}],
            "/relationships/0/to_component_id",
        ),
        ("files", [{"diagnostic_ids": ["missing"]}], "/files/0/diagnostic_ids/0"),
    ],
)
def test_inventory_scalar_links_require_existing_local_records(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: object,
    pointer: str,
) -> None:
    """A declared scalar inventory link cannot silently remain unresolved."""
    index = index_references(
        graph(
            snapshot_profile,
            snapshot_catalog,
            artifact("inventory-snapshot", "inventory", fields={field: value}),
        )
    )
    assert [(finding.code, finding.pointer) for finding in index.findings] == [
        ("REFERENCE_LINKAGE", pointer)
    ]


@pytest.mark.parametrize(
    "kind,fields,pointer",
    [
        ("scope", {"included_components": ["missing"]}, "/included_components/0"),
        (
            "coverage-ledger",
            {"components": [{"component_id": "missing"}]},
            "/components/0/component_id",
        ),
        (
            "parity-matrix",
            {"entries": [{"id": "row", "feature_id": "missing"}]},
            "/entries/0/feature_id",
        ),
    ],
)
def test_selectors_cannot_use_unlinked_global_artifacts(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    kind: str,
    fields: dict[str, object],
    pointer: str,
) -> None:
    """Missing declared context remains a blocker even when another inventory exists."""
    unused = artifact(
        "inventory-snapshot",
        "unlinked",
        fields={"components": [{"component_id": "missing"}]},
    )
    index = index_references(
        graph(
            snapshot_profile,
            snapshot_catalog,
            artifact(kind, "source", fields=fields),
            unused,
        )
    )
    assert [(finding.code, finding.pointer) for finding in index.findings] == [
        ("REFERENCE_LINKAGE", pointer)
    ]


def test_unknown_extensions_and_action_payloads_cannot_create_graph_authority(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Reference-shaped domain payloads and fake record IDs remain opaque."""
    fake = {
        "id": "repeat",
        "evidence_refs": [reference("evidence-reference", "absent")],
    }
    source = artifact(
        "runtime-characterization-scenario",
        "scenario",
        fields={
            "extensions": {"domain.example": {"entries": [fake, fake]}},
            "action": {
                "inputs": [{"name": "payload", "value": {"entries": [fake, fake]}}]
            },
            "unknown": fake,
            "pre_state_capture": None,
        },
    )
    index = index_references(graph(snapshot_profile, snapshot_catalog, source))
    assert index.findings == ()
    assert index.links == ()
    assert len(index.records) == 1


def test_unparseable_and_identityless_reports_retain_loading_failures(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Index construction does not manufacture identities or clear loader findings."""
    from drm_copilot_discovery.findings import Finding

    invalid = replace(artifact("scope", "bad"), document=None)
    report = replace(
        artifact("migration-report", "report"), document=immutable({"counts": {}})
    )
    snapshot = replace(
        graph(snapshot_profile, snapshot_catalog, invalid, report),
        findings=(
            Finding(
                code="PARSE_INVALID",
                message="Invalid source.",
                next_action="Correct input.",
            ),
        ),
    )
    index = index_references(snapshot)
    assert index.records == ()
    assert index.findings == snapshot.findings
