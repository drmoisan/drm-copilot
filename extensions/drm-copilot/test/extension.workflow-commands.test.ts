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
  appendLineMock,
  childProcessMock,
  createMockProcess,
  createMockProcessWithStderr,
  createTerminalMock,
  registerMcpServerDefinitionProviderMock,
  resetExtensionHarnessState,
  setExecutablePresence,
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

  it("collectCommitContext fails when python runtime is unavailable", async () => {
    setExecutablePresence({ python: false });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow(
      "Python runtime 'python' not found on PATH.",
    );
  });

  it("collectCommitContext passes explicit output args to bundled script", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/collect_commit_context.py",
    );
    expect(args[1]).toBe("--output");
    expect(args[2]).toBe("artifacts/commit_context.txt");
  });

  it("collectCommitContext runs with workspace cwd", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await handler();

    const [, , options] = childProcessMock.spawn.mock.calls[0] as [
      string,
      string[],
      { cwd: string; shell: boolean },
    ];
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shell).toBe(false);
  });

  it("collectCommitContext logs and throws on non-zero exit", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(2));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow("Command exited with code 2");

    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) =>
        line.includes(
          "[drmCopilotExtension.collectCommitContext] command failure",
        ),
      ),
    ).toBe(true);
  });

  it("collectCommitContext reports git failure details from collector stderr", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(
      createMockProcessWithStderr(1, "git executable not found on PATH"),
    );

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow("Command exited with code 1");

    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) => line.includes("git executable not found on PATH")),
    ).toBe(true);
  });

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
      showInputBoxMock
        .mockResolvedValueOnce("auth-refactor")
        .mockResolvedValueOnce("Refactor the auth module.");

      const handler = activateAndGetHandler(
        "drmCopilotExtension.newClaudeWorktreeSession",
      );
      await handler();

      expect(showInputBoxMock).toHaveBeenCalledTimes(2);
      expect(createTerminalMock).toHaveBeenCalledTimes(1);
      const [terminalOptions] = createTerminalMock.mock.calls[0] as [
        {
          name: string;
          cwd: string;
          shellPath: string;
          shellArgs: ReadonlyArray<string>;
        },
      ];
      expect(terminalOptions.name).toMatch(
        /^Claude: feature\/.*-auth-refactor$/,
      );
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
      expect(gitCmd).toMatch(/-b 'feature\/[0-9]{14}-auth-refactor'$/);
      expect(setLocationCmd).toMatch(
        /^Set-Location 'C:\/drm-copilot-wt-[0-9]{14}-auth-refactor'$/,
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
      showInputBoxMock
        .mockResolvedValueOnce("auth-refactor")
        .mockResolvedValueOnce("Refactor the auth module.");

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
      showInputBoxMock
        .mockResolvedValueOnce("auth-refactor")
        .mockResolvedValueOnce("Refactor the auth module.");

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
      showInputBoxMock
        .mockResolvedValueOnce("auth-refactor")
        .mockResolvedValueOnce("   ");

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
      showInputBoxMock
        .mockResolvedValueOnce("auth-refactor")
        .mockResolvedValueOnce("Refactor the auth module.");

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

  it("newClaudeWorktreeSession returns early when the short-name prompt is cancelled", async () => {
    showInputBoxMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newClaudeWorktreeSession",
    );
    await handler();

    expect(createTerminalMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("newClaudeWorktreeSession returns early when the objective prompt is cancelled", async () => {
    showInputBoxMock
      .mockResolvedValueOnce("auth-refactor")
      .mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newClaudeWorktreeSession",
    );
    await handler();

    expect(createTerminalMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("newClaudeWorktreeSession surfaces a missing powershell runtime error", async () => {
    setExecutablePresence({ pwsh: false, powershell: false });
    showInputBoxMock
      .mockResolvedValueOnce("auth-refactor")
      .mockResolvedValueOnce("Refactor the auth module.");

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
