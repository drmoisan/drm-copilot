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
  getFreshChildProcessMock,
  prepareFreshModulesWithPosixPathResolve,
  registerCommandMock,
  resetExtensionHarnessState,
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

  it("no workspace throws clear no-workspace error", async () => {
    setWorkspaceFolders(undefined);
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await expect(handler()).rejects.toThrow("No workspace");
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

  it("detectRuntime returns named Python error when python missing", () => {
    setExecutablePresence({ python: false });

    expect(() => detectRuntime("python")).toThrow(
      "Python runtime 'python' not found on PATH.",
    );
  });

  it("detectRuntime falls back to py -3 when python is unavailable", () => {
    setExecutablePresence({ python: false, py: true });

    const runtime = detectRuntime("python");
    expect(runtime).toEqual({
      executable: "py",
      argsPrefix: ["-3"],
    });
  });

  it("helloPython uses bundled extension script path", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe("C:/extension/resources/templates/hello_python.py");
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

  it("helloPython uses explicit executable and argv arrays", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await handler();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { shell: boolean; cwd: string }];
    expect(executable).toBe("python");
    expect(Array.isArray(args)).toBe(true);
    expect(options.shell).toBe(false);
  });

  it("hello commands do not copy hello scripts into workspace root", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const scriptPath = args[0];
    expect(scriptPath.includes("/resources/templates/")).toBe(true);
    expect(scriptPath.includes("C:/workspace/hello_python.py")).toBe(false);
  });

  it("handlers log runtime probe start success failure to Scaffold Utils output channel", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(1));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
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

  it("helloPython preserves C:/extension on POSIX hosts", async () => {
    try {
      prepareFreshModulesWithPosixPathResolve();
      setFreshExecutablePresence({ python: true });
      const freshChildProcessMock = getFreshChildProcessMock();
      freshChildProcessMock.spawn.mockReturnValue(createMockProcess(0));
      const handler = await activateFreshHandlerWithPosixPathResolve(
        "drmCopilotExtension.helloPython",
      );
      await handler();

      const [, args] = freshChildProcessMock.spawn.mock.calls[0] as [
        string,
        string[],
      ];
      expect(args[0]).toBe("C:/extension/resources/templates/hello_python.py");
    } finally {
      jest.dontMock("node:path");
      jest.resetModules();
    }
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
