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
      joinPath: jest.fn((base: { fsPath: string }, ...segments: string[]) => ({
        fsPath: `${base.fsPath}/${segments.join("/")}`,
      })),
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
  statSync: jest.fn(),
  readdirSync: jest.fn(),
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
  statSync: jest.Mock;
  readdirSync: jest.Mock;
  readFileSync: jest.Mock;
  writeFileSync: jest.Mock;
  mkdirSync: jest.Mock;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

/** Files written through the mocked node:fs during a collector run. */
const writtenFiles = new Map<string, string>();

/** Workspace-joined summary artifact path for the `C:/workspace` fixture. */
const WORKSPACE_SUMMARY_PATH = "C:/workspace/artifacts/pr_context.summary.txt";
/** Workspace-joined appendix artifact path for the `C:/workspace` fixture. */
const WORKSPACE_APPENDIX_PATH =
  "C:/workspace/artifacts/pr_context.appendix.txt";

/**
 * Configure the node:fs mock so the in-process collector's RealFileSystem can
 * read the (empty) repo tree and capture the artifact writes. Branch-discovery
 * uses the separate `existsSync` python-presence mock, so this preserves that.
 */
function setCollectorFileSystemState(): void {
  writtenFiles.clear();
  fsMock.statSync.mockImplementation((filePath: string) => {
    // No directories exist in this hermetic fixture, so statSync raises like a
    // missing path; RealFileSystem treats that as "not a directory".
    throw new Error(`ENOENT: ${filePath}`);
  });
  fsMock.readdirSync.mockReturnValue([]);
  fsMock.readFileSync.mockImplementation((filePath: string) => {
    // Serve reads consistently with writes. The service call verifies each
    // write by reading the file back, so a double that records a write but
    // refuses to serve the read would report a false verification failure.
    const written = writtenFiles.get(filePath);
    if (written !== undefined) {
      return written;
    }
    throw new Error(`ENOENT: ${filePath}`);
  });
  fsMock.mkdirSync.mockReturnValue(undefined);
  fsMock.writeFileSync.mockImplementation(
    (filePath: string, content: string) => {
      writtenFiles.set(filePath, content);
    },
  );
}

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
    setCollectorFileSystemState();
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

  it("collectPrContext runs in-process and writes both artifacts without spawning Python", async () => {
    setExecutablePresence({ python: true });
    setGitBranchDiscoveryState({
      originHead: "origin/main",
      remoteRefs: ["origin/HEAD", "origin/main", "origin/release/1.0"],
    });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler();

    // No Python (or any) process is spawned via child_process.spawn.
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    // The in-process collector wrote both artifacts through node:fs, at the
    // workspace-joined paths.
    expect(writtenFiles.has(WORKSPACE_SUMMARY_PATH)).toBe(true);
    expect(writtenFiles.has(WORKSPACE_APPENDIX_PATH)).toBe(true);
    // The summary references the selected base.
    expect(writtenFiles.get(WORKSPACE_SUMMARY_PATH)).toContain(
      "Base ref (requested): origin/main",
    );
  });

  it("collectPrContext direct invocation uses explicit base without prompting", async () => {
    setExecutablePresence({ python: true });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler("--base", "origin/release/1.0");

    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    // The in-process collector used the explicit base in the written summary.
    expect(writtenFiles.get(WORKSPACE_SUMMARY_PATH)).toContain(
      "Base ref (requested): origin/release/1.0",
    );
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

  it("collectPrContext emits the in-process collector log lines", async () => {
    setExecutablePresence({ python: true });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) =>
        line.includes(
          `Wrote context summary to: ${WORKSPACE_SUMMARY_PATH}`,
        ),
      ),
    ).toBe(true);
    expect(
      logs.some((line) =>
        line.includes(
          `Wrote context appendix to: ${WORKSPACE_APPENDIX_PATH}`,
        ),
      ),
    ).toBe(true);
  });

  it("collectPrContext does not spawn the bundled Python wrapper script", async () => {
    setExecutablePresence({ python: true });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );

    await handler();

    // The in-process port never spawns resources/templates/collect_pr_context.py.
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    const spawnTargets = childProcessMock.spawn.mock.calls.map((call) =>
      String((call as unknown[])[0]),
    );
    expect(
      spawnTargets.some((target) => target.includes("collect_pr_context.py")),
    ).toBe(false);
  });

  it("collectPrContext writes artifacts against the workspace root in-process", async () => {
    setExecutablePresence({ python: true });

    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler();

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
    // The collector wrote both artifacts via node:fs, against the workspace
    // root the command was invoked for.
    expect([...writtenFiles.keys()].sort()).toEqual([
      WORKSPACE_APPENDIX_PATH,
      WORKSPACE_SUMMARY_PATH,
    ]);
  });

  it("collectPrContext passes workspace-joined paths to the node:fs write boundary", async () => {
    // Arrange
    setExecutablePresence({ python: true });

    // Act
    const handler = activateAndGetHandler(
      "drmCopilotExtension.collectPrContext",
    );
    await handler();

    // Assert: the recorded write arguments are exactly the two workspace-joined
    // artifact paths. This observes the exact argument RealFileSystem hands to
    // Node, which is where a repository-relative path resolves against the
    // server process cwd rather than the workspace.
    const writeArguments = [...writtenFiles.keys()].sort();
    expect(writeArguments).toEqual([
      WORKSPACE_APPENDIX_PATH,
      WORKSPACE_SUMMARY_PATH,
    ]);
    // No recorded write argument is a repository-relative path.
    expect(
      writeArguments.filter((value) => !value.startsWith("C:/workspace/")),
    ).toEqual([]);
  });
});
