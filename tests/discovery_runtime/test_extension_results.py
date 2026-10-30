"""Check inert extension schema, integrity, source and identity boundaries in memory."""

from __future__ import annotations

import hashlib
import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.findings import row
from drm_copilot_discovery.analyzer.input_capture import capture_snapshot
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.extension_inputs import (
    extension_input_digest,
    extension_manifest_digest,
)
from drm_copilot_discovery.extension_results import (
    ExtensionResultError,
    validate_extension_results,
)
from drm_copilot_discovery.models import JsonObject, canonical_json, to_plain_value
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import DiscoverySnapshot, SnapshotFile

from tests.discovery_runtime.analyzer.test_repository import (
    analyzer_catalog as analyzer_catalog,
)
from tests.discovery_runtime.analyzer.test_repository import inventory_profile
from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.validation_test_support import captured
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog

MANIFEST = "docs/migration/discovery/inventory/extension.json"
MEMBER = "docs/migration/discovery/inventory/member.json"
ADAPTER = row(id="local-example", version="7.1")
AUTHOR = row(kind="agent", id="synthetic")
STAMP = "2026-01-01T00:00:00Z"


def extension_snapshot(catalog: SchemaCatalog) -> DiscoverySnapshot:
    """Return a pinned source/docs bundle using catalog (SchemaCatalog).

    Returns DiscoverySnapshot; malformed fixture data raises ValueError.
    Allocates isolated immutable test data without I/O or input mutation.
    """
    profile = inventory_profile(
        catalog,
        analyzers={
            "enabled": ["repository"],
            "options": {},
            "ignored_paths": [],
            "extension_result_manifests": [MANIFEST],
        },
    )
    source = SnapshotFile(
        path="src/main.cs", content=b"class Example {}\r\n", category="source"
    )
    docs = SnapshotFile(
        path="docs/guide.md", content="Guide é\n".encode(), category="documentation"
    )
    snapshot = captured(profile, catalog, payloads=(source, docs))
    identity = RepositoryIdentity(
        id=profile.repository.id, revision=profile.repository.revision
    )
    snapshot = replace(
        snapshot,
        repository_files=(
            RepositoryFile(
                repository=identity, path=source.path, content=source.content
            ),
            RepositoryFile(repository=identity, path=docs.path, content=docs.content),
        ),
    )
    capture = capture_snapshot(snapshot)
    reference = row(
        repository=identity.id,
        revision=identity.revision,
        path=source.path,
        sha256=source.sha256,
    )
    component = row(
        component_id="local-component",
        component_type="type",
        source=reference,
        analyzer=ADAPTER,
        classification="inferred",
        confidence="low",
        properties=(),
        extensions=row(),
    )
    finding = row(
        finding_id="local-finding",
        component_id="local-component",
        kind="mention",
        source=reference,
        analyzer=ADAPTER,
        classification="inferred",
        confidence="unknown",
        properties=(),
        extensions=row(),
    )
    relationship = row(
        relationship_id="local-relation",
        from_component_id="local-component",
        to_component_id=None,
        target_description="Unresolved target",
        kind="relevance",
        source=reference,
        analyzer=ADAPTER,
        classification="inferred",
        confidence="low",
        extensions=row(),
    )
    result = inventory_result(
        capture,
        (
            Analysis(
                components=(component,),
                findings=(finding,),
                relationships=(relationship,),
            ),
        ),
        analyzer_ids=(),
        extension_adapters=(ADAPTER,),
        timestamp=STAMP,
        author_or_agent=AUTHOR,
        catalog=catalog,
    )
    values = as_object(to_plain_value(result.document))
    values["tool"] = to_plain_value(ADAPTER)
    content = canonical_json(immutable(values))
    manifest = row(
        **{"$schema": "urn:drm-copilot:discovery:2.0.0:extension-result-manifest"},
        schema_version="2.0.0",
        artifact_kind="extension-result-manifest",
        id="local-manifest",
        adapter=ADAPTER,
        repository=row(id=identity.id, revision=identity.revision),
        input_manifest_sha256=extension_input_digest(capture),
        source_inputs=(
            row(path=source.path, sha256=source.sha256, size=len(source.content)),
        ),
        result_files=(
            row(
                artifact_kind="inventory-snapshot",
                id=result.document["id"],
                schema_version="2.0.0",
                path=MEMBER,
                sha256=hashlib.sha256(content).hexdigest(),
                size=len(content),
            ),
        ),
        manifest_sha256="0" * 64,
        generated_at=STAMP,
        generated_by=AUTHOR,
        diagnostics=(),
        extensions=row(),
    )
    # The signed transport digest excludes exactly its own root field.
    manifest = JsonObject(
        tuple(
            (
                key,
                (
                    extension_manifest_digest(manifest)
                    if key == "manifest_sha256"
                    else value
                ),
            )
            for key, value in manifest.members
        )
    )
    return replace(
        snapshot,
        manifest=replace(
            snapshot.manifest,
            files=snapshot.manifest.files
            + (
                SnapshotFile(
                    path=MANIFEST,
                    content=canonical_json(manifest),
                    category="extension-result",
                ),
                SnapshotFile(path=MEMBER, content=content, category="inventory"),
            ),
        ),
    )


@pytest.fixture(scope="module")
def bundle(analyzer_catalog: SchemaCatalog) -> DiscoverySnapshot:
    """Return read-only DiscoverySnapshot from analyzer_catalog (SchemaCatalog).

    Module-scoped immutable data is safe to share; invalid fixture construction
    raises ValueError. No external effects or mutable shared state are introduced.
    """
    return extension_snapshot(analyzer_catalog)


def documents(
    snapshot: DiscoverySnapshot,
) -> tuple[dict[str, object], dict[str, object]]:
    """Detach manifest/member dictionaries from snapshot (DiscoverySnapshot).

    Returns tuple[dict[str, object], dict[str, object]]; missing fixture bytes
    raise AssertionError. Allocates local fault-injection copies without I/O.
    """
    manifest, member = snapshot.file(MANIFEST), snapshot.file(MEMBER)
    assert manifest is not None and member is not None
    return as_object(json.loads(manifest.content)), as_object(
        json.loads(member.content)
    )


def edit_bundle(
    snapshot: DiscoverySnapshot,
    manifest: dict[str, object],
    member: dict[str, object],
    *,
    seal: bool = True,
    bind: bool = True,
) -> DiscoverySnapshot:
    """Return a resealed DiscoverySnapshot from isolated test dictionaries.

    snapshot (DiscoverySnapshot) stays unchanged. manifest/member (dict[str, object])
    are local copies; seal/bind (bool) control deliberate integrity faults.
    Mutates those dictionaries only; invalid fixture shapes raise ValueError. No I/O.
    """
    content = canonical_json(immutable(member))
    if bind:
        refs = cast("list[object]", manifest["result_files"])
        if refs:
            as_object(refs[0]).update(
                sha256=hashlib.sha256(content).hexdigest(), size=len(content)
            )
    if seal:
        manifest["manifest_sha256"] = extension_manifest_digest(immutable(manifest))
    replacements = {MANIFEST: canonical_json(immutable(manifest)), MEMBER: content}
    # Preserve every unrelated captured stream while replacing exact selected bytes.
    files = tuple(
        replace(file, content=replacements.get(file.path, file.content))
        for file in snapshot.manifest.files
    )
    return replace(snapshot, manifest=replace(snapshot.manifest, files=files))


def set_field(
    document: dict[str, object], path: tuple[str | int, ...], value: object
) -> None:
    """Change one leaf in document (dict[str, object]); return None.

    path (tuple[str | int, ...]) selects the leaf; value (object) replaces it.
    Invalid fixture paths raise KeyError/IndexError. Mutates only this local copy.
    """
    cursor: object = document
    # Explicit paths keep parameterized negative cases readable without executable
    # expressions.
    for part in path[:-1]:
        cursor = (
            cast("list[object]", cursor)[part]
            if isinstance(part, int)
            else as_object(cursor)[part]
        )
    leaf = path[-1]
    if isinstance(leaf, int):
        cast("list[object]", cursor)[leaf] = value
    else:
        as_object(cursor)[leaf] = value


def test_valid_bundle_preserves_versions_uncertainty_and_bytes(
    bundle: DiscoverySnapshot,
) -> None:
    """Preserve exact bytes and inference from bundle (DiscoverySnapshot).

    Returns None; assertions detect carrier/confidence changes. Pure in-memory test.
    """
    first = validate_extension_results(bundle)
    assert first == validate_extension_results(bundle, manifest_paths=(MANIFEST,))
    assert first[0].adapter == ADAPTER
    assert first[0].result_files == (bundle.file(MEMBER),)
    assert first[0].analysis.components[0]["confidence"] == "low"
    assert first[0].analysis.findings[0]["confidence"] == "unknown"
    assert first[0].analysis.relationships[0]["to_component_id"] is None
    assert validate_extension_results(bundle, manifest_paths=()) == ()


@pytest.mark.parametrize(
    ("target", "path", "value", "code"),
    [
        ("manifest", ("schema_version",), "3.0.0", "SCHEMA"),
        ("manifest", ("module",), "untrusted.module", "SCHEMA"),
        ("manifest", ("adapter", "id"), "repository", "IDENTITY"),
        ("manifest", ("repository", "revision"), "b" * 40, "SOURCE"),
        ("manifest", ("input_manifest_sha256",), "f" * 64, "DIGEST"),
        ("manifest", ("source_inputs",), [], "SOURCE"),
        ("manifest", ("source_inputs", 0, "path"), "docs/guide.md", "SOURCE"),
        ("manifest", ("source_inputs", 0, "size"), 0, "SOURCE"),
        ("manifest", ("result_files", 0, "path"), "src/member.json", "PATH"),
        ("manifest", ("result_files", 0, "path"), "../member.json", "SCHEMA"),
        ("manifest", ("result_files", 0, "id"), "wrong-id", "MEMBER"),
        ("member", ("repository",), "other", "DIGEST"),
        ("member", ("revision",), "b" * 40, "DIGEST"),
        ("member", ("scan_configuration_sha256",), "f" * 64, "DIGEST"),
        ("member", ("analyzers", 0, "version"), "8", "IDENTITY"),
        ("member", ("tool", "id"), "repository", "IDENTITY"),
        ("member", ("components", 0, "analyzer", "version"), "8", "IDENTITY"),
        ("member", ("components", 0, "source", "sha256"), "f" * 64, "SOURCE"),
        ("member", ("components", 0, "source", "revision"), "b" * 40, "SOURCE"),
        ("member", ("components", 0, "source", "path"), "docs/guide.md", "SOURCE"),
        ("member", ("components", 0, "classification"), "verified", "SCHEMA"),
        ("member", ("components", 0, "confidence"), "verified", "SCHEMA"),
        (
            "member",
            ("components", 0, "source", "line_range"),
            {"start": 1, "end": 2},
            "SOURCE",
        ),
        (
            "member",
            ("components", 0, "source", "line_range"),
            {"start": 2, "end": 1},
            "SOURCE",
        ),
        ("member", ("findings", 0, "component_id"), "missing", "REFERENCE"),
        ("member", ("relationships", 0, "to_component_id"), "missing", "REFERENCE"),
        ("member", ("files",), [], "ACCOUNTING"),
        ("member", ("files", 0, "size"), 999, "ACCOUNTING"),
        ("member", ("files", 0, "path"), "docs/other.md", "ACCOUNTING"),
        ("member", ("files", 0, "diagnostic_ids"), ["missing"], "ACCOUNTING"),
        ("member", ("exclusions",), [], "ACCOUNTING"),
        (
            "member",
            ("components", 0, "properties"),
            [{"name": "x", "value": 1}, {"name": "x", "value": 2}],
            "COLLISION",
        ),
    ],
)
def test_invalid_claims_fail_closed(
    bundle: DiscoverySnapshot,
    target: str,
    path: tuple[str | int, ...],
    value: object,
    code: str,
) -> None:
    """Reject a resealed claim fault in bundle (DiscoverySnapshot); return None.

    target (str), path (tuple[str | int, ...]), value (object) locate the fault;
    code (str) names the expected ExtensionResultError. Only local copies mutate;
    assertions detect incorrect rejection or leaked partial output. No I/O.
    """
    manifest, member = documents(bundle)
    # Schema/integrity cases intentionally target different layers of the same
    # transport.
    set_field(manifest if target == "manifest" else member, path, value)
    changed = edit_bundle(bundle, manifest, member)
    with pytest.raises(ExtensionResultError) as failure:
        validate_extension_results(changed)
    assert failure.value.code == "EXTENSION_" + code


@pytest.mark.parametrize(
    "selection", [[MANIFEST], (MANIFEST, MANIFEST), ("absent.json",), (True,)]
)
def test_selection_is_an_explicit_configured_tuple(
    bundle: DiscoverySnapshot, selection: object
) -> None:
    """Reject selection (object) against bundle (DiscoverySnapshot); return None.

    Expects EXTENSION_SELECTION; assertion failure detects accepted malformed input.
    Uses immutable memory data without reads or input mutation.
    """
    with pytest.raises(ExtensionResultError, match="EXTENSION_SELECTION"):
        validate_extension_results(
            bundle, manifest_paths=cast("tuple[str, ...]", selection)
        )


def test_line_ranges_share_cached_physical_bounds(bundle: DiscoverySnapshot) -> None:
    """Check repeated CRLF anchors in bundle (DiscoverySnapshot); return None.

    Mutates detached fixture rows only; assertions detect mismatched source bounds.
    No retained input bytes or external state change.
    """
    manifest, member = documents(bundle)
    # All three row families share one independently hashed physical source.
    for family in ("components", "findings", "relationships"):
        set_field(member, (family, 0, "source", "line_range"), {"start": 1, "end": 1})
    result = validate_extension_results(edit_bundle(bundle, manifest, member))
    assert (
        result[0].analysis.components[0]["source"]
        == result[0].analysis.findings[0]["source"]
    )


def test_generic_artifact_capture_remains_compatible(bundle: DiscoverySnapshot) -> None:
    """Check generic labels for bundle (DiscoverySnapshot); return None.

    Creates immutable local replacements; assertions detect changed validation.
    No input mutation or I/O occurs.
    """
    # Older immutable captures use a generic label for these same exact documents.
    files = tuple(
        replace(file, category="artifact") if file.path in {MANIFEST, MEMBER} else file
        for file in bundle.manifest.files
    )
    changed = replace(bundle, manifest=replace(bundle.manifest, files=files))
    assert (
        validate_extension_results(changed)[0].analysis
        == validate_extension_results(bundle)[0].analysis
    )


def test_unexplained_capture_exclusion_has_fixed_input_error(
    bundle: DiscoverySnapshot,
) -> None:
    """Reject an unexplained omission from bundle (DiscoverySnapshot); return None.

    Expects EXTENSION_INPUT and asserts path redaction. Uses local memory only.
    """
    with pytest.raises(ExtensionResultError, match="EXTENSION_INPUT") as failure:
        validate_extension_results(replace(bundle, excluded_paths=("unexplained",)))
    assert "unexplained" not in str(failure.value)
