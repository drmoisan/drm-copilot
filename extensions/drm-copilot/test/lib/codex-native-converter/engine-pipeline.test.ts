// Coverage tests for `src/lib/codex-native-converter/engine-pipeline.ts`,
// added under the coordinator standing decision of 2026-10-09 for #796 (every
// changed line must be covered).
import { describe, expect, it } from "@jest/globals";

import { buildTranslationTraces } from "../../../src/lib/codex-native-converter/engine-pipeline";
import {
  ConversionClass,
  type MappingRecord,
  type RunOptions,
  SourceEcosystem,
  SourceKind,
  TargetRole,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const SOURCE_ROOT = "/repo";
const PROMPT_PATH = ".github/prompts/mixed-runtime.prompt.md";
const PROMPT_TEXT =
  "# Mixed runtime prompt\n\nUse this prompt to launch a runtime workflow.\n\n## Hard Gate\n\nExecution must not begin until the plan is validated.\n\n## Workflow\n\n1. Collect context.\n2. Run the review workflow.\n";

const RUN_OPTIONS: RunOptions = {
  mode: "review",
  sourceRoot: SOURCE_ROOT,
  sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
  selectedPaths: [],
  destinationRoot: null,
  artifactRoot: `${SOURCE_ROOT}/artifacts`,
  enableRepoPrompts: false,
  emitIntermediateState: false,
};

const PROMPT_RECORD: MappingRecord = {
  sourcePath: PROMPT_PATH,
  sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
  sourceKind: SourceKind.LAUNCHER_PROMPT,
  conversionClass: ConversionClass.DECOMPOSED,
  targetRole: TargetRole.LAUNCHER,
  targetPath: null,
  notes: [],
  isRequired: true,
};

describe("coverage: engine-pipeline.ts", () => {
  it("orders traces with equal source and section by target role, keeping duplicates adjacent", () => {
    // Arrange: the same prompt record twice yields pairs of traces whose
    // sourcePath and sectionId are equal, so the final targetRole key decides.
    const fs = new InMemoryFileSystem();
    fs.addFile(`${SOURCE_ROOT}/${PROMPT_PATH}`, PROMPT_TEXT);
    const single = buildTranslationTraces(fs, RUN_OPTIONS, [PROMPT_RECORD]);

    // Act
    const doubled = buildTranslationTraces(fs, RUN_OPTIONS, [
      PROMPT_RECORD,
      PROMPT_RECORD,
    ]);

    // Assert: the single run has several traces, and the doubled run lists
    // each of them twice in the same deterministic order.
    expect(single.length).toBeGreaterThan(1);
    expect(doubled.map((trace) => trace.sectionId)).toEqual(
      single.flatMap((trace) => [trace.sectionId, trace.sectionId]),
    );
  });
});
