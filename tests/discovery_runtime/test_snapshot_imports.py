"""Verify local extension/bootstrap and transported input capture without I/O."""

from __future__ import annotations

import hashlib
import json
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.catalog import CatalogError
from drm_copilot_discovery.path_models import PathPolicyError
from drm_copilot_discovery.profile_v2 import ProfileError
from drm_copilot_discovery.snapshot_loading import load_snapshot

from tests.discovery_runtime.test_profile_v2 import profile_extension_catalog
from tests.discovery_runtime.test_snapshot_io import (
    PROFILE_PATH,
    MemoryStore,
    memory_workspace,
)
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.test_snapshot_loading import put_document
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog


def file_entry(
    path: str, content: bytes, *, kind: str | None = None
) -> dict[str, object]:
    """Create a transport declaration bound to exact bytes in memory."""
    result: dict[str, object] = {
        "path": path,
        "sha256": hashlib.sha256(content).hexdigest(),
        "size": len(content),
    }
    if kind is not None:
        result.update(artifact_kind=kind, id="source-alpha", schema_version="2.0.0")
    return result


def test_extension_schema_bytes_are_captured_before_pinned_catalog_construction(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Configured documentation schemas participate in raw-byte snapshot identity."""
    document, pinned = profile_extension_catalog()
    store = MemoryStore()
    put_document(store, PROFILE_PATH, document)
    extension = pinned.extensions[0]
    store.put(extension.path, extension.content)
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert snapshot.ok and snapshot.catalog.extensions == pinned.extensions
    assert snapshot.file(extension.path).category == "extension-schema"
    assert snapshot.file(extension.path).sha256 == extension.sha256


@pytest.mark.parametrize(
    "path",
    [
        "src/extension.schema.json",
        "docs-else/extension.schema.json",
        "Docs/extension.schema.json",
    ],
)
def test_extension_schema_outside_exact_documentation_roots_is_rejected_before_read(
    path: str, snapshot_catalog: SchemaCatalog
) -> None:
    """Readable source scope cannot grant extension-schema read authority."""
    store, document = memory_workspace()
    document["extension_schemas"] = {
        "example.discovery": {"path": path, "sha256": "a" * 64}
    }
    put_document(store, PROFILE_PATH, document)
    # Avoid a physical alias so this case isolates the stricter lexical root rule.
    if not path.startswith("Docs/"):
        store.put(path, b"must not be read")
    with pytest.raises(PathPolicyError, match="EXTENSION_SCHEMA_ROOT"):
        load_snapshot(
            io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
        )
    assert [path for path, _ in store.calls] == [PROFILE_PATH]


def test_extension_hash_mismatch_and_preextended_bootstrap_are_explicit(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Pin mismatch cannot fall back to an unpinned or caller-supplied schema."""
    document, pinned = profile_extension_catalog()
    store = MemoryStore()
    put_document(store, PROFILE_PATH, document)
    store.put(pinned.extensions[0].path, b"{}")
    with pytest.raises(CatalogError, match="checksum mismatch"):
        load_snapshot(
            io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
        )
    with pytest.raises(ValueError, match="unextended trusted"):
        load_snapshot(io=store.io(), profile_path=PROFILE_PATH, catalog=pinned)


def test_invalid_profile_and_locator_disagreement_stop_before_enumeration(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Bootstrap cannot proceed with malformed policy or conflicting activation."""
    store, _ = memory_workspace()
    store.put(PROFILE_PATH, b"[]")
    with pytest.raises(ProfileError):
        load_snapshot(
            io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
        )
    store, document = memory_workspace()
    put_document(
        store,
        "config/discovery.json",
        {
            "schema_version": "2.0.0",
            "enabled": True,
            "required_runtime_major": 2,
            "profile_path": "docs/else.yaml",
        },
    )
    with pytest.raises(ValueError, match="disagrees with activation"):
        load_snapshot(
            io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
        )
    as_object(document["artifacts"])["profile"] = "docs/else.yaml"
    put_document(store, PROFILE_PATH, document)
    with pytest.raises(ValueError, match="profile artifact location"):
        load_snapshot(
            io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
        )


def test_import_manifest_artifacts_and_payloads_have_one_local_storage_namespace(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Imported identity survives without reading the source checkout."""
    store, document = memory_workspace()
    parent = "docs/migration/discovery/source-snapshots/imported"
    manifest_path = parent + "/manifest.json"
    evidence = load_fixture("evidence-reference")
    evidence.update(path="payload.bin", repository="source-example")
    as_object(evidence["runtime_artifact"])["path"] = "payload.bin"
    content = json.dumps(evidence).encode()
    payload = b"captured source behavior"
    manifest = load_fixture("source-snapshot-manifest")
    as_object(manifest["source_repository"])["id"] = "source-example"
    manifest["artifacts"] = [
        file_entry("evidence.yaml", content, kind="evidence-reference")
    ]
    manifest["payloads"] = [file_entry("payload.bin", payload)]
    put_document(store, manifest_path, manifest)
    store.put(parent + "/evidence.yaml", content)
    store.put(parent + "/payload.bin", payload)
    document["repositories"] = [
        {
            "id": "source-example",
            "role": "legacy-source",
            "revision": "a" * 40,
            "snapshot_manifest": manifest_path,
            "clients": [],
        }
    ]
    put_document(store, PROFILE_PATH, document)
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert snapshot.ok, snapshot.findings
    imported = next(item for item in snapshot.artifacts if item.origin_path)
    assert (
        imported.path == parent + "/evidence.yaml"
        and imported.origin_path == "evidence.yaml"
    )
    assert imported.repository.id == "source-example"
    assert snapshot.file(parent + "/payload.bin").content == payload
    assert snapshot.file(manifest_path).category == "source-snapshot"
    assert not snapshot.repository_files


def test_extension_manifest_captures_result_and_source_bytes_without_execution(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Explicit local adapter output expands into fixed inventory schema validation."""
    store, document = memory_workspace()
    manifest_path = "docs/migration/discovery/inventory/adapter.json"
    result_path = "docs/migration/discovery/inventory/result.yaml"
    inventory = json.dumps(load_fixture("inventory-snapshot")).encode()
    source = b"source input"
    manifest = load_fixture("extension-result-manifest")
    manifest["result_files"] = [
        file_entry(result_path, inventory, kind="inventory-snapshot")
    ]
    manifest["source_inputs"] = [file_entry("src/a.py", source)]
    as_object(document["analyzers"])["extension_result_manifests"] = [manifest_path]
    put_document(store, PROFILE_PATH, document)
    put_document(store, manifest_path, manifest)
    store.put(result_path, inventory)
    store.put("src/a.py", source)
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert snapshot.ok, snapshot.findings
    assert snapshot.file(manifest_path).category == "extension-result"
    assert snapshot.file(result_path).category == "inventory"
    assert snapshot.file("src/a.py").category == "source"


def test_extension_manifest_cannot_expand_source_or_result_read_scope(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Declared source/results cannot redirect reads into unrelated local paths."""
    store, document = memory_workspace()
    manifest_path = "docs/migration/discovery/inventory/adapter.json"
    manifest = load_fixture("extension-result-manifest")
    manifest["result_files"] = [
        file_entry("neighbor/result.json", b"{}", kind="inventory-snapshot")
    ]
    manifest["source_inputs"] = [file_entry("neighbor/source.py", b"source")]
    as_object(document["analyzers"])["extension_result_manifests"] = [manifest_path]
    put_document(store, PROFILE_PATH, document)
    put_document(store, manifest_path, manifest)
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert not snapshot.ok
    assert {finding.code for finding in snapshot.findings} == {"SNAPSHOT_INPUT_SCOPE"}
    assert not any(path.startswith("neighbor") for path, _ in store.calls)


def test_missing_import_bytes_fail_instead_of_accepting_manifest_claims(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A declared immutable artifact cannot be represented by hashes alone."""
    store, _ = memory_workspace()
    manifest = load_fixture("source-snapshot-manifest")
    manifest["artifacts"] = [file_entry("missing.yaml", b"{}", kind="scope")]
    manifest["payloads"] = []
    put_document(
        store,
        "docs/migration/discovery/source-snapshots/imported/manifest.json",
        manifest,
    )
    with pytest.raises(FileNotFoundError, match="missing.yaml"):
        load_snapshot(
            io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
        )


def test_conflicting_import_and_payload_roles_are_blocking(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A manifest or evidence claim cannot relabel another structured artifact."""
    store, _ = memory_workspace()
    parent = "docs/migration/discovery/source-snapshots/imported"
    manifest = load_fixture("source-snapshot-manifest")
    content = json.dumps(load_fixture("scope")).encode()
    manifest["artifacts"] = [file_entry("scope.yaml", content, kind="scope")]
    manifest["payloads"] = [file_entry("scope.yaml", content)]
    put_document(store, parent + "/manifest.json", manifest)
    store.put(parent + "/scope.yaml", content)
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert not snapshot.ok
    assert any(
        finding.code == "SNAPSHOT_ROLE_CONFLICT" for finding in snapshot.findings
    )


def test_loading_can_resolve_installed_catalog_when_no_trusted_instance_is_passed() -> (
    None
):
    """The normal entry point remains usable with the package's offline resources."""
    store, _ = memory_workspace()
    assert load_snapshot(io=store.io(), profile_path=PROFILE_PATH).ok


def test_import_manifest_cannot_reclassify_its_own_storage_path(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Conflicting transport roles block even when both use supported core kinds."""
    store, _ = memory_workspace()
    manifest = load_fixture("source-snapshot-manifest")
    manifest["artifacts"] = [file_entry("manifest.json", b"{}", kind="scope")]
    manifest["payloads"] = []
    put_document(
        store,
        "docs/migration/discovery/source-snapshots/imported/manifest.json",
        manifest,
    )
    snapshot = load_snapshot(
        io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
    )
    assert not snapshot.ok
    assert any(
        finding.code == "SNAPSHOT_ROLE_CONFLICT" for finding in snapshot.findings
    )


def test_related_import_manifest_must_use_configured_transport_root(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A general documentation read grant cannot relocate imported graph storage."""
    store, document = memory_workspace()
    document["repositories"] = [
        {
            "id": "source",
            "role": "legacy-source",
            "revision": "a" * 40,
            "snapshot_manifest": "docs/other/manifest.json",
            "clients": [],
        }
    ]
    put_document(store, PROFILE_PATH, document)
    store.put("docs/other/manifest.json", b"never opened")
    with pytest.raises(PathPolicyError, match="SNAPSHOT_IMPORT_ROOT"):
        load_snapshot(
            io=store.io(), profile_path=PROFILE_PATH, catalog=snapshot_catalog
        )
    assert "docs/other/manifest.json" not in [path for path, _ in store.calls]
