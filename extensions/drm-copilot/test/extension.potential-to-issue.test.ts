import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

/**
 * Extension-level cases for the `potentialToIssue` command. After F7 the command
 * runs the promotion workflow in-process (no Python spawn), so these cases drive
 * the command handler with the `node:fs` and `node:child_process` module mocks
 * configured to provide an in-memory potential file and seeded `gh` responses.
 * The Python-spawn assertions were replaced with in-process equivalents; the
 * argument-parsing, UI-resolution, and cancellation behaviors are preserved.
 */

type CommandHandler = (...args: unknown[]) => Promise<void> | void;
type MockUri = { fsPath: string };

const commandHandlers = new Map<string, CommandHandler>();
const showOpenDialogMock =
  jest.fn<(options?: unknown) => Promise<ReadonlyArray<MockUri> | undefined>>();
const showQuickPickMock = jest.fn<() => Promise<string | undefined>>();
const showInputBoxMock = jest.fn<() => Promise<string | undefined>>();
const appendLineMock = jest.fn<(line: string) => void>();
const registerCommandMock = jest.fn(
  (command: string, handler: CommandHandler) => {
    commandHandlers.set(command, handler);
    return { dispose: jest.fn() };
  },
);

let workspaceFoldersState: Array<{ uri: { fsPath: string } }> | undefined = [
  { uri: { fsPath: "C:/workspace" } },
];
let activeTextEditorState:
  { document: { uri: { fsPath: string } } } | undefined;

jest.mock(
  "vscode",
  () => ({
    commands: {
      registerCommand: registerCommandMock,
    },
    window: {
      createOutputChannel: jest.fn(() => ({
        appendLine: appendLineMock,
        dispose: jest.fn(),
      })),
      get activeTextEditor() {
        return activeTextEditorState;
      },
      showInputBox: showInputBoxMock,
      showOpenDialog: showOpenDialogMock,
      showQuickPick: showQuickPickMock,
    },
    workspace: {
      get workspaceFolders() {
        return workspaceFoldersState;
      },
    },
    Uri: {
      joinPath: jest.fn((base: { fsPath: string }, ...segments: string[]) => ({
        fsPath: `${base.fsPath}/${segments.join("/")}`,
      })),
      file: jest.fn((path: string) => ({ fsPath: path })),
    },
    lm: {
      registerMcpServerDefinitionProvider: jest.fn(() => ({
        dispose: jest.fn(),
      })),
    },
    EventEmitter: jest.fn(() => ({
      event: jest.fn(),
      dispose: jest.fn(),
    })),
    McpStdioServerDefinition: jest.fn(),
  }),
  { virtual: true },
);

jest.mock("node:fs", () => ({
  existsSync: jest.fn(),
  readFileSync: jest.fn(),
  writeFileSync: jest.fn(),
  mkdirSync: jest.fn(),
  renameSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
  execSync: jest.fn(),
}));

import { activate } from "../src/extension";

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
  readFileSync: jest.MockedFunction<(filePath: string) => string>;
  writeFileSync: jest.MockedFunction<
    (filePath: string, content: string) => void
  >;
  mkdirSync: jest.MockedFunction<(dirPath: string) => void>;
  renameSync: jest.MockedFunction<(src: string, dest: string) => void>;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
  execSync: jest.Mock;
};

/** Minimal feature potential content used by the in-process scenarios. */
const FEATURE_CONTENT = [
  "# Feature Title",
  "## Problem / Why",
  "why",
  "## Proposed Behavior",
  "behave",
].join("\n");

/**
 * Configure the in-process seams so the promotion workflow runs hermetically:
 * `gh` resolves on PATH (execSync), `gh` calls return a seeded create result
 * (spawnSync), and the potential file exists with feature content.
 *
 * @param createExitCode Exit code returned by the seeded `gh issue create`.
 */
function installInProcessSeams(createExitCode = 0): {
  readonly spawnSyncArgs: string[][];
} {
  const spawnSyncArgs: string[][] = [];

  // `gh` path lookup uses execSync; resolve it to a fake path.
  childProcessMock.execSync.mockReturnValue("/usr/bin/gh\n");

  // `gh` invocations route through spawnSync. Seed auth-success and a create
  // result; the workflow inspects exit codes itself.
  childProcessMock.spawnSync.mockImplementation((...rawArgs: unknown[]) => {
    const exe = rawArgs[0] as string;
    const args = (rawArgs[1] as string[] | undefined) ?? [];
    if (exe === "/usr/bin/gh") {
      spawnSyncArgs.push([...args]);
      if (args[0] === "auth") {
        return { status: 0, stdout: "ok", stderr: "" };
      }
      if (args[0] === "issue" && args[1] === "create") {
        return {
          status: createExitCode,
          stdout:
            createExitCode === 0
              ? "Created: https://example.com/issues/123"
              : "gh: create failed",
          stderr: "",
        };
      }
      if (args[0] === "issue" && args[1] === "view") {
        return {
          status: 0,
          stdout: '{"number":123,"updatedAt":"2024-01-02T00:00:00Z"}',
          stderr: "",
        };
      }
    }
    return { status: 0, stdout: "", stderr: "" };
  });

  // The potential file exists and holds feature content; metadata writes and
  // the move are recorded by the fs mock (no real disk access).
  fsMock.existsSync.mockReturnValue(true);
  fsMock.readFileSync.mockReturnValue(FEATURE_CONTENT);
  fsMock.writeFileSync.mockReturnValue(undefined);
  fsMock.mkdirSync.mockReturnValue(undefined);
  fsMock.renameSync.mockReturnValue(undefined);

  return { spawnSyncArgs };
}

function activateAndGetHandler(commandId: string): CommandHandler {
  const context = {
    extensionUri: { fsPath: "C:/extension" },
    subscriptions: [] as Array<{ dispose(): void }>,
  };

  activate(context as never);
  const handler = commandHandlers.get(commandId);
  if (!handler) {
    throw new Error(`Missing command handler: ${commandId}`);
  }

  return handler;
}

function setActiveEditorPath(filePath: string | undefined): void {
  activeTextEditorState = filePath
    ? { document: { uri: { fsPath: filePath } } }
    : undefined;
}

/** Assert that no Python `.py` script was spawned. */
function expectNoPythonSpawn(): void {
  const pySpawned = childProcessMock.spawn.mock.calls.some((call: unknown[]) =>
    ((call[1] as string[] | undefined) ?? []).some((arg) =>
      arg.endsWith("/resources/templates/potential_to_issue.py"),
    ),
  );
  expect(pySpawned).toBe(false);
}

describe("drm-copilot potentialToIssue command", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    commandHandlers.clear();
    appendLineMock.mockReset();
    registerCommandMock.mockClear();
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    childProcessMock.execSync.mockReset();
    fsMock.existsSync.mockReset();
    fsMock.readFileSync.mockReset();
    fsMock.writeFileSync.mockReset();
    fsMock.mkdirSync.mockReset();
    fsMock.renameSync.mockReset();
    showInputBoxMock.mockReset();
    showOpenDialogMock.mockReset();
    showQuickPickMock.mockReset();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
    activeTextEditorState = undefined;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers potentialToIssue", () => {
    activateAndGetHandler("drmCopilotExtension.potentialToIssue");

    expect(commandHandlers.has("drmCopilotExtension.potentialToIssue")).toBe(
      true,
    );
  });

  it("runs the promotion in-process without spawning the bundled script", async () => {
    installInProcessSeams();
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    // The in-process workflow runs the gh CLI via spawnSync; no Python spawn.
    expectNoPythonSpawn();
    expect(childProcessMock.spawnSync).toHaveBeenCalled();
  });

  it("potentialToIssue direct invocation skips active-editor and prompt UI", async () => {
    installInProcessSeams();

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler([
      "--potential-path",
      "C:/workspace/docs/features/potential/direct.md",
      "--promotion-type",
      "feature",
      "--work-mode",
      "full-feature",
    ]);

    // Direct invocation resolves arguments without the file picker or quick picks.
    expect(showOpenDialogMock).not.toHaveBeenCalled();
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expectNoPythonSpawn();
  });

  it("potentialToIssue direct mode rejects unknown flag", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );

    await expect(
      handler([
        "--potential-path",
        "C:/workspace/docs/features/potential/direct.md",
        "--promotion-type",
        "feature",
        "--work-mode",
        "full-feature",
        "--mystery-flag",
        "boom",
      ]),
    ).rejects.toThrow(/unknown flag/i);
    expect(showOpenDialogMock).not.toHaveBeenCalled();
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("potentialToIssue direct mode rejects invalid work mode", async () => {
    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );

    await expect(
      handler([
        "--potential-path",
        "C:/workspace/docs/features/potential/direct.md",
        "--promotion-type",
        "feature",
        "--work-mode",
        "freeform-mode",
      ]),
    ).rejects.toThrow(/work mode/i);
    expect(showOpenDialogMock).not.toHaveBeenCalled();
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("reuses the active potential editor path before falling back to the file picker", async () => {
    installInProcessSeams();
    setActiveEditorPath("C:/workspace/docs/features/potential/active.md");
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("minor-audit");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    // The active editor path is reused, so the file picker is not shown.
    expect(showOpenDialogMock).not.toHaveBeenCalled();
    expectNoPythonSpawn();
  });

  it("keeps the promotion-type quick pick after active-editor auto-resolution", async () => {
    installInProcessSeams();
    setActiveEditorPath("C:/workspace/docs/features/potential/active.md");
    showQuickPickMock
      .mockResolvedValueOnce("bug")
      .mockResolvedValueOnce("full-bug");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    expect(showQuickPickMock).toHaveBeenNthCalledWith(
      1,
      expect.arrayContaining(["epic", "feature", "refactor", "bug"]),
      expect.objectContaining({
        prompt: "Choose a promotion type.",
      }),
    );
    expectNoPythonSpawn();
  });

  it("keeps the work-mode quick pick after active-editor auto-resolution", async () => {
    installInProcessSeams();
    setActiveEditorPath("C:/workspace/docs/features/potential/active.md");
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("minor-audit");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    expect(showQuickPickMock).toHaveBeenNthCalledWith(
      2,
      expect.arrayContaining([
        "minor-audit",
        "full-feature",
        "full-bug",
        "full",
      ]),
      expect.objectContaining({
        prompt: "Choose a work mode.",
      }),
    );
    expectNoPythonSpawn();
  });

  it("returns early when the file picker is cancelled", async () => {
    showOpenDialogMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(childProcessMock.spawnSync).not.toHaveBeenCalled();
  });

  it("returns early when the promotion-type quick pick is cancelled", async () => {
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock.mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(childProcessMock.spawnSync).not.toHaveBeenCalled();
  });

  it("returns early when the work-mode quick pick is cancelled", async () => {
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(childProcessMock.spawnSync).not.toHaveBeenCalled();
  });

  it("succeeds without any Python runtime present (in-process port)", async () => {
    // The prior Python-runtime requirement is intentionally inverted: with no
    // python on PATH the in-process workflow still completes.
    installInProcessSeams();
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );

    await expect(handler()).resolves.toBeUndefined();
    expectNoPythonSpawn();
  });

  it("passes default folder for potential docs to showOpenDialog", async () => {
    installInProcessSeams();
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    expect(showOpenDialogMock).toHaveBeenCalledWith(
      expect.objectContaining({
        defaultUri: expect.objectContaining({
          fsPath: expect.stringContaining("docs/features/potential"),
        }),
      }),
    );
  });

  it("surfaces a non-zero in-process promotion failure", async () => {
    // A non-zero gh create exit surfaces as the preserved failure contract.
    installInProcessSeams(2);
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );

    await expect(handler()).rejects.toThrow("Command exited with code 2");
  });
});
