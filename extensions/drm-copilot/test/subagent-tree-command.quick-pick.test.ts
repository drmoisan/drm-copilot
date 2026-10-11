import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";
import type { TerminalWriter } from "../src/terminal-writer";
import type { FileTimes } from "../src/lib/file-system";
import { InMemoryFileSystem } from "./lib/subagent-tree/in-memory-file-system";

type CommandHandler = () => Promise<void> | void;

import {
  CLAUDE_PROJECTS_ROOT,
  MATCHING_DIR,
  WORKSPACE_ROOT,
  FakeFileTimes,
  FakeTerminalWriter,
  addRootSession,
} from "./subagent-tree-command-test-support";

const commandHandlers = new Map<string, CommandHandler>();
type PickItem = { path: string };
type PickResult = Promise<PickItem | undefined>;
type PickFn = (items: readonly PickItem[], options?: unknown) => PickResult;
type RootFn = (...args: unknown[]) => string;
const appendLineMock = jest.fn<(line: string) => void>();
const showQuickPickMock = jest.fn<PickFn>();
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

const getWorkspaceRootMock = jest.fn<RootFn>(() => WORKSPACE_ROOT);
const getClaudeProjectsRootMock = jest.fn<RootFn>(() => CLAUDE_PROJECTS_ROOT);

jest.mock("../src/command-runtime", () => ({
  getWorkspaceRoot: (...args: unknown[]) => getWorkspaceRootMock(...args),
  getClaudeProjectsRoot: (...args: unknown[]) =>
    getClaudeProjectsRootMock(...args),
}));

jest.mock("../src/terminal-writer", () => ({
  // Every test injects its own `createTerminalWriter`; the real factory
  // should never be reached, so a call here indicates a wiring regression.
  createSubagentTreeTerminalWriter: jest.fn(() => {
    throw new Error(
      "createSubagentTreeTerminalWriter should not be invoked: tests always inject createTerminalWriter",
    );
  }),
}));

import { registerSubagentTreeCommand } from "../src/subagent-tree-command";

/** Register a command instance and return its handler, injecting the given fakes. */
function activateAndGetHandler(
  fileSystem: InMemoryFileSystem,
  terminalWriter: TerminalWriter,
  fileTimes: FileTimes = new FakeFileTimes(),
): CommandHandler {
  registerSubagentTreeCommand({
    output: { appendLine: appendLineMock } as never,
    createFileSystem: () => fileSystem,
    createFileTimes: () => fileTimes,
    createTerminalWriter: () => terminalWriter,
  });
  const handler = commandHandlers.get("drmCopilotExtension.showSubagentTree");
  if (!handler) {
    throw new Error(
      "Missing command handler: drmCopilotExtension.showSubagentTree",
    );
  }
  return handler;
}

describe("drm-copilot showSubagentTree command quick pick", () => {
  beforeEach(() => {
    commandHandlers.clear();
    appendLineMock.mockReset();
    showQuickPickMock.mockReset();
    showErrorMessageMock.mockReset();
    getWorkspaceRootMock.mockReset().mockReturnValue(WORKSPACE_ROOT);
    getClaudeProjectsRootMock.mockReset().mockReturnValue(CLAUDE_PROJECTS_ROOT);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("shows quick-pick entries ordered most-recent-first with formatted timestamp labels and matchOnDetail", async () => {
    // Arrange: two candidates with distinct injected mtimes.
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "older.jsonl");
    addRootSession(fileSystem, MATCHING_DIR, "newer.jsonl");
    const olderPath = `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/older.jsonl`;
    const newerPath = `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/newer.jsonl`;
    const fileTimes = new FakeFileTimes(
      new Map([
        [olderPath, 1609459200000], // 2021-01-01 00:00 UTC
        [newerPath, 1640995200000], // 2022-01-01 00:00 UTC
      ]),
    );
    showQuickPickMock.mockResolvedValue(undefined);
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(
      fileSystem,
      terminalWriter,
      fileTimes,
    );

    // Act
    await handler();

    // Assert: entries ordered newest-first with timestamp labels + matchOnDetail.
    expect(showQuickPickMock).toHaveBeenCalledTimes(1);
    const [entries, options] = showQuickPickMock.mock.calls[0] as [
      ReadonlyArray<{ label: string; detail: string; path: string }>,
      { matchOnDetail?: boolean },
    ];
    expect(entries.map((entry) => entry.path)).toEqual([newerPath, olderPath]);
    expect(entries[0]?.label.startsWith("2022-01-01 00:00")).toBe(true);
    expect(entries[1]?.label.startsWith("2021-01-01 00:00")).toBe(true);
    expect(entries[0]?.detail).toBe(newerPath);
    expect(options.matchOnDetail).toBe(true);
  });

  it("maps the selected quick-pick entry back to its full transcript path", async () => {
    // Arrange: two candidates; the user selects the second by full path.
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "alpha.jsonl");
    addRootSession(fileSystem, MATCHING_DIR, "beta.jsonl");
    const betaPath = `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/beta.jsonl`;
    showQuickPickMock.mockImplementation(async (items) =>
      items.find((item) => item.path === betaPath),
    );
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: rendered tree header names the selected candidate's path.
    expect(terminalWriter.writes).toHaveLength(1);
    expect(terminalWriter.writes[0]?.header).toContain(betaPath);
  });

  it("auto-selects a single candidate without prompting even when a FileTimes is injected", async () => {
    // Arrange: exactly one candidate with a readable mtime.
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "solo.jsonl");
    const soloPath = `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/solo.jsonl`;
    const fileTimes = new FakeFileTimes(new Map([[soloPath, 1609459200000]]));
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(
      fileSystem,
      terminalWriter,
      fileTimes,
    );

    // Act
    await handler();

    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(terminalWriter.writes).toHaveLength(1);
    expect(terminalWriter.writes[0]?.header).toContain(soloPath);
  });

  it("keeps the prompt working when one candidate's mtime is unreadable, sorting it last as 'unknown'", async () => {
    // Arrange: one readable candidate and one whose mtime cannot be read
    // (absent from the FakeFileTimes map -> undefined).
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "readable.jsonl");
    addRootSession(fileSystem, MATCHING_DIR, "unreadable.jsonl");
    const readablePath = `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/readable.jsonl`;
    const unreadablePath = `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/unreadable.jsonl`;
    const fileTimes = new FakeFileTimes(
      new Map([[readablePath, 1609459200000]]),
    );
    showQuickPickMock.mockResolvedValue(undefined);
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(
      fileSystem,
      terminalWriter,
      fileTimes,
    );

    // Act
    await handler();

    // Assert: no error; the unreadable candidate sorts last, labeled 'unknown'.
    expect(showErrorMessageMock).not.toHaveBeenCalled();
    expect(showQuickPickMock).toHaveBeenCalledTimes(1);
    const [entries] = showQuickPickMock.mock.calls[0] as [
      ReadonlyArray<{ label: string; path: string }>,
    ];
    expect(entries.map((entry) => entry.path)).toEqual([
      readablePath,
      unreadablePath,
    ]);
    expect(entries[1]?.label.startsWith("unknown")).toBe(true);
  });
});
