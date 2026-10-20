"""Check build staging and inert package metadata without files or processes."""

from __future__ import annotations

import stat
import sys
from contextlib import contextmanager
from importlib import import_module
from pathlib import Path
from types import SimpleNamespace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import build_identity as runtime_identity
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.resources import ResourceError
from drm_copilot_discovery.service_contracts import ServiceRuntimeError

if TYPE_CHECKING:
    from collections.abc import Generator, Iterator
    from os import stat_result

from scripts.dev_tools import build_discovery_runtime as build
from scripts.dev_tools import discovery_build_identity as identity
from tests.scripts.dev_tools.test_build_discovery_runtime import MemoryFileSystem


@pytest.fixture
def memory_build_metadata(
    mem_fs_path: Path, monkeypatch: pytest.MonkeyPatch
) -> dict[str, tuple[int, int]]:
    """Inject streaming memory metadata; Path and MonkeyPatch are local fixtures.

    Return mutable path-to-(mode,reparse-flags) overrides. No native metadata or
    processes are accessed; assertions/fixture errors propagate.
    """
    overrides: dict[str, tuple[int, int]] = {}

    def metadata(path: Path) -> stat_result:
        """Return fake stat_result for path (Path); only memory is read."""
        mode, flags = overrides.get(
            str(path), (stat.S_IFDIR if path.is_dir() else stat.S_IFREG, 0)
        )
        return cast(
            "stat_result", SimpleNamespace(st_mode=mode, st_file_attributes=flags)
        )

    @contextmanager
    def scanner(path: Path) -> Generator[Iterator[SimpleNamespace], None, None]:
        """Yield memory entries for path (Path); close generator without native I/O."""
        yield (SimpleNamespace(name=child.name) for child in path.iterdir())

    monkeypatch.setattr(runtime_identity, "lstat", metadata)
    monkeypatch.setattr(runtime_identity, "scandir", scanner)
    return overrides


@pytest.mark.parametrize("adapter", ("installed", "source"))
def test_streaming_limits_stop_at_first_excess_entry(
    adapter: str,
    mem_fs_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    memory_build_metadata: dict[str, tuple[int, int]],
) -> None:
    """adapter (str) selects a real walker; memory fixtures isolate scanner I/O.

    Return None; assert count rejection consumes exactly two entries and closes
    the scanner. No excess metadata is read and no native filesystem is used.
    """
    consumed: list[int] = []
    closed: list[bool] = []
    (mem_fs_path / identity.SOURCE_ROOT).mkdir(parents=True, exist_ok=True)

    def entries() -> Iterator[SimpleNamespace]:
        """Yield counted memory entries; return iterator, changing only local logs."""
        for index in range(10000):
            consumed.append(index)
            yield SimpleNamespace(name=f"source{index}.py")

    @contextmanager
    def scanner(path: Path) -> Generator[Iterator[SimpleNamespace], None, None]:
        """Yield entries for path (Path), recording closure even on a limit error."""
        try:
            yield entries()
        finally:
            closed.append(True)

    def root(anchor: str) -> Path:
        """Return memory package for anchor (str); no native reads or mutations."""
        return mem_fs_path

    monkeypatch.setattr(runtime_identity, "scandir", scanner)
    monkeypatch.setattr(runtime_identity, "files", root)
    with pytest.raises(ValueError, match="limits"):
        if adapter == "installed":
            runtime_identity.PackageBuildStore().paths(
                limits=ParseLimits(artifact_records=1)
            )
        else:
            identity.list_build_source_files(
                mem_fs_path, limits=ParseLimits(artifact_records=1)
            )
    assert consumed == [0, 1]
    assert closed == [True]


def test_metadata_uses_approved_parser_when_tomllib_is_unavailable(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """MonkeyPatch simulates the 3.10 import surface using the available TOML reader.

    Return None; assert real bounded metadata semantics without package installs,
    filesystem fixtures or persistent import changes. Assertion failures propagate.
    """
    reader = import_module("tomllib" if sys.version_info >= (3, 11) else "tomli")
    monkeypatch.setitem(sys.modules, "tomllib", None)
    monkeypatch.setitem(sys.modules, "tomli", reader)
    result = identity.package_metadata(
        MemoryFileSystem().content[identity.PROJECT_PATH]
    )
    assert result["name"] == "drm-copilot-discovery"
    assert result["python"] == ">=3.10,<4.0"


@pytest.mark.parametrize("operation", ("enumerate", "read", "source"))
def test_reparse_rejection_does_not_require_new_path_apis(
    operation: str,
    mem_fs_path: Path,
    monkeypatch: pytest.MonkeyPatch,
    memory_build_metadata: dict[str, tuple[int, int]],
) -> None:
    """operation (str), memory metadata and MonkeyPatch model older Path APIs.

    Return None; assert Windows reparse rejection despite unavailable junction/symlink
    convenience methods. Only local memory/import attributes change temporarily.
    """
    memory_build_metadata[str(mem_fs_path)] = (stat.S_IFDIR, 0x400)

    def root(anchor: str) -> Path:
        """Return fixed memory root for anchor (str), without I/O or mutations."""
        return mem_fs_path

    def unavailable(path: Path) -> bool:
        """Raise AttributeError for path (Path) to model an unavailable API; no I/O."""
        raise AttributeError("Unavailable older Path API")

    monkeypatch.setattr(runtime_identity, "files", root)
    with monkeypatch.context() as older:
        older.setattr(Path, "is_junction", unavailable, raising=False)
        older.setattr(Path, "is_symlink", unavailable, raising=False)
        with pytest.raises(ValueError, match="Linked"):
            if operation == "enumerate":
                runtime_identity.PackageBuildStore().paths(limits=ParseLimits())
            elif operation == "read":
                runtime_identity.PackageBuildStore().read_bytes("source.py", limit=10)
            else:
                identity.list_build_source_files(mem_fs_path)


@pytest.mark.parametrize("operation", ("enumerate", "read"))
def test_nonfilesystem_installation_fails_closed(
    operation: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """operation (str) and MonkeyPatch supply an unsupported resource provider.

    Return None; reject before enumeration/read without I/O or persistent changes.
    """

    def unsupported(anchor: str) -> Path:
        """Return invalid Path for anchor (str); no reads, errors or mutation."""
        return cast("Path", object())

    monkeypatch.setattr(runtime_identity, "files", unsupported)
    with pytest.raises(ValueError, match="Unsupported"):
        if operation == "enumerate":
            runtime_identity.PackageBuildStore().paths(limits=ParseLimits())
        else:
            runtime_identity.PackageBuildStore().read_bytes("source.py", limit=1)


def staged() -> MemoryFileSystem:
    """Return freshly resource-staged memory; no arguments, I/O or shared state."""
    filesystem = MemoryFileSystem()
    build.stage_resources(filesystem)
    return filesystem


def test_build_identity_stage_is_idempotent_and_check_never_writes() -> None:
    """Freeze source/resources in memory and verify stable identities, without I/O.

    Returns None; assertions may fail; only local test state changes.
    """
    filesystem = staged()
    first = identity.stage_build_identity(filesystem)
    writes = tuple(filesystem.writes)
    second = identity.stage_build_identity(filesystem)
    checked = identity.stage_build_identity(filesystem, check=True)
    assert first["build_manifest_changed"] is True
    assert (
        second["build_manifest_changed"] is checked["build_manifest_changed"] is False
    )
    assert tuple(filesystem.writes) == writes
    assert writes[-1] == identity.BUILD_MANIFEST_PATH
    assert first["build_sha256"] == checked["build_sha256"]
    assert first["policy_version"] == 2
    assert first["policy_sha256"] != first["build_sha256"]


@pytest.mark.parametrize(
    "state", ("absent", "stale", "changed-code", "changed-package")
)
def test_check_rejects_unverified_identity_without_writes(state: str) -> None:
    """state (str) controls stored bytes; read-only checks reject without I/O.

    Returns None; assertions may fail; only local test state changes.
    """
    filesystem = staged()
    if state != "absent":
        identity.stage_build_identity(filesystem)
    # Separate identity corruption from a legitimate changed source/declaration.
    if state == "stale":
        filesystem.content[identity.BUILD_MANIFEST_PATH] = b"{}"
    elif state == "changed-code":
        filesystem.content[f"{identity.SOURCE_ROOT}/__init__.py"] += b"# changed\n"
    elif state == "changed-package":
        filesystem.content[identity.PROJECT_PATH] = filesystem.content[
            identity.PROJECT_PATH
        ].replace(b">=6.0", b">=6.1")
    writes = tuple(filesystem.writes)
    with pytest.raises(ResourceError, match="missing or stale"):
        identity.stage_build_identity(filesystem, check=True)
    assert tuple(filesystem.writes) == writes


@pytest.mark.parametrize(
    "content",
    (
        b"\xff",
        b"[",
        b"",
        b"tool=1",
        b"[tool]\npoetry=1",
        b'[tool.poetry]\nname=1\nversion="2.0.0"\n[tool.poetry.dependencies]\npython="*"\n',
        b'[tool.poetry]\nname="x"\nversion="2.0.0"\n',
        b'[tool.poetry]\nname="x"\nversion="2.0.0"\n[tool.poetry.dependencies]\nx={git="secret"}',
        b'[tool.poetry]\nname="x"\nversion="2.0.0"\n[tool.poetry.dependencies]\nx="1"',
        b"." * 1025,
        b"x" * 65537,
    ),
    ids=(
        "utf8",
        "syntax",
        "empty",
        "tool",
        "poetry",
        "name",
        "dependencies",
        "executable",
        "python",
        "syntax-limit",
        "byte-limit",
    ),
)
def test_metadata_rejects_malformed_or_executable_declarations(content: bytes) -> None:
    """content (bytes) is rejected with fixed diagnostic and no dependency execution.

    Returns None; assertions may fail; only local test state changes.
    """
    with pytest.raises(ResourceError):
        identity.package_metadata(content)


def test_metadata_limits_and_exact_declared_requirements() -> None:
    """Retain package constraints exactly within bounded immutable values, no I/O.

    Returns None; assertions may fail; only local test state changes.
    """
    content = MemoryFileSystem().content[identity.PROJECT_PATH]
    result = identity.package_metadata(content)
    assert result["name"] == "drm-copilot-discovery"
    assert result["python"] == ">=3.10,<4.0"
    with pytest.raises(ResourceError):
        identity.package_metadata(content, limits=ParseLimits(document_bytes=20))
    with pytest.raises(ResourceError):
        identity.package_metadata(content, limits=ParseLimits(artifact_records=1))


@pytest.mark.parametrize("kind", ("foreign-package", "unknown-dependency", "url"))
def test_stage_rejects_unapproved_package_identity(kind: str) -> None:
    """kind (str) changes declarations; reject before generated writes, without I/O.

    Returns None; assertions may fail; only local test state changes.
    """
    filesystem = staged()
    content = filesystem.content[identity.PROJECT_PATH]
    # TOML is syntactically valid; pure identity rules reject unsupported values.
    if kind == "foreign-package":
        content = content.replace(b"drm-copilot-discovery", b"unapproved")
    elif kind == "unknown-dependency":
        content += b'other="1"\n'
    else:
        content = content.replace(b">=6.0", b"https://user:secret@example")
    filesystem.content[identity.PROJECT_PATH] = content
    writes = tuple(filesystem.writes)
    with pytest.raises(ServiceRuntimeError, match="RUNTIME_CORRUPT"):
        identity.stage_build_identity(filesystem)
    assert tuple(filesystem.writes) == writes


def test_metadata_mutation_during_capture_aborts_before_write(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """monkeypatch changes only memory metadata between reads; no external effects.

    Returns None; assertions may fail; only local test state changes.
    """
    filesystem = staged()
    original = filesystem.read_bounded
    reads = 0

    def read(path: str, *, limit: int) -> bytes:
        """Read path (str)/limit (int), changing second metadata bytes in memory.

        Returns bytes; only local counter changes and boundary errors propagate.
        """
        nonlocal reads
        if path == identity.PROJECT_PATH:
            reads += 1
            if reads == 2:
                return b"changed"
        return original(path, limit=limit)

    monkeypatch.setattr(filesystem, "read_bounded", read)
    writes = tuple(filesystem.writes)
    with pytest.raises(ResourceError, match="changed"):
        identity.stage_build_identity(filesystem)
    assert tuple(filesystem.writes) == writes


@pytest.mark.parametrize(
    "kind", ("foreign-path", "count", "oversized", "mutable", "path-type")
)
def test_build_boundary_contracts_are_checked(
    kind: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """kind (str) chooses invalid boundary data; monkeypatch is memory-only.

    Returns None; assertions may fail; only local test state changes.
    """
    filesystem = staged()
    limits = ParseLimits()

    def listing(root: str) -> tuple[str, ...]:
        """Return invalid listing for root (str) selected by kind; memory only.

        Returns tuple[str,...] or a deliberate casted violation, with no mutation.
        """
        if kind == "foreign-path":
            return ("foreign/source.py",)
        if kind == "count":
            return (f"{identity.SOURCE_ROOT}/x.py",) * 11
        if kind == "path-type":
            return cast("tuple[str, ...]", (1,))
        return cast("tuple[str, ...]", ["mutable"])

    # These injected boundaries deliberately violate their declared return contract.
    if kind == "foreign-path":
        monkeypatch.setattr(filesystem, "list_files", listing)
    elif kind == "count":
        limits = ParseLimits(artifact_records=10)
        monkeypatch.setattr(filesystem, "list_files", listing)
    elif kind == "oversized":
        original = filesystem.read_bounded

        def oversized(path: str, *, limit: int) -> bytes:
            """Return excess bytes for path (str), using limit (int); memory only."""
            return (
                original(path, limit=limit)
                if path == identity.PROJECT_PATH
                else b"x" * (limit + 1)
            )

        monkeypatch.setattr(filesystem, "read_bounded", oversized)
    else:
        monkeypatch.setattr(filesystem, "list_files", listing)
    with pytest.raises((ResourceError, ValueError)):
        identity.stage_build_identity(filesystem, limits=limits)
    assert identity.BUILD_MANIFEST_PATH not in filesystem.content


def test_undeclared_resource_is_not_refreshed_by_identity_stage() -> None:
    """Identity cannot repair resource closure or generate before it is valid.

    Returns None; assertions may fail; only local test state changes.
    """
    filesystem = staged()
    filesystem.content[f"{build.STAGE_ROOT}/schemas/discovery/v1/new.json"] = b"{}"
    writes = tuple(filesystem.writes)
    with pytest.raises(ServiceRuntimeError, match="RUNTIME_CORRUPT"):
        identity.stage_build_identity(filesystem)
    assert tuple(filesystem.writes) == writes


def test_nonboolean_check_is_not_coerced_into_write_authority() -> None:
    """Invalid check type fails before reading or writing the memory store.

    Returns None; assertions may fail; only local test state changes.
    """
    filesystem = staged()
    with pytest.raises(ResourceError, match="boolean"):
        identity.stage_build_identity(filesystem, check=cast("bool", 1))
