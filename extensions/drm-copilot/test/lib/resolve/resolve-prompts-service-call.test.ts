import { describe, expect, it, jest } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  resolveAtomicPlanPromptServiceCall,
  resolveExecuteHardLockPromptServiceCall,
} from "../../../src/lib/resolve/resolve-prompts-service-call";

/**
 * In-memory {@link FileSystem} fake keyed on POSIX paths.
 *
 * `isFile` and `readTextFile` consult the seeded map; `writeTextFile` and
 * `ensureDir` record calls so output-write behavior is observable.
 */
function createFakeFileSystem(files: Readonly<Record<string, string>>): {
  fs: FileSystem;
  writes: Array<{ path: string; content: string }>;
} {
  const store = new Map<string, string>(Object.entries(files));
  const writes: Array<{ path: string; content: string }> = [];
  const fs: FileSystem = {
    glob: () => [],
    isFile: (path: string) => store.has(path),
    readTextFile: (path: string) => {
      const content = store.get(path);
      if (content === undefined) {
        throw new Error(`ENOENT: ${path}`);
      }
      return content;
    },
    writeTextFile: (path: string, content: string) => {
      writes.push({ path, content });
      store.set(path, content);
    },
    ensureDir: () => undefined,
  };
  return { fs, writes };
}

const EXTENSION_ROOT = "C:/extension";
const WORKSPACE = "C:/workspace";
const HARD_LOCK_TEMPLATE =
  "C:/extension/resources/customizations/.github/codex/execute-hard-lock.prompt.md";
const ATOMIC_TEMPLATE =
  "C:/extension/resources/customizations/.github/prompts/generate-atomic-plan.prompt.md";
const FOLDER = "docs/features/active/2026-01-02-port-cmd-240";
const TARGET = `${WORKSPACE}/${FOLDER}/plan.md`;

describe("resolveExecuteHardLockPromptServiceCall", () => {
  it("returns the artifact and writes the resolved prompt for a relative output", () => {
    // Arrange
    const { fs, writes } = createFakeFileSystem({
      [HARD_LOCK_TEMPLATE]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
    });

    // Act
    const result = resolveExecuteHardLockPromptServiceCall({
      fileSystem: fs,
      extensionRoot: EXTENSION_ROOT,
      workspaceRoot: WORKSPACE,
      target: TARGET,
      output: "artifacts/hard_lock_prompt.txt",
    });

    // Assert
    expect(result).toEqual({
      tool: "resolve_execute_hard_lock_prompt",
      workspaceRoot: WORKSPACE,
      summary: `Resolved the execute hard-lock prompt for '${TARGET}'.`,
      artifacts: [`${WORKSPACE}/artifacts/hard_lock_prompt.txt`],
    });
    expect(writes[0]?.path).toBe(`${WORKSPACE}/artifacts/hard_lock_prompt.txt`);
  });

  it("uses an absolute output verbatim in artifacts", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      [HARD_LOCK_TEMPLATE]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
    });

    // Act
    const result = resolveExecuteHardLockPromptServiceCall({
      fileSystem: fs,
      extensionRoot: EXTENSION_ROOT,
      workspaceRoot: WORKSPACE,
      target: TARGET,
      output: "C:/absolute/hard_lock_prompt.txt",
    });

    // Assert
    expect(result.artifacts).toEqual(["C:/absolute/hard_lock_prompt.txt"]);
  });

  it("performs no clipboard call on the quiet path and returns the artifact", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      [HARD_LOCK_TEMPLATE]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
    });
    const log = jest.fn<(message: string) => void>();

    // Act
    const result = resolveExecuteHardLockPromptServiceCall({
      fileSystem: fs,
      extensionRoot: EXTENSION_ROOT,
      workspaceRoot: WORKSPACE,
      target: TARGET,
      output: "artifacts/hard_lock_prompt.txt",
      quiet: true,
      log,
    });

    // Assert
    expect(result.artifacts).toEqual([
      `${WORKSPACE}/artifacts/hard_lock_prompt.txt`,
    ]);
    // The quiet path emits nothing to the log sink.
    expect(log).not.toHaveBeenCalled();
  });

  it("throws the verbatim guard message for quiet without output", () => {
    // Arrange
    const { fs } = createFakeFileSystem({});

    // Act / Assert
    expect(() =>
      resolveExecuteHardLockPromptServiceCall({
        fileSystem: fs,
        extensionRoot: EXTENSION_ROOT,
        workspaceRoot: WORKSPACE,
        target: TARGET,
        quiet: true,
      }),
    ).toThrow(
      "resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.",
    );
  });

  it("throws carrying the command error text when the template is not found", () => {
    // Arrange
    const { fs } = createFakeFileSystem({ [TARGET]: "plan" });

    // Act / Assert
    expect(() =>
      resolveExecuteHardLockPromptServiceCall({
        fileSystem: fs,
        extensionRoot: EXTENSION_ROOT,
        workspaceRoot: WORKSPACE,
        target: TARGET,
        output: "artifacts/hard_lock_prompt.txt",
      }),
    ).toThrow("Error: Template 'execute-hard-lock.prompt.md' not found");
  });
});

describe("resolveAtomicPlanPromptServiceCall", () => {
  it("returns the preserved record with no artifacts and emits resolved content", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      [ATOMIC_TEMPLATE]: "File: ${file}\n",
      [TARGET]: "plan",
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
    });
    const log = jest.fn<(message: string) => void>();

    // Act
    const result = resolveAtomicPlanPromptServiceCall({
      fileSystem: fs,
      extensionRoot: EXTENSION_ROOT,
      workspaceRoot: WORKSPACE,
      target: TARGET,
      log,
    });

    // Assert
    expect(result).toEqual({
      tool: "resolve_atomic_plan_prompt",
      workspaceRoot: WORKSPACE,
      summary: `Resolved the atomic-plan prompt for '${TARGET}'.`,
    });
    expect(result).not.toHaveProperty("artifacts");
    // The default no-op clipboard yields the failure branch then the content.
    expect(log).toHaveBeenCalledWith(
      "Could not copy to clipboard; printing resolved prompt to stdout.",
    );
    expect(
      log.mock.calls.some(([line]) => line.includes(`File: ${FOLDER}/plan.md`)),
    ).toBe(true);
  });

  it("resolves a relative target against the workspace root", () => {
    // Arrange
    const { fs } = createFakeFileSystem({
      [ATOMIC_TEMPLATE]: "File: ${file}\n",
      [TARGET]: "plan",
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
    });
    const log = jest.fn<(message: string) => void>();

    // Act
    const result = resolveAtomicPlanPromptServiceCall({
      fileSystem: fs,
      extensionRoot: EXTENSION_ROOT,
      workspaceRoot: WORKSPACE,
      target: `${FOLDER}/plan.md`,
      log,
    });

    // Assert
    expect(result.tool).toBe("resolve_atomic_plan_prompt");
    expect(
      log.mock.calls.some(([line]) => line.includes(`File: ${FOLDER}/plan.md`)),
    ).toBe(true);
  });

  it("throws carrying the command error text when the template is missing", () => {
    // Arrange
    const { fs } = createFakeFileSystem({ [TARGET]: "plan" });

    // Act / Assert
    expect(() =>
      resolveAtomicPlanPromptServiceCall({
        fileSystem: fs,
        extensionRoot: EXTENSION_ROOT,
        workspaceRoot: WORKSPACE,
        target: TARGET,
      }),
    ).toThrow("Error: Template file not found:");
  });
});
