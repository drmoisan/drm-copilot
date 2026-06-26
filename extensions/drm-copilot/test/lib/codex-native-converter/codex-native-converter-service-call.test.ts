import { beforeEach, describe, expect, it } from "@jest/globals";

import { runCodexNativeConverterServiceCall } from "../../../src/lib/codex-native-converter/codex-native-converter-service-call";
import { InMemoryFileSystem } from "./in-memory-file-system";

const WORKSPACE_ROOT = "/repo";
const SOURCE_ROOT = "/repo/source";

/**
 * Seed an in-memory filesystem with a minimal GitHub Copilot source tree.
 *
 * @returns A seeded in-memory filesystem.
 */
function seedSource(): InMemoryFileSystem {
  const fileSystem = new InMemoryFileSystem();
  fileSystem.addDir(SOURCE_ROOT);
  fileSystem.addFile(
    `${SOURCE_ROOT}/.github/copilot-instructions.md`,
    "# Copilot fixture instructions\n\nUse semantic MCP tools where supported.\n",
  );
  fileSystem.addFile(
    `${SOURCE_ROOT}/.github/instructions/general-code-change.instructions.md`,
    '---\napplyTo: "**"\nname: fixture-general-policy\n---\n\n# Fixture instruction\n\nFollow the policy.\n',
  );
  fileSystem.addFile(
    `${SOURCE_ROOT}/.github/skills/review-workflow/SKILL.md`,
    "# Review workflow fixture\n\nUse the review skill.\n",
  );
  return fileSystem;
}

describe("runCodexNativeConverterServiceCall", () => {
  let fileSystem: InMemoryFileSystem;
  let logged: string[];

  beforeEach(() => {
    fileSystem = seedSource();
    logged = [];
  });

  it("returns the preserved result record for a review run", () => {
    // Arrange & Act
    const result = runCodexNativeConverterServiceCall({
      fileSystem,
      workspaceRoot: WORKSPACE_ROOT,
      mode: "review",
      sourceEcosystem: "github-copilot",
      sourceRoot: SOURCE_ROOT,
      log: (message) => logged.push(message),
    });

    // Assert: tool, workspaceRoot, exact summary, and single artifact path.
    expect(result.tool).toBe("run_codex_native_converter");
    expect(result.workspaceRoot).toBe(WORKSPACE_ROOT);
    expect(result.summary).toBe(
      "Ran bundled codex-native-converter in review mode for 'github-copilot'.",
    );
    expect(result.artifacts).toEqual([
      `${SOURCE_ROOT}/artifacts/codex-native-converter`,
    ]);
    expect(logged).toContain(result.summary);
  });

  it("writes report artifacts through the filesystem for review mode", () => {
    // Arrange & Act
    const result = runCodexNativeConverterServiceCall({
      fileSystem,
      workspaceRoot: WORKSPACE_ROOT,
      mode: "review",
      sourceEcosystem: "github-copilot",
      sourceRoot: SOURCE_ROOT,
    });

    // Assert: the conversion report and proposed tree were written under the
    // artifact root; no destination output exists for review mode.
    const artifactRoot = result.artifacts[0] as string;
    expect(fileSystem.isFile(`${artifactRoot}/conversion-report.md`)).toBe(
      true,
    );
    expect(fileSystem.isFile(`${artifactRoot}/mapping-catalog.json`)).toBe(
      true,
    );
    expect(fileSystem.isFile(`${artifactRoot}/proposed-tree/AGENTS.md`)).toBe(
      true,
    );
  });

  it("writes destination files in apply mode for a clean plan", () => {
    // Arrange & Act
    const result = runCodexNativeConverterServiceCall({
      fileSystem,
      workspaceRoot: WORKSPACE_ROOT,
      mode: "apply",
      sourceEcosystem: "github-copilot",
      sourceRoot: SOURCE_ROOT,
      destinationRoot: "/repo/out",
    });

    // Assert
    expect(result.summary).toBe(
      "Ran bundled codex-native-converter in apply mode for 'github-copilot'.",
    );
    const destinationFiles = [...fileSystem.files.keys()].filter((path) =>
      path.startsWith("/repo/out/"),
    );
    expect(destinationFiles.length).toBeGreaterThan(0);
  });

  it("resolves a relative source root against the workspace root", () => {
    // Arrange: seed the source tree at a workspace-relative location.
    const relativeFs = new InMemoryFileSystem();
    relativeFs.addDir(`${WORKSPACE_ROOT}/source`);
    relativeFs.addFile(
      `${WORKSPACE_ROOT}/source/.github/copilot-instructions.md`,
      "# Copilot fixture instructions\n",
    );

    // Act
    const result = runCodexNativeConverterServiceCall({
      fileSystem: relativeFs,
      workspaceRoot: WORKSPACE_ROOT,
      mode: "review",
      sourceEcosystem: "github-copilot",
      sourceRoot: "source",
    });

    // Assert: the artifact root resolves beneath the absolute source root.
    expect(result.artifacts).toEqual([
      `${WORKSPACE_ROOT}/source/artifacts/codex-native-converter`,
    ]);
  });

  it("honors an explicit artifact root", () => {
    // Arrange & Act
    const result = runCodexNativeConverterServiceCall({
      fileSystem,
      workspaceRoot: WORKSPACE_ROOT,
      mode: "review",
      sourceEcosystem: "github-copilot",
      sourceRoot: SOURCE_ROOT,
      artifactRoot: "/repo/custom-artifacts",
    });

    // Assert
    expect(result.artifacts).toEqual(["/repo/custom-artifacts"]);
  });
});
