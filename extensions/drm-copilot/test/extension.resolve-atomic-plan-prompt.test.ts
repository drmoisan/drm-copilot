import { EventEmitter } from "node:events";
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
type MockChildProcess = EventEmitter & {
  stdout: EventEmitter;
  stderr: EventEmitter;
};

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

jest.mock("node:fs", () => ({
  existsSync: jest.fn(),
}));

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
  spawnSync: jest.fn(),
}));

import { activate } from "../src/extension";

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

function setExecutablePresence(presence: { readonly python?: boolean }): void {
  fsMock.existsSync.mockImplementation((filePath: string) => {
    const lowerPath = filePath.toLowerCase();
    if (lowerPath.includes("python")) {
      return presence.python ?? false;
    }

    return false;
  });
}

function createMockProcess(exitCode: number): MockChildProcess {
  const processMock = new EventEmitter() as MockChildProcess;
  processMock.stdout = new EventEmitter();
  processMock.stderr = new EventEmitter();
  process.nextTick(() => {
    processMock.emit("close", exitCode);
  });
  return processMock;
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

describe("drm-copilot resolveAtomicPlanPrompt command", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    commandHandlers.clear();
    appendLineMock.mockReset();
    registerCommandMock.mockClear();
    showOpenDialogMock.mockReset();
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
    activeTextEditorState = undefined;
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers resolveAtomicPlanPrompt", () => {
    activateAndGetHandler("drmCopilotExtension.resolveAtomicPlanPrompt");

    expect(
      commandHandlers.has("drmCopilotExtension.resolveAtomicPlanPrompt"),
    ).toBe(true);
  });

  it("reuses the active eligible plan editor before opening the picker", async () => {
    setExecutablePresence({ python: true });
    setActiveEditorPath(
      "C:/workspace/docs/features/active/feature-152/plan.2026-04-17T19-54.md",
    );
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveAtomicPlanPrompt",
    );
    await handler();

    expect(showOpenDialogMock).not.toHaveBeenCalled();
    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/resolve_atomic_plan_prompt.py",
    );
    expect(args).toContain("--target");
    expect(args).toContain(
      "C:/workspace/docs/features/active/feature-152/plan.2026-04-17T19-54.md",
    );
  });

  it("opens a docs/features/active picker when the active editor is issue.md", async () => {
    setExecutablePresence({ python: true });
    setActiveEditorPath(
      "C:/workspace/docs/features/active/feature-152/issue.md",
    );
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/active/feature-152/plan.md" },
    ]);
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveAtomicPlanPrompt",
    );
    await handler();

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
    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain(
      "C:/workspace/docs/features/active/feature-152/plan.md",
    );
    expect(args).not.toContain(
      "C:/workspace/docs/features/active/feature-152/issue.md",
    );
  });

  it("returns early when the feature plan picker is cancelled", async () => {
    showOpenDialogMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveAtomicPlanPrompt",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("surfaces a missing python runtime error for resolveAtomicPlanPrompt", async () => {
    setExecutablePresence({ python: false });
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/active/feature-152/plan.md" },
    ]);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveAtomicPlanPrompt",
    );

    await expect(handler()).rejects.toThrow(
      "Python runtime 'python' not found on PATH.",
    );
  });

  it("rejects a picker-selected spec.md file before spawning the bundled wrapper", async () => {
    setExecutablePresence({ python: true });
    setActiveEditorPath(
      "C:/workspace/docs/features/active/feature-152/issue.md",
    );
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/active/feature-152/spec.md" },
    ]);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.resolveAtomicPlanPrompt",
    );

    await expect(handler()).rejects.toThrow(
      "This command requires an active or selected plan markdown file under docs/features/active/**/plan*.md.",
    );
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });
});
