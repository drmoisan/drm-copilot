"""Regression tests for Ruff configuration alignment.

These tests guard the fix for issue #515. The ``[tool.ruff]`` table must not
enable fix mode: with fix mode on, the agent-facing ``poetry run ruff check``
invocation rewrites fixable violations in place and still exits ``0``, so the
lint stage silently modifies the working tree and reports success.

The assertions read committed text and query the filesystem for the absence of
two paths. No subprocess is spawned, no fixture file is written, and no
temporary file is created, per ``.claude/rules/general-unit-test.md``.
"""

from __future__ import annotations

import re
from pathlib import Path

_REPOSITORY_ROOT = Path(__file__).resolve().parents[3]

_WORKFLOW_RELATIVE_PATH = ".github/workflows/_quality-checks.yml"

# A TOML table header occupying its own line, for example ``[tool.ruff.lint]``.
_TABLE_HEADER = re.compile(r"^\s*\[[^\]]+\]\s*$")

# Matched against comment-stripped, whitespace-trimmed table body lines, so
# ``fix=true``, ``fix  =  true`` and ``fix = true  # note`` all match while a
# commented-out ``# fix = true`` does not.
_FIX_ENABLED = re.compile(r"^fix\s*=\s*true$", re.IGNORECASE)
_SHOW_FIXES_ENABLED = re.compile(r"^show-fixes\s*=\s*true$", re.IGNORECASE)

_RUFF_LINT_INVOCATION = re.compile(r"\bruff\s+check\b")
_YAML_NAME_KEY = re.compile(r"^-?\s*name\s*:")

_STANDALONE_RUFF_CONFIG_NAMES = ("ruff.toml", ".ruff.toml")


def _read_repository_text(relative_path: str) -> str:
    """Load and return the UTF-8 text of a repository file."""
    return (_REPOSITORY_ROOT / relative_path).read_text(encoding="utf-8")


def _strip_comment(line: str) -> str:
    """Return ``line`` without a trailing TOML comment, whitespace-trimmed."""
    return line.split("#", 1)[0].strip()


def _tool_ruff_table_lines() -> list[str]:
    """Return the comment-free body lines of the ``[tool.ruff]`` table.

    Scanning the table body rather than the whole document keeps the assertions
    scoped to Ruff's own settings, and stripping comments before matching makes
    them tolerant of whitespace and comment variation instead of pinned to one
    byte sequence.
    """
    body: list[str] = []
    inside_tool_ruff = False
    for raw_line in _read_repository_text("pyproject.toml").splitlines():
        if _TABLE_HEADER.match(raw_line):
            header = _strip_comment(raw_line).replace(" ", "")
            inside_tool_ruff = header == "[tool.ruff]"
            continue
        if inside_tool_ruff:
            body.append(_strip_comment(raw_line))
    return body


def test_ruff_config_does_not_enable_fix_mode() -> None:
    """The ``[tool.ruff]`` table must not enable Ruff fix mode."""
    offending = [line for line in _tool_ruff_table_lines() if _FIX_ENABLED.match(line)]
    assert offending == [], (
        "[tool.ruff] in pyproject.toml enables fix mode. The bare "
        "`poetry run ruff check` invocation then rewrites fixable violations "
        "in place and still exits 0, so the lint stage silently modifies the "
        f"working tree and reports success (issue #515). Offending: {offending}"
    )


def test_ruff_config_retains_show_fixes() -> None:
    """``show-fixes = true`` must remain in the ``[tool.ruff]`` table."""
    body = _tool_ruff_table_lines()
    assert any(_SHOW_FIXES_ENABLED.match(line) for line in body), (
        "[tool.ruff] in pyproject.toml no longer sets `show-fixes = true`. "
        "With fix mode off, show-fixes is what reports which findings are "
        "fixable, so dropping it would hide the diagnostic the fix preserves "
        f"(issue #515). Table body read: {body}"
    )


def test_no_standalone_ruff_config_at_repository_root() -> None:
    """No standalone Ruff config may sit at the repository root."""
    present = [
        name
        for name in _STANDALONE_RUFF_CONFIG_NAMES
        if (_REPOSITORY_ROOT / name).exists()
    ]
    assert present == [], (
        "A standalone Ruff configuration file exists at the repository root. "
        "It would take precedence over the [tool.ruff] table in pyproject.toml "
        "and could reinstate fix mode without failing the other tests in this "
        f"module (issue #515). Found: {present}"
    )


def test_quality_checks_workflow_still_runs_a_ruff_lint_step() -> None:
    """The quality-checks workflow must still invoke the Ruff linter."""
    workflow_lines = _read_repository_text(_WORKFLOW_RELATIVE_PATH).splitlines()
    invocations = [
        stripped
        for stripped in (line.strip() for line in workflow_lines)
        if _RUFF_LINT_INVOCATION.search(stripped) and not _YAML_NAME_KEY.match(stripped)
    ]
    assert invocations != [], (
        f"{_WORKFLOW_RELATIVE_PATH} no longer invokes the Ruff linter. The "
        "other tests in this module would still pass if the lint gate were "
        "deleted, so this test asserts the invocation itself rather than the "
        "step name (issue #515)."
    )
