"""Tests for scripts.dev_tools.prompt_mode_contract."""

from scripts.dev_tools.prompt_mode_contract import (
    build_fallback_reason,
    parse_issue_work_mode,
    resolve_selected_work_mode,
)


def test_parse_issue_work_mode_valid_minor_marker() -> None:
    """Parse valid minor-audit marker from issue content."""
    mode, malformed = parse_issue_work_mode("- Work Mode: minor-audit\n")
    assert mode == "minor-audit"
    assert malformed is False


def test_parse_issue_work_mode_valid_full_marker() -> None:
    """Parse valid full marker from issue content."""
    mode, malformed = parse_issue_work_mode("- Work Mode: full\n")
    assert mode == "full"
    assert malformed is False


def test_resolve_selected_work_mode_fails_closed_when_marker_missing() -> None:
    """Resolve to full when marker is absent."""
    assert resolve_selected_work_mode("# no marker here\n") == "full"


def test_resolve_selected_work_mode_fails_closed_when_marker_malformed() -> None:
    """Resolve to full when marker has unsupported value."""
    assert resolve_selected_work_mode("- Work Mode: maybe\n") == "full"


def test_build_fallback_reason_is_explicit_for_missing_marker() -> None:
    """Return explicit fallback reason text for missing marker scenario."""
    reason = build_fallback_reason("# no marker\n")
    assert reason == "issue.md Work Mode marker missing; fail closed to full"
