import { describe, expect, it } from "@jest/globals";

import {
  ConversionClass,
  type MappingRecord,
  mappingRecordToJson,
  type PlannedEmission,
  plannedEmissionToJson,
  type RunOptions,
  runOptionsToJson,
  type SectionIntent,
  sectionIntentToJson,
  SectionIntentKind,
  SemanticCueKind,
  type SourceArtifact,
  sourceArtifactToJson,
  SourceEcosystem,
  SourceKind,
  TargetRole,
  type TranslationTrace,
  translationTraceToJson,
  type ValidationFinding,
  validationFindingToJson,
} from "../../../src/lib/codex-native-converter/models";

describe("codex-native-converter models enums", () => {
  it("preserves every SourceKind string value", () => {
    // Arrange / Act / Assert: each value must match the Python enum verbatim.
    expect(Object.values(SourceKind).sort()).toEqual(
      [
        "standing-instruction",
        "path-scoped-instruction",
        "reusable-skill",
        "agent-manifest",
        "launcher-prompt",
        "hook-definition",
        "permissions-or-settings",
        "shell-policy-or-rule",
        "mcp-dependency-declaration",
        "host-adapter-reference",
        "unknown",
      ].sort(),
    );
  });

  it("preserves every TargetRole string value", () => {
    expect(Object.values(TargetRole).sort()).toEqual(
      [
        "standing-guidance",
        "shared-skill",
        "subagent",
        "hook",
        "approval-rule",
        "mcp-config",
        "launcher",
        "unsupported",
      ].sort(),
    );
  });

  it("preserves every ConversionClass string value", () => {
    expect(Object.values(ConversionClass).sort()).toEqual(
      ["direct", "decomposed", "repo-convention", "unsupported"].sort(),
    );
  });

  it("preserves every SectionIntentKind string value", () => {
    expect(Object.values(SectionIntentKind).sort()).toEqual(
      [
        "identity",
        "standing-guidance",
        "shared-workflow",
        "hook-candidate",
        "rule-candidate",
        "config-candidate",
        "launcher-only",
        "unsupported",
      ].sort(),
    );
  });

  it("preserves every SemanticCueKind string value", () => {
    expect(Object.values(SemanticCueKind).sort()).toEqual(
      [
        "heading",
        "numbered-workflow",
        "hard-gate",
        "forbidden-pattern",
        "launcher-wrapper",
        "tool-requirement",
      ].sort(),
    );
  });

  it("preserves every SourceEcosystem string value", () => {
    expect(Object.values(SourceEcosystem).sort()).toEqual(
      ["github-copilot", "claude"].sort(),
    );
  });
});

describe("mappingRecordToJson", () => {
  it("serializes a populated record with notes list and default is_required true", () => {
    // Arrange
    const record: MappingRecord = {
      sourcePath: ".github/copilot-instructions.md",
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.STANDING_INSTRUCTION,
      conversionClass: ConversionClass.DIRECT,
      targetRole: TargetRole.STANDING_GUIDANCE,
      targetPath: "AGENTS.md",
      notes: ["note one", "note two"],
      isRequired: true,
    };

    // Act
    const json = mappingRecordToJson(record);

    // Assert
    expect(json).toEqual({
      source_path: ".github/copilot-instructions.md",
      source_ecosystem: "github-copilot",
      source_kind: "standing-instruction",
      conversion_class: "direct",
      target_role: "standing-guidance",
      target_path: "AGENTS.md",
      notes: ["note one", "note two"],
      is_required: true,
    });
  });

  it("serializes a null target_path and empty notes", () => {
    // Arrange
    const record: MappingRecord = {
      sourcePath: ".github/skills/README.md",
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.UNKNOWN,
      conversionClass: ConversionClass.UNSUPPORTED,
      targetRole: TargetRole.UNSUPPORTED,
      targetPath: null,
      notes: [],
      isRequired: false,
    };

    // Act
    const json = mappingRecordToJson(record);

    // Assert
    expect(json.target_path).toBeNull();
    expect(json.notes).toEqual([]);
    expect(json.is_required).toBe(false);
  });
});

describe("validationFindingToJson", () => {
  it("serializes a finding with null source and target paths", () => {
    // Arrange
    const finding: ValidationFinding = {
      code: "missing-required-input",
      severity: "error",
      blocking: true,
      sourcePath: null,
      targetPath: null,
      message: "Apply mode requires an explicit destination root.",
      recommendedAction: "Provide destination_root before running apply mode.",
    };

    // Act
    const json = validationFindingToJson(finding);

    // Assert
    expect(json).toEqual({
      code: "missing-required-input",
      severity: "error",
      blocking: true,
      source_path: null,
      target_path: null,
      message: "Apply mode requires an explicit destination root.",
      recommended_action: "Provide destination_root before running apply mode.",
    });
  });
});

describe("runOptionsToJson", () => {
  it("converts paths to POSIX, serializes empty selected_paths, null destination, and default flags", () => {
    // Arrange
    const options: RunOptions = {
      mode: "review",
      sourceRoot: "C:\\workspace\\source",
      sourceEcosystem: SourceEcosystem.CLAUDE,
      selectedPaths: [],
      destinationRoot: null,
      artifactRoot: "C:\\workspace\\artifacts\\codex-native-converter",
      enableRepoPrompts: false,
      emitIntermediateState: false,
    };

    // Act
    const json = runOptionsToJson(options);

    // Assert
    expect(json).toEqual({
      mode: "review",
      source_root: "C:/workspace/source",
      source_ecosystem: "claude",
      selected_paths: [],
      destination_root: null,
      artifact_root: "C:/workspace/artifacts/codex-native-converter",
      enable_repo_prompts: false,
      emit_intermediate_state: false,
    });
  });

  it("serializes populated selected_paths and a non-null destination_root in POSIX form", () => {
    // Arrange
    const options: RunOptions = {
      mode: "apply",
      sourceRoot: "/repo/source",
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      selectedPaths: ["a\\b.md", "c/d.md"],
      destinationRoot: "C:\\repo\\dest",
      artifactRoot: "/repo/artifacts",
      enableRepoPrompts: true,
      emitIntermediateState: true,
    };

    // Act
    const json = runOptionsToJson(options);

    // Assert
    expect(json.selected_paths).toEqual(["a/b.md", "c/d.md"]);
    expect(json.destination_root).toBe("C:/repo/dest");
    expect(json.enable_repo_prompts).toBe(true);
    expect(json.emit_intermediate_state).toBe(true);
  });
});

describe("intermediate serializers", () => {
  it("serializes a planned emission with enum string values and notes", () => {
    // Arrange
    const emission: PlannedEmission = {
      sourcePath: ".github/prompts/x.prompt.md",
      sectionId: ".github/prompts/x.prompt.md#workflow-3",
      heading: "Workflow",
      intentKind: SectionIntentKind.SHARED_WORKFLOW,
      targetRole: TargetRole.SHARED_SKILL,
      targetPath: ".agents/skills/x/SKILL.md",
      notes: ["a note"],
    };

    // Act
    const json = plannedEmissionToJson(emission);

    // Assert
    expect(json).toEqual({
      source_path: ".github/prompts/x.prompt.md",
      section_id: ".github/prompts/x.prompt.md#workflow-3",
      heading: "Workflow",
      intent_kind: "shared-workflow",
      target_role: "shared-skill",
      target_path: ".agents/skills/x/SKILL.md",
      notes: ["a note"],
    });
  });

  it("serializes a section intent", () => {
    // Arrange
    const intent: SectionIntent = {
      sourcePath: "CLAUDE.md",
      sectionId: "CLAUDE.md#body-1",
      heading: "Body",
      intentKind: SectionIntentKind.STANDING_GUIDANCE,
      notes: [],
    };

    // Act
    const json = sectionIntentToJson(intent);

    // Assert
    expect(json).toEqual({
      source_path: "CLAUDE.md",
      section_id: "CLAUDE.md#body-1",
      heading: "Body",
      intent_kind: "standing-guidance",
      notes: [],
    });
  });

  it("serializes a translation trace with a null target path", () => {
    // Arrange
    const trace: TranslationTrace = {
      sourcePath: ".github/prompts/x.prompt.md",
      sectionId: ".github/prompts/x.prompt.md#__launcher__",
      heading: "Launcher Surface",
      intentKind: SectionIntentKind.LAUNCHER_ONLY,
      targetRole: TargetRole.LAUNCHER,
      targetPath: null,
      notes: ["note"],
    };

    // Act
    const json = translationTraceToJson(trace);

    // Assert
    expect(json).toEqual({
      source_path: ".github/prompts/x.prompt.md",
      section_id: ".github/prompts/x.prompt.md#__launcher__",
      heading: "Launcher Surface",
      intent_kind: "launcher-only",
      target_role: "launcher",
      target_path: null,
      notes: ["note"],
    });
  });
});

describe("sourceArtifactToJson", () => {
  it("sorts frontmatter keys and serializes section cues deterministically", () => {
    // Arrange
    const artifact: SourceArtifact = {
      sourcePath: ".github/prompts/x.prompt.md",
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.LAUNCHER_PROMPT,
      frontmatter: { mode: "agent", applyTo: "**" },
      rawText: "raw",
      sections: [
        {
          sectionId: ".github/prompts/x.prompt.md#workflow-3",
          heading: "Workflow",
          level: 2,
          content: "1. do\n2. then",
          startLine: 3,
          endLine: 5,
          cues: [{ kind: SemanticCueKind.HEADING, value: "Workflow" }],
        },
      ],
    };

    // Act
    const json = sourceArtifactToJson(artifact);

    // Assert: frontmatter keys sorted (applyTo before mode), cues preserved.
    expect(Object.keys(json.frontmatter as Record<string, string>)).toEqual([
      "applyTo",
      "mode",
    ]);
    expect(json.sections).toEqual([
      {
        section_id: ".github/prompts/x.prompt.md#workflow-3",
        heading: "Workflow",
        level: 2,
        start_line: 3,
        end_line: 5,
        cues: [{ kind: "heading", value: "Workflow" }],
      },
    ]);
  });
});
