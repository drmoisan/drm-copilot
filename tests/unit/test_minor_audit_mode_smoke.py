"""Smoke tests for deterministic work-mode resolution states."""

from __future__ import annotations

import re
from pathlib import Path

WORK_MODE_PATTERN = re.compile(
    r"^-\s*Work Mode:\s*(minor-audit|full)\s*$", re.IGNORECASE
)


def _read_issue_text(path: Path) -> str:
    """Read issue fixture text from disk."""
    return path.read_text(encoding="utf-8")


def resolve_work_mode_from_issue_text(issue_text: str) -> str:
    """Resolve mode and fail closed to full for invalid marker states."""
    for line in issue_text.splitlines():
        match = WORK_MODE_PATTERN.match(line.strip())
        if match:
            return match.group(1).lower()
    return "full"


def test_mode_resolution_selects_minor_audit_for_valid_marker() -> None:
    """Validate valid minor marker resolves to minor-audit mode."""
    fixture = Path("tests/fixtures/minor_audit_mode/issue.valid-minor.md")
    issue_text = _read_issue_text(fixture)

    assert "- Work Mode: minor-audit" in issue_text
    assert resolve_work_mode_from_issue_text(issue_text) == "minor-audit"


def test_mode_resolution_selects_full_for_valid_full_marker() -> None:
    """Validate valid full marker resolves to full mode."""
    fixture = Path("tests/fixtures/minor_audit_mode/issue.valid-full.md")
    issue_text = _read_issue_text(fixture)

    assert "- Work Mode: full" in issue_text
    assert resolve_work_mode_from_issue_text(issue_text) == "full"


def test_mode_resolution_fails_closed_to_full_for_missing_or_malformed_marker() -> None:
    """Validate missing and malformed marker states fail closed to full mode."""
    missing_fixture = Path("tests/fixtures/minor_audit_mode/issue.missing-marker.md")
    malformed_fixture = Path(
        "tests/fixtures/minor_audit_mode/issue.malformed-marker.md"
    )

    missing_text = _read_issue_text(missing_fixture)
    malformed_text = _read_issue_text(malformed_fixture)

    assert "- Work Mode:" not in missing_text
    assert "- Work Mode: minor audit" in malformed_text
    assert resolve_work_mode_from_issue_text(missing_text) == "full"
    assert resolve_work_mode_from_issue_text(malformed_text) == "full"
