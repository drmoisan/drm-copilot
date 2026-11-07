import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";

/**
 * Pin the tolerated, unvalidated `stage_timing` checkpoint key (issue #1097,
 * stage B).
 *
 * Purpose:
 *     The orchestrator main session writes `stage_timing` into the checkpoint.
 *     No validator reads the key, so three shapes (a valid list, JSON `null`,
 *     and a string) must leave the error list equal to the list for the same
 *     checkpoint without the key. A control removes a required key, which proves
 *     the validator ran.
 *
 * Filesystem access:
 *     A read-only load of the committed back-compat checkpoint `none.json`
 *     resolved from `__dirname`. The key is added in memory. No temporary file
 *     is created and no file is mutated.
 */

/**
 * Committed base checkpoint, five levels up from this directory: `validate` ->
 * `lib` -> `test` -> `drm-copilot` -> `extensions` -> repository root.
 */
const BASE_CHECKPOINT_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "orchestrator_state_blocked_reason_backcompat",
  "none.json",
);

/** The tolerated checkpoint key under test. */
const KEY = "stage_timing";

/** Three shapes that a later validator must not start rejecting silently. */
const SHAPES: readonly (readonly [string, unknown])[] = [
  [
    "valid list",
    [
      {
        stage: "S4_atomic_planning",
        attempt: 1,
        started_at: "2026-01-02T01:00:00Z",
        ended_at: "2026-01-02T01:10:00Z",
      },
      {
        stage: "S5_atomic_execution",
        attempt: 1,
        started_at: "2026-01-02T01:10:00Z",
        ended_at: null,
      },
    ],
  ],
  ["null", null],
  ["string", "not-a-list"],
];

/**
 * Routing matrix injected under `requireComplete`, declared the same way as
 * `orchestrator-state-blocked-reason-backcompat.test.ts`.
 */
const ROUTING_MATRIX = {
  routes: {
    large: {
      requires_pr_gate: true,
      required_agents: [],
      required_skills: [],
      required_mcp_tools: [],
    },
    small: {
      required_agents: [],
      required_skills: [],
      required_mcp_tools: [],
    },
  },
};

/**
 * Read the committed base checkpoint as a mutable object.
 *
 * @returns A fresh parsed copy of the base checkpoint.
 * @throws Error when the fixture is not a JSON object.
 */
function loadBaseCheckpoint(): Record<string, unknown> {
  const parsed: unknown = JSON.parse(
    fs.readFileSync(BASE_CHECKPOINT_PATH, "utf-8"),
  );
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error("The base checkpoint must be a JSON object.");
  }
  return { ...(parsed as Record<string, unknown>) };
}

/**
 * Serialize the base checkpoint, optionally adding `stage_timing`.
 *
 * @param value The value stored under `stage_timing` when it is added.
 * @param present Whether the key is added at all.
 * @returns The checkpoint as JSON text.
 */
function checkpointText(value: unknown, present: boolean): string {
  const checkpoint = loadBaseCheckpoint();
  if (present) {
    checkpoint[KEY] = value;
  }
  return JSON.stringify(checkpoint, null, 2);
}

describe("orchestrator-state stage_timing tolerated key", () => {
  it("ignores stage_timing in plain mode", () => {
    for (const [shape, value] of SHAPES) {
      // Arrange
      const withoutKey = checkpointText(value, false);
      const withKey = checkpointText(value, true);

      // Act
      const expected = validateOrchestratorStateText(withoutKey);
      const observed = validateOrchestratorStateText(withKey);

      // Assert
      expect({ shape, errors: observed }).toEqual({ shape, errors: expected });
      expect(observed.filter((line) => line.includes(KEY))).toEqual([]);
    }
  });

  it("ignores stage_timing under requireComplete", () => {
    for (const [shape, value] of SHAPES) {
      // Arrange
      const withoutKey = checkpointText(value, false);
      const withKey = checkpointText(value, true);
      const options = { requireComplete: true, routingMatrix: ROUTING_MATRIX };

      // Act
      const expected = validateOrchestratorStateText(withoutKey, options);
      const observed = validateOrchestratorStateText(withKey, options);

      // Assert
      expect({ shape, errors: observed }).toEqual({ shape, errors: expected });
      expect(observed.filter((line) => line.includes(KEY))).toEqual([]);
    }
  });

  it("still reports a missing required key as a control", () => {
    // Arrange: the key is present and a required key is removed.
    const checkpoint = loadBaseCheckpoint();
    checkpoint[KEY] = SHAPES[0][1];
    delete checkpoint["last_updated"];

    // Act
    const errors = validateOrchestratorStateText(
      JSON.stringify(checkpoint, null, 2),
    );

    // Assert: the validator ran and does not name the tolerated key.
    expect(errors).toContain("Checkpoint missing required key: last_updated");
    expect(errors.filter((line) => line.includes(KEY))).toEqual([]);
  });
});
