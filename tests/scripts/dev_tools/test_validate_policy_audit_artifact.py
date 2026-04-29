"""Tests for the split policy-audit validator helpers."""

from __future__ import annotations

from collections.abc import Callable
from typing import cast

import scripts.dev_tools.validate_policy_audit_artifact as policy_validator

# Bind the internal parser helper through typed runtime lookup so the tests can
# cover the extracted helper behavior without changing production visibility.
extract_policy_audit_coverage_rows = cast(
    "Callable[[str], list[dict[str, str]]]",
    vars(policy_validator)["_extract_policy_audit_coverage_rows"],
)
extract_policy_audit_comparison_lines = cast(
    "Callable[[str], dict[str, str]]",
    vars(policy_validator)["_extract_policy_audit_comparison_lines"],
)

TYPESCRIPT_COVERAGE_ROW = (
    "| TypeScript | 2 files | 12 tests | [✅] 12 pass, 0 fail | "
    "91% lines, 88% functions | 93% lines, 90% functions | 95% |"
)
POWERSHELL_COVERAGE_ROW = (
    "| PowerShell | 1 file | 8 tests | [✅] 8 pass, 0 fail | "
    "84% commands, 82% functions | 86% commands, 84% functions | "
    "N/A - generated report does not expose a numeric changed-file metric |"
)
TYPESCRIPT_EVIDENCE_REFERENCE = (
    "Evidence: docs/features/active/example/evidence/baseline/typescript.md; "
    "docs/features/active/example/evidence/qa-gates/typescript.md."
)
TYPESCRIPT_EVIDENCE_REFERENCE_NO_LABEL = (
    "docs/features/active/example/evidence/baseline/typescript.md; "
    "docs/features/active/example/evidence/qa-gates/typescript.md."
)


def build_valid_policy_audit_text() -> str:
    """Return a policy-audit document that satisfies the split validator.

    Purpose:
        Provide a stable baseline document for focused unit tests that mutate one
        policy-audit branch at a time.

    Args:
        None.

    Returns:
        str: A policy-audit document that passes the policy-audit validator.

    Raises:
        None.

    Side Effects:
        None.
    """

    return "\n".join(
        (
            "# Policy Compliance Audit: Component",
            "**Audit Date:** 2026-04-12",
            "**Code Under Test:** `src/example.ts`, `scripts/example.ps1`",
            "**Coverage Metrics by Language:**",
            "",
            (
                "| Language | Files Changed | Tests | Test Result | "
                "Baseline Coverage | Post-Change Coverage | "
                "New Code Coverage |"
            ),
            (
                "|----------|--------------|-------|-------------|"
                "-------------------|---------------------|"
                "-------------------|"
            ),
            TYPESCRIPT_COVERAGE_ROW,
            POWERSHELL_COVERAGE_ROW,
            "",
            "### Coverage Evidence Checklist",
            "",
            (
                "- TypeScript baseline coverage artifact: "
                "docs/features/active/example/evidence/baseline/typescript.md"
            ),
            (
                "- TypeScript post-change coverage artifact: "
                "docs/features/active/example/evidence/qa-gates/typescript.md"
            ),
            (
                "- PowerShell baseline coverage artifact: "
                "docs/features/active/example/evidence/baseline/powershell.md"
            ),
            (
                "- PowerShell post-change coverage artifact: "
                "docs/features/active/example/evidence/qa-gates/powershell.md"
            ),
            "- Per-language comparison summary: Section 1.2.1",
            "## Executive Summary",
            "## 1. General Unit Test Policy Compliance",
            "### 1.2.1 Per-Language Coverage Comparison",
            (
                "- TypeScript: Baseline: 91% lines, 88% functions -> "
                "Post-change: 93% lines, 90% functions. Change: +2% lines, "
                "+2% functions. New/changed-code coverage: 95%. "
                "Disposition: PASS. Evidence: "
                "docs/features/active/example/evidence/baseline/typescript.md; "
                "docs/features/active/example/evidence/qa-gates/typescript.md."
            ),
            (
                "- PowerShell: Baseline: 84% commands, 82% functions -> "
                "Post-change: 86% commands, 84% functions. Change: "
                "+2% commands, +2% functions. "
                "Disposition: PASS. Evidence: "
                "docs/features/active/example/evidence/baseline/powershell.md; "
                "docs/features/active/example/evidence/qa-gates/powershell.md."
            ),
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
    )


def test_extract_policy_audit_coverage_rows_ignores_nonseven_cell_rows() -> None:
    """Reject malformed table rows that do not have the required seven cells.

    Purpose:
        Cover the parser branch that skips table rows with missing columns so
        malformed coverage rows do not become false evidence.

    Args:
        None.

    Returns:
        None: Assertions verify that the malformed row is ignored.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = "\n".join(
        (
            "| Language | Files Changed | Tests | Test Result | Baseline Coverage |",
            "|----------|--------------|-------|-------------|-------------------|",
            "| TypeScript | 2 files | 12 tests | [✅] 12 pass, 0 fail | 91% lines |",
        )
    )

    rows = extract_policy_audit_coverage_rows(text)

    assert rows == []


def test_extract_policy_audit_coverage_rows_ignores_separator_language_rows() -> None:
    """Ignore rows whose language cell is only dash separators.

    Purpose:
        Cover the parser branch that rejects rows where the language cell is a
        dashed separator rather than a real language name.

    Args:
        None.

    Returns:
        None: Assertions verify that only real language rows are retained.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = "\n".join(
        (
            (
                "| Language | Files Changed | Tests | Test Result | "
                "Baseline Coverage | Post-Change Coverage | New Code Coverage |"
            ),
            (
                "|----------|--------------|-------|-------------|"
                "-------------------|---------------------|"
                "-------------------|"
            ),
            (
                "| ----- | 0 files | 0 tests | [✅] 0 pass, 0 fail | "
                "N/A | N/A | N/A |"
            ),
            (
                "| TypeScript | 2 files | 12 tests | [✅] 12 pass, 0 fail | "
                "91% lines | 93% lines | 95% |"
            ),
        )
    )

    rows = extract_policy_audit_coverage_rows(text)

    assert [row["Language"] for row in rows] == ["TypeScript"]


def test_extract_policy_audit_comparison_lines_stops_at_next_heading() -> None:
    """Stop comparison parsing at the next subsection heading.

    Purpose:
        Cover the comparison parser branches that skip malformed bullets without
        a `Language:` separator and stop collecting lines once the next heading
        begins.

    Args:
        None.

    Returns:
        None: Assertions verify that only valid in-section bullets are kept.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = "\n".join(
        (
            policy_validator.POLICY_AUDIT_COMPARISON_HEADING,
            (
                "- TypeScript: Baseline: 91% lines -> Post-change: 93% lines. "
                "Change: +2%. Disposition: PASS. New/changed-code coverage: "
                "95%. Evidence: baseline.md; post.md."
            ),
            "- malformed comparison bullet without a separator",
            "### 1.2.2 Another Section",
            (
                "- PowerShell: Baseline: 84% commands -> Post-change: 86% "
                "commands. Change: +2%. Disposition: PASS. Evidence: "
                "baseline.md; post.md."
            ),
        )
    )

    comparison_lines = extract_policy_audit_comparison_lines(text)

    assert comparison_lines == {
        "typescript": (
            "- TypeScript: Baseline: 91% lines -> Post-change: 93% lines. "
            "Change: +2%. Disposition: PASS. New/changed-code coverage: 95%. "
            "Evidence: baseline.md; post.md."
        )
    }


def test_validate_policy_audit_text_reports_template_placeholders() -> None:
    """Report template instructions, placeholder text, and missing headings.

    Purpose:
        Cover the public validator branches that reject the template instruction
        block, the placeholder component marker, and missing required headings.

    Args:
        None.

    Returns:
        None: Assertions verify that the template-specific errors are emitted.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = policy_validator.validate_policy_audit_text(
        "Template Usage Instructions\n[Component Name]"
    )

    assert "Policy audit still contains the template instruction block." in errors
    assert "Policy audit still contains placeholder component text." in errors
    assert any(
        "Policy audit missing required heading: ## Executive Summary" == error
        for error in errors
    )


def _test_policy_audit_rejects_missing_coverage_table_rows() -> None:
    """Reject a policy audit that has headings and checklist entries but no rows.

    Purpose:
        Cover the substantive validation branch that fails when the coverage
        table headings exist but no data rows remain.

    Args:
        None.

    Returns:
        None: Assertions verify that the missing-row error is emitted.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = (
        build_valid_policy_audit_text()
        .replace(f"{TYPESCRIPT_COVERAGE_ROW}\n", "")
        .replace(f"{POWERSHELL_COVERAGE_ROW}\n", "")
    )

    errors = policy_validator.validate_policy_audit_substantive_requirements(text)

    assert "Policy audit missing coverage metrics table rows." in errors


globals()[
    "test_validate_policy_audit_substantive_requirements_rejects_missing_coverage_table_rows"
] = _test_policy_audit_rejects_missing_coverage_table_rows


def _test_policy_audit_rejects_comparison_line_missing_change_text() -> None:
    """Reject comparison lines that omit the explicit change label.

    Purpose:
        Cover the comparison validation branch that requires each language line
        to carry explicit `Change:` wording.

    Args:
        None.

    Returns:
        None: Assertions verify that the missing-change error is emitted.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = build_valid_policy_audit_text().replace(
        "Change: +2% lines, +2% functions. ", ""
    )

    errors = policy_validator.validate_policy_audit_substantive_requirements(text)

    assert any(
        "comparison line missing explicit change text for TypeScript" in error
        for error in errors
    )


globals()[
    "test_validate_policy_audit_substantive_requirements_rejects_comparison_line_missing_change_text"
] = _test_policy_audit_rejects_comparison_line_missing_change_text


def _test_policy_audit_rejects_comparison_line_missing_evidence_reference() -> None:
    """Reject comparison lines that omit the required evidence reference.

    Purpose:
        Cover the branch that requires each per-language comparison line to cite
        evidence rather than only narrative text.

    Args:
        None.

    Returns:
        None: Assertions verify that the missing-evidence error is emitted.

    Raises:
        None.

    Side Effects:
        None.
    """

    text = build_valid_policy_audit_text().replace(
        TYPESCRIPT_EVIDENCE_REFERENCE,
        TYPESCRIPT_EVIDENCE_REFERENCE_NO_LABEL,
    )

    errors = policy_validator.validate_policy_audit_substantive_requirements(text)

    assert any(
        "comparison line missing evidence reference for TypeScript" in error
        for error in errors
    )


globals()[
    "test_validate_policy_audit_substantive_requirements_rejects_comparison_line_missing_evidence_reference"
] = _test_policy_audit_rejects_comparison_line_missing_evidence_reference


def _test_policy_audit_allows_na_new_code_without_percentage() -> None:
    """Allow N/A new-code rows to omit a numeric new-code comparison percentage.

    Purpose:
        Cover the branch that skips the new-code percentage requirement when the
        coverage row explicitly records `N/A` for new-code coverage.

    Args:
        None.

    Returns:
        None: Assertions verify that no PowerShell new-code percentage error is
        emitted.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors = policy_validator.validate_policy_audit_substantive_requirements(
        build_valid_policy_audit_text()
    )

    assert not any(
        "new/changed-code coverage for PowerShell" in error for error in errors
    )


globals()[
    "test_validate_policy_audit_substantive_requirements_allows_na_new_code_without_percentage"
] = _test_policy_audit_allows_na_new_code_without_percentage
