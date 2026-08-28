import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import { type CollectedPrContext } from "../../../src/lib/pr-context/collector-core";
import { type PrContextResult } from "../../../src/lib/pr-context/models";
import {
  buildAppendixText,
  buildSummaryText,
  renderVerificationEvidenceSection,
  writeOutput,
} from "../../../src/lib/pr-context/collector-output";
import { appendGenerationTimestamp } from "../../../src/lib/pr-context/summary-helpers";

/**
 * Tests for the collector output builder (`collector.py` rendering/write half).
 * The summary/appendix text content and ordering, the `(none)` placeholders, the
 * stale-base WARNING, the verification-evidence rows/fallback, and the
 * `writeOutput` overwrite/append semantics are asserted against representative
 * fixtures. No real disk is used.
 */

const ROOT = "/repo";
const FIXED_CLOCK = (): Date => new Date(Date.UTC(2026, 5, 26, 10, 2, 3));
/** Concrete forty-character fixture SHA supplied by these tests. */
const FIXTURE_HEAD_SHA = "0123456789abcdef0123456789abcdef01234567";
/** The single freshness header both builders receive, rendered once. */
const GENERATED_SECTION = appendGenerationTimestamp(
  FIXED_CLOCK,
  FIXTURE_HEAD_SHA,
);

/** Build a base context result with overridable fields. */
function contextResult(
  overrides: Partial<PrContextResult> = {},
): PrContextResult {
  return {
    text: "PR-CONTEXT-TEXT-BODY",
    referencedIssues: [],
    referencedPrs: [],
    verifiedClosing: [],
    invalidReferences: [],
    baseRef: "main",
    resolvedBase: "origin/main",
    baseSha: "base-sha",
    headRef: "feature/docs",
    headSha: "head-sha",
    mergeBase: "merge-sha",
    revRange: "merge-sha..head-sha",
    ghAvailable: true,
    ...overrides,
  };
}

/** Build a minimal collected record with overridable fields. */
function collected(
  overrides: Partial<CollectedPrContext> = {},
): CollectedPrContext {
  return {
    resolvedRoot: ROOT,
    contextResult: contextResult(),
    featureDocs: [],
    additionalContextFiles: [],
    referencedIssues: [],
    referencedPrs: [],
    invalidRefs: [],
    verified: [],
    verifiedReason: "None (no PR exists yet for this branch)",
    authorReason: "None (author has not asserted autoclose issues)",
    authorAsserted: [],
    issuesToAutocloseSection:
      "\n===== Issues to autoclose (verified or pending) =====\nNone (no verified closing issues and readiness not PASS)",
    issueDetails: [],
    prDetailsList: [],
    scopingChanges: [],
    materialScoping: [],
    nonMaterialScoping: [],
    ciStatus: null,
    ciJobs: [],
    bucketCore: [],
    bucketRenames: [],
    bucketDocs: [],
    ghAvailable: true,
    ghStatusOverride: null,
    ghStatusMessage: "GitHub CLI authenticated for owner/repo",
    head: "feature/docs",
    ...overrides,
  };
}

describe("buildSummaryText", () => {
  it("orders the canonical sections and uses placeholders", () => {
    const fs = new TreeFileSystem();
    const text = buildSummaryText(
      collected(),
      fs,
      "artifacts/pr_context.appendix.txt",
      GENERATED_SECTION,
    );

    // Section ordering is preserved, with the generated-context freshness
    // header added as the first entry ahead of the GitHub CLI status section.
    const order = [
      "===== Context generated =====",
      "===== GitHub CLI status =====",
      "===== PR Intent =====",
      "===== Base/Head =====",
      "===== Issues to autoclose (verified or pending) =====",
      "===== Close candidates =====",
      "===== Additional context files =====",
      "===== Feature doc excerpts =====",
      "===== Referenced issues (classified) =====",
      "===== PRs in range (classified) =====",
      "===== Invalid references (not found) =====",
      "===== Scoping docs changed =====",
      "===== Changed files overview =====",
      "===== Issue digests =====",
      "===== PR digests =====",
      "===== Verification evidence (feature docs + canonical artifacts) =====",
      "===== CI status (HEAD) =====",
      "===== Appendix pointer =====",
    ];
    let lastIndex = -1;
    for (const heading of order) {
      const index = text.indexOf(heading);
      expect(index).toBeGreaterThan(lastIndex);
      lastIndex = index;
    }
    // Placeholders and fallbacks.
    expect(text).toContain("(none)");
    expect(text).toContain("(not available)");
    expect(text).toContain("See artifacts/pr_context.appendix.txt");
    expect(text).toContain("No canonical verification evidence parsed");
  });

  it("emits the stale-base WARNING for a local resolved base", () => {
    const text = buildSummaryText(
      collected({
        contextResult: contextResult({ resolvedBase: "main" }),
      }),
      new TreeFileSystem(),
      "appendix.txt",
      GENERATED_SECTION,
    );
    expect(text).toContain(
      "WARNING: Requested base is local and may be stale; prefer origin/main",
    );
  });

  it("renders feature excerpts, scoping buckets, CI jobs, and digests", () => {
    const fs = new TreeFileSystem();
    const text = buildSummaryText(
      collected({
        featureDocs: [
          {
            feature: "feat-x",
            excerpt: "EXCERPT-X",
            issueRefs: [],
            contextFiles: ["docs/features/active/feat-x/spec.md"],
            primaryIssueRef: null,
            readinessSignal: null,
          },
        ],
        additionalContextFiles: ["docs/features/active/feat-x/spec.md"],
        materialScoping: [
          {
            path: "docs/features/active/feat-x/spec.md",
            reasons: ["new scoping doc"],
            excerpt: "EXCERPT-MATERIAL",
          },
          {
            path: "docs/features/active/feat-x/plan.md",
            reasons: [],
            excerpt: null,
          },
        ],
        nonMaterialScoping: [
          {
            path: "docs/features/active/feat-x/readme.md",
            reasons: ["link/whitespace-only changes"],
          },
        ],
        ciStatus: "failure",
        ciJobs: ["build", "test"],
        bucketCore: [["src/app.py", [3, 1]]],
        issueDetails: [
          {
            number: "#42",
            title: "Issue 42",
            state: "open",
            labels: [],
            assignees: [],
            author: "a",
            createdAt: "",
            updatedAt: "",
            body: "## Why\n- reason\n",
            comments: [],
            userStoryPath: null,
            userStoryContent: null,
          },
        ],
        prDetailsList: [
          {
            number: "#5",
            title: "PR 5",
            state: "open",
            author: "a",
            baseRef: "main",
            headRef: "f",
            createdAt: "",
            updatedAt: "",
            mergedAt: null,
            labels: [],
            assignees: [],
            body: "## Why\n- pr reason\n",
            closingIssues: [],
            filesChanged: [],
          },
        ],
      }),
      fs,
      "appendix.txt",
      GENERATED_SECTION,
    );
    expect(text).toContain("Feature: feat-x");
    expect(text).toContain("EXCERPT-X");
    expect(text).toContain("Scoping docs changed (material):");
    expect(text).toContain("EXCERPT-MATERIAL");
    expect(text).toContain("Scoping docs changed (non-material):");
    expect(text).toContain("Status: failure");
    expect(text).toContain("Failing jobs: build, test");
    expect(text).toContain("Core logic changes: 1 files");
    expect(text).toContain("Why: reason");
    expect(text).toContain("Why: pr reason");
  });

  it("appends the GitHub-unavailable note to referenced issues", () => {
    const text = buildSummaryText(
      collected({
        ghAvailable: false,
        ghStatusOverride: "GitHub CLI unavailable: offline",
      }),
      new TreeFileSystem(),
      "appendix.txt",
      GENERATED_SECTION,
    );
    expect(text).toContain("NOTE: Unverified (GitHub unavailable)");
    expect(text).toContain("GitHub CLI unavailable: offline");
  });
});

describe("buildAppendixText", () => {
  it("starts with the timestamp and embeds the context text", () => {
    const text = buildAppendixText(collected(), GENERATED_SECTION);
    expect(text).toContain("===== Context generated =====");
    expect(text).toContain("2026-06-26 10:02:03 UTC");
    expect(text).toContain(`Head SHA: ${FIXTURE_HEAD_SHA}`);
    expect(text).toContain("PR-CONTEXT-TEXT-BODY");
    expect(text).toContain("===== Issue details =====");
    expect(text).toContain("===== Contributing pull requests =====");
    expect(text).toContain("(none)");
  });

  it("appends the feature block when feature docs are present", () => {
    const text = buildAppendixText(
      collected({
        featureDocs: [
          {
            feature: "f",
            excerpt: "FEATURE-EXCERPT-BLOCK",
            issueRefs: [],
            contextFiles: [],
            primaryIssueRef: null,
            readinessSignal: null,
          },
        ],
      }),
      GENERATED_SECTION,
    );
    expect(text).toContain("FEATURE-EXCERPT-BLOCK");
  });
});

describe("renderVerificationEvidenceSection", () => {
  it("renders the expectation line for a non-zero declared expectation", () => {
    const fs = new TreeFileSystem();
    fs.addFile(
      `${ROOT}/docs/features/active/f/evidence/qa-gates/absence-gate.md`,
      "Timestamp: 2026-08-20T09-53\nCommand: git grep -n forbidden-token\nEXIT_CODE: 1\nExpectedExitCode: 1",
    );
    const section = renderVerificationEvidenceSection(fs, ROOT, [
      {
        feature: "f",
        excerpt: "",
        issueRefs: [],
        contextFiles: [
          "docs/features/active/f/evidence/qa-gates/absence-gate.md",
        ],
        primaryIssueRef: null,
        readinessSignal: null,
      },
    ]);
    const lines = section.split("\n");
    const exitIndex = lines.indexOf("  - EXIT_CODE: 1");
    const expectedIndex = lines.indexOf("  - Expected EXIT_CODE: 1");
    const resultIndex = lines.indexOf("  - Normalized result: pass");
    expect(expectedIndex).toBeGreaterThan(-1);
    expect(expectedIndex).toBe(exitIndex + 1);
    expect(resultIndex).toBe(expectedIndex + 1);
  });

  it.each([
    { label: "key omitted", expectationRow: "" },
    { label: "key written as zero", expectationRow: "\nExpectedExitCode: 0" },
  ])(
    "omits the expectation line when the expectation is zero ($label)",
    ({ expectationRow }) => {
      const fs = new TreeFileSystem();
      fs.addFile(
        `${ROOT}/docs/features/active/f/evidence/qa-gates/zero-gate.md`,
        `Timestamp: 2026-08-20T09-53\nCommand: npm test\nEXIT_CODE: 0${expectationRow}`,
      );
      const section = renderVerificationEvidenceSection(fs, ROOT, [
        {
          feature: "f",
          excerpt: "",
          issueRefs: [],
          contextFiles: [
            "docs/features/active/f/evidence/qa-gates/zero-gate.md",
          ],
          primaryIssueRef: null,
          readinessSignal: null,
        },
      ]);
      expect(section).not.toContain("Expected EXIT_CODE");
      expect(section.split("\n")).toEqual([
        "- Feature: f",
        "  - Source: docs/features/active/f/evidence/qa-gates/zero-gate.md",
        "  - Timestamp: 2026-08-20T09-53",
        "  - Command: npm test",
        "  - EXIT_CODE: 0",
        "  - Normalized result: pass",
      ]);
    },
  );

  it("renders rows for parseable evidence sorted by source", () => {
    const fs = new TreeFileSystem();
    fs.addFile(
      `${ROOT}/docs/features/active/f/evidence/qa-gates/a.md`,
      "Timestamp: 2026-01-01T00-00\nCommand: npm test\nEXIT_CODE: 0",
    );
    const section = renderVerificationEvidenceSection(fs, ROOT, [
      {
        feature: "f",
        excerpt: "",
        issueRefs: [],
        contextFiles: ["docs/features/active/f/evidence/qa-gates/a.md"],
        primaryIssueRef: null,
        readinessSignal: null,
      },
    ]);
    expect(section).toContain("- Feature: f");
    expect(section).toContain("  - EXIT_CODE: 0");
    expect(section).toContain("  - Normalized result: pass");
  });

  it("skips non-evidence paths and tolerates unreadable evidence files", () => {
    // One context file is not under /evidence/ (skipped); the other points to a
    // missing /evidence/ file (read failure tolerated) -> fallback text.
    const section = renderVerificationEvidenceSection(
      new TreeFileSystem(),
      ROOT,
      [
        {
          feature: "f",
          excerpt: "",
          issueRefs: [],
          contextFiles: [
            "docs/features/active/f/spec.md",
            "docs/features/active/f/evidence/qa-gates/missing.md",
          ],
          primaryIssueRef: null,
          readinessSignal: null,
        },
      ],
    );
    expect(section).toBe("No canonical verification evidence parsed");
  });

  it("sorts multiple evidence rows by source path", () => {
    const fs = new TreeFileSystem();
    fs.addFile(
      `${ROOT}/docs/features/active/f/evidence/qa-gates/b.md`,
      "Timestamp: t\nCommand: c\nEXIT_CODE: 1",
    );
    fs.addFile(
      `${ROOT}/docs/features/active/f/evidence/qa-gates/a.md`,
      "Timestamp: t\nCommand: c\nEXIT_CODE: 0",
    );
    const section = renderVerificationEvidenceSection(fs, ROOT, [
      {
        feature: "f",
        excerpt: "",
        issueRefs: [],
        contextFiles: [
          "docs/features/active/f/evidence/qa-gates/b.md",
          "docs/features/active/f/evidence/qa-gates/a.md",
        ],
        primaryIssueRef: null,
        readinessSignal: null,
      },
    ]);
    // a.md sorts before b.md regardless of input order.
    const aIndex = section.indexOf("a.md");
    const bIndex = section.indexOf("b.md");
    expect(aIndex).toBeGreaterThanOrEqual(0);
    expect(aIndex).toBeLessThan(bIndex);
  });

  it("returns the fallback when no evidence is parseable", () => {
    const section = renderVerificationEvidenceSection(
      new TreeFileSystem(),
      ROOT,
      [
        {
          feature: "f",
          excerpt: "",
          issueRefs: [],
          contextFiles: ["docs/features/active/f/spec.md"],
          primaryIssueRef: null,
          readinessSignal: null,
        },
      ],
    );
    expect(section).toBe("No canonical verification evidence parsed");
  });
});

describe("writeOutput", () => {
  it("overwrites by default", () => {
    const fs = new TreeFileSystem();
    fs.addFile("/repo/artifacts/out.txt", "old");
    writeOutput(fs, "new", "/repo/artifacts/out.txt", false);
    expect(fs.readTextFile("/repo/artifacts/out.txt")).toBe("new");
    expect(fs.ensuredDirs).toContain("/repo/artifacts");
  });

  it("appends to existing content when append is true", () => {
    const fs = new TreeFileSystem();
    fs.addFile("/repo/artifacts/out.txt", "old");
    writeOutput(fs, "-new", "/repo/artifacts/out.txt", true);
    expect(fs.readTextFile("/repo/artifacts/out.txt")).toBe("old-new");
  });

  it("writes fresh content in append mode when the file is absent", () => {
    const fs = new TreeFileSystem();
    writeOutput(fs, "fresh", "/repo/artifacts/out.txt", true);
    expect(fs.readTextFile("/repo/artifacts/out.txt")).toBe("fresh");
  });
});
