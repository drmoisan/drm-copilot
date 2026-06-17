import { afterEach, describe, expect, it, jest } from "@jest/globals";
import { EventEmitter } from "node:events";

import {
  buildRemovalSummaryMessage,
  classifyWorktreeForRemoval,
  parseWorktreePorcelain,
  selectSecondaryWorktrees,
  type WorktreeEntry,
  type WorktreeSummary,
} from "../src/remove-worktrees";
import {
  createGitRunner,
  removeAllSecondaryWorktrees,
  type GitRunResult,
  type GitRunner,
} from "../src/remove-worktrees-runner";
import {
  createMockProcess,
  createMockProcessWithStderr,
  type MockChildProcess,
} from "./runtime-test-helpers";

// ---------------------------------------------------------------------------
// [P4-T1] parseWorktreePorcelain
// ---------------------------------------------------------------------------

describe("parseWorktreePorcelain", () => {
  it("parses a single primary block and marks it primary", () => {
    // Arrange
    const raw = "worktree /repo/main\nHEAD abc123\nbranch refs/heads/main\n";

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries).toHaveLength(1);
    expect(entries[0].path).toBe("/repo/main");
    expect(entries[0].isPrimary).toBe(true);
    expect(entries[0].isLocked).toBe(false);
    expect(entries[0].isPrunable).toBe(false);
  });

  it("marks only the first block as primary across multiple blocks", () => {
    // Arrange
    const raw = [
      "worktree /repo/main\nHEAD aaa\nbranch refs/heads/main",
      "worktree /repo/wt-1\nHEAD bbb\nbranch refs/heads/feature-1",
      "worktree /repo/wt-2\nHEAD ccc\nbranch refs/heads/feature-2",
    ].join("\n\n");

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries.map((entry) => entry.path)).toEqual([
      "/repo/main",
      "/repo/wt-1",
      "/repo/wt-2",
    ]);
    expect(entries.map((entry) => entry.isPrimary)).toEqual([
      true,
      false,
      false,
    ]);
  });

  it("parses a locked entry with a reason", () => {
    // Arrange
    const raw = [
      "worktree /repo/main\nHEAD aaa",
      "worktree /repo/wt-1\nHEAD bbb\nlocked needs review",
    ].join("\n\n");

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries[1].isLocked).toBe(true);
    expect(entries[1].lockReason).toBe("needs review");
  });

  it("parses a locked entry with no reason", () => {
    // Arrange
    const raw = ["worktree /repo/main", "worktree /repo/wt-1\nlocked"].join(
      "\n\n",
    );

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries[1].isLocked).toBe(true);
    expect(entries[1].lockReason).toBe("");
  });

  it("parses a prunable entry with a reason", () => {
    // Arrange
    const raw = [
      "worktree /repo/main",
      "worktree /repo/wt-1\nprunable gitdir file points to non-existent location",
    ].join("\n\n");

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries[1].isPrunable).toBe(true);
    expect(entries[1].pruneReason).toBe(
      "gitdir file points to non-existent location",
    );
  });

  it("parses a prunable entry with no reason", () => {
    // Arrange
    const raw = ["worktree /repo/main", "worktree /repo/wt-1\nprunable"].join(
      "\n\n",
    );

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries[1].isPrunable).toBe(true);
    expect(entries[1].pruneReason).toBe("");
  });

  it("recognizes detached and bare flags without affecting removal data", () => {
    // Arrange
    const raw = [
      "worktree /repo/main\nbare",
      "worktree /repo/wt-1\nHEAD bbb\ndetached",
    ].join("\n\n");

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries).toHaveLength(2);
    expect(entries[1].path).toBe("/repo/wt-1");
    expect(entries[1].isLocked).toBe(false);
    expect(entries[1].isPrunable).toBe(false);
  });

  it("splits blocks separated by CRLF blank lines", () => {
    // Arrange
    const raw =
      "worktree /repo/main\r\nHEAD aaa\r\n\r\nworktree /repo/wt-1\r\nHEAD bbb\r\n";

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries.map((entry) => entry.path)).toEqual([
      "/repo/main",
      "/repo/wt-1",
    ]);
  });

  it("ignores a trailing blank block", () => {
    // Arrange
    const raw = "worktree /repo/main\nHEAD aaa\n\n\n";

    // Act
    const entries = parseWorktreePorcelain(raw);

    // Assert
    expect(entries).toHaveLength(1);
    expect(entries[0].path).toBe("/repo/main");
  });
});

// ---------------------------------------------------------------------------
// [P4-T2] selectSecondaryWorktrees
// ---------------------------------------------------------------------------

function entry(overrides: Partial<WorktreeEntry>): WorktreeEntry {
  return {
    path: "/repo/wt",
    isPrimary: false,
    isLocked: false,
    lockReason: "",
    isPrunable: false,
    pruneReason: "",
    ...overrides,
  };
}

describe("selectSecondaryWorktrees", () => {
  it("excludes the primary worktree", () => {
    // Arrange
    const entries = [
      entry({ path: "/repo/main", isPrimary: true }),
      entry({ path: "/repo/wt-1" }),
    ];

    // Act
    const result = selectSecondaryWorktrees(entries);

    // Assert
    expect(result.map((item) => item.path)).toEqual(["/repo/wt-1"]);
  });

  it("preserves input order of secondary worktrees", () => {
    // Arrange
    const entries = [
      entry({ path: "/repo/main", isPrimary: true }),
      entry({ path: "/repo/wt-3" }),
      entry({ path: "/repo/wt-1" }),
      entry({ path: "/repo/wt-2" }),
    ];

    // Act
    const result = selectSecondaryWorktrees(entries);

    // Assert
    expect(result.map((item) => item.path)).toEqual([
      "/repo/wt-3",
      "/repo/wt-1",
      "/repo/wt-2",
    ]);
  });

  it("returns an empty set when only the primary is present", () => {
    // Arrange
    const entries = [entry({ path: "/repo/main", isPrimary: true })];

    // Act
    const result = selectSecondaryWorktrees(entries);

    // Assert
    expect(result).toEqual([]);
  });
});

// ---------------------------------------------------------------------------
// [P4-T3] classifyWorktreeForRemoval
// ---------------------------------------------------------------------------

describe("classifyWorktreeForRemoval", () => {
  it("skips a locked entry with a reason containing 'locked'", () => {
    // Arrange
    const target = entry({ isLocked: true, lockReason: "in use" });

    // Act
    const result = classifyWorktreeForRemoval(target);

    // Assert
    expect(result.skip).toBe(true);
    if (result.skip) {
      expect(result.reason).toContain("locked");
      expect(result.reason).toContain("in use");
    }
  });

  it("skips a prunable entry with a path-missing reason", () => {
    // Arrange
    const target = entry({ isPrunable: true, pruneReason: "gitdir missing" });

    // Act
    const result = classifyWorktreeForRemoval(target);

    // Assert
    expect(result.skip).toBe(true);
    if (result.skip) {
      expect(result.reason).toContain("missing on disk");
      expect(result.reason).toContain("gitdir missing");
    }
  });

  it("marks a clean entry as eligible for removal", () => {
    // Arrange
    const target = entry({ path: "/repo/wt-1" });

    // Act
    const result = classifyWorktreeForRemoval(target);

    // Assert
    expect(result.skip).toBe(false);
  });

  it("reports locked before prunable when both flags are set", () => {
    // Arrange
    const target = entry({
      isLocked: true,
      lockReason: "held",
      isPrunable: true,
      pruneReason: "gone",
    });

    // Act
    const result = classifyWorktreeForRemoval(target);

    // Assert
    expect(result.skip).toBe(true);
    if (result.skip) {
      expect(result.reason).toContain("locked");
      expect(result.reason).not.toContain("missing on disk");
    }
  });
});

// ---------------------------------------------------------------------------
// [P4-T4] buildRemovalSummaryMessage
// ---------------------------------------------------------------------------

describe("buildRemovalSummaryMessage", () => {
  it("reports no secondary worktrees when both lists are empty", () => {
    // Arrange
    const summary: WorktreeSummary = { removed: [], skipped: [] };

    // Act
    const message = buildRemovalSummaryMessage(summary);

    // Assert
    expect(message).toBe("No secondary worktrees found.");
  });

  it("reports the removed count when nothing was skipped", () => {
    // Arrange
    const summary: WorktreeSummary = {
      removed: ["/repo/wt-1", "/repo/wt-2"],
      skipped: [],
    };

    // Act
    const message = buildRemovalSummaryMessage(summary);

    // Assert
    expect(message).toBe("Removed 2 worktree(s).");
  });

  it("lists skipped paths when some worktrees were skipped", () => {
    // Arrange
    const summary: WorktreeSummary = {
      removed: ["/repo/wt-1"],
      skipped: [{ path: "/repo/wt-2", reason: "locked" }],
    };

    // Act
    const message = buildRemovalSummaryMessage(summary);

    // Assert
    expect(message).toContain("Removed 1 worktree(s).");
    expect(message).toContain("Skipped 1");
    expect(message).toContain("/repo/wt-2");
  });
});

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
    const summary = await removeAllSecondaryWorktrees("/repo", git, output);

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
    const summary = await removeAllSecondaryWorktrees("/repo", git, output);

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
    const summary = await removeAllSecondaryWorktrees("/repo", git, output);

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
    const summary = await removeAllSecondaryWorktrees("/repo", git, output);

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
    await removeAllSecondaryWorktrees("/repo", git, output);

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
      removeAllSecondaryWorktrees("/repo", git, output),
    ).rejects.toThrow(/not a git repository/);
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
