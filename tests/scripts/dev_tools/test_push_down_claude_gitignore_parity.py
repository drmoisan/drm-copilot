"""Fixture parity test for the Python managed ``.gitignore`` merge (issue #790).

Purpose:
    Assert that the Python ``merge_claude_gitignore`` reproduces every case of
    the shared fixture ``tests/fixtures/push_down/gitignore-merge-parity.json``
    byte-for-byte. The same fixture is asserted against the TypeScript merge by
    ``extensions/drm-copilot/test/lib/push-down/claude-gitignore-merge-parity.test.ts``.
    The merge module is imported inside the test body so this file collects
    before the module exists.
"""

from __future__ import annotations

import importlib
import json
from pathlib import Path
from typing import Any, cast

REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_PATH = Path("tests/fixtures/push_down/gitignore-merge-parity.json")
EXPECTED_CASE_NAMES = [
    "absent",
    "content-without-block",
    "up-to-date-block",
    "stale-block-with-surrounding-content",
    "duplicate-entry-outside-block",
    "no-trailing-newline",
    "crlf-input",
    "lone-cr-input",
    "begin-without-end",
    "end-before-begin",
    "multiple-trailing-blank-lines",
]
_BEGIN_SENTINEL = "# BEGIN drm-copilot managed ignores"
_END_SENTINEL = "# END drm-copilot managed ignores"


def _block_entries(text: str) -> list[str]:
    """Return the lines strictly between the first BEGIN and the END after it."""

    lines = text.split("\n")
    begin_index = lines.index(_BEGIN_SENTINEL)
    end_index = lines.index(_END_SENTINEL, begin_index)
    return lines[begin_index + 1 : end_index]


def test_gitignore_merge_fixture_parity() -> None:
    """The Python merge reproduces every shared fixture case byte-for-byte."""

    # The fixture is loaded as a loose mapping at this single test-local
    # boundary, matching the routing-merge parity test.
    fixture = cast(
        "dict[str, Any]",
        json.loads((REPO_ROOT / FIXTURE_PATH).read_text(encoding="utf-8")),
    )
    merge_module = importlib.import_module(
        "scripts.dev_tools.push_down_claude_gitignore_merge"
    )
    cases = cast("list[dict[str, str]]", fixture["cases"])

    assert [case["name"] for case in cases] == EXPECTED_CASE_NAMES
    for case in cases:
        assert set(case) == {"name", "current", "expected"}, case["name"]
        merged = merge_module.merge_claude_gitignore(case["current"])
        assert merged == case["expected"], case["name"]
        assert _block_entries(case["expected"]) == [
            ".claude/state/",
            ".codex/state/",
        ], case["name"]
