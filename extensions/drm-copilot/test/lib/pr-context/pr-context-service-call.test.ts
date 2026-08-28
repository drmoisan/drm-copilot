import { describe, expect, it } from "@jest/globals";

import { TreeFileSystem } from "./tree-file-system";
import {
  type CommandResult,
  type CommandRunner,
  type CommandRunOptions,
} from "../../../src/lib/subprocess-runner";
import { collectPrContextServiceCall } from "../../../src/lib/pr-context/pr-context-service-call";

/**
 * Tests for the in-process `collectPrContextServiceCall` helper (F9). A fake
 * `CommandRunner` and tree-backed in-memory `FileSystem` are injected so the
 * preserved return contract and the two written artifact files are asserted
 * without a real process, disk, or temp file.
 */

const ROOT = "/workspace";
const GH_PATH = "/usr/bin/gh";

/** The two workspace-joined artifact paths, in sorted order. */
const SORTED_WORKSPACE_JOINED_PAIR = [
  `${ROOT}/artifacts/pr_context.appendix.txt`,
  `${ROOT}/artifacts/pr_context.summary.txt`,
];

const ok = (stdout: string): CommandResult => ({ stdout, stderr: "", code: 0 });
const fail = (stderr: string): CommandResult => ({
  stdout: "",
  stderr,
  code: 1,
});

/** Scripted runner honoring the throw-on-nonzero SubprocessRunner contract. */
class ScriptRunner implements CommandRunner {
  run(args: readonly string[], options?: CommandRunOptions): CommandResult {
    const result = this.dispatch(args);
    if (!(options?.allowError ?? false) && result.code !== 0) {
      const joined = (result.stdout + "\n" + result.stderr).trim();
      throw new Error(`${args.join(" ")} failed (${result.code}): ${joined}`);
    }
    return result;
  }

  private dispatch(args: readonly string[]): CommandResult {
    const isGh = args[0] === GH_PATH || args[0] === "gh";
    if (isGh) {
      // gh is unavailable in this hermetic test (auth fails); the collector
      // gracefully degrades and still writes both artifacts.
      return fail("offline");
    }
    const sub = args.slice(1).join(" ");
    if (sub.startsWith("rev-parse --abbrev-ref HEAD")) {
      return ok("feature/test");
    }
    if (sub.includes("@{u}")) {
      return ok("");
    }
    if (sub.startsWith("rev-parse --verify")) {
      return ok("resolved-sha");
    }
    if (sub.startsWith("merge-base")) {
      return ok("base-sha");
    }
    return ok("");
  }
}

/** Seed a minimal repo with a `.git` marker so resolveRoot returns ROOT. */
function seedWorkspace(): TreeFileSystem {
  const fs = new TreeFileSystem();
  fs.addFile(`${ROOT}/.git`, "");
  fs.addDir(`${ROOT}/docs/features/active`);
  fs.addDir(`${ROOT}/docs/features/potential/promoted`);
  return fs;
}

describe("collectPrContextServiceCall", () => {
  it("returns the preserved contract and the two normalized artifact paths", () => {
    // Arrange
    const fs = seedWorkspace();
    const runner = new ScriptRunner();

    // Act
    const result = collectPrContextServiceCall({
      runner,
      fileSystem: fs,
      workspaceRoot: ROOT,
      base: "main",
    });

    // Assert: preserved tool/workspaceRoot/summary.
    expect(result.tool).toBe("collect_pr_context");
    expect(result.workspaceRoot).toBe(ROOT);
    expect(result.summary).toBe("Collected PR context against base 'main'.");
    // Both normalized artifact paths joined to the workspace root.
    expect(result.artifacts).toEqual([
      "/workspace/artifacts/pr_context.summary.txt",
      "/workspace/artifacts/pr_context.appendix.txt",
    ]);
  });

  it("writes both artifact files through the injected filesystem", () => {
    // Arrange
    const fs = seedWorkspace();
    const runner = new ScriptRunner();

    // Act
    collectPrContextServiceCall({
      runner,
      fileSystem: fs,
      workspaceRoot: ROOT,
      base: "main",
    });

    // Assert: both files were written (relative to the workspace root).
    expect(fs.isFile("artifacts/pr_context.summary.txt")).toBe(true);
    expect(fs.isFile("artifacts/pr_context.appendix.txt")).toBe(true);
  });

  it("writes exactly the paths it reports in result.artifacts", () => {
    // Arrange
    const fs = seedWorkspace();
    const runner = new ScriptRunner();

    // Act
    const result = collectPrContextServiceCall({
      runner,
      fileSystem: fs,
      workspaceRoot: ROOT,
      base: "main",
    });

    // Assert: one equality between the written set and the reported set, so the
    // two expressions cannot drift apart again.
    const writtenSorted = [...fs.writtenPaths].sort();
    expect(writtenSorted).toEqual([...result.artifacts].sort());
    // That single value is the workspace-joined summary and appendix pair.
    expect(writtenSorted).toEqual(SORTED_WORKSPACE_JOINED_PAIR);
  });

  it("forwards log lines to the injected sink", () => {
    const fs = seedWorkspace();
    const logs: string[] = [];
    collectPrContextServiceCall({
      runner: new ScriptRunner(),
      fileSystem: fs,
      workspaceRoot: ROOT,
      base: "main",
      log: (message) => logs.push(message),
    });
    expect(logs).toEqual([
      "Wrote context summary to: artifacts/pr_context.summary.txt",
      "Wrote context appendix to: artifacts/pr_context.appendix.txt",
    ]);
  });
});
