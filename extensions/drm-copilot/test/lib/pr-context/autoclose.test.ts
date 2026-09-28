/**
 * Unit tests for the autoclose module (issue #622).
 *
 * Covers reference classification (D8), pending-primary selection (D3, D5),
 * and the autoclose section builder (D4, D5, D10-D12). The GitHub client is an
 * in-file fake that records every `issueDetails` call, so no process runs.
 */

import {
  buildIssuesToAutocloseSection,
  classifyReferences,
  selectPendingPrimary,
} from "../../../src/lib/pr-context/autoclose";
import { type GhClient } from "../../../src/lib/pr-context/gh-client-core";
import {
  AUTOCLOSE_PENDING_NOT_OPEN_TEXT,
  AUTOCLOSE_UNVERIFIED_ANNOTATION,
  type IssueDetails,
  section,
} from "../../../src/lib/pr-context/models";

type FakeGh = Pick<GhClient, "classifyEntity" | "issueDetails"> & {
  detailCalls: string[];
};

/**
 * Build a fake GitHub client from classification and state maps.
 *
 * @param classifications Entity type per bare number; unknown numbers are null.
 * @param states Issue state per bare number; unknown numbers are `(unknown)`.
 * @returns A fake client that records every `issueDetails` argument.
 */
function makeFakeGh(
  classifications: Record<string, "issue" | "pull">,
  states: Record<string, string> = {},
): FakeGh {
  const detailCalls: string[] = [];
  return {
    detailCalls,
    classifyEntity: (numberRef: string) => classifications[numberRef] ?? null,
    issueDetails: (numberRef: string): IssueDetails => {
      detailCalls.push(numberRef);
      return {
        number: numberRef,
        title: `Issue ${numberRef}`,
        state: states[numberRef] ?? "(unknown)",
        labels: [],
        assignees: [],
        author: "octocat",
        createdAt: "2026-01-01T00:00:00Z",
        updatedAt: "2026-01-01T00:00:00Z",
        body: "",
        comments: [],
        userStoryPath: null,
        userStoryContent: null,
      };
    },
  };
}

/**
 * Run `classifyReferences` into fresh sets.
 *
 * @param gh Fake client used for classification.
 * @param ghAvailable Whether gh is treated as available.
 * @param refs Feature, branch, and path refs, in that order.
 * @returns The issue, PR, and invalid sets as sorted arrays.
 */
function classify(
  gh: FakeGh,
  ghAvailable: boolean,
  refs: [string[], string[], string[]],
): { issues: string[]; prs: string[]; invalid: string[] } {
  const issues = new Set<string>();
  const prs = new Set<string>();
  const invalid = new Set<string>();
  classifyReferences({
    gh,
    ghAvailable,
    featureIssueRefs: refs[0],
    branchRefs: refs[1],
    pathRefs: refs[2],
    referencedIssuesSet: issues,
    referencedPrsSet: prs,
    invalidRefsSet: invalid,
  });
  return {
    issues: [...issues].sort(),
    prs: [...prs].sort(),
    invalid: [...invalid].sort(),
  };
}

const AUTOCLOSE_HEADER = section("Issues to autoclose (verified or pending)");

describe("selectPendingPrimary", () => {
  it("keeps an open issue", () => {
    // Arrange
    const gh = makeFakeGh({ "5": "issue" }, { "5": "open" });

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: true,
      pendingPrimary: ["#5"],
    });

    // Assert
    expect(selection.kept).toEqual(["#5"]);
    expect(selection.excluded).toBe(false);
  });

  it("keeps an OPEN issue", () => {
    // Arrange
    const gh = makeFakeGh({ "5": "issue" }, { "5": "OPEN" });

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: true,
      pendingPrimary: ["#5"],
    });

    // Assert
    expect(selection.kept).toEqual(["#5"]);
    expect(selection.excluded).toBe(false);
  });

  it("excludes a closed issue", () => {
    // Arrange
    const gh = makeFakeGh({ "5": "issue" }, { "5": "closed" });

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: true,
      pendingPrimary: ["#5"],
    });

    // Assert
    expect(selection.kept).toEqual([]);
    expect(selection.excluded).toBe(true);
    expect([...selection.fetchedDetails.keys()]).toEqual(["#5"]);
  });

  it("excludes an (unknown) state", () => {
    // Arrange
    const gh = makeFakeGh({ "5": "issue" }, { "5": "(unknown)" });

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: true,
      pendingPrimary: ["#5"],
    });

    // Assert
    expect(selection.kept).toEqual([]);
    expect(selection.excluded).toBe(true);
  });

  it("excludes a pull request", () => {
    // Arrange
    const gh = makeFakeGh({ "5": "pull" });

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: true,
      pendingPrimary: ["#5"],
    });

    // Assert
    expect(selection.kept).toEqual([]);
    expect(selection.excluded).toBe(true);
    expect(gh.detailCalls).toEqual([]);
  });

  it("excludes an unclassified ref", () => {
    // Arrange
    const gh = makeFakeGh({});

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: true,
      pendingPrimary: ["#5"],
    });

    // Assert
    expect(selection.kept).toEqual([]);
    expect(selection.excluded).toBe(true);
    expect(gh.detailCalls).toEqual([]);
  });

  it("keeps every ref when gh is unavailable", () => {
    // Arrange
    const gh = makeFakeGh({});

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: false,
      pendingPrimary: ["#5", "#6"],
    });

    // Assert
    expect(selection.kept).toEqual(["#5", "#6"]);
    expect(selection.excluded).toBe(false);
    expect(selection.fetchedDetails.size).toBe(0);
    expect(gh.detailCalls).toEqual([]);
  });

  it("fetches each issue at most once", () => {
    // Arrange
    const gh = makeFakeGh({ "5": "issue", "6": "pull" }, { "5": "open" });

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: true,
      pendingPrimary: ["#5", "#6"],
    });

    // Assert
    expect(gh.detailCalls).toEqual(["5"]);
    expect([...selection.fetchedDetails.keys()]).toEqual(["#5"]);
  });

  it("reports mixed outcomes", () => {
    // Arrange
    const gh = makeFakeGh(
      { "5": "issue", "6": "issue", "7": "pull" },
      { "5": "open", "6": "closed" },
    );

    // Act
    const selection = selectPendingPrimary({
      gh,
      ghAvailable: true,
      pendingPrimary: ["#5", "#6", "#7"],
    });

    // Assert
    expect(selection.kept).toEqual(["#5"]);
    expect(selection.excluded).toBe(true);
  });
});

describe("classifyReferences", () => {
  it("routes issue, pull, and invalid refs", () => {
    // Arrange
    const gh = makeFakeGh({ "1": "issue", "2": "pull" });

    // Act
    const result = classify(gh, true, [["#1"], ["#2"], ["#3"]]);

    // Assert
    expect(result).toEqual({ issues: ["#1"], prs: ["#2"], invalid: ["#3"] });
  });

  it("adds raw refs when gh is unavailable", () => {
    // Arrange
    const gh = makeFakeGh({ "2": "pull" });

    // Act
    const result = classify(gh, false, [["#1"], ["#2"], ["#3"]]);

    // Assert
    expect(result).toEqual({
      issues: ["#1", "#2", "#3"],
      prs: [],
      invalid: [],
    });
  });

  it("prefixes an unprefixed ref", () => {
    // Arrange
    const gh = makeFakeGh({ "9": "issue" });

    // Act
    const result = classify(gh, true, [[], ["9"], []]);

    // Assert
    expect(result).toEqual({ issues: ["#9"], prs: [], invalid: [] });
  });
});

describe("buildIssuesToAutocloseSection", () => {
  it("appends the unverified annotation when gh is unavailable", () => {
    // Arrange
    const expectedAnnotation =
      "Unverified: the issues listed above come from feature metadata only " +
      "and were not checked against GitHub (GitHub CLI unavailable).";

    // Act
    const result = buildIssuesToAutocloseSection({
      verified: [],
      pendingPrimary: ["#7"],
      readinessSignals: ["PASS"],
      ghAvailable: false,
      pendingPrimaryExcluded: false,
    });

    // Assert
    const lines = result.split("\n");
    const annotationLine = lines[lines.indexOf("- #7") + 1];
    expect(annotationLine).toBe(expectedAnnotation);
    expect(annotationLine?.startsWith("- ")).toBe(false);
  });

  it("omits the annotation when gh is available", () => {
    // Arrange
    const expected = [AUTOCLOSE_HEADER, "- #7"].join("\n");

    // Act
    const result = buildIssuesToAutocloseSection({
      verified: [],
      pendingPrimary: ["#7"],
      readinessSignals: ["PASS"],
      ghAvailable: true,
      pendingPrimaryExcluded: false,
    });

    // Assert
    expect(result).toBe(expected);
  });

  it("renders the not-open text when the pending primary is excluded", () => {
    // Arrange
    const expected = [AUTOCLOSE_HEADER, AUTOCLOSE_PENDING_NOT_OPEN_TEXT].join(
      "\n",
    );

    // Act
    const result = buildIssuesToAutocloseSection({
      verified: [],
      pendingPrimary: [],
      readinessSignals: ["PASS"],
      ghAvailable: true,
      pendingPrimaryExcluded: true,
    });

    // Assert
    expect(result).toBe(expected);
  });

  it.each<[string, boolean, string[], string[], string[], boolean, string]>([
    ["available-non-empty", true, [], ["#7"], ["PASS"], false, "- #7"],
    [
      "available-empty-excluded",
      true,
      [],
      [],
      ["PASS"],
      true,
      "None (deterministic pending issue is not an open issue)",
    ],
    [
      "available-empty-pass",
      true,
      [],
      [],
      ["PASS"],
      false,
      "None (no verified closing issues and no deterministic pending issue)",
    ],
    [
      "available-empty-non-pass",
      true,
      [],
      [],
      [],
      false,
      "None (no verified closing issues and readiness not PASS)",
    ],
    [
      "unavailable-non-empty",
      false,
      [],
      ["#7"],
      ["PASS"],
      false,
      `- #7\n${AUTOCLOSE_UNVERIFIED_ANNOTATION}`,
    ],
  ])(
    "applies the composed fallback precedence: %s",
    (
      _id,
      ghAvailable,
      verified,
      pendingPrimary,
      readinessSignals,
      pendingPrimaryExcluded,
      expectedBody,
    ) => {
      // Arrange
      const expected = [AUTOCLOSE_HEADER, expectedBody].join("\n");

      // Act
      const result = buildIssuesToAutocloseSection({
        verified,
        pendingPrimary,
        readinessSignals,
        ghAvailable,
        pendingPrimaryExcluded,
      });

      // Assert
      expect(result).toBe(expected);
    },
  );
});
