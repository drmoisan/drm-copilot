"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatTree = void 0;
exports.buildSubagentTree = buildSubagentTree;
const tree_assembler_1 = require("./tree-assembler");
const transcript_scanner_1 = require("./transcript-scanner");
var tree_formatter_1 = require("./tree-formatter");
Object.defineProperty(exports, "formatTree", { enumerable: true, get: function () { return tree_formatter_1.formatTree; } });
/**
 * Build the subagent call tree for a root session.
 *
 * Purpose:
 *     Barrel entry point composing `scanTranscripts` (I/O, injected
 *     `FileSystem`) and `assembleTree` (pure) into a single call, so host
 *     wiring (`src/subagent-tree-command.ts`) depends on one function rather
 *     than the module's internal shape.
 *
 * @param rootSessionPath Absolute path to the root session's `.jsonl` file.
 * @param deps Injected dependencies; `fileSystem` performs the actual I/O.
 * @returns The assembled root `TreeNode`.
 */
function buildSubagentTree(rootSessionPath, deps) {
    const scanned = (0, transcript_scanner_1.scanTranscripts)(rootSessionPath, deps.fileSystem);
    return (0, tree_assembler_1.assembleTree)(scanned);
}
