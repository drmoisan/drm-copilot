"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.runReviewMode = runReviewMode;
exports.runApplyMode = runApplyMode;
const section_intent_1 = require("./section-intent");
const engine_pipeline_1 = require("./engine-pipeline");
const intermediate_state_1 = require("./intermediate-state");
const parser_1 = require("./parser");
const pipeline_1 = require("./pipeline");
const reporting_1 = require("./reporting");
const validation_1 = require("./validation");
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
function runConversion(fileSystem, runOptions, options) {
    const mappingRecords = (0, engine_pipeline_1.planMappings)(fileSystem, runOptions);
    const translationTraces = (0, engine_pipeline_1.buildTranslationTraces)(fileSystem, runOptions, mappingRecords);
    const plannedEmissions = (0, engine_pipeline_1.buildPlannedEmissions)(translationTraces);
    // Classify section intents for all parsed source artifacts so the
    // intermediate state captures the full pipeline view, in discovery order.
    const sourceArtifacts = [];
    const sectionIntents = [];
    for (const mappingRecord of mappingRecords) {
        const sourceArtifact = (0, parser_1.parseSourceArtifact)(fileSystem, runOptions.sourceRoot, mappingRecord.sourcePath, mappingRecord.sourceEcosystem, mappingRecord.sourceKind);
        sourceArtifacts.push(sourceArtifact);
        // Accumulate one intent per section for the intermediate state.
        for (const sourceSection of sourceArtifact.sections) {
            sectionIntents.push((0, section_intent_1.classifySectionIntent)(sourceSection, sourceArtifact));
        }
    }
    // Persist intermediate state only when the caller opts in, leaving emitted
    // native outputs unchanged.
    if (runOptions.emitIntermediateState) {
        const intermediate = {
            sourceArtifacts,
            sectionIntents,
            plannedEmissions,
            translationTraces,
        };
        (0, intermediate_state_1.writeIntermediateStateArtifacts)(fileSystem, intermediate, runOptions.artifactRoot);
    }
    const generatedOutput = (0, engine_pipeline_1.renderGeneratedOutput)(fileSystem, runOptions, mappingRecords, plannedEmissions);
    const topologyEdges = (0, pipeline_1.buildTopologyEdges)(fileSystem, runOptions, mappingRecords, translationTraces);
    const validationFindings = (0, validation_1.validateConversionPlan)(runOptions, mappingRecords, plannedEmissions, generatedOutput);
    const reportPaths = (0, reporting_1.writeConversionReportSet)(fileSystem, runOptions, mappingRecords, topologyEdges, translationTraces, validationFindings, generatedOutput);
    const blockingFindings = validationFindings.some((finding) => finding.blocking);
    let wroteDestination = false;
    // Apply-mode writes occur only when allowed, unblocked, and a destination
    // root is set.
    if (options.allowDestinationWrite &&
        !blockingFindings &&
        runOptions.destinationRoot) {
        (0, engine_pipeline_1.writeDestinationOutputs)(fileSystem, runOptions.destinationRoot, generatedOutput);
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
function runReviewMode(fileSystem, runOptions) {
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
function runApplyMode(fileSystem, runOptions) {
    return runConversion(fileSystem, runOptions, {
        allowDestinationWrite: true,
    });
}
