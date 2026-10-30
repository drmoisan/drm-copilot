"""Verify detached parity compatibility reports without granting graph authority."""

from __future__ import annotations

import json
import math
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import parity_report
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.rendering import render_pretty_json
from drm_copilot_discovery.report_models import ReportLimitError

from tests.discovery_runtime.test_snapshot import snapshot_profile as snapshot_profile
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.parity_metrics import ParityProjection
    from drm_copilot_discovery.profile_v2 import ProfileV2
    from drm_copilot_discovery.references import ArtifactRecord
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from pytest import MonkeyPatch


def test_parsed_and_projected_rows_have_independent_nested_values() -> None:
    """Detach nested row values through both public helpers; return None, no I/O."""
    text = '{"schema_version":"1.2.3","rows":[{"feature_id":"a","notes":["é"]}]}'
    artifact = parity_report.parse_parity_matrix(text)
    rows, summary = parity_report.build_parity_rows(artifact)
    rendered = parity_report.render_parity_report(rows, summary)

    # A returned row must not retain any caller-owned nested mutable container.
    authored_rows = cast("list[dict[str, object]]", artifact["rows"])
    authored_notes = cast("list[str]", authored_rows[0]["notes"])
    authored_notes.append("later change")

    assert rows == [{"feature_id": "a", "notes": ["é"]}]
    assert json.loads(rendered) == {"entries": rows, "summary": {"total_entries": 1}}
    assert "\r" not in rendered and rendered.endswith("\n")
    assert parity_report.parse_parity_matrix(text) != artifact


@pytest.mark.parametrize("version", [True, 1, "2.0.0", "1.bad"])
def test_explicit_non_v1_versions_cannot_establish_compatibility(
    version: object,
) -> None:
    """Reject version (object) in parsed and supplied data; return None, no I/O."""
    artifact: dict[str, object] = {"schema_version": version, "rows": []}
    message = "^Use a captured v2 snapshot for discovery parity$"

    with pytest.raises(ValueError, match=message):
        parity_report.parse_parity_matrix(json.dumps(artifact))
    with pytest.raises(ValueError, match=message):
        parity_report.build_parity_rows(artifact)


@pytest.mark.parametrize(
    "text",
    [
        '{"SECRET":',
        '{"SECRET":1,"SECRET":2}',
        '{"SECRET":NaN}',
        '["SECRET"]',
    ],
)
def test_parsing_failures_use_a_fixed_redacted_message(text: str) -> None:
    """Reject malformed text (str) without exposing its values; return None."""
    with pytest.raises(
        ValueError, match="^Parity compatibility input requires valid bounded JSON$"
    ) as error:
        parity_report.parse_parity_matrix(text)
    assert "SECRET" not in str(error.value)


@pytest.mark.parametrize(
    "artifact",
    [
        {"schema_version": "1.0.0"},
        {"schema_version": "1.0.0", "rows": {}},
        {"schema_version": "1.0.0", "rows": [None]},
        {"entries": None},
    ],
)
def test_row_shape_is_checked_before_returning_any_projection(
    artifact: dict[str, object],
) -> None:
    """Reject malformed artifact rows (dict); return None without partial data."""
    with pytest.raises(ValueError, match="^Parity rows must be JSON objects$"):
        parity_report.build_parity_rows(artifact)


@pytest.mark.parametrize(
    "value, message",
    [
        (object(), "JSON-compatible"),
        (math.nan, "finite"),
        ("\ud800", "invalid Unicode"),
    ],
)
def test_rendering_rejects_non_json_values_before_encoding(
    value: object, message: str
) -> None:
    """Reject value (object) with fixed message (str); return None without I/O."""
    with pytest.raises(ValueError, match=message):
        parity_report.render_parity_report([{"id": "a", "value": value}], {})


def test_build_rejects_excess_before_detaching_any_rows(
    monkeypatch: MonkeyPatch,
) -> None:
    """Use monkeypatch to intercept forbidden copying; return None without I/O."""
    limits = ParseLimits(document_bytes=64)

    def configured_limits() -> ParseLimits:
        """Return the fixed small ParseLimits policy; perform no external effects."""
        return limits

    def forbidden(value: object) -> object:
        """Reject a copy of value (object); raise AssertionError without I/O."""
        raise AssertionError("Over-budget rows must not be copied")

    monkeypatch.setattr(parity_report, "ParseLimits", configured_limits)
    monkeypatch.setattr(parity_report, "to_plain_value", forbidden)
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        parity_report.build_parity_rows({"entries": [{"id": "😀" * 40}]})


@pytest.mark.parametrize("text", ["é", "😀", "\x01"])
def test_pretty_render_budget_accounts_for_unicode_and_escape_expansion(
    monkeypatch: MonkeyPatch, text: str
) -> None:
    """Bound encoded text (str) with monkeypatch; return None without external I/O.

    The exact pretty-JSON byte capacity succeeds. One fewer byte must reject
    before rendering, including supplementary Unicode surrogate-pair escapes.
    """
    rows: list[dict[str, object]] = [{"id": text}]
    summary: dict[str, object] = {"total_entries": 1}
    expected = (
        json.dumps({"entries": rows, "summary": summary}, sort_keys=True, indent=2)
        + "\n"
    )
    capacity = len(expected.encode("utf-8"))
    calls: list[object] = []

    def configured_limits() -> ParseLimits:
        """Return ParseLimits using current capacity (bytes); perform no I/O."""
        return ParseLimits(document_bytes=capacity)

    def observed(value: object) -> str:
        """Record value (object), then return pretty JSON; mutate only local calls."""
        calls.append(value)
        return render_pretty_json(value)

    monkeypatch.setattr(parity_report, "ParseLimits", configured_limits)
    monkeypatch.setattr(parity_report, "render_pretty_json", observed)
    assert parity_report.render_parity_report(rows, summary) == expected
    capacity -= 1
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        parity_report.render_parity_report(rows, summary)
    assert len(calls) == 1


@pytest.mark.parametrize("value", [None, {}, 1])
def test_graph_entrypoints_reject_non_snapshot_inputs(value: object) -> None:
    """Reject value (object) before any graph work; return None without I/O."""
    with pytest.raises(ValueError, match="captured v2 DiscoverySnapshot"):
        parity_report.build_parity_report(cast("DiscoverySnapshot", value))


def test_graph_preflight_reserves_input_before_projection(
    monkeypatch: MonkeyPatch,
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Use immutable fixtures and monkeypatch to observe preflight rejection.

    snapshot_profile/snapshot_catalog are ProfileV2/SchemaCatalog fixtures;
    monkeypatch is a MonkeyPatch with local restoration of the isolated seam.
    Returns None; an over-budget profile must fail before invoking the lazy
    validator, without filesystem access or source mutation.
    """
    from drm_copilot_discovery import validation

    from tests.discovery_runtime.test_coverage_scope import profile_with
    from tests.discovery_runtime.test_references import graph

    profile = profile_with(
        snapshot_profile, snapshot_catalog, limits={"document_bytes": 1024}
    )
    snapshot = graph(profile, snapshot_catalog)

    def forbidden(*args: object, **kwargs: object) -> dict[str, object]:
        """Reject args/kwargs before any projection; raise AssertionError, no I/O."""
        raise AssertionError("Input budget must reject before validation")

    monkeypatch.setattr(validation, "report_projection", forbidden)
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        parity_report.build_parity_report(snapshot)


def test_public_builder_reuses_complete_projection_with_independent_root_mode(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Render an actual configured empty graph using SchemaCatalog; return None.

    Public composition retains structural root mode and separate parity result.
    No injected assessment, output write, filesystem access or mutation occurs.
    """
    from tests.discovery_runtime.validation_test_support import no_scope_snapshot

    snapshot = no_scope_snapshot(snapshot_catalog)
    before = snapshot.sha256
    report = parity_report.build_parity_report(snapshot, mode="structural")
    document = report.to_dict()
    assert document["mode"] == "structural"
    assert document["validation_result"] == document["parity_result"] == "pass"
    assert report.to_markdown().startswith("# Discovery parity report\n")
    assert json.loads(report.to_json()) == document
    assert snapshot.sha256 == before


def assessed_projection(profile: ProfileV2, catalog: SchemaCatalog) -> ParityProjection:
    """Return a projection with real rule outcomes from ProfileV2/SchemaCatalog.

    This fixture exercises bounded local aggregation only, never publication.
    Propagates rule errors; inputs stay immutable and no external effects occur.
    """
    from drm_copilot_discovery.claim_rules import validate_claims
    from drm_copilot_discovery.decision_rules import validate_decisions
    from drm_copilot_discovery.dimension_rules import validate_dimensions
    from drm_copilot_discovery.evidence_rules import validate_evidence
    from drm_copilot_discovery.parity_metrics import ParityProjection
    from drm_copilot_discovery.parity_rules import validate_parity
    from drm_copilot_discovery.references import index_references

    from tests.discovery_runtime.test_evidence_rules import configured
    from tests.discovery_runtime.test_parity_metrics import report_graph

    snapshot = report_graph(configured(profile, catalog, role="combined"), catalog)
    index = index_references(snapshot)
    evidence = validate_evidence(snapshot, index=index)
    claims = validate_claims(snapshot, index=index, evidence=evidence)
    decisions = validate_decisions(snapshot, index=index, evidence=evidence)
    dimensions = validate_dimensions(
        snapshot, index=index, evidence=evidence, decisions=decisions
    )
    parity = validate_parity(
        snapshot,
        index=index,
        evidence=evidence,
        decisions=decisions,
        dimensions=dimensions,
        complete=True,
    )
    return ParityProjection(
        snapshot, index, evidence, claims, decisions, dimensions, parity, ()
    )


def test_graph_work_rejects_before_retaining_entry_locations(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    monkeypatch: MonkeyPatch,
) -> None:
    """Bound aggregate work using typed immutable fixtures and MonkeyPatch.

    Returns None. A one-unit shortage must reject before any location projection;
    sufficient capacity uses the real projection. Only local counters mutate.
    """
    from drm_copilot_discovery import parity_metrics
    from drm_copilot_discovery.coverage_population import record_identity

    projection = assessed_projection(snapshot_profile, snapshot_catalog)
    original = record_identity
    calls = 0

    def counted(
        record: ArtifactRecord, identifier: str | None = None
    ) -> tuple[str, str | None, str]:
        """Count record (ArtifactRecord)/identifier (str|None) identity projection.

        Returns the real identity tuple. Only the enclosing counter changes;
        no I/O or rule substitution occurs.
        """
        nonlocal calls
        calls += 1
        return original(record, identifier)

    monkeypatch.setattr(parity_metrics, "record_identity", counted)
    budget = projection.population.budget
    required = len(projection.population.index.records) + len(projection.parity.entries)
    budget.work_left = required - 1
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        projection.entries()
    assert calls == 0 and projection.by_obligation == {}
    budget.work_left = budget.limits.expanded_nodes
    counts, _ = projection.entries()
    assert calls == counts["total"] == 1


def test_axis_output_budget_rejects_before_processing_remaining_rows(
    snapshot_profile: ProfileV2,
    snapshot_catalog: SchemaCatalog,
    monkeypatch: MonkeyPatch,
) -> None:
    """Reserve encoded row bytes with ProfileV2/SchemaCatalog and MonkeyPatch.

    Returns None. Actual bounded output supplies the positive control; one byte
    less than the first row requires fails before visiting subsequent axis rows.
    Only local output counters and the restored observation seam change.
    """
    from drm_copilot_discovery.report_models import ReportBudget

    projection = assessed_projection(snapshot_profile, snapshot_catalog)
    obligation = projection.dimensions.obligations[0]
    entry = projection.parity.entries[0]
    rows = projection.axes(obligation, entry)
    first_bytes = len(
        json.dumps(rows[0], ensure_ascii=False, separators=(",", ":")).encode()
    )
    projection.output = ReportBudget(ParseLimits(document_bytes=first_bytes))
    original = ReportBudget.check
    calls: list[str] = []

    def counted(budget: ReportBudget, value: object, depth: int = 1) -> None:
        """Observe row checks, then apply real ReportBudget validation.

        budget/value/depth are ReportBudget/object/int. Returns None or propagates
        ReportLimitError. Only the local call list and budget counters mutate.
        """
        if isinstance(value, dict) and "name" in value:
            calls.append(str(cast("dict[str, object]", value)["name"]))
        original(budget, cast("object", value), depth)

    monkeypatch.setattr(ReportBudget, "check", counted)
    with pytest.raises(ReportLimitError, match="^REPORT_LIMIT:"):
        projection.axes(obligation, entry)
    # Profile feature dimensions remain visible alongside the three fixed axes.
    assert {row["name"] for row in rows} == {
        "mobile",
        "observable_outputs",
        "offline",
        "online",
        "trigger",
    }
    assert calls == [str(rows[0]["name"])]


def assert_approved_disposition(
    profile: ProfileV2, catalog: SchemaCatalog, state: str
) -> None:
    """Assert actual approved aggregation for ProfileV2/SchemaCatalog/state (str).

    Reuses canonical decision/evidence fixtures with distinct physical identities.
    Returns None or raises AssertionError; no rule replacement, I/O or mutation of
    shared fixtures occurs. Retirement disposition never grants execution proof.
    """
    from tests.discovery_runtime.test_decision_rules import decision
    from tests.discovery_runtime.test_evidence_rules import evidence
    from tests.discovery_runtime.test_parity_metrics import axes, report_graph, summary
    from tests.discovery_runtime.test_references import reference
    from tests.schemas.discovery.v2_schema_test_support import as_object

    approval = decision(
        profile,
        approval={
            "owner": "owner-example",
            "timestamp": "2026-01-01T00:00:00Z",
            "evidence_refs": [reference("evidence-reference", "approval-proof")],
        },
    )
    proof = evidence(
        profile,
        kind="decision",
        path="docs/approval-proof.json",
        changes={"id": "approval-proof", "evidence_id": "approval-proof"},
    )
    # The two approved dispositions retain their distinct authored reference fields.
    change: dict[str, object] = (
        {"retirement_decision_ref": reference("product-decision", "decision")}
        if state == "retired"
        else {"intentional_deviation_refs": [reference("product-decision", "decision")]}
    )
    value = summary(
        report_graph(
            profile, catalog, state=state, row_changes=change, extra=(approval, proof)
        )
    )
    assert as_object(value["entries"])["complete"] == 1
    assert as_object(value["source_features"])["completed_required"] == 1
    assert value["unresolved_decisions"] == []
    online = as_object(axes(value)["online"])
    assert online["retired"] == int(state == "retired")
    assert online["verified"] == int(state != "retired")
