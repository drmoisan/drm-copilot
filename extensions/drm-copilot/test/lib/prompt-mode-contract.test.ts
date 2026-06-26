import { describe, expect, it } from "@jest/globals";

import {
  ACCEPTED_WORK_MODES,
  buildFallbackReason,
  CANONICAL_WORK_MODES,
  LEGACY_FULL_MODE,
  normalizeRequestedWorkMode,
  parseIssueWorkMode,
  resolveSelectedWorkMode,
} from "../../src/lib/prompt-mode-contract";

describe("prompt-mode-contract constants", () => {
  it("exposes canonical work modes", () => {
    // Arrange / Act / Assert
    expect(CANONICAL_WORK_MODES).toEqual([
      "minor-audit",
      "full-feature",
      "full-bug",
    ]);
  });

  it("exposes the legacy full mode and accepted set", () => {
    // Arrange / Act / Assert
    expect(LEGACY_FULL_MODE).toBe("full");
    expect(ACCEPTED_WORK_MODES).toEqual([
      "minor-audit",
      "full-feature",
      "full-bug",
      "full",
    ]);
  });
});

describe("parseIssueWorkMode", () => {
  it("parses a valid minor-audit marker", () => {
    // Arrange
    const content = "- Work Mode: minor-audit\n";

    // Act
    const result = parseIssueWorkMode(content);

    // Assert
    expect(result.mode).toBe("minor-audit");
    expect(result.malformed).toBe(false);
  });

  it("parses a valid full-feature marker", () => {
    // Arrange
    const content = "- Work Mode: full-feature\n";

    // Act
    const result = parseIssueWorkMode(content);

    // Assert
    expect(result.mode).toBe("full-feature");
    expect(result.malformed).toBe(false);
  });

  it("flags a malformed marker line", () => {
    // Arrange
    const content = "- Work Mode: maybe\n";

    // Act
    const result = parseIssueWorkMode(content);

    // Assert
    expect(result.mode).toBeNull();
    expect(result.malformed).toBe(true);
  });

  it("reports no marker and not malformed when marker absent", () => {
    // Arrange
    const content = "# no marker here\n";

    // Act
    const result = parseIssueWorkMode(content);

    // Assert
    expect(result.mode).toBeNull();
    expect(result.malformed).toBe(false);
  });
});

describe("resolveSelectedWorkMode", () => {
  it("normalizes the legacy full marker to full-feature", () => {
    // Arrange / Act / Assert
    expect(resolveSelectedWorkMode("- Work Mode: full\n")).toBe("full-feature");
  });

  it("fails closed to full-feature when marker missing", () => {
    // Arrange / Act / Assert
    expect(resolveSelectedWorkMode("# no marker here\n")).toBe("full-feature");
  });

  it("fails closed to full-feature when marker malformed", () => {
    // Arrange / Act / Assert
    expect(resolveSelectedWorkMode("- Work Mode: maybe\n")).toBe(
      "full-feature",
    );
  });

  it("returns full-feature when content is null", () => {
    // Arrange / Act / Assert
    expect(resolveSelectedWorkMode(null)).toBe("full-feature");
  });

  it("returns the canonical marker value when valid", () => {
    // Arrange / Act / Assert
    expect(resolveSelectedWorkMode("- Work Mode: full-bug\n")).toBe("full-bug");
  });
});

describe("normalizeRequestedWorkMode", () => {
  it("returns minor-audit unchanged", () => {
    // Arrange / Act / Assert
    expect(normalizeRequestedWorkMode("minor-audit", "feature")).toBe(
      "minor-audit",
    );
  });

  it("accepts full-feature for feature work", () => {
    // Arrange / Act / Assert
    expect(normalizeRequestedWorkMode("full-feature", "feature")).toBe(
      "full-feature",
    );
  });

  it("maps legacy full to full-bug for bug work", () => {
    // Arrange / Act / Assert
    expect(normalizeRequestedWorkMode("full", "bug")).toBe("full-bug");
  });

  it("maps legacy full to full-feature for feature work", () => {
    // Arrange / Act / Assert
    expect(normalizeRequestedWorkMode("full", "feature")).toBe("full-feature");
  });

  it("rejects full-bug for feature work", () => {
    // Arrange / Act / Assert
    expect(() => normalizeRequestedWorkMode("full-bug", "feature")).toThrow(
      "full-bug may only be used with bug work",
    );
  });

  it("rejects full-feature for bug work", () => {
    // Arrange / Act / Assert
    expect(() => normalizeRequestedWorkMode("full-feature", "bug")).toThrow(
      "full-feature may not be used with bug work",
    );
  });

  it("rejects an unrecognized work mode", () => {
    // Arrange / Act / Assert
    expect(() => normalizeRequestedWorkMode("unknown", "feature")).toThrow(
      "work_mode must be one of: minor-audit, full-feature, full-bug, full",
    );
  });
});

describe("buildFallbackReason", () => {
  it("is explicit for a missing marker", () => {
    // Arrange / Act / Assert
    expect(buildFallbackReason("# no marker\n")).toBe(
      "issue.md Work Mode marker missing; fail closed to full-feature",
    );
  });

  it("returns none for a valid marker", () => {
    // Arrange / Act / Assert
    expect(buildFallbackReason("- Work Mode: full-feature\n")).toBe("none");
  });

  it("describes the legacy full normalization", () => {
    // Arrange / Act / Assert
    expect(buildFallbackReason("- Work Mode: full\n")).toBe(
      "issue.md Work Mode marker uses legacy full; normalized to full-feature",
    );
  });

  it("describes a malformed marker", () => {
    // Arrange / Act / Assert
    expect(buildFallbackReason("- Work Mode: maybe\n")).toBe(
      "issue.md Work Mode marker malformed; fail closed to full-feature",
    );
  });

  it("returns the missing-file reason when content is null", () => {
    // Arrange / Act / Assert
    expect(buildFallbackReason(null)).toBe(
      "issue.md missing; fail closed to full-feature",
    );
  });
});
