"""Check ledger claims and completion separately using fresh in-memory graphs."""

from __future__ import annotations

import hashlib
from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.claim_rules import ClaimValidation, validate_claims
from drm_copilot_discovery.coverage_rules import validate_coverage
from drm_copilot_discovery.coverage_scope_rules import inventory_configuration_digest
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.test_evidence_rules import CONTENT, PIN, evidence
from tests.discovery_runtime.test_observation_claims import claim_snapshot, contract
from tests.discovery_runtime.test_references import artifact, reference
from tests.discovery_runtime.test_runtime_claims import scenario
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from collections.abc import Sequence

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot


def component(**changes: object) -> dict[str, object]:
    """Return a fresh inspected disposition without deriving it from detection."""
    return {
        "component_id": "component",
        "component_type": "class",
        "path": "src/component.cs",
        "source_sha256": hashlib.sha256(CONTENT).hexdigest(),
        "inspection_status": "inspected",
        "disposition": "supporting",
        "feature_refs": [],
        "tests_found": [],
        "supporting_rationale": "Shared infrastructure.",
        "runtime_validation_requirement": "not-required",
        "runtime_rationale": "Pure helper.",
        "last_updated_evidence_refs": [reference("evidence-reference", "capture")],
        **changes,
    }


def detection(profile: ProfileV2, **changes: object) -> dict[str, object]:
    """Keep inventory identity independent of the ledger's authored claims."""
    return {
        "component_id": "component",
        "component_type": "class",
        "classification": "detected",
        "source": {
            "repository": profile.repository.id,
            "revision": PIN,
            "path": "src/component.cs",
            "sha256": hashlib.sha256(CONTENT).hexdigest(),
        },
        **changes,
    }


def coverage_snapshot(
    profile: ProfileV2,
    catalog: SchemaCatalog,
    *,
    rows: Sequence[object] | None = None,
    detected: Sequence[object] | None = None,
    ledger_changes: dict[str, object] | None = None,
    scope_changes: dict[str, object] | None = None,
    inventory_changes: dict[str, object] | None = None,
    extra: tuple[ArtifactSnapshot, ...] = (),
    proof_changes: dict[str, object] | None = None,
    inputs: tuple[SnapshotFile, ...] = (),
) -> DiscoverySnapshot:
    """Capture isolated ledger, scope, inventory, proof and selected source bytes."""
    inventory_link = reference("inventory-snapshot", "inventory")
    source = SnapshotFile(path="src/component.cs", content=CONTENT, category="source")
    inventory = artifact(
        "inventory-snapshot",
        "inventory",
        repository=profile.repository.id,
        fields={
            "repository": profile.repository.id,
            "revision": PIN,
            "scan_configuration_sha256": inventory_configuration_digest(profile),
            "components": [detection(profile)] if detected is None else detected,
            "files": [
                {
                    "path": item.path,
                    "status": "inspected",
                    "sha256": item.sha256,
                    "size": len(item.content),
                }
                for item in sorted((source, *inputs), key=lambda item: item.path)
            ],
            "diagnostics": [],
            "exclusions": [],
            **(inventory_changes or {}),
        },
    )
    scope = artifact(
        "scope",
        "scope",
        repository=profile.repository.id,
        fields={
            "repository": {"id": profile.repository.id, "revision": PIN},
            "status": "confirmed",
            "included_roots": ["src"],
            "included_components": [],
            "included_features": [],
            "exclusions": [],
            "inventory_snapshot_refs": [inventory_link],
            "confirmed_by": {
                "owner": "analyst",
                "timestamp": "2026-01-01T00:00:00Z",
                "evidence_refs": [reference("evidence-reference", "capture")],
            },
            **(scope_changes or {}),
        },
    )
    ledger = artifact(
        "coverage-ledger",
        "ledger",
        repository=profile.repository.id,
        fields={
            "repository": profile.repository.id,
            "revision": PIN,
            "scope_ref": reference("scope", "scope"),
            "inventory_snapshot_refs": [inventory_link],
            "components": [component()] if rows is None else rows,
            **(ledger_changes or {}),
        },
    )
    snapshot = claim_snapshot(
        profile,
        catalog,
        ledger,
        scope,
        inventory,
        contract(profile),
        evidence(profile, changes=proof_changes),
        *extra,
    )
    return replace(
        snapshot,
        manifest=replace(
            snapshot.manifest, files=(*snapshot.manifest.files, source, *inputs)
        ),
        repository_files=(
            *snapshot.repository_files,
            *(
                RepositoryFile(
                    repository=ledger.repository, path=item.path, content=item.content
                )
                for item in (source, *inputs)
            ),
        ),
    )


def codes(snapshot: DiscoverySnapshot, *, complete: bool = True) -> set[str]:
    """Expose only diagnostic codes while retaining detailed findings on failure."""
    return {
        finding.code
        for finding in validate_coverage(snapshot, complete=complete).findings
    }


def test_complete_ledger_reuses_proof_without_mutating_inputs(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """A fully accounted scope passes with reusable immutable graph assessments."""
    snapshot = coverage_snapshot(snapshot_profile, snapshot_catalog)
    before = snapshot.sha256
    index = index_references(snapshot)
    proof = validate_evidence(snapshot, index=index)
    claims = validate_claims(snapshot, index=index, evidence=proof)
    result = validate_coverage(
        snapshot, complete=True, index=index, evidence=proof, claims=claims
    )
    assert result.findings == ()
    assert snapshot.sha256 == before


@pytest.mark.parametrize(
    "inspection,disposition",
    [
        ("uninspected", "unassigned"),
        ("blocked", "blocked"),
        ("inspected", "unassigned"),
    ],
)
def test_draft_rows_are_valid_but_cannot_complete(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    inspection: str,
    disposition: str,
) -> None:
    """Recorded uncertainty remains valid without implying complete discovery."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[
            component(
                inspection_status=inspection,
                disposition=disposition,
                blocked_reason="Source unavailable.",
            )
        ],
    )
    assert codes(snapshot, complete=False) == set()
    assert "COVERAGE_INCOMPLETE" in codes(snapshot)


@pytest.mark.parametrize(
    "rows,expected",
    [
        ([], "COVERAGE_MISSING"),
        ([component(), component()], "COVERAGE_DUPLICATE"),
        ([component(component_id="foreign")], "COVERAGE_FOREIGN_COMPONENT"),
        ([component(component_id=None)], "COVERAGE_FOREIGN_COMPONENT"),
    ],
)
def test_inventory_identity_requires_exact_once_accounting(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    rows: list[object],
    expected: str,
) -> None:
    """Missing, duplicate and foreign rows cannot count as inventory coverage."""
    snapshot = coverage_snapshot(snapshot_profile, snapshot_catalog, rows=rows)
    assert expected in codes(snapshot)


@pytest.mark.parametrize(
    "field,value",
    [
        ("component_type", "method"),
        ("path", "src/other.cs"),
        ("source_sha256", "f" * 64),
        ("symbol", "Other"),
        ("line_range", {"start": 1, "end": 2}),
    ],
)
def test_ledger_cannot_rewrite_inventory_provenance(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: object,
) -> None:
    """Every retained component coordinate must match the original detection."""
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, rows=[component(**{field: value})]
    )
    assert "COVERAGE_COMPONENT" in codes(snapshot, complete=False)


@pytest.mark.parametrize(
    "changes,expected",
    [
        ({"last_updated_evidence_refs": []}, "COVERAGE_EVIDENCE"),
        ({"inspection_status": "uninspected"}, "COVERAGE_INSPECTION"),
        ({"supporting_rationale": " "}, "COVERAGE_RATIONALE"),
        ({"disposition": "feature-linked"}, "COVERAGE_FEATURE"),
        ({"disposition": "blocked", "blocked_reason": None}, "COVERAGE_RATIONALE"),
        ({"runtime_rationale": ""}, "COVERAGE_RATIONALE"),
    ],
)
def test_positive_disposition_claims_require_independent_support(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    changes: dict[str, object],
    expected: str,
) -> None:
    """A status label cannot replace inspection, evidence, linkage or rationale."""
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, rows=[component(**changes)]
    )
    assert expected in codes(snapshot, complete=False)


@pytest.mark.parametrize("broken", [False, True])
def test_feature_links_must_resolve_completely(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, broken: bool
) -> None:
    """A valid feature cannot hide a second unresolved feature link."""
    links = [reference("feature-contract", "feature")]
    if broken:
        links.append(reference("feature-contract", "missing"))
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[component(disposition="feature-linked", feature_refs=links)],
    )
    assert ("COVERAGE_FEATURE" in codes(snapshot)) == broken


@pytest.mark.parametrize(
    "change", ["none", "scope", "draft", "pattern", "rationale", "path"]
)
def test_explicit_exclusions_allow_uninspected_accounting(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, change: str
) -> None:
    """Only the linked confirmed scope can justify an excluded component."""
    scope: dict[str, object] = {
        "exclusions": [
            {
                "path_or_glob": "src/*" if change != "pattern" else "other/*",
                "rationale": "Generated code.",
            }
        ]
    }
    if change == "draft":
        scope.update(status="draft", confirmed_by=None)
    row = component(
        inspection_status="uninspected",
        disposition="excluded",
        exclusion_rationale="Generated." if change != "rationale" else "",
        exclusion_scope_ref=reference(
            "scope", "missing" if change == "scope" else "scope"
        ),
    )
    if change == "path":
        row["path"] = None
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, rows=[row], scope_changes=scope
    )
    assert ("COVERAGE_EXCLUSION" in codes(snapshot)) == (change != "none")
    if change == "none":
        assert codes(snapshot) == set()


@pytest.mark.parametrize(
    "case",
    [
        "observed",
        "not-run",
        "broken-capture",
        "no-feature",
        "no-scenario",
        "undetermined",
        "foreign-repository",
        "foreign-pin",
    ],
)
def test_runtime_need_requires_valid_feature_characterization(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Runtime capability or source inspection cannot waive a declared runtime need."""
    extra = (
        ()
        if case == "no-scenario"
        else (
            scenario(
                snapshot_profile,
                status="not-run" if case == "not-run" else "observed",
                overrides={"evidence_refs": []} if case == "broken-capture" else {},
                feature_refs=[
                    reference(
                        "feature-contract",
                        "feature",
                        repository=snapshot_profile.repository.id,
                    )
                ],
            ),
        )
    )
    row = component(
        runtime_validation_requirement=(
            "undetermined" if case == "undetermined" else "required"
        ),
        feature_refs=(
            [] if case == "no-feature" else [reference("feature-contract", "feature")]
        ),
    )
    claims = None
    if case.startswith("foreign") and extra:
        repository_id = snapshot_profile.repository.id
        if case == "foreign-repository":
            repository_id = "foreign"
        owner = RepositoryIdentity(id=repository_id, revision="b" * 40)
        extra = (replace(extra[0], repository=owner),)
        # An independently valid target claim is insufficient for the source.
        claims = ClaimValidation(())
    snapshot = coverage_snapshot(
        snapshot_profile, snapshot_catalog, rows=[row], extra=extra
    )
    result = validate_coverage(snapshot, complete=True, claims=claims)
    assert any(f.code == "COVERAGE_RUNTIME" for f in result.findings) == (
        case != "observed"
    )
    assert "COVERAGE_RUNTIME" not in codes(snapshot, complete=False)


@pytest.mark.parametrize(
    "case", ["valid", "missing-bytes", "missing-proof", "invalid-path"]
)
def test_test_relationships_need_pinned_bytes_and_local_proof(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Detected tests establish relevance without claiming execution or coverage."""
    test = {
        "path": None if case == "invalid-path" else "tests/example.py",
        "classification": "detected",
        "confidence": "low",
        "evidence_refs": (
            []
            if case == "missing-proof"
            else [reference("evidence-reference", "capture")]
        ),
    }
    inputs = (
        ()
        if case == "missing-bytes"
        else (
            SnapshotFile(
                path="tests/example.py", content=b"assert True", category="test"
            ),
        )
    )
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[component(tests_found=[test])],
        inputs=inputs,
    )
    assert ("COVERAGE_TEST" in codes(snapshot)) == (case != "valid")


def test_malformed_preceding_rows_keep_physical_diagnostic_positions(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """Invalid upstream rows do not shift reference pointers or raise exceptions."""
    tests: list[object] = [None, {"path": "tests/missing.py", "evidence_refs": []}]
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[
            None,
            component(tests_found=tests),
        ],
    )
    findings = validate_coverage(snapshot).findings
    assert any(
        f.pointer == "/components/1/tests_found/1" and f.code == "COVERAGE_TEST"
        for f in findings
    )
    assert not any(f.code == "COVERAGE_EVIDENCE" for f in findings)


def test_no_ledger_is_a_completion_gap_only(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> None:
    """An empty draft graph is allowed while discovery needs an actual ledger."""
    snapshot = claim_snapshot(snapshot_profile, snapshot_catalog)
    assert codes(snapshot, complete=False) == set()
    assert codes(snapshot) == {"COVERAGE_LEDGER"}


@pytest.mark.parametrize("failed_detection", [False, True])
def test_feature_only_scope_retains_undetected_inputs_and_all_components(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog, failed_detection: bool
) -> None:
    """Feature-only selection cannot hide a failed scan or a second detection."""
    detected = (
        []
        if failed_detection
        else [
            detection(snapshot_profile),
            detection(snapshot_profile, component_id="second"),
        ]
    )
    diagnostics = (
        [{"path": "src/component.cs", "blocking": True}] if failed_detection else []
    )
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        detected=detected,
        rows=[] if failed_detection else [component()],
        inventory_changes={"diagnostics": diagnostics},
        scope_changes={
            "included_roots": [],
            "included_features": [reference("feature-contract", "feature")],
        },
    )
    assert ("COVERAGE_SCAN" if failed_detection else "COVERAGE_MISSING") in codes(
        snapshot
    )
