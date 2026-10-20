"""Verify explicit mode composition against complete immutable in-memory inputs."""

from __future__ import annotations

from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import canonical_json, to_plain_value
from drm_copilot_discovery.snapshot import (
    SnapshotFile,
)
from drm_copilot_discovery.validation import (
    report_input_digest,
    report_projection,
    validate_snapshot,
)

from tests.discovery_runtime.test_references import immutable
from tests.discovery_runtime.test_snapshot_io import (
    snapshot_catalog as snapshot_catalog,
)
from tests.schemas.discovery.v2_schema_test_support import as_object

if TYPE_CHECKING:
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.validation import ValidationMode

from tests.discovery_runtime.validation_test_support import (
    ROOT,
    captured,
    document_record,
    mode_profile,
    no_scope_snapshot,
    replace_document,
)


@pytest.mark.parametrize("mode", ["discovery-complete", "parity-complete", "planning"])
def test_initialized_draft_is_structural_success_but_not_completion(
    snapshot_catalog: SchemaCatalog, mode: ValidationMode
) -> None:
    """An honest empty initialization cannot authorize discovery, parity or planning."""
    snapshot = captured(mode_profile(snapshot_catalog, draft=True), snapshot_catalog)
    assert validate_snapshot(snapshot, mode="structural").ok
    result = validate_snapshot(snapshot, mode=mode)
    assert not result.ok and result.validation_result == "fail"
    assert "COMPLETION_PROFILE" in {item.code for item in result.findings}
    assert result.input_sha256 == snapshot.sha256 and result.output_valid is None


@pytest.mark.parametrize(
    "mode", ["structural", "discovery-complete", "parity-complete", "planning"]
)
def test_confirmed_empty_scope_can_complete_without_synthetic_features(
    snapshot_catalog: SchemaCatalog, mode: ValidationMode
) -> None:
    """Confirmed no-scope with current inventory has no invented feature obligations."""
    snapshot = no_scope_snapshot(snapshot_catalog)
    result = validate_snapshot(snapshot, mode=mode)
    assert result.findings == () and result.ok


@pytest.mark.parametrize(
    "prerequisite,passed",
    [("none", True), ("discovery-complete", False), ("parity-complete", False)],
)
def test_planning_obeys_explicit_profile_prerequisite(
    snapshot_catalog: SchemaCatalog, prerequisite: str, passed: bool
) -> None:
    """Structural success only permits planning when the configured prerequisite is
    none.
    """
    snapshot = captured(
        mode_profile(snapshot_catalog, draft=True, planning=prerequisite),
        snapshot_catalog,
    )
    assert validate_snapshot(snapshot, mode="planning").ok is passed


@pytest.mark.parametrize(
    "mode",
    ["structural", "agent-output", "discovery-complete", "parity-complete", "planning"],
)
def test_absent_snapshot_fails_closed_in_every_mode(mode: ValidationMode) -> None:
    """A missing active profile cannot be interpreted as an inactive successful gate."""
    result = validate_snapshot(None, mode=mode)
    assert not result.ok and result.findings[0].code == "PROFILE_REQUIRED"


@pytest.mark.parametrize(
    "case",
    [
        "missing-profile",
        "malformed-profile",
        "profile-mismatch",
        "missing-descriptor",
        "parsed-mismatch",
        "v1",
        "wrong-kind",
        "bad-unreferenced",
        "pins",
    ],
)
def test_all_retained_inputs_are_checked_before_graph_success(
    snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Valid artifacts cannot hide malformed or unrepresented inputs."""
    snapshot = no_scope_snapshot(snapshot_catalog)
    files, records = snapshot.manifest.files, snapshot.artifacts
    profile_path = snapshot.profile.artifacts["profile"]
    if case == "missing-profile":
        files = tuple(item for item in files if item.path != profile_path)
    elif case in {"malformed-profile", "profile-mismatch"}:
        content = (
            b"{"
            if case == "malformed-profile"
            else canonical_json(mode_profile(snapshot_catalog, draft=True).document)
        )
        files = tuple(
            replace(item, content=content) if item.path == profile_path else item
            for item in files
        )
    elif case == "missing-descriptor":
        files += (
            SnapshotFile(
                path=ROOT + "evidence/extra.json", content=b"{}", category="artifact"
            ),
        )
    elif case == "pins":
        snapshot = replace(
            snapshot, manifest=replace(snapshot.manifest, source_repositories=())
        )
        files = snapshot.manifest.files
    else:
        first = records[0]
        value = as_object(to_plain_value(first.document)) if first.document else {}
        if case == "v1":
            value["schema_version"] = "1.0.0"
        if case == "wrong-kind":
            value["artifact_kind"] = "feature-contract"
        content = (
            b"{" if case == "bad-unreferenced" else canonical_json(immutable(value))
        )
        records = (
            replace(
                first,
                document=(
                    immutable({}) if case == "parsed-mismatch" else immutable(value)
                ),
            ),
            *records[1:],
        )
        files = tuple(
            replace(item, content=content) if item.path == first.path else item
            for item in files
        )
    result = validate_snapshot(
        replace(
            snapshot,
            artifacts=records,
            manifest=replace(snapshot.manifest, files=files),
        ),
        mode="structural",
    )
    assert not result.ok and result.findings


def test_loader_findings_are_preserved_and_deterministically_sorted(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Existing capture errors remain blocking and input order cannot change
    diagnostics.
    """
    snapshot = no_scope_snapshot(snapshot_catalog)
    errors = (
        Finding(code="Z_ERROR", message="z", next_action="Fix z."),
        Finding(code="A_ERROR", message="a", next_action="Fix a."),
    )
    first = validate_snapshot(replace(snapshot, findings=errors), mode="structural")
    second = validate_snapshot(
        replace(snapshot, findings=tuple(reversed(errors))), mode="structural"
    )
    assert first == second and not first.ok


@pytest.mark.parametrize(
    "missing_output",
    [None, "", "/report.json"],
    ids=["initialized-root", "absent-root", "absent-report"],
)
@pytest.mark.parametrize("kind", ["completion-report", "coverage-report"])
def test_report_projection_is_recomputed_and_nonrecursive(
    snapshot_catalog: SchemaCatalog, missing_output: str | None, kind: str
) -> None:
    """Adding the exact derived report changes full identity but not its semantic
    digest.
    """
    snapshot = no_scope_snapshot(snapshot_catalog)
    if missing_output is not None:
        snapshot = replace(
            snapshot,
            manifest=replace(
                snapshot.manifest,
                missing_paths=(snapshot.profile.artifacts["reports"] + missing_output,),
            ),
        )
    value = report_projection(snapshot, kind=kind, identifier="report", mode="planning")
    record = document_record(
        snapshot.profile, kind, ROOT + "reports/report.json", value
    )
    with_report = captured(
        snapshot.profile,
        snapshot_catalog,
        *snapshot.artifacts,
        record,
        payloads=tuple(
            item for item in snapshot.manifest.files if item.category == "evidence"
        ),
    )
    assert with_report.sha256 != snapshot.sha256
    assert report_input_digest(with_report) == report_input_digest(snapshot)
    # The planning report reuses the already evaluated discovery prerequisite.
    assert validate_snapshot(with_report, mode="discovery-complete").ok
    value["validation_result"] = "fail"
    assert "REPORT_RESULT" in {
        item.code
        for item in validate_snapshot(
            replace_document(with_report, record.path, value), mode="structural"
        ).findings
    }


@pytest.mark.parametrize(
    "case",
    [
        "id",
        "mode",
        "extra",
        "agent-output",
        "coverage",
        "discovery_result",
        "completion_findings",
    ],
)
def test_authored_report_contract_cannot_replace_recomputation(
    snapshot_catalog: SchemaCatalog, case: str
) -> None:
    """Missing bindings, unsupported mode and authored synthetic readiness fail."""
    snapshot = no_scope_snapshot(snapshot_catalog)
    value = report_projection(
        snapshot, kind="coverage-report", identifier="report", mode="structural"
    )
    if case in {"id", "mode"}:
        value.pop(case)
    elif case == "extra":
        value["ready"] = True
    elif case == "coverage":
        value["coverage"] = {}
    elif case == "discovery_result":
        value["discovery_result"] = "fail"
    elif case == "completion_findings":
        value["completion_findings"] = [{"code": "AUTHORED_SUCCESS"}]
    else:
        value["mode"] = "agent-output"
    record = document_record(
        snapshot.profile, "coverage-report", ROOT + "reports/report.json", value
    )
    result = validate_snapshot(
        captured(
            snapshot.profile,
            snapshot_catalog,
            *snapshot.artifacts,
            record,
            payloads=tuple(
                item for item in snapshot.manifest.files if item.category == "evidence"
            ),
        ),
        mode="structural",
    )
    assert not result.ok and any(
        item.code.startswith("REPORT_") for item in result.findings
    )


def test_invalid_public_modes_and_unparsed_projection_raise_explicitly(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Caller API mistakes are distinct from ordinary input validation findings."""
    snapshot = captured(mode_profile(snapshot_catalog), snapshot_catalog)
    with pytest.raises(ValueError, match="supported validation"):
        validate_snapshot(snapshot, mode=cast("ValidationMode", "automatic"))
    with pytest.raises(ValueError, match="Unsupported report or validation mode"):
        report_projection(
            snapshot,
            kind="coverage-report",
            identifier="report",
            mode=cast("ValidationMode", "automatic"),
        )
    # Public caller mistakes fail before constructing any report assessment.
    for kind, mode in (("unknown", "structural"), ("coverage-report", "agent-output")):
        with pytest.raises(ValueError, match="Reports require"):
            report_projection(
                snapshot,
                kind=kind,
                identifier="report",
                mode=cast("ValidationMode", mode),
            )
    # Only coverage has a truthful unavailable-input envelope; other kinds still reject.
    for kind in ("completion-report", "parity-report"):
        with pytest.raises(ValueError, match="structurally parsed"):
            report_projection(
                replace(snapshot, manifest=replace(snapshot.manifest, files=())),
                kind=kind,
                identifier="report",
                mode="structural",
            )


def test_semantic_digest_tracks_changed_source_bytes(
    snapshot_catalog: SchemaCatalog,
) -> None:
    """Report hashing still includes actual inspected source changes."""
    snapshot = no_scope_snapshot(snapshot_catalog)
    file = SnapshotFile(path="src/addition.cs", content=b"source", category="source")
    changed = replace(
        snapshot,
        manifest=replace(snapshot.manifest, files=(*snapshot.manifest.files, file)),
    )
    assert report_input_digest(snapshot) != report_input_digest(changed)
    assert sha256(file.content).hexdigest() == file.sha256


@pytest.mark.parametrize(
    "missing_path", ["src/missing.cs", ROOT + "reports-neighbor/input.json"]
)
def test_semantic_digest_preserves_non_output_missing_inputs(
    snapshot_catalog: SchemaCatalog, missing_path: str
) -> None:
    """Missing inspected inputs stay bound even beside the configured report root."""
    snapshot = captured(mode_profile(snapshot_catalog), snapshot_catalog)
    missing = replace(
        snapshot,
        manifest=replace(snapshot.manifest, missing_paths=(missing_path,)),
    )
    assert report_input_digest(missing) != report_input_digest(snapshot)


@pytest.mark.parametrize("count,passed", [(1, True), (120, False)])
def test_composed_warning_findings_are_bounded_and_truncation_blocks(
    snapshot_catalog: SchemaCatalog, count: int, passed: bool
) -> None:
    """Preserve warnings and reject overflow of the finite result budget."""
    snapshot = captured(
        mode_profile(snapshot_catalog, planning="none"), snapshot_catalog
    )
    # Distinct captured diagnostics exercise aggregation without schema noise.
    warnings = tuple(
        Finding(
            code="INPUT_WARNING",
            severity="warning",
            message=f"Observation {index}",
            next_action="Inspect the captured observation.",
        )
        for index in range(count)
    )
    result = validate_snapshot(replace(snapshot, findings=warnings), mode="planning")
    assert result.ok is passed
    assert len(result.findings) == min(
        count, snapshot.profile.limits.parse_limits().findings
    )
    assert ("FINDINGS_LIMIT" in {item.code for item in result.findings}) is not passed


@pytest.mark.parametrize("fault", ["missing-profile", "loader"])
def test_invalid_coverage_inputs_retain_original_findings_and_unavailable_counts(
    snapshot_catalog: SchemaCatalog, fault: str
) -> None:
    """For fault (str), project blockers without trusting invalid population bytes."""
    snapshot = no_scope_snapshot(snapshot_catalog)
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
    structural = validate_snapshot(snapshot, mode="structural")

    report = report_projection(
        snapshot, kind="coverage-report", identifier="coverage", mode="structural"
    )

    assert report["validation_result"] == report["discovery_result"] == "fail"
    assert report["findings"] == report["completion_findings"]
    assert report["findings"] == [item.to_dict() for item in structural.findings]
    assert report["counts"] == {}
    assert report["coverage"] == {
        "population_state": "unavailable",
        "components": None,
        "features": None,
        "runtime": None,
        "unresolved_behaviors": None,
        "metrics": None,
        "known_inventory_refs": None,
    }
    assert report["input_sha256"] == report_input_digest(snapshot)
    assert not validate_snapshot(snapshot, mode="planning").ok
    with pytest.raises(ValueError, match="Unsupported report or validation mode"):
        report_projection(
            snapshot,
            kind="coverage-report",
            identifier="coverage",
            mode=cast("ValidationMode", "automatic"),
        )


@pytest.mark.parametrize("draft", [False, True])
@pytest.mark.parametrize("mode", ["structural", "discovery-complete", "planning"])
def test_coverage_preserves_requested_mode_and_independent_discovery_results(
    snapshot_catalog: SchemaCatalog, draft: bool, mode: ValidationMode
) -> None:
    """For draft (bool) and mode, use the existing assessments without new gates."""
    snapshot = (
        captured(mode_profile(snapshot_catalog, draft=True), snapshot_catalog)
        if draft
        else no_scope_snapshot(snapshot_catalog)
    )
    requested = validate_snapshot(snapshot, mode=mode)
    complete = validate_snapshot(snapshot, mode="discovery-complete")

    report = report_projection(
        snapshot, kind="coverage-report", identifier="coverage", mode=mode
    )

    assert report["validation_result"] == requested.validation_result
    assert report["findings"] == [item.to_dict() for item in requested.findings]
    assert report["discovery_result"] == complete.validation_result
    assert report["completion_findings"] == [
        item.to_dict() for item in complete.findings
    ]
    population = as_object(report["coverage"])
    assert population["population_state"] == ("unavailable" if draft else "available")
    if draft:
        assert all(
            population[key] is None
            for key in (
                "components",
                "features",
                "runtime",
                "unresolved_behaviors",
                "metrics",
            )
        )
    other = report_projection(
        snapshot, kind="parity-report", identifier="parity", mode=mode
    )
    assert not ({"coverage", "discovery_result", "completion_findings"} & other.keys())
