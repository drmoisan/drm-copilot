"""Validate and merge separately produced inventory data without executing it.

No value returned here authorizes publication. A future importing command must
reconstruct this merge inside a separate guarded mutation planner; the existing
inventory planner deliberately accepts only its own built-in reconstruction.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.analyzer.emitter import inventory_result
from drm_copilot_discovery.analyzer.models import Analysis
from drm_copilot_discovery.analyzer.pipeline import run_inventory
from drm_copilot_discovery.analyzer.registry import builtin_analyzer_identities
from drm_copilot_discovery.extension_inputs import extension_manifest_digest
from drm_copilot_discovery.extension_validation import (
    ExtensionResultError as ExtensionResultError,
)
from drm_copilot_discovery.extension_validation import (
    ExtensionValidation,
    budget,
    check_link_work,
    object_rows,
)
from drm_copilot_discovery.extension_validation import (
    ValidatedExtension as ValidatedExtension,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryResult
    from drm_copilot_discovery.models import JsonObject
    from drm_copilot_discovery.snapshot import DiscoverySnapshot, SnapshotFile

_FAMILIES = (
    ("components", "component_id"),
    ("findings", "finding_id"),
    ("relationships", "relationship_id"),
    ("diagnostics", "id"),
)


def _analysis(document: JsonObject) -> Analysis:
    """Return Analysis from schema-validated document (JsonObject); no mutation/I/O."""
    return Analysis(
        components=object_rows(document, "components"),
        findings=object_rows(document, "findings"),
        relationships=object_rows(document, "relationships"),
        diagnostics=object_rows(document, "diagnostics"),
    )


def _member(
    context: ExtensionValidation, reference: JsonObject, adapter: JsonObject
) -> tuple[SnapshotFile, Analysis]:
    """Validate one member; return (SnapshotFile, Analysis) without I/O.

    context (ExtensionValidation) holds mutable operation-local reservations.
    reference and adapter (JsonObject) are schema-shaped declarations. Fixed
    ExtensionResultError codes report integrity/accounting/identity/source faults.
    """
    file, document = context.read(cast("str", reference["path"]), "inventory-snapshot")
    if file.sha256 != reference["sha256"] or len(file.content) != reference["size"]:
        raise ExtensionResultError("EXTENSION_MEMBER")
    if any(
        document[key] != reference[key]
        for key in ("id", "artifact_kind", "schema_version")
    ):
        raise ExtensionResultError("EXTENSION_MEMBER")
    context.unique("inventory", cast("str", document["id"]))
    profile = context.snapshot.profile
    if (
        document["repository"] != profile.repository.id
        or document["revision"] != profile.repository.revision
        or document["scan_configuration_sha256"]
        != context.projection["scan_configuration_sha256"]
    ):
        raise ExtensionResultError("EXTENSION_DIGEST")
    if document["analyzers"] != (adapter,) or document["tool"] != adapter:
        raise ExtensionResultError("EXTENSION_IDENTITY")
    diagnostics = object_rows(document, "diagnostics")
    context.diagnostics(diagnostics, adapter)
    context.accounting(document, diagnostics)
    # Preserve classifications/confidence; declaration validation never upgrades them.
    for family, key in _FAMILIES[:-1]:
        # Prospective row/text reservations precede collection into returned Analysis.
        for item in object_rows(document, family):
            context.rows.reserve(item, records=1)
            context.unique(family, cast("str", item[key]))
            if item["analyzer"] != adapter:
                raise ExtensionResultError("EXTENSION_IDENTITY")
            context.source(cast("JsonObject", item["source"]))
            properties = cast("tuple[JsonObject, ...]", item.get("properties", ()))
            # Duplicate names with different values are ambiguous despite distinct
            # JSON rows.
            if len({value["name"] for value in properties}) != len(properties):
                raise ExtensionResultError("EXTENSION_COLLISION")
    return file, _analysis(document)


def _references(analyses: tuple[Analysis, ...]) -> None:
    """Check references across analyses (Analysis tuple); return None without I/O.

    Missing component links raise EXTENSION_REFERENCE; null targets stay unresolved.
    """
    # Cross-member links are allowed, but another adapter cannot supply their authority.
    components = {
        item["component_id"] for analysis in analyses for item in analysis.components
    }
    # Null target means unresolved binding; it is preserved without inventing a target.
    for analysis in analyses:
        # Findings and relationships have different mandatory reference fields.
        for family, keys in (
            (analysis.findings, ("component_id",)),
            (analysis.relationships, ("from_component_id", "to_component_id")),
        ):
            # Every non-null link must resolve to a returned component in this bundle.
            for item in family:
                if any(
                    item[key] is not None and item[key] not in components
                    for key in keys
                ):
                    raise ExtensionResultError("EXTENSION_REFERENCE")


def _manifest(context: ExtensionValidation, path: str) -> ValidatedExtension:
    """Return ValidatedExtension for path (str) using context (ExtensionValidation).

    Reserves context counters before retaining rows. Invalid identity, provenance,
    schema or budgets raises ExtensionResultError; no I/O or publication occurs.
    """
    file, document = context.read(path, "extension-result-manifest")
    context.unique("manifest", cast("str", document["id"]))
    adapter = cast("JsonObject", document["adapter"])
    # Registered identities are reserved even when their adapters are not enabled.
    if adapter["id"] in {item["id"] for item in builtin_analyzer_identities()}:
        raise ExtensionResultError("EXTENSION_IDENTITY")
    context.unique("adapter", cast("str", adapter["id"]))
    repository = cast("JsonObject", document["repository"])
    profile = context.snapshot.profile
    if (
        repository["id"] != profile.repository.id
        or repository["revision"] != profile.repository.revision
    ):
        raise ExtensionResultError("EXTENSION_SOURCE")
    if document["input_manifest_sha256"] != context.input_sha256 or document[
        "manifest_sha256"
    ] != extension_manifest_digest(document):
        raise ExtensionResultError("EXTENSION_DIGEST")
    context.source_inputs(document)
    diagnostics = object_rows(document, "diagnostics")
    context.diagnostics(diagnostics, adapter)
    analyses: list[Analysis] = []
    members: list[SnapshotFile] = []
    references = object_rows(document, "result_files")
    # Member order cannot affect merged identity; exact raw paths bind each payload.
    for reference in sorted(references, key=lambda item: cast("str", item["path"])):
        member, analysis = _member(context, reference, adapter)
        members.append(member)
        analyses.append(analysis)
    _references(tuple(analyses))
    # Aggregate only after every member and prospective retained row cost passed.
    analysis = Analysis(
        components=tuple(item for value in analyses for item in value.components),
        findings=tuple(item for value in analyses for item in value.findings),
        relationships=tuple(item for value in analyses for item in value.relationships),
        diagnostics=diagnostics
        + tuple(item for value in analyses for item in value.diagnostics),
    )
    return ValidatedExtension(
        manifest_path=path,
        manifest_sha256=file.sha256,
        input_manifest_sha256=context.input_sha256,
        adapter=adapter,
        result_files=tuple(members),
        analysis=analysis,
    )


def _validated(
    context: ExtensionValidation, manifest_paths: tuple[str, ...] | None
) -> tuple[ValidatedExtension, ...]:
    """Select manifest_paths (tuple[str, ...] or None) using ExtensionValidation.

    Returns a sorted ValidatedExtension tuple; invalid selections/data raise
    ExtensionResultError. context is operation-local mutable reservation state;
    no I/O or partial return occurs.
    """
    configured = context.snapshot.profile.analyzers.extension_result_manifests
    selected = configured if manifest_paths is None else manifest_paths
    if (
        type(selected) is not tuple
        or len(selected) > context.limits.artifact_records
        or any(type(path) is not str for path in selected)
    ):
        raise ExtensionResultError("EXTENSION_SELECTION")
    if len(set(selected)) != len(selected) or not set(selected).issubset(configured):
        raise ExtensionResultError("EXTENSION_SELECTION")
    # No result escapes if a later manifest fails validation or consumes the budget.
    return tuple(_manifest(context, path) for path in sorted(selected))


def validate_extension_results(
    snapshot: DiscoverySnapshot, *, manifest_paths: tuple[str, ...] | None = None
) -> tuple[ValidatedExtension, ...]:
    """Validate selected inert extension artifacts from immutable snapshot bytes.

    snapshot (DiscoverySnapshot) must be configured and load-valid. manifest_paths
    (tuple[str, ...] or None) selects a configured subset or all paths. Returns
    immutable descriptive carriers. Raises ExtensionResultError for invalid data; draft
    profile
    rejection remains fail closed. Performs no filesystem/process/network operation.
    Documentation participates in input digest/accounting but cannot be an extension
    source claim under the current source/test/entrypoint loader contract.
    """
    try:
        return _validated(ExtensionValidation(snapshot), manifest_paths)
    except ExtensionResultError:
        raise
    except ValueError as error:
        raise ExtensionResultError("EXTENSION_INPUT") from error


def _merge_budget(
    context: ExtensionValidation,
    core: InventoryResult,
    extensions: tuple[ValidatedExtension, ...],
) -> None:
    """Reserve full output before flattening, including newly linked diagnostic IDs.

    Canonical core bytes plus each added row/adapter/separator and file diagnostic
    reference conservatively bound the emitter's complete wire document. Separate
    semantic-row and JSON-traversal counters include all error/fallback rows.
    context supplies profile limits; core is InventoryResult; extensions is a
    ValidatedExtension tuple. Returns None or raises ExtensionResultError for
    exhaustion/collision. Does not change inputs or perform I/O.
    """
    # The existing emitter compares every input with every emitted diagnostic.
    diagnostic_count = len(object_rows(core.document, "diagnostics")) + sum(
        len(extension.analysis.diagnostics) for extension in extensions
    )
    check_link_work(
        len(context.capture.inputs),
        diagnostic_count,
        context.limits.parse_limits().expanded_nodes,
    )
    reservation = budget(context.limits)
    # The built-in result is authoritative and is never overwritten by imported rows.
    core_rows = sum(len(object_rows(core.document, family)) for family, _ in _FAMILIES)
    reservation.reserve(core.document, records=core_rows)
    # Index exact per-family IDs once before checking all added rows for collisions.
    identities = {
        family: {item[key] for item in object_rows(core.document, family)}
        for family, key in _FAMILIES
    }
    # Every external row and its possible file linkage contributes to the final budget.
    for extension in extensions:
        reservation.reserve(extension.adapter)
        # All row families, including error diagnostics, consume the shared output
        # ceiling.
        for family, key in _FAMILIES:
            rows = cast("tuple[JsonObject, ...]", getattr(extension.analysis, family))
            # Validation already checked external collisions; core collisions also fail.
            for item in rows:
                reservation.reserve(item, records=1)
                if item[key] in identities[family]:
                    raise ExtensionResultError("EXTENSION_COLLISION")
                identities[family].add(item[key])
                if family == "diagnostics" and item["path"] is not None:
                    reservation.reserve(item["id"])


def merge_extension_inventory(
    snapshot: DiscoverySnapshot,
    *,
    timestamp: str,
    author_or_agent: JsonObject,
    manifest_paths: tuple[str, ...] | None = None,
) -> InventoryResult:
    """Reconstruct core plus external inventory from snapshot, never a proof carrier.

    snapshot (DiscoverySnapshot) holds immutable input bytes. timestamp (str) and
    author_or_agent (JsonObject) are explicit capture metadata. manifest_paths
    (tuple[str, ...] or None) selects a configured subset or all paths. Returns
    schema-valid
    InventoryResult and unassigned ledger proposals, preserving all core rows and
    blockers. Invalid data/budgets raise ExtensionResultError before return. This
    pure operation does not write, approve coverage or authorize later mutation.
    """
    try:
        context = ExtensionValidation(snapshot)
        # Bound caller metadata before the built-in emitter can copy or serialize it.
        metadata_budget = budget(context.limits)
        metadata_budget.reserve(timestamp)
        metadata_budget.reserve(author_or_agent)
        extensions = _validated(context, manifest_paths)
        core = run_inventory(
            context.capture,
            timestamp=timestamp,
            author_or_agent=author_or_agent,
            catalog=snapshot.catalog,
        )
        _merge_budget(context, core, extensions)
        # Preflight completed before these collections or the emitted merge are
        # allocated.
        analyses = (_analysis(core.document),) + tuple(
            item.analysis for item in extensions
        )
        # External versions come only from the validated descriptors, never runtime
        # defaults.
        adapters = tuple(item.adapter for item in extensions)
        # The emitter keeps built-in selection separate from external version authority.
        identifiers = tuple(
            cast("str", item["id"]) for item in object_rows(core.document, "analyzers")
        )
        return inventory_result(
            context.capture,
            analyses,
            analyzer_ids=identifiers,
            timestamp=timestamp,
            author_or_agent=author_or_agent,
            catalog=snapshot.catalog,
            extension_adapters=adapters,
        )
    except ExtensionResultError:
        raise
    except ValueError as error:
        raise ExtensionResultError("EXTENSION_MERGE") from error
