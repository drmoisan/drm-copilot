import type { FileSystem } from "../file-system";
import { assembleTree } from "./tree-assembler";
import { scanTranscripts } from "./transcript-scanner";
import type { TreeNode } from "./types";

export { formatTree } from "./tree-formatter";
export type { TreeNode } from "./types";

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
export function buildSubagentTree(
  rootSessionPath: string,
  deps: { readonly fileSystem: FileSystem },
): TreeNode {
  const scanned = scanTranscripts(rootSessionPath, deps.fileSystem);
  return assembleTree(scanned);
}
