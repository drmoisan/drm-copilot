"""Filesystem abstractions for the push-down customization publisher.

Purpose:
    Isolate the publisher's filesystem contract and real-disk adapter so the
    orchestration module can stay focused on validation, rewriting, and summary
    reporting.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from pathlib import Path


class PushDownFileSystem(Protocol):
    """
    Define the filesystem operations required by the push-down publisher.

    Purpose:
        Provide a small, typed seam that keeps the core publisher logic
        deterministic in tests while still allowing the production CLI to work
        against the real filesystem.

    Usage:
        Pass `RealPushDownFileSystem` in production or a deterministic test
        double in unit tests.

    Flow:
        The publisher validates the destination, enumerates source files, then
        reads and writes text through this protocol.

    Invariants / Constraints:
        - `list_files()` returns files that are beneath the requested root.
        - `is_dir()` and `is_file()` reflect the current filesystem state.
        - `read_text()` and `write_text()` operate on UTF-8 repository text.

    Side Effects:
        Concrete implementations may touch the real filesystem.
    """

    def list_files(self, root: Path) -> list[Path]: ...

    def is_dir(self, path: Path) -> bool: ...

    def is_file(self, path: Path) -> bool: ...

    def read_text(self, path: Path) -> str: ...

    def write_text(self, path: Path, content: str) -> None: ...

    def ensure_dir(self, path: Path) -> None: ...


class RealPushDownFileSystem:
    """
    Implement push-down filesystem operations against the real disk.

    Purpose:
        Provide the production filesystem behavior for source enumeration,
        destination writes, and summary-artifact emission.

    Usage:
        Instantiated by `scripts.dev_tools.push_down_copilot_customizations`
        when callers do not inject a test double.

    Flow:
        Uses `pathlib.Path` primitives for recursive enumeration and UTF-8 text
        I/O.

    Invariants / Constraints:
        The scoped `.github` trees currently contain repository text content, so
        this adapter reads and writes UTF-8 text.

    Side Effects:
        Reads from and writes to the real filesystem.
    """

    def list_files(self, root: Path) -> list[Path]:
        """
        Return all files beneath a root path in sorted order.

        Purpose:
            Preserve deterministic enumeration for summary artifacts and tests.

        Args:
            root (Path): Root path to enumerate.

        Returns:
            list[Path]: Sorted file paths beneath `root`.

        Raises:
            None.

        Side Effects:
            Reads directory metadata from disk.
        """
        if not root.is_dir():
            return []

        files: list[Path] = []
        # Collect files in stable order so summary artifacts remain deterministic.
        for path in root.rglob("*"):
            if path.is_file():
                files.append(path)
        return sorted(files)

    def is_dir(self, path: Path) -> bool:
        """
        Return whether the path is an existing directory.

        Purpose:
            Support destination validation without leaking `pathlib` directly
            into the orchestration layer.

        Args:
            path (Path): Path to inspect.

        Returns:
            bool: True when `path` exists and is a directory.

        Raises:
            None.

        Side Effects:
            Reads filesystem metadata.
        """
        return path.is_dir()

    def is_file(self, path: Path) -> bool:
        """
        Return whether the path is an existing file.

        Purpose:
            Let the publisher classify writes as created versus overwritten.

        Args:
            path (Path): Path to inspect.

        Returns:
            bool: True when `path` exists and is a file.

        Raises:
            None.

        Side Effects:
            Reads filesystem metadata.
        """
        return path.is_file()

    def read_text(self, path: Path) -> str:
        """
        Read UTF-8 text from a file path.

        Purpose:
            Provide the production text-read primitive used by the publisher.

        Args:
            path (Path): File path to read.

        Returns:
            str: File content decoded as UTF-8.

        Raises:
            OSError: Propagated when the file cannot be read.

        Side Effects:
            Reads file contents from disk.
        """
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        """
        Write UTF-8 text to a file path.

        Purpose:
            Persist copied customization content and summary artifacts.

        Args:
            path (Path): Destination file path.
            content (str): UTF-8 text to write.

        Returns:
            None.

        Raises:
            OSError: Propagated when the file cannot be written.

        Side Effects:
            Creates parent directories and writes LF-normalized file content to
            disk.
        """
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8", newline="\n")

    def ensure_dir(self, path: Path) -> None:
        """
        Ensure a directory exists.

        Purpose:
            Share one directory-creation primitive between destination writes
            and artifact output.

        Args:
            path (Path): Directory path to create.

        Returns:
            None.

        Raises:
            OSError: Propagated when the directory cannot be created.

        Side Effects:
            Creates the directory path on disk when needed.
        """
        path.mkdir(parents=True, exist_ok=True)
