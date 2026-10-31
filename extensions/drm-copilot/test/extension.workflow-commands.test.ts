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
  fsMock,
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

  it("runCodexNativeConverter review mode runs the in-process converter without spawning Python", async () => {
    setExecutablePresence({ python: true });
    showQuickPickMock
      .mockResolvedValueOnce("review")
      .mockResolvedValueOnce("github-copilot")
      .mockResolvedValueOnce("Yes");
    showInputBoxMock.mockResolvedValueOnce("C:/source-runtime");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.runCodexNativeConverter",
    );
    await handler();

    // The F10 in-process port never spawns the bundled Python script; the
    // converter writes its report artifacts through the (mocked) filesystem.
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    const wroteConversionReport = fsMock.writeFileSync.mock.calls.some(
      ([filePath]) =>
        typeof filePath === "string" &&
        filePath.includes("artifacts/codex-native-converter") &&
        filePath.endsWith("conversion-report.md"),
    );
    expect(wroteConversionReport).toBe(true);
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

  // The behavioral `newPotentialBugEntry` cases were moved to
  // `extension.new-potential-bug-entry-inprocess.test.ts` for the F6 in-process
  // port (this file already exceeds 500 lines and must not grow). The
  // registration case remains above.

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

  // The `newPotentialBugEntry passes --template-root ...` case was moved to
  // `extension.new-potential-bug-entry-inprocess.test.ts` and reworked to assert
  // the in-process template read under the bundled feature-templates root.

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

  // The former `newActiveFeatureFolder passes --template-root ...` Python-spawn
  // assertion was reworked to the in-process expectation in
  // `extension.new-active-feature-folder-inprocess.test.ts` (F8): the service
  // forwards `this.templateRoot` to the in-process workflow, which resolves the
  // bundled `resources/feature-templates` tree without spawning a `.py` script.
});
