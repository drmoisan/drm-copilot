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

/**
 * Tree filesystem whose `writeTextFile` accepts the call and discards the
 * content for the selected artifact paths.
 *
 * The write succeeds, nothing throws, and any content already at the path is
 * left untouched. This reproduces the defect's shape: a write that reports
 * success while the file at the reported path is not what this invocation
 * rendered.
 */
class DiscardingFileSystem extends TreeFileSystem {
  constructor(private readonly discard: (path: string) => boolean) {
    super();
  }

  override writeTextFile(path: string, content: string): void {
    if (this.discard(path)) {
      // Record the call so path identity stays observable, then drop the bytes.
      this.writtenPaths.push(path);
      return;
    }
    super.writeTextFile(path, content);
  }
}

/** Seed the `.git` marker and discovery directories on any tree filesystem. */
function seedInto<T extends TreeFileSystem>(fs: T): T {
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

    // Assert: both files were written at the workspace-joined absolute paths.
    // The collector resolves the path it is given against the host's cwd, so a
    // repository-relative key here would mean the write landed outside the
    // workspace the tool was asked to describe.
    expect(fs.isFile(`${ROOT}/artifacts/pr_context.summary.txt`)).toBe(true);
    expect(fs.isFile(`${ROOT}/artifacts/pr_context.appendix.txt`)).toBe(true);
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

  it("raises when the write is accepted and the content is discarded", () => {
    // Arrange: a filesystem whose write accepts the call and drops the bytes.
    const fs = seedInto(new DiscardingFileSystem(() => true));

    // Act / Assert
    expect(() =>
      collectPrContextServiceCall({
        runner: new ScriptRunner(),
        fileSystem: fs,
        workspaceRoot: ROOT,
        base: "main",
      }),
    ).toThrow(/Failed to verify PR context artifact/u);
  });

  it("raises when a stale file is present and the write is discarded", () => {
    // Arrange: both target paths already hold a prior invocation's content, and
    // the write discards. An existence-only check passes this scenario, which is
    // exactly the hazard read-back verification exists to catch.
    const fs = seedInto(new DiscardingFileSystem(() => true));
    fs.addFile(
      `${ROOT}/artifacts/pr_context.summary.txt`,
      "PRIOR INVOCATION SUMMARY",
    );
    fs.addFile(
      `${ROOT}/artifacts/pr_context.appendix.txt`,
      "PRIOR INVOCATION APPENDIX",
    );

    // Act / Assert: both files exist, yet the call raises.
    expect(fs.isFile(`${ROOT}/artifacts/pr_context.summary.txt`)).toBe(true);
    expect(fs.isFile(`${ROOT}/artifacts/pr_context.appendix.txt`)).toBe(true);
    expect(() =>
      collectPrContextServiceCall({
        runner: new ScriptRunner(),
        fileSystem: fs,
        workspaceRoot: ROOT,
        base: "main",
      }),
    ).toThrow(/Failed to verify PR context artifact/u);
  });

  it("raises naming the appendix when the summary write succeeds and the appendix write fails", () => {
    // Arrange: only the appendix write discards, so the summary verifies.
    const appendixPath = `${ROOT}/artifacts/pr_context.appendix.txt`;
    const fs = seedInto(
      new DiscardingFileSystem((path) => path === appendixPath),
    );

    // Act / Assert: the raised message names the appendix artifact path.
    expect(() =>
      collectPrContextServiceCall({
        runner: new ScriptRunner(),
        fileSystem: fs,
        workspaceRoot: ROOT,
        base: "main",
      }),
    ).toThrow(appendixPath);
  });

  it("writes both artifacts and succeeds when the GitHub CLI is unavailable", () => {
    // Arrange: the scripted runner already reports gh as failing, which is the
    // GitHub-CLI-unavailable degradation path.
    const fs = seedWorkspace();

    // Act
    const result = collectPrContextServiceCall({
      runner: new ScriptRunner(),
      fileSystem: fs,
      workspaceRoot: ROOT,
      base: "main",
    });

    // Assert: degradation is not failure. Both artifacts are written and the
    // call returns successfully.
    expect(result.tool).toBe("collect_pr_context");
    expect([...fs.writtenPaths].sort()).toEqual(SORTED_WORKSPACE_JOINED_PAIR);
    expect(
      fs.readTextFile(`${ROOT}/artifacts/pr_context.summary.txt`),
    ).toContain("GitHub CLI unavailable");
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
    // The two collector log lines carry the absolute workspace-joined paths,
    // because they log the value actually written to.
    expect(logs).toEqual([
      `Wrote context summary to: ${ROOT}/artifacts/pr_context.summary.txt`,
      `Wrote context appendix to: ${ROOT}/artifacts/pr_context.appendix.txt`,
    ]);
  });
});
