import { describe, expect, it, jest } from "@jest/globals";

// A minimal virtual `vscode` mock is retained here because `command-runtime.ts`
// still imports `vscode` at module scope (e.g. for `getWorkspaceRoot`,
// `createOutputChannel`); the `getClaudeProjectsRoot` tests below do not
// exercise any `vscode` API themselves, but the module must still import
// cleanly under Jest, which has no real `vscode` module on disk.
jest.mock("vscode", () => ({}), { virtual: true });

import { getClaudeProjectsRoot } from "../src/command-runtime";

describe("getClaudeProjectsRoot", () => {
  it("uses CLAUDE_CONFIG_DIR's projects subfolder when it is set", () => {
    // Arrange
    const env = { CLAUDE_CONFIG_DIR: "/custom/config" } as NodeJS.ProcessEnv;

    // Act
    const root = getClaudeProjectsRoot(env);

    // Assert
    expect(root).toBe("/custom/config/projects");
  });

  it("falls back to HOME/.claude/projects when CLAUDE_CONFIG_DIR is unset", () => {
    // Arrange
    const env = { HOME: "/home/dan" } as NodeJS.ProcessEnv;

    // Act
    const root = getClaudeProjectsRoot(env);

    // Assert
    expect(root).toBe("/home/dan/.claude/projects");
  });

  it("falls back to USERPROFILE when neither CLAUDE_CONFIG_DIR nor HOME is set", () => {
    // Arrange
    const env = { USERPROFILE: "C:/Users/dan" } as NodeJS.ProcessEnv;

    // Act
    const root = getClaudeProjectsRoot(env);

    // Assert
    expect(root).toBe("C:/Users/dan/.claude/projects");
  });

  it("treats a whitespace-only CLAUDE_CONFIG_DIR as unset and falls back to HOME", () => {
    // Arrange
    const env = {
      CLAUDE_CONFIG_DIR: "   ",
      HOME: "/home/dan",
    } as NodeJS.ProcessEnv;

    // Act
    const root = getClaudeProjectsRoot(env);

    // Assert
    expect(root).toBe("/home/dan/.claude/projects");
  });

  it("throws when none of CLAUDE_CONFIG_DIR, HOME, or USERPROFILE is set", () => {
    // Arrange
    const env = {} as NodeJS.ProcessEnv;

    // Act / Assert
    expect(() => getClaudeProjectsRoot(env)).toThrow(
      /Cannot resolve the user-global Claude projects directory/,
    );
  });
});
