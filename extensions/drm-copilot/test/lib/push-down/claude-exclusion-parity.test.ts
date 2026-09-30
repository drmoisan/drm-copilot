import { describe, expect, it } from "@jest/globals";
import { readFileSync } from "node:fs";
import path from "node:path";

import {
  buildExclusionReport,
  renderExclusionLines,
} from "../../../src/lib/push-down/claude-exclusion-filter";
import {
  EXCLUSION_MANIFEST_RELATIVE_PATH,
  ExclusionManifestError,
  matchesExclusionEntry,
  parseExclusionManifest,
  planExclusions,
} from "../../../src/lib/push-down/claude-exclusion-manifest";

/**
 * Cross-language parity for the exclusion manifest (issue #621).
 *
 * Purpose:
 *     Iterate every case of the three shared corpus files that the pytest
 *     parity module also iterates, so a divergence between the Python and
 *     TypeScript implementations fails at least one suite. The corpus is
 *     committed repository data read with `readFileSync`; no file is created.
 */

const corpusRoot = path.resolve(
  __dirname,
  "../../../../../tests/fixtures/push_down_exclusions",
);

/** Fields every corpus file carries. */
interface Corpus<TCase> {
  readonly manifest_relative_path: string;
  readonly cases: ReadonlyArray<TCase>;
}

/** One matcher corpus case. */
interface MatcherCase {
  readonly id: string;
  readonly entry: string;
  readonly candidate: string;
  readonly expected: boolean;
}

/** One manifest corpus case; exactly one expectation field is present. */
interface ManifestCase {
  readonly id: string;
  readonly text: string;
  readonly expected_entries?: ReadonlyArray<{
    readonly normalized: string;
    readonly kind: string;
    readonly line: number;
  }>;
  readonly expected_error_line?: number;
}

/** One plan corpus case. */
interface PlanCase {
  readonly id: string;
  readonly manifest_text: string;
  readonly payload_paths: ReadonlyArray<string>;
  readonly destination_present: ReadonlyArray<string>;
  readonly expected_kept: ReadonlyArray<string>;
  readonly expected_skipped: ReadonlyArray<{
    readonly relative_path: string;
    readonly entry: string;
    readonly line: number;
    readonly destination_status: string;
  }>;
  readonly expected_unmatched_entries: ReadonlyArray<string>;
  readonly expected_lines: ReadonlyArray<string>;
}

/**
 * Load one corpus file.
 *
 * @param name File name under the corpus directory.
 * @returns The parsed corpus.
 */
function loadCorpus<TCase>(name: string): Corpus<TCase> {
  return JSON.parse(
    readFileSync(path.join(corpusRoot, name), "utf8"),
  ) as Corpus<TCase>;
}

const matcherCorpus = loadCorpus<MatcherCase>("matcher-corpus.json");
const manifestCorpus = loadCorpus<ManifestCase>("manifest-corpus.json");
const planCorpus = loadCorpus<PlanCase>("plan-corpus.json");

describe("claude-exclusion-parity", () => {
  it("every corpus file declares the manifest relative path", () => {
    // Arrange / Act / Assert
    expect([
      matcherCorpus.manifest_relative_path,
      manifestCorpus.manifest_relative_path,
      planCorpus.manifest_relative_path,
    ]).toEqual([
      EXCLUSION_MANIFEST_RELATIVE_PATH,
      EXCLUSION_MANIFEST_RELATIVE_PATH,
      EXCLUSION_MANIFEST_RELATIVE_PATH,
    ]);
  });

  it("matcher corpus has 18 cases", () => {
    expect(matcherCorpus.cases).toHaveLength(18);
  });

  it.each(matcherCorpus.cases)("matcher case $id", (testCase) => {
    // Arrange
    const [entry] = parseExclusionManifest(
      `${testCase.entry}\n`,
      EXCLUSION_MANIFEST_RELATIVE_PATH,
    ).entries;
    if (entry === undefined) {
      throw new Error(`matcher case ${testCase.id} parsed no entry`);
    }

    // Act
    const matched = matchesExclusionEntry(entry, testCase.candidate);

    // Assert
    expect(matched).toBe(testCase.expected);
  });

  it("manifest corpus has 14 cases", () => {
    expect(manifestCorpus.cases).toHaveLength(14);
  });

  it.each(manifestCorpus.cases)("manifest case $id", (testCase) => {
    // Arrange
    const parse = (): ReturnType<typeof parseExclusionManifest> =>
      parseExclusionManifest(testCase.text, EXCLUSION_MANIFEST_RELATIVE_PATH);

    // Act / Assert
    if (testCase.expected_error_line === undefined) {
      expect(
        parse().entries.map(({ normalized, kind, line }) => ({
          normalized,
          kind,
          line,
        })),
      ).toEqual(testCase.expected_entries);
      return;
    }
    let caught: unknown;
    try {
      parse();
    } catch (error: unknown) {
      caught = error;
    }
    expect(caught).toBeInstanceOf(ExclusionManifestError);
    expect((caught as ExclusionManifestError).line).toBe(
      testCase.expected_error_line,
    );
  });

  it("plan corpus has 9 cases", () => {
    expect(planCorpus.cases).toHaveLength(9);
  });

  it.each(planCorpus.cases)("plan case $id", (testCase) => {
    // Arrange
    const manifest = parseExclusionManifest(
      testCase.manifest_text,
      EXCLUSION_MANIFEST_RELATIVE_PATH,
    );
    const present = new Set(testCase.destination_present);

    // Act
    const plan = planExclusions(testCase.payload_paths, manifest, (p) =>
      present.has(p),
    );
    const lines = renderExclusionLines(
      buildExclusionReport(manifest, plan.skipped),
    );

    // Assert
    expect(plan.kept).toEqual(testCase.expected_kept);
    expect(
      plan.skipped.map((skip) => ({
        relative_path: skip.relativePath,
        entry: skip.entry,
        line: skip.line,
        destination_status: skip.destinationStatus,
      })),
    ).toEqual(testCase.expected_skipped);
    expect(plan.unmatchedEntries.map((entry) => entry.normalized)).toEqual(
      testCase.expected_unmatched_entries,
    );
    expect(lines).toEqual(testCase.expected_lines);
  });
});
