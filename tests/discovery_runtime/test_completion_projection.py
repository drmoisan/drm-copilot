"""Verify selected completion assessments without granting publication authority."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import validation, validation_operation
from drm_copilot_discovery.completion_report import build_completion_report
from drm_copilot_discovery.findings import Finding
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
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.validation import ValidationMode
    from pytest import MonkeyPatch


@pytest.mark.parametrize("draft", [False, True])
@pytest.mark.parametrize(
    "mode", ["structural", "discovery-complete", "parity-complete", "planning"]
)
def test_completion_uses_only_selected_mode_with_trusted_warnings(
    snapshot_catalog: SchemaCatalog,
    monkeypatch: MonkeyPatch,
    draft: bool,
    mode: ValidationMode,
) -> None:
    """Preserve selected results and warnings without unrelated complete checks.

    snapshot_catalog (SchemaCatalog) supplies schemas; monkeypatch (MonkeyPatch)
    scopes a real assessment observer; draft (bool) and mode (ValidationMode)
    select inputs and the root gate. Return None; perform only in-memory work.
    """
    # Confirmed empty scope and a draft capture exercise both selected-mode outcomes.
    snapshot = (
        captured(mode_profile(snapshot_catalog, draft=True), snapshot_catalog)
        if draft
        else no_scope_snapshot(snapshot_catalog)
    )
    warning = Finding(
        code="CAPTURE_WARNING",
        severity="warning",
        message="Retained capture warning.",
        next_action="Inspect retained warning.",
    )
    snapshot = replace(snapshot, findings=(warning,))
    expected = validate_snapshot(snapshot, mode=mode)
    original = validation_operation.ValidationOperation.complete
    calls: list[bool] = []

    def counted(
        operation: validation_operation.ValidationOperation, *, parity: bool
    ) -> tuple[Finding, ...]:
        """Count parity (bool) for operation (ValidationOperation); return findings.

        Forward to the real tuple[Finding, ...] assessment without changing proof.
        """
        calls.append(parity)
        return original(operation, parity=parity)

    monkeypatch.setattr(validation_operation.ValidationOperation, "complete", counted)
    report = build_completion_report(snapshot, mode=mode).to_dict()
    summary = as_object(report["completion"])
    assert report["validation_result"] == expected.validation_result
    # Compare the entire retained payload rather than only summary counters.
    expected_findings = [item.to_dict() for item in expected.findings]
    assert report["findings"] == expected_findings
    assert warning.to_dict() in expected_findings
    assert summary["assessment_state"] == "available"
    assert as_object(summary["retained_finding_counts"])["warning"] == 1
    assert summary["planning_prerequisite"] == (
        snapshot.profile.completion_gates.planning_prerequisite
        if mode == "planning"
        else None
    )
    assert calls == ([] if mode == "structural" else [mode == "parity-complete"])
    assert report["input_sha256"] == report_input_digest(snapshot)
    assert (
        not {"coverage", "parity", "discovery_result", "parity_result"} & report.keys()
    )


@pytest.mark.parametrize("fault", ["missing-profile", "malformed", "loader"])
def test_malformed_completion_retains_diagnostics_without_semantic_assessment(
    snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch, fault: str
) -> None:
    """Return unavailable diagnostics while preserving root and output refusal.

    snapshot_catalog (SchemaCatalog) supplies schemas; monkeypatch (MonkeyPatch)
    scopes an observer; fault (str) selects captured invalid input. Return None;
    use immutable snapshots and no external I/O.
    """
    baseline = no_scope_snapshot(snapshot_catalog)
    snapshot = baseline
    # Exercise absent captured authority, invalid core bytes and loader failure.
    if fault == "missing-profile":
        snapshot = replace(
            snapshot,
            manifest=replace(
                snapshot.manifest,
                # Remove only profile authority while retaining captured artifacts.
                files=tuple(
                    item
                    for item in snapshot.manifest.files
                    if item.path != snapshot.profile.artifacts["profile"]
                ),
            ),
        )
    elif fault == "malformed":
        snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})
    else:
        snapshot = replace(
            snapshot,
            findings=(
                Finding(
                    code="CAPTURE_ERROR",
                    message="Unavailable.",
                    next_action="Recapture.",
                ),
            ),
        )
    expected = validate_snapshot(snapshot, mode="structural")

    def unexpected(*args: object, **kwargs: object) -> None:
        """Reject args/kwargs (object) if invalid inputs reach semantic construction.

        Return None only by annotation; raise AssertionError without external effects.
        """
        raise AssertionError((args, kwargs))

    with monkeypatch.context() as scoped:
        scoped.setattr(validation, "_Validation", unexpected)
        report = build_completion_report(snapshot, mode="planning").to_dict()
    assert report["validation_result"] == "fail"
    assert report["counts"] is None
    # Preserve each original structural diagnostic without substituting a summary.
    assert report["findings"] == [item.to_dict() for item in expected.findings]
    assert as_object(report["completion"])["assessment_state"] == "unavailable"
    assert as_object(report["completion"])["planning_prerequisite"] is None
    assert not validate_snapshot(snapshot, mode="planning").ok
    output = document_record(
        baseline.profile, "completion-report", ROOT + "reports/invalid.json", report
    )
    reviewed, invocation = output_context(
        baseline,
        "migration-coverage-reviewer",
        outputs=(output,),
        review_mode="planning",
    )
    # Canonical sorting prevents positional identification of newly added outputs.
    baseline_artifacts = {item.path for item in baseline.artifacts}
    # Input manifests independently sort profile, evidence and artifact paths.
    baseline_files = {item.path for item in baseline.manifest.files}
    # Preserve the valid invocation binding while retaining the prospective fault.
    reviewed = replace(
        reviewed,
        artifacts=(
            *snapshot.artifacts,
            # Add report/control descriptors without copying existing graph records.
            *(
                item
                for item in reviewed.artifacts
                if item.path not in baseline_artifacts
            ),
        ),
        manifest=replace(
            reviewed.manifest,
            files=(
                *snapshot.manifest.files,
                # Keep prospective output bytes while retaining the original fault.
                *(
                    item
                    for item in reviewed.manifest.files
                    if item.path not in baseline_files
                ),
            ),
        ),
        findings=snapshot.findings,
    )
    assert (
        validate_snapshot(
            reviewed, mode="agent-output", invocation=invocation
        ).output_valid
        is False
    )


def test_completion_recomputation_reuses_assessment_and_rejects_authored_override(
    snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch
) -> None:
    """Reuse one selected assessment and reject forged derived completion fields.

    snapshot_catalog (SchemaCatalog) supplies schemas; monkeypatch (MonkeyPatch)
    scopes real assessment counting. Return None; mutate only local report data.
    """
    warning = Finding(
        code="CAPTURE_WARNING",
        severity="warning",
        message="Warning.",
        next_action="Inspect.",
    )
    baseline = replace(no_scope_snapshot(snapshot_catalog), findings=(warning,))
    # Multiple derived views must share one selected completion assessment.
    reports = tuple(
        document_record(
            baseline.profile,
            "completion-report",
            ROOT + f"reports/{identifier}.json",
            build_completion_report(
                baseline, mode="planning", identifier=identifier
            ).to_dict(),
        )
        for identifier in ("first", "second")
    )
    snapshot = replace(
        captured(
            baseline.profile,
            snapshot_catalog,
            *baseline.artifacts,
            *reports,
            # Retain the real confirmation payload required by the empty scope.
            payloads=tuple(
                item for item in baseline.manifest.files if item.category == "evidence"
            ),
        ),
        findings=(warning,),
    )
    original = validation_operation.ValidationOperation.complete
    calls: list[bool] = []

    def counted(
        operation: validation_operation.ValidationOperation, *, parity: bool
    ) -> tuple[Finding, ...]:
        """Record parity (bool) and forward operation's real assessment tuple.

        operation (ValidationOperation) retains its cache; return tuple[Finding, ...].
        """
        calls.append(parity)
        return original(operation, parity=parity)

    with monkeypatch.context() as scoped:
        scoped.setattr(validation_operation.ValidationOperation, "complete", counted)
        checked = validate_snapshot(snapshot, mode="planning")
    assert checked.ok and checked.findings == (warning,)
    assert calls == [False]
    assert report_input_digest(snapshot) == report_input_digest(baseline)
    forged = build_completion_report(
        baseline, mode="planning", identifier="first"
    ).to_dict()
    as_object(forged["completion"])["assessment_state"] = "unavailable"
    altered = replace_document(snapshot, reports[0].path, forged)
    # Recomputed completion fields must reject an authored availability override.
    assert "REPORT_RESULT" in {
        item.code for item in validate_snapshot(altered, mode="planning").findings
    }


@pytest.mark.parametrize("count", [100, 101])
def test_completion_preserves_bounded_warning_and_truncation_authority(
    snapshot_catalog: SchemaCatalog, count: int
) -> None:
    """Keep retained warnings and fail closed when the trusted input budget truncates.

    snapshot_catalog (SchemaCatalog) supplies schemas; count (int) selects the
    finite warning population. Return None; construct only memory values.
    """
    snapshot = replace(
        no_scope_snapshot(snapshot_catalog),
        # Distinct diagnostics reach the configured bound and its first overflow.
        findings=tuple(
            Finding(
                code=f"WARNING_{index}",
                severity="warning",
                message="Warning.",
                next_action="Inspect.",
            )
            for index in range(count)
        ),
    )
    result = build_completion_report(snapshot, mode="structural").to_dict()
    summary = as_object(result["completion"])
    limit = snapshot.profile.limits.parse_limits().findings
    assert len(cast("list[object]", result["findings"])) == limit
    assert summary["findings_complete"] is (count == limit)
    assert result["validation_result"] == ("pass" if count == limit else "fail")
    assert summary["assessment_state"] == (
        "available" if count == limit else "unavailable"
    )


def test_completion_preflight_precedes_input_validation(
    snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch
) -> None:
    """Reject oversized captured inputs before structural or semantic traversal.

    snapshot_catalog (SchemaCatalog) supplies schemas; monkeypatch (MonkeyPatch)
    scopes the structural observer. Return None; allocate no external resources.
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
        """Record value (DiscoverySnapshot)'s identity; return empty finding tuple."""
        calls.append(value.sha256)
        return ()

    monkeypatch.setattr(validation, "_schema_findings", unexpected)
    with pytest.raises(ReportLimitError):
        build_completion_report(snapshot, mode="structural")
    assert calls == []


@pytest.mark.parametrize("malformed", [False, True])
@pytest.mark.parametrize("mode", ["automatic", "agent-output"])
def test_completion_rejects_unsupported_modes(
    snapshot_catalog: SchemaCatalog, malformed: bool, mode: str
) -> None:
    """Keep caller mode errors separate from diagnostic reports.

    snapshot_catalog (SchemaCatalog) supplies schemas; malformed (bool) selects
    invalid input and mode (str) the unsupported selector. Return None; no I/O.
    """
    snapshot = no_scope_snapshot(snapshot_catalog)
    # Unsupported modes remain caller errors regardless of input validity.
    if malformed:
        snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})
    with pytest.raises(ValueError, match="mode"):
        report_projection(
            snapshot,
            kind="completion-report",
            identifier="completion",
            mode=cast("ValidationMode", mode),
        )


@pytest.mark.parametrize("malformed", [False, True])
def test_validation_report_preserves_plain_envelope_and_strict_input_boundary(
    snapshot_catalog: SchemaCatalog, monkeypatch: MonkeyPatch, malformed: bool
) -> None:
    """Keep validation-report behavior separate from completion diagnostics.

    snapshot_catalog (SchemaCatalog) supplies schemas; monkeypatch (MonkeyPatch)
    rejects completion preflight; malformed (bool) selects invalid captured input.
    Return None; preserve original exceptions and perform no external I/O.
    """
    snapshot = no_scope_snapshot(snapshot_catalog)
    # The compatibility boundary rejects malformed core rather than summarizing it.
    if malformed:
        snapshot = replace_document(snapshot, snapshot.artifacts[0].path, {})

    def unexpected(value: DiscoverySnapshot) -> None:
        """Reject completion preflight for value (DiscoverySnapshot).

        Raise AssertionError if reached; return None only by annotation, with no I/O.
        """
        raise AssertionError(value.sha256)

    monkeypatch.setattr(validation, "completion_preflight", unexpected)
    # Both branches use the same public dispatch with different captured validity.
    if malformed:
        with pytest.raises(ValueError, match="structurally parsed"):
            report_projection(
                snapshot,
                kind="validation-report",
                identifier="review",
                mode="structural",
            )
    else:
        report = report_projection(
            snapshot, kind="validation-report", identifier="review", mode="structural"
        )
        assert report["validation_result"] == "pass"
        assert report["findings"] == []
        assert report["artifact_kind"] == "validation-report"
        assert report["input_sha256"] == report_input_digest(snapshot)
        assert set(report) == {
            "schema_version",
            "artifact_kind",
            "id",
            "mode",
            "input_sha256",
            "validation_result",
            "counts",
            "findings",
        }
