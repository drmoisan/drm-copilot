"""Verify public coverage-report rendering and authority boundaries in memory."""

from __future__ import annotations

import json
from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.claim_rules import validate_claims
from drm_copilot_discovery.coverage_population import CoveragePopulation
from drm_copilot_discovery.coverage_report import (
    build_coverage_report,
    coverage_preflight,
)
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.report_models import ReportLimitError
from drm_copilot_discovery.snapshot import SnapshotFile
from drm_copilot_discovery.snapshot_io import within_roots
from drm_copilot_discovery.validation import report_input_digest

from tests.discovery_runtime.test_coverage_report import change, summary
from tests.discovery_runtime.test_coverage_rules import coverage_snapshot, detection
from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_references import artifact, reference
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import (
    ROOT,
    captured,
    document_record,
    mode_profile,
    no_scope_snapshot,
    replace_document,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import DiscoverySnapshot


def test_public_report_renders_exact_fields_and_null_empty_percentages(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Confirmed no-scope has explicit zero populations without fabricated ratios."""
    snapshot = no_scope_snapshot(snapshot_catalog)
    before = snapshot.sha256
    report = build_coverage_report(snapshot)
    data = json.loads(report.to_json())
    markdown_data = json.loads(
        report.to_markdown().split("```json\n", 1)[1].split("```")[0]
    )
    assert data == markdown_data == to_plain_value(report.document)
    assert data["validation_result"] == data["discovery_result"] == "pass"
    assert data["completion_findings"] == []
    assert data["input_sha256"] == report_input_digest(snapshot)
    assert data["coverage"]["components"]["total"] == 0
    # Empty denominator is unknown coverage, never an invented hundred percent.
    assert all(
        item["percentage"] is None for item in data["coverage"]["metrics"].values()
    )
    assert snapshot.sha256 == before


@pytest.mark.parametrize("case", ["draft", "uninventoried", "invalid"])
def test_public_report_never_promotes_missing_or_invalid_graphs(
    snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Authored empty input and malformed retained bytes keep actionable failures."""
    snapshot = (
        captured(
            mode_profile(snapshot_catalog, draft=case == "draft"), snapshot_catalog
        )
        if case != "invalid"
        else no_scope_snapshot(snapshot_catalog)
    )
    if case == "invalid":
        snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})
    data = as_object(to_plain_value(build_coverage_report(snapshot).document))
    assert data["discovery_result"] == "fail"
    assert data["completion_findings"]
    counts = as_object(data["coverage"])
    assert counts["population_state"] == "unavailable"
    assert counts["components"] is None


def test_report_outputs_do_not_change_input_digest_or_semantic_counts(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """A previous derived report does not introduce recursive coverage or identity."""
    snapshot = no_scope_snapshot(snapshot_catalog)
    original = build_coverage_report(snapshot)
    record = document_record(
        snapshot.profile,
        "coverage-report",
        ROOT + "reports/coverage.json",
        as_object(to_plain_value(original.document)),
    )
    updated = captured(
        snapshot.profile,
        snapshot_catalog,
        *snapshot.artifacts,
        record,
        # Reuse only evidence payloads; captured rebuilds profile/artifact inputs.
        payloads=tuple(
            item for item in snapshot.manifest.files if item.category == "evidence"
        ),
    )
    assert build_coverage_report(updated).document == original.document


@pytest.mark.parametrize("value", [None, {}, {"validation_result": "pass"}])
def test_arbitrary_objects_cannot_supply_graph_authority(value: object) -> None:
    """The public producer requires a captured typed snapshot before validation."""
    with pytest.raises(ValueError, match="DiscoverySnapshot"):
        build_coverage_report(cast("DiscoverySnapshot", value))


def test_aggregate_preflight_limits_nonascii_input_before_validation(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Reject prospective UTF-8 excess before invoking graph assessment."""
    profile = profile_with(
        snapshot_profile, snapshot_catalog, limits={"document_bytes": 4096}
    )
    snapshot = coverage_snapshot(profile, snapshot_catalog)
    snapshot = change(snapshot, "feature-contract", summary="😀" * 1200)
    calls = 0

    def forbidden(*args: object, **kwargs: object) -> None:
        """Record unexpected validation calls; return None without external effects."""
        nonlocal calls
        calls += 1

    monkeypatch.setattr("drm_copilot_discovery.validation.report_projection", forbidden)
    with pytest.raises(ReportLimitError):
        build_coverage_report(snapshot)
    assert calls == 0


def test_preflight_excludes_large_report_output_but_not_authored_artifacts(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Derived views do not consume the structured semantic-input budget."""
    profile = profile_with(
        snapshot_profile, snapshot_catalog, limits={"document_bytes": 4096}
    )
    report = artifact("coverage-report", "coverage", fields={"extra": "😀" * 1200})
    snapshot = captured(profile, snapshot_catalog, report)
    coverage_preflight(snapshot)
    authored = replace(report, expected_kind="feature-contract")
    with pytest.raises(ReportLimitError):
        coverage_preflight(replace(snapshot, artifacts=(authored,)))


@pytest.mark.parametrize(
    "case", ["empty-ledger", "absent", "missing-scope", "ambiguous"]
)
def test_unknown_population_is_unavailable_instead_of_zero_components(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    case: str,
) -> None:
    """Known inventory survives empty rows; unresolvable selection reports no counts."""
    snapshot = coverage_snapshot(
        snapshot_profile,
        snapshot_catalog,
        rows=[],
        detected=[
            detection(snapshot_profile),
            detection(snapshot_profile, component_id="second"),
        ],
    )
    if case == "absent":
        # Remove the entire ledger while preserving the same scope/inventory inputs.
        snapshot = replace(
            snapshot,
            artifacts=tuple(
                item
                for item in snapshot.artifacts
                if item.expected_kind != "coverage-ledger"
            ),
        )
    elif case == "missing-scope":
        snapshot = change(
            snapshot, "coverage-ledger", scope_ref=reference("scope", "missing")
        )
    elif case == "ambiguous":
        # Duplicate scope identity prevents authoritative reference resolution.
        scope = next(
            item for item in snapshot.artifacts if item.expected_kind == "scope"
        )
        snapshot = replace(
            snapshot,
            artifacts=(
                *snapshot.artifacts,
                replace(scope, path="docs/duplicate-scope.json"),
            ),
            manifest=replace(
                snapshot.manifest,
                files=(
                    *snapshot.manifest.files,
                    SnapshotFile(
                        path="docs/duplicate-scope.json",
                        content=snapshot.file(scope.path).content,
                        category="artifact",
                    ),
                ),
            ),
        )
    data = summary(snapshot)
    references = cast("list[dict[str, object]]", data["known_inventory_refs"])
    assert len(references) == 1 and references[0]["id"] == "inventory"
    if case == "empty-ledger":
        assert data["population_state"] == "available"
        counts = as_object(data["components"])
        assert counts["total"] == counts["inventoried"] == counts["missing_ledger"] == 2
    else:
        assert data["population_state"] == "unavailable"
        assert data["components"] is None and data["metrics"] is None


@pytest.mark.parametrize(
    "root_count,overflow", [(16, False), (128, False), (1024, True)]
)
def test_selector_work_is_reserved_before_the_accepted_scope_query(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    root_count: int,
    overflow: bool,
) -> None:
    """Root-dependent comparisons cannot exceed the configured aggregate work budget."""
    profile = profile_with(
        snapshot_profile, snapshot_catalog, limits={"artifact_records": 512}
    )
    # Retain fixed components while increasing only the selector population.
    snapshot = coverage_snapshot(
        profile,
        snapshot_catalog,
        rows=[],
        detected=[
            detection(profile, component_id=f"component-{number}")
            for number in range(64)
        ],
        scope_changes={
            "included_roots": [f"other/{number}" for number in range(root_count)]
        },
    )
    index = index_references(snapshot)
    evidence = validate_evidence(snapshot, index=index)
    claims = validate_claims(snapshot, index=index, evidence=evidence)
    population = CoveragePopulation(snapshot, index, evidence, claims, ())
    comparisons = 0

    def counted(path: str, roots: tuple[str, ...]) -> bool:
        """Count exact nonmatching root predicates; return the accepted bool result."""
        nonlocal comparisons
        comparisons += len(roots)
        return within_roots(path, roots)

    monkeypatch.setattr(
        "drm_copilot_discovery.coverage_scope_rules.within_roots", counted
    )
    if overflow:
        with pytest.raises(ReportLimitError):
            population.collect()
        assert comparisons == 0
    else:
        population.collect()
        assert comparisons > 0
        assert (
            comparisons
            <= profile.limits.parse_limits().expanded_nodes
            - population.budget.work_left
        )
