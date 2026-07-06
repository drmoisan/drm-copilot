import type {
  ScannedSession,
  ScannedSubagent,
  ScannedTranscript,
  TreeNode,
} from "./types";

/**
 * Sentinel key identifying the root transcript in the parent-lookup map.
 *
 * Uses a `__root__` sentinel so it can never collide with a real
 * `agentId` (a filename-derived identifier) or `toolUseId`, without needing
 * a discriminated union just to distinguish "root" from "subagent" keys.
 */
const ROOT_KEY = "__root__";

/**
 * Assemble the deterministic subagent call tree from scan results.
 *
 * Purpose:
 *     Pure port of the parent/child matching, sibling ordering, and orphan
 *     handling described in Design Decision items 3–5. Performs no I/O.
 *
 * Algorithm:
 *     1. `spawnDepth` is read verbatim from each subagent's meta as the
 *        node's `depth`; the root node's `depth` is `0`.
 *     2. A subagent is a child of whichever transcript (root or another
 *        subagent) contains its `meta.toolUseId` among that transcript's
 *        `agentToolUseIds` (exact match, no heuristics).
 *     3. Siblings are ordered by the index of their spawning tool-use id
 *        within the parent transcript's `agentToolUseIds`, ascending; ties
 *        break by ascending `agentId`.
 *     4. A subagent whose `toolUseId` matches no transcript is an orphan,
 *        attached as a root child after all normally-matched root children,
 *        ordered by ascending `agentId`. An orphan's own descendants are
 *        still assembled normally beneath it.
 *
 * @param scanned The scan result produced by `scanTranscripts`.
 * @returns The assembled root `TreeNode`.
 */
export function assembleTree(scanned: ScannedSession): TreeNode {
  const transcriptsByKey = new Map<string, ScannedTranscript>();
  transcriptsByKey.set(ROOT_KEY, scanned.root);
  for (const subagent of scanned.subagents) {
    transcriptsByKey.set(subagent.meta.agentId, subagent.transcript);
  }

  const matchedChildrenByParentKey = new Map<string, ScannedSubagent[]>();
  const orphans: ScannedSubagent[] = [];

  for (const subagent of scanned.subagents) {
    const parentKey = findParentKey(subagent.meta.toolUseId, transcriptsByKey);
    if (parentKey === undefined) {
      orphans.push(subagent);
      continue;
    }

    const siblings = matchedChildrenByParentKey.get(parentKey) ?? [];
    siblings.push(subagent);
    matchedChildrenByParentKey.set(parentKey, siblings);
  }

  orphans.sort(compareByAgentId);

  return buildNode({
    key: ROOT_KEY,
    agentType: "root",
    description: "",
    depth: 0,
    models: scanned.root.models,
    transcriptsByKey,
    matchedChildrenByParentKey,
    orphans,
  });
}

/**
 * Find the key of the transcript whose `agentToolUseIds` contains `toolUseId`.
 *
 * @param toolUseId The spawning tool-use id to search for.
 * @param transcriptsByKey All scanned transcripts, keyed by `ROOT_KEY` or `agentId`.
 * @returns The matching key, or `undefined` when no transcript contains it.
 */
function findParentKey(
  toolUseId: string,
  transcriptsByKey: ReadonlyMap<string, ScannedTranscript>,
): string | undefined {
  for (const [key, transcript] of transcriptsByKey) {
    if (transcript.agentToolUseIds.includes(toolUseId)) {
      return key;
    }
  }
  return undefined;
}

/** Ascending string comparison of two subagents' `agentId`. */
function compareByAgentId(a: ScannedSubagent, b: ScannedSubagent): number {
  if (a.meta.agentId < b.meta.agentId) {
    return -1;
  }
  if (a.meta.agentId > b.meta.agentId) {
    return 1;
  }
  return 0;
}

/**
 * Order a parent's matched children by spawn-index, tie-broken by `agentId`.
 *
 * @param children Subagents matched to this parent.
 * @param parentTranscript The parent's transcript (supplies spawn order).
 * @returns A new array in deterministic sibling order.
 */
function sortBySpawnIndex(
  children: readonly ScannedSubagent[],
  parentTranscript: ScannedTranscript,
): ScannedSubagent[] {
  return [...children].sort((a, b) => {
    const indexA = parentTranscript.agentToolUseIds.indexOf(a.meta.toolUseId);
    const indexB = parentTranscript.agentToolUseIds.indexOf(b.meta.toolUseId);
    if (indexA !== indexB) {
      return indexA - indexB;
    }
    return compareByAgentId(a, b);
  });
}

/** Inputs needed to recursively build one `TreeNode`. */
interface BuildNodeInput {
  readonly key: string;
  readonly agentType: string;
  readonly description: string;
  readonly depth: number;
  readonly models: readonly string[];
  readonly transcriptsByKey: ReadonlyMap<string, ScannedTranscript>;
  readonly matchedChildrenByParentKey: ReadonlyMap<string, ScannedSubagent[]>;
  readonly orphans: readonly ScannedSubagent[];
}

/**
 * Recursively build one `TreeNode` and its ordered children.
 *
 * @param input The node's own fields plus the shared lookup maps.
 * @returns The assembled `TreeNode`.
 */
function buildNode(input: BuildNodeInput): TreeNode {
  const {
    key,
    agentType,
    description,
    depth,
    models,
    transcriptsByKey,
    matchedChildrenByParentKey,
    orphans,
  } = input;

  const transcript = transcriptsByKey.get(key);
  const matchedChildren = matchedChildrenByParentKey.get(key) ?? [];
  const orderedMatched = transcript
    ? sortBySpawnIndex(matchedChildren, transcript)
    : matchedChildren;

  const isRoot = key === ROOT_KEY;
  const orderedChildren = isRoot
    ? [...orderedMatched, ...orphans]
    : orderedMatched;

  const children = orderedChildren.map((subagent) =>
    buildNode({
      key: subagent.meta.agentId,
      agentType: subagent.meta.agentType,
      description: subagent.meta.description,
      depth: subagent.meta.spawnDepth,
      models: subagent.transcript.models,
      transcriptsByKey,
      matchedChildrenByParentKey,
      orphans,
    }),
  );

  return {
    agentType,
    description,
    depth,
    models: [...models].sort(),
    children,
  };
}
