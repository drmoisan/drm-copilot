import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateOrchestratorStateText } from "../../../src/lib/validate/orchestrator-state-core";

/**
 * Cross-runtime parity assertions over the remediation-loop corpus (issue #484).
 *
 * Purpose:
 *     Assert that this runtime emits exactly the remediation-family messages
 *     each `tests/fixtures/orchestrator_state_remediation_loop/*.json` case
 *     records in `expected_errors`, in that order. The Python suite
 *     `tests/scripts/dev_tools/test_orchestrator_state_remediation_loop_parity.py`
 *     and the Pester suite
 *     `tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1`
 *     assert the same files. The pattern follows
 *     `parallel-cohort-barrier-parity.test.ts`.
 *
 * Filesystem access:
 *     Read-only load of the committed corpus, resolved from `__dirname`. No
 *     temporary file is created and no process is started.
 *
 * Binding discipline:
 *     Every case routes through the public `validateOrchestratorStateText`
 *     entry point; this module does not import the remediation module.
 */

/**
 * Committed corpus directory, five levels up from this directory: `validate` ->
 * `lib` -> `test` -> `drm-copilot` -> `extensions` -> repository root.
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
  "orchestrator_state_remediation_loop",
);

/** Corpus file extension. */
const CORPUS_SUFFIX = ".json";

/** Floor on corpus size, equal to the Python and Pester floors. */
const MINIMUM_CORPUS_COUNT = 41;

/** Family filter restated from the spec. */
const FAMILY_SUBSTRING = "remediation";

/** The four keys every corpus file must carry. */
const REQUIRED_FIXTURE_KEYS: readonly string[] = [
  "name",
  "notes",
  "checkpoint",
  "expected_errors",
];

/** One parsed and structurally guarded corpus case. */
interface CorpusCase {
  readonly stem: string;
  readonly name: unknown;
  readonly checkpoint: Record<string, unknown>;
  readonly expected: readonly string[];
}

/**
 * Read, parse, and structurally guard one committed corpus file.
 *
 * @param fileName Corpus file name within {@link CORPUS_DIR}.
 * @returns The guarded case.
 * @throws Error when the file shape is invalid.
 */
function loadCase(fileName: string): CorpusCase {
  const parsed: unknown = JSON.parse(
    fs.readFileSync(path.join(CORPUS_DIR, fileName), "utf8"),
  );
  if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
    throw new Error(`${fileName} must be a JSON object.`);
  }
  const fixture = parsed as Record<string, unknown>;
  for (const key of REQUIRED_FIXTURE_KEYS) {
    if (!(key in fixture)) {
      throw new Error(`${fileName} must carry the key ${key}.`);
    }
  }
  const checkpoint = fixture["checkpoint"];
  if (
    typeof checkpoint !== "object" ||
    checkpoint === null ||
    Array.isArray(checkpoint)
  ) {
    throw new Error(`${fileName}.checkpoint must be a JSON object.`);
  }
  const expected = fixture["expected_errors"];
  if (
    !Array.isArray(expected) ||
    !expected.every((entry: unknown) => typeof entry === "string")
  ) {
    throw new Error(`${fileName}.expected_errors must be a list of strings.`);
  }
  return {
    stem: path.basename(fileName, CORPUS_SUFFIX),
    name: fixture["name"],
    checkpoint: checkpoint as Record<string, unknown>,
    expected: expected as string[],
  };
}

/** Every `.json` file in the corpus directory, sorted for stable case order. */
const CORPUS_FILE_NAMES: readonly string[] = fs
  .readdirSync(CORPUS_DIR)
  .filter((entry) => entry.endsWith(CORPUS_SUFFIX))
  .sort((left, right) => left.localeCompare(right));

/** The guarded cases, loaded once at module evaluation. */
const CORPUS_CASES: readonly CorpusCase[] = CORPUS_FILE_NAMES.map(loadCase);

/**
 * Return the plain-validation errors containing the family substring.
 *
 * @param checkpoint One corpus checkpoint.
 * @returns The filtered errors in validator order.
 */
function familyErrors(checkpoint: Record<string, unknown>): string[] {
  return validateOrchestratorStateText(JSON.stringify(checkpoint)).filter(
    (error) => error.includes(FAMILY_SUBSTRING),
  );
}

describe("remediation-loop corpus parity", () => {
  it("meets the minimum corpus size", () => {
    expect(CORPUS_FILE_NAMES.length).toBeGreaterThanOrEqual(
      MINIMUM_CORPUS_COUNT,
    );
  });

  it("discovers every JSON file in the corpus directory", () => {
    const onDisk = fs
      .readdirSync(CORPUS_DIR, { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.endsWith(CORPUS_SUFFIX));
    expect(CORPUS_CASES.length).toBe(onDisk.length);
  });

  it.each(CORPUS_CASES)(
    "keeps the case name equal to the file stem for $stem",
    (corpusCase: CorpusCase) => {
      expect(corpusCase.name).toBe(corpusCase.stem);
    },
  );

  it.each(CORPUS_CASES)(
    "reproduces the expected remediation errors for $stem",
    (corpusCase: CorpusCase) => {
      // Arrange / Act
      const observed = familyErrors(corpusCase.checkpoint);
      // Assert: element for element and in order.
      expect(observed).toEqual(corpusCase.expected);
    },
  );
});
