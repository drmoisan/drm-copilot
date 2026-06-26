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

import { type FileSystem } from "../file-system";
import { classifyPromptSections } from "./classifier";
import { planSectionTargetPath } from "./mapping";
import {
  type MappingRecord,
  type RunOptions,
  SectionIntentKind,
  SourceKind,
  TargetRole,
  type TranslationTrace,
} from "./models";
import { parseSourceArtifact } from "./parser";

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
export function buildPromptTranslationTraces(
  fileSystem: FileSystem,
  runOptions: RunOptions,
  mappingRecord: MappingRecord,
): ReadonlyArray<TranslationTrace> {
  if (mappingRecord.sourceKind !== SourceKind.LAUNCHER_PROMPT) {
    return [];
  }

  const sourceArtifact = parseSourceArtifact(
    fileSystem,
    runOptions.sourceRoot,
    mappingRecord.sourcePath,
    mappingRecord.sourceEcosystem,
    mappingRecord.sourceKind,
  );
  const translationTraces: TranslationTrace[] = [];
  const launcherTargetPath = planSectionTargetPath(mappingRecord.sourcePath, {
    sourceEcosystem: mappingRecord.sourceEcosystem,
    sourceKind: mappingRecord.sourceKind,
    targetRole: TargetRole.LAUNCHER,
    enableRepoPrompts: runOptions.enableRepoPrompts,
  });
  const launcherNotes: string[] = [
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
    intentKind: SectionIntentKind.LAUNCHER_ONLY,
    targetRole: TargetRole.LAUNCHER,
    targetPath: launcherTargetPath,
    notes: launcherNotes,
  });

  // Each classified workflow/hook section contributes a trace; other intents
  // are skipped (target role stays unsupported).
  for (const sectionIntent of classifyPromptSections(sourceArtifact)) {
    let targetRole: TargetRole = TargetRole.UNSUPPORTED;
    if (sectionIntent.intentKind === SectionIntentKind.SHARED_WORKFLOW) {
      targetRole = TargetRole.SHARED_SKILL;
    } else if (sectionIntent.intentKind === SectionIntentKind.HOOK_CANDIDATE) {
      targetRole = TargetRole.HOOK;
    }

    if (targetRole === TargetRole.UNSUPPORTED) {
      continue;
    }

    translationTraces.push({
      sourcePath: sectionIntent.sourcePath,
      sectionId: sectionIntent.sectionId,
      heading: sectionIntent.heading,
      intentKind: sectionIntent.intentKind,
      targetRole,
      targetPath: planSectionTargetPath(mappingRecord.sourcePath, {
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
