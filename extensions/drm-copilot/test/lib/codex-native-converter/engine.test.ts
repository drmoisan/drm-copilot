import { beforeEach, describe, expect, it } from "@jest/globals";

import {
  runApplyMode,
  runReviewMode,
} from "../../../src/lib/codex-native-converter/engine";
import {
  type RunOptions,
  SourceEcosystem,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const SOURCE_ROOT = "/repo/github_copilot";
const ARTIFACT_ROOT = "/virtual/end-to-end/github";
const DESTINATION_ROOT = "/out";

/**
 * Faithful in-memory copy of the committed GitHub Copilot converter fixture.
 *
 * Each entry mirrors `tests/fixtures/codex_native_converter/github_copilot`.
 */
const GITHUB_COPILOT_FIXTURE: Readonly<Record<string, string>> = {
  ".github/copilot-instructions.md":
    "# Copilot fixture instructions\n\nUse semantic MCP tools where supported.\n",
  ".github/instructions/general-code-change.instructions.md":
    '---\napplyTo: "**"\nname: fixture-general-policy\ndescription: Fixture policy\n---\n\n# Fixture instruction\n\nFollow the conversion policy.\n',
  ".github/agents/orchestrator.agent.md":
    "# Orchestrator fixture\n\nRoute review work through this agent.\n\nhandoffs:\n- reviewer\n",
  ".github/agents/beast-topology.agent.md":
    "# Beast topology fixture\n\nRead and follow these files in order:\n\n1. `.github/copilot-instructions.md`\n2. `.github/instructions/general-code-change.instructions.md`\n3. `.github/skills/review-workflow/SKILL.md`\n",
  ".github/skills/review-workflow/SKILL.md":
    "# Review workflow fixture\n\nUse `drmCopilotExtension.collectPrContext` before review.\n",
  ".github/prompts/launch-review.prompt.md":
    "# Launch review\n\nCall `drmCopilotExtension.collectPrContext` and continue.\n",
  ".github/prompts/mixed-runtime.prompt.md":
    "---\nagent: 'orchestrator'\ndescription: 'Fixture prompt that mixes launcher, workflow, and hard-gate content.'\n---\n\n# Mixed runtime prompt\n\nUse this prompt to launch a deterministic runtime workflow.\n\n## Hard Gate\n\nExecution must not begin until the plan is validated.\nBlocked if tests introduce tempfile or network usage.\n\n## Workflow\n\n1. Collect context.\n2. Run the review workflow.\n3. Record evidence paths.\n\n## Launch Template\n\nUse `/mixed-runtime <feature-root>` to invoke this launcher.\n",
};

/**
 * Build an in-memory filesystem seeded with the GitHub Copilot fixture tree.
 *
 * @returns A seeded in-memory filesystem.
 */
function seedGithubCopilot(): InMemoryFileSystem {
  const fileSystem = new InMemoryFileSystem();
  fileSystem.addDir(SOURCE_ROOT);
  // Register every fixture file beneath the source root.
  for (const [relativePath, content] of Object.entries(
    GITHUB_COPILOT_FIXTURE,
  )) {
    fileSystem.addFile(`${SOURCE_ROOT}/${relativePath}`, content);
  }
  return fileSystem;
}

/**
 * Build review-mode run options for the seeded fixture.
 *
 * @param overrides Field overrides.
 * @returns Run options.
 */
function runOptions(overrides: Partial<RunOptions> = {}): RunOptions {
  return {
    mode: "review",
    sourceRoot: SOURCE_ROOT,
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    selectedPaths: [],
    destinationRoot: null,
    artifactRoot: ARTIFACT_ROOT,
    enableRepoPrompts: false,
    emitIntermediateState: false,
    ...overrides,
  };
}

describe("runReviewMode", () => {
  let fileSystem: InMemoryFileSystem;

  beforeEach(() => {
    fileSystem = seedGithubCopilot();
  });

  it("produces the required review artifact set without writing a destination", () => {
    // Arrange & Act
    const result = runReviewMode(fileSystem, runOptions());

    // Assert
    const writtenPaths = [...fileSystem.files.keys()];
    expect(
      writtenPaths.some((path) => path.endsWith("conversion-report.md")),
    ).toBe(true);
    expect(
      writtenPaths.some((path) => path.endsWith("mapping-catalog.json")),
    ).toBe(true);
    expect(
      writtenPaths.some((path) => path.endsWith("validation-results.json")),
    ).toBe(true);
    expect(
      writtenPaths.some((path) => path.includes("proposed-tree/AGENTS.md")),
    ).toBe(true);
    expect(result.mappingRecords.length).toBeGreaterThanOrEqual(4);
    expect(result.wroteDestination).toBe(false);
  });

  it("merges repo-wide instructions into one generated AGENTS.md", () => {
    // Arrange & Act
    const result = runReviewMode(fileSystem, runOptions());

    // Assert
    const agentsPath = [...fileSystem.files.keys()].find((path) =>
      path.endsWith("proposed-tree/AGENTS.md"),
    );
    expect(agentsPath).toBeDefined();
    const agentsOutput = fileSystem.readTextFile(agentsPath as string);
    expect(agentsOutput).toContain("Copilot fixture instructions");
    expect(agentsOutput).toContain("fixture-general-policy");
    expect(
      result.mappingRecords.some(
        (record) =>
          record.sourcePath ===
            ".github/instructions/general-code-change.instructions.md" &&
          record.targetPath === "AGENTS.md",
      ),
    ).toBe(true);
    expect(
      result.validationFindings.some(
        (finding) => finding.code === "duplicate-target-path",
      ),
    ).toBe(false);
  });

  it("accumulates section intents through parsed source artifacts", () => {
    // Arrange & Act
    const result = runReviewMode(
      fileSystem,
      runOptions({ emitIntermediateState: true }),
    );

    // Assert: emit-intermediate-state writes the four intermediate JSON files.
    const intermediateFiles = [...fileSystem.files.keys()].filter((path) =>
      path.includes("/intermediate/"),
    );
    expect(intermediateFiles).toEqual(
      expect.arrayContaining([
        `${ARTIFACT_ROOT}/intermediate/source-artifacts.json`,
        `${ARTIFACT_ROOT}/intermediate/section-intents.json`,
        `${ARTIFACT_ROOT}/intermediate/planned-emissions.json`,
        `${ARTIFACT_ROOT}/intermediate/translation-traces.json`,
      ]),
    );
    expect(result.translationTraces.length).toBeGreaterThan(0);
  });

  it("does not emit intermediate state when the flag is off", () => {
    // Arrange & Act
    runReviewMode(fileSystem, runOptions());

    // Assert
    const intermediateFiles = [...fileSystem.files.keys()].filter((path) =>
      path.includes("/intermediate/"),
    );
    expect(intermediateFiles).toEqual([]);
  });
});

describe("runApplyMode", () => {
  let fileSystem: InMemoryFileSystem;

  beforeEach(() => {
    fileSystem = seedGithubCopilot();
  });

  it("writes destination files when no blocking findings remain", () => {
    // Arrange & Act
    const result = runApplyMode(
      fileSystem,
      runOptions({ mode: "apply", destinationRoot: DESTINATION_ROOT }),
    );

    // Assert: the clean fixture plan writes the destination tree and sets the
    // flag.
    expect(result.validationFindings.some((finding) => finding.blocking)).toBe(
      false,
    );
    expect(result.wroteDestination).toBe(true);
    const destinationFiles = [...fileSystem.files.keys()].filter((path) =>
      path.startsWith(`${DESTINATION_ROOT}/`),
    );
    expect(destinationFiles.length).toBeGreaterThan(0);
  });

  it("does not write a destination when a blocking finding is present", () => {
    // Arrange: apply mode without a destination root raises the blocking
    // `missing-required-input` finding, which suppresses destination writes.
    const result = runApplyMode(
      fileSystem,
      runOptions({ mode: "apply", destinationRoot: null }),
    );

    // Assert
    expect(
      result.validationFindings.some(
        (finding) =>
          finding.blocking && finding.code === "missing-required-input",
      ),
    ).toBe(true);
    expect(result.wroteDestination).toBe(false);
    const destinationFiles = [...fileSystem.files.keys()].filter((path) =>
      path.startsWith(`${DESTINATION_ROOT}/`),
    );
    expect(destinationFiles).toEqual([]);
  });
});
