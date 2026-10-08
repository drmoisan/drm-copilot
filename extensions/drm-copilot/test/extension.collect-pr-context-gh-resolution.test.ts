import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

/**
 * Composition-root tests for issue #588: the `collectPrContext` command must
 * resolve `gh` from PATH through the default resolver and spawn it with
 * `auth status`. The platform is pinned to `linux` and PATH is set per test,
 * so a Windows run and a Linux CI run take the same branch. Every process
 * spawn and filesystem call goes through module mocks; nothing real runs.
 */

type CommandHandler = (...args: unknown[]) => Promise<void> | void;

const commandHandlers = new Map<string, CommandHandler>();
const registerCommandMock = jest.fn(
  (command: string, handler: CommandHandler) => {
    commandHandlers.set(command, handler);
    return { dispose: jest.fn() };
  },
);

jest.mock(
  "vscode",
  () => ({
    commands: {
      registerCommand: registerCommandMock,
    },
    window: {
      createOutputChannel: jest.fn(() => ({
        appendLine: jest.fn(),
        dispose: jest.fn(),
      })),
      showQuickPick: jest.fn(),
    },
    workspace: {
      workspaceFolders: [{ uri: { fsPath: "/workspace" } }],
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
  statSync: jest.Mock<(filePath: string) => unknown>;
  readdirSync: jest.Mock;
  readFileSync: jest.Mock<(filePath: string) => string>;
  writeFileSync: jest.Mock<(filePath: string, content: string) => void>;
  mkdirSync: jest.Mock;
};

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
  spawnSync: jest.Mock;
};

const COMMAND_ID = "drmCopilotExtension.collectPrContext";

/** Files written through the mocked node:fs during a collector run. */
const writtenFiles = new Map<string, string>();

/** Serve an empty repo tree and capture artifact writes for read-back. */
function setCollectorFileSystemState(): void {
  writtenFiles.clear();
  fsMock.statSync.mockImplementation((filePath: string) => {
    throw new Error(`ENOENT: ${filePath}`);
  });
  fsMock.readdirSync.mockReturnValue([]);
  fsMock.readFileSync.mockImplementation((filePath: string) => {
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

/** Script git diff output and a not-authenticated `gh auth status`. */
function setSpawnSyncState(): void {
  childProcessMock.spawnSync.mockImplementation((...rawArgs: unknown[]) => {
    const args = (rawArgs[1] as ReadonlyArray<string> | undefined) ?? [];
    const joined = args.join(" ");
    if (joined.startsWith("diff --name-status")) {
      return {
        status: 0,
        stdout: Buffer.from("M\tsrc/example.ts"),
        stderr: Buffer.from(""),
      };
    }
    if (joined.startsWith("diff --numstat")) {
      return {
        status: 0,
        stdout: Buffer.from("1\t0\tsrc/example.ts"),
        stderr: Buffer.from(""),
      };
    }
    if (joined === "auth status") {
      return {
        status: 1,
        stdout: Buffer.from(""),
        stderr: Buffer.from("not logged in"),
      };
    }
    return { status: 0, stdout: Buffer.from(""), stderr: Buffer.from("") };
  });
}

function activateAndGetHandler(): CommandHandler {
  const context = {
    extensionUri: { fsPath: "/extension" },
    subscriptions: [] as Array<{ dispose(): void }>,
  };
  activate(context as never);
  const handler = commandHandlers.get(COMMAND_ID);
  if (!handler) {
    throw new Error(`Missing command handler: ${COMMAND_ID}`);
  }
  return handler;
}

describe("drm-copilot collectPrContext gh resolution", () => {
  let originalPlatform: PropertyDescriptor | undefined;
  let originalPath: string | undefined;
  let originalPathExt: string | undefined;

  beforeEach(() => {
    originalPlatform = Object.getOwnPropertyDescriptor(process, "platform");
    originalPath = process.env["PATH"];
    originalPathExt = process.env["PATHEXT"];
    Object.defineProperty(process, "platform", { value: "linux" });
    delete process.env["PATHEXT"];
    commandHandlers.clear();
    setCollectorFileSystemState();
    setSpawnSyncState();
  });

  afterEach(() => {
    if (originalPlatform) {
      Object.defineProperty(process, "platform", originalPlatform);
    }
    if (originalPath === undefined) {
      delete process.env["PATH"];
    } else {
      process.env["PATH"] = originalPath;
    }
    if (originalPathExt === undefined) {
      delete process.env["PATHEXT"];
    } else {
      process.env["PATHEXT"] = originalPathExt;
    }
    jest.clearAllMocks();
  });

  it("collectPrContext spawns the PATH-resolved gh with auth status", async () => {
    // Arrange: gh exists only in /opt/gh-bin, which is on PATH.
    process.env["PATH"] = "/opt/gh-bin";
    fsMock.existsSync.mockImplementation(
      (filePath: string) => filePath === "/opt/gh-bin/gh",
    );
    const handler = activateAndGetHandler();

    // Act
    await handler("--base", "main");

    // Assert: the resolved gh was spawned with `auth status`.
    expect(childProcessMock.spawnSync).toHaveBeenCalledWith(
      "/opt/gh-bin/gh",
      ["auth", "status"],
      expect.anything(),
    );
  });

  it("collectPrContext does not spawn gh when no PATH directory contains it", async () => {
    // Arrange: PATH has one directory, and no file exists anywhere.
    process.env["PATH"] = "/opt/empty-bin";
    fsMock.existsSync.mockReturnValue(false);
    const handler = activateAndGetHandler();

    // Act
    await handler("--base", "main");

    // Assert: no spawn targeted a gh executable.
    const executables = childProcessMock.spawnSync.mock.calls.map(
      (call) => call[0] as string,
    );
    expect(executables.some((exe) => exe.endsWith("/gh"))).toBe(false);
  });
});
