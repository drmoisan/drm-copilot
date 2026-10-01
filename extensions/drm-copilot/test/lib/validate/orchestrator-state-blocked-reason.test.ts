import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  classifyBlockedReason,
  MECHANICAL_BLOCKED_REASONS,
  NON_MECHANICAL_BLOCKED_REASONS,
  VALID_BLOCKED_REASONS as MODULE_VALID_BLOCKED_REASONS,
} from "../../../src/lib/validate/orchestrator-state-blocked-reason";
import { VALID_BLOCKED_REASONS as CORE_VALID_BLOCKED_REASONS } from "../../../src/lib/validate/orchestrator-state-core";

/**
 * Tests for the orchestrator-state `blocked_reason` partition module (#523).
 *
 * Purpose:
 *     Pin the mechanical and non-mechanical partitions to the committed oracle
 *     `tests/fixtures/orchestrator_state_blocked_reason_partition.json`, check
 *     that the core validator re-exports the module's vocabulary, and enumerate
 *     `classifyBlockedReason` over the whole vocabulary plus the invalid-value
 *     classes. Property-based testing libraries are not dependencies of this
 *     repository, so exhaustive enumeration is used instead.
 *
 * Filesystem access:
 *     Read-only load of the committed oracle resolved from `__dirname`. No
 *     temporary file is created and no file is mutated.
 */

/**
 * Committed partition oracle, five levels up from this directory: `validate` ->
 * `lib` -> `test` -> `drm-copilot` -> `extensions` -> repository root.
 */
const PARTITION_ORACLE_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "orchestrator_state_blocked_reason_partition.json",
);

/** The six validator-enforced members. */
const MECHANICAL: readonly string[] = [
  "spawn_agent_unavailable",
  "delegation_launch_failed",
  "delegate_no_receipt",
  "delegate_contract_incomplete",
  "validator_failed",
  "user_requested_stop",
];

/** The five members added by #523. */
const NON_MECHANICAL: readonly string[] = [
  "premise_falsified",
  "external_dependency",
  "policy_hold",
  "awaiting_ci",
  "human_decision_required",
];

/** Out-of-vocabulary strings, case variants, and non-string values. */
const INVALID_VALUES: readonly unknown[] = [
  "halted",
  "Premise_Falsified",
  7,
  ["none"],
  { k: "none" },
];

/**
 * Load the committed oracle as a mapping of partition name to sorted members.
 *
 * @returns The parsed oracle.
 * @throws Error when the oracle is not an object of string arrays.
 */
function loadOracle(): Record<string, string[]> {
  const parsed: unknown = JSON.parse(
    fs.readFileSync(PARTITION_ORACLE_PATH, "utf-8"),
  );
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error("partition oracle must be a JSON object.");
  }
  const result: Record<string, string[]> = {};
  for (const [key, value] of Object.entries(parsed)) {
    if (
      !Array.isArray(value) ||
      !value.every((entry: unknown) => typeof entry === "string")
    ) {
      throw new Error(`partition oracle key ${key} must be a string array.`);
    }
    result[key] = value as string[];
  }
  return result;
}

describe("orchestrator-state blocked_reason partitions", () => {
  it("keeps the two partitions disjoint and free of none", () => {
    // Act
    const overlap = [...MECHANICAL_BLOCKED_REASONS].filter((member) =>
      NON_MECHANICAL_BLOCKED_REASONS.has(member),
    );

    // Assert
    expect(overlap).toEqual([]);
    expect(MECHANICAL_BLOCKED_REASONS.has("none")).toBe(false);
    expect(NON_MECHANICAL_BLOCKED_REASONS.has("none")).toBe(false);
  });

  it("publishes the vocabulary as none plus both partitions", () => {
    // Arrange
    const expected = [
      "none",
      ...MECHANICAL_BLOCKED_REASONS,
      ...NON_MECHANICAL_BLOCKED_REASONS,
    ].sort();

    // Act
    const actual = [...MODULE_VALID_BLOCKED_REASONS].sort();

    // Assert
    expect(actual).toEqual(expected);
    expect(actual).toHaveLength(12);
  });

  it("matches the committed partition oracle", () => {
    // Arrange
    const oracle = loadOracle();

    // Act
    const actual = {
      not_blocked: ["none"],
      mechanical: [...MECHANICAL_BLOCKED_REASONS].sort(),
      non_mechanical: [...NON_MECHANICAL_BLOCKED_REASONS].sort(),
    };

    // Assert
    expect(actual).toEqual(oracle);
  });

  it("is the same set the core validator exports", () => {
    // Assert
    expect(CORE_VALID_BLOCKED_REASONS).toBe(MODULE_VALID_BLOCKED_REASONS);
  });
});

describe("classifyBlockedReason", () => {
  it.each([null, undefined, "none"])(
    "classifies %p as not_blocked",
    (value) => {
      // Act
      const result = classifyBlockedReason(value);

      // Assert
      expect(result).toBe("not_blocked");
    },
  );

  it.each(MECHANICAL)("classifies %s as mechanical", (value) => {
    // Act
    const result = classifyBlockedReason(value);

    // Assert
    expect(result).toBe("mechanical");
  });

  it.each(NON_MECHANICAL)("classifies %s as non_mechanical", (value) => {
    // Act
    const result = classifyBlockedReason(value);

    // Assert
    expect(result).toBe("non_mechanical");
  });

  it.each(INVALID_VALUES.map((value) => [value]))(
    "rejects %p with a RangeError",
    (value) => {
      // Act
      const act = (): unknown => classifyBlockedReason(value);

      // Assert
      expect(act).toThrow(RangeError);
      expect(act).toThrow(/^invalid blocked_reason: /);
    },
  );
});
