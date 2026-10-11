import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateRoutingContract } from "../../../src/lib/validate/orchestrator-state-routing";

/**
 * Cross-runtime parity assertions over the committed issue-adoption corpus.
 *
 * Purpose:
 *     Assert that `validateRoutingContract` emits exactly the ordered error list
 *     each `tests/fixtures/orchestrator_state_issue_adoption/*.json` file
 *     records in `expected_errors`. The Python reader
 *     `tests/scripts/dev_tools/test_orchestrator_state_issue_adoption_parity.py`
 *     and the Pester reader `OrchestratorStateIssueAdoption.Parity.Tests.ps1`
 *     assert the same files, so the corpus binds the three runtimes.
 *
 * Filesystem access:
 *     Read-only loads of the committed corpus and of
 *     `config/orchestration-routing.json`, resolved from `__dirname`. No file is
 *     written, no process is started, and no clock, timer, or randomness is used.
 */

/** Repository root, five levels up from this directory. */
const REPO_ROOT = path.resolve(__dirname, "..", "..", "..", "..", "..");

/** Committed corpus directory. */
const CORPUS_DIR = path.join(
  REPO_ROOT,
  "tests",
  "fixtures",
  "orchestrator_state_issue_adoption",
);

/** Corpus file extension, used by both the discovery filter and the count guard. */
const CORPUS_SUFFIX = ".json";

/**
 * Floor on corpus size. An empty or partially matched enumeration would make
 * every case disappear and the suite would pass vacuously.
 */
const MINIMUM_CORPUS_COUNT = 34;

/** The four keys every corpus file must carry. */
const REQUIRED_FIXTURE_KEYS: readonly string[] = [
  "name",
  "notes",
  "checkpoint",
  "expected_errors",
];

/** The real routing matrix, read once. */
const ROUTING_MATRIX: unknown = JSON.parse(
  fs.readFileSync(
    path.join(REPO_ROOT, "config", "orchestration-routing.json"),
    "utf8",
  ),
);

/** One parsed and structurally guarded corpus case. */
interface CorpusCase {
  /** Case identifier, equal to the file stem. */
  readonly name: string;
  /** The checkpoint passed to the routing contract. */
  readonly checkpoint: Record<string, unknown>;
  /** The ordered errors every runtime must emit. */
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
 * Narrow an unknown corpus value to an array of strings.
 *
 * @param value Value read from a parsed corpus file.
 * @param label Corpus path used in the failure message.
 * @returns The strings in corpus order.
 * @throws Error when the value is not an array of strings.
 */
function requireStringList(value: unknown, label: string): string[] {
  if (!Array.isArray(value)) {
    throw new Error(`${label} must be a JSON array.`);
  }
  const items: unknown[] = value;
  return items.map((entry, index) => {
    if (typeof entry !== "string") {
      throw new Error(`${label}[${index}] must be a string.`);
    }
    return entry;
  });
}

/**
 * Read, parse, and structurally guard one committed corpus file.
 *
 * @param fileName Corpus file name within {@link CORPUS_DIR}.
 * @returns The guarded case.
 * @throws Error when a key is missing, a field has the wrong type, or `name`
 * does not equal the file stem.
 */
function loadCase(fileName: string): CorpusCase {
  const parsed: unknown = JSON.parse(
    fs.readFileSync(path.join(CORPUS_DIR, fileName), "utf8"),
  );
  const fixture = requireObject(parsed, fileName);
  for (const key of REQUIRED_FIXTURE_KEYS) {
    if (!(key in fixture)) {
      throw new Error(`${fileName} must carry the key ${key}.`);
    }
  }
  const name = fixture["name"];
  const stem = path.basename(fileName, CORPUS_SUFFIX);
  if (name !== stem) {
    throw new Error(`${fileName}.name must equal the file stem ${stem}.`);
  }
  return {
    name: stem,
    checkpoint: requireObject(fixture["checkpoint"], `${fileName}.checkpoint`),
    expected: requireStringList(
      fixture["expected_errors"],
      `${fileName}.expected_errors`,
    ),
  };
}

/** Corpus file names in sorted order. */
const CORPUS_FILES: readonly string[] = fs
  .readdirSync(CORPUS_DIR)
  .filter((fileName) => fileName.endsWith(CORPUS_SUFFIX))
  .sort();

/** Every guarded corpus case, loaded once at module scope. */
const CORPUS: readonly CorpusCase[] = CORPUS_FILES.map(loadCase);

describe("issue-adoption corpus discovery", () => {
  it("meets the documented minimum corpus size", () => {
    expect(CORPUS.length).toBeGreaterThanOrEqual(MINIMUM_CORPUS_COUNT);
  });

  it("discovers exactly the number of JSON files in the corpus directory", () => {
    const onDisk = fs
      .readdirSync(CORPUS_DIR, { withFileTypes: true })
      .filter((entry) => entry.isFile() && entry.name.endsWith(CORPUS_SUFFIX));
    expect(CORPUS.length).toBe(onDisk.length);
  });

  it("exercises both an empty and a non-empty expected error list", () => {
    expect(CORPUS.some((entry) => entry.expected.length === 0)).toBe(true);
    expect(CORPUS.some((entry) => entry.expected.length > 0)).toBe(true);
  });
});

describe("issue-adoption routing-contract parity", () => {
  it.each(CORPUS.map((entry) => ({ ...entry })))(
    "reproduces the expected routing-contract errors for $name",
    ({ checkpoint, expected }) => {
      const actual = validateRoutingContract(checkpoint, {
        routingMatrix: ROUTING_MATRIX,
      });
      expect(actual).toEqual(expected);
    },
  );
});
