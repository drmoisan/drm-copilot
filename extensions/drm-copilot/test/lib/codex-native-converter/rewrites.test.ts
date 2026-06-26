import { describe, expect, it } from "@jest/globals";

import {
  camelOrPascalToSnake,
  detectUnresolvedRuntimeReference,
  normalizeHookTargetName,
  normalizeTargetName,
  rewriteSupportedAutomationReference,
} from "../../../src/lib/codex-native-converter/rewrites";

describe("rewriteSupportedAutomationReference", () => {
  it("rewrites supported Copilot paths and command identifiers to native targets", () => {
    const sourceText = [
      "See .github/copilot-instructions.md first.",
      "Open .github/instructions/general-code-change.instructions.md.",
      "Use .github/skills/review-workflow/SKILL.md during review.",
      "Delegate to .github/agents/orchestrator.agent.md.",
      "Run drmCopilotExtension.collectPrContext before proceeding.",
    ].join("\n");

    const [rewritten, applied] = rewriteSupportedAutomationReference(
      sourceText,
      { enableRepoPrompts: false },
    );

    expect(rewritten).toContain("AGENTS.md");
    expect(rewritten).toContain(".agents/skills/general-code-change/SKILL.md");
    expect(rewritten).toContain(".agents/skills/review-workflow/SKILL.md");
    expect(rewritten).toContain(".codex/agents/orchestrator.toml");
    expect(rewritten).toContain("mcp__drmCopilotExtension__collect_pr_context");
    expect(rewritten).not.toContain(".github/");
    expect(applied.length).toBeGreaterThan(0);
    expect(detectUnresolvedRuntimeReference(rewritten)).toEqual([]);
  });

  it("rewrites GitHub prompt references in both prompt modes", () => {
    const sourceText =
      "Launch .github/prompts/launch-review.prompt.md after setup.";

    const [withoutPrompts] = rewriteSupportedAutomationReference(sourceText, {
      enableRepoPrompts: false,
    });
    const [withPrompts] = rewriteSupportedAutomationReference(sourceText, {
      enableRepoPrompts: true,
    });

    expect(withoutPrompts).not.toContain(".github/prompts/");
    expect(withoutPrompts).toContain(".agents/skills/launch-review.prompt.md");
    expect(withPrompts).toContain(".codex/prompts/launch-review.md");
  });

  it("rewrites known prompt references to shared-skill fallbacks when disabled", () => {
    const sourceText = [
      "Use .github/prompts/generate-atomic-plan.prompt.md as the canonical template.",
      "Then run .github/prompts/review-feature.prompt.md for the audit workflow.",
      "Finally use .github/prompts/research-issue.prompt.md for implementation research.",
    ].join("\n");

    const [rewritten] = rewriteSupportedAutomationReference(sourceText, {
      enableRepoPrompts: false,
    });

    expect(rewritten).toContain(".agents/skills/atomic-plan-contract/SKILL.md");
    expect(rewritten).toContain(".agents/skills/review-feature/SKILL.md");
    expect(rewritten).toContain(".agents/skills/research-issue/SKILL.md");
    expect(rewritten).not.toContain(".github/prompts/");
    expect(detectUnresolvedRuntimeReference(rewritten)).toEqual([]);
  });

  it("rewrites directory-level instruction references to the native skill root", () => {
    const [rewritten] = rewriteSupportedAutomationReference(
      "Review guidance in .github/instructions/ before proceeding.",
      { enableRepoPrompts: false },
    );

    expect(rewritten).toContain(".agents/skills/");
    expect(rewritten).not.toContain(".github/instructions/");
    expect(detectUnresolvedRuntimeReference(rewritten)).toEqual([]);
  });

  it("rewrites Claude hook paths to PowerShell Codex hook targets without doubling extensions", () => {
    const [rewritten] = rewriteSupportedAutomationReference(
      "Run .claude/hooks/check-python-test-purity.ps1 before review.",
      { enableRepoPrompts: false },
    );

    expect(rewritten).toContain(".codex/hooks/check-python-test-purity.ps1");
    expect(rewritten).not.toContain(".ps1.ps1");
    expect(detectUnresolvedRuntimeReference(rewritten)).toEqual([]);
  });

  it("rewrites bare and placeholder Claude directory references to native roots", () => {
    const sourceText = [
      "See .claude/skills/<name>/SKILL.md and .claude/skills/**/SKILL.md examples.",
      "Reference .claude/agents/*.md and .claude/hooks/<name>.ps1 for routing.",
      "Bare ref: .claude/hooks/ followed by content.",
    ].join("\n");

    const [rewritten] = rewriteSupportedAutomationReference(sourceText, {
      enableRepoPrompts: false,
    });

    expect(rewritten).not.toContain(".claude/skills/");
    expect(rewritten).not.toContain(".claude/agents/");
    expect(rewritten).not.toContain(".claude/hooks/");
    expect(rewritten).toContain(".agents/skills/");
    expect(rewritten).toContain(".codex/agents/");
    expect(rewritten).toContain(".codex/hooks/");
    expect(detectUnresolvedRuntimeReference(rewritten)).toEqual([]);
  });

  it("rewrites named Claude rule paths to shared skill paths", () => {
    const [rewritten] = rewriteSupportedAutomationReference(
      "Apply .claude/rules/python.md and .claude/rules/tonality.md before review.",
      { enableRepoPrompts: false },
    );

    expect(rewritten).toContain(".agents/skills/python/SKILL.md");
    expect(rewritten).toContain(".agents/skills/tonality/SKILL.md");
    expect(rewritten).not.toContain(".claude/rules/");
  });

  it("expands the atomic-planner preflight shorthand into the Codex handoff contract", () => {
    const sourceText =
      "Return the finalized plan for validation-only preflight through " +
      "`atomic-executor` and preserve the same target file path across revision " +
      "loops. Do not claim nested worker delegation from within planner execution.";

    const [rewritten, applied] = rewriteSupportedAutomationReference(
      sourceText,
      { enableRepoPrompts: false },
    );

    expect(rewritten).toContain(
      "explicitly spawn the `atomic-executor` subagent",
    );
    expect(rewritten).toContain("`DIRECTIVE: PREFLIGHT VALIDATION ONLY`");
    expect(rewritten).toContain("`PREFLIGHT: ALL CLEAR`");
    expect(rewritten).toContain("`PREFLIGHT: REVISIONS REQUIRED`");
    expect(rewritten).toContain(
      "Treat executor preflight findings as binding plan defects",
    );
    expect(rewritten).toContain("Reuse the same target plan file");
    expect(rewritten).toContain("stop and report blocked state");
    expect(rewritten).toContain("validate_orchestration_artifacts` MCP tool");
    expect(
      applied.some((description) =>
        description.includes(
          "Expand the Claude atomic-planner preflight shorthand",
        ),
      ),
    ).toBe(true);
  });

  it("rewrites bare Claude rules-directory references to the native skill root", () => {
    const [rewritten] = rewriteSupportedAutomationReference(
      "Browse .claude/rules/ for the policy catalog.",
      { enableRepoPrompts: false },
    );

    expect(rewritten).not.toContain(".claude/rules/");
    expect(rewritten).toContain(".agents/skills/");
  });

  it("rewrites bare GitHub prompt-directory references when prompts are disabled", () => {
    const [rewritten] = rewriteSupportedAutomationReference(
      "Browse .github/prompts/ and look at .github/prompts/*.prompt.md for guidance.",
      { enableRepoPrompts: false },
    );

    expect(rewritten).not.toContain(".github/prompts/");
    expect(rewritten).toContain(".agents/skills/");
    expect(detectUnresolvedRuntimeReference(rewritten)).toEqual([]);
  });

  it("rewrites GitHub prompt references to repo-prompt paths when prompts are enabled", () => {
    const [rewritten] = rewriteSupportedAutomationReference(
      "Browse .github/prompts/ and .github/prompts/research-issue.prompt.md.",
      { enableRepoPrompts: true },
    );

    expect(rewritten).toContain(".codex/prompts/");
    expect(rewritten).toContain(".codex/prompts/research-issue.md");
  });

  it("rewrites standing-guidance source paths to AGENTS.md", () => {
    const [rewritten] = rewriteSupportedAutomationReference(
      "Merged from custom/standing.md elsewhere.",
      {
        enableRepoPrompts: false,
        standingGuidanceSourcePaths: ["custom/standing.md"],
      },
    );

    expect(rewritten).toContain("AGENTS.md");
    expect(rewritten).not.toContain("custom/standing.md");
  });
});

describe("normalizer helpers", () => {
  it("normalizeTargetName replaces underscores with hyphens", () => {
    expect(normalizeTargetName("a_b_c")).toBe("a-b-c");
  });

  it("normalizeHookTargetName strips .ps1 and .py suffixes after normalizing", () => {
    expect(normalizeHookTargetName("pre_session.ps1")).toBe("pre-session");
    expect(normalizeHookTargetName("check.py")).toBe("check");
    expect(normalizeHookTargetName("plain_name")).toBe("plain-name");
  });

  it("camelOrPascalToSnake converts identifiers to snake_case", () => {
    expect(camelOrPascalToSnake("collectPrContext")).toBe("collect_pr_context");
    expect(camelOrPascalToSnake("RunPoshQCSuite")).toBe("run_posh_qc_suite");
    expect(camelOrPascalToSnake("already-kebab")).toBe("already_kebab");
  });
});

describe("detectUnresolvedRuntimeReference", () => {
  it("detects multiple unresolved runtime reference kinds", () => {
    const findings = detectUnresolvedRuntimeReference(
      "Use drmCopilotExtension.someTool and CLAUDE.md and scripts/dev_tools/x.py.",
    );
    expect(findings).toContain("raw VS Code command identifier");
    expect(findings).toContain("Claude standing-instructions file");
    expect(findings).toContain("repository-local script reference");
  });

  it("returns an empty list for fully rewritten text", () => {
    expect(
      detectUnresolvedRuntimeReference("All native here: AGENTS.md"),
    ).toEqual([]);
  });

  it("ignores non-runtime github workflow paths", () => {
    expect(
      detectUnresolvedRuntimeReference(
        "This skill applies to .github/workflows/*.yml files.",
      ),
    ).toEqual([]);
  });
});
