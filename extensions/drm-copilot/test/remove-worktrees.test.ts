import { describe, expect, it } from "@jest/globals";

import {
  buildRemovalSummaryMessage,
  classifyWorktreeForRemoval,
  parseWorktreePorcelain,
  selectSecondaryWorktrees,
  type WorktreeEntry,
  type WorktreeSummary,
} from "../src/remove-worktrees";

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
