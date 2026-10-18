"""Check scope selection and current inventory identity without external reads."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.coverage_rules import validate_coverage
from drm_copilot_discovery.coverage_scope_rules import (
    inventory_configuration_digest,
    object_rows,
    strings,
)
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.profile_v2 import ProfileV2
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.test_coverage_rules import (
    codes,
    component,
    coverage_snapshot,
    detection,
)
from tests.discovery_runtime.test_evidence_rules import CONTENT, PIN
from tests.discovery_runtime.test_references import immutable, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def profile_with(
    profile: ProfileV2, catalog: SchemaCatalog, **changes: object
) -> ProfileV2:
    """Validate fresh profile mutations without changing shared immutable fixtures."""
    value = as_object(to_plain_value(profile.document))
    value.update(changes)
    return ProfileV2(json.dumps(value), format="json", catalog=catalog)


def inventory_origin(snapshot: DiscoverySnapshot) -> DiscoverySnapshot:
    """Represent transported inventory without inferring its original scan profile."""
    return replace(
        snapshot,
        artifacts=tuple(
            (
                replace(item, origin_path=item.path)
                if item.expected_kind in {"inventory-snapshot", "scope"}
                else item
            )
            for item in snapshot.artifacts
        ),
    )


@pytest.mark.parametrize(
    "scope",
    [None, reference("scope", "missing"), reference("feature-contract", "feature")],
)
def test_missing_or_wrong_scope_prevents_accounting(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, scope: object
) -> None:
    """A ledger cannot derive selection from an unresolved or wrong-kind scope."""
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, ledger_changes={"scope_ref": scope}
    )
    assert "COVERAGE_SCOPE" in codes(snapshot)


@pytest.mark.parametrize(
    "location,change",
    [
        ("ledger", {"repository": "foreign"}),
        ("ledger", {"revision": "b" * 40}),
        ("scope", {"repository": None}),
        ("scope", {"repository": {"id": "foreign", "revision": PIN}}),
        ("inventory", {"repository": "foreign"}),
        ("inventory", {"revision": "b" * 40}),
    ],
)
def test_declared_repository_and_pin_cannot_replace_trusted_identity(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    location: str,
    change: dict[str, object],
) -> None:
    """Inventory, ledger and scope must agree with their trusted captured owner."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        ledger_changes=change if location == "ledger" else None,
        scope_changes=change if location == "scope" else None,
        inventory_changes=change if location == "inventory" else None,
    )
    assert "COVERAGE_IDENTITY" in codes(snapshot, complete=False)


@pytest.mark.parametrize("kind", ["scope", "inventory-snapshot", "coverage-ledger"])
def test_trusted_pin_mismatch_is_rejected_even_when_documents_agree(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, kind: str
) -> None:
    """Untrusted declarations cannot establish the provenance of retained bytes."""
    snapshot = coverage_snapshot(snapshot_profile, snapshot_catalog)
    changed = tuple(
        (
            replace(
                item,
                repository=RepositoryIdentity(id=item.repository.id, revision="b" * 40),
            )
            if item.expected_kind == kind
            else item
        )
        for item in snapshot.artifacts
    )
    assert "COVERAGE_IDENTITY" in codes(replace(snapshot, artifacts=changed))


@pytest.mark.parametrize("case", ["scope-empty", "ledger-missing", "scope-missing"])
def test_scope_and_ledger_share_the_complete_resolved_inventory_set(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Omitted and unresolved inventory links cannot silently narrow accounting."""
    missing = [reference("inventory-snapshot", "missing")]
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        scope_changes=(
            {"inventory_snapshot_refs": [] if case == "scope-empty" else missing}
            if case != "ledger-missing"
            else None
        ),
        ledger_changes=(
            {"inventory_snapshot_refs": missing} if case == "ledger-missing" else None
        ),
    )
    assert "COVERAGE_INVENTORY" in codes(snapshot, complete=False)


def test_null_pin_empty_draft_does_not_claim_completion(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A structurally valid unconfigured ledger remains incomplete."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[],
        ledger_changes={"revision": None, "inventory_snapshot_refs": []},
        scope_changes={
            "status": "draft",
            "confirmed_by": None,
            "repository": {"id": snapshot_profile.repository.id, "revision": None},
            "inventory_snapshot_refs": [],
            "included_roots": [],
        },
    )
    assert codes(snapshot, complete=False) == set()
    assert {"COVERAGE_CONFIRMATION", "COVERAGE_INVENTORY"} <= codes(snapshot)


@pytest.mark.parametrize(
    "confirmation",
    [
        None,
        {"owner": "", "timestamp": "2026-01-01T00:00:00Z", "evidence_refs": []},
        {
            "owner": "analyst",
            "timestamp": "not-a-time",
            "evidence_refs": [reference("evidence-reference", "capture")],
        },
        {
            "owner": "analyst",
            "timestamp": "2026-01-01T00:00:00Z",
            "evidence_refs": [reference("evidence-reference", "missing")],
        },
    ],
)
def test_confirmation_is_a_supported_claim_even_in_structural_mode(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, confirmation: object
) -> None:
    """Confirmed labels require owner, timestamp and usable local evidence."""
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, scope_changes={"confirmed_by": confirmation}
    )
    assert "COVERAGE_CONFIRMATION" in codes(snapshot, complete=False)


@pytest.mark.parametrize(
    "selector,missing",
    [
        ({"included_roots": ["src"]}, True),
        ({"included_roots": ["sr"]}, False),
        ({"included_roots": [], "included_components": ["component"]}, True),
        (
            {
                "included_roots": [],
                "included_features": [reference("feature-contract", "feature")],
            },
            True,
        ),
    ],
)
def test_root_component_and_feature_selectors_preserve_scope_boundaries(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    selector: dict[str, object],
    missing: bool,
) -> None:
    """Root selection uses path segments; component/feature selectors are additive."""
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, rows=[], scope_changes=selector
    )
    assert ("COVERAGE_MISSING" in codes(snapshot)) == missing


def test_linked_selected_feature_adds_component_outside_selected_root(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A feature relationship cannot exempt its unassigned implementation component."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[
            component(
                disposition="unassigned",
                feature_refs=[reference("feature-contract", "feature")],
            )
        ],
        scope_changes={
            "included_roots": ["other"],
            "included_features": [reference("feature-contract", "feature")],
        },
    )
    assert "COVERAGE_INCOMPLETE" in codes(snapshot)


@pytest.mark.parametrize(
    "case,expected",
    [
        ("missing-id", "COVERAGE_SCOPE"),
        ("duplicate", "COVERAGE_COMPONENT"),
        ("foreign-source", "COVERAGE_IDENTITY"),
        ("malformed-source", "COVERAGE_IDENTITY"),
    ],
)
def test_inventory_component_identity_remains_unambiguous(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    case: str,
    expected: str,
) -> None:
    """Selected identity must resolve once and retain the inventory's source owner."""
    detected = (
        [detection(snapshot_profile)] * 2
        if case == "duplicate"
        else (
            [
                detection(
                    snapshot_profile,
                    source=(
                        None
                        if case == "malformed-source"
                        else {"repository": "foreign", "revision": PIN}
                    ),
                )
            ]
            if "source" in case
            else None
        )
    )
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        detected=detected,
        scope_changes=(
            {"included_components": ["missing"]} if case == "missing-id" else None
        ),
    )
    assert expected in codes(snapshot)


@pytest.mark.parametrize(
    "case,expected",
    [
        ("missing", "COVERAGE_INPUTS"),
        ("extra", "COVERAGE_INPUTS"),
        ("changed-hash", "COVERAGE_INPUTS"),
        ("duplicate", "COVERAGE_FILES"),
        ("unsorted", "COVERAGE_FILES"),
        ("unreadable", "COVERAGE_SCAN"),
        ("excluded", "COVERAGE_SCAN"),
    ],
)
def test_complete_scan_requires_exact_captured_input_accounting(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    case: str,
    expected: str,
) -> None:
    """Omitted, stale, duplicated and unjustifiably skipped inputs remain visible."""
    file = SnapshotFile(path="src/component.cs", content=CONTENT, category="source")
    row = {**file.entry(), "status": "inspected"}
    rows: list[object] = [row]
    if case == "missing":
        rows = []
    elif case == "duplicate":
        rows.append(row)
    elif case in {"extra", "unsorted"}:
        rows.append({**row, "path": "src/a.cs"})
    elif case == "changed-hash":
        row["sha256"] = "b" * 64
    else:
        row["status"] = case
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, inventory_changes={"files": rows}
    )
    assert expected in codes(snapshot)
    assert expected not in codes(snapshot, complete=False)


@pytest.mark.parametrize(
    "path,blocking",
    [
        (None, True),
        ("src/component.cs", True),
        ("src/new.cs", True),
        ("src2/other.cs", False),
    ],
)
def test_scan_failures_block_only_global_or_selected_inputs(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    path: str | None,
    blocking: bool,
) -> None:
    """Unrelated diagnostic paths do not widen an explicitly selected scope."""
    diagnostic = {"path": path, "blocking": True, "severity": "warning"}
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        inventory_changes={"diagnostics": [diagnostic]},
    )
    assert ("COVERAGE_SCAN" in codes(snapshot)) == blocking


@pytest.mark.parametrize("rationale", ["Generated files.", ""])
def test_skipped_paths_require_explicit_inventory_exclusion_accounting(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, rationale: str
) -> None:
    """A skipped path cannot disappear from the scan's input accounting."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        inventory_changes={
            "exclusions": [{"path_or_glob": "generated/*", "rationale": rationale}]
        },
    )
    snapshot = replace(snapshot, excluded_paths=("generated/code.cs",))
    assert ("COVERAGE_INPUTS" in codes(snapshot)) == (not rationale)


def test_excluded_selected_scan_input_requires_scope_rationale(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A confirmed scope can explicitly account for an intentionally excluded path."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[],
        detected=[],
        scope_changes={
            "exclusions": [{"path_or_glob": "src/*", "rationale": "Generated."}]
        },
        inventory_changes={
            "files": [
                {
                    "path": "src/component.cs",
                    "status": "excluded",
                    "rationale": "Generated.",
                }
            ]
        },
    )
    assert codes(snapshot) == set()


@pytest.mark.parametrize("imported", [False, True])
def test_current_configuration_is_checked_only_against_its_own_profile(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, imported: bool
) -> None:
    """Transported source configuration cannot be compared to consumer settings."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        inventory_changes={"scan_configuration_sha256": "b" * 64},
    )
    addition = SnapshotFile(path="modern/New.cs", content=b"target", category="source")
    snapshot = replace(
        snapshot,
        manifest=replace(snapshot.manifest, files=(*snapshot.manifest.files, addition)),
    )
    if imported:
        snapshot = inventory_origin(snapshot)
    assert ("COVERAGE_CONFIGURATION" in codes(snapshot)) != imported
    assert ("COVERAGE_INPUTS" in codes(snapshot)) != imported


def test_configuration_digest_preserves_scan_semantics(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Root order and owners are irrelevant while scan options change identity."""
    first = profile_with(
        snapshot_profile, snapshot_catalog, production_roots=["src", "lib"]
    )
    reordered = profile_with(
        first, snapshot_catalog, production_roots=["lib", "src"], decision_owners=[]
    )
    assert inventory_configuration_digest(first) == inventory_configuration_digest(
        reordered
    )
    assert inventory_configuration_digest(first) != inventory_configuration_digest(
        snapshot_profile
    )
    analyzers = as_object(to_plain_value(first.document["analyzers"]))
    analyzers["options"] = {"max_file_bytes": 1000}
    ordered = profile_with(first, snapshot_catalog, analyzers=analyzers)
    analyzers["options"] = {"max_file_bytes": 2000}
    changed = profile_with(first, snapshot_catalog, analyzers=analyzers)
    assert inventory_configuration_digest(ordered) != inventory_configuration_digest(
        changed
    )


def test_disabled_completion_policies_do_not_invent_completed_inspection(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Profile switches affect prerequisites without changing structural claims."""
    gates = as_object(to_plain_value(snapshot_profile.document["completion_gates"]))
    gates.update(
        require_confirmed_scope=False,
        require_current_inventory=False,
        require_all_dispositions=False,
        require_runtime_for_declared_features=False,
    )
    profile = profile_with(snapshot_profile, snapshot_catalog, completion_gates=gates)
    snapshot = coverage_snapshot(
        profile,
        snapshot_catalog,
        rows=[
            component(
                inspection_status="uninspected",
                disposition="unassigned",
                runtime_validation_requirement="undetermined",
            )
        ],
        scope_changes={"status": "draft", "confirmed_by": None},
    )
    assert validate_coverage(snapshot, complete=True).findings == ()


def test_malformed_inventory_rows_do_not_crash_or_shift_selection(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Structural errors retain their physical positions for later schema findings."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        detected=[None, {"component_id": None}, detection(snapshot_profile)],
        inventory_changes={"files": [None, {"path": None}]},
    )
    assert "COVERAGE_INPUTS" in codes(snapshot)
    assert object_rows(None) == () and strings(None) == frozenset()
    assert strings(immutable({"value": [1, "a"]})["value"]) == frozenset({"a"})


def test_bad_payload_cannot_support_inspection_or_confirmation(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Referenced evidence must pass the accepted checksum assessment."""
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, proof_changes={"checksum": None}
    )
    assert {"COVERAGE_EVIDENCE", "COVERAGE_CONFIRMATION"} <= codes(snapshot)
