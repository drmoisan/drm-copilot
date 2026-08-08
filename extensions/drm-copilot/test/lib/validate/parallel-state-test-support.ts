/**
 * In-memory checkpoint fixtures for the parallel-state validator tests.
 *
 * This module is deliberately NOT a `.test.ts` file: the `testMatch` glob in
 * `jest.config.cjs` collects only files whose name ends in `.test.ts`, so this
 * file adds no Jest suite. It mirrors the
 * `epic-planner-launch-evidence-test-support.ts` convention and the Python
 * side's shared `build_valid_parallel_state()` builder in
 * `tests/scripts/dev_tools/test_validate_parallel_orchestrator_state.py`, so
 * both language ports start every case from the same minimally valid payload.
 */

import { validateParallelOrchestratorStateText } from "../../../src/lib/validate/parallel-orchestrator-state-core";

/** A deserialized JSON object, the shape every fixture helper works with. */
export type JsonRecord = Record<string, unknown>;

/** Type guard narrowing an unknown fixture value to a plain object. */
function isRecord(value: unknown): value is JsonRecord {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Return a minimally valid, planner-declared blast-radius block.
 *
 * @returns A fresh `blast_radius` object that satisfies invariant 9.
 */
export function buildBlastRadius(): JsonRecord {
  return {
    paths: ["scripts/dev_tools/**"],
    modules: ["scripts"],
    shared_surfaces: [],
    contracts: [],
    source: "declared",
    computed_at: "2026-08-07T10-00",
  };
}

/**
 * Return a minimally valid parallel-orchestrator checkpoint payload.
 *
 * Two scheduled items sit in one current-generation cohort with empty edge,
 * mutation, and drift logs, so a test can mutate one field and attribute any
 * resulting error to that mutation.
 *
 * @returns A fresh checkpoint object that validates with zero errors.
 */
export function buildValidParallelState(): JsonRecord {
  return {
    objective: "deliver parallel-schema-validators-444",
    completed_steps: ["manifest_parsed"],
    next_step: "cohort_0_launch",
    last_updated: "2026-08-07T10-00",
    route_id: "parallel",
    parallel_slug: "wave-one",
    parallel_manifest_path: "docs/features/parallel/wave-one/parallel.md",
    parallel_status_doc_path:
      "docs/features/parallel/wave-one/parallel-status.md",
    mode: "closed",
    max_concurrency: 4,
    current_cohort: 0,
    recolor_generation: 0,
    cohorts: [{ index: 0, generation: 0, item_keys: [444, 445] }],
    items: [
      {
        issue_num: 444,
        feature_folder: "2026-08-07-parallel-schema-validators-444",
        state: "scheduled",
        blast_radius: buildBlastRadius(),
      },
      {
        issue_num: 445,
        feature_folder: "2026-08-07-parallel-cohort-scheduler-445",
        state: "scheduled",
        blast_radius: buildBlastRadius(),
      },
    ],
    conflict_edges: [],
    mutations: [],
    drift_events: [],
  };
}

/**
 * Read one object-shaped entry out of a builder-produced collection.
 *
 * @param state A builder-produced checkpoint.
 * @param key The collection key, for example `items` or `cohorts`.
 * @param index Zero-based position within that collection.
 * @returns The entry as a mutable record.
 * @throws Error when the fixture does not hold an object at that position,
 * which means the test mutated the fixture into an unusable shape.
 */
function entryAt(state: JsonRecord, key: string, index: number): JsonRecord {
  const collection = state[key];
  if (!Array.isArray(collection)) {
    throw new Error(`fixture ${key} is not an array`);
  }
  const entry: unknown = collection[index];
  if (!isRecord(entry)) {
    throw new Error(`fixture ${key}[${index}] is not an object`);
  }
  return entry;
}

/**
 * Return one `items[]` entry of a builder-produced checkpoint.
 *
 * @param state A builder-produced checkpoint.
 * @param index Zero-based position within `items`.
 * @returns The item record, mutable in place by the caller.
 */
export function itemAt(state: JsonRecord, index: number): JsonRecord {
  return entryAt(state, "items", index);
}

/**
 * Return one `cohorts[]` entry of a builder-produced checkpoint.
 *
 * @param state A builder-produced checkpoint.
 * @param index Zero-based position within `cohorts`.
 * @returns The cohort record, mutable in place by the caller.
 */
export function cohortAt(state: JsonRecord, index: number): JsonRecord {
  return entryAt(state, "cohorts", index);
}

/**
 * Return one item's `blast_radius` block of a builder-produced checkpoint.
 *
 * @param state A builder-produced checkpoint.
 * @param index Zero-based position within `items`.
 * @returns The radius record, mutable in place by the caller.
 * @throws Error when that item's radius is not an object.
 */
export function radiusOf(state: JsonRecord, index: number): JsonRecord {
  const radius = itemAt(state, index)["blast_radius"];
  if (!isRecord(radius)) {
    throw new Error(`fixture items[${index}].blast_radius is not an object`);
  }
  return radius;
}

/**
 * Serialize a checkpoint object and return the validator's error array.
 *
 * @param state The checkpoint payload to validate.
 * @param requireComplete When true, run the mode-dependent completion gate.
 * @returns The validator's error strings.
 */
export function validateState(
  state: JsonRecord,
  requireComplete = false,
): string[] {
  return validateParallelOrchestratorStateText(JSON.stringify(state), {
    requireComplete,
  });
}
