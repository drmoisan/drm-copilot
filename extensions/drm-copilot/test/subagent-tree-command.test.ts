import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

type CommandHandler = () => Promise<void> | void;

const commandHandlers = new Map<string, CommandHandler>();
const appendLineMock = jest.fn<(line: string) => void>();
const showOutputMock = jest.fn();
const showQuickPickMock = jest.fn();
const showErrorMessageMock = jest.fn();
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
      showQuickPick: showQuickPickMock,
      showErrorMessage: showErrorMessageMock,
    },
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

jest.mock("../src/command-runtime", () => ({
  getWorkspaceRoot: jest.fn(() => "C:/workspace"),
}));

import * as fs from "node:fs";
import { registerSubagentTreeCommand } from "../src/subagent-tree-command";

const readdirSyncMock = fs.readdirSync as jest.MockedFunction<
  typeof fs.readdirSync
>;
const readFileSyncMock = fs.readFileSync as jest.MockedFunction<
  typeof fs.readFileSync
>;

/** Build a minimal Dirent-like entry for mocking readdirSync results. */
function dirent(name: string, isDir: boolean): fs.Dirent {
  return {
    name,
    isDirectory: () => isDir,
    isFile: () => !isDir,
  } as unknown as fs.Dirent;
}

/**
 * Configure `readdirSync` to model a fixed workspace tree:
 * `C:/workspace/.claude/projects/proj/<sessionEntries>`.
 *
 * @param sessionEntries Dirent entries returned for the `proj` directory.
 */
function setWorkspaceTree(sessionEntries: readonly fs.Dirent[]): void {
  readdirSyncMock.mockImplementation((dir) => {
    const path = String(dir);
    if (path.endsWith("workspace")) {
      return [dirent(".claude", true)] as unknown as ReturnType<
        typeof fs.readdirSync
      >;
    }
    if (path.endsWith(".claude")) {
      return [dirent("projects", true)] as unknown as ReturnType<
        typeof fs.readdirSync
      >;
    }
    if (path.endsWith("projects")) {
      return [dirent("proj", true)] as unknown as ReturnType<
        typeof fs.readdirSync
      >;
    }
    if (path.endsWith("proj")) {
      return [...sessionEntries] as unknown as ReturnType<
        typeof fs.readdirSync
      >;
    }
    // Any other directory (e.g. a session's `subagents` folder) has no
    // entries in these fixtures, matching the empty-subagents scan path.
    return [] as unknown as ReturnType<typeof fs.readdirSync>;
  });
}

function activateAndGetHandler(): CommandHandler {
  registerSubagentTreeCommand({
    output: {
      appendLine: appendLineMock,
      show: showOutputMock,
    } as never,
  });
  const handler = commandHandlers.get("drmCopilotExtension.showSubagentTree");
  if (!handler) {
    throw new Error(
      "Missing command handler: drmCopilotExtension.showSubagentTree",
    );
  }
  return handler;
}

describe("drm-copilot showSubagentTree command", () => {
  beforeEach(() => {
    commandHandlers.clear();
    appendLineMock.mockReset();
    showOutputMock.mockReset();
    showQuickPickMock.mockReset();
    showErrorMessageMock.mockReset();
    readdirSyncMock.mockReset();
    readFileSyncMock.mockReset();
    readFileSyncMock.mockReturnValue("");
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("reports an error and does not throw when zero root sessions are found", async () => {
    // Arrange: an empty `.claude/projects` directory (no `proj` entry).
    readdirSyncMock.mockImplementation((dir) => {
      const path = String(dir);
      if (path.endsWith("workspace")) {
        return [dirent(".claude", true)] as unknown as ReturnType<
          typeof fs.readdirSync
        >;
      }
      if (path.endsWith(".claude")) {
        return [dirent("projects", true)] as unknown as ReturnType<
          typeof fs.readdirSync
        >;
      }
      return [] as unknown as ReturnType<typeof fs.readdirSync>;
    });
    const handler = activateAndGetHandler();

    // Act
    await handler();

    // Assert: no throw (implicit — handler resolved), an error is reported.
    expect(showErrorMessageMock).toHaveBeenCalledTimes(1);
    expect(showQuickPickMock).not.toHaveBeenCalled();
    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(
      logs.some((line) => line.includes("No root session transcripts found")),
    ).toBe(true);
  });

  it("auto-selects a single discovered root session without prompting", async () => {
    // Arrange: exactly one `.jsonl` root session under `proj`.
    setWorkspaceTree([dirent("session-1.jsonl", false)]);
    const handler = activateAndGetHandler();

    // Act
    await handler();

    // Assert: no quick-pick prompt; the rendered tree is written to output.
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(showErrorMessageMock).not.toHaveBeenCalled();
    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(logs.some((line) => line.includes("session-1.jsonl"))).toBe(true);
    expect(logs.some((line) => line.includes("root ·"))).toBe(true);
  });

  it("prompts via showQuickPick among multiple candidates and renders the one selected", async () => {
    // Arrange: two `.jsonl` root sessions under `proj`.
    setWorkspaceTree([
      dirent("session-1.jsonl", false),
      dirent("session-2.jsonl", false),
    ]);
    showQuickPickMock.mockImplementation(async (items: ReadonlyArray<string>) =>
      items.find((item) => item.includes("session-2.jsonl")),
    );
    const handler = activateAndGetHandler();

    // Act
    await handler();

    // Assert: the quick pick ran, and the selected session (session-2) was
    // the one passed through to the renderer.
    expect(showQuickPickMock).toHaveBeenCalledTimes(1);
    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(logs.some((line) => line.includes("session-2.jsonl"))).toBe(true);
    expect(logs.some((line) => line.includes("session-1.jsonl"))).toBe(false);
  });
});
