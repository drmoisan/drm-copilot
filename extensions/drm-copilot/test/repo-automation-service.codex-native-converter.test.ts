import {
  afterEach,
  beforeEach,
  describe,
  expect,
  it,
  jest,
} from "@jest/globals";

import { InMemoryFileSystem } from "./lib/codex-native-converter/in-memory-file-system";

const appendLineMock = jest.fn<(line: string) => void>();

jest.mock("vscode", () => ({}), { virtual: true });

import { createRepoAutomationService } from "../src/repo-automation-service";

/**
 * Seed an in-memory filesystem with a minimal GitHub Copilot source tree.
 *
 * @param sourceRoot Absolute POSIX source root.
 * @returns A seeded in-memory filesystem.
 */
function seedSource(sourceRoot: string): InMemoryFileSystem {
  const fileSystem = new InMemoryFileSystem();
  fileSystem.addDir(sourceRoot);
  fileSystem.addFile(
    `${sourceRoot}/.github/copilot-instructions.md`,
    "# Copilot fixture instructions\n",
  );
  fileSystem.addFile(
    `${sourceRoot}/.github/instructions/general-code-change.instructions.md`,
    '---\napplyTo: "**"\nname: fixture-general-policy\n---\n\n# Fixture instruction\n\nFollow the policy.\n',
  );
  fileSystem.addFile(
    `${sourceRoot}/.github/skills/review-workflow/SKILL.md`,
    "# Review workflow fixture\n\nUse the review skill.\n",
  );
  return fileSystem;
}

describe("repo automation service runCodexNativeConverter", () => {
  beforeEach(() => {
    appendLineMock.mockReset();
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it("runs the in-process converter in apply mode and returns the preserved result", async () => {
    // Arrange: a clean source tree under an absolute workspace path.
    const fileSystem = seedSource("C:/workspace/source");
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
    });

    // Act
    const result = await service.runCodexNativeConverter({
      workspaceRoot: "C:/workspace",
      invocationId: "run_codex_native_converter",
      mode: "apply",
      sourceEcosystem: "github-copilot",
      sourceRoot: "C:/workspace/source",
      destinationRoot: "C:/workspace/destination",
      artifactRoot: "C:/workspace/artifacts/codex-native-converter",
      enableRepoPrompts: true,
    });

    // Assert: in-process result contract (no Python spawn).
    expect(result.tool).toBe("run_codex_native_converter");
    expect(result.workspaceRoot).toBe("C:/workspace");
    expect(result.summary).toBe(
      "Ran bundled codex-native-converter in apply mode for 'github-copilot'.",
    );
    expect(result.artifacts).toEqual([
      "C:/workspace/artifacts/codex-native-converter",
    ]);
    // Apply mode wrote destination output for the clean plan.
    const destinationFiles = [...fileSystem.files.keys()].filter((path) =>
      path.startsWith("C:/workspace/destination/"),
    );
    expect(destinationFiles.length).toBeGreaterThan(0);
  });

  it("returns the artifact root parsed from the conversion-report parent", async () => {
    // Arrange
    const fileSystem = seedSource("C:/workspace/source");
    const service = createRepoAutomationService({
      extensionRoot: "C:/extension",
      output: { appendLine: appendLineMock },
      fileSystem,
    });

    // Act: review mode defaults the artifact root beneath the source root.
    const result = await service.runCodexNativeConverter({
      workspaceRoot: "C:/workspace",
      mode: "review",
      sourceEcosystem: "github-copilot",
      sourceRoot: "C:/workspace/source",
    });

    // Assert
    expect(result.artifacts).toEqual([
      "C:/workspace/source/artifacts/codex-native-converter",
    ]);
  });
});
