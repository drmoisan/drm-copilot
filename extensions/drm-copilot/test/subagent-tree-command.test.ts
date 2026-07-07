import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";
import type { TerminalWriter } from "../src/command-runtime";
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

/** Register a command instance and return its handler, injecting the given fakes. */
function activateAndGetHandler(
  fileSystem: InMemoryFileSystem,
  terminalWriter: TerminalWriter,
): CommandHandler {
  registerSubagentTreeCommand({
    output: { appendLine: appendLineMock } as never,
    createFileSystem: () => fileSystem,
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
    showQuickPickMock.mockImplementation(async (items: ReadonlyArray<string>) =>
      items.find((item) => item.includes("session-2.jsonl")),
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
});
