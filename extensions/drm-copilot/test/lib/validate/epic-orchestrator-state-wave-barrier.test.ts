import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";

/**
 * Start-guard parity assertions for the epic wave-barrier ordering invariant.
 *
 * Purpose:
 *     Build one epic checkpoint per case of the committed fixture
 *     `tests/fixtures/epic_wave_barrier/start-guard-matrix.json` (the fixture
 *     envelope plus the case's `features`), validate it through the public entry
 *     point `validateEpicOrchestratorStateText` with default options, and compare
 *     the errors that begin with `EPIC_WAVE_BARRIER_VIOLATION: `, in order, with
 *     the case's `expected_barrier_errors`. The Python suite
 *     `tests/scripts/dev_tools/test_validate_epic_orchestrator_state_wave_barrier.py`
 *     asserts the same fixture, so both runtimes are pinned to one set of strings.
 *
 * Filesystem access:
 *     The only filesystem access is the read-only load of the committed fixture,
 *     resolved from `__dirname`. No temporary file is created and no process is
 *     started.
 */

/**
 * Committed fixture path, five levels up from this directory: `validate` ->
 * `lib` -> `test` -> `drm-copilot` -> `extensions` -> repository root.
 */
const FIXTURE_PATH = path.resolve(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "epic_wave_barrier",
  "start-guard-matrix.json",
);

/** Prefix that identifies a wave-barrier error in validator output. */
const BARRIER_PREFIX = "EPIC_WAVE_BARRIER_VIOLATION: ";

/** One structurally guarded fixture case. */
interface StartGuardCase {
  /** Kebab-case case identifier. */
  readonly name: string;
  /** The `features[]` array placed into the envelope. */
  readonly features: unknown[];
  /** The ordered barrier errors the validator must emit. */
  readonly expected: readonly string[];
}

/**
 * Type guard narrowing an unknown value to a plain JSON object.
 *
 * @param value Candidate value.
 * @returns True when the value is a non-null, non-array object.
 */
function isJsonObject(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Narrow an unknown value to a plain JSON object.
 *
 * @param value Value read from the parsed fixture.
 * @param label Fixture path used in the failure message.
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
 * Narrow an unknown value to an array.
 *
 * @param value Value read from the parsed fixture.
 * @param label Fixture path used in the failure message.
 * @returns The validated array.
 * @throws Error when the value is not an array.
 */
function requireArray(value: unknown, label: string): unknown[] {
  if (!Array.isArray(value)) {
    throw new Error(`${label} must be an array.`);
  }
  return value as unknown[];
}

/**
 * Narrow an unknown value to a string.
 *
 * @param value Value read from the parsed fixture.
 * @param label Fixture path used in the failure message.
 * @returns The validated string.
 * @throws Error when the value is not a string.
 */
function requireString(value: unknown, label: string): string {
  if (typeof value !== "string") {
    throw new Error(`${label} must be a string.`);
  }
  return value;
}

const fixture = requireObject(
  JSON.parse(fs.readFileSync(FIXTURE_PATH, "utf8")) as unknown,
  "fixture",
);
const envelope = requireObject(fixture["envelope"], "fixture.envelope");
const cases: StartGuardCase[] = requireArray(
  fixture["cases"],
  "fixture.cases",
).map((rawCase, index) => {
  const label = `fixture.cases[${String(index)}]`;
  const caseObject = requireObject(rawCase, label);
  return {
    name: requireString(caseObject["name"], `${label}.name`),
    features: requireArray(caseObject["features"], `${label}.features`),
    expected: requireArray(
      caseObject["expected_barrier_errors"],
      `${label}.expected_barrier_errors`,
    ).map((entry, entryIndex) =>
      requireString(
        entry,
        `${label}.expected_barrier_errors[${String(entryIndex)}]`,
      ),
    ),
  };
});

/**
 * Validate the envelope plus the given features and keep only barrier errors.
 *
 * @param features The `features[]` array placed into the envelope.
 * @returns Validator errors that start with the barrier prefix, in order.
 */
function barrierErrorsFor(features: unknown[]): string[] {
  const document = { ...envelope, features };
  return validateEpicOrchestratorStateText(JSON.stringify(document)).filter(
    (error) => error.startsWith(BARRIER_PREFIX),
  );
}

describe("epic wave-barrier start guard", () => {
  it("has fourteen uniquely named cases", () => {
    // Arrange
    const names = cases.map((testCase) => testCase.name);

    // Act
    const uniqueNames = new Set(names);

    // Assert
    expect(names).toHaveLength(14);
    expect(uniqueNames.size).toBe(names.length);
  });

  it.each(cases.map((testCase) => [testCase.name, testCase] as const))(
    "start-guard matrix case %s",
    (_name, testCase) => {
      // Arrange
      const { features, expected } = testCase;

      // Act
      const actual = barrierErrorsFor(features);

      // Assert
      expect(actual).toEqual(expected);
    },
  );

  it("reports a list-valued dependency merge_status as not merged", () => {
    // Arrange
    const features: unknown[] = [
      {
        feature_folder: "2026-09-29-alpha-901",
        issue_num: 901,
        depends_on: [],
        merge_status: ["merged"],
      },
      {
        feature_folder: "2026-09-29-bravo-902",
        issue_num: 902,
        depends_on: ["2026-09-29-alpha-901"],
        merge_status: "worktree_created",
      },
    ];

    // Act
    const actual = barrierErrorsFor(features);

    // Assert
    expect(actual).toEqual([
      "EPIC_WAVE_BARRIER_VIOLATION: 2026-09-29-bravo-902 is treated as started while dependency 2026-09-29-alpha-901 is not merged",
    ]);
  });
});
