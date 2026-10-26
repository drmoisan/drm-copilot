"""Share the memory host partition, store and request builders for the host suites."""

from __future__ import annotations

import json
from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.agent_output import required_output_digest
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.gateway_host import (
    CONSUMED_LATCH_SUFFIX,
    HostPrincipal,
    HostServiceIO,
    invocation_directory,
    session_directory,
)
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service_contracts import ServiceRequest

from tests.discovery_runtime.test_service import MemoryService, invoke
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan
from tests.schemas.discovery.v2_control_test_support import (
    OPAQUE_REFERENCE,
    START_ATTESTATION_REFERENCE,
    control_fixture,
)

if TYPE_CHECKING:
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.service_contracts import Mode, Operation

HOST, SESSION, AGENT = "codex", "session-alpha", "agent-alpha"
ROLE, INVOCATION = "legacy-parity-analyst", "invocation-alpha"
READ_REFERENCE = "protected-read-000000000002"
FINALIZE_REFERENCE = "protected-final-00000000003"
CONTRACTS = "docs/migration/discovery/feature-contracts"
NEW_OUTPUT = CONTRACTS + "/feature-alpha.json"
EXISTING_OUTPUT = CONTRACTS + "/feature-beta.json"
EXISTING_BYTES = b'{"artifact_kind": "feature-contract", "id": "feature-beta"}\n'
SOURCE = "application/orders.cs"
FIXTURE = (
    Path(__file__).resolve().parents[1]
    / "fixtures"
    / "discovery_host"
    / "controlled-operations.json"
)
Document = dict[str, object]


class MemoryHostStore:
    """Hold protected records in memory and record every attempted write."""

    def __init__(self) -> None:
        """Start with no records and no writes; return None."""
        self.files: dict[str, str] = {}
        self.writes: list[str] = []
        self.reads: list[str] = []

    def read_text(self, path: str) -> str | None:
        """Return the stored text at path or None; record the read."""
        self.reads.append(path)
        return self.files.get(path)

    def list_entries(self, directory: str) -> tuple[str, ...]:
        """Return the immediate entry names under directory."""
        prefix = directory + "/"
        return tuple(
            sorted(
                path[len(prefix) :]
                for path in self.files
                if path.startswith(prefix) and "/" not in path[len(prefix) :]
            )
        )

    def exists(self, path: str) -> bool:
        """Return whether path is stored."""
        return path in self.files


@dataclass
class HostCase:
    """Bind one memory service, its protected partition and the host composition."""

    service: MemoryService
    store: MemoryHostStore
    io: HostServiceIO
    directory: str
    session: str
    runtime: Document
    workspace: Document
    outputs: list[Document]

    def capture(self) -> CapturedWorkspace:
        """Capture the current memory workspace as the service would."""
        return capture_workspace(
            workspace_root=self.service.disk.root,
            profile_path=DEFAULT_PROFILE,
            metadata=self.service.disk.store.metadata,
            read_bytes=self.service.disk.store.read,
            catalog=self.service.initialization.catalog,
            repository=self.service.repository,
        )

    def put(self, name: str, document: Document) -> None:
        """Store document under the invocation partition as name."""
        self.store.files[f"{self.directory}/{name}"] = json.dumps(document)

    def authorization(
        self,
        reference: str,
        *,
        tool: str,
        operation: str,
        consumed: bool = True,
        latch: bool = True,
    ) -> Document:
        """Store and return a grant for operation under the authorizations partition."""
        document = control_fixture("tool-authorization")
        document.update(
            authorization_ref=reference,
            workspace=self.workspace,
            identity={
                "host": HOST,
                "session_id": SESSION,
                "agent_id": AGENT,
                "role": ROLE,
                "invocation_id": INVOCATION,
            },
            tool=tool,
            operation=operation,
            invocation_ref=INVOCATION,
            start_attestation_ref=START_ATTESTATION_REFERENCE,
            capability_ref=OPAQUE_REFERENCE,
            state="consumed" if consumed else "issued",
            consumed_at="2026-01-01T00:00:30Z" if consumed else None,
        )
        path = f"{self.directory}/authorizations/{reference}.json"
        self.store.files[path] = json.dumps(document)
        if latch:
            self.store.files[path + CONSUMED_LATCH_SUFFIX] = "{}\n"
        return document


def no_repository(root: str, repository_id: str | None) -> None:
    """Stand in for the installed repository binding; return None without I/O."""
    return None


def output_row(path: str, identifier: str, expected: str | None) -> Document:
    """Return one required-output row for a feature contract."""
    return {
        "artifact_kind": "feature-contract",
        "id": identifier,
        "path": path,
        "format": "json",
        "expected_sha256": expected,
    }


def request(
    operation: str,
    inputs: dict[str, object] | None = None,
    *,
    root: str,
    reference: str | None = OPAQUE_REFERENCE,
    invocation: str | None = INVOCATION,
    mode: str = "agent-output",
) -> ServiceRequest:
    """Return a host-shaped service request for operation over root."""
    return ServiceRequest(
        id="request",
        request_id="correlation",
        operation=cast("Operation", operation),
        mode=cast("Mode", mode),
        workspace_root=root,
        profile_path=None,
        dry_run=False,
        write=False,
        format="json",
        inputs=bounded_object(inputs or {}, limits=ParseLimits()),
        invocation_ref=invocation,
        authorization_ref=reference,
    )


def host_case(service: MemoryService) -> HostCase:
    """Prepare a real baseline, then write a coherent protected partition."""
    service.disk.store.put(EXISTING_OUTPUT, EXISTING_BYTES)
    service.disk.store.put(SOURCE, b"public class Order {}\n")
    service.repository.files[SOURCE] = service.disk.store.files[SOURCE]
    outputs: list[Document] = [
        output_row(NEW_OUTPUT, "feature-alpha", None),
        output_row(EXISTING_OUTPUT, "feature-beta", sha256(EXISTING_BYTES).hexdigest()),
    ]
    prepared = invoke(
        service,
        "prepare-agent",
        {
            "skill_id": "extract-feature-contract",
            "selected_ids": ["feature-alpha"],
            "paths": ["application"],
            "expected_outputs": outputs,
            "execution_context": "standalone",
            "complexity": "C2",
        },
    )
    assert prepared.ok, prepared.findings
    identity = service.runtime_identity()
    runtime: Document = {
        "package_version": identity.package_version,
        "schema_version": identity.schema_version,
        "build_sha256": identity.build_sha256,
        "policy_version": identity.policy_version,
        "policy_sha256": identity.policy_sha256,
    }
    workspace: Document = {
        "workspace_root": service.disk.root,
        "workspace_sha256": service.configuration.location.workspace_sha256,
        "profile_path": DEFAULT_PROFILE,
        "profile_sha256": sha256(service.disk.store.files[DEFAULT_PROFILE]).hexdigest(),
    }
    manifest = control_fixture("required-output-manifest")
    manifest.update(invocation_id=INVOCATION, workspace=workspace, role=ROLE)
    manifest["outputs"] = outputs
    manifest["manifest_sha256"] = required_output_digest(
        bounded_object(manifest, limits=ParseLimits())
    )
    invocation = control_fixture("discovery-invocation")
    invocation.update(
        workspace=workspace,
        host=HOST,
        session_id=SESSION,
        agent_id=AGENT,
        role=ROLE,
        skill_id="extract-feature-contract",
        operation="new-contract",
        gate_mode="agent-output",
        selected_ids=["feature-alpha"],
        selected_paths=["application"],
        runtime=runtime,
        required_outputs=manifest,
        state="started",
        start_attestation_ref=START_ATTESTATION_REFERENCE,
    )
    start = control_fixture("start-attestation")
    start.update(
        workspace=workspace, host=HOST, agent_id=AGENT, runtime=runtime, role=ROLE
    )
    capability = control_fixture("capability-attestation")
    capability.update(workspace=workspace, host=HOST, runtime=runtime)
    location = service.configuration.location
    store = MemoryHostStore()
    case = HostCase(
        service=service,
        store=store,
        io=HostServiceIO(
            activation=service.activation,
            repository=service.repository,
            principal=HostPrincipal(
                host=HOST, session_id=SESSION, agent_id=AGENT, role=ROLE
            ),
            store=store,
            runtime_identity=service.runtime_identity,
        ),
        directory=invocation_directory(location, SESSION, INVOCATION),
        session=session_directory(location, SESSION),
        runtime=runtime,
        workspace=workspace,
        outputs=outputs,
    )
    case.put("invocation.json", invocation)
    case.put("start-attestation.json", start)
    case.store.files[f"{case.directory}/baseline-result.json"] = prepared.to_json()
    case.store.files[f"{case.session}/capability-attestation.json"] = json.dumps(
        capability
    )
    case.authorization(
        OPAQUE_REFERENCE, tool="create_discovery_artifact", operation="new-contract"
    )
    return case


def new_contract(
    case: HostCase,
    *,
    reference: str | None = OPAQUE_REFERENCE,
    invocation: str | None = INVOCATION,
    mode: str = "agent-output",
) -> ServiceRequest:
    """Return the granted new-contract request of the case with optional overrides."""
    return request(
        "new-contract",
        {"feature_id": "feature-alpha", "name": "Feature Alpha"},
        root=case.service.disk.root,
        reference=reference,
        invocation=invocation,
        mode=mode,
    )
