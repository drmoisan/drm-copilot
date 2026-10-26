"""Prove the host-principal gateway over memory stores: options, composition, writer."""

from __future__ import annotations

import io
import json
from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import gateway
from drm_copilot_discovery.agent_output import required_output_digest
from drm_copilot_discovery.configuration import DEFAULT_PROFILE
from drm_copilot_discovery.gateway_host import (
    CONSUMED_LATCH_SUFFIX,
    HostPrincipal,
    HostServiceIO,
    invocation_directory,
    partition_name,
    session_directory,
)
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.mutation_io import GuardedMutationWriter, capture_workspace
from drm_copilot_discovery.path_models import WriteGrant
from drm_copilot_discovery.report_models import bounded_object
from drm_copilot_discovery.service_contracts import ServiceAuthority, ServiceRequest
from drm_copilot_discovery.service_request_rules import CONTROLLED_OPERATIONS

from tests.discovery_runtime.gateway_test_support import REQUEST
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


def test_partition_paths_follow_the_host_digest_layout(
    service_io: MemoryService,
) -> None:
    """Session and invocation partitions are the sha256 of the correlation ids."""
    location = service_io.configuration.location

    assert partition_name(SESSION) == sha256(SESSION.encode()).hexdigest()
    assert session_directory(location, SESSION) == (
        f"{location.directory}/sessions/{partition_name(SESSION)}"
    )
    assert invocation_directory(location, SESSION, INVOCATION) == (
        f"{session_directory(location, SESSION)}/invocations/"
        f"{partition_name(INVOCATION)}"
    )


def test_controlled_operations_equal_the_pinned_fixture() -> None:
    """The Python controlled set is the fixture both runtimes assert against."""
    fixture = json.loads(FIXTURE.read_text(encoding="utf-8"))

    assert sorted(CONTROLLED_OPERATIONS) == fixture["controlled_operations"]


def test_host_authority_binds_invocation_grants_and_pinned_baseline(
    service_io: MemoryService,
) -> None:
    """A verified request yields a host authority bound to the prepared baseline."""
    case = host_case(service_io)
    # The agent has since created the new output and rewritten the existing one.
    service_io.disk.store.put(NEW_OUTPUT, b'{"id": "feature-alpha"}\n')
    service_io.disk.store.put(EXISTING_OUTPUT, b'{"id": "feature-beta-v2"}\n')
    before = dict(service_io.disk.store.files)

    authority = case.io.authorize(new_contract(case), baseline=case.capture())

    assert authority.principal == "host" and authority.author_or_agent == AGENT
    assert authority.invocation is not None
    assert authority.invocation.invocation_id == INVOCATION
    assert authority.invocation.role == ROLE
    assert authority.invocation.selected_ids == ("feature-alpha",)
    assert authority.grants == (
        WriteGrant(
            artifact_kind="feature-contract",
            artifact_id="feature-alpha",
            path=NEW_OUTPUT,
        ),
        WriteGrant(
            artifact_kind="feature-contract",
            artifact_id="feature-beta",
            path=EXISTING_OUTPUT,
        ),
    )
    baseline_files = {
        f.path: f.content for f in authority.invocation.baseline.manifest.files
    }
    assert NEW_OUTPUT not in baseline_files
    assert baseline_files[EXISTING_OUTPUT] == EXISTING_BYTES
    assert authority.read_selection is None
    assert case.store.writes == [] and service_io.disk.store.files == before
    assert service_io.writer_calls == 0


def test_authorize_before_capture_uses_its_own_bound_capture(
    service_io: MemoryService,
) -> None:
    """Without a service capture the host IO captures through the same ports."""
    case = host_case(service_io)

    authority = case.io.authorize(new_contract(case), baseline=None)

    assert authority.principal == "host" and authority.invocation is not None
    assert {f.path for f in authority.invocation.baseline.manifest.files} >= {
        DEFAULT_PROFILE,
        EXISTING_OUTPUT,
    }
    assert case.store.writes == []


def test_read_source_authority_is_bounded_by_the_selected_paths(
    service_io: MemoryService,
) -> None:
    """A read inside the invocation's selected paths yields exact read grants."""
    case = host_case(service_io)
    case.authorization(
        READ_REFERENCE, tool="read_discovery_source", operation="read-source"
    )

    authority = case.io.authorize(
        request(
            "read-source",
            {"read_operation": "read", "paths": [SOURCE]},
            root=service_io.disk.root,
            reference=READ_REFERENCE,
        ),
        baseline=case.capture(),
    )

    assert authority.principal == "host" and authority.read_selection is not None
    assert [grant.path for grant in authority.read_selection.grants] == [SOURCE]
    assert authority.read_selection.grants[0].directory is False


def test_finalize_authority_carries_every_required_output_grant(
    service_io: MemoryService,
) -> None:
    """finalize-agent is admitted under host with the invocation's grants."""
    case = host_case(service_io)
    case.authorization(
        FINALIZE_REFERENCE, tool="finalize_discovery_agent", operation="finalize-agent"
    )

    authority = case.io.authorize(
        request(
            "finalize-agent", root=service_io.disk.root, reference=FINALIZE_REFERENCE
        ),
        baseline=case.capture(),
    )

    assert authority.principal == "host" and len(authority.grants) == 2
    assert authority.invocation is not None
    assert authority.invocation.required_outputs["invocation_id"] == INVOCATION


def test_writer_is_issued_only_for_the_verified_host_authority(
    service_io: MemoryService,
) -> None:
    """The writer binds the host principal, agent and a verified invocation."""
    case = host_case(service_io)
    baseline = case.capture()
    authority = case.io.authorize(new_contract(case), baseline=baseline)

    writer = case.io.writer(baseline, authority=authority)

    assert isinstance(writer, GuardedMutationWriter)
    local = ServiceAuthority(
        principal="local-user",
        author_or_agent=AGENT,
        invocation=None,
        grants=(),
        read_selection=None,
    )
    with pytest.raises(PermissionError):
        case.io.writer(baseline, authority=local)
    other_agent = ServiceAuthority(
        principal="host",
        author_or_agent="agent-beta",
        invocation=authority.invocation,
        grants=authority.grants,
        read_selection=None,
    )
    with pytest.raises(PermissionError):
        case.io.writer(baseline, authority=other_agent)
    fresh = HostServiceIO(
        activation=service_io.activation,
        repository=service_io.repository,
        principal=case.io.principal,
        store=case.store,
        runtime_identity=service_io.runtime_identity,
    )
    with pytest.raises(PermissionError):
        fresh.writer(baseline, authority=authority)
    assert case.store.writes == [] and service_io.writer_calls == 0


def test_capability_observation_is_never_reported_for_a_host(
    service_io: MemoryService,
) -> None:
    """Doctor is not a host operation, so the host IO observes no capability."""
    case = host_case(service_io)

    assert case.io.capability_observation() is None
    assert case.io.runtime_identity() == service_io.runtime_identity()


@pytest.mark.parametrize(
    "extra",
    [
        [],
        ["--repository-id", "consumer-repository"],
    ],
)
def test_main_composes_the_host_ports_from_the_complete_identity(
    service_io: MemoryService, monkeypatch: pytest.MonkeyPatch, extra: list[str]
) -> None:
    """`--principal host` with the four identity options composes the host ports."""
    case = host_case(service_io)
    recorded: list[dict[str, object]] = []

    def compose(root: str, repository: object, **identity: str) -> HostServiceIO:
        """Record the trusted options and return the memory host composition."""
        recorded.append({"root": root, "repository": repository, **identity})
        return case.io

    monkeypatch.setattr(gateway, "installed_repository", no_repository)
    monkeypatch.setattr(gateway, "installed_host_io", compose)
    output, errors = io.StringIO(), io.StringIO()
    arguments = [
        "--workspace-root",
        service_io.disk.root,
        "--principal",
        "host",
        "--author-id",
        AGENT,
        "--session-id",
        SESSION,
        "--host-name",
        HOST,
        "--agent-role",
        ROLE,
        *extra,
    ]

    code = gateway.main(
        arguments, stdin=io.BytesIO(REQUEST), stdout=output, stderr=errors
    )

    document = json.loads(output.getvalue())
    # The minimal doctor request is malformed for the service (exit 2); the host
    # composition was still created from the complete fixed identity.
    assert code == 2 and document["exit_code"] == 2
    assert recorded == [
        {
            "root": service_io.disk.root,
            "repository": None,
            "session_id": SESSION,
            "host_name": HOST,
            "agent_id": AGENT,
            "agent_role": ROLE,
        }
    ]


@pytest.mark.parametrize(
    "arguments",
    [
        ["--workspace-root", "/workspace", "--principal", "host"],
        [
            "--workspace-root",
            "/workspace",
            "--principal",
            "host",
            "--author-id",
            AGENT,
            "--session-id",
            SESSION,
            "--host-name",
            HOST,
        ],
        [
            "--workspace-root",
            "/workspace",
            "--principal",
            "host",
            "--session-id",
            SESSION,
            "--host-name",
            HOST,
            "--agent-role",
            ROLE,
        ],
        [
            "--workspace-root",
            "/workspace",
            "--principal",
            "local-user",
            "--session-id",
            SESSION,
        ],
        [
            "--workspace-root",
            "/workspace",
            "--principal",
            "local-user",
            "--host-name",
            HOST,
        ],
        [
            "--workspace-root",
            "/workspace",
            "--principal",
            "local-user",
            "--agent-role",
            ROLE,
        ],
        ["--workspace-root", "/workspace", "--principal", "host", "--author-id", ""],
        [
            "--workspace-root",
            "/workspace",
            "--principal",
            "host",
            "--author-id",
            AGENT,
            "--session-id",
            SESSION,
            "--host-name",
            HOST,
            "--agent-role",
            ROLE,
            "--repository-id",
            "r",
            "--extra",
            "x",
        ],
    ],
)
def test_main_refuses_incomplete_or_misplaced_host_identity(
    monkeypatch: pytest.MonkeyPatch, arguments: list[str]
) -> None:
    """An incomplete host identity or a host marker on local-user exits 2 before I/O."""
    calls: list[str] = []

    def record(root: str, repository_id: str | None) -> None:
        """Record a repository resolution that must never happen; return None."""
        calls.append(root)

    monkeypatch.setattr(gateway, "installed_repository", record)
    output, errors = io.StringIO(), io.StringIO()

    code = gateway.main(
        arguments, stdin=io.BytesIO(REQUEST), stdout=output, stderr=errors
    )

    assert code == 2 and json.loads(output.getvalue())["exit_code"] == 2
    assert calls == []


def test_local_user_options_still_compose_the_local_ports(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The local-user table is unchanged: author id travels, host options do not."""
    recorded: list[tuple[object, ...]] = []

    def compose(*arguments: object) -> object:
        """Record the local composition call and fail closed afterwards."""
        recorded.append(arguments)
        raise PermissionError("stop")

    monkeypatch.setattr(gateway, "installed_repository", no_repository)
    monkeypatch.setattr(gateway, "installed_local_io", compose)
    root = Path(gateway.__file__).resolve().anchor + "workspace"
    output, errors = io.StringIO(), io.StringIO()

    code = gateway.main(
        ["--workspace-root", root, "--principal", "local-user", "--author-id", "dan"],
        stdin=io.BytesIO(REQUEST),
        stdout=output,
        stderr=errors,
    )

    assert code == 3 and recorded == [(root, None, "local-user", "dan")]


def test_host_io_never_writes_the_protected_store(service_io: MemoryService) -> None:
    """Every store interaction of a successful authorization is a read."""
    case = host_case(service_io)

    case.io.authorize(new_contract(case), baseline=case.capture())

    assert case.store.writes == []
    assert all(
        path.startswith(case.directory) or path.startswith(case.session)
        for path in case.store.reads
    )
