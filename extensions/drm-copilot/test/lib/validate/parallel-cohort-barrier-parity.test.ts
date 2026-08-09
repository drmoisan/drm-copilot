import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateArtifact } from "../../../src/lib/validate/orchestration-artifacts";

/**
 * Cross-runtime parity assertions over the committed cohort-barrier corpus.
 *
 * Purpose:
 *     Assert that this runtime emits exactly the barrier messages each
 *     `tests/fixtures/parallel_cohort_barrier/*.json` file records in its
 *     `expected_barrier_errors` block, in that order. The Python counterpart
 *     `tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py` asserts
 *     the SAME files, so the corpus is the single artifact that binds the two
 *     runtimes; neither suite may relax an expectation without the other
 *     observing the change.
 *
 * Why a shared corpus rather than two per-side suites:
 *     The parallel-orchestration epic has shipped the producer/consumer
 *     divergence defect three times, each time with both language surfaces at
 *     full per-side coverage. Per-side coverage is structurally blind to
 *     divergence: each suite can be complete and internally consistent while the
 *     two surfaces disagree. The pattern follows the blast-radius precedent,
 *     `tests/scripts/dev_tools/test_blast_radius_parity.py` and
 *     `tests/scripts/claude-lib/blast-radius/BlastRadius.Parity.Tests.ps1`
 *     against `tests/fixtures/blast_radius`.
 *
 * Filesystem access:
 *     The only filesystem access is the read-only load of the committed corpus,
 *     resolved from `__dirname`. No temporary file is created, no file is
 *     mutated, no process is started, and no clock, timer, or randomness is
 *     used. The corpus files are committed fixtures, not temporary files.
 *
 * Binding discipline:
 *     Every case routes through the dispatched public entry point
 *     `validateArtifact({ artifactType: "parallel-orchestrator-state", text })`,
 *     and this module imports the barrier invariant module nowhere -- not even by
 *     name, so the negative search that proves the discipline stays clean.
 *     Exercising the dispatched entry point is what proves the F7 seam in
 *     `parallel-orchestrator-state-core.ts` is genuinely parsed and reached at run
 *     time, which a helper-only import cannot show.
 *
 * Parity claim scope:
 *     Only barrier messages are compared: both suites filter validator output to
 *     the strings beginning with the literal violation token before asserting.
 *     Corpus documents are restricted to JSON-representable values that
 *     round-trip through both runtimes' native types, so the three divergence
 *     classes recorded in `.claude/rules/parallel-orchestration.md` —
 *     `pythonRepr` quote selection, integral floats erased by `JSON.parse`, and
 *     boolean/integer equality — are avoided rather than fixed.
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
  "parallel_cohort_barrier",
);

/** Corpus file extension, used by both the discovery glob and the count guard. */
const CORPUS_SUFFIX = ".json";

/**
 * Floor on corpus size. An empty or partially matched enumeration would make
 * every case below disappear and the suite would pass vacuously, so the count is
 * asserted twice: against this floor and against the files on disk.
 */
const MINIMUM_CORPUS_COUNT = 30;

/**
 * Literal invariant token, restated here from design section 9 rather than
 * imported from the new module, so the filter is pinned to the specification and
 * not to the implementation's own constant.
 */
const VIOLATION_LABEL = "PARALLEL_COHORT_BARRIER_VIOLATION";

/** The four keys every corpus file must carry. */
const REQUIRED_FIXTURE_KEYS: readonly string[] = [
  "name",
  "notes",
  "document",
  "expected_barrier_errors",
];

/** One parsed and structurally guarded corpus case. */
interface CorpusCase {
  /** Kebab-case case identifier, equal to the file stem. */
  readonly name: string;
  /** The checkpoint document to submit to the dispatched validator. */
  readonly document: Record<string, unknown>;
  /** The ordered barrier messages both runtimes must emit for that document. */
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
 * Narrow an unknown corpus value to an array of barrier messages.
 *
 * @param value Value read from a parsed corpus file.
 * @param label Dotted corpus path used in the failure message.
 * @returns The expected messages in corpus order. An empty array is valid and
 * means the barrier holds for that document.
 * @throws Error when the value is not an array, holds a non-string entry, or
 * holds an entry that does not begin with the violation token, which would put
 * an unrelated expectation inside the barrier comparison.
 */
function requireMessageList(value: unknown, label: string): string[] {
  if (!Array.isArray(value)) {
    throw new Error(`${label} must be a JSON array.`);
  }
  // Validate every entry as it is read so a malformed corpus fails at load time
  // naming the offending record rather than inside an assertion body.
  const messages: string[] = [];
  value.forEach((entry: unknown, index: number) => {
    const message = requireText(entry, `${label}[${index}]`);
    if (!message.startsWith(VIOLATION_LABEL)) {
      throw new Error(`${label}[${index}] must begin with ${VIOLATION_LABEL}.`);
    }
    messages.push(message);
  });
  return messages;
}

/**
 * Read, parse, and structurally guard one committed corpus file.
 *
 * @param fileName Corpus file name within {@link CORPUS_DIR}.
 * @returns The guarded case.
 * @throws Error when the file does not parse to a JSON object, a required key is
 * absent, a field has the wrong type, or `name` does not equal the file stem —
 * which would let a case be silently renamed away from the file the Python suite
 * reads.
 */
function loadCase(fileName: string): CorpusCase {
  const filePath = path.join(CORPUS_DIR, fileName);
  const parsed: unknown = JSON.parse(fs.readFileSync(filePath, "utf8"));
  const fixture = requireObject(parsed, fileName);

  // Guard the whole key set before any field is read, so a partially authored
  // corpus file reports the missing key rather than a confusing type error.
  for (const key of REQUIRED_FIXTURE_KEYS) {
    if (!(key in fixture)) {
      throw new Error(`${fileName} must carry the key ${key}.`);
    }
  }

  const stem = path.basename(fileName, CORPUS_SUFFIX);
  const name = requireText(fixture["name"], `${fileName}.name`);
  if (name !== stem) {
    throw new Error(`${fileName}.name must equal the file stem ${stem}.`);
  }
  requireText(fixture["notes"], `${fileName}.notes`);

  return {
    name,
    document: requireObject(fixture["document"], `${fileName}.document`),
    expected: requireMessageList(
      fixture["expected_barrier_errors"],
      `${fileName}.expected_barrier_errors`,
    ),
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
 * Return only the barrier messages the dispatched validator emits for one
 * document.
 *
 * @param document One corpus checkpoint document.
 * @returns The validator's error strings filtered to those beginning with the
 * violation token, in the order the validator produced them. Filtering isolates
 * the parity claim from the F3 shape errors a deliberately malformed collection
 * also reports.
 */
function barrierErrors(document: Record<string, unknown>): string[] {
  const errors = validateArtifact({
    artifactType: "parallel-orchestrator-state",
    text: JSON.stringify(document),
  });
  return errors.filter((error) => error.startsWith(VIOLATION_LABEL));
}

describe("parallel cohort-barrier corpus parity", () => {
  it("meets the documented minimum corpus size", () => {
    // Arrange: the corpus is discovered at module evaluation.
    // Act
    const discovered = CORPUS_FILE_NAMES.length;

    // Assert: a short corpus would silently drop behavior classes the parity
    // claim depends on, and an empty one would make the suite pass vacuously.
    expect(discovered).toBeGreaterThanOrEqual(MINIMUM_CORPUS_COUNT);
  });

  it("discovers every JSON file that exists in the corpus directory", () => {
    // Arrange: enumerate the directory independently of the discovery filter, so
    // a filter that silently skipped files would be caught, not reproduced.
    const onDisk = fs
      .readdirSync(CORPUS_DIR, { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.endsWith(CORPUS_SUFFIX));

    // Act / Assert: the two counts must agree, otherwise the Python suite and
    // this one could be iterating different subsets of the same directory.
    expect(CORPUS_FILE_NAMES.length).toBe(onDisk.length);
    expect(CORPUS_CASES.length).toBe(onDisk.length);
  });

  it("exercises both a violating and a barrier-satisfying document", () => {
    // Arrange / Act
    const violating = CORPUS_CASES.filter((entry) => entry.expected.length > 0);
    const clean = CORPUS_CASES.filter((entry) => entry.expected.length === 0);

    // Assert: an all-clean corpus would never exercise the message-emitting
    // path, and an all-violating corpus would never exercise the gating paths.
    expect(violating.length).toBeGreaterThan(0);
    expect(clean.length).toBeGreaterThan(0);
  });

  // One case per corpus file, driven through the dispatched public entry point so
  // the F7 seam is parsed and reached on every run of this suite.
  it.each(CORPUS_CASES)(
    "reproduces the expected barrier errors for $name",
    (corpusCase: CorpusCase) => {
      // Arrange: the corpus document and its ordered expectation.
      // Act
      const observed = barrierErrors(corpusCase.document);

      // Assert: element for element and in order, which is the same comparison
      // the Python suite performs against the same file.
      expect(observed).toEqual(corpusCase.expected);
    },
  );
});
