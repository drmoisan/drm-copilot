/**
 * Epic wave-barrier ordering check (TypeScript port).
 *
 * Purpose:
 *     Port `validate_wave_barrier_ordering` of
 *     `scripts/dev_tools/_epic_orchestrator_state_wave_barrier.py`: the start guard,
 *     the status and timing checks, and the early-start exemption of issue #1097.
 *     `epic-orchestrator-state-core.ts` calls `validateWaveBarrierOrdering` and reads
 *     `MERGED_STATUSES` for its completion gate.
 *
 * Responsibilities:
 *     - Report one `EPIC_WAVE_BARRIER_VIOLATION` error per violated dependency edge of
 *       a started feature.
 *     - Exempt the one edge that a valid `early_start` record names and judge it with
 *       one of two messages:
 *       `EPIC_WAVE_BARRIER_VIOLATION: <f> is at pr_open or later while early_start dependency <d> is not merged`
 *       and
 *       `EPIC_WAVE_BARRIER_VIOLATION: <f> is at pr_open or later without a string synced_at for early_start dependency <d>`.
 *
 * Invariants / Constraints:
 *     - Error-message strings are identical to the Python authority.
 *     - A feature without a valid `early_start` record takes the pre-#1097 path.
 *
 * Side Effects:
 *     None; pure records-in, errors-out validation.
 */

import {
  buildFeatureReferenceIndex,
  resolveFeatureReference,
} from "./epic-orchestrator-state-resolution";
import type { FeatureReferenceIndex } from "./epic-orchestrator-state-resolution";
import {
  CROSS_EPIC_KEY,
  isEpicSlug,
  isPositiveInt,
} from "./epic-orchestrator-state-resolution";

/** The merge statuses that durably confirm a dependency edge. */
export const MERGED_STATUSES: ReadonlySet<string> = new Set([
  "merged",
  "worktree_removed",
]);

const NOT_STARTED_MERGE_STATUS = "not_started";

/** The exact checkpoint key of an early-start record. */
const EARLY_START_KEY = "early_start";

/** Dependent statuses before pr_open, which carry no requirement on the exempt edge. */
const EARLY_START_PRE_REVIEW_STATUSES: ReadonlySet<string> = new Set([
  NOT_STARTED_MERGE_STATUS,
  "worktree_created",
]);

/** The record fields that must hold non-empty strings, besides `dependency`. */
const EARLY_START_STRING_FIELDS = [
  "upstream_branch",
  "interface_settled_at",
  "interface_evidence",
] as const;

/** The exempt folder of a valid early-start record and the record's `synced_at`. */
interface EarlyStartExemption {
  /** The canonical feature folder of the exempt dependency edge. */
  readonly folder: string;
  /** The record's raw `synced_at` value, read only on the exempt edge. */
  readonly syncedAt: unknown;
}

/**
 * Type guard for a plain object (non-null, non-array).
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Report whether a value is a string of length above zero (no trimming).
 *
 * @param value Candidate value.
 * @returns True for a non-empty string.
 */
function isNonEmptyString(value: unknown): value is string {
  return typeof value === "string" && value.length > 0;
}

/**
 * Report whether a feature is treated as started for the wave barrier.
 *
 * Mirrors Python `feature_has_started`. Fail-closed: a feature is started when its
 * `worktree_created_at` is a string (including an empty one), or when its
 * `merge_status` is not the literal `not_started` (a missing, null, or other
 * non-string `merge_status` counts as started).
 *
 * @param feature One object-shaped `features[]` entry.
 * @returns True when the feature is treated as started.
 */
function hasStarted(feature: Record<string, unknown>): boolean {
  return (
    typeof feature["worktree_created_at"] === "string" ||
    feature["merge_status"] !== NOT_STARTED_MERGE_STATUS
  );
}

/**
 * Return the exemption of a valid `early_start` record.
 *
 * Mirrors Python `early_start_exempt_folder`. The record is valid when it is an
 * object under the exact key `early_start`, its `dependency` is a non-empty string
 * or a number (never a boolean), and `upstream_branch`, `interface_settled_at`, and
 * `interface_evidence` are non-empty strings. An invalid record is the same as none.
 *
 * @param feature One object-shaped `features[]` entry.
 * @param index The union index from `buildFeatureReferenceIndex`.
 * @returns The exempt folder with the record's `synced_at`, or null when the record
 *   is absent, invalid, or resolves to no defined feature.
 */
function earlyStartExemptFolder(
  feature: Record<string, unknown>,
  index: FeatureReferenceIndex,
): EarlyStartExemption | null {
  const record = feature[EARLY_START_KEY];
  if (!isObject(record)) {
    return null;
  }
  const dependency = record["dependency"];
  if (!isNonEmptyString(dependency) && typeof dependency !== "number") {
    return null;
  }
  // Every descriptive field must hold a non-empty string for the record to count.
  for (const name of EARLY_START_STRING_FIELDS) {
    if (!isNonEmptyString(record[name])) {
      return null;
    }
  }
  const folder = resolveFeatureReference(dependency, index);
  return folder === null ? null : { folder, syncedAt: record["synced_at"] };
}

/**
 * Judge the one dependency edge that a valid `early_start` record exempts.
 *
 * Mirrors Python `early_start_edge_error`. A dependent at `not_started` or
 * `worktree_created` reports nothing; any other status, absent included, needs a
 * merged upstream (else the unmerged message) and then a non-empty string
 * `synced_at` (else the unsynced message).
 *
 * @param feature The dependent feature carrying the record.
 * @param dependencyFeature The resolved upstream feature.
 * @param folder The dependent's `feature_folder`.
 * @param dependency The raw `depends_on` element, rendered as today's messages do.
 * @param syncedAt The record's raw `synced_at` value.
 * @returns One `EPIC_WAVE_BARRIER_VIOLATION` error, or null.
 */
function earlyStartEdgeError(
  feature: Record<string, unknown>,
  dependencyFeature: Record<string, unknown>,
  folder: string,
  dependency: unknown,
  syncedAt: unknown,
): string | null {
  const status = feature["merge_status"];
  if (
    typeof status === "string" &&
    EARLY_START_PRE_REVIEW_STATUSES.has(status)
  ) {
    return null;
  }
  const upstreamStatus = dependencyFeature["merge_status"];
  // The upstream merge comes first: a sync recorded before it proves nothing.
  if (
    typeof upstreamStatus !== "string" ||
    !MERGED_STATUSES.has(upstreamStatus)
  ) {
    return `EPIC_WAVE_BARRIER_VIOLATION: ${folder} is at pr_open or later while early_start dependency ${String(dependency)} is not merged`;
  }
  if (!isNonEmptyString(syncedAt)) {
    return `EPIC_WAVE_BARRIER_VIOLATION: ${folder} is at pr_open or later without a string synced_at for early_start dependency ${String(dependency)}`;
  }
  return null;
}

/**
 * Validate the retrospective wave-barrier ordering invariant.
 *
 * Only a dependent feature that is treated as started (`hasStarted`) is checked.
 * Exactly one error is reported per violated dependency edge, and the status case
 * takes precedence over the timing case:
 * - `EPIC_WAVE_BARRIER_VIOLATION: <f> is treated as started while dependency <d> is not merged`
 *   when the dependency's `merge_status` is not `merged` or `worktree_removed`;
 * - `EPIC_WAVE_BARRIER_VIOLATION: <f> worktree_created_at precedes dependency <d> merge_confirmed_at`
 *   when the dependency's `merge_confirmed_at` is later than the dependent's
 *   `worktree_created_at`.
 * The one edge a valid `early_start` record names is judged by `earlyStartEdgeError`.
 *
 * @param features Object-shaped `features[]` entries.
 * @returns One `EPIC_WAVE_BARRIER_VIOLATION` error per violated dependency edge.
 */
export function validateWaveBarrierOrdering(
  features: Record<string, unknown>[],
): string[] {
  const errors: string[] = [];
  const byFolder = new Map<string, Record<string, unknown>>();
  for (const feature of features) {
    const folder = feature["feature_folder"];
    if (typeof folder === "string") {
      byFolder.set(folder, feature);
    }
  }
  // Resolve dependencies through the union index so a barrier edge is found
  // whether the reference is an issue_num or a folder-basename hint; on legacy
  // folder strings the resolved key equals the reference, so lookups match.
  const index = buildFeatureReferenceIndex(features);

  for (const feature of features) {
    const folder = feature["feature_folder"];
    const dependsOn = feature["depends_on"];
    if (typeof folder !== "string" || !Array.isArray(dependsOn)) {
      continue;
    }
    // Start guard: a dependent that has not started cannot have violated the
    // ordering of its dependencies, so its edges are not checked.
    if (!hasStarted(feature)) {
      continue;
    }
    const worktreeCreatedAt = feature["worktree_created_at"];
    const exemption = earlyStartExemptFolder(feature, index);

    // Every dependency edge must be durably confirmed merged before this
    // feature is considered to have safely started its own wave.
    for (const dependency of dependsOn as unknown[]) {
      const resolved = resolveFeatureReference(dependency, index);
      const dependencyFeature =
        resolved !== null ? byFolder.get(resolved) : undefined;
      if (dependencyFeature === undefined) {
        continue;
      }
      // The edge a valid early_start record names follows its own table and
      // skips both checks below; every other edge is unchanged.
      if (exemption !== null && resolved === exemption.folder) {
        const earlyError = earlyStartEdgeError(
          feature,
          dependencyFeature,
          folder,
          dependency,
          exemption.syncedAt,
        );
        if (earlyError !== null) {
          errors.push(earlyError);
        }
        continue;
      }
      const depMergeStatus = dependencyFeature["merge_status"];
      const depConfirmedAt = dependencyFeature["merge_confirmed_at"];
      const statusViolation =
        typeof depMergeStatus !== "string" ||
        !MERGED_STATUSES.has(depMergeStatus);
      const timingViolation =
        typeof depConfirmedAt === "string" &&
        typeof worktreeCreatedAt === "string" &&
        depConfirmedAt > worktreeCreatedAt;
      if (statusViolation) {
        errors.push(
          `EPIC_WAVE_BARRIER_VIOLATION: ${folder} is treated as started while dependency ${String(dependency)} is not merged`,
        );
      } else if (timingViolation) {
        errors.push(
          `EPIC_WAVE_BARRIER_VIOLATION: ${folder} worktree_created_at precedes dependency ${String(dependency)} merge_confirmed_at`,
        );
      }
    }
  }
  // Key-gated issue #1162 check: a feature without cross_epic_depends_on adds
  // nothing, so the result above is unchanged for older checkpoints.
  errors.push(...validateCrossEpicStartedWhileHeld(features));
  return errors;
}

/**
 * Report started features whose cross-epic dependency is not integrated.
 *
 * Mirrors Python `validate_cross_epic_started_while_held` (issue #1162): a feature
 * that `hasStarted` treats as started must not carry a `cross_epic_depends_on`
 * entry whose `status` is not `integrated` or `in_main`. Entries without a valid
 * epic slug or a positive integer `issue_num` are left to the shape check.
 *
 * @param features Object-shaped `features[]` entries.
 * @returns One `EPIC_CROSS_DEPENDENCY_VIOLATION` error per held entry.
 */
export function validateCrossEpicStartedWhileHeld(
  features: Record<string, unknown>[],
): string[] {
  const errors: string[] = [];
  for (const feature of features) {
    const folder = feature["feature_folder"];
    const entries = feature[CROSS_EPIC_KEY];
    if (
      typeof folder !== "string" ||
      !Array.isArray(entries) ||
      !hasStarted(feature)
    ) {
      continue;
    }
    for (const entry of entries as unknown[]) {
      if (!isObject(entry)) {
        continue;
      }
      const epic = entry["epic"];
      const issueNum = entry["issue_num"];
      if (!isEpicSlug(epic) || !isPositiveInt(issueNum)) {
        continue;
      }
      const status = entry["status"];
      if (status === "integrated" || status === "in_main") {
        continue;
      }
      errors.push(
        `EPIC_CROSS_DEPENDENCY_VIOLATION: ${folder} is treated as started while cross-epic dependency ${epic}#${String(issueNum)} is not integrated`,
      );
    }
  }
  return errors;
}
