"""Prove host read grants are bounded by the invocation scope and resolved target."""

from __future__ import annotations

from dataclasses import replace
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.path_models import PathPolicyError

from tests.discovery_runtime.gateway_host_test_support import (
    READ_REFERENCE,
    SOURCE,
    HostCase,
    host_case,
    request,
)
from tests.discovery_runtime.test_gateway_host_refusals import edit, refused
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan

if TYPE_CHECKING:
    from drm_copilot_discovery.service_contracts import ServiceRequest

    from tests.discovery_runtime.test_service import MemoryService


def granted_read(case: HostCase, path: str, operation: str = "list") -> ServiceRequest:
    """Issue the read grant of the case and return the read-source request for path."""
    case.authorization(
        READ_REFERENCE, tool="read_discovery_source", operation="read-source"
    )
    return request(
        "read-source",
        {"read_operation": operation, "paths": [path]},
        root=case.service.disk.root,
        reference=READ_REFERENCE,
    )


def test_read_outside_the_selected_paths_is_refused(service_io: MemoryService) -> None:
    """A read beyond the invocation scope is refused even inside a configured root."""
    case = host_case(service_io)
    read = granted_read(case, "verification")

    refused(
        case,
        lambda: case.io.authorize(read, baseline=case.capture()),
        "SERVICE_AUTHORITY",
        spent=READ_REFERENCE,
    )


def test_read_outside_the_configured_input_scope_is_refused(
    service_io: MemoryService,
) -> None:
    """A selected path outside the profile's configured roots still cannot be read."""
    case = host_case(service_io)
    read = granted_read(case, "secrets/key.txt")
    edit(case, "invocation.json", selected_paths=["application", "secrets"])

    refused(
        case,
        lambda: case.io.authorize(read, baseline=case.capture()),
        "SERVICE_AUTHORITY",
        spent=READ_REFERENCE,
    )


def test_a_symlinked_read_inside_the_selection_is_refused(
    service_io: MemoryService,
) -> None:
    """A selected, configured source whose leaf is a symlink is refused, never followed.

    The injected metadata marks the source leaf as a symlink resolving to another
    selected path inside the configured input scope. The workspace capture that
    follows the accepted grant refuses the link, so no read grant and no writer
    exist; the gateway's own observation check behind the capture is proved
    directly in test_gateway_host_reads.py.
    """
    case = host_case(service_io)
    read = granted_read(case, SOURCE, operation="read")
    entries = service_io.disk.store.metadata.entries
    entries[SOURCE] = replace(
        entries[SOURCE],
        kind="symlink",
        resolved_path=f"{service_io.disk.root}/application/other.cs",
    )

    with pytest.raises(PathPolicyError, match="PATH_LINK"):
        case.io.authorize(read, baseline=None)

    assert case.store.writes == [case.used_latch(READ_REFERENCE)]
    assert case.service.writer_calls == 0


def test_a_resolved_target_outside_the_selection_is_refused(
    service_io: MemoryService,
) -> None:
    """A selected source whose metadata resolves outside the selection is refused.

    The leaf resolves to a path under another root: the capture refuses the alias
    before any read grant exists, and the resolved-target check of
    test_gateway_host_reads.py stands behind it.
    """
    case = host_case(service_io)
    read = granted_read(case, SOURCE, operation="read")
    entries = service_io.disk.store.metadata.entries
    entries[SOURCE] = replace(
        entries[SOURCE], resolved_path=f"{service_io.disk.root}/verification/orders.cs"
    )

    with pytest.raises(PathPolicyError, match="PATH_ALIAS"):
        case.io.authorize(read, baseline=None)

    assert case.store.writes == [case.used_latch(READ_REFERENCE)]
    assert case.service.writer_calls == 0
