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
  fsMock,
  resetExtensionHarnessState,
  setExecutablePresence,
  showOpenDialogMock,
  showQuickPickMock,
} from "./extension-test-harness";
import {
  CommandExecutionError,
  getStderrExcerpt,
} from "../src/command-runtime";
import { POSHQC_TERMINAL_NAME } from "../src/poshqc-terminal-output";

const commandCases = [
  {
    commandId: "drmCopilotExtension.runPoshQCFormat",
    wrapperPath: "C:/extension/resources/templates/run-poshqc-format.ps1",
    scanFolderFlag: "-ScanFoldersJson",
    scanFolderArg: '["C:/workspace/src"]',
  },
  {
    commandId: "drmCopilotExtension.runPoshQCAnalyze",
    wrapperPath: "C:/extension/resources/templates/run-poshqc-analyze.ps1",
    scanFolderFlag: "-ScanFoldersJson",
    scanFolderArg: '["C:/workspace/src"]',
  },
  {
    commandId: "drmCopilotExtension.runPoshQCTest",
    wrapperPath: "C:/extension/resources/templates/run-poshqc-test.ps1",
    scanFolderFlag: "-ScanFoldersJson",
    scanFolderArg: '["C:/workspace/src"]',
  },
  {
    commandId: "drmCopilotExtension.runPoshQCAnalyzeAutofix",
    wrapperPath:
      "C:/extension/resources/templates/run-poshqc-analyze-autofix.ps1",
    scanFolderFlag: "-ScanFolders",
    scanFolderArg: "C:/workspace/src",
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
    async ({ commandId, wrapperPath, scanFolderFlag, scanFolderArg }) => {
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
      expect(args).toContain(scanFolderFlag);
      expect(args).toContain(scanFolderArg);
      expect(options.cwd).toBe("C:/workspace");
      expect(options.shell).toBe(false);
    },
  );

  // The test command routes interactive folder selection through the seeded
  // multi-select picker (asserted separately below); the other three commands
  // retain the native folder dialog.
  const nativeDialogCases = commandCases.filter(
    (commandCase) =>
      commandCase.commandId !== "drmCopilotExtension.runPoshQCTest",
  );

  it.each(nativeDialogCases)(
    "prompts for folder selection in interactive mode for $commandId",
    async ({ commandId, scanFolderFlag, scanFolderArg }) => {
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
      expect(args).toContain(scanFolderFlag);
      expect(args).toContain(scanFolderArg);
    },
  );
});

describe("runPoshQCTest interactive folder multi-select", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("runs the multi-select folder choice with the selected workspace-relative folders and persists the config before spawning", async () => {
    // Arrange: scope choice then a multi-select return of two folders.
    setExecutablePresence({ pwsh: true, powershell: false });
    showQuickPickMock
      .mockResolvedValueOnce("Select folders to scan")
      .mockResolvedValueOnce([
        { label: "scripts", folder: "scripts" },
        { label: "tests/scripts", folder: "tests/scripts" },
      ]);
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    // Act
    const handler = activateAndGetHandler("drmCopilotExtension.runPoshQCTest");
    await handler();

    // Assert: the selection is serialized as workspace-relative -ScanFoldersJson.
    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain("-ScanFoldersJson");
    expect(args).toContain('["scripts","tests/scripts"]');

    // Assert: the config file was written with the canonical selection before
    // the process was spawned.
    const configWrite = fsMock.writeFileSync.mock.calls.find(([filePath]) =>
      String(filePath).endsWith("config/poshqc-scan.json"),
    );
    expect(configWrite).toBeDefined();
    expect(String(configWrite?.[1])).toContain('"scripts"');
    expect(String(configWrite?.[1])).toContain('"tests/scripts"');
    const writeOrder = fsMock.writeFileSync.mock.invocationCallOrder[0] ?? 0;
    const spawnOrder = childProcessMock.spawn.mock.invocationCallOrder[0] ?? 0;
    expect(writeOrder).toBeLessThan(spawnOrder);
  });

  it("does not run or persist when the multi-select folder picker is cancelled", async () => {
    // Arrange: scope choice then a cancelled picker.
    setExecutablePresence({ pwsh: true, powershell: false });
    showQuickPickMock
      .mockResolvedValueOnce("Select folders to scan")
      .mockResolvedValueOnce(undefined);
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    // Act
    const handler = activateAndGetHandler("drmCopilotExtension.runPoshQCTest");
    await handler();

    // Assert: no spawn, no config write.
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    const configWrite = fsMock.writeFileSync.mock.calls.find(([filePath]) =>
      String(filePath).endsWith("config/poshqc-scan.json"),
    );
    expect(configWrite).toBeUndefined();
  });
});

describe("runPoshQCTest terminal streaming and failure semantics", () => {
  beforeEach(() => {
    resetExtensionHarnessState();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("streams command output into a stably-named terminal that is revealed at start, and the OutputChannel receives the identical line stream", async () => {
    // Arrange: a successful run that emits two Pester lines.
    setExecutablePresence({ pwsh: true, powershell: false });
    childProcessMock.spawn.mockReturnValue(
      createMockProcess(0, "Pester line A\nPester line B"),
    );

    // Act
    const handler = activateAndGetHandler("drmCopilotExtension.runPoshQCTest");
    await handler(["--scan-folder", "C:/workspace/src"]);

    // Assert: a terminal with the stable name was created and revealed.
    expect(createTerminalMock).toHaveBeenCalled();
    const terminalOptions = createTerminalMock.mock.calls[0]?.[0] as
      { name: string } | undefined;
    expect(terminalOptions?.name).toBe(POSHQC_TERMINAL_NAME);
    const terminal = createTerminalMock.mock.results[0]?.value as {
      show: jest.Mock;
    };
    expect(terminal.show).toHaveBeenCalled();

    // Assert: the OutputChannel received the streamed process output (tee). The
    // runtime appends each stdout chunk as one line, so both Pester lines arrive
    // in the same appended entry.
    const loggedLines = appendLineMock.mock.calls.map(([line]) => String(line));
    expect(
      loggedLines.some(
        (line) =>
          line.includes("Pester line A") && line.includes("Pester line B"),
      ),
    ).toBe(true);
  });

  it("rejects with CommandExecutionError carrying exitCode/stdout/stderr and preserves getStderrExcerpt while the tee is active", async () => {
    // Arrange: a failing run emitting a stderr line, with the tee wired.
    setExecutablePresence({ pwsh: true, powershell: false });
    childProcessMock.spawn.mockReturnValue(
      createMockProcessWithStderr(1, "ERROR: boom"),
    );

    // Act
    const handler = activateAndGetHandler("drmCopilotExtension.runPoshQCTest");
    const error = await handler(["--scan-folder", "C:/workspace/src"]).then(
      () => undefined,
      (caught: unknown) => caught,
    );

    // Assert: the failure contract is unchanged by the terminal tee.
    expect(error).toBeInstanceOf(CommandExecutionError);
    const commandError = error as CommandExecutionError;
    expect(commandError.exitCode).toBe(1);
    expect(commandError.stderr).toContain("ERROR: boom");
    expect(getStderrExcerpt(commandError)).toBe("ERROR: boom");

    // Assert: the terminal tee was active during the failing run.
    expect(createTerminalMock).toHaveBeenCalled();
  });
});
