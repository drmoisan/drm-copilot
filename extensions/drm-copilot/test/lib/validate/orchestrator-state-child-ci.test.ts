import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  isChildCiIntegrationOnly,
  validateCompletionGateEvidence,
} from "../../../src/lib/validate/orchestrator-state-child-ci";
import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";

/**
 * Pin the completion rule of `child_ci: integration_only` (issue #1233).
 *
 * Purpose:
 *     The committed corpus binds this port to the Python and PowerShell
 *     validators: each file records a checkpoint and the ordered errors the
 *     completion gate selection must return. Two rows drive the core validator
 *     with completion required, proving the selection inside the CI-gated
 *     route branch.
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
  "orchestrator_state_child_ci",
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
const MINIMUM_CORPUS_COUNT = 13;

/** A reviewed head shared by the review outcome and the local gate. */
const REVIEWED_HEAD = "3f2a9c1e5b7d4a6f8e0c2b4d6a8f0e1c3b5d7a9f";

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
  /** The checkpoint passed to the selection. */
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
 * Return the base checkpoint text with the opt-out keys and optional changes.
 *
 * @param changes Top-level keys to set after the opt-out keys.
 * @param removed Top-level keys to delete.
 * @returns The checkpoint as JSON text.
 */
function optOutCheckpointText(
  changes: Record<string, unknown>,
  removed: readonly string[],
): string {
  const checkpoint = JSON.parse(
    fs.readFileSync(BASE_CHECKPOINT_PATH, "utf8"),
  ) as Record<string, unknown>;
  const merged: Record<string, unknown> = {
    ...checkpoint,
    epic_mode: true,
    child_ci: "integration_only",
    review_mode: "concurrent",
    remediation_loop: {
      review_outcomes: [{ verdict: "PASS", head_sha: REVIEWED_HEAD }],
    },
    local_qc_gate: {
      conclusion: "success",
      head_sha: REVIEWED_HEAD,
      evidence_path:
        "docs/features/active/feature-1/evidence/qa-gates/local-qc-gate.2026-11-24T05-00.md",
      verified_at: "2026-11-24T05:00:00Z",
    },
    ...changes,
  };
  for (const key of removed) {
    delete merged[key];
  }
  return JSON.stringify(merged, null, 2);
}

/**
 * Report whether an error line comes from either completion gate check.
 *
 * @param line One validator error.
 * @returns True for a `ci_gate`, `local_qc_gate`, or `child_ci` error.
 */
function isGateError(line: string): boolean {
  return (
    line.includes("ci_gate") ||
    line.includes("local_qc_gate") ||
    line.includes("child_ci")
  );
}

describe("orchestrator-state child CI opt-out", () => {
  it.each(CORPUS_FILES)("matches the corpus for %s", (fileName) => {
    // Arrange
    const fixture = loadFixture(fileName);

    // Act
    const observed = validateCompletionGateEvidence(fixture.checkpoint);

    // Assert
    expect(fixture.name).toBe(path.basename(fileName, ".json"));
    expect(observed).toEqual(fixture.expected_errors);
  });

  it("meets the corpus floor", () => {
    expect(CORPUS_FILES.length).toBeGreaterThanOrEqual(MINIMUM_CORPUS_COUNT);
  });

  it("activates only for the boolean epic_mode and the exact value", () => {
    expect(
      isChildCiIntegrationOnly({
        epic_mode: true,
        child_ci: "integration_only",
      }),
    ).toBe(true);
    expect(
      isChildCiIntegrationOnly({
        epic_mode: "true",
        child_ci: "integration_only",
      }),
    ).toBe(false);
    expect(
      isChildCiIntegrationOnly({ epic_mode: true, child_ci: "per_child" }),
    ).toBe(false);
  });

  it("accepts an opted-out child without ci_gate under requireComplete", () => {
    // Arrange
    const options = { requireComplete: true, routingMatrix: ROUTING_MATRIX };

    // Act
    const observed = validateOrchestratorStateText(
      optOutCheckpointText({}, []),
      options,
    );

    // Assert
    expect(observed.filter(isGateError)).toEqual([]);
  });

  it("reports the existing ci_gate error with the opt-out removed", () => {
    // Arrange
    const options = { requireComplete: true, routingMatrix: ROUTING_MATRIX };

    // Act
    const observed = validateOrchestratorStateText(
      optOutCheckpointText({}, ["child_ci"]),
      options,
    );

    // Assert
    expect(observed.filter(isGateError)).toEqual([
      "Checkpoint completion validation failed: ci_gate must be an object with keys: conclusion, head_sha, verified_at.",
    ]);
  });
});
