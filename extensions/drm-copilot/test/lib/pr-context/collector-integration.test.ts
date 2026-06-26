import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { collectAndWrite } from "../../../src/lib/pr-context/collector-output";

/**
 * End-to-end integration test for `collectAndWrite` against an in-memory repo
 * fixture and a scripted git/gh runner. Asserts both artifact files are written
 * through the injected filesystem and that the two `Wrote context ...` log lines
 * are emitted. No real process or disk is used.
 */

const ROOT = "/repo";
const GH_PATH = "/usr/bin/gh";
const SUMMARY_OUT = "/repo/artifacts/pr_context.summary.txt";
const APPENDIX_OUT = "/repo/artifacts/pr_context.appendix.txt";
const CHANGED = "docs/features/active/2025-12-18-docs-v3-upgrade/spec.md";
const FIXED_CLOCK = (): Date => new Date(Date.UTC(2026, 5, 26, 10, 2, 3));

const ok = (stdout: string): CommandResult => ({ stdout, stderr: "", code: 0 });
const fail = (stderr: string): CommandResult => ({
  stdout: "",
  stderr,
  code: 1,
});

/** Scripted runner honoring the SubprocessRunner throw-on-nonzero contract. */
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

function isGh(args: readonly string[]): boolean {
  return args[0] === GH_PATH || args[0] === "gh";
}

/** Answer gh argv: authenticated, no current PR, numeric issue classification. */
function ghHandler(args: readonly string[]): CommandResult {
  const sub = args.slice(1).join(" ");
  if (sub.startsWith("auth status")) {
    return ok("Logged in");
  }
  if (sub.startsWith("repo view --json nameWithOwner")) {
    return ok('{"nameWithOwner": "owner/repo"}');
  }
  if (args.includes("pr") && args.includes("view") && !args.includes("api")) {
    return fail("no pull request");
  }
  if (sub.startsWith("api")) {
    const apiPath = args[args.indexOf("api") + 1] ?? "";
    if (/issues\/\d+$/u.test(apiPath)) {
      const number = apiPath.split("/").pop() ?? "0";
      return ok(JSON.stringify({ number: Number(number) }));
    }
    return ok("{}");
  }
  if (sub.startsWith("run list")) {
    return ok(JSON.stringify([{ status: "success" }]));
  }
  return ok("{}");
}

/** Answer git argv for the comparison range and working tree. */
function gitHandler(args: readonly string[]): CommandResult {
  const sub = args.slice(1).join(" ");
  if (sub.startsWith("rev-parse --abbrev-ref HEAD")) {
    return ok("feature/docs");
  }
  if (sub.includes("@{u}")) {
    return ok("origin/feature/docs");
  }
  if (sub.startsWith("remote -v")) {
    return ok("origin https://example/repo (fetch)");
  }
  if (sub.startsWith("status -sb")) {
    return ok("## feature/docs");
  }
  if (sub.startsWith("ls-files")) {
    return ok("");
  }
  if (sub.startsWith("rev-parse --verify")) {
    return ok("resolved-sha");
  }
  if (sub.startsWith("merge-base")) {
    return ok("base-sha");
  }
  if (sub.startsWith("log")) {
    return ok("");
  }
  if (sub.startsWith("diff --name-status")) {
    return ok(`M\t${CHANGED}`);
  }
  if (sub.startsWith("diff --numstat")) {
    return ok(`1\t0\t${CHANGED}`);
  }
  if (sub.startsWith("diff")) {
    return ok("");
  }
  return ok("");
}

/** Seed an in-memory repo with one active feature and a `.git` marker. */
function seedRepo(): TreeFileSystem {
  const fs = new TreeFileSystem();
  const dir = `${ROOT}/docs/features/active/2025-12-18-docs-v3-upgrade`;
  fs.addDir(dir);
  fs.addDir(`${ROOT}/docs/features/potential/promoted`);
  fs.addFile(`${dir}/spec.md`, "- Issue: #42\n## Context\nContext\n");
  fs.addFile(`${dir}/plan.md`, "## Tasks\n- [x] done\n");
  fs.addFile(`${dir}/user-story.md`, "## Story Statement\n- Story\n");
  fs.addFile(`${ROOT}/.git`, "");
  return fs;
}

describe("collectAndWrite (integration)", () => {
  it("writes the summary and appendix and emits the two log lines", () => {
    // Arrange
    const fs = seedRepo();
    const runner = new ScriptRunner((args) =>
      isGh(args) ? ghHandler(args) : gitHandler(args),
    );
    const logs: string[] = [];

    // Act
    collectAndWrite({
      base: "main",
      head: "feature/docs",
      repoRoot: ROOT,
      includeUntracked: false,
      fs,
      runner,
      clock: FIXED_CLOCK,
      whichGh: () => GH_PATH,
      out: SUMMARY_OUT,
      appendixOut: APPENDIX_OUT,
      append: false,
      log: (message) => logs.push(message),
    });

    // Assert: both files written through the FS.
    expect(fs.isFile(SUMMARY_OUT)).toBe(true);
    expect(fs.isFile(APPENDIX_OUT)).toBe(true);
    const summary = fs.readTextFile(SUMMARY_OUT);
    const appendix = fs.readTextFile(APPENDIX_OUT);
    expect(summary).toContain("===== GitHub CLI status =====");
    expect(summary).toContain("===== Appendix pointer =====");
    expect(summary).toContain(`See ${APPENDIX_OUT}`);
    expect(appendix).toContain("===== Context generated =====");
    expect(appendix).toContain("2026-06-26 10:02:03 UTC");
    // Both log lines are emitted.
    expect(logs).toEqual([
      `Wrote context summary to: ${SUMMARY_OUT}`,
      `Wrote context appendix to: ${APPENDIX_OUT}`,
    ]);
  });
});
