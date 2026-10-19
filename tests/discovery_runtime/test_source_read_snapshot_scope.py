"""Verify selected snapshot integrity stays inside configured read authority."""

from __future__ import annotations

import json
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.profile_v2 import parse_profile_v2
from drm_copilot_discovery.source_read_models import (
    ReadGrant,
    ReadSelection,
    SelectedManifest,
    SourceReadLimits,
    SourceReadRequest,
)

from tests.discovery_runtime.source_snapshot_test_support import (
    changed_header,
    unit_transport,
)
from tests.discovery_runtime.test_profile_v2 import profile_document
from tests.discovery_runtime.test_snapshot_io import MemoryStore
from tests.discovery_runtime.test_source_reads import make_reader
from tests.discovery_runtime.test_source_reads import read_catalog as read_catalog
from tests.discovery_runtime.test_source_reads import read_profile as read_profile
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.transport_manifest import TransportRoute


def install_transport(store: MemoryStore, route: TransportRoute) -> ReadSelection:
    """Populate MemoryStore using TransportRoute; return explicit ReadSelection.
    Mutate only the provided in-memory store; no physical writes.
    """
    # The accepted transport helper declares and hashes every member.
    for member in route.members:
        store.put(
            member.grant.path,
            route.manifest.content if member.origin is None else b"{}",
        )
    return ReadSelection(
        grants=(ReadGrant(path=route.manifest.path.rsplit("/", 1)[0], directory=True),),
        manifests=(
            SelectedManifest(path=route.manifest.path, sha256=route.manifest.sha256),
        ),
    )


def test_imported_member_requires_complete_transport_and_retains_original_identity(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Read a selected member only after all declared bytes validate, then keep pin.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store, route = MemoryStore(), unit_transport(read_catalog)
    selection = install_transport(store, route)
    path = route.members[0].grant.path
    exact = replace(selection, grants=(ReadGrant(path=path),))
    result = make_reader(store, read_profile, read_catalog, selection=exact).inspect(
        SourceReadRequest(operation="read", paths=(path,))
    )
    evidence = result.items[0].evidence
    assert evidence.path == route.members[0].origin and evidence.workspace_path == path
    assert evidence.repository == route.source
    assert (
        evidence.provenance == "snapshot-member"
        and evidence.manifest_sha256 == route.manifest.sha256
    )
    assert {read_path for read_path, _ in store.calls} == {
        member.grant.path for member in route.members
    }
    assert len(result.items) == 1


def test_snapshot_listing_and_envelope_do_not_claim_envelope_bytes_at_source_pin(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Reuse the validated route while keeping envelope provenance local.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store, route = MemoryStore(), unit_transport(read_catalog)
    selection = install_transport(store, route)
    result = make_reader(
        store, read_profile, read_catalog, selection=selection
    ).inspect(SourceReadRequest(operation="list", paths=(selection.grants[0].path,)))
    # Select the envelope separately because it cannot inherit member provenance.
    envelope = next(
        item
        for item in result.items
        if item.evidence.workspace_path == route.manifest.path
    )
    assert envelope.evidence.provenance == "snapshot-manifest"
    assert envelope.evidence.repository.revision is None
    assert result.total == len(route.members)


@pytest.mark.parametrize(
    "fault", ("unselected", "header-hash", "member-hash", "unlisted", "missing-member")
)
def test_snapshot_failures_cannot_fall_through_broad_documentation_roots(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    fault: str,
) -> None:
    """Reject one local transport fault; never read an unlisted requested member.
    ProfileV2/SchemaCatalog fixtures; fault:str; None; memory only."""
    store, route = MemoryStore(), unit_transport(read_catalog)
    selection = install_transport(store, route)
    path = route.members[0].grant.path
    # Alter one authorization or integrity input without changing accepted schemas.
    if fault == "unselected":
        selection = replace(selection, manifests=())
    elif fault == "header-hash":
        selection = replace(
            selection, manifests=(replace(selection.manifests[0], sha256="0" * 64),)
        )
    elif fault == "member-hash":
        store.put(route.members[1].grant.path, b"[]")
    elif fault == "missing-member":
        store.metadata.remove(route.members[1].grant.path)
    else:
        path = selection.grants[0].path + "/unlisted.txt"
        store.put(path, b"secret")
    with pytest.raises((ValueError, OSError)):
        make_reader(store, read_profile, read_catalog, selection=selection).inspect(
            SourceReadRequest(operation="read", paths=(path,))
        )
    if fault in {"unselected", "unlisted"}:
        assert path not in {read_path for read_path, _ in store.calls}


@pytest.mark.parametrize("selected_file", ("manifest.json", "contracts/alpha.json"))
def test_manifest_and_every_integrity_member_require_configured_read_scope(
    read_catalog: SchemaCatalog,
    selected_file: str,
) -> None:
    """An exact project input cannot authorize its sibling integrity files.
    SchemaCatalog fixtures; selected_file:str; None; memory only."""
    store, route = MemoryStore(), unit_transport(read_catalog)
    root, path = "build/transport", "build/transport/" + selected_file
    document = profile_document()
    document["project_entry_points"] = [path]
    profile = parse_profile_v2(json.dumps(document), catalog=read_catalog)
    store.put(root + "/manifest.json", route.manifest.content)
    store.put(root + "/contracts/alpha.json", b"{}")
    selection = ReadSelection(
        grants=(ReadGrant(path=path),),
        manifests=(
            SelectedManifest(
                path=root + "/manifest.json", sha256=route.manifest.sha256
            ),
        ),
    )
    with pytest.raises(ValueError, match="outside configured read scope"):
        make_reader(store, profile, read_catalog, selection=selection).inspect(
            SourceReadRequest(operation="read", paths=(path,))
        )
    assert "build/transport/contracts/alpha.json" not in {
        item[0] for item in store.calls
    }


@pytest.mark.parametrize(
    "fault",
    ("aggregate", "members", "declared-size", "invalid-header", "directory-member"),
)
def test_snapshot_integrity_reads_apply_bounds_to_every_member(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
    fault: str,
) -> None:
    """Validate a selected transport under independent byte and member limits.
    ProfileV2/SchemaCatalog fixtures; fault:str; None; memory only."""
    store, route = MemoryStore(), unit_transport(read_catalog)
    selection = install_transport(store, route)
    path, limits = route.members[0].grant.path, SourceReadLimits()
    # Retain exact header selection while altering only the targeted limit/fault.
    if fault == "aggregate":
        limits = replace(limits, input_bytes=len(route.manifest.content) + 3)
    elif fault == "directory-member":
        store.metadata.remove(route.members[1].grant.path)
        store.metadata.add(route.members[1].grant.path + "/child")
    else:
        document = as_object(json.loads(route.manifest.content))
        artifacts = cast("list[dict[str, object]]", document["artifacts"])
        if fault == "members":
            # More declared payloads than metadata ancestors reach the member bound.
            artifacts = [
                dict(artifacts[0], id=f"member-{index}", path=f"records/{index}.json")
                for index in range(12)
            ]
            limits = replace(limits, entries=12)
        else:
            artifacts[0]["size"] = 1048577 if fault == "declared-size" else -1
        transport = as_object(document["transport"])
        transport["artifact_count"] = len(artifacts)
        content = changed_header(
            route, {"artifacts": artifacts, "transport": transport}
        )
        store.put(route.manifest.path, content)
        selection = replace(
            selection,
            manifests=(
                SelectedManifest(
                    path=route.manifest.path, sha256=sha256(content).hexdigest()
                ),
            ),
        )
    with pytest.raises((ValueError, OSError)):
        make_reader(
            store, read_profile, read_catalog, selection=selection, limits=limits
        ).inspect(SourceReadRequest(operation="read", paths=(path,)))


def test_nested_selected_manifests_are_ambiguous_before_any_byte_read(
    read_profile: ProfileV2,
    read_catalog: SchemaCatalog,
) -> None:
    """Reject two possible original identities for one selected member path.
    ProfileV2/SchemaCatalog fixtures; None; memory only."""
    store, route = MemoryStore(), unit_transport(read_catalog)
    selection = install_transport(store, route)
    parent = route.manifest.path.rsplit("/", 2)[0] + "/manifest.json"
    selection = replace(
        selection,
        manifests=(
            *selection.manifests,
            SelectedManifest(path=parent, sha256="a" * 64),
        ),
    )
    with pytest.raises(ValueError, match="one selected manifest"):
        make_reader(store, read_profile, read_catalog, selection=selection).inspect(
            SourceReadRequest(operation="read", paths=(route.members[0].grant.path,))
        )
    assert store.calls == []


@pytest.mark.parametrize("excluded_kind", ("header", "integrity-sibling"))
def test_excluded_snapshot_integrity_inputs_are_rejected_before_byte_capture(
    read_catalog: SchemaCatalog,
    excluded_kind: str,
) -> None:
    """Reject an excluded header or unrequested integrity sibling before reading it.
    SchemaCatalog fixture and str excluded_kind select one isolated profile fault;
    return None after asserting no excluded/target byte reads or store mutation.
    """
    store, route = MemoryStore(), unit_transport(read_catalog)
    selection = install_transport(store, route)
    path = route.members[0].grant.path
    # Both integrity inputs require profile scope without requiring output grants.
    excluded = (
        route.manifest.path
        if excluded_kind == "header"
        else route.members[1].grant.path
    )
    document = profile_document()
    document["excluded_paths"] = [
        {"path_or_glob": excluded, "rationale": "Explicitly excluded integrity input."}
    ]
    profile = parse_profile_v2(json.dumps(document), catalog=read_catalog)
    original = dict(store.files)
    exact = replace(selection, grants=(ReadGrant(path=path),))

    with pytest.raises(ValueError, match="outside configured read scope"):
        make_reader(store, profile, read_catalog, selection=exact).inspect(
            SourceReadRequest(operation="read", paths=(path,))
        )

    # Compare observed reads with profile authority independently of returned data.
    read_paths = {read_path for read_path, _ in store.calls}
    assert excluded not in read_paths and path not in read_paths
    assert store.files == original
    # An excluded header denies the entire transport before any byte read.
    if excluded_kind == "header":
        assert store.calls == []
    else:
        assert read_paths == {route.manifest.path}
