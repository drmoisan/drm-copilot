"""Bug-mode issue-body tests for potential-to-issue promotion."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools import potential_to_issue as mod
from tests.scripts.dev_tools.potential_to_issue_test_support import (
    FakeFileSystem,
    FakeGhClient,
)


def test_promote_potential_bug_builds_issue_body_from_bug_sections() -> None:
    """Verify bug promotion renders all bug sections into the created issue body."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/sample-bug.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Sample Bug (Potential Bug)",
            "## Summary",
            "summary details",
            "## Environment",
            "- OS: Linux",
            "## Steps to Reproduce",
            "1. step one",
            "## Expected Behavior",
            "expected results",
            "## Actual Behavior",
            "actual results",
            "## Impact / Severity",
            "medium",
            "## Logs / Screenshots",
            "screenshot attached",
        ]
    )

    create_result = mod.GhResult(["Created: https://example.com/issues/200"], 0)
    view_result = mod.GhResult(
        [
            '{"number":200,"title":"Bug title","url":"https://example.com/issues/200","author":{"login":"me"},"updatedAt":"2024-02-01T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result)

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    assert outcome.exit_code == 0
    verb, (title, body, label) = gh.calls[0]
    assert verb == "create"
    assert title == "Bug: Sample Bug"
    assert label == "bug"
    assert "## Summary\nsummary details" in body
    assert "## Environment\n- OS: Linux" in body
    assert "## Steps to Reproduce\n1. step one" in body
    assert "## Expected Behavior\nexpected results" in body
    assert "## Actual Behavior\nactual results" in body
    assert "## Impact / Severity\nmedium" in body
    assert "## Logs / Screenshots\nscreenshot attached" in body
    assert "## Source\nFrom: docs/features/potential/sample-bug.md" in body


def test_promote_potential_bug_missing_sections_use_placeholders() -> None:
    """Verify missing bug sections are filled with placeholder text."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/placeholder-bug.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(["# Placeholder Bug", "## Summary", "only summary"])

    create_result = mod.GhResult(["Created: https://example.com/issues/300"], 0)
    gh = FakeGhClient(create_result)

    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    _, (_, body, _) = gh.calls[0]
    assert "## Summary\nonly summary" in body
    assert "## Environment\n(not provided in potential file)" in body
    assert "## Steps to Reproduce\n(not provided in potential file)" in body
    assert "## Expected Behavior\n(not provided in potential file)" in body
    assert "## Actual Behavior\n(not provided in potential file)" in body
    assert "## Impact / Severity\n(not provided in potential file)" in body
    assert "## Logs / Screenshots\n(not provided in potential file)" in body


def test_promote_potential_normalizes_smart_punctuation_in_issue_body_and_title() -> (
    None
):
    """Verify smart punctuation is normalized in generated issue title/body."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/smart.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# “Curly” Feature (Potential Bug)",
            "## Summary",
            (
                "Title uses “smart” quotes and an en dash – "
                "plus non-breaking space\u00a0here."
            ),
            "## Environment",
            "- OS: “Windows”\u00a0",
            "## Steps to Reproduce",
            "1. step one with “quote”",
            "## Expected Behavior",
            "expected with em dash — and quote “",
            "## Actual Behavior",
            "actual with smart apostrophe ’",
            "## Impact / Severity",
            "medium",
            "## Logs / Screenshots",
            "none",
        ]
    )

    create_result = mod.GhResult(["Created: https://example.com/issues/400"], 0)
    view_result = mod.GhResult(
        [
            '{"number":400,"title":"t","url":"https://example.com/issues/400","author":{"login":"me"},"updatedAt":"2024-03-01T00:00:00Z"}',
        ],
        0,
    )
    gh = FakeGhClient(create_result, view_result)

    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
    )

    verb, (title, body, label) = gh.calls[0]
    assert verb == "create"
    assert label == "bug"

    assert "Curly" in title and "“" not in title and "”" not in title
    assert "smart" in body and "“" not in body and "”" not in body
    assert "–" not in body and "—" not in body
    assert "\u00a0" not in body


def test_promote_potential_bug_honors_explicit_minor_audit() -> None:
    """Verify bug promotions honor explicit minor-audit selection."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/bug-minor.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Bug Minor Audit",
            "## Problem / Why",
            "problem",
            "## Proposed Behavior",
            "behavior",
            "## Acceptance Criteria (early draft)",
            "criteria",
            "## Constraints & Risks",
            "constraints",
            "## Test Conditions to Consider",
            "tests",
        ]
    )
    messages: list[str] = []
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/58"], 0), mod.GhResult([], 0)
    )
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
        emit=messages.append,
    )
    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    # After the branch reorder a bug promotion routes to the bug body even in
    # minor-audit mode, so the body carries bug headings (not the minor-audit
    # "Implementation Intent" section) while still recording the selected mode.
    assert "## Summary" in body
    assert "## Implementation Intent" not in body
    assert any("Selected mode: minor-audit" in m for m in messages)
    assert not any("Fallback reason:" in m for m in messages)


def test_promote_potential_bug_minor_audit_uses_bug_body() -> None:
    """Verify a bug potential in minor-audit mode renders the bug-headed body (AC-3)."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/minor-bug.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Minor Audit Bug",
            "## Summary",
            "summary details",
            "## Environment",
            "- OS: Linux",
            "## Steps to Reproduce",
            "1. step one",
            "## Expected Behavior",
            "expected results",
            "## Actual Behavior",
            "actual results",
            "## Logs / Screenshots",
            "screenshot attached",
            "## Impact / Severity",
            "medium",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/401"], 0),
        mod.GhResult([], 0),
    )

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )

    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    # The bug body must lead with the minor-audit marker and carry authored
    # bug-section content, not the minor-audit/feature-oriented placeholders.
    assert body.splitlines()[0] == "- Work Mode: minor-audit"
    assert "## Summary\nsummary details" in body
    assert "## Environment\n- OS: Linux" in body
    assert "## Steps to Reproduce\n1. step one" in body
    assert "## Expected Behavior\nexpected results" in body
    assert "## Actual Behavior\nactual results" in body
    assert "## Logs / Screenshots\nscreenshot attached" in body
    assert "## Impact / Severity\nmedium" in body
    assert "## Implementation Intent" not in body
    assert "## Verification Steps" not in body
    assert "(not provided in potential file)" not in body


def test_promote_potential_full_alias_normalizes_bug_to_full_bug() -> None:
    """Verify legacy full alias normalizes to full-bug for bug promotions."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/full-bug-mode.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Full Bug Mode",
            "## Summary",
            "summary",
            "## Expected Behavior",
            "expected",
            "## Actual Behavior",
            "actual",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/100"], 0),
        mod.GhResult([], 0),
    )

    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="bug",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="full",
    )

    body = gh.calls[0][1][1]
    assert "- Work Mode: full-bug" in body
    assert "## Summary" in body
    assert "## Proposed Behavior" not in body
