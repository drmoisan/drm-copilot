/**
 * Code-review and feature-audit orchestration-artifact validators.
 *
 * Purpose:
 *     Port the review-oriented validators from
 *     `scripts/dev_tools/validate_orchestration_review_artifacts.py`. The two
 *     pure functions check for the required headings and findings-table header
 *     that repository code reviews and feature audits must contain.
 *
 * Responsibilities:
 *     - `validateCodeReviewText`: require the code-review headings and findings
 *       table header.
 *     - `validateFeatureAuditText`: require the canonical feature-audit sections.
 *
 * Invariants / Constraints:
 *     - The functions return arrays of error strings and never print or mutate
 *       input. Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */

/** Required headings for an audit-grade code review. */
export const CODE_REVIEW_REQUIRED_HEADINGS = [
  "## Executive Summary",
  "## Findings Table",
] as const;

/** Required canonical sections for a feature-audit artifact. */
export const FEATURE_AUDIT_REQUIRED_HEADINGS = [
  "## Scope and Baseline",
  "## Acceptance Criteria Inventory",
  "## Acceptance Criteria Evaluation",
  "## Summary",
  "## Acceptance Criteria Check-off",
] as const;

/** The exact findings-table header a code review must include. */
const CODE_REVIEW_FINDINGS_TABLE_HEADER =
  "| Severity | File | Location | Finding | Recommendation | " +
  "Rationale | Evidence |";

/**
 * Validate audit-grade code-review structure.
 *
 * Purpose:
 *     Require the minimal headings and findings table that repository code
 *     reviews must include.
 *
 * @param text Full code-review artifact text.
 * @returns Validation errors for missing headings or table structure.
 */
export function validateCodeReviewText(text: string): string[] {
  const errors: string[] = [];

  // Require each canonical heading; absence of any heading is reported once.
  for (const heading of CODE_REVIEW_REQUIRED_HEADINGS) {
    if (!text.includes(heading)) {
      errors.push(`Code review missing required heading: ${heading}`);
    }
  }

  if (!text.includes(CODE_REVIEW_FINDINGS_TABLE_HEADER)) {
    errors.push("Code review missing the required findings table header.");
  }

  return errors;
}

/**
 * Validate feature-audit structure.
 *
 * Purpose:
 *     Require the canonical sections that tie implementation evidence back to
 *     acceptance criteria.
 *
 * @param text Full feature-audit artifact text.
 * @returns Validation errors for any missing canonical sections.
 */
export function validateFeatureAuditText(text: string): string[] {
  const errors: string[] = [];

  // Require each canonical feature-audit section; report each missing heading.
  for (const heading of FEATURE_AUDIT_REQUIRED_HEADINGS) {
    if (!text.includes(heading)) {
      errors.push(`Feature audit missing required heading: ${heading}`);
    }
  }

  return errors;
}
