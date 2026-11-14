import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { validateEpicOrchestratorStateText } from "../../../src/lib/validate/epic-orchestrator-state-core";
import {
  isEpicSlug,
  isPositiveInt,
  validateCrossEpicDependencyShape,
  validateCrossEpicMainGate,
} from "../../../src/lib/validate/epic-orchestrator-state-resolution";
import { validateCrossEpicStartedWhileHeld } from "../../../src/lib/validate/epic-orchestrator-state-wave-barrier";
import { validateEpicPlannerStateText } from "../../../src/lib/validate/epic-planner-state-core";

/**
 * Issue #1162 cross-epic dependency parity assertions for the TypeScript ports.
 *
 * Purpose:
 *     Build one checkpoint per case and listed checkpoint type of the committed
 *     corpus `tests/fixtures/epic_cross_dependency/cross-dependency-cases.json`
 *     (the type's envelope, the case's `features`, and its `extra` keys), validate
 *     it through `validateEpicOrchestratorStateText` (with `requireComplete` when
 *     set) or `validateEpicPlannerStateText`, and compare the errors that begin
 *     with `EPIC_CROSS_DEPENDENCY_`, in order, with `expected`. The Python suite
 *     `tests/scripts/dev_tools/test_epic_cross_dependency_parity_corpus.py` asserts
 *     the same file, so both runtimes are pinned to one set of strings.
 *
 * Filesystem access:
 *     The only filesystem access is the read-only load of the committed fixture,
 *     resolved from `__dirname`. No temporary file is created.
 */

/** Committed corpus path, five levels up from this directory to the repository root. */
const CORPUS_PATH = path.resolve(
  __dirname,
  "../../../../../tests/fixtures/epic_cross_dependency/cross-dependency-cases.json",
);

interface CorpusCase {
  readonly name: string;
  readonly checkpoint_types: readonly string[];
  readonly require_complete: boolean;
  readonly features: readonly unknown[];
  readonly extra: Record<string, unknown>;
  readonly expected: readonly string[];
}

interface Corpus {
  readonly envelopes: Record<string, Record<string, unknown>>;
  readonly cases: readonly CorpusCase[];
}

const corpus = JSON.parse(fs.readFileSync(CORPUS_PATH, "utf8")) as Corpus;

/** One row per (case, checkpoint type) pair. */
const rows: [string, CorpusCase][] = corpus.cases.flatMap((entry) =>
  entry.checkpoint_types.map((type): [string, CorpusCase] => [type, entry]),
);

/**
 * Validate a checkpoint through the public entry point of its type.
 *
 * @param type The checkpoint type of the corpus row.
 * @param text The checkpoint JSON text.
 * @param requireComplete Completion gate flag (orchestrator only).
 * @returns Every validator error.
 */
function validate(
  type: string,
  text: string,
  requireComplete: boolean,
): string[] {
  return type === "epic-orchestrator-state"
    ? validateEpicOrchestratorStateText(text, { requireComplete })
    : validateEpicPlannerStateText(text);
}

describe("cross-epic dependency corpus parity", () => {
  it("expands every case into at least one row", () => {
    expect(rows.length).toBeGreaterThanOrEqual(corpus.cases.length);
  });

  it.each(rows)("%s: %s", (type, entry) => {
    // Arrange
    const checkpoint: Record<string, unknown> = {
      ...corpus.envelopes[type],
      features: entry.features,
      ...entry.extra,
    };

    // Act
    const errors = validate(
      type,
      JSON.stringify(checkpoint),
      entry.require_complete,
    ).filter((error) => error.startsWith("EPIC_CROSS_DEPENDENCY_"));

    // Assert
    expect(errors).toEqual(entry.expected);
  });
});

describe("cross-epic helpers", () => {
  it.each([
    [1, true],
    [0, false],
    [-2, false],
    [1.5, false],
    ["1", false],
    [true, false],
  ])("isPositiveInt(%p) is %p", (value, expected) => {
    expect(isPositiveInt(value)).toBe(expected);
  });

  it.each([
    ["provider-epic", true],
    [".", false],
    ["..", false],
    ["a/b", false],
    ["", false],
    [3, false],
  ])("isEpicSlug(%p) is %p", (value, expected) => {
    expect(isEpicSlug(value)).toBe(expected);
  });

  it("ignores a non-list features value in the shape check", () => {
    expect(validateCrossEpicDependencyShape({ features: { a: 1 } })).toEqual(
      [],
    );
  });

  it("skips unstarted features, non-list values, and non-object entries", () => {
    const features = [
      {
        feature_folder: "a",
        merge_status: "not_started",
        cross_epic_depends_on: [{ epic: "p", issue_num: 1 }],
      },
      {
        feature_folder: "b",
        merge_status: "pr_open",
        cross_epic_depends_on: "x",
      },
      {
        feature_folder: "c",
        merge_status: "pr_open",
        cross_epic_depends_on: [5],
      },
      { feature_folder: 7, merge_status: "pr_open", cross_epic_depends_on: [] },
    ];
    expect(validateCrossEpicStartedWhileHeld(features)).toEqual([]);
  });

  it("ignores entries without a valid epic in the main gate", () => {
    const features = [
      { cross_epic_depends_on: [{ epic: "a/b" }, 3] },
      { cross_epic_depends_on: "x" },
    ];
    expect(validateCrossEpicMainGate(features, {})).toEqual([]);
  });

  it("ignores non-object gate entries and keeps released complete epics", () => {
    const features = [
      { cross_epic_depends_on: [{ epic: "p" }, { epic: "p" }] },
    ];
    const state = {
      cross_epic_main_gate: {
        status: "released",
        prerequisites: [
          "p",
          { epic: "p", pr_number: 1, merge_commit_sha: "", verified_at: "t" },
          { epic: "p", pr_number: 1, merge_commit_sha: "s", verified_at: "" },
          { epic: "p", pr_number: 1, merge_commit_sha: "s", verified_at: "t" },
        ],
      },
    };
    expect(validateCrossEpicMainGate(features, state)).toEqual([]);
  });
});
