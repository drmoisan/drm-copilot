import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import { type GitClient } from "../../../src/lib/pr-context/git-client";
import {
  type IssueDetails,
  type PullRequestDetails,
} from "../../../src/lib/pr-context/models";
import {
  appendGenerationTimestamp,
  bucketText,
  extractDigestBullets,
  isScopingDoc,
  issueAppendix,
  issueDigest,
  parseNameStatusMap,
  parseNumstatDetailed,
  prAppendix,
  prDigest,
  scopingDocChanges,
} from "../../../src/lib/pr-context/summary-helpers";

/**
 * Tests for the summary helpers (`summary_helpers.py`). Pure functions are
 * exercised directly; `scopingDocChanges` uses a fixed-diff fake `GitClient`
 * and an in-memory `FileSystem`, and `appendGenerationTimestamp` uses an
 * injected fixed clock for determinism.
 */

/** Fake `GitClient` whose `diffRange` always returns a fixed text. */
function fakeGitWithDiff(diffText: string): GitClient {
  return {
    diffRange: (): string => diffText,
  } as unknown as GitClient;
}

const issue: IssueDetails = {
  number: "#10",
  title: "Test",
  state: "open",
  labels: ["bug"],
  assignees: ["alice"],
  author: "bob",
  createdAt: "2024-01-01",
  updatedAt: "2024-01-02",
  body: "## Why\n- reason one\n- reason two\n",
  comments: Array.from({ length: 6 }, (_unused, idx) => `comment ${idx}`),
  userStoryPath: null,
  userStoryContent: null,
};

const pr: PullRequestDetails = {
  number: "#21",
  title: "Improve docs",
  state: "open",
  author: "lee",
  baseRef: "main",
  headRef: "feature/docs",
  createdAt: "2024-01-01",
  updatedAt: "2024-01-02",
  mergedAt: null,
  labels: ["docs"],
  assignees: ["lee"],
  body: "## Why\n- clarify usage\n",
  closingIssues: ["#8"],
  filesChanged: ["a.md", "b.md", "c.md", "d.md"],
};

describe("parseNumstatDetailed", () => {
  it("collects totals and a per-file map", () => {
    const [adds, dels, mapping] = parseNumstatDetailed(
      "5\t1\ta.py\n3\t2\tdocs/readme.md",
    );
    expect(adds).toBe(8);
    expect(dels).toBe(3);
    expect(mapping.get("a.py")).toEqual([5, 1]);
    expect(mapping.get("docs/readme.md")).toEqual([3, 2]);
  });

  it("handles non-numeric entries as zero", () => {
    const [adds, dels, mapping] = parseNumstatDetailed(
      "-\t-\tfirst.txt\nnotnum\t3\tsecond.txt\n",
    );
    expect(adds).toBe(0);
    expect(dels).toBe(3);
    expect(mapping.get("first.txt")).toEqual([0, 0]);
    expect(mapping.get("second.txt")).toEqual([0, 3]);
  });
});

describe("parseNameStatusMap", () => {
  it("maps normalized paths to status codes", () => {
    const map = parseNameStatusMap("M\tsrc/a.py\nA\tsrc/b.py");
    expect(map.get("src/a.py")).toBe("M");
    expect(map.get("src/b.py")).toBe("A");
  });
});

describe("isScopingDoc", () => {
  it("recognizes scoping docs and rejects others", () => {
    expect(isScopingDoc("docs/features/active/feat/spec.md")).toBe(true);
    expect(isScopingDoc("docs/features/active/feat/plan.md")).toBe(true);
    expect(
      isScopingDoc("docs/features/active/feat/bug-remediation-plan.md"),
    ).toBe(true);
    expect(isScopingDoc("docs/features/active/feat/user-story.md")).toBe(true);
    expect(isScopingDoc("docs/features/ideas/idea.md")).toBe(false);
    expect(isScopingDoc("src/main.py")).toBe(false);
  });
});

describe("scopingDocChanges", () => {
  const path = "docs/features/active/fix-all-script/spec.md";

  it("flags a material change when a key heading is touched", () => {
    const git = fakeGitWithDiff(
      `+++ b/${path}\n+## Acceptance Criteria\n+New criteria`,
    );
    const changes = scopingDocChanges({
      git,
      fs: new TreeFileSystem(),
      mergeBase: "base",
      headSha: "head",
      root: "/repo",
      nameStatusText: `M\t${path}`,
      numstatDetails: new Map([[path, [10, 2]]]),
    });
    expect(changes.some((c) => c.material)).toBe(true);
  });

  it("marks a link/whitespace-only change as non-material", () => {
    const git = fakeGitWithDiff(
      `+++ b/${path}\n+http://example.com\n+[link](https://example.com)`,
    );
    const changes = scopingDocChanges({
      git,
      fs: new TreeFileSystem(),
      mergeBase: "base",
      headSha: "head",
      root: "/repo",
      nameStatusText: `M\t${path}`,
      numstatDetails: new Map([[path, [2, 0]]]),
    });
    expect(changes).toHaveLength(1);
    expect(changes[0]!.material).toBe(false);
  });

  it("returns empty when there is no range", () => {
    const changes = scopingDocChanges({
      git: fakeGitWithDiff(""),
      fs: new TreeFileSystem(),
      mergeBase: null,
      headSha: null,
      root: "/repo",
      nameStatusText: `M\t${path}`,
      numstatDetails: new Map(),
    });
    expect(changes).toEqual([]);
  });
});

describe("bucketText", () => {
  it("returns the 0-files form for an empty bucket", () => {
    expect(bucketText("Core", [])).toBe("Core: 0 files");
  });

  it("sorts entries by churn descending and caps at 10", () => {
    const entries: [string, [number, number]][] = [
      ["small.py", [1, 0]],
      ["big.py", [50, 10]],
    ];
    const result = bucketText("Core", entries);
    const lines = result.split("\n");
    expect(lines[0]).toBe("Core: 2 files");
    expect(lines[1]).toBe("- big.py (+50/-10)");
    expect(lines[2]).toBe("- small.py (+1/-0)");
  });
});

describe("extractDigestBullets", () => {
  it("skips blank lines within a section", () => {
    const body = "## Why\n- a\n\n- b\n";
    const bullets = extractDigestBullets(body, ["Why"], 8);
    expect(bullets).toEqual(["Why: a", "Why: b"]);
  });

  it("stops once the limit is reached", () => {
    const body = "## Why\n- a\n- b\n- c\n";
    const bullets = extractDigestBullets(body, ["Why"], 2);
    expect(bullets).toEqual(["Why: a", "Why: b"]);
  });
});

describe("issueDigest", () => {
  it("extracts heading bullets and truncates comments", () => {
    const digest = issueDigest(issue);
    expect(digest).toContain("reason one");
    expect(digest).toContain("TRUNCATED: last 3 comments shown");
  });

  it("falls back to state/labels metadata when no headings are present", () => {
    const minimal: IssueDetails = {
      ...issue,
      body: "plain body",
      comments: [],
    };
    const digest = issueDigest(minimal);
    expect(digest).toContain("State: open");
    expect(digest).toContain("(no comments)");
  });
});

describe("prDigest", () => {
  it("covers headings", () => {
    expect(prDigest(pr)).toContain("Why: clarify usage");
  });

  it("falls back to touched files and state when no headings are present", () => {
    const minimal: PullRequestDetails = { ...pr, body: "plain" };
    const digest = prDigest(minimal);
    expect(digest).toContain("Touches files: a.md, b.md, c.md ...");
    expect(digest).toContain("State: open");
  });

  it("omits the ellipsis when three or fewer files changed", () => {
    const minimal: PullRequestDetails = {
      ...pr,
      body: "plain",
      filesChanged: ["only.md"],
    };
    const digest = prDigest(minimal);
    expect(digest).toContain("Touches files: only.md");
    expect(digest).not.toContain("...");
  });

  it("lists only state when no files changed and no headings", () => {
    const minimal: PullRequestDetails = {
      ...pr,
      body: "plain",
      filesChanged: [],
    };
    const digest = prDigest(minimal);
    expect(digest).not.toContain("Touches files:");
    expect(digest).toContain("State: open");
  });
});

describe("issueAppendix", () => {
  it("truncates body and comments and includes the user story block", () => {
    const big: IssueDetails = {
      ...issue,
      body: Array.from({ length: 130 }, (_u, i) => `line ${i}`).join("\n"),
      comments: Array.from({ length: 15 }, (_u, i) => `note ${i}`),
      userStoryPath: "docs/story/user-story.md",
      userStoryContent: "Story content line 1\nline 2",
    };
    const appendix = issueAppendix(big);
    expect(appendix).toContain("TRUNCATED: first 120 lines shown");
    expect(appendix).toContain("TRUNCATED: last 10 comments shown");
    expect(appendix).toContain("User story (docs/story/user-story.md)");
    expect(appendix).toContain("Story content line");
  });
});

describe("prAppendix", () => {
  it("renders the files block and omits the raw body shape", () => {
    const appendix = prAppendix(pr);
    expect(appendix).toContain("Files (first 25):");
    expect(appendix).toContain("Auto-close issues (from this PR):");
  });
});

describe("appendGenerationTimestamp", () => {
  /** Concrete forty-character fixture SHA supplied by the test. */
  const FIXTURE_HEAD_SHA = "0123456789abcdef0123456789abcdef01234567";

  it("formats the injected clock as a UTC timestamp deterministically", () => {
    // Arrange: a fixed UTC instant and a fixed head SHA.
    const fixed = new Date(Date.UTC(2026, 5, 26, 10, 2, 3));
    // Act
    const result = appendGenerationTimestamp(() => fixed, FIXTURE_HEAD_SHA);
    // Assert
    expect(result).toContain("===== Context generated =====");
    expect(result).toContain("2026-06-26 10:02:03 UTC");
    expect(FIXTURE_HEAD_SHA).toHaveLength(40);
    expect(result).toContain(`Head SHA: ${FIXTURE_HEAD_SHA}`);
  });

  it("renders the unknown token when no head SHA is supplied", () => {
    const fixed = new Date(Date.UTC(2026, 5, 26, 10, 2, 3));
    const result = appendGenerationTimestamp(() => fixed);
    expect(result).toContain("Head SHA: (unknown)");
  });
});
