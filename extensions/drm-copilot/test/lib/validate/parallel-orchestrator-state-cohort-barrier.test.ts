import { describe, expect, it } from "@jest/globals";

import { validateArtifact } from "../../../src/lib/validate/orchestration-artifacts";
import {
  buildBlastRadius,
  buildValidParallelState,
} from "./parallel-state-test-support";

import type { JsonRecord } from "./parallel-state-test-support";

/**
 * Behavior suite for the Layer 2 cohort-barrier ordering invariant.
 *
 * Purpose:
 *     Cover the behavior classes that are properties of the invariant rather than
 *     rows of the shared corpus: the byte-exact message form, key-gated backward
 *     compatibility, run-time reachability of the F7 seam, the absence of false
 *     positives on the minimally valid checkpoint, and independence from the
 *     completion gate. The per-document truth table lives in the committed corpus
 *     under `tests/fixtures/parallel_cohort_barrier/`, asserted by
 *     `parallel-cohort-barrier-parity.test.ts` here and by
 *     `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` on the
 *     Python side; this file deliberately does not duplicate that table.
 *
 * Binding discipline:
 *     Every case routes through the dispatched public entry point
 *     `validateArtifact({ artifactType: "parallel-orchestrator-state", text })`
 *     and this module imports the invariant module nowhere -- not even by name,
 *     so the negative search that proves the discipline stays clean. Exercising
 *     the dispatched entry point is what makes the seam edit in
 *     `parallel-orchestrator-state-core.ts` load-bearing on every run: a suite
 *     that imported the invariant directly would pass with an empty seam, which
 *     is precisely the defect this remediation cycle exists to close.
 *
 * Determinism:
 *     Every document is built in memory and serialized with `JSON.stringify`. No
 *     file is read or written, no process is started, and no clock, timer, or
 *     randomness is used.
 */

/**
 * Byte-exact expected message, restated inline from design section 9 rather than
 * read from the implementation's own constant. The form carries no
 * `Parallel checkpoint` context prefix and no trailing period, unlike every other
 * error this validator family emits.
 */
const EXPECTED_SAME_COHORT_MESSAGE =
  "PARALLEL_COHORT_BARRIER_VIOLATION: 444 ran concurrently with conflicting 445";

/** Literal violation token used to isolate barrier messages from shape errors. */
const VIOLATION_LABEL = "PARALLEL_COHORT_BARRIER_VIOLATION";

/** F3 required-key error the key-gating case expects to see instead. */
const MISSING_COHORTS_ERROR =
  "Parallel checkpoint missing required key: cohorts.";

/**
 * Build one `items[]` entry carrying only F3-defined fields.
 *
 * @param issueNum The item primary key.
 * @param state The item lifecycle state.
 * @param mergeStatus The merge status, omitted entirely when undefined so the
 * absent-reads-as-not_started rule is exercised rather than bypassed.
 * @returns A fresh item record.
 */
function buildItem(
  issueNum: number,
  state: string,
  mergeStatus?: string,
): JsonRecord {
  const record: JsonRecord = {
    issue_num: issueNum,
    feature_folder: `2026-08-07-parallel-item-${String(issueNum)}`,
    state,
    blast_radius: buildBlastRadius(),
  };
  if (mergeStatus !== undefined) {
    record["merge_status"] = mergeStatus;
  }
  return record;
}

/**
 * Build a checkpoint satisfying F3's required-key set around the given data.
 *
 * @param items The `items[]` collection.
 * @param cohorts The `cohorts[]` collection.
 * @param edges The `conflict_edges[]` collection.
 * @param currentCohort The `current_cohort` counter.
 * @returns A fresh checkpoint object.
 */
function buildState(
  items: readonly JsonRecord[],
  cohorts: readonly JsonRecord[],
  edges: readonly JsonRecord[],
  currentCohort = 0,
): JsonRecord {
  return {
    objective: "deliver parallel-enforcement-hooks-440",
    completed_steps: ["manifest_parsed"],
    next_step: "cohort_0_launch",
    last_updated: "2026-08-08T10-00",
    route_id: "parallel",
    parallel_slug: "wave-four",
    parallel_manifest_path: "docs/features/parallel/wave-four/parallel.md",
    parallel_status_doc_path:
      "docs/features/parallel/wave-four/parallel-status.md",
    mode: "closed",
    max_concurrency: 4,
    current_cohort: currentCohort,
    recolor_generation: 0,
    cohorts: [...cohorts],
    items: [...items],
    conflict_edges: [...edges],
    mutations: [],
    drift_events: [],
  };
}

/**
 * Build the same-cohort conflicting pair of items 444 and 445.
 *
 * @returns A checkpoint whose single conflict edge joins two items sharing one
 * current-generation cohort index, which is a structural barrier violation.
 */
function buildSameCohortState(): JsonRecord {
  return buildState(
    [buildItem(444, "scheduled"), buildItem(445, "scheduled")],
    [{ index: 0, generation: 0, item_keys: [444, 445] }],
    [{ a: 444, b: 445, reason: "path_overlap" }],
  );
}

/**
 * Build a two-row coloring whose second row carries the given cohort index.
 *
 * The two documents this produces are byte-identical apart from that one value,
 * so a decision that flips between them can only have come from the coloring
 * being read at run time.
 *
 * @param secondRowIndex The `index` of the cohort row holding item 445.
 * @returns A checkpoint carrying one conflict edge between 444 and 445.
 */
function buildColoringVariant(secondRowIndex: number): JsonRecord {
  return buildState(
    [
      buildItem(444, "merged", "merged"),
      buildItem(445, "in_flight", "pr_open"),
    ],
    [
      { index: 0, generation: 0, item_keys: [444] },
      { index: secondRowIndex, generation: 0, item_keys: [445] },
    ],
    [{ a: 444, b: 445, reason: "path_overlap" }],
    secondRowIndex,
  );
}

/**
 * Submit a checkpoint through the dispatched public entry point.
 *
 * @param state The checkpoint payload.
 * @param requireComplete When provided, threaded into the dispatcher; when
 * omitted, the dispatcher's own default applies.
 * @returns The dispatcher's full error array.
 */
function dispatch(state: JsonRecord, requireComplete?: boolean): string[] {
  const text = JSON.stringify(state);
  if (requireComplete === undefined) {
    return validateArtifact({
      artifactType: "parallel-orchestrator-state",
      text,
    });
  }
  return validateArtifact({
    artifactType: "parallel-orchestrator-state",
    text,
    requireComplete,
  });
}

/**
 * Filter a dispatcher result down to the barrier messages alone.
 *
 * @param errors The dispatcher's full error array.
 * @returns Only the entries beginning with the violation token.
 */
function barrierOnly(errors: readonly string[]): string[] {
  return errors.filter((error) => error.startsWith(VIOLATION_LABEL));
}

describe("cohort-barrier invariant behavior through the dispatched validator", () => {
  it("emits the byte-exact message form for a same-cohort conflicting pair", () => {
    // Arrange
    const state = buildSameCohortState();

    // Act
    const errors = dispatch(state);

    // Assert: the whole error list is the single barrier message, so the absence
    // of a context prefix and of a trailing period is asserted, not assumed.
    expect(errors).toEqual([EXPECTED_SAME_COHORT_MESSAGE]);
  });

  it("stays silent and reports the missing key when cohorts is absent", () => {
    // Arrange: a document that would otherwise violate structurally.
    const state = buildSameCohortState();
    delete state["cohorts"];

    // Act
    const errors = dispatch(state);

    // Assert: the invariant is key-gated, so an older checkpoint shape earns the
    // F3 required-key error and no barrier message at all.
    expect(errors).toContain(MISSING_COHORTS_ERROR);
    expect(barrierOnly(errors)).toEqual([]);
  });

  it("flips its decision when only the second cohort row index changes", () => {
    // Arrange: two documents identical apart from one cohort index value.
    const shared = buildColoringVariant(0);
    const split = buildColoringVariant(1);

    // Act
    const sharedErrors = barrierOnly(dispatch(shared));
    const splitErrors = barrierOnly(dispatch(split));

    // Assert: the flip cannot occur unless the seam call is genuinely reached at
    // run time, so this case fails if the seam is emptied.
    expect(sharedErrors).toEqual([EXPECTED_SAME_COHORT_MESSAGE]);
    expect(splitErrors).toEqual([]);
  });

  it("leaves the minimally valid checkpoint validating with zero errors", () => {
    // Arrange: the shared fixture every parallel suite starts from.
    const state = buildValidParallelState();

    // Act
    const errors = dispatch(state);

    // Assert: filling the seam introduces no false positive on the baseline
    // payload, whose conflict_edges collection is empty.
    expect(errors).toEqual([]);
  });

  it("applies the invariant unconditionally of the completion gate", () => {
    // Arrange
    const state = buildSameCohortState();

    // Act: once with the flag absent and once with it explicitly false.
    const withoutFlag = barrierOnly(dispatch(state));
    const withFalseFlag = barrierOnly(dispatch(state, false));

    // Assert: the invariant is not gated on requireComplete, so both calls
    // produce the same single barrier message.
    expect(withoutFlag).toEqual([EXPECTED_SAME_COHORT_MESSAGE]);
    expect(withFalseFlag).toEqual([EXPECTED_SAME_COHORT_MESSAGE]);
  });
});
