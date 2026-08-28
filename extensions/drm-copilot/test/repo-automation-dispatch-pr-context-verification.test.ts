import { describe, expect, it, jest } from "@jest/globals";

jest.mock("vscode", () => ({}), { virtual: true });

import { dispatchRepoAutomationTool } from "../src/mcp-tools";
import { createRepoAutomationService } from "../src/repo-automation-service";

/**
 * Tool-dispatch boundary contract for `collect_pr_context`.
 *
 * These two tests observe the boundary the MCP client actually sees. The first
 * asserts that a raised verification failure becomes `ok: false` carrying the
 * failure text, which is what makes a silent-success impossible at the tool
 * surface. The second asserts that a successful invocation reports `ok: true`
 * with an `artifacts` array equal to the paths written during that same run,
 * so the reported set and the written set are compared against each other
 * rather than against two separately maintained literals.
 *
 * Neither test invokes the live MCP tool. The MCP client resolves an unpinned
 * package, so a live call would exercise the installed build rather than this
 * branch; both exercise the in-process dispatch path against this branch's
 * source. No real disk and no temporary file is used.
 */

const WORKSPACE_ROOT = "C:/workspace";

/** In-memory filesystem seam recording writes and serving reads from them. */
interface WriteRecordingFileSystem {
  readonly writes: Map<string, string>;
  readonly fileSystem: Parameters<
    typeof createRepoAutomationService
  >[0]["fileSystem"];
}

/**
 * Build a hermetic filesystem seam.
 *
 * @param discardWrites When true, writes are recorded as having been attempted
 *   but their content is dropped, so read-back verification must fail.
 */
function buildFileSystem(discardWrites: boolean): WriteRecordingFileSystem {
  const writes = new Map<string, string>();
  const attempted = new Map<string, string>();
  return {
    writes: discardWrites ? attempted : writes,
    fileSystem: {
      glob: () => [],
      isFile: (path: string) => writes.has(path.replace(/\\/g, "/")),
      exists: (path: string) => path.replace(/\\/g, "/").endsWith("/.git"),
      isDirectory: () => false,
      listDirectory: () => [],
      readTextFile: (path: string) => writes.get(path.replace(/\\/g, "/")) ?? "",
      writeTextFile: (path: string, content: string) => {
        const key = path.replace(/\\/g, "/");
        attempted.set(key, content);
        if (!discardWrites) {
          writes.set(key, content);
        }
      },
      ensureDir: () => undefined,
    },
  };
}

/** Build a service whose git resolves and whose gh reports unavailable. */
function buildService(discardWrites: boolean): {
  readonly service: ReturnType<typeof createRepoAutomationService>;
  readonly writes: Map<string, string>;
} {
  const { writes, fileSystem } = buildFileSystem(discardWrites);
  const service = createRepoAutomationService({
    extensionRoot: "C:/extension",
    output: { appendLine: () => undefined },
    fileSystem,
    runner: {
      run: (args: readonly string[]) => {
        // gh is unavailable in this hermetic test; git resolves.
        if (args[0] === "gh" || String(args[0]).endsWith("gh")) {
          return { stdout: "", stderr: "offline", code: 1 };
        }
        return { stdout: "", stderr: "", code: 0 };
      },
    },
  });
  return { service, writes };
}

describe("collect_pr_context tool-dispatch boundary", () => {
  it("reports ok false with the failure text when the service call raises", async () => {
    // Arrange: writes are accepted and discarded, so read-back verification
    // raises inside the service call.
    const { service } = buildService(true);

    // Act
    const result = await dispatchRepoAutomationTool(
      "collect_pr_context",
      { workspace_root: WORKSPACE_ROOT, base: "origin/main" },
      service,
    );

    // Assert
    expect(result.ok).toBe(false);
    expect(result.tool).toBe("collect_pr_context");
    expect(result.summary).toContain("Failed to verify PR context artifact");
  });

  it("reports ok true with artifacts equal to the paths written in the same run", async () => {
    // Arrange
    const { service, writes } = buildService(false);

    // Act
    const result = await dispatchRepoAutomationTool(
      "collect_pr_context",
      { workspace_root: WORKSPACE_ROOT, base: "origin/main" },
      service,
    );

    // Assert
    expect(result.ok).toBe(true);
    expect(result.artifacts).toHaveLength(2);
    // The two reported entries equal the two paths written during this run.
    expect([...(result.artifacts ?? [])].sort()).toEqual(
      [...writes.keys()].sort(),
    );
  });
});
