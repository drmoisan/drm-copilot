/**
 * Parallel-planner checkpoint validator (TypeScript port).
 *
 * Purpose:
 *     Port `scripts/dev_tools/validate_parallel_planner_state.py`'s
 *     `validate_parallel_planner_state_text`. Enforces the repository contract
 *     for `artifacts/orchestration/parallel-planner-state.json` -- spec
 *     invariants P1 through P4 unconditionally and the structural readiness gate
 *     P6 through P9 only under `requireReadyForExecution` -- before a prepared
 *     parallel run is handed to the orchestrator surface.
 *
 * Flow:
 *     Parse the checkpoint JSON, reject a non-object root, check the S3
 *     required-key set, validate run identity (`parallel_slug`,
 *     `parallel_manifest_path`, `mode`, `max_concurrency`), scan for prohibited
 *     keys, then delegate the item, cohort, and conflict-edge collections to
 *     `parallel-state-shared.ts` and `parallel-state-structures.ts` so the
 *     planner and orchestrator surfaces share one implementation of each shape.
 *
 * Deliberate omissions:
 *     Spec P5 records that F3 does NOT recompute the cohort coloring: parity
 *     against the cohort computation is F4's planner-side check. The readiness
 *     gate here is structural only; the deep readiness-integrity machinery is
 *     likewise F4's, and this module never parses kickoff CONTENT -- invariant
 *     P9 constrains the kickoff PATH only (assumption A6).
 *
 * Invariants / Constraints:
 *     - Error strings are byte-identical to the Python source; every one begins
 *       with the literal prefix `Parallel planner checkpoint` and ends with a
 *       period.
 *     - The validator returns an array of error strings and never mutates its
 *       input. No JSON Schema file is authored or imported.
 *
 * Side Effects:
 *     None; pure text-in, errors-out validation.
 */

import {
  VALID_MODES,
  enumError,
  inBoundedRange,
  isEnumMember,
  isNonEmptyString,
  isObject,
  itemContext,
  pythonRepr,
  pythonStr,
  scanProhibitedKeys,
  validateItems,
} from "./parallel-state-shared";
import {
  collectIssueNumbers,
  validateCohortShapes,
  validateConflictEdges,
  validateCurrentCohortBound,
  validateCurrentGenerationCohorts,
} from "./parallel-state-structures";

/** Literal context prefix for every error this module and its helpers emit. */
const CONTEXT = "Parallel planner checkpoint";

/** Inclusive lower bound on `max_concurrency` (invariant P2, assumption A7). */
const MIN_CONCURRENCY = 1;

/** Inclusive upper bound on `max_concurrency` (invariant P2, assumption A7). */
const MAX_CONCURRENCY = 32;

/**
 * Required top-level keys (invariant P1, schema S3). `kickoff_prompt_path` is
 * deliberately absent: it is optional outside the readiness gate, where
 * invariant P9 then pins its exact value.
 */
export const REQUIRED_KEYS: readonly string[] = [
  "objective",
  "parallel_slug",
  "parallel_manifest_path",
  "mode",
  "max_concurrency",
  "items",
  "cohorts",
  "conflict_edges",
  "recolor_generation",
  "completed_steps",
  "next_step",
  "last_updated",
];

/**
 * Required per-item keys (invariant P3, schema S3). The preparation fields have
 * no unconditional value constraint; the readiness gate pins them.
 */
export const REQUIRED_ITEM_KEYS: readonly string[] = [
  "issue_num",
  "feature_folder",
  "kind",
  "state",
  "blast_radius",
  "preparation_status",
  "research_path",
  "plan_path",
  "preflight_status",
];

/** Complexity bands accepted for the optional per-item `complexity_band`. */
export const VALID_COMPLEXITY_BANDS: readonly string[] = [
  "C1",
  "C2",
  "C3",
  "C4",
];

/** Readiness sentinel required of `next_step` (invariant P8). */
const READY_NEXT_STEP = "PARALLEL_EXECUTION_READY";

/** Per-item preparation value required by the readiness gate (invariant P7). */
const READY_PREPARATION_STATUS = "prepared";

/** Per-item preflight value required by the readiness gate (invariant P7). */
const READY_PREFLIGHT_STATUS = "PREFLIGHT: ALL CLEAR";

/**
 * Only the planner-computed radius is authoritative for scheduling, so the
 * readiness gate requires the declared source (invariant P7, design 5.2).
 */
const READY_RADIUS_SOURCE = "declared";

/** A parallel run needs at least two items to be worth scheduling (P6). */
const MINIMUM_READY_ITEMS = 2;

/** Per-item paths the readiness gate requires to name a produced artifact. */
const READY_ITEM_PATH_KEYS: readonly string[] = ["research_path", "plan_path"];

/** Options controlling parallel-planner-state validation. */
export interface ValidateParallelPlannerStateOptions {
  /** When true, enforce the structural readiness gate (invariants P6-P9). */
  readonly requireReadyForExecution?: boolean;
}

/**
 * Render the kickoff-prompt path invariant P9 pins for a slug (assumption A6).
 *
 * @param slug The checkpoint's `parallel_slug` value as deserialized.
 * @returns The conventional kickoff path; a non-string slug is interpolated with
 * Python `str` semantics so a missing slug renders as `None`.
 */
function kickoffPathFor(slug: unknown): string {
  return `artifacts/orchestration/parallel-kickoff-${pythonStr(slug)}.md`;
}

/**
 * Report every absent required top-level key (invariant P1).
 *
 * @param state The parsed checkpoint object.
 * @returns One error per missing key, in {@link REQUIRED_KEYS} order.
 */
function missingRequiredKeys(state: Record<string, unknown>): string[] {
  // Report every missing key rather than the first, so one validation pass tells
  // the planner the whole set of fields still to write.
  return REQUIRED_KEYS.filter((key) => !(key in state)).map(
    (key) => `${CONTEXT} missing required key: ${key}.`,
  );
}

/**
 * Validate run identity fields against invariant P2.
 *
 * Each check is presence-gated: an absent key has already produced its own
 * required-key error, and reporting a second error for the same omission would
 * overstate the number of defects.
 *
 * @param state The parsed checkpoint object.
 * @returns One error per violated identity condition.
 */
function validateIdentity(state: Record<string, unknown>): string[] {
  const errors: string[] = [];
  // The slug and the manifest path bind the checkpoint to one authored run;
  // either being blank makes the checkpoint unattributable.
  for (const key of ["parallel_slug", "parallel_manifest_path"]) {
    if (key in state && !isNonEmptyString(state[key])) {
      errors.push(`${CONTEXT} ${key} must be a non-empty string.`);
    }
  }

  const mode = state["mode"];
  if ("mode" in state && !isEnumMember(VALID_MODES, mode)) {
    errors.push(enumError(CONTEXT, "mode", VALID_MODES, mode));
  }

  const concurrency = state["max_concurrency"];
  if (
    "max_concurrency" in state &&
    !inBoundedRange(concurrency, MIN_CONCURRENCY, MAX_CONCURRENCY)
  ) {
    errors.push(
      `${CONTEXT} max_concurrency must be an integer from ${MIN_CONCURRENCY} through ${MAX_CONCURRENCY}; found: ${pythonRepr(concurrency)}.`,
    );
  }
  return errors;
}

/** One object-shaped `items[]` entry paired with its document position. */
interface IndexedItem {
  /** Zero-based position of the entry within `items`. */
  readonly index: number;
  /** The object-shaped entry itself. */
  readonly record: Record<string, unknown>;
}

/**
 * Pair each object-shaped `items[]` entry with its position.
 *
 * @param items The candidate `items` value as deserialized.
 * @returns One pair per object-shaped entry, in document order. A non-array
 * `items` yields an empty result; its shape error belongs to the shared item
 * validator.
 */
function itemRecords(items: unknown): IndexedItem[] {
  if (!Array.isArray(items)) {
    return [];
  }
  // Skip non-object entries: the shared item validator already reported their
  // shape, and no per-key check is meaningful without a mapping.
  const records: IndexedItem[] = [];
  items.forEach((entry: unknown, index: number) => {
    if (isObject(entry)) {
      records.push({ index, record: entry });
    }
  });
  return records;
}

/**
 * Validate the planner-specific per-item contract (invariant P3).
 *
 * Covers the required-key set and the optional `complexity_band` enum. The value
 * shapes shared with the other parallel surfaces are checked by
 * {@link validateItems} instead of being restated here.
 *
 * @param items The candidate `items` value as deserialized.
 * @returns Per-entry errors in positional order: missing required keys in
 * {@link REQUIRED_ITEM_KEYS} order, then the band error when present.
 */
function validateItemContract(items: unknown): string[] {
  const errors: string[] = [];
  // Check every entry so one pass reports the whole set of unprepared items.
  for (const { index, record } of itemRecords(items)) {
    const entryContext = itemContext(CONTEXT, index);
    for (const key of REQUIRED_ITEM_KEYS) {
      if (!(key in record)) {
        errors.push(`${entryContext} missing required key: ${key}.`);
      }
    }
    const band = record["complexity_band"];
    // The band is optional: absence is the backward-compatible shape, so the
    // enum check is presence-gated rather than requirement-gated.
    if (
      "complexity_band" in record &&
      !isEnumMember(VALID_COMPLEXITY_BANDS, band)
    ) {
      errors.push(
        enumError(
          entryContext,
          "complexity_band",
          VALID_COMPLEXITY_BANDS,
          band,
        ),
      );
    }
  }
  return errors;
}

/**
 * Delegate the planner collections to their helper validators.
 *
 * Covers invariant P3's shared item shape and invariant P4's cohort and
 * conflict-edge shapes (orchestrator invariants 12 through 15). The cohort
 * coloring itself is never recomputed here; that is spec P5, assigned to F4.
 *
 * @param state The parsed checkpoint object.
 * @returns The concatenated helper errors, in schema order.
 */
function validateCollections(state: Record<string, unknown>): string[] {
  const items = state["items"];
  const issueNums = collectIssueNumbers(items);
  const generation = state["recolor_generation"];
  const cohorts = state["cohorts"];

  const errors: string[] = [];
  // Each collection is gated on its own key so a missing required key costs
  // exactly one error, while a present but malformed value is fully checked.
  if ("items" in state) {
    errors.push(...validateItems(items, CONTEXT, true));
    errors.push(...validateItemContract(items));
  }
  if ("cohorts" in state) {
    errors.push(
      ...validateCohortShapes(cohorts, issueNums, generation, CONTEXT),
    );
    errors.push(
      ...validateCurrentGenerationCohorts(cohorts, items, generation, CONTEXT),
    );
  }
  // `current_cohort` is not part of schema S3, so the bound check runs only for
  // a planner checkpoint that chose to carry the orchestrator's pointer.
  if ("current_cohort" in state) {
    errors.push(
      ...validateCurrentCohortBound(
        state["current_cohort"],
        cohorts,
        generation,
        CONTEXT,
      ),
    );
  }
  if ("conflict_edges" in state) {
    errors.push(
      ...validateConflictEdges(state["conflict_edges"], issueNums, CONTEXT),
    );
  }
  return errors;
}

/**
 * Validate one item against the readiness gate (invariant P7).
 *
 * @param record One object-shaped `items[]` entry.
 * @param entryContext Item-scoped context prefix.
 * @returns One error per violated readiness condition, in field order:
 * preparation status, preflight status, the two artifact paths, then the
 * blast-radius source.
 */
function validateReadyItem(
  record: Record<string, unknown>,
  entryContext: string,
): string[] {
  const errors: string[] = [];
  const preparationStatus = record["preparation_status"];
  if (preparationStatus !== READY_PREPARATION_STATUS) {
    errors.push(
      `${entryContext} preparation_status must be ${pythonRepr(READY_PREPARATION_STATUS)}; found: ${pythonRepr(preparationStatus)}.`,
    );
  }

  const preflightStatus = record["preflight_status"];
  if (preflightStatus !== READY_PREFLIGHT_STATUS) {
    errors.push(
      `${entryContext} preflight_status must be ${pythonRepr(READY_PREFLIGHT_STATUS)}; found: ${pythonRepr(preflightStatus)}.`,
    );
  }

  // Both paths must name a produced artifact: an item with no research or no
  // plan has not been prepared, whatever its preparation_status claims.
  for (const key of READY_ITEM_PATH_KEYS) {
    if (!isNonEmptyString(record[key])) {
      errors.push(`${entryContext} ${key} must be a non-empty string.`);
    }
  }

  const radius = record["blast_radius"];
  const source = isObject(radius) ? radius["source"] : null;
  if (source !== READY_RADIUS_SOURCE) {
    errors.push(
      `${entryContext} blast_radius.source must be ${pythonRepr(READY_RADIUS_SOURCE)} for execution readiness; found: ${pythonRepr(source)}.`,
    );
  }
  return errors;
}

/**
 * Enforce the structural readiness gate (invariants P6 through P9).
 *
 * The gate is structural only. It checks cardinality, per-item preparation, the
 * sentinel, and the kickoff PATH; it never opens the kickoff document and never
 * consults a repository. Those checks belong to F4.
 *
 * @param state The parsed checkpoint object.
 * @returns The cardinality error, then per-item readiness errors in positional
 * order, then the sentinel error, then the kickoff-path error.
 */
function validateReadyGate(state: Record<string, unknown>): string[] {
  const errors: string[] = [];
  const items = state["items"];
  // A non-array `items` already reported its shape, so the gate adds nothing for
  // it; an array is measured against the two-item minimum.
  if (Array.isArray(items)) {
    const count = items.length;
    if (count < MINIMUM_READY_ITEMS) {
      errors.push(
        `${CONTEXT} requires at least ${MINIMUM_READY_ITEMS} items for execution readiness; found: ${count}.`,
      );
    }
    for (const { index, record } of itemRecords(items)) {
      errors.push(...validateReadyItem(record, itemContext(CONTEXT, index)));
    }
  }

  const nextStep = state["next_step"];
  if (nextStep !== READY_NEXT_STEP) {
    errors.push(
      `${CONTEXT} next_step must be ${pythonRepr(READY_NEXT_STEP)}; found: ${pythonRepr(nextStep)}.`,
    );
  }

  const expectedKickoff = kickoffPathFor(state["parallel_slug"]);
  const kickoffPromptPath = state["kickoff_prompt_path"];
  if (kickoffPromptPath !== expectedKickoff) {
    errors.push(
      `${CONTEXT} kickoff_prompt_path must be ${pythonRepr(expectedKickoff)}; found: ${pythonRepr(kickoffPromptPath)}.`,
    );
  }
  return errors;
}

/**
 * Validate a parallel-planner checkpoint document.
 *
 * @param text Raw checkpoint JSON text.
 * @param options When `requireReadyForExecution` is true, additionally enforce
 * the structural readiness gate (invariants P6 through P9). When false the gate
 * contributes no errors, so a checkpoint written mid-preparation validates.
 * @returns Validation errors for a malformed or unready checkpoint; an empty
 * array when the checkpoint is valid. Invalid JSON and a non-object root each
 * return a single-element array, because no field check is meaningful without a
 * parsed object.
 */
export function validateParallelPlannerStateText(
  text: string,
  options: ValidateParallelPlannerStateOptions = {},
): string[] {
  let state: unknown;
  try {
    state = JSON.parse(text);
  } catch (error) {
    const detail = error instanceof Error ? error.message : String(error);
    return [`${CONTEXT} is not valid JSON: ${detail}.`];
  }

  if (!isObject(state)) {
    return [`${CONTEXT} root must be a JSON object.`];
  }

  const errors: string[] = [];
  errors.push(...missingRequiredKeys(state));
  errors.push(...validateIdentity(state));
  errors.push(...scanProhibitedKeys(state, CONTEXT));
  errors.push(...validateCollections(state));

  if (options.requireReadyForExecution === true) {
    errors.push(...validateReadyGate(state));
  }
  return errors;
}
