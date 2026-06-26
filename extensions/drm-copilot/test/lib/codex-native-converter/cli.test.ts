import { beforeEach, describe, expect, it } from "@jest/globals";

import {
  apply,
  printRunSummary,
  resolveRunOptions,
  resolveSourceEcosystem,
  review,
} from "../../../src/lib/codex-native-converter/cli";
import {
  type ConversionRunResult,
  type ReportSetPaths,
  SourceEcosystem,
} from "../../../src/lib/codex-native-converter/index";
import { InMemoryFileSystem } from "./in-memory-file-system";

const SOURCE_ROOT = "/repo/github_copilot";

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

/**
 * Build a synthetic conversion result for summary tests.
 *
 * @param options Blocking and write flags.
 * @returns A conversion result value.
 */
function buildResult(options: {
  readonly blocking: boolean;
  readonly wroteDestination: boolean;
}): ConversionRunResult {
  const reportRoot = "virtual/report-root";
  const reportPaths: ReportSetPaths = {
    conversionReport: `${reportRoot}/conversion-report.md`,
    mappingCatalog: `${reportRoot}/mapping-catalog.json`,
    validationResults: `${reportRoot}/validation-results.json`,
    proposedTreeRoot: `${reportRoot}/proposed-tree`,
  };
  return {
    mappingRecords: [],
    validationFindings: options.blocking
      ? [
          {
            code: "blocking-test-finding",
            severity: "error",
            blocking: true,
            sourcePath: "source/runtime.md",
            targetPath: "AGENTS.md",
            message: "Synthetic blocking finding for CLI tests.",
            recommendedAction: "Keep the test harness deterministic.",
          },
        ]
      : [],
    reportPaths,
    generatedOutput: {},
    wroteDestination: options.wroteDestination,
    translationTraces: [],
  };
}

describe("resolveSourceEcosystem", () => {
  it("rejects an unsupported source ecosystem with the documented message", () => {
    // Arrange & Act & Assert
    expect(() => resolveSourceEcosystem("unsupported")).toThrow(
      "source_ecosystem must be 'github-copilot' or 'claude'.",
    );
  });

  it("resolves supported ecosystems", () => {
    // Arrange & Act & Assert
    expect(resolveSourceEcosystem("github-copilot")).toBe(
      SourceEcosystem.GITHUB_COPILOT,
    );
    expect(resolveSourceEcosystem("claude")).toBe(SourceEcosystem.CLAUDE);
  });
});

describe("resolveRunOptions", () => {
  let fileSystem: InMemoryFileSystem;

  beforeEach(() => {
    fileSystem = seedSource();
  });

  it("throws when the source root does not exist as a directory", () => {
    // Arrange & Act & Assert
    expect(() =>
      resolveRunOptions(fileSystem, {
        mode: "review",
        sourceRoot: `${SOURCE_ROOT}/missing`,
        sourceEcosystem: "github-copilot",
      }),
    ).toThrow("source_root must point to an existing directory.");
  });

  it("throws when apply mode omits a destination root", () => {
    // Arrange & Act & Assert
    expect(() =>
      resolveRunOptions(fileSystem, {
        mode: "apply",
        sourceRoot: SOURCE_ROOT,
        sourceEcosystem: "github-copilot",
      }),
    ).toThrow("apply mode requires --destination-root.");
  });

  it("defaults the artifact root beneath the source root", () => {
    // Arrange & Act
    const runOptions = resolveRunOptions(fileSystem, {
      mode: "review",
      sourceRoot: SOURCE_ROOT,
      sourceEcosystem: "github-copilot",
      selectedPaths: [`${SOURCE_ROOT}/.github`],
      enableRepoPrompts: true,
      emitIntermediateState: true,
    });

    // Assert
    expect(runOptions.mode).toBe("review");
    expect(runOptions.sourceRoot).toBe(SOURCE_ROOT);
    expect(runOptions.artifactRoot).toBe(
      `${SOURCE_ROOT}/artifacts/codex-native-converter`,
    );
    expect(runOptions.enableRepoPrompts).toBe(true);
    expect(runOptions.emitIntermediateState).toBe(true);
  });
});

describe("printRunSummary", () => {
  it("prints the documented pass and fail summary formats", () => {
    // Arrange
    const passLines: string[] = [];
    const failLines: string[] = [];

    // Act
    printRunSummary(
      buildResult({ blocking: false, wroteDestination: false }),
      (message) => passLines.push(message),
    );
    printRunSummary(
      buildResult({ blocking: true, wroteDestination: false }),
      (message) => failLines.push(message),
    );

    // Assert
    expect(passLines).toContain("Artifact root: virtual/report-root");
    expect(passLines).toContain("Validation outcome: pass");
    expect(failLines).toContain(
      "Validation outcome: fail (1 blocking findings)",
    );
  });
});

describe("review", () => {
  it("builds review options and prints the summary lines", () => {
    // Arrange
    const fileSystem = seedSource();
    const lines: string[] = [];

    // Act
    const outcome = review(
      fileSystem,
      {
        sourceRoot: SOURCE_ROOT,
        sourceEcosystem: "github-copilot",
        artifactRoot: "virtual/review-artifacts",
      },
      (message) => lines.push(message),
    );

    // Assert
    expect(outcome.exitCode).toBe(0);
    expect(outcome.result.wroteDestination).toBe(false);
    expect(lines).toContain("Validation outcome: pass");
    expect(lines.some((line) => line.startsWith("Artifact root: "))).toBe(true);
  });
});

describe("apply", () => {
  it("writes the destination and returns exit code 0 for a clean plan", () => {
    // Arrange
    const fileSystem = seedSource();
    const lines: string[] = [];

    // Act
    const outcome = apply(
      fileSystem,
      {
        sourceRoot: SOURCE_ROOT,
        sourceEcosystem: "github-copilot",
        destinationRoot: "/out",
      },
      (message) => lines.push(message),
    );

    // Assert
    expect(outcome.exitCode).toBe(0);
    expect(outcome.result.wroteDestination).toBe(true);
    const destinationFiles = [...fileSystem.files.keys()].filter((path) =>
      path.startsWith("/out/"),
    );
    expect(destinationFiles.length).toBeGreaterThan(0);
  });

  it("returns a non-zero exit code when a blocking finding suppresses the write", () => {
    // Arrange: an unknown required artifact yields a blocking finding.
    const fileSystem = seedSource();
    fileSystem.addFile(
      `${SOURCE_ROOT}/.github/agents/notes.md`,
      "# Notes\n\nNot an agent manifest.\n",
    );
    const lines: string[] = [];

    // Act
    const outcome = apply(
      fileSystem,
      {
        sourceRoot: SOURCE_ROOT,
        sourceEcosystem: "github-copilot",
        destinationRoot: "/out",
      },
      (message) => lines.push(message),
    );

    // Assert
    expect(
      outcome.result.validationFindings.some((finding) => finding.blocking),
    ).toBe(true);
    expect(outcome.result.wroteDestination).toBe(false);
    expect(outcome.exitCode).toBe(1);
    expect(
      lines.some((line) => line.startsWith("Validation outcome: fail")),
    ).toBe(true);
  });
});
