"""Unit tests for the Python managed ``.gitignore`` merge (issue #790).

Purpose:
    Pin ``merge_claude_gitignore`` and its constants against the TypeScript
    ``mergeClaudeGitignore`` behavior. The module under test is imported inside
    each test body so this file collects before the module exists.
"""

from __future__ import annotations

import importlib
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from types import ModuleType

BLOCK_TEXT = (
    "# BEGIN drm-copilot managed ignores\n"
    ".claude/state/\n"
    ".codex/state/\n"
    "# END drm-copilot managed ignores\n"
)


def _module() -> ModuleType:
    """Import the gitignore merge module under test."""

    return importlib.import_module("scripts.dev_tools.push_down_claude_gitignore_merge")


def test_constants_match_typescript_values() -> None:
    """The module constants equal the TypeScript sentinel and entry values."""

    module = _module()

    assert module.GITIGNORE_RELATIVE_PATH == ".gitignore"
    assert module.GITIGNORE_BEGIN_SENTINEL == "# BEGIN drm-copilot managed ignores"
    assert module.GITIGNORE_END_SENTINEL == "# END drm-copilot managed ignores"
    assert module.MANAGED_IGNORE_ENTRIES == (".claude/state/", ".codex/state/")


def test_merge_absent_input_returns_bare_block() -> None:
    """An absent file (empty text) merges to the bare managed block."""

    module = _module()

    result = module.merge_claude_gitignore("")

    assert result == BLOCK_TEXT


def test_merge_appends_block_after_one_blank_line() -> None:
    """Existing content without a block gains the block after one blank line."""

    module = _module()

    result = module.merge_claude_gitignore("node_modules/\n*.log\n")

    assert result == "node_modules/\n*.log\n\n" + BLOCK_TEXT


def test_merge_replaces_stale_block_in_place() -> None:
    """A stale block is replaced in place and surrounding lines are kept."""

    module = _module()
    current = (
        "dist/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n"
        "# END drm-copilot managed ignores\ncoverage/\n"
    )
    expected = (
        "dist/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n"
        "# END drm-copilot managed ignores\ncoverage/\n"
    )

    result = module.merge_claude_gitignore(current)

    assert result == expected


def test_merge_up_to_date_block_is_fixed_point() -> None:
    """Text holding an up-to-date block merges to itself."""

    module = _module()

    result = module.merge_claude_gitignore("node_modules/\n\n" + BLOCK_TEXT)

    assert result == "node_modules/\n\n" + BLOCK_TEXT


def test_merge_is_idempotent() -> None:
    """Merging the merged output again returns the same text."""

    module = _module()
    inputs = [
        "",
        "a/\n",
        BLOCK_TEXT,
        "x\r\ny\r\n",
        "# BEGIN drm-copilot managed ignores\nz/\n",
    ]

    for current in inputs:
        once = module.merge_claude_gitignore(current)
        twice = module.merge_claude_gitignore(once)

        assert twice == once, repr(current)


def test_merge_input_without_trailing_newline() -> None:
    """Content without a final newline gains the block after one blank line."""

    module = _module()

    result = module.merge_claude_gitignore("node_modules/")

    assert result == "node_modules/\n\n" + BLOCK_TEXT


def test_merge_normalizes_crlf_input() -> None:
    """CRLF input is normalized to LF-only output."""

    module = _module()

    result = module.merge_claude_gitignore("node_modules/\r\n*.log\r\n")

    assert result == "node_modules/\n*.log\n\n" + BLOCK_TEXT
    assert "\r" not in result


def test_merge_normalizes_lone_cr_input() -> None:
    """Lone carriage returns are treated as line breaks."""

    module = _module()

    result = module.merge_claude_gitignore("node_modules/\r*.log\r")

    assert result == "node_modules/\n*.log\n\n" + BLOCK_TEXT


def test_merge_blank_only_input_returns_bare_block() -> None:
    """Input holding only blank lines merges to the bare managed block."""

    module = _module()

    result = module.merge_claude_gitignore("\n\n")

    assert result == BLOCK_TEXT


def test_merge_strips_multiple_trailing_blank_lines_before_append() -> None:
    """Several trailing blank lines collapse to one separator line."""

    module = _module()

    result = module.merge_claude_gitignore("node_modules/\n\n\n\n")

    assert result == "node_modules/\n\n" + BLOCK_TEXT


def test_merge_begin_without_end_keeps_later_lines() -> None:
    """A BEGIN sentinel without END is replaced alone and later lines are kept."""

    module = _module()
    current = "dist/\n# BEGIN drm-copilot managed ignores\nstale-entry/\n"
    expected = (
        "dist/\n# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n"
        "# END drm-copilot managed ignores\nstale-entry/\n"
    )

    result = module.merge_claude_gitignore(current)

    assert result == expected


def test_merge_ignores_end_before_begin() -> None:
    """An END sentinel before the first BEGIN does not close the block."""

    module = _module()
    current = (
        "# END drm-copilot managed ignores\nkeep/\n"
        "# BEGIN drm-copilot managed ignores\nold/\n"
        "# END drm-copilot managed ignores\n"
    )
    expected = (
        "# END drm-copilot managed ignores\nkeep/\n"
        "# BEGIN drm-copilot managed ignores\n.claude/state/\n.codex/state/\n"
        "# END drm-copilot managed ignores\n"
    )

    result = module.merge_claude_gitignore(current)

    assert result == expected


def test_merge_keeps_managed_entry_duplicated_outside_block() -> None:
    """A managed entry outside the block is kept, not deduplicated."""

    module = _module()

    result = module.merge_claude_gitignore(".claude/state/\nbuild/\n")

    assert result == ".claude/state/\nbuild/\n\n" + BLOCK_TEXT
    assert result.split("\n").count(".claude/state/") == 2


def test_merge_sentinel_with_trailing_whitespace_does_not_match() -> None:
    """A sentinel line with trailing whitespace is not an exact match."""

    module = _module()
    current = (
        "# BEGIN drm-copilot managed ignores \n.claude/state/\n"
        "# END drm-copilot managed ignores\n"
    )

    result = module.merge_claude_gitignore(current)

    assert result == current + "\n" + BLOCK_TEXT


def test_merge_considers_only_first_begin_sentinel() -> None:
    """Only the first BEGIN sentinel opens the managed block."""

    module = _module()
    current = BLOCK_TEXT + "x/\n# BEGIN drm-copilot managed ignores\ny/\n"

    result = module.merge_claude_gitignore(current)

    assert result == current
    assert result.split("\n").count("# BEGIN drm-copilot managed ignores") == 2
