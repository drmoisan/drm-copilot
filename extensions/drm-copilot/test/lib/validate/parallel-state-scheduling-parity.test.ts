import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateArtifact } from "../../../src/lib/validate/orchestration-artifacts";

/**
 * Shared corpus for the recorded scheduling decisions (issue #1164, spec B10.1).
 *
 * Each file of `tests/fixtures/parallel_state_scheduling/` holds an artifact
 * type, a complete planner or orchestrator checkpoint, and its ordered expected
 * errors. `tests/scripts/dev_tools/test_parallel_state_scheduling_parity.py`
 * runs the same files through the Python validators, so the two runtimes must
 * produce byte-identical error strings. The files are read in place; nothing
 * is written.
 */

/**
 * The corpus directory, resolved from this file: `validate` -> `lib` -> `test`
 * -> `drm-copilot` -> `extensions` -> repository root.
 */
const CORPUS_DIR = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "parallel_state_scheduling",
);

/** Floor on corpus size, so a broken read cannot make the table pass vacuously. */
const MINIMUM_CASE_COUNT = 20;

/** One parsed corpus case. */
interface SchedulingCase {
  name: string;
  artifact_type: "parallel-planner-state" | "parallel-orchestrator-state";
  checkpoint: unknown;
  expected_errors: string[];
}

/** Read every corpus case in name order. */
function loadCases(): SchedulingCase[] {
  return fs
    .readdirSync(CORPUS_DIR)
    .filter((name) => name.endsWith(".json"))
    .sort()
    .map(
      (name) =>
        JSON.parse(
          fs.readFileSync(path.join(CORPUS_DIR, name), "utf8"),
        ) as SchedulingCase,
    );
}

const CASES = loadCases();

describe("parallel state scheduling corpus (issue #1164)", () => {
  it("holds every accepted and rejecting case", () => {
    // Arrange / Act / Assert
    expect(CASES.length).toBeGreaterThanOrEqual(MINIMUM_CASE_COUNT);
  });

  it.each(CASES.map((entry) => [entry.name, entry] as const))(
    "reproduces the expected errors of %s",
    (_name, entry) => {
      // Arrange
      const text = JSON.stringify(entry.checkpoint);

      // Act
      const errors = validateArtifact({
        artifactType: entry.artifact_type,
        text,
      });

      // Assert
      expect(errors).toEqual(entry.expected_errors);
    },
  );
});
