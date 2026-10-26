"""Exercise the complete offline catalog with immutable resources and memory stores."""

from __future__ import annotations

import hashlib
import json
import sys
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.catalog import (
    DIALECT,
    V1_KINDS,
    V2_KINDS,
    V2_URN,
    CatalogError,
    ExtensionSchema,
    SchemaCatalog,
    load_catalog,
    schema_aliases,
    schema_path,
)
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.resources import read_resource, render_resource_manifest
from referencing.exceptions import Unresolvable

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch


def _extension(schema: dict[str, object], **overrides: object) -> ExtensionSchema:
    """Bind a fresh synthetic local extension to its exact serialized bytes."""
    content = json.dumps({"$schema": DIALECT, **schema}).encode()
    values = {
        "namespace": "example.domain",
        "path": "docs/Extension Schema.json",
        "sha256": hashlib.sha256(content).hexdigest(),
        "content": content,
        **overrides,
    }
    return ExtensionSchema(
        namespace=cast("str", values["namespace"]),
        path=cast("str", values["path"]),
        sha256=cast("str", values["sha256"]),
        content=cast("bytes", values["content"]),
    )


def _store() -> dict[str, bytes]:
    """Copy immutable packaged schemas into a fresh injectable resource store."""
    # Populate only known immutable resources; fault injection modifies this copy.
    resources = {
        schema_path(kind, version): read_resource(schema_path(kind, version))
        for version, kinds in (("1.0.0", V1_KINDS), ("2.0.0", V2_KINDS))
        for kind in kinds
    }
    return {**resources, "manifest.json": render_resource_manifest(resources)}


def _replace_schema(
    catalog: SchemaCatalog,
    identifier: str,
    schema: dict[str, object],
) -> SchemaCatalog:
    """Retain all catalog identities while probing one supplied schema boundary."""
    parsed = parse_document(json.dumps(schema), format="json")
    assert isinstance(parsed.value, JsonObject)
    # Keep every unrelated catalog document intact for a targeted negative probe.
    return replace(
        catalog,
        documents=tuple(
            (key, parsed.value if key == identifier else value)
            for key, value in catalog.documents
        ),
    )


def test_complete_catalog_and_all_registered_aliases_are_fresh_and_offline() -> None:
    """Every supported version resolves; returned dictionaries cannot alter schemas."""
    catalog = load_catalog()

    assert len(catalog.documents) == 34
    # Exercise all exact version identities instead of sampling one schema family.
    for version, kinds in (("1.0.0", V1_KINDS), ("2.0.0", V2_KINDS)):
        # Common definitions intentionally cannot be selected as an artifact validator.
        for kind in kinds:
            if kind == "common":
                continue
            expected = catalog.schema(expected_kind=kind, expected_version=version)
            # Every historical spelling binds the same fixed schema without path I/O.
            for alias in schema_aliases(kind, version):
                assert catalog.schema_for_alias(alias) == expected
            expected.clear()
            assert catalog.schema(expected_kind=kind, expected_version=version)


@pytest.mark.parametrize(
    ("kind", "version"),
    [
        ("feature-contract", "1.2.0"),
        ("feature-contract", "2.0"),
        ("feature-contract", "2.0.0\n"),
        ("missing", "2.0.0"),
        ("common", "2.0.0"),
        ("domain-profile", "1.0.0"),
    ],
)
def test_catalog_rejects_unsupported_or_weaker_expected_identity(
    kind: str, version: str
) -> None:
    """Trusted dispatch still cannot request unknown versions or shared definitions."""
    catalog = load_catalog()

    with pytest.raises(CatalogError, match="Unsupported|Shared definitions"):
        catalog.schema(expected_kind=kind, expected_version=version)


@pytest.mark.parametrize(
    "identifier",
    [
        "https://example.invalid/weak.json",
        "file:///schema.json",
        "feature-contract.schema.json",
        "../../schemas/discovery/v1/feature-contract.schema.json",
        V2_URN + "common",
        V2_URN + "feature-contract#",
        V2_URN + "feature-contract\n",
    ],
)
def test_unregistered_aliases_never_resolve(identifier: str) -> None:
    """Aliases are exact opaque IDs, not paths, URLs, or fragment selectors."""
    with pytest.raises(CatalogError, match="Unregistered"):
        load_catalog().schema_for_alias(identifier)


def test_catalog_resource_reader_is_complete_and_checksum_verified() -> None:
    """An injected store follows the same manifest and byte checks as installation."""
    store = _store()
    assert len(load_catalog(read_bytes=store.__getitem__).documents) == 34
    store[schema_path("scope", "2.0.0")] += b" "

    with pytest.raises(CatalogError, match="checksum"):
        load_catalog(read_bytes=store.__getitem__)


def test_catalog_rejects_missing_declared_resource_and_malformed_schema() -> None:
    """Neither a partial manifest nor hash-consistent invalid JSON can load."""
    store = _store()
    path = schema_path("scope", "2.0.0")
    del store[path]
    # Re-pin the remaining store so the failure concerns completeness, not checksum.
    store["manifest.json"] = render_resource_manifest(
        {k: v for k, v in store.items() if k != "manifest.json"}
    )
    with pytest.raises(CatalogError, match="not declared"):
        load_catalog(read_bytes=store.__getitem__)
    store[path] = b'{"duplicate":1,"duplicate":2}'
    # The second fault is hash-consistent malformed schema content.
    store["manifest.json"] = render_resource_manifest(
        {k: v for k, v in store.items() if k != "manifest.json"}
    )
    with pytest.raises(CatalogError, match="Invalid schema"):
        load_catalog(read_bytes=store.__getitem__)


@pytest.mark.parametrize("library", ("jsonschema", "referencing"))
def test_missing_required_dependency_fails_without_reduced_validation(
    library: str,
    monkeypatch: MonkeyPatch,
) -> None:
    """Unavailable full validators produce an actionable catalog failure."""
    monkeypatch.setitem(sys.modules, library, None)

    with pytest.raises(CatalogError, match="Required schema dependency unavailable"):
        load_catalog()


def test_catalog_rejects_incomplete_or_duplicate_document_sets() -> None:
    """Direct construction cannot omit or duplicate a registered schema identity."""
    catalog = load_catalog()
    # Both omission and duplication violate the same complete-catalog invariant.
    for documents in (
        catalog.documents[:-1],
        (*catalog.documents, catalog.documents[0]),
    ):
        with pytest.raises(CatalogError, match="complete fixed"):
            replace(catalog, documents=documents)


@pytest.mark.parametrize(
    ("key", "value", "message"),
    [
        ("$id", "other", "identity or dialect"),
        ("$schema", "https://example.invalid/meta", "identity or dialect"),
        ("type", 42, "Invalid catalog schema"),
        ("$ref", "https://example.invalid/schema", "Unregistered"),
        ("$ref", "#/$defs/absent", "Unresolved"),
        ("$dynamicRef", "file:///outside", "Unregistered"),
        ("properties", {"value": {"$id": "other"}}, "Nested"),
    ],
)
def test_catalog_checks_identity_metaschema_and_complete_reference_closure(
    key: str,
    value: object,
    message: str,
) -> None:
    """Even unused schema branches cannot redirect or defer reference resolution."""
    catalog = load_catalog()
    schema = catalog.schema(expected_kind="scope", expected_version="2.0.0")
    schema[key] = value

    with pytest.raises(CatalogError, match=message):
        _replace_schema(catalog, V2_URN + "scope", schema)


def test_registry_denies_unknown_runtime_retrieval() -> None:
    """An unexpected reference reaches the denying backend without network access."""
    registry = load_catalog().registry()

    with pytest.raises(Unresolvable):
        registry.resolver().lookup("https://example.invalid/unregistered")


@pytest.mark.parametrize(
    "overrides",
    [
        {"namespace": "local"},
        {"namespace": "example.domain\n"},
        {"path": "../outside.json"},
        {"sha256": "a" * 64 + "\n"},
        {"sha256": "a" * 64},
        {"content": "not bytes"},
    ],
)
def test_extension_requires_a_safe_namespace_path_hash_and_immutable_bytes(
    overrides: dict[str, object],
) -> None:
    """Extension provenance is validated before its schema can be consumed."""
    with pytest.raises(ValueError):
        _extension({"type": "object"}, **overrides)


def test_extension_accepts_local_refs_and_rejects_duplicate_namespace() -> None:
    """A pinned document resolves local definitions without replacing core schemas."""
    extension = _extension(
        {"$defs": {"value": {"type": "string"}}, "$ref": "#/$defs/value"}
    )
    catalog = load_catalog(extensions=(extension,))

    assert catalog.extension_documents()[0][0] == extension.identifier
    assert catalog.registry().resolver(extension.identifier).lookup(
        "#/$defs/value"
    ).contents == {"type": "string"}
    with pytest.raises(CatalogError, match="namespaces must be unique"):
        replace(catalog, extensions=(extension, extension))


@pytest.mark.parametrize(
    ("schema", "message"),
    [
        ({"properties": {"date": {"format": "date"}}}, "Unsupported schema format"),
        ({"$schema": "https://example.invalid/dialect"}, "Draft 2020-12"),
        ({"$id": V2_URN + "feature-contract"}, "IDs are assigned"),
        ({"$ref": "https://example.invalid/weak"}, "must be local"),
        ({"$dynamicRef": "file:///outside"}, "must be local"),
        ({"$ref": V2_URN + "common"}, "must be local"),
        ({"$ref": "#/$defs/missing"}, "Unresolved"),
        ({"properties": {"value": {"$id": "https://example.invalid/"}}}, "Nested"),
    ],
)
def test_extension_cannot_change_dialect_identity_or_escape_its_document(
    schema: dict[str, object],
    message: str,
) -> None:
    """Pinned bytes remain untrusted schema content and receive full closure checks."""
    with pytest.raises(CatalogError, match=message):
        load_catalog(extensions=(_extension(schema),))
