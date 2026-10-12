import { describe, expect, it } from "@jest/globals";

import { validateConversionPlan } from "../../../src/lib/codex-native-converter/validation";
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

function runOptions(overrides: Partial<RunOptions> = {}): RunOptions {
  return {
    mode: "apply",
    sourceRoot: "fixtures/source",
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    selectedPaths: [],
    destinationRoot: "fixtures/destination",
    artifactRoot: "fixtures/artifacts",
    enableRepoPrompts: false,
    emitIntermediateState: false,
    ...overrides,
  };
}

function record(overrides: Partial<MappingRecord>): MappingRecord {
  return {
    sourcePath: "x.md",
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    sourceKind: SourceKind.REUSABLE_SKILL,
    conversionClass: ConversionClass.DIRECT,
    targetRole: TargetRole.SHARED_SKILL,
    targetPath: ".agents/skills/x/SKILL.md",
    notes: [],
    isRequired: true,
    ...overrides,
  };
}

function emission(overrides: Partial<PlannedEmission>): PlannedEmission {
  return {
    sourcePath: ".github/prompts/review-feature.prompt.md",
    sectionId: ".github/prompts/review-feature.prompt.md#gate-1",
    heading: "Gate",
    intentKind: SectionIntentKind.HOOK_CANDIDATE,
    targetRole: TargetRole.HOOK,
    targetPath: ".codex/hooks/review-feature.ps1",
    notes: [],
    ...overrides,
  };
}

describe("validateConversionPlan", () => {
  it("emits a missing-required-input finding when apply mode lacks a destination", () => {
    const findings = validateConversionPlan(
      runOptions({ destinationRoot: null }),
      [],
      [],
      {},
    );
    expect(findings.some((f) => f.code === "missing-required-input")).toBe(
      true,
    );
  });

  it("blocks unresolved hard-gate, handoff, and mcp mappings via note flags", () => {
    const findings = validateConversionPlan(
      runOptions(),
      [
        record({
          sourcePath: "hard-gate.md",
          sourceKind: SourceKind.AGENT_MANIFEST,
          conversionClass: ConversionClass.DECOMPOSED,
          targetRole: TargetRole.SUBAGENT,
          targetPath: ".codex/agents/hard-gate.toml",
          notes: ["requires-native-hard-gate"],
        }),
        record({
          sourcePath: "handoff.md",
          sourceKind: SourceKind.AGENT_MANIFEST,
          conversionClass: ConversionClass.DECOMPOSED,
          targetRole: TargetRole.SUBAGENT,
          targetPath: ".codex/agents/handoff.toml",
          notes: ["requires-handoff-review"],
        }),
        record({
          sourcePath: "mcp.md",
          sourceKind: SourceKind.HOST_ADAPTER_REFERENCE,
          conversionClass: ConversionClass.DECOMPOSED,
          targetRole: TargetRole.MCP_CONFIG,
          targetPath: ".codex/config.toml",
          notes: ["requires-mcp-rewrite"],
        }),
      ],
      [],
      {},
    );
    const codes = new Set(findings.map((f) => f.code));
    expect(codes.has("unresolved-hard-gate-mapping")).toBe(true);
    expect(codes.has("unresolved-handoff-mapping")).toBe(true);
    expect(codes.has("unresolved-mcp-rewrite")).toBe(true);
  });

  it("blocks a required unsupported artifact with unsupported-ecosystem", () => {
    const findings = validateConversionPlan(
      runOptions(),
      [
        record({
          conversionClass: ConversionClass.UNSUPPORTED,
          targetRole: TargetRole.UNSUPPORTED,
          targetPath: null,
          isRequired: true,
        }),
      ],
      [],
      {},
    );
    expect(findings.some((f) => f.code === "unsupported-ecosystem")).toBe(true);
  });

  it("blocks duplicate target paths and lingering runtime references", () => {
    const findings = validateConversionPlan(
      runOptions(),
      [
        record({ sourcePath: "first.md" }),
        record({
          sourcePath: "second.md",
          sourceKind: SourceKind.PATH_SCOPED_INSTRUCTION,
          conversionClass: ConversionClass.DECOMPOSED,
        }),
      ],
      [],
      {
        ".agents/skills/x/SKILL.md":
          "This output still points at .github/instructions/runtime.instructions.md.",
      },
    );
    const codes = new Set(findings.map((f) => f.code));
    expect(codes.has("duplicate-target-path")).toBe(true);
    expect(codes.has("lingering-source-runtime-reference")).toBe(true);
  });

  it("allows multiple standing-guidance inputs to merge into AGENTS.md", () => {
    const findings = validateConversionPlan(
      runOptions(),
      [
        record({
          sourcePath: ".github/copilot-instructions.md",
          sourceKind: SourceKind.STANDING_INSTRUCTION,
          targetRole: TargetRole.STANDING_GUIDANCE,
          targetPath: "AGENTS.md",
        }),
        record({
          sourcePath: ".github/instructions/general.instructions.md",
          sourceKind: SourceKind.PATH_SCOPED_INSTRUCTION,
          conversionClass: ConversionClass.DECOMPOSED,
          targetRole: TargetRole.STANDING_GUIDANCE,
          targetPath: "AGENTS.md",
        }),
      ],
      [],
      {},
    );
    expect(findings.some((f) => f.code === "duplicate-target-path")).toBe(
      false,
    );
  });

  it("allows multiple sections from one source prompt to merge into one target", () => {
    const findings = validateConversionPlan(
      runOptions(),
      [],
      [
        emission({ sectionId: "a#gate-1" }),
        emission({ sectionId: "a#gate-2", heading: "Required deliverables" }),
      ],
      {},
    );
    expect(findings.some((f) => f.code === "duplicate-target-path")).toBe(
      false,
    );
  });

  it("blocks conflicting target paths claimed by separate section-emission groups", () => {
    const findings = validateConversionPlan(
      runOptions(),
      [],
      [
        emission({ sourcePath: ".github/prompts/review-feature.prompt.md" }),
        emission({
          sourcePath: ".github/prompts/review-staged.prompt.md",
          heading: "Required deliverables",
        }),
      ],
      {},
    );
    expect(findings.some((f) => f.code === "duplicate-target-path")).toBe(true);
  });

  it("returns no findings for a clean review-mode plan", () => {
    const findings = validateConversionPlan(
      runOptions({ mode: "review", destinationRoot: null }),
      [record({})],
      [],
      {
        ".agents/skills/x/SKILL.md":
          "Clean native content referencing AGENTS.md.",
      },
    );
    expect(findings).toEqual([]);
  });

  it("returns findings sorted by code then source then target", () => {
    const findings = validateConversionPlan(
      runOptions(),
      [
        record({
          sourcePath: "second.md",
          conversionClass: ConversionClass.UNSUPPORTED,
          targetRole: TargetRole.UNSUPPORTED,
          targetPath: null,
        }),
        record({
          sourcePath: "first.md",
          conversionClass: ConversionClass.UNSUPPORTED,
          targetRole: TargetRole.UNSUPPORTED,
          targetPath: null,
        }),
      ],
      [],
      {},
    );
    // Both findings share the unsupported-ecosystem code; sourcePath orders them.
    expect(findings.map((f) => f.sourcePath)).toEqual([
      "first.md",
      "second.md",
    ]);
  });

  it("889-null-arm: applies the null source-path default on both operands and orders by target path", () => {
    // Arrange: lingering-reference findings always carry a null source path,
    // so the source-path default applies to both operands and the target path
    // decides. Both generated-output insertion orders are exercised.
    const trigger =
      "This output still points at .github/instructions/runtime.instructions.md.";
    const outputs = [
      { "z.md": trigger, "a.md": trigger },
      { "a.md": trigger, "z.md": trigger },
    ];

    for (const generatedOutput of outputs) {
      // Act
      const lingering = validateConversionPlan(
        runOptions(),
        [],
        [],
        generatedOutput,
      ).filter((f) => f.code === "lingering-source-runtime-reference");

      // Assert
      expect(lingering.map((f) => f.sourcePath)).toEqual([null, null]);
      expect(lingering.map((f) => f.targetPath)).toEqual(["a.md", "z.md"]);
    }
  });

  it("889-null-arm: sorts a null target path before a non-null one in both input orders", () => {
    // Arrange: equal code and source path, so the target path decides.
    const nonNull = record({
      sourcePath: "s.md",
      conversionClass: ConversionClass.UNSUPPORTED,
      targetRole: TargetRole.UNSUPPORTED,
      targetPath: ".agents/x/SKILL.md",
    });
    const nullPath = record({
      sourcePath: "s.md",
      conversionClass: ConversionClass.UNSUPPORTED,
      targetRole: TargetRole.UNSUPPORTED,
      targetPath: null,
    });
    const inputOrders = [
      [nonNull, nullPath],
      [nullPath, nonNull],
    ];

    for (const records of inputOrders) {
      // Act
      const unsupported = validateConversionPlan(
        runOptions(),
        records,
        [],
        {},
      ).filter((f) => f.code === "unsupported-ecosystem");

      // Assert
      expect(unsupported.map((f) => f.targetPath)).toEqual([
        null,
        ".agents/x/SKILL.md",
      ]);
    }
  });
});
