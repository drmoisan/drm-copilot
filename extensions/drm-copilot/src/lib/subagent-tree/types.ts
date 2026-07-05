/**
 * Pure data types for the subagent-tree module.
 *
 * Purpose:
 *     Model the on-disk transcript/meta facts (`SubagentMeta`,
 *     `ScannedTranscript`, `ScannedSubagent`, `ScannedSession`) and the
 *     assembled render tree (`TreeNode`) that `transcript-parser.ts`,
 *     `transcript-scanner.ts`, `tree-assembler.ts`, and `tree-formatter.ts`
 *     operate over. This file performs no I/O and has no VS Code imports.
 */

/**
 * Fields read verbatim from a subagent's `agent-<agentId>.meta.json`, plus
 * the `agentId` parsed from the meta filename itself.
 *
 * `spawnDepth` is read as-is and never recomputed by recursion (Design
 * Decision item 3): it becomes the assembled node's `depth` directly.
 */
export interface SubagentMeta {
  /** The `agentId` segment parsed from `agent-<agentId>.meta.json`. */
  readonly agentId: string;
  /** The subagent's declared type (e.g. `atomic-executor`). */
  readonly agentType: string;
  /** Human-readable description of the subagent's task. */
  readonly description: string;
  /** The `Agent` tool-use id that spawned this subagent. */
  readonly toolUseId: string;
  /** Nesting depth recorded verbatim by the spawning host. */
  readonly spawnDepth: number;
  /** Optional worktree path associated with this subagent's session. */
  readonly worktreePath?: string;
  /** Optional worktree branch associated with this subagent's session. */
  readonly worktreeBranch?: string;
}

/**
 * The facts extracted from a single transcript file (root or subagent): the
 * distinct `message.model` values observed, and the ordered list of `Agent`
 * tool-use ids emitted by that transcript, in file line order.
 */
export interface ScannedTranscript {
  /** Distinct `message.model` values observed, in first-seen order. */
  readonly models: readonly string[];
  /** `Agent` tool-use ids emitted by this transcript, in file line order. */
  readonly agentToolUseIds: readonly string[];
}

/** One subagent's parsed meta plus its own scanned transcript facts. */
export interface ScannedSubagent {
  readonly meta: SubagentMeta;
  readonly transcript: ScannedTranscript;
}

/** The full scan result for a root session: its transcript plus every subagent. */
export interface ScannedSession {
  readonly root: ScannedTranscript;
  readonly subagents: readonly ScannedSubagent[];
}

/**
 * One node of the assembled, renderable subagent tree.
 *
 * The root node's `agentType` is a fixed sentinel (`"root"`) since the root
 * session has no `meta.json`; `depth` is `0` for the root.
 */
export interface TreeNode {
  readonly agentType: string;
  readonly description: string;
  readonly depth: number;
  /** Distinct models observed for this node, sorted ascending. */
  readonly models: readonly string[];
  readonly children: readonly TreeNode[];
}
