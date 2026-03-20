"""Focused coverage tests for potential_to_issue_content helpers."""

from __future__ import annotations

from scripts.dev_tools import potential_to_issue_content as mod


def test_build_bug_body_preserves_canonical_heading_order() -> None:
    """Verify build_bug_body emits sections in canonical bug-heading order.

    Purpose:
        Lock in the stable heading order used by bug promotion so downstream issue
        templates and audits can rely on deterministic section sequencing.

    Args:
        None.

    Returns:
        None: Assertions validate the emitted heading order.

    Raises:
        AssertionError: Raised when any canonical heading is missing or out of order.

    Side Effects:
        None.
    """
    sections = {heading: heading.lower() for heading in mod.BUG_SECTION_HEADINGS}

    body = mod.build_bug_body("full-bug", sections, "docs/features/potential/sample.md")

    expected_headings = [f"## {heading}" for heading in mod.BUG_SECTION_HEADINGS]
    heading_positions = [body.index(heading) for heading in expected_headings]
    assert heading_positions == sorted(heading_positions)
    assert body.startswith("- Work Mode: full-bug")
    assert body.rstrip().endswith("## Source\nFrom: docs/features/potential/sample.md")


def test_evaluate_minor_audit_eligibility_accepts_bootstrapped_keyword() -> None:
    """Verify bootstrapped content is considered minor-audit eligible.

    Purpose:
        Preserve the fast-path eligibility rule that treats bootstrapped potentials
        as deterministically eligible without further production-file counting.

    Args:
        None.

    Returns:
        None: Assertions validate the eligible branch and reason string.

    Raises:
        AssertionError: Raised when the helper fails to recognize the keyword.

    Side Effects:
        None.
    """
    eligible, reason = mod.evaluate_minor_audit_eligibility(
        "This entry is bootstrapped."
    )

    assert eligible is True
    assert reason == "eligible: bootstrapped/pre-cooked"


def test_evaluate_minor_audit_eligibility_rejects_more_than_three_production_files() -> (  # noqa: E501
    None
):
    """Verify more than three production files forces the fallback branch.

    Purpose:
        Lock in the deterministic overflow rule for minor-audit eligibility so the
        planner can fail closed once the production-file budget is exceeded.

    Args:
        None.

    Returns:
        None: Assertions validate the overflow fallback branch.

    Raises:
        AssertionError: Raised when the helper incorrectly reports eligibility.

    Side Effects:
        None.
    """
    content = "\n".join(
        [
            "- file: a.py",
            "- production file: b.py",
            "- file: c.py",
            "- file: d.py",
            "risk: low",
        ]
    )

    eligible, reason = mod.evaluate_minor_audit_eligibility(content)

    assert eligible is False
    assert reason == "fallback: production file count exceeds 3"


def test_extract_last_updated_returns_none_for_invalid_json() -> None:
    """Verify extract_last_updated returns None for invalid JSON payloads.

    Purpose:
        Preserve tolerant metadata extraction when gh output is malformed.

    Args:
        None.

    Returns:
        None: Assertions validate the invalid-JSON fallback branch.

    Raises:
        AssertionError: Raised when invalid JSON does not resolve to ``None``.

    Side Effects:
        None.
    """
    assert mod.extract_last_updated("{not json") is None


def test_extract_last_updated_returns_none_for_non_string_updated_at() -> None:
    """Verify extract_last_updated rejects non-string updatedAt values.

    Purpose:
        Ensure metadata extraction remains type-safe before ISO parsing is attempted.

    Args:
        None.

    Returns:
        None: Assertions validate the non-string fallback branch.

    Raises:
        AssertionError: Raised when a non-string ``updatedAt`` is accepted.

    Side Effects:
        None.
    """
    assert mod.extract_last_updated('{"updatedAt": 123}') is None


def test_extract_last_updated_returns_none_for_invalid_iso_timestamp() -> None:
    """Verify extract_last_updated returns None for invalid ISO timestamps.

    Purpose:
        Preserve graceful handling when gh returns an ``updatedAt`` string that is
        present but not ISO-parseable.

    Args:
        None.

    Returns:
        None: Assertions validate the ValueError fallback branch.

    Raises:
        AssertionError: Raised when an invalid timestamp is not rejected.

    Side Effects:
        None.
    """
    assert mod.extract_last_updated('{"updatedAt": "not-a-timestamp"}') is None


def test_update_metadata_lines_inserts_missing_issue_url_last_updated_and_status() -> (
    None
):
    """Verify update_metadata_lines inserts missing metadata fields at the meta block.

    Purpose:
        Lock in the insertion behavior used during potential promotion when a source
        file is missing issue URL, last updated, or status metadata lines.

    Args:
        None.

    Returns:
        None: Assertions validate the inserted metadata lines.

    Raises:
        AssertionError: Raised when any required metadata line is missing or malformed.

    Side Effects:
        None.
    """
    lines = ["# Feature Title", "## Problem / Why", "problem"]

    updated = mod.update_metadata_lines(
        lines=lines,
        feature_name="Feature Title",
        issue_number="123",
        issue_url="https://example.com/issues/123",
        last_updated="2026-03-14",
        feature_path="Feature_Title",
    )

    assert updated[0] == "# Feature Title (Issue #123)"
    assert "- Issue: #123" in updated
    assert "- Issue URL: https://example.com/issues/123" in updated
    assert "- Last Updated: 2026-03-14" in updated
    assert (
        "- Status: Promoted -> docs/features/active/Feature_Title/ (Issue #123)"
        in updated
    )


def test_normalize_smart_punctuation_replaces_all_mapped_characters() -> None:
    """Verify normalize_smart_punctuation replaces every mapped smart character.

    Purpose:
        Preserve deterministic ASCII normalization across quotes, apostrophes,
        dashes, and non-breaking spaces before issue bodies are submitted.

    Args:
        None.

    Returns:
        None: Assertions validate the mapped replacement output.

    Raises:
        AssertionError: Raised when any mapped smart punctuation remains.

    Side Effects:
        None.
    """
    raw = "“quoted” ‘apostrophe’ ’dash’ – —\u00a0"

    normalized = mod.normalize_smart_punctuation(raw)

    assert normalized == "\"quoted\" 'apostrophe' 'dash' - - "
