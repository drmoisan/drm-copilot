import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";
import { validatePlannerWorktrees } from "../../../src/lib/validate/epic-planner-state-planner-worktrees";

/**
 * Cross-runtime parity assertions over the planner_worktrees corpus (issue #1161).
 *
 * Purpose:
 *     Assert that `validateEpicPlannerStateText` emits exactly the ordered
 *     errors each `tests/fixtures/epic_planner_state_planner_worktrees/*.json`
 *     file records in `expected_errors`. The Python suite
 *     `tests/scripts/dev_tools/test_validate_epic_planner_state_planner_worktrees.py`
 *     asserts the same files, so the corpus binds the two runtimes.
 *
 * Filesystem access:
 *     Read-only loads of the committed corpus, resolved from `__dirname`. No
 *     file is written, no process is started, and no clock, timer, or
 *     randomness is used.
 */

/** Repository root, five levels up from this directory. */
const REPO_ROOT = path.resolve(__dirname, "..", "..", "..", "..", "..");

/** Committed corpus directory. */
const CORPUS_DIR = path.join(
  REPO_ROOT,
  "tests",
  "fixtures",
  "epic_planner_state_planner_worktrees",
);

/** The planned corpus size; a smaller enumeration would pass vacuously. */
const EXPECTED_CORPUS_COUNT = 17;

/** The existing parallelism error, used to pin the planner errors' position. */
const MAX_PARALLEL_ERROR =
  "Epic planner checkpoint max_parallel_features must be an integer " +
  "from 1 through 8.";

/** One parsed and structurally guarded corpus case. */
interface CorpusCase {
  /** Case identifier, equal to the file stem. */
  readonly name: string;
  /** The checkpoint passed to the validator. */
  readonly checkpoint: Record<string, unknown>;
  /** The ordered errors both runtimes must emit. */
  readonly expected: readonly string[];
}

/**
 * Narrow an unknown corpus value to a plain JSON object.
 *
 * @param value Value read from a parsed corpus file.
 * @param label Corpus path used in the failure message.
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
 * Read and guard one committed corpus file.
 *
 * @param fileName Corpus file name within {@link CORPUS_DIR}.
 * @returns The guarded case.
 * @throws Error when a key is missing or `name` does not equal the file stem.
 */
function loadCase(fileName: string): CorpusCase {
  const parsed: unknown = JSON.parse(
    fs.readFileSync(path.join(CORPUS_DIR, fileName), "utf8"),
  );
  const fixture = requireObject(parsed, fileName);
  const stem = path.basename(fileName, ".json");
  if (fixture["name"] !== stem) {
    throw new Error(`${fileName}.name must equal the file stem ${stem}.`);
  }
  const expected = fixture["expected_errors"];
  if (
    !Array.isArray(expected) ||
    !expected.every((e) => typeof e === "string")
  ) {
    throw new Error(`${fileName}.expected_errors must be a string array.`);
  }
  return {
    name: stem,
    checkpoint: requireObject(fixture["checkpoint"], `${fileName}.checkpoint`),
    expected: expected as string[],
  };
}

/** Every guarded corpus case, loaded once in sorted order. */
const CORPUS: readonly CorpusCase[] = fs
  .readdirSync(CORPUS_DIR)
  .filter((fileName) => fileName.endsWith(".json"))
  .sort()
  .map(loadCase);

/**
 * Find a corpus case by name.
 *
 * @param name The case name.
 * @returns The case.
 * @throws Error when no case carries the name.
 */
function findCase(name: string): CorpusCase {
  const found = CORPUS.find((entry) => entry.name === name);
  if (found === undefined) {
    throw new Error(`corpus case ${name} is missing`);
  }
  return found;
}

describe("planner_worktrees corpus discovery", () => {
  it("holds exactly the planned number of files", () => {
    expect(CORPUS).toHaveLength(EXPECTED_CORPUS_COUNT);
  });

  it("exercises both an empty and a non-empty expected error list", () => {
    expect(CORPUS.some((entry) => entry.expected.length === 0)).toBe(true);
    expect(CORPUS.some((entry) => entry.expected.length > 0)).toBe(true);
  });
});

describe("planner_worktrees validator parity", () => {
  it.each(CORPUS.map((entry) => ({ ...entry })))(
    "reproduces the expected errors for $name",
    ({ checkpoint, expected }) => {
      const actual = validateEpicPlannerStateText(JSON.stringify(checkpoint));
      expect(actual).toEqual(expected);
    },
  );

  it.each(CORPUS.map((entry) => ({ ...entry })))(
    "reports no error for $name once the key is removed",
    ({ checkpoint }) => {
      const withoutKey = { ...checkpoint };
      delete withoutKey["planner_worktrees"];
      expect(validateEpicPlannerStateText(JSON.stringify(withoutKey))).toEqual(
        [],
      );
    },
  );

  it("appends planner errors after the max_parallel_features error", () => {
    const base = findCase("wrong-purpose");
    const checkpoint = { ...base.checkpoint, max_parallel_features: 9 };
    expect(validateEpicPlannerStateText(JSON.stringify(checkpoint))).toEqual([
      MAX_PARALLEL_ERROR,
      ...base.expected,
    ]);
  });

  it("returns no error from the module when the key is absent", () => {
    expect(validatePlannerWorktrees({}, [])).toEqual([]);
  });
});
