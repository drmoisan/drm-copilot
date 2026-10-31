/**
 * Validator tolerance for the scheduling layer's extra fields (issue #722).
 *
 * The integration-cost scheduling layer records three tolerated-not-validated
 * fields on each conflict edge (`hard`, `cost`, `benefit`) and a
 * `tolerated_overlaps` list on the planner and orchestrator checkpoints. No
 * validator reads them, so a checkpoint carrying them must validate with zero
 * errors, while the four-member edge reason enum stays enforced. These cases
 * mirror `tests/scripts/dev_tools/test_validate_parallel_state_tolerated_edge_fields.py`
 * and assert the byte-identical error literal the Python validator emits.
 */

import { validateParallelPlannerStateText } from "../../../src/lib/validate/parallel-planner-state-core";
import {
  buildBlastRadius,
  buildPlannerRoutingFields,
  buildValidParallelState,
  itemAt,
  validateState,
  type JsonRecord,
} from "./parallel-state-test-support";

/** An edge in the shape the scheduling layer records, extra fields included. */
const SCHEDULED_EDGE: JsonRecord = {
  a: 444,
  b: 445,
  reason: "path_overlap",
  hard: false,
  cost: 8,
  benefit: 2,
};

/** A tolerated overlap in the shape the scheduling layer records. */
const TOLERATED_OVERLAP: JsonRecord = {
  a: 444,
  b: 445,
  reasons: ["path_overlap", "module_overlap"],
  cost: 1,
  benefit: 2,
};

/** The observed_resolution telemetry object (issue #1013, spec D-3). */
const OBSERVED_RESOLUTION: JsonRecord = {
  later_item: 445,
  conflicted: true,
  conflict_detected_at: "2026-10-30T12-00",
  resolved_at: "2026-10-30T12-40",
  resolution_minutes: 40,
  recorded_at: "2026-10-30T12-41",
};

/** A combination record in the planner's combinations list (issue #1013, D-5). */
const COMBINATION: JsonRecord = {
  members: [444, 990],
  primary: 444,
  pairs: [{ a: 444, b: 990, cost: 16, benefit: 2 }],
  estimated_savings: 16,
};

/**
 * Return a valid orchestrator checkpoint whose edge list is replaced.
 *
 * The two builder items are split into distinct current-generation cohorts,
 * because an edge between two items of one cohort is a cohort-barrier violation
 * that would otherwise be reported alongside the condition under test.
 *
 * @param edges The replacement `conflict_edges` value.
 * @returns A fresh checkpoint object.
 */
function orchestratorStateWithEdges(edges: unknown): JsonRecord {
  const state = buildValidParallelState();
  state["cohorts"] = [
    { index: 0, generation: 0, item_keys: [444] },
    { index: 1, generation: 0, item_keys: [445] },
  ];
  state["conflict_edges"] = edges;
  return state;
}

/**
 * Return one fully prepared, preflight-cleared planner item.
 *
 * @param issueNum The item's issue number.
 * @param slug The feature slug used to build the item's paths.
 * @returns A fresh planner item record.
 */
function buildPlannerItem(issueNum: number, slug: string): JsonRecord {
  return {
    issue_num: issueNum,
    feature_folder: `2026-08-07-${slug}-${String(issueNum)}`,
    kind: "feature",
    state: "prepared",
    blast_radius: buildBlastRadius(),
    preparation_status: "prepared",
    research_path: `docs/features/active/${slug}/research.md`,
    plan_path: `docs/features/active/${slug}/plan.md`,
    preflight_status: "PREFLIGHT: ALL CLEAR",
    ...buildPlannerRoutingFields(),
  };
}

/**
 * Return a minimally valid, execution-ready planner checkpoint payload.
 *
 * @returns A fresh planner checkpoint that validates with zero errors with and
 *   without the readiness gate.
 */
function buildValidPlannerState(): JsonRecord {
  return {
    objective: "prepare parallel run wave-one",
    parallel_slug: "wave-one",
    parallel_manifest_path: "docs/features/parallel/wave-one/parallel.md",
    mode: "closed",
    max_concurrency: 4,
    items: [
      buildPlannerItem(444, "parallel-schema-validators"),
      buildPlannerItem(445, "parallel-cohort-scheduler"),
    ],
    cohorts: [
      { index: 0, generation: 0, item_keys: [444] },
      { index: 1, generation: 0, item_keys: [445] },
    ],
    conflict_edges: [],
    recolor_generation: 0,
    completed_steps: ["manifest_parsed"],
    next_step: "PARALLEL_EXECUTION_READY",
    last_updated: "2026-08-07T10-00",
    kickoff_prompt_path: "artifacts/orchestration/parallel-kickoff-wave-one.md",
  };
}

/**
 * Validate a planner checkpoint object.
 *
 * @param state The planner checkpoint payload.
 * @param ready When true, also enforce the readiness gate.
 * @returns The validator's error strings.
 */
function validatePlanner(state: JsonRecord, ready: boolean): string[] {
  return validateParallelPlannerStateText(JSON.stringify(state), {
    requireReadyForExecution: ready,
  });
}

describe("issue #722: tolerated scheduling fields", () => {
  it("accepts an orchestrator edge carrying hard, cost, and benefit", () => {
    // Arrange
    const state = orchestratorStateWithEdges([{ ...SCHEDULED_EDGE }]);

    // Act
    const errors = validateState(state);

    // Assert
    expect(errors).toEqual([]);
  });

  it("accepts a planner edge carrying hard, cost, and benefit", () => {
    // Arrange
    const state = buildValidPlannerState();
    state["conflict_edges"] = [{ ...SCHEDULED_EDGE, hard: true }];

    // Act
    const plainErrors = validatePlanner(state, false);
    const readyErrors = validatePlanner(state, true);

    // Assert
    expect(plainErrors).toEqual([]);
    expect(readyErrors).toEqual([]);
  });

  it("accepts an orchestrator checkpoint carrying tolerated_overlaps", () => {
    // Arrange
    const state = buildValidParallelState();
    state["tolerated_overlaps"] = [{ ...TOLERATED_OVERLAP }];

    // Act
    const errors = validateState(state);

    // Assert
    expect(errors).toEqual([]);
  });

  it("accepts a planner checkpoint carrying tolerated_overlaps", () => {
    // Arrange
    const state = buildValidPlannerState();
    state["tolerated_overlaps"] = [{ ...TOLERATED_OVERLAP }];

    // Act
    const plainErrors = validatePlanner(state, false);
    const readyErrors = validatePlanner(state, true);

    // Assert
    expect(plainErrors).toEqual([]);
    expect(readyErrors).toEqual([]);
  });

  it("accepts a tolerated overlap carrying observed_resolution (issue #1013)", () => {
    // Arrange: the D-3 telemetry object on an orchestrator tolerated overlap.
    const state = buildValidParallelState();
    state["tolerated_overlaps"] = [
      { ...TOLERATED_OVERLAP, observed_resolution: { ...OBSERVED_RESOLUTION } },
    ];

    // Act
    const errors = validateState(state);

    // Assert
    expect(errors).toEqual([]);
  });

  it("accepts an orchestrator item carrying combined_issue_nums (issue #1013)", () => {
    // Arrange
    const state = buildValidParallelState();
    itemAt(state, 0)["combined_issue_nums"] = [990];

    // Act
    const errors = validateState(state);

    // Assert
    expect(errors).toEqual([]);
  });

  it("accepts a planner combined item and a combinations list (issue #1013)", () => {
    // Arrange
    const state = buildValidPlannerState();
    state["items"] = [
      { ...buildPlannerItem(444, "parallel-schema-validators"), combined_issue_nums: [990] },
      buildPlannerItem(445, "parallel-cohort-scheduler"),
    ];
    state["combinations"] = [{ ...COMBINATION }];

    // Act
    const plainErrors = validatePlanner(state, false);
    const readyErrors = validatePlanner(state, true);

    // Assert
    expect(plainErrors).toEqual([]);
    expect(readyErrors).toEqual([]);
  });

  it("still rejects an edge reason outside the four-member enum", () => {
    // Arrange: extra fields must not relax the reason enum.
    const state = orchestratorStateWithEdges([
      { ...SCHEDULED_EDGE, reason: "same_file" },
    ]);
    state["tolerated_overlaps"] = [{ ...TOLERATED_OVERLAP }];

    // Act
    const errors = validateState(state);

    // Assert: exactly the existing reason-enum error is reported.
    expect(errors).toEqual([
      "Parallel checkpoint conflict_edges[0] reason must be one of " +
        "path_overlap, module_overlap, shared_surface_overlap, " +
        "contract_dependency; found: 'same_file'.",
    ]);
  });
});
