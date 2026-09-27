"""Builder tests for the autoclose section (issue #622).

These tests pin the rendering rules the collector relies on:

- D4: an unverified list (GitHub CLI unavailable) carries a trailing annotation.
- D5: an excluded pending primary renders a dedicated not-open fallback.
- D10: the annotation is appended only when the ordered list is non-empty.
- D11: the builder tests live in this #622-owned file.
- D12: the composed fallback precedence across the five documented rows.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools.pr_context.models import (
    AUTOCLOSE_PENDING_NOT_OPEN_TEXT,
    AUTOCLOSE_UNVERIFIED_ANNOTATION,
    section,
)
from scripts.dev_tools.pr_context.render_pr_helpers import (
    build_issues_to_autoclose_section,
)

AUTOCLOSE_HEADER = section("Issues to autoclose (verified or pending)")


def _appends_unverified_annotation_when_gh_unavailable() -> None:
    """An unverified non-empty list is followed by the unverified annotation."""
    # Arrange
    expected_annotation = (
        "Unverified: the issues listed above come from feature metadata only and "
        "were not checked against GitHub (GitHub CLI unavailable)."
    )

    # Act
    result = build_issues_to_autoclose_section(
        verified=[],
        pending_primary=["#7"],
        readiness_signals=["PASS"],
        gh_available=False,
        pending_primary_excluded=False,
    )

    # Assert
    lines = result.splitlines()
    bullet_index = lines.index("- #7")
    annotation_line = lines[bullet_index + 1]
    assert annotation_line == expected_annotation, "annotation must follow the list"
    assert not annotation_line.startswith("- "), "annotation must not be a bullet"


# The collected test name exceeds the 88-column limit on a ``def`` line, so the
# body is bound to that name here; a bare name on its own line is exempt.
(
    test_build_issues_to_autoclose_section_appends_unverified_annotation_when_gh_unavailable
) = _appends_unverified_annotation_when_gh_unavailable


def test_build_issues_to_autoclose_section_omits_annotation_when_gh_available() -> None:
    """A verified-capable run renders the list with no annotation."""
    # Arrange
    expected = "\n".join([AUTOCLOSE_HEADER, "- #7"])

    # Act
    result = build_issues_to_autoclose_section(
        verified=[],
        pending_primary=["#7"],
        readiness_signals=["PASS"],
        gh_available=True,
        pending_primary_excluded=False,
    )

    # Assert
    assert result == expected, "no annotation may be appended when gh is available"


def _renders_not_open_text_when_pending_excluded() -> None:
    """An empty list with an excluded pending primary renders the not-open text."""
    # Arrange
    expected = "\n".join([AUTOCLOSE_HEADER, AUTOCLOSE_PENDING_NOT_OPEN_TEXT])

    # Act
    result = build_issues_to_autoclose_section(
        verified=[],
        pending_primary=[],
        readiness_signals=["PASS"],
        gh_available=True,
        pending_primary_excluded=True,
    )

    # Assert
    assert result == expected, "the excluded primary must select the not-open text"


# Bound to its collected name for the same line-length reason as above.
test_build_issues_to_autoclose_section_renders_not_open_text_when_pending_excluded = (
    _renders_not_open_text_when_pending_excluded
)


@pytest.mark.parametrize(
    (
        "gh_available",
        "verified",
        "pending_primary",
        "readiness_signals",
        "pending_primary_excluded",
        "expected_body",
    ),
    [
        pytest.param(
            True, [], ["#7"], ["PASS"], False, "- #7", id="available-non-empty"
        ),
        pytest.param(
            True,
            [],
            [],
            ["PASS"],
            True,
            "None (deterministic pending issue is not an open issue)",
            id="available-empty-excluded",
        ),
        pytest.param(
            True,
            [],
            [],
            ["PASS"],
            False,
            "None (no verified closing issues and no deterministic pending issue)",
            id="available-empty-pass",
        ),
        pytest.param(
            True,
            [],
            [],
            [],
            False,
            "None (no verified closing issues and readiness not PASS)",
            id="available-empty-non-pass",
        ),
        pytest.param(
            False,
            [],
            ["#7"],
            ["PASS"],
            False,
            "- #7\n" + AUTOCLOSE_UNVERIFIED_ANNOTATION,
            id="unavailable-non-empty",
        ),
    ],
)
def test_build_issues_to_autoclose_section_fallback_precedence(
    gh_available: bool,
    verified: list[str],
    pending_primary: list[str],
    readiness_signals: list[str],
    pending_primary_excluded: bool,
    expected_body: str,
) -> None:
    """Each documented precedence row renders exactly its expected body."""
    # Arrange
    expected = "\n".join([AUTOCLOSE_HEADER, expected_body])

    # Act
    result = build_issues_to_autoclose_section(
        verified=verified,
        pending_primary=pending_primary,
        readiness_signals=readiness_signals,
        gh_available=gh_available,
        pending_primary_excluded=pending_primary_excluded,
    )

    # Assert
    assert result == expected, "the rendered section must match the precedence row"
