import { describe, expect, it } from "@jest/globals";

import {
  POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS,
  POLICY_AUDIT_REQUIRED_HEADINGS,
  validatePolicyAuditSubstantiveRequirements,
  validatePolicyAuditText,
} from "../../../src/lib/validate/policy-audit-artifact";

const TYPESCRIPT_COVERAGE_ROW =
  "| TypeScript | 2 files | 12 tests | [OK] 12 pass, 0 fail | " +
  "91% lines, 88% functions | 93% lines, 90% functions | 95% |";
const POWERSHELL_COVERAGE_ROW =
  "| PowerShell | 1 file | 8 tests | [OK] 8 pass, 0 fail | " +
  "84% commands, 82% functions | 86% commands, 84% functions | " +
  "N/A - generated report does not expose a numeric changed-file metric |";
const TYPESCRIPT_EVIDENCE_REFERENCE =
  "Evidence: docs/features/active/example/evidence/baseline/typescript.md; " +
  "docs/features/active/example/evidence/qa-gates/typescript.md.";
const TYPESCRIPT_EVIDENCE_REFERENCE_NO_LABEL =
  "docs/features/active/example/evidence/baseline/typescript.md; " +
  "docs/features/active/example/evidence/qa-gates/typescript.md.";

/**
 * Build a policy-audit document that satisfies the validator so focused tests
 * can mutate one branch at a time.
 */
function buildValidPolicyAuditText(): string {
  return [
    "# Policy Compliance Audit: Component",
    "**Audit Date:** 2026-04-12",
    "**Code Under Test:** `src/example.ts`, `scripts/example.ps1`",
    "**Coverage Metrics by Language:**",
    "",
    "| Language | Files Changed | Tests | Test Result | " +
      "Baseline Coverage | Post-Change Coverage | New Code Coverage |",
    "|----------|--------------|-------|-------------|" +
      "-------------------|---------------------|-------------------|",
    TYPESCRIPT_COVERAGE_ROW,
    POWERSHELL_COVERAGE_ROW,
    "",
    "### Coverage Evidence Checklist",
    "",
    "- TypeScript baseline coverage artifact: " +
      "docs/features/active/example/evidence/baseline/typescript.md",
    "- TypeScript post-change coverage artifact: " +
      "docs/features/active/example/evidence/qa-gates/typescript.md",
    "- PowerShell baseline coverage artifact: " +
      "docs/features/active/example/evidence/baseline/powershell.md",
    "- PowerShell post-change coverage artifact: " +
      "docs/features/active/example/evidence/qa-gates/powershell.md",
    "- Per-language comparison summary: Section 1.2.1",
    "## Executive Summary",
    "## 1. General Unit Test Policy Compliance",
    "### 1.2.1 Per-Language Coverage Comparison",
    "- TypeScript: Baseline: 91% lines, 88% functions -> " +
      "Post-change: 93% lines, 90% functions. Change: +2% lines, " +
      "+2% functions. New/changed-code coverage: 95%. " +
      "Disposition: PASS. Evidence: " +
      "docs/features/active/example/evidence/baseline/typescript.md; " +
      "docs/features/active/example/evidence/qa-gates/typescript.md.",
    "- PowerShell: Baseline: 84% commands, 82% functions -> " +
      "Post-change: 86% commands, 84% functions. Change: " +
      "+2% commands, +2% functions. " +
      "Disposition: PASS. Evidence: " +
      "docs/features/active/example/evidence/baseline/powershell.md; " +
      "docs/features/active/example/evidence/qa-gates/powershell.md.",
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
  ].join("\n");
}

describe("validatePolicyAuditText", () => {
  it("returns no errors for a valid policy-audit document", () => {
    // Arrange
    const text = buildValidPolicyAuditText();

    // Act
    const errors = validatePolicyAuditText(text);

    // Assert
    expect(errors).toEqual([]);
  });

  it("reports the template instruction block and placeholder component text", () => {
    // Arrange
    const text = "Template Usage Instructions\n[Component Name]";

    // Act
    const errors = validatePolicyAuditText(text);

    // Assert
    expect(errors).toContain(
      "Policy audit still contains the template instruction block.",
    );
    expect(errors).toContain(
      "Policy audit still contains placeholder component text.",
    );
    expect(errors).toContain(
      "Policy audit missing required heading: ## Executive Summary",
    );
  });

  it("reports each missing required heading", () => {
    // Arrange / Act / Assert: drop one heading at a time.
    for (const heading of POLICY_AUDIT_REQUIRED_HEADINGS) {
      const text = buildValidPolicyAuditText().replace(heading, "## Removed");
      const errors = validatePolicyAuditText(text);
      expect(errors).toContain(
        `Policy audit missing required heading: ${heading}`,
      );
    }
  });

  it("rejects PASS artifacts reporting a missing template resolver", () => {
    // Arrange
    const text = [
      buildValidPolicyAuditText(),
      "MCP resolver status: resolve_policy_audit_template_asset was not exposed.",
      "Review readiness: READY.",
      "Final disposition: PASS.",
    ].join("\n");

    // Act
    const errors = validatePolicyAuditText(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("resolve_policy_audit_template_asset"),
      ),
    ).toBe(true);
  });
});

describe("validatePolicyAuditSubstantiveRequirements", () => {
  it("reports each missing checklist label", () => {
    // Arrange / Act / Assert: drop one checklist label at a time.
    for (const label of POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS) {
      const text = buildValidPolicyAuditText().replace(label, "Removed:");
      const errors = validatePolicyAuditSubstantiveRequirements(text);
      expect(errors).toContain(
        `Policy audit missing required checklist line: ${label}`,
      );
    }
  });

  it("reports a checklist line that still contains placeholder text", () => {
    // Arrange: inject a placeholder marker into one checklist value.
    const text = buildValidPolicyAuditText().replace(
      "docs/features/active/example/evidence/baseline/typescript.md",
      "[path to artifact TBD]",
    );

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(errors).toContain(
      "Policy audit checklist line still contains placeholder text: " +
        "TypeScript baseline coverage artifact:",
    );
  });

  it("reports missing coverage metrics table rows", () => {
    // Arrange: remove both coverage data rows.
    const text = buildValidPolicyAuditText()
      .replace(`${TYPESCRIPT_COVERAGE_ROW}\n`, "")
      .replace(`${POWERSHELL_COVERAGE_ROW}\n`, "");

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(errors).toContain(
      "Policy audit missing coverage metrics table rows.",
    );
  });

  it("reports the missing comparison heading", () => {
    // Arrange: remove the per-language comparison heading.
    const text = buildValidPolicyAuditText().replace(
      "### 1.2.1 Per-Language Coverage Comparison",
      "### 1.2.1 Removed",
    );

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(errors).toContain(
      "Policy audit missing required heading: " +
        "### 1.2.1 Per-Language Coverage Comparison",
    );
  });

  it("reports missing numeric baseline coverage per language", () => {
    // Arrange: replace the TypeScript baseline coverage cell with prose.
    const text = buildValidPolicyAuditText().replace(
      "91% lines, 88% functions | 93% lines, 90% functions | 95% |",
      "lines covered | 93% lines, 90% functions | 95% |",
    );

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(errors).toContain(
      "Policy audit missing numeric baseline coverage for TypeScript.",
    );
  });

  it("allows N/A new-code rows to omit a numeric new-code percentage", () => {
    // Arrange
    const text = buildValidPolicyAuditText();

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("new/changed-code coverage for PowerShell"),
      ),
    ).toBe(false);
  });

  it("reports a comparison line missing explicit change text", () => {
    // Arrange
    const text = buildValidPolicyAuditText().replace(
      "Change: +2% lines, +2% functions. ",
      "",
    );

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes(
          "comparison line missing explicit change text for TypeScript",
        ),
      ),
    ).toBe(true);
  });

  it("reports a comparison line missing the disposition", () => {
    // Arrange: remove the disposition token from the TypeScript line.
    const text = buildValidPolicyAuditText().replace(
      "Disposition: PASS. Evidence: " +
        "docs/features/active/example/evidence/baseline/typescript.md",
      "Evidence: " +
        "docs/features/active/example/evidence/baseline/typescript.md",
    );

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes("comparison line missing disposition for TypeScript"),
      ),
    ).toBe(true);
  });

  it("reports a comparison line missing the evidence reference", () => {
    // Arrange
    const text = buildValidPolicyAuditText().replace(
      TYPESCRIPT_EVIDENCE_REFERENCE,
      TYPESCRIPT_EVIDENCE_REFERENCE_NO_LABEL,
    );

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes(
          "comparison line missing evidence reference for TypeScript",
        ),
      ),
    ).toBe(true);
  });

  it("reports a comparison line missing numeric new/changed-code coverage", () => {
    // Arrange: drop the numeric new-code percentage from the TypeScript line
    // while keeping the row's new-code cell numeric so the check applies.
    const text = buildValidPolicyAuditText().replace(
      "New/changed-code coverage: 95%. ",
      "New/changed-code coverage: pending. ",
    );

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert
    expect(
      errors.some((error) =>
        error.includes(
          "comparison line missing numeric new/changed-code coverage for TypeScript",
        ),
      ),
    ).toBe(true);
  });

  it("ignores coverage rows that do not have seven cells", () => {
    // Arrange: a five-column row must not become a coverage row.
    const text = [
      "| Language | Files Changed | Tests | Test Result | Baseline Coverage |",
      "|----------|--------------|-------|-------------|-------------------|",
      "| TypeScript | 2 files | 12 tests | [OK] 12 pass, 0 fail | 91% lines |",
    ].join("\n");

    // Act
    const errors = validatePolicyAuditSubstantiveRequirements(text);

    // Assert: no coverage rows parsed, so the missing-rows error is present.
    expect(errors).toContain(
      "Policy audit missing coverage metrics table rows.",
    );
  });
});
