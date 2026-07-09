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

/** Absolute workspace root used across scenarios (mirrors a real Windows cwd). */
const WORKSPACE_ROOT = "C:\\Users\\DanMoisan\\repos\\drm-copilot";
/** Fake resolved user-global Claude projects directory (distinct from any
 * path under `WORKSPACE_ROOT`, so tests fail loudly if discovery regresses
 * to scanning the workspace root instead). */
const CLAUDE_PROJECTS_ROOT = "/claude-root/projects";
/** Encoded directory name matching `WORKSPACE_ROOT`, using a lowercase
 * drive-letter segment to exercise the case-insensitive matching rule. */
const MATCHING_DIR = "c--users-danmoisan-repos-drm-copilot";

const commandHandlers = new Map<string, CommandHandler>();
const appendLineMock = jest.fn<(line: string) => void>();
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

const getWorkspaceRootMock = jest.fn(() => WORKSPACE_ROOT);
const getClaudeProjectsRootMock = jest.fn(() => CLAUDE_PROJECTS_ROOT);

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

/** In-test `TerminalWriter` fake capturing writes and reveal calls. */
class FakeTerminalWriter implements TerminalWriter {
  readonly writes: Array<{ header: string; body: string }> = [];
  revealCallCount = 0;

  write(header: string, body: string): void {
    this.writes.push({ header, body });
  }

  reveal(): void {
    this.revealCallCount += 1;
  }
}

/**
 * In-test `FileTimes` fake backed by a path->mtime map. Any path not present
 * in the map resolves to `undefined`, modeling an unreadable mtime (stat
 * failure), which the production code renders as the timestamp `unknown` and
 * sorts last.
 */
class FakeFileTimes implements FileTimes {
  constructor(
    private readonly times: ReadonlyMap<string, number | undefined> = new Map(),
  ) {}

  getModifiedTimeMs(path: string): number | undefined {
    return this.times.get(path);
  }
}

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

/** Build a root transcript line containing one `Agent` tool-use block. */
function agentToolUseLine(model: string, toolUseId: string): string {
  return JSON.stringify({
    message: {
      model,
      content: [{ type: "tool_use", name: "Agent", id: toolUseId }],
    },
  });
}

/** Register one root-session transcript file under a matched Claude projects directory. */
function addRootSession(
  fileSystem: InMemoryFileSystem,
  directoryName: string,
  sessionFileName: string,
): void {
  fileSystem.addFile(
    `${CLAUDE_PROJECTS_ROOT}/${directoryName}/${sessionFileName}`,
    "",
  );
}

describe("drm-copilot showSubagentTree command", () => {
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

  it("resolves candidates from the user-global Claude projects directory rather than the workspace root", async () => {
    // Arrange: the only session fixture lives under the fake user-global
    // root; nothing is registered under WORKSPACE_ROOT.
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "session-1.jsonl");
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: discovery succeeded using the injected user-global root.
    expect(showErrorMessageMock).not.toHaveBeenCalled();
    expect(terminalWriter.writes).toHaveLength(1);
    expect(terminalWriter.writes[0]?.header).toContain(
      `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/session-1.jsonl`,
    );
  });

  it("auto-selects a single discovered root session without prompting", async () => {
    // Arrange: exactly one `.jsonl` root session under the matched directory.
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "session-1.jsonl");
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: no quick-pick prompt; the rendered tree is written once.
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(showErrorMessageMock).not.toHaveBeenCalled();
    expect(terminalWriter.writes).toHaveLength(1);
  });

  it("prompts via showQuickPick among multiple candidates and renders the one selected", async () => {
    // Arrange: two `.jsonl` root sessions under the matched directory.
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "session-1.jsonl");
    addRootSession(fileSystem, MATCHING_DIR, "session-2.jsonl");
    showQuickPickMock.mockImplementation(
      async (items: ReadonlyArray<{ path: string }>) =>
        items.find((item) => item.path.includes("session-2.jsonl")),
    );
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: the quick pick ran, and the selected session (session-2) was
    // the one rendered.
    expect(showQuickPickMock).toHaveBeenCalledTimes(1);
    expect(terminalWriter.writes).toHaveLength(1);
    expect(terminalWriter.writes[0]?.header).toContain("session-2.jsonl");
    expect(terminalWriter.writes[0]?.header).not.toContain("session-1.jsonl");
  });

  it("excludes flattened /subagents/ transcripts from candidates", async () => {
    // Arrange: one root session plus a flattened subagent transcript sibling.
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "session-1.jsonl");
    fileSystem.addFile(
      `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/session-1/subagents/agent-aaa.jsonl`,
      "",
    );
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: only the root session is a candidate; no prompt was needed.
    expect(showQuickPickMock).not.toHaveBeenCalled();
    expect(terminalWriter.writes[0]?.header).toContain("session-1.jsonl");
    expect(terminalWriter.writes[0]?.header).not.toContain("subagents");
  });

  it("names the real resolved user-global search location in the zero-candidates error message", async () => {
    // Arrange: no session fixtures registered anywhere.
    const fileSystem = new InMemoryFileSystem();
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: the error names the real resolved location, not the old
    // relative-glob string, and nothing was written to the terminal seam.
    expect(showErrorMessageMock).toHaveBeenCalledTimes(1);
    const [message] = showErrorMessageMock.mock.calls[0] as [string];
    expect(message).toContain(CLAUDE_PROJECTS_ROOT);
    expect(message).not.toContain(".claude/projects/**/*.jsonl");
    expect(terminalWriter.writes).toHaveLength(0);
  });

  it("writes the header plus full formatTree output to the terminal seam and reveals it", async () => {
    // Arrange
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "session-1.jsonl");
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: the header line matches the established format, the body is
    // the full rendered tree, and the terminal was revealed exactly once.
    expect(terminalWriter.writes).toHaveLength(1);
    const [write] = terminalWriter.writes;
    expect(write?.header).toBe(
      `[drmCopilotExtension.showSubagentTree] subagent tree for ${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/session-1.jsonl:`,
    );
    expect(write?.body).toContain("root ·");
    expect(terminalWriter.revealCallCount).toBe(1);
  });

  it("writes a multi-line formatTree body (root plus a subagent child) to the terminal seam", async () => {
    // Arrange: a root session transcript spawning one subagent, registered
    // under a `/subagents/` path segment (mirroring the fixture-construction
    // pattern in test/lib/subagent-tree/tree-assembler.test.ts and
    // test/lib/subagent-tree/index.test.ts), so formatTree renders more than
    // one line.
    const fileSystem = new InMemoryFileSystem();
    const sessionPath = `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/session-multi.jsonl`;
    fileSystem.addFile(
      sessionPath,
      agentToolUseLine("claude-sonnet-5", "toolu_child"),
    );
    fileSystem.addFile(
      `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/session-multi/subagents/agent-child.meta.json`,
      JSON.stringify({
        agentType: "atomic-executor",
        description: "Execute plan",
        toolUseId: "toolu_child",
        spawnDepth: 1,
      }),
    );
    fileSystem.addFile(
      `${CLAUDE_PROJECTS_ROOT}/${MATCHING_DIR}/session-multi/subagents/agent-child.jsonl`,
      JSON.stringify({ message: { model: "claude-sonnet-5" } }),
    );
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: the captured body is multi-line (embeds a `\n`) and matches
    // the exact joined string formatTree produces for this fixture: the
    // root line followed by the indented subagent-child line.
    expect(terminalWriter.writes).toHaveLength(1);
    const [write] = terminalWriter.writes;
    expect(write?.body).toContain("\n");
    expect(write?.body).toBe(
      "root · [claude-sonnet-5] · 0 · \n  atomic-executor · [claude-sonnet-5] · 1 · Execute plan",
    );
  });

  it("reuses the same terminal-writer instance across two consecutive invocations", async () => {
    // Arrange: the terminal-writer factory is invoked once at registration
    // time, so both invocations of the command must share one instance.
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "session-1.jsonl");
    const terminalWriter = new FakeTerminalWriter();
    const createTerminalWriterMock = jest.fn(() => terminalWriter);
    registerSubagentTreeCommand({
      output: { appendLine: appendLineMock } as never,
      createFileSystem: () => fileSystem,
      createTerminalWriter: createTerminalWriterMock,
    });
    const handler = commandHandlers.get("drmCopilotExtension.showSubagentTree");
    if (!handler) {
      throw new Error(
        "Missing command handler: drmCopilotExtension.showSubagentTree",
      );
    }

    // Act
    await handler();
    await handler();

    // Assert: the factory was invoked exactly once; the same writer received
    // both writes, so no second terminal was accumulated.
    expect(createTerminalWriterMock).toHaveBeenCalledTimes(1);
    expect(terminalWriter.writes).toHaveLength(2);
  });

  it("routes a discovery failure to the error path and does not write to the terminal seam", async () => {
    // Arrange: simulate no open workspace folder.
    getWorkspaceRootMock.mockImplementation(() => {
      throw new Error("No workspace folder is open.");
    });
    const fileSystem = new InMemoryFileSystem();
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: the failure routes to showErrorMessage; the terminal seam is
    // never written to.
    expect(showErrorMessageMock).toHaveBeenCalledTimes(1);
    expect(terminalWriter.writes).toHaveLength(0);
  });

  it("routes a user-cancel selection to the output log and does not write to the terminal seam", async () => {
    // Arrange: two candidates so a quick-pick prompt is required, then the
    // user cancels it (showQuickPick resolves to undefined).
    const fileSystem = new InMemoryFileSystem();
    addRootSession(fileSystem, MATCHING_DIR, "session-1.jsonl");
    addRootSession(fileSystem, MATCHING_DIR, "session-2.jsonl");
    showQuickPickMock.mockResolvedValue(undefined);
    const terminalWriter = new FakeTerminalWriter();
    const handler = activateAndGetHandler(fileSystem, terminalWriter);

    // Act
    await handler();

    // Assert: cancellation is logged, not reported as an error, and nothing
    // is written to the terminal seam.
    expect(showErrorMessageMock).not.toHaveBeenCalled();
    const logs = appendLineMock.mock.calls.map(([line]) => line);
    expect(logs.some((line) => line.includes("canceled by user"))).toBe(true);
    expect(terminalWriter.writes).toHaveLength(0);
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
    showQuickPickMock.mockImplementation(
      async (items: ReadonlyArray<{ path: string }>) =>
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
      unknown,
    ];
    expect(entries.map((entry) => entry.path)).toEqual([
      readablePath,
      unreadablePath,
    ]);
    expect(entries[1]?.label.startsWith("unknown")).toBe(true);
  });
});
