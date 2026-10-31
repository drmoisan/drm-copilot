import { describe, expect, it } from "@jest/globals";

import { buildWorktreeSessionCommands } from "../src/claude-worktree-session";
import { buildCodexWorktreeSessionCommands } from "../src/codex-worktree-session";
import {
  buildClaudeSessionScript,
  buildClaudeSessionShellArgs,
  buildCodexSessionScript,
  buildCodexSessionShellArgs,
  buildEncodedShellArgs,
  encodePowerShellCommand,
  MAX_ENCODED_COMMAND_LENGTH,
} from "../src/worktree-session-launch";

/**
 * Decodes the `-EncodedCommand` argument of a shellArgs array in memory.
 *
 * @param shellArgs The shellArgs array returned by the launch module.
 * @returns The decoded script text.
 */
function decodeShellArgs(shellArgs: readonly string[]): string {
  const encoded = shellArgs[3] ?? "";
  return Buffer.from(encoded, "base64").toString("utf16le");
}

/**
 * Asserts that every needle occurs in the haystack in strictly increasing order.
 *
 * @param haystack The decoded script.
 * @param needles Substrings expected in order.
 */
function expectInOrder(haystack: string, needles: readonly string[]): void {
  let previous = -1;
  for (const needle of needles) {
    const index = haystack.indexOf(needle, previous + 1);
    expect({ needle, found: index > previous }).toEqual({
      needle,
      found: true,
    });
    previous = index;
  }
}

/**
 * Counts non-overlapping occurrences of a substring.
 *
 * @param haystack Text to search.
 * @param needle Substring to count.
 * @returns The occurrence count.
 */
function countOccurrences(haystack: string, needle: string): number {
  return haystack.split(needle).length - 1;
}

const claudeBase = {
  repoRoot: "C:/workspace",
  worktreePath: "C:/workspace-wt/2026-04-20T09-59",
  branchName: "workspace-wt-2026-04-20T09-59",
};

const codexBase = {
  ...claudeBase,
  codexExecutablePath: "C:/bin/codex.exe",
};

const fullClaudeCommands = buildWorktreeSessionCommands({
  ...claudeBase,
  usePoetry: true,
  objective: "Refactor the auth module.",
  preClaudeScriptPath: "scripts/bootstrap.ps1",
});

const minimalClaudeCommands = buildWorktreeSessionCommands({
  ...claudeBase,
  usePoetry: false,
  objective: undefined,
  preClaudeScriptPath: undefined,
});

const fullCodexCommands = buildCodexWorktreeSessionCommands({
  ...codexBase,
  usePoetry: true,
  objective: "Start the Codex session.",
  postCodexScriptPath: "C:/workspace/scripts/post-codex.ps1",
});

const minimalCodexCommands = buildCodexWorktreeSessionCommands({
  ...codexBase,
  usePoetry: false,
  objective: undefined,
  postCodexScriptPath: "",
});

describe("worktree-session-launch encoding", () => {
  it("encodes the script as base64 of UTF-16LE that round-trips through Buffer", () => {
    // Arrange
    const script = "Write-Host 'caf\u00e9 \u2713'";

    // Act
    const encoded = encodePowerShellCommand(script);

    // Assert
    expect(encoded).toMatch(/^[A-Za-z0-9+/]+=*$/);
    expect(Buffer.from(encoded, "base64").toString("utf16le")).toBe(script);
  });

  it("returns shellArgs in the order -NoLogo, -NoExit, -EncodedCommand, encoded", () => {
    // Arrange
    const script = "Write-Host 'hello'";

    // Act
    const shellArgs = buildEncodedShellArgs(script);

    // Assert
    expect(shellArgs).toEqual([
      "-NoLogo",
      "-NoExit",
      "-EncodedCommand",
      encodePowerShellCommand(script),
    ]);
  });

  it("accepts a script whose encoded length is exactly 30000", () => {
    // Arrange
    const script = "a".repeat(11250);

    // Act
    const shellArgs = buildEncodedShellArgs(script);

    // Assert
    expect(MAX_ENCODED_COMMAND_LENGTH).toBe(30000);
    expect(shellArgs[3]).toHaveLength(30000);
  });

  it("throws when the encoded length exceeds 30000", () => {
    // Arrange
    const script = "a".repeat(11251);

    // Act
    const act = (): string[] => buildEncodedShellArgs(script);

    // Assert
    expect(act).toThrow(Error);
    expect(act).toThrow(/30004 characters.*30000-character limit/);
  });
});

describe("worktree-session-launch Claude script", () => {
  it("orders the Claude steps ensureParentDirectory, git, setLocation, poetryInstall, activate, preClaude, claude", () => {
    // Arrange / Act
    const script = decodeShellArgs(
      buildClaudeSessionShellArgs(fullClaudeCommands),
    );

    // Assert
    expectInOrder(script, [
      fullClaudeCommands.ensureParentDirectory,
      fullClaudeCommands.git,
      fullClaudeCommands.setLocation,
      fullClaudeCommands.poetryInstall ?? "missing poetryInstall",
      fullClaudeCommands.activate ?? "missing activate",
      fullClaudeCommands.preClaude ?? "missing preClaude",
      fullClaudeCommands.claude,
    ]);
    expect(script).toContain(
      "claude --dangerously-skip-permissions 'Refactor the auth module.'",
    );
  });

  it("omits poetryInstall, activate, and preClaude when they are undefined", () => {
    // Arrange / Act
    const script = buildClaudeSessionScript(minimalClaudeCommands);

    // Assert
    expect(script).not.toContain("poetry install");
    expect(script).not.toContain("Activate.ps1");
    expect(script).not.toContain("Test-Path");
    expect(script).not.toContain("Installing dependencies with poetry");
    expect(script).not.toContain("Activating virtual environment");
    expect(script).not.toContain("Running pre-claude script");
    expect(script).toContain("claude --dangerously-skip-permissions\n");
  });

  it("emits a LASTEXITCODE guard after git worktree add and after poetry install", () => {
    // Arrange / Act
    const script = buildClaudeSessionScript(fullClaudeCommands);

    // Assert
    expectInOrder(script, [
      fullClaudeCommands.git,
      "if ($LASTEXITCODE -ne 0) { throw ('git worktree add failed with exit code ' + $LASTEXITCODE) }",
      fullClaudeCommands.setLocation,
      "poetry install --with dev",
      "if ($LASTEXITCODE -ne 0) { throw ('poetry install failed with exit code ' + $LASTEXITCODE) }",
      "Activating virtual environment",
    ]);
  });

  it("emits no LASTEXITCODE guard for poetry install when poetry is not used", () => {
    // Arrange / Act
    const script = buildClaudeSessionScript(minimalClaudeCommands);

    // Assert
    expect(countOccurrences(script, "$LASTEXITCODE -ne 0")).toBe(1);
    expect(script).not.toContain("poetry install failed");
  });

  it("places the agent launch after the guarded try block behind the success flag", () => {
    // Arrange / Act
    const claudeScript = buildClaudeSessionScript(fullClaudeCommands);
    const codexScript = buildCodexSessionScript(fullCodexCommands);

    // Assert
    expect(claudeScript.startsWith("& {\n$setupSucceeded = $false\ntry {\n")).toBe(
      true,
    );
    expectInOrder(claudeScript, [
      fullClaudeCommands.preClaude ?? "missing preClaude",
      "$setupSucceeded = $true",
      "} catch {",
      "if ($setupSucceeded) {",
      "Write-Host '==> Starting claude'",
      fullClaudeCommands.claude,
    ]);
    expect(claudeScript.endsWith(`${fullClaudeCommands.claude}\n}\n}`)).toBe(
      true,
    );
    expectInOrder(codexScript, [
      fullCodexCommands.postCodex ?? "missing postCodex",
      "$setupSucceeded = $true",
      "} catch {",
      "if ($setupSucceeded) {",
      "Write-Host '==> Starting codex'",
      fullCodexCommands.codex,
    ]);
  });

  it("writes a red setup-failure message in the catch block", () => {
    // Arrange / Act
    const claudeScript = buildClaudeSessionScript(minimalClaudeCommands);
    const codexScript = buildCodexSessionScript(minimalCodexCommands);

    // Assert
    expect(claudeScript).toContain(
      '} catch { Write-Host "Claude session setup failed: $_" -ForegroundColor Red }',
    );
    expect(codexScript).toContain(
      '} catch { Write-Host "Codex session setup failed: $_" -ForegroundColor Red }',
    );
  });

  it("emits one Write-Host banner per emitted step plus the launch", () => {
    // Arrange / Act
    const fullClaude = buildClaudeSessionScript(fullClaudeCommands);
    const minimalClaude = buildClaudeSessionScript(minimalClaudeCommands);
    const fullCodex = buildCodexSessionScript(fullCodexCommands);
    const minimalCodex = buildCodexSessionScript(minimalCodexCommands);

    // Assert
    expect(countOccurrences(fullClaude, "Write-Host '==> ")).toBe(7);
    expect(countOccurrences(minimalClaude, "Write-Host '==> ")).toBe(4);
    expect(countOccurrences(fullCodex, "Write-Host '==> ")).toBe(8);
    expect(countOccurrences(minimalCodex, "Write-Host '==> ")).toBe(5);
    expectInOrder(fullClaude, [
      "Write-Host '==> Creating worktree group directory'",
      "Write-Host '==> Adding git worktree'",
      "Write-Host '==> Entering worktree'",
      "Write-Host '==> Installing dependencies with poetry'",
      "Write-Host '==> Activating virtual environment'",
      "Write-Host '==> Running pre-claude script'",
      "Write-Host '==> Starting claude'",
    ]);
  });

  it("contains no &&, ||, $IsWindows, or $ErrorActionPreference in either session script", () => {
    // Arrange / Act
    const scripts = [
      buildClaudeSessionScript(fullClaudeCommands),
      buildCodexSessionScript(fullCodexCommands),
    ];

    // Assert
    for (const script of scripts) {
      expect(script).not.toContain("&&");
      expect(script).not.toContain("||");
      expect(script).not.toContain("$IsWindows");
      expect(script).not.toContain("$ErrorActionPreference");
    }
  });

  it("preserves spaces, double quotes, and apostrophes in paths and objective after a decode round trip", () => {
    // Arrange
    const commands = buildWorktreeSessionCommands({
      repoRoot: "C:/o'connor dir/repo",
      worktreePath: "C:/o'connor dir/repo-wt/2026-04-20T09-59",
      branchName: "repo-wt-2026-04-20T09-59",
      usePoetry: false,
      objective: 'Fix the "auth" module, don\'t break it',
      preClaudeScriptPath: undefined,
    });

    // Act
    const script = decodeShellArgs(buildClaudeSessionShellArgs(commands));

    // Assert
    expect(script).toContain(
      "git -C 'C:/o''connor dir/repo' worktree add 'C:/o''connor dir/repo-wt/2026-04-20T09-59' -b 'repo-wt-2026-04-20T09-59'",
    );
    expect(script).toContain(
      "Set-Location 'C:/o''connor dir/repo-wt/2026-04-20T09-59'",
    );
    expect(script).toContain(
      "claude --dangerously-skip-permissions 'Fix the \"auth\" module, don''t break it'",
    );
  });
});

describe("worktree-session-launch Codex script", () => {
  it("orders the Codex steps ensureParentDirectory, git, setLocation, trustCodexProject, poetryInstall, activate, postCodex, codex", () => {
    // Arrange / Act
    const script = decodeShellArgs(
      buildCodexSessionShellArgs(fullCodexCommands),
    );

    // Assert
    expectInOrder(script, [
      fullCodexCommands.ensureParentDirectory,
      fullCodexCommands.git,
      fullCodexCommands.setLocation,
      fullCodexCommands.trustCodexProject,
      fullCodexCommands.poetryInstall ?? "missing poetryInstall",
      fullCodexCommands.activate ?? "missing activate",
      fullCodexCommands.postCodex ?? "missing postCodex",
      fullCodexCommands.codex,
    ]);
  });

  it("omits poetryInstall, activate, and postCodex when they are undefined", () => {
    // Arrange / Act
    const script = buildCodexSessionScript(minimalCodexCommands);

    // Assert
    expect(script).not.toContain("poetry install");
    expect(script).not.toContain("Activate.ps1");
    expect(script).not.toContain("-SourceRoot");
    expect(script).not.toContain("Running post-codex script");
    expect(script).toContain(minimalCodexCommands.trustCodexProject);
    expect(script).toContain("& 'C:/bin/codex.exe'\n");
  });
});
