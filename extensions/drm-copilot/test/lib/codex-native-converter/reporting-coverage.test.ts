// Coverage tests for `src/lib/codex-native-converter/reporting.ts`, added
// under the coordinator standing decision of 2026-10-09 for #796 (every
// changed line must be covered).
import { describe, expect, it } from "@jest/globals";

import { writeConversionReportSet } from "../../../src/lib/codex-native-converter/reporting";
import {
  type RunOptions,
  SourceEcosystem,
  type ValidationFinding,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const RUN_OPTIONS: RunOptions = {
  mode: "review",
  sourceRoot: "fixtures/source",
  sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
  selectedPaths: [],
  destinationRoot: null,
  artifactRoot: "fixtures/artifacts",
  enableRepoPrompts: false,
  emitIntermediateState: false,
};

/** Build a validation finding with the given sort keys. */
function finding(
  code: string,
  sourcePath: string | null,
  targetPath: string | null,
  message: string,
): ValidationFinding {
  return {
    code,
    severity: "warning",
    blocking: false,
    sourcePath,
    targetPath,
    message,
    recommendedAction: "",
  };
}

describe("coverage: reporting.ts", () => {
  it("writes validation results sorted by code, then source path, then target path", () => {
    // Arrange: equal codes force the source-path key, and equal source paths
    // force the target-path key; null paths sort as empty strings.
    const fileSystem = new InMemoryFileSystem();
    const findings = [
      finding("same-code", "b.md", null, "fourth"),
      finding("same-code", "a.md", "z.md", "third"),
      finding("same-code", "a.md", "m.md", "second"),
      finding("same-code", null, null, "first"),
    ];

    // Act
    writeConversionReportSet(fileSystem, RUN_OPTIONS, [], [], [], findings, {});

    // Assert
    const results = fileSystem.readTextFile(
      "fixtures/artifacts/validation-results.json",
    );
    const parsed = JSON.parse(results) as Array<{ message: string }>;
    expect(parsed.map((item) => item.message)).toEqual([
      "first",
      "second",
      "third",
      "fourth",
    ]);
  });
});
