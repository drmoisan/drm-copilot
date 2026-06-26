import { describe, expect, it } from "@jest/globals";

import {
  buildBody,
  buildBugBody,
  buildMinorAuditBody,
  BUG_SECTION_HEADINGS,
  evaluateMinorAuditEligibility,
  extractLastUpdated,
  findMetaEnd,
  getFeatureName,
  getFeaturePath,
  getSection,
  normalizeSmartPunctuation,
  parseIssueReference,
  PLACEHOLDER,
  setLineValue,
  stripPotentialMarker,
  updateMetadataLines,
} from "../../../src/lib/potential-to-issue/content";

/**
 * Tests for the content/metadata helpers ported from the bundled
 * `potential_to_issue_content.py`. Scenarios mirror
 * `tests/scripts/dev_tools/test_potential_to_issue_content.py` and the
 * content-helper cases in `test_potential_to_issue.py`. All helpers are pure;
 * no subprocess, filesystem, or temp files are used.
 */
describe("content helpers — getFeatureName", () => {
  it("returns the first H1 heading text", () => {
    // Arrange / Act / Assert
    expect(getFeatureName("# My Feature Name\n## Section", "test.md")).toBe(
      "My Feature Name",
    );
  });

  it("strips a trailing (Potential) marker from the heading", () => {
    expect(getFeatureName("# Feature (Potential)\n", "test.md")).toBe(
      "Feature",
    );
  });

  it("strips a (Potential Bug) marker from the heading", () => {
    expect(getFeatureName("# Bug Title (Potential Bug)\n", "test.md")).toBe(
      "Bug Title",
    );
  });

  it("trims whitespace and marker around the heading text", () => {
    expect(getFeatureName("#   Feature Name (Potential)  \n", "test.md")).toBe(
      "Feature Name",
    );
  });

  it("uses the first heading when multiple H1s are present", () => {
    expect(
      getFeatureName("# First Feature\n## Second\n# Third", "test.md"),
    ).toBe("First Feature");
  });

  it("falls back to the basename with .md removed when no heading exists", () => {
    expect(getFeatureName("No heading", "feature-name.md")).toBe(
      "feature-name",
    );
  });

  it("falls back to the full basename when it has no .md extension", () => {
    expect(getFeatureName("No heading", "my-feature")).toBe("my-feature");
  });
});

describe("content helpers — getFeaturePath", () => {
  it("replaces spaces with underscores", () => {
    expect(getFeaturePath("My Feature Name")).toBe("My_Feature_Name");
  });

  it("strips disallowed characters after underscore replacement", () => {
    expect(getFeaturePath("Feature: (v2.0) @ Test!")).toBe("Feature_v20__Test");
  });

  it("collapses runs of whitespace into a single underscore", () => {
    expect(getFeaturePath("Feature   Name")).toBe("Feature_Name");
  });

  it("preserves hyphens already present", () => {
    expect(getFeaturePath("my-feature-name")).toBe("my-feature-name");
  });

  it("handles a single-character name", () => {
    expect(getFeaturePath("A")).toBe("A");
  });
});

describe("content helpers — stripPotentialMarker", () => {
  it("returns the trimmed original when stripping empties the value", () => {
    // A value consisting solely of a marker falls back to the trimmed original.
    expect(stripPotentialMarker("(Potential)")).toBe("(Potential)");
  });
});

describe("content helpers — getSection", () => {
  it("extracts a single-line section body", () => {
    const content = "## Problem / Why\nabc\n## Proposed Behavior\ndef";
    expect(getSection(content, "Problem / Why")).toBe("abc");
  });

  it("extracts a multi-line section body up to the next heading", () => {
    const multiLine =
      "## Problem / Why\nline1\nline2\nline3\n## Next Section\nother";
    expect(getSection(multiLine, "Problem / Why")).toBe("line1\nline2\nline3");
  });

  it("returns an empty string for a missing heading", () => {
    const content = "## Problem / Why\nabc\n## Proposed Behavior\ndef";
    expect(getSection(content, "NonExistent")).toBe("");
  });

  it("extracts the final section body at end-of-string", () => {
    const endSection = "## Problem / Why\nabc\n## Last Section\nfinal content";
    expect(getSection(endSection, "Last Section")).toBe("final content");
  });

  it("trims only the outer whitespace of the section body", () => {
    const trimmed = "## Problem / Why\n  abc  \n  def  \n## Next";
    expect(getSection(trimmed, "Problem / Why")).toBe("abc  \n  def");
  });

  it("matches a heading containing parentheses", () => {
    const specialHeading =
      "## Acceptance Criteria (early draft)\ncontent here\n## Next";
    expect(
      getSection(specialHeading, "Acceptance Criteria (early draft)"),
    ).toBe("content here");
  });

  it("returns an empty string for an empty section body", () => {
    const emptySection = "## Problem / Why\n\n## Proposed Behavior\ndef";
    expect(getSection(emptySection, "Problem / Why")).toBe("");
  });

  it("handles Windows CRLF line endings", () => {
    const windowsEndings =
      "## Problem / Why\r\nabc\r\n## Proposed Behavior\r\ndef";
    expect(getSection(windowsEndings, "Problem / Why")).toBe("abc");
  });
});

describe("content helpers — body builders", () => {
  it("buildBody emits sections, work-mode line, and source footer with spacing", () => {
    // Act
    const body = buildBody(
      "full-feature",
      "why",
      "behave",
      "criteria",
      "risk",
      "tests",
      "docs/features/potential/sample.md",
    );

    // Assert: exact composition.
    expect(body).toBe(
      "- Work Mode: full-feature\n" +
        "## Problem / Why\nwhy\n\n" +
        "## Proposed Behavior\nbehave\n\n" +
        "## Acceptance Criteria\ncriteria\n\n" +
        "## Constraints & Risks\nrisk\n\n" +
        "## Test Conditions\ntests\n\n" +
        "## Source\nFrom: docs/features/potential/sample.md\n",
    );
  });

  it("buildBugBody preserves canonical heading order and footer", () => {
    // Arrange
    const sections: Record<string, string> = {};
    for (const heading of BUG_SECTION_HEADINGS) {
      sections[heading] = heading.toLowerCase();
    }

    // Act
    const body = buildBugBody(
      "full-bug",
      sections,
      "docs/features/potential/sample.md",
    );

    // Assert: headings appear in canonical order; marker and footer correct.
    const positions = BUG_SECTION_HEADINGS.map((heading) =>
      body.indexOf(`## ${heading}`),
    );
    const sorted = [...positions].sort((a, b) => a - b);
    expect(positions).toEqual(sorted);
    expect(body.startsWith("- Work Mode: full-bug")).toBe(true);
    expect(
      body
        .trimEnd()
        .endsWith("## Source\nFrom: docs/features/potential/sample.md"),
    ).toBe(true);
  });

  it("buildMinorAuditBody emits the minor-audit section set", () => {
    // Act
    const body = buildMinorAuditBody(
      "minor-audit",
      "problem",
      "intent",
      "criteria",
      "deps",
      "verify",
      "- [ ] Baseline",
      "docs/features/potential/m.md",
    );

    // Assert: exact composition including minor-audit-only sections.
    expect(body).toBe(
      "- Work Mode: minor-audit\n" +
        "## Problem / Why\nproblem\n\n" +
        "## Implementation Intent\nintent\n\n" +
        "## Acceptance Criteria\ncriteria\n\n" +
        "## Dependencies / Risks\ndeps\n\n" +
        "## Verification Steps\nverify\n\n" +
        "## Evidence Checklist\n- [ ] Baseline\n\n" +
        "## Source\nFrom: docs/features/potential/m.md\n",
    );
  });
});

describe("content helpers — evaluateMinorAuditEligibility", () => {
  it("accepts a bootstrapped keyword on the fast path", () => {
    expect(
      evaluateMinorAuditEligibility("This entry is bootstrapped."),
    ).toEqual([true, "eligible: bootstrapped/pre-cooked"]);
  });

  it("accepts a pre-cooked keyword on the fast path", () => {
    expect(evaluateMinorAuditEligibility("It is pre-cooked already.")).toEqual([
      true,
      "eligible: bootstrapped/pre-cooked",
    ]);
  });

  it("accepts <=3 production files with a low integration risk signal", () => {
    const content = [
      "- file: a.py",
      "- production file: b.py",
      "low integration risk",
    ].join("\n");
    expect(evaluateMinorAuditEligibility(content)).toEqual([
      true,
      "eligible: <=3 production files and low integration risk",
    ]);
  });

  it("falls back when more than three production files are present", () => {
    const content = [
      "- file: a.py",
      "- production file: b.py",
      "- file: c.py",
      "- file: d.py",
      "risk: low",
    ].join("\n");
    expect(evaluateMinorAuditEligibility(content)).toEqual([
      false,
      "fallback: production file count exceeds 3",
    ]);
  });

  it("falls back when the low integration risk signal is missing", () => {
    const content = ["- file: a.py", "- file: b.py"].join("\n");
    expect(evaluateMinorAuditEligibility(content)).toEqual([
      false,
      "fallback: missing low integration risk signal",
    ]);
  });
});

describe("content helpers — parseIssueReference", () => {
  it("returns the URL and number for a matching line", () => {
    expect(
      parseIssueReference(["Created: https://example.com/issues/123"]),
    ).toEqual(["https://example.com/issues/123", "123"]);
  });

  it("returns nulls when no issue URL is present", () => {
    expect(parseIssueReference(["nothing here"])).toEqual([null, null]);
  });
});

describe("content helpers — extractLastUpdated", () => {
  it("returns the date portion for a valid payload", () => {
    expect(extractLastUpdated('{"updatedAt": "2024-01-02T00:00:00Z"}')).toBe(
      "2024-01-02",
    );
  });

  it("returns null for invalid JSON", () => {
    expect(extractLastUpdated("{not json")).toBeNull();
  });

  it("returns null for a non-string updatedAt", () => {
    expect(extractLastUpdated('{"updatedAt": 123}')).toBeNull();
  });

  it("returns null for an unparseable timestamp", () => {
    expect(extractLastUpdated('{"updatedAt": "not-a-timestamp"}')).toBeNull();
  });

  it("returns null for a missing updatedAt field", () => {
    expect(extractLastUpdated('{"number": 5}')).toBeNull();
  });
});

describe("content helpers — findMetaEnd", () => {
  it("returns the index of the first section heading", () => {
    expect(findMetaEnd(["# Title", "- Issue: #1", "## Problem", "body"])).toBe(
      2,
    );
  });

  it("returns the line count when no section heading exists", () => {
    expect(findMetaEnd(["# Title", "- Issue: #1"])).toBe(2);
  });
});

describe("content helpers — setLineValue", () => {
  it("replaces an existing label line in place and keeps the boundary", () => {
    // Arrange
    const lines = ["# Title", "- Issue: #1", "## Problem"];

    // Act
    const next = setLineValue(lines, "Issue", "#42", 2);

    // Assert: replaced in place; boundary unchanged.
    expect(lines[1]).toBe("- Issue: #42");
    expect(next).toBe(2);
  });

  it("inserts a missing label line at the boundary and advances it", () => {
    // Arrange
    const lines = ["# Title", "## Problem"];

    // Act
    const next = setLineValue(lines, "Issue", "#42", 1);

    // Assert: inserted at index 1; boundary advanced by one.
    expect(lines[1]).toBe("- Issue: #42");
    expect(next).toBe(2);
  });
});

describe("content helpers — normalizeSmartPunctuation", () => {
  it("replaces every occurrence of each mapped character", () => {
    const raw = "“quoted” ‘apostrophe’ ’dash’ – — ";
    expect(normalizeSmartPunctuation(raw)).toBe(
      "\"quoted\" 'apostrophe' 'dash' - - ",
    );
  });
});

describe("content helpers — updateMetadataLines", () => {
  it("rewrites the title and sets Issue/Issue URL/Last Updated/Status", () => {
    // Arrange
    const lines = ["# Feature Title", "## Problem / Why", "problem"];

    // Act
    const updated = updateMetadataLines(
      lines,
      "Feature Title",
      "123",
      "https://example.com/issues/123",
      "2026-03-14",
      "Feature_Title",
    );

    // Assert
    expect(updated[0]).toBe("# Feature Title (Issue #123)");
    expect(updated).toContain("- Issue: #123");
    expect(updated).toContain("- Issue URL: https://example.com/issues/123");
    expect(updated).toContain("- Last Updated: 2026-03-14");
    expect(updated).toContain(
      "- Status: Promoted -> docs/features/active/Feature_Title/ (Issue #123)",
    );
  });

  it("omits the Last Updated line when no date is provided", () => {
    // Arrange
    const lines = ["# Feature Title", "## Problem / Why", "problem"];

    // Act
    const updated = updateMetadataLines(
      lines,
      "Feature Title",
      "200",
      "https://example.com/issues/200",
      null,
      "Feature_Title",
    );

    // Assert: no Last Updated line, but Status still present.
    expect(updated.some((line) => line.startsWith("- Last Updated:"))).toBe(
      false,
    );
    expect(updated).toContain(
      "- Status: Promoted -> docs/features/active/Feature_Title/ (Issue #200)",
    );
  });
});

describe("content helpers — PLACEHOLDER constant", () => {
  it("is the byte-identical placeholder string", () => {
    expect(PLACEHOLDER).toBe("(not provided in potential file)");
  });
});
