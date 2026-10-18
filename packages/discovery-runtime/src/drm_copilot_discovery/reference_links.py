"""Follow trusted core schema links and bind scalar IDs to their declared context."""

from __future__ import annotations

from collections import defaultdict
from typing import TYPE_CHECKING

from drm_copilot_discovery.catalog import V2_URN
from drm_copilot_discovery.findings import Finding, FindingCollector, child_pointer
from drm_copilot_discovery.models import JsonObject, JsonValue

if TYPE_CHECKING:
    from collections.abc import Iterator, Mapping

    from drm_copilot_discovery.references import (
        ArtifactRecord,
        ReferenceIndex,
        ReferenceResolution,
    )


def string_value(value: JsonValue) -> str | None:
    """Retain strings without coercing malformed values into identities."""
    return value if isinstance(value, str) else None


def reference_finding(
    code: str,
    source: ArtifactRecord,
    pointer: str,
    message: str,
    targets: tuple[ArtifactRecord, ...] = (),
) -> Finding:
    """Attach stable source pointers and candidate locations to graph failures."""
    return Finding(
        code=code,
        artifact_path=source.artifact.path,
        pointer=pointer,
        message=message,
        next_action="Correct the identity or supply the artifact, then validate again.",
        related_paths=tuple(item.artifact.path for item in targets),
    )


def schema_references(
    value: JsonValue,
    schema: JsonValue,
    schemas: Mapping[str, JsonObject],
    *,
    base: str,
    pointer: str,
    expected: str | None = None,
) -> Iterator[tuple[str, JsonObject, str | None, str]]:
    """Follow only trusted schema properties/items, never arbitrary JSON values."""
    if not isinstance(schema, JsonObject) or value is None:
        return
    properties = schema.get("properties")
    if isinstance(properties, JsonObject):
        kind_schema = properties.get("artifact_kind")
        if isinstance(kind_schema, JsonObject):
            expected = string_value(kind_schema.get("const")) or expected
    reference = string_value(schema.get("$ref"))
    if reference is not None:
        identifier, _, fragment = reference.partition("#")
        identifier = identifier or base
        marker = identifier.removeprefix(V2_URN) + "#" + fragment
        # These leaves are reference wire types, not embedded artifact definitions.
        if marker in {
            "common#/$defs/artifact-reference",
            "parity-matrix#/$defs/source-contract-reference",
            "source-snapshot-manifest#/$defs/artifact",
            "extension-result-manifest#/$defs/result-file",
        }:
            if isinstance(value, JsonObject):
                expected = {
                    "parity-matrix": "feature-contract",
                    "extension-result-manifest": "inventory-snapshot",
                }.get(marker.split("#")[0], expected)
                yield pointer, value, expected, marker.split("#")[0]
            return
        resolved: JsonValue = schemas[identifier]
        # Catalog construction already validated every local JSON pointer.
        for part in fragment.split("/")[1:]:
            if isinstance(resolved, JsonObject):
                resolved = resolved[part.replace("~1", "/").replace("~0", "~")]
        yield from schema_references(
            value,
            resolved,
            schemas,
            base=identifier,
            pointer=pointer,
            expected=expected,
        )
    # Core object properties exclude extension payloads and untyped action values.
    if isinstance(value, JsonObject) and isinstance(properties, JsonObject):
        for key, child in properties.items():
            if key in value and key not in {"extensions", "value"}:
                yield from schema_references(
                    value[key],
                    child,
                    schemas,
                    base=base,
                    pointer=child_pointer(pointer, key),
                )
    if isinstance(value, tuple):
        # Preserve source array positions for actionable diagnostics.
        for position, child in enumerate(value):
            yield from schema_references(
                child,
                schema.get("items"),
                schemas,
                base=base,
                pointer=child_pointer(pointer, position),
                expected=expected,
            )
    # Nullable alternatives and typed allOf refinements share the same data node.
    for keyword in ("allOf", "anyOf", "oneOf"):
        alternatives = schema.get(keyword)
        if isinstance(alternatives, tuple):
            # Refinements may contribute the kind constraint on a shared reference.
            for alternative in alternatives:
                yield from schema_references(
                    value,
                    alternative,
                    schemas,
                    base=base,
                    pointer=pointer,
                    expected=expected,
                )


def _objects(document: JsonObject, name: str) -> tuple[JsonObject, ...]:
    """Select immutable object members without coercing malformed collections."""
    values = document.get(name)
    return (
        tuple(item for item in values if isinstance(item, JsonObject))
        if isinstance(values, tuple)
        else ()
    )


def validate_linkage(index: ReferenceIndex, collector: FindingCollector) -> None:
    """Bind scalar selectors to their declared inventory, feature and criterion."""
    grouped: dict[tuple[str, str], list[ReferenceResolution]] = defaultdict(list)
    # Keep each container member's links separate from its siblings.
    for link in index.links:
        grouped[(link.source.artifact.path, link.source.pointer)].append(link)
    # Scalar selectors must use their explicitly linked record context.
    for record in index.records:
        links = grouped[(record.artifact.path, record.pointer)]

        def selected(
            prefix: str,
            *,
            record: ArtifactRecord = record,
            links: list[ReferenceResolution] = links,
        ) -> tuple[ArtifactRecord, ...]:
            """Select successful references from one exact source field or array."""
            location = record.pointer + "/" + prefix
            return tuple(
                link.target
                for link in links
                if link.target is not None
                and (
                    link.pointer == location or link.pointer.startswith(location + "/")
                )
            )

        def check(
            identifier: JsonValue,
            choices: tuple[JsonValue, ...],
            pointer: str,
            *,
            record: ArtifactRecord = record,
        ) -> None:
            """Reject missing or multiply bound scalar IDs without inventing targets."""
            if isinstance(identifier, str) and choices.count(identifier) != 1:
                collector.add(
                    reference_finding(
                        "REFERENCE_LINKAGE",
                        record,
                        record.pointer + pointer,
                        f"Linked identity {identifier} requires one matching record "
                        "in its declared context.",
                    )
                )

        document = record.document
        # Inventory IDs resolve locally; coverage/scope IDs use linked inventories.
        if record.kind == "inventory-snapshot":
            components = tuple(
                item.get("component_id") for item in _objects(document, "components")
            )
            diagnostics = tuple(
                item.get("id") for item in _objects(document, "diagnostics")
            )
            # Findings must point to an actual component in this inventory.
            for position, finding in enumerate(_objects(document, "findings")):
                check(
                    finding.get("component_id"),
                    components,
                    f"/findings/{position}/component_id",
                )
            # A null target records unresolved binding; present endpoints must exist.
            for position, relationship in enumerate(
                _objects(document, "relationships")
            ):
                # Both endpoint directions use the same inventory namespace.
                for name in ("from_component_id", "to_component_id"):
                    check(
                        relationship.get(name),
                        components,
                        f"/relationships/{position}/{name}",
                    )
            # Unreadable file diagnostics must identify actual diagnostic records.
            for position, file in enumerate(_objects(document, "files")):
                ids = file.get("diagnostic_ids")
                if isinstance(ids, tuple):
                    # Retain individual selector pointers instead of the whole array.
                    for number, identifier in enumerate(ids):
                        check(
                            identifier,
                            diagnostics,
                            f"/files/{position}/diagnostic_ids/{number}",
                        )
        if record.kind in {"scope", "coverage-ledger"}:
            components = tuple(
                item.get("component_id")
                for inventory in selected("inventory_snapshot_refs")
                for item in _objects(inventory.document, "components")
            )
            if record.kind == "scope":
                included = document.get("included_components")
                if isinstance(included, tuple):
                    # Unlinked global components cannot satisfy declared scope.
                    for position, identifier in enumerate(included):
                        check(
                            identifier, components, f"/included_components/{position}"
                        )
            else:
                # Ledger dispositions refer back to explicit inventory identities.
                for position, component in enumerate(_objects(document, "components")):
                    check(
                        component.get("component_id"),
                        components,
                        f"/components/{position}/component_id",
                    )
        if record.kind == "parity-matrix":
            # A row's feature selector must agree with its resolved source contract.
            for position, entry in enumerate(_objects(document, "entries")):
                features = tuple(
                    target.document.get("feature_id")
                    for target in selected(f"entries/{position}/source_contract_ref")
                )
                check(
                    entry.get("feature_id"), features, f"/entries/{position}/feature_id"
                )
        if record.kind == "acceptance-specification":
            sources = selected("source_contract_refs")
            # Several pinned contracts may represent the same selected feature.
            features = tuple(
                dict.fromkeys(item.document.get("feature_id") for item in sources)
            )
            check(document.get("feature_id"), features, "/feature_id")
            # Criteria may originate in source contracts or linked target decisions.
            criteria = tuple(
                dict.fromkeys(
                    criterion.get("id")
                    for target in sources + selected("product_decision_refs")
                    for name in ("acceptance_criteria", "resulting_acceptance_criteria")
                    for criterion in _objects(target.document, name)
                )
            )
            check(document.get("criterion_id"), criteria, "/criterion_id")
