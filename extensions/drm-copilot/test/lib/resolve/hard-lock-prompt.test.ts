import { describe, expect, it, jest } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  resolveExecuteHardLockCommand,
  resolveHardLockPrompt,
  resolveIssueFileForTarget,
  resolveTemplateName,
  resolveTemplatePath,
} from "../../../src/lib/resolve/hard-lock-prompt";

/**
 * In-memory {@link FileSystem} fake keyed on POSIX paths.
 *
 * `isFile` and `readTextFile` consult the seeded map; `writeTextFile` and
 * `ensureDir` record calls so output-write behavior is observable.
 */
function createFakeFileSystem(files: Readonly<Record<string, string>>): {
  fs: FileSystem;
  writes: Array<{ path: string; content: string }>;
  ensured: string[];
} {
  const store = new Map<string, string>(Object.entries(files));
  const writes: Array<{ path: string; content: string }> = [];
  const ensured: string[] = [];
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
    ensureDir: (path: string) => {
      ensured.push(path);
    },
  };
  return { fs, writes, ensured };
}

const WORKSPACE = "C:/workspace";
const TEMPLATE_ROOT = "C:/extension/resources/customizations/.github/codex";
const TEMPLATE_PATH = `${TEMPLATE_ROOT}/execute-hard-lock.prompt.md`;
const FOLDER = "docs/features/active/feature-123";
const TARGET = `${WORKSPACE}/${FOLDER}/plan.md`;

describe("hard-lock-prompt template selection", () => {
  it("maps execute and resume template kinds", () => {
    // Arrange / Act / Assert
    expect(resolveTemplateName("execute")).toBe("execute-hard-lock.prompt.md");
    expect(resolveTemplateName("resume")).toBe("resume-hard-lock.prompt.md");
  });

  it("probes the template root first then the workspace fallback", () => {
    // Arrange
    const { fs } = createFakeFileSystem({ [TEMPLATE_PATH]: "x" });

    // Act
    const result = resolveTemplatePath(
      "execute-hard-lock.prompt.md",
      WORKSPACE,
      TEMPLATE_ROOT,
      fs,
    );

    // Assert
    expect(result.path).toBe(TEMPLATE_PATH);
    expect(result.checked[0]).toBe(TEMPLATE_PATH);
    expect(result.checked[1]).toBe(
      `${WORKSPACE}/.github/codex/execute-hard-lock.prompt.md`,
    );
  });

  it("returns null with the checked list when no template exists", () => {
    // Arrange
    const { fs } = createFakeFileSystem({});

    // Act
    const result = resolveTemplatePath(
      "execute-hard-lock.prompt.md",
      WORKSPACE,
      TEMPLATE_ROOT,
      fs,
    );

    // Assert
    expect(result.path).toBeNull();
    expect(result.checked).toHaveLength(2);
  });
});

describe("hard-lock-prompt resolveHardLockPrompt", () => {
  it("substitutes plan-path, work-mode, and fallback-reason", () => {
    // Arrange
    const template =
      "Plan: ${plan-path}\nMode: ${work-mode}\nReason: ${fallback-reason}\n";
    const { fs } = createFakeFileSystem({
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: minor-audit\n",
    });

    // Act
    const resolved = resolveHardLockPrompt(template, TARGET, WORKSPACE, fs);

    // Assert
    expect(resolved).toContain(`Plan: ${FOLDER}/plan.md`);
    expect(resolved).toContain("Mode: minor-audit");
    expect(resolved).toContain("Reason: none");
  });
});

describe("hard-lock-prompt issue.md resolution", () => {
  it("uses the parent issue.md for a versioned v* plan dir", () => {
    // Arrange
    const versionedTarget = `${WORKSPACE}/${FOLDER}/v2/plan.md`;
    const parentIssue = `${WORKSPACE}/${FOLDER}/issue.md`;
    const { fs } = createFakeFileSystem({
      [parentIssue]: "- Work Mode: full-bug\n",
    });

    // Act
    const issuePath = resolveIssueFileForTarget(versionedTarget, WORKSPACE, fs);

    // Assert
    expect(issuePath).toBe(parentIssue);
  });

  it("returns the direct issue candidate when no file exists", () => {
    // Arrange
    const { fs } = createFakeFileSystem({});

    // Act
    const issuePath = resolveIssueFileForTarget(TARGET, WORKSPACE, fs);

    // Assert
    expect(issuePath).toBe(`${WORKSPACE}/${FOLDER}/issue.md`);
  });
});

describe("hard-lock-prompt resolveExecuteHardLockCommand", () => {
  it("emits a not-found message and exitCode 1 when the template is missing", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const { fs } = createFakeFileSystem({ [TARGET]: "plan" });

    // Act
    const result = resolveExecuteHardLockCommand({
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      templateRoot: TEMPLATE_ROOT,
      fs,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(1);
    expect(
      log.mock.calls.some(([line]) =>
        line.includes(
          "Error: Template 'execute-hard-lock.prompt.md' not found",
        ),
      ),
    ).toBe(true);
  });

  it("emits a target-not-found message and exitCode 1 when the target is missing", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "Plan: ${plan-path}\n",
    });

    // Act
    const result = resolveExecuteHardLockCommand({
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      templateRoot: TEMPLATE_ROOT,
      fs,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(1);
    expect(log).toHaveBeenCalledWith(
      `Error: Target file not found at ${TARGET}`,
    );
  });

  it("writes the resolved prompt to a relative output path resolved against the workspace", () => {
    // Arrange
    const { fs, writes, ensured } = createFakeFileSystem({
      [TEMPLATE_PATH]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
    });

    // Act
    const result = resolveExecuteHardLockCommand({
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      templateRoot: TEMPLATE_ROOT,
      output: "artifacts/hard_lock_prompt.txt",
      fs,
    });

    // Assert
    expect(result.exitCode).toBe(0);
    expect(result.outputWritten).toBe(
      `${WORKSPACE}/artifacts/hard_lock_prompt.txt`,
    );
    expect(writes[0]?.path).toBe(`${WORKSPACE}/artifacts/hard_lock_prompt.txt`);
    expect(ensured).toContain(`${WORKSPACE}/artifacts`);
  });

  it("writes an absolute output path verbatim", () => {
    // Arrange
    const { fs, writes } = createFakeFileSystem({
      [TEMPLATE_PATH]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
    });

    // Act
    const result = resolveExecuteHardLockCommand({
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      templateRoot: TEMPLATE_ROOT,
      output: "C:/absolute/hard_lock_prompt.txt",
      fs,
    });

    // Assert
    expect(result.outputWritten).toBe("C:/absolute/hard_lock_prompt.txt");
    expect(writes[0]?.path).toBe("C:/absolute/hard_lock_prompt.txt");
  });

  it("returns exitCode 0 with no clipboard or stdout emission on the quiet path", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const copyToClipboard = jest.fn<(text: string) => boolean>(() => true);
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
    });

    // Act
    const result = resolveExecuteHardLockCommand({
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      templateRoot: TEMPLATE_ROOT,
      output: "artifacts/hard_lock_prompt.txt",
      quiet: true,
      fs,
      copyToClipboard,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(0);
    expect(copyToClipboard).not.toHaveBeenCalled();
    expect(log).not.toHaveBeenCalled();
  });

  it("emits resolved content then the clipboard-success line on the non-quiet path", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const copyToClipboard = jest.fn<(text: string) => boolean>(() => true);
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
    });

    // Act
    const result = resolveExecuteHardLockCommand({
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      templateRoot: TEMPLATE_ROOT,
      fs,
      copyToClipboard,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(0);
    expect(log.mock.calls[0]?.[0]).toBe(result.resolved);
    expect(log).toHaveBeenCalledWith("\n✓ Copied to clipboard");
  });

  it("emits the clipboard-failure line when no supported mechanism is found", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "Plan: ${plan-path}\n",
      [TARGET]: "plan",
    });

    // Act
    resolveExecuteHardLockCommand({
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      templateRoot: TEMPLATE_ROOT,
      fs,
      log,
    });

    // Assert
    expect(log).toHaveBeenCalledWith(
      "\n✗ Could not copy to clipboard (no supported mechanism found)",
    );
  });

  it("returns the quiet-requires-output error path at the command level", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const { fs } = createFakeFileSystem({});

    // Act
    const result = resolveExecuteHardLockCommand({
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      templateRoot: TEMPLATE_ROOT,
      quiet: true,
      fs,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(1);
    expect(log).toHaveBeenCalledWith(
      "Error: --quiet requires --output; --quiet alone would suppress all output.",
    );
  });
});
