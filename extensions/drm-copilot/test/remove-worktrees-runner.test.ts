import { afterEach, describe, expect, it, jest } from "@jest/globals";
import { EventEmitter } from "node:events";

import {
  createGitRunner,
  removeAllSecondaryWorktrees,
  type GitRunResult,
  type GitRunner,
  type ParentDirectoryFileSystem,
} from "../src/remove-worktrees-runner";
import {
  createMockProcess,
  createMockProcessWithStderr,
  type MockChildProcess,
} from "./runtime-test-helpers";

// ---------------------------------------------------------------------------
// Fake GitRunner used for orchestration tests ([P4-T5]–[P4-T8]).
// ---------------------------------------------------------------------------

/**
 * A fake GitRunner that records each argv it receives and returns canned
 * responses in sequence. No child_process, no EventEmitter, no temp files.
 */
class FakeGitRunner implements GitRunner {
  readonly calls: Array<{ args: ReadonlyArray<string>; cwd: string }> = [];
  private readonly responses: GitRunResult[];
  private index = 0;

  constructor(responses: GitRunResult[]) {
    this.responses = responses;
  }

  run(args: ReadonlyArray<string>, cwd: string): Promise<GitRunResult> {
    this.calls.push({ args, cwd });
    const response = this.responses[this.index];
    this.index += 1;
    if (response === undefined) {
      throw new Error(
        `FakeGitRunner received an unexpected call: ${args.join(" ")}`,
      );
    }
    return Promise.resolve(response);
  }
}

/**
 * Creates an in-memory output sink so orchestration tests avoid importing
 * `command-runtime` (which imports the unmockable `vscode` module here).
 */
function createBufferedOutput(): {
  output: { appendLine(line: string): void };
  lines: string[];
} {
  const lines: string[] = [];
  return {
    output: {
      appendLine(line: string): void {
        lines.push(line);
      },
    },
    lines,
  };
}

function ok(stdout: string): GitRunResult {
  return { exitCode: 0, stdout, stderr: "" };
}

function fail(stderr: string): GitRunResult {
  return { exitCode: 1, stdout: "", stderr };
}

/**
 * In-memory ParentDirectoryFileSystem seam. Records every listing and removal
 * so tests can assert cleanup behavior without touching the real filesystem.
 * A directory "exists" only when it is present in the supplied map.
 */
class FakeParentDirectoryFileSystem implements ParentDirectoryFileSystem {
  readonly listedPaths: string[] = [];
  readonly removedPaths: string[] = [];
  private readonly dirs: Map<string, string[]>;

  constructor(dirs: Record<string, string[]> = {}) {
    this.dirs = new Map(Object.entries(dirs));
  }

  directoryExists(path: string): boolean {
    return this.dirs.has(path);
  }

  listDirectoryEntries(path: string): ReadonlyArray<string> {
    this.listedPaths.push(path);
    return this.dirs.get(path) ?? [];
  }

  removeEmptyDirectory(path: string): void {
    this.removedPaths.push(path);
    this.dirs.delete(path);
  }
}

/**
 * A filesystem seam for tests that do not exercise grouping-directory cleanup:
 * every directory reports as non-existent, so no cleanup is attempted.
 */
function noopFileSystem(): FakeParentDirectoryFileSystem {
  return new FakeParentDirectoryFileSystem();
}

const NESTED_TWO_SECONDARIES = [
  "worktree /repo/main\nHEAD aaa\nbranch refs/heads/main",
  "worktree /parent/auth-wt/2026-04-20T09-59\nHEAD bbb\nbranch refs/heads/auth-wt-2026-04-20T09-59",
  "worktree /parent/auth-wt/2026-04-20T10-05\nHEAD ccc\nbranch refs/heads/auth-wt-2026-04-20T10-05",
].join("\n\n");

const TWO_CLEAN_SECONDARIES = [
  "worktree /repo/main\nHEAD aaa\nbranch refs/heads/main",
  "worktree /repo/wt-1\nHEAD bbb\nbranch refs/heads/feature-1",
  "worktree /repo/wt-2\nHEAD ccc\nbranch refs/heads/feature-2",
].join("\n\n");

// ---------------------------------------------------------------------------
// [P4-T5] positive-flow orchestration
// ---------------------------------------------------------------------------

describe("removeAllSecondaryWorktrees — positive flow", () => {
  it("removes all clean secondary worktrees with NON-force argv", async () => {
    // Arrange
    const git = new FakeGitRunner([ok(TWO_CLEAN_SECONDARIES), ok(""), ok("")]);
    const { output } = createBufferedOutput();

    // Act
    const summary = await removeAllSecondaryWorktrees(
      "/repo",
      git,
      output,
      noopFileSystem(),
    );

    // Assert
    expect(summary.removed).toEqual(["/repo/wt-1", "/repo/wt-2"]);
    expect(summary.skipped).toEqual([]);
    const removeCalls = git.calls.filter(
      (call) => call.args[0] === "worktree" && call.args[1] === "remove",
    );
    expect(removeCalls).toHaveLength(2);
    for (const call of removeCalls) {
      expect(call.args).not.toContain("--force");
      expect(call.args.slice(0, 2)).toEqual(["worktree", "remove"]);
    }
  });
});

// ---------------------------------------------------------------------------
// [P4-T6] skip-on-failure continuation
// ---------------------------------------------------------------------------

describe("removeAllSecondaryWorktrees — skip on failure", () => {
  it("continues the batch when one removal fails", async () => {
    // Arrange
    const git = new FakeGitRunner([
      ok(TWO_CLEAN_SECONDARIES),
      fail("fatal: '/repo/wt-1' contains modified or untracked files"),
      ok(""),
    ]);
    const { output } = createBufferedOutput();

    // Act
    const summary = await removeAllSecondaryWorktrees(
      "/repo",
      git,
      output,
      noopFileSystem(),
    );

    // Assert
    expect(summary.removed).toEqual(["/repo/wt-2"]);
    expect(summary.skipped).toHaveLength(1);
    expect(summary.skipped[0].path).toBe("/repo/wt-1");
    expect(summary.skipped[0].reason).toContain("modified or untracked files");
  });
});

// ---------------------------------------------------------------------------
// [P4-T7] locked / prunable skip
// ---------------------------------------------------------------------------

describe("removeAllSecondaryWorktrees — locked and prunable skip", () => {
  it("skips locked and prunable worktrees without issuing a remove call", async () => {
    // Arrange
    const list = [
      "worktree /repo/main\nHEAD aaa\nbranch refs/heads/main",
      "worktree /repo/wt-locked\nHEAD bbb\nlocked maintenance",
      "worktree /repo/wt-prunable\nHEAD ccc\nprunable gitdir missing",
    ].join("\n\n");
    const git = new FakeGitRunner([ok(list)]);
    const { output } = createBufferedOutput();

    // Act
    const summary = await removeAllSecondaryWorktrees(
      "/repo",
      git,
      output,
      noopFileSystem(),
    );

    // Assert
    expect(summary.removed).toEqual([]);
    expect(summary.skipped.map((item) => item.path)).toEqual([
      "/repo/wt-locked",
      "/repo/wt-prunable",
    ]);
    const removeCalls = git.calls.filter((call) => call.args[1] === "remove");
    expect(removeCalls).toHaveLength(0);
    expect(git.calls).toHaveLength(1);
    expect(git.calls[0].args).toEqual(["worktree", "list", "--porcelain"]);
  });
});

// ---------------------------------------------------------------------------
// [P4-T8] no-secondary, primary-never-removed, list-failure
// ---------------------------------------------------------------------------

describe("removeAllSecondaryWorktrees — edge cases", () => {
  it("issues no remove call when only the primary is present", async () => {
    // Arrange
    const git = new FakeGitRunner([
      ok("worktree /repo/main\nHEAD aaa\nbranch refs/heads/main\n"),
    ]);
    const { output } = createBufferedOutput();

    // Act
    const summary = await removeAllSecondaryWorktrees(
      "/repo",
      git,
      output,
      noopFileSystem(),
    );

    // Assert
    expect(summary.removed).toEqual([]);
    expect(summary.skipped).toEqual([]);
    const removeCalls = git.calls.filter((call) => call.args[1] === "remove");
    expect(removeCalls).toHaveLength(0);
  });

  it("never passes the primary worktree path to a remove call", async () => {
    // Arrange
    const git = new FakeGitRunner([ok(TWO_CLEAN_SECONDARIES), ok(""), ok("")]);
    const { output } = createBufferedOutput();

    // Act
    await removeAllSecondaryWorktrees("/repo", git, output, noopFileSystem());

    // Assert
    const removeTargets = git.calls
      .filter((call) => call.args[1] === "remove")
      .map((call) => call.args[2]);
    expect(removeTargets).not.toContain("/repo/main");
  });

  it("throws when 'git worktree list' exits non-zero", async () => {
    // Arrange
    const git = new FakeGitRunner([fail("fatal: not a git repository")]);
    const { output } = createBufferedOutput();

    // Act / Assert
    await expect(
      removeAllSecondaryWorktrees("/repo", git, output, noopFileSystem()),
    ).rejects.toThrow(/not a git repository/);
  });
});

// ---------------------------------------------------------------------------
// [P4-T7] nested-scheme discovery + empty grouping-directory cleanup
// ---------------------------------------------------------------------------

describe("removeAllSecondaryWorktrees — nested scheme and empty-parent cleanup", () => {
  it("discovers and removes nested-scheme secondary worktrees unchanged (AC5)", async () => {
    // Arrange: nested porcelain paths <parent>/<repo>-wt/<timestamp>.
    const git = new FakeGitRunner([ok(NESTED_TWO_SECONDARIES), ok(""), ok("")]);
    const { output } = createBufferedOutput();
    // The grouping directory still has one worktree left on disk, so it is not
    // eligible for cleanup here; discovery/removal must work regardless.
    const fileSystem = new FakeParentDirectoryFileSystem({
      "/parent/auth-wt": ["2026-04-20T10-05"],
    });

    // Act
    const summary = await removeAllSecondaryWorktrees(
      "/repo",
      git,
      output,
      fileSystem,
    );

    // Assert
    expect(summary.removed).toEqual([
      "/parent/auth-wt/2026-04-20T09-59",
      "/parent/auth-wt/2026-04-20T10-05",
    ]);
    const removeTargets = git.calls
      .filter((call) => call.args[1] === "remove")
      .map((call) => call.args[2]);
    expect(removeTargets).toEqual([
      "/parent/auth-wt/2026-04-20T09-59",
      "/parent/auth-wt/2026-04-20T10-05",
    ]);
  });

  it("removes an emptied -wt grouping directory via the seam and reports it", async () => {
    // Arrange
    const git = new FakeGitRunner([ok(NESTED_TWO_SECONDARIES), ok(""), ok("")]);
    const { output } = createBufferedOutput();
    // The grouping directory is empty after both worktrees are removed.
    const fileSystem = new FakeParentDirectoryFileSystem({
      "/parent/auth-wt": [],
    });

    // Act
    const summary = await removeAllSecondaryWorktrees(
      "/repo",
      git,
      output,
      fileSystem,
    );

    // Assert
    expect(summary.removed).toHaveLength(2);
    expect(summary.removedEmptyParents).toEqual(["/parent/auth-wt"]);
    expect(fileSystem.removedPaths).toEqual(["/parent/auth-wt"]);
    // The listing is taken exactly once, immediately before removal.
    expect(fileSystem.listedPaths).toEqual(["/parent/auth-wt"]);
  });

  it("preserves a non-empty grouping directory", async () => {
    // Arrange
    const git = new FakeGitRunner([ok(NESTED_TWO_SECONDARIES), ok(""), ok("")]);
    const { output } = createBufferedOutput();
    const fileSystem = new FakeParentDirectoryFileSystem({
      "/parent/auth-wt": ["stray-file.txt"],
    });

    // Act
    const summary = await removeAllSecondaryWorktrees(
      "/repo",
      git,
      output,
      fileSystem,
    );

    // Assert
    expect(summary.removedEmptyParents).toEqual([]);
    expect(fileSystem.removedPaths).toEqual([]);
  });

  it("never invokes the seam when no worktree was removed", async () => {
    // Arrange: only the primary is present, so nothing is removed.
    const git = new FakeGitRunner([
      ok("worktree /repo/main\nHEAD aaa\nbranch refs/heads/main\n"),
    ]);
    const { output } = createBufferedOutput();
    const fileSystem = new FakeParentDirectoryFileSystem({
      "/parent/auth-wt": [],
    });

    // Act
    const summary = await removeAllSecondaryWorktrees(
      "/repo",
      git,
      output,
      fileSystem,
    );

    // Assert
    expect(summary.removed).toEqual([]);
    expect(summary.removedEmptyParents).toEqual([]);
    expect(fileSystem.listedPaths).toEqual([]);
    expect(fileSystem.removedPaths).toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// [P4-T9] createGitRunner resolve-on-nonzero / reject-on-spawn-error
// ---------------------------------------------------------------------------

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

describe("createGitRunner", () => {
  afterEach(() => {
    childProcessMock.spawn.mockReset();
  });

  it("resolves with the exit code and stderr on a non-zero close", async () => {
    // Arrange
    const proc: MockChildProcess = createMockProcessWithStderr(
      1,
      "fatal: cannot remove",
    );
    childProcessMock.spawn.mockReturnValue(proc);

    // Act
    const result = await createGitRunner().run(
      ["worktree", "remove", "/repo/wt-1"],
      "/repo",
    );

    // Assert
    expect(result.exitCode).toBe(1);
    expect(result.stderr).toContain("fatal: cannot remove");
  });

  it("resolves with stdout on a zero close", async () => {
    // Arrange
    const proc: MockChildProcess = createMockProcess(0, "worktree /repo/main");
    childProcessMock.spawn.mockReturnValue(proc);

    // Act
    const result = await createGitRunner().run(
      ["worktree", "list", "--porcelain"],
      "/repo",
    );

    // Assert
    expect(result.exitCode).toBe(0);
    expect(result.stdout).toContain("worktree /repo/main");
  });

  it("rejects only on the spawn error event", async () => {
    // Arrange
    const proc = new EventEmitter() as MockChildProcess;
    proc.stdout = new EventEmitter();
    proc.stderr = new EventEmitter();
    childProcessMock.spawn.mockReturnValue(proc);
    process.nextTick(() => {
      proc.emit("error", new Error("git not found"));
    });

    // Act / Assert
    await expect(
      createGitRunner().run(["worktree", "list"], "/repo"),
    ).rejects.toThrow(/git not found/);
  });
});
