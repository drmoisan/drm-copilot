"""Bounded reads of explicit local Git identities and immutable file objects.

The host supplies execution; this module never starts a process or discovers a
neighboring repository. Git arguments and transport restrictions are fixed here.
"""

from __future__ import annotations

import hashlib
import re
from dataclasses import dataclass
from pathlib import PurePosixPath, PureWindowsPath
from typing import Protocol, cast

from drm_copilot_discovery.path_models import relative_path


def full_revision(value: str) -> str:
    """Require a literal full Git object identity, never a revision expression."""
    if re.fullmatch(r"(?:[0-9a-f]{40}|[0-9a-f]{64})", value) is None:
        raise ValueError("A full lowercase Git revision is required")
    return value


@dataclass(frozen=True, kw_only=True, order=True)
class RepositoryIdentity:
    """Keep a configured repository ID and pin without claiming remote freshness."""

    id: str
    revision: str | None

    def __post_init__(self) -> None:
        """Reject malformed identities while preserving an explicitly absent pin."""
        if re.fullmatch(r"[a-z][a-z0-9]*(?:[._-][a-z0-9]+)*", self.id) is None:
            raise ValueError("A stable repository ID is required")
        if self.revision is not None:
            full_revision(self.revision)

    def to_dict(self) -> dict[str, str | None]:
        """Project the identity into the manifest's transport shape."""
        return {"id": self.id, "revision": self.revision}


@dataclass(frozen=True, kw_only=True)
class RepositoryFile:
    """Retain the exact immutable bytes inspected at one explicit repository pin."""

    repository: RepositoryIdentity
    path: str
    content: bytes

    def __post_init__(self) -> None:
        """Require immutable bytes and a full revision before exposing evidence."""
        relative_path(self.path)
        if self.repository.revision is None or not isinstance(
            cast("object", self.content), bytes
        ):
            raise ValueError("Repository files require pinned identities and bytes")

    @property
    def sha256(self) -> str:
        """Hash the retained bytes rather than reading the object a second time."""
        return hashlib.sha256(self.content).hexdigest()


class RepositoryReader(Protocol):
    """Read only the explicitly bound local repository; foreign IDs are rejected."""

    def identity(self) -> RepositoryIdentity:
        """Return the verified local checkout identity."""
        ...

    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
        """Read one pinned ordinary Git blob with a finite byte ceiling."""
        ...


class GitCommand(Protocol):
    """Execute fixed argv without a shell, bounding output before allocating it.

    A native host implementation must raise OSError on command failure or output
    overflow. Unit tests implement this protocol entirely in memory.
    """

    def __call__(self, argv: tuple[str, ...], *, output_limit: int) -> bytes:
        """Return successful stdout bytes; never reinterpret arguments as code."""
        ...


class LocalGitReader:
    """Bind read-only Git operations to one caller-selected workspace and ID."""

    def __init__(
        self, *, workspace_root: str, repository_id: str, run: GitCommand
    ) -> None:
        """Keep execution injected and reject relative or noncanonical roots."""
        self._root = (
            PureWindowsPath(workspace_root)
            if ":" in workspace_root or workspace_root.startswith("\\\\")
            else PurePosixPath(workspace_root)
        )
        if not self._root.is_absolute() or ".." in self._root.parts:
            raise ValueError("Git reads require an explicit absolute workspace")
        self._id = RepositoryIdentity(id=repository_id, revision=None).id
        self._run = run
        self._argv = (
            "git",
            "--no-pager",
            "--no-replace-objects",
            "--no-lazy-fetch",
            "--literal-pathspecs",
            "-c",
            "protocol.allow=never",
            "-c",
            "core.fsmonitor=false",
            "-C",
            self._root.as_posix(),
        )

    def _read(self, *arguments: str, limit: int) -> bytes:
        """Enforce the output contract again at the injected execution boundary."""
        if type(limit) is not int or limit < 1:
            raise ValueError("A positive Git output limit is required")
        result = self._run(self._argv + arguments, output_limit=limit)
        if not isinstance(cast("object", result), bytes) or len(result) > limit:
            raise OSError("Git returned invalid or oversized output")
        return result

    def _verify_workspace(self) -> None:
        """Reject Git's ordinary parent-repository discovery before reading objects."""
        actual = (
            self._read("rev-parse", "--show-toplevel", limit=32768)
            .decode("utf-8", errors="strict")
            .rstrip("\r\n")
        )
        if actual.replace("\\", "/") != self._root.as_posix():
            raise OSError("Git repository root differs from the selected workspace")

    def identity(self) -> RepositoryIdentity:
        """Return HEAD only after verifying that Git selected the exact workspace."""
        self._verify_workspace()
        revision = (
            self._read("rev-parse", "--verify", "HEAD", limit=128)
            .decode("ascii", errors="strict")
            .strip()
        )
        return RepositoryIdentity(id=self._id, revision=full_revision(revision))

    def read_file(self, *, revision: str, path: str, limit: int) -> RepositoryFile:
        """Resolve a literal path at a full commit and verify its Git object bytes."""
        full_revision(revision)
        relative_path(path)
        self._verify_workspace()
        kind = self._read("cat-file", "-t", revision, limit=32)
        if kind != b"commit\n":
            raise OSError("The configured revision is not a local Git commit")
        entry = self._read("ls-tree", "-z", revision, "--", path, limit=32768)
        parts = entry.rstrip(b"\0").split(b"\t")
        if len(parts) != 2 or parts[1] != path.encode("utf-8"):
            raise OSError("The pinned Git file is missing or ambiguous")
        fields = parts[0].split(b" ")
        if (
            len(fields) != 3
            or fields[0] not in {b"100644", b"100755"}
            or fields[1] != b"blob"
        ):
            raise OSError("Only ordinary Git files can supply snapshot bytes")
        object_id = full_revision(fields[2].decode("ascii", errors="strict"))
        content = self._read("cat-file", "blob", object_id, limit=limit)
        digest = hashlib.new("sha1" if len(object_id) == 40 else "sha256")
        digest.update(f"blob {len(content)}\0".encode("ascii") + content)
        if digest.hexdigest() != object_id:
            raise OSError("Git blob identity does not match the returned bytes")
        return RepositoryFile(
            repository=RepositoryIdentity(id=self._id, revision=revision),
            path=path,
            content=content,
        )
