import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import type { FileSystem } from "../src/lib/file-system";

const appendLineMock = jest.fn<(line: string) => void>();

jest.mock("vscode", () => ({}), { virtual: true });

jest.mock("node:child_process", () => ({
  spawn: jest.fn(),
}));

import { createRepoAutomationService } from "../src/repo-automation-service";

const childProcessMock = jest.requireMock("node:child_process") as {
  spawn: jest.Mock;
};

const EXTENSION_ROOT = "C:/extension";
const WORKSPACE = "C:/workspace";
const TEMPLATE_PATH =
  "C:/extension/resources/customizations/.github/codex/execute-hard-lock.prompt.md";
const TARGET = "C:/workspace/docs/features/active/feature-123/plan.md";

/**
 * In-memory {@link FileSystem} fake keyed on POSIX paths.
 *
 * Seeds the hard-lock template (containing `${plan-path}`) and the target so the
 * in-process resolver succeeds; records `writeTextFile`/`ensureDir` calls so the
 * output write is observable.
 */
function createFakeFileSystem(
  extraFiles: Readonly<Record<string, string>> = {},
): {
  fs: FileSystem;
  writes: Array<{ path: string; content: string }>;
} {
  const store = new Map<string, string>(
    Object.entries({
      [TEMPLATE_PATH]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
      ...extraFiles,
    }),
  );
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

describe("repo automation hard-lock prompt resolution (in-process)", () => {
  beforeEach(() => {
    appendLineMock.mockReset();
    childProcessMock.spawn.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("without output returns no artifacts and does not write a file", async () => {
    // Arrange
    const { fs, writes } = createFakeFileSystem();
    const service = createRepoAutomationService({
      extensionRoot: EXTENSION_ROOT,
      output: { appendLine: appendLineMock },
      fileSystem: fs,
    });

    // Act
    const result = await service.resolveExecuteHardLockPrompt({
      workspaceRoot: WORKSPACE,
      invocationId: "resolve_execute_hard_lock_prompt",
      target: TARGET,
    });

    // Assert
    expect(result.artifacts).toBeUndefined();
    expect(writes).toHaveLength(0);
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("with output returns the absolute artifact path and writes the resolved prompt", async () => {
    // Arrange
    const { fs, writes } = createFakeFileSystem();
    const service = createRepoAutomationService({
      extensionRoot: EXTENSION_ROOT,
      output: { appendLine: appendLineMock },
      fileSystem: fs,
    });

    // Act
    const result = await service.resolveExecuteHardLockPrompt({
      workspaceRoot: WORKSPACE,
      invocationId: "resolve_execute_hard_lock_prompt",
      target: TARGET,
      output: "artifacts/hard_lock_prompt.txt",
    });

    // Assert
    expect(result.artifacts).toEqual([
      "C:/workspace/artifacts/hard_lock_prompt.txt",
    ]);
    expect(writes[0]?.path).toBe("C:/workspace/artifacts/hard_lock_prompt.txt");
    expect(writes[0]?.content).toContain(
      "Plan: docs/features/active/feature-123/plan.md",
    );
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("with output and quiet returns the artifact path and writes the resolved prompt", async () => {
    // Arrange
    const { fs, writes } = createFakeFileSystem();
    const service = createRepoAutomationService({
      extensionRoot: EXTENSION_ROOT,
      output: { appendLine: appendLineMock },
      fileSystem: fs,
    });

    // Act
    const result = await service.resolveExecuteHardLockPrompt({
      workspaceRoot: WORKSPACE,
      invocationId: "resolve_execute_hard_lock_prompt",
      target: TARGET,
      output: "artifacts/hard_lock_prompt.txt",
      quiet: true,
    });

    // Assert
    expect(result.artifacts).toEqual([
      "C:/workspace/artifacts/hard_lock_prompt.txt",
    ]);
    expect(writes[0]?.path).toBe("C:/workspace/artifacts/hard_lock_prompt.txt");
  });

  it("with an absolute output path uses it directly in artifacts", async () => {
    // Arrange
    const { fs, writes } = createFakeFileSystem();
    const service = createRepoAutomationService({
      extensionRoot: EXTENSION_ROOT,
      output: { appendLine: appendLineMock },
      fileSystem: fs,
    });

    // Act
    const result = await service.resolveExecuteHardLockPrompt({
      workspaceRoot: WORKSPACE,
      invocationId: "resolve_execute_hard_lock_prompt",
      target: TARGET,
      output: "C:/absolute/hard_lock_prompt.txt",
      quiet: true,
    });

    // Assert
    expect(result.artifacts).toEqual(["C:/absolute/hard_lock_prompt.txt"]);
    expect(writes[0]?.path).toBe("C:/absolute/hard_lock_prompt.txt");
  });

  it("rejects quiet without output at the TS layer without any Python spawn", async () => {
    // Arrange
    const { fs } = createFakeFileSystem();
    const service = createRepoAutomationService({
      extensionRoot: EXTENSION_ROOT,
      output: { appendLine: appendLineMock },
      fileSystem: fs,
    });

    // Act / Assert
    await expect(
      service.resolveExecuteHardLockPrompt({
        workspaceRoot: WORKSPACE,
        invocationId: "resolve_execute_hard_lock_prompt",
        target: TARGET,
        quiet: true,
      }),
    ).rejects.toThrow(
      "resolve_execute_hard_lock_prompt: 'quiet' requires 'output' to be set.",
    );

    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });
});
