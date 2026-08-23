"""Unit tests for the blast-radius token-shape predicates.

Cover the placeholder-marker predicate added by issue #502 and the
feature-corpus-span predicate relocated into the same leaf module, including the
degenerate inputs that must not raise. Every input is an in-memory literal; no
temporary file is created and no external process is started.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools._blast_radius_token_shapes import (
    PLACEHOLDER_MARKERS,
    contains_placeholder_marker,
    spans_multiple_feature_folders,
)
from scripts.dev_tools.plan_gate_coverage import (
    PLACEHOLDER_MARKERS as ACCEPTANCE_GATE_MARKERS,
)

# One probe per marker, each carrying exactly one of the five so that a failure
# names the marker that regressed rather than a token carrying several. Python
# string literals perform no interpolation, so the text below is exactly what
# reaches the predicate.
MARKER_PROBES = [
    pytest.param("docs/features/active/<feature/plan.md", id="angle-open"),
    pytest.param("docs/features/active/feature>/plan.md", id="angle-close"),
    pytest.param(".claude/state/${session_id}.json", id="dollar-brace"),
    pytest.param(".claude/state/$(session).json", id="dollar-paren"),
    pytest.param(".claude/state/%SESSION%.json", id="percent"),
]


@pytest.mark.parametrize("token", MARKER_PROBES)
def test_contains_placeholder_marker_reports_a_marker_bearing_token(
    token: str,
) -> None:
    """Report a token carrying any single marker as marker-bearing."""
    # Arrange / Act
    observed = contains_placeholder_marker(token)

    # Assert
    assert observed is True, f"Expected {token!r} to be marker-bearing."


def test_contains_placeholder_marker_reads_the_filename_position() -> None:
    """A marker in the filename position is as disqualifying as one earlier.

    The predicate is deliberately position-blind: an interpolated filename is
    exactly as unresolvable as an interpolated directory, so scoping the scan
    to leading segments would admit the shape it exists to reject.
    """
    # Arrange
    citation = ".claude/state/powershell-batch-budget.<session_id>.json"

    # Act / Assert
    assert contains_placeholder_marker(citation) is True


def test_contains_placeholder_marker_admits_a_marker_free_real_path() -> None:
    """A real repository path is not reported as marker-bearing.

    This is the discrimination control: a predicate that reported every token
    as marker-bearing would satisfy every rejection test above while dropping
    the entire harvest.
    """
    # Arrange
    citation = "scripts/dev_tools/compute_blast_radius.py"

    # Act / Assert
    assert contains_placeholder_marker(citation) is False


@pytest.mark.parametrize(
    ("token", "expected"),
    [
        pytest.param("", False, id="empty-string"),
        pytest.param("<", True, id="marker-only"),
        pytest.param("<>", True, id="bare-bracket-pair"),
    ],
)
def test_contains_placeholder_marker_handles_a_degenerate_token(
    token: str, expected: bool
) -> None:
    """Return a verdict without raising for a degenerate token.

    The predicate runs inside a classifier that is called on every inline-code
    span in a document, so it must be total. A raise on a degenerate token
    would abort an entire derivation over one stray span.
    """
    # Arrange / Act
    observed = contains_placeholder_marker(token)

    # Assert
    assert observed is expected


def test_marker_tuple_agrees_with_the_acceptance_gate_tuple() -> None:
    """Pin the two subsystems' marker vocabularies equal by test.

    The acceptance-gate rules and this shape predicate answer the same question
    about the same text: whether a token was written to document a shape rather
    than to name a thing. Two independently maintained copies of that
    vocabulary would drift silently, and the drift would be invisible because
    each subsystem's own tests would keep passing. Asserting equality here
    makes a divergence fail immediately, in the runtime that changed.
    """
    # Arrange / Act / Assert
    assert PLACEHOLDER_MARKERS == ACCEPTANCE_GATE_MARKERS


@pytest.mark.parametrize(
    "token",
    [
        "docs/features/**/plan*.md",
        "docs/features/active/*/plan.md",
        "docs/features/**",
    ],
)
def test_spans_multiple_feature_folders_reports_a_cross_corpus_glob(
    token: str,
) -> None:
    """Report a documentation glob whose wildcard spans every feature folder."""
    # Arrange / Act
    observed = spans_multiple_feature_folders(token)

    # Assert
    assert observed is True, f"Expected {token!r} to span multiple folders."


def test_spans_multiple_feature_folders_retains_one_complete_folder() -> None:
    """A glob naming one complete feature folder claims exactly that folder."""
    # Arrange
    own_folder_glob = (
        "docs/features/active/2026-08-17-blast-radius-false-conflict-edges-489/**"
    )

    # Act / Assert
    assert spans_multiple_feature_folders(own_folder_glob) is False


def test_spans_multiple_feature_folders_ignores_a_token_rooted_elsewhere() -> None:
    """The span rule is scoped to the documentation corpus and nothing else."""
    # Arrange / Act / Assert
    assert spans_multiple_feature_folders("scripts/dev_tools/**") is False
