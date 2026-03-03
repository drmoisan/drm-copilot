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
}));

import { activate, detectRuntime } from "../src/extension";

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

function setExecutablePresence(presence: {
  readonly python?: boolean;
  readonly pwsh?: boolean;
  readonly powershell?: boolean;
}): void {
  fsMock.existsSync.mockImplementation((filePath: string) => {
    const lowerPath = filePath.toLowerCase();
    if (lowerPath.includes("python")) {
      return presence.python ?? false;
    }

    if (lowerPath.includes("pwsh")) {
      return presence.pwsh ?? false;
    }

    if (lowerPath.includes("powershell")) {
      return presence.powershell ?? false;
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

describe("scaffold-extension command behavior", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    commandHandlers.clear();
    appendLineMock.mockReset();
    registerCommandMock.mockClear();
    childProcessMock.spawn.mockReset();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("activate registers scaffoldExtension.helloPython", () => {
    activateAndGetHandler("scaffoldExtension.helloPython");

    expect(commandHandlers.has("scaffoldExtension.helloPython")).toBe(true);
  });

  it("activate registers scaffoldExtension.helloPowerShell", () => {
    activateAndGetHandler("scaffoldExtension.helloPowerShell");

    expect(commandHandlers.has("scaffoldExtension.helloPowerShell")).toBe(true);
  });

  it("no workspace throws clear no-workspace error", async () => {
    workspaceFoldersState = undefined;
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("scaffoldExtension.helloPython");
    await expect(handler()).rejects.toThrow("No workspace");
  });

  it("detectRuntime probes pwsh then powershell", () => {
    setExecutablePresence({ pwsh: true, powershell: true });

    const runtime = detectRuntime("powershell");
    expect(runtime.executable).toBe("pwsh");
  });

  it("missing PowerShell returns actionable runtime error when pwsh and powershell are unavailable", () => {
    setExecutablePresence({ pwsh: false, powershell: false });

    expect(() => detectRuntime("powershell")).toThrow(
      "PowerShell runtime not found. Expected 'pwsh' or 'powershell' on PATH.",
    );
  });

  it("detectRuntime returns named Python error when python missing", () => {
    setExecutablePresence({ python: false });

    expect(() => detectRuntime("python")).toThrow(
      "Python runtime 'python' not found on PATH.",
    );
  });

  it("helloPython uses bundled extension script path", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("scaffoldExtension.helloPython");
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe("C:/extension/resources/templates/hello_python.py");
  });

  it("helloPowerShell uses bundled extension script path", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("scaffoldExtension.helloPowerShell");
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[args.length - 1]).toBe(
      "C:/extension/resources/templates/hello_pwsh.ps1",
    );
  });

  it("helloPython uses explicit executable and argv arrays", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("scaffoldExtension.helloPython");
    await handler();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { shell: boolean; cwd: string }];
    expect(executable).toBe("python");
    expect(Array.isArray(args)).toBe(true);
    expect(options.shell).toBe(false);
  });

  it("hello commands do not copy hello scripts into workspace root", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("scaffoldExtension.helloPython");
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const scriptPath = args[0];
    expect(scriptPath.includes("/resources/templates/")).toBe(true);
    expect(scriptPath.includes("C:/workspace/hello_python.py")).toBe(false);
  });

  it("handlers log runtime probe start success failure to Scaffold Utils output channel", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(1));

    const handler = activateAndGetHandler("scaffoldExtension.helloPython");
    await expect(handler()).rejects.toThrow("Command exited with code 1");

    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(logs.some((line) => line.includes("runtime probe start"))).toBe(
      true,
    );
    expect(logs.some((line) => line.includes("runtime probe success"))).toBe(
      true,
    );
    expect(logs.some((line) => line.includes("command failure"))).toBe(true);
  });

  it("subprocess calls use argv arrays and never shell-concatenated command strings", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("scaffoldExtension.helloPowerShell");
    await handler();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { shell: boolean }];
    expect(typeof executable).toBe("string");
    expect(Array.isArray(args)).toBe(true);
    expect(options.shell).toBe(false);
    expect(executable.includes(" ")).toBe(false);
  });
});
