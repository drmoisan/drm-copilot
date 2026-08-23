"use strict";
/**
 * Render Mermaid topology charts for the Codex-native conversion report.
 *
 * Purpose:
 *     Provide the pure Mermaid rendering helpers ported from
 *     `_reporting_topology.py`. Node IDs are generated from enumeration indices
 *     so output is stable for the same input sequence.
 *
 * Invariants:
 *     All functions are pure and side-effect-free; the Mermaid text (node ids,
 *     edge syntax, ordering) is preserved verbatim from the Python source.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.mermaidLabel = mermaidLabel;
exports.renderSourceToDestinationChart = renderSourceToDestinationChart;
exports.renderSourceToRepeatedDestinationChart = renderSourceToRepeatedDestinationChart;
exports.renderDestinationToRepeatedSourceChart = renderDestinationToRepeatedSourceChart;
/**
 * Escape one Mermaid node label deterministically.
 *
 * Mirrors `mermaid_label`: returns the JSON-string escaping without the
 * surrounding quotes (`json.dumps(text)[1:-1]`).
 *
 * @param text Raw label text.
 * @returns Escaped label text without surrounding quotes.
 */
function mermaidLabel(text) {
    const jsonString = JSON.stringify(text);
    return jsonString.slice(1, jsonString.length - 1);
}
/**
 * Render a Mermaid chart with shared source and destination nodes.
 *
 * Mirrors `render_source_to_destination_chart`: deduplicates both source and
 * destination nodes.
 *
 * @param topologyEdges Edges to render.
 * @returns Markdown lines for a fenced Mermaid code block.
 */
function renderSourceToDestinationChart(topologyEdges) {
    const sourceNodeIds = new Map();
    const destinationNodeIds = new Map();
    const lines = ["```mermaid", "graph LR"];
    // Emit one node per unique source or destination path; connect with arrows.
    topologyEdges.forEach((topologyEdge, index) => {
        const sourcePath = topologyEdge.sourcePath;
        const targetLabel = topologyEdge.destinationPath;
        let sourceNodeId = sourceNodeIds.get(sourcePath);
        if (sourceNodeId === undefined) {
            sourceNodeId = `source_${index}`;
            sourceNodeIds.set(sourcePath, sourceNodeId);
            lines.push(`    ${sourceNodeId}["${mermaidLabel(sourcePath)}"]`);
        }
        let destinationNodeId = destinationNodeIds.get(targetLabel);
        if (destinationNodeId === undefined) {
            destinationNodeId = `destination_${index}`;
            destinationNodeIds.set(targetLabel, destinationNodeId);
            lines.push(`    ${destinationNodeId}["${mermaidLabel(targetLabel)}"]`);
        }
        lines.push(`    ${sourceNodeId} --> ${destinationNodeId}`);
    });
    lines.push("```");
    return lines;
}
/**
 * Render a Mermaid chart that repeats destination nodes per mapping.
 *
 * Mirrors `render_source_to_repeated_destination_chart`: collapses source
 * nodes but repeats destination nodes per edge.
 *
 * @param topologyEdges Edges to render.
 * @returns Markdown lines for a fenced Mermaid code block.
 */
function renderSourceToRepeatedDestinationChart(topologyEdges) {
    const sourceNodeIds = new Map();
    const lines = ["```mermaid", "graph LR"];
    topologyEdges.forEach((topologyEdge, index) => {
        const sourcePath = topologyEdge.sourcePath;
        const targetLabel = topologyEdge.destinationPath;
        let sourceNodeId = sourceNodeIds.get(sourcePath);
        if (sourceNodeId === undefined) {
            sourceNodeId = `source_${index}`;
            sourceNodeIds.set(sourcePath, sourceNodeId);
            lines.push(`    ${sourceNodeId}["${mermaidLabel(sourcePath)}"]`);
        }
        const destinationNodeId = `destination_${index}`;
        lines.push(`    ${destinationNodeId}["${mermaidLabel(targetLabel)}"]`);
        lines.push(`    ${sourceNodeId} --> ${destinationNodeId}`);
    });
    lines.push("```");
    return lines;
}
/**
 * Render a Mermaid chart that repeats source nodes per mapping.
 *
 * Mirrors `render_destination_to_repeated_source_chart`: collapses destination
 * nodes but repeats source nodes per edge.
 *
 * @param topologyEdges Edges to render.
 * @returns Markdown lines for a fenced Mermaid code block.
 */
function renderDestinationToRepeatedSourceChart(topologyEdges) {
    const destinationNodeIds = new Map();
    const lines = ["```mermaid", "graph LR"];
    topologyEdges.forEach((topologyEdge, index) => {
        const sourcePath = topologyEdge.sourcePath;
        const targetLabel = topologyEdge.destinationPath;
        let destinationNodeId = destinationNodeIds.get(targetLabel);
        if (destinationNodeId === undefined) {
            destinationNodeId = `destination_${index}`;
            destinationNodeIds.set(targetLabel, destinationNodeId);
            lines.push(`    ${destinationNodeId}["${mermaidLabel(targetLabel)}"]`);
        }
        const sourceNodeId = `source_${index}`;
        lines.push(`    ${sourceNodeId}["${mermaidLabel(sourcePath)}"]`);
        lines.push(`    ${destinationNodeId} --> ${sourceNodeId}`);
    });
    lines.push("```");
    return lines;
}
