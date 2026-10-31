import { describe, expect, it } from "@jest/globals";
import * as fs from "node:fs";
import * as path from "node:path";

import {
  BlastRadiusOverlayError,
  composeBlastRadiusOverlay,
} from "../../../src/lib/push-down/claude-blast-radius-overlay";

/**
 * Cross-language overlay composition corpus (issue #508 AC16).
 *
 * Purpose:
 *     Pin the TypeScript overlay composition to the committed corpus under
 *     `tests/fixtures/blast_radius_overlay/`. The Python parity test asserts the
 *     same corpus, so both implementations produce byte-identical output.
 *
 * Side effects:
 *     Read-only access to the committed corpus; no temporary files.
 */

/** Corpus directory, five levels above this file at the repository root. */
const CORPUS_DIR = path.join(
  __dirname,
  "..",
  "..",
  "..",
  "..",
  "..",
  "tests",
  "fixtures",
  "blast_radius_overlay",
);

/**
 * One corpus case: an expected composed text, or (issue #1006) the full
 * expected error message of a composition that must fail.
 */
interface CorpusCase {
  readonly base_text: string;
  readonly overlay_text: string;
  readonly expected_text?: string;
  readonly expected_error?: string;
}

/** Read every corpus file as a `[name, case]` pair in file-name order. */
function loadCorpus(): Array<[string, CorpusCase]> {
  return fs
    .readdirSync(CORPUS_DIR)
    .filter((name) => name.endsWith(".json"))
    .sort()
    .map((name): [string, CorpusCase] => [
      name,
      JSON.parse(
        fs.readFileSync(path.join(CORPUS_DIR, name), "utf8"),
      ) as CorpusCase,
    ]);
}

describe("issue #508 AC16 overlay composition corpus", () => {
  const corpus = loadCorpus();

  it("discovers at least six corpus files", () => {
    expect(corpus.length).toBeGreaterThanOrEqual(6);
  });

  it.each(corpus)("composes %s to its expected text", (_name, testCase) => {
    const compose = (): string =>
      composeBlastRadiusOverlay(
        testCase.base_text,
        testCase.overlay_text,
        "config/blast-radius.local.json",
      );
    if (testCase.expected_error === undefined) {
      expect(compose()).toBe(testCase.expected_text);
      return;
    }
    let thrown: unknown = null;
    try {
      compose();
    } catch (error) {
      thrown = error;
    }
    expect(thrown).toBeInstanceOf(BlastRadiusOverlayError);
    expect((thrown as Error).message).toBe(testCase.expected_error);
  });
});
