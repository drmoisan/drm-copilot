import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";

/**
 * Early-start parity assertions for the epic wave-barrier ordering invariant (issue #1097).
 *
 * Purpose:
 *     Build one epic checkpoint per case of the committed fixture
 *     `tests/fixtures/epic_wave_barrier/early-start-edge-cases.json` (the fixture
 *     envelope plus the case's `features`), validate it through the public entry
 *     point `validateEpicOrchestratorStateText` with default options, and compare
 *     the errors that begin with `EPIC_WAVE_BARRIER_VIOLATION: `, in order, with the
 *     case's `expected_barrier_errors`. The Python suite
 *     `tests/scripts/dev_tools/test_epic_wave_barrier_early_start.py` asserts the same
 *     fixture, so both runtimes are pinned to one set of strings.
 *
 * Filesystem access:
 *     The only filesystem access is the read-only load of the committed fixture,
 *     resolved from `__dirname`. No temporary file is created, no process is
 *     started, and nothing is mocked.
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
  "early-start-edge-cases.json",
);

/** Prefix that identifies a wave-barrier error in validator output. */
const BARRIER_PREFIX = "EPIC_WAVE_BARRIER_VIOLATION: ";

/** One structurally guarded fixture case. */
interface EarlyStartCase {
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
const cases: EarlyStartCase[] = requireArray(
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

/** The upstream feature shared by the hand-written cases below. */
const UPSTREAM = {
  feature_folder: "2026-11-08-upstream-901",
  issue_num: 901,
  depends_on: [],
  merge_status: "pr_open",
};

describe("epic wave-barrier early start", () => {
  it.each(cases.map((testCase) => [testCase.name, testCase] as const))(
    "matches the corpus for %s",
    (_name, testCase) => {
      // Arrange
      const { features, expected } = testCase;

      // Act
      const actual = barrierErrorsFor(features);

      // Assert
      expect(actual).toEqual(expected);
    },
  );

  it("reports nothing for an absent key", () => {
    // Arrange: without the key, today's status message applies to the unmerged edge.
    const features: unknown[] = [
      UPSTREAM,
      {
        feature_folder: "2026-11-08-dependent-902",
        issue_num: 902,
        depends_on: [901],
        merge_status: "worktree_created",
        worktree_created_at: "2026-11-08T10-00",
      },
    ];

    // Act
    const actual = barrierErrorsFor(features);

    // Assert: no early-start message appears, only the pre-#1097 status message.
    expect(actual).toEqual([
      "EPIC_WAVE_BARRIER_VIOLATION: 2026-11-08-dependent-902 is treated as started while dependency 901 is not merged",
    ]);
    expect(actual.some((error) => error.includes("early_start"))).toBe(false);
  });

  it("keeps the barrier errors in core order", () => {
    // Arrange: an invalid merge_status error, an early-start error, and a waves error.
    // A non-object wave, a wave without feature_folders, and a feature with an empty
    // folder ride along; core skips each of them, so they add no error of their own.
    const document = {
      ...envelope,
      waves: [
        "not-a-wave",
        { wave_number: 3 },
        { wave_number: 1, feature_folders: ["2026-11-08-upstream-901"] },
      ],
      features: [
        { feature_folder: "", depends_on: [], merge_status: "not_started" },
        { ...UPSTREAM, merge_status: "ci_green", wave_number: 2 },
        {
          feature_folder: "2026-11-08-dependent-902",
          issue_num: 902,
          depends_on: [901],
          merge_status: "pr_open",
          worktree_created_at: "2026-11-08T10-00",
          early_start: {
            dependency: 901,
            upstream_branch: "feature/upstream-901",
            interface_settled_at: "2026-11-08T09-30",
            interface_evidence: "docs/evidence/interface-settled.md",
          },
        },
        {
          feature_folder: "2026-11-08-other-903",
          issue_num: 903,
          depends_on: [],
          merge_status: "unknown_status",
        },
      ],
    };

    // Act
    const errors = validateEpicOrchestratorStateText(JSON.stringify(document));

    // Assert: the barrier error sits after the merge_status error and before the waves error.
    const statusIndex = errors.findIndex((error) =>
      error.includes("has invalid merge_status"),
    );
    const barrierIndex = errors.indexOf(
      "EPIC_WAVE_BARRIER_VIOLATION: 2026-11-08-dependent-902 is at pr_open or later while early_start dependency 901 is not merged",
    );
    const wavesIndex = errors.findIndex((error) =>
      error.startsWith("Epic checkpoint waves[]"),
    );
    expect(statusIndex).toBeGreaterThanOrEqual(0);
    expect(barrierIndex).toBeGreaterThan(statusIndex);
    expect(wavesIndex).toBeGreaterThan(barrierIndex);
  });
});
