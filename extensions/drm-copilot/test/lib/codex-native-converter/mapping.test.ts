import { describe, expect, it } from "@jest/globals";

import {
  planSectionTargetPath,
  planTargetPaths,
} from "../../../src/lib/codex-native-converter/mapping";
import {
  ConversionClass,
  type MappingRecord,
  SourceEcosystem,
  SourceKind,
  TargetRole,
} from "../../../src/lib/codex-native-converter/models";

function record(overrides: Partial<MappingRecord>): MappingRecord {
  return {
    sourcePath: ".github/prompts/launch.prompt.md",
    sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
    sourceKind: SourceKind.LAUNCHER_PROMPT,
    conversionClass: ConversionClass.REPO_CONVENTION,
    targetRole: TargetRole.LAUNCHER,
    targetPath: null,
    notes: [],
    isRequired: true,
    ...overrides,
  };
}

describe("planTargetPaths", () => {
  it("maps standing guidance to AGENTS.md", () => {
    const planned = planTargetPaths(
      record({ targetRole: TargetRole.STANDING_GUIDANCE }),
      { enableRepoPrompts: false },
    );
    expect(planned.targetPath).toBe("AGENTS.md");
  });

  it("uses the reusable skill folder name for SKILL.md targets", () => {
    const planned = planTargetPaths(
      record({
        sourcePath: ".github/skills/review-workflow/SKILL.md",
        sourceKind: SourceKind.REUSABLE_SKILL,
        conversionClass: ConversionClass.DIRECT,
        targetRole: TargetRole.SHARED_SKILL,
      }),
      { enableRepoPrompts: false },
    );
    expect(planned.targetPath).toBe(".agents/skills/review-workflow/SKILL.md");
  });

  it("keeps filename-based naming for path-scoped instruction skills", () => {
    const planned = planTargetPaths(
      record({
        sourcePath: ".github/instructions/general-code-change.instructions.md",
        sourceKind: SourceKind.PATH_SCOPED_INSTRUCTION,
        conversionClass: ConversionClass.DECOMPOSED,
        targetRole: TargetRole.SHARED_SKILL,
      }),
      { enableRepoPrompts: false },
    );
    expect(planned.targetPath).toBe(
      ".agents/skills/general-code-change/SKILL.md",
    );
  });

  it("maps a subagent to a .codex/agents toml target", () => {
    const planned = planTargetPaths(
      record({
        sourcePath: ".github/agents/orchestrator.agent.md",
        sourceKind: SourceKind.AGENT_MANIFEST,
        conversionClass: ConversionClass.DECOMPOSED,
        targetRole: TargetRole.SUBAGENT,
      }),
      { enableRepoPrompts: false },
    );
    expect(planned.targetPath).toBe(".codex/agents/orchestrator.toml");
  });

  it("maps MCP config to the codex config target", () => {
    const planned = planTargetPaths(
      record({
        sourcePath: ".claude/settings.json",
        sourceKind: SourceKind.PERMISSIONS_OR_SETTINGS,
        targetRole: TargetRole.MCP_CONFIG,
      }),
      { enableRepoPrompts: false },
    );
    expect(planned.targetPath).toBe(".codex/config.toml");
  });

  it("emits a powershell hook target without duplicating the script extension", () => {
    const planned = planTargetPaths(
      record({
        sourcePath: ".claude/hooks/check_python_test_purity.ps1",
        sourceKind: SourceKind.HOOK_DEFINITION,
        conversionClass: ConversionClass.DIRECT,
        targetRole: TargetRole.HOOK,
      }),
      { enableRepoPrompts: false },
    );
    expect(planned.targetPath).toBe(
      ".codex/hooks/check-python-test-purity.ps1",
    );
  });

  it("maps an approval rule to a .codex/rules target", () => {
    const planned = planTargetPaths(
      record({
        sourcePath: ".claude/rules/shell-policy.md",
        targetRole: TargetRole.APPROVAL_RULE,
      }),
      { enableRepoPrompts: false },
    );
    expect(planned.targetPath).toBe(".codex/rules/shell-policy.rules");
  });

  it("emits a .codex/prompts launcher target when repo prompts are enabled", () => {
    const planned = planTargetPaths(record({}), { enableRepoPrompts: true });
    expect(planned.targetPath).toBe(".codex/prompts/launch.md");
  });

  it("demotes launcher prompts to unsupported when repo prompts are disabled", () => {
    const planned = planTargetPaths(record({}), { enableRepoPrompts: false });
    expect(planned.conversionClass).toBe(ConversionClass.UNSUPPORTED);
    expect(planned.targetRole).toBe(TargetRole.UNSUPPORTED);
    expect(planned.targetPath).toBeNull();
    expect(planned.isRequired).toBe(false);
    expect(planned.notes).toContain(
      "Repository-convention prompt output is disabled for this run.",
    );
  });

  it("preserves prior notes when demoting a launcher prompt", () => {
    const planned = planTargetPaths(record({ notes: ["prior note"] }), {
      enableRepoPrompts: false,
    });
    expect(planned.notes[0]).toBe("prior note");
  });

  it("returns a null target for an unsupported role", () => {
    const planned = planTargetPaths(
      record({ targetRole: TargetRole.UNSUPPORTED }),
      { enableRepoPrompts: false },
    );
    expect(planned.targetPath).toBeNull();
  });
});

describe("planSectionTargetPath", () => {
  it("resolves a shared-skill section target", () => {
    const target = planSectionTargetPath(".github/prompts/x.prompt.md", {
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.LAUNCHER_PROMPT,
      targetRole: TargetRole.SHARED_SKILL,
      enableRepoPrompts: false,
    });
    expect(target).toBe(".agents/skills/x/SKILL.md");
  });

  it("returns null for a launcher section when repo prompts are disabled", () => {
    const target = planSectionTargetPath(".github/prompts/x.prompt.md", {
      sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
      sourceKind: SourceKind.LAUNCHER_PROMPT,
      targetRole: TargetRole.LAUNCHER,
      enableRepoPrompts: false,
    });
    expect(target).toBeNull();
  });
});
