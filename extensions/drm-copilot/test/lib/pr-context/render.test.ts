import { describe, expect, it } from "@jest/globals";

import { type CommandResult } from "../../../src/lib/subprocess-runner";
import { type GitClient } from "../../../src/lib/pr-context/git-client";
import {
  type GhLike,
  buildPrContext,
  resolveFeatureDir,
} from "../../../src/lib/pr-context/render";
import { type PullRequestDetails } from "../../../src/lib/pr-context/models";
import { TreeFileSystem } from "./tree-file-system";

/**
 * Tests for `buildPrContext` (`render.py`). A configurable fake `GitClient`
 * scripts each method (mirroring the Python FakeGit), and a fake `GhLike`
 * classifies references. The combined-text ordering, classification, merge-PR
 * exclusion, stale-base warning, gh-unavailable fallback, and the failure block
 * are exercised.
 */

const ok = (stdout: string): CommandResult => ({ stdout, stderr: "", code: 0 });
const notFound = (): CommandResult => ({ stdout: "", stderr: "", code: 1 });

/** Behaviors a test can override on the fake git client. */
interface FakeGitConfig {
  runByArgs?: (args: readonly string[]) => CommandResult;
  revParse?: (ref: string) => string;
  mergeBase?: (base: string, head: string) => string;
  log?: (fmt: string, revRange: string) => string;
  diffRange?: (args: readonly string[]) => string;
  branchName?: string;
  upstream?: string;
  throwOnRevParse?: boolean;
}

/** Build a fake GitClient covering the surface `buildPrContext` uses. */
function fakeGit(config: FakeGitConfig = {}): GitClient {
  const impl = {
    run: (args: readonly string[]): CommandResult =>
      (config.runByArgs ?? (() => ok("resolved")))(args),
    branchName: (): string => config.branchName ?? "feature/test",
    upstream: (): string => config.upstream ?? "origin/feature/test",
    remoteVerbose: (): string => "origin https://example/repo (fetch)",
    statusShort: (): string => "## feature/test...origin/feature/test",
    untracked: (): string => "",
    diffNameStatus: (): string => "",
    diffPatch: (): string => "(diff omitted)",
    revParse: (ref: string): string => {
      if (config.throwOnRevParse) {
        throw new Error("rev-parse failed");
      }
      return (
        config.revParse ??
        ((r: string) => (r === "main" ? "basehash" : "headhash"))
      )(ref);
    },
    mergeBase: (base: string, head: string): string =>
      (config.mergeBase ?? ((b: string) => b))(base, head),
    log: (fmt: string, revRange: string): string =>
      (config.log ?? defaultLog)(fmt, revRange),
    diffRange: (args: readonly string[]): string =>
      (config.diffRange ?? defaultDiffRange)(args),
  };
  return impl as unknown as GitClient;
}

/** Default git log output matching the Python FakeGit. */
function defaultLog(fmt: string): string {
  if (fmt.startsWith("--pretty=format:")) {
    return [
      "a1 2025-01-01 alice Merge pull request #53",
      "a2 2025-01-02 bob fix(scope): closes #44",
    ].join("\n");
  }
  if (fmt === "--pretty=%s") {
    return "Merge pull request #53\nfix(scope): closes #44";
  }
  if (fmt === "--format=%an <%ae>") {
    return "alice <a@example.com>\nbob <b@example.com>";
  }
  return "";
}

/** Default diff-range output matching the Python FakeGit. */
function defaultDiffRange(args: readonly string[]): string {
  if (args.includes("--name-status")) {
    return "M\tdocs/features/active/fix-all-script/spec.md";
  }
  if (args.includes("--numstat")) {
    return "4\t2\tdocs/features/active/fix-all-script/spec.md";
  }
  if (args.includes("--shortstat")) {
    return " 1 files changed, 4 insertions(+), 2 deletions(-)";
  }
  if (args.includes("--stat")) {
    return " spec.md | 6 +-";
  }
  return "";
}

/** Fake GhLike classifying #44 as issue and #53 as pull. */
function fakeGh(available = true): GhLike {
  return {
    available,
    ensureAvailable(): void {
      // available by default
    },
    classifyEntity(numberRef: string): "issue" | "pull" | null {
      if (numberRef === "44") {
        return "issue";
      }
      if (numberRef === "53") {
        return "pull";
      }
      return null;
    },
  };
}

const currentPr: PullRequestDetails = {
  number: "#99",
  title: "current",
  state: "open",
  author: "alice",
  baseRef: "main",
  headRef: "feature/test",
  createdAt: "2025-01-01",
  updatedAt: "2025-01-02",
  mergedAt: null,
  labels: [],
  assignees: [],
  body: "closes #44",
  closingIssues: ["#50"],
  filesChanged: [],
};

describe("buildPrContext", () => {
  it("classifies PRs and issues and embeds verified closing refs", () => {
    const context = buildPrContext({
      git: fakeGit(),
      gh: fakeGh(),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr,
    });
    expect(context.text).toContain("PRs in range");
    expect(context.text).toContain("#53");
    expect(context.text).toContain("Referenced issues");
    expect(context.text).toContain("#44");
    expect(context.text).toContain("Author-asserted autoclose issues");
    expect(context.verifiedClosing).toEqual(["#50"]);
    expect(context.invalidReferences).toEqual([]);
  });

  it("excludes merge PR numbers from referenced issues", () => {
    const context = buildPrContext({
      git: fakeGit(),
      gh: fakeGh(),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
    });
    expect(context.referencedIssues).toContain("#44");
    expect(context.referencedIssues).not.toContain("#53");
    expect(context.referencedPrs).toContain("#53");
  });

  it("probes origin/<base> and resolves it when present", () => {
    // Arrange: a local base "main" whose origin/main remote probe succeeds.
    const git = fakeGit({
      runByArgs: (args) =>
        args.includes("origin/main") ? ok("remotehash") : notFound(),
    });
    const context = buildPrContext({
      git,
      gh: fakeGh(),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
    });
    expect(context.resolvedBase).toBe("origin/main");
    expect(context.text).not.toContain("Base warning");
  });

  it("emits a stale-base warning when the remote probe fails", () => {
    const git = fakeGit({ runByArgs: () => notFound() });
    const context = buildPrContext({
      git,
      gh: fakeGh(),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
    });
    expect(context.resolvedBase).toBe("main");
    expect(context.text).toContain(
      "Base warning: WARNING: Requested base is local and may be stale; prefer origin/main",
    );
  });

  it("falls back to classifying references as issues when gh is unavailable", () => {
    const context = buildPrContext({
      git: fakeGit(),
      gh: fakeGh(false),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
      ghAvailable: false,
    });
    // With gh unavailable, #44 is treated as an issue (no classification), while
    // #53 is a merge PR that is excluded from issue candidates and stays a
    // referenced PR. No reference is marked invalid when gh is unavailable.
    expect(context.referencedIssues).toContain("#44");
    expect(context.referencedPrs).toContain("#53");
    expect(context.invalidReferences).toEqual([]);
  });

  it("emits the failure block and resets fields when git raises", () => {
    const git = fakeGit({ throwOnRevParse: true });
    const context = buildPrContext({
      git,
      gh: fakeGh(),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr,
    });
    expect(context.text).toContain("FAILED to compute PR context:");
    expect(context.resolvedBase).toBeNull();
    expect(context.baseSha).toBeNull();
    expect(context.mergeBase).toBeNull();
    expect(context.referencedIssues).toEqual([]);
    expect(context.verifiedClosing).toEqual([]);
  });

  it("defaults gh-available from the gh.available property and uses untracked text", () => {
    // Arrange: include untracked output and rely on gh.available defaulting
    // (no explicit ghAvailable flag).
    const git = fakeGit({ upstream: "" });
    const withUntracked = {
      ...git,
      untracked: (): string => "docs/x/file.md",
    } as unknown as GitClient;
    const context = buildPrContext({
      git: withUntracked,
      gh: fakeGh(true),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
    });
    // Empty upstream falls back to "(none)"; untracked text is surfaced.
    expect(context.text).toContain("===== Upstream =====");
    expect(context.text).toContain("docs/x/file.md");
    expect(context.ghAvailable).toBe(true);
  });

  it("resolves the base via selectDefaultBase when no base ref is supplied", () => {
    // Arrange: no baseRef; the first verify probe (origin/main) succeeds.
    const git = fakeGit({
      runByArgs: (args) =>
        args.includes("origin/main") ? ok("abc") : notFound(),
    });
    const context = buildPrContext({
      git,
      gh: fakeGh(true),
      baseRef: null,
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
    });
    expect(context.resolvedBase).toBe("origin/main");
  });

  it("throws-and-recovers into the failure block when no base ref resolves", () => {
    // No baseRef and every default candidate probe fails -> resolve raises ->
    // failure block. This also covers the non-Error throw path indirectly.
    const git = fakeGit({ runByArgs: () => notFound() });
    const context = buildPrContext({
      git,
      gh: fakeGh(true),
      baseRef: null,
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
    });
    expect(context.text).toContain(
      "FAILED to compute PR context: Failed to resolve base ref (tried common defaults)",
    );
    expect(context.resolvedBase).toBeNull();
  });

  it("renders (none) placeholders when the range has no commits or refs", () => {
    // Empty log/diff output exercises the display fallbacks and empty splitLines.
    const git = fakeGit({
      log: () => "",
      diffRange: () => "",
    });
    const context = buildPrContext({
      git,
      gh: fakeGh(true),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
    });
    expect(context.text).toContain("===== Commits in range =====");
    expect(context.text).toContain("(none)");
    expect(context.referencedPrs).toEqual([]);
    expect(context.referencedIssues).toEqual([]);
  });

  it("marks an unclassified reference invalid when gh is available", () => {
    // classifyEntity returns null for an unknown number, so it is invalid.
    const git = fakeGit({
      log: (fmt) =>
        fmt === "--pretty=%s"
          ? "chore: touches #777"
          : fmt.startsWith("--pretty=format:")
            ? "h1 2025-01-01 alice chore: touches #777"
            : fmt === "--format=%an <%ae>"
              ? "alice <a@x>"
              : "",
    });
    const context = buildPrContext({
      git,
      gh: fakeGh(true),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: false,
      currentPr: null,
    });
    expect(context.invalidReferences).toContain("#777");
  });

  it("orders the combined-text sections with the PR block last", () => {
    const context = buildPrContext({
      git: fakeGit(),
      gh: fakeGh(),
      baseRef: "main",
      headRef: "feature/test",
      includeUntracked: true,
      currentPr: null,
    });
    const text = context.text;
    const intentIndex = text.indexOf(
      "PR Intent (edit before generating PR body)",
    );
    const remotesIndex = text.indexOf("===== Repository remotes =====");
    const stagedIndex = text.indexOf("===== Working tree diff (staged) =====");
    const prComparisonIndex = text.indexOf("===== PR Comparison =====");
    expect(intentIndex).toBeGreaterThanOrEqual(0);
    expect(remotesIndex).toBeGreaterThan(intentIndex);
    expect(stagedIndex).toBeGreaterThan(remotesIndex);
    expect(prComparisonIndex).toBeGreaterThan(stagedIndex);
  });
});

describe("resolveFeatureDir", () => {
  const base = "/repo/active";

  it("returns the direct child when it exists", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/my-feature`);
    expect(resolveFeatureDir(fs, base, "my-feature")).toBe(
      `${base}/my-feature`,
    );
  });

  it("delegates to the strong-pattern resolver", () => {
    const fs = new TreeFileSystem();
    fs.addDir(`${base}/prefix-my-feature-suffix`);
    expect(resolveFeatureDir(fs, base, "my-feature")).toBe(
      `${base}/prefix-my-feature-suffix`,
    );
  });

  it("returns null when the base directory is missing", () => {
    const fs = new TreeFileSystem();
    expect(resolveFeatureDir(fs, "/repo/missing", "feature")).toBeNull();
  });
});
