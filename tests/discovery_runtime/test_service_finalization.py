"""Prove the finalize-agent route reports exact outputs and mints nothing."""

from __future__ import annotations

from hashlib import sha256
from typing import TYPE_CHECKING, Literal

from drm_copilot_discovery.models import JsonObject, ParseLimits, canonical_json
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.validation import report_projection

from tests.discovery_runtime.host_test_support import (
    INVOCATION_ID,
    MemoryHostService,
    invoke_host,
)
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.discovery_runtime.test_service_publication import seed_contract

if TYPE_CHECKING:
    from drm_copilot_discovery.service_contracts import DiscoveryResult

    from tests.discovery_runtime.test_service import MemoryService

CONTRACTS = "docs/migration/discovery/feature-contracts"
CONTRACT = CONTRACTS + "/feature.json"
QUESTIONS = "docs/migration/discovery/unspecified-behaviors.yaml"
CONTRACT_GRANTS = (
    WriteGrant(artifact_kind="feature-contract", artifact_id="feature", path=CONTRACT),
    WriteGrant(
        artifact_kind="unspecified-behavior-collection",
        artifact_id="unresolved-consumer-system",
        path=QUESTIONS,
    ),
)
REVIEWER = "migration-coverage-reviewer"


def manifest_grant(service_io: MemoryService) -> WriteGrant:
    """Return the stored-manifest grant under the configured reports root."""
    reports = MemoryHostService(service_io).invocation
    assert reports is not None
    root = reports.baseline.profile.artifacts["reports"]
    # The loader recognizes a report-root file by its stem, so the stored manifest
    # and every report are named after their artifact kind.
    return WriteGrant(
        artifact_kind="required-output-manifest",
        artifact_id="required-outputs-alpha",
        path=root + "/required-output-manifest.json",
    )


def store_manifest(service_io: MemoryService, host: MemoryHostService) -> str:
    """Write the invocation's exact manifest to its granted path; return the path."""
    assert host.invocation is not None
    row = next(
        grant
        for grant in host.grants
        if grant.artifact_kind == "required-output-manifest"
    )
    service_io.disk.store.put(
        row.path, canonical_json(host.invocation.required_outputs)
    )
    return row.path


def assert_gate_invariants(
    result: DiscoveryResult, verdict: Literal["pass", "fail"]
) -> None:
    """Assert the three checks requireAuthoritativeResult applies to a verdict.

    The result is a finalize-agent agent-output result for the invocation, it
    carries no receipt reference, and its success claims agree with the verdict,
    the exit code and the presence of error findings.
    """
    detail = [
        f"{item.code} {item.artifact_path or ''} {item.message}"
        for item in result.findings
    ]
    assert result.operation == "finalize-agent" and result.mode == "agent-output"
    assert result.summary["invocation_ref"] == INVOCATION_ID
    assert result.summary["receipt_ref"] is None
    assert result.summary["validation_result"] == verdict, detail
    errors = [item for item in result.findings if item.severity == "error"]
    if verdict == "pass":
        assert result.ok and result.exit_code == 0 and errors == []
    else:
        assert not result.ok and result.exit_code != 0 and errors


def test_passing_finalize_reports_created_outputs_and_mints_nothing(
    service_io: MemoryService,
) -> None:
    """A host that published its granted outputs finalizes with exit 0 and no write."""
    grants = (*CONTRACT_GRANTS, manifest_grant(service_io))
    host = MemoryHostService(service_io, grants=grants)
    published = invoke_host(
        host, "new-contract", {"feature_id": "feature", "name": "Feature"}, write=True
    )
    assert published.ok, published.findings
    store_manifest(service_io, host)
    before = dict(service_io.disk.store.files)

    result = invoke_host(host, "finalize-agent")

    assert_gate_invariants(result, "pass")
    assert result.findings == ()
    assert host.invocation is not None
    rows = {row.path: row for row in result.artifacts}
    assert set(rows) == {grant.path for grant in grants}
    # Each row's status follows the pinned prior digest and its digest is current.
    outputs = host.invocation.required_outputs["outputs"]
    assert isinstance(outputs, tuple)
    for output in outputs:
        assert isinstance(output, JsonObject)
        path = str(output["path"])
        expected = "created" if output["expected_sha256"] is None else "updated"
        assert rows[path].status == expected
        assert rows[path].sha256 == sha256(before[path]).hexdigest()
        assert rows[path].kind == output["artifact_kind"]
    assert host.writer_calls == 1 and service_io.disk.store.files == before
    assert result.input_manifest is not None


def test_reviewer_valid_failing_review_exits_one_with_valid_outputs(
    service_io: MemoryService,
) -> None:
    """A reviewer's recomputable failing report is output-valid and result fail."""
    manifest = manifest_grant(service_io)
    report = WriteGrant(
        artifact_kind="completion-report",
        artifact_id="review",
        path=manifest.path.rsplit("/", 1)[0] + "/completion-report.json",
    )
    host = MemoryHostService(
        service_io,
        grants=(report, manifest),
        role=REVIEWER,
        review_mode="discovery-complete",
    )
    assert host.invocation is not None
    projection = report_projection(
        host.invocation.baseline,
        kind="completion-report",
        identifier="review",
        mode="discovery-complete",
    )
    service_io.disk.store.put(
        report.path, canonical_json(bounded_object(projection, limits=ParseLimits()))
    )
    store_manifest(service_io, host)
    before = dict(service_io.disk.store.files)

    result = invoke_host(host, "finalize-agent")

    assert_gate_invariants(result, "fail")
    assert {row.path for row in result.artifacts} == {report.path, manifest.path}
    assert all(row.status == "created" for row in result.artifacts)
    # Output-contract findings are absent; the errors are the recomputed gate result.
    assert not any(item.code.startswith("OUTPUT_") for item in result.findings)
    assert host.writer_calls == 0 and service_io.disk.store.files == before


def test_missing_required_output_is_a_conflict_row_and_exit_one(
    service_io: MemoryService,
) -> None:
    """A granted output deleted after preparation is reported as conflict."""
    path = seed_contract(service_io)
    original = sha256(service_io.disk.store.files[path]).hexdigest()
    contract = WriteGrant(
        artifact_kind="feature-contract", artifact_id="feature", path=path
    )
    host = MemoryHostService(service_io, grants=(contract, manifest_grant(service_io)))
    # Delete the pinned output after preparation: both bytes and enumeration name.
    del service_io.disk.store.files[path]
    service_io.disk.store.metadata.remove(path)
    store_manifest(service_io, host)

    result = invoke_host(host, "finalize-agent")

    assert_gate_invariants(result, "fail")
    assert "OUTPUT_MISSING" in {item.code for item in result.findings}
    rows = {row.path: row for row in result.artifacts}
    assert rows[path].status == "conflict" and rows[path].sha256 == original
    assert host.writer_calls == 0


def test_never_written_output_is_reported_by_finding_without_a_fabricated_row(
    service_io: MemoryService,
) -> None:
    """An absent output with no prior digest has no row; the finding names it."""
    grants = (*CONTRACT_GRANTS, manifest_grant(service_io))
    host = MemoryHostService(service_io, grants=grants)
    store_manifest(service_io, host)

    result = invoke_host(host, "finalize-agent")

    assert_gate_invariants(result, "fail")
    missing = [
        item.artifact_path for item in result.findings if item.code == "OUTPUT_MISSING"
    ]
    assert CONTRACT in missing
    assert CONTRACT not in {row.path for row in result.artifacts}
    assert host.writer_calls == 0


def test_ungranted_required_output_row_is_refused_before_validation(
    service_io: MemoryService,
) -> None:
    """A required output outside the authority's grants is an exit-3 refusal."""
    grants = (*CONTRACT_GRANTS, manifest_grant(service_io))
    host = MemoryHostService(service_io, grants=grants)
    store_manifest(service_io, host)
    host.grants = grants[:-1]
    before = dict(service_io.disk.store.files)

    result = invoke_host(host, "finalize-agent")

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert result.summary["validation_result"] is None
    assert result.summary["receipt_ref"] is None
    assert host.writer_calls == 0 and service_io.disk.store.files == before


def test_local_user_finalize_remains_refused(service_io: MemoryService) -> None:
    """No finalize result exists for a non-host authority."""
    host = MemoryHostService(service_io, grants=CONTRACT_GRANTS)
    host.principal = "local-user"
    host.invocation = None

    result = invoke_host(host, "finalize-agent")

    assert result.exit_code == 3 and result.findings[0].code == "SERVICE_AUTHORITY"
    assert result.input_manifest is None and result.artifacts == ()
    assert result.summary["invocation_ref"] is None
    assert host.writer_calls == 0
