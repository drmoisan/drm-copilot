"""Verify local publication with memory directories and injected kernel calls."""

from __future__ import annotations

import ctypes
import os
import stat
import sys
from contextlib import contextmanager
from dataclasses import replace
from hashlib import sha256
from pathlib import Path
from types import SimpleNamespace
from typing import TYPE_CHECKING, cast

import pytest
from drm_copilot_discovery import mutation_filesystem as filesystem
from drm_copilot_discovery.mutation_filesystem import (
    LocalMutationPrimitives,
    NativeDirectory,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Generator

    from drm_copilot_discovery.mutation_filesystem import Directory


from tests.discovery_runtime.mutation_test_support import MemoryDisk, constant


def test_local_create_replace_and_parent_handles_remain_until_guard_exit() -> None:
    """
    Concrete publication pins parents through checks and preserves unrelated bytes.
    """
    disk = MemoryDisk()
    disk.store.put("docs/unrelated", b"preserve")
    provider = disk.provider()
    with provider.guard():
        provider.create_exclusive(disk.target("docs/new/output.json"), b"first")
        assert disk.held == 3
    assert disk.held == 0 and not disk.locked
    with provider.guard():
        provider.replace_if_digest(
            disk.target("docs/new/output.json"),
            b"second",
            expected_sha256=sha256(b"first").hexdigest(),
        )
    assert provider.read_bytes("docs/new/output.json", limit=8) == b"second"
    assert disk.store.files == {
        "docs/unrelated": b"preserve",
        "docs/new/output.json": b"second",
    }


@pytest.mark.parametrize(
    "failure", ["collision", "stale", "publish", "stage", "guard", "reentry"]
)
def test_failed_publication_preserves_foreign_bytes_and_closes_handles(
    failure: str,
) -> None:
    """Every bounded failure leaves old/foreign content and no owned staging file."""
    disk = MemoryDisk()
    provider = disk.provider()
    disk.store.put("docs/output.json", b"original")
    if failure == "stage":
        disk.store.put("docs/.drm-mutation-owned", b"foreign")
    disk.fail_publish = failure == "publish"
    before = dict(disk.store.files)
    # Select failures before exclusion, during publication, or at reentry without
    # retries.
    with pytest.raises(OSError):
        if failure == "guard":
            provider.create_exclusive(disk.target(), b"changed")
        else:
            with provider.guard():
                if failure == "reentry":
                    with provider.guard():
                        pytest.fail("reentry admitted")
                elif failure in {"collision", "stage"}:
                    provider.create_exclusive(disk.target(), b"changed")
                else:
                    provider.replace_if_digest(
                        disk.target(),
                        b"changed",
                        expected_sha256=sha256(
                            b"stale" if failure == "stale" else b"original"
                        ).hexdigest(),
                    )
    assert disk.store.files == before and disk.held == 0 and not disk.locked


@pytest.mark.parametrize("path", [".", "docs"])
def test_opened_identity_substitution_is_rejected_before_staging(path: str) -> None:
    """Swapping a normal directory after metadata inspection cannot redirect writes."""
    disk = MemoryDisk()
    target = disk.target()

    def exchange(opening: str) -> None:
        """Simulate the exact metadata-to-open race once at the named parent."""
        if opening == path:
            disk.store.metadata.entries[path] = replace(
                disk.store.metadata.entries[path], identity="substituted"
            )

    disk.before_open = exchange
    provider = disk.provider()
    with pytest.raises(OSError, match="identity changed"):
        with provider.guard():
            provider.create_exclusive(target, b"proposed")
    assert not disk.store.files and disk.held == 0


def test_separate_providers_share_exclusion_and_honor_configured_byte_bound() -> None:
    """Two authorized writers cannot overlap, and configured larger originals work."""
    disk = MemoryDisk()
    original = b"x" * 16777217
    disk.store.put("docs/output.json", original)
    first, second = disk.provider(limit=33554432), disk.provider()
    with first.guard():
        with pytest.raises(FileExistsError):
            with second.guard():
                pytest.fail("concurrent writer admitted")
        first.replace_if_digest(
            disk.target(), b"new", expected_sha256=sha256(original).hexdigest()
        )
    assert disk.limits == [33554432] and disk.store.files["docs/output.json"] == b"new"


@pytest.mark.parametrize("bound", [0, 67108865])
def test_provider_requires_finite_bounds_and_external_absolute_lock(bound: int) -> None:
    """Invalid deployment configuration cannot create an operational provider."""
    disk = MemoryDisk()
    with pytest.raises(ValueError, match="finite range"):
        disk.provider(limit=bound)
    with pytest.raises(ValueError, match="absolute"):
        LocalMutationPrimitives(workspace_root="relative", lock_path="relative")
    with pytest.raises(ValueError, match="outside"):
        LocalMutationPrimitives(workspace_root=disk.root, lock_path=disk.root + "/lock")


def stat_value(*, directory: bool = False) -> os.stat_result:
    """
    Return deterministic inode/device data without consulting the operating system.
    """
    return cast(
        "os.stat_result",
        SimpleNamespace(
            st_mode=stat.S_IFDIR if directory else stat.S_IFREG,
            st_ino=11,
            st_dev=7,
            st_file_attributes=0,
        ),
    )


@pytest.mark.parametrize("failure", ["none", "zero", "flush", "collision", "cleanup"])
def test_native_stage_closes_handles_and_cleans_only_owned_files(
    failure: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """
    Real native-stage control flow handles short writes, I/O failures and
    collisions.
    """
    removed: list[str] = []

    def removing(name: str, **kwargs: object) -> None:
        """Observe cleanup without touching the native namespace."""
        removed.append(name)
        if failure == "cleanup":
            raise OSError("owned stage cleanup failed")

    closed: list[int] = []
    writes: list[bytes] = []

    def opening(*args: object, **kwargs: object) -> int:
        """Inject exclusive-create failure before ownership can be established."""
        if failure == "collision":
            raise FileExistsError("foreign stage")
        return 17

    def writing(descriptor: int, value: bytes) -> int:
        """Model a short write or a zero-progress error without external I/O."""
        writes.append(value)
        return 0 if failure in {"zero", "cleanup"} else min(2, len(value))

    def flushing(descriptor: int) -> None:
        """Fail only the explicit fsync boundary under test."""
        if failure == "flush":
            raise OSError("flush failed")

    monkeypatch.setattr(os, "open", opening)
    monkeypatch.setattr(os, "write", writing)
    monkeypatch.setattr(os, "fsync", flushing)
    monkeypatch.setattr(os, "close", closed.append)
    monkeypatch.setattr(os, "unlink", removing)
    directory = NativeDirectory(Path("anchor"), 5, "7:11")
    # Successful short writes must flush all bytes; failure cases expose their cleanup
    # outcome.
    if failure == "none":
        directory.stage("stage", b"abcde")
        assert writes == [b"abcde", b"cde", b"e"]
    else:
        with pytest.raises(OSError):
            directory.stage("stage", b"abcde")
    assert closed == ([] if failure == "collision" else [17])
    assert removed == (["stage"] if failure in {"zero", "flush", "cleanup"} else [])


@pytest.mark.parametrize("platform", ["nt", "posix", "unsupported"])
def test_native_directory_uses_actual_handle_identity_and_closes(
    platform: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """
    Both supported directory mechanisms bind identity; other platforms fail closed.
    """
    closed: list[int] = []

    @contextmanager
    def pin(path: Path, *, directory: bool) -> Generator[os.stat_result, None, None]:
        """Model an already pinned Windows handle without calling a native library."""
        yield stat_value(directory=directory)

    monkeypatch.setattr(filesystem, "pin_windows_path", pin)
    monkeypatch.setattr(os, "open", constant(23))
    monkeypatch.setattr(os, "fstat", constant(stat_value(directory=True)))
    monkeypatch.setattr(os, "close", closed.append)
    monkeypatch.setattr(os, "O_DIRECTORY", 0x10000, raising=False)
    monkeypatch.setattr(os, "O_NOFOLLOW", 0x20000, raising=False)
    # Only supported handle providers may produce a directory capability.
    if platform == "unsupported":
        with pytest.raises(OSError, match="requires"):
            with filesystem.open_local_directory(Path("anchor"), platform=platform):
                pytest.fail("unsupported platform admitted")
    else:
        with filesystem.open_local_directory(
            Path("anchor"), platform=platform
        ) as directory:
            assert directory.identity() == "7:11"
    assert closed == ([23] if platform == "posix" else [])


@pytest.mark.parametrize("failure", ["none", "open", "transfer", "kind"])
def test_windows_pins_transfer_real_handle_ownership_and_check_identity(
    failure: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Injected Win32 calls verify no-delete-sharing flags and exact-handle fstat."""
    closed: list[int] = []
    native_closed: list[int] = []

    class KernelCall:
        """Model typed ctypes function attributes and record native close calls."""

        argtypes: list[object] = []
        restype: object = None

        def __init__(self, *, closing: bool) -> None:
            """Select one narrow injected Windows function."""
            self.closing = closing

        def __call__(self, *args: object) -> int | None:
            """Return a handle/status without invoking the kernel."""
            # Track native closes separately from descriptor closes after ownership
            # transfer.
            if self.closing:
                native_closed.append(cast("int", args[0]))
                return 1
            assert (
                args[1] == 0x81 and args[2] == 3 and cast("int", args[5]) & 0x00200000
            )
            return None if failure == "open" else 31

    def transfer(handle: int, flags: int) -> int:
        """Simulate descriptor ownership transfer or its explicit failure."""
        if failure == "transfer":
            raise OSError("transfer failed")
        return handle + 1

    kernel = SimpleNamespace(
        CreateFileW=KernelCall(closing=False), CloseHandle=KernelCall(closing=True)
    )
    monkeypatch.setattr(ctypes, "WinDLL", constant(kernel), raising=False)
    monkeypatch.setitem(
        sys.modules, "msvcrt", cast("object", SimpleNamespace(open_osfhandle=transfer))
    )
    monkeypatch.setattr(os, "lstat", constant(stat_value(directory=True)))
    monkeypatch.setattr(
        os,
        "fstat",
        constant(stat_value(directory=failure != "kind")),
    )
    monkeypatch.setattr(os, "close", closed.append)
    # Every unsuccessful ownership transfer/open must unwind the resource it actually
    # owns.
    if failure == "none":
        with filesystem.pin_windows_path(Path("anchor"), directory=True) as info:
            assert (info.st_dev, info.st_ino) == (7, 11)
    else:
        with pytest.raises(OSError):
            with filesystem.pin_windows_path(Path("anchor"), directory=True):
                pytest.fail("invalid pin admitted")
    assert closed == ([32] if failure in {"none", "kind"} else [])
    assert native_closed == ([31] if failure == "transfer" else [])


@pytest.mark.parametrize("failure", ["none", "overflow", "kind"])
def test_native_bounded_read_consumes_short_reads_and_closes(
    failure: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """Bounded ordinary-file reads preserve exact bytes and reject overflow/types."""
    closed: list[int] = []
    pieces = [b"ab", b"c", b""]

    def reading(descriptor: int, count: int) -> bytes:
        """Return the next deterministic short-read chunk."""
        return pieces.pop(0)

    @contextmanager
    def pin(path: Path, *, directory: bool) -> Generator[os.stat_result, None, None]:
        """Model a retained Windows file while the injected descriptor is read."""
        yield stat_value(directory=directory)

    monkeypatch.setattr(filesystem, "pin_windows_path", pin)
    monkeypatch.setattr(os, "open", constant(43))
    monkeypatch.setattr(
        os,
        "fstat",
        constant(stat_value(directory=failure == "kind")),
    )
    monkeypatch.setattr(os, "read", reading)
    monkeypatch.setattr(os, "close", closed.append)
    directory = NativeDirectory(Path("anchor"), 5, "7:11")
    # Valid reads assemble short chunks; overflow and nonregular handles fail
    # explicitly.
    if failure == "none":
        assert directory.read("input", limit=3) == b"abc"
    else:
        with pytest.raises(OSError):
            directory.read("input", limit=2 if failure == "overflow" else 3)
    assert closed == [43]
    with pytest.raises(ValueError, match="immediate"):
        directory.stage("nested/name", b"invalid")


def test_native_publication_child_creation_and_external_lock_primitives(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """Native wrappers select atomic link/replace, relative parents and lock cleanup."""
    calls: list[tuple[str, tuple[object, ...], dict[str, object]]] = []

    def record(name: str) -> Callable[..., None]:
        """Record one injected primitive without executing external effects."""

        def invoke(*args: object, **kwargs: object) -> None:
            """Retain exact primitive argument dispatch for assertions."""
            calls.append((name, args, kwargs))

        return invoke

    @contextmanager
    def opening(
        path: Path, *, parent: NativeDirectory | None = None
    ) -> Generator[Directory, None, None]:
        """Expose one already-anchored child for native directory sequencing."""
        assert parent is not None
        yield NativeDirectory(path, 51, "7:11")

    monkeypatch.setattr(filesystem, "open_local_directory", opening)
    # Replace every native operation reached by this test, preserving observable call
    # order.
    for name in ("mkdir", "link", "replace", "unlink", "close"):
        monkeypatch.setattr(os, name, record(name))
    monkeypatch.setattr(os, "open", constant(53))
    directory = NativeDirectory(Path("anchor"), None, "7:11")
    with directory.child("new", create=True) as child:
        assert child.identity() == "7:11"
    with directory.child("existing", create=False):
        pass
    directory.publish("stage", "output", replace=False)
    directory.publish("stage", "output", replace=True)
    with filesystem.exclusive_workspace_lock(Path("external.lock")):
        assert calls[-1][0] == "replace"
    # Publication must precede guard cleanup, and child creation must be exclusive.
    assert [item[0] for item in calls] == [
        "mkdir",
        "link",
        "replace",
        "close",
        "unlink",
    ]


@pytest.mark.parametrize(
    "kind", ["file", "directory", "symlink", "reparse", "other", "missing"]
)
def test_native_metadata_keeps_complete_names_and_nonfollowing_identity(
    kind: str, monkeypatch: pytest.MonkeyPatch
) -> None:
    """The provider exposes complete namespaces, explicit links and honest absence."""
    disk = MemoryDisk()
    provider = disk.provider()

    def inspect(path: object) -> os.stat_result:
        """Return deterministic native metadata or the exact missing-file signal."""
        if kind == "missing":
            raise FileNotFoundError("missing")
        mode = {
            "file": stat.S_IFREG,
            "directory": stat.S_IFDIR,
            "symlink": stat.S_IFLNK,
        }.get(kind, stat.S_IFIFO)
        return cast(
            "os.stat_result",
            SimpleNamespace(
                st_mode=mode,
                st_dev=7,
                st_ino=11,
                st_file_attributes=0x400 if kind == "reparse" else 0,
            ),
        )

    monkeypatch.setattr(os, "lstat", inspect)
    monkeypatch.setattr(os, "listdir", constant(["z", "a"]))
    result = provider.metadata("." if kind == "directory" else "file")
    assert result.kind == kind
    assert result.children == (("a", "z") if kind == "directory" else ())
