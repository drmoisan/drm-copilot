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
  resetExtensionHarnessState,
  setExecutablePresence,
  showOpenDialogMock,
  showQuickPickMock,
} from "./extension-test-harness";

const commandCases = [
  {
    commandId: "drmCopilotExtension.runPoshQCFormat",
    wrapperPath: "C:/extension/resources/templates/run-poshqc-format.ps1",
  },
  {
    commandId: "drmCopilotExtension.runPoshQCAnalyze",
    wrapperPath: "C:/extension/resources/templates/run-poshqc-analyze.ps1",
  },
  {
    commandId: "drmCopilotExtension.runPoshQCTest",
    wrapperPath: "C:/extension/resources/templates/run-poshqc-test.ps1",
  },
  {
    commandId: "drmCopilotExtension.runPoshQCAnalyzeAutofix",
    wrapperPath:
      "C:/extension/resources/templates/run-poshqc-analyze-autofix.ps1",
  },
] as const;

describe("granular PoshQC commands", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it.each(commandCases)("registers $commandId", ({ commandId }) => {
    activateAndGetHandler(commandId);
  });

  it.each(commandCases)(
    "passes direct scan folders to $commandId",
    async ({ commandId, wrapperPath }) => {
      setExecutablePresence({ pwsh: true, powershell: false });
      childProcessMock.spawn.mockReturnValue(createMockProcess(0));

      const handler = activateAndGetHandler(commandId);
      await handler(["--scan-folder", "C:/workspace/src"]);

      const [, args, options] = childProcessMock.spawn.mock.calls[0] as [
        string,
        string[],
        { cwd: string; shell: boolean },
      ];
      expect(args).toContain(wrapperPath);
      expect(args).toContain("-ScanFolders");
      expect(args).toContain("C:/workspace/src");
      expect(options.cwd).toBe("C:/workspace");
      expect(options.shell).toBe(false);
    },
  );

  it.each(commandCases)(
    "prompts for folder selection in interactive mode for $commandId",
    async ({ commandId }) => {
      setExecutablePresence({ pwsh: true, powershell: false });
      showQuickPickMock.mockResolvedValueOnce("Select folders to scan");
      showOpenDialogMock.mockResolvedValueOnce([
        { fsPath: "C:/workspace/src" },
      ]);
      childProcessMock.spawn.mockReturnValue(createMockProcess(0));

      const handler = activateAndGetHandler(commandId);
      await handler();

      const [, args] = childProcessMock.spawn.mock.calls[0] as [
        string,
        string[],
      ];
      expect(args).toContain("-ScanFolders");
      expect(args).toContain("C:/workspace/src");
    },
  );
});
