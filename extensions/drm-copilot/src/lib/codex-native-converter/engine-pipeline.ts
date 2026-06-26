/**
 * Pipeline-preparation half of the Codex-native conversion engine.
 *
 * Purpose:
 *     Port the preparation helpers from `engine.py` (`_plan_mappings`,
 *     `_render_generated_output`, `_build_translation_traces`,
 *     `_build_planned_emissions`, `_write_destination_outputs`). The
 *     run-orchestration half lives in `engine.ts` so neither file exceeds the
 *     500-line policy. Source reads and destination writes flow through the
 *     injected {@link FileSystem}.
 *
 * Invariants:
 *     Discovery, classification, mapping, rendering, trace, and emission
 *     ordering are preserved verbatim from the Python source so report and
 *     proposed-tree output stay deterministic.
 */

import { type FileSystem } from "../file-system";
import { classifySourceArtifact } from "./classifier";
import { discoverSourceArtifacts } from "./inventory";
import { planTargetPaths } from "./mapping";
import {
  type MappingRecord,
  type PlannedEmission,
  type RunOptions,
  SourceKind,
  type SourceSection,
  TargetRole,
  type TranslationTrace,
} from "./models";
import { parseSourceArtifact } from "./parser";
import {
  renderMergedStandingGuidance,
  renderSectionEmissionContent,
  renderTargetContent,
} from "./pipeline-render";
import { buildPromptTranslationTraces } from "./pipeline-traces";

/**
 * Compare two strings with stable ascending ordering.
 *
 * @param left Left operand.
 * @param right Right operand.
 * @returns Negative, zero, or positive ordering value.
 */
function compareStrings(left: string, right: string): number {
  return left < right ? -1 : left > right ? 1 : 0;
}

/**
 * Plan mappings for one converter run.
 *
 * Mirrors `_plan_mappings`: discovers artifacts, classifies and maps each in
 * source-path order, then returns the mappings sorted by source path.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @returns Planned mappings sorted by source path.
 * @throws Error When selected paths escape the source root.
 */
export function planMappings(
  fileSystem: FileSystem,
  runOptions: RunOptions,
): ReadonlyArray<MappingRecord> {
  const discoveredPaths = discoverSourceArtifacts(
    fileSystem,
    runOptions.sourceRoot,
    runOptions.sourceEcosystem,
    runOptions.selectedPaths,
  );
  const mappingRecords: MappingRecord[] = [];

  // Classify and map each discovered artifact so reporting stays deterministic.
  for (const sourcePath of discoveredPaths) {
    const classifiedRecord = classifySourceArtifact(
      fileSystem,
      runOptions.sourceRoot,
      sourcePath,
      runOptions.sourceEcosystem,
    );
    const mappedRecord = planTargetPaths(classifiedRecord, {
      enableRepoPrompts: runOptions.enableRepoPrompts,
    });
    mappingRecords.push(mappedRecord);
  }

  return [...mappingRecords].sort((left, right) =>
    compareStrings(left.sourcePath, right.sourcePath),
  );
}

/**
 * Render the generated output set for one run.
 *
 * Mirrors `_render_generated_output`: renders concrete targets in sorted path
 * order, merges multiple standing-guidance records into `AGENTS.md`, parses
 * launcher prompts for section lookups, and renders section emissions for
 * targets not already produced.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @param mappingRecords Planned mappings.
 * @param plannedEmissions Section-level planned emissions.
 * @returns Generated output keyed by target path.
 * @throws Error When a required source file cannot be read.
 */
export function renderGeneratedOutput(
  fileSystem: FileSystem,
  runOptions: RunOptions,
  mappingRecords: ReadonlyArray<MappingRecord>,
  plannedEmissions: ReadonlyArray<PlannedEmission>,
): Record<string, string> {
  const generatedOutput: Record<string, string> = {};
  const standingGuidanceSourcePaths = mappingRecords
    .filter(
      (record) =>
        record.targetRole === TargetRole.STANDING_GUIDANCE &&
        record.targetPath === "AGENTS.md",
    )
    .map((record) => record.sourcePath);

  const mappingRecordsByTarget = new Map<string, MappingRecord[]>();
  const sectionEmissionsByTarget = new Map<string, PlannedEmission[]>();

  // Group records with concrete target paths; unsupported items surface only
  // through validation findings and report rows.
  for (const mappingRecord of mappingRecords) {
    if (mappingRecord.targetPath === null) {
      continue;
    }
    const bucket = mappingRecordsByTarget.get(mappingRecord.targetPath) ?? [];
    bucket.push(mappingRecord);
    mappingRecordsByTarget.set(mappingRecord.targetPath, bucket);
  }
  for (const plannedEmission of plannedEmissions) {
    if (plannedEmission.targetPath === null) {
      continue;
    }
    const bucket =
      sectionEmissionsByTarget.get(plannedEmission.targetPath) ?? [];
    bucket.push(plannedEmission);
    sectionEmissionsByTarget.set(plannedEmission.targetPath, bucket);
  }

  // Render each target's content; AGENTS.md merges when several
  // standing-guidance records resolve to it.
  for (const targetPath of [...mappingRecordsByTarget.keys()].sort(
    compareStrings,
  )) {
    const recordsForTarget = mappingRecordsByTarget.get(targetPath) ?? [];
    if (recordsForTarget.length === 0) {
      continue;
    }
    if (
      targetPath === "AGENTS.md" &&
      recordsForTarget.every(
        (record) => record.targetRole === TargetRole.STANDING_GUIDANCE,
      ) &&
      recordsForTarget.length > 1
    ) {
      generatedOutput[targetPath] = renderMergedStandingGuidance(
        fileSystem,
        runOptions,
        recordsForTarget,
      );
      continue;
    }
    generatedOutput[targetPath] = renderTargetContent(
      fileSystem,
      runOptions,
      recordsForTarget[recordsForTarget.length - 1] as MappingRecord,
      standingGuidanceSourcePaths,
    );
  }

  const sectionLookupById = new Map<string, SourceSection>();
  const parsedSourcePaths = [
    ...new Set(
      plannedEmissions
        .filter((emission) => emission.targetPath !== null)
        .map((emission) => emission.sourcePath),
    ),
  ].sort(compareStrings);
  // Parse each source whose sections feed a planned emission so the section
  // renderer can resolve section bodies by id.
  for (const sourcePath of parsedSourcePaths) {
    const sourceArtifact = parseSourceArtifact(
      fileSystem,
      runOptions.sourceRoot,
      sourcePath,
      runOptions.sourceEcosystem,
      SourceKind.LAUNCHER_PROMPT,
    );
    for (const sourceSection of sourceArtifact.sections) {
      sectionLookupById.set(sourceSection.sectionId, sourceSection);
    }
  }

  // Render section emissions for any target not already produced above.
  for (const targetPath of [...sectionEmissionsByTarget.keys()].sort(
    compareStrings,
  )) {
    if (targetPath in generatedOutput) {
      continue;
    }
    generatedOutput[targetPath] = renderSectionEmissionContent(
      runOptions,
      targetPath,
      sectionEmissionsByTarget.get(targetPath) ?? [],
      sectionLookupById,
      standingGuidanceSourcePaths,
    );
  }

  return generatedOutput;
}

/**
 * Build section-aware translation traces for mixed prompt artifacts.
 *
 * Mirrors `_build_translation_traces`: accumulates per-record prompt traces and
 * sorts by (sourcePath, sectionId, targetRole).
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @param mappingRecords Planned mappings.
 * @returns Translation traces in deterministic order.
 * @throws Error When a required source file cannot be read.
 */
export function buildTranslationTraces(
  fileSystem: FileSystem,
  runOptions: RunOptions,
  mappingRecords: ReadonlyArray<MappingRecord>,
): ReadonlyArray<TranslationTrace> {
  const translationTraces: TranslationTrace[] = [];
  for (const mappingRecord of mappingRecords) {
    translationTraces.push(
      ...buildPromptTranslationTraces(fileSystem, runOptions, mappingRecord),
    );
  }

  return [...translationTraces].sort((left, right) => {
    const bySource = compareStrings(left.sourcePath, right.sourcePath);
    if (bySource !== 0) {
      return bySource;
    }
    const bySection = compareStrings(left.sectionId, right.sectionId);
    if (bySection !== 0) {
      return bySection;
    }
    return compareStrings(left.targetRole, right.targetRole);
  });
}

/**
 * Build section-level planned emissions from translation traces.
 *
 * Mirrors `_build_planned_emissions`: keeps only traces with a non-null target
 * whose target role is `SHARED_SKILL` or `HOOK`.
 *
 * @param translationTraces Source translation traces.
 * @returns Planned emissions in trace order.
 */
export function buildPlannedEmissions(
  translationTraces: ReadonlyArray<TranslationTrace>,
): ReadonlyArray<PlannedEmission> {
  // Only shared-skill and hook traces with a concrete target become emissions.
  return translationTraces
    .filter(
      (trace) =>
        trace.targetPath !== null &&
        (trace.targetRole === TargetRole.SHARED_SKILL ||
          trace.targetRole === TargetRole.HOOK),
    )
    .map((trace) => ({
      sourcePath: trace.sourcePath,
      sectionId: trace.sectionId,
      heading: trace.heading,
      intentKind: trace.intentKind,
      targetRole: trace.targetRole,
      targetPath: trace.targetPath,
      notes: trace.notes,
    }));
}

/**
 * Write generated output files into the destination root.
 *
 * Mirrors `_write_destination_outputs`: writes each generated file in sorted
 * target-path order beneath the destination root.
 *
 * @param fileSystem Injected filesystem.
 * @param destinationRoot Destination root for apply mode.
 * @param generatedOutput Generated target files keyed by relative target path.
 * @throws Error When a destination file cannot be written.
 */
export function writeDestinationOutputs(
  fileSystem: FileSystem,
  destinationRoot: string,
  generatedOutput: Readonly<Record<string, string>>,
): void {
  const normalizedRoot = destinationRoot.replace(/\/+$/, "");
  // Write each generated file in stable path order beneath the destination.
  for (const targetPath of Object.keys(generatedOutput).sort(compareStrings)) {
    const fullPath =
      normalizedRoot === "" ? targetPath : `${normalizedRoot}/${targetPath}`;
    fileSystem.writeTextFile(fullPath, generatedOutput[targetPath] ?? "");
  }
}
