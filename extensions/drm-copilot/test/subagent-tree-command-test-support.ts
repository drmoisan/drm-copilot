/**
 * Shared constants, fakes, and fixture helpers for the subagent-tree command
 * test suites. This module registers no module mocks and imports no module
 * that the suites mock.
 */
import type { TerminalWriter } from "../src/terminal-writer";
import type { FileTimes } from "../src/lib/file-system";
import { InMemoryFileSystem } from "./lib/subagent-tree/in-memory-file-system";

/** Absolute workspace root used across scenarios (mirrors a real Windows cwd). */
export const WORKSPACE_ROOT = "C:\\Users\\DanMoisan\\repos\\drm-copilot";
/** Fake resolved user-global Claude projects directory (distinct from any
 * path under `WORKSPACE_ROOT`, so tests fail loudly if discovery regresses
 * to scanning the workspace root instead). */
export const CLAUDE_PROJECTS_ROOT = "/claude-root/projects";
/** Encoded directory name matching `WORKSPACE_ROOT`, using a lowercase
 * drive-letter segment to exercise the case-insensitive matching rule. */
export const MATCHING_DIR = "c--users-danmoisan-repos-drm-copilot";

/** In-test `TerminalWriter` fake capturing writes and reveal calls. */
export class FakeTerminalWriter implements TerminalWriter {
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
export class FakeFileTimes implements FileTimes {
  constructor(
    private readonly times: ReadonlyMap<string, number | undefined> = new Map(),
  ) {}

  getModifiedTimeMs(path: string): number | undefined {
    return this.times.get(path);
  }
}

/** Build a root transcript line containing one `Agent` tool-use block. */
export function agentToolUseLine(model: string, toolUseId: string): string {
  return JSON.stringify({
    message: {
      model,
      content: [{ type: "tool_use", name: "Agent", id: toolUseId }],
    },
  });
}

/** Register one root-session transcript file under a matched Claude projects directory. */
export function addRootSession(
  fileSystem: InMemoryFileSystem,
  directoryName: string,
  sessionFileName: string,
): void {
  fileSystem.addFile(
    `${CLAUDE_PROJECTS_ROOT}/${directoryName}/${sessionFileName}`,
    "",
  );
}
