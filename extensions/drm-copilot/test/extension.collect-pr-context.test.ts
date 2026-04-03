import { EventEmitter } from "node:events";
import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

type CommandHandler = (...args: unknown[]) => Promise<void> | void;
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

import { activate } from "../src/extension";

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

describe("drm-copilot collectPrContext command behavior", () => {
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

  it("collectPrContext cancels before spawn", async () => {
    quickPickResultLabel = undefined;
    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );

    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) =>
        line.includes(
          "[drmCopilotExtension.collectPrContext] branch selection canceled by user",
        ),
      ),
    ).toBe(true);
  });

  it("collectPrContext fails when no workspace folder is open", async () => {
    workspaceFoldersState = undefined;

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await expect(handler()).rejects.toThrow("No workspace folder is open.");
  });

  it("collectPrContext selects deterministic default base branch", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    setGitBranchDiscoveryState({
      originHead: "origin/main",
      remoteRefs: ["origin/HEAD", "origin/develop", "origin/main"],
    });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler();

    const firstQuickPickCall = showQuickPickMock.mock.calls[0] as [
      Array<{ label: string; description: string }>,
    ];
    const labels = firstQuickPickCall[0].map((item) => item.label);
    expect(labels[0]).toBe("origin/main");
    const defaultItem = firstQuickPickCall[0].find(
      (item) => item.label === "origin/main",
    );
    expect(defaultItem?.description).toBe("default");
  });

  it("collectPrContext passes base and artifact args", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));
    setGitBranchDiscoveryState({
      originHead: "origin/main",
      remoteRefs: ["origin/HEAD", "origin/main", "origin/release/1.0"],
    });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/collect_pr_context.py",
    );
    expect(args).toContain("--base");
    expect(args).toContain("--repo-root");
    expect(args).toContain("C:/workspace");
    expect(args).toContain("--out");
    expect(args).toContain("artifacts/pr_context.summary.txt");
    expect(args).toContain("--appendix-out");
    expect(args).toContain("artifacts/pr_context.appendix.txt");
  });

  it("collectPrContext direct invocation uses explicit base without prompting", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler("--base", "origin/release/1.0");

    expect(showQuickPickMock).not.toHaveBeenCalled();
    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args).toContain("--base");
    expect(args).toContain("origin/release/1.0");
  });

  it("collectPrContext git branch discovery failure", async () => {
    childProcessMock.spawnSync.mockImplementation((...rawArgs: unknown[]) => {
      const args = (rawArgs[1] as ReadonlyArray<string> | undefined) ?? [];
      const joined = args.join(" ");
      if (
        joined.includes("for-each-ref") &&
        joined.includes("refs/remotes/origin")
      ) {
        return {
          status: 2,
          stdout: "",
          stderr: "fatal: cannot list refs",
        };
      }

      return {
        status: 0,
        stdout: "origin/main",
        stderr: "",
      };
    });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await expect(handler()).rejects.toThrow("Git command failed (2)");

    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) =>
        line.includes(
          "[drmCopilotExtension.collectPrContext] branch discovery failure",
        ),
      ),
    ).toBe(true);
    expect(logs.some((line) => line.includes("git command failure"))).toBe(
      true,
    );
  });

  it("collectPrContext non-zero collector exit diagnostics", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(
      createMockProcessWithStderr(7, "collector crashed: simulated stderr"),
    );

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await expect(handler()).rejects.toThrow("Command exited with code 7");

    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) => line.includes("collector crashed: simulated stderr")),
    ).toBe(true);
    expect(
      logs.some((line) =>
        line.includes("[drmCopilotExtension.collectPrContext] command failure"),
      ),
    ).toBe(true);
  });

  it("collectPrContext executes bundled wrapper script", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );

    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    expect(args[0]).toBe(
      "C:/extension/resources/templates/collect_pr_context.py",
    );
  });

  it("collectPrContext always propagates --repo-root with workspace path", async () => {
    setExecutablePresence({ python: true });
    childProcessMock.spawn.mockReturnValue(createMockProcess(0));

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler();

    const [, args] = childProcessMock.spawn.mock.calls[0] as [string, string[]];
    const repoRootIndex = args.indexOf("--repo-root");
    expect(repoRootIndex).toBeGreaterThan(-1);
    expect(args[repoRootIndex + 1]).toBe("C:/workspace");
  });
});
