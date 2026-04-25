import { describe, expect, it } from "@jest/globals";

import {
  buildBranchName,
  buildWorktreePath,
  buildWorktreeSessionCommands,
  formatWorktreeTimestamp,
  quoteForPwsh,
} from "../src/claude-worktree-session";

describe("formatWorktreeTimestamp", () => {
  it("formats a fixed local-time date as a 14-character yyyyMMddHHmmss string", () => {
    // Arrange
    const fixedDate = new Date(2026, 3, 20, 9, 59, 37);

    // Act
    const result = formatWorktreeTimestamp(fixedDate);

    // Assert
    expect(result).toBe("20260420095937");
  });

  it("zero-pads single-digit calendar fields", () => {
    // Arrange
    const fixedDate = new Date(2026, 0, 1, 0, 0, 0);

    // Act
    const result = formatWorktreeTimestamp(fixedDate);

    // Assert
    expect(result).toBe("20260101000000");
    expect(result).toHaveLength(14);
  });
});

describe("buildWorktreePath", () => {
  it("composes the canonical drm-copilot-wt path with forward slashes", () => {
    // Arrange
    const parent = "/parent";
    const timestamp = "20260420095937";
    const shortName = "auth";

    // Act
    const result = buildWorktreePath(parent, timestamp, shortName);

    // Assert
    expect(result).toBe("/parent/drm-copilot-wt-20260420095937-auth");
  });

  it("normalizes Windows-style backslashes in the parent directory to forward slashes", () => {
    // Arrange
    const parent = "C:\\repos";

    // Act
    const result = buildWorktreePath(parent, "20260420095937", "auth");

    // Assert
    expect(result).toBe("C:/repos/drm-copilot-wt-20260420095937-auth");
  });

  it("strips trailing slashes from the parent directory", () => {
    // Arrange
    const parent = "/parent/";

    // Act
    const result = buildWorktreePath(parent, "20260420095937", "auth");

    // Assert
    expect(result).toBe("/parent/drm-copilot-wt-20260420095937-auth");
  });
});

describe("buildBranchName", () => {
  it("composes a feature/<timestamp>-<shortName> branch name", () => {
    // Arrange / Act
    const result = buildBranchName("20260420095937", "auth");

    // Assert
    expect(result).toBe("feature/20260420095937-auth");
  });
});

describe("quoteForPwsh", () => {
  it("returns an empty single-quoted literal for an empty string", () => {
    // Arrange / Act
    const result = quoteForPwsh("");

    // Assert
    expect(result).toBe("''");
  });

  it("wraps plain text in single quotes without modification", () => {
    // Arrange / Act
    const result = quoteForPwsh("plain text");

    // Assert
    expect(result).toBe("'plain text'");
  });

  it("doubles a standalone single quote so PowerShell preserves it", () => {
    // Arrange / Act
    const result = quoteForPwsh("'");

    // Assert
    expect(result).toBe("''''");
  });

  it("doubles embedded apostrophes inside a word", () => {
    // Arrange / Act
    const result = quoteForPwsh("don't");

    // Assert
    expect(result).toBe("'don''t'");
  });
});

describe("buildWorktreeSessionCommands", () => {
  const baseInput = {
    repoRoot: "/parent/drm-copilot",
    worktreePath: "/parent/drm-copilot-wt-20260420095937-auth",
    branchName: "feature/20260420095937-auth",
    usePoetry: false,
  };

  it("emits a git command that uses git -C <repoRoot> with quoted path and branch", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
    });

    // Assert
    expect(commands.git).toBe(
      "git -C '/parent/drm-copilot' worktree add '/parent/drm-copilot-wt-20260420095937-auth' -b 'feature/20260420095937-auth'",
    );
  });

  it("emits a Set-Location command targeting the worktree path", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
    });

    // Assert
    expect(commands.setLocation).toBe(
      "Set-Location '/parent/drm-copilot-wt-20260420095937-auth'",
    );
  });

  it("returns undefined poetryInstall and activate when usePoetry is false", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      usePoetry: false,
      objective: undefined,
    });

    // Assert
    expect(commands.poetryInstall).toBeUndefined();
    expect(commands.activate).toBeUndefined();
  });

  it("emits poetry install --with dev when usePoetry is true", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      usePoetry: true,
      objective: undefined,
    });

    // Assert
    expect(commands.poetryInstall).toBe("poetry install --with dev");
  });

  it("emits a relative-path activate command for the worktree-local venv when usePoetry is true", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      usePoetry: true,
      objective: undefined,
    });

    // Assert
    expect(commands.activate).toBe("& './.venv/Scripts/Activate.ps1'");
  });

  it("emits a claude command without a trailing objective when objective is undefined", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
    });

    // Assert
    expect(commands.claude).toBe("claude --dangerously-skip-permissions");
  });

  it("emits a claude command without a trailing objective when objective trims to empty", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: "   ",
    });

    // Assert
    expect(commands.claude).toBe("claude --dangerously-skip-permissions");
  });

  it("emits a claude command with the quoted objective when supplied", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: "Refactor the auth module.",
    });

    // Assert
    expect(commands.claude).toBe(
      "claude --dangerously-skip-permissions 'Refactor the auth module.'",
    );
  });

  it("escapes embedded apostrophes inside the claude objective", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: "don't break the build",
    });

    // Assert
    expect(commands.claude).toBe(
      "claude --dangerously-skip-permissions 'don''t break the build'",
    );
  });

  it("quotes a repo root, worktree path, and branch that contain spaces or apostrophes", () => {
    // Arrange
    const tricky = {
      repoRoot: "/parent dir/o'connor",
      worktreePath: "/parent dir/o'connor-wt",
      branchName: "feature/o'connor",
      usePoetry: false,
      objective: undefined,
    };

    // Act
    const commands = buildWorktreeSessionCommands(tricky);

    // Assert
    expect(commands.git).toBe(
      "git -C '/parent dir/o''connor' worktree add '/parent dir/o''connor-wt' -b 'feature/o''connor'",
    );
    expect(commands.setLocation).toBe(
      "Set-Location '/parent dir/o''connor-wt'",
    );
  });
});
