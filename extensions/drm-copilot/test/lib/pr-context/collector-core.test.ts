import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { collectPrContext } from "../../../src/lib/pr-context/collector-core";

/**
 * Tests for the collector orchestration core (`collector.py` first half). A
 * single scripted `CommandRunner` answers both git and gh argv, a tree-backed
 * in-memory `FileSystem` provides the repo fixture, and `whichGh` is injected.
 * No real process or disk is touched.
 */

/**
 * Build a scripted runner that dispatches by command + argv shape. Mirrors the
 * real `SubprocessRunner` contract: a non-zero exit throws unless `allowError`
 * is set, so the clients' fail-fast paths are exercised faithfully.
 */
class ScriptRunner implements CommandRunner {
  constructor(
    private readonly handler: (args: readonly string[]) => CommandResult,
  ) {}

  run(args: readonly string[], options?: CommandRunOptions): CommandResult {
    const result = this.handler(args);
    if (!(options?.allowError ?? false) && result.code !== 0) {
      const joined = (result.stdout + "\n" + result.stderr).trim();
      throw new Error(`${args.join(" ")} failed (${result.code}): ${joined}`);
    }
    return result;
  }
}

const ROOT = "/repo";
const GH_PATH = "/usr/bin/gh";
const CHANGED = "docs/features/active/2025-12-18-docs-v3-upgrade/spec.md";

/** True when the argv is a gh invocation (executable is the resolved gh path). */
function isGh(args: readonly string[]): boolean {
  return args[0] === GH_PATH || args[0] === "gh";
}
const okResult = (stdout: string): CommandResult => ({
  stdout,
  stderr: "",
  code: 0,
});
const failResult = (stderr: string): CommandResult => ({
  stdout: "",
  stderr,
  code: 1,
});

/** Seed a feature tree so gatherFeatureExcerpts discovers one feature. */
function seedFeatureTree(): TreeFileSystem {
  const fs = new TreeFileSystem();
  const dir = `${ROOT}/docs/features/active/2025-12-18-docs-v3-upgrade`;
  fs.addDir(dir);
  fs.addDir(`${ROOT}/docs/features/potential/promoted`);
  fs.addFile(
    `${dir}/spec.md`,
    "- Issue: #42\n## Context\nContext touching #42\n",
  );
  fs.addFile(`${dir}/plan.md`, "## Tasks\n- [x] done\n");
  fs.addFile(`${dir}/user-story.md`, "## Story Statement\n- Story\n");
  fs.addFile(`${dir}/feature-audit.2026-01-01T00-00.md`, "Readiness: PASS\n");
  fs.addFile(`${ROOT}/.git`, "");
  return fs;
}

/**
 * Build a gh handler covering availability, current PR, classification, issue/PR
 * detail, and CI status. `ghAvailable=false` makes auth fail.
 */
function ghHandler(options: {
  ghAvailable: boolean;
  currentPrStdout?: string;
}): (args: readonly string[]) => CommandResult | null {
  return (args) => {
    if (!isGh(args)) {
      return null;
    }
    const sub = args.slice(1).join(" ");
    if (sub.startsWith("auth status")) {
      return options.ghAvailable
        ? okResult("Logged in")
        : failResult("offline");
    }
    if (sub.startsWith("repo view --json nameWithOwner")) {
      return okResult('{"nameWithOwner": "owner/repo"}');
    }
    if (args.includes("pr") && args.includes("view") && !args.includes("api")) {
      // current_pr or pr view: by default no PR (non-zero), unless overridden.
      return options.currentPrStdout !== undefined
        ? okResult(options.currentPrStdout)
        : failResult("no pull request");
    }
    if (sub.startsWith("api")) {
      // classify_entity / issue/pr detail: a numeric ref classifies as issue.
      const apiPath = args[args.indexOf("api") + 1] ?? "";
      if (/issues\/\d+$/u.test(apiPath)) {
        const number = apiPath.split("/").pop() ?? "0";
        return okResult(JSON.stringify({ number: Number(number) }));
      }
      return okResult("{}");
    }
    if (sub.startsWith("run list")) {
      return okResult(JSON.stringify([{ status: "success" }]));
    }
    return okResult("{}");
  };
}

/** Build a git handler matching the integration StubGit behavior. */
function gitHandler(args: readonly string[]): CommandResult {
  const sub = args.slice(1).join(" ");
  if (sub.startsWith("rev-parse --abbrev-ref HEAD")) {
    return okResult("feature/docs");
  }
  if (sub.includes("@{u}")) {
    return okResult("origin/feature/docs");
  }
  if (sub.startsWith("remote -v")) {
    return okResult("origin https://example/repo (fetch)");
  }
  if (sub.startsWith("status -sb")) {
    return okResult("## feature/docs");
  }
  if (sub.startsWith("ls-files")) {
    return okResult("");
  }
  if (sub.startsWith("rev-parse --verify")) {
    // base/head/remote-probe verification all resolve.
    return okResult("resolved-sha");
  }
  if (sub.startsWith("merge-base")) {
    return okResult("base-sha");
  }
  if (sub.startsWith("log")) {
    return okResult("");
  }
  if (sub.startsWith("diff --name-status")) {
    return okResult(`M\t${CHANGED}`);
  }
  if (sub.startsWith("diff --numstat")) {
    return okResult(`1\t0\t${CHANGED}`);
  }
  if (sub.startsWith("diff")) {
    return okResult("");
  }
  return okResult("");
}

/** Compose git + gh handlers into one runner. */
function buildRunner(ghOptions: {
  ghAvailable: boolean;
  currentPrStdout?: string;
}): ScriptRunner {
  const gh = ghHandler(ghOptions);
  return new ScriptRunner((args) => {
    if (isGh(args)) {
      return gh(args) ?? okResult("{}");
    }
    return gitHandler(args);
  });
}

describe("collectPrContext (gh available)", () => {
  it("gathers feature docs, classifies refs, and partitions buckets", () => {
    // Arrange
    const fs = seedFeatureTree();
    const runner = buildRunner({ ghAvailable: true });

    // Act
    const result = collectPrContext({
      base: "main",
      head: "feature/docs",
      repoRoot: ROOT,
      includeUntracked: false,
      fs,
      runner,
      whichGh: () => "/usr/bin/gh",
    });

    // Assert
    expect(result.ghAvailable).toBe(true);
    expect(result.resolvedRoot).toBe(ROOT);
    expect(result.featureDocs).toHaveLength(1);
    // The feature ref #42 is classified as an issue.
    expect(result.referencedIssues).toContain("#42");
    // Readiness PASS + primary #42 yields a deterministic autoclose entry.
    expect(result.issuesToAutocloseSection).toContain("#42");
    // CI target resolves and status is reported.
    expect(result.ciStatus).toBe("success");
    // The changed spec.md is a docs-bucket entry.
    expect(result.bucketDocs.map(([path]) => path)).toContain(CHANGED);
  });

  it("fetches issue and PR details for classified references", () => {
    const fs = seedFeatureTree();
    const runner = buildRunner({ ghAvailable: true });
    const result = collectPrContext({
      base: "main",
      head: "feature/docs",
      repoRoot: ROOT,
      includeUntracked: false,
      fs,
      runner,
      whichGh: () => "/usr/bin/gh",
    });
    // #42 was classified as an issue, so issue details are fetched.
    expect(result.issueDetails.some((d) => d.number === "#42")).toBe(true);
  });
});

describe("collectPrContext (gh unavailable)", () => {
  it("records the override message and classifies refs as issues", () => {
    const fs = seedFeatureTree();
    const runner = buildRunner({ ghAvailable: false });
    const result = collectPrContext({
      base: "main",
      head: "feature/docs",
      repoRoot: ROOT,
      includeUntracked: false,
      fs,
      runner,
      whichGh: () => "/usr/bin/gh",
    });
    expect(result.ghAvailable).toBe(false);
    expect(result.ghStatusOverride).toContain("GitHub CLI unavailable:");
    // With gh unavailable, the feature ref #42 is still surfaced as an issue.
    expect(result.referencedIssues).toContain("#42");
    expect(result.issueDetails).toHaveLength(0);
    // CI is not queried when gh is unavailable.
    expect(result.ciStatus).toBeNull();
  });
});

describe("collectPrContext classification and buckets", () => {
  /** gh handler classifying #5 as pull, #7 as invalid, numeric issues otherwise. */
  function richGh(): (args: readonly string[]) => CommandResult | null {
    return (args) => {
      if (!isGh(args)) {
        return null;
      }
      const sub = args.slice(1).join(" ");
      if (sub.startsWith("auth status")) {
        return okResult("Logged in");
      }
      if (sub.startsWith("repo view --json nameWithOwner")) {
        return okResult('{"nameWithOwner": "owner/repo"}');
      }
      if (
        args.includes("pr") &&
        args.includes("view") &&
        !args.includes("api")
      ) {
        if (args.includes("5")) {
          // pr_details(#5)
          return okResult(JSON.stringify({ number: 5, title: "PR 5" }));
        }
        // current_pr: a PR exists with a verified closing issue.
        return okResult(
          JSON.stringify({
            number: 99,
            closingIssuesReferences: [{ number: 50 }],
          }),
        );
      }
      if (sub.startsWith("api")) {
        const apiPath = args[args.indexOf("api") + 1] ?? "";
        if (apiPath.endsWith("/5")) {
          return okResult(JSON.stringify({ number: 5, pull_request: {} }));
        }
        if (apiPath.endsWith("/7")) {
          return failResult("404 Not Found");
        }
        if (/issues\/\d+$/u.test(apiPath)) {
          const number = apiPath.split("/").pop() ?? "0";
          return okResult(JSON.stringify({ number: Number(number) }));
        }
        return okResult("{}");
      }
      if (sub.startsWith("run list")) {
        return okResult(JSON.stringify([{ status: "success" }]));
      }
      return okResult("{}");
    };
  }

  it("classifies pull/invalid refs and partitions core/rename buckets", () => {
    // Arrange: branch name carries #5 (pull) and #7 (invalid); the diff has a
    // renamed file and a .py core file plus the docs spec.
    const fs = seedFeatureTree();
    const gh = richGh();
    const runner = new ScriptRunner((args) => {
      if (isGh(args)) {
        return gh(args) ?? okResult("{}");
      }
      const sub = args.slice(1).join(" ");
      if (sub.startsWith("rev-parse --abbrev-ref HEAD")) {
        return okResult("feature/#5-#7");
      }
      if (sub.startsWith("diff --name-status")) {
        return okResult(`M\t${CHANGED}\nR100\told.py\tnew.py\nM\tsrc/app.py`);
      }
      if (sub.startsWith("diff --numstat")) {
        return okResult(`1\t0\t${CHANGED}\n2\t1\tnew.py\n3\t1\tsrc/app.py`);
      }
      return gitHandler(args);
    });

    // Act
    const result = collectPrContext({
      base: "main",
      head: "feature/docs",
      repoRoot: ROOT,
      includeUntracked: false,
      fs,
      runner,
      whichGh: () => GH_PATH,
    });

    // Assert
    expect(result.referencedPrs).toContain("#5");
    expect(result.invalidRefs).toContain("#7");
    // current_pr has a verified closing issue, surfaced in verified.
    expect(result.verified).toContain("#50");
    expect(result.verifiedReason).toBe("(verified from GitHub PR metadata)");
    // Rename -> renames bucket; .py -> core bucket; spec.md -> docs bucket.
    expect(result.bucketRenames.map(([p]) => p)).toContain("new.py");
    expect(result.bucketCore.map(([p]) => p)).toContain("src/app.py");
    expect(result.bucketDocs.map(([p]) => p)).toContain(CHANGED);
  });
});

describe("collectPrContext diff selection", () => {
  it("uses the working-tree diff when no merge base is available", () => {
    // Arrange: rev-parse fails so buildPrContext hits its failure path and
    // mergeBase/headSha are null, forcing the working-tree diff selection.
    const fs = seedFeatureTree();
    const gh = ghHandler({ ghAvailable: true });
    const runner = new ScriptRunner((args) => {
      if (isGh(args)) {
        return gh(args) ?? okResult("{}");
      }
      if (args.slice(1).join(" ").startsWith("rev-parse --verify")) {
        return failResult("bad ref");
      }
      return gitHandler(args);
    });

    // Act
    const result = collectPrContext({
      base: "main",
      head: "feature/docs",
      repoRoot: ROOT,
      includeUntracked: false,
      fs,
      runner,
      whichGh: () => "/usr/bin/gh",
    });

    // Assert: the context failed to compute a merge base, so the working-tree
    // diff is used and the changed file still lands in the docs bucket.
    expect(result.contextResult.mergeBase).toBeNull();
    expect(result.bucketDocs.map(([path]) => path)).toContain(CHANGED);
  });
});
