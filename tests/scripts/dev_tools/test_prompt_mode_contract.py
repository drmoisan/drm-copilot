"""Tests for scripts.dev_tools.prompt_mode_contract."""

import pytest

from scripts.dev_tools.prompt_mode_contract import (
    build_fallback_reason,
    normalize_requested_work_mode,
    parse_issue_work_mode,
    resolve_selected_work_mode,
)


def test_parse_issue_work_mode_valid_minor_marker() -> None:
    """Parse valid minor-audit marker from issue content."""
    mode, malformed = parse_issue_work_mode("- Work Mode: minor-audit\n")
    assert mode == "minor-audit"
    assert malformed is False


def test_parse_issue_work_mode_valid_full_feature_marker() -> None:
    """Parse valid full-feature marker from issue content."""
    mode, malformed = parse_issue_work_mode("- Work Mode: full-feature\n")
    assert mode == "full-feature"
    assert malformed is False


def test_resolve_selected_work_mode_normalizes_legacy_full_marker() -> None:
    """Normalize legacy full markers to the canonical full-feature variant."""
    assert resolve_selected_work_mode("- Work Mode: full\n") == "full-feature"


def test_resolve_selected_work_mode_fails_closed_when_marker_missing() -> None:
    """Resolve to full-feature when marker is absent."""
    assert resolve_selected_work_mode("# no marker here\n") == "full-feature"


def test_resolve_selected_work_mode_fails_closed_when_marker_malformed() -> None:
    """Resolve to full-feature when marker has unsupported value."""
    assert resolve_selected_work_mode("- Work Mode: maybe\n") == "full-feature"


def test_build_fallback_reason_is_explicit_for_missing_marker() -> None:
    """Return explicit fallback reason text for missing marker scenario."""
    reason = build_fallback_reason("# no marker\n")
    assert reason == "issue.md Work Mode marker missing; fail closed to full-feature"


def test_normalize_requested_work_mode_returns_minor_audit_unchanged() -> None:
    """Preserve minor-audit as-is during requested-mode normalization."""
    assert normalize_requested_work_mode("minor-audit", "feature") == "minor-audit"


def test_normalize_requested_work_mode_accepts_full_feature_for_feature_work() -> None:
    """Accept canonical full-feature mode for feature promotion workflows."""
    assert normalize_requested_work_mode("full-feature", "feature") == "full-feature"


def test_normalize_requested_work_mode_maps_legacy_full_to_full_bug_for_bug_work() -> (
    None
):
    """Normalize legacy full to full-bug when the promotion type is bug."""
    assert normalize_requested_work_mode("full", "bug") == "full-bug"


def test_normalize_requested_work_mode_rejects_full_bug_for_feature_work() -> None:
    """Reject canonical full-bug mode when the promotion type is feature."""
    with pytest.raises(ValueError, match="full-bug may only be used with bug work"):
        normalize_requested_work_mode("full-bug", "feature")


def test_normalize_requested_work_mode_rejects_full_feature_for_bug_work() -> None:
    """Reject canonical full-feature mode when the promotion type is bug."""
    with pytest.raises(ValueError, match="full-feature may not be used with bug work"):
        normalize_requested_work_mode("full-feature", "bug")


def test_build_fallback_reason_returns_none_for_valid_marker() -> None:
    """Return `none` when the issue marker is already valid and canonical."""
    assert build_fallback_reason("- Work Mode: full-feature\n") == "none"


def test_build_fallback_reason_describes_legacy_full_normalization() -> None:
    """Describe the legacy full normalization branch explicitly."""
    assert (
        build_fallback_reason("- Work Mode: full\n")
        == "issue.md Work Mode marker uses legacy full; normalized to full-feature"
    )


def test_build_fallback_reason_describes_malformed_marker() -> None:
    """Describe malformed issue markers with the fail-closed reason string."""
    assert (
        build_fallback_reason("- Work Mode: maybe\n")
        == "issue.md Work Mode marker malformed; fail closed to full-feature"
    )
