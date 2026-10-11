// Coverage tests for `src/lib/codex-native-converter/pipeline-traces.ts`,
// added under the coordinator standing decision of 2026-10-09 for #796 (every
// changed line must be covered). The classifier is replaced with a targeted
// mock so the sort callback sees traces whose source paths differ and traces
// that share a source path and section id, which real prompt parsing never
// produces for a single artifact.
import { afterEach, describe, expect, it, jest } from "@jest/globals";

import { classifyPromptSections } from "../../../src/lib/codex-native-converter/classifier";
import {
  ConversionClass,
  type MappingRecord,
  type RunOptions,
  SectionIntentKind,
  SourceEcosystem,
  SourceKind,
  TargetRole,
} from "../../../src/lib/codex-native-converter/models";
import { buildPromptTranslationTraces } from "../../../src/lib/codex-native-converter/pipeline-traces";
import { InMemoryFileSystem } from "./in-memory-file-system";

jest.mock("../../../src/lib/codex-native-converter/classifier", () => ({
  ...jest.requireActual<
    typeof import("../../../src/lib/codex-native-converter/classifier")
  >("../../../src/lib/codex-native-converter/classifier"),
  classifyPromptSections: jest.fn(),
}));

const classifyPromptSectionsMock =
  classifyPromptSections as jest.MockedFunction<typeof classifyPromptSections>;

const SOURCE_ROOT = "/repo";
const PROMPT_PATH = ".github/prompts/p.prompt.md";

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

afterEach(() => {
  jest.resetAllMocks();
});

describe("coverage: pipeline-traces.ts", () => {
  it("orders traces by source path, then section id, then target role", () => {
    // Arrange: one intent from another source path, two intents sharing a
    // section id with different roles, and one unsupported intent.
    const fs = new InMemoryFileSystem();
    fs.addFile(`${SOURCE_ROOT}/${PROMPT_PATH}`, "# Prompt\n\nLaunch it.\n");
    const sharedSectionId = `${PROMPT_PATH}#dup-5`;
    classifyPromptSectionsMock.mockReturnValue([
      {
        sourcePath: "other/path.md",
        sectionId: "other/path.md#alpha-1",
        heading: "alpha",
        intentKind: SectionIntentKind.SHARED_WORKFLOW,
        notes: [],
      },
      {
        sourcePath: PROMPT_PATH,
        sectionId: sharedSectionId,
        heading: "gamma",
        intentKind: SectionIntentKind.SHARED_WORKFLOW,
        notes: [],
      },
      {
        sourcePath: PROMPT_PATH,
        sectionId: sharedSectionId,
        heading: "beta",
        intentKind: SectionIntentKind.HOOK_CANDIDATE,
        notes: [],
      },
      {
        sourcePath: PROMPT_PATH,
        sectionId: `${PROMPT_PATH}#skipped-9`,
        heading: "skipped",
        intentKind: SectionIntentKind.UNSUPPORTED,
        notes: [],
      },
    ]);

    // Act
    const traces = buildPromptTranslationTraces(fs, RUN_OPTIONS, PROMPT_RECORD);

    // Assert: the prompt source sorts before "other/path.md"; within the
    // shared section id "hook" sorts before "shared-skill"; the unsupported
    // intent is skipped.
    expect(traces.map((trace) => trace.heading)).toEqual([
      "Launcher Surface",
      "beta",
      "gamma",
      "alpha",
    ]);
    expect(traces.map((trace) => trace.targetRole)).toEqual([
      TargetRole.LAUNCHER,
      TargetRole.HOOK,
      TargetRole.SHARED_SKILL,
      TargetRole.SHARED_SKILL,
    ]);
  });
});
