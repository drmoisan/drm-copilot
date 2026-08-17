/**
 * Tests for the parallel-orchestrator checkpoint validator, invariants 1-11.
 *
 * Covers spec invariants 1 through 11, the `current_cohort` bound (invariant
 * 14), and invariant 19 (the optional receipt arrays), plus the invalid-JSON,
 * non-object-root, and absent-optional-key backward-compatibility cases. Every
 * expected string is the byte-identical literal emitted by the Python source in
 * `scripts/dev_tools/validate_parallel_orchestrator_state.py` and its helper
 * modules; the invalid-JSON case asserts the prefix only, because the parser's
 * own message text cannot be reproduced across the two runtimes.
 */

import {
  REQUIRED_KEYS,
  validateParallelOrchestratorStateText,
} from "../../../src/lib/validate/parallel-orchestrator-state-core";
import {
  VALID_DISPOSITIONS,
  VALID_DRIFT_ACTIONS,
  VALID_EDGE_REASONS,
  VALID_ITEM_STATES,
  VALID_KINDS,
  VALID_MERGE_STATUS,
  VALID_MODES,
  VALID_MUTATION_OPS,
  VALID_SOURCES,
} from "../../../src/lib/validate/parallel-state-shared";
import {
  buildValidParallelState,
  itemAt,
  radiusOf,
  validateState,
} from "./parallel-state-test-support";

const ITEM_STATE_ENUM =
  "proposed, admitted, prepared, scheduled, in_flight, merged, withdrawn, blocked";
const MERGE_STATUS_ENUM =
  "not_started, worktree_created, pr_open, ci_green, merged, worktree_removed, blocked_drift, blocked_ci_loop_limit";

describe("validateParallelOrchestratorStateText root handling", () => {
  it("returns no errors for a checkpoint satisfying every invariant", () => {
    expect(validateState(buildValidParallelState())).toEqual([]);
  });

  it("does not mutate its input", () => {
    const state = buildValidParallelState();
    const snapshot = JSON.stringify(state);

    validateParallelOrchestratorStateText(JSON.stringify(state));

    expect(JSON.stringify(state)).toBe(snapshot);
  });

  it("returns a single prefixed error for unparseable text", () => {
    const errors = validateParallelOrchestratorStateText("{not json");

    expect(errors).toHaveLength(1);
    expect(errors[0]).toMatch(/^Parallel checkpoint is not valid JSON: /);
  });

  it("rejects a JSON array root with one shape error", () => {
    expect(validateParallelOrchestratorStateText("[]")).toEqual([
      "Parallel checkpoint root must be a JSON object.",
    ]);
  });
});

describe("invariant 1 required top-level keys", () => {
  it.each(REQUIRED_KEYS)("reports the missing key %s", (key) => {
    const state = buildValidParallelState();
    delete state[key];

    expect(validateState(state)).toContain(
      `Parallel checkpoint missing required key: ${key}.`,
    );
  });

  it("reports exactly one error per required key for an empty object", () => {
    expect(validateParallelOrchestratorStateText("{}")).toHaveLength(
      REQUIRED_KEYS.length,
    );
  });
});

describe("invariants 2-4 run identity", () => {
  it("rejects a checkpoint claiming another route", () => {
    const state = buildValidParallelState();
    state["route_id"] = "epic";

    expect(validateState(state)).toContain(
      "Parallel checkpoint route_id must be 'parallel'; found: 'epic'.",
    );
  });

  it.each(["closed", "open"])("accepts run mode %s", (mode) => {
    const state = buildValidParallelState();
    state["mode"] = mode;

    expect(validateState(state)).toEqual([]);
  });

  it("rejects a mode outside the two-value enum", () => {
    const state = buildValidParallelState();
    state["mode"] = "half-open";

    expect(validateState(state)).toContain(
      "Parallel checkpoint mode must be one of closed, open; found: 'half-open'.",
    );
  });

  it.each([1, 4, 32])("accepts in-range concurrency %p", (concurrency) => {
    const state = buildValidParallelState();
    state["max_concurrency"] = concurrency;

    expect(validateState(state)).toEqual([]);
  });

  it.each([
    [0, "0"],
    [33, "33"],
    [-1, "-1"],
    [true, "True"],
    ["4", "'4'"],
    [4.5, "4.5"],
    [null, "None"],
  ])("rejects out-of-range concurrency %p", (concurrency, rendered) => {
    const state = buildValidParallelState();
    state["max_concurrency"] = concurrency;

    expect(validateState(state)).toContain(
      `Parallel checkpoint max_concurrency must be an integer from 1 through 32; found: ${String(rendered)}.`,
    );
  });
});

describe("invariant 5 item shape and primary key", () => {
  it.each([
    [{}, "Parallel checkpoint items must be a list."],
    [["not-an-object"], "Parallel checkpoint items[0] must be an object."],
  ])("rejects a malformed items container", (items, expected) => {
    const state = buildValidParallelState();
    state["items"] = items;

    expect(validateState(state)).toContain(expected);
  });

  it.each([
    [0, "0"],
    [-3, "-3"],
    [true, "True"],
    ["444", "'444'"],
    [null, "None"],
  ])("rejects non-positive issue_num %p", (issueNum, rendered) => {
    const state = buildValidParallelState();
    itemAt(state, 0)["issue_num"] = issueNum;

    expect(validateState(state)).toContain(
      `Parallel checkpoint items[0] issue_num must be a positive integer; found: ${String(rendered)}.`,
    );
  });

  it("reports a repeated primary key once, naming the duplicated value", () => {
    const state = buildValidParallelState();
    itemAt(state, 1)["issue_num"] = 444;
    state["cohorts"] = [{ index: 0, generation: 0, item_keys: [444] }];

    expect(validateState(state)).toContain(
      "Parallel checkpoint has duplicate items[].issue_num: 444.",
    );
  });

  it("rejects a blank feature_folder", () => {
    const state = buildValidParallelState();
    itemAt(state, 0)["feature_folder"] = "   ";

    expect(validateState(state)).toContain(
      "Parallel checkpoint items[0] feature_folder must be a non-empty string.",
    );
  });
});

describe("invariant 6 item state enum", () => {
  it.each(VALID_ITEM_STATES)("accepts item state %s", (stateValue) => {
    const state = buildValidParallelState();
    itemAt(state, 0)["state"] = stateValue;

    expect(
      validateState(state).filter((error) => error.includes("items[0] state")),
    ).toEqual([]);
  });

  it("rejects an item state outside the eight-value enum", () => {
    const state = buildValidParallelState();
    itemAt(state, 0)["state"] = "parked";

    expect(validateState(state)).toContain(
      `Parallel checkpoint items[0] state must be one of ${ITEM_STATE_ENUM}; found: 'parked'.`,
    );
  });

  it.each([
    [VALID_ITEM_STATES, 8],
    [VALID_MERGE_STATUS, 8],
    [VALID_SOURCES, 3],
    [VALID_KINDS, 2],
    [VALID_MODES, 2],
    [VALID_MUTATION_OPS, 4],
    [VALID_DISPOSITIONS, 2],
    [VALID_EDGE_REASONS, 4],
    [VALID_DRIFT_ACTIONS, 2],
  ])("carries the spec S4 member count for %p", (members, count) => {
    expect(members).toHaveLength(count);
  });
});

describe("invariants 7-8 merge status", () => {
  it("treats an absent merge_status as the backward-compatible shape", () => {
    const state = buildValidParallelState();

    expect("merge_status" in itemAt(state, 0)).toBe(false);
    expect(validateState(state)).toEqual([]);
  });

  it.each(["not_started", "worktree_created", "pr_open"])(
    "accepts non-terminal merge status %s",
    (mergeStatus) => {
      const state = buildValidParallelState();
      itemAt(state, 0)["merge_status"] = mergeStatus;

      expect(validateState(state)).toEqual([]);
    },
  );

  it("rejects a merge_status outside the eight-value enum", () => {
    const state = buildValidParallelState();
    itemAt(state, 0)["merge_status"] = "merge_conflict";

    expect(validateState(state)).toContain(
      `Parallel checkpoint items[0] merge_status must be one of ${MERGE_STATUS_ENUM}; found: 'merge_conflict'.`,
    );
  });

  it("applies the S8 merge-status replacements", () => {
    expect(VALID_MERGE_STATUS).toHaveLength(8);
    expect(VALID_MERGE_STATUS).not.toContain("merge_conflict");
    expect(VALID_MERGE_STATUS).not.toContain("blocked_conflict_loop_limit");
    expect(VALID_MERGE_STATUS).toEqual(
      expect.arrayContaining(["blocked_drift", "blocked_ci_loop_limit"]),
    );
  });

  it.each(["merged", "worktree_removed"])(
    "requires state 'merged' for terminal merge status %s",
    (mergeStatus) => {
      const state = buildValidParallelState();
      itemAt(state, 0)["merge_status"] = mergeStatus;

      expect(validateState(state)).toContain(
        `Parallel checkpoint items[0] merge_status '${mergeStatus}' requires state 'merged'; found: 'scheduled'.`,
      );
    },
  );

  it.each(["blocked_drift", "blocked_ci_loop_limit"])(
    "requires state 'blocked' for blocked merge status %s",
    (mergeStatus) => {
      const state = buildValidParallelState();
      itemAt(state, 0)["merge_status"] = mergeStatus;

      expect(validateState(state)).toContain(
        `Parallel checkpoint items[0] merge_status '${mergeStatus}' requires state 'blocked'; found: 'scheduled'.`,
      );
    },
  );

  it("accepts a consistent terminal pairing", () => {
    const state = buildValidParallelState();
    itemAt(state, 0)["state"] = "merged";
    itemAt(state, 0)["merge_status"] = "merged";

    expect(validateState(state)).toEqual([]);
  });
});

describe("invariant 9 blast radius", () => {
  it("rejects a non-object blast radius with one shape error", () => {
    const state = buildValidParallelState();
    itemAt(state, 0)["blast_radius"] = "scripts/**";

    expect(validateState(state)).toContain(
      "Parallel checkpoint items[0] blast_radius must be an object.",
    );
  });

  it.each(["paths", "modules", "shared_surfaces", "contracts"])(
    "requires blast_radius.%s to be a list of non-empty strings",
    (field) => {
      const state = buildValidParallelState();
      radiusOf(state, 0)[field] = [""];

      expect(validateState(state)).toContain(
        `Parallel checkpoint items[0] blast_radius.${field} must be a list of non-empty strings.`,
      );
    },
  );

  it.each(VALID_SOURCES)("accepts confidence source %s", (source) => {
    const state = buildValidParallelState();
    radiusOf(state, 0)["source"] = source;

    expect(validateState(state)).toEqual([]);
  });

  it("rejects a confidence source outside the three-value enum", () => {
    const state = buildValidParallelState();
    radiusOf(state, 0)["source"] = "guessed";

    expect(validateState(state)).toContain(
      "Parallel checkpoint items[0] blast_radius.source must be one of derived, declared, observed; found: 'guessed'.",
    );
  });

  it("rejects a blank radius timestamp", () => {
    const state = buildValidParallelState();
    radiusOf(state, 0)["computed_at"] = "";

    expect(validateState(state)).toContain(
      "Parallel checkpoint items[0] blast_radius.computed_at must be a non-empty string.",
    );
  });
});

describe("invariants 10-11 prohibited keys", () => {
  it.each(["depends_on", "integration_branch", "epic_merge_pr"])(
    "rejects prohibited top-level key %s",
    (key) => {
      const state = buildValidParallelState();
      state[key] = "value";

      expect(validateState(state)).toContain(
        `Parallel checkpoint carries prohibited key '${key}' at <root>.`,
      );
    },
  );

  it("rejects a depends_on nested inside an item and locates it by path", () => {
    const state = buildValidParallelState();
    itemAt(state, 1)["depends_on"] = [444];

    expect(validateState(state)).toContain(
      "Parallel checkpoint carries prohibited key 'depends_on' at items[1].",
    );
  });

  it("rejects an epic_merge_pr block nested two levels down", () => {
    const state = buildValidParallelState();
    itemAt(state, 0)["metadata"] = {
      epic_merge_pr: { merge_commit_sha: "abc" },
    };

    expect(validateState(state)).toContain(
      "Parallel checkpoint carries prohibited key 'epic_merge_pr' at items[0].metadata.",
    );
  });
});

describe("invariant 14 current_cohort bound", () => {
  it.each([
    [-1, "-1"],
    [true, "True"],
    ["0", "'0'"],
    [1.5, "1.5"],
    [null, "None"],
  ])("rejects non-integer current_cohort %p", (currentCohort, rendered) => {
    const state = buildValidParallelState();
    state["current_cohort"] = currentCohort;

    expect(validateState(state)).toContain(
      `Parallel checkpoint current_cohort must be a non-negative integer; found: ${String(rendered)}.`,
    );
  });

  it("rejects a pointer past the highest current-generation index", () => {
    const state = buildValidParallelState();
    state["current_cohort"] = 3;

    expect(validateState(state)).toContain(
      "Parallel checkpoint current_cohort 3 must not exceed the maximum current-generation cohorts[].index 0.",
    );
  });

  it("allows any pointer when no current-generation coloring exists", () => {
    const state = buildValidParallelState();
    state["cohorts"] = [];
    state["current_cohort"] = 7;
    itemAt(state, 0)["state"] = "withdrawn";
    itemAt(state, 1)["state"] = "withdrawn";

    expect(validateState(state)).toEqual([]);
  });
});

describe("invariant 19 optional receipt arrays", () => {
  it("treats absent receipt arrays as backward compatible", () => {
    const state = buildValidParallelState();

    expect("delegation_receipts" in state).toBe(false);
    expect(validateState(state)).toEqual([]);
  });

  it("accepts a present receipt array whatever it holds", () => {
    const state = buildValidParallelState();
    state["delegation_receipts"] = [{ anything: "tolerated" }];

    expect(validateState(state)).toEqual([]);
  });
});
