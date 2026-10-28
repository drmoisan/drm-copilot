"""In-memory filesystem double and repository helpers for the agentic sync suites."""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from scripts.dev_tools.agentic_sync_filesystem import SyncFileSystem


@dataclass
class MemoryFile:
    """In-memory file record for sync testing."""

    content: str
    mtime: float


class InMemorySyncFileSystem(SyncFileSystem):
    """
    In-memory filesystem for agentic_sync tests.

    Purpose:
        Provides deterministic file storage without disk I/O to comply with the
        repo policy that forbids temporary files in tests.
    """

    def __init__(self, files: dict[Path, MemoryFile] | None = None) -> None:
        """
        Initialize the in-memory filesystem.

        Args:
            files (dict[Path, MemoryFile] | None): Optional initial files.
        """
        self._files: dict[Path, MemoryFile] = files or {}
        self.directories: set[Path] = set()

    def get_file(self, path: Path) -> MemoryFile | None:
        """
        Retrieve a file from the in-memory store.

        Purpose:
            Allow tests to inspect file state without accessing private members.
        """
        return self._files.get(path)

    def list_files(self, root: Path) -> list[Path]:
        """
        Return all file paths under root.

        Purpose:
            Provide deterministic file listing for sync comparisons.

        Args:
            root (Path): Root directory to scan.

        Returns:
            list[Path]: Sorted list of file paths.

        Raises:
            None.

        Side Effects:
            None (reads in-memory state only).
        """
        files: list[Path] = []
        # Collect files under the root to simulate recursive globbing.
        for path in self._files:
            if self._is_under(path, root):
                files.append(path)
        return sorted(files)

    def is_file(self, path: Path) -> bool:
        """
        Return True when path exists and is a file.

        Purpose:
            Emulate file existence checks for sync logic.

        Args:
            path (Path): File path to check.

        Returns:
            bool: True if path exists in the in-memory store.

        Raises:
            None.

        Side Effects:
            None.
        """
        return path in self._files

    def read_text(self, path: Path) -> str:
        """
        Read UTF-8 text from path.

        Purpose:
            Provide file content for sync comparisons.

        Args:
            path (Path): File path to read.

        Returns:
            str: File contents.

        Raises:
            FileNotFoundError: When path is missing.

        Side Effects:
            None.
        """
        if path not in self._files:
            raise FileNotFoundError(f"Missing file: {path}")
        return self._files[path].content

    def write_text(self, path: Path, content: str) -> None:
        """
        Write UTF-8 text to path.

        Purpose:
            Update file content while preserving existing mtime by default.

        Args:
            path (Path): File path to write.
            content (str): Content to write.

        Side Effects:
            Overwrites the file and updates parent directory tracking.
        """
        prior = self._files.get(path)
        prior_mtime = prior.mtime if prior else 0.0
        self._files[path] = MemoryFile(content=content, mtime=prior_mtime)
        self.directories.add(path.parent)

    def get_mtime(self, path: Path) -> float:
        """
        Return file modification time.

        Purpose:
            Provide mtime values for sync decision logic.

        Args:
            path (Path): File path to inspect.

        Returns:
            float: Modification time.

        Raises:
            FileNotFoundError: When path is missing.

        Side Effects:
            None.
        """
        if path not in self._files:
            raise FileNotFoundError(f"Missing file: {path}")
        return self._files[path].mtime

    def set_mtime(self, path: Path, mtime: float) -> None:
        """
        Set file modification time.

        Purpose:
            Normalize timestamps during sync operations.

        Args:
            path (Path): File path to update.
            mtime (float): Modification time to set.

        Returns:
            None.

        Raises:
            FileNotFoundError: When path is missing.

        Side Effects:
            None.
        """
        if path not in self._files:
            raise FileNotFoundError(f"Missing file: {path}")
        self._files[path] = MemoryFile(content=self._files[path].content, mtime=mtime)

    def ensure_dir(self, path: Path) -> None:
        """
        Ensure directory exists.

        Purpose:
            Track directories created for artifact output.

        Args:
            path (Path): Directory path to create.

        Returns:
            None.

        Raises:
            None.

        Side Effects:
            Records directory in memory.
        """
        self.directories.add(path)

    def _is_under(self, path: Path, root: Path) -> bool:
        """
        Check whether path is under root.

        Purpose:
            Emulate Path.relative_to behavior for directory containment checks.

        Args:
            path (Path): Path to test.
            root (Path): Root directory.

        Returns:
            bool: True when path is within root.

        Raises:
            None.

        Side Effects:
            None.
        """
        try:
            path.relative_to(root)
        except ValueError:
            return False
        return True


def make_repo_paths() -> tuple[Path, Path]:
    """Return repo root paths for tests."""
    return Path("/repo-left"), Path("/repo-right")


def add_files(
    fs: InMemorySyncFileSystem,
    *,
    repo_left: Path,
    repo_right: Path,
    root: Path,
    relative: str,
    left_content: str,
    right_content: str,
    left_mtime: float,
    right_mtime: float,
) -> tuple[Path, Path]:
    """
    Helper to add file pairs to the in-memory filesystem.

    Args:
        fs (InMemorySyncFileSystem): In-memory filesystem.
        repo_left (Path): Left repo root.
        repo_right (Path): Right repo root.
        root (Path): Root folder within .github.
        relative (str): Relative file path under root.
        left_content (str): Left file contents.
        right_content (str): Right file contents.
        left_mtime (float): Left file mtime.
        right_mtime (float): Right file mtime.

    Returns:
        tuple[Path, Path]: Left and right file paths.
    """
    left_path = repo_left / root / relative
    right_path = repo_right / root / relative
    fs.write_text(left_path, left_content)
    fs.set_mtime(left_path, left_mtime)
    fs.write_text(right_path, right_content)
    fs.set_mtime(right_path, right_mtime)
    return left_path, right_path
