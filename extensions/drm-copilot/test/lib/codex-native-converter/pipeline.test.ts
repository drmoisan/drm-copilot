import { beforeEach, describe, expect, it } from "@jest/globals";

import {
  renderMergedStandingGuidance,
  renderSectionEmissionContent,
  renderTargetContent,
} from "../../../src/lib/codex-native-converter/pipeline-render";
import { buildTopologyEdges } from "../../../src/lib/codex-native-converter/pipeline";
import {
  ConversionClass,
  type MappingRecord,
  type PlannedEmission,
  type RunOptions,
  SectionIntentKind,
  SourceEcosystem,
  SourceKind,
  type SourceSection,
  TargetRole,
  type TranslationTrace,
} from "../../../src/lib/codex-native-converter/models";
import { InMemoryFileSystem } from "./in-memory-file-system";

const SOURCE_ROOT = "/repo";

function runOptions(overrides: Partial<RunOptions> = {}): RunOptions {
  return {
    mode: "review",
    sourceRoot: SOURCE_ROOT,
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    selectedPaths: [],
    destinationRoot: null,
    artifactRoot: `${SOURCE_ROOT}/artifacts`,
    enableRepoPrompts: false,
    emitIntermediateState: false,
    ...overrides,
  };
}

function record(overrides: Partial<MappingRecord>): MappingRecord {
  return {
    sourcePath: ".github/copilot-instructions.md",
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    sourceKind: SourceKind.STANDING_INSTRUCTION,
    conversionClass: ConversionClass.DIRECT,
    targetRole: TargetRole.STANDING_GUIDANCE,
    targetPath: "AGENTS.md",
    notes: [],
    isRequired: true,
    ...overrides,
  };
}

describe("renderTargetContent", () => {
  let fs: InMemoryFileSystem;

  beforeEach(() => {
    fs = new InMemoryFileSystem();
  });

  it("wraps standing-guidance content with the converted-guidance header and rewrite summary", () => {
    fs.addFile(
      `${SOURCE_ROOT}/.github/copilot-instructions.md`,
      "Follow .github/instructions/x.instructions.md.",
    );
    const rendered = renderTargetContent(fs, runOptions(), record({}), []);
    expect(rendered).toContain("# Converted standing guidance");
    expect(rendered).toContain("Applied rewrites:");
    // The body's source reference is rewritten to the native skill path.
    expect(rendered).toContain(".agents/skills/x/SKILL.md");
  });

  it("wraps subagent content as a TOML manifest using the target stem", () => {
    fs.addFile(`${SOURCE_ROOT}/.github/agents/orchestrator.agent.md`, "Body.");
    const rendered = renderTargetContent(
      fs,
      runOptions(),
      record({
        sourcePath: ".github/agents/orchestrator.agent.md",
        sourceKind: SourceKind.AGENT_MANIFEST,
        conversionClass: ConversionClass.DECOMPOSED,
        targetRole: TargetRole.SUBAGENT,
        targetPath: ".codex/agents/orchestrator.toml",
      }),
      [],
    );
    expect(rendered).toContain('name = "orchestrator"');
    expect(rendered).toContain("developer_instructions = '''");
  });
});

describe("renderMergedStandingGuidance", () => {
  it("merges multiple standing-guidance sources with deterministic ordering", () => {
    const fs = new InMemoryFileSystem();
    fs.addFile(`${SOURCE_ROOT}/.github/copilot-instructions.md`, "Alpha body.");
    fs.addFile(
      `${SOURCE_ROOT}/.github/instructions/general.instructions.md`,
      "Beta body.",
    );
    const records = [
      record({ sourcePath: ".github/copilot-instructions.md" }),
      record({
        sourcePath: ".github/instructions/general.instructions.md",
        sourceKind: SourceKind.PATH_SCOPED_INSTRUCTION,
        conversionClass: ConversionClass.DECOMPOSED,
      }),
    ];
    const merged = renderMergedStandingGuidance(fs, runOptions(), records);
    expect(merged).toContain("# Converted standing guidance");
    expect(merged).toContain("Merged standing-guidance sources:");
    expect(merged).toContain("## Source: `copilot-instructions.md`");
    expect(merged).toContain("## Source: `general.instructions.md`");
    expect(merged.indexOf("copilot-instructions.md")).toBeLessThan(
      merged.indexOf("general.instructions.md"),
    );
  });
});

describe("renderSectionEmissionContent", () => {
  it("renders merged section emissions and returns empty for no emissions", () => {
    const section: SourceSection = {
      sectionId: ".github/prompts/x.prompt.md#workflow-3",
      heading: "Workflow",
      level: 2,
      content: "1. discover\n2. classify",
      startLine: 3,
      endLine: 5,
      cues: [],
    };
    const lookup = new Map<string, SourceSection>([
      [section.sectionId, section],
    ]);
    const emission: PlannedEmission = {
      sourcePath: ".github/prompts/x.prompt.md",
      sectionId: section.sectionId,
      heading: "Workflow",
      intentKind: SectionIntentKind.SHARED_WORKFLOW,
      targetRole: TargetRole.SHARED_SKILL,
      targetPath: ".agents/skills/x/SKILL.md",
      notes: [],
    };

    const rendered = renderSectionEmissionContent(
      runOptions(),
      ".agents/skills/x/SKILL.md",
      [emission],
      lookup,
      [],
    );
    expect(rendered).toContain("# Converted skill");
    expect(rendered).toContain("Derived prompt sections:");
    expect(rendered).toContain("## Source section: `Workflow`");

    expect(
      renderSectionEmissionContent(
        runOptions(),
        ".agents/skills/x/SKILL.md",
        [],
        lookup,
        [],
      ),
    ).toBe("");
  });
});

describe("buildTopologyEdges", () => {
  it("builds one edge per translation trace and sorts deterministically", () => {
    const fs = new InMemoryFileSystem();
    const traces: TranslationTrace[] = [
      {
        sourcePath: ".github/prompts/x.prompt.md",
        sectionId: ".github/prompts/x.prompt.md#__launcher__",
        heading: "Launcher Surface",
        intentKind: SectionIntentKind.LAUNCHER_ONLY,
        targetRole: TargetRole.LAUNCHER,
        targetPath: ".codex/prompts/x.md",
        notes: [],
      },
    ];
    const edges = buildTopologyEdges(fs, runOptions(), [], traces);
    expect(edges).toEqual([
      {
        sourcePath: ".github/prompts/x.prompt.md",
        destinationPath: ".codex/prompts/x.md",
      },
    ]);
  });

  it("emits a [no target] edge for a mapping record with no target path", () => {
    const fs = new InMemoryFileSystem();
    const edges = buildTopologyEdges(
      fs,
      runOptions(),
      [
        record({
          sourcePath: ".github/skills/README.md",
          sourceKind: SourceKind.UNKNOWN,
          conversionClass: ConversionClass.UNSUPPORTED,
          targetRole: TargetRole.UNSUPPORTED,
          targetPath: null,
        }),
      ],
      [],
    );
    expect(edges).toEqual([
      {
        sourcePath: ".github/skills/README.md",
        destinationPath: "[no target]",
      },
    ]);
  });

  it("includes additional referenced destinations found in rendered content", () => {
    const fs = new InMemoryFileSystem();
    // The standing-guidance body references another known target path.
    fs.addFile(
      `${SOURCE_ROOT}/.github/copilot-instructions.md`,
      "See .github/skills/review/SKILL.md for review.",
    );
    fs.addFile(`${SOURCE_ROOT}/.github/skills/review/SKILL.md`, "skill");
    const edges = buildTopologyEdges(
      fs,
      runOptions(),
      [
        record({ sourcePath: ".github/copilot-instructions.md" }),
        record({
          sourcePath: ".github/skills/review/SKILL.md",
          sourceKind: SourceKind.REUSABLE_SKILL,
          targetRole: TargetRole.SHARED_SKILL,
          targetPath: ".agents/skills/review/SKILL.md",
        }),
      ],
      [],
    );
    // The standing-guidance source fans out to AGENTS.md plus the referenced
    // skill destination its rewritten body mentions.
    const standingEdges = edges.filter(
      (edge) => edge.sourcePath === ".github/copilot-instructions.md",
    );
    expect(
      standingEdges.some((edge) => edge.destinationPath === "AGENTS.md"),
    ).toBe(true);
    expect(
      standingEdges.some(
        (edge) => edge.destinationPath === ".agents/skills/review/SKILL.md",
      ),
    ).toBe(true);
  });
});
