"""
Tests for agentic_sync module.

Purpose:
    Validate synchronization rules for .github document syncing using an
    in-memory filesystem to avoid touching the real filesystem.
"""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools import agentic_sync
from tests.scripts.dev_tools.agentic_sync_test_support import (
    InMemorySyncFileSystem,
    add_files,
    make_repo_paths,
)


def test_sync_equivalent_mtime_skips_content() -> None:
    """Sync should short-circuit when mtimes are within threshold."""
    fs = InMemorySyncFileSystem()
    repo_left, repo_right = make_repo_paths()
    root = Path(".github/agents")
    add_files(
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
    repo_left, repo_right = make_repo_paths()
    root = Path(".github/instructions")
    add_files(
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
    repo_left, repo_right = make_repo_paths()
    root = Path(".github/prompts")
    add_files(
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
    repo_left, repo_right = make_repo_paths()
    root = Path(".github/skills")
    add_files(
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
    repo_left, repo_right = make_repo_paths()
    root = Path(".github/prompts")

    left_only_path = repo_left / root / "left-only.prompt.md"
    fs.write_text(left_only_path, "left only")
    fs.set_mtime(left_only_path, 100.0)

    summary = agentic_sync.AgenticSyncer(fs).sync_repos(repo_left, repo_right)

    assert summary.actions == []
    assert fs.read_text(left_only_path) == "left only"
    assert fs.get_file(repo_right / root / "left-only.prompt.md") is None
