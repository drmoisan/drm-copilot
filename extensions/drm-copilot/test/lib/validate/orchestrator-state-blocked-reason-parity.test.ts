import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";

/**
 * Cross-runtime parity assertions over the `blocked_reason` corpus (#523).
 *
 * Purpose:
 *     Assert that this runtime emits exactly the `blocked_reason` errors each
 *     `tests/fixtures/orchestrator_state_blocked_reason/*.json` file records. The
 *     Python suite `tests/scripts/dev_tools/test_orchestrator_state_blocked_reason_parity.py`
 *     and the Pester suite `OrchestratorStateBlockedReason.Parity.Tests.ps1`
 *     assert the same files, so the corpus binds the three runtimes. The pattern
 *     follows `parallel-cohort-barrier-parity.test.ts`.
 *
 * Filesystem access:
 *     Read-only loads of the committed corpus and partition oracle resolved from
 *     `__dirname`. No temporary file is created and no file is mutated.
 */

/**
 * Committed fixtures root, five levels up from this directory: `validate` ->
 * `lib` -> `test` -> `drm-copilot` -> `extensions` -> repository root.
 */
const FIXTURES_ROOT = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
);

/** Committed corpus directory. */
const CORPUS_DIR = path.join(
  FIXTURES_ROOT,
  "orchestrator_state_blocked_reason",
);

/** Committed partition oracle. */
const PARTITION_ORACLE_PATH = path.join(
  FIXTURES_ROOT,
  "orchestrator_state_blocked_reason_partition.json",
);

/** Corpus file extension. */
const CORPUS_SUFFIX = ".json";

/** Floor on corpus size, so an empty enumeration cannot pass vacuously. */
const MINIMUM_CORPUS_COUNT = 20;

/** Substring every compared error contains. */
const BLOCKED_REASON_SUBSTRING = "blocked_reason";

/** The existing completion message, quoted from the specification. */
const COMPLETION_MESSAGE =
  "Checkpoint completion validation failed: blocked_reason is not `none`.";

/**
 * Focused routing matrix injected under `requireComplete`, declared the same
 * way as `orchestrator-state-core.completion.test.ts`.
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
 * Narrow an unknown JSON value to a plain object.
 *
 * @param value Parsed JSON value.
 * @param label Label used in the failure message.
 * @returns The validated object.
 * @throws Error when the value is not a plain JSON object.
 */
function requireObject(value: unknown, label: string): Record<string, unknown> {
  if (typeof value !== "object" || value === null || Array.isArray(value)) {
    throw new Error(`${label} must be a JSON object.`);
  }
  return value as Record<string, unknown>;
}

/**
 * Narrow an unknown JSON value to a string list.
 *
 * @param value Parsed JSON value.
 * @param label Label used in the failure message.
 * @returns The validated list.
 * @throws Error when the value is not an array of strings.
 */
function requireStringList(value: unknown, label: string): string[] {
  if (
    !Array.isArray(value) ||
    !value.every((entry: unknown) => typeof entry === "string")
  ) {
    throw new Error(`${label} must be an array of strings.`);
  }
  return value as string[];
}

/**
 * Load one corpus case by file name.
 *
 * @param fileName Corpus file name.
 * @returns The parsed case object.
 */
function loadCase(fileName: string): Record<string, unknown> {
  return requireObject(
    JSON.parse(fs.readFileSync(path.join(CORPUS_DIR, fileName), "utf-8")),
    fileName,
  );
}

/**
 * Keep only the errors that mention `blocked_reason`, in order.
 *
 * @param errors Validator output.
 * @returns The filtered errors.
 */
function filtered(errors: string[]): string[] {
  return errors.filter((error) => error.includes(BLOCKED_REASON_SUBSTRING));
}

/** Corpus file names discovered at collection time, sorted. */
const CORPUS_FILES: readonly string[] = fs
  .readdirSync(CORPUS_DIR)
  .filter((name) => name.endsWith(CORPUS_SUFFIX))
  .sort();

/** Corpus file names that carry `expected_completion_errors`. */
const COMPLETION_FILES: readonly string[] = CORPUS_FILES.filter(
  (name) => "expected_completion_errors" in loadCase(name),
);

/** The non-mechanical members read from the committed partition oracle. */
const NON_MECHANICAL: readonly string[] = requireStringList(
  requireObject(
    JSON.parse(fs.readFileSync(PARTITION_ORACLE_PATH, "utf-8")),
    "partition oracle",
  )["non_mechanical"],
  "partition oracle non_mechanical",
);

describe("orchestrator-state blocked_reason corpus parity", () => {
  it("discovers at least the minimum corpus count", () => {
    // Assert
    expect(CORPUS_FILES.length).toBeGreaterThanOrEqual(MINIMUM_CORPUS_COUNT);
  });

  it("discovers every JSON file on disk", () => {
    // Act
    const onDisk = fs
      .readdirSync(CORPUS_DIR, { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.endsWith(CORPUS_SUFFIX))
      .map((entry) => entry.name)
      .sort();

    // Assert
    expect([...CORPUS_FILES]).toEqual(onDisk);
  });

  for (const fileName of CORPUS_FILES) {
    const stem = fileName.slice(0, -CORPUS_SUFFIX.length);

    it(`${stem}: name equals the file stem`, () => {
      // Act
      const testCase = loadCase(fileName);

      // Assert
      expect(testCase["name"]).toBe(stem);
    });

    it(`${stem}: plain blocked_reason errors match the corpus`, () => {
      // Arrange
      const testCase = loadCase(fileName);
      const text = JSON.stringify(testCase["checkpoint"]);
      const expected = requireStringList(
        testCase["expected_errors"],
        `${stem}.expected_errors`,
      );

      // Act
      const actual = filtered(validateOrchestratorStateText(text));

      // Assert
      expect(actual).toEqual(expected);
    });
  }

  for (const fileName of COMPLETION_FILES) {
    const stem = fileName.slice(0, -CORPUS_SUFFIX.length);

    it(`${stem}: completion blocked_reason errors match the corpus`, () => {
      // Arrange
      const testCase = loadCase(fileName);
      const text = JSON.stringify(testCase["checkpoint"]);
      const expected = requireStringList(
        testCase["expected_completion_errors"],
        `${stem}.expected_completion_errors`,
      );

      // Act
      const actual = filtered(
        validateOrchestratorStateText(text, {
          requireComplete: true,
          routingMatrix: ROUTING_MATRIX,
        }),
      );

      // Assert
      expect(actual).toEqual(expected);
    });
  }

  it.each(NON_MECHANICAL)(
    "%s blocks completion with exactly one existing message",
    (member) => {
      // Arrange
      const checkpoint = requireObject(
        loadCase("completion_clear_none.json")["checkpoint"],
        "completion_clear_none.checkpoint",
      );
      const text = JSON.stringify({ ...checkpoint, blocked_reason: member });

      // Act
      const errors = validateOrchestratorStateText(text, {
        requireComplete: true,
        routingMatrix: ROUTING_MATRIX,
      });

      // Assert
      expect(
        errors.filter((error) => error === COMPLETION_MESSAGE),
      ).toHaveLength(1);
    },
  );
});
