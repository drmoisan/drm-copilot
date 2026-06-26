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
  createMockProcess,
  createTerminalMock,
  registerMcpServerDefinitionProviderMock,
  resetExtensionHarnessState,
  setExecutablePresence,
  setPreClaudeScriptPathConfig,
  setPyprojectFixture,
  setWorkspaceFolders,
  showInputBoxMock,
  showQuickPickMock,
} from "./extension-test-harness";

describe("drm-copilot workflow command behavior", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers collectCommitContext", () => {
    activateAndGetHandler("drmCopilotExtension.collectCommitContext");
  });

  it("registers collectPrContext", () => {
    activateAndGetHandler("drmCopilotExtension.collectPrContext");
  });

  it("registers pushDownCopilotCustomizations", () => {
    activateAndGetHandler("drmCopilotExtension.pushDownCopilotCustomizations");
  });

  it("registers pushDownCodexAndAgentsCustomizations", () => {
    activateAndGetHandler(
      "drmCopilotExtension.pushDownCodexAndAgentsCustomizations",
    );
  });

  it("activate registers drmCopilotExtension.syncAgentsFromInstructions", () => {
    activateAndGetHandler("drmCopilotExtension.syncAgentsFromInstructions");
  });

  it("runCodexNativeConverter review mode passes the selected prompt values to the bundled service", async () => {
    setExecutablePresence({ python: true });
    showQuickPickMock
      .mockResolvedValueOnce("review")
      .mockResolvedValueOnce("github-copilot")
      .mockResolvedValueOnce("Yes");
    showInputBoxMock.mockResolvedValueOnce("C:/source-runtime");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runCodexNativeConverter",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/codex_native_converter.py",
    );
    expect(args).toContain("review");
    expect(args).toContain("--source-root");
    expect(args).toContain("C:/source-runtime");
    expect(args).toContain("--source-ecosystem");
    expect(args).toContain("github-copilot");
    expect(args).toContain("--enable-repo-prompts");
    expect(args).not.toContain("--destination-root");
  });

  it("runCodexNativeConverter apply mode returns early when the destination root is blank", async () => {
    showQuickPickMock
      .mockResolvedValueOnce("apply")
      .mockResolvedValueOnce("claude");
    showInputBoxMock
      .mockResolvedValueOnce("C:/source-runtime")
      .mockResolvedValueOnce("   ");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runCodexNativeConverter",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("syncAgentsFromInstructions runs the bundled PowerShell script with the workspace root", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.syncAgentsFromInstructions",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain(
      "C:/extension/resources/templates/sync-agents-from-instructions.ps1",
    );
    expect(args).toContain("-RepoRoot");
    expect(args).toContain("C:/workspace");
  });

  it("registers newPotentialBugEntry", () => {
    activateAndGetHandler("drmCopilotExtension.newPotentialBugEntry");
  });

  it("registers newPotentialEntry", () => {
    activateAndGetHandler("drmCopilotExtension.newPotentialEntry");
  });

  it("registers linkParentChild", () => {
    activateAndGetHandler("drmCopilotExtension.linkParentChild");
  });

  it("registers newClaudeWorktreeSession", () => {
    activateAndGetHandler("drmCopilotExtension.newClaudeWorktreeSession");
  });

  it("activate registers the MCP server definition provider", () => {
    activateAndGetHandler("drmCopilotExtension.helloPython");

    expect(registerMcpServerDefinitionProviderMock).toHaveBeenCalledWith(
      "drmCopilotMcpProvider",
      expect.objectContaining({
        onDidChangeMcpServerDefinitions: expect.any(Function),
        provideMcpServerDefinitions: expect.any(Function),
        resolveMcpServerDefinition: expect.any(Function),
      }),
    );
  });

  it("collectCommitContext fails when no workspace folder is open", async () => {
    setWorkspaceFolders(undefined);
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow("No workspace folder is open.");
  });

  // NOTE: The in-process `collectCommitContext` behavioral cases (no python
  // runtime required, in-process artifact write, workspace cwd, mandatory git
  // failure, stderr detail) live in
  // `extension.collect-commit-context-inprocess.test.ts`. They were moved out
  // of this file (which already exceeds the 500-line limit) when F4 ported the
  // command to the in-process TS path, to avoid growing this file further.

  it("newPotentialBugEntry passes the bundled script path and short-name args", async () => {
    setExecutablePresence({ python: true });
    showInputBoxMock.mockResolvedValue("blank-pr-context");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/new_potential_bug_entry.py",
    );
    expect(args[1]).toBe("--short-name");
    expect(args[2]).toBe("blank-pr-context");
  });

  it("newPotentialBugEntry direct --short-name invocation skips prompts", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler(["--short-name", "blank-pr-context"]);

    expect(showInputBoxMock).not.toHaveBeenCalled();
    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[1]).toBe("--short-name");
    expect(args[2]).toBe("blank-pr-context");
  });

  it("newPotentialBugEntry direct mode rejects invalid short-name pattern", async () => {
    setExecutablePresence({ python: true });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );

    await expect(handler(["--short-name", "Invalid Name"])).rejects.toThrow(
      /short-name/i,
    );
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("newPotentialBugEntry returns early when the input box is cancelled", async () => {
    showInputBoxMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("newPotentialBugEntry surfaces a missing python runtime error", async () => {
    setExecutablePresence({ python: false });
    showInputBoxMock.mockResolvedValue("blank-pr-context");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );

    await expect(handler()).rejects.toThrow(
      "Python runtime 'python' not found on PATH.",
    );
  });

  it("newPotentialBugEntry surfaces non-zero exit failures", async () => {
    setExecutablePresence({ python: true });
    showInputBoxMock.mockResolvedValue("blank-pr-context");
    childProcessMock.spawn.mockReturnValue(createMockProcess(2));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );

    await expect(handler()).rejects.toThrow("Command exited with code 2");
  });

  it("newPotentialEntry passes the bundled script path and short-name args", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    showInputBoxMock.mockResolvedValue("stale-cache");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialEntry",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain(
      "C:/extension/resources/templates/new-potential-entry.ps1",
    );
    expect(args).toContain("-ShortName");
    expect(args).toContain("stale-cache");
  });

  it("newPotentialEntry direct -ShortName invocation skips prompts", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialEntry",
    );
    await handler(["-ShortName", "stale-cache"]);

    expect(showInputBoxMock).not.toHaveBeenCalled();
    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain("-ShortName");
    expect(args).toContain("stale-cache");
  });

  it("newPotentialEntry direct mode rejects missing -ShortName value", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialEntry",
    );

    await expect(handler(["-ShortName"])).rejects.toThrow(/-ShortName.*value/i);
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("newPotentialEntry direct mode rejects duplicate -ShortName flag", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialEntry",
    );

    await expect(
      handler(["-ShortName", "first-entry", "-ShortName", "second-entry"]),
    ).rejects.toThrow(/duplicate.*-ShortName/i);
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("newPotentialEntry returns early when the input box is cancelled", async () => {
    showInputBoxMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialEntry",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("newPotentialEntry surfaces a missing powershell runtime error", async () => {
    setExecutablePresence({ pwsh: false, powershell: false });
    showInputBoxMock.mockResolvedValue("stale-cache");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialEntry",
    );

    await expect(handler()).rejects.toThrow(
      "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
    );
  });

  it("newPotentialEntry surfaces non-zero exit failures", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    showInputBoxMock.mockResolvedValue("stale-cache");
    childProcessMock.spawn.mockReturnValue(createMockProcess(2));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialEntry",
    );

    await expect(handler()).rejects.toThrow("Command exited with code 2");
  });

  it("newClaudeWorktreeSession without poetry sends git, Set-Location, and claude as separate sendText calls in order", async () => {
    // The handler sends each step as its own sendText call so each appears
    // on its own PowerShell prompt. With no poetry-flavored pyproject.toml
    // present, only git and Set-Location fire synchronously; the claude
    // call is deferred behind a grace period so VS Code's Python extension
    // auto-activation can land at the host shell's prompt instead of being
    // typed into claude's TUI.
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      // No setPyprojectFixture call here means the workspace has no
      // pyproject.toml, so usePoetry resolves to false.
      // Empty pre-claude path so this test isolates git/Set-Location/claude
      // ordering without an additional preClaude send.
      setPreClaudeScriptPathConfig("");
      showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      expect(showInputBoxMock).toHaveBeenCalledTimes(1);
      expect(createTerminalMock).toHaveBeenCalledTimes(1);
      const [terminalOptions] = createTerminalMock.mock.calls[0] as [
        {
          name: string;
          cwd: string;
          shellPath: string;
          shellArgs: ReadonlyArray<string>;
        },
      ];
      expect(terminalOptions.name).toMatch(/^Claude: workspace-wt-/);
      // The terminal must launch inside the source repository so `git worktree
      // add` can find `.git`. The workspace fixture is "C:/workspace".
      expect(terminalOptions.cwd).toBe("C:/workspace");
      expect(terminalOptions.shellPath).toBe("pwsh");
      expect(terminalOptions.shellArgs).toEqual(["-NoLogo"]);

      const terminal = createTerminalMock.mock.results[0]?.value as {
        show: jest.Mock;
        sendText: jest.Mock;
      };
      expect(terminal.show).toHaveBeenCalledTimes(1);

      // No poetry => exactly two pre-claude sendText calls: git, Set-Location.
      expect(terminal.sendText).toHaveBeenCalledTimes(2);
      const [gitCmd, gitNewline] = terminal.sendText.mock.calls[0] as [
        string,
        boolean,
      ];
      const [setLocationCmd, setLocationNewline] = terminal.sendText.mock
        .calls[1] as [string, boolean];
      expect(gitNewline).toBe(true);
      expect(setLocationNewline).toBe(true);
      // The git command uses `git -C <repoRoot>` so it works regardless of
      // the terminal's actual current working directory at launch time.
      expect(gitCmd).toContain("git -C 'C:/workspace' worktree add");
      expect(gitCmd).toMatch(
        /-b 'workspace-wt-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}'$/,
      );
      expect(setLocationCmd).toMatch(
        /^Set-Location 'C:\/workspace-wt-\d{4}-\d{2}-\d{2}-\d{2}-\d{2}'$/,
      );

      // The deferred claude sendText fires after the grace period.
      jest.advanceTimersByTime(5000);

      expect(terminal.sendText).toHaveBeenCalledTimes(3);
      const [claudeCmd, claudeNewline] = terminal.sendText.mock.calls[2] as [
        string,
        boolean,
      ];
      expect(claudeNewline).toBe(true);
      expect(claudeCmd).toBe(
        "claude --dangerously-skip-permissions 'Refactor the auth module.'",
      );
    } finally {
      jest.useRealTimers();
    }
  });

  it("newClaudeWorktreeSession with a poetry pyproject sends poetry install --with dev and activates before claude", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      setPyprojectFixture(
        '[tool.poetry]\nname = "drm-copilot"\nversion = "0.1.0"\n',
      );
      // Empty pre-claude path so this test isolates the poetry install and
      // activate ordering without an additional preClaude send.
      setPreClaudeScriptPathConfig("");
      showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      expect(createTerminalMock).toHaveBeenCalledTimes(1);
      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };

      // With poetry: four pre-claude sendText calls (git, Set-Location,
      // poetry install, activate), then the deferred claude.
      expect(terminal.sendText).toHaveBeenCalledTimes(4);
      const [gitCmd] = terminal.sendText.mock.calls[0] as [string];
      const [setLocationCmd] = terminal.sendText.mock.calls[1] as [string];
      const [poetryInstallCmd] = terminal.sendText.mock.calls[2] as [string];
      const [activateCmd] = terminal.sendText.mock.calls[3] as [string];
      expect(gitCmd).toContain("git -C 'C:/workspace' worktree add");
      expect(setLocationCmd).toMatch(/^Set-Location '/);
      expect(poetryInstallCmd).toBe("poetry install --with dev");
      expect(activateCmd).toBe("& './.venv/Scripts/Activate.ps1'");

      jest.advanceTimersByTime(5000);

      expect(terminal.sendText).toHaveBeenCalledTimes(5);
      const [claudeCmd] = terminal.sendText.mock.calls[4] as [string];
      expect(claudeCmd).toBe(
        "claude --dangerously-skip-permissions 'Refactor the auth module.'",
      );
    } finally {
      jest.useRealTimers();
    }
  });

  it("newClaudeWorktreeSession ignores a pyproject that does not mention poetry", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      setPyprojectFixture(
        '[project]\nname = "plain"\nversion = "0.1.0"\nrequires-python = ">=3.13"\n',
      );
      // Empty pre-claude path so this test isolates the no-poetry behavior
      // without an additional preClaude send.
      setPreClaudeScriptPathConfig("");
      showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };

      // Pyproject exists but does not mention poetry => no install/activate.
      expect(terminal.sendText).toHaveBeenCalledTimes(2);
      jest.advanceTimersByTime(5000);
      expect(terminal.sendText).toHaveBeenCalledTimes(3);
    } finally {
      jest.useRealTimers();
    }
  });

  it("newClaudeWorktreeSession omits the objective from the claude command when blank", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      // Empty pre-claude path so this test isolates the blank-objective claude
      // command without an additional preClaude send.
      setPreClaudeScriptPathConfig("");
      showInputBoxMock.mockResolvedValueOnce("   ");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      expect(createTerminalMock).toHaveBeenCalledTimes(1);
      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };

      jest.advanceTimersByTime(5000);

      // Three sendText calls: git, Set-Location, claude (no poetry).
      expect(terminal.sendText).toHaveBeenCalledTimes(3);
      const [claudeCmd] = terminal.sendText.mock.calls[2] as [string];
      expect(claudeCmd).toBe("claude --dangerously-skip-permissions");
    } finally {
      jest.useRealTimers();
    }
  });

  it("newClaudeWorktreeSession defers the claude sendText behind a grace period so the Python extension's auto-activation cannot collide with claude's TUI input", async () => {
    // Regression guard: if the deferral is accidentally removed, the claude
    // sendText would fire synchronously and the test catches it.
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      // Empty pre-claude path so this deferral guard isolates the git +
      // Set-Location synchronous sends without an additional preClaude send.
      setPreClaudeScriptPathConfig("");
      showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };

      // Immediately after the handler resolves the pre-claude commands have
      // fired (git + Set-Location, no poetry), but claude has not.
      expect(terminal.sendText).toHaveBeenCalledTimes(2);

      // Even after most of the grace window elapses, the timer has not fired.
      jest.advanceTimersByTime(4999);
      expect(terminal.sendText).toHaveBeenCalledTimes(2);

      // At the configured grace boundary, the claude sendText fires.
      jest.advanceTimersByTime(1);
      expect(terminal.sendText).toHaveBeenCalledTimes(3);
      const [claudeCmd] = terminal.sendText.mock.calls[2] as [string];
      expect(claudeCmd).toContain("claude --dangerously-skip-permissions");
    } finally {
      jest.useRealTimers();
    }
  });

  it("newClaudeWorktreeSession applies the default pre-claude script path when the setting is unset", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      // No setPreClaudeScriptPathConfig call: the setting is unset, so the
      // handler applies its TypeScript-side default.
      showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };

      // No poetry => synchronous order is git, Set-Location, preClaude.
      expect(terminal.sendText).toHaveBeenCalledTimes(3);
      const [preClaudeCmd, preClaudeNewline] = terminal.sendText.mock
        .calls[2] as [string, boolean];
      expect(preClaudeNewline).toBe(true);
      expect(preClaudeCmd).toBe(
        "if (Test-Path -LiteralPath '.claude/hooks/pre-claude-session.ps1') { & '.claude/hooks/pre-claude-session.ps1' }",
      );

      jest.advanceTimersByTime(5000);
      expect(terminal.sendText).toHaveBeenCalledTimes(4);
    } finally {
      jest.useRealTimers();
    }
  });

  it("newClaudeWorktreeSession sends preClaude immediately after activate and before the deferred claude when poetry is present", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      setPyprojectFixture(
        '[tool.poetry]\nname = "drm-copilot"\nversion = "0.1.0"\n',
      );
      setPreClaudeScriptPathConfig("scripts/bootstrap.ps1");
      showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };

      // Synchronous order: git, Set-Location, poetry install, activate,
      // preClaude (five calls). claude is deferred.
      expect(terminal.sendText).toHaveBeenCalledTimes(5);
      const [poetryInstallCmd] = terminal.sendText.mock.calls[2] as [string];
      const [activateCmd] = terminal.sendText.mock.calls[3] as [string];
      const [preClaudeCmd] = terminal.sendText.mock.calls[4] as [string];
      expect(poetryInstallCmd).toBe("poetry install --with dev");
      expect(activateCmd).toBe("& './.venv/Scripts/Activate.ps1'");
      expect(preClaudeCmd).toBe(
        "if (Test-Path -LiteralPath 'scripts/bootstrap.ps1') { & 'scripts/bootstrap.ps1' }",
      );

      jest.advanceTimersByTime(5000);

      // claude is the last call.
      expect(terminal.sendText).toHaveBeenCalledTimes(6);
      const [claudeCmd] = terminal.sendText.mock.calls[5] as [string];
      expect(claudeCmd).toBe(
        "claude --dangerously-skip-permissions 'Refactor the auth module.'",
      );
    } finally {
      jest.useRealTimers();
    }
  });

  it("newClaudeWorktreeSession sends preClaude after Set-Location and before the deferred claude when poetry is absent", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      // No pyproject fixture => no poetry.
      setPreClaudeScriptPathConfig("scripts/bootstrap.ps1");
      showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };

      // Synchronous order: git, Set-Location, preClaude (three calls).
      expect(terminal.sendText).toHaveBeenCalledTimes(3);
      const [setLocationCmd] = terminal.sendText.mock.calls[1] as [string];
      const [preClaudeCmd] = terminal.sendText.mock.calls[2] as [string];
      expect(setLocationCmd).toMatch(/^Set-Location '/);
      expect(preClaudeCmd).toBe(
        "if (Test-Path -LiteralPath 'scripts/bootstrap.ps1') { & 'scripts/bootstrap.ps1' }",
      );

      jest.advanceTimersByTime(5000);

      expect(terminal.sendText).toHaveBeenCalledTimes(4);
      const [claudeCmd] = terminal.sendText.mock.calls[3] as [string];
      expect(claudeCmd).toBe(
        "claude --dangerously-skip-permissions 'Refactor the auth module.'",
      );
    } finally {
      jest.useRealTimers();
    }
  });

  it("newClaudeWorktreeSession sends no extra command when the configured pre-claude path is empty", async () => {
    jest.useFakeTimers();
    try {
      setExecutablePresence({ pwsh: true, powershell: false });
      // Empty configured path => builder yields preClaude === undefined.
      setPreClaudeScriptPathConfig("");
      showInputBoxMock.mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      const terminal = createTerminalMock.mock.results[0]?.value as {
        sendText: jest.Mock;
      };

      // No poetry, no preClaude => only git and Set-Location synchronously.
      expect(terminal.sendText).toHaveBeenCalledTimes(2);

      jest.advanceTimersByTime(5000);

      // Only the deferred claude send is added; no preClaude send.
      expect(terminal.sendText).toHaveBeenCalledTimes(3);
      const [claudeCmd] = terminal.sendText.mock.calls[2] as [string];
      expect(claudeCmd).toContain("claude --dangerously-skip-permissions");
    } finally {
      jest.useRealTimers();
    }
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

  it("linkParentChild prompts for both issue numbers and runs the bundled script", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    showInputBoxMock.mockResolvedValueOnce("12").mockResolvedValueOnce("34");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.linkParentChild",
    );
    await handler();

    expect(showInputBoxMock).toHaveBeenCalledTimes(2);
    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain(
      "C:/extension/resources/templates/link-parent-child.ps1",
    );
    expect(args).toContain("-ChildIssueNumber");
    expect(args).toContain("12");
    expect(args).toContain("-ParentIssueNumber");
    expect(args).toContain("34");
  });

  it("linkParentChild direct invocation skips prompts", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.linkParentChild",
    );
    await handler(["-ChildIssueNumber", "12", "-ParentIssueNumber", "34"]);

    expect(showInputBoxMock).not.toHaveBeenCalled();
    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain("-ChildIssueNumber");
    expect(args).toContain("12");
    expect(args).toContain("-ParentIssueNumber");
    expect(args).toContain("34");
  });

  it("linkParentChild direct mode rejects non-digit issue numbers", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.linkParentChild",
    );

    await expect(
      handler(["-ChildIssueNumber", "child-12", "-ParentIssueNumber", "34"]),
    ).rejects.toThrow(/ChildIssueNumber.*digits only/i);
    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("linkParentChild returns early when the child issue prompt is cancelled", async () => {
    showInputBoxMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.linkParentChild",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("linkParentChild returns early when the parent issue prompt is cancelled", async () => {
    showInputBoxMock
      .mockResolvedValueOnce("12")
      .mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.linkParentChild",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("linkParentChild surfaces a missing powershell runtime error", async () => {
    setExecutablePresence({ pwsh: false, powershell: false });
    showInputBoxMock.mockResolvedValueOnce("12").mockResolvedValueOnce("34");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.linkParentChild",
    );

    await expect(handler()).rejects.toThrow(
      "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
    );
  });

  it("newPotentialBugEntry passes --template-root pointing to bundled feature-templates", async () => {
    setExecutablePresence({ python: true });
    showInputBoxMock.mockResolvedValue("test-bug");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialBugEntry",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const templateRootIdx = args.indexOf("--template-root");
    expect(templateRootIdx).toBeGreaterThan(-1);
    expect(args[templateRootIdx + 1]).toContain("resources/feature-templates");
  });

  it("newPotentialEntry passes -TemplateRoot pointing to bundled feature-templates", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    showInputBoxMock.mockResolvedValue("test-entry");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newPotentialEntry",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const templateRootIdx = args.indexOf("-TemplateRoot");
    expect(templateRootIdx).toBeGreaterThan(-1);
    expect(args[templateRootIdx + 1]).toContain("resources/feature-templates");
  });

  it("newActiveFeatureFolder passes --template-root pointing to bundled feature-templates", async () => {
    setExecutablePresence({ python: true });
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("minor-audit");
    showInputBoxMock
      .mockResolvedValueOnce("test-feature")
      .mockResolvedValueOnce("");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const templateRootIdx = args.indexOf("--template-root");
    expect(templateRootIdx).toBeGreaterThan(-1);
    expect(args[templateRootIdx + 1]).toContain("resources/feature-templates");
  });
});
