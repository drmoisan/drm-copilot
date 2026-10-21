"""Prove local gateway authority, capture and native wiring with memory-only seams."""

from __future__ import annotations

from dataclasses import replace
from pathlib import Path
from typing import TYPE_CHECKING

import pytest
from drm_copilot_discovery import gateway_local
from drm_copilot_discovery.agent_output import InvocationContext
from drm_copilot_discovery.gateway_local import LocalServiceIO
from drm_copilot_discovery.models import JsonObject
from drm_copilot_discovery.repository_reader import RepositoryFile, RepositoryIdentity
from drm_copilot_discovery.service_contracts import ServiceRuntimeError

from tests.discovery_runtime.gateway_test_support import MemoryProcess, memory_io
from tests.discovery_runtime.gateway_test_support import (
    fixed_deadline as fixed_deadline,
)
from tests.discovery_runtime.initialization_test_support import MemoryRepository
from tests.discovery_runtime.test_activation_store import ConfigurationCase
from tests.discovery_runtime.test_configuration import config_catalog as config_catalog
from tests.discovery_runtime.test_doctor import IDENTITY, doctor_request

if TYPE_CHECKING:
    from collections.abc import Callable

    from drm_copilot_discovery.activation_filesystem import RegistryLocation
    from drm_copilot_discovery.activation_store import ActivationStore
    from drm_copilot_discovery.catalog import SchemaCatalog
    from drm_copilot_discovery.mutation_plan import CapturedWorkspace
    from drm_copilot_discovery.repository_reader import RepositoryReader
    from drm_copilot_discovery.service_contracts import RuntimeIdentity


def test_local_ports_share_exact_readers_and_guard(
    config_catalog: SchemaCatalog,
) -> None:
    """Local composition retains one store and one explicitly selected repository.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    repository = MemoryRepository()
    case, local, _ = memory_io(config_catalog, repository=repository)

    assert local.activation is case.service
    assert local.initialization.repository is repository
    assert local.initialization.metadata is case.service.metadata
    assert local.initialization.read_bytes is case.service.read_bytes
    assert local.initialization.primitives is case.service.primitives
    assert local.runtime_identity() is IDENTITY
    assert not case.revocations and not case.registry.writes


def test_missing_identity_never_fabricates_runtime(
    config_catalog: SchemaCatalog,
) -> None:
    """A typed installed-provider failure passes through the local adapter unchanged.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)

    def unavailable() -> RuntimeIdentity:
        """Model a missing manifest without reading an actual installation."""
        raise ServiceRuntimeError(code="RUNTIME_UNAVAILABLE")

    local = LocalServiceIO(
        activation=case.service,
        repository=None,
        principal="local-user",
        author_id="test-user",
        identity=unavailable,
    )

    with pytest.raises(ServiceRuntimeError, match="RUNTIME_UNAVAILABLE"):
        local.runtime_identity()


def test_host_principal_is_never_converted_to_local_user(
    config_catalog: SchemaCatalog,
) -> None:
    """Explicit unavailable host authority fails before any workspace observation.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)

    with pytest.raises(PermissionError, match="host"):
        LocalServiceIO(
            activation=case.service,
            repository=None,
            principal="host",
            author_id="test-agent",
        )
    assert not case.registry.writes and not case.authorization_calls


@pytest.mark.parametrize(
    "marker",
    ["invocation", "authorization", "mode", "workspace", "prepare", "finalize"],
)
def test_request_markers_cannot_expand_local_authority(
    config_catalog: SchemaCatalog,
    marker: str,
) -> None:
    """Opaque references and a substituted root cannot acquire local permissions.
    config_catalog (SchemaCatalog): verified immutable schema fixture. marker (str):
    selected forbidden host-context marker. Returns None; memory-only effects;
    AssertionError on mismatch.
    """
    case, local, _ = memory_io(config_catalog)
    request = doctor_request(case)
    # Each otherwise valid request isolates a forbidden authority source or mode.
    if marker == "invocation":
        request = replace(request, invocation_ref="opaque-invocation-0001")
    elif marker == "authorization":
        request = replace(request, authorization_ref="opaque-authorization-0001")
    elif marker == "mode":
        request = replace(
            request,
            operation="inventory",
            mode="agent-output",
            invocation_ref="opaque-invocation-0001",
        )
    elif marker == "workspace":
        request = replace(request, workspace_root="/other-workspace")
    elif marker == "prepare":
        request = replace(
            request,
            operation="prepare-agent",
            inputs=JsonObject(
                (
                    ("skill_id", "analyst"),
                    ("selected_ids", ("feature",)),
                    ("paths", ("src",)),
                    (
                        "expected_outputs",
                        (
                            JsonObject(
                                (
                                    ("artifact_kind", "feature-contract"),
                                    ("id", "feature"),
                                    ("path", "docs/feature.json"),
                                    ("format", "json"),
                                    ("expected_sha256", None),
                                )
                            ),
                        ),
                    ),
                    ("execution_context", "standalone"),
                    ("complexity", "C1"),
                )
            ),
        )
    else:
        request = replace(
            request,
            operation="finalize-agent",
            mode="agent-output",
            invocation_ref="opaque-invocation-0001",
        )

    with pytest.raises(PermissionError, match="authority"):
        local.authorize(request, baseline=None)
    assert not case.registry.writes and not case.revocations


def test_cross_workspace_baseline_and_writer_are_rejected(
    config_catalog: SchemaCatalog,
) -> None:
    """Reject a foreign capture before authorization or mutation. config_catalog
    (SchemaCatalog): verified immutable schema fixture. Returns None; memory-only
    effects; AssertionError on mismatch.
    """
    case, local, baseline = memory_io(config_catalog)
    foreign = replace(baseline, workspace_root="/other-workspace")
    authority = local.authorize(doctor_request(case), baseline=baseline)

    with pytest.raises(PermissionError, match="authority"):
        local.authorize(doctor_request(case), baseline=foreign)
    with pytest.raises(PermissionError, match="authority"):
        local.writer(foreign, authority=authority)
    with pytest.raises(PermissionError, match="authority"):
        local.writer(
            baseline, authority=replace(authority, author_or_agent="other-user")
        )
    with pytest.raises(PermissionError, match="authority"):
        local.writer(baseline, authority=replace(authority, principal="host"))
    invocation = InvocationContext(
        baseline=baseline.snapshot,
        role="analyst",
        invocation_id="native-reference",
        workspace=JsonObject(()),
        required_outputs=JsonObject(()),
    )
    with pytest.raises(PermissionError, match="authority"):
        local.writer(baseline, authority=replace(authority, invocation=invocation))


def test_writer_recaptures_real_memory_state_and_invalidates(
    config_catalog: SchemaCatalog,
) -> None:
    """The local adapter forwards actual capture and revocation calls. config_catalog
    (SchemaCatalog): verified immutable schema fixture. Returns None; memory-only
    effects; AssertionError on mismatch.
    """
    case, local, baseline = memory_io(config_catalog)
    authority = local.authorize(doctor_request(case), baseline=baseline)

    writer = local.writer(baseline, authority=authority)
    observed = writer.capture()
    writer.invalidate_authority()

    assert observed == baseline and case.revocations == 1
    assert not authority.grants and authority.invocation is None
    assert not case.registry.writes


def test_read_selection_is_exact_and_profile_scoped(
    config_catalog: SchemaCatalog,
) -> None:
    """Explicit local reads receive only the requested configured file grant.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case, local, baseline = memory_io(config_catalog)
    path = baseline.snapshot.profile.artifacts["profile"]
    request = replace(
        doctor_request(case),
        operation="read-source",
        inputs=JsonObject((("read_operation", "read"), ("paths", (path,)))),
    )

    authority = local.authorize(request, baseline=baseline)

    assert authority.read_selection is not None
    assert authority.read_selection.allows(path)
    assert not authority.read_selection.allows("docs/other.json")
    assert not authority.grants


@pytest.mark.parametrize("mismatch", [False, True])
def test_inventory_writer_preserves_exact_pinned_selection(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
    mismatch: bool,
) -> None:
    """Inventory recapture uses the same reader and refuses unrelated extra objects.
    config_catalog (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. mismatch (bool):
    whether recapture returns a different selection. Returns None; memory-only effects;
    AssertionError on mismatch.
    """
    repository = MemoryRepository()
    case, local, baseline = memory_io(config_catalog, repository=repository)
    pin = RepositoryFile(
        repository=RepositoryIdentity(id="consumer-repository", revision="a" * 40),
        path="application/one.py",
        content=b"one",
    )
    pinned = replace(
        baseline, snapshot=replace(baseline.snapshot, repository_files=(pin,))
    )
    observed: list[RepositoryReader] = []

    def recapture(**values: object) -> CapturedWorkspace:
        """Return the unchanged unaugmented capture and record selected reader. values
        (object): captured keyword values for the read seam. Returns CapturedWorkspace;
        memory-only effects; AssertionError on mismatch.
        """
        assert values["repository"] is repository
        return baseline

    def augment(
        current: CapturedWorkspace, reader: RepositoryReader
    ) -> CapturedWorkspace:
        """Model only the accepted inventory source-pin transform. current
        (CapturedWorkspace): fresh captured workspace. reader (RepositoryReader): exact
        expected repository reader. Returns CapturedWorkspace; memory-only effects;
        AssertionError on mismatch.
        """
        assert current is baseline
        observed.append(reader)
        return baseline if mismatch else pinned

    monkeypatch.setattr(gateway_local, "capture_workspace", recapture)
    monkeypatch.setattr(
        "drm_copilot_discovery.analyzer.input_capture.pin_inventory_sources", augment
    )
    writer = local.writer(
        pinned, authority=local.authorize(doctor_request(case), baseline=pinned)
    )

    if mismatch:
        with pytest.raises(OSError, match="selection"):
            writer.capture()
    else:
        assert writer.capture() is pinned
    assert observed == [repository]


def test_extra_pins_require_the_bound_repository_reader(
    config_catalog: SchemaCatalog,
) -> None:
    """A missing reader cannot be replaced by a working-tree or caller source.
    config_catalog (SchemaCatalog): verified immutable schema fixture. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case, local, baseline = memory_io(config_catalog)
    pin = RepositoryFile(
        repository=RepositoryIdentity(id="consumer-repository", revision="a" * 40),
        path="application/one.py",
        content=b"one",
    )
    pinned = replace(
        baseline, snapshot=replace(baseline.snapshot, repository_files=(pin,))
    )
    writer = local.writer(
        pinned, authority=local.authorize(doctor_request(case), baseline=pinned)
    )

    with pytest.raises(OSError, match="unavailable"):
        writer.capture()


@pytest.mark.usefixtures("fixed_deadline")
@pytest.mark.parametrize(
    "content,code,pipe,valid",
    [
        (b"data", 0, True, True),
        (b"excess", 0, True, False),
        (b"", 1, True, False),
        (b"", 0, False, False),
        (b"", -2, True, False),
    ],
)
def test_fixed_git_runner_bounds_output_and_cleans_process(
    monkeypatch: pytest.MonkeyPatch,
    content: bytes,
    code: int,
    pipe: bool,
    valid: bool,
) -> None:
    """Fixed Git argv stays shell-free and strips inherited Git overrides. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. content (bytes):
    immutable input or simulated output bytes. code (int): selected fixed failure or
    simulated process status. pipe (bool): whether simulated stdout is available. valid
    (bool): whether the selected process outcome is accepted. Returns None; memory-only
    effects; AssertionError on mismatch.
    """
    process = MemoryProcess(content, code=code, pipe=pipe)
    recorded: list[dict[str, object]] = []
    monkeypatch.setenv("GIT_DIR", "untrusted-location")
    monkeypatch.setattr(
        "drm_copilot_discovery.gateway_local.subprocess.TimeoutExpired", TimeoutError
    )

    def which(name: str) -> str:
        """Resolve only the fixed trusted executable name in memory. name (str): fixed
        executable name to resolve. Returns str; memory-only effects; AssertionError on
        mismatch.
        """
        assert name == "git"
        return "/trusted/git"

    monkeypatch.setattr("drm_copilot_discovery.gateway_local.shutil.which", which)

    def start(argv: tuple[str, ...], **options: object) -> MemoryProcess:
        """Record arguments without starting a process. argv (tuple[str,
        ...]): fixed outer argument sequence. options (object): captured fixed keyword
        options. Returns MemoryProcess; memory-only effects; AssertionError on mismatch.
        """
        assert argv == ("/trusted/git", "--version")
        recorded.append(options)
        return process

    monkeypatch.setattr("drm_copilot_discovery.gateway_local.subprocess.Popen", start)
    # Only bounded successful output survives; every failure must still clean up.
    if valid:
        assert (
            gateway_local.run_local_git(("git", "--version"), output_limit=4) == content
        )
    else:
        with pytest.raises(OSError):
            gateway_local.run_local_git(("git", "--version"), output_limit=4)

    assert recorded[0]["shell"] is False
    assert "GIT_DIR" not in str(recorded[0]["env"])
    assert process.finished
    assert process.killed == (not pipe or len(content) > 4 or code == -2)


@pytest.mark.parametrize(
    "argv,limit,executable",
    [
        ((), 4, "/trusted/git"),
        (("other",), 4, "/trusted/git"),
        (("git",), 0, "/trusted/git"),
        (("git",), True, "/trusted/git"),
        (("git",), 4, None),
        (("git",), 4, "/trusted/git.cmd"),
        (("git",), 4, "/trusted/git.bat"),
    ],
)
def test_git_runner_rejects_unavailable_or_unbounded_selection(
    monkeypatch: pytest.MonkeyPatch,
    argv: tuple[str, ...],
    limit: int,
    executable: str | None,
) -> None:
    """No invalid runner selection reaches the process boundary. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. argv (tuple[str,
    ...]): fixed outer argument sequence. limit (int): positive read capacity in bytes.
    executable (str | None): simulated resolved Git path or absence. Returns None;
    memory-only effects; AssertionError on mismatch.
    """

    def which(name: str) -> str | None:
        """Return the selected installed-executable availability. name (str): fixed
        executable name to resolve. Returns str | None; memory-only effects;
        AssertionError on mismatch.
        """
        assert name == "git"
        return executable

    monkeypatch.setattr("drm_copilot_discovery.gateway_local.shutil.which", which)

    with pytest.raises(OSError, match="unavailable"):
        gateway_local.run_local_git(argv, output_limit=limit)


def test_installed_factory_wires_only_trusted_outer_host_values(
    config_catalog: SchemaCatalog,
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Compose real ports through patched native boundaries. config_catalog
    (SchemaCatalog): verified immutable schema fixture. monkeypatch
    (pytest.MonkeyPatch): test-local restoration of injected seams. Returns None;
    memory-only effects; AssertionError on mismatch.
    """
    case = ConfigurationCase(config_catalog)

    def resolve(self: Path, strict: bool = False) -> Path:
        """Preserve synthetic paths without I/O. strict (bool) requires the workspace
        to exist while state may be absent. Return Path; AssertionError on the wrong
        existence policy; memory-only effects.
        """
        assert strict == (self == Path(case.disk.root))
        return self

    def home(cls: type[Path]) -> Path:
        """Return deterministic user storage without accessing host settings."""
        return cls(case.location.directory).parent

    monkeypatch.setattr(Path, "resolve", resolve)
    monkeypatch.setattr(Path, "home", classmethod(home))
    monkeypatch.setattr(gateway_local, "load_catalog", lambda: config_catalog)

    def activate(
        *,
        location: RegistryLocation,
        catalog: SchemaCatalog,
        authorize_root: Callable[[], None],
        invalidate_authority: Callable[[], None],
    ) -> ActivationStore:
        """Check factory collaborators and return the isolated memory store. location
        (RegistryLocation): trusted host/workspace registry location. catalog
        (SchemaCatalog): verified immutable schema catalog. authorize_root (Callable[[],
        None]): explicit local-root authorization callback. invalidate_authority
        (Callable[[], None]): separate empty-authority P6 callback. Returns
        ActivationStore; memory-only effects; AssertionError on mismatch.
        """
        assert location.workspace == case.disk.root and catalog is config_catalog
        assert authorize_root is not invalidate_authority
        authorize_root()
        invalidate_authority()
        return case.service

    monkeypatch.setattr(
        "drm_copilot_discovery.gateway_local.ActivationStore.local", activate
    )
    monkeypatch.setenv("LOCALAPPDATA", "C:/state")

    local = gateway_local.installed_local_io(
        case.disk.root, None, "local-user", "test-user"
    )

    assert local.activation is case.service and not case.registry.writes
    with pytest.raises(PermissionError, match="unavailable"):
        gateway_local.installed_local_io(case.disk.root, None, "host", "test-agent")
    with pytest.raises(ValueError, match="absolute"):
        gateway_local.installed_local_io("relative", None, "local-user", "test-user")
