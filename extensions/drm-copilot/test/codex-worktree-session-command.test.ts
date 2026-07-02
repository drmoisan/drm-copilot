import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import {
  activateAndGetHandler,
  childProcessMock,
  createTerminalMock,
  resetExtensionHarnessState,
  setCodexExecutablePathConfig,
  setExecutablePresence,
  setPostCodexScriptPathConfig,
  setPyprojectFixture,
  showInputBoxMock,
} from "./extension-test-harness";

const expectedPathResolvedCodexExecutable =
  process.platform === "win32" ? "C:/bin/codex.EXE" : "/bin/codex";

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

  it("sends git, Set-Location, trust, post script, and codex in order", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false, codex: true });
      setPostCodexScriptPathConfig("scripts/post-codex.ps1");
      showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newCodexWorktreeSession",
      );
      await handler();

      expect(createTerminalMock).toHaveBeenCalledTimes(1);
      const [terminalOptions] = createTerminalMock.mock.calls[0] as [
        {
          name: string;
          cwd: string;
          shellPath: string;
          shellArgs: ReadonlyArray<string>;
        },
      ];
      expect(terminalOptions.name).toMatch(/^Codex: workspace-wt-/);
      expect(terminalOptions.cwd).toBe("C:/workspace");
      expect(terminalOptions.shellPath).toBe("pwsh");
      expect(terminalOptions.shellArgs).toEqual(["-NoLogo"]);

      const terminal = createTerminalMock.mock.results[0]?.value as {
        show: jest.Mock;
        sendText: jest.Mock;
      };
      expect(terminal.show).toHaveBeenCalledTimes(1);

      expect(terminal.sendText).toHaveBeenCalledTimes(4);
      const [gitCmd] = terminal.sendText.mock.calls[0] as [string];
      const [setLocationCmd] = terminal.sendText.mock.calls[1] as [string];
      const [trustCmd] = terminal.sendText.mock.calls[2] as [string];
      const [postCmd] = terminal.sendText.mock.calls[3] as [string];
      expect(gitCmd).toContain("git -C 'C:/workspace' worktree add");
      expect(setLocationCmd).toMatch(/^Set-Location '/);
      expect(trustCmd).toContain(
        "$codexConfig = Join-Path $HOME '.codex/config.toml'",
      );
      expect(trustCmd).toContain(
        "Codex project trust entry exists but is not trusted",
      );
      expect(postCmd).toContain(
        "if (Test-Path -LiteralPath 'C:/workspace/scripts/post-codex.ps1') { & 'C:/workspace/scripts/post-codex.ps1'",
      );
      expect(postCmd).toContain("-SourceRoot 'C:/workspace'");
      expect(postCmd).toContain("-WorktreeRoot 'C:/workspace-wt-");

      jest.advanceTimersByTime(5000);

      expect(terminal.sendText).toHaveBeenCalledTimes(5);
      const [codexCmd] = terminal.sendText.mock.calls[4] as [string];
      expect(codexCmd).toBe(
        `& '${expectedPathResolvedCodexExecutable}' 'Start the Codex session.'`,
      );
    } finally {
      jest.useRealTimers();
    }
  });

  it("runs poetry setup before the post script when poetry is configured", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false, codex: true });
      setPyprojectFixture(
        '[tool.poetry]\nname = "drm-copilot"\nversion = "0.1.0"\n',
      );
      setPostCodexScriptPathConfig("scripts/post-codex.ps1");
      showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newCodexWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };
      expect(terminal.sendText).toHaveBeenCalledTimes(6);
      const [poetryInstallCmd] = terminal.sendText.mock.calls[3] as [string];
      const [activateCmd] = terminal.sendText.mock.calls[4] as [string];
      const [postCmd] = terminal.sendText.mock.calls[5] as [string];
      expect(poetryInstallCmd).toBe("poetry install --with dev");
      expect(activateCmd).toBe("& './.venv/Scripts/Activate.ps1'");
      expect(postCmd).toContain(
        "if (Test-Path -LiteralPath 'C:/workspace/scripts/post-codex.ps1') { & 'C:/workspace/scripts/post-codex.ps1'",
      );
      expect(postCmd).toContain("-SourceRoot 'C:/workspace'");
      expect(postCmd).toContain("-WorktreeRoot 'C:/workspace-wt-");

      jest.advanceTimersByTime(5000);

      expect(terminal.sendText).toHaveBeenCalledTimes(7);
      const [codexCmd] = terminal.sendText.mock.calls[6] as [string];
      expect(codexCmd).toBe(
        `& '${expectedPathResolvedCodexExecutable}' 'Start the Codex session.'`,
      );
    } finally {
      jest.useRealTimers();
    }
  });

  it("uses the default post-codex script path when the setting is unset", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false, codex: true });
      showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newCodexWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };
      const [postCmd] = terminal.sendText.mock.calls[3] as [string];
      expect(postCmd).toContain(
        "if (Test-Path -LiteralPath 'C:/workspace/.codex/scripts/post-codex-worktree-session.ps1') { & 'C:/workspace/.codex/scripts/post-codex-worktree-session.ps1'",
      );
      expect(postCmd).toContain("-SourceRoot 'C:/workspace'");
      expect(postCmd).toContain("-WorktreeRoot 'C:/workspace-wt-");
    } finally {
      jest.useRealTimers();
    }
  });

  it("invokes the post-codex script from the source root before deferred codex startup", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false, codex: true });
      setPostCodexScriptPathConfig(
        ".codex/scripts/post-codex-worktree-session.ps1",
      );
      showInputBoxMock.mockResolvedValueOnce("Start the Codex session.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newCodexWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };
      expect(terminal.sendText).toHaveBeenCalledTimes(4);
      const [postCmd] = terminal.sendText.mock.calls[3] as [string];
      expect(postCmd).toContain(
        "Test-Path -LiteralPath 'C:/workspace/.codex/scripts/post-codex-worktree-session.ps1'",
      );
      expect(postCmd).toContain(
        "& 'C:/workspace/.codex/scripts/post-codex-worktree-session.ps1'",
      );
      expect(postCmd).toContain("-SourceRoot 'C:/workspace'");
      expect(postCmd).toContain("-WorktreeRoot 'C:/workspace-wt-");

      jest.advanceTimersByTime(5000);

      expect(terminal.sendText).toHaveBeenCalledTimes(5);
    } finally {
      jest.useRealTimers();
    }
  });

  it("omits the post script and objective when both are blank", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false, codex: true });
      setPostCodexScriptPathConfig("");
      showInputBoxMock.mockResolvedValueOnce("   ");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newCodexWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };
      expect(terminal.sendText).toHaveBeenCalledTimes(3);

      jest.advanceTimersByTime(5000);

      expect(terminal.sendText).toHaveBeenCalledTimes(4);
      const [codexCmd] = terminal.sendText.mock.calls[3] as [string];
      expect(codexCmd).toBe(`& '${expectedPathResolvedCodexExecutable}'`);
    } finally {
      jest.useRealTimers();
    }
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
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false, codex: true });
      setCodexExecutablePathConfig("C:/Tools/Codex/codex.exe");
      showInputBoxMock.mockResolvedValueOnce("Implement issue 268");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newCodexWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };
      jest.advanceTimersByTime(5000);

      const [codexCmd] = terminal.sendText.mock.calls[
        terminal.sendText.mock.calls.length - 1
      ] as [string];
      expect(codexCmd).toBe(
        "& 'C:/Tools/Codex/codex.exe' 'Implement issue 268'",
      );
    } finally {
      jest.useRealTimers();
    }
  });
});
