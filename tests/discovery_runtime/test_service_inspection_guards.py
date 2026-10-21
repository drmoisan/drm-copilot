"""Cover the finite inspection guards without changing accepted service callers."""

from __future__ import annotations

import json
from dataclasses import replace
from hashlib import sha256
from typing import TYPE_CHECKING, NoReturn

import pytest
from drm_copilot_discovery.analyzer import pipeline, registry
from drm_copilot_discovery.analyzer.input_capture import pin_inventory_sources
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.findings import Finding
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.operations import OperationContext, OperationFailure
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.profile_v2 import ProfileError, ProfileV2
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service_inspection import inspect_request
from drm_copilot_discovery.source_read_models import (
    ReadGrant,
    ReadSelection,
    SourceReadLimits,
)

from tests.discovery_runtime.test_service import MemoryService, invoke
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.discovery_runtime.test_service_boundaries import context as context

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.models import InventoryCapture, InventoryResult
    from drm_copilot_discovery.analyzer.registry import InventoryRegistry
    from drm_copilot_discovery.catalog import SchemaCatalog


def captured_source(context: OperationContext, io: MemoryService) -> OperationContext:
    """Return OperationContext from context (OperationContext), io (MemoryService).

    Seed one four-byte production file, retain its repository pin, and grant only
    that path. No external I/O occurs; setup or capture failures propagate.
    """
    path = "application/a.cs"
    io.disk.store.put(path, b"one\n")
    io.repository.files[path] = io.disk.store.files[path]
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
            context.request,
            operation="read-source",
            inputs=bounded_object(
                {"read_operation": "read", "paths": [path]}, limits=ParseLimits()
            ),
        ),
        io=io,
        authority=replace(
            context.authority,
            read_selection=ReadSelection(grants=(ReadGrant(path=path),)),
        ),
        runtime=context.runtime,
        baseline=pin_inventory_sources(baseline, io.repository),
        reads=context.reads,
        timestamp=context.timestamp,
        analyzer_registry=context.analyzer_registry,
    )


def test_ig1_default_profile_uses_trusted_selection_and_exact_bytes(
    context: OperationContext, service_io: MemoryService
) -> None:
    """Expose trusted profile bytes without writes; return None.

    context (OperationContext) and service_io (MemoryService) are isolated memory
    fixtures. Assert exact bytes/digest and unchanged activation and files.
    """
    before = dict(service_io.disk.store.files)
    activation = service_io.configuration.registry.raw
    result = inspect_request(context)
    assert result.ok and len(result.artifacts) == 1
    row = result.artifacts[0]
    assert row.path == DEFAULT_PROFILE and row.status == "planned"
    assert row.content == before[DEFAULT_PROFILE].decode("utf-8")
    assert row.sha256 == sha256(before[DEFAULT_PROFILE]).hexdigest()
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before
    assert service_io.configuration.registry.raw == activation


def test_ig2_unsupported_profile_version_refuses_artifacts(
    context: OperationContext, service_io: MemoryService
) -> None:
    """Reject unsupported captured version; return None after typed refusal.

    context (OperationContext) and service_io (MemoryService) supply memory-only
    profile reads. Require SERVICE_VERSION and no file or writer effects.
    """
    service_io.disk.store.put(DEFAULT_PROFILE, b'{"schema_version":"3.0.0"}')
    context.inputs["input_path"] = DEFAULT_PROFILE
    before = dict(service_io.disk.store.files)
    with pytest.raises(OperationFailure) as raised:
        inspect_request(context)
    assert raised.value.findings[0].code == "SERVICE_VERSION"
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_ig3_malformed_v2_preserves_original_profile_findings(
    context: OperationContext, service_io: MemoryService
) -> None:
    """Preserve real ProfileV2 findings without activation or writes; return None.

    context (OperationContext) and service_io (MemoryService) supply memory-only
    malformed v2 bytes. Compare the exact parser findings and blocking result.
    """
    content = b'{"schema_version":"2.0.0"}'
    service_io.disk.store.put(DEFAULT_PROFILE, content)
    context.request = replace(context.request, operation="validate-profile")
    context.inputs["input_path"] = DEFAULT_PROFILE
    activation = service_io.configuration.registry.raw
    with pytest.raises(ProfileError) as expected:
        ProfileV2(content, catalog=service_io.initialization.catalog)
    result = inspect_request(context)
    assert result.findings == expected.value.findings
    assert not result.ok and result.exit_code == 1 and result.artifacts == ()
    assert service_io.writer_calls == 0
    assert service_io.configuration.registry.raw == activation


def test_ig4_selector_profile_error_survives_before_analysis(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Retain selector ProfileError before analysis or publication; return None.

    context (OperationContext), service_io (MemoryService), and monkeypatch
    (pytest.MonkeyPatch) bind memory capture and the trusted selector seam.
    """
    selected = captured_source(context, service_io)
    selected.request = replace(
        selected.request, operation="inventory", inputs=JsonObject(())
    )
    selected.inputs = {}
    finding = Finding(code="PROFILE_REQUIRED", message="Required", next_action="Repair")
    failure = ProfileError((finding,))
    calls: list[str] = []

    def refuse(
        profile: ProfileV2, *, analyzer_ids: tuple[str, ...] | None = None
    ) -> NoReturn:
        """Record profile (ProfileV2), analyzer_ids (tuple[str, ...] | None).

        Raise the retained ProfileError; never return or perform I/O.
        """
        assert profile is selected.snapshot.profile and analyzer_ids is None
        calls.append("selection")
        raise failure

    def forbidden(*args: object, **kwargs: object) -> NoReturn:
        """Reject args (object tuple)/kwargs (object dict) with AssertionError.

        Never return or perform external I/O; record forbidden analysis use.
        """
        calls.append("analysis")
        raise AssertionError("Selection failure must precede analysis")

    monkeypatch.setattr(registry, "normalized_analyzer_ids", refuse)
    monkeypatch.setattr(pipeline, "run_inventory", forbidden)
    with pytest.raises(ProfileError) as raised:
        inspect_request(selected)
    assert raised.value is failure and raised.value.findings == (finding,)
    assert calls == ["selection"] and service_io.writer_calls == 0


def test_ig5_inventory_write_reconstructs_exact_selection_and_grants(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Use real memory publication and patched preview to prove authority isolation.

    service_io (MemoryService), monkeypatch (pytest.MonkeyPatch) are fixtures.
    Return None; retain exact
    selected IDs/grants and reject altered preview metadata before another write.
    """
    preview = invoke(service_io, "inventory", {"analyzer_ids": ["repository"]})
    assert preview.ok and service_io.writer_calls == 0
    row = preview.artifacts[0]
    assert row.content is not None
    document = json.loads(row.content)
    service_io.grants = (
        WriteGrant(artifact_kind=row.kind, artifact_id=document["id"], path=row.path),
    )
    real = pipeline.run_inventory
    calls: list[tuple[tuple[str, ...] | None, bool]] = []
    corrupt = False

    def observed(
        capture: InventoryCapture,
        *,
        timestamp: str,
        author_or_agent: JsonObject,
        catalog: SchemaCatalog,
        dry_run: bool = False,
        analyzer_ids: tuple[str, ...] | None = None,
        analyzer_registry: InventoryRegistry | None = None,
    ) -> InventoryResult:
        """Record selection and alter preview only; return InventoryResult.

        capture (InventoryCapture), timestamp (str), author_or_agent (JsonObject),
        catalog (SchemaCatalog), dry_run (bool), analyzer_ids (tuple[str, ...] |
        None), and analyzer_registry (InventoryRegistry | None) pass unchanged.

        Return the real immutable result, except a requested injected-preview
        digest fault. Propagate pipeline errors; no writes occur in this seam.
        """
        calls.append((analyzer_ids, analyzer_registry is not None))
        result = real(
            capture,
            timestamp=timestamp,
            author_or_agent=author_or_agent,
            catalog=catalog,
            dry_run=dry_run,
            analyzer_ids=analyzer_ids,
            analyzer_registry=analyzer_registry,
        )
        return (
            replace(result, semantic_sha256="0" * 64)
            if corrupt and analyzer_registry is not None
            else result
        )

    monkeypatch.setattr(pipeline, "run_inventory", observed)
    result = invoke(
        service_io, "inventory", {"analyzer_ids": ["repository"]}, write=True
    )
    assert result.ok, result.findings
    assert service_io.writer_calls == 1 and result.artifacts[0].status == "created"
    assert service_io.disk.store.files[row.path] == row.content.encode("utf-8")
    assert calls == [(("repository",), True), (("repository",), False)]
    before = dict(service_io.disk.store.files)
    corrupt = True
    refused = invoke(
        service_io, "inventory", {"analyzer_ids": ["repository"]}, write=True
    )
    assert not refused.ok and refused.findings[0].code == "INVENTORY_INPUTS"
    assert calls[-2:] == [(("repository",), True), (("repository",), False)]
    assert service_io.writer_calls == 1 and service_io.disk.store.files == before


def test_ig6_changed_physical_source_refuses_captured_page(
    context: OperationContext, service_io: MemoryService
) -> None:
    """Reject changed bytes after capture; return None after freshness refusal.

    context (OperationContext), service_io (MemoryService) retain old bytes and
    change only the memory reader. Require OSError and no writer invocation.
    """
    selected = captured_source(context, service_io)
    service_io.disk.store.put("application/a.cs", b"two\n")
    with pytest.raises(OSError, match="Captured source is excessive or changed"):
        inspect_request(selected)
    assert service_io.writer_calls == 0


def test_ig7_captured_source_bound_refuses_before_physical_read(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Reject captured bytes beyond the reader bound; return None.

    context (OperationContext), service_io (MemoryService), and monkeypatch
    (pytest.MonkeyPatch) tighten public limits in memory. Require OSError before
    any physical-reader call or write, without weakening capture validation.
    """
    from drm_copilot_discovery import source_read_models

    selected = captured_source(context, service_io)
    reads: list[str] = []

    def limits() -> SourceReadLimits:
        """Return a valid three-byte per-file policy; no inputs or external effects."""
        return SourceReadLimits(file_bytes=3)

    def forbidden(path: str, *, limit: int) -> NoReturn:
        """Record path (str)/limit (int); raise AssertionError, no return or I/O."""
        reads.append(path)
        raise AssertionError(f"Captured bound must precede physical read: {limit}")

    monkeypatch.setattr(source_read_models, "SourceReadLimits", limits)
    monkeypatch.setattr(service_io.initialization, "read_bytes", forbidden)
    with pytest.raises(OSError, match="Captured source is excessive or changed"):
        inspect_request(selected)
    assert reads == [] and service_io.writer_calls == 0


def test_ig8_invalid_direct_source_request_refuses_before_read(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Reject invalid direct helper input before reading; return None.

    context (OperationContext), service_io (MemoryService), and monkeypatch
    (pytest.MonkeyPatch) isolate the direct-helper boundary in memory. Require
    SERVICE_SOURCE and no physical-reader call or publication.
    """
    selected = captured_source(context, service_io)
    selected.inputs["line_start"] = 0
    reads: list[str] = []

    def forbidden(path: str, *, limit: int) -> NoReturn:
        """Record path (str)/limit (int); raise AssertionError, no return or I/O."""
        reads.append(path)
        raise AssertionError(f"Invalid request reached reader with limit {limit}")

    monkeypatch.setattr(service_io.initialization, "read_bytes", forbidden)
    with pytest.raises(OperationFailure) as raised:
        inspect_request(selected)
    assert raised.value.findings[0].code == "SERVICE_SOURCE"
    assert reads == [] and service_io.writer_calls == 0


def test_ig9_other_operation_family_refuses_before_assessment(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Reject report routing through inspection; return None without assessment.

    context (OperationContext), service_io (MemoryService), and monkeypatch
    (pytest.MonkeyPatch) supply isolated memory fixtures and an assessment trap.
    Require SERVICE_OPERATION and no graph or writer calls.
    """
    from drm_copilot_discovery import validation

    context.request = replace(context.request, operation="coverage-report")
    calls: list[str] = []

    def forbidden(*args: object, **kwargs: object) -> NoReturn:
        """Reject args (object tuple)/kwargs (object dict) with AssertionError.

        Never return or perform I/O; record any forbidden assessment use.
        """
        calls.append("assessment")
        raise AssertionError("Wrong family must not assess the graph")

    monkeypatch.setattr(validation, "validate_snapshot", forbidden)
    with pytest.raises(OperationFailure) as raised:
        inspect_request(context)
    assert raised.value.findings[0].code == "SERVICE_OPERATION"
    assert calls == [] and service_io.writer_calls == 0
