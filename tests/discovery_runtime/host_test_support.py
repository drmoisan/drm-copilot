"""Share a memory host ServiceIO whose invocation is verified by construction."""

from __future__ import annotations

from datetime import datetime, timezone
from hashlib import sha256
from typing import TYPE_CHECKING, Literal

from drm_copilot_discovery.agent_output import InvocationContext, required_output_digest
from drm_copilot_discovery.analyzer.registry import InstalledInventoryRegistry
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.models import JsonObject, ParseLimits
from drm_copilot_discovery.mutation_io import capture_workspace
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service import execute
from drm_copilot_discovery.service_contracts import ServiceAuthority

if TYPE_CHECKING:
    from drm_copilot_discovery.activation_store import ActivationStore
    from drm_copilot_discovery.init_io import InitializationIO
    from drm_copilot_discovery.mutation_io import MutationWriter
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.path_models import WriteGrant
    from drm_copilot_discovery.service_contracts import (
        DiscoveryResult,
        RuntimeIdentity,
        ServiceRequest,
    )
    from drm_copilot_discovery.snapshot import DiscoverySnapshot
    from drm_copilot_discovery.source_read_models import ReadSelection

    from tests.discovery_runtime.test_service import MemoryService

AGENT_ID = "agent-alpha"
ROLE = "legacy-parity-analyst"
INVOCATION_ID = "invocation-alpha"
AUTHORIZATION_REF = "protected-alpha-00000001"


def output_rows(
    grants: tuple[WriteGrant, ...], baseline: DiscoverySnapshot | None = None
) -> tuple[JsonObject, ...]:
    """Project grants (tuple[WriteGrant, ...]) into required-output rows.

    baseline (DiscoverySnapshot | None) supplies the pinned prior digest of a
    granted path that already exists; absent paths and a None baseline pin None.
    """
    digests = (
        {file.path: file.sha256 for file in baseline.manifest.files}
        if baseline is not None
        else {}
    )
    return tuple(
        bounded_object(
            {
                "artifact_kind": grant.artifact_kind,
                "id": grant.artifact_id,
                "path": grant.path,
                "format": "yaml" if grant.path.endswith((".yaml", ".yml")) else "json",
                "expected_sha256": digests.get(grant.path),
            },
            limits=ParseLimits(),
        )
        for grant in grants
    )


class MemoryHostService:
    """Bind a verified host invocation to the memory service's real ports.

    The wrapped MemoryService supplies capture, activation and the guarded
    memory writer. authorize returns a host authority whose InvocationContext
    is the capture taken at construction (the prepared state); tests mutate the
    principal, grants, invocation or selection to model each refusal. No disk,
    network or native authority is involved.
    """

    def __init__(
        self,
        service: MemoryService,
        *,
        grants: tuple[WriteGrant, ...] = (),
        agent_id: str = AGENT_ID,
        role: str = ROLE,
        invocation_id: str = INVOCATION_ID,
        review_mode: str | None = None,
    ) -> None:
        """Capture the prepared baseline and build the verified invocation context.

        review_mode (str | None) is the reviewer's requested gate mode; existing
        granted paths pin their captured digest as the row's expected_sha256.
        """
        self.service, self.grants = service, grants
        self.agent_id, self.role = agent_id, role
        self.principal: Literal["local-user", "host"] = "host"
        self.selection: ReadSelection | None = None
        self.authorization_calls = 0
        captured = capture_workspace(
            workspace_root=service.disk.root,
            profile_path=DEFAULT_PROFILE,
            metadata=service.disk.store.metadata,
            read_bytes=service.disk.store.read,
            catalog=service.initialization.catalog,
            repository=service.repository,
        )
        workspace = bounded_object(
            {
                "workspace_root": service.disk.root,
                "workspace_sha256": service.configuration.location.workspace_sha256,
                "profile_path": DEFAULT_PROFILE,
                "profile_sha256": sha256(
                    service.disk.store.files[DEFAULT_PROFILE]
                ).hexdigest(),
            },
            limits=ParseLimits(),
        )
        manifest: dict[str, object] = {
            "$schema": "urn:drm-copilot:discovery:2.0.0:required-output-manifest",
            "schema_version": "2.0.0",
            "artifact_kind": "required-output-manifest",
            "id": "required-outputs-alpha",
            "invocation_id": invocation_id,
            "workspace": workspace,
            "role": role,
            "outputs": output_rows(grants, captured.snapshot),
            "manifest_sha256": "0" * 64,
        }
        document = bounded_object(manifest, limits=ParseLimits())
        manifest["manifest_sha256"] = required_output_digest(document)
        self.invocation: InvocationContext | None = InvocationContext(
            baseline=captured.snapshot,
            role=role,
            invocation_id=invocation_id,
            workspace=workspace,
            required_outputs=bounded_object(manifest, limits=ParseLimits()),
            selected_ids=tuple(grant.artifact_id for grant in grants),
            review_mode=review_mode,
        )

    @property
    def initialization(self) -> InitializationIO:
        """Return the wrapped service's bound initialization ports."""
        return self.service.initialization

    @property
    def activation(self) -> ActivationStore:
        """Return the wrapped service's activation store."""
        return self.service.activation

    @property
    def writer_calls(self) -> int:
        """Return how many guarded writers the wrapped service issued."""
        return self.service.writer_calls

    def runtime_identity(self) -> RuntimeIdentity:
        """Return the wrapped service's synthetic verified identity."""
        return self.service.runtime_identity()

    def authorize(
        self, request: ServiceRequest, *, baseline: CapturedWorkspace | None
    ) -> ServiceAuthority:
        """Return the preset host authority for any request; count the call."""
        self.authorization_calls += 1
        return ServiceAuthority(
            principal=self.principal,
            author_or_agent=self.agent_id,
            invocation=self.invocation,
            grants=self.grants,
            read_selection=self.selection,
        )

    def writer(
        self, baseline: CapturedWorkspace, *, authority: ServiceAuthority
    ) -> MutationWriter:
        """Return the wrapped service's guarded memory writer."""
        return self.service.writer(baseline, authority=authority)


def invoke_host(
    host: MemoryHostService,
    operation: str,
    inputs: object = None,
    **fields: object,
) -> DiscoveryResult:
    """Execute operation as an agent-output host request through the real service.

    The request names the host's invocation and a consumed authorization unless
    fields override them; the deterministic clock and registry match invoke().
    """
    request: dict[str, object] = {
        "$schema": "urn:drm-copilot:discovery:2.0.0:service-request",
        "schema_version": "2.0.0",
        "artifact_kind": "service-request",
        "id": "request",
        "request_id": "correlation",
        "operation": operation,
        "mode": "agent-output",
        "workspace_root": host.service.disk.root,
        "profile_path": None,
        "dry_run": False,
        "write": False,
        "format": "json",
        "inputs": inputs or {},
        "invocation_ref": INVOCATION_ID,
        "authorization_ref": AUTHORIZATION_REF,
    }
    request.update(fields)
    return execute(
        bounded_object(request, limits=ParseLimits()),
        io=host,
        repository_reader=host.service.repository,
        clock=lambda: datetime(2026, 10, 20, tzinfo=timezone.utc),
        analyzer_registry=InstalledInventoryRegistry(),
    )
