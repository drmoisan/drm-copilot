"""
Tests for the agentic_sync artifact, argument and entry-point surface.

Purpose:
    Validate artifact placement and rendering, argument parsing, the CLI entry
    point and the scoped-root contract through the compatibility names the
    ``agentic_sync`` module keeps exporting after the file-size split.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import pytest

from scripts.dev_tools import agentic_sync
from tests.scripts.dev_tools.agentic_sync_test_support import InMemorySyncFileSystem


def test_build_artifact_path_uses_timestamp() -> None:
    """Artifact path should include timestamp and folder path."""
    started = agentic_sync.datetime(2026, 2, 9, 12, 34, 56, tzinfo=agentic_sync.UTC)
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
        started_at=agentic_sync.datetime(2026, 2, 9, 12, 0, tzinfo=agentic_sync.UTC),
        finished_at=agentic_sync.datetime(2026, 2, 9, 12, 1, tzinfo=agentic_sync.UTC),
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
        started_at=agentic_sync.datetime(2026, 2, 9, 12, 0, tzinfo=agentic_sync.UTC),
        finished_at=agentic_sync.datetime(2026, 2, 9, 12, 1, tzinfo=agentic_sync.UTC),
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
        started_at=agentic_sync.datetime.now(agentic_sync.UTC),
        finished_at=agentic_sync.datetime.now(agentic_sync.UTC),
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


def test_root_folders_include_published_github_hooks_in_scoped_order() -> None:
    """Keep `.github/hooks` in the shared scoped-root contract in sorted order."""

    assert agentic_sync.ROOT_FOLDERS == (
        Path(".github/agents"),
        Path(".github/hooks"),
        Path(".github/instructions"),
        Path(".github/prompts"),
        Path(".github/skills"),
    )
