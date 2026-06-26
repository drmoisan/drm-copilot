import { beforeEach, describe, expect, it, jest } from "@jest/globals";

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
const ATOMIC_TEMPLATE =
  "C:/extension/resources/customizations/.github/prompts/generate-atomic-plan.prompt.md";
const FOLDER = "docs/features/active/feature-152";
const TARGET = `${WORKSPACE}/${FOLDER}/plan.2026-04-17T19-54.md`;

/**
 * In-memory {@link FileSystem} fake keyed on POSIX paths.
 *
 * Seeds the atomic-plan template (containing `${file}`), the target, and a
 * full-feature issue.md so the in-process resolver succeeds; `seedTemplate`
 * toggles template presence for the failure case.
 */
function createFakeFileSystem(seedTemplate: boolean): { fs: FileSystem } {
  const files: Record<string, string> = {
    [TARGET]: "plan",
    [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
  };
  if (seedTemplate) {
    files[ATOMIC_TEMPLATE] = "File: ${file}\n";
  }
  const store = new Map<string, string>(Object.entries(files));
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
    writeTextFile: () => undefined,
    ensureDir: () => undefined,
  };
  return { fs };
}

describe("repo automation service resolveAtomicPlanPrompt (in-process)", () => {
  beforeEach(() => {
    appendLineMock.mockReset();
    childProcessMock.spawn.mockReset();
  });

  it("resolves the prompt in-process and emits the resolved content", async () => {
    // Arrange
    const { fs } = createFakeFileSystem(true);
    const service = createRepoAutomationService({
      extensionRoot: EXTENSION_ROOT,
      output: { appendLine: appendLineMock },
      fileSystem: fs,
    });

    // Act
    const result = await service.resolveAtomicPlanPrompt({
      workspaceRoot: WORKSPACE,
      invocationId: "resolve_atomic_plan_prompt",
      target: TARGET,
    });

    // Assert
    expect(result.tool).toBe("resolve_atomic_plan_prompt");
    expect(result.summary).toContain(TARGET);
    expect(result).not.toHaveProperty("artifacts");
    expect(
      appendLineMock.mock.calls.some(([line]) =>
        line.includes(`File: ${FOLDER}/plan.2026-04-17T19-54.md`),
      ),
    ).toBe(true);
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });

  it("surfaces a failure as a thrown error without any Python spawn", async () => {
    // Arrange: omit the template so the resolver fails.
    const { fs } = createFakeFileSystem(false);
    const service = createRepoAutomationService({
      extensionRoot: EXTENSION_ROOT,
      output: { appendLine: appendLineMock },
      fileSystem: fs,
    });

    // Act / Assert
    await expect(
      service.resolveAtomicPlanPrompt({
        workspaceRoot: WORKSPACE,
        invocationId: "resolve_atomic_plan_prompt",
        target: TARGET,
      }),
    ).rejects.toThrow("Error: Template file not found:");
    expect(childProcessMock.spawn).not.toHaveBeenCalled();
  });
});
