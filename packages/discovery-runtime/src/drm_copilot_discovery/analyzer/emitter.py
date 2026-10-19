"""Evidence Reference v1 serialization for the analyzer framework.

Purpose:
    Turn an ``EvidenceRecord`` into a discovery v1 Evidence Reference JSON
    document string. This module owns the ``$schema`` relative-path computation
    and deterministic serialization; the record owns the field-set assembly.

Invariants / Constraints:
    - ``$schema`` is a scheme-less relative POSIX path from the emitted instance
      file to the schema file. It never contains a drive letter or a leading
      ``/`` (absolute Windows paths are prohibited).
    - Serialization is deterministic: ``json.dumps(..., sort_keys=True,
      indent=2)``.
    - Standard library only; no domain-specific identifiers.

Side Effects:
    None. Writing instances to disk is the caller's responsibility (via the
    filesystem seam).
"""

from __future__ import annotations

import hashlib
import json
import os
import re
from pathlib import PurePosixPath
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.findings import row, seed_component, stable_id, tool
from drm_copilot_discovery.analyzer.models import InventoryResult
from drm_copilot_discovery.coverage_scope_rules import inventory_configuration_digest
from drm_copilot_discovery.models import JsonObject, canonical_json
from drm_copilot_discovery.schema_validation import validate_document

if TYPE_CHECKING:
    from pathlib import Path

    from drm_copilot_discovery.analyzer.models import (
        Analysis,
        EvidenceRecord,
        InventoryCapture,
    )
    from drm_copilot_discovery.catalog import SchemaCatalog


def compute_schema_ref(instance_path: Path, schema_path: Path) -> str:
    """Compute the scheme-less relative POSIX ``$schema`` path.

    Args:
        instance_path: Path of the emitted instance file.
        schema_path: Path of the discovery v1 Evidence Reference schema file.

    Returns:
        A relative POSIX path from the instance file's directory to the schema
        file, with no drive letter and no leading ``/``.

    Raises:
        ValueError: When a scheme-less relative path cannot be produced (for
            example the paths are on different drives, or the result would be
            absolute).
    """
    try:
        relative = os.path.relpath(str(schema_path), start=str(instance_path.parent))
    except ValueError as exc:
        raise ValueError(
            f"cannot compute a relative $schema path from {instance_path} "
            f"to {schema_path}: {exc}"
        ) from exc
    posix = PurePosixPath(relative.replace(os.sep, "/")).as_posix()
    if posix.startswith("/") or ":" in posix.split("/", 1)[0]:
        raise ValueError(
            f"computed $schema path is not scheme-less relative: {posix!r}"
        )
    return posix


def serialize_record(
    record: EvidenceRecord, instance_path: Path, schema_path: Path
) -> str:
    """Build and deterministically serialize an Evidence Reference instance.

    Args:
        record: The evidence record to serialize.
        instance_path: Path where the instance will be written (drives ``$schema``).
        schema_path: Path of the schema file that the instance references.

    Returns:
        The JSON text of the Evidence Reference instance with sorted keys.
    """
    schema_ref = compute_schema_ref(instance_path, schema_path)
    document = record.to_json_dict(schema_ref)
    return json.dumps(document, sort_keys=True, indent=2)


def _ordered(rows: tuple[JsonObject, ...], key: str) -> tuple[JsonObject, ...]:
    """Reject ambiguous adapter identities before returning deterministic row order.

    rows (tuple[JsonObject, ...]) supply immutable adapter rows; key (str) names
    their identifier field. Returns a sorted tuple. Raises ValueError for missing or
    duplicate IDs; performs no I/O or mutation.
    """
    # Reject missing IDs before sorting can obscure an ambiguous adapter result.
    keys = [item.get(key) for item in rows]
    if any(not isinstance(key, str) for key in keys):
        raise ValueError(f"Missing analyzer identifier: {key}")
    if len(set(keys)) != len(keys):
        raise ValueError(f"Duplicate analyzer identifier: {key}")
    return tuple(sorted(rows, key=lambda item: cast("str", item[key])))


def _analyzer_metadata(
    capture: InventoryCapture,
    analyzer_ids: tuple[str, ...],
    extension_adapters: tuple[JsonObject, ...] | None,
) -> tuple[JsonObject, ...]:
    """Bind exact declared versions without allowing external built-in identities.

    capture (InventoryCapture) supplies finite limits; analyzer_ids (tuple[str,
    ...]) selects reserved identities; extension_adapters (tuple[JsonObject, ...]
    | None) declares external id/version pairs. Returns sorted immutable metadata.
    Raises ValueError for malformed, duplicate, unknown or reserved declarations
    and resource overflow. No implementation loading, I/O or mutation occurs.
    """
    from drm_copilot_discovery.analyzer.registry import builtin_analyzer_identities

    supplied = () if extension_adapters is None else extension_adapters
    if type(analyzer_ids) is not tuple or type(supplied) is not tuple:
        raise ValueError("Analyzer identities require immutable tuples")
    if len(analyzer_ids) + len(supplied) > capture.profile.limits.artifact_records:
        raise ValueError("Analyzer identities exceed the configured record limit")
    # Metadata is the sole reserved-ID authority and does not load implementations.
    reserved = {cast("str", item["id"]): item for item in builtin_analyzer_identities()}
    selected: dict[str, JsonObject] = {}
    remaining = capture.profile.limits.document_bytes
    # Validate every fixed selector before retaining any external declaration.
    for identifier in analyzer_ids:
        if (
            not isinstance(cast("object", identifier), str)
            or len(identifier) > remaining
        ):
            raise ValueError("Invalid or oversized built-in analyzer identity")
        remaining -= len(identifier)
        if identifier not in reserved or identifier in selected:
            raise ValueError("Unknown or duplicate built-in analyzer identity")
        selected[identifier] = reserved[identifier]
    # Bound retained JSON text before regex validation or metadata allocation.
    for descriptor in supplied:
        if (
            not isinstance(cast("object", descriptor), JsonObject)
            or len(descriptor) != 2
        ):
            raise ValueError("External analyzer metadata requires only id and version")
        identifier, version = descriptor.get("id"), descriptor.get("version")
        if not isinstance(identifier, str) or not isinstance(version, str):
            raise ValueError("External analyzer id and version must be strings")
        cost = 6 * (len(identifier) + len(version)) + 32
        if cost > remaining:
            raise ValueError("Analyzer identities exceed the configured byte limit")
        remaining -= cost
        # Reject malformed selectors without coercing versions or echoing payloads.
        if not re.fullmatch(
            r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", identifier
        ) or not any(not character.isspace() for character in version):
            raise ValueError("External analyzer id or version is invalid")
        if identifier in reserved or identifier in selected:
            raise ValueError("External analyzer identity is reserved or duplicated")
        selected[identifier] = descriptor
    # Sort only the already bounded union; preserve each descriptor's exact version.
    return tuple(selected[name] for name in sorted(selected))


def inventory_result(
    capture: InventoryCapture,
    analyses: tuple[Analysis, ...],
    *,
    analyzer_ids: tuple[str, ...],
    timestamp: str,
    author_or_agent: JsonObject,
    catalog: SchemaCatalog,
    extension_adapters: tuple[JsonObject, ...] | None = None,
) -> InventoryResult:
    """Validate complete deterministic inventory JSON and separate ledger proposals.

    Required capture metadata is caller-supplied. Stable identity excludes it;
    content hashes come from the retained input bytes used by the adapters.
    Schema and cross-row failures raise ValueError; this function performs no I/O.

    capture (InventoryCapture) supplies input hashes and configuration; analyses
    (tuple[Analysis, ...]) contains adapter rows. analyzer_ids (tuple[str, ...]),
    timestamp (str), author_or_agent (JsonObject), and catalog (SchemaCatalog) bind
    implementation and provenance. extension_adapters (tuple[JsonObject, ...] |
    None) supplies exact external id/version declarations; None and () preserve
    the built-in-only output. Returns InventoryResult with immutable document
    and ledger proposals. Raises ValueError for row, reference, limit or schema
    failures; performs no I/O or mutation.
    """
    metadata = _analyzer_metadata(capture, analyzer_ids, extension_adapters)
    if len(analyses) > capture.profile.limits.artifact_records:
        raise ValueError("Analyzer batches exceed the configured record limit")
    # Validate exact row ownership before aggregation allocates family-wide tuples.
    identities = {cast("str", item["id"]): item for item in metadata}
    remaining_records = capture.profile.limits.artifact_records
    for analysis in analyses:
        families = (analysis.components, analysis.findings, analysis.relationships)
        remaining_records -= sum(map(len, families)) + len(analysis.diagnostics)
        if remaining_records < 0:
            raise ValueError("Analyzer result exceeds the configured record limit")
        # Diagnostics have no analyzer field; source-bearing rows require a pair.
        for family in families:
            # Every row is checked once before a complete result can be exposed.
            for item in family:
                declaration = item.get("analyzer")
                if not isinstance(declaration, JsonObject) or len(declaration) != 2:
                    raise ValueError("Analyzer row requires exact id/version metadata")
                identifier, version = declaration.get("id"), declaration.get("version")
                if (
                    not isinstance(identifier, str)
                    or not isinstance(version, str)
                    or len(identifier) + len(version)
                    > capture.profile.limits.document_bytes
                    or declaration != identities.get(identifier)
                ):
                    raise ValueError(
                        "Analyzer row does not match a declared id/version"
                    )
    # Aggregate each row family independently while rejecting duplicate identities.
    components = _ordered(
        tuple(item for analysis in analyses for item in analysis.components),
        "component_id",
    )
    # Findings retain their own stable IDs, separate from owning component IDs.
    findings = _ordered(
        tuple(item for analysis in analyses for item in analysis.findings), "finding_id"
    )
    # Relationship order is independent of adapter execution or source walk order.
    relationships = _ordered(
        tuple(item for analysis in analyses for item in analysis.relationships),
        "relationship_id",
    )
    # Stable diagnostic IDs let unavailable file rows point to exact failures.
    diagnostics = _ordered(
        tuple(item for analysis in analyses for item in analysis.diagnostics), "id"
    )
    # References can bind only the components actually present in this result.
    component_ids = {item["component_id"] for item in components}
    # A detection may refer only to a component actually returned in this run.
    for item in findings + relationships:
        references = (
            item.get("component_id"),
            item.get("from_component_id"),
            item.get("to_component_id"),
        )
        # Nullable unresolved targets are allowed; nonnull targets must be emitted.
        if any(
            value is not None and value not in component_ids for value in references
        ):
            raise ValueError("Analyzer result contains a broken component reference")
    # Preserve every selected/excluded/unreadable input with its captured digest.
    files = tuple(
        row(
            path=item.path,
            status=item.status,
            sha256=item.sha256,
            size=len(item.file.content) if item.file else None,
            rationale=item.rationale,
            # Associate errors with the input without inventing unavailable bytes.
            diagnostic_ids=tuple(
                d["id"] for d in diagnostics if d.get("path") == item.path
            ),
        )
        for item in capture.inputs
    )
    # Semantic data excludes observation metadata so clock changes do not change IDs.
    values = row(
        **{"$schema": "urn:drm-copilot:discovery:2.0.0:inventory-snapshot"},
        schema_version="2.0.0",
        artifact_kind="inventory-snapshot",
        repository=capture.profile.repository.id,
        revision=capture.profile.repository.revision,
        tool=tool("discovery-inventory"),
        analyzers=metadata,
        scan_configuration_sha256=inventory_configuration_digest(capture.profile),
        files=files,
        components=components,
        findings=findings,
        relationships=relationships,
        diagnostics=diagnostics,
        exclusions=capture.exclusions,
        extensions=row(),
    )
    document = JsonObject(
        values.members
        + (
            ("id", stable_id("inventory", values)),
            ("capture", row(timestamp=timestamp, author_or_agent=author_or_agent)),
        )
    )
    # Validate the closed wire contract before exposing JSON or coverage proposals.
    checked = validate_document(
        canonical_json(document),
        expected_kind="inventory-snapshot",
        expected_version="2.0.0",
        format="json",
        catalog=catalog,
        limits=capture.profile.limits.parse_limits(),
    )
    if not checked.ok:
        raise ValueError(
            "Invalid analyzer inventory: "
            + "; ".join(finding.message for finding in checked.findings)
        )
    # Coverage proposals preserve detections without upgrading inspection state.
    return InventoryResult(
        document=document,
        # Proposed coverage rows retain the existing uninspected/unassigned state.
        ledger_components=tuple(seed_component(item) for item in components),
        semantic_sha256=hashlib.sha256(canonical_json(values)).hexdigest(),
    )
