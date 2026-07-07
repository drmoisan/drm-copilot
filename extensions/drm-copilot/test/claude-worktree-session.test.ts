import { describe, expect, it } from "@jest/globals";

import {
  buildBranchName,
  buildWorktreeGroupDirectory,
  buildWorktreePath,
  buildWorktreeSessionCommands,
  deriveWorktreeGroupDirectory,
  formatWorktreeTimestamp,
  quoteForPwsh,
} from "../src/claude-worktree-session";

describe("formatWorktreeTimestamp", () => {
  it("formats a fixed local-time date as a 16-character yyyy-MM-ddTHH-mm string", () => {
    // Arrange
    const fixedDate = new Date(2026, 3, 20, 9, 59, 37);

    // Act
    const result = formatWorktreeTimestamp(fixedDate);

    // Assert
    expect(result).toBe("2026-04-20T09-59");
  });

  it("zero-pads single-digit calendar fields with the T separator", () => {
    // Arrange
    const fixedDate = new Date(2026, 0, 1, 0, 0, 0);

    // Act
    const result = formatWorktreeTimestamp(fixedDate);

    // Assert
    expect(result).toBe("2026-01-01T00-00");
    expect(result).toHaveLength(16);
  });

  it("produces the same string as the PowerShell formatter for the shared fixed fixture", () => {
    // Cross-toolchain parity. The matching PowerShell counterpart is the Pester
    // "returns correct yyyy-MM-ddTHH-mm format for injected fixed datetime" test
    // (P1-T7) in tests/scripts/dev-tools/new-claude-worktree-session.Tests.ps1,
    // which asserts the byte-identical string for local 2026-04-20 09:59.
    // Arrange
    const fixedDate = new Date(2026, 3, 20, 9, 59, 37);

    // Act
    const result = formatWorktreeTimestamp(fixedDate);

    // Assert
    expect(result).toBe("2026-04-20T09-59");
  });
});

describe("buildWorktreePath", () => {
  it("composes the nested repoName-wt/timestamp path with forward slashes", () => {
    // Arrange
    const parent = "/parent";
    const timestamp = "2026-04-20T09-59";
    const repoName = "auth";

    // Act
    const result = buildWorktreePath(parent, timestamp, repoName);

    // Assert
    expect(result).toBe("/parent/auth-wt/2026-04-20T09-59");
  });

  it("normalizes Windows-style backslashes in the parent directory to forward slashes", () => {
    // Arrange
    const parent = "C:\\repos";

    // Act
    const result = buildWorktreePath(parent, "2026-04-20T09-59", "auth");

    // Assert
    expect(result).toBe("C:/repos/auth-wt/2026-04-20T09-59");
  });

  it("strips trailing slashes from the parent directory", () => {
    // Arrange
    const parent = "/parent/";

    // Act
    const result = buildWorktreePath(parent, "2026-04-20T09-59", "auth");

    // Assert
    expect(result).toBe("/parent/auth-wt/2026-04-20T09-59");
  });
});

describe("buildWorktreeGroupDirectory", () => {
  it("composes the <parent>/<repoName>-wt grouping directory", () => {
    // Arrange / Act
    const result = buildWorktreeGroupDirectory("/parent", "auth");

    // Assert
    expect(result).toBe("/parent/auth-wt");
  });

  it("is the leading segment of buildWorktreePath for the same inputs (no drift)", () => {
    // Arrange
    const group = buildWorktreeGroupDirectory("/parent", "auth");

    // Act
    const path = buildWorktreePath("/parent", "2026-04-20T09-59", "auth");

    // Assert
    expect(path.startsWith(`${group}/`)).toBe(true);
  });
});

describe("deriveWorktreeGroupDirectory", () => {
  it("strips the timestamp leaf to recover the grouping directory", () => {
    // Arrange / Act
    const result = deriveWorktreeGroupDirectory(
      "/parent/auth-wt/2026-04-20T09-59",
    );

    // Assert
    expect(result).toBe("/parent/auth-wt");
  });

  it("normalizes backslashes before stripping the leaf", () => {
    // Arrange / Act
    const result = deriveWorktreeGroupDirectory(
      "C:\\repos\\auth-wt\\2026-04-20T09-59",
    );

    // Assert
    expect(result).toBe("C:/repos/auth-wt");
  });
});

describe("buildBranchName", () => {
  it("composes a flat <repoName>-wt-<timestamp> branch name", () => {
    // Arrange / Act
    const result = buildBranchName("2026-04-20T09-59", "auth");

    // Assert
    expect(result).toBe("auth-wt-2026-04-20T09-59");
  });

  it("produces a flat branch name that contains no path separator", () => {
    // Arrange / Act
    const result = buildBranchName("2026-04-20T09-59", "auth");

    // Assert
    expect(result).not.toContain("/");
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
    worktreePath: "/parent/auth-wt/2026-04-20T09-59",
    branchName: "auth-wt-2026-04-20T09-59",
    usePoetry: false,
    preClaudeScriptPath: undefined,
  };

  it("emits a git command that uses git -C <repoRoot> with quoted path and branch", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
    });

    // Assert
    expect(commands.git).toBe(
      "git -C '/parent/drm-copilot' worktree add '/parent/auth-wt/2026-04-20T09-59' -b 'auth-wt-2026-04-20T09-59'",
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
      "Set-Location '/parent/auth-wt/2026-04-20T09-59'",
    );
  });

  it("emits an idempotent ensureParentDirectory command quoted with quoteForPwsh", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
    });

    // Assert
    expect(commands.ensureParentDirectory).toBe(
      "New-Item -ItemType Directory -Force -Path '/parent/auth-wt' | Out-Null",
    );
  });

  it("guards the grouping directory that is the leading segment of the worktree path (no drift)", () => {
    // Arrange
    const worktreePath = buildWorktreePath(
      "/parent",
      "2026-04-20T09-59",
      "auth",
    );
    const group = buildWorktreeGroupDirectory("/parent", "auth");

    // Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      worktreePath,
      objective: undefined,
    });

    // Assert
    expect(commands.ensureParentDirectory).toBe(
      `New-Item -ItemType Directory -Force -Path ${quoteForPwsh(group)} | Out-Null`,
    );
    expect(worktreePath.startsWith(`${group}/`)).toBe(true);
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
      preClaudeScriptPath: undefined,
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

  it("emits preClaude as undefined when preClaudeScriptPath is undefined", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
      preClaudeScriptPath: undefined,
    });

    // Assert
    expect(commands.preClaude).toBeUndefined();
  });

  it("emits preClaude as undefined for an empty preClaudeScriptPath", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
      preClaudeScriptPath: "",
    });

    // Assert
    expect(commands.preClaude).toBeUndefined();
  });

  it("emits preClaude as undefined for a whitespace-only preClaudeScriptPath", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
      preClaudeScriptPath: "   ",
    });

    // Assert
    expect(commands.preClaude).toBeUndefined();
  });

  it("emits a Test-Path-guarded preClaude command for a normal script path", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
      preClaudeScriptPath: ".claude/hooks/pre-claude-session.ps1",
    });

    // Assert
    expect(commands.preClaude).toBe(
      "if (Test-Path -LiteralPath '.claude/hooks/pre-claude-session.ps1') { & '.claude/hooks/pre-claude-session.ps1' }",
    );
  });

  it("preserves spaces and doubles apostrophes in the preClaude script path", () => {
    // Arrange / Act
    const commands = buildWorktreeSessionCommands({
      ...baseInput,
      objective: undefined,
      preClaudeScriptPath: "C:/o'connor dir/pre.ps1",
    });

    // Assert
    expect(commands.preClaude).toBe(
      "if (Test-Path -LiteralPath 'C:/o''connor dir/pre.ps1') { & 'C:/o''connor dir/pre.ps1' }",
    );
  });
});
