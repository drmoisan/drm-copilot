"""
Tests for agentic_sync module.

Purpose:
    Validate synchronization rules for .github document syncing using an
    in-memory filesystem to avoid touching the real filesystem.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import pytest

from scripts.dev_tools import agentic_sync


@dataclass
class MemoryFile:
    """In-memory file record for sync testing."""

    content: str
    mtime: float


class InMemorySyncFileSystem(agentic_sync.SyncFileSystem):
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


def _make_repo_paths() -> tuple[Path, Path]:
    """Return repo root paths for tests."""
    return Path("/repo-left"), Path("/repo-right")


def _add_files(
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


def test_sync_equivalent_mtime_skips_content() -> None:
    """Sync should short-circuit when mtimes are within threshold."""
    fs = InMemorySyncFileSystem()
    repo_left, repo_right = _make_repo_paths()
    root = Path(".github/agents")
    _add_files(
        fs,
        repo_left=repo_left,
        repo_right=repo_right,
        root=root,
        relative="agent.md",
        left_content="left",
        right_content="right",
        left_mtime=100.0,
        right_mtime=150.0,
    )
    syncer = agentic_sync.AgenticSyncer(fs, threshold_seconds=60)

    summary = syncer.sync_repos(repo_left, repo_right)

    assert summary.actions
    action = summary.actions[0]
    assert action.decision == "equivalent-mtime"
    assert fs.read_text(repo_left / root / "agent.md") == "left"
    assert fs.read_text(repo_right / root / "agent.md") == "right"


def test_sync_equivalent_content_skips_write() -> None:
    """Sync should treat identical content as equivalent."""
    fs = InMemorySyncFileSystem()
    repo_left, repo_right = _make_repo_paths()
    root = Path(".github/instructions")
    _add_files(
        fs,
        repo_left=repo_left,
        repo_right=repo_right,
        root=root,
        relative="policy.md",
        left_content="same",
        right_content="same",
        left_mtime=100.0,
        right_mtime=400.0,
    )
    syncer = agentic_sync.AgenticSyncer(fs, threshold_seconds=60)

    summary = syncer.sync_repos(repo_left, repo_right)

    assert summary.actions[0].decision == "equivalent-content"
    assert fs.get_mtime(repo_left / root / "policy.md") == 100.0
    assert fs.get_mtime(repo_right / root / "policy.md") == 400.0


def test_sync_newer_content_propagates_and_normalizes_mtime() -> None:
    """Sync should propagate newer content and align timestamps."""
    fs = InMemorySyncFileSystem()
    repo_left, repo_right = _make_repo_paths()
    root = Path(".github/prompts")
    _add_files(
        fs,
        repo_left=repo_left,
        repo_right=repo_right,
        root=root,
        relative="prompt.md",
        left_content="old",
        right_content="new",
        left_mtime=100.0,
        right_mtime=300.0,
    )
    syncer = agentic_sync.AgenticSyncer(fs, threshold_seconds=60)

    summary = syncer.sync_repos(repo_left, repo_right)

    action = summary.actions[0]
    assert action.decision == "synced"
    assert action.source == "right"
    assert fs.read_text(repo_left / root / "prompt.md") == "new"
    assert fs.read_text(repo_right / root / "prompt.md") == "new"
    assert fs.get_mtime(repo_left / root / "prompt.md") == 300.0
    assert fs.get_mtime(repo_right / root / "prompt.md") == 300.0


def test_force_left_to_right_overrides_newer_right() -> None:
    """Forced direction should override timestamp-based selection."""
    fs = InMemorySyncFileSystem()
    repo_left, repo_right = _make_repo_paths()
    root = Path(".github/skills")
    _add_files(
        fs,
        repo_left=repo_left,
        repo_right=repo_right,
        root=root,
        relative="skill.md",
        left_content="left",
        right_content="right",
        left_mtime=100.0,
        right_mtime=500.0,
    )
    syncer = agentic_sync.AgenticSyncer(
        fs,
        threshold_seconds=60,
        force_direction="left-to-right",
    )

    summary = syncer.sync_repos(repo_left, repo_right)

    action = summary.actions[0]
    assert action.decision == "synced"
    assert action.source == "left"
    assert action.forced is True
    assert fs.read_text(repo_left / root / "skill.md") == "left"
    assert fs.read_text(repo_right / root / "skill.md") == "left"
    assert fs.get_mtime(repo_left / root / "skill.md") == 100.0
    assert fs.get_mtime(repo_right / root / "skill.md") == 100.0


def test_sync_repos_ignores_files_missing_on_one_side() -> None:
    """Ignore files that exist in only one repo so two-way sync stays unchanged."""
    fs = InMemorySyncFileSystem()
    repo_left, repo_right = _make_repo_paths()
    root = Path(".github/prompts")

    left_only_path = repo_left / root / "left-only.prompt.md"
    fs.write_text(left_only_path, "left only")
    fs.set_mtime(left_only_path, 100.0)

    summary = agentic_sync.AgenticSyncer(fs).sync_repos(repo_left, repo_right)

    assert summary.actions == []
    assert fs.read_text(left_only_path) == "left only"
    assert fs.get_file(repo_right / root / "left-only.prompt.md") is None


def test_build_artifact_path_uses_timestamp() -> None:
    """Artifact path should include timestamp and folder path."""
    started = agentic_sync.datetime(
        2026, 2, 9, 12, 34, 56, tzinfo=agentic_sync.timezone.utc
    )
    repo_root = Path("/repo")
    path = agentic_sync.build_artifact_path(repo_root, started)
    assert "artifacts" in path.parts
    assert "agentic-sync" in path.parts
    assert path.name == "sync-20260209T123456Z.json"


def test_render_sync_summary_serializes_actions() -> None:
    """Render should produce JSON with actions."""
    action = agentic_sync.SyncAction(
        root=".github/agents",
        relative_path="agent.md",
        left_path="/left/.github/agents/agent.md",
        right_path="/right/.github/agents/agent.md",
        left_mtime=100.0,
        right_mtime=120.0,
        decision="equivalent-mtime",
        source=None,
        sync_mtime=None,
        forced=False,
    )
    summary = agentic_sync.SyncSummary(
        repo_left="/left",
        repo_right="/right",
        started_at=agentic_sync.datetime(
            2026, 2, 9, 12, 0, tzinfo=agentic_sync.timezone.utc
        ),
        finished_at=agentic_sync.datetime(
            2026, 2, 9, 12, 1, tzinfo=agentic_sync.timezone.utc
        ),
        force_direction=None,
        actions=[action],
    )
    rendered = agentic_sync.render_sync_summary(summary)
    assert '"actions"' in rendered
    assert "agent.md" in rendered


def test_write_sync_artifact_creates_dir_and_writes() -> None:
    """Write should create the artifacts directory and write content."""
    fs = InMemorySyncFileSystem()
    action = agentic_sync.SyncAction(
        root=".github/agents",
        relative_path="agent.md",
        left_path="/left/.github/agents/agent.md",
        right_path="/right/.github/agents/agent.md",
        left_mtime=100.0,
        right_mtime=120.0,
        decision="equivalent-mtime",
        source=None,
        sync_mtime=None,
        forced=False,
    )
    summary = agentic_sync.SyncSummary(
        repo_left="/left",
        repo_right="/right",
        started_at=agentic_sync.datetime(
            2026, 2, 9, 12, 0, tzinfo=agentic_sync.timezone.utc
        ),
        finished_at=agentic_sync.datetime(
            2026, 2, 9, 12, 1, tzinfo=agentic_sync.timezone.utc
        ),
        force_direction=None,
        actions=[action],
    )
    repo_root = Path("/repo")
    path = agentic_sync.write_sync_artifact(fs, repo_root, summary)

    assert fs.is_file(path)
    assert path.parent in fs.directories
    assert "agent.md" in fs.read_text(path)


def test_parse_args_defaults() -> None:
    """Arg parsing should handle required args and defaults."""
    args = agentic_sync.parse_args(["/left", "/right"])
    assert args.left_repo == "/left"
    assert args.right_repo == "/right"
    assert args.threshold_seconds == 180
    assert args.force_left_to_right is False
    assert args.force_right_to_left is False


def test_parse_args_force_flags() -> None:
    """Arg parsing should handle flags."""
    args = agentic_sync.parse_args(
        ["/left", "/right", "--force-left-to-right", "--threshold-seconds", "60"]
    )
    assert args.force_left_to_right is True
    assert args.threshold_seconds == 60


def test_main_runs_sync(monkeypatch: pytest.MonkeyPatch) -> None:
    """Main entry point should run the sync process."""
    # Mock passed args
    args = ["/left", "/right"]

    # Mock Path to pass validation
    class MockPath:
        def __init__(self, path: str) -> None:
            self.path = path

        def expanduser(self) -> MockPath:
            return self

        def resolve(self) -> MockPath:
            return self

        def is_dir(self) -> bool:
            return True

        def __str__(self) -> str:
            return self.path

        def __truediv__(self, other: str) -> MockPath:
            return MockPath(f"{self.path}/{other}")

        # Add basic attributes expected by other parts if main doesn't crash
        @staticmethod
        def cwd() -> MockPath:
            return MockPath("/cwd")

        @property
        def parent(self) -> MockPath:
            return MockPath("/cwd")  # simplistic

        def as_posix(self) -> str:
            return self.path

    # Monkeypatch Path in agentic_sync
    monkeypatch.setattr(agentic_sync, "Path", MockPath)

    # Mock RealSyncFileSystem
    class MockFs:
        def ensure_dir(self, path: MockPath) -> None:
            pass

        def write_text(self, path: MockPath, content: str) -> None:
            pass

    monkeypatch.setattr(agentic_sync, "RealSyncFileSystem", MockFs)

    # Mock AgenticSyncer
    summary = agentic_sync.SyncSummary(
        repo_left="/left",
        repo_right="/right",
        started_at=agentic_sync.datetime.now(agentic_sync.timezone.utc),
        finished_at=agentic_sync.datetime.now(agentic_sync.timezone.utc),
        force_direction=None,
        actions=[],
    )

    class MockSyncer:
        def __init__(
            self, fs: object, threshold_seconds: int, force_direction: object
        ) -> None:
            pass

        def sync_repos(self, left: object, right: object) -> agentic_sync.SyncSummary:
            return summary

    monkeypatch.setattr(agentic_sync, "AgenticSyncer", MockSyncer)

    # Run main
    exit_code = agentic_sync.main(args)
    assert exit_code == 0
