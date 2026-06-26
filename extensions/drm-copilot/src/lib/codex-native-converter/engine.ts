/**
 * Run the end-to-end Codex-native conversion pipeline.
 *
 * Purpose:
 *     Port the run-orchestration half of `engine.py` (`_run_conversion`,
 *     `run_review_mode`, `run_apply_mode`, `ConversionRunResult`). The
 *     preparation helpers live in `engine-pipeline.ts`. All filesystem access
 *     flows through the injected {@link FileSystem}.
 *
 * Invariants:
 *     Review mode never mutates the destination workspace. Apply mode writes no
 *     destination files when blocking validation findings are present.
 */

import { type FileSystem } from "../file-system";
import { classifySectionIntent } from "./section-intent";
import {
  buildPlannedEmissions,
  buildTranslationTraces,
  planMappings,
  renderGeneratedOutput,
  writeDestinationOutputs,
} from "./engine-pipeline";
import {
  type IntermediateState,
  writeIntermediateStateArtifacts,
} from "./intermediate-state";
import {
  type MappingRecord,
  type SectionIntent,
  type SourceArtifact,
  type TranslationTrace,
  type ValidationFinding,
} from "./models";
import { parseSourceArtifact } from "./parser";
import { buildTopologyEdges } from "./pipeline";
import { type ReportSetPaths, writeConversionReportSet } from "./reporting";
import { type RunOptions } from "./models";
import { validateConversionPlan } from "./validation";

/**
 * The outcome of one review or apply run.
 *
 * Mirrors `ConversionRunResult`. Report paths always point to the written
 * artifact set for the run.
 */
export interface ConversionRunResult {
  readonly mappingRecords: ReadonlyArray<MappingRecord>;
  readonly validationFindings: ReadonlyArray<ValidationFinding>;
  readonly reportPaths: ReportSetPaths;
  readonly generatedOutput: Readonly<Record<string, string>>;
  readonly wroteDestination: boolean;
  readonly translationTraces: ReadonlyArray<TranslationTrace>;
}

/**
 * Run the shared conversion pipeline for review or apply mode.
 *
 * Mirrors `_run_conversion`: plans mappings, builds traces and emissions,
 * classifies section intents, optionally writes intermediate state, renders
 * generated output, validates, writes the report set, and (when allowed and
 * unblocked) writes destination files.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @param options Behavior flags (`allowDestinationWrite`).
 * @returns The auditable conversion outcome.
 * @throws Error When source files or report writes fail.
 */
function runConversion(
  fileSystem: FileSystem,
  runOptions: RunOptions,
  options: { readonly allowDestinationWrite: boolean },
): ConversionRunResult {
  const mappingRecords = planMappings(fileSystem, runOptions);
  const translationTraces = buildTranslationTraces(
    fileSystem,
    runOptions,
    mappingRecords,
  );
  const plannedEmissions = buildPlannedEmissions(translationTraces);

  // Classify section intents for all parsed source artifacts so the
  // intermediate state captures the full pipeline view, in discovery order.
  const sourceArtifacts: SourceArtifact[] = [];
  const sectionIntents: SectionIntent[] = [];
  for (const mappingRecord of mappingRecords) {
    const sourceArtifact = parseSourceArtifact(
      fileSystem,
      runOptions.sourceRoot,
      mappingRecord.sourcePath,
      mappingRecord.sourceEcosystem,
      mappingRecord.sourceKind,
    );
    sourceArtifacts.push(sourceArtifact);
    // Accumulate one intent per section for the intermediate state.
    for (const sourceSection of sourceArtifact.sections) {
      sectionIntents.push(classifySectionIntent(sourceSection, sourceArtifact));
    }
  }

  // Persist intermediate state only when the caller opts in, leaving emitted
  // native outputs unchanged.
  if (runOptions.emitIntermediateState) {
    const intermediate: IntermediateState = {
      sourceArtifacts,
      sectionIntents,
      plannedEmissions,
      translationTraces,
    };
    writeIntermediateStateArtifacts(
      fileSystem,
      intermediate,
      runOptions.artifactRoot,
    );
  }

  const generatedOutput = renderGeneratedOutput(
    fileSystem,
    runOptions,
    mappingRecords,
    plannedEmissions,
  );
  const topologyEdges = buildTopologyEdges(
    fileSystem,
    runOptions,
    mappingRecords,
    translationTraces,
  );
  const validationFindings = validateConversionPlan(
    runOptions,
    mappingRecords,
    plannedEmissions,
    generatedOutput,
  );
  const reportPaths = writeConversionReportSet(
    fileSystem,
    runOptions,
    mappingRecords,
    topologyEdges,
    translationTraces,
    validationFindings,
    generatedOutput,
  );

  const blockingFindings = validationFindings.some(
    (finding) => finding.blocking,
  );
  let wroteDestination = false;
  // Apply-mode writes occur only when allowed, unblocked, and a destination
  // root is set.
  if (
    options.allowDestinationWrite &&
    !blockingFindings &&
    runOptions.destinationRoot
  ) {
    writeDestinationOutputs(
      fileSystem,
      runOptions.destinationRoot,
      generatedOutput,
    );
    wroteDestination = true;
  }

  return {
    mappingRecords,
    translationTraces,
    validationFindings,
    reportPaths,
    generatedOutput,
    wroteDestination,
  };
}

/**
 * Run the converter in review mode.
 *
 * Mirrors `run_review_mode`: executes the full pipeline without mutating a
 * destination root.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested review-mode options.
 * @returns Review-mode result including report paths and validation findings.
 * @throws Error When source files or report writes fail.
 */
export function runReviewMode(
  fileSystem: FileSystem,
  runOptions: RunOptions,
): ConversionRunResult {
  return runConversion(fileSystem, runOptions, {
    allowDestinationWrite: false,
  });
}

/**
 * Run the converter in apply mode.
 *
 * Mirrors `run_apply_mode`: executes the full pipeline and writes destination
 * files only when validation leaves no blocking findings.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested apply-mode options.
 * @returns Apply-mode result including whether destination files were written.
 * @throws Error When source files or report writes fail.
 */
export function runApplyMode(
  fileSystem: FileSystem,
  runOptions: RunOptions,
): ConversionRunResult {
  return runConversion(fileSystem, runOptions, {
    allowDestinationWrite: true,
  });
}
