"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.renderConversionReport = renderConversionReport;
const file_system_1 = require("../file-system");
const reporting_topology_1 = require("./reporting-topology");
/**
 * Compare two strings with stable ascending ordering.
 *
 * @param left Left operand.
 * @param right Right operand.
 * @returns Negative, zero, or positive ordering value.
 */
function compareStrings(left, right) {
    return left < right ? -1 : left > right ? 1 : 0;
}
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
function renderConversionReport(runOptions, mappingRecords, topologyEdges, translationTraces, validationFindings) {
    // Count blocking findings for the summary header line.
    const blockingCount = validationFindings.filter((finding) => finding.blocking).length;
    const destinationRootText = runOptions.destinationRoot !== null
        ? (0, file_system_1.toPosixPath)(runOptions.destinationRoot)
        : "review-only";
    const sortedMappingRecords = [...mappingRecords].sort((left, right) => compareStrings(left.sourcePath, right.sourcePath));
    const sortedTopologyEdges = [...topologyEdges].sort((left, right) => {
        const bySource = compareStrings(left.sourcePath, right.sourcePath);
        if (bySource !== 0) {
            return bySource;
        }
        return compareStrings(left.destinationPath, right.destinationPath);
    });
    const sortedTranslationTraces = [...translationTraces].sort((left, right) => {
        const bySource = compareStrings(left.sourcePath, right.sourcePath);
        if (bySource !== 0) {
            return bySource;
        }
        const bySection = compareStrings(left.sectionId, right.sectionId);
        if (bySection !== 0) {
            return bySection;
        }
        const byRole = compareStrings(left.targetRole, right.targetRole);
        if (byRole !== 0) {
            return byRole;
        }
        return compareStrings(left.targetPath ?? "", right.targetPath ?? "");
    });
    const lines = [
        "# Conversion Report",
        "",
        `- Mode: \`${runOptions.mode}\``,
        `- Source ecosystem: \`${runOptions.sourceEcosystem}\``,
        `- Source root: \`${(0, file_system_1.toPosixPath)(runOptions.sourceRoot)}\``,
        `- Destination root: \`${destinationRootText}\``,
        `- Artifact root: \`${(0, file_system_1.toPosixPath)(runOptions.artifactRoot)}\``,
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
    lines.push(...(0, reporting_topology_1.renderSourceToDestinationChart)(sortedTopologyEdges));
    lines.push("", "### Repeated Destination Nodes", "", "Destination nodes may repeat in this source-to-destination " +
        "view so fan-in stays legible.");
    lines.push(...(0, reporting_topology_1.renderSourceToRepeatedDestinationChart)(sortedTopologyEdges));
    lines.push("", "### Repeated Source Nodes", "", "Source nodes may repeat in this destination-to-source view so " +
        "fan-out stays legible.");
    lines.push(...(0, reporting_topology_1.renderDestinationToRepeatedSourceChart)(sortedTopologyEdges));
    lines.push("", "## Mappings", "", "| Source path | Conversion class | Target role | Target path | Notes |", "| --- | --- | --- | --- | --- |");
    // Render mappings in stable source-path order so review diffs stay small and
    // predictable.
    for (const mappingRecord of sortedMappingRecords) {
        const notes = mappingRecord.notes.length > 0 ? mappingRecord.notes.join("<br>") : "";
        lines.push("| " +
            `\`${mappingRecord.sourcePath}\` | ` +
            `\`${mappingRecord.conversionClass}\` | ` +
            `\`${mappingRecord.targetRole}\` | ` +
            `\`${mappingRecord.targetPath ?? ""}\` | ${notes} |`);
    }
    lines.push("", "## Section Mappings", "");
    if (sortedTranslationTraces.length === 0) {
        lines.push("- None");
    }
    else {
        lines.push("| Source path | Section | Intent | Target role | " +
            "Target path | Notes |", "| --- | --- | --- | --- | --- | --- |");
        // Each section trace renders one table row.
        for (const translationTrace of sortedTranslationTraces) {
            const notes = translationTrace.notes.length > 0
                ? translationTrace.notes.join("<br>")
                : "";
            lines.push("| " +
                `\`${translationTrace.sourcePath}\` | ` +
                `\`${translationTrace.heading}\` | ` +
                `\`${translationTrace.intentKind}\` | ` +
                `\`${translationTrace.targetRole}\` | ` +
                `\`${translationTrace.targetPath ?? ""}\` | ` +
                `${notes} |`);
        }
    }
    lines.push("", "## Validation Findings", "");
    if (validationFindings.length === 0) {
        lines.push("- None");
    }
    else {
        // Render validation findings in a stable order so the Markdown summary
        // mirrors JSON output.
        const sortedFindings = [...validationFindings].sort((left, right) => {
            const byCode = compareStrings(left.code, right.code);
            if (byCode !== 0) {
                return byCode;
            }
            const bySource = compareStrings(left.sourcePath ?? "", right.sourcePath ?? "");
            if (bySource !== 0) {
                return bySource;
            }
            return compareStrings(left.targetPath ?? "", right.targetPath ?? "");
        });
        for (const validationFinding of sortedFindings) {
            lines.push(`- \`${validationFinding.code}\`: ${validationFinding.message}`);
        }
    }
    return lines.join("\n") + "\n";
}
