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
  activateFreshHandlerWithPosixPathResolve,
  appendLineMock,
  childProcessMock,
  commandHandlers,
  createMockProcess,
  createMockProcessWithStderr,
  deactivate,
  detectRuntime,
  fsMock,
  getFreshChildProcessMock,
  prepareFreshModulesWithPosixPathResolve,
  registerCommandMock,
  resetExtensionHarnessState,
  resolveCodexExecutable,
  setExecutablePresence,
  setFreshExecutablePresence,
  setWorkspaceFolders,
  showWarningMessageMock,
  showInformationMessageMock,
  showErrorMessageMock,
} from "./extension-test-harness";

describe("drm-copilot core command behavior", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("activate registers drmCopilotExtension.helloPython", () => {
    activateAndGetHandler("drmCopilotExtension.helloPython");

    expect(commandHandlers.has("drmCopilotExtension.helloPython")).toBe(true);
  });

  it("activate registers drmCopilotExtension.helloPowerShell", () => {
    activateAndGetHandler("drmCopilotExtension.helloPowerShell");

    expect(commandHandlers.has("drmCopilotExtension.helloPowerShell")).toBe(
      true,
    );
  });

  it("activate registers drmCopilotExtension.syncAgentsFromInstructions", () => {
    activateAndGetHandler("drmCopilotExtension.syncAgentsFromInstructions");

    expect(
      commandHandlers.has("drmCopilotExtension.syncAgentsFromInstructions"),
    ).toBe(true);
  });

  it("activate registers drmCopilotExtension.listMcpTools", () => {
    activateAndGetHandler("drmCopilotExtension.listMcpTools");

    expect(commandHandlers.has("drmCopilotExtension.listMcpTools")).toBe(true);
  });

  it("activate registers drmCopilotExtension.runCodexNativeConverter", () => {
    activateAndGetHandler("drmCopilotExtension.runCodexNativeConverter");

    expect(
      commandHandlers.has("drmCopilotExtension.runCodexNativeConverter"),
    ).toBe(true);
  });

  it("activate registers drmCopilotExtension.resolvePolicyAuditTemplateAsset exactly once", () => {
    activateAndGetHandler(
      "drmCopilotExtension.resolvePolicyAuditTemplateAsset",
    );

    expect(
      commandHandlers.has(
        "drmCopilotExtension.resolvePolicyAuditTemplateAsset",
      ),
    ).toBe(true);
    expect(
      [...commandHandlers.keys()].filter(
        (commandId) =>
          commandId === "drmCopilotExtension.resolvePolicyAuditTemplateAsset",
      ),
    ).toHaveLength(1);
  });

  it("does not register the retired placeholder commands", () => {
    activateAndGetHandler("drmCopilotExtension.newPotentialEntry");

    expect(
      commandHandlers.has(
        "drmCopilotExtension.newActiveFeatureFolderPlaceholder",
      ),
    ).toBe(false);
    expect(
      commandHandlers.has("drmCopilotExtension.potentialToIssuePlaceholder"),
    ).toBe(false);
    expect(
      commandHandlers.has(
        "drmCopilotExtension.newPotentialBugEntryPyPlaceholder",
      ),
    ).toBe(false);
    expect(
      commandHandlers.has("drmCopilotExtension.newPotentialEntryPsPlaceholder"),
    ).toBe(false);
  });

  it("no workspace throws clear no-workspace error", () => {
    setWorkspaceFolders(undefined);

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    // The in-process helloPython resolves the workspace root via
    // getWorkspaceRoot(), which throws synchronously when no workspace folder
    // is open.
    expect(() => handler()).toThrow("No workspace");
  });

  it("detectRuntime probes pwsh then powershell", () => {
    setExecutablePresence({ pwsh: true, powershell: true });

    const runtime = detectRuntime("powershell");
    expect(runtime.executable).toBe("pwsh");
  });

  it("missing PowerShell returns actionable runtime error when pwsh and powershell are unavailable", () => {
    setExecutablePresence({ pwsh: false, powershell: false });

    expect(() => detectRuntime("powershell")).toThrow(
      "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
    );
  });

  it("resolveCodexExecutable finds default codex on PATH", () => {
    setExecutablePresence({ codex: true });

    expect(resolveCodexExecutable("")).toBe("C:/bin/codex.EXE");
  });

  it("resolveCodexExecutable treats undefined configuration as PATH fallback", () => {
    setExecutablePresence({ codex: true });

    expect(resolveCodexExecutable(undefined)).toBe("C:/bin/codex.EXE");
  });

  it("resolveCodexExecutable resolves configured command names from PATH", () => {
    setExecutablePresence({ codex: true });

    expect(resolveCodexExecutable("codex")).toBe("C:/bin/codex.EXE");
  });

  it("resolveCodexExecutable validates configured executable paths", () => {
    setExecutablePresence({ codex: true });

    expect(resolveCodexExecutable("C:/Tools/Codex/codex.exe")).toBe(
      "C:/Tools/Codex/codex.exe",
    );
  });

  it("resolveCodexExecutable fails when a configured executable path is missing", () => {
    setExecutablePresence({ codex: false });

    expect(() => resolveCodexExecutable("C:/Tools/Codex/codex.exe")).toThrow(
      "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
    );
  });

  it("resolveCodexExecutable fails when a configured command name is missing", () => {
    setExecutablePresence({ codex: false });

    expect(() => resolveCodexExecutable("codex")).toThrow(
      "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
    );
  });

  it("resolveCodexExecutable fails when default codex cannot be found", () => {
    setExecutablePresence({ codex: false });

    expect(() => resolveCodexExecutable("")).toThrow(
      "Codex CLI not found. Configure drmCopilotExtension.newCodexWorktreeSession.codexExecutablePath or install codex on PATH.",
    );
  });

  it("helloPython writes artifacts/hello_python.txt in-process without spawning", async () => {
    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await handler();

    // The in-process path writes the smoke-test file through node:fs and never
    // spawns a runtime.
    const writeCall = fsMock.writeFileSync.mock.calls[0] as [
      string,
      string,
      string,
    ];
    expect(writeCall[0]).toBe("C:/workspace/artifacts/hello_python.txt");
    expect(writeCall[1]).toBe("hello_python:ok\n");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("helloPowerShell uses bundled extension script path", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.helloPowerShell",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[args.length - 1]).toBe(
      "C:/extension/resources/templates/hello_pwsh.ps1",
    );
  });

  it("helloPython ensures the artifacts parent directory in-process", async () => {
    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await handler();

    const mkdirCall = fsMock.mkdirSync.mock.calls[0] as [
      string,
      { recursive?: boolean },
    ];
    expect(mkdirCall[0]).toBe("C:/workspace/artifacts");
    expect(mkdirCall[1]).toEqual({ recursive: true });
  });

  it("helloPython does not copy the hello script into the workspace root", async () => {
    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await handler();

    // The in-process write targets artifacts/hello_python.txt only; no script
    // file is copied into the workspace root.
    const writtenPaths = fsMock.writeFileSync.mock.calls.map(
      ([writtenPath]) => writtenPath,
    );
    expect(writtenPaths).toContain("C:/workspace/artifacts/hello_python.txt");
    expect(writtenPaths).not.toContain("C:/workspace/hello_python.py");
  });

  it("handlers log runtime probe start success failure to Scaffold Utils output channel", async () => {
    // The PowerShell command still spawns a runtime, so it exercises the
    // runtime-probe logging path that this test asserts.
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(1));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.helloPowerShell",
    );
    await expect(handler()).rejects.toThrow("Command exited with code 1");

    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(logs.some((line) => line.includes("runtime probe start"))).toBe(
      true,
    );
    expect(logs.some((line) => line.includes("runtime probe success"))).toBe(
      true,
    );
    expect(logs.some((line) => line.includes("command failure"))).toBe(true);
  });

  it("subprocess calls use argv arrays and never shell-concatenated command strings", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.helloPowerShell",
    );
    await handler();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { shell: boolean }];
    expect(typeof executable).toBe("string");
    expect(Array.isArray(args)).toBe(true);
    expect(options.shell).toBe(false);
    expect(executable.includes(" ")).toBe(false);
  });

  it("helloPowerShell preserves C:/extension on POSIX hosts", async () => {
    try {
      prepareFreshModulesWithPosixPathResolve();
      setFreshExecutablePresence({ pwsh: true });
      const freshChildProcessMock = getFreshChildProcessMock();
      freshChildProcessMock.spawn.mockReturnValue(createMockProcess(0));
      const handler = await activateFreshHandlerWithPosixPathResolve(
        "drmCopilotExtension.helloPowerShell",
      );
      await handler();

      const [, args] = freshChildProcessMock.spawn.mock.calls[0] as [
        string,
        string[],
      ];
      expect(
        args[args.length - 1].startsWith("C:/extension/resources/templates/"),
      ).toBe(true);
    } finally {
      jest.dontMock("node:path");
      jest.resetModules();
    }
  });
});

describe("drmCopilotExtension.removeSecondaryWorktrees", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("activate registers the command exactly once", () => {
    activateAndGetHandler("drmCopilotExtension.removeSecondaryWorktrees");

    expect(
      commandHandlers.has("drmCopilotExtension.removeSecondaryWorktrees"),
    ).toBe(true);
    const registrations = registerCommandMock.mock.calls.filter(
      ([command]) => command === "drmCopilotExtension.removeSecondaryWorktrees",
    ).length;
    expect(registrations).toBe(1);
  });

  it("issues no git command when the confirmation is cancelled", async () => {
    showWarningMessageMock.mockResolvedValue(undefined);
    const handler = activateAndGetHandler(
      "drmCopilotExtension.removeSecondaryWorktrees",
    );

    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(showInformationMessageMock).not.toHaveBeenCalled();
  });

  it("surfaces an error when git worktree list exits non-zero", async () => {
    showWarningMessageMock.mockResolvedValue("Remove All");
    childProcessMock.spawn.mockReturnValue(
      createMockProcessWithStderr(128, "fatal: not a git repository"),
    );
    const handler = activateAndGetHandler(
      "drmCopilotExtension.removeSecondaryWorktrees",
    );

    await handler();

    expect(showErrorMessageMock).toHaveBeenCalledTimes(1);
    const [message] = showErrorMessageMock.mock.calls[0] as [string];
    expect(message).toContain("Remove Secondary Worktrees failed");
  });
});

describe("deactivate", () => {
  it("completes without throwing (no-op implementation)", () => {
    expect(() => deactivate()).not.toThrow();
  });
});
