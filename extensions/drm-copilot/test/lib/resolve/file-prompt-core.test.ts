import { describe, expect, it, jest } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  resolveAtomicPlanCommand,
  resolvePrompt,
} from "../../../src/lib/resolve/file-prompt-core";

/**
 * In-memory {@link FileSystem} fake keyed on POSIX paths.
 *
 * `isFile` and `readTextFile` consult the seeded map; `glob`/`writeTextFile`/
 * `ensureDir` are recording stubs so the resolver remains hermetic.
 */
function createFakeFileSystem(files: Readonly<Record<string, string>>): {
  fs: FileSystem;
} {
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

const WORKSPACE = "C:/workspace";
const FOLDER = "docs/features/active/2026-01-02-port-cmd-240";
const TARGET = `${WORKSPACE}/${FOLDER}/plan.md`;

describe("file-prompt-core resolvePrompt", () => {
  it("produces a fully resolved prompt with no remaining placeholders", () => {
    // Arrange
    const template =
      "---\nx: 1\n---\nFile: ${file}\nFolder: ${folderpath}\nName: ${name}\n" +
      "Spec: ${spec}\nMode: ${work-mode}\nReason: ${fallback-reason}\n";
    const { fs } = createFakeFileSystem({
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
    });

    // Act
    const resolved = resolvePrompt(template, TARGET, WORKSPACE, fs);

    // Assert
    expect(resolved).not.toContain("${");
    expect(resolved).toContain(`File: ${FOLDER}/plan.md`);
    expect(resolved).toContain(`Folder: ${FOLDER}`);
    expect(resolved).toContain("Name: port-cmd");
    expect(resolved).toContain("Mode: full-feature");
  });

  it("applies minor-audit overrides only on the minor-audit path", () => {
    // Arrange
    const template =
      "## Core Requirements\n\n- Use `${spec}`\nFile: ${file}\n" +
      "Mode: ${work-mode}\nReason: ${fallback-reason}\n";
    const minorFs = createFakeFileSystem({
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: minor-audit\n",
    }).fs;
    const fullFs = createFakeFileSystem({
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
    }).fs;

    // Act
    const minor = resolvePrompt(template, TARGET, WORKSPACE, minorFs);
    const full = resolvePrompt(template, TARGET, WORKSPACE, fullFs);

    // Assert
    expect(minor).toContain("### Minor-Audit Mode Overrides (Mandatory)");
    expect(full).not.toContain("### Minor-Audit Mode Overrides (Mandatory)");
  });
});

describe("file-prompt-core resolveAtomicPlanCommand", () => {
  const TEMPLATE_PATH = "C:/extension/template.md";

  it("returns exitCode 1 with a template-not-found message", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const { fs } = createFakeFileSystem({});

    // Act
    const result = resolveAtomicPlanCommand({
      templatePath: TEMPLATE_PATH,
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      fs,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(1);
    expect(result.resolved).toBeNull();
    expect(log).toHaveBeenCalledWith(
      `Error: Template file not found: ${TEMPLATE_PATH}`,
    );
  });

  it("returns exitCode 1 with a target-not-found message", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "File: ${file}\n",
    });

    // Act
    const result = resolveAtomicPlanCommand({
      templatePath: TEMPLATE_PATH,
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      fs,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(1);
    expect(log).toHaveBeenCalledWith(`Error: Target file not found: ${TARGET}`);
  });

  it("returns exitCode 1 with Error processing prompt when resolution throws", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "Unknown: ${unknown}\n",
      [TARGET]: "plan",
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
    });

    // Act
    const result = resolveAtomicPlanCommand({
      templatePath: TEMPLATE_PATH,
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      fs,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(1);
    expect(
      log.mock.calls.some(([line]) =>
        line.startsWith("Error processing prompt:"),
      ),
    ).toBe(true);
  });

  it("emits the clipboard-success line then the content when clipboard succeeds", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const copyToClipboard = jest.fn<(text: string) => boolean>(() => true);
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "File: ${file}\n",
      [TARGET]: "plan",
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
    });

    // Act
    const result = resolveAtomicPlanCommand({
      templatePath: TEMPLATE_PATH,
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      fs,
      copyToClipboard,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(0);
    expect(log.mock.calls[0]?.[0]).toBe(
      "Successfully resolved prompt and copied to clipboard.",
    );
    expect(log.mock.calls[1]?.[0]).toBe(result.resolved);
  });

  it("emits the clipboard-failure line then the content when clipboard fails", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const copyToClipboard = jest.fn<(text: string) => boolean>(() => false);
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "File: ${file}\n",
      [TARGET]: "plan",
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
    });

    // Act
    const result = resolveAtomicPlanCommand({
      templatePath: TEMPLATE_PATH,
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      fs,
      copyToClipboard,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(0);
    expect(log.mock.calls[0]?.[0]).toBe(
      "Could not copy to clipboard; printing resolved prompt to stdout.",
    );
    expect(log.mock.calls[1]?.[0]).toBe(result.resolved);
  });

  it("uses the failure branch when no clipboard callback is provided", () => {
    // Arrange
    const log = jest.fn<(message: string) => void>();
    const { fs } = createFakeFileSystem({
      [TEMPLATE_PATH]: "File: ${file}\n",
      [TARGET]: "plan",
      [`${WORKSPACE}/${FOLDER}/issue.md`]: "- Work Mode: full-feature\n",
    });

    // Act
    const result = resolveAtomicPlanCommand({
      templatePath: TEMPLATE_PATH,
      targetPath: TARGET,
      workspaceRoot: WORKSPACE,
      fs,
      log,
    });

    // Assert
    expect(result.exitCode).toBe(0);
    expect(log.mock.calls[0]?.[0]).toBe(
      "Could not copy to clipboard; printing resolved prompt to stdout.",
    );
  });
});
