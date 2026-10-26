"""Prove every host-gateway refusal exits 3 before dispatch without authority."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery.gateway_host import CONSUMED_LATCH_SUFFIX
from drm_copilot_discovery.operations import OperationFailure
from drm_copilot_discovery.service_contracts import ServiceRequest

from tests.discovery_runtime.test_gateway_host import (
    EXISTING_OUTPUT,
    INVOCATION,
    NEW_OUTPUT,
    HostCase,
    host_case,
    new_contract,
    request,
)
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.schemas.discovery.v2_control_test_support import OPAQUE_REFERENCE

if TYPE_CHECKING:
    from collections.abc import Callable

    from tests.discovery_runtime.test_service import MemoryService

Document = dict[str, object]


def edit(case: HostCase, name: str, **fields: object) -> None:
    """Rewrite the top-level fields of the protected record name in the partition."""
    path = f"{case.directory}/{name}"
    document: Document = json.loads(case.store.files[path])
    document.update(fields)
    case.store.files[path] = json.dumps(document)


def edit_authorization(case: HostCase, **fields: object) -> None:
    """Rewrite fields of the consumed grant record."""
    edit(case, f"authorizations/{OPAQUE_REFERENCE}.json", **fields)


def drop_latch(case: HostCase) -> None:
    """Remove the exclusive consumed latch of the grant."""
    del case.store.files[
        f"{case.directory}/authorizations/{OPAQUE_REFERENCE}.json{CONSUMED_LATCH_SUFFIX}"
    ]


def unsupported_capability(case: HostCase) -> None:
    """Mark the session capability as unsupported with a blocking finding."""
    path = f"{case.session}/capability-attestation.json"
    document: Document = json.loads(case.store.files[path])
    finding: Document = {
        "code": "DISCOVERY_ENFORCEMENT_UNAVAILABLE",
        "severity": "error",
        "artifact_path": None,
        "pointer": "/",
        "related_ids": [],
        "related_paths": [],
        "message": "Hooks are disabled.",
        "next_action": "Enable hooks.",
    }
    document.update(status="unsupported", findings=[finding])
    case.store.files[path] = json.dumps(document)


def change_scope(case: HostCase) -> None:
    """Rewrite a non-output input after preparation."""
    case.service.disk.store.put(
        "docs/migration/discovery/scope.yaml", b"schema_version: 2.0.0\nchanged: true\n"
    )


def add_input(case: HostCase) -> None:
    """Add a non-output input after preparation."""
    case.service.disk.store.put("proposals/new-input.md", b"# new\n")


def refused(case: HostCase, action: Callable[[], object], code: str) -> None:
    """Assert action raises the exit-3 failure with code and leaves no effect."""
    before = dict(case.service.disk.store.files)
    with pytest.raises(OperationFailure) as caught:
        action()
    assert caught.value.exit_code == 3
    assert [finding.code for finding in caught.value.findings] == [code]
    assert case.store.writes == [] and case.service.disk.store.files == before
    assert case.service.writer_calls == 0


AUTHORITY_CASES: list[tuple[Callable[[HostCase], None], str]] = [
    (
        lambda case: edit(case, "invocation.json", agent_id="agent-beta"),
        "another agent",
    ),
    (
        lambda case: edit(
            case,
            "invocation.json",
            state="prepared",
            agent_id=None,
            start_attestation_ref=None,
        ),
        "not been started",
    ),
    (
        lambda case: edit(case, "invocation.json", session_id="session-beta"),
        "another host identity",
    ),
    (
        lambda case: edit(
            case,
            "start-attestation.json",
            start_attestation_ref="start-0000000000000000000f",
        ),
        "not the one the invocation names",
    ),
    (
        lambda case: edit(case, "start-attestation.json", agent_id="agent-beta"),
        "another host identity",
    ),
    (unsupported_capability, "does not report support"),
    (
        lambda case: edit_authorization(case, state="issued", consumed_at=None),
        "not been consumed",
    ),
    (drop_latch, "not been consumed"),
    (
        lambda case: edit_authorization(case, operation="new-scenario"),
        "another operation",
    ),
    (
        lambda case: edit_authorization(case, invocation_ref="invocation-beta0"),
        "another invocation",
    ),
    (
        lambda case: edit(case, "baseline-result.json", ok=False, exit_code=1),
        "not an ok prepare-agent result",
    ),
]


@pytest.mark.parametrize("mutate,reason", AUTHORITY_CASES)
def test_every_protected_record_binding_refuses_before_dispatch(
    service_io: MemoryService,
    mutate: Callable[[HostCase], None],
    reason: str,
) -> None:
    """One drifted protected record yields SERVICE_AUTHORITY with its own reason."""
    case = host_case(service_io)
    mutate(case)

    refused(
        case,
        lambda: case.io.authorize(new_contract(case), baseline=case.capture()),
        "SERVICE_AUTHORITY",
    )


def test_unknown_authorization_reference_is_refused(service_io: MemoryService) -> None:
    """A reference that names no partition entry never reaches a record read."""
    case = host_case(service_io)

    refused(
        case,
        lambda: case.io.authorize(
            new_contract(case, reference="protected-zeta-0000000009"),
            baseline=case.capture(),
        ),
        "SERVICE_AUTHORITY",
    )


@pytest.mark.parametrize(
    "mode,invocation,reference",
    [
        ("structural", None, OPAQUE_REFERENCE),
        ("agent-output", INVOCATION, None),
    ],
)
def test_requests_without_host_markers_are_refused(
    service_io: MemoryService,
    mode: str,
    invocation: str | None,
    reference: str | None,
) -> None:
    """A structural request or one without an authorization reference is refused."""
    case = host_case(service_io)

    refused(
        case,
        lambda: case.io.authorize(
            new_contract(case, mode=mode, invocation=invocation, reference=reference),
            baseline=case.capture(),
        ),
        "SERVICE_AUTHORITY",
    )
    assert case.store.reads == []


def test_an_operation_outside_the_controlled_set_cannot_be_an_agent_request() -> None:
    """The request matrix refuses agent-output for a root-only operation first."""
    with pytest.raises(ValueError, match="mode"):
        request("init", {"system_id": "s"}, root="/workspace")


DRIFT_CASES: list[Callable[[HostCase], None]] = [change_scope, add_input]


@pytest.mark.parametrize("mutate", DRIFT_CASES)
def test_non_output_input_drift_is_refused_as_baseline_drift(
    service_io: MemoryService, mutate: Callable[[HostCase], None]
) -> None:
    """A changed or added non-output input after preparation yields SERVICE_BASELINE."""
    case = host_case(service_io)
    mutate(case)

    refused(
        case,
        lambda: case.io.authorize(new_contract(case), baseline=case.capture()),
        "SERVICE_BASELINE",
    )


def test_output_changes_are_not_drift(service_io: MemoryService) -> None:
    """Rewriting the granted outputs is the agent's work and never drift."""
    case = host_case(service_io)
    service_io.disk.store.put(NEW_OUTPUT, b"{}\n")
    service_io.disk.store.put(EXISTING_OUTPUT, b'{"id": "feature-beta-v2"}\n')

    authority = case.io.authorize(new_contract(case), baseline=case.capture())

    assert authority.principal == "host"


def test_read_outside_the_selected_paths_is_refused(service_io: MemoryService) -> None:
    """A read beyond the invocation scope is refused even inside a configured root."""
    case = host_case(service_io)
    case.authorization(
        "protected-read-000000000002",
        tool="read_discovery_source",
        operation="read-source",
    )

    refused(
        case,
        lambda: case.io.authorize(
            request(
                "read-source",
                {"read_operation": "list", "paths": ["verification"]},
                root=service_io.disk.root,
                reference="protected-read-000000000002",
            ),
            baseline=case.capture(),
        ),
        "SERVICE_AUTHORITY",
    )


@pytest.mark.parametrize(
    "name", ["invocation.json", "start-attestation.json", "baseline-result.json"]
)
def test_a_missing_protected_record_raises_an_io_failure(
    service_io: MemoryService, name: str
) -> None:
    """An absent record is an I/O refusal (exit 3 through the service)."""
    case = host_case(service_io)
    del case.store.files[f"{case.directory}/{name}"]

    with pytest.raises(OSError, match="unavailable"):
        case.io.authorize(new_contract(case), baseline=case.capture())
    assert case.store.writes == [] and case.service.writer_calls == 0


def test_another_invocation_reference_finds_no_partition(
    service_io: MemoryService,
) -> None:
    """A request for an invocation the session never prepared finds no record."""
    case = host_case(service_io)

    with pytest.raises(OSError, match="unavailable"):
        case.io.authorize(
            new_contract(case, invocation="invocation-beta"), baseline=case.capture()
        )
    assert INVOCATION not in "".join(case.store.writes)


def test_a_malformed_record_is_refused_by_kind(service_io: MemoryService) -> None:
    """Bytes that are not the expected document refuse before any binding is read."""
    case = host_case(service_io)
    case.store.files[f"{case.directory}/invocation.json"] = "{"

    refused(
        case,
        lambda: case.io.authorize(new_contract(case), baseline=case.capture()),
        "SERVICE_AUTHORITY",
    )


def test_a_foreign_workspace_request_is_refused(service_io: MemoryService) -> None:
    """A request naming another workspace root is not bound to this composition."""
    case = host_case(service_io)

    refused(
        case,
        lambda: case.io.authorize(
            ServiceRequest(
                id="request",
                request_id="correlation",
                operation="new-contract",
                mode="agent-output",
                workspace_root=service_io.disk.root + "/other",
                profile_path=None,
                dry_run=False,
                write=False,
                format="json",
                inputs=new_contract(case).inputs,
                invocation_ref=INVOCATION,
                authorization_ref=OPAQUE_REFERENCE,
            ),
            baseline=case.capture(),
        ),
        "SERVICE_AUTHORITY",
    )
