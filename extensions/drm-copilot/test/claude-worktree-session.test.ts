import { describe, expect, it } from "@jest/globals";

import {
  buildBranchName,
  buildWorktreePath,
  buildWorktreeSessionCommand,
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

describe("buildWorktreeSessionCommand", () => {
  const baseInput = {
    repoRoot: "/parent/drm-copilot",
    worktreePath: "/parent/drm-copilot-wt-20260420095937-auth",
    branchName: "feature/20260420095937-auth",
  };

  it("includes git -C <repoRoot> worktree add, Set-Location, and the claude command without the objective when objective is undefined", () => {
    // Arrange / Act
    const command = buildWorktreeSessionCommand({
      ...baseInput,
      objective: undefined,
    });

    // Assert
    expect(command).toContain(
      "git -C '/parent/drm-copilot' worktree add '/parent/drm-copilot-wt-20260420095937-auth' -b 'feature/20260420095937-auth'",
    );
    expect(command).toContain("$LASTEXITCODE -eq 0");
    expect(command).toContain(
      "Set-Location '/parent/drm-copilot-wt-20260420095937-auth'",
    );
    expect(command).toContain("claude --dangerously-skip-permissions");
    expect(command).not.toContain("claude --dangerously-skip-permissions '");
  });

  it("omits the trailing objective when objective trims to empty", () => {
    // Arrange / Act
    const command = buildWorktreeSessionCommand({
      ...baseInput,
      objective: "   ",
    });

    // Assert
    expect(command).toContain("claude --dangerously-skip-permissions");
    expect(command).not.toMatch(/claude --dangerously-skip-permissions '/);
  });

  it("appends a quoted objective when supplied", () => {
    // Arrange
    const objective = "Refactor the auth module.";

    // Act
    const command = buildWorktreeSessionCommand({
      ...baseInput,
      objective,
    });

    // Assert
    expect(command).toContain(
      "claude --dangerously-skip-permissions 'Refactor the auth module.'",
    );
  });

  it("escapes embedded apostrophes inside the objective", () => {
    // Arrange
    const objective = "don't break the build";

    // Act
    const command = buildWorktreeSessionCommand({
      ...baseInput,
      objective,
    });

    // Assert
    expect(command).toContain(
      "claude --dangerously-skip-permissions 'don''t break the build'",
    );
  });

  it("guards the claude launch behind a $LASTEXITCODE check on the worktree add", () => {
    // Arrange / Act
    const command = buildWorktreeSessionCommand({
      ...baseInput,
      objective: undefined,
    });

    // Assert
    expect(command).toMatch(
      /git -C .* worktree add .* -b .*; if \(\$LASTEXITCODE -eq 0\) \{ Set-Location .* claude --dangerously-skip-permissions \}$/,
    );
  });

  it("quotes a repo root, worktree path, and branch that contain spaces or apostrophes", () => {
    // Arrange
    const tricky = {
      repoRoot: "/parent dir/o'connor",
      worktreePath: "/parent dir/o'connor-wt",
      branchName: "feature/o'connor",
      objective: undefined,
    };

    // Act
    const command = buildWorktreeSessionCommand(tricky);

    // Assert
    expect(command).toContain(
      "git -C '/parent dir/o''connor' worktree add '/parent dir/o''connor-wt' -b 'feature/o''connor'",
    );
    expect(command).toContain("Set-Location '/parent dir/o''connor-wt'");
  });
});
