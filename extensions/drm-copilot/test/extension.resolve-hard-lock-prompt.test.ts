import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

type CommandHandler = () => Promise<void> | void;
type MockUri = { fsPath: string };

const commandHandlers = new Map<string, CommandHandler>();
const appendLineMock = jest.fn<(line: string) => void>();
const showOpenDialogMock =
  jest.fn<(options?: unknown) => Promise<ReadonlyArray<MockUri> | undefined>>();
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
  | {
      document: {
        uri: {
          fsPath: string;
        };
      };
    }
  | undefined;

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
      showOpenDialog: showOpenDialogMock,
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
      file: jest.fn((filePath: string) => ({ fsPath: filePath })),
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

// The in-process resolver reads templates/targets through RealFileSystem; route
// those reads through the node:fs mock so no real disk I/O occurs.
jest.mock("node:fs", () => ({
  existsSync: jest.fn(),
  statSync: jest.fn(),
  readFileSync: jest.fn(),
  writeFileSync: jest.fn(),
  mkdirSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
}));

import { activate } from "../src/extension";

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
  statSync: jest.MockedFunction<(filePath: string) => { isFile(): boolean }>;
  readFileSync: jest.MockedFunction<
    (filePath: string, encoding: string) => string
  >;
  writeFileSync: jest.MockedFunction<
    (filePath: string, content: string, encoding: string) => void
  >;
  mkdirSync: jest.MockedFunction<
    (filePath: string, options?: { recursive?: boolean }) => void
  >;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

/**
 * Seed the node:fs mock so RealFileSystem treats every path as an existing file
 * and returns a hard-lock template containing `${plan-path}`. This keeps the
 * command-handler suite hermetic while exercising the in-process resolver.
 */
function seedInProcessFileSystem(): void {
  fsMock.statSync.mockReturnValue({ isFile: () => true });
  fsMock.readFileSync.mockReturnValue("Plan: ${plan-path}\n");
  fsMock.writeFileSync.mockReturnValue(undefined);
  fsMock.mkdirSync.mockReturnValue(undefined);
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
    ? {
        document: {
          uri: {
            fsPath: filePath,
          },
        },
      }
    : undefined;
}

describe("drm-copilot resolveExecuteHardLockPrompt command", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    commandHandlers.clear();
    appendLineMock.mockReset();
    registerCommandMock.mockClear();
    showOpenDialogMock.mockReset();
    fsMock.existsSync.mockReset();
    fsMock.statSync.mockReset();
    fsMock.readFileSync.mockReset();
    fsMock.writeFileSync.mockReset();
    fsMock.mkdirSync.mockReset();
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
    activeTextEditorState = undefined;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers resolveExecuteHardLockPrompt", () => {
    activateAndGetHandler("drmCopilotExtension.resolveExecuteHardLockPrompt");

    expect(
      commandHandlers.has("drmCopilotExtension.resolveExecuteHardLockPrompt"),
    ).toBe(true);
  });

  it("reuses the active feature plan editor before opening the picker", async () => {
    // Arrange
    seedInProcessFileSystem();
    setActiveEditorPath(
      "C:/workspace/docs/features/active/feature-123/plan.md",
    );

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveExecuteHardLockPrompt",
    );
    await handler();

    // Assert: the active editor is reused without the picker, and the
    // in-process path runs (no Python spawn).
    expect(showOpenDialogMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("opens a docs/features/active picker when the active editor is not eligible", async () => {
    // Arrange
    seedInProcessFileSystem();
    setActiveEditorPath("C:/workspace/README.md");
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/active/feature-123/plan.md" },
    ]);

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveExecuteHardLockPrompt",
    );
    await handler();

    // Assert
    expect(showOpenDialogMock).toHaveBeenCalledWith(
      expect.objectContaining({
        defaultUri: expect.objectContaining({
          fsPath: expect.stringContaining("docs/features/active"),
        }),
        filters: {
          Markdown: ["md"],
        },
      }),
    );
  });

  it("resolves the selected plan via the in-process path without a Python spawn", async () => {
    // Arrange
    seedInProcessFileSystem();
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/active/feature-123/plan.md" },
    ]);

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveExecuteHardLockPrompt",
    );
    await handler();

    // Assert: the in-process resolver reads the hard-lock template through the
    // injected filesystem and emits the resolved content; no Python spawn occurs.
    // The command handler does not supply --output, so the non-quiet branch
    // emits the resolved prompt via the output channel.
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(fsMock.readFileSync).toHaveBeenCalled();
    expect(
      appendLineMock.mock.calls.some(([line]) =>
        line.includes("Plan: docs/features/active/feature-123/plan.md"),
      ),
    ).toBe(true);
  });

  it("returns early when the feature plan picker is cancelled", async () => {
    // Arrange
    showOpenDialogMock.mockResolvedValue(undefined);

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveExecuteHardLockPrompt",
    );
    await handler();

    // Assert
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    expect(fsMock.writeFileSync).not.toHaveBeenCalled();
  });

  it("completes via the in-process path without probing a Python runtime", async () => {
    // Arrange: existsSync returns false everywhere (no Python on PATH); the
    // in-process resolver does not probe Python, so the command still succeeds.
    seedInProcessFileSystem();
    fsMock.existsSync.mockReturnValue(false);
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/active/feature-123/plan.md" },
    ]);

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveExecuteHardLockPrompt",
    );

    // Assert: no Python-runtime error is thrown.
    await expect(handler()).resolves.toBeUndefined();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });
});
