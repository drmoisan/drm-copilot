"use strict";
/**
 * Resolve approved Codex-native target paths for classified artifacts.
 *
 * Purpose:
 *     Convert classification records into concrete Codex-native destination
 *     paths while preserving the approved runtime surfaces. Ported from
 *     `mapping.py`; pure logic, no I/O.
 *
 * Invariants:
 *     Only approved Codex-native surfaces are emitted. Repository-convention
 *     prompt output remains disabled unless the caller explicitly enables it.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.planTargetPaths = planTargetPaths;
exports.planSectionTargetPath = planSectionTargetPath;
const models_1 = require("./models");
/**
 * Return the final path segment (basename) of a POSIX path.
 *
 * @param posixPath POSIX path.
 * @returns The basename.
 */
function posixName(posixPath) {
    const trimmed = posixPath.replace(/\/+$/, "");
    const index = trimmed.lastIndexOf("/");
    return index >= 0 ? trimmed.slice(index + 1) : trimmed;
}
/**
 * Return the parent folder name of a POSIX path, or an empty string when there
 * is no parent segment.
 *
 * @param posixPath POSIX path.
 * @returns The parent directory name.
 */
function posixParentName(posixPath) {
    const trimmed = posixPath.replace(/\/+$/, "");
    const index = trimmed.lastIndexOf("/");
    if (index < 0) {
        return "";
    }
    return posixName(trimmed.slice(0, index));
}
/**
 * Normalize one source path into a stable target-friendly base name.
 *
 * Mirrors `_normalized_name`: strips known ecosystem suffixes (first match
 * only) and replaces underscores with hyphens.
 *
 * @param sourcePath Source-root-relative path for the artifact.
 * @returns A kebab-case friendly base name.
 */
function normalizedName(sourcePath) {
    const sourceName = posixName(sourcePath);
    let normalized = sourceName;
    // Strip the first matching known suffix.
    for (const suffix of [
        ".instructions.md",
        ".agent.md",
        ".prompt.md",
        ".md",
        ".json",
    ]) {
        if (normalized.endsWith(suffix)) {
            normalized = normalized.slice(0, normalized.length - suffix.length);
            break;
        }
    }
    return normalized.replace(/_/g, "-");
}
/**
 * Derive the target skill name for one mapped skill-like artifact.
 *
 * Mirrors `_planned_skill_name`: a reusable `SKILL.md` keeps its parent folder
 * identity; otherwise the filename-based name is used.
 *
 * @param mappingRecord Skill-like mapping record.
 * @returns The normalized skill folder name.
 */
function plannedSkillName(mappingRecord) {
    const name = posixName(mappingRecord.sourcePath);
    const parentName = posixParentName(mappingRecord.sourcePath);
    if (mappingRecord.sourceKind === models_1.SourceKind.REUSABLE_SKILL &&
        name === "SKILL.md" &&
        parentName !== "") {
        return parentName.replace(/_/g, "-");
    }
    return normalizedName(mappingRecord.sourcePath);
}
/**
 * Derive the target hook name without carrying source script extensions.
 *
 * Mirrors `_planned_hook_name`.
 *
 * @param mappingRecord Hook mapping record.
 * @returns The normalized hook name.
 */
function plannedHookName(mappingRecord) {
    const sourceName = posixName(mappingRecord.sourcePath);
    if (sourceName.endsWith(".ps1") || sourceName.endsWith(".py")) {
        const normalized = sourceName.slice(0, sourceName.lastIndexOf("."));
        return normalized.replace(/_/g, "-");
    }
    return normalizedName(mappingRecord.sourcePath);
}
/**
 * Resolve the approved Codex-native target path for one mapping record.
 *
 * Mirrors `plan_target_paths`, preserving every target-role branch, the
 * `enable_repo_prompts` `.codex/prompts` branch, the `AGENTS.md` standing
 * target, the unsupported-launcher fallthrough, and the null target for
 * unmapped roles.
 *
 * @param mappingRecord Classified mapping record whose target path is unresolved.
 * @param options Run options (`enableRepoPrompts`).
 * @returns A copy of the input record with `targetPath` resolved when known.
 */
function planTargetPaths(mappingRecord, options) {
    const { enableRepoPrompts } = options;
    if (mappingRecord.targetRole === models_1.TargetRole.STANDING_GUIDANCE) {
        return { ...mappingRecord, targetPath: "AGENTS.md" };
    }
    if (mappingRecord.targetRole === models_1.TargetRole.SHARED_SKILL) {
        const skillName = plannedSkillName(mappingRecord);
        return {
            ...mappingRecord,
            targetPath: `.agents/skills/${skillName}/SKILL.md`,
        };
    }
    if (mappingRecord.targetRole === models_1.TargetRole.SUBAGENT) {
        const agentName = normalizedName(mappingRecord.sourcePath);
        return { ...mappingRecord, targetPath: `.codex/agents/${agentName}.toml` };
    }
    if (mappingRecord.targetRole === models_1.TargetRole.MCP_CONFIG) {
        return { ...mappingRecord, targetPath: ".codex/config.toml" };
    }
    if (mappingRecord.targetRole === models_1.TargetRole.HOOK) {
        const hookName = plannedHookName(mappingRecord);
        return { ...mappingRecord, targetPath: `.codex/hooks/${hookName}.ps1` };
    }
    if (mappingRecord.targetRole === models_1.TargetRole.APPROVAL_RULE) {
        const ruleName = normalizedName(mappingRecord.sourcePath);
        return { ...mappingRecord, targetPath: `.codex/rules/${ruleName}.rules` };
    }
    if (mappingRecord.targetRole === models_1.TargetRole.LAUNCHER) {
        if (enableRepoPrompts) {
            const promptName = normalizedName(mappingRecord.sourcePath);
            return {
                ...mappingRecord,
                targetPath: `.codex/prompts/${promptName}.md`,
            };
        }
        // Repo-convention prompts disabled: demote to unsupported.
        return {
            ...mappingRecord,
            conversionClass: models_1.ConversionClass.UNSUPPORTED,
            targetRole: models_1.TargetRole.UNSUPPORTED,
            targetPath: null,
            notes: [
                ...mappingRecord.notes,
                "Repository-convention prompt output is disabled for this run.",
            ],
            isRequired: false,
        };
    }
    return { ...mappingRecord, targetPath: null };
}
/**
 * Resolve a native target path for one section-level planned emission.
 *
 * Mirrors `plan_section_target_path`: reuses the file-level planner for a
 * synthetic decomposed record and returns the resolved target path.
 *
 * @param sourcePath Source-root-relative artifact path.
 * @param options Section ecosystem/kind/role plus `enableRepoPrompts`.
 * @returns The planned target path when the role has a destination, else null.
 */
function planSectionTargetPath(sourcePath, options) {
    return planTargetPaths({
        sourcePath,
        sourceEcosystem: options.sourceEcosystem,
        sourceKind: options.sourceKind,
        conversionClass: models_1.ConversionClass.DECOMPOSED,
        targetRole: options.targetRole,
        targetPath: null,
        notes: [],
        isRequired: true,
    }, { enableRepoPrompts: options.enableRepoPrompts }).targetPath;
}
