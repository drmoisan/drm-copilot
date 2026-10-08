"""Unit tests for the shared `.claude` distributable-path scope helper (issue #510).

The helper decides which repository `.claude` paths belong to the distributable
payload and which are gitignored, machine-local runtime state. Every test here
operates on literal `Path` values only: no filesystem access, no subprocess, no
temporary files, and no clock use.
"""

from __future__ import annotations

from pathlib import Path

import pytest

from tests.scripts.dev_tools.claude_payload_scope_test_support import (
    LOCAL_ONLY_CLAUDE_FILES,
    LOCAL_ONLY_CLAUDE_SUBDIRS,
    filter_distributable_claude_paths,
    is_local_runtime_path,
)
from tests.scripts.dev_tools.test_claude_rules_frontmatter import (
    EXCLUDED_CLAUDE_SUBDIRS,
)


def test_state_file_from_issue_report_is_excluded() -> None:
    """The path reported in issue #510 is classified as local runtime state."""
    # Arrange
    reported = Path(".claude/state/python-batch-budget.default.json")

    # Act
    result = is_local_runtime_path(reported)

    # Assert
    assert result is True, "Reported .claude/state file must be excluded"


def test_nested_state_paths_are_excluded() -> None:
    """Deeply nested paths under `.claude/state` are excluded."""
    # Arrange
    nested = Path(".claude/state/a/b/c.json")

    # Act
    result = is_local_runtime_path(nested)

    # Assert
    assert result is True, "Nested .claude/state path must be excluded"


def test_worktrees_paths_are_excluded() -> None:
    """Paths under `.claude/worktrees`, including nested trees, are excluded."""
    # Arrange
    nested = Path(".claude/worktrees/x/.claude/rules/y.md")

    # Act
    result = is_local_runtime_path(nested)

    # Assert
    assert result is True, "Nested .claude/worktrees path must be excluded"


def test_agent_memory_paths_remain_excluded() -> None:
    """Paths under `.claude/agent-memory` remain excluded."""
    # Arrange
    memory = Path(".claude/agent-memory/orchestrator/m.md")

    # Act
    result = is_local_runtime_path(memory)

    # Assert
    assert result is True, "Agent-memory path must remain excluded"


def test_settings_local_json_remains_excluded() -> None:
    """The explicit file entry `.claude/settings.local.json` remains excluded."""
    # Arrange
    settings_local = Path(".claude/settings.local.json")

    # Act
    result = is_local_runtime_path(settings_local)

    # Assert
    assert result is True, "settings.local.json must remain excluded"


@pytest.mark.parametrize(
    "retained",
    [
        Path(".claude/settings.json"),
        Path(".claude/rules/python.md"),
        Path(".claude/statement.md"),
        Path(".claude/hooks/state/x.ps1"),
        Path(".claude/settings.local.json.bak"),
    ],
)
def test_lookalike_and_tracked_paths_are_retained(retained: Path) -> None:
    """Tracked paths and lookalike names are not classified as local runtime state."""
    # Arrange
    candidate = retained

    # Act
    result = is_local_runtime_path(candidate)

    # Assert
    assert result is False, f"{candidate.as_posix()} must be retained"


def test_filter_preserves_order_and_returns_list() -> None:
    """The filter keeps input order for retained paths and returns a `list`."""
    # Arrange
    mixed = [
        Path(".claude/settings.json"),
        Path(".claude/state/x.json"),
        Path(".claude/rules/python.md"),
        Path(".claude/worktrees/w/a.md"),
        Path(".claude/agents/a.md"),
        Path(".claude/settings.local.json"),
    ]

    # Act
    result = filter_distributable_claude_paths(mixed)

    # Assert
    assert isinstance(result, list), "Filter must return a list"
    assert result == [
        Path(".claude/settings.json"),
        Path(".claude/rules/python.md"),
        Path(".claude/agents/a.md"),
    ], "Retained paths must keep input order"


def test_missing_tracked_file_is_still_reported() -> None:
    """A tracked file absent from the bundle still appears in the filtered repo list."""
    # Arrange
    repo_files = [
        Path(".claude/rules/new.md"),
        Path(".claude/state/x.json"),
    ]
    bundle_files: list[Path] = []

    # Act
    filtered_repo = filter_distributable_claude_paths(repo_files)
    missing = [path for path in filtered_repo if path not in bundle_files]

    # Assert
    assert filtered_repo == [Path(".claude/rules/new.md")], "Only tracked path remains"
    assert missing == [Path(".claude/rules/new.md")], "Missing tracked file is reported"


def test_subdirs_match_frontmatter_excluded_subdirs() -> None:
    """The frontmatter test's excluded subdirs are the shared helper constant."""
    # Arrange
    expected = {"agent-memory", "state", "worktrees"}

    # Act
    is_same_object = EXCLUDED_CLAUDE_SUBDIRS is LOCAL_ONLY_CLAUDE_SUBDIRS

    # Assert
    assert (
        is_same_object
    ), "EXCLUDED_CLAUDE_SUBDIRS must be bound to the helper constant"
    assert set(LOCAL_ONLY_CLAUDE_SUBDIRS) == expected, "Subdir set must match contract"
    assert Path(".claude/settings.local.json") in LOCAL_ONLY_CLAUDE_FILES


def test_single_part_claude_path_is_retained() -> None:
    """A bare `.claude` path has no second part and is retained."""
    # Arrange
    bare = Path(".claude")

    # Act
    result = is_local_runtime_path(bare)

    # Assert
    assert result is False, "Single-part .claude path must be retained"


def test_bare_state_path_without_child_is_excluded() -> None:
    """The `.claude/state` directory path itself is excluded."""
    # Arrange
    bare_state = Path(".claude/state")

    # Act
    result = is_local_runtime_path(bare_state)

    # Assert
    assert result is True, "Bare .claude/state path must be excluded"


def test_empty_input_returns_empty_list() -> None:
    """An empty input yields an empty list."""
    # Arrange
    empty: list[Path] = []

    # Act
    result = filter_distributable_claude_paths(empty)

    # Assert
    assert result == [], "Empty input must return an empty list"
