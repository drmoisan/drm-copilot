/**
 * Tests for the parallel checkpoint scheduling and record collections: cohort
 * shape and key resolution (invariant 12), current-generation index uniqueness
 * and exactly-one coverage (13), conflict-edge shape including `a < b`
 * normalization and duplicate-pair rejection (15), the full `mutations[]` shape
 * with every schema S5 null rule and the in-flight-removal disposition rule (16
 * and 17), and the full `drift_events[]` shape (18). Every expected string is
 * the byte-identical literal emitted by the Python helper modules. The S4
 * enum-cardinality assertions live in `parallel-orchestrator-state-core.test.ts`
 * alongside the other vocabulary checks.
 */

import {
  VALID_DISPOSITIONS,
  VALID_DRIFT_ACTIONS,
  VALID_EDGE_REASONS,
} from "../../../src/lib/validate/parallel-state-shared";
import {
  buildValidParallelState,
  cohortAt,
  itemAt,
  validateState,
  type JsonRecord,
} from "./parallel-state-test-support";

const EDGE_REASON_ENUM =
  "path_overlap, module_overlap, shared_surface_overlap, contract_dependency";
const ITEM_STATE_ENUM =
  "proposed, admitted, prepared, scheduled, in_flight, merged, withdrawn, blocked";
const UNRESOLVED_DRIFT_ERROR =
  "Parallel checkpoint unresolved drift for items [444] blocks admission and completion.";
const MISSING_DRIFT_EVENT_ERROR =
  "Parallel checkpoint semantic-drift requeue requires a persisted halted_later_started_item event.";

const NON_INTEGER_CASES: [unknown, string][] = [
  [-1, "-1"],
  [true, "True"],
  ["0", "'0'"],
  [null, "None"],
];

const UNRESOLVED_KEY_CASES: [unknown, string][] = [
  [999, "999"],
  ["444", "'444'"],
  [true, "True"],
  [null, "None"],
];

/** Assert that validating a checkpoint reports one exact error string. */
function expectError(state: JsonRecord, expected: string): void {
  expect(validateState(state)).toContain(expected);
}

/** Assert that validating a checkpoint reports no error at all. */
function expectValid(state: JsonRecord): void {
  expect(validateState(state)).toEqual([]);
}

/** Return a checkpoint with replaced edges and a valid split coloring. */
function stateWithEdges(edges: unknown): JsonRecord {
  const state = buildValidParallelState();
  state["cohorts"] = [
    { index: 0, generation: 0, item_keys: [444] },
    { index: 1, generation: 0, item_keys: [445] },
  ];
  state["conflict_edges"] = edges;
  return state;
}

/** Return a valid checkpoint whose mutation log holds one supplied entry. */
function stateWithMutation(overrides: JsonRecord = {}): JsonRecord {
  const state = buildValidParallelState();
  state["mutations"] = [
    {
      op: "requeue",
      item_key: 444,
      at: "2026-08-07T11-00",
      prior_state: "scheduled",
      new_state: "admitted",
      disposition: null,
      recolor_generation: 0,
      ...overrides,
    },
  ];
  return state;
}

/** Return a valid checkpoint whose mutation log holds one close record. */
function stateWithClose(overrides: JsonRecord = {}): JsonRecord {
  return stateWithMutation({
    op: "close",
    item_key: null,
    at: "2026-08-07T12-00",
    prior_state: null,
    new_state: null,
    ...overrides,
  });
}

/** Return a valid checkpoint whose drift log holds one supplied event. */
function stateWithDriftEvent(overrides: JsonRecord = {}): JsonRecord {
  const state = buildValidParallelState();
  state["drift_events"] = [
    {
      item_key: 444,
      declared: ["scripts/dev_tools/**"],
      observed: ["scripts/dev_tools/a.py", "extensions/b.ts"],
      escaped_paths: ["extensions/b.ts"],
      at: "2026-08-07T11-30",
      action: "raised_blocking_finding",
      ...overrides,
    },
  ];
  return state;
}

describe("invariant 12 cohort shape", () => {
  it("accepts the builder's single current-generation cohort", () => {
    expectValid(buildValidParallelState());
  });

  it("rejects a non-list cohorts value with one collection-level error", () => {
    const state = buildValidParallelState();
    state["cohorts"] = {};
    expectError(state, "Parallel checkpoint cohorts must be a list.");
  });

  it("names a non-object cohort entry by its positional index", () => {
    const state = buildValidParallelState();
    state["cohorts"] = ["cohort-0"];
    expectError(state, "Parallel checkpoint cohorts[0] must be an object.");
  });

  it.each(NON_INTEGER_CASES)("rejects cohort index %p", (index, rendered) => {
    const state = buildValidParallelState();
    cohortAt(state, 0)["index"] = index;
    expectError(
      state,
      `Parallel checkpoint cohorts[0] index must be a non-negative integer; found: ${rendered}.`,
    );
  });

  it.each(NON_INTEGER_CASES)("rejects generation %p", (value, rendered) => {
    const state = buildValidParallelState();
    cohortAt(state, 0)["generation"] = value;
    expectError(
      state,
      `Parallel checkpoint cohorts[0] generation must be a non-negative integer; found: ${rendered}.`,
    );
  });

  it("rejects a cohort generation the run has not reached", () => {
    const state = buildValidParallelState();
    cohortAt(state, 0)["generation"] = 3;
    expectError(
      state,
      "Parallel checkpoint cohorts[0] generation 3 must not exceed recolor_generation 0.",
    );
  });

  it("rejects a malformed top-level generation counter", () => {
    const state = buildValidParallelState();
    state["recolor_generation"] = "one";
    expectError(
      state,
      "Parallel checkpoint recolor_generation must be a non-negative integer; found: 'one'.",
    );
  });

  it("requires a cohort's item_keys to be a list", () => {
    const state = buildValidParallelState();
    cohortAt(state, 0)["item_keys"] = 444;
    expectError(
      state,
      "Parallel checkpoint cohorts[0] item_keys must be a list.",
    );
  });

  it.each(UNRESOLVED_KEY_CASES)("rejects member %p", (key, rendered) => {
    const state = buildValidParallelState();
    cohortAt(state, 0)["item_keys"] = [444, 445, key];
    expectError(
      state,
      `Parallel checkpoint cohorts[0] item_keys entry ${rendered} does not resolve to an items[].issue_num.`,
    );
  });
});

describe("invariant 13 current-generation coverage", () => {
  it("rejects two current-generation cohorts sharing one index", () => {
    const state = buildValidParallelState();
    state["cohorts"] = [
      { index: 0, generation: 0, item_keys: [444] },
      { index: 0, generation: 0, item_keys: [445] },
    ];
    expectError(
      state,
      "Parallel checkpoint has duplicate current-generation cohorts[].index: 0.",
    );
  });

  it("rejects a scheduled item absent from the current coloring", () => {
    const state = buildValidParallelState();
    cohortAt(state, 0)["item_keys"] = [444];
    expectError(
      state,
      "Parallel checkpoint item 445 in state 'scheduled' must appear in exactly one current-generation cohort; found 0.",
    );
  });

  it("rejects an item colored into two current-generation cohorts", () => {
    const state = buildValidParallelState();
    state["cohorts"] = [
      { index: 0, generation: 0, item_keys: [444, 445] },
      { index: 1, generation: 0, item_keys: [445] },
    ];
    state["current_cohort"] = 1;
    expectError(
      state,
      "Parallel checkpoint item 445 in state 'scheduled' must appear in exactly one current-generation cohort; found 2.",
    );
  });

  it.each(["withdrawn", "merged", "blocked"])(
    "exempts an item in state %s from coverage",
    (exemptState) => {
      const state = buildValidParallelState();
      cohortAt(state, 0)["item_keys"] = [444];
      itemAt(state, 1)["state"] = exemptState;
      expectValid(state);
    },
  );

  it("ignores cohorts of an earlier generation", () => {
    const state = buildValidParallelState();
    state["recolor_generation"] = 1;
    cohortAt(state, 0)["generation"] = 0;
    expectError(
      state,
      "Parallel checkpoint item 444 in state 'scheduled' must appear in exactly one current-generation cohort; found 0.",
    );
  });
});

describe("invariant 15 conflict edges", () => {
  it("accepts a distinct, normalized, in-enum edge", () => {
    expectValid(stateWithEdges([{ a: 444, b: 445, reason: "path_overlap" }]));
  });

  it("rejects a non-list conflict_edges value", () => {
    expectError(
      stateWithEdges({}),
      "Parallel checkpoint conflict_edges must be a list.",
    );
  });

  it("names a non-object edge entry by its positional index", () => {
    expectError(
      stateWithEdges(["444-445"]),
      "Parallel checkpoint conflict_edges[0] must be an object.",
    );
  });

  it("rejects a self-edge", () => {
    expectError(
      stateWithEdges([{ a: 444, b: 444, reason: "path_overlap" }]),
      "Parallel checkpoint conflict_edges[0] endpoints must be distinct; found: 444.",
    );
  });

  it.each(["a", "b"])("rejects an unresolved %s endpoint", (endpoint) => {
    const edge: JsonRecord = { a: 444, b: 445, reason: "path_overlap" };
    edge[endpoint] = 999;
    expectError(
      stateWithEdges([edge]),
      `Parallel checkpoint conflict_edges[0] ${endpoint} 999 does not resolve to an items[].issue_num.`,
    );
  });

  it("rejects an unnormalized pair", () => {
    expectError(
      stateWithEdges([{ a: 445, b: 444, reason: "path_overlap" }]),
      "Parallel checkpoint conflict_edges[0] must be normalized with a < b; found: (445, 444).",
    );
  });

  it("reports a repeated canonical pair once", () => {
    expectError(
      stateWithEdges([
        { a: 444, b: 445, reason: "path_overlap" },
        { a: 444, b: 445, reason: "module_overlap" },
      ]),
      "Parallel checkpoint has duplicate conflict_edges[] pair: (444, 445).",
    );
  });

  it.each(VALID_EDGE_REASONS)("accepts edge reason %s", (reason) => {
    expectValid(stateWithEdges([{ a: 444, b: 445, reason }]));
  });

  it("rejects a reason outside the four-value enum", () => {
    expectError(
      stateWithEdges([{ a: 444, b: 445, reason: "vibes" }]),
      `Parallel checkpoint conflict_edges[0] reason must be one of ${EDGE_REASON_ENUM}; found: 'vibes'.`,
    );
  });
});

describe("invariant 16 mutation log", () => {
  it("accepts the item-scoped shape before requiring its drift event", () => {
    expectError(stateWithMutation(), MISSING_DRIFT_EVENT_ERROR);
  });

  it("accepts the run-level close record", () => {
    expectValid(stateWithClose());
  });

  it("rejects a non-list mutations value", () => {
    const state = buildValidParallelState();
    state["mutations"] = {};
    expectError(state, "Parallel checkpoint mutations must be a list.");
  });

  it("names a non-object mutation entry by its positional index", () => {
    const state = buildValidParallelState();
    state["mutations"] = ["close"];
    expectError(state, "Parallel checkpoint mutations[0] must be an object.");
  });

  it("rejects an op outside the four-value enum", () => {
    expectError(
      stateWithMutation({ op: "rename" }),
      "Parallel checkpoint mutations[0] op must be one of add, remove, close, requeue; found: 'rename'.",
    );
  });

  it("requires a null item_key on the run-level close", () => {
    expectError(
      stateWithClose({ item_key: 444 }),
      "Parallel checkpoint mutations[0] item_key must be null for op 'close'; found: 444.",
    );
  });

  it.each(["add", "remove", "requeue"])(
    "requires a resolving key (%s)",
    (op) => {
      expectError(
        stateWithMutation({ op, item_key: 999, prior_state: null }),
        "Parallel checkpoint mutations[0] item_key 999 does not resolve to an items[].issue_num.",
      );
    },
  );

  it("requires a mutation to record when it happened", () => {
    expectError(
      stateWithMutation({ at: "" }),
      "Parallel checkpoint mutations[0] at must be a non-empty string.",
    );
  });

  it.each(["add", "close"])("requires a null prior_state for op %s", (op) => {
    expectError(
      stateWithMutation({ op, item_key: op === "close" ? null : 444 }),
      `Parallel checkpoint mutations[0] prior_state must be null for op '${op}'; found: 'scheduled'.`,
    );
  });

  it("requires a null new_state for the run-level close", () => {
    expectError(
      stateWithMutation({ op: "close", item_key: null, prior_state: null }),
      "Parallel checkpoint mutations[0] new_state must be null for op 'close'; found: 'admitted'.",
    );
  });

  it.each(["prior_state", "new_state"])("rejects out-of-enum %s", (field) => {
    expectError(
      stateWithMutation({ [field]: "parked" }),
      `Parallel checkpoint mutations[0] ${field} must be null or one of ${ITEM_STATE_ENUM}; found: 'parked'.`,
    );
  });

  it.each(NON_INTEGER_CASES)("rejects generation %p", (value, rendered) => {
    expectError(
      stateWithMutation({ recolor_generation: value }),
      `Parallel checkpoint mutations[0] recolor_generation must be a non-negative integer; found: ${rendered}.`,
    );
  });

  it("rejects a mutation generation above the top-level counter", () => {
    expectError(
      stateWithMutation({ recolor_generation: 4 }),
      "Parallel checkpoint mutations[0] recolor_generation 4 must not exceed recolor_generation 0.",
    );
  });
});

describe("invariant 17 in-flight removal disposition", () => {
  it.each(VALID_DISPOSITIONS)("accepts disposition %s", (disposition) => {
    expectValid(
      stateWithMutation({
        op: "remove",
        prior_state: "in_flight",
        new_state: "withdrawn",
        disposition,
      }),
    );
  });

  it("requires a disposition on an in-flight removal", () => {
    expectError(
      stateWithMutation({
        op: "remove",
        prior_state: "in_flight",
        new_state: "withdrawn",
      }),
      "Parallel checkpoint mutations[0] disposition must be one of detach, abandon for an in-flight removal; found: None.",
    );
  });

  it.each(["add", "requeue", "remove"])(
    "rejects a disposition on op %s outside an in-flight removal",
    (op) => {
      expectError(
        stateWithMutation({
          op,
          prior_state: "scheduled",
          disposition: "detach",
        }),
        "Parallel checkpoint mutations[0] disposition must be null unless op is 'remove' with prior_state 'in_flight'; found: 'detach'.",
      );
    },
  );
});

describe("invariant 18 drift events", () => {
  it("accepts the complete shape before unresolved-drift quiescence", () => {
    expectError(stateWithDriftEvent(), UNRESOLVED_DRIFT_ERROR);
  });

  it("rejects a non-list drift_events value", () => {
    const state = buildValidParallelState();
    state["drift_events"] = {};
    expectError(state, "Parallel checkpoint drift_events must be a list.");
  });

  it("names a non-object drift entry by its positional index", () => {
    const state = buildValidParallelState();
    state["drift_events"] = ["drift"];
    expectError(
      state,
      "Parallel checkpoint drift_events[0] must be an object.",
    );
  });

  it.each(UNRESOLVED_KEY_CASES)("rejects item_key %p", (key, rendered) => {
    expectError(
      stateWithDriftEvent({ item_key: key }),
      `Parallel checkpoint drift_events[0] item_key ${rendered} does not resolve to an items[].issue_num.`,
    );
  });

  it.each(["declared", "observed"])("rejects a blank %s entry", (field) => {
    expectError(
      stateWithDriftEvent({ [field]: [""] }),
      `Parallel checkpoint drift_events[0] ${field} must be a list of non-empty strings.`,
    );
  });

  it.each(["declared", "observed"])("accepts an empty %s set", (field) => {
    expectError(stateWithDriftEvent({ [field]: [] }), UNRESOLVED_DRIFT_ERROR);
  });

  it.each([[[]], ["extensions/b.ts"], [[""]], [null]])(
    "rejects empty or malformed escaped_paths %p",
    (escaped) => {
      expectError(
        stateWithDriftEvent({ escaped_paths: escaped }),
        "Parallel checkpoint drift_events[0] escaped_paths must be a non-empty list of non-empty strings.",
      );
    },
  );

  it("requires a drift event to record when detection happened", () => {
    expectError(
      stateWithDriftEvent({ at: "  " }),
      "Parallel checkpoint drift_events[0] at must be a non-empty string.",
    );
  });

  it.each(VALID_DRIFT_ACTIONS)("accepts drift action %s", (action) => {
    expectError(stateWithDriftEvent({ action }), UNRESOLVED_DRIFT_ERROR);
  });

  it("rejects an action outside the two-value enum", () => {
    expectError(
      stateWithDriftEvent({ action: "ignored" }),
      "Parallel checkpoint drift_events[0] action must be one of raised_blocking_finding, halted_later_started_item; found: 'ignored'.",
    );
  });
});
