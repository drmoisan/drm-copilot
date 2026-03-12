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
type MockChildProcess = EventEmitter & {
  stdout: EventEmitter;
  stderr: EventEmitter;
};

const commandHandlers = new Map<string, CommandHandler>();
const showInputBoxMock = jest.fn<() => Promise<string | undefined>>();
const showQuickPickMock = jest.fn<() => Promise<string | undefined>>();
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

describe("drm-copilot newActiveFeatureFolder command", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    commandHandlers.clear();
    appendLineMock.mockReset();
    registerCommandMock.mockClear();
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    showInputBoxMock.mockReset();
    showQuickPickMock.mockReset();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("registers newActiveFeatureFolder", () => {
    activateAndGetHandler("drmCopilotExtension.newActiveFeatureFolder");

    expect(
      commandHandlers.has("drmCopilotExtension.newActiveFeatureFolder"),
    ).toBe(true);
  });

  it("passes the bundled script path and omits --issue-number when blank", async () => {
    setExecutablePresence({ python: true });
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce("");
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/new_active_feature_folder.py",
    );
    expect(args[1]).toBe("--feature-name");
    expect(args[2]).toBe("blank-pr-context");
    expect(args[3]).toBe("--type");
    expect(args[4]).toBe("feature");
    expect(args[5]).toBe("--work-mode");
    expect(args[6]).toBe("full");
    expect(args).not.toContain("--issue-number");
  });

  it("returns early when the type quick pick is cancelled", async () => {
    showQuickPickMock.mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("returns early when the feature-name input is cancelled", async () => {
    showQuickPickMock.mockResolvedValueOnce("feature");
    showInputBoxMock.mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("returns early when the issue-number input is cancelled", async () => {
    showQuickPickMock.mockResolvedValueOnce("feature");
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce(undefined);

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("returns early when the work-mode quick pick is cancelled", async () => {
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce(undefined);
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce("");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("surfaces a missing python runtime error", async () => {
    setExecutablePresence({ python: false });
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce("");

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );

    await expect(handler()).rejects.toThrow(
      "Python runtime 'python' not found on PATH.",
    );
  });

  it("surfaces non-zero exit failures", async () => {
    setExecutablePresence({ python: true });
    showQuickPickMock
      .mockResolvedValueOnce("feature")
      .mockResolvedValueOnce("full");
    showInputBoxMock
      .mockResolvedValueOnce("blank-pr-context")
      .mockResolvedValueOnce("");
    childProcessMock.spawn.mockReturnValue(createMockProcess(2));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.newActiveFeatureFolder",
    );

    await expect(handler()).rejects.toThrow("Command exited with code 2");
  });
});
