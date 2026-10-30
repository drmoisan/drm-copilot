"""Exercise report refusal and acceptance publication through real memory ports."""

from __future__ import annotations

import json
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, NoReturn, cast

import pytest
from drm_copilot_discovery import validation
from drm_copilot_discovery.acceptance_generation import generate_acceptance
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.gherkin import render_acceptance
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.operations import OperationContext, OperationFailure
from drm_copilot_discovery.report_models import DiscoveryReport, ReportLimitError
from drm_copilot_discovery.service_reports import project, report_findings

from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.discovery_runtime.test_service_boundaries import context as context
from tests.schemas.discovery.v2_schema_test_support import as_object, load_fixture

if TYPE_CHECKING:
    from drm_copilot_discovery.acceptance_models import AcceptanceGeneration
    from drm_copilot_discovery.mutation_plan import MutationChange, MutationPlan
    from drm_copilot_discovery.service_contracts import Operation
    from drm_copilot_discovery.transport_manifest import TransportRoute

    from tests.discovery_runtime.test_service import MemoryService


def _captured(
    bootstrap: OperationContext,
    io: MemoryService,
    *,
    operation: Operation = "coverage-report",
    inputs: JsonObject | None = None,
    write: bool = False,
) -> OperationContext:
    """Return OperationContext over actual memory capture without publication.

    bootstrap (OperationContext) and io (MemoryService) supply authenticated ports.
    operation (Operation), inputs (JsonObject | None) and write (bool) select the
    request; omitted inputs retain bootstrap's fields. Capture errors propagate.
    """
    baseline = capture_workspace(
        workspace_root=io.disk.root,
        profile_path=DEFAULT_PROFILE,
        metadata=io.disk.store.metadata,
        read_bytes=io.disk.store.read,
        catalog=io.initialization.catalog,
        repository=io.repository,
    )
    return OperationContext(
        replace(
            bootstrap.request,
            operation=operation,
            inputs=bootstrap.request.inputs if inputs is None else inputs,
            write=write,
        ),
        io=io,
        authority=bootstrap.authority,
        runtime=bootstrap.runtime,
        baseline=baseline,
        reads=bootstrap.reads,
        timestamp=bootstrap.timestamp,
        analyzer_registry=bootstrap.analyzer_registry,
    )


def _unexpected(*_args: object, **_kwargs: object) -> NoReturn:
    """Reject downstream calls with ignored object args/kwargs; never return.

    Raises AssertionError to expose fallback, rendering or planning after a
    refusal. Test-owned monkeypatches install this observer; no I/O occurs.
    """
    raise AssertionError("A refused report reached a downstream operation")


def _seed_acceptance(io: MemoryService) -> None:
    """Seed verified-source and unresolved criteria in io (MemoryService); return None.

    Committed example documents supply authored claims; a matching memory payload
    supplies their exact evidence. Public generation still determines readiness.
    Fixture shape errors propagate; only this test's memory store is changed.
    """
    profile = as_object(json.loads(io.disk.store.files[DEFAULT_PROFILE]))
    roots = as_object(profile["artifacts"])
    repository = as_object(profile["repository"])
    source = load_fixture("feature-contract")
    ready = as_object(cast("list[object]", source["acceptance_criteria"])[0])
    ready.update(client_ids=[], platforms=[])
    pending = {
        **ready,
        "id": "criterion-pending",
        "readiness": "pending",
        "expected_result": None,
        "pending_reason": "The alternative outcome remains unresolved.",
    }
    source["acceptance_criteria"] = [ready, pending]
    payload = b"Observed activation.\r\n"
    payload_path = str(roots["evidence"]) + "/observed.bin"
    proof = load_fixture("evidence-reference")
    proof.update(
        id="source-alpha",
        evidence_id="source-alpha",
        repository=repository["id"],
        revision=repository["revision"],
        path=payload_path,
        runtime_artifact={"path": payload_path, "capture_method": "manual"},
        checksum={"algorithm": "sha256", "value": sha256(payload).hexdigest()},
    )
    as_object(proof["environment"])["client_id"] = None
    io.disk.store.put(payload_path, payload)
    io.disk.store.put(
        str(roots["feature_contracts"]) + "/feature-alpha.json",
        json.dumps(source).encode("utf-8"),
    )
    io.disk.store.put(
        str(roots["evidence"]) + "/source-alpha.json",
        json.dumps(proof).encode("utf-8"),
    )


def _acceptance_expected(
    captured: OperationContext, output_format: str
) -> tuple[AcceptanceGeneration, dict[str, bytes]]:
    """Return AcceptanceGeneration and dict[str, bytes] for the selected format.

    captured (OperationContext) supplies the real graph; output_format (str) selects
    Markdown or Gherkin views. All source specifications remain. Generation and
    rendering failures propagate; no state changes occur.
    """
    generated = generate_acceptance(captured.snapshot, kind="legacy-characterization")
    rendered = render_acceptance(generated)
    root = captured.snapshot.profile.artifacts["acceptance"]
    # Keep every source specification, including a pending non-executable criterion.
    expected = {
        root
        + "/"
        + item.identity.scenario_id(limits=captured.limits)
        + ".json": item.to_json().encode("utf-8")
        for item in generated.specifications
    }
    suffix = ".md" if output_format == "markdown" else ".feature"
    # Selection changes only view formats; public readiness selects eligible Gherkin.
    expected.update(
        (root + "/" + view.path, view.content)
        for view in rendered.files
        if view.path.endswith(suffix)
    )
    assert len(generated.specifications) == 2 and len(generated.ready) == 1
    # Bind pending provenance explicitly so a fabricated ready membership fails.
    pending = next(
        item
        for item in generated.specifications
        if item.document["readiness"] == "pending"
    )
    assert pending.document["then"] is None
    assert pending.document["expectation_basis"] == "unresolved"
    assert pending.document["pending_reasons"] == (
        "The alternative outcome remains unresolved.",
    )
    pending_view = (
        root + "/" + pending.identity.scenario_id(limits=captured.limits) + ".feature"
    )
    assert pending_view not in expected
    return generated, expected


@pytest.mark.parametrize(
    "document, message",
    [
        pytest.param(
            JsonObject((("findings", "invalid"),)), "immutable sequence", id="RG1"
        ),
        pytest.param(
            JsonObject((("findings", ("invalid",)),)), "immutable objects", id="RG2"
        ),
    ],
)
def test_malformed_report_findings_are_not_an_empty_success(
    document: JsonObject,
    message: str,
) -> None:
    """Reject document (JsonObject) using message (str); return None without I/O.

    ValueError must expose the precise trusted-output shape failure rather than
    silently dropping possible blocking findings.
    """
    with pytest.raises(ValueError, match=message):
        report_findings(document)


@pytest.mark.parametrize(
    "error",
    [
        pytest.param(ReportLimitError(), id="RG3"),
        pytest.param(ValueError("projection"), id="RG4"),
    ],
)
def test_projection_errors_propagate_without_fallback_or_publication(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
    error: ValueError,
) -> None:
    """Propagate error (ValueError) unchanged; return None without memory writes.

    context (OperationContext) and service_io (MemoryService) supply fresh capture.
    monkeypatch (pytest.MonkeyPatch) confines faults to projection and forbids
    subsequent assessment, serialization and planning. No fallback is accepted.
    """
    captured = _captured(context, service_io)
    before = dict(service_io.disk.store.files)

    def refuse(*_args: object, **_kwargs: object) -> NoReturn:
        """Raise the exact error for ignored object args/kwargs; no I/O or return."""
        raise error

    monkeypatch.setattr(validation, "report_projection", refuse)
    monkeypatch.setattr(validation, "validate_snapshot", _unexpected)
    monkeypatch.setattr(DiscoveryReport, "to_json", _unexpected)
    monkeypatch.setattr(captured, "plan", _unexpected)
    with pytest.raises(type(error)) as raised:
        project(captured)
    assert raised.value is error
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_malformed_validate_all_retains_public_validator_findings(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """RG5: retain original malformed-core findings; return None without writes.

    context (OperationContext) and service_io (MemoryService) provide the graph;
    monkeypatch (pytest.MonkeyPatch) forbids planning after public validation fails.
    Actual validator findings must survive with no report artifacts or publication.
    """
    service_io.disk.store.put("docs/migration/discovery/coverage-ledger.json", b"{}")
    captured = _captured(context, service_io, operation="validate-all")
    before = dict(service_io.disk.store.files)
    expected = validation.validate_snapshot(captured.snapshot, mode="structural")
    assert expected.findings and expected.validation_result == "fail"
    monkeypatch.setattr(captured, "plan", _unexpected)

    result = project(captured)

    assert result.exit_code == 1 and not result.ok and result.artifacts == ()
    assert result.findings == expected.findings
    assert result.summary["validation_result"] == "fail"
    assert result.input_manifest == captured.snapshot.manifest
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_invalid_projection_validation_status_is_refused(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """RG6: reject an invalid projection status; return None without memory writes.

    context (OperationContext) and service_io (MemoryService) provide real capture.
    monkeypatch (pytest.MonkeyPatch) corrupts only projection and forbids planning.
    Bounded construction is real; ValueError must precede artifact emission.
    """
    captured = _captured(context, service_io)
    before = dict(service_io.disk.store.files)

    def invalid(*_args: object, **_kwargs: object) -> dict[str, object]:
        """Return dict[str, object] for ignored object args/kwargs; no I/O occurs."""
        return {"findings": [], "validation_result": "unknown"}

    monkeypatch.setattr(validation, "report_projection", invalid)
    monkeypatch.setattr(captured, "plan", _unexpected)
    with pytest.raises(ValueError, match="selected validation result"):
        project(captured)
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


@pytest.mark.parametrize(
    "output_format",
    [pytest.param("markdown", id="RG7"), pytest.param("gherkin", id="RG8")],
)
def test_acceptance_preview_preserves_ready_and_pending_selected_views(
    context: OperationContext,
    service_io: MemoryService,
    output_format: str,
) -> None:
    """Preserve actual acceptance sources and selected views; return None, no writes.

    context (OperationContext), service_io (MemoryService) and output_format (str)
    exercise real generation/rendering. Exact bytes, provenance, pending membership
    and selected counts must remain intact; fixture or producer errors propagate.
    """
    _seed_acceptance(service_io)
    captured = _captured(
        context,
        service_io,
        operation="generate-acceptance",
        inputs=JsonObject(
            (
                ("acceptance_kind", "legacy-characterization"),
                ("output_format", output_format),
            )
        ),
    )
    generated, expected = _acceptance_expected(captured, output_format)
    before = dict(service_io.disk.store.files)

    result = project(captured)

    assert result.ok and result.findings == generated.findings
    assert result.input_manifest == captured.snapshot.manifest
    assert len(result.artifacts) == len(expected)
    # Each retained row must preserve exact generated bytes and their original hash.
    for row in result.artifacts:
        assert row.status == "planned" and row.content is not None
        assert row.content.encode("utf-8") == expected[row.path]
        assert row.sha256 == sha256(expected[row.path]).hexdigest()
    counts = result.summary["counts"]
    assert counts == (
        JsonObject((("name", "specifications"), ("value", 2))),
        JsonObject((("name", "ready_specifications"), ("value", 1))),
    )
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_acceptance_write_plans_complete_sources_and_selected_views(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """RG9: publish one real prospective acceptance plan; return None, memory only.

    context (OperationContext), service_io (MemoryService) and monkeypatch
    (pytest.MonkeyPatch) observe the unchanged planner. Guarded writes retain exact
    identities, byte digests and findings; planner/writer errors are not suppressed.
    """
    _seed_acceptance(service_io)
    captured = _captured(
        context,
        service_io,
        operation="generate-acceptance",
        write=True,
        inputs=JsonObject(
            (
                ("acceptance_kind", "legacy-characterization"),
                ("output_format", "gherkin"),
            )
        ),
    )
    generated, expected = _acceptance_expected(captured, "gherkin")
    before = dict(service_io.disk.store.files)
    plans: list[MutationPlan] = []
    real_plan = captured.plan

    def observe(
        changes: tuple[MutationChange, ...],
        *,
        transport: TransportRoute | None = None,
    ) -> MutationPlan:
        """Return the actual MutationPlan, recording it in the test-local list.

        changes (tuple[MutationChange, ...]) and transport (TransportRoute | None)
        reach the real planner. Errors propagate; validation, grants, prospective
        capture and writes remain real. This observer performs no publication.
        """
        plan = real_plan(changes, transport=transport)
        plans.append(plan)
        return plan

    monkeypatch.setattr(captured, "plan", observe)
    result = project(captured)

    assert result.ok and result.findings == generated.findings
    assert len(plans) == 1 and service_io.writer_calls == 1
    assert result.input_manifest == captured.snapshot.manifest
    # Match the complete request set; no source or selected view may disappear.
    assert {
        write.change.path: write.change.content for write in plans[0].writes
    } == expected
    assert service_io.disk.store.files == {**before, **expected}
    assert len(result.artifacts) == len(expected)
    # Only guarded outcomes may claim created files with exact final digests.
    for row in result.artifacts:
        assert row.status == "created" and row.content is None
        assert row.sha256 == sha256(expected[row.path]).hexdigest()
    # Specification IDs survive planning; views retain the authenticated request ID.
    for write in plans[0].writes:
        change = write.change
        assert change.expected_sha256 is None
        assert change.artifact_id == (
            json.loads(change.content)["id"]
            if change.artifact_kind == "acceptance-specification"
            else captured.request.id
        )


def test_report_dispatch_refuses_another_operation_family(
    context: OperationContext,
    service_io: MemoryService,
) -> None:
    """RG10: reject context (OperationContext) with a valid profile-family request.

    service_io (MemoryService) exposes unchanged memory for comparison. Return None;
    OperationFailure must retain SERVICE_OPERATION without projection or writes.
    """
    before = dict(service_io.disk.store.files)
    with pytest.raises(OperationFailure) as raised:
        project(context)
    assert raised.value.findings[0].code == "SERVICE_OPERATION"
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before
