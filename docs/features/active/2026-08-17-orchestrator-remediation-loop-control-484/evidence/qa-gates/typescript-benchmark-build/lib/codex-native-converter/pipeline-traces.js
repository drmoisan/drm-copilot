"use strict";
/**
 * Section-level translation-trace builder for prompt source artifacts.
 *
 * Purpose:
 *     Port `build_prompt_translation_traces` from `_pipeline_traces.py`. Source
 *     parsing flows through the injected {@link FileSystem}.
 *
 * Invariants:
 *     Trace ordering and content are preserved verbatim. This module does not
 *     import from `engine.ts` to avoid circular dependencies.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.buildPromptTranslationTraces = buildPromptTranslationTraces;
const classifier_1 = require("./classifier");
const mapping_1 = require("./mapping");
const models_1 = require("./models");
const parser_1 = require("./parser");
/**
 * Build section-level translation traces for one GitHub prompt artifact.
 *
 * Mirrors `build_prompt_translation_traces`: emits a launcher trace plus
 * workflow/hook traces for classified prompt sections, then sorts by
 * (sourcePath, sectionId, targetRole).
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @param mappingRecord File-level mapping record for one prompt.
 * @returns Section-level traces in deterministic order, or an empty array when
 *   the record is not a launcher prompt.
 * @throws Error When the source file cannot be read.
 */
function buildPromptTranslationTraces(fileSystem, runOptions, mappingRecord) {
    if (mappingRecord.sourceKind !== models_1.SourceKind.LAUNCHER_PROMPT) {
        return [];
    }
    const sourceArtifact = (0, parser_1.parseSourceArtifact)(fileSystem, runOptions.sourceRoot, mappingRecord.sourcePath, mappingRecord.sourceEcosystem, mappingRecord.sourceKind);
    const translationTraces = [];
    const launcherTargetPath = (0, mapping_1.planSectionTargetPath)(mappingRecord.sourcePath, {
        sourceEcosystem: mappingRecord.sourceEcosystem,
        sourceKind: mappingRecord.sourceKind,
        targetRole: models_1.TargetRole.LAUNCHER,
        enableRepoPrompts: runOptions.enableRepoPrompts,
    });
    const launcherNotes = [
        "Prompt launcher wrapper maps only to the repository-convention " +
            "launcher surface.",
        ...(launcherTargetPath === null
            ? ["Repository-convention prompt output is disabled for this run."]
            : []),
    ];
    translationTraces.push({
        sourcePath: mappingRecord.sourcePath,
        sectionId: `${mappingRecord.sourcePath}#__launcher__`,
        heading: "Launcher Surface",
        intentKind: models_1.SectionIntentKind.LAUNCHER_ONLY,
        targetRole: models_1.TargetRole.LAUNCHER,
        targetPath: launcherTargetPath,
        notes: launcherNotes,
    });
    // Each classified workflow/hook section contributes a trace; other intents
    // are skipped (target role stays unsupported).
    for (const sectionIntent of (0, classifier_1.classifyPromptSections)(sourceArtifact)) {
        let targetRole = models_1.TargetRole.UNSUPPORTED;
        if (sectionIntent.intentKind === models_1.SectionIntentKind.SHARED_WORKFLOW) {
            targetRole = models_1.TargetRole.SHARED_SKILL;
        }
        else if (sectionIntent.intentKind === models_1.SectionIntentKind.HOOK_CANDIDATE) {
            targetRole = models_1.TargetRole.HOOK;
        }
        if (targetRole === models_1.TargetRole.UNSUPPORTED) {
            continue;
        }
        translationTraces.push({
            sourcePath: sectionIntent.sourcePath,
            sectionId: sectionIntent.sectionId,
            heading: sectionIntent.heading,
            intentKind: sectionIntent.intentKind,
            targetRole,
            targetPath: (0, mapping_1.planSectionTargetPath)(mappingRecord.sourcePath, {
                sourceEcosystem: mappingRecord.sourceEcosystem,
                sourceKind: mappingRecord.sourceKind,
                targetRole,
                enableRepoPrompts: runOptions.enableRepoPrompts,
            }),
            notes: [...sectionIntent.notes],
        });
    }
    return [...translationTraces].sort((left, right) => {
        if (left.sourcePath !== right.sourcePath) {
            return left.sourcePath < right.sourcePath ? -1 : 1;
        }
        if (left.sectionId !== right.sectionId) {
            return left.sectionId < right.sectionId ? -1 : 1;
        }
        if (left.targetRole !== right.targetRole) {
            return left.targetRole < right.targetRole ? -1 : 1;
        }
        return 0;
    });
}
