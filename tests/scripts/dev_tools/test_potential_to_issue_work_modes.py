"""Work-mode issue-body tests for potential-to-issue promotion."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools import potential_to_issue as mod
from tests.scripts.dev_tools.potential_to_issue_test_support import (
    FakeFileSystem,
    FakeGhClient,
)


def test_promote_potential_minor_audit_adds_required_issue_sections() -> None:
    """Verify minor-audit mode emits required issue section headings."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/minor.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Minor Audit Feature",
            "- File: scripts/dev_tools/potential_to_issue.py",
            "- File: tests/scripts/dev_tools/test_potential_to_issue.py",
            "- Risk: low",
            "## Problem / Why",
            "problem",
            "## Proposed Behavior",
            "intent",
            "## Acceptance Criteria (early draft)",
            "- [ ] done",
            "## Constraints & Risks",
            "low integration risk",
            "## Test Conditions to Consider",
            "verify this",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/55"], 0), mod.GhResult([], 0)
    )
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )
    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    assert "## Implementation Intent" in body
    assert "## Verification Steps" in body
    assert "## Evidence Checklist" in body


def test_work_mode_marker_minor_audit() -> None:
    """Verify minor-audit issue bodies persist marker above first section heading."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/minor-marker.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Minor Marker Feature",
            "- File: scripts/dev_tools/potential_to_issue.py",
            "- Risk: low",
            "## Problem / Why",
            "problem",
            "## Proposed Behavior",
            "behavior",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/56"], 0), mod.GhResult([], 0)
    )

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )

    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    lines = body.splitlines()
    first_section_index = lines.index("## Problem / Why")
    assert first_section_index > 0
    assert lines[first_section_index - 1] == "- Work Mode: minor-audit"


def test_work_mode_marker_honors_explicit_minor_audit() -> None:
    """Verify explicit minor-audit requests persist a minor-audit marker."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/fallback-marker.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Fallback Marker Feature",
            "- File: a.py",
            "- File: b.py",
            "- File: c.py",
            "- File: d.py",
            "## Problem / Why",
            "problem",
            "## Proposed Behavior",
            "behavior",
        ]
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/57"], 0), mod.GhResult([], 0)
    )

    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )

    assert outcome.exit_code == 0
    body = gh.calls[0][1][1]
    lines = body.splitlines()
    first_section_index = lines.index("## Problem / Why")
    assert first_section_index > 0
    assert lines[first_section_index - 1] == "- Work Mode: minor-audit"


def test_promote_potential_persists_explicit_selected_work_mode() -> None:
    """Verify explicit selection persists as minor-audit."""
    test_work_mode_marker_honors_explicit_minor_audit()


def test_promote_potential_minor_audit_honors_explicit_user_selection() -> None:
    """Verify explicit minor-audit selection is honored."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/not-eligible.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Not Eligible",
            "- File: a.py",
            "- File: b.py",
            "- File: c.py",
            "- File: d.py",
            "## Problem / Why",
            "problem",
            "## Proposed Behavior",
            "behavior",
        ]
    )
    messages: list[str] = []
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/77"], 0), mod.GhResult([], 0)
    )
    outcome = mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
        emit=messages.append,
    )
    assert outcome.exit_code == 0
    assert any("Selected mode: minor-audit" in m for m in messages)
    assert not any("Fallback reason:" in m for m in messages)


def test_promote_potential_full_mode_preserves_existing_body_contract() -> None:
    """Verify legacy full alias preserves the full-feature body contract."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/full-mode.md"
    fs = FakeFileSystem()
    fs.files[potential] = "\n".join(
        [
            "# Full Mode",
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
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/99"], 0), mod.GhResult([], 0)
    )
    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="full",
    )
    body = gh.calls[0][1][1]
    assert "- Work Mode: full-feature" in body
    assert "## Proposed Behavior" in body
    assert "## Implementation Intent" not in body


def test_promote_potential_body_omits_token_like_secret_strings() -> None:
    """Verify generated issue bodies do not include token-like secret substrings."""
    workspace = Path("/workspace")
    potential = workspace / "docs/features/potential/security.md"
    fs = FakeFileSystem()
    fs.files[potential] = (
        "# Security\n"
        "## Problem / Why\n"
        "no tokens\n"
        "## Proposed Behavior\n"
        "no tokens\n"
    )
    gh = FakeGhClient(
        mod.GhResult(["Created: https://example.com/issues/12"], 0), mod.GhResult([], 0)
    )
    mod.promote_potential(
        potential_path=str(potential),
        promotion_type="feature",
        fs=fs,
        gh=gh,
        workspace=workspace,
        work_mode="minor-audit",
    )
    body = gh.calls[0][1][1]
    assert "ghp_" not in body
    assert "xoxb-" not in body
    assert "AIza" not in body
