/**
 * Tests for the parallel-planner checkpoint validator, invariants P1 to P9.
 *
 * Covers the unconditional structural invariants P1 through P4 and the
 * structural readiness gate P6 through P9, including the
 * `PARALLEL_EXECUTION_READY` sentinel and the kickoff-PATH convention.
 * Delegation to the shared helper modules is asserted with one representative
 * error per helper; the helpers' exhaustive per-branch behavior is covered by
 * the orchestrator-checkpoint test files. The deliberate omission recorded as
 * spec P5 is asserted as an absence. Every expected string is the
 * byte-identical literal emitted by
 * `scripts/dev_tools/validate_parallel_planner_state.py`.
 */

import {
  REQUIRED_ITEM_KEYS,
  REQUIRED_KEYS,
  VALID_COMPLEXITY_BANDS,
  validateParallelPlannerStateText,
} from "../../../src/lib/validate/parallel-planner-state-core";
import { VALID_MODES } from "../../../src/lib/validate/parallel-state-shared";
import {
  buildBlastRadius,
  cohortAt,
  itemAt,
  radiusOf,
  type JsonRecord,
} from "./parallel-state-test-support";

const CONTEXT = "Parallel planner checkpoint";

/** The kickoff path invariant P9 pins for the builder's slug (assumption A6). */
const EXPECTED_KICKOFF = "docs/features/parallel/wave-one/parallel-kickoff.md";

/** Error-string prefix for the second builder item, which the gate cases mutate. */
const ITEM1 = `${CONTEXT} items[1]`;

/** Return one fully prepared, preflight-cleared planner item. */
function buildItem(issueNum: number, slug: string): JsonRecord {
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
  };
}

/**
 * Return a minimally valid, execution-ready planner checkpoint payload. Two
 * prepared items sit in one current-generation cohort with no conflict edges, so
 * a test can mutate one field and attribute any resulting error to it. The
 * payload also satisfies the readiness gate, so one builder serves both the
 * gate-off and gate-on cases.
 */
function buildValidPlannerState(): JsonRecord {
  return {
    objective: "prepare parallel run wave-one",
    parallel_slug: "wave-one",
    parallel_manifest_path: "docs/features/parallel/wave-one/parallel.md",
    mode: "closed",
    max_concurrency: 4,
    items: [
      buildItem(444, "parallel-schema-validators"),
      buildItem(445, "parallel-cohort-scheduler"),
    ],
    cohorts: [{ index: 0, generation: 0, item_keys: [444, 445] }],
    conflict_edges: [],
    recolor_generation: 0,
    completed_steps: ["manifest_parsed"],
    next_step: "PARALLEL_EXECUTION_READY",
    last_updated: "2026-08-07T10-00",
    kickoff_prompt_path: EXPECTED_KICKOFF,
  };
}

/** Serialize a checkpoint object and return the validator's error array. */
function validate(state: JsonRecord, ready = false): string[] {
  return validateParallelPlannerStateText(JSON.stringify(state), {
    requireReadyForExecution: ready,
  });
}

describe("parallel planner checkpoint root handling", () => {
  it("returns no errors for a valid checkpoint with the gate false", () => {
    expect(validate(buildValidPlannerState())).toEqual([]);
  });

  it("requires external Codex evidence with the gate true", () => {
    expect(validate(buildValidPlannerState(), true)).toEqual([
      `${CONTEXT} Codex readiness evidence is required.`,
    ]);
  });

  it("does not mutate its input", () => {
    const state = buildValidPlannerState();
    const snapshot = JSON.stringify(state);

    validateParallelPlannerStateText(JSON.stringify(state));

    expect(JSON.stringify(state)).toBe(snapshot);
  });

  it("returns a single prefixed error for unparseable text", () => {
    const errors = validateParallelPlannerStateText("{not json");

    expect(errors).toHaveLength(1);
    expect(errors[0]).toMatch(
      /^Parallel planner checkpoint is not valid JSON: /,
    );
  });

  it("rejects a JSON array root with one shape error", () => {
    expect(validateParallelPlannerStateText("[]")).toEqual([
      `${CONTEXT} root must be a JSON object.`,
    ]);
  });
});

describe("invariant P1 required top-level keys", () => {
  it.each(REQUIRED_KEYS)("reports the missing key %s", (key) => {
    const state = buildValidPlannerState();
    delete state[key];

    expect(validate(state)).toContain(
      `${CONTEXT} missing required key: ${key}.`,
    );
  });

  it("reports exactly one error per required key for an empty object", () => {
    expect(validateParallelPlannerStateText("{}")).toHaveLength(
      REQUIRED_KEYS.length,
    );
  });

  it("treats kickoff_prompt_path and complexity_band as optional off the gate", () => {
    const state = buildValidPlannerState();
    delete state["kickoff_prompt_path"];

    expect("complexity_band" in itemAt(state, 0)).toBe(false);
    expect(validate(state)).toEqual([]);
  });
});

describe("invariant P2 run identity", () => {
  it.each([
    ["parallel_slug", ""],
    ["parallel_slug", "   "],
    ["parallel_slug", 5],
    ["parallel_slug", null],
    ["parallel_manifest_path", ""],
    ["parallel_manifest_path", "   "],
    ["parallel_manifest_path", 5],
    ["parallel_manifest_path", null],
  ])("rejects a blank %s of %p", (key, value) => {
    const state = buildValidPlannerState();
    state[key] = value;

    expect(validate(state)).toContain(
      `${CONTEXT} ${key} must be a non-empty string.`,
    );
  });

  it.each(VALID_MODES)("accepts mode %s", (mode) => {
    const state = buildValidPlannerState();
    state["mode"] = mode;

    expect(validate(state)).toEqual([]);
  });

  it("rejects an out-of-enum mode with the shared enum error", () => {
    const state = buildValidPlannerState();
    state["mode"] = "ajar";

    expect(validate(state)).toContain(
      `${CONTEXT} mode must be one of closed, open; found: 'ajar'.`,
    );
  });

  // The accept direction had no case before the 1..32 widening, so a raised
  // ceiling could not have been detected from the planner core suite alone.
  it.each([1, 4, 32])("accepts in-range concurrency %p", (concurrency) => {
    const state = buildValidPlannerState();
    state["max_concurrency"] = concurrency;

    expect(validate(state)).toEqual([]);
  });

  it.each([
    [0, "0"],
    [-1, "-1"],
    [33, "33"],
    ["4", "'4'"],
    [1.5, "1.5"],
    [true, "True"],
    [null, "None"],
  ])("rejects out-of-bound concurrency %p", (concurrency, rendered) => {
    const state = buildValidPlannerState();
    state["max_concurrency"] = concurrency;

    expect(validate(state)).toContain(
      `${CONTEXT} max_concurrency must be an integer from 1 through 32; found: ${String(rendered)}.`,
    );
  });
});

describe("invariant P3 per-item contract", () => {
  it.each(REQUIRED_ITEM_KEYS)("reports the missing item key %s", (key) => {
    const state = buildValidPlannerState();
    delete itemAt(state, 0)[key];

    expect(validate(state)).toContain(
      `${CONTEXT} items[0] missing required key: ${key}.`,
    );
  });

  it("rejects two items sharing the primary key", () => {
    const state = buildValidPlannerState();
    itemAt(state, 1)["issue_num"] = 444;
    cohortAt(state, 0)["item_keys"] = [444];

    expect(validate(state)).toContain(
      `${CONTEXT} has duplicate items[].issue_num: 444.`,
    );
  });

  it("requires the S4 kind enum on every planner item", () => {
    const state = buildValidPlannerState();
    itemAt(state, 0)["kind"] = "chore";

    expect(validate(state)).toContain(
      `${CONTEXT} items[0] kind must be one of feature, bug; found: 'chore'.`,
    );
  });

  it("rejects a non-object blast radius with one shape error", () => {
    const state = buildValidPlannerState();
    itemAt(state, 0)["blast_radius"] = ["scripts/**"];

    expect(validate(state)).toContain(
      `${CONTEXT} items[0] blast_radius must be an object.`,
    );
  });

  it.each(VALID_COMPLEXITY_BANDS)("accepts complexity band %s", (band) => {
    const state = buildValidPlannerState();
    itemAt(state, 0)["complexity_band"] = band;

    expect(validate(state)).toEqual([]);
  });

  it("rejects a complexity band outside C1..C4", () => {
    const state = buildValidPlannerState();
    itemAt(state, 0)["complexity_band"] = "C9";

    expect(validate(state)).toContain(
      `${CONTEXT} items[0] complexity_band must be one of C1, C2, C3, C4; found: 'C9'.`,
    );
  });

  it("reports one shape error and no gate item errors for non-list items", () => {
    const state = buildValidPlannerState();
    state["items"] = { "444": {} };

    expect(validate(state, true)).toContain(`${CONTEXT} items must be a list.`);
  });

  it.each(["depends_on", "integration_branch", "epic_merge_pr"])(
    "rejects prohibited top-level key %s",
    (key) => {
      const state = buildValidPlannerState();
      state[key] = "value";

      expect(validate(state)).toContain(
        `${CONTEXT} carries prohibited key '${key}' at <root>.`,
      );
    },
  );

  it("rejects a per-item dependency declaration with its path", () => {
    const state = buildValidPlannerState();
    itemAt(state, 1)["depends_on"] = [444];

    expect(validate(state)).toContain(
      `${CONTEXT} carries prohibited key 'depends_on' at items[1].`,
    );
  });
});

describe("invariants P4-P5 delegated collection checks", () => {
  it("requires exactly one current-generation cohort per item", () => {
    const state = buildValidPlannerState();
    cohortAt(state, 0)["item_keys"] = [444];

    expect(validate(state)).toContain(
      `${CONTEXT} item 445 in state 'prepared' must appear in exactly one current-generation cohort; found 0.`,
    );
  });

  it("rejects a negative recolor_generation", () => {
    const state = buildValidPlannerState();
    state["recolor_generation"] = -1;

    expect(validate(state)).toContain(
      `${CONTEXT} recolor_generation must be a non-negative integer; found: -1.`,
    );
  });

  it("rejects an unnormalized conflict edge", () => {
    const state = buildValidPlannerState();
    state["conflict_edges"] = [{ a: 445, b: 444, reason: "path_overlap" }];

    expect(validate(state)).toContain(
      `${CONTEXT} conflict_edges[0] must be normalized with a < b; found: (445, 444).`,
    );
  });

  it("bounds an optional current_cohort pointer by the coloring", () => {
    const state = buildValidPlannerState();
    state["current_cohort"] = 3;

    expect(validate(state)).toContain(
      `${CONTEXT} current_cohort 3 must not exceed the maximum current-generation cohorts[].index 0.`,
    );
  });

  it("does not recompute the coloring (spec P5, F4 owns parity)", () => {
    const state = buildValidPlannerState();
    state["cohorts"] = [
      { index: 0, generation: 0, item_keys: [444] },
      { index: 1, generation: 0, item_keys: [445] },
    ];

    expect(validate(state)).toEqual([]);
  });
});

describe("invariants P6-P9 structural readiness gate", () => {
  it("requires at least two items", () => {
    const state = buildValidPlannerState();
    state["items"] = [buildItem(444, "parallel-schema-validators")];
    cohortAt(state, 0)["item_keys"] = [444];

    expect(validate(state, true)).toEqual([
      `${CONTEXT} requires at least 2 items for execution readiness; found: 1.`,
      `${CONTEXT} Codex readiness evidence is required.`,
    ]);
  });

  it.each([
    [
      "preparation_status",
      "in_progress",
      `${ITEM1} preparation_status must be 'prepared'; found: 'in_progress'.`,
    ],
    [
      "preflight_status",
      "PREFLIGHT: REVISIONS REQUIRED",
      `${ITEM1} preflight_status must be 'PREFLIGHT: ALL CLEAR'; found: 'PREFLIGHT: REVISIONS REQUIRED'.`,
    ],
    ["research_path", "", `${ITEM1} research_path must be a non-empty string.`],
    ["plan_path", null, `${ITEM1} plan_path must be a non-empty string.`],
  ])("rejects an unprepared item field %s", (key, value, expected) => {
    const state = buildValidPlannerState();
    itemAt(state, 1)[key] = value;

    expect(validate(state, true)).toContain(expected);
  });

  it.each([
    ["derived", "'derived'"],
    ["observed", "'observed'"],
  ])("requires a declared radius, rejecting source %s", (source, rendered) => {
    const state = buildValidPlannerState();
    radiusOf(state, 1)["source"] = source;

    expect(validate(state, true)).toContain(
      `${ITEM1} blast_radius.source must be 'declared' for execution readiness; found: ${rendered}.`,
    );
  });

  it("reports its own condition for a radius with no readable source", () => {
    const state = buildValidPlannerState();
    itemAt(state, 1)["blast_radius"] = "scripts/dev_tools/**";

    expect(validate(state, true)).toContain(
      `${ITEM1} blast_radius.source must be 'declared' for execution readiness; found: None.`,
    );
  });

  it.each([
    ["cohort_0_launch", "'cohort_0_launch'"],
    ["", "''"],
    [null, "None"],
  ])("requires the readiness sentinel, rejecting %p", (nextStep, rendered) => {
    const state = buildValidPlannerState();
    state["next_step"] = nextStep;

    expect(validate(state, true)).toContain(
      `${CONTEXT} next_step must be 'PARALLEL_EXECUTION_READY'; found: ${String(rendered)}.`,
    );
  });

  it.each([
    [
      "docs/features/parallel/other/parallel-kickoff.md",
      "'docs/features/parallel/other/parallel-kickoff.md'",
    ],
    [
      "artifacts/orchestration/epic-kickoff-wave-one.md",
      "'artifacts/orchestration/epic-kickoff-wave-one.md'",
    ],
    ["", "''"],
    [null, "None"],
  ])(
    "pins the conventional kickoff path, rejecting %p",
    (kickoff, rendered) => {
      const state = buildValidPlannerState();
      state["kickoff_prompt_path"] = kickoff;

      expect(validate(state, true)).toContain(
        `${CONTEXT} kickoff_prompt_path must be '${EXPECTED_KICKOFF}'; found: ${String(rendered)}.`,
      );
    },
  );

  it("contributes no errors when the gate is disabled", () => {
    const state = buildValidPlannerState();
    state["items"] = [buildItem(444, "parallel-schema-validators")];
    cohortAt(state, 0)["item_keys"] = [444];
    itemAt(state, 0)["preparation_status"] = "in_progress";
    itemAt(state, 0)["preflight_status"] = "PREFLIGHT: REVISIONS REQUIRED";
    radiusOf(state, 0)["source"] = "derived";
    state["next_step"] = "awaiting_research";
    delete state["kickoff_prompt_path"];

    expect(validate(state)).toEqual([]);
  });
});
