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
  registerMcpServerDefinitionProviderMock,
  resetExtensionHarnessState,
  setExecutablePresence,
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
