"""Bind coverage scope and current inventory to captured identities and inputs."""

from __future__ import annotations

import hashlib
from dataclasses import dataclass
from fnmatch import fnmatchcase
from types import MappingProxyType
from typing import TYPE_CHECKING

from drm_copilot_discovery.models import JsonObject, JsonValue, canonical_json
from drm_copilot_discovery.runtime_claim_rules import has_text
from drm_copilot_discovery.schema_validation import is_rfc3339_timestamp
from drm_copilot_discovery.snapshot_io import within_roots

if TYPE_CHECKING:
    from collections.abc import Mapping

    from drm_copilot_discovery.claim_rules import ClaimContext
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.references import ArtifactRecord
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def object_rows(value: JsonValue) -> tuple[tuple[int, JsonObject], ...]:
    """Retain physical array positions while ignoring structurally invalid rows."""
    # Graph checks preserve pointers even when preceding rows are malformed.
    return (
        tuple((i, row) for i, row in enumerate(value) if isinstance(row, JsonObject))
        if isinstance(value, tuple)
        else ()
    )


def strings(value: JsonValue) -> frozenset[str]:
    """Return explicit string selectors without coercing invalid upstream values."""
    return (
        frozenset(item for item in value if isinstance(item, str))
        if isinstance(value, tuple)
        else frozenset()
    )


def _configuration(value: JsonValue) -> JsonValue:
    """Canonicalize unordered configuration selectors, preserving scalar options."""
    if isinstance(value, JsonObject):
        return JsonObject(
            tuple(
                (key, item if key == "options" else _configuration(item))
                for key, item in value.items()
            )
        )
    if isinstance(value, tuple):
        return tuple(
            sorted((_configuration(item) for item in value), key=canonical_json)
        )
    return value


def inventory_configuration_digest(profile: ProfileV2) -> str:
    """Hash only local scan selection/configuration, with unordered selector arrays.

    Includes production/test/project/documentation/evidence roots, artifact roots,
    exclusions and analyzer configuration. Opaque analyzer options retain array
    order. Owners, completion policy and Git HEAD are excluded. Analyzers must
    use this helper for scan_configuration_sha256.
    """
    keys = (
        "production_roots",
        "test_roots",
        "project_entry_points",
        "documentation_roots",
        "evidence_roots",
        "artifacts",
        "excluded_paths",
        "analyzers",
    )
    value = JsonObject(
        tuple((key, _configuration(profile.document[key])) for key in keys)
    )
    return hashlib.sha256(canonical_json(value)).hexdigest()


def excluded(path: str, scope: ArtifactRecord) -> bool:
    """Require an explicit matching scope exclusion and substantive rationale."""
    # Use the same case-sensitive glob semantics as snapshot input selection.
    return any(
        isinstance(pattern := row.get("path_or_glob"), str)
        and fnmatchcase(path, pattern)
        and has_text(row.get("rationale"))
        for _, row in object_rows(scope.document.get("exclusions"))
    )


@dataclass(frozen=True)
class CoverageScope:
    """Retain resolved scope, inventory components and selected source identities.

    Constructed only after repository/reference checks. The immutable mapping
    supports ledger validation without rereading inventory or changing selection.
    """

    scope: ArtifactRecord
    inventories: tuple[ArtifactRecord, ...]
    components: Mapping[str, JsonObject]
    selected: frozenset[str]
    feature_only: bool

    def selects_path(self, path: str) -> bool:
        """Recognize explicit root or selected-component membership for diagnostics."""
        if self.feature_only:
            return True
        roots = tuple(strings(self.scope.document.get("included_roots")))
        if within_roots(path, roots):
            return True
        # Exact component paths supplement root selection without prefix mistakes.
        return any(
            isinstance(source := self.components[key].get("source"), JsonObject)
            and source.get("path") == path
            for key in self.selected
        )


def _confirmation(scope: ArtifactRecord, claims: ClaimContext) -> None:
    """Validate a declared confirmation independently from completion policy."""
    confirmation = scope.document.get("confirmed_by")
    timestamp = (
        confirmation.get("timestamp") if isinstance(confirmation, JsonObject) else None
    )
    links = claims.links(scope, "/confirmed_by/evidence_refs")
    valid = bool(links)
    # Scope confirmation may use approval or observation evidence, but never a URI.
    for link in links:
        proof = claims.evidence.for_record(link.target) if link.target else None
        valid = (
            valid
            and proof is not None
            and proof.can_prove(
                repository=scope.repository, revision=scope.artifact.repository.revision
            )
        )
    if (
        not isinstance(confirmation, JsonObject)
        or not has_text(confirmation.get("owner"))
        or not isinstance(timestamp, str)
        or not is_rfc3339_timestamp(timestamp)
        or not valid
    ):
        claims.add(
            "COVERAGE_CONFIRMATION",
            scope,
            "/confirmed_by",
            "Confirmed scope requires owner, timestamp and local proof.",
        )


def _inventory(
    selection: CoverageScope, snapshot: DiscoverySnapshot, claims: ClaimContext
) -> None:
    """Require complete current local inputs and visible selected scan failures."""
    paths: set[str] = set()
    captured = {file.path: file for file in snapshot.manifest.files}
    for inventory in selection.inventories:
        document = inventory.document
        local = (
            inventory.artifact.origin_path is None
            and inventory.repository == snapshot.profile.repository.id
            and inventory.artifact.repository.revision
            == snapshot.profile.repository.revision
        )
        if local and document.get(
            "scan_configuration_sha256"
        ) != inventory_configuration_digest(snapshot.profile):
            claims.add(
                "COVERAGE_CONFIGURATION",
                inventory,
                "/scan_configuration_sha256",
                "Inventory scan configuration differs from the current profile.",
            )
        rows = object_rows(document.get("files"))
        ordered = [row.get("path") for _, row in rows]
        actual = [path for path in ordered if isinstance(path, str)]
        if actual != sorted(set(actual)):
            claims.add(
                "COVERAGE_FILES",
                inventory,
                "/files",
                "Inventory file paths must be sorted and unique.",
            )
        # Every captured scan input is accounted for across the selected inventories.
        for position, row in rows:
            path = row.get("path")
            if not isinstance(path, str):
                continue
            if path in paths:
                claims.add(
                    "COVERAGE_FILES",
                    inventory,
                    f"/files/{position}",
                    "A scan input appears in more than one selected inventory.",
                )
            paths.add(path)
            if local and row.get("status") == "inspected":
                file = captured.get(path)
                if (
                    file is None
                    or row.get("sha256") != file.sha256
                    or row.get("size") != len(file.content)
                ):
                    claims.add(
                        "COVERAGE_INPUTS",
                        inventory,
                        f"/files/{position}",
                        "Inspected scan input differs from the current captured bytes.",
                    )
            if selection.selects_path(path) and (
                row.get("status") == "unreadable"
                or row.get("status") == "excluded"
                and not excluded(path, selection.scope)
            ):
                claims.add(
                    "COVERAGE_SCAN",
                    inventory,
                    f"/files/{position}",
                    "A selected scan input is unreadable or unjustifiably excluded.",
                )
        # Detected components cannot hide global or selected-path scan failures.
        for position, diagnostic in object_rows(document.get("diagnostics")):
            path = diagnostic.get("path")
            if (
                diagnostic.get("blocking") is True
                or diagnostic.get("severity") == "error"
            ) and (
                path is None or isinstance(path, str) and selection.selects_path(path)
            ):
                claims.add(
                    "COVERAGE_SCAN",
                    inventory,
                    f"/diagnostics/{position}",
                    "An incomplete required scan prevents coverage completion.",
                )
    if (
        selection.scope.artifact.origin_path is None
        and selection.scope.repository == snapshot.profile.repository.id
        and selection.scope.artifact.repository.revision
        == snapshot.profile.repository.revision
    ):
        expected = {
            file.path
            for file in snapshot.manifest.files
            if file.category in {"source", "test", "documentation"}
        }
        # Skipped paths need explicit inventory exclusion records.
        for path in snapshot.excluded_paths:
            if not any(
                any(
                    isinstance(pattern := row.get("path_or_glob"), str)
                    and fnmatchcase(path, pattern)
                    and has_text(row.get("rationale"))
                    for _, row in object_rows(item.document.get("exclusions"))
                )
                for item in selection.inventories
            ):
                expected.add(path)
        if not expected <= paths:
            claims.add(
                "COVERAGE_INPUTS",
                selection.scope,
                "/inventory_snapshot_refs",
                "Captured scan inputs are missing from the selected inventory.",
            )


def select_coverage_scope(
    snapshot: DiscoverySnapshot,
    ledger: ArtifactRecord,
    claims: ClaimContext,
    *,
    complete: bool,
) -> CoverageScope | None:
    """Resolve a ledger's exact inventory set and explicit scope without I/O."""
    scopes = claims.targets(ledger, "/scope_ref")
    if len(scopes) != 1 or scopes[0].kind != "scope":
        claims.add(
            "COVERAGE_SCOPE",
            ledger,
            "/scope_ref",
            "A ledger requires one resolvable scope.",
        )
        return None
    scope = scopes[0]
    owner = scope.document.get("repository")
    revision = ledger.document.get("revision")
    if (
        not isinstance(owner, JsonObject)
        or owner.get("id") != ledger.repository
        or scope.repository != ledger.repository
        or ledger.document.get("repository") != ledger.repository
        or owner.get("revision") != revision
        or revision is not None
        and (
            revision != ledger.artifact.repository.revision
            or revision != scope.artifact.repository.revision
        )
    ):
        claims.add(
            "COVERAGE_IDENTITY",
            ledger,
            "/scope_ref",
            "Ledger and scope must share trusted repository and revision.",
        )
        return None
    inventories = claims.targets(ledger, "/inventory_snapshot_refs")
    scoped = claims.targets(scope, "/inventory_snapshot_refs")
    if (
        set(inventories) != set(scoped)
        or len(inventories) != len(claims.links(ledger, "/inventory_snapshot_refs"))
        or len(scoped) != len(claims.links(scope, "/inventory_snapshot_refs"))
    ):
        claims.add(
            "COVERAGE_INVENTORY",
            ledger,
            "/inventory_snapshot_refs",
            "Ledger and scope must resolve the same complete inventory set.",
        )
    if scope.document.get("status") == "confirmed":
        _confirmation(scope, claims)
    gates = snapshot.profile.completion_gates
    if (
        complete
        and gates.required("require_confirmed_scope")
        and scope.document.get("status") != "confirmed"
    ):
        claims.add(
            "COVERAGE_CONFIRMATION",
            scope,
            "/status",
            "Discovery completion requires confirmed scope.",
        )
    if (
        complete
        and gates.required("require_current_inventory")
        and (not inventories or revision is None)
    ):
        claims.add(
            "COVERAGE_INVENTORY",
            ledger,
            "/inventory_snapshot_refs",
            "Discovery completion requires pinned current inventory.",
        )
    components: dict[str, JsonObject] = {}
    # Inventory detections retain provenance and never imply inspection/disposition.
    for inventory in inventories:
        if (
            inventory.kind != "inventory-snapshot"
            or inventory.repository != ledger.repository
            or inventory.document.get("repository") != ledger.repository
            or inventory.document.get("revision") != revision
            or inventory.artifact.repository.revision != revision
        ):
            claims.add(
                "COVERAGE_IDENTITY",
                ledger,
                "/inventory_snapshot_refs",
                "Inventory ownership and pin must match the ledger.",
            )
            continue
        for position, component in object_rows(inventory.document.get("components")):
            identifier = component.get("component_id")
            if not isinstance(identifier, str):
                continue
            source = component.get("source")
            if (
                not isinstance(source, JsonObject)
                or source.get("repository") != inventory.repository
                or source.get("revision") != revision
            ):
                claims.add(
                    "COVERAGE_IDENTITY",
                    inventory,
                    f"/components/{position}/source",
                    "Component ownership and pin must match its inventory.",
                )
            if identifier in components:
                claims.add(
                    "COVERAGE_COMPONENT",
                    inventory,
                    f"/components/{position}",
                    "Inventory component identity is duplicated.",
                )
            components[identifier] = component
    selected = set(strings(scope.document.get("included_components")))
    roots = tuple(strings(scope.document.get("included_roots")))
    features = claims.targets(scope, "/included_features") + claims.targets(
        scope, "/required_coverage/feature_refs"
    )
    feature_only = bool(features) and not roots and not selected
    # Root/component selectors are additive; feature-only selection stays conservative.
    for identifier, component in components.items():
        source = component.get("source")
        path = source.get("path") if isinstance(source, JsonObject) else None
        if isinstance(path, str) and within_roots(path, roots) or feature_only:
            selected.add(identifier)
    for position, row in object_rows(ledger.document.get("components")):
        if any(
            feature in features
            for feature in claims.targets(
                ledger, f"/components/{position}/feature_refs"
            )
        ) and isinstance(identifier := row.get("component_id"), str):
            selected.add(identifier)
    if not selected <= components.keys():
        claims.add(
            "COVERAGE_SCOPE",
            scope,
            "/included_components",
            "Selected components are absent from the linked inventory.",
        )
    selection = CoverageScope(
        scope,
        inventories,
        MappingProxyType(components),
        frozenset(selected & components.keys()),
        feature_only,
    )
    if complete and gates.required("require_current_inventory"):
        _inventory(selection, snapshot, claims)
    return selection
