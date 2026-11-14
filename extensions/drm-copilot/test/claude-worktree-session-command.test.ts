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
  setExecutablePresence,
  setPreClaudeScriptPathConfig,
  setPyprojectFixture,
  showInputBoxMock,
} from "./extension-test-harness";

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

const POETRY_PYPROJECT =
  '[tool.poetry]\nname = "drm-copilot"\nversion = "0.1.0"\n';
const CLAUDE_WITH_OBJECTIVE =
  "claude --dangerously-skip-permissions 'Refactor the auth module.'";

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
 * Decodes the `-EncodedCommand` argument of the captured terminal in memory.
 *
 * @returns The decoded session script.
 */
function decodedScript(): string {
  const encoded = capturedTerminalOptions().shellArgs[3] ?? "";
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
 * Activates the extension and runs the Claude worktree session handler.
 *
 * @returns A promise that settles when the handler settles.
 */
async function runClaudeHandler(): Promise<void> {
  const handler = activateAndGetHandler(
    "drmCopilotExtension.newClaudeWorktreeSession",
  );
  await handler();
}

describe("newClaudeWorktreeSession", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("newClaudeWorktreeSession creates one hidden terminal and never calls sendText", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newClaudeWorktreeSession",
    );

    // Act
    await handler();

    // Assert
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
  });

  it("registers newClaudeWorktreeSession", () => {
    activateAndGetHandler("drmCopilotExtension.newClaudeWorktreeSession");
  });

  it("newClaudeWorktreeSession returns early when the objective prompt is cancelled", async () => {
    showInputBoxMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newClaudeWorktreeSession",
    );
    await handler();

    expect(createTerminalMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("newClaudeWorktreeSession surfaces a missing powershell runtime error", async () => {
    setExecutablePresence({ pwsh: false, powershell: false });
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newClaudeWorktreeSession",
    );

    await expect(handler()).rejects.toThrow(
      "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
    );
    expect(createTerminalMock).not.toHaveBeenCalled();
  });

  it("newClaudeWorktreeSession without poetry delivers ensureParentDirectory, git, Set-Location, and claude in one encoded script", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    // Act
    await runClaudeHandler();

    // Assert
    expect(createTerminalMock).toHaveBeenCalledTimes(1);
    const options = capturedTerminalOptions();
    expect(options.name).toMatch(/^Claude: workspace-wt-/);
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shellPath).toBe("pwsh");
    expect(options.hideFromUser).toBe(true);
    const terminal = capturedTerminal();
    expect(terminal.show).toHaveBeenCalledTimes(1);
    const createOrder = createTerminalMock.mock.invocationCallOrder[0] ?? 0;
    const showOrder = terminal.show.mock.invocationCallOrder[0] ?? 0;
    expect(showOrder).toBeGreaterThan(createOrder);
    const script = decodedScript();
    expectInOrder(script, [
      "New-Item -ItemType Directory -Force -Path 'C:/workspace-wt' -ErrorAction Stop | Out-Null",
      "git -C 'C:/workspace' worktree add",
      "Set-Location 'C:/workspace-wt/",
      CLAUDE_WITH_OBJECTIVE,
    ]);
    expect(script).toMatch(/-b 'workspace-wt-\d{4}-\d{2}-\d{2}T\d{2}-\d{2}'/);
    expect(script).not.toContain("poetry install");
  });

  it("newClaudeWorktreeSession with a poetry pyproject emits poetry install --with dev and the activation probe before claude", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPyprojectFixture(POETRY_PYPROJECT);
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    // Act
    await runClaudeHandler();

    // Assert
    expectInOrder(decodedScript(), [
      "Set-Location 'C:/workspace-wt/",
      "poetry install --with dev",
      VENV_ACTIVATE_COMMAND,
      CLAUDE_WITH_OBJECTIVE,
    ]);
  });

  it("newClaudeWorktreeSession ignores a pyproject that does not mention poetry", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPyprojectFixture(
      '[project]\nname = "plain"\nversion = "0.1.0"\nrequires-python = ">=3.13"\n',
    );
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    // Act
    await runClaudeHandler();

    // Assert
    const script = decodedScript();
    expect(script).not.toContain("poetry install");
    expect(script).not.toContain("Activate.ps1");
    expect(script).toContain(CLAUDE_WITH_OBJECTIVE);
  });

  it("newClaudeWorktreeSession omits the objective from the claude command when blank", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("   ");

    // Act
    await runClaudeHandler();

    // Assert
    expect(decodedScript()).toContain(
      "Write-Host '==> Starting claude'\nclaude --dangerously-skip-permissions\n",
    );
  });

  it("newClaudeWorktreeSession applies the default pre-claude script path when the setting is unset", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    // Act
    await runClaudeHandler();

    // Assert
    expectInOrder(decodedScript(), [
      "Set-Location 'C:/workspace-wt/",
      "if (Test-Path -LiteralPath '.claude/hooks/pre-claude-session.ps1') { & '.claude/hooks/pre-claude-session.ps1' }",
      CLAUDE_WITH_OBJECTIVE,
    ]);
  });

  it("newClaudeWorktreeSession emits preClaude after activate and before claude when poetry is present", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPyprojectFixture(POETRY_PYPROJECT);
    setPreClaudeScriptPathConfig("scripts/bootstrap.ps1");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    // Act
    await runClaudeHandler();

    // Assert
    expectInOrder(decodedScript(), [
      "poetry install --with dev",
      VENV_ACTIVATE_COMMAND,
      "if (Test-Path -LiteralPath 'scripts/bootstrap.ps1') { & 'scripts/bootstrap.ps1' }",
      CLAUDE_WITH_OBJECTIVE,
    ]);
  });

  it("newClaudeWorktreeSession emits preClaude after Set-Location and before claude when poetry is absent", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPreClaudeScriptPathConfig("scripts/bootstrap.ps1");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    // Act
    await runClaudeHandler();

    // Assert
    const script = decodedScript();
    expectInOrder(script, [
      "Set-Location 'C:/workspace-wt/",
      "if (Test-Path -LiteralPath 'scripts/bootstrap.ps1') { & 'scripts/bootstrap.ps1' }",
      CLAUDE_WITH_OBJECTIVE,
    ]);
    expect(script).not.toContain("poetry install");
  });

  it("newClaudeWorktreeSession emits no preClaude step when the configured pre-claude path is empty", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    // Act
    await runClaudeHandler();

    // Assert
    const script = decodedScript();
    expect(script).not.toContain("Running pre-claude script");
    expect(script).not.toContain("Test-Path");
    expect(script).toContain(CLAUDE_WITH_OBJECTIVE);
  });

  it("newClaudeWorktreeSession fails before terminal creation when the encoded command exceeds the length limit", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("x".repeat(12000));
    const handler = activateAndGetHandler(
      "drmCopilotExtension.newClaudeWorktreeSession",
    );

    // Act / Assert
    await expect(handler()).rejects.toThrow(/30000-character limit/);
    expect(createTerminalMock).not.toHaveBeenCalled();
  });

  it("newClaudeWorktreeSession logs the session without a deferred-send note", async () => {
    // Arrange
    setExecutablePresence({ pwsh: true, powershell: false });
    setPreClaudeScriptPathConfig("");
    showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

    // Act
    await runClaudeHandler();

    // Assert
    const logLine = appendLineMock.mock.calls
      .map(([line]) => line)
      .find((line) =>
        line.startsWith("[drmCopilotExtension.newClaudeWorktreeSession]"),
      );
    expect(logLine).toBeDefined();
    expect(logLine).toContain("-EncodedCommand");
    expect(logLine).not.toContain("deferred");
  });
});
