"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatTree = formatTree;
/**
 * Render an assembled subagent tree as human-readable text.
 *
 * Purpose:
 *     Pure renderer per Design Decision item 6. Each node renders as one
 *     line, `${indent}${agentType} · [${models}] · ${depth} · ${description}`,
 *     followed by each child's rendered lines, in child order. Indentation
 *     is two spaces per depth unit. Models are sorted ascending before
 *     joining so a node with more than one distinct model prints all of
 *     them in a deterministic order regardless of scan/assembly order.
 *
 * @param node The root (or any) `TreeNode` to render.
 * @returns The rendered tree as newline-joined text.
 */
function formatTree(node) {
    return renderLines(node).join("\n");
}
/**
 * Recursively render `node` and its children into an ordered list of lines.
 *
 * @param node The node to render.
 * @returns This node's line followed by each child's lines, in child order.
 */
function renderLines(node) {
    const indent = "  ".repeat(node.depth);
    const sortedModels = [...node.models].sort();
    const line = `${indent}${node.agentType} · [${sortedModels.join(",")}] · ${node.depth} · ${node.description}`;
    const childLines = node.children.flatMap((child) => renderLines(child));
    return [line, ...childLines];
}
