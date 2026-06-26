import { describe, expect, it } from "@jest/globals";

import {
  CODE_REVIEW_REQUIRED_HEADINGS,
  FEATURE_AUDIT_REQUIRED_HEADINGS,
  validateCodeReviewText,
  validateFeatureAuditText,
} from "../../../src/lib/validate/review-artifacts";

const FINDINGS_TABLE_HEADER =
  "| Severity | File | Location | Finding | Recommendation | " +
  "Rationale | Evidence |";

/**
 * Build a valid code-review document containing both required headings and the
 * findings-table header so individual-omission tests can subtract one element.
 */
function validCodeReview(): string {
  return [
    "## Executive Summary",
    "Summary text.",
    "## Findings Table",
    FINDINGS_TABLE_HEADER,
    "| Low | a.ts | 1 | x | y | z | e |",
  ].join("\n");
}

/** Build a valid feature-audit document containing all required headings. */
function validFeatureAudit(): string {
  return FEATURE_AUDIT_REQUIRED_HEADINGS.map(
    (heading) => `${heading}\nbody\n`,
  ).join("\n");
}

describe("validateCodeReviewText", () => {
  it("returns no errors when all headings and the table header are present", () => {
    // Arrange
    const text = validCodeReview();

    // Act
    const errors = validateCodeReviewText(text);

    // Assert
    expect(errors).toEqual([]);
  });

  it("reports one error per missing code-review heading", () => {
    // Arrange: omit one heading at a time and assert its specific error.
    for (const omitted of CODE_REVIEW_REQUIRED_HEADINGS) {
      const text = validCodeReview().replace(omitted, "## Removed");

      // Act
      const errors = validateCodeReviewText(text);

      // Assert
      expect(errors).toContain(
        `Code review missing required heading: ${omitted}`,
      );
    }
  });

  it("reports the missing findings-table header error", () => {
    // Arrange: drop the findings-table header line only.
    const text = validCodeReview().replace(FINDINGS_TABLE_HEADER, "| no |");

    // Act
    const errors = validateCodeReviewText(text);

    // Assert
    expect(errors).toContain(
      "Code review missing the required findings table header.",
    );
  });
});

describe("validateFeatureAuditText", () => {
  it("returns no errors when all feature-audit headings are present", () => {
    // Arrange
    const text = validFeatureAudit();

    // Act
    const errors = validateFeatureAuditText(text);

    // Assert
    expect(errors).toEqual([]);
  });

  it("reports one error per missing feature-audit heading", () => {
    // Arrange: omit one heading at a time and assert its specific error.
    for (const omitted of FEATURE_AUDIT_REQUIRED_HEADINGS) {
      const text = validFeatureAudit().replace(omitted, "## Removed");

      // Act
      const errors = validateFeatureAuditText(text);

      // Assert
      expect(errors).toContain(
        `Feature audit missing required heading: ${omitted}`,
      );
    }
  });
});
