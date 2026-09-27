"""Tests for the autoclose builder's GitHub-CLI-unavailable body (issue #588)."""

from __future__ import annotations

import pytest

from scripts.dev_tools.pr_context.render_pr_helpers import (
    build_issues_to_autoclose_section,
)

UNAVAILABLE_BODY = "None (GitHub CLI unavailable; closing issues not verified)"


def test_build_issues_to_autoclose_section_reports_gh_unavailable_when_empty() -> None:
    """An empty list with gh unavailable renders exactly the unavailable body."""
    # Arrange
    readiness = ["NEEDS REVISION"]

    # Act
    result = build_issues_to_autoclose_section(
        verified=[],
        pending_primary=[],
        readiness_signals=readiness,
        gh_available=False,
    )

    # Assert
    assert UNAVAILABLE_BODY in result
    assert "None (no verified closing issues" not in result
    assert result.splitlines()[-1] == UNAVAILABLE_BODY


@pytest.mark.parametrize("readiness", [["PASS"]])
def test_build_issues_to_autoclose_section_prefers_unavailable_text_over_pass_readiness(
    readiness: list[str],
) -> None:
    """The unavailable body takes precedence over the PASS-readiness fallback."""
    # Arrange: readiness is PASS, which would otherwise select the PASS fallback.

    # Act
    result = build_issues_to_autoclose_section(
        verified=[],
        pending_primary=[],
        readiness_signals=readiness,
        gh_available=False,
    )

    # Assert
    assert "None (no verified closing issues" not in result
    assert result.splitlines()[-1] == UNAVAILABLE_BODY


def test_build_issues_to_autoclose_section_lists_pending_refs_when_gh_unavailable() -> (
    None
):
    """A non-empty list still renders its bullets and omits the empty-list body."""
    # Arrange
    pending = ["#7"]

    # Act
    result = build_issues_to_autoclose_section(
        verified=[],
        pending_primary=pending,
        readiness_signals=["PASS"],
        gh_available=False,
    )

    # Assert
    assert "- #7" in result
    assert UNAVAILABLE_BODY not in result


@pytest.mark.parametrize(
    ("readiness", "expected"),
    [
        (
            ["PASS"],
            "None (no verified closing issues and no deterministic pending issue)",
        ),
        (
            ["NEEDS REVISION"],
            "None (no verified closing issues and readiness not PASS)",
        ),
    ],
)
def test_build_issues_to_autoclose_section_keeps_available_fallback_texts(
    readiness: list[str], expected: str
) -> None:
    """Omitting gh_available defaults to available and keeps both fallbacks."""
    # Arrange / Act
    result = build_issues_to_autoclose_section(
        verified=[],
        pending_primary=[],
        readiness_signals=readiness,
    )

    # Assert
    assert expected in result
    assert UNAVAILABLE_BODY not in result
