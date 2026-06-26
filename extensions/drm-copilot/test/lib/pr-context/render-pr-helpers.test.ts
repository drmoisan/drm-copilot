import { describe, expect, it } from "@jest/globals";

import { type CommandResult } from "../../../src/lib/subprocess-runner";
import { type GitClient } from "../../../src/lib/pr-context/git-client";
import {
  buildCloseCandidatesSection,
  buildIssuesToAutocloseSection,
  convertNumstat,
  extensionSummary,
  extractChangedPaths,
  extractMergePrNumbers,
  formatDiffPath,
  selectDefaultBase,
  summarizeConventionalCommits,
} from "../../../src/lib/pr-context/render-pr-helpers";

/**
 * Tests for the PR rendering helpers (`render_pr_helpers.py`). `selectDefaultBase`
 * uses a fake `GitClient` returning queued results; the remaining helpers are
 * pure functions exercised directly.
 */

/** Fake `GitClient` exposing only the `run` method `selectDefaultBase` uses. */
function fakeGit(results: CommandResult[]): GitClient {
  const queue = [...results];
  // Only `run` is invoked by selectDefaultBase; cast through unknown so the
  // partial fake satisfies the GitClient type without the full surface.
  return {
    run: (): CommandResult =>
      queue.shift() ?? { stdout: "", stderr: "", code: 1 },
  } as unknown as GitClient;
}

const ok = (stdout: string): CommandResult => ({ stdout, stderr: "", code: 0 });
const fail = (): CommandResult => ({ stdout: "", stderr: "", code: 1 });

describe("selectDefaultBase", () => {
  it("returns origin/main when it verifies", () => {
    expect(selectDefaultBase(fakeGit([ok("abc123")]))).toBe("origin/main");
  });

  it("falls back to origin/master", () => {
    expect(selectDefaultBase(fakeGit([fail(), ok("def456")]))).toBe(
      "origin/master",
    );
  });

  it("returns null when no candidate verifies", () => {
    expect(
      selectDefaultBase(
        fakeGit([fail(), fail(), fail(), fail(), fail(), fail()]),
      ),
    ).toBeNull();
  });
});

describe("formatDiffPath", () => {
  it("returns empty string for null", () => {
    expect(formatDiffPath(null)).toBe("");
  });

  it("preserves whitespace-only strings", () => {
    expect(formatDiffPath("")).toBe("");
    expect(formatDiffPath("   ")).toBe("   ");
  });

  it("strips surrounding quotes", () => {
    expect(formatDiffPath('"file.py"')).toBe("file.py");
  });

  it("collapses brace renames", () => {
    expect(formatDiffPath("file{old => new}.py")).toBe("filenew.py");
  });

  it("resolves arrow renames", () => {
    expect(formatDiffPath("old/path.py => new/path.py")).toBe("new/path.py");
  });

  it("returns a plain path unchanged", () => {
    expect(formatDiffPath("src/module.py")).toBe("src/module.py");
  });
});

describe("convertNumstat", () => {
  it("parses a single file", () => {
    expect(convertNumstat("10\t5\tsrc/file.py")).toEqual([
      10,
      5,
      ["src/file.py"],
    ]);
  });

  it("sums multiple files", () => {
    expect(convertNumstat("10\t5\tfile1.py\n20\t15\tfile2.py")).toEqual([
      30,
      20,
      ["file1.py", "file2.py"],
    ]);
  });

  it("handles binary markers", () => {
    expect(convertNumstat("10\t5\tfile.py\n-\t-\tbinary.bin")).toEqual([
      10,
      5,
      ["file.py", "binary.bin"],
    ]);
  });

  it("returns zeros for empty input", () => {
    expect(convertNumstat("")).toEqual([0, 0, []]);
  });

  it("skips malformed lines", () => {
    expect(
      convertNumstat("10\t5\tfile.py\nmalformed\n20\t10\tfile2.py"),
    ).toEqual([30, 15, ["file.py", "file2.py"]]);
  });
});

describe("extensionSummary", () => {
  it("groups files by extension with %8d formatting", () => {
    const result = extensionSummary(["file1.py", "file2.py", "file3.js"]);
    expect(result).toContain("       2  .py");
    expect(result).toContain("       1  .js");
  });

  it("labels files without an extension as (noext)", () => {
    expect(extensionSummary(["Makefile", "README"])).toContain("(noext)");
  });

  it("returns empty for an empty list", () => {
    expect(extensionSummary([])).toBe("");
  });
});

describe("extractMergePrNumbers", () => {
  it("extracts PR numbers from merge commits", () => {
    expect(
      extractMergePrNumbers([
        "Merge pull request #42 from branch",
        "Merge pull request #100",
      ]),
    ).toEqual(["#100", "#42"]);
  });

  it("returns empty for non-merge commits", () => {
    expect(extractMergePrNumbers(["Normal commit", "Another"])).toEqual([]);
  });
});

describe("summarizeConventionalCommits", () => {
  it("counts each recognized type", () => {
    const result = summarizeConventionalCommits("feat: a\nfeat: b\nfix: c");
    expect(result).toContain("feat");
    expect(result).toContain("fix");
  });

  it("buckets unrecognized lines as other", () => {
    const result = summarizeConventionalCommits(
      "feat: a\nrandom commit\nfix: b",
    );
    expect(result).toContain("other");
    expect(result).not.toContain("random");
  });

  it("handles scoped commits", () => {
    expect(summarizeConventionalCommits("feat(api): x\nfix(ui): y")).toContain(
      "feat",
    );
  });

  it("returns the fallback for empty input", () => {
    expect(summarizeConventionalCommits("")).toBe(
      "(no recognizable conventional commit types)",
    );
  });
});

describe("buildCloseCandidatesSection", () => {
  it("formats all candidate groups", () => {
    const result = buildCloseCandidatesSection({
      verified: ["#1", "#2"],
      authorAsserted: ["#3"],
      referenced: ["#4", "#5"],
      verifiedReason: "Found in PR metadata",
      authorReason: "Found in commits",
    });
    expect(result).toContain("Close candidates");
    expect(result).toContain("#1");
    expect(result).toContain("#3");
  });

  it("merges author-asserted and referenced into author auto-close", () => {
    const result = buildCloseCandidatesSection({
      verified: [],
      authorAsserted: ["#1"],
      referenced: ["#2", "#1"],
      verifiedReason: "(none)",
      authorReason: "(found)",
    });
    expect(result).toContain("#1");
    expect(result).toContain("#2");
  });
});

describe("buildIssuesToAutocloseSection", () => {
  it("lists verified then pending refs without duplicates", () => {
    const result = buildIssuesToAutocloseSection({
      verified: ["#1"],
      pendingPrimary: ["#1", "#2"],
      readinessSignals: ["PASS"],
    });
    expect(result).toContain(
      "===== Issues to autoclose (verified or pending) =====",
    );
    expect(result).toContain("- #1");
    expect(result).toContain("- #2");
  });

  it("uses the PASS fallback text when nothing is present and readiness is PASS", () => {
    const result = buildIssuesToAutocloseSection({
      verified: [],
      pendingPrimary: [],
      readinessSignals: ["PASS"],
    });
    expect(result).toContain(
      "None (no verified closing issues and no deterministic pending issue)",
    );
  });

  it("uses the non-PASS fallback text otherwise", () => {
    const result = buildIssuesToAutocloseSection({
      verified: [],
      pendingPrimary: [],
      readinessSignals: ["NEEDS REVISION"],
    });
    expect(result).toContain(
      "None (no verified closing issues and readiness not PASS)",
    );
  });
});

describe("extractChangedPaths", () => {
  it("parses tab-bearing lines after the section header", () => {
    const context =
      "===== Changed files =====\n10\t5\tfile1.py\n20\t10\tfile2.py\n=====";
    expect(extractChangedPaths(context)).toEqual(["file1.py", "file2.py"]);
  });

  it("returns empty when there is no changed-files section", () => {
    expect(extractChangedPaths("Some other text")).toEqual([]);
  });

  it("returns empty when the section is immediately closed", () => {
    expect(extractChangedPaths("===== Changed files =====\n=====")).toEqual([]);
  });

  it("parses non-tab lines as whole-path entries", () => {
    const context = "===== Changed files =====\nplain/path.py\n=====";
    expect(extractChangedPaths(context)).toEqual(["plain/path.py"]);
  });
});
