/**
 * Epic-orchestrator checkpoint validator (TypeScript port).
 *
 * Purpose:
 *     Port `scripts/dev_tools/validate_epic_orchestrator_state.py`'s
 *     `validate_epic_orchestrator_state_text`. The MCP-served `validate_orchestration_artifacts`
 *     tool is backed by this TS port; the Python CLI remains the direct/test entrypoint.
 *
 * Responsibilities:
 *     - Parse the epic checkpoint JSON and validate the four baseline fields plus the
 *       epic-specific required fields (`route_id`, `epic_feature_folder`,
 *       `integration_branch`, `waves`, `features`).
 *     - Validate `features[]` shape: `feature_folder` uniqueness, `depends_on` reference
 *       resolution, dependency-cycle rejection, and `merge_status` enum membership.
 *     - Validate the retrospective wave-barrier ordering invariant and the
 *       `waves[].feature_folders`/`wave_number` consistency.
 *     - Under `requireComplete`, enforce the completion gate (every feature
 *       merged/removed, `epic_merge_pr.merge_commit_sha` recorded).
 *
 * Invariants / Constraints:
 *     - Error-message strings are identical to the Python source.
 *     - This module stays within the repository's 500-line file-size limit.
 *
 * Side Effects:
 *     None; pure text-in, errors-out validation.
 */

const REQUIRED_BASELINE_KEYS = [
  "objective",
  "completed_steps",
  "next_step",
  "last_updated",
] as const;

const REQUIRED_EPIC_KEYS = [
  "route_id",
  "epic_feature_folder",
  "integration_branch",
  "waves",
  "features",
] as const;

const EXPECTED_ROUTE_ID = "epic";

const VALID_MERGE_STATUS: ReadonlySet<string> = new Set([
  "not_started",
  "worktree_created",
  "pr_open",
  "ci_green",
  "merge_conflict",
  "blocked_conflict_loop_limit",
  "merged",
  "worktree_removed",
]);

const MERGED_STATUSES: ReadonlySet<string> = new Set([
  "merged",
  "worktree_removed",
]);

/** Options controlling epic-orchestrator-state validation. */
export interface ValidateEpicOrchestratorStateOptions {
  /** When true, enforce completion-safe feature/merge state. */
  readonly requireComplete?: boolean;
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
 * Return the features[] list as typed records, skipping non-object entries.
 *
 * @param state Parsed checkpoint JSON object.
 * @returns Each object-shaped entry in `features[]`.
 */
function extractFeatures(
  state: Record<string, unknown>,
): Record<string, unknown>[] {
  const features = state["features"];
  if (!Array.isArray(features)) {
    return [];
  }
  // Keep only well-formed feature objects; a non-object entry is not a valid
  // feature record and cannot be used for uniqueness/reference resolution.
  return features.filter(isObject);
}

/**
 * Validate presence of the baseline and epic-specific required keys.
 *
 * @param state Parsed checkpoint JSON object.
 * @returns One error string per missing required key.
 */
function missingBaselineAndEpicKeys(state: Record<string, unknown>): string[] {
  const errors: string[] = [];
  for (const key of [...REQUIRED_BASELINE_KEYS, ...REQUIRED_EPIC_KEYS]) {
    if (!(key in state)) {
      errors.push(`Epic checkpoint missing required key: ${key}`);
    }
  }
  return errors;
}

/**
 * Validate that route_id, when present, is exactly 'epic'.
 *
 * @param state Parsed checkpoint JSON object.
 * @returns An error when route_id is present but not 'epic'.
 */
function validateRouteId(state: Record<string, unknown>): string[] {
  if ("route_id" in state && state["route_id"] !== EXPECTED_ROUTE_ID) {
    return [
      `Epic checkpoint route_id must be 'epic', found: ${JSON.stringify(state["route_id"])}`,
    ];
  }
  return [];
}

/**
 * Validate feature_folder uniqueness and depends_on reference resolution.
 *
 * @param features Object-shaped `features[]` entries.
 * @returns One error per duplicate `feature_folder` or unresolved `depends_on` reference.
 */
function validateFeatureFolderUniquenessAndDependencies(
  features: Record<string, unknown>[],
): string[] {
  const errors: string[] = [];
  const seen = new Set<string>();
  const duplicates = new Set<string>();

  // Walk once to collect the full set of defined feature_folder values before
  // checking depends_on resolution, so forward references are not misreported.
  const allFolders = new Set<string>();
  for (const feature of features) {
    const folder = feature["feature_folder"];
    if (typeof folder === "string" && folder) {
      allFolders.add(folder);
    }
  }

  for (const feature of features) {
    const folder = feature["feature_folder"];
    if (typeof folder !== "string" || !folder) {
      continue;
    }
    if (seen.has(folder)) {
      duplicates.add(folder);
    }
    seen.add(folder);

    const dependsOn = feature["depends_on"];
    if (!Array.isArray(dependsOn)) {
      continue;
    }
    // Every declared dependency must resolve to a defined feature_folder; an
    // unresolved reference is a malformed manifest, rejected up front.
    for (const dependency of dependsOn as unknown[]) {
      if (!allFolders.has(dependency as string)) {
        errors.push(
          `Epic checkpoint feature '${folder}' depends_on unresolved feature_folder: ${JSON.stringify(dependency)}`,
        );
      }
    }
  }

  for (const folder of [...duplicates].sort()) {
    errors.push(
      `Epic checkpoint has duplicate features[].feature_folder: ${folder}`,
    );
  }
  return errors;
}

/**
 * Detect a cycle in the depends_on dependency graph via DFS.
 *
 * @param features Object-shaped `features[]` entries.
 * @returns An error string naming the cycle, or null when acyclic.
 */
function detectDependencyCycle(
  features: Record<string, unknown>[],
): string | null {
  const graph = new Map<string, string[]>();
  for (const feature of features) {
    const folder = feature["feature_folder"];
    if (typeof folder !== "string" || !folder) {
      continue;
    }
    const dependsOn = feature["depends_on"];
    graph.set(
      folder,
      Array.isArray(dependsOn)
        ? (dependsOn as unknown[]).filter(
            (d): d is string => typeof d === "string",
          )
        : [],
    );
  }

  const visiting = new Set<string>();
  const visited = new Set<string>();

  function visit(node: string): string | null {
    if (visiting.has(node)) {
      return node;
    }
    if (visited.has(node) || !graph.has(node)) {
      return null;
    }
    visiting.add(node);
    // Depth-first traversal of this node's dependencies; a revisit of a node
    // still on the current path (in `visiting`) indicates a cycle.
    for (const dependency of graph.get(node) ?? []) {
      const cycleNode = visit(dependency);
      if (cycleNode !== null) {
        return cycleNode;
      }
    }
    visiting.delete(node);
    visited.add(node);
    return null;
  }

  for (const start of graph.keys()) {
    const cycleNode = visit(start);
    if (cycleNode !== null) {
      return `Epic checkpoint depends_on graph contains a cycle involving feature_folder: ${cycleNode}`;
    }
  }
  return null;
}

/**
 * Validate merge_status enum membership for every feature record.
 *
 * @param features Object-shaped `features[]` entries.
 * @returns One error per feature with an invalid `merge_status` value.
 */
function validateMergeStatusEnum(
  features: Record<string, unknown>[],
): string[] {
  const errors: string[] = [];
  for (const feature of features) {
    const folder = feature["feature_folder"] ?? "<unknown>";
    const mergeStatus = feature["merge_status"];
    if (
      mergeStatus !== undefined &&
      mergeStatus !== null &&
      !(typeof mergeStatus === "string" && VALID_MERGE_STATUS.has(mergeStatus))
    ) {
      errors.push(
        `Epic checkpoint feature '${String(folder)}' has invalid merge_status: ${JSON.stringify(mergeStatus)}`,
      );
    }
  }
  return errors;
}

/**
 * Validate the retrospective wave-barrier ordering invariant.
 *
 * @param features Object-shaped `features[]` entries.
 * @returns One `EPIC_WAVE_BARRIER_VIOLATION` error per violated dependency edge.
 */
function validateWaveBarrierOrdering(
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

  for (const feature of features) {
    const folder = feature["feature_folder"];
    const dependsOn = feature["depends_on"];
    if (typeof folder !== "string" || !Array.isArray(dependsOn)) {
      continue;
    }
    const worktreeCreatedAt = feature["worktree_created_at"];

    // Every dependency edge must be durably confirmed merged before this
    // feature is considered to have safely started its own wave.
    for (const dependency of dependsOn as unknown[]) {
      const dependencyFeature = byFolder.get(dependency as string);
      if (dependencyFeature === undefined) {
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
      if (statusViolation || timingViolation) {
        errors.push(
          `EPIC_WAVE_BARRIER_VIOLATION: ${folder} started before dependency ${String(dependency)} merged`,
        );
      }
    }
  }
  return errors;
}

/**
 * Validate consistency between waves[].feature_folders and wave_number.
 *
 * @param state Parsed checkpoint JSON object.
 * @returns One error per feature_folder whose recorded wave_number does not match the
 *   wave it is listed under in `waves[]`.
 */
function validateWavesConsistency(state: Record<string, unknown>): string[] {
  const errors: string[] = [];
  const waves = state["waves"];
  if (!Array.isArray(waves)) {
    return errors;
  }
  const featuresByFolder = new Map<string, Record<string, unknown>>();
  for (const feature of extractFeatures(state)) {
    const folder = feature["feature_folder"];
    if (typeof folder === "string") {
      featuresByFolder.set(folder, feature);
    }
  }

  for (const waveItem of waves as unknown[]) {
    if (!isObject(waveItem)) {
      continue;
    }
    const waveNumber = waveItem["wave_number"];
    const folders = waveItem["feature_folders"];
    if (!Array.isArray(folders)) {
      continue;
    }
    // Every feature listed under this wave must record the same wave_number
    // on its own features[] entry.
    for (const folder of folders as unknown[]) {
      const feature = featuresByFolder.get(folder as string);
      if (feature === undefined) {
        continue;
      }
      if (feature["wave_number"] !== waveNumber) {
        errors.push(
          `Epic checkpoint waves[] lists '${String(folder)}' under wave ${String(waveNumber)} but its own wave_number is ${JSON.stringify(feature["wave_number"])}`,
        );
      }
    }
  }
  return errors;
}

/**
 * Validate the requireComplete completion gate.
 *
 * @param features Object-shaped `features[]` entries.
 * @param state Parsed checkpoint JSON object.
 * @returns Completion-gate errors: any feature not merged/removed, or a missing/empty
 *   `epic_merge_pr.merge_commit_sha`.
 */
function validateCompletion(
  features: Record<string, unknown>[],
  state: Record<string, unknown>,
): string[] {
  const errors: string[] = [];
  for (const feature of features) {
    const folder = feature["feature_folder"] ?? "<unknown>";
    const mergeStatus = feature["merge_status"];
    if (typeof mergeStatus !== "string" || !MERGED_STATUSES.has(mergeStatus)) {
      errors.push(
        `Epic checkpoint completion validation failed: feature '${String(folder)}' merge_status is not merged/worktree_removed.`,
      );
    }
  }

  const epicMergePr = state["epic_merge_pr"];
  const mergeCommitSha = isObject(epicMergePr)
    ? epicMergePr["merge_commit_sha"]
    : undefined;
  if (typeof mergeCommitSha !== "string" || !mergeCommitSha.trim()) {
    errors.push(
      "Epic checkpoint completion validation failed: epic_merge_pr.merge_commit_sha is missing or empty.",
    );
  }
  return errors;
}

/**
 * Validate epic checkpoint schema and wave-barrier/completion invariants.
 *
 * Purpose:
 *     Mirror Python `validate_epic_orchestrator_state_text`. Enforce the repository
 *     contract for `artifacts/orchestration/epic-orchestrator-state.json` before resume
 *     or completion-gate workflows rely on its contents.
 *
 * @param text Raw epic checkpoint JSON text.
 * @param options Validation options (completion gate).
 * @returns Validation errors for malformed or incomplete checkpoint state; an empty array
 *   when the checkpoint is valid.
 */
export function validateEpicOrchestratorStateText(
  text: string,
  options: ValidateEpicOrchestratorStateOptions = {},
): string[] {
  let state: unknown;
  try {
    state = JSON.parse(text);
  } catch (exc) {
    return [
      `Epic checkpoint is not valid JSON: ${exc instanceof Error ? exc.message : String(exc)}`,
    ];
  }

  if (!isObject(state)) {
    return ["Epic checkpoint root must be a JSON object."];
  }
  const stateMap = state;

  const errors: string[] = [];
  errors.push(...missingBaselineAndEpicKeys(stateMap));
  errors.push(...validateRouteId(stateMap));

  const features = extractFeatures(stateMap);
  errors.push(...validateFeatureFolderUniquenessAndDependencies(features));
  const cycleError = detectDependencyCycle(features);
  if (cycleError !== null) {
    errors.push(cycleError);
  }
  errors.push(...validateMergeStatusEnum(features));
  errors.push(...validateWaveBarrierOrdering(features));
  errors.push(...validateWavesConsistency(stateMap));

  if (options.requireComplete === true) {
    errors.push(...validateCompletion(features, stateMap));
  }

  return errors;
}
