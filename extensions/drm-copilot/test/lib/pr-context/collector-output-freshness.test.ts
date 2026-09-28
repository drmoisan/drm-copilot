import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import { type CollectedPrContext } from "../../../src/lib/pr-context/collector-core";
import { type PrContextResult } from "../../../src/lib/pr-context/models";
import {
  buildAppendixText,
  buildSummaryText,
} from "../../../src/lib/pr-context/collector-output";
import { appendGenerationTimestamp } from "../../../src/lib/pr-context/summary-helpers";

/**
 * Tests for the generated-context freshness header that both rendered
 * documents carry.
 *
 * The header exists so a consumer can decide, without parsing either document
 * body, whether a pair on disk describes the branch it is about to review. The
 * two checks it enables are pair identity (the timestamp is byte-identical in
 * both files, proving one invocation produced both) and head binding (the head
 * SHA equals the head of the branch under review). Existence and modification
 * time are not freshness signals, which is why neither is asserted here.
 *
 * Determinism comes from the injected clock and a fixed fixture SHA. No real
 * disk, no temporary file, and no wall-clock read.
 */

const FIXED_CLOCK = (): Date => new Date(Date.UTC(2026, 5, 26, 10, 2, 3));
/** Concrete forty-character fixture SHA supplied by these tests. */
const FIXTURE_HEAD_SHA = "0123456789abcdef0123456789abcdef01234567";
const GENERATED_CONTEXT_BANNER = "===== Context generated =====";

/** Build a base context result carrying the supplied head SHA. */
function contextResult(headSha: string | null): PrContextResult {
  return {
    text: "PR-CONTEXT-TEXT-BODY",
    referencedIssues: [],
    referencedPrs: [],
    verifiedClosing: [],
    invalidReferences: [],
    baseRef: "main",
    resolvedBase: "origin/main",
    baseSha: "base-sha",
    headRef: "feature/freshness",
    headSha,
    mergeBase: "merge-sha",
    revRange: "merge-sha..head-sha",
    ghAvailable: true,
  };
}

/** Build a minimal collected record carrying the supplied head SHA. */
function collected(headSha: string | null): CollectedPrContext {
  return {
    resolvedRoot: "/repo",
    contextResult: contextResult(headSha),
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
    head: "feature/freshness",
  };
}

/**
 * Render both documents from one shared freshness header, exactly as
 * `collectAndWrite` does.
 */
function renderPair(headSha: string | null): {
  readonly summaryText: string;
  readonly appendixText: string;
} {
  const record = collected(headSha);
  const generatedSection = appendGenerationTimestamp(
    FIXED_CLOCK,
    record.contextResult.headSha,
  );
  const summaryText = buildSummaryText(
    record,
    new TreeFileSystem(),
    "appendix.txt",
    generatedSection,
  );
  const appendixText = buildAppendixText(record, generatedSection);
  return { summaryText, appendixText };
}

/**
 * Extract the timestamp line that follows the generated-context banner.
 *
 * The section helper emits a blank line after the banner, so the timestamp is
 * the first non-empty line after it. The head-SHA line follows the timestamp.
 */
function timestampLineOf(text: string): string {
  const lines = text.split("\n");
  const bannerIndex = lines.indexOf(GENERATED_CONTEXT_BANNER);
  expect(bannerIndex).toBeGreaterThanOrEqual(0);
  for (let index = bannerIndex + 1; index < lines.length; index += 1) {
    const line = lines[index] ?? "";
    if (line !== "") {
      return line;
    }
  }
  return "";
}

/** Index of the generated-context banner among the section banners of a text. */
function firstBannerOf(text: string): string {
  const banner = text
    .split("\n")
    .find((line) => line.startsWith("===== ") && line.endsWith(" ====="));
  return banner ?? "";
}

describe("generated-context freshness header", () => {
  it("renders the generated-context section first in both documents with an identical timestamp", () => {
    // Arrange / Act
    const { summaryText, appendixText } = renderPair(FIXTURE_HEAD_SHA);

    // Assert: the first section of each rendered text is the generated-context
    // section.
    expect(firstBannerOf(summaryText)).toBe(GENERATED_CONTEXT_BANNER);
    expect(firstBannerOf(appendixText)).toBe(GENERATED_CONTEXT_BANNER);

    // Assert: the timestamp line extracted from each text is byte-identical.
    const summaryTimestamp = timestampLineOf(summaryText);
    expect(summaryTimestamp).toBe("2026-06-26 10:02:03 UTC");
    expect(summaryTimestamp).toBe(timestampLineOf(appendixText));
  });

  it("carries the head-SHA line built from the fixture SHA in both documents", () => {
    // Arrange / Act
    const { summaryText, appendixText } = renderPair(FIXTURE_HEAD_SHA);

    // Assert
    expect(FIXTURE_HEAD_SHA).toHaveLength(40);
    const expectedLine = `Head SHA: ${FIXTURE_HEAD_SHA}`;
    expect(summaryText).toContain(expectedLine);
    expect(appendixText).toContain(expectedLine);
  });

  it("renders the unknown token and raises no error when no head SHA is collected", () => {
    // Arrange / Act: rendering must not throw when the record carries no SHA.
    expect(() => renderPair(null)).not.toThrow();
    const rendered = renderPair(null);

    // Assert
    expect(rendered.summaryText).toContain("Head SHA: (unknown)");
    expect(rendered.appendixText).toContain("Head SHA: (unknown)");
    expect(rendered.summaryText).not.toContain(FIXTURE_HEAD_SHA);
  });
});
