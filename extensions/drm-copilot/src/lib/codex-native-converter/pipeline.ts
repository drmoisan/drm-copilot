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

import { type FileSystem } from "../file-system";
import {
  type MappingRecord,
  type RunOptions,
  TargetRole,
  type TopologyEdge,
  type TranslationTrace,
} from "./models";
import { renderTargetContent } from "./pipeline-render";

export {
  renderMergedStandingGuidance,
  renderSectionEmissionContent,
  renderTargetContent,
} from "./pipeline-render";

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
function extractTopologyDestinations(
  renderedText: string,
  knownDestinationPaths: ReadonlyArray<string>,
): string[] {
  const destinationsByPosition: Array<[number, string]> = [];
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
export function buildTopologyEdges(
  fileSystem: FileSystem,
  runOptions: RunOptions,
  mappingRecords: ReadonlyArray<MappingRecord>,
  translationTraces: ReadonlyArray<TranslationTrace>,
): ReadonlyArray<TopologyEdge> {
  const standingGuidanceSourcePaths = mappingRecords
    .filter(
      (record) =>
        record.targetRole === TargetRole.STANDING_GUIDANCE &&
        record.targetPath === "AGENTS.md",
    )
    .map((record) => record.sourcePath);
  const knownDestinationPaths = [
    ...new Set(
      mappingRecords
        .filter((record) => record.targetPath !== null)
        .map((record) => record.targetPath as string),
    ),
  ].sort((left, right) => (left < right ? -1 : left > right ? 1 : 0));
  const topologyEdges: TopologyEdge[] = [];
  const translationTraceSourcePaths = new Set(
    translationTraces.map((trace) => trace.sourcePath),
  );

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
      renderedText = renderTargetContent(
        fileSystem,
        runOptions,
        mappingRecord,
        standingGuidanceSourcePaths,
      );
    }

    const destinationPaths: string[] = [];
    if (mappingRecord.targetPath !== null) {
      destinationPaths.push(mappingRecord.targetPath);
      for (const destinationPath of extractTopologyDestinations(
        renderedText,
        knownDestinationPaths,
      )) {
        if (!destinationPaths.includes(destinationPath)) {
          destinationPaths.push(destinationPath);
        }
      }
    } else {
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
