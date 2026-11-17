import { beforeEach, describe, expect, it } from "@jest/globals";

import {
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

  it("renders standing-guidance content without a converted-guidance header", () => {
    fs.addFile(
      `${SOURCE_ROOT}/.github/copilot-instructions.md`,
      "Follow .github/instructions/x.instructions.md.",
    );
    const rendered = renderTargetContent(fs, runOptions(), record({}), []);
    expect(rendered).not.toContain("# Converted standing guidance");
    expect(rendered).not.toContain("Applied rewrites:");
    // The body's source reference is still rewritten to the native skill path.
    expect(rendered).toBe("Follow .agents/skills/x/SKILL.md.\n");
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

  it("emits a shared helper verbatim under .codex/lib after reference rewrites", () => {
    fs.addFile(
      `${SOURCE_ROOT}/.claude/lib/discovery-validation/DiscoveryValidation.psm1`,
      "# Siblings import from .claude/lib/discovery-validation/ by name.\nfunction Test-Helper { 1 }",
    );
    const rendered = renderTargetContent(
      fs,
      runOptions({ sourceEcosystem: SourceEcosystem.CLAUDE }),
      record({
        sourcePath: ".claude/lib/discovery-validation/DiscoveryValidation.psm1",
        sourceEcosystem: SourceEcosystem.CLAUDE,
        sourceKind: SourceKind.HOST_ADAPTER_REFERENCE,
        targetRole: TargetRole.HOOK,
        targetPath: ".codex/lib/discovery-validation/DiscoveryValidation.psm1",
      }),
      [],
    );
    expect(rendered).toBe(
      "# Siblings import from .codex/lib/discovery-validation/ by name.\nfunction Test-Helper { 1 }\n",
    );
  });

  it("still wraps a handler hook with the converted-hook header", () => {
    fs.addFile(
      `${SOURCE_ROOT}/.github/hooks/discovery-pre-tool.ps1`,
      "Write-Output 1",
    );
    const rendered = renderTargetContent(
      fs,
      runOptions(),
      record({
        sourcePath: ".github/hooks/discovery-pre-tool.ps1",
        sourceKind: SourceKind.HOOK_DEFINITION,
        targetRole: TargetRole.HOOK,
        targetPath: ".codex/hooks/discovery-pre-tool.ps1",
      }),
      [],
    );
    expect(rendered.startsWith("# Converted hook\n")).toBe(true);
    expect(rendered).toContain("Write-Output 1");
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

  it("adds no AGENTS.md destination when standing guidance is not emitted", () => {
    const fs = new InMemoryFileSystem();
    fs.addFile(`${SOURCE_ROOT}/.github/skills/review/SKILL.md`, "skill");
    const edges = buildTopologyEdges(
      fs,
      runOptions(),
      [
        // planTargetPaths leaves standing guidance with a null target.
        record({
          sourcePath: ".github/copilot-instructions.md",
          targetPath: null,
        }),
        record({
          sourcePath: ".github/skills/review/SKILL.md",
          sourceKind: SourceKind.REUSABLE_SKILL,
          targetRole: TargetRole.SHARED_SKILL,
          targetPath: ".agents/skills/review/SKILL.md",
        }),
      ],
      [],
    );
    expect(edges.some((edge) => edge.destinationPath === "AGENTS.md")).toBe(
      false,
    );
    expect(
      edges.filter(
        (edge) => edge.sourcePath === ".github/copilot-instructions.md",
      ),
    ).toEqual([
      {
        sourcePath: ".github/copilot-instructions.md",
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

describe("coverage: pipeline-render.ts wrappers", () => {
  let fs: InMemoryFileSystem;

  beforeEach(() => {
    fs = new InMemoryFileSystem();
  });

  it("wraps MCP configuration, approval-rule, and launcher content with their headers", () => {
    fs.addFile(`${SOURCE_ROOT}/src.md`, "Body.");
    const render = (targetRole: TargetRole): string =>
      renderTargetContent(
        fs,
        runOptions(),
        record({ sourcePath: "src.md", targetRole, targetPath: "out.md" }),
        [],
      );
    expect(render(TargetRole.MCP_CONFIG)).toBe(
      "# Review and merge native MCP, hook, and approval settings intentionally.\n\nBody.\n",
    );
    expect(render(TargetRole.APPROVAL_RULE)).toBe(
      "# Converted approval rule candidate\n# Review the generated rule semantics before enforcement.\n\nBody.\n",
    );
    expect(render(TargetRole.LAUNCHER)).toBe(
      "# Converted launcher prompt\n\nBody.\n",
    );
  });

  it("names a subagent without a target path 'agent' and wraps a hook without a target path", () => {
    fs.addFile(`${SOURCE_ROOT}/src.md`, "Body.");
    const subagent = renderTargetContent(
      fs,
      runOptions(),
      record({
        sourcePath: "src.md",
        targetRole: TargetRole.SUBAGENT,
        targetPath: null,
      }),
      [],
    );
    const hook = renderTargetContent(
      fs,
      runOptions(),
      record({
        sourcePath: "src.md",
        targetRole: TargetRole.HOOK,
        targetPath: null,
      }),
      [],
    );
    expect(subagent).toContain('name = "agent"');
    expect(hook.startsWith("# Converted hook\n")).toBe(true);
  });

  it("uses the target name as the subagent name when it has no extension", () => {
    fs.addFile(`${SOURCE_ROOT}/src.md`, "Body.");
    const rendered = renderTargetContent(
      fs,
      runOptions(),
      record({
        sourcePath: "src.md",
        targetRole: TargetRole.SUBAGENT,
        targetPath: ".codex/agents/plain",
      }),
      [],
    );
    expect(rendered).toContain('name = "plain"');
  });

  it("reads a source path directly when the source root is empty", () => {
    fs.addFile("src.md", "Rootless body.");
    const rendered = renderTargetContent(
      fs,
      runOptions({ sourceRoot: "" }),
      record({
        sourcePath: "src.md",
        targetRole: TargetRole.LAUNCHER,
        targetPath: "out.md",
      }),
      [],
    );
    expect(rendered).toBe("# Converted launcher prompt\n\nRootless body.\n");
  });

  it("skips an emission whose section is not in the lookup", () => {
    const emission: PlannedEmission = {
      sourcePath: ".github/prompts/x.prompt.md",
      sectionId: ".github/prompts/x.prompt.md#missing-1",
      heading: "Missing",
      intentKind: SectionIntentKind.SHARED_WORKFLOW,
      targetRole: TargetRole.SHARED_SKILL,
      targetPath: ".agents/skills/x/SKILL.md",
      notes: [],
    };
    const rendered = renderSectionEmissionContent(
      runOptions(),
      ".agents/skills/x/SKILL.md",
      [emission],
      new Map<string, SourceSection>(),
      [],
    );
    expect(rendered).toContain("- `Missing`");
    expect(rendered).not.toContain("## Source section:");
  });
});

describe("coverage: pipeline.ts", () => {
  it("collects referenced destinations found at different positions", () => {
    // Arrange: one skill body names two other skills at different positions,
    // the later-sorting one first, so the position comparator decides.
    const fs = new InMemoryFileSystem();
    fs.addFile(
      `${SOURCE_ROOT}/.github/skills/main/SKILL.md`,
      "Use .github/skills/zeta/SKILL.md, then .github/skills/alpha/SKILL.md.",
    );
    fs.addFile(`${SOURCE_ROOT}/.github/skills/zeta/SKILL.md`, "zeta");
    fs.addFile(`${SOURCE_ROOT}/.github/skills/alpha/SKILL.md`, "alpha");
    const skill = (name: string): MappingRecord =>
      record({
        sourcePath: `.github/skills/${name}/SKILL.md`,
        sourceKind: SourceKind.REUSABLE_SKILL,
        targetRole: TargetRole.SHARED_SKILL,
        targetPath: `.agents/skills/${name}/SKILL.md`,
      });

    // Act
    const edges = buildTopologyEdges(
      fs,
      runOptions(),
      [skill("main"), skill("zeta"), skill("alpha")],
      [],
    ).filter((edge) => edge.sourcePath === ".github/skills/main/SKILL.md");

    // Assert: the primary target and both references, in the final
    // destination-path sort order.
    expect(edges.map((edge) => edge.destinationPath)).toEqual([
      ".agents/skills/alpha/SKILL.md",
      ".agents/skills/main/SKILL.md",
      ".agents/skills/zeta/SKILL.md",
    ]);
  });

  it("orders referenced destinations found at the same position by path text", () => {
    // Arrange: "docs/out.md" is a prefix of "docs/out.md.txt", so both known
    // destinations are first found at the same position in the rendered body.
    const fs = new InMemoryFileSystem();
    fs.addFile(
      `${SOURCE_ROOT}/.github/copilot-instructions.md`,
      "Read docs/out.md.txt before starting.",
    );
    fs.addFile(`${SOURCE_ROOT}/.github/skills/one/SKILL.md`, "skill one");
    fs.addFile(`${SOURCE_ROOT}/.github/skills/two/SKILL.md`, "skill two");

    // Act
    const edges = buildTopologyEdges(
      fs,
      runOptions(),
      [
        record({ sourcePath: ".github/copilot-instructions.md" }),
        record({
          sourcePath: ".github/skills/two/SKILL.md",
          sourceKind: SourceKind.REUSABLE_SKILL,
          targetRole: TargetRole.SHARED_SKILL,
          targetPath: "docs/out.md.txt",
        }),
        record({
          sourcePath: ".github/skills/one/SKILL.md",
          sourceKind: SourceKind.REUSABLE_SKILL,
          targetRole: TargetRole.SHARED_SKILL,
          targetPath: "docs/out.md",
        }),
      ],
      [],
    );

    // Assert: the standing-guidance source fans out to its primary target and
    // both equal-position references, ordered by path text.
    const standingDestinations = edges
      .filter((edge) => edge.sourcePath === ".github/copilot-instructions.md")
      .map((edge) => edge.destinationPath);
    expect(standingDestinations).toEqual([
      "AGENTS.md",
      "docs/out.md",
      "docs/out.md.txt",
    ]);
  });
});
