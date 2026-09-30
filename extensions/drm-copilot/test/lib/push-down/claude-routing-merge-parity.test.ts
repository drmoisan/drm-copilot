import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  mergeRoutingDocuments,
  RoutingMergeError,
  RoutingMergeFileSystem,
} from "../../../src/lib/push-down/claude-routing-merge";
import { REPO_ROOT } from "./config-carriage.test-helpers";
import { buildInMemoryFileSystem } from "./push-down.test-helpers";

/**
 * Routing-merge behavioral parity fixture (issue #507).
 *
 * Purpose:
 *     Assert that the TypeScript routing merge reproduces every case of the
 *     shared committed fixture `tests/fixtures/push_down/routing-merge-parity.json`
 *     byte-for-byte. The same fixture is asserted by the Python port in
 *     `tests/scripts/dev_tools/test_push_down_claude_parity.py`, so a drift in
 *     either implementation fails one of the two suites.
 *
 * Scope note:
 *     The fixture is read from the repository; every write goes to an in-memory
 *     filesystem. No temporary file is created.
 */

/** One fixture case: a merge expectation or an error expectation. */
interface ParityCase {
  readonly name: string;
  readonly destination: string | null;
  readonly source: string;
  readonly expected?: string;
  readonly expectedErrorPrefix?: string;
}

/** The fixture document: the destination path and its ordered cases. */
interface ParityFixture {
  readonly path: string;
  readonly cases: ReadonlyArray<ParityCase>;
}

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
 * @returns True when the value carries a name, source, nullable destination,
 *   and exactly one of `expected` or `expectedErrorPrefix`.
 */
function isParityCase(value: unknown): value is ParityCase {
  if (!isRecord(value)) {
    return false;
  }
  const destination = value["destination"];
  const hasExpected = typeof value["expected"] === "string";
  const hasError = typeof value["expectedErrorPrefix"] === "string";
  return (
    typeof value["name"] === "string" &&
    typeof value["source"] === "string" &&
    (destination === null || typeof destination === "string") &&
    hasExpected !== hasError
  );
}

/**
 * Narrow the parsed fixture document.
 *
 * @param value Candidate parsed fixture.
 * @returns True when the value is a well-formed fixture.
 */
function isParityFixture(value: unknown): value is ParityFixture {
  if (!isRecord(value)) {
    return false;
  }
  const cases = value["cases"];
  return (
    typeof value["path"] === "string" &&
    Array.isArray(cases) &&
    cases.every(isParityCase)
  );
}

/**
 * Load and validate the shared fixture.
 *
 * @returns The parsed fixture.
 * @throws Error When the fixture does not match the expected shape.
 */
function loadFixture(): ParityFixture {
  const fixturePath = path.join(
    REPO_ROOT,
    "tests",
    "fixtures",
    "push_down",
    "routing-merge-parity.json",
  );
  const parsed: unknown = JSON.parse(fs.readFileSync(fixturePath, "utf8"));
  if (!isParityFixture(parsed)) {
    throw new Error(`Malformed routing-merge parity fixture: ${fixturePath}`);
  }
  return parsed;
}

const FIXTURE = loadFixture();

describe("issue #507: routing-merge behavioral parity fixture", () => {
  it.each([...FIXTURE.cases])(
    "reproduces the $name case",
    (parityCase: ParityCase) => {
      const { destination, source, expected, expectedErrorPrefix } = parityCase;

      if (destination === null) {
        // Arrange: no destination file exists, so the source is written as is.
        const inMemory = buildInMemoryFileSystem();
        const merging = new RoutingMergeFileSystem(
          inMemory,
          "/dest",
          "config/orchestration-routing.json",
        );

        // Act
        merging.writeTextFile(FIXTURE.path, source);

        // Assert
        expect(inMemory.readTextFile(FIXTURE.path)).toBe(expected);
        return;
      }

      if (expected !== undefined) {
        // Act / Assert: byte-identical merge output.
        expect(mergeRoutingDocuments(destination, source, FIXTURE.path)).toBe(
          expected,
        );
        return;
      }

      // Act
      let caught: unknown;
      try {
        mergeRoutingDocuments(destination, source, FIXTURE.path);
      } catch (error) {
        caught = error;
      }

      // Assert
      expect(caught).toBeInstanceOf(RoutingMergeError);
      const routingError = caught as RoutingMergeError;
      expect(
        routingError.message.startsWith(expectedErrorPrefix ?? "\u0000"),
      ).toBe(true);
      expect(routingError.path).toBe(FIXTURE.path);
    },
  );
});
