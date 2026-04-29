"""Validate review-oriented orchestration artifacts.

Purpose:
    Hold the policy-audit, code-review, and feature-audit validators plus the
    shared parsing helpers that support their fail-closed evidence checks.

Usage:
    Import the public validation functions from
    ``scripts.dev_tools.validate_orchestration_artifacts`` or directly from this
    module when a caller needs the review-specific validators.

Flow:
    1. Parse required headings and evidence tables from review text.
    2. Reject placeholder or non-numeric coverage evidence where policy
       requires explicit percentages.
    3. Return a list of contract violations for the caller to surface.

Invariants / Constraints:
    - Placeholder markers are treated as failures.
    - Coverage rows must retain numeric evidence unless the field is marked N/A.
    - The public validator functions return lists of error strings and do not
      print or mutate files.

Side Effects:
    None.
"""

from __future__ import annotations

import re

COVERAGE_PERCENT_RE = re.compile(r"\b\d+(?:\.\d+)?%")
POLICY_AUDIT_REQUIRED_HEADINGS = (
    "## Executive Summary",
    "## 1. General Unit Test Policy Compliance",
    "## 2. General Code Change Policy Compliance",
    "## 3. Language-Specific Code Change Policy Compliance",
    "## 4. Language-Specific Unit Test Policy Compliance",
    "## 5. Test Coverage Detail",
    "## 6. Test Execution Metrics",
    "## 7. Code Quality Checks",
    "## 8. Gaps and Exceptions",
    "## 9. Summary of Changes",
    "## 10. Compliance Verdict",
    "## Appendix A: Test Inventory",
    "## Appendix B: Toolchain Commands Reference",
)
POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS = (
    "TypeScript baseline coverage artifact:",
    "TypeScript post-change coverage artifact:",
    "PowerShell baseline coverage artifact:",
    "PowerShell post-change coverage artifact:",
    "Per-language comparison summary:",
)
POLICY_AUDIT_COMPARISON_HEADING = "### 1.2.1 Per-Language Coverage Comparison"
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
PLACEHOLDER_MARKERS = (
    "[n]",
    "[path",
    "[artifact",
    "[section reference",
    "[language]",
    "tbd",
    "unverified",
    "missing",
)


def _has_numeric_coverage(value: str) -> bool:
    """Return True when a coverage field contains a numeric percentage.

    Purpose:
        Identify whether a coverage field satisfies the policy requirement for
        explicit numeric evidence.

    Args:
        value (str): Raw coverage field text extracted from an audit artifact.

    Returns:
        bool: True when the value contains at least one percentage token.

    Raises:
        None.

    Side Effects:
        None.
    """

    return COVERAGE_PERCENT_RE.search(value) is not None


def _is_na_value(value: str) -> bool:
    """Return True when an audit field explicitly records not-applicable.

    Purpose:
        Allow the validator to distinguish missing numeric evidence from fields
        that are intentionally marked not applicable.

    Args:
        value (str): Raw field text to inspect.

    Returns:
        bool: True when the value begins with an N/A marker.

    Raises:
        None.

    Side Effects:
        None.
    """

    return value.strip().lower().startswith("n/a")


def _has_placeholder_marker(value: str) -> bool:
    """Return True when a field still contains template placeholder text.

    Purpose:
        Fail closed when a review artifact still includes unfinished template or
        draft markers.

    Args:
        value (str): Raw field text to inspect.

    Returns:
        bool: True when the field includes a known placeholder marker.

    Raises:
        None.

    Side Effects:
        None.
    """

    lowered = value.lower()
    return any(marker in lowered for marker in PLACEHOLDER_MARKERS)


def _extract_policy_audit_coverage_rows(text: str) -> list[dict[str, str]]:
    """Parse the policy-audit coverage table into named row dictionaries.

    Purpose:
        Normalize coverage table rows so later validation checks can reason
        about baseline, post-change, and new-code evidence by language.

    Args:
        text (str): Full policy-audit artifact text.

    Returns:
        list[dict[str, str]]: Parsed coverage rows keyed by canonical column
        names.

    Raises:
        None.

    Side Effects:
        None.
    """

    rows: list[dict[str, str]] = []

    # Interpret only the seven-column coverage table rows and ignore headers or
    # separator rows.
    for line in text.splitlines():
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.split("|")[1:-1]]
        if len(cells) != 7:
            continue
        language = cells[0]
        if language in {"Language", "----------"} or not language:
            continue
        if set(language) == {"-"}:
            continue
        rows.append(
            {
                "Language": language,
                "Files Changed": cells[1],
                "Tests": cells[2],
                "Test Result": cells[3],
                "Baseline Coverage": cells[4],
                "Post-Change Coverage": cells[5],
                "New Code Coverage": cells[6],
            }
        )

    return rows


def _find_policy_audit_checklist_line(text: str, label: str) -> str | None:
    """Return the checklist line containing a required label.

    Purpose:
        Locate required evidence checklist entries without assuming a fixed line
        number or surrounding context.

    Args:
        text (str): Full policy-audit artifact text.
        label (str): Required checklist label to locate.

    Returns:
        str | None: The matching checklist line, if present.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Search only checklist bullets because the same label text may appear in
    # narrative prose elsewhere in the document.
    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("- ") and label in stripped:
            return stripped
    return None


def _extract_policy_audit_comparison_lines(text: str) -> dict[str, str]:
    """Return per-language comparison lines keyed by normalized language name.

    Purpose:
        Capture the explicit comparison bullets under the per-language coverage
        section so downstream checks can verify each language summary is present.

    Args:
        text (str): Full policy-audit artifact text.

    Returns:
        dict[str, str]: Mapping of lowercase language name to the matching
        comparison bullet.

    Raises:
        None.

    Side Effects:
        None.
    """

    in_section = False
    comparison_lines: dict[str, str] = {}

    # Limit parsing to the per-language coverage section so unrelated bullets do
    # not satisfy the evidence checks accidentally.
    for line in text.splitlines():
        stripped = line.strip()
        if stripped == POLICY_AUDIT_COMPARISON_HEADING:
            in_section = True
            continue
        if in_section and stripped.startswith("### "):
            break
        if not in_section or not stripped.startswith("- "):
            continue
        language, separator, _ = stripped[2:].partition(":")
        if not separator:
            continue
        comparison_lines[language.strip().lower()] = stripped

    return comparison_lines


def _comparison_line_has_labelled_percentage(line: str, label: str) -> bool:
    """Return True when the comparison line includes a labelled percentage.

    Purpose:
        Verify that each comparison bullet records numeric evidence after the
        expected label, rather than narrative text alone.

    Args:
        line (str): Comparison bullet text.
        label (str): Required label to anchor the percentage search.

    Returns:
        bool: True when the labelled numeric evidence is present.

    Raises:
        None.

    Side Effects:
        None.
    """

    pattern = re.compile(rf"{re.escape(label)}.*?\d+(?:\.\d+)?%")
    return pattern.search(line) is not None


def validate_policy_audit_substantive_requirements(text: str) -> list[str]:
    """Validate policy-audit evidence requirements beyond headings.

    Purpose:
        Enforce the numeric coverage and evidence checklist requirements that
        turn the review template into an auditable artifact.

    Args:
        text (str): Full policy-audit artifact text.

    Returns:
        list[str]: Validation errors describing each missing or malformed
        evidence element.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []

    # Require every checklist line to exist and remain free of unresolved
    # placeholders before the audit can report a passing verdict.
    for label in POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS:
        line = _find_policy_audit_checklist_line(text, label)
        if line is None:
            errors.append(f"Policy audit missing required checklist line: {label}")
            continue
        if _has_placeholder_marker(line):
            errors.append(
                f"Policy audit checklist line still contains placeholder text: {label}"
            )

    coverage_rows = _extract_policy_audit_coverage_rows(text)
    if not coverage_rows:
        errors.append("Policy audit missing coverage metrics table rows.")

    if POLICY_AUDIT_COMPARISON_HEADING not in text:
        errors.append(
            "Policy audit missing required heading: "
            f"{POLICY_AUDIT_COMPARISON_HEADING}"
        )

    comparison_lines = _extract_policy_audit_comparison_lines(text)

    # Validate each language row against the comparison summary so baseline,
    # post-change, and changed-code evidence remain synchronized.
    for row in coverage_rows:
        language = row["Language"]
        baseline = row["Baseline Coverage"]
        post_change = row["Post-Change Coverage"]
        new_code = row["New Code Coverage"]
        requires_coverage_comparison = any(
            not _is_na_value(value) for value in (baseline, post_change, new_code)
        )

        if not _is_na_value(baseline) and not _has_numeric_coverage(baseline):
            errors.append(
                f"Policy audit missing numeric baseline coverage for {language}."
            )
        if not _is_na_value(post_change) and not _has_numeric_coverage(post_change):
            errors.append(
                f"Policy audit missing numeric post-change coverage for {language}."
            )
        if not _is_na_value(new_code) and not _has_numeric_coverage(new_code):
            errors.append(
                "Policy audit missing numeric new/changed-code coverage for "
                f"{language}."
            )

        if not requires_coverage_comparison:
            continue

        comparison_line = comparison_lines.get(language.lower())
        if comparison_line is None:
            errors.append(
                f"Policy audit missing per-language comparison line for {language}."
            )
            continue

        if not _comparison_line_has_labelled_percentage(comparison_line, "Baseline:"):
            errors.append(
                f"Policy audit comparison line missing numeric baseline for {language}."
            )
        if not _comparison_line_has_labelled_percentage(
            comparison_line, "Post-change:"
        ):
            errors.append(
                "Policy audit comparison line missing numeric post-change "
                f"coverage for {language}."
            )
        if "Change:" not in comparison_line:
            errors.append(
                "Policy audit comparison line missing explicit change text for "
                f"{language}."
            )
        if (
            re.search(
                r"Disposition:\s*(PASS|FAIL|N/A|INCOMPLETE|BLOCKED)",
                comparison_line,
            )
            is None
        ):
            errors.append(
                f"Policy audit comparison line missing disposition for {language}."
            )
        if not _is_na_value(new_code) and not _comparison_line_has_labelled_percentage(
            comparison_line, "New/changed-code coverage:"
        ):
            errors.append(
                "Policy audit comparison line missing numeric new/changed-code "
                f"coverage for {language}."
            )
        if "Evidence:" not in comparison_line:
            errors.append(
                "Policy audit comparison line missing evidence reference for "
                f"{language}."
            )
        elif _has_placeholder_marker(comparison_line):
            errors.append(
                "Policy audit comparison line still contains placeholder text for "
                f"{language}."
            )

    return errors


def validate_policy_audit_text(text: str) -> list[str]:
    """Validate template-derived policy-audit structure.

    Purpose:
        Enforce the required policy-audit headings and substantive evidence
        checks for repository review artifacts.

    Args:
        text (str): Full policy-audit artifact text.

    Returns:
        list[str]: Validation errors for missing headings or evidence.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    if "Template Usage Instructions" in text:
        errors.append("Policy audit still contains the template instruction block.")
    if "[Component Name]" in text:
        errors.append("Policy audit still contains placeholder component text.")
    for heading in POLICY_AUDIT_REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"Policy audit missing required heading: {heading}")
    errors.extend(validate_policy_audit_substantive_requirements(text))
    return errors


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
