// Coverage tests for `src/lib/codex-native-converter/engine-pipeline.ts`,
// added under the coordinator standing decision of 2026-10-09 for #796 (every
// changed line must be covered).
import { describe, expect, it } from "@jest/globals";

import {
  buildTranslationTraces,
  renderGeneratedOutput,
  writeDestinationOutputs,
} from "../../../src/lib/codex-native-converter/engine-pipeline";
import {
  ConversionClass,
  type MappingRecord,
  type PlannedEmission,
  type RunOptions,
  SectionIntentKind,
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

const SKILL_TEXT =
  "# P\n\nIntro.\n\n## Gate\n\n1. Collect context.\n2. Run the review.\n";
const HOOK_TEXT =
  "# P\n\nIntro.\n\n## Gate\n\nExecution must not begin until the plan is validated.\n";

/**
 * In-memory filesystem that returns queued texts, in order, for successive
 * reads of the prompt source path and delegates every other read.
 */
class SequencedReadFileSystem extends InMemoryFileSystem {
  private readonly queuedTexts: string[];

  constructor(texts: readonly string[]) {
    super();
    this.queuedTexts = [...texts];
    this.addFile(`${SOURCE_ROOT}/${PROMPT_PATH}`, texts[0] ?? "");
  }

  override readTextFile(path: string): string {
    if (path === `${SOURCE_ROOT}/${PROMPT_PATH}`) {
      const next = this.queuedTexts.shift();
      if (next === undefined) {
        throw new Error(`No queued text remains for ${path}`);
      }
      return next;
    }
    return super.readTextFile(path);
  }
}

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

  it("889-target-role: orders traces sharing source path and section id by target role", () => {
    // Arrange: two texts whose "Gate" section shares one section id but
    // classifies to different target roles. The sequenced filesystem returns
    // the shared-skill text on the first read and the hook text on the second,
    // so the pre-sort order is ["shared-skill", "hook"].
    const gateRoles = (fs: InMemoryFileSystem, records: MappingRecord[]) =>
      buildTranslationTraces(fs, RUN_OPTIONS, records).filter((trace) =>
        trace.sectionId.includes("#gate-"),
      );
    const skillOnly = gateRoles(new SequencedReadFileSystem([SKILL_TEXT]), [
      PROMPT_RECORD,
    ]);
    const hookOnly = gateRoles(new SequencedReadFileSystem([HOOK_TEXT]), [
      PROMPT_RECORD,
    ]);

    // Act
    const combined = gateRoles(
      new SequencedReadFileSystem([SKILL_TEXT, HOOK_TEXT]),
      [PROMPT_RECORD, PROMPT_RECORD],
    );

    // Assert: each text alone yields one gate trace with the expected role and
    // the same section id; combined, the targetRole key orders hook first.
    expect(skillOnly.map((trace) => trace.targetRole)).toEqual([
      "shared-skill",
    ]);
    expect(hookOnly.map((trace) => trace.targetRole)).toEqual(["hook"]);
    expect(skillOnly.map((trace) => trace.sectionId)).toEqual(
      hookOnly.map((trace) => trace.sectionId),
    );
    expect(combined.map((trace) => trace.targetRole)).toEqual([
      "hook",
      "shared-skill",
    ]);
  });

  it("renders section emissions only for targets no mapping record produced and skips null targets", () => {
    // Arrange: one mapping record owns skill A; emissions target skill A
    // (already produced), no target (null), and skill B (new).
    const fs = new InMemoryFileSystem();
    fs.addFile(`${SOURCE_ROOT}/.github/skills/a/SKILL.md`, "Skill A body.");
    fs.addFile(`${SOURCE_ROOT}/${PROMPT_PATH}`, PROMPT_TEXT);
    const skillRecord: MappingRecord = {
      ...PROMPT_RECORD,
      sourcePath: ".github/skills/a/SKILL.md",
      sourceKind: SourceKind.REUSABLE_SKILL,
      conversionClass: ConversionClass.DIRECT,
      targetRole: TargetRole.SHARED_SKILL,
      targetPath: ".agents/skills/a/SKILL.md",
    };
    const emission = (targetPath: string | null): PlannedEmission => ({
      sourcePath: PROMPT_PATH,
      sectionId: `${PROMPT_PATH}#workflow-1`,
      heading: "Workflow",
      intentKind: SectionIntentKind.SHARED_WORKFLOW,
      targetRole: TargetRole.SHARED_SKILL,
      targetPath,
      notes: [],
    });

    // Act
    const output = renderGeneratedOutput(
      fs,
      RUN_OPTIONS,
      [skillRecord],
      [
        emission(".agents/skills/a/SKILL.md"),
        emission(null),
        emission(".agents/skills/b/SKILL.md"),
      ],
    );

    // Assert: skill A keeps its mapping-record rendering, skill B comes from
    // the emission, and the null-target emission adds no key.
    expect(Object.keys(output).sort()).toEqual([
      ".agents/skills/a/SKILL.md",
      ".agents/skills/b/SKILL.md",
    ]);
    expect(output[".agents/skills/a/SKILL.md"]).toContain("Skill A body.");
    expect(output[".agents/skills/a/SKILL.md"]).not.toContain(
      "Derived prompt sections:",
    );
    expect(output[".agents/skills/b/SKILL.md"]).toContain(
      "Derived prompt sections:",
    );
  });

  it("writes generated files beneath an empty destination root as bare paths", () => {
    // Arrange
    const fs = new InMemoryFileSystem();

    // Act
    writeDestinationOutputs(fs, "", { "b.md": "B\n", "a.md": "A\n" });

    // Assert
    expect(fs.readTextFile("a.md")).toBe("A\n");
    expect(fs.readTextFile("b.md")).toBe("B\n");
  });
});
