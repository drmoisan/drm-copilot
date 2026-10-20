"""Verify source coverage populations and diagnostic reports entirely in memory."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.claim_rules import validate_claims
from drm_copilot_discovery.coverage_report import coverage_summary
from drm_copilot_discovery.coverage_rules import validate_coverage
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import validate_dimensions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.repository_reader import RepositoryIdentity
from drm_copilot_discovery.revision_rules import validate_revisions

from tests.discovery_runtime.test_coverage_rules import (
    component,
    coverage_snapshot,
    detection,
)
from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_dimension_rules import client, feature
from tests.discovery_runtime.test_evidence_rules import configured
from tests.discovery_runtime.test_observation_claims import dimension, question
from tests.discovery_runtime.test_references import artifact, reference
from tests.discovery_runtime.test_runtime_claims import environment, execution, scenario
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import replace_document
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def summary(
    snapshot: DiscoverySnapshot, *, extra: tuple[Finding, ...] = ()
) -> dict[str, object]:
    """Return a plain projection using actual public rule results for snapshot.

    extra supplies diagnostic-boundary findings, never replacement validation.
    Raises the production errors unchanged; performs no I/O or input mutation.
    Narrow semantic fixtures exercise aggregation without claiming schema validity.
    """
    index = index_references(snapshot)
    evidence = validate_evidence(snapshot, index=index)
    claims = validate_claims(snapshot, index=index, evidence=evidence)
    decisions = validate_decisions(snapshot, index=index, evidence=evidence)
    dimensions = validate_dimensions(
        snapshot, index=index, evidence=evidence, decisions=decisions
    )
    coverage = validate_coverage(
        snapshot, complete=True, index=index, evidence=evidence, claims=claims
    )
    revisions = validate_revisions(snapshot, index=index)
    # Reuse real diagnostics instead of supplying a permissive validator stub.
    findings = tuple(
        item
        for result in (
            index,
            evidence,
            claims,
            decisions,
            dimensions,
            coverage,
            revisions,
        )
        for item in result.findings
    )
    value = coverage_summary(
        snapshot,
        index=index,
        evidence=evidence,
        claims=claims,
        dimensions=dimensions,
        findings=(*findings, *extra),
    )
    return as_object(to_plain_value(value))


def change(
    snapshot: DiscoverySnapshot, kind: str, **fields: object
) -> DiscoverySnapshot:
    """Return snapshot with one kind's document and captured bytes updated.

    fields replace root keys; missing records raise StopIteration. No external
    state changes, schema shortcuts or validation-result injection occurs.
    """
    # Locate the named semantic record while keeping every unrelated byte unchanged.
    record = next(item for item in snapshot.artifacts if item.expected_kind == kind)
    value = as_object(to_plain_value(record.document))
    value.update(fields)
    return replace_document(snapshot, record.path, value)


@pytest.mark.parametrize(
    "inspection,disposition,blocked,assigned",
    [
        ("inspected", "supporting", 0, 1),
        ("inspected", "unassigned", 0, 0),
        ("blocked", "blocked", 1, 0),
        ("blocked", "supporting", 1, 1),
        ("uninspected", "unassigned", 0, 0),
    ],
)
def test_inspection_disposition_and_blocked_identity_counts_are_independent(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    inspection: str,
    disposition: str,
    blocked: int,
    assigned: int,
) -> None:
    """A component blocked on both axes contributes exactly one blocked identity."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[
            component(
                inspection_status=inspection,
                disposition=disposition,
                blocked_reason="Unavailable.",
            )
        ],
    )
    counts = as_object(summary(snapshot)["components"])
    assert counts["total"] == counts["inventoried"] == 1
    assert counts["inspected"] == int(inspection == "inspected")
    assert counts["inspection_blocked"] == int(inspection == "blocked")
    assert counts["uninspected"] == int(inspection == "uninspected")
    assert counts["blocked"] == blocked
    assert counts["dispositioned"] == assigned
    assert counts["undispositioned"] == 1 - assigned


@pytest.mark.parametrize("rows", [[], [component(), component()]])
def test_missing_and_duplicate_ledger_rows_remain_in_selected_denominator(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    rows: list[object],
) -> None:
    """Inventory selection survives missing rows and cannot choose a duplicate proof."""
    data = summary(coverage_snapshot(snapshot_profile, snapshot_catalog, rows=rows))
    counts, metrics = as_object(data["components"]), as_object(data["metrics"])
    assert counts["total"] == 1
    assert counts["missing_ledger"] == int(not rows)
    assert counts["conflicting_ledger"] == int(bool(rows))
    assert counts["with_update_evidence"] == 0
    assert counts["runtime_undetermined"] == 1
    assert as_object(metrics["inspection"])["denominator"] == 1


@pytest.mark.parametrize("valid", [True, False])
def test_only_valid_exclusions_leave_the_eligible_denominator(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    valid: bool,
) -> None:
    """Authored exclusion alone cannot remove a selected coverage obligation."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[
            component(
                inspection_status="uninspected",
                disposition="excluded",
                exclusion_rationale="Reviewed generated support." if valid else "",
                exclusion_scope_ref=reference("scope", "scope"),
            )
        ],
        scope_changes={
            "exclusions": [
                {"path_or_glob": "src/*", "rationale": "Reviewed generated support."}
            ]
        },
    )
    data = summary(snapshot)
    counts, metrics = as_object(data["components"]), as_object(data["metrics"])
    assert counts["excluded"] == 1
    assert counts["excluded_valid"] == int(valid)
    assert as_object(metrics["inspection"])["denominator"] == int(not valid)


def test_unselected_inventory_and_multiple_feature_links_have_named_units(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """One selected component linked to two contracts counts once in coverage."""
    second = artifact(
        "feature-contract",
        "second",
        repository=snapshot_profile.repository.id,
        fields={"feature_id": "second", "observation_state": "inferred"},
    )
    data = summary(
        coverage_snapshot(
            snapshot_profile,
            snapshot_catalog,
            rows=[
                component(
                    disposition="feature-linked",
                    feature_refs=[
                        reference("feature-contract", "feature"),
                        reference("feature-contract", "second"),
                    ],
                )
            ],
            detected=[
                detection(snapshot_profile),
                detection(snapshot_profile, component_id="other"),
            ],
            scope_changes={"included_roots": [], "included_components": ["component"]},
            extra=(second,),
        )
    )
    counts, metrics = as_object(data["components"]), as_object(data["metrics"])
    assert counts["total"] == counts["feature_linked"] == 1
    assert counts["inventoried"] == 2 and counts["unselected"] == 1
    assert as_object(data["features"])["total"] == 2
    assert as_object(metrics["feature_contract_coverage"]) == {
        "numerator": 1,
        "denominator": 1,
        "percentage": 100.0,
        "unit": "selected nonexcluded component identities",
    }


@pytest.mark.parametrize(
    "status,expected",
    [
        ("observed", 1),
        ("passed", 1),
        ("failed", 0),
        ("not-run", 0),
        ("blocked", 0),
        ("absent", 0),
    ],
)
def test_runtime_support_counts_source_scenarios_not_runs(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    status: str,
    expected: int,
) -> None:
    """Validated observation/pass claims require exact source runtime proof."""
    known = "Recorded behavior." if status == "passed" else None
    runs = [execution(status, known, id="one"), execution(status, known, id="two")]
    record = scenario(
        snapshot_profile,
        status=status,
        expected=known,
        runs=runs if status in ("observed", "passed", "failed") else [],
    )
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        extra=() if status == "absent" else (record,),
        rows=[
            component(
                disposition="feature-linked",
                feature_refs=[reference("feature-contract", "feature")],
                runtime_validation_requirement="required",
            )
        ],
    )
    if status == "passed":
        snapshot = change(snapshot, "feature-contract", trigger=dimension("verified"))
    data = summary(snapshot)
    runtime, counts = as_object(data["runtime"]), as_object(data["components"])
    assert runtime["source_scenarios"] == int(status != "absent")
    assert runtime["supported_scenarios"] == runtime["supported_features"] == expected
    assert runtime["result_counts"] == ({} if status == "absent" else {status: 1})
    assert counts["runtime_required"] == 1 and counts["runtime_supported"] == expected
    assert runtime["required"] == runtime["denominator"] == 1
    assert runtime["observed"] == expected
    assert runtime["verified"] == int(status == "passed")
    assert runtime["missing"] == 1 - expected
    assert (
        runtime["unit"] == "selected nonexcluded runtime-required component identities"
    )
    assert runtime["verified_scenarios"] == int(status == "passed")


@pytest.mark.parametrize(
    "defect",
    [
        "missing",
        "checksum",
        "stale",
        "uri-only",
        "environment",
        "claim",
        "truncation",
        "passed-without-proof",
        "target-owned",
    ],
)
def test_runtime_proof_failures_cannot_inflate_verified_numerators(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    defect: str,
) -> None:
    """Authored observed status remains visible while invalid proof counts zero."""
    record = scenario(
        snapshot_profile,
        overrides=(
            {"environment": environment(platform="other")}
            if defect == "environment"
            else {}
        ),
    )
    if defect == "target-owned":
        snapshot_profile = configured(
            snapshot_profile,
            snapshot_catalog,
            role="legacy-source",
            foreign_role="modernization-target",
        )
        record = replace(
            record, repository=RepositoryIdentity(id="foreign", revision="b" * 40)
        )
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        extra=(record,),
        rows=[
            component(
                disposition="feature-linked",
                feature_refs=[reference("feature-contract", "feature")],
                runtime_validation_requirement="required",
            )
        ],
    )
    extra: tuple[Finding, ...] = ()
    # Each case breaks one prerequisite while retaining the authored observed status.
    if defect == "missing":
        snapshot = replace(
            snapshot,
            manifest=replace(
                snapshot.manifest,
                # Remove the captured payload rather than merely changing its label.
                files=tuple(
                    item
                    for item in snapshot.manifest.files
                    if item.path != "evidence/capture.txt"
                ),
            ),
        )
    elif defect in ("checksum", "stale", "uri-only"):
        changes: dict[str, object] = {
            "checksum": (
                None
                if defect == "checksum"
                else {"algorithm": "sha256", "value": "f" * 64}
            )
        }
        if defect == "stale":
            changes = {"revision": "b" * 40}
        if defect == "uri-only":
            changes = {
                "path": None,
                "runtime_artifact": {"uri": "https://example.invalid/capture"},
            }
        snapshot = change(snapshot, "evidence-reference", **changes)
    elif defect == "claim":
        snapshot = change(snapshot, "runtime-characterization-scenario", runs=[])
    elif defect == "passed-without-proof":
        snapshot = change(snapshot, "feature-contract", trigger=dimension("verified"))
        passed = scenario(
            snapshot_profile,
            status="passed",
            expected="Recorded behavior.",
            evidence_refs=[],
        )
        assert passed.document is not None
        snapshot = change(
            snapshot,
            "runtime-characterization-scenario",
            **as_object(to_plain_value(passed.document)),
        )
    elif defect == "truncation":
        extra = (
            Finding(
                code="FINDINGS_LIMIT",
                pointer="",
                message="Findings were bounded.",
                next_action="Resolve findings and rerun validation.",
            ),
        )
    data = summary(snapshot, extra=extra)
    assert as_object(data["runtime"])["supported_scenarios"] == 0
    assert as_object(data["runtime"])["missing"] == 1
    assert as_object(data["runtime"])["verified"] == 0


def test_required_feature_count_is_distinct_from_client_obligations(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Two target clients create two obligations for one source feature identity."""
    profile = configured(
        snapshot_profile,
        snapshot_catalog,
        role="combined",
        foreign_role="modernization-target",
    )
    profile = profile_with(
        profile,
        snapshot_catalog,
        clients=[client(profile, "browser"), client(profile, "desktop")],
    )
    snapshot = coverage_snapshot(profile, snapshot_catalog)
    record = feature(profile)
    assert record.document is not None
    snapshot = change(
        snapshot, "feature-contract", **as_object(to_plain_value(record.document))
    )
    data = as_object(summary(snapshot)["features"])
    assert data["total"] == data["required"] == 1
    assert data["required_client_obligations"] == 2


@pytest.mark.parametrize(
    "state,confidence,verified",
    [
        ("inferred", "high", 0),
        ("verified", "low", 1),
        ("unknown", "high", 0),
    ],
)
def test_confidence_never_substitutes_for_verified_claim_or_evidence(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    state: str,
    confidence: str,
    verified: int,
) -> None:
    """Actual proof supports either confidence without changing observation state."""
    snapshot = coverage_snapshot(snapshot_profile, snapshot_catalog)
    snapshot = change(
        snapshot,
        "feature-contract",
        observation_state=state,
        confidence=confidence,
        source_evidence_refs=[reference("evidence-reference", "capture")],
    )
    data = as_object(summary(snapshot)["features"])
    assert data["confidence_counts"] == {confidence: 1}
    assert data["verified_claims"] == verified
    assert data["with_evidence"] == int(state != "unknown")


@pytest.mark.parametrize(
    "status,count", [("open", 1), ("under-review", 1), ("resolved", 0)]
)
def test_unresolved_questions_are_counted_independently(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    status: str,
    count: int,
) -> None:
    """Question status does not become evidence confidence or feature completeness."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        extra=(question(snapshot_profile, status=status),),
    )
    assert summary(snapshot)["unresolved_behaviors"] == count
