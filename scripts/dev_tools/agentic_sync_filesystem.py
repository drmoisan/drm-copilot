"""Filesystem seam for the agentic sync engine.

Purpose:
    Define the ``SyncFileSystem`` protocol the sync engine depends on and the
    ``RealSyncFileSystem`` adapter that reads, writes and touches files on disk,
    so the engine and its artifact writer can run against an in-memory double.
"""

from __future__ import annotations

import os
from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from pathlib import Path


class SyncFileSystem(Protocol):
    """
    Protocol for filesystem operations required by the sync engine.

    Purpose:
        Abstracts file system access so that unit tests can run without touching
        the real filesystem, while production uses a concrete implementation.

    Usage:
        Implement with RealSyncFileSystem for production or an in-memory test
        double for unit tests.

    Invariants / Constraints:
        - Paths passed in are absolute or workspace-relative Path objects.
        - get_mtime raises FileNotFoundError for missing paths.
        - read_text raises FileNotFoundError for missing paths.

    Side Effects:
        Implementations may read/write disk, or mutate in-memory stores.
    """

    def list_files(self, root: Path) -> list[Path]:
        """Return all files under root (recursive)."""
        ...

    def is_file(self, path: Path) -> bool:
        """Return True when path exists and is a file."""
        ...

    def read_text(self, path: Path) -> str:
        """Read UTF-8 text from path."""
        ...

    def write_text(self, path: Path, content: str) -> None:
        """Write UTF-8 text to path."""
        ...

    def get_mtime(self, path: Path) -> float:
        """Return file modification time (seconds since epoch)."""
        ...

    def set_mtime(self, path: Path, mtime: float) -> None:
        """Set file modification time (seconds since epoch)."""
        ...

    def ensure_dir(self, path: Path) -> None:
        """Ensure directory exists (create if missing)."""
        ...


class RealSyncFileSystem:
    """
    Concrete filesystem implementation for sync operations.

    Purpose:
        Uses pathlib and os utilities to read/write files and mutate timestamps
        on the real filesystem.

    Usage:
        Injected into AgenticSyncer for production runs.

    Side Effects:
        Reads and writes files on disk and updates file timestamps.
    """

    def list_files(self, root: Path) -> list[Path]:
        """
        Return all files under root (recursive).

        Purpose:
            Provide a deterministic list of files to sync under a root folder.

        Args:
            root (Path): Directory to scan.

        Returns:
            list[Path]: Sorted list of files under root.

        Raises:
            None.

        Side Effects:
            Reads directory contents from disk.
        """
        if not root.is_dir():
            return []

        files: list[Path] = []
        # Collect file paths to provide a deterministic, sorted list for sync.
        for path in root.rglob("*"):
            if path.is_file():
                files.append(path)
        return sorted(files)

    def is_file(self, path: Path) -> bool:
        """
        Return True when path exists and is a file.

        Purpose:
            Provide a lightweight file existence check for sync logic.

        Args:
            path (Path): File path to check.

        Returns:
            bool: True if path is a file, False otherwise.

        Raises:
            None.

        Side Effects:
            Reads filesystem metadata.
        """
        return path.is_file()

    def read_text(self, path: Path) -> str:
        """
        Read UTF-8 text from path.

        Purpose:
            Load file content for comparison and syncing.

        Args:
            path (Path): File path to read.

        Returns:
            str: File contents.

        Raises:
            FileNotFoundError: When the file is missing.

        Side Effects:
            Reads file content from disk.
        """
        return path.read_text(encoding="utf-8")

    def write_text(self, path: Path, content: str) -> None:
        """
        Write UTF-8 text to path.

        Purpose:
            Persist updated file content to disk during synchronization.

        Args:
            path (Path): File path to write.
            content (str): Content to write.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Writes file content to disk and updates modification time.
        """
        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")

    def get_mtime(self, path: Path) -> float:
        """
        Return file modification time (seconds since epoch).

        Purpose:
            Provide mtime values for timestamp comparisons.

        Args:
            path (Path): File path to inspect.

        Returns:
            float: Modification time in seconds since epoch.

        Raises:
            FileNotFoundError: When the file is missing.

        Side Effects:
            Reads filesystem metadata.
        """
        return path.stat().st_mtime

    def set_mtime(self, path: Path, mtime: float) -> None:
        """
        Set file modification time (seconds since epoch).

        Purpose:
            Normalize timestamps after syncing content.

        Args:
            path (Path): File path to update.
            mtime (float): Target modification time.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Updates file timestamps on disk.
        """
        os.utime(path, (mtime, mtime))

    def ensure_dir(self, path: Path) -> None:
        """
        Ensure directory exists (create if missing).

        Purpose:
            Prepare artifact output directories before writing logs.

        Args:
            path (Path): Directory path to create.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Creates directories on disk.
        """
        path.mkdir(parents=True, exist_ok=True)
