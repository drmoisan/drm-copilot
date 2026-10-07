"""Shared scope rules for the distributable `.claude` payload (issue #510).

Some subtrees of `.claude/` are gitignored, machine-local runtime state and are
never part of the distributable payload:

- `.claude/worktrees/` (`.gitignore` line 23),
- `.claude/agent-memory/` (`.gitignore` line 69),
- `.claude/state/` (`.gitignore` line 70).

`.claude/settings.local.json` is a single local-override file rather than a
subtree, so it is listed as an explicit file entry instead of a subdirectory.

Matching is performed on `Path.parts` and never on substrings, so lookalike names
such as `.claude/statement.md` or `.claude/hooks/state/x.ps1` are retained.

This module is pure: no filesystem access, no subprocess, no logging.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Iterable

LOCAL_ONLY_CLAUDE_SUBDIRS: frozenset[str] = frozenset(
    {"agent-memory", "state", "worktrees"}
)
LOCAL_ONLY_CLAUDE_FILES: frozenset[Path] = frozenset(
    {Path(".claude/settings.local.json")}
)


def is_local_runtime_path(relative_path: Path) -> bool:
    """Return True when the repo-relative path is gitignored local runtime state."""
    parts = relative_path.parts[:2]
    if (
        len(parts) == 2
        and parts[0] == ".claude"
        and parts[1] in LOCAL_ONLY_CLAUDE_SUBDIRS
    ):
        return True
    return relative_path in LOCAL_ONLY_CLAUDE_FILES


def filter_distributable_claude_paths(paths: Iterable[Path]) -> list[Path]:
    """Return, in input order, the paths that are not local runtime state."""
    return [path for path in paths if not is_local_runtime_path(path)]
