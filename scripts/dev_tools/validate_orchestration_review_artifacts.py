"""Validate non-policy review-oriented orchestration artifacts.

Purpose:
    Hold the code-review and feature-audit validators while re-exporting the
    split policy-audit validator from its dedicated module.

Usage:
    Import the public validation functions from
    ``scripts.dev_tools.validate_orchestration_artifacts`` or directly from this
    module when a caller needs the review-specific validators.

Flow:
    1. Delegate policy-audit validation to the split policy-audit module.
    2. Validate code-review and feature-audit headings locally.
    3. Return a list of contract violations for the caller to surface.

Invariants / Constraints:
    - The public validator functions return lists of error strings and do not
      print or mutate files.
    - The module preserves the existing import surface for callers that still
      import ``validate_policy_audit_text`` from this module.

Side Effects:
    None.
"""

from __future__ import annotations

from scripts.dev_tools.validate_policy_audit_artifact import validate_policy_audit_text

__all__ = [
    "validate_policy_audit_text",
    "validate_code_review_text",
    "validate_feature_audit_text",
]

CODE_REVIEW_REQUIRED_HEADINGS = (
    "## Executive Summary",
    "## Findings Table",
)
FEATURE_AUDIT_REQUIRED_HEADINGS = (
    "## Scope and Baseline",
    "## Acceptance Criteria Inventory",
    "## Acceptance Criteria Evaluation",
    "## Summary",
    "## Acceptance Criteria Check-off",
)


def validate_code_review_text(text: str) -> list[str]:
    """Validate audit-grade code-review structure.

    Purpose:
        Require the minimal headings and findings table that repository code
        reviews must include.

    Args:
        text (str): Full code-review artifact text.

    Returns:
        list[str]: Validation errors for missing headings or table structure.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    for heading in CODE_REVIEW_REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"Code review missing required heading: {heading}")
    table_header = (
        "| Severity | File | Location | Finding | Recommendation | "
        "Rationale | Evidence |"
    )
    if table_header not in text:
        errors.append("Code review missing the required findings table header.")
    return errors


def validate_feature_audit_text(text: str) -> list[str]:
    """Validate feature-audit structure.

    Purpose:
        Require the canonical sections that tie implementation evidence back to
        acceptance criteria.

    Args:
        text (str): Full feature-audit artifact text.

    Returns:
        list[str]: Validation errors for any missing canonical sections.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    for heading in FEATURE_AUDIT_REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"Feature audit missing required heading: {heading}")
    return errors
