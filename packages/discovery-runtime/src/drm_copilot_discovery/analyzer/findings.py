"""Build deterministic analyzer identities and source-bound inert result rows.

These helpers describe captured syntax and provenance. They never classify legacy
feature behavior, decide target requirements, inspect a workspace, or write files.
"""

from __future__ import annotations

import hashlib
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryInput


def row(**values: JsonValue) -> JsonObject:
    """Freeze one schema-shaped object, rejecting mutable/non-JSON descendants.

    values (JsonValue keyword members) supply immutable schema fields. Returns a
    JsonObject; raises ValueError for non-JSON descendants. Performs no I/O or input
    mutation.
    """
    return JsonObject(tuple(values.items()))


def stable_id(prefix: str, value: JsonValue) -> str:
    """Bind a portable identifier to canonical semantic data, never timestamps.

    prefix (str) labels the identifier; value (JsonValue) contains semantic fields.
    Returns str containing the prefix and SHA-256. Invalid JSON raises ValueError;
    no I/O or mutation occurs.
    """
    return prefix + "-" + hashlib.sha256(canonical_json(value)).hexdigest()


def tool(identifier: str) -> JsonObject:
    """Identify a built-in adapter implementation independently of caller labels.

    identifier (str) is the fixed registered adapter name. Returns a JsonObject with
    id and implementation version. Performs no I/O or mutation.
    """
    return row(id=identifier, version="2.0.0")


def source_reference(capture: InventoryCapture, item: InventoryInput) -> JsonObject:
    """Bind one inspected source to retained bytes and its configured full revision.

    The separate provenance diagnostic retains an unverified pin; this reference
    alone never proves the current working copy equals its immutable Git source.

    capture (InventoryCapture) supplies the configured repository pin; item
    (InventoryInput) supplies exact retained bytes. Returns a JsonObject source
    descriptor. Raises ValueError for unavailable inputs; performs no I/O or
    mutation.
    """
    if item.file is None or item.sha256 is None:
        raise ValueError("Source references require inspected captured bytes")
    return row(
        repository=capture.profile.repository.id,
        revision=capture.profile.repository.revision,
        path=item.path,
        sha256=item.sha256,
    )


def pinned_matches(capture: InventoryCapture, item: InventoryInput) -> bool:
    """Compare retained bytes with matching pinned Git input; no hash rereads or I/O.

    capture (InventoryCapture) holds previously captured Git objects; item
    (InventoryInput) is the input to compare. Returns bool, false when bytes or
    matching provenance are absent. Performs no I/O or mutation.
    """
    # All identity dimensions and exact bytes must agree before confidence increases.
    return item.file is not None and any(
        source.repository.id == capture.profile.repository.id
        and source.repository.revision == capture.profile.repository.revision
        and source.path == item.path
        and source.content == item.file.content
        for source in capture.repository_files
    )


def diagnostic(
    code: str,
    path: str | None,
    message: str,
    *,
    analyzer: str = "repository",
    blocking: bool = True,
) -> JsonObject:
    """Create a stable actionable diagnostic without OS-specific exception text.

    code, message and analyzer (str) describe a fixed failure; path (str | None)
    identifies its source and blocking (bool) selects severity. Returns a JsonObject
    diagnostic. Performs no I/O or mutation.
    """
    identity = row(code=code, path=path, analyzer=analyzer)
    return row(
        id=stable_id("diagnostic", identity),
        code=code,
        severity="error" if blocking else "warning",
        path=path,
        message=message,
        analyzer_id=analyzer,
        blocking=blocking,
        extensions=row(),
    )


def seed_component(component: JsonObject) -> JsonObject:
    """Propose an uninspected, unassigned ledger row without changing authored scope.

    The caller must align ledger inventory references with root-authored scope
    before proposing publication. Detection never checks off discovery coverage.

    component (JsonObject) must be a schema-valid detected component. Returns a
    JsonObject coverage proposal with no feature assignments. Missing required
    fields raise KeyError; performs no I/O or mutation.
    """
    source = cast("JsonObject", component["source"])
    return row(
        component_id=component["component_id"],
        component_type=component["component_type"],
        path=source["path"],
        source_sha256=source["sha256"],
        inspection_status="uninspected",
        disposition="unassigned",
        feature_refs=(),
        tests_found=(),
        runtime_validation_requirement="undetermined",
        runtime_rationale=None,
        exclusion_rationale=None,
        exclusion_scope_ref=None,
        supporting_rationale=None,
        blocked_reason=None,
        responsible_workflow="inventory-legacy-system",
        responsible_agent=None,
        last_updated_evidence_refs=(),
        extensions=row(),
    )
