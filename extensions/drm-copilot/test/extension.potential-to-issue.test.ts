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
      joinPath: jest.fn((base: { fsPath: string }, relative: string) => ({
        fsPath: `${base.fsPath}/${relative}`,
      })),
      file: jest.fn((path: string) => ({ fsPath: path })),
    },
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

describe("drm-copilot potentialToIssue command", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    commandHandlers.clear();
    appendLineMock.mockReset();
    registerCommandMock.mockClear();
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    showInputBoxMock.mockReset();
    showOpenDialogMock.mockReset();
    showQuickPickMock.mockReset();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
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

  it("passes the bundled script path and argument pairs", async () => {
    setExecutablePresence({ python: true });
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/potential_to_issue.py",
    );
    expect(args[1]).toBe("--potential-path");
    expect(args[2]).toBe("C:/workspace/docs/features/potential/sample.md");
    expect(args[3]).toBe("--promotion-type");
    expect(args[4]).toBe("feature");
    expect(args[5]).toBe("--work-mode");
    expect(args[6]).toBe("full");
  });

  it("returns early when the file picker is cancelled", async () => {
    showOpenDialogMock.mockResolvedValue(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
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
  });

  it("surfaces a missing python runtime error", async () => {
    setExecutablePresence({ python: false });
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );

    await expect(handler()).rejects.toThrow(
      "Python runtime 'python' not found on PATH.",
    );
  });

  it("passes default folder for potential docs to showOpenDialog", async () => {
    setExecutablePresence({ python: true });
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

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

  it("surfaces non-zero exit failures", async () => {
    setExecutablePresence({ python: true });
    showOpenDialogMock.mockResolvedValue([
      { fsPath: "C:/workspace/docs/features/potential/sample.md" },
    ]);
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    childProcessMock.spawn.mockReturnValue(createMockProcess(2));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.potentialToIssue",
    );

    await expect(handler()).rejects.toThrow("Command exited with code 2");
  });
});
