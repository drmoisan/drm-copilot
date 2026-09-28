"""Bare-number issue-reference contract tests for the PR-context extractors.

Issue #622 (D1) narrows every issue-reference extractor to bare GitHub issue
numbers. These tests pin that contract for the three Python extractors and pin
the shared literals against their TypeScript twins in ``models.ts``.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools.pr_context import render_feature_excerpts
from scripts.dev_tools.pr_context.feature_docs import (
    extract_issue_references as feature_docs_extract,
)
from scripts.dev_tools.pr_context.models import (
    AUTOCLOSE_PENDING_NOT_OPEN_TEXT,
    AUTOCLOSE_UNVERIFIED_ANNOTATION,
    ISSUE_REFERENCE_PATTERN,
)
from scripts.dev_tools.pr_context.render_pr_helpers import (
    extract_issue_references as render_pr_helpers_extract,
)

if TYPE_CHECKING:
    from collections.abc import Callable

# The excerpt extractor is private; read it from the module namespace so the
# test needs no suppression comment.
render_feature_excerpts_extract: Callable[[str], list[str]] = vars(
    render_feature_excerpts
)["_extract_issue_references"]

TYPESCRIPT_MODELS_PATH = (
    Path(__file__).resolve().parents[4]
    / "extensions/drm-copilot/src/lib/pr-context/models.ts"
)

EXTRACTORS = [
    pytest.param(feature_docs_extract, id="feature_docs"),
    pytest.param(render_pr_helpers_extract, id="render_pr_helpers"),
    pytest.param(render_feature_excerpts_extract, id="render_feature_excerpts"),
]

REJECTED_INPUTS = [
    "#ISO-8601",
    "#CR-1",
    "ISO-8601",
    "CR-1",
    "UTF-8",
    "SHA-256",
    "AC-12",
    "#12abc",
    "#12_",
    "abc#12",
    "#",
    "#١٢",
    "",
]

ACCEPTED_INPUTS = [
    ("#468", ["#468"]),
    ("(#660)", ["#660"]),
    ("#12-3", ["#12"]),
    ("#12é", ["#12"]),
    ("#7 and #7", ["#7"]),
    ("line one\n#0 starts line two", ["#0"]),
]


@pytest.mark.parametrize("text", REJECTED_INPUTS)
@pytest.mark.parametrize("extract", EXTRACTORS)
def test_extractors_reject_non_bare_number_tokens(
    extract: Callable[[str], list[str]], text: str
) -> None:
    """Return no reference for tokens that are not a bare issue number."""
    # Arrange: the parametrized input carries no bare issue number.

    # Act
    result = extract(text)

    # Assert
    assert result == [], f"expected no references for {text!r}, got {result!r}"


@pytest.mark.parametrize(("text", "expected"), ACCEPTED_INPUTS)
@pytest.mark.parametrize("extract", EXTRACTORS)
def test_extractors_accept_bare_number_tokens(
    extract: Callable[[str], list[str]], text: str, expected: list[str]
) -> None:
    """Return each bare issue number once, in encounter order."""
    # Arrange: the parametrized input carries at least one bare issue number.

    # Act
    result = extract(text)

    # Assert
    assert result == expected, f"expected {expected!r} for {text!r}, got {result!r}"


def test_issue_reference_pattern_matches_typescript_literal() -> None:
    """Keep the Python pattern identical to the TypeScript regular expression."""
    # Arrange
    typescript_source = TYPESCRIPT_MODELS_PATH.read_text(encoding="utf-8")

    # Act
    typescript_literal = f"/{ISSUE_REFERENCE_PATTERN.pattern}/u"

    # Assert
    assert typescript_literal in typescript_source
    assert ISSUE_REFERENCE_PATTERN.flags & re.ASCII


def test_autoclose_literals_match_typescript_source() -> None:
    """Keep the autoclose literals identical to their TypeScript twins."""
    # Arrange
    typescript_source = TYPESCRIPT_MODELS_PATH.read_text(encoding="utf-8")

    # Act
    quoted_literals = [
        f'"{AUTOCLOSE_UNVERIFIED_ANNOTATION}"',
        f'"{AUTOCLOSE_PENDING_NOT_OPEN_TEXT}"',
    ]

    # Assert: each Python literal appears double-quoted in the TypeScript source.
    for literal in quoted_literals:
        assert literal in typescript_source, f"missing TypeScript literal {literal}"
