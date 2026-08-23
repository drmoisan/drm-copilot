"use strict";
/**
 * Claude classification path and section-level prompt classification for the
 * Codex-native converter.
 *
 * Purpose:
 *     Hold `_classify_claude` and `classify_prompt_sections` (ported from
 *     `classifier.py`) so the classifier surface stays within the 500-line
 *     policy. `classifier.ts` consumes these.
 *
 * Invariants:
 *     Classification is deterministic and path-driven; file reads flow through
 *     the injected {@link FileSystem} via the shared `readOptionalText` helper.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.classifyClaude = classifyClaude;
exports.classifyPromptSections = classifyPromptSections;
const models_1 = require("./models");
const classifier_1 = require("./classifier");
// Prompt heading keywords that indicate reusable workflow or output-contract
// content suitable for a shared skill.
const PROMPT_WORKFLOW_HEADING_PATTERN = /(workflow|steps|task execution|required orchestration behavior|completion criteria|output format|what to investigate|section rules|execution rules|launch template|objective|goal)/i;
// Enforcement language that resembles a native validation hook.
const PROMPT_ENFORCEMENT_PATTERN = /\b(must not|blocked|forbidden|non-negotiable|hard lock|hard gate|must not begin|must be blocked)\b/i;
// Numbered-step structure indicating a procedural workflow.
const NUMBERED_STEP_PATTERN = /^\d+[.)]\s+/gm;
/**
 * Classify one Claude source artifact.
 *
 * Mirrors `_classify_claude`, preserving every `SourceKind`, `ConversionClass`,
 * `TargetRole`, note string, and branch ordering verbatim.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source root that bounds the artifact.
 * @param sourcePath Source-root-relative artifact path.
 * @returns The classification result with an unresolved target path.
 */
function classifyClaude(fileSystem, sourceRoot, sourcePath) {
    const pathText = sourcePath;
    const notes = [];
    if (pathText === "CLAUDE.md") {
        return {
            sourcePath: pathText,
            sourceEcosystem: models_1.SourceEcosystem.CLAUDE,
            sourceKind: models_1.SourceKind.STANDING_INSTRUCTION,
            conversionClass: models_1.ConversionClass.DIRECT,
            targetRole: models_1.TargetRole.STANDING_GUIDANCE,
            targetPath: null,
            notes: [],
            isRequired: true,
        };
    }
    if (pathText.includes("/SKILL.md") &&
        pathText.startsWith(".claude/skills/")) {
        return {
            sourcePath: pathText,
            sourceEcosystem: models_1.SourceEcosystem.CLAUDE,
            sourceKind: models_1.SourceKind.REUSABLE_SKILL,
            conversionClass: models_1.ConversionClass.DIRECT,
            targetRole: models_1.TargetRole.SHARED_SKILL,
            targetPath: null,
            notes: [],
            isRequired: true,
        };
    }
    if (pathText.startsWith(".claude/agents/") && pathText.endsWith(".md")) {
        const sourceText = (0, classifier_1.readOptionalText)(fileSystem, sourceRoot, sourcePath);
        if (sourceText.toLowerCase().includes("handoff") ||
            sourceText.toLowerCase().includes("agent:")) {
            notes.push("Claude agent manifest may encode orchestration or handoff " +
                "semantics that require validation before apply mode.");
        }
        return {
            sourcePath: pathText,
            sourceEcosystem: models_1.SourceEcosystem.CLAUDE,
            sourceKind: models_1.SourceKind.AGENT_MANIFEST,
            conversionClass: models_1.ConversionClass.DECOMPOSED,
            targetRole: models_1.TargetRole.SUBAGENT,
            targetPath: null,
            notes,
            isRequired: true,
        };
    }
    if (pathText.startsWith(".claude/hooks/")) {
        return {
            sourcePath: pathText,
            sourceEcosystem: models_1.SourceEcosystem.CLAUDE,
            sourceKind: models_1.SourceKind.HOOK_DEFINITION,
            conversionClass: models_1.ConversionClass.DIRECT,
            targetRole: models_1.TargetRole.HOOK,
            targetPath: null,
            notes: [],
            isRequired: true,
        };
    }
    if (pathText === ".claude/settings.json") {
        return {
            sourcePath: pathText,
            sourceEcosystem: models_1.SourceEcosystem.CLAUDE,
            sourceKind: models_1.SourceKind.PERMISSIONS_OR_SETTINGS,
            conversionClass: models_1.ConversionClass.DECOMPOSED,
            targetRole: models_1.TargetRole.MCP_CONFIG,
            targetPath: null,
            notes: [
                "Claude settings require decomposition across native Codex " +
                    "config, hooks, and approval surfaces.",
            ],
            isRequired: true,
        };
    }
    if (pathText.startsWith(".claude/rules/") && pathText.endsWith(".md")) {
        // Repo-wide rules merge into standing guidance; path-scoped ones decompose
        // into shared skills.
        if ((0, classifier_1.hasRepoWidePathsYaml)(fileSystem, sourceRoot, sourcePath)) {
            return {
                sourcePath: pathText,
                sourceEcosystem: models_1.SourceEcosystem.CLAUDE,
                sourceKind: models_1.SourceKind.PATH_SCOPED_INSTRUCTION,
                conversionClass: models_1.ConversionClass.DECOMPOSED,
                targetRole: models_1.TargetRole.STANDING_GUIDANCE,
                targetPath: null,
                notes: [
                    "Repo-wide Claude rule applies to all files and merges into " +
                        "standing guidance.",
                ],
                isRequired: true,
            };
        }
        return {
            sourcePath: pathText,
            sourceEcosystem: models_1.SourceEcosystem.CLAUDE,
            sourceKind: models_1.SourceKind.PATH_SCOPED_INSTRUCTION,
            conversionClass: models_1.ConversionClass.DECOMPOSED,
            targetRole: models_1.TargetRole.SHARED_SKILL,
            targetPath: null,
            notes: [
                "Path-scoped Claude rule requires decomposition into shared " +
                    "skills or standing guidance.",
            ],
            isRequired: true,
        };
    }
    return {
        sourcePath: pathText,
        sourceEcosystem: models_1.SourceEcosystem.CLAUDE,
        sourceKind: models_1.SourceKind.UNKNOWN,
        conversionClass: models_1.ConversionClass.UNSUPPORTED,
        targetRole: models_1.TargetRole.UNSUPPORTED,
        targetPath: null,
        notes: ["No supported Claude v1 mapping rule matched this artifact."],
        isRequired: true,
    };
}
/**
 * Count the number of non-overlapping matches of the numbered-step pattern.
 *
 * @param text Section content text.
 * @returns The number of numbered-step matches.
 */
function countNumberedSteps(text) {
    // A fresh RegExp avoids lastIndex state leaking across calls.
    const matches = text.match(new RegExp(NUMBERED_STEP_PATTERN.source, NUMBERED_STEP_PATTERN.flags));
    return matches ? matches.length : 0;
}
/**
 * Classify prompt sections into section-level semantic intents.
 *
 * Mirrors `classify_prompt_sections`: returns an empty list for non launcher
 * prompts; otherwise classifies each section as a hook candidate (enforcement
 * language) or a shared workflow (workflow heading or >= 2 numbered steps), and
 * skips sections that match neither.
 *
 * @param sourceArtifact Parsed source artifact for one prompt.
 * @returns Deterministic section-intent records in source order.
 */
function classifyPromptSections(sourceArtifact) {
    if (sourceArtifact.sourceKind !== models_1.SourceKind.LAUNCHER_PROMPT) {
        return [];
    }
    const sectionIntents = [];
    // Inspect each parsed section in source order and assign one intent.
    for (const sourceSection of sourceArtifact.sections) {
        const sectionText = sourceSection.content;
        const notes = [];
        let intentKind = models_1.SectionIntentKind.UNSUPPORTED;
        if (PROMPT_ENFORCEMENT_PATTERN.test(sectionText)) {
            intentKind = models_1.SectionIntentKind.HOOK_CANDIDATE;
            notes.push("Section contains hard-gate or forbidden-action language that " +
                "resembles a native validation hook.");
        }
        else if (PROMPT_WORKFLOW_HEADING_PATTERN.test(sourceSection.heading) ||
            countNumberedSteps(sectionText) >= 2) {
            intentKind = models_1.SectionIntentKind.SHARED_WORKFLOW;
            notes.push("Section contains reusable workflow or output-contract content " +
                "that maps more naturally to a shared skill.");
        }
        if (intentKind === models_1.SectionIntentKind.UNSUPPORTED) {
            continue;
        }
        sectionIntents.push({
            sourcePath: sourceArtifact.sourcePath,
            sectionId: sourceSection.sectionId,
            heading: sourceSection.heading,
            intentKind,
            notes,
        });
    }
    return sectionIntents;
}
