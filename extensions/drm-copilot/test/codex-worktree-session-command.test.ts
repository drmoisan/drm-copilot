import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import { VENV_ACTIVATE_COMMAND } from "../src/claude-worktree-session";
import {
  activateAndGetHandler,
  appendLineMock,
  childProcessMock,
  createTerminalMock,
  resetExtensionHarnessState,
  setCodexExecutablePathConfig,
  setExecutablePresence,
  setInstalledCodexExtensionRoots,
  setPostCodexScriptPathConfig,
  setPyprojectFixture,
  showInputBoxMock,
} from "./extension-test-harness";

const expectedPathResolvedCodexExecutable =
  process.platform === "win32" ? "C:/bin/codex.EXE" : "C/codex";

/** Terminal options captured from the single createTerminal call. */
interface CapturedTerminalOptions {
  readonly name: string;
  readonly cwd: string;
  readonly shellPath: string;
  readonly shellArgs: ReadonlyArray<string>;
  readonly hideFromUser?: boolean;
}

/** Shape of the mock terminal returned by the harness createTerminal mock. */
interface CapturedTerminal {
  readonly show: jest.Mock;
  readonly sendText: jest.Mock;
}

/**
 * Reads the options passed to the first createTerminal call.
 *
 * @returns The captured terminal options.
 */
function capturedTerminalOptions(): CapturedTerminalOptions {
  const [options] = createTerminalMock.mock.calls[0] as [
    CapturedTerminalOptions,
  ];
  return options;
}

/**
 * Reads the mock terminal returned by the first createTerminal call.
 *
 * @returns The captured mock terminal.
 */
function capturedTerminal(): CapturedTerminal {
  return createTerminalMock.mock.results[0]?.value as CapturedTerminal;
}

/**
 * Asserts the single hidden terminal, the encoded shellArgs order, one show
 * call, and no sendText call, then decodes the session script in memory.
 *
 * @returns The decoded session script.
 */
function expectEncodedSessionTerminal(): string {
  expect(createTerminalMock).toHaveBeenCalledTimes(1);
  const options = capturedTerminalOptions();
  expect(options.hideFromUser).toBe(true);
  expect(options.shellArgs).toHaveLength(4);
  expect(options.shellArgs.slice(0, 3)).toEqual([
    "-NoLogo",
    "-NoExit",
    "-EncodedCommand",
  ]);
  const terminal = capturedTerminal();
  expect(terminal.show).toHaveBeenCalledTimes(1);
  expect(terminal.sendText).not.toHaveBeenCalled();
  const encoded = options.shellArgs[3] ?? "";
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

describe("newCodexWorktreeSession", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers the command", () => {
    activateAndGetHandler("drmCopilotExtension.newCodexWorktreeSession");
  });

  it("delivers ensureParentDirectory, git, Set-Location, trust, post script, and codex in one encoded script", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false, codex: true });
    setPostCodexScriptPathConfig("scripts/post-codex.ps1");
    showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    const script = expectEncodedSessionTerminal();
    const options = capturedTerminalOptions();
    expect(options.name).toMatch(/^Codex: workspace-wt-/);
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shellPath).toBe("pwsh");
    expectInOrder(script, [
      "New-Item -ItemType Directory -Force -Path 'C:/workspace-wt' -ErrorAction Stop | Out-Null",
      "git -C 'C:/workspace' worktree add",
      "Set-Location 'C:/workspace-wt/",
      "$codexConfig = Join-Path $HOME '.codex/config.toml'",
      "Codex project trust entry exists but is not trusted",
      "if (Test-Path -LiteralPath 'C:/workspace/scripts/post-codex.ps1') { & 'C:/workspace/scripts/post-codex.ps1'",
      "-SourceRoot 'C:/workspace'",
      "-WorktreeRoot 'C:/workspace-wt/",
      `& '${expectedPathResolvedCodexExecutable}' 'Start the Codex session.'`,
    ]);
    expect(script).not.toMatch(/^codex(?:\s|$)/m);
  });

  it("runs poetry setup before the post script when poetry is configured", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false, codex: true });
    setPyprojectFixture(
      '[tool.poetry]\nname = "drm-copilot"\nversion = "0.1.0"\n',
    );
    setPostCodexScriptPathConfig("scripts/post-codex.ps1");
    showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    const script = expectEncodedSessionTerminal();
    expectInOrder(script, [
      "$codexConfig = Join-Path $HOME '.codex/config.toml'",
      "poetry install --with dev",
      VENV_ACTIVATE_COMMAND,
      "if (Test-Path -LiteralPath 'C:/workspace/scripts/post-codex.ps1') { & 'C:/workspace/scripts/post-codex.ps1'",
      `& '${expectedPathResolvedCodexExecutable}' 'Start the Codex session.'`,
    ]);
  });

  it("uses the default post-codex script path when the setting is unset", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false, codex: true });
    showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    const script = expectEncodedSessionTerminal();
    expect(script).toContain(
      "if (Test-Path -LiteralPath 'C:/workspace/.codex/scripts/post-codex-worktree-session.ps1') { & 'C:/workspace/.codex/scripts/post-codex-worktree-session.ps1'",
    );
    expect(script).toContain("-SourceRoot 'C:/workspace'");
    expect(script).toContain("-WorktreeRoot 'C:/workspace-wt/");
  });

  it("invokes the post-codex script from the source root before the codex launch", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false, codex: true });
    setPostCodexScriptPathConfig(
      ".codex/scripts/post-codex-worktree-session.ps1",
    );
    showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    const script = expectEncodedSessionTerminal();
    expectInOrder(script, [
      "Test-Path -LiteralPath 'C:/workspace/.codex/scripts/post-codex-worktree-session.ps1'",
      "& 'C:/workspace/.codex/scripts/post-codex-worktree-session.ps1'",
      "-SourceRoot 'C:/workspace'",
      "-WorktreeRoot 'C:/workspace-wt/",
      "Write-Host '==> Starting codex'",
      `& '${expectedPathResolvedCodexExecutable}' 'Start the Codex session.'`,
    ]);
  });

  it("omits the post script and objective when both are blank", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false, codex: true });
    setPostCodexScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("   ");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    const script = expectEncodedSessionTerminal();
    expect(script).not.toContain("Running post-codex script");
    expect(script).not.toContain("-SourceRoot");
    expect(script).toContain(
      `Write-Host '==> Starting codex'\n& '${expectedPathResolvedCodexExecutable}'\n`,
    );
  });

  it("returns early when the objective prompt is cancelled", async () => {
    showInputBoxMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );
    await handler();

    expect(createTerminalMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("surfaces a missing powershell runtime error", async () => {
    setExecutablePresence({ pwsh: false, powershell: false });
    showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    await expect(handler()).rejects.toThrow(
      "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
    );
    expect(createTerminalMock).not.toHaveBeenCalled();
  });

  it("fails before terminal creation when the codex cli cannot be resolved", async () => {
    setExecutablePresence({ pwsh: true, powershell: false, codex: false });
    showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    await expect(handler()).rejects.toThrow(
      "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
    );
    expect(createTerminalMock).not.toHaveBeenCalled();
  });

  it("uses the configured codex executable path when present", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false, codex: true });
    setCodexExecutablePathConfig("C:/Tools/Codex/codex.exe");
    showInputBoxMock.mockResolvedValueOnce("Implement issue 268");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    const script = expectEncodedSessionTerminal();
    expect(script).toContain(
      "Write-Host '==> Starting codex'\n& 'C:/Tools/Codex/codex.exe' 'Implement issue 268'\n",
    );
  });

  it("launches installed extension package codex through PowerShell call operator", async () => {
    // Arrange
    const installedExtensionCodexExecutable =
      process.platform === "win32"
        ? "C:/extensions/openai.chatgpt/bin/windows-x86_64/codex.EXE"
        : "C:/extensions/openai.chatgpt/bin/codex";
    setExecutablePresence({
      pwsh: true,
      powershell: false,
      codex: false,
      [installedExtensionCodexExecutable]: true,
    });
    setInstalledCodexExtensionRoots(["C:/extensions/openai.chatgpt"]);
    showInputBoxMock.mockResolvedValueOnce("Implement issue 306");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    const script = expectEncodedSessionTerminal();
    expect(script).toContain(
      `Write-Host '==> Starting codex'\n& '${installedExtensionCodexExecutable}' 'Implement issue 306'\n`,
    );
  });

  it("fails before terminal creation when installed extension package codex is absent", async () => {
    setExecutablePresence({ pwsh: true, powershell: false, codex: false });
    setInstalledCodexExtensionRoots([]);
    showInputBoxMock.mockResolvedValueOnce("Implement issue 306");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    await expect(handler()).rejects.toThrow(
      "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
    );
    expect(createTerminalMock).not.toHaveBeenCalled();
  });

  it("fails before terminal creation when the encoded command exceeds the length limit", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false, codex: true });
    showInputBoxMock.mockResolvedValueOnce("x".repeat(12000));
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act / Assert
    await expect(handler()).rejects.toThrow(/30000-character limit/);
    expect(createTerminalMock).not.toHaveBeenCalled();
  });

  it("logs the session without a deferred-send note", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false, codex: true });
    showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newCodexWorktreeSession",
    );

    // Act
    await handler();

    // Assert
    const logLine = appendLineMock.mock.calls
      .map(([line]) => line)
      .find((line) =>
        line.startsWith("[drmCopilotExtension.newCodexWorktreeSession]"),
      );
    expect(logLine).toBeDefined();
    expect(logLine).toContain("-EncodedCommand");
    expect(logLine).not.toContain("deferred");
  });
});
