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
const showQuickPickMock = jest.fn();
const registerCommandMock = jest.fn(
  (command: string, handler: CommandHandler) => {
    commandHandlers.set(command, handler);
    return { dispose: jest.fn() };
  },
);

let quickPickResultLabel: string | undefined = "origin/main";

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

import { activate, detectRuntime } from "../src/extension";

const fsMock = jest.requireMock("node:fs") as {
  existsSync: jest.MockedFunction<(filePath: string) => boolean>;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

function setGitBranchDiscoveryState(input: {
  readonly originHead?: string;
  readonly remoteRefs?: ReadonlyArray<string>;
  readonly localRefs?: ReadonlyArray<string>;
}): void {
  const originHead = input.originHead ?? "origin/main";
  const remoteRefs = input.remoteRefs ?? ["origin/HEAD", "origin/main"];
  const localRefs = input.localRefs ?? ["main"];

  childProcessMock.spawnSync.mockImplementation((...rawArgs: unknown[]) => {
    const args = (rawArgs[1] as ReadonlyArray<string> | undefined) ?? [];
    const joined = args.join(" ");
    if (joined.includes("symbolic-ref") && joined.includes("origin/HEAD")) {
      return {
        status: originHead.length > 0 ? 0 : 1,
        stdout: originHead,
        stderr: originHead.length > 0 ? "" : "origin/HEAD not set",
      };
    }

    if (
      joined.includes("for-each-ref") &&
      joined.includes("refs/remotes/origin")
    ) {
      return {
        status: 0,
        stdout: remoteRefs.join("\n"),
        stderr: "",
      };
    }

    if (joined.includes("for-each-ref") && joined.includes("refs/heads")) {
      return {
        status: 0,
        stdout: localRefs.join("\n"),
        stderr: "",
      };
    }

    return {
      status: 0,
      stdout: "",
      stderr: "",
    };
  });

  showQuickPickMock.mockImplementation(async (...rawArgs: unknown[]) => {
    const items =
      (rawArgs[0] as ReadonlyArray<{ label: string }> | undefined) ?? [];
    if (!quickPickResultLabel) {
      return undefined;
    }

    const matched = items.find((item) => item.label === quickPickResultLabel);
    return matched ?? items[0];
  });
}

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

function createMockProcessWithStderr(
  exitCode: number,
  stderrLine: string,
): MockChildProcess {
  const processMock = new EventEmitter() as MockChildProcess;
  processMock.stdout = new EventEmitter();
  processMock.stderr = new EventEmitter();
  process.nextTick(() => {
    processMock.stderr.emit("data", Buffer.from(stderrLine, "utf-8"));
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

describe("drm-copilot command behavior", () => {
  beforeEach(() => {
    process.env.PATH = "C:/bin";
    process.env.PATHEXT = ".EXE;.CMD";
    commandHandlers.clear();
    appendLineMock.mockReset();
    registerCommandMock.mockClear();
    childProcessMock.spawn.mockReset();
    childProcessMock.spawnSync.mockReset();
    showQuickPickMock.mockReset();
    workspaceFoldersState = [{ uri: { fsPath: "C:/workspace" } }];
    quickPickResultLabel = "origin/main";
    setGitBranchDiscoveryState({
      originHead: "origin/main",
      remoteRefs: ["origin/HEAD", "origin/main", "origin/develop"],
      localRefs: ["main"],
    });
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("activate registers drmCopilotExtension.helloPython", () => {
    activateAndGetHandler("drmCopilotExtension.helloPython");

    expect(commandHandlers.has("drmCopilotExtension.helloPython")).toBe(true);
  });

  it("activate registers drmCopilotExtension.helloPowerShell", () => {
    activateAndGetHandler("drmCopilotExtension.helloPowerShell");

    expect(commandHandlers.has("drmCopilotExtension.helloPowerShell")).toBe(
      true,
    );
  });

  it("registers collectCommitContext", () => {
    activateAndGetHandler("drmCopilotExtension.collectCommitContext");

    expect(
      commandHandlers.has("drmCopilotExtension.collectCommitContext"),
    ).toBe(true);
  });

  it("registers collectPrContext", () => {
    activateAndGetHandler("drmCopilotExtension.collectPrContext");

    expect(commandHandlers.has("drmCopilotExtension.collectPrContext")).toBe(
      true,
    );
  });

  it("registers pushDownCopilotCustomizations", () => {
    activateAndGetHandler("drmCopilotExtension.pushDownCopilotCustomizations");

    expect(
      commandHandlers.has("drmCopilotExtension.pushDownCopilotCustomizations"),
    ).toBe(true);
  });

  it("no workspace throws clear no-workspace error", async () => {
    workspaceFoldersState = undefined;
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
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

  it("collectCommitContext fails when no workspace folder is open", async () => {
    workspaceFoldersState = undefined;
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow("No workspace folder is open.");
  });

  it("collectCommitContext fails when python runtime is unavailable", async () => {
    setExecutablePresence({ python: false });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow(
      "Python runtime 'python' not found on PATH.",
    );
  });

  it("helloPython uses bundled extension script path", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe("C:/extension/resources/templates/hello_python.py");
  });

  it("helloPowerShell uses bundled extension script path", async () => {
    setExecutablePresence({ pwsh: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.helloPowerShell",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[args.length - 1]).toBe(
      "C:/extension/resources/templates/hello_pwsh.ps1",
    );
  });

  it("collectCommitContext passes explicit output args to bundled script", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/collect_commit_context.py",
    );
    expect(args[1]).toBe("--output");
    expect(args[2]).toBe("artifacts/commit_context.txt");
  });

  it("collectCommitContext runs with workspace cwd", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await handler();

    const [, , options] = childProcessMock.spawn.mock.calls[0] as [
      string,
      string[],
      { cwd: string; shell: boolean },
    ];
    expect(options.cwd).toBe("C:/workspace");
    expect(options.shell).toBe(false);
  });

  it("collectCommitContext logs and throws on non-zero exit", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(2));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow("Command exited with code 2");

    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) =>
        line.includes(
          "[drmCopilotExtension.collectCommitContext] command failure",
        ),
      ),
    ).toBe(true);
  });

  it("collectCommitContext reports git failure details from collector stderr", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(
      createMockProcessWithStderr(1, "git executable not found on PATH"),
    );

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectCommitContext",
    );
    await expect(handler()).rejects.toThrow("Command exited with code 1");

    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) => line.includes("git executable not found on PATH")),
    ).toBe(true);
  });

  it("helloPython uses explicit executable and argv arrays", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
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

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const scriptPath = args[0];
    expect(scriptPath.includes("/resources/templates/")).toBe(true);
    expect(scriptPath.includes("C:/workspace/hello_python.py")).toBe(false);
  });

  it("handlers log runtime probe start success failure to Scaffold Utils output channel", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(1));

    const handler = activateAndGetHandler("drmCopilotExtension.helloPython");
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

    const handler = activateAndGetHandler(
      "drmCopilotExtension.helloPowerShell",
    );
    await handler();

    const [executable, args, options] = childProcessMock.spawn.mock
      .calls[0] as [string, string[], { shell: boolean }];
    expect(typeof executable).toBe("string");
    expect(Array.isArray(args)).toBe(true);
    expect(options.shell).toBe(false);
    expect(executable.includes(" ")).toBe(false);
  });
});
