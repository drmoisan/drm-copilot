"""Keep context failures explicit without inventing reads or publication effects."""

from __future__ import annotations

from dataclasses import replace
from datetime import datetime
from typing import TYPE_CHECKING, NoReturn

import pytest
from drm_copilot_discovery import service
from drm_copilot_discovery.activation_store import ActivationStore
from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.configuration import DEFAULT_PROFILE, ConfigurationSelection
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service_bootstrap import bootstrap
from drm_copilot_discovery.snapshot_io import SnapshotIO

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
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.operations import OperationContext
    from drm_copilot_discovery.service_contracts import ServiceAuthority, ServiceRequest


def test_configured_uncaptured_read_refuses_before_physical_io(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject a physical file that has no configured capture authority.

    service_io (MemoryService) supplies isolated files and observed read/write
    counters. monkeypatch (pytest.MonkeyPatch) replaces only dispatch. Seed one
    uncaptured memory file, then assert the real service retains its capture and
    typed refusal. Return None; no external I/O or service publication occurs.
    """
    service_io.disk.store.put("uncaptured.txt", b"not authorized by the capture")
    before = dict(service_io.disk.store.files)
    read_calls: list[tuple[str, int]] = []

    def read_uncaptured(selected: OperationContext) -> NoReturn:
        """Refuse a read outside selected (OperationContext)'s captured files.

        Append existing read observations to the local list. NoReturn: propagate
        OperationFailure; fail the test if bytes are returned. No new physical
        read or write occurs.
        """
        assert selected.baseline is not None
        assert "uncaptured.txt" not in selected.files
        read_calls.extend(service_io.disk.store.calls)
        selected.read("uncaptured.txt")
        pytest.fail("An uncaptured physical file must not become an authorized input")

    monkeypatch.setattr(service, "dispatch", read_uncaptured)
    result = invoke(service_io, "validate-all")
    assert result.exit_code == 2 and not result.ok
    assert tuple(finding.code for finding in result.findings) == ("SERVICE_INPUT",)
    assert result.input_manifest is not None and result.artifacts == ()
    assert read_calls and service_io.disk.store.calls == read_calls
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before


def test_required_read_none_contract_violation_refuses_fabricated_bytes(
    context: OperationContext,
    service_io: MemoryService,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Reject a required-read adapter that incorrectly returns no bytes.

    context (OperationContext) is the uncaptured bootstrap fixture; service_io
    (MemoryService) supplies its isolated file state and counters. monkeypatch
    (pytest.MonkeyPatch) replaces only SnapshotIO.read with the invalid return.
    Return None after asserting typed refusal and unchanged state; no external
    I/O occurs. Real required-read FileNotFoundError behavior remains unchanged.
    """
    before = dict(service_io.disk.store.files)
    read_calls = list(service_io.disk.store.calls)
    calls: list[tuple[str, int, bool]] = []

    def absent_bytes(
        reader: SnapshotIO, path: str, *, limit: int, required: bool = True
    ) -> None:
        """Return None deliberately, violating the required-byte adapter contract.

        reader (SnapshotIO) must be the fixture's instance; path (str), limit
        (int) and required (bool) are recorded unchanged as its requested path,
        byte ceiling and presence requirement. Append only that call tuple;
        perform no I/O.
        """
        assert reader is context.reads
        calls.append((path, limit, required))

    monkeypatch.setattr(SnapshotIO, "read", absent_bytes)
    with pytest.raises(OperationFailure, match="^SERVICE_INPUT$") as caught:
        context.read("missing.json")
    assert caught.value.exit_code == 2
    assert tuple(finding.code for finding in caught.value.findings) == (
        "SERVICE_INPUT",
    )
    assert calls == [("missing.json", context.limits.document_bytes, True)]
    assert context.reads.captured == () and context.observed_manifest is None
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before
    assert service_io.disk.store.calls == read_calls


def test_naive_trusted_clock_refuses_before_capture_or_publication(
    service_io: MemoryService,
) -> None:
    """Reject a trusted clock value that omits its time zone.

    service_io (MemoryService) supplies isolated provider state and counters.
    Supply a naive datetime through the clock port and assert SERVICE_CLOCK
    before capture. Return None; no file mutation, publication or external I/O.
    """
    before = dict(service_io.disk.store.files)
    read_calls = list(service_io.disk.store.calls)
    request = bounded_object(
        {
            "$schema": "urn:drm-copilot:discovery:2.0.0:service-request",
            "schema_version": "2.0.0",
            "artifact_kind": "service-request",
            "id": "request",
            "request_id": "correlation",
            "operation": "validate-all",
            "mode": "structural",
            "workspace_root": service_io.disk.root,
            "profile_path": None,
            "dry_run": False,
            "write": False,
            "format": "json",
            "inputs": {},
            "invocation_ref": None,
            "authorization_ref": None,
        },
        limits=ParseLimits(),
    )
    result = service.execute(
        request,
        io=service_io,
        repository_reader=service_io.repository,
        clock=lambda: datetime(2026, 10, 21),
        analyzer_registry=InstalledInventoryRegistry(),
    )
    assert result.exit_code == 3 and not result.ok
    assert tuple(finding.code for finding in result.findings) == ("SERVICE_CLOCK",)
    assert result.runtime == service_io.runtime_identity()
    assert result.input_manifest is None and result.artifacts == ()
    assert service_io.authorization_calls == 1 and service_io.writer_calls == 0
    assert service_io.disk.store.calls == read_calls
    assert service_io.disk.store.files == before


def test_missing_activation_profile_refuses_without_graph_authority(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject activation that does not select a configured profile.

    service_io (MemoryService) supplies isolated provider state. monkeypatch
    (pytest.MonkeyPatch) replaces selection with an inactive result. Return None
    after asserting SERVICE_PROFILE and no invented capture or write authority;
    preserve all memory files and perform no external I/O.
    """
    before = dict(service_io.disk.store.files)
    read_calls = list(service_io.disk.store.calls)
    selections: list[tuple[str | None, bool]] = []

    def select_without_profile(
        store: ActivationStore,
        *,
        profile_path: str | None = None,
        controlled: bool = False,
    ) -> ConfigurationSelection:
        """Return an inactive ConfigurationSelection without reading a profile.

        store (ActivationStore) must be the fixture's selector. profile_path
        (str | None) and controlled (bool) record the caller's profile override
        and protected-selection requirement. Append only these arguments;
        perform no reads or writes.
        """
        assert store is service_io.activation
        selections.append((profile_path, controlled))
        return ConfigurationSelection(state="inactive")

    monkeypatch.setattr(ActivationStore, "select", select_without_profile)
    result = invoke(service_io, "validate-all")
    assert result.exit_code == 2 and not result.ok
    assert tuple(finding.code for finding in result.findings) == ("SERVICE_PROFILE",)
    assert selections == [(None, True)] and service_io.authorization_calls == 1
    assert result.input_manifest is None and result.artifacts == ()
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before
    assert service_io.disk.store.calls == read_calls


def test_profile_change_between_selection_and_capture_refuses_publication(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject profile-byte drift between trusted selection and capture.

    service_io (MemoryService) supplies isolated files. monkeypatch
    (pytest.MonkeyPatch) wraps selection to append a newline to the memory
    profile after selection. Return None after asserting SERVICE_CAPTURE and
    that only this deliberate fake edit occurred; no writer or external I/O.
    """
    before = dict(service_io.disk.store.files)
    select = ActivationStore.select
    changed_profile = before[DEFAULT_PROFILE] + b"\n"

    def select_then_change_profile(
        store: ActivationStore,
        *,
        profile_path: str | None = None,
        controlled: bool = False,
    ) -> ConfigurationSelection:
        """Return the original ConfigurationSelection after memory profile drift.

        store (ActivationStore), profile_path (str | None) and controlled (bool)
        are forwarded unchanged to trusted selection. Then replace only the
        in-memory profile bytes. Propagate selection errors; no external I/O.
        """
        selected = select(store, profile_path=profile_path, controlled=controlled)
        assert selected.profile_bytes == before[DEFAULT_PROFILE]
        service_io.disk.store.files[DEFAULT_PROFILE] = changed_profile
        return selected

    monkeypatch.setattr(ActivationStore, "select", select_then_change_profile)
    result = invoke(service_io, "validate-all")
    assert result.exit_code == 3 and not result.ok
    assert tuple(finding.code for finding in result.findings) == ("SERVICE_CAPTURE",)
    assert result.input_manifest is None and result.artifacts == ()
    assert service_io.authorization_calls == 1 and service_io.writer_calls == 0
    assert service_io.disk.store.files == {**before, DEFAULT_PROFILE: changed_profile}


def test_changed_reauthorization_actor_refuses_dispatch_and_writes(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Reject a different authenticated actor after capture.

    service_io (MemoryService) supplies isolated state and authorization counts.
    monkeypatch (pytest.MonkeyPatch) changes the second authorization's actor
    and installs a dispatch refusal observer. Return None after asserting
    SERVICE_AUTHORITY and no dispatch, file writes or external I/O.
    """
    before = dict(service_io.disk.store.files)
    authorize = MemoryService.authorize

    def changed_actor(
        provider: MemoryService,
        request: ServiceRequest,
        *,
        baseline: CapturedWorkspace | None,
    ) -> ServiceAuthority:
        """Return ServiceAuthority with a different actor only after capture.

        provider (MemoryService) and request (ServiceRequest) are forwarded to
        memory authorization; baseline (CapturedWorkspace | None) distinguishes
        the post-capture call. Preserve its authorization counter increment;
        do not write files or perform external I/O.
        """
        authority = authorize(provider, request, baseline=baseline)
        # A new identity after capture cannot inherit the original actor's authority.
        if baseline is not None:
            return replace(authority, author_or_agent="different-operator")
        return authority

    def reject_dispatch(selected: OperationContext) -> NoReturn:
        """Fail if selected (OperationContext) reaches dispatch after actor drift.

        Use its requested operation in the failure diagnostic. NoReturn: raise
        the pytest failure; perform no external I/O or file mutation.
        """
        pytest.fail(
            f"Changed authority reached dispatch for {selected.request.operation}"
        )

    monkeypatch.setattr(MemoryService, "authorize", changed_actor)
    monkeypatch.setattr(service, "dispatch", reject_dispatch)
    result = invoke(service_io, "validate-all")
    assert result.exit_code == 3 and not result.ok
    assert tuple(finding.code for finding in result.findings) == ("SERVICE_AUTHORITY",)
    assert service_io.authorization_calls == 2 and service_io.writer_calls == 0
    assert result.input_manifest is None and result.artifacts == ()
    assert service_io.disk.store.files == before


def test_bootstrap_rejects_wrong_operation_family_without_effects(
    context: OperationContext, service_io: MemoryService
) -> None:
    """Reject an operation that belongs outside the bootstrap family.

    context (OperationContext) is the profile-request fixture; service_io
    (MemoryService) supplies the same isolated files and observed calls. Return
    None after asserting SERVICE_OPERATION, no captured bytes and no reads or
    writes. No external I/O occurs.
    """
    before = dict(service_io.disk.store.files)
    read_calls = list(service_io.disk.store.calls)
    with pytest.raises(OperationFailure, match="^SERVICE_OPERATION$") as caught:
        bootstrap(context)
    assert caught.value.exit_code == 2
    assert tuple(finding.code for finding in caught.value.findings) == (
        "SERVICE_OPERATION",
    )
    assert context.reads.captured == () and context.observed_manifest is None
    assert service_io.writer_calls == 0 and service_io.disk.store.files == before
    assert service_io.disk.store.calls == read_calls
