/**
 * Pure per-file comparator of the unified push-down pipeline (issue #1029).
 *
 * Purpose:
 *     Classify one payload file against the destination file and its manifest
 *     entry, following the spec `### Decision Table`. The comparator performs
 *     no I/O: it receives hashes and returns the action, whether an apply run
 *     writes the file, the hash the next manifest records, and the reason.
 *
 * Invariants / Constraints:
 *     - Hashes are of LF-normalized text.
 *     - A destination file that differs from both its manifest entry and the
 *       payload is never written.
 *     - A destination file without a manifest entry that differs from the
 *       payload is written only when `overwriteUnmanaged` is true.
 */

/** Every action the pipeline reports. */
export type PushDownAction =
  | "create"
  | "deleted-locally"
  | "unchanged"
  | "update"
  | "converged"
  | "conflict"
  | "adopt"
  | "unmanaged-conflict"
  | "merge"
  | "excluded"
  | "orphaned";

/** Human-readable reason per action. */
export const PUSH_DOWN_ACTION_REASONS: Readonly<
  Record<PushDownAction, string>
> = {
  create: "absent in destination and manifest",
  "deleted-locally":
    "absent in destination but recorded in the manifest; not restored",
  unchanged: "destination and payload match the manifest",
  update: "destination matches the manifest and the payload changed",
  converged: "destination was edited to match the payload",
  conflict: "destination was edited since the last push-down; not overwritten",
  adopt: "present without a manifest entry and identical to the payload",
  "unmanaged-conflict":
    "present without a manifest entry and different from the payload; not overwritten",
  merge: "merged into the destination file",
  excluded: "listed in .push-down-exclusions",
  orphaned: "manifest entry without a payload counterpart; not deleted",
};

/** Reason recorded when an unmanaged conflict is overwritten on request. */
export const UNMANAGED_OVERWRITE_REASON =
  "present without a manifest entry and different from the payload; overwritten through overwrite_unmanaged";

/** Hashes and options the comparator decides from. */
export interface PayloadComparisonInput {
  /** Hash of the destination file, or `undefined` when it is absent. */
  readonly destinationHash: string | undefined;
  /** Hash recorded in the manifest, or `undefined` without an entry. */
  readonly manifestHash: string | undefined;
  /** Hash of the payload text after rewrites and variant routing. */
  readonly payloadHash: string;
  /** Overwrite an `unmanaged-conflict` file (O-4 opt-in). */
  readonly overwriteUnmanaged: boolean;
}

/** Decision for one payload file. */
export interface PayloadClassification {
  /** Decision-table action. */
  readonly action: PushDownAction;
  /** Whether an apply run writes the payload text. */
  readonly write: boolean;
  /** Hash the next manifest records, or `undefined` for no entry. */
  readonly recordHash: string | undefined;
  /** Human-readable reason. */
  readonly reason: string;
}

/**
 * Build a classification whose reason is the action's standard reason.
 *
 * @param action Decision-table action.
 * @param write Whether an apply run writes the file.
 * @param recordHash Hash the next manifest records.
 * @returns The classification.
 */
function decide(
  action: PushDownAction,
  write: boolean,
  recordHash: string | undefined,
): PayloadClassification {
  return {
    action,
    write,
    recordHash,
    reason: PUSH_DOWN_ACTION_REASONS[action],
  };
}

/**
 * Classify one payload file per the spec decision table.
 *
 * @param input Destination, manifest, and payload hashes plus the opt-in.
 * @returns The action, write flag, recorded hash, and reason.
 */
export function classifyPayloadFile(
  input: PayloadComparisonInput,
): PayloadClassification {
  const { destinationHash, manifestHash, payloadHash, overwriteUnmanaged } =
    input;
  if (destinationHash === undefined) {
    return manifestHash === undefined
      ? decide("create", true, payloadHash)
      : decide("deleted-locally", false, manifestHash);
  }
  if (manifestHash === undefined) {
    if (destinationHash === payloadHash) {
      return decide("adopt", false, payloadHash);
    }
    return overwriteUnmanaged
      ? {
          action: "unmanaged-conflict",
          write: true,
          recordHash: payloadHash,
          reason: UNMANAGED_OVERWRITE_REASON,
        }
      : decide("unmanaged-conflict", false, undefined);
  }
  if (destinationHash === manifestHash) {
    return payloadHash === manifestHash
      ? decide("unchanged", false, manifestHash)
      : decide("update", true, payloadHash);
  }
  return destinationHash === payloadHash
    ? decide("converged", false, payloadHash)
    : decide("conflict", false, manifestHash);
}
