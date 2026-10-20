"""Check graph parity denominators and retained outcome truth entirely in memory."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.claim_rules import validate_claims
from drm_copilot_discovery.coverage_rules import validate_coverage
from drm_copilot_discovery.decision_rules import validate_decisions
from drm_copilot_discovery.dimension_rules import validate_dimensions
from drm_copilot_discovery.evidence_rules import validate_evidence
from drm_copilot_discovery.models import canonical_json, to_plain_value
from drm_copilot_discovery.parity_report import (
    parity_summary,
    unavailable_parity_summary,
)
from drm_copilot_discovery.parity_rules import validate_parity
from drm_copilot_discovery.references import index_references
from drm_copilot_discovery.revision_rules import validate_revisions
from drm_copilot_discovery.snapshot import SnapshotFile

from tests.discovery_runtime.parity_test_support import (
    classification,
    implementation,
    parity_row,
    parity_snapshot,
    source_contract,
)
from tests.discovery_runtime.test_coverage_rules import coverage_snapshot
from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_dimension_rules import client
from tests.discovery_runtime.test_evidence_rules import configured
from tests.discovery_runtime.test_references import artifact
from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import (
    no_scope_snapshot,
    replace_document,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.snapshot import ArtifactSnapshot, DiscoverySnapshot


@pytest.fixture(scope="module")
def report_profile(
    snapshot_profile: ProfileV2, snapshot_catalog: SchemaCatalog
) -> ProfileV2:
    """Return a combined ProfileV2 from immutable fixtures; propagate profile errors.

    The local source is the only configured source; no I/O or fixture mutation.
    """
    return profile_with(
        configured(snapshot_profile, snapshot_catalog, role="combined"),
        snapshot_catalog,
        repositories=[],
    )


def report_graph(
    profile: ProfileV2,
    catalog: SchemaCatalog,
    *,
    state: str = "full",
    row_changes: dict[str, object] | None = None,
    extra: tuple[ArtifactSnapshot, ...] = (),
) -> DiscoverySnapshot:
    """Compose source scope from profile (ProfileV2) and catalog (SchemaCatalog).

    state (str)/row_changes (dict|None) alter authored values; extra
    (tuple[ArtifactSnapshot]) adds captured artifacts.
    Returns DiscoverySnapshot for semantic tests, not a schema-valid publication
    fixture. Duplicate manifest paths retain identical accepted payloads. No I/O.
    """
    source = source_contract(profile)
    target = implementation(profile, source)
    row = parity_row(profile, source, target, parity_state=state, **(row_changes or {}))
    target_graph = parity_snapshot(
        profile, catalog, source=source, target=target, row=row, extra=extra
    )
    source_graph = coverage_snapshot(profile, catalog)
    # The source contract replaces the coverage placeholder; proofs keep distinct paths.
    records = tuple(
        item
        for item in source_graph.artifacts
        if item.expected_kind != "feature-contract"
    ) + tuple(
        (
            replace(item, path=item.path.replace("/capture.json", "/target-proof.json"))
            if item.expected_kind == "evidence-reference"
            else item
        )
        for item in target_graph.artifacts
    )
    # Rebuild artifact bytes at corrected paths while retaining source payloads.
    files = {
        item.path: item
        for item in (*source_graph.manifest.files, *target_graph.manifest.files)
        if item.category != "artifact"
    }
    # Every record's current physical location has one exact captured JSON byte stream.
    for item in records:
        files[item.path] = SnapshotFile(
            path=item.path, content=canonical_json(item.document), category="artifact"
        )
    # Keep all immutable repository objects used by source and target evidence.
    pins = {
        (item.repository, item.path): item
        for item in (*source_graph.repository_files, *target_graph.repository_files)
    }
    return replace(
        source_graph,
        artifacts=records,
        manifest=replace(source_graph.manifest, files=tuple(files.values())),
        repository_files=tuple(pins.values()),
    )


def summary(snapshot: DiscoverySnapshot) -> dict[str, object]:
    """Return parity metrics from actual outcomes for DiscoverySnapshot; no I/O.

    Propagates production errors. Narrow graph fixtures do not grant structural
    validity, and no permissive validator or synthetic passing outcome is used.
    """
    index = index_references(snapshot)
    evidence = validate_evidence(snapshot, index=index)
    claims = validate_claims(snapshot, index=index, evidence=evidence)
    decisions = validate_decisions(snapshot, index=index, evidence=evidence)
    dimensions = validate_dimensions(
        snapshot, index=index, evidence=evidence, decisions=decisions
    )
    revisions = validate_revisions(snapshot, index=index)
    coverage = validate_coverage(
        snapshot, complete=True, index=index, evidence=evidence, claims=claims
    )
    parity = validate_parity(
        snapshot,
        complete=True,
        index=index,
        evidence=evidence,
        revisions=revisions,
        decisions=decisions,
        dimensions=dimensions,
    )
    # Preserve every family's actual diagnostics for source-scope selection.
    findings = tuple(
        item
        for result in (
            index,
            evidence,
            claims,
            decisions,
            dimensions,
            revisions,
            coverage,
            parity,
        )
        for item in result.findings
    )
    return as_object(
        to_plain_value(
            parity_summary(
                snapshot,
                index=index,
                evidence=evidence,
                claims=claims,
                decisions=decisions,
                dimensions=dimensions,
                parity=parity,
                findings=findings,
            )
        )
    )


def axes(value: dict[str, object], client_id: str = "browser") -> dict[str, object]:
    """Return client_id's (str) axes from value (dict); raise if absent, no I/O."""
    # Client identity determines selection; ordering never chooses an arbitrary target.
    selected = next(
        as_object(item)
        for item in cast_rows(value["clients"])
        if as_object(item)["client_id"] == client_id
    )
    return as_object(selected["dimensions"])


def test_verified_full_parity_keeps_four_population_units(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Count separate units using ProfileV2/SchemaCatalog fixtures; return None.

    No I/O or mutation; all proof comes from real rule assessments.
    """
    snapshot = report_graph(report_profile, snapshot_catalog)
    before = snapshot.sha256
    value = summary(snapshot)
    assert value["population_state"] == "available"
    assert value["source_features"] == {
        "total": 1,
        "required": 1,
        "completed_required": 1,
    }
    assert as_object(value["feature_client_obligations"])["completed_required"] == 1
    assert as_object(value["entries"])["complete"] == 1
    assert as_object(axes(value)["online"])["required_verified"] == 1
    assert summary(snapshot) == value and snapshot.sha256 == before


@pytest.mark.parametrize("name", ["offline", "mobile"])
def test_undeclared_optional_axis_is_not_required_and_never_passed(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    name: str,
) -> None:
    """Keep name (str) optional with ProfileV2/SchemaCatalog fixtures; return None.

    No I/O, approval or snapshot mutation occurs.
    """
    value = as_object(
        axes(summary(report_graph(report_profile, snapshot_catalog)))[name]
    )
    assert value["not_required"] == 1
    assert value["required"] == value["verified"] == value["required_verified"] == 0
    assert as_object(value["verification"])["percentage"] is None


@pytest.mark.parametrize(
    "state",
    [
        "unassessed",
        "partial",
        "missing",
        "conflicting",
        "intentionally-changed",
        "retired",
    ],
)
def test_authored_states_do_not_imply_approved_completion(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    state: str,
) -> None:
    """Retain state (str) with ProfileV2/SchemaCatalog fixtures; return None.

    Requires actual approval and proof; performs no I/O or input mutation.
    """
    value = summary(report_graph(report_profile, snapshot_catalog, state=state))
    entries = as_object(value["entries"])
    assert as_object(entries["state_counts"])[state] == 1
    assert entries["complete"] == 0
    assert as_object(value["source_features"])["completed_required"] == 0
    assert (
        as_object(as_object(value["metrics"])["feature_completion"])["percentage"] == 0
    )
    # Only these states can become dispositions with actual current approval.
    if state in {"intentionally-changed", "retired"}:
        from tests.discovery_runtime.test_parity_report import (
            assert_approved_disposition,
        )

        assert_approved_disposition(report_profile, snapshot_catalog, state)


@pytest.mark.parametrize(
    "field,value",
    [
        ("repository_id", "wrong"),
        ("artifact_sha256", "0" * 64),
        ("feature_id", "absent"),
    ],
)
def test_invalid_source_stays_visible_without_verified_numerator(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    field: str,
    value: str,
) -> None:
    """Reject field/value (str) using ProfileV2/SchemaCatalog fixtures; return None.

    Retains authored state and alters only fresh local data; no I/O occurs.
    """
    snapshot = report_graph(report_profile, snapshot_catalog)
    matrix = next(
        item for item in snapshot.artifacts if item.expected_kind == "parity-matrix"
    )
    document = as_object(to_plain_value(matrix.document))
    row = as_object(cast_rows(document["entries"])[0])
    as_object(row["source_contract_ref"])[field] = value
    result = summary(replace_document(snapshot, matrix.path, document))
    entries = as_object(result["entries"])
    assert entries["unresolved_source"] == entries["invalid"] == 1
    assert entries["complete"] == 0 and len(cast_rows(entries["invalid_entries"])) == 1
    assert as_object(axes(result)["online"])["verified"] == 0


def cast_rows(value: object) -> list[object]:
    """Narrow value (object) to a list for test assertions; return it without I/O.

    Raises AssertionError for unexpected output shape, preserving strict typing.
    """
    assert isinstance(value, list)
    return cast("list[object]", value)


def test_duplicate_rows_are_all_invalid_and_count_one_missing_completion(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Use ProfileV2/SchemaCatalog fixtures to reject duplicate proof; return None.

    Only fresh local rows change; no I/O or shared state mutation occurs.
    """
    snapshot = report_graph(report_profile, snapshot_catalog)
    matrix = next(
        item for item in snapshot.artifacts if item.expected_kind == "parity-matrix"
    )
    document = as_object(to_plain_value(matrix.document))
    original = as_object(cast_rows(document["entries"])[0])
    document["entries"] = [original, {**original, "id": "other"}]
    value = summary(replace_document(snapshot, matrix.path, document))
    entries = as_object(value["entries"])
    assert entries["total"] == entries["duplicate_rows"] == entries["invalid"] == 2
    assert entries["valid"] == entries["complete"] == 0
    assert as_object(value["feature_client_obligations"])["conflicting"] == 1
    assert as_object(axes(value)["online"])["required_pending"] == 1


def test_multiple_clients_do_not_multiply_source_feature_identity(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Use ProfileV2/SchemaCatalog fixtures with two clients; return None.

    A missing client blocks the unique source feature without I/O or mutation.
    """
    profile = profile_with(
        report_profile,
        snapshot_catalog,
        clients=[
            client(report_profile),
            client(
                report_profile,
                "tablet",
                platforms=["mobile"],
                modes=["online", "offline", "batch"],
            ),
        ],
    )
    value = summary(report_graph(profile, snapshot_catalog))
    assert value["source_features"] == {
        "total": 1,
        "required": 1,
        "completed_required": 0,
    }
    counts = as_object(value["feature_client_obligations"])
    assert counts["required"] == counts["total"] == 2
    assert counts["completed_required"] == counts["missing"] == 1
    tablet = axes(value, "tablet")
    assert as_object(tablet["batch"])["required_pending"] == 1
    assert as_object(tablet["offline"])["required_pending"] == 1
    assert as_object(tablet["mobile"])["required_pending"] == 1
    assert as_object(axes(value)["mobile"])["not_required"] == 1


@pytest.mark.parametrize(
    "state,unresolved",
    [
        ("proposed", 1),
        ("blocked", 1),
        ("approved", 1),
        ("rejected", 0),
        ("superseded", 0),
    ],
)
def test_current_unresolved_decisions_exclude_historical_proposals(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    state: str,
    unresolved: int,
) -> None:
    """Count state (str) as unresolved (int) using profile/catalog fixtures.

    Fixtures are ProfileV2/SchemaCatalog; returns None without I/O or mutation.
    """
    decision = artifact(
        "product-decision",
        "decision",
        repository=report_profile.repository.id,
        fields={"status": state},
    )
    value = summary(report_graph(report_profile, snapshot_catalog, extra=(decision,)))
    assert len(cast_rows(value["unresolved_decisions"])) == unresolved


def test_all_authored_blockers_preserve_row_location(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Keep blockers using ProfileV2/SchemaCatalog fixtures; return None.

    Invalid claims remain visible; no I/O or shared fixture mutation occurs.
    """
    value = summary(
        report_graph(
            report_profile,
            snapshot_catalog,
            state="conflicting",
            row_changes={"blockers": ["First.", "Second."]},
        )
    )
    rows = cast_rows(value["blockers"])
    # Distinct prose is retained in original row order, without collapsing evidence.
    assert [as_object(row)["blocker"] for row in rows] == ["First.", "Second."]
    assert all(as_object(row)["pointer"] == "/entries/0" for row in rows)


@pytest.mark.parametrize("kind", ["coverage-ledger", "inventory-snapshot"])
def test_missing_source_authority_is_unavailable_not_zero(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    kind: str,
) -> None:
    """Remove kind (str) from ProfileV2/SchemaCatalog fixtures; return None.

    Fresh local absence cannot imply empty scope; no I/O or mutation occurs.
    """
    snapshot = report_graph(report_profile, snapshot_catalog)
    # Remove authority without altering independent retained source bytes.
    snapshot = replace(
        snapshot,
        artifacts=tuple(
            item for item in snapshot.artifacts if item.expected_kind != kind
        ),
    )
    assert summary(snapshot) == to_plain_value(unavailable_parity_summary())


def test_confirmed_empty_scope_has_real_zeros_and_null_percentages(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Use SchemaCatalog to distinguish empty/unavailable scope; return None.

    The captured fixture remains immutable and no I/O occurs.
    """
    value = summary(no_scope_snapshot(snapshot_catalog))
    assert value["population_state"] == "available"
    assert as_object(value["source_features"])["total"] == 0
    assert as_object(value["entries"])["total"] == 0
    assert (
        as_object(as_object(value["metrics"])["feature_completion"])["percentage"]
        is None
    )


@pytest.mark.parametrize(
    "changes",
    [
        {"online": classification(verification="failed")},
        {"offline": classification()},
        {
            "mobile": classification(
                applicability="not-applicable",
                verification="unverified",
                rationale="Unused.",
                evidence_refs=[],
            )
        },
    ],
)
def test_present_optional_or_contradictory_claims_remain_independent(
    report_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    changes: dict[str, object],
) -> None:
    """Apply changes (dict) to ProfileV2/SchemaCatalog fixtures; return None.

    False claims remain separate; only fresh local data changes, without I/O.
    """
    value = summary(report_graph(report_profile, snapshot_catalog, row_changes=changes))
    named = next(iter(changes))
    counts = as_object(axes(value)[named])
    # The three inputs exercise conflicting required, false optional and disposed axes.
    if named == "online":
        assert counts["conflicting"] == 1 and counts["verified"] == 0
    elif named == "offline":
        assert counts["verified"] == 0 and as_object(value["entries"])["invalid"] == 1
    else:
        assert counts["not_applicable"] == counts["disposed"] == 1
        assert counts["verified"] == 0
