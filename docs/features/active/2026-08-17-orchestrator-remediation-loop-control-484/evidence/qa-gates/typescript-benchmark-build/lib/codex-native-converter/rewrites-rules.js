"use strict";
/**
 * Rewrite-rule table builder for the Codex-native converter.
 *
 * Purpose:
 *     Hold the ordered rewrite-rule catalog (`_BASE_REWRITE_RULES`,
 *     `_PROMPT_SKILL_FALLBACKS`, and the `_rewrite_rules` builder) ported from
 *     `rewrites.py`, so `rewrites.ts` stays within the 500-line policy.
 *
 * Invariants:
 *     Every pattern, replacement, and rule order is preserved verbatim from the
 *     Python source so rewrite output and applied-rule metadata are identical.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildRewriteRules = buildRewriteRules;
const rewrites_1 = require("./rewrites");
/**
 * Escape regular-expression metacharacters in a literal pattern segment,
 * matching Python `re.escape` for the characters that appear in source paths.
 *
 * @param value Literal text to escape.
 * @returns The escaped text.
 */
function escapeRegExp(value) {
    return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
/**
 * The fixed base rewrite catalog applied to every run, in order.
 *
 * Mirrors `_BASE_REWRITE_RULES` from `rewrites.py`.
 */
const BASE_REWRITE_RULES = [
    {
        pattern: /(?<![A-Za-z0-9_])\.github\/copilot-instructions\.md\b/g,
        replacement: "AGENTS.md",
        description: "Rewrite GitHub Copilot standing guidance paths to AGENTS.md.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.github\/instructions\/([A-Za-z0-9_.-]+)\.instructions\.md\b/g,
        replacement: (_match, group1) => `.agents/skills/${(0, rewrites_1.normalizeTargetName)(group1)}/SKILL.md`,
        description: "Rewrite GitHub Copilot path-scoped instructions to shared skill paths.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.github\/skills\/([A-Za-z0-9_.-]+)\/SKILL\.md\b/g,
        replacement: (_match, group1) => `.agents/skills/${(0, rewrites_1.normalizeTargetName)(group1)}/SKILL.md`,
        description: "Rewrite GitHub Copilot reusable skill paths to shared skill paths.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.github\/agents\/([A-Za-z0-9_.-]+)\.agent\.md\b/g,
        replacement: (_match, group1) => `.codex/agents/${(0, rewrites_1.normalizeTargetName)(group1)}.toml`,
        description: "Rewrite GitHub Copilot agent manifest paths to Codex agent paths.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.github\/instructions\//g,
        replacement: ".agents/skills/",
        description: "Rewrite GitHub Copilot instruction-directory references to the native " +
            "skill root.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.github\/skills\//g,
        replacement: ".agents/skills/",
        description: "Rewrite GitHub Copilot skill-directory references to the native skill " +
            "root.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.github\/agents\//g,
        replacement: ".codex/agents/",
        description: "Rewrite GitHub Copilot agent-directory references to the native agent " +
            "root.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])CLAUDE\.md\b/g,
        replacement: "AGENTS.md",
        description: "Rewrite Claude standing guidance paths to AGENTS.md.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/skills\/([A-Za-z0-9_.-]+)\/SKILL\.md\b/g,
        replacement: (_match, group1) => `.agents/skills/${(0, rewrites_1.normalizeTargetName)(group1)}/SKILL.md`,
        description: "Rewrite Claude skill paths to shared skill paths.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/agents\/([A-Za-z0-9_.-]+)\.md\b/g,
        replacement: (_match, group1) => `.codex/agents/${(0, rewrites_1.normalizeTargetName)(group1)}.toml`,
        description: "Rewrite Claude agent manifest paths to Codex agent paths.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/hooks\/([A-Za-z0-9_.-]+)\b/g,
        replacement: (_match, group1) => `.codex/hooks/${(0, rewrites_1.normalizeHookTargetName)(group1)}.ps1`,
        description: "Rewrite Claude hook paths to Codex hook paths.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/settings\.json\b/g,
        replacement: ".codex/config.toml",
        description: "Rewrite Claude settings paths to Codex config paths.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/rules\/([A-Za-z0-9_.-]+)\.md\b/g,
        replacement: (_match, group1) => `.agents/skills/${(0, rewrites_1.normalizeTargetName)(group1)}/SKILL.md`,
        description: "Rewrite Claude rule paths to shared skill paths.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/rules\//g,
        replacement: ".agents/skills/",
        description: "Rewrite Claude rules-directory references to the native skill root.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/skills\//g,
        replacement: ".agents/skills/",
        description: "Rewrite Claude skill-directory references to the native skill root.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/agents\//g,
        replacement: ".codex/agents/",
        description: "Rewrite Claude agent-directory references to the native agent root.",
    },
    {
        pattern: /(?<![A-Za-z0-9_])\.claude\/hooks\//g,
        replacement: ".codex/hooks/",
        description: "Rewrite Claude hook-directory references to the native hook root.",
    },
    {
        pattern: /\bdrmCopilotExtension\.collectPrContext\b/g,
        replacement: "mcp__drmCopilotExtension__collect_pr_context",
        description: "Rewrite VS Code collectPrContext command IDs to semantic MCP " +
            "tool usage.",
    },
    {
        pattern: /\bdrmCopilotExtension\.validateOrchestrationArtifacts\b/g,
        replacement: "mcp__drmCopilotExtension__validate_orchestration_artifacts",
        description: "Rewrite orchestration validator command IDs to semantic MCP tool " +
            "usage.",
    },
    {
        pattern: /Return the finalized plan for validation-only preflight through `atomic-executor` and preserve the same target file path across revision loops\. Do not claim nested worker delegation from within planner execution\./g,
        replacement: "Before reporting completion, explicitly spawn the `atomic-executor` " +
            "subagent for validation-only preflight. The delegated prompt MUST " +
            "include the exact directive `DIRECTIVE: PREFLIGHT VALIDATION ONLY`.\n\n" +
            "- `atomic-executor` MUST return exactly one of:\n" +
            "  - `PREFLIGHT: ALL CLEAR`\n" +
            "  - `PREFLIGHT: REVISIONS REQUIRED`\n" +
            "- Treat executor preflight findings as binding plan defects.\n" +
            "- If preflight returns `PREFLIGHT: REVISIONS REQUIRED`, revise the " +
            "same target plan file using the executor's precise plan delta and " +
            "re-run preflight.\n" +
            "- Reuse the same target plan file for every preflight revision " +
            "iteration in the same planning cycle.\n" +
            "- If the required `atomic-executor` handoff cannot be started or " +
            "completed, stop and report blocked state; do not self-approve the " +
            "plan.\n" +
            "- Before reporting completion, the target plan MUST pass the " +
            "`validate_orchestration_artifacts` MCP tool with `artifact_type: " +
            '"plan"` and `artifact_path: <plan-path>`.\n\n' +
            "Do not claim nested worker delegation from within planner execution.",
        description: "Expand the Claude atomic-planner preflight shorthand into the strict " +
            "Codex atomic-executor handoff contract.",
    },
    {
        pattern: /\bdrmCopilotExtension\.runPoshQcSuite\b/g,
        replacement: "mcp__drmCopilotExtension__run_poshqc_analyze",
        description: "Rewrite PoshQC suite command IDs to the semantic MCP analyzer " +
            "surface.",
    },
    {
        pattern: /\bdrmCopilotExtension\.([A-Za-z0-9_]+)\b/g,
        replacement: (_match, group1) => "mcp__drmCopilotExtension__" + (0, rewrites_1.camelOrPascalToSnake)(group1),
        description: "Rewrite remaining VS Code command IDs to semantic MCP tool usage.",
    },
];
/**
 * Known prompt-to-skill fallback pairs applied when repo prompts are disabled.
 *
 * Mirrors `_PROMPT_SKILL_FALLBACKS` from `rewrites.py`.
 */
const PROMPT_SKILL_FALLBACKS = [
    [
        ".github/prompts/fillout-prd-feature.prompt.md",
        ".agents/skills/fillout-prd-feature/SKILL.md",
    ],
    [
        ".github/prompts/generate-atomic-plan.prompt.md",
        ".agents/skills/atomic-plan-contract/SKILL.md",
    ],
    [
        ".github/prompts/orchestrate-csharp-work.prompt.md",
        ".agents/skills/orchestrate-csharp-work/SKILL.md",
    ],
    [
        ".github/prompts/orchestrate-powershell-work.prompt.md",
        ".agents/skills/orchestrate-powershell-work/SKILL.md",
    ],
    [
        ".github/prompts/orchestrate-python-work.prompt.md",
        ".agents/skills/orchestrate-python-work/SKILL.md",
    ],
    [
        ".github/prompts/orchestrate-work.prompt.md",
        ".agents/skills/orchestrate-work/SKILL.md",
    ],
    [
        ".github/prompts/research-issue.prompt.md",
        ".agents/skills/research-issue/SKILL.md",
    ],
    [
        ".github/prompts/review-feature.prompt.md",
        ".agents/skills/review-feature/SKILL.md",
    ],
];
/**
 * Build the ordered rewrite catalog for one converter run.
 *
 * Mirrors `_rewrite_rules`: prepends standing-guidance source-path rules, then
 * the base rules, then (when prompts are disabled) the prompt-skill fallback
 * rules, then (when prompts are enabled) the repo-prompt rules.
 *
 * @param options `enableRepoPrompts` and `standingGuidanceSourcePaths`.
 * @returns The ordered rewrite-rule catalog.
 */
function buildRewriteRules(options) {
    const { enableRepoPrompts, standingGuidanceSourcePaths } = options;
    const standingGuidanceRules = standingGuidanceSourcePaths.map((sourcePath) => ({
        pattern: new RegExp(`(?<![A-Za-z0-9_])${escapeRegExp(sourcePath)}\\b`, "g"),
        replacement: "AGENTS.md",
        description: "Rewrite merged standing-guidance source paths to the native " +
            "AGENTS.md target.",
    }));
    const promptSkillFallbackRules = [
        ...PROMPT_SKILL_FALLBACKS.map(([sourcePath, targetPath]) => ({
            pattern: new RegExp(`(?<![A-Za-z0-9_])${escapeRegExp(sourcePath)}\\b`, "g"),
            replacement: targetPath,
            description: "Rewrite a known GitHub prompt reference to the native shared " +
                "skill fallback when repository prompt launchers are disabled.",
        })),
        {
            pattern: /(?<![A-Za-z0-9_])\.github\/prompts\//g,
            replacement: ".agents/skills/",
            description: "Rewrite GitHub prompt-directory references to the native shared " +
                "skill root when repository prompt launchers are disabled.",
        },
    ];
    let promptRewriteRules = [];
    if (enableRepoPrompts) {
        promptRewriteRules = [
            {
                pattern: /(?<![A-Za-z0-9_])\.github\/prompts\/([A-Za-z0-9_.-]+?)(?:\.prompt)?\.md\b/g,
                replacement: (_match, group1) => `.codex/prompts/${(0, rewrites_1.normalizeTargetName)(group1)}.md`,
                description: "Rewrite GitHub prompt references to repository prompt paths.",
            },
            {
                pattern: /(?<![A-Za-z0-9_])\.github\/prompts\//g,
                replacement: ".codex/prompts/",
                description: "Rewrite GitHub prompt-directory references to repository prompt " +
                    "paths.",
            },
        ];
    }
    return [
        ...standingGuidanceRules,
        ...BASE_REWRITE_RULES,
        ...(enableRepoPrompts ? [] : promptSkillFallbackRules),
        ...promptRewriteRules,
    ];
}
