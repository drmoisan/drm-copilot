import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateConcurrentReviewCompletion } from "../../../src/lib/validate/orchestrator-state-concurrent-review";
import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";

/**
 * Pin the checkpoint rule of `review_mode: "concurrent"` (issue #1097, stage C).
 *
 * Purpose:
 *     The committed corpus binds this port to the Python rule and the PowerShell
 *     rule. The remaining cases prove that `requireComplete` reports the review
 *     error only under the key, and that plain validation ignores the key.
 *
 * Filesystem access:
 *     Read-only loads of the committed corpus, the back-compat checkpoint
 *     `none.json`, and `config/orchestration-routing.json`, resolved from
 *     `__dirname`. No file is written and no process is started.
 */

/** Repository root, five levels up from this directory. */
const REPO_ROOT = path.resolve(__dirname, "..", "..", "..", "..", "..");

/** Committed corpus directory. */
const CORPUS_DIR = path.join(
  REPO_ROOT,
  "tests",
  "fixtures",
  "orchestrator_state_concurrent_review",
);

/** Committed base checkpoint. */
const BASE_CHECKPOINT_PATH = path.join(
  REPO_ROOT,
  "tests",
  "fixtures",
  "orchestrator_state_blocked_reason_backcompat",
  "none.json",
);

/** Floor on corpus size, matching the Python and PowerShell readers. */
const MINIMUM_CORPUS_COUNT = 12;

/** The error `requireComplete` adds for a checkpoint with no review record. */
const NOT_PASSED_ERROR =
  "Checkpoint completion validation failed: review_mode concurrent requires a last review_outcomes entry with verdict PASS.";

/** The real routing matrix, read once. */
const ROUTING_MATRIX: unknown = JSON.parse(
  fs.readFileSync(
    path.join(REPO_ROOT, "config", "orchestration-routing.json"),
    "utf8",
  ),
);

/** One parsed corpus case. */
interface CorpusFixture {
  /** Case identifier, equal to the file stem. */
  readonly name: string;
  /** The checkpoint passed to the rule. */
  readonly checkpoint: Record<string, unknown>;
  /** The ordered errors every runtime must emit. */
  readonly expected_errors: readonly string[];
}

/** Corpus file names in sorted order. */
const CORPUS_FILES: readonly string[] = fs
  .readdirSync(CORPUS_DIR)
  .filter((entry) => entry.endsWith(".json"))
  .sort((left, right) => (left < right ? -1 : 1));

/**
 * Read one committed corpus file.
 *
 * @param fileName Corpus file name.
 * @returns The parsed fixture.
 */
function loadFixture(fileName: string): CorpusFixture {
  return JSON.parse(
    fs.readFileSync(path.join(CORPUS_DIR, fileName), "utf8"),
  ) as CorpusFixture;
}

/**
 * Return the base checkpoint text with top-level changes.
 *
 * @param changes Keys to set.
 * @returns The checkpoint as JSON text.
 */
function checkpointText(changes: Record<string, unknown>): string {
  const checkpoint = JSON.parse(
    fs.readFileSync(BASE_CHECKPOINT_PATH, "utf8"),
  ) as Record<string, unknown>;
  return JSON.stringify({ ...checkpoint, ...changes }, null, 2);
}

describe("orchestrator-state concurrent review", () => {
  it.each(CORPUS_FILES)("matches the corpus for %s", (fileName) => {
    // Arrange
    const fixture = loadFixture(fileName);

    // Act
    const observed = validateConcurrentReviewCompletion(fixture.checkpoint);

    // Assert
    expect(fixture.name).toBe(path.basename(fileName, ".json"));
    expect(observed).toEqual(fixture.expected_errors);
  });

  it("meets the corpus floor", () => {
    expect(CORPUS_FILES.length).toBeGreaterThanOrEqual(MINIMUM_CORPUS_COUNT);
  });

  it("reports the review error under requireComplete", () => {
    // Arrange
    const options = { requireComplete: true, routingMatrix: ROUTING_MATRIX };

    // Act
    const expected = validateOrchestratorStateText(checkpointText({}), options);
    const observed = validateOrchestratorStateText(
      checkpointText({ review_mode: "concurrent" }),
      options,
    );

    // Assert
    expect(observed.filter((line) => line !== NOT_PASSED_ERROR)).toEqual(
      expected,
    );
    expect(observed.filter((line) => line === NOT_PASSED_ERROR)).toHaveLength(
      1,
    );
  });

  it("is unchanged without the key", () => {
    // Arrange
    const options = { requireComplete: true, routingMatrix: ROUTING_MATRIX };

    // Act
    const expected = validateOrchestratorStateText(checkpointText({}), options);
    const observed = validateOrchestratorStateText(
      checkpointText({ review_mode: "sequential" }),
      options,
    );

    // Assert
    expect(observed).toEqual(expected);
  });

  it("ignores review_mode in plain mode", () => {
    // Act
    const expected = validateOrchestratorStateText(checkpointText({}));
    const observed = validateOrchestratorStateText(
      checkpointText({ review_mode: "concurrent" }),
    );

    // Assert
    expect(observed).toEqual(expected);
  });
});
