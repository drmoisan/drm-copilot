"""Publish mutations on Windows/Linux through anchored, injectable OS boundaries.

The external workspace lock serializes cooperating authorized writers. Native
controls must deny analyst writes through other routes. Portable filesystems do
not offer a digest-conditioned rename against arbitrary same-user processes;
complete pre/postchecks detect observed external changes and invalidate results.
No lock is stolen automatically after a crash; root recovery must inspect it.
"""

from __future__ import annotations

import ctypes
import os
import stat
from contextlib import ExitStack, contextmanager
from hashlib import sha256
from pathlib import Path
from typing import TYPE_CHECKING, Protocol, cast
from uuid import uuid4

from drm_copilot_discovery.path_models import PathMetadata, relative_path

if TYPE_CHECKING:
    from collections.abc import Callable, Generator
    from contextlib import AbstractContextManager

    from drm_copilot_discovery.path_models import PathMetadataReader, ResolvedPath


class Directory(Protocol):
    """Expose only operations anchored to an already checked directory handle."""

    def identity(self) -> str:
        """Return the opened handle identity, independently of the pathname."""
        ...

    def child(self, name: str, *, create: bool) -> AbstractContextManager[Directory]:
        """Open a non-following child, creating it exclusively only when requested."""
        ...

    def read(self, name: str, *, limit: int) -> bytes:
        """Read an ordinary anchored file within a finite byte ceiling."""
        ...

    def stage(self, name: str, content: bytes) -> None:
        """Exclusively create and flush a staged file, exposing partial errors."""
        ...

    def publish(self, staged: str, name: str, *, replace: bool) -> None:
        """Atomically link without overwrite, or replace under the workspace guard."""
        ...

    def remove(self, name: str) -> None:
        """Remove only the caller-owned staged name; propagate cleanup failure."""
        ...


class _WindowsCall(Protocol):
    """Type the two narrow kernel calls without exposing untyped ctypes elsewhere."""

    argtypes: list[object]
    restype: object

    def __call__(self, *args: object) -> int | None:
        """Return the native handle/status; errors are checked by its caller."""
        ...


def _ordinary(info: os.stat_result, *, directory: bool) -> None:
    """Reject links, reparse points and nonordinary entries before any byte access."""
    expected = stat.S_ISDIR if directory else stat.S_ISREG
    if not expected(info.st_mode) or getattr(info, "st_file_attributes", 0) & 0x400:
        raise OSError("Mutation paths must be ordinary non-reparse entries")


@contextmanager
def pin_windows_path(
    path: Path, *, directory: bool
) -> Generator[os.stat_result, None, None]:
    """Deny delete sharing so Windows cannot rename/replace an opened ancestor."""
    _ordinary(os.lstat(path), directory=directory)
    kernel = ctypes.WinDLL("kernel32", use_last_error=True)
    opening = cast("_WindowsCall", kernel.CreateFileW)
    opening.argtypes = [
        ctypes.c_wchar_p,
        ctypes.c_uint32,
        ctypes.c_uint32,
        ctypes.c_void_p,
        ctypes.c_uint32,
        ctypes.c_uint32,
        ctypes.c_void_p,
    ]
    opening.restype = ctypes.c_void_p
    closing = cast("_WindowsCall", kernel.CloseHandle)
    closing.argtypes, closing.restype = [ctypes.c_void_p], ctypes.c_int
    # Read/list access participates in sharing checks; attribute access alone does not.
    # OPEN_REPARSE_POINT plus no FILE_SHARE_DELETE protects the checked name.
    handle = opening(str(path), 0x81, 3, None, 3, 0x02200000, None)
    if handle is None or handle == ctypes.c_void_p(-1).value:
        raise OSError("Cannot pin Windows mutation path")
    import msvcrt

    # Transfer ownership to a descriptor so fstat uses the exact retained handle.
    try:
        descriptor = msvcrt.open_osfhandle(handle, os.O_RDONLY)
    except OSError:
        closing(handle)
        raise
    try:
        _ordinary(os.lstat(path), directory=directory)
        info = os.fstat(descriptor)
        _ordinary(info, directory=directory)
        yield info
    finally:
        os.close(descriptor)


class NativeDirectory:
    """Implement anchored primitive calls; POSIX uses dir_fd, Windows pins parents."""

    def __init__(self, path: Path, descriptor: int | None, identity: str) -> None:
        """Retain a pinned directory for the lifetime of its owning context."""
        self.path, self.descriptor = path, descriptor
        self._identity = identity

    def identity(self) -> str:
        """Expose the stat identity of the retained directory handle."""
        return self._identity

    def _name(self, name: str) -> str:
        """
        Reject multicomponent names before selecting relative or pinned absolute
        I/O.
        """
        if "/" in relative_path(name):
            raise ValueError("Anchored operation requires an immediate child name")
        return name if self.descriptor is not None else str(self.path / name)

    @contextmanager
    def child(self, name: str, *, create: bool) -> Generator[Directory, None, None]:
        """Keep every ancestor open and exclusively create requested missing parents."""
        # Only a previously absent parent may be created; existing parents are anchored
        # as-is.
        if create:
            os.mkdir(self._name(name), 0o700, dir_fd=self.descriptor)
        with open_local_directory(self.path / name, parent=self) as child:
            yield child

    def read(self, name: str, *, limit: int) -> bytes:
        """Bound reads and reject file links while all parent handles remain pinned."""
        with ExitStack() as stack:
            # Windows needs a retained file handle because its open API has no dir_fd
            # route.
            if os.name == "nt":
                stack.enter_context(pin_windows_path(self.path / name, directory=False))
            descriptor = os.open(
                self._name(name),
                os.O_RDONLY | getattr(os, "O_NOFOLLOW", 0),
                dir_fd=self.descriptor,
            )
            stack.callback(os.close, descriptor)
            _ordinary(os.fstat(descriptor), directory=False)
            pieces: list[bytes] = []
            remaining = limit + 1
            # A short kernel read is not EOF; consume only the finite allowed budget.
            while remaining:
                piece = os.read(descriptor, min(remaining, 65536))
                if not piece:
                    break
                pieces.append(piece)
                remaining -= len(piece)
            content = b"".join(pieces)
            if len(content) > limit:
                raise OSError("Mutation input exceeds the bounded read limit")
            return content

    def stage(self, name: str, content: bytes) -> None:
        """Write every staged byte before flushing; zero/short writes cannot pass."""
        descriptor = os.open(
            self._name(name),
            os.O_WRONLY | os.O_CREAT | os.O_EXCL,
            0o600,
            dir_fd=self.descriptor,
        )
        try:
            try:
                offset = 0
                # Partial writes are finite progress; zero writes are failures.
                while offset < len(content):
                    count = os.write(descriptor, content[offset:])
                    if count <= 0:
                        raise OSError("Staged mutation write made no progress")
                    offset += count
                os.fsync(descriptor)
            finally:
                os.close(descriptor)
        except OSError:
            # Only a successfully created stage is ours to clean on failure.
            self.remove(name)
            raise

    def publish(self, staged: str, name: str, *, replace: bool) -> None:
        """
        Publish within one filesystem; exclusive links never overwrite a collision.
        """
        # Replacement consumes its stage; creation uses a link that rejects a colliding
        # leaf.
        if replace:
            os.replace(
                self._name(staged),
                self._name(name),
                src_dir_fd=self.descriptor,
                dst_dir_fd=self.descriptor,
            )
        else:
            os.link(
                self._name(staged),
                self._name(name),
                src_dir_fd=self.descriptor,
                dst_dir_fd=self.descriptor,
                follow_symlinks=False,
            )

    def remove(self, name: str) -> None:
        """Remove a known stage and expose failures instead of hiding leaked state."""
        os.unlink(self._name(name), dir_fd=self.descriptor)


@contextmanager
def open_local_directory(
    path: Path, *, parent: NativeDirectory | None = None, platform: str | None = None
) -> Generator[Directory, None, None]:
    """Anchor directories without following links on the two supported platforms."""
    selected = platform or os.name
    # Windows denies deletion sharing; POSIX keeps non-following directory descriptors.
    if selected == "nt":
        with pin_windows_path(path, directory=True) as info:
            yield NativeDirectory(path, None, f"{info.st_dev}:{info.st_ino}")
    elif selected == "posix":
        directory_flag = cast("int", getattr(os, "O_DIRECTORY", 0))
        nofollow_flag = cast("int", getattr(os, "O_NOFOLLOW", 0))
        if not directory_flag or not nofollow_flag:
            raise OSError("POSIX mutation directory flags are unavailable")
        descriptor = os.open(
            path.name if parent else str(path),
            os.O_RDONLY | directory_flag | nofollow_flag,
            dir_fd=parent.descriptor if parent else None,
        )
        try:
            info = os.fstat(descriptor)
            _ordinary(info, directory=True)
            yield NativeDirectory(path, descriptor, f"{info.st_dev}:{info.st_ino}")
        finally:
            os.close(descriptor)
    else:
        raise OSError("Mutation filesystem requires Windows or POSIX directory handles")


@contextmanager
def exclusive_workspace_lock(path: Path) -> Generator[None, None, None]:
    """Use an externally provisioned canonical lock; never steal a stale lock."""
    descriptor = os.open(path, os.O_WRONLY | os.O_CREAT | os.O_EXCL, 0o600)
    try:
        yield
    finally:
        os.close(descriptor)
        os.unlink(path)


class LocalMutationPrimitives:
    """Provide real local publication and memory-only injectable OS seams.

    lock_path is trusted, canonical, external to the workspace and identical for
    all its mutators. Its parent is provisioned by root; request data cannot set it.
    Input captures must use metadata/read_bytes below for matching file identities.
    Inject directory/lock factories only from trusted composition or unit tests.
    """

    def __init__(
        self,
        *,
        workspace_root: str,
        lock_path: str,
        open_directory: Callable[[], AbstractContextManager[Directory]] | None = None,
        lock: Callable[[], AbstractContextManager[None]] | None = None,
        metadata: PathMetadataReader | None = None,
        nonce: Callable[[], str] | None = None,
        document_bytes: int = 16777216,
    ) -> None:
        """
        Bind canonical trusted paths and injectable capabilities without touching
        disk.
        """
        self.root, self.lock_path = Path(workspace_root), Path(lock_path)
        if not self.root.is_absolute() or not self.lock_path.is_absolute():
            raise ValueError("Workspace and external lock paths must be absolute")
        if self.lock_path == self.root or self.root in self.lock_path.parents:
            raise ValueError("Mutation lock must be outside the workspace")
        if not 1 <= document_bytes <= 67108864:
            raise ValueError(
                "Document byte limit is outside the supported finite range"
            )
        self.document_bytes = document_bytes
        self._open = open_directory or (lambda: open_local_directory(self.root))
        self._lock = lock or (lambda: exclusive_workspace_lock(self.lock_path))
        self._metadata = metadata or self.metadata
        self._nonce = nonce or (lambda: uuid4().hex)
        self._guarded = False
        self._anchors: ExitStack | None = None

    def metadata(self, path: str) -> PathMetadata:
        """Supply complete ordinary namespace identities to the accepted path policy."""
        target = self.root if path == "." else self.root / relative_path(path)
        try:
            info = os.lstat(target)
        except FileNotFoundError:
            return PathMetadata(kind="missing")
        # Classify links/reparse entries before ordinary types so policy can reject
        # them.
        kind = (
            "symlink"
            if stat.S_ISLNK(info.st_mode)
            else (
                "reparse"
                if getattr(info, "st_file_attributes", 0) & 0x400
                else (
                    "directory"
                    if stat.S_ISDIR(info.st_mode)
                    else "file" if stat.S_ISREG(info.st_mode) else "other"
                )
            )
        )
        children = tuple(sorted(os.listdir(target))) if kind == "directory" else ()
        return PathMetadata(
            kind=kind,
            identity=f"{info.st_dev}:{info.st_ino}",
            resolved_path=target.as_posix(),
            children=children,
        )

    def read_bytes(self, path: str, *, limit: int) -> bytes:
        """
        Read bounded snapshot inputs through non-following pinned directory chains.
        """
        parts = relative_path(path).split("/")
        with ExitStack() as stack:
            directory = stack.enter_context(self._open())
            # Every parent stays pinned until the final bounded read has completed.
            for name in parts[:-1]:
                directory = stack.enter_context(directory.child(name, create=False))
            return directory.read(parts[-1], limit=limit)

    @contextmanager
    def guard(self) -> Generator[None, None, None]:
        """
        Serialize authorized writes and reject reentry instead of bypassing
        exclusion.
        """
        if self._guarded:
            raise OSError("Mutation workspace guard is already held")
        with self._lock(), ExitStack() as anchors:
            self._guarded = True
            self._anchors = anchors
            try:
                yield
            finally:
                self._guarded = False
                self._anchors = None

    def create_exclusive(self, target: ResolvedPath, content: bytes) -> None:
        """Publish only to an absent path while retaining all parent anchors."""
        self._publish(target, content, expected_sha256=None)

    def replace_if_digest(
        self, target: ResolvedPath, content: bytes, *, expected_sha256: str
    ) -> None:
        """
        Recheck original bytes under exclusion before atomically replacing the file.
        """
        self._publish(target, content, expected_sha256=expected_sha256)

    def _publish(
        self, target: ResolvedPath, content: bytes, *, expected_sha256: str | None
    ) -> None:
        """
        Stage, validate parents/digest, publish once and clean only the owned stage.
        """
        if not self._guarded or self._anchors is None or target.grant is None:
            raise OSError("An active workspace guard and exact grant are required")
        # Bind opened native handles to the exact stamps checked by the path policy.
        observations = {item.path: item for item in target.observations}
        parts = relative_path(target.path).split("/")
        staged = ".drm-mutation-" + self._nonce()
        relative_path(staged)
        with ExitStack() as cleanup:
            directory = self._anchors.enter_context(self._open())
            if directory.identity() != observations["."].identity:
                raise OSError("Opened workspace root identity changed")
            # Verify original parent identities before opening/creating their anchors.
            for index, name in enumerate(parts[:-1], 1):
                path = "/".join(parts[:index])
                old = observations[path]
                current = self._metadata(path)
                if (old.kind, old.identity, old.resolved_path) != (
                    current.kind,
                    current.identity,
                    current.resolved_path,
                ):
                    raise OSError("Mutation parent changed before publication")
                directory = self._anchors.enter_context(
                    directory.child(name, create=old.kind == "missing")
                )
                if old.kind != "missing" and directory.identity() != old.identity:
                    raise OSError("Opened mutation parent identity changed")
            # Stage ownership is established by exclusive creation; collisions
            # propagate.
            directory.stage(staged, content)
            cleanup.callback(directory.remove, staged)
            published = False
            try:
                # Creation must not read a foreign target; replacement verifies current
                # bytes.
                if expected_sha256 is not None:
                    original = directory.read(parts[-1], limit=self.document_bytes)
                    if sha256(original).hexdigest() != expected_sha256:
                        raise OSError(
                            "Mutation original digest changed before replacement"
                        )
                directory.publish(
                    staged, parts[-1], replace=expected_sha256 is not None
                )
                published = True
            finally:
                # Replacement consumes its stage; creation keeps the owned hard link.
                if published and expected_sha256 is not None:
                    cleanup.pop_all()
