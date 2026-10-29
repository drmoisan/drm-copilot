"""Resolve trusted schema identities from a complete, hash-verified offline catalog.

Artifacts cannot select validators. Legacy aliases are opaque identifiers, never
filesystem paths; extension bytes are supplied through the caller's read boundary.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass, field
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.findings import validate_finding_path
from drm_copilot_discovery.models import JsonObject, JsonValue, to_plain_value
from drm_copilot_discovery.parsing import parse_document
from drm_copilot_discovery.resources import (
    ResourceError,
    load_resource_manifest,
    read_resource,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Iterator

    from referencing import Registry, Resource
    from referencing.jsonschema import Schema

DIALECT = "https://json-schema.org/draft/2020-12/schema"
V2_URN = "urn:drm-copilot:discovery:2.0.0:"
V1_KINDS = (
    "coverage-ledger",
    "evidence-reference",
    "feature-contract",
    "parity-matrix",
    "product-decision",
    "runtime-characterization-scenario",
    "unspecified-behavior",
)
V2_KINDS = (
    "acceptance-specification",
    "activation",
    "capability-attestation",
    "common",
    "coverage-ledger",
    "discovery-invocation",
    "domain-profile",
    "evidence-reference",
    "extension-result-manifest",
    "feature-contract",
    "implementation-record",
    "inventory-snapshot",
    "migration-report",
    "parity-matrix",
    "product-decision",
    "product-decision-collection",
    "required-output-manifest",
    "runtime-characterization-scenario",
    "scope",
    "service-request",
    "service-result",
    "source-snapshot-manifest",
    "start-attestation",
    "tool-authorization",
    "unspecified-behavior",
    "unspecified-behavior-collection",
    "validation-receipt",
)


class CatalogError(ValueError):
    """Reject incomplete, unsafe, unavailable or unsupported schema resolution."""


def schema_path(kind: str, version: str) -> str:
    """Return the fixed path for string kind/version; raise CatalogError otherwise.

    This pure mapping performs no I/O or path interpretation by the host OS.
    """
    kinds = {"1.0.0": V1_KINDS, "2.0.0": V2_KINDS}.get(version)
    if kinds is None or kind not in kinds:
        raise CatalogError(f"Unsupported schema identity: {version}/{kind}")
    filename = kind
    # Only these frozen v1 filenames differ from the current logical kind names.
    if version == "1.0.0" and kind in {"product-decision", "unspecified-behavior"}:
        filename += "-record"
    return f"schemas/discovery/v{version[0]}/{filename}.schema.json"


def schema_aliases(kind: str, version: str) -> tuple[str, ...]:
    """Return immutable registered aliases, raising CatalogError for unknown kinds.

    Kind/version strings are trusted dispatch inputs; aliases are never read paths.
    """
    path = schema_path(kind, version)
    if version == "2.0.0":
        return (V2_URN + kind,)
    return (path, "../../../" + path, "../../../../" + path)


def _schema_object(content: bytes, context: str) -> JsonObject:
    """Apply strict parsing before schema metadata or reference inspection."""
    parsed = parse_document(content, format="json")
    if parsed.value is None:
        raise CatalogError(f"Invalid schema {context}: {parsed.findings[0].message}")
    return parsed.value


def _schema_nodes(value: JsonValue) -> Iterator[JsonObject]:
    """Visit schema-bearing keywords without treating examples as schemas."""
    if not isinstance(value, JsonObject):
        return
    yield value
    # JSON Schema defines these positions as schemas, not arbitrary annotations.
    for key in (
        "$defs",
        "definitions",
        "properties",
        "patternProperties",
        "dependentSchemas",
    ):
        children = value.get(key)
        if isinstance(children, JsonObject):
            # Named definitions retain their own schema context, not their key names.
            for child in children.values():
                yield from _schema_nodes(child)
    # Single-schema applicators can hide references in otherwise inactive branches.
    for key in (
        "items",
        "contains",
        "additionalProperties",
        "propertyNames",
        "not",
        "if",
        "then",
        "else",
        "unevaluatedProperties",
        "unevaluatedItems",
        "additionalItems",
        "contentSchema",
    ):
        yield from _schema_nodes(value.get(key))
    # Alternative and tuple schemas must all be checked before instance evaluation.
    for key in ("allOf", "anyOf", "oneOf", "prefixItems"):
        children = value.get(key)
        if isinstance(children, tuple):
            # Visit alternatives independently of the eventual instance branch.
            for child in children:
                yield from _schema_nodes(child)


@dataclass(frozen=True, kw_only=True)
class ExtensionSchema:
    """Bind a namespaced extension to caller-supplied local bytes and their pin.

    Construct after an authorized caller reads the configured path. Construction
    checks namespace/path spelling and the content hash; it performs no I/O and
    grants no filesystem authority. The immutable value travels with its catalog.
    """

    namespace: str
    path: str
    sha256: str
    content: bytes

    def __post_init__(self) -> None:
        """Reject unpinned or misidentified extension input before parsing it."""
        if re.fullmatch(r"[a-z][a-z0-9]*(?:[.-][a-z0-9]+)+", self.namespace) is None:
            raise CatalogError("Extension namespace must be a dotted or dashed name")
        validate_finding_path(self.path)
        if re.fullmatch(r"[0-9a-f]{64}", self.sha256) is None:
            raise CatalogError("Extension schema requires an exact SHA-256 pin")
        if not isinstance(cast("object", self.content), bytes):
            raise CatalogError("Extension schema content must be immutable bytes")
        if hashlib.sha256(self.content).hexdigest() != self.sha256:
            raise CatalogError(f"Extension schema checksum mismatch: {self.path}")

    @property
    def identifier(self) -> str:
        """Keep extension resources distinct from core catalog identities."""
        return f"urn:drm-copilot:discovery:extension:{self.namespace}:{self.sha256}"


def _deny_retrieval(uri: str) -> Resource[Schema]:
    """Reject every uncatalogued reference without invoking a retrieval backend."""
    from referencing.exceptions import NoSuchResource

    raise NoSuchResource(ref=uri)


def _registry(
    documents: tuple[tuple[str, JsonObject], ...],
    extensions: tuple[ExtensionSchema, ...],
) -> Registry[Schema]:
    """Build the full validator registry or fail explicitly on a missing library."""
    try:
        from jsonschema import Draft202012Validator
        from jsonschema.exceptions import SchemaError
        from referencing import Registry, Resource
        from referencing.exceptions import Unresolvable
        from referencing.jsonschema import DRAFT202012, Schema
    except ImportError as error:
        raise CatalogError(
            f"Required schema dependency unavailable: {error}"
        ) from error
    resources: list[tuple[str, Resource[Schema]]] = []
    # Validate every document before registering any schema for instance evaluation.
    for identifier, document in documents:
        schema = cast("dict[str, object]", to_plain_value(document))
        # Strengthen the shared schema position so every embedded core use is checked.
        if identifier == V2_URN + "common" and extensions:
            definitions = cast("dict[str, object]", schema["$defs"])
            extension_schema = cast("dict[str, object]", definitions["extensions"])
            # Properties adds constraints only at the shared core extension boundary.
            extension_schema["properties"] = {
                item.namespace: {"$ref": item.identifier} for item in extensions
            }
        try:
            Draft202012Validator.check_schema(schema)
        except SchemaError as error:
            raise CatalogError(
                f"Invalid catalog schema {identifier}: {error.message}"
            ) from error
        resources.append(
            (
                identifier,
                Resource.from_contents(schema, default_specification=DRAFT202012),
            )
        )
    registry = Registry[Schema](retrieve=_deny_retrieval).with_resources(resources)
    # Absolute references must match an already registered identity without fetching.
    registered = {identifier for identifier, _ in documents}
    # Resolve all references eagerly rather than only branches exercised by one input.
    for identifier, document in documents:
        # Schema-bearing positions exclude arbitrary annotation payloads.
        for node in _schema_nodes(document):
            if "format" in node and node["format"] not in {"date-time", "uri"}:
                raise CatalogError(f"Unsupported schema format: {node['format']}")
            # A nested identifier could silently redirect relative reference resolution.
            if node is not document and "$id" in node:
                raise CatalogError(
                    f"Nested schema identifiers are unsupported: {identifier}"
                )
            # Both static and dynamic references require the same offline closure.
            for keyword in ("$ref", "$dynamicRef"):
                reference = node.get(keyword)
                if not isinstance(reference, str):
                    continue
                base = reference.split("#", 1)[0]
                if base and base not in registered:
                    raise CatalogError(f"Unregistered schema reference: {reference}")
                try:
                    registry.resolver(identifier).lookup(reference)
                except Unresolvable as error:
                    raise CatalogError(
                        f"Unresolved schema reference: {reference}"
                    ) from error
    return registry


@dataclass(frozen=True, kw_only=True)
class SchemaCatalog:
    """Hold the complete immutable schema set; expose fresh validator inputs.

    Prefer load_catalog to bind installed hashes before construction. The catalog
    verifies identities, metaschemas and complete local reference closure once at
    construction; validators are created per call over the shared registry. No
    network or writes are performed.
    """

    documents: tuple[tuple[str, JsonObject], ...]
    extensions: tuple[ExtensionSchema, ...] = ()
    # Built once by __post_init__; excluded from init, equality, hashing and repr.
    _shared_registry: Registry[Schema] = field(init=False, compare=False, repr=False)

    def __post_init__(self) -> None:
        """Require every fixed schema identity and prohibit injected alternatives."""
        # Compare the entire supported set so no missing schema creates a fallback.
        expected = {
            schema_aliases(kind, version)[0]
            for version, kinds in (("1.0.0", V1_KINDS), ("2.0.0", V2_KINDS))
            for kind in kinds
        }
        # Retain multiplicity for the duplicate-identity check.
        identifiers = [identifier for identifier, _ in self.documents]
        if len(identifiers) != len(expected) or set(identifiers) != expected:
            raise CatalogError(
                "Catalog must contain the complete fixed v1/v2 schema set"
            )
        # Resource IDs and dialect declarations must agree with trusted registration.
        for identifier, document in self.documents:
            if document.get("$id") != identifier or document.get("$schema") != DIALECT:
                raise CatalogError(
                    f"Catalog schema identity or dialect mismatch: {identifier}"
                )
        # A namespace cannot select between two competing pinned constraints.
        namespaces = [item.namespace for item in self.extensions]
        if len(set(namespaces)) != len(namespaces):
            raise CatalogError("Extension schema namespaces must be unique")
        # Validate closure eagerly, including references in currently unused branches,
        # and keep the verified registry so later validations do not rebuild it.
        object.__setattr__(
            self,
            "_shared_registry",
            _registry(self.documents + self.extension_documents(), self.extensions),
        )

    def schema(self, *, expected_kind: str, expected_version: str) -> dict[str, object]:
        """Resolve a trusted artifact kind and exact version, never an artifact URI."""
        if expected_kind == "common":
            raise CatalogError("Shared definitions cannot validate an artifact")
        identifier = schema_aliases(expected_kind, expected_version)[0]
        return cast(
            "dict[str, object]", to_plain_value(dict(self.documents)[identifier])
        )

    def schema_for_alias(self, identifier: str) -> dict[str, object]:
        """Support legacy lookup callers with registered offline identities only."""
        # Compatibility aliases identify an exact kind/version, never a search path.
        for version, kinds in (("1.0.0", V1_KINDS), ("2.0.0", V2_KINDS)):
            # Shared definitions are deliberately not valid artifact dispatch targets.
            for kind in kinds:
                if kind != "common" and identifier in schema_aliases(kind, version):
                    return self.schema(expected_kind=kind, expected_version=version)
        raise CatalogError(f"Unregistered artifact schema identifier: {identifier}")

    def extension_documents(self) -> tuple[tuple[str, JsonObject], ...]:
        """Restrict extension references to their own pinned schema document."""
        documents: list[tuple[str, JsonObject]] = []
        # Each namespace has one independently pinned schema and reference scope.
        for extension in self.extensions:
            schema = _schema_object(extension.content, extension.path)
            if schema.get("$schema") != DIALECT:
                raise CatalogError(
                    f"Extension requires Draft 2020-12: {extension.path}"
                )
            if "$id" in schema:
                raise CatalogError(
                    "Extension schema IDs are assigned from their content pin"
                )
            # Inspect unused branches as well as currently applicable constraints.
            for node in _schema_nodes(schema):
                # No extension can reference or replace an external/core resource.
                for keyword in ("$ref", "$dynamicRef"):
                    reference = node.get(keyword)
                    if isinstance(reference, str) and not reference.startswith("#"):
                        raise CatalogError(
                            f"Extension reference must be local: {reference}"
                        )
            documents.append((extension.identifier, schema))
        return tuple(documents)

    def registry(self) -> Registry[Schema]:
        """Return the shared offline registry built and verified once at construction.

        Sharing is safe because referencing.Registry is immutable: lookups and
        resource additions return new registries or resolvers and never change
        this one. No build, I/O or verification is performed by this call.

        Returns:
            Registry[Schema]: the catalog's verified registry, identical per call.
        """
        return self._shared_registry


def load_catalog(
    *,
    read_bytes: Callable[[str], bytes] | None = None,
    extensions: tuple[ExtensionSchema, ...] = (),
) -> SchemaCatalog:
    """Return the complete supported catalog or raise CatalogError.

    read_bytes optionally supplies a pure string-path-to-bytes test seam; otherwise
    installed package resources are read. Extensions are already pinned values.
    No artifact-selected lookup, network access, cache write or checkout is used.
    """
    try:
        manifest = (
            load_resource_manifest()
            if read_bytes is None
            else load_resource_manifest(read_bytes=read_bytes)
        )
        documents: list[tuple[str, JsonObject]] = []
        # Version/kind ownership is fixed in code rather than inferred from filenames.
        for version, kinds in (("1.0.0", V1_KINDS), ("2.0.0", V2_KINDS)):
            # Verify manifest bytes before interpreting any schema metadata.
            for kind in kinds:
                path = schema_path(kind, version)
                content = (
                    read_resource(path, manifest=manifest)
                    if read_bytes is None
                    else read_resource(path, manifest=manifest, read_bytes=read_bytes)
                )
                documents.append(
                    (schema_aliases(kind, version)[0], _schema_object(content, path))
                )
        return SchemaCatalog(documents=tuple(documents), extensions=extensions)
    except ResourceError as error:
        raise CatalogError(str(error)) from error
