"""Filesystem seam for the potential-to-issue promotion workflow.

Extracted from `potential_to_issue.py` for #623 so that module does not grow
when the post-move destination check is added. `FileSystem` and
`RealFileSystem` are re-exported from `potential_to_issue.py`, so existing
callers and test doubles keep importing them from there.
"""

from __future__ import annotations

import shutil
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from collections.abc import Iterable


class FileSystem(Protocol):
    """Define filesystem operations required by promotion workflows.

    Purpose:
        Provide an abstraction boundary for filesystem interactions.

    Usage:
        Implemented by `RealFileSystem` and test doubles.

    Flow:
        Expose read/write/move/exists primitives used by promotion orchestration.

    Invariants / Constraints:
        Implementations must preserve UTF-8 behavior for markdown IO.

    Side Effects:
        Implementations may perform local disk IO.

    Attributes:
        None.
    """

    def resolve_path(self, path_str: str) -> Path: ...

    def exists(self, path: Path) -> bool: ...

    def read_text(self, path: Path) -> str: ...

    def write_text(self, path: Path, content: str) -> None: ...

    def write_lines(self, path: Path, lines: Iterable[str]) -> None: ...

    def ensure_dir(self, path: Path) -> None: ...

    def move(self, src: Path, dest: Path) -> None: ...


@dataclass
class RealFileSystem(FileSystem):
    """Concrete filesystem adapter using local disk operations.

    Purpose:
        Execute production file operations behind the `FileSystem` protocol.

    Usage:
        Used by default in promotion workflows and replaceable in tests.

    Flow:
        Resolve paths, read/write text, ensure directories, and move files.

    Invariants / Constraints:
        Paths are treated as UTF-8 text files when reading/writing markdown content.

    Side Effects:
        Reads/writes/moves files on the local filesystem.

    Attributes:
        None.
    """

    def resolve_path(self, path_str: str) -> Path:
        return Path(path_str).expanduser().resolve()

    def exists(self, path: Path) -> bool:
        return path.exists()

    def read_text(self, path: Path) -> str:
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        path.write_text(content, encoding="utf-8")

    def write_lines(self, path: Path, lines: Iterable[str]) -> None:
        joined = "\n".join(lines)
        path.write_text(joined, encoding="utf-8")

    def ensure_dir(self, path: Path) -> None:
        path.mkdir(parents=True, exist_ok=True)

    def move(self, src: Path, dest: Path) -> None:
        dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.move(str(src), str(dest))
