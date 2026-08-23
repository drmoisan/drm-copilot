"use strict";
/**
 * Pipeline topology stage for the Codex-native converter.
 *
 * Purpose:
 *     Hold the topology-edge construction half of the pipeline (ported from
 *     `pipeline.py`) and re-export the content-rendering functions from
 *     `pipeline-render.ts` so consumers import one pipeline surface while
 *     neither file exceeds the 500-line policy.
 *
 * Invariants:
 *     Topology output is deterministic. This module does not import from
 *     `engine.ts` to avoid circular dependencies.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.renderTargetContent = exports.renderSectionEmissionContent = exports.renderMergedStandingGuidance = void 0;
exports.buildTopologyEdges = buildTopologyEdges;
const models_1 = require("./models");
const pipeline_render_1 = require("./pipeline-render");
var pipeline_render_2 = require("./pipeline-render");
Object.defineProperty(exports, "renderMergedStandingGuidance", { enumerable: true, get: function () { return pipeline_render_2.renderMergedStandingGuidance; } });
Object.defineProperty(exports, "renderSectionEmissionContent", { enumerable: true, get: function () { return pipeline_render_2.renderSectionEmissionContent; } });
Object.defineProperty(exports, "renderTargetContent", { enumerable: true, get: function () { return pipeline_render_2.renderTargetContent; } });
/**
 * Extract referenced native destinations from rendered output text.
 *
 * Mirrors `_extract_topology_destinations`: orders matches by first-occurrence
 * position, then path text.
 *
 * @param renderedText Rendered native output.
 * @param knownDestinationPaths Known native target paths.
 * @returns Referenced destination paths in deterministic order.
 */
function extractTopologyDestinations(renderedText, knownDestinationPaths) {
    const destinationsByPosition = [];
    // Record the first occurrence position of each known destination path.
    for (const destinationPath of knownDestinationPaths) {
        const position = renderedText.indexOf(destinationPath);
        if (position >= 0) {
            destinationsByPosition.push([position, destinationPath]);
        }
    }
    destinationsByPosition.sort((left, right) => {
        if (left[0] !== right[0]) {
            return left[0] - right[0];
        }
        return left[1] < right[1] ? -1 : left[1] > right[1] ? 1 : 0;
    });
    return destinationsByPosition.map(([, destinationPath]) => destinationPath);
}
/**
 * Build report topology edges from per-source rendered native intent.
 *
 * Mirrors `build_topology_edges`.
 *
 * @param fileSystem Injected filesystem.
 * @param runOptions Requested run options.
 * @param mappingRecords Planned mappings.
 * @param translationTraces Prompt translation traces.
 * @returns Deterministic topology edges for reporting.
 * @throws Error When a required source file cannot be read.
 */
function buildTopologyEdges(fileSystem, runOptions, mappingRecords, translationTraces) {
    const standingGuidanceSourcePaths = mappingRecords
        .filter((record) => record.targetRole === models_1.TargetRole.STANDING_GUIDANCE &&
        record.targetPath === "AGENTS.md")
        .map((record) => record.sourcePath);
    const knownDestinationPaths = [
        ...new Set(mappingRecords
            .filter((record) => record.targetPath !== null)
            .map((record) => record.targetPath)),
    ].sort((left, right) => (left < right ? -1 : left > right ? 1 : 0));
    const topologyEdges = [];
    const translationTraceSourcePaths = new Set(translationTraces.map((trace) => trace.sourcePath));
    // Each translation trace contributes one edge.
    for (const translationTrace of translationTraces) {
        topologyEdges.push({
            sourcePath: translationTrace.sourcePath,
            destinationPath: translationTrace.targetPath ?? "[no target]",
        });
    }
    // Each mapping record without a trace contributes its primary destination
    // plus any additional destinations referenced in its rendered content.
    for (const mappingRecord of mappingRecords) {
        if (translationTraceSourcePaths.has(mappingRecord.sourcePath)) {
            continue;
        }
        let renderedText = "";
        if (mappingRecord.targetPath !== null) {
            renderedText = (0, pipeline_render_1.renderTargetContent)(fileSystem, runOptions, mappingRecord, standingGuidanceSourcePaths);
        }
        const destinationPaths = [];
        if (mappingRecord.targetPath !== null) {
            destinationPaths.push(mappingRecord.targetPath);
            for (const destinationPath of extractTopologyDestinations(renderedText, knownDestinationPaths)) {
                if (!destinationPaths.includes(destinationPath)) {
                    destinationPaths.push(destinationPath);
                }
            }
        }
        else {
            destinationPaths.push("[no target]");
        }
        for (const destinationPath of destinationPaths) {
            topologyEdges.push({
                sourcePath: mappingRecord.sourcePath,
                destinationPath,
            });
        }
    }
    return [...topologyEdges].sort((left, right) => {
        if (left.sourcePath !== right.sourcePath) {
            return left.sourcePath < right.sourcePath ? -1 : 1;
        }
        if (left.destinationPath !== right.destinationPath) {
            return left.destinationPath < right.destinationPath ? -1 : 1;
        }
        return 0;
    });
}
