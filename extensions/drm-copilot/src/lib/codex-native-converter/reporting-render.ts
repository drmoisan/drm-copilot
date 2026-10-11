/**
 * Render the human-readable Markdown conversion report.
 *
 * Purpose:
 *     Port `_render_conversion_report` from `reporting.py`. Extracted into a
 *     dedicated module so neither `reporting.ts` nor this renderer exceeds the
 *     500-line file-size policy. Pure logic; no filesystem I/O.
 *
 * Invariants:
 *     Section ordering, table headers, Mermaid chart sequence, and every text
 *     fragment are preserved verbatim from the Python source. Mappings, topology
 *     edges, and section traces are rendered in deterministic sorted order.
 */

import { toPosixPath } from "../file-system";
import { compareCodePoint } from "../string-ordering";
import {
  type MappingRecord,
  type RunOptions,
  type TopologyEdge,
  type TranslationTrace,
  type ValidationFinding,
} from "./models";
import {
  renderDestinationToRepeatedSourceChart,
  renderSourceToDestinationChart,
  renderSourceToRepeatedDestinationChart,
} from "./reporting-topology";

/**
 * Render the human-readable Markdown conversion report.
 *
 * Mirrors `_render_conversion_report`: emits the run summary header, the three
 * Mermaid topology charts (shared, repeated-destination, repeated-source), the
 * mapping table, the section-mapping table, and the validation findings list.
 *
 * @param runOptions Requested run options.
 * @param mappingRecords Planned mappings.
 * @param topologyEdges Derived topology edges for Mermaid rendering.
 * @param translationTraces Section-level translation traces.
 * @param validationFindings Validation results.
 * @returns Markdown report text terminated with a trailing newline.
 */
export function renderConversionReport(
  runOptions: RunOptions,
  mappingRecords: ReadonlyArray<MappingRecord>,
  topologyEdges: ReadonlyArray<TopologyEdge>,
  translationTraces: ReadonlyArray<TranslationTrace>,
  validationFindings: ReadonlyArray<ValidationFinding>,
): string {
  // Count blocking findings for the summary header line.
  const blockingCount = validationFindings.filter(
    (finding) => finding.blocking,
  ).length;
  const destinationRootText =
    runOptions.destinationRoot !== null
      ? toPosixPath(runOptions.destinationRoot)
      : "review-only";

  const sortedMappingRecords = [...mappingRecords].sort((left, right) =>
    compareCodePoint(left.sourcePath, right.sourcePath),
  );
  const sortedTopologyEdges = [...topologyEdges].sort((left, right) => {
    const bySource = compareCodePoint(left.sourcePath, right.sourcePath);
    if (bySource !== 0) {
      return bySource;
    }
    return compareCodePoint(left.destinationPath, right.destinationPath);
  });
  const sortedTranslationTraces = [...translationTraces].sort((left, right) => {
    const bySource = compareCodePoint(left.sourcePath, right.sourcePath);
    if (bySource !== 0) {
      return bySource;
    }
    const bySection = compareCodePoint(left.sectionId, right.sectionId);
    if (bySection !== 0) {
      return bySection;
    }
    const byRole = compareCodePoint(left.targetRole, right.targetRole);
    if (byRole !== 0) {
      return byRole;
    }
    return compareCodePoint(left.targetPath ?? "", right.targetPath ?? "");
  });

  const lines: string[] = [
    "# Conversion Report",
    "",
    `- Mode: \`${runOptions.mode}\``,
    `- Source ecosystem: \`${runOptions.sourceEcosystem}\``,
    `- Source root: \`${toPosixPath(runOptions.sourceRoot)}\``,
    `- Destination root: \`${destinationRootText}\``,
    `- Artifact root: \`${toPosixPath(runOptions.artifactRoot)}\``,
    `- Mapping records: ${String(mappingRecords.length)}`,
    `- Validation findings: ${String(validationFindings.length)} ` +
      `(${String(blockingCount)} blocking)`,
    "",
    "## Mapping Topology",
    "",
    "### Shared Destination Nodes",
    "",
    "Source and destination nodes are both deduplicated in this view.",
    "",
  ];
  lines.push(...renderSourceToDestinationChart(sortedTopologyEdges));
  lines.push(
    "",
    "### Repeated Destination Nodes",
    "",
    "Destination nodes may repeat in this source-to-destination " +
      "view so fan-in stays legible.",
  );
  lines.push(...renderSourceToRepeatedDestinationChart(sortedTopologyEdges));
  lines.push(
    "",
    "### Repeated Source Nodes",
    "",
    "Source nodes may repeat in this destination-to-source view so " +
      "fan-out stays legible.",
  );
  lines.push(...renderDestinationToRepeatedSourceChart(sortedTopologyEdges));
  lines.push(
    "",
    "## Mappings",
    "",
    "| Source path | Conversion class | Target role | Target path | Notes |",
    "| --- | --- | --- | --- | --- |",
  );

  // Render mappings in stable source-path order so review diffs stay small and
  // predictable.
  for (const mappingRecord of sortedMappingRecords) {
    const notes =
      mappingRecord.notes.length > 0 ? mappingRecord.notes.join("<br>") : "";
    lines.push(
      "| " +
        `\`${mappingRecord.sourcePath}\` | ` +
        `\`${mappingRecord.conversionClass}\` | ` +
        `\`${mappingRecord.targetRole}\` | ` +
        `\`${mappingRecord.targetPath ?? ""}\` | ${notes} |`,
    );
  }

  lines.push("", "## Section Mappings", "");
  if (sortedTranslationTraces.length === 0) {
    lines.push("- None");
  } else {
    lines.push(
      "| Source path | Section | Intent | Target role | " +
        "Target path | Notes |",
      "| --- | --- | --- | --- | --- | --- |",
    );
    // Each section trace renders one table row.
    for (const translationTrace of sortedTranslationTraces) {
      const notes =
        translationTrace.notes.length > 0
          ? translationTrace.notes.join("<br>")
          : "";
      lines.push(
        "| " +
          `\`${translationTrace.sourcePath}\` | ` +
          `\`${translationTrace.heading}\` | ` +
          `\`${translationTrace.intentKind}\` | ` +
          `\`${translationTrace.targetRole}\` | ` +
          `\`${translationTrace.targetPath ?? ""}\` | ` +
          `${notes} |`,
      );
    }
  }

  lines.push("", "## Validation Findings", "");
  if (validationFindings.length === 0) {
    lines.push("- None");
  } else {
    // Render validation findings in a stable order so the Markdown summary
    // mirrors JSON output.
    const sortedFindings = [...validationFindings].sort((left, right) => {
      const byCode = compareCodePoint(left.code, right.code);
      if (byCode !== 0) {
        return byCode;
      }
      const bySource = compareCodePoint(
        left.sourcePath ?? "",
        right.sourcePath ?? "",
      );
      if (bySource !== 0) {
        return bySource;
      }
      return compareCodePoint(left.targetPath ?? "", right.targetPath ?? "");
    });
    for (const validationFinding of sortedFindings) {
      lines.push(
        `- \`${validationFinding.code}\`: ${validationFinding.message}`,
      );
    }
  }

  return lines.join("\n") + "\n";
}
