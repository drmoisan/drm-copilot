import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import { type CollectedPrContext } from "../../../src/lib/pr-context/collector-core";
import { type PrContextResult } from "../../../src/lib/pr-context/models";
import { buildSummaryText } from "../../../src/lib/pr-context/collector-output";

/**
 * Tests for the `Head ref (source):` line in the summary artifact's
 * `Base/Head` block (Decision 3 / Decision 6 of spec.md #675).
 *
 * Split from `collector-output.test.ts`, which is effectively full, matching
 * the existing split precedent set by `collector-output-freshness.test.ts`.
 * These tests assert the line's position relative to `Head ref (resolved):`,
 * not merely its presence, so a fallback cannot be read without the head it
 * produced being read in the same glance.
 */

const FIXED_GENERATED_SECTION = "===== Context generated =====\n\nfixture";

/** Build a base context result carrying the supplied resolved head ref. */
function contextResult(headRef: string | null): PrContextResult {
  return {
    text: "PR-CONTEXT-TEXT-BODY",
    referencedIssues: [],
    referencedPrs: [],
    verifiedClosing: [],
    invalidReferences: [],
    baseRef: "main",
    resolvedBase: "origin/main",
    baseSha: "base-sha",
    headRef,
    headSha: "head-sha",
    mergeBase: "merge-sha",
    revRange: "merge-sha..head-sha",
    ghAvailable: true,
  };
}

/** Build a minimal collected record carrying the supplied `head` option. */
function collected(head: string | null): CollectedPrContext {
  return {
    resolvedRoot: "/repo",
    contextResult: contextResult(head),
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
    head,
  };
}

/** Lines of the `Base/Head` block, in render order. */
function baseHeadLines(head: string | null): string[] {
  const record = collected(head);
  const summaryText = buildSummaryText(
    record,
    new TreeFileSystem(),
    "appendix.txt",
    FIXED_GENERATED_SECTION,
  );
  return summaryText.split("\n");
}

describe("Head ref (source) — Base/Head block", () => {
  it("renders Head ref (source) naming the explicit target in the Base/Head block", () => {
    const lines = baseHeadLines("feature/explicit-target");
    const resolvedIndex = lines.findIndex((line) =>
      line.startsWith("Head ref (resolved):"),
    );
    const sourceIndex = lines.findIndex((line) =>
      line.startsWith("Head ref (source):"),
    );

    expect(resolvedIndex).toBeGreaterThanOrEqual(0);
    expect(sourceIndex).toBeGreaterThan(resolvedIndex);
    expect(lines[sourceIndex]).toContain("feature/explicit-target");

    // Distinguishability: the explicit-target line must differ from the
    // session-fallback line rendered for the same Base/Head block.
    const fallbackLine = baseHeadLines(null).find((line) =>
      line.startsWith("Head ref (source):"),
    );
    expect(lines[sourceIndex]).not.toEqual(fallbackLine);
  });

  it("renders Head ref (source) naming the session fallback in the Base/Head block", () => {
    const lines = baseHeadLines(null);
    const resolvedIndex = lines.findIndex((line) =>
      line.startsWith("Head ref (resolved):"),
    );
    const sourceIndex = lines.findIndex((line) =>
      line.startsWith("Head ref (source):"),
    );

    expect(resolvedIndex).toBeGreaterThanOrEqual(0);
    expect(sourceIndex).toBeGreaterThan(resolvedIndex);
    expect(lines[sourceIndex]).toContain("session fallback");
    expect(lines[sourceIndex]).toContain("/repo");

    // Distinguishability: the session-fallback line must differ from the
    // explicit-target line rendered for the same Base/Head block.
    const explicitLine = baseHeadLines("feature/explicit-target").find(
      (line) => line.startsWith("Head ref (source):"),
    );
    expect(lines[sourceIndex]).not.toEqual(explicitLine);
  });
});
