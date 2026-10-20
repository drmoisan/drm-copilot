"""Check parity report composition, recomputation and authority entirely in memory."""

from __future__ import annotations

from dataclasses import replace
from functools import partial
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import validation, validation_operation
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import to_plain_value
from drm_copilot_discovery.parity_report import (
    build_parity_report,
    unavailable_parity_summary,
)
from drm_copilot_discovery.report_models import ReportLimitError
from drm_copilot_discovery.validation import (
    report_input_digest,
    report_projection,
    validate_snapshot,
)

from tests.discovery_runtime.test_coverage_scope import profile_with
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.discovery_runtime.validation_test_support import (
    ROOT,
    captured,
    document_record,
    mode_profile,
    no_scope_snapshot,
    output_context,
    replace_document,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.validation import ValidationMode
    from pytest import MonkeyPatch


@pytest.mark.parametrize("draft", [False, True])
@pytest.mark.parametrize("mode", ["structural", "parity-complete", "planning"])
def test_requested_mode_and_independent_parity_results(
    snapshot_catalog: SchemaCatalog, draft: bool, mode: ValidationMode
) -> None:
    """Preserve requested findings and independently assess parity in memory.

    snapshot_catalog (SchemaCatalog) validates fixtures; draft (bool) selects
    draft inputs and mode (ValidationMode) selects root validation. Return None.
    """
    snapshot = (
        captured(mode_profile(snapshot_catalog, draft=True), snapshot_catalog)
        if draft
        else no_scope_snapshot(snapshot_catalog)
    )
    requested = validate_snapshot(snapshot, mode=mode)
    complete = validate_snapshot(snapshot, mode="parity-complete")
    report = report_projection(
        snapshot, kind="parity-report", identifier="parity", mode=mode
    )
    assert report["mode"] == mode
    assert report["validation_result"] == requested.validation_result
    assert report["findings"] == [item.to_dict() for item in requested.findings]
    assert report["parity_result"] == complete.validation_result
    assert report["parity_findings"] == [item.to_dict() for item in complete.findings]
    assert report["input_sha256"] == report_input_digest(snapshot)
    assert as_object(report["parity"])["population_state"] == (
        "unavailable" if draft else "available"
    )
    assert not {"coverage", "discovery_result", "completion_findings"} & report.keys()


@pytest.mark.parametrize("fault", ["missing-profile", "loader", "artifact"])
def test_invalid_core_reports_unavailable_but_never_valid_output(
    snapshot_catalog: SchemaCatalog, fault: str
) -> None:
    """Retain original diagnostics and reject invalid completion authority.

    snapshot_catalog (SchemaCatalog) validates fixtures; fault (str) selects the
    captured-input defect. Return None; construct and inspect only memory values.
    """
    baseline = no_scope_snapshot(snapshot_catalog)
    snapshot = baseline
    # Separate absent profile bytes, malformed artifacts and loader diagnostics.
    if fault == "missing-profile":
        snapshot = replace(
            snapshot,
            manifest=replace(
                snapshot.manifest,
                files=tuple(
                    item
                    for item in snapshot.manifest.files
                    if item.path != snapshot.profile.artifacts["profile"]
                ),
            ),
        )
    elif fault == "artifact":
        snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})
    else:
        snapshot = replace(
            snapshot,
            findings=(
                Finding(
                    code="CAPTURE_ERROR",
                    message="Unavailable",
                    next_action="Recapture.",
                ),
            ),
        )
    expected = validate_snapshot(snapshot, mode="structural")
    report = build_parity_report(snapshot).to_dict()
    assert report["validation_result"] == report["parity_result"] == "fail"
    assert report["findings"] == report["parity_findings"]
    assert report["findings"] == [item.to_dict() for item in expected.findings]
    assert report["counts"] == {}
    assert report["parity"] == to_plain_value(unavailable_parity_summary())
    assert report["input_sha256"] == report_input_digest(snapshot)
    assert not validate_snapshot(snapshot, mode="planning").ok
    output = document_record(
        snapshot.profile, "parity-report", ROOT + "reports/invalid.json", report
    )
    # Bind the invocation before prospective profile removal invalidates its input.
    reviewed, invocation = output_context(
        baseline if fault == "missing-profile" else snapshot,
        "migration-coverage-reviewer",
        outputs=(output,),
        review_mode="parity-complete",
    )
    # Keep the independently bound baseline while rejecting missing prospective bytes.
    if fault == "missing-profile":
        reviewed = replace(
            reviewed,
            manifest=replace(
                reviewed.manifest,
                # Preserve the report/control bytes and only reapply the input defect.
                files=tuple(
                    item
                    for item in reviewed.manifest.files
                    if item.path != reviewed.profile.artifacts["profile"]
                ),
            ),
        )
    assert (
        validate_snapshot(
            reviewed, mode="agent-output", invocation=invocation
        ).output_valid
        is False
    )
    with pytest.raises(ValueError, match="Unsupported report or validation mode"):
        report_projection(
            snapshot,
            kind="parity-report",
            identifier="parity",
            mode=cast("ValidationMode", "automatic"),
        )


@pytest.mark.parametrize("field", ["parity", "parity_result", "parity_findings"])
def test_authored_parity_fields_cannot_override_recomputed_output(
    snapshot_catalog: SchemaCatalog, field: str
) -> None:
    """Reject forged parity fields despite an otherwise exact role manifest.

    snapshot_catalog (SchemaCatalog) validates fixtures; field (str) selects the
    authored override. Return None; mutate only the local report dictionary.
    """
    baseline = no_scope_snapshot(snapshot_catalog)
    report = build_parity_report(baseline).to_dict()
    report[field] = "forged"
    output = document_record(
        baseline.profile, "parity-report", ROOT + "reports/parity.json", report
    )
    snapshot, invocation = output_context(
        baseline,
        "migration-coverage-reviewer",
        outputs=(output,),
        review_mode="parity-complete",
    )
    before = snapshot.sha256
    result = validate_snapshot(snapshot, mode="agent-output", invocation=invocation)
    assert result.output_valid is False and not result.ok
    assert "REPORT_RESULT" in {item.code for item in result.findings}
    assert snapshot.sha256 == before


def test_multiple_derived_reports_reuse_one_complete_assessment(
    snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch
) -> None:
    """Prove complete-family reuse and exact parity carriers within one operation.

    snapshot_catalog (SchemaCatalog) validates fixtures; monkeypatch
    (pytest.MonkeyPatch) scopes local observers. Return None; perform no I/O.
    """
    baseline = no_scope_snapshot(snapshot_catalog)
    reports = tuple(
        document_record(
            baseline.profile,
            "parity-report",
            ROOT + f"reports/{identifier}.json",
            build_parity_report(baseline, identifier=identifier).to_dict(),
        )
        for identifier in ("first", "second")
    )
    snapshot = captured(
        baseline.profile,
        snapshot_catalog,
        *baseline.artifacts,
        *reports,
        payloads=tuple(
            item for item in baseline.manifest.files if item.category == "evidence"
        ),
    )
    counts: dict[str, int] = dict.fromkeys(
        (
            "validate_coverage",
            "validate_dimensions",
            "validate_acceptance",
            "validate_parity",
        ),
        0,
    )
    carriers: list[object] = []

    def counted(
        name: str, target: Callable[..., object], *args: object, **kwargs: object
    ) -> object:
        """Forward object args/kwargs to target (Callable), counting name (str).

        Return its object result unchanged; propagate validation exceptions.
        """
        # Observe summary carriers separately from complete validator invocations.
        if name == "parity_summary":
            carriers.append(kwargs["parity"])
        elif kwargs.get("complete") is True:
            counts[name] += 1
        return target(*args, **kwargs)

    with monkeypatch.context() as scoped:
        # Observe real assessments; do not replace their proof or graph behavior.
        for name in (*counts, "parity_summary"):
            scoped.setattr(
                validation_operation,
                name,
                partial(counted, name, getattr(validation_operation, name)),
            )
        result = validate_snapshot(snapshot, mode="parity-complete")
    assert result.ok and result.findings == ()
    assert set(counts.values()) == {1}
    assert len(carriers) == 2 and carriers[0] is carriers[1]
    assert report_input_digest(snapshot) == report_input_digest(baseline)
    assert build_parity_report(snapshot, identifier="first").to_dict() == (
        build_parity_report(baseline, identifier="first").to_dict()
    )


def test_parity_preflight_rejects_excess_before_graph_work(
    snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch
) -> None:
    """Enforce prospective resource limits before structural or semantic scans.

    snapshot_catalog (SchemaCatalog) validates fixtures; monkeypatch
    (pytest.MonkeyPatch) restores the local observer. Return None; perform no I/O.
    """
    snapshot = no_scope_snapshot(
        snapshot_catalog,
        profile=profile_with(
            mode_profile(snapshot_catalog),
            snapshot_catalog,
            limits={"document_bytes": 4096},
        ),
    )
    snapshot = replace_document(
        snapshot, snapshot.artifacts[0].path, {"oversized": "\U0001f600" * 1200}
    )
    calls: list[str] = []

    def unexpected(value: DiscoverySnapshot) -> tuple[Finding, ...]:
        """Append value (DiscoverySnapshot)'s digest to the local call list.

        Return an empty tuple[Finding, ...] if structural work incorrectly begins.
        """
        calls.append(value.sha256)
        return ()

    monkeypatch.setattr(validation, "_schema_findings", unexpected)
    with pytest.raises(ReportLimitError):
        report_projection(
            snapshot, kind="parity-report", identifier="parity", mode="structural"
        )
    assert calls == []


@pytest.mark.parametrize("mode", ["automatic", "agent-output"])
def test_unsupported_parity_report_modes_remain_errors(
    snapshot_catalog: SchemaCatalog, mode: str
) -> None:
    """Reject unsupported modes without creating report authority or fallback.

    snapshot_catalog (SchemaCatalog) validates fixtures; mode (str) selects the
    unsupported mode. Return None; construct and inspect only memory values.
    """
    snapshot = no_scope_snapshot(snapshot_catalog)
    with pytest.raises(ValueError, match="mode"):
        report_projection(
            snapshot,
            kind="parity-report",
            identifier="parity",
            mode=cast("ValidationMode", mode),
        )
