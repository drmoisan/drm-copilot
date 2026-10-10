import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import { mergeClaudeGitignore } from "../../../src/lib/push-down/claude-gitignore-merge";
import { REPO_ROOT } from "./config-carriage.test-helpers";

/**
 * Gitignore-merge behavioral parity fixture (issue #790).
 *
 * Purpose:
 *     Assert that the TypeScript gitignore merge reproduces every case of the
 *     shared committed fixture `tests/fixtures/push_down/gitignore-merge-parity.json`
 *     byte-for-byte. The same fixture is asserted by the Python port in
 *     `tests/scripts/dev_tools/test_push_down_claude_gitignore_parity.py`, so a
 *     drift in either implementation fails one of the two suites.
 *
 * Scope note:
 *     The fixture is read from the repository; no file is written and no
 *     temporary file is created.
 */

/** One fixture case: the current destination text and the merged result. */
interface GitignoreParityCase {
  readonly name: string;
  readonly current: string;
  readonly expected: string;
}

/** The fixture document: its ordered cases. */
interface GitignoreParityFixture {
  readonly cases: ReadonlyArray<GitignoreParityCase>;
}

/** The eleven fixture case names, in fixture order. */
const EXPECTED_CASE_NAMES: ReadonlyArray<string> = [
  "absent",
  "content-without-block",
  "up-to-date-block",
  "stale-block-with-surrounding-content",
  "duplicate-entry-outside-block",
  "no-trailing-newline",
  "crlf-input",
  "lone-cr-input",
  "begin-without-end",
  "end-before-begin",
  "multiple-trailing-blank-lines",
];

/**
 * Report whether a value is a non-null, non-array object.
 *
 * @param value Candidate parsed JSON value.
 * @returns True when the value is a plain object.
 */
function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

/**
 * Narrow one parsed fixture case.
 *
 * @param value Candidate parsed case.
 * @returns True when the value carries string `name`, `current`, and `expected`.
 */
function isParityCase(value: unknown): value is GitignoreParityCase {
  return (
    isRecord(value) &&
    typeof value["name"] === "string" &&
    typeof value["current"] === "string" &&
    typeof value["expected"] === "string"
  );
}

/**
 * Narrow the parsed fixture document.
 *
 * @param value Candidate parsed fixture.
 * @returns True when the value is a well-formed fixture.
 */
function isParityFixture(value: unknown): value is GitignoreParityFixture {
  if (!isRecord(value)) {
    return false;
  }
  const cases = value["cases"];
  return Array.isArray(cases) && cases.every(isParityCase);
}

/**
 * Load and validate the shared fixture.
 *
 * @returns The parsed fixture.
 * @throws Error When the fixture does not match the expected shape.
 */
function loadFixture(): GitignoreParityFixture {
  const fixturePath = path.join(
    REPO_ROOT,
    "tests",
    "fixtures",
    "push_down",
    "gitignore-merge-parity.json",
  );
  const parsed: unknown = JSON.parse(fs.readFileSync(fixturePath, "utf8"));
  if (!isParityFixture(parsed)) {
    throw new Error(`Malformed gitignore-merge parity fixture: ${fixturePath}`);
  }
  return parsed;
}

const FIXTURE = loadFixture();

describe("issue #790: gitignore-merge behavioral parity fixture", () => {
  it("carries the eleven named cases in order", () => {
    // Act
    const names = FIXTURE.cases.map((parityCase) => parityCase.name);

    // Assert
    expect(names).toEqual(EXPECTED_CASE_NAMES);
  });

  it.each([...FIXTURE.cases])(
    "reproduces the $name case",
    (parityCase: GitignoreParityCase) => {
      // Act
      const merged = mergeClaudeGitignore(parityCase.current);

      // Assert: byte-identical merge output.
      expect(merged).toBe(parityCase.expected);
    },
  );
});
