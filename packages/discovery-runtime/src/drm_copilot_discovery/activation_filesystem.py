"""Protect external activation bytes through the accepted native directory
primitives."""

from __future__ import annotations

from contextlib import ExitStack, contextmanager
from dataclasses import dataclass
from hashlib import sha256
from pathlib import Path, PurePosixPath, PureWindowsPath
from typing import TYPE_CHECKING, Literal
from uuid import uuid4

from drm_copilot_discovery.mutation_filesystem import open_local_directory
from drm_copilot_discovery.path_models import relative_path

if TYPE_CHECKING:
    from collections.abc import Callable, Generator
    from contextlib import AbstractContextManager

    from drm_copilot_discovery.mutation_filesystem import Directory


@dataclass(frozen=True, kw_only=True)
class RegistryLocation:
    """Derive workspace-specific paths from host-resolved locations, never requests.

    The trusted host resolves aliases before construction. Windows identity uses
    native separators and invariant lowercase, matching the existing authority
    store. Linux/macOS preserve case. No directories are created by this value.
    """

    workspace: str
    workspace_sha256: str
    directory: str

    @classmethod
    def for_host(
        cls,
        *,
        workspace_root: str,
        platform: Literal["windows", "macos", "linux"],
        user_home: str,
        local_app_data: str | None = None,
        xdg_state_home: str | None = None,
    ) -> RegistryLocation:
        """Return canonical external storage paths from trusted host values only."""
        path_type = PureWindowsPath if platform == "windows" else PurePosixPath
        workspace, home = path_type(workspace_root), path_type(user_home)
        # Platform state locations are fixed policy; profiles cannot redirect them.
        if platform == "windows":
            if not local_app_data:
                raise ValueError("Trusted LocalApplicationData is required")
            base = path_type(local_app_data)
        elif platform == "macos":
            base = home / "Library/Application Support"
        elif platform == "linux":
            base = (
                path_type(xdg_state_home) if xdg_state_home else home / ".local/state"
            )
        else:
            raise ValueError("Unsupported activation registry platform")
        if any(
            not path.is_absolute() or ".." in path.parts
            for path in (workspace, home, base)
        ):
            raise ValueError("Trusted host paths must be absolute and canonical")
        root = base / "drm-copilot/discovery"
        if root.is_relative_to(workspace):
            raise ValueError("Activation authority must remain outside the workspace")
        canonical = str(workspace).lower() if platform == "windows" else str(workspace)
        digest = sha256(canonical.encode()).hexdigest()
        return cls(
            workspace=workspace.as_posix(),
            workspace_sha256=digest,
            directory=(root / "workspaces" / digest).as_posix(),
        )


class NativeRegistry:
    """Use the accepted anchored directory primitives for a fixed external record.

    Reads never create paths. The root operation provisions state directories and
    holds mutation.lock through workspace and registry publication. No stale lock
    is stolen. Injected directory and nonce seams keep unit tests in memory.
    """

    def __init__(
        self,
        location: RegistryLocation,
        *,
        opener: Callable[
            [Path], AbstractContextManager[Directory]
        ] = open_local_directory,
        nonce: Callable[[], str] = lambda: uuid4().hex,
    ) -> None:
        """Retain trusted deployment values without performing I/O or granting root."""
        self.location, self._opener, self._nonce = location, opener, nonce
        self._held: Directory | None = None
        self._identities: dict[str, str] = {}

    @contextmanager
    def _directory(
        self, *, create: bool, capture: dict[str, str] | None = None
    ) -> Generator[Directory, None, None]:
        """Pin every ordinary ancestor, exclusively creating absent state
        directories."""
        path = Path(self.location.directory)
        with ExitStack() as anchors:
            directory = anchors.enter_context(self._opener(Path(path.anchor)))
            current = Path(path.anchor)
            self._identity(current, directory, capture)
            # The complete absolute chain remains open until the protected I/O ends.
            for name in path.parts[1:]:
                try:
                    child = anchors.enter_context(directory.child(name, create=False))
                except FileNotFoundError:
                    if not create:
                        raise
                    child = anchors.enter_context(directory.child(name, create=True))
                directory = child
                current /= name
                self._identity(current, directory, capture)
            yield directory

    def _identity(
        self, path: Path, directory: Directory, capture: dict[str, str] | None
    ) -> None:
        """Bind opened state ancestors to the retained guard, rejecting namespace
        replacement."""
        name, identity = path.as_posix(), directory.identity()
        if name in self._identities and self._identities[name] != identity:
            raise OSError("Protected activation parent identity changed")
        if capture is not None:
            capture[name] = identity

    def read(self) -> bytes | None:
        """Read the bounded fixed record without creating even its parent directory."""
        try:
            with self._directory(create=False) as directory:
                try:
                    return directory.read("activation.json", limit=65536)
                except FileNotFoundError:
                    return None
        except FileNotFoundError:
            if self._held is not None:
                raise OSError("Protected activation directory disappeared") from None
            return None

    @contextmanager
    def guard(self) -> Generator[None, None, None]:
        """Serialize cooperating writers with the canonical external mutation lock."""
        if self._held is not None:
            raise OSError("Activation guard is already held")
        identities: dict[str, str] = {}
        with self._directory(create=True, capture=identities) as directory:
            directory.stage("mutation.lock", b"")
            self._held = directory
            self._identities = identities
            try:
                yield
            finally:
                self._held = None
                self._identities = {}
                directory.remove("mutation.lock")

    def write(self, content: bytes, *, expected: bytes | None) -> None:
        """Check original bytes under exclusion, then atomically publish one record."""
        directory = self._held
        if directory is None:
            raise OSError("Protected activation publication requires its guard")
        if self.read() != expected:
            raise OSError("Protected activation changed before publication")
        name = relative_path(".activation-" + self._nonce())
        directory.stage(name, content)
        with ExitStack() as cleanup:
            cleanup.callback(directory.remove, name)
            directory.publish(name, "activation.json", replace=expected is not None)
            if expected is not None:
                cleanup.pop_all()
