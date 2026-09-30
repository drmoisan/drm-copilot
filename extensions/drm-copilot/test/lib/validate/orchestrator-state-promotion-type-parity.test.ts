import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateRoutingContract } from "../../../src/lib/validate/orchestrator-state-routing";

/**
 * Cross-runtime parity assertions over the committed promotion-type corpus.
 *
 * Purpose:
 *     Assert that this runtime emits exactly the routing-contract errors each
 *     `tests/fixtures/orchestrator_state_promotion_type/*.json` file records in
 *     its `expected_errors` block, in that order. The Python counterpart
 *     `tests/scripts/dev_tools/test_orchestrator_state_promotion_type_parity.py`
 *     and the PowerShell counterpart
 *     `tests/scripts/claude-lib/orchestrator-state/OrchestratorStatePromotionType.Parity.Tests.ps1`
 *     assert the SAME files, so the corpus is the single artifact that binds the
 *     three runtimes.
 *
 * Filesystem access:
 *     Read-only load of the committed corpus and of
 *     `config/orchestration-routing.json`, both resolved from `__dirname`. No
 *     temporary file is created, no file is mutated, no process is started, and
 *     no clock, timer, or randomness is used.
 */

/**
 * Repository root, five levels up from this directory: `validate` -> `lib` ->
 * `test` -> `drm-copilot` -> `extensions` -> repository root.
 */
const REPO_ROOT = path.resolve(__dirname, "..", "..", "..", "..", "..");

/** Committed corpus directory. */
const CORPUS_DIR = path.join(
  REPO_ROOT,
  "tests",
  "fixtures",
  "orchestrator_state_promotion_type",
);

/** Real routing matrix, the same file the Python runtime loads. */
const ROUTING_MATRIX_PATH = path.join(REPO_ROOT, "config", "orchestration-routing.json");

/** Corpus file extension, used by both the discovery filter and the count guard. */
const CORPUS_SUFFIX = ".json";

/**
 * Floor on corpus size. An empty or partially matched enumeration would make
 * every case below disappear and the suite would pass vacuously, so the count is
 * asserted twice: against this floor and against the files on disk.
 */
const MINIMUM_CORPUS_COUNT = 12;

/** The four keys every corpus file must carry. */
const REQUIRED_FIXTURE_KEYS: readonly string[] = [
  "name",
  "notes",
  "checkpoint",
  "expected_errors",
];

/** One parsed and structurally guarded corpus case. */
interface CorpusCase {
  /** Case identifier, equal to the file stem. */
  readonly name: string;
  /** The checkpoint object submitted to the routing-contract validator. */
  readonly checkpoint: Record<string, unknown>;
  /** The ordered errors every runtime must emit for that checkpoint. */
  readonly expected: readonly string[];
}

/**
 * Type guard narrowing an unknown corpus value to a plain JSON object.
 *
 * @param value Value read from a parsed corpus file.
 * @returns True when the value is a non-null, non-array object.
 */
function isJsonObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Narrow an unknown corpus value to a plain JSON object.
 *
 * @param value Value read from a parsed corpus file.
 * @param label Dotted corpus path used in the failure message.
 * @returns The validated object.
 * @throws Error when the value is not a plain JSON object.
 */
function requireObject(value: unknown, label: string): Record<string, unknown> {
  if (!isJsonObject(value)) {
    throw new Error(`${label} must be a JSON object.`);
  }
  return value;
}

/**
 * Narrow an unknown corpus value to a non-blank JSON string.
 *
 * @param value Value read from a parsed corpus file.
 * @param label Dotted corpus path used in the failure message.
 * @returns The validated string.
 * @throws Error when the value is not a string or is blank.
 */
function requireText(value: unknown, label: string): string {
  if (typeof value !== "string") {
    throw new Error(`${label} must be a string.`);
  }
  if (value.trim().length === 0) {
    throw new Error(`${label} must not be empty.`);
  }
  return value;
}

/**
 * Narrow an unknown corpus value to an array of error strings.
 *
 * @param value Value read from a parsed corpus file.
 * @param label Dotted corpus path used in the failure message.
 * @returns The expected errors in corpus order; an empty array is valid.
 * @throws Error when the value is not an array or holds a blank or non-string entry.
 */
function requireErrorList(value: unknown, label: string): string[] {
  if (!Array.isArray(value)) {
    throw new Error(`${label} must be a JSON array.`);
  }
  const entries: unknown[] = value;
  return entries.map((entry, index) => requireText(entry, `${label}[${String(index)}]`));
}

/**
 * Read, parse, and structurally guard one committed corpus file.
 *
 * @param fileName Corpus file name inside the corpus directory.
 * @returns The guarded corpus case.
 * @throws Error when a required key is absent, a field has the wrong type, or
 *     `name` does not equal the file stem.
 */
function loadCase(fileName: string): CorpusCase {
  const stem = path.basename(fileName, CORPUS_SUFFIX);
  const parsed: unknown = JSON.parse(
    fs.readFileSync(path.join(CORPUS_DIR, fileName), "utf8"),
  );
  const fixture = requireObject(parsed, fileName);
  for (const key of REQUIRED_FIXTURE_KEYS) {
    if (!(key in fixture)) {
      throw new Error(`${fileName} must carry the key ${key}.`);
    }
  }
  const name = requireText(fixture["name"], `${fileName}.name`);
  if (name !== stem) {
    throw new Error(`${fileName}.name must equal the file stem ${stem}.`);
  }
  requireText(fixture["notes"], `${fileName}.notes`);
  return {
    name,
    checkpoint: requireObject(fixture["checkpoint"], `${fileName}.checkpoint`),
    expected: requireErrorList(fixture["expected_errors"], `${fileName}.expected_errors`),
  };
}

/** Sorted corpus file names discovered by the suffix filter. */
const CORPUS_FILES: readonly string[] = fs
  .readdirSync(CORPUS_DIR)
  .filter((entry) => entry.endsWith(CORPUS_SUFFIX))
  .sort();

/** Every guarded corpus case, loaded once at import. */
const CORPUS_CASES: readonly CorpusCase[] = CORPUS_FILES.map(loadCase);

/** The real routing matrix, parsed once. */
const ROUTING_MATRIX: unknown = JSON.parse(fs.readFileSync(ROUTING_MATRIX_PATH, "utf8"));

describe("orchestrator-state promotion-type parity corpus", () => {
  it("meets the documented minimum corpus size", () => {
    // Arrange / Act: the corpus is discovered at import.
    const discovered = CORPUS_FILES.length;

    // Assert: a short corpus would silently drop behavior classes.
    expect(discovered).toBeGreaterThanOrEqual(MINIMUM_CORPUS_COUNT);
  });

  it("discovers exactly the number of JSON files in the corpus directory", () => {
    // Arrange: enumerate the directory again, counting only files.
    const onDisk = fs
      .readdirSync(CORPUS_DIR, { withFileTypes: true })
      .filter((entry) => entry.isFile() && path.extname(entry.name) === CORPUS_SUFFIX);

    // Act / Assert: the two counts must agree.
    expect(CORPUS_CASES).toHaveLength(onDisk.length);
  });

  it("exercises both an accepted and a rejected checkpoint", () => {
    // Arrange / Act: partition the cases by expectation length.
    const rejected = CORPUS_CASES.filter((entry) => entry.expected.length > 0);
    const accepted = CORPUS_CASES.filter((entry) => entry.expected.length === 0);

    // Assert: a one-sided corpus never exercises both verdict paths.
    expect(rejected.length).toBeGreaterThan(0);
    expect(accepted.length).toBeGreaterThan(0);
  });

  it.each([...CORPUS_CASES])(
    "reproduces the expected routing-contract errors for $name",
    ({ checkpoint, expected }) => {
      // Arrange: the corpus checkpoint and its ordered expectation.
      // Act: drive the checkpoint through the public validator entry point.
      const observed = validateRoutingContract(checkpoint, {
        routingMatrix: ROUTING_MATRIX,
      });

      // Assert: element for element and in order.
      expect(observed).toEqual([...expected]);
    },
  );
});
