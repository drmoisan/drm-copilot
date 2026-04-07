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
  resetExtensionHarnessState,
  setExecutablePresence,
  showInputBoxMock,
  showOpenDialogMock,
  showQuickPickMock,
} from "./extension-test-harness";

describe("drm-copilot runPoshQCSuite command", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers runPoshQCSuite", () => {
    activateAndGetHandler("drmCopilotExtension.runPoshQCSuite");
  });

  it("passes the bundled script path and selected scan folders", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.runPoshQCSuite");
    await handler([
      "--scan-folder",
      "C:/workspace/src",
      "--scan-folder",
      "C:/workspace/tests/powershell",
    ]);

    expect(showInputBoxMock).not.toHaveBeenCalled();
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(showOpenDialogMock).not.toHaveBeenCalled();

    const [, args, options] = childProcessMock.spawn.mock.calls[0] as [
      string,
      string[],
      { cwd: string; shell: boolean },
    ];
    expect(
      args.includes("C:/extension/resources/templates/run-poshqc-suite.ps1"),
    ).toBe(true);
    expect(args).toContain("-WorkspaceRoot");
    expect(args).toContain("C:/workspace");
    expect(args).toContain("-ScanFolders");
    expect(args).toContain("C:/workspace/src");
    expect(args).toContain("C:/workspace/tests/powershell");
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shell).toBe(false);
  });

  it("rejects unknown direct-invocation flags", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });

    const handler = activateAndGetHandler("drmCopilotExtension.runPoshQCSuite");

    await expect(handler(["--mystery-flag", "boom"])).rejects.toThrow(
      /unknown flag/i,
    );
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("prompts for folder selection when the user chooses a narrowed scan", async () => {
    setExecutablePresence({ pwsh: true, powershell: false });
    showQuickPickMock.mockResolvedValueOnce("Select folders to scan");
    showOpenDialogMock.mockResolvedValueOnce([
      { fsPath: "C:/workspace/src" },
      { fsPath: "C:/workspace/tests/powershell" },
    ]);
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.runPoshQCSuite");
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain("-ScanFolders");
    expect(args).toContain("C:/workspace/src");
    expect(args).toContain("C:/workspace/tests/powershell");
  });

  it("logs and surfaces a missing PowerShell runtime error", async () => {
    setExecutablePresence({ pwsh: false, powershell: false });

    const handler = activateAndGetHandler("drmCopilotExtension.runPoshQCSuite");

    await expect(handler()).rejects.toThrow(
      "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
    );

    expect(
      appendLineMock.mock.calls.some(([line]) =>
        String(line).includes("runtime probe failure"),
      ),
    ).toBe(true);
  });
});
