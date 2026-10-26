"""Prove the gateway option table admits only a complete host identity."""

from __future__ import annotations

import io
import json
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import gateway
from drm_copilot_discovery.activation_store import ActivationStore
from drm_copilot_discovery.gateway_host import (
    HostPrincipal,
    HostServiceIO,
    InstalledHostStore,
    installed_host_io,
)

from tests.discovery_runtime.gateway_host_test_support import (
    AGENT,
    FIXTURE,
    HOST,
    ROLE,
    SESSION,
    host_case,
    no_repository,
)
from tests.discovery_runtime.gateway_test_support import REQUEST
from tests.discovery_runtime.test_gateway_factory import FactoryCase
from tests.discovery_runtime.test_gateway_factory import (
    config_catalog as config_catalog,
)
from tests.discovery_runtime.test_gateway_factory import (
    factory_case as factory_case,
)
from tests.discovery_runtime.test_service import (
    initialization_catalog as initialization_catalog,
)
from tests.discovery_runtime.test_service import (
    initialization_templates as initialization_templates,
)
from tests.discovery_runtime.test_service import service_io as service_io
from tests.discovery_runtime.test_service import service_plan as service_plan

if TYPE_CHECKING:
    from tests.discovery_runtime.test_service import MemoryService


def test_installed_host_io_composes_the_real_store_for_the_principal(
    factory_case: FactoryCase,
) -> None:
    """The installed host composition reuses the canonical state location."""
    case = factory_case

    host = installed_host_io(
        case.root.as_posix(),
        None,
        session_id=SESSION,
        host_name=HOST,
        agent_id=AGENT,
        agent_role=ROLE,
    )

    assert isinstance(host.activation, ActivationStore)
    assert host.activation.location.workspace == case.location.workspace
    assert host.principal == HostPrincipal(
        host=HOST, session_id=SESSION, agent_id=AGENT, role=ROLE
    )
    assert isinstance(host.store, InstalledHostStore)
    assert (case.root, True) in case.resolutions and not case.effects
    with pytest.raises(PermissionError):
        host.activation.authorize_root()
    host.activation.invalidate_authority()


def test_installed_host_store_reads_committed_files_and_reports_absence() -> None:
    """The filesystem store seam returns text, listings and existence without writes."""
    store = InstalledHostStore()
    fixtures = FIXTURE.parent

    assert store.read_text(FIXTURE.as_posix()) is not None
    assert store.read_text((fixtures / "absent.json").as_posix()) is None
    assert "controlled-operations.json" in store.list_entries(fixtures.as_posix())
    assert store.list_entries((fixtures / "absent").as_posix()) == ()
    assert store.exists(FIXTURE.as_posix()) is True
    assert store.exists((fixtures / "absent.json").as_posix()) is False


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
