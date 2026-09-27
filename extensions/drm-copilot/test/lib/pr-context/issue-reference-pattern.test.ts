/**
 * Bare-number issue-reference contract tests (issue #622, D1).
 *
 * Every TypeScript issue-reference extractor must return only bare GitHub
 * issue numbers. The matrices cross each of the three exports with the same
 * rejection and acceptance inputs used by the Python twin tests.
 */

import { extractIssueReferences as extractFromFeatureDocs } from "../../../src/lib/pr-context/feature-docs-parsers";
import { extractIssueReferences as extractFromRenderFeatureExcerpts } from "../../../src/lib/pr-context/render-feature-excerpts";
import { extractIssueReferences as extractFromRenderPrHelpers } from "../../../src/lib/pr-context/render-pr-helpers";

type Extractor = (text: string) => string[];

const EXTRACTORS: [string, Extractor][] = [
  ["feature-docs-parsers", extractFromFeatureDocs],
  ["render-pr-helpers", extractFromRenderPrHelpers],
  ["render-feature-excerpts", extractFromRenderFeatureExcerpts],
];

const REJECTED_INPUTS: string[] = [
  "#ISO-8601",
  "#CR-1",
  "ISO-8601",
  "CR-1",
  "UTF-8",
  "SHA-256",
  "AC-12",
  "#12abc",
  "#12_",
  "abc#12",
  "#",
  "#١٢",
  "",
];

const ACCEPTED_INPUTS: [string, string[]][] = [
  ["#468", ["#468"]],
  ["(#660)", ["#660"]],
  ["#12-3", ["#12"]],
  ["#12é", ["#12"]],
  ["#7 and #7", ["#7"]],
  ["line one\n#0 starts line two", ["#0"]],
];

// Cross every extractor with every rejection input: (input, export name, extractor).
const rejectionCases: [string, string, Extractor][] = EXTRACTORS.flatMap(
  ([name, extract]) =>
    REJECTED_INPUTS.map((input): [string, string, Extractor] => [
      input,
      name,
      extract,
    ]),
);

// Cross every extractor with every acceptance input and its expected result.
const acceptanceCases: [string, string, Extractor, string[]][] =
  EXTRACTORS.flatMap(([name, extract]) =>
    ACCEPTED_INPUTS.map(
      ([input, expected]): [string, string, Extractor, string[]] => [
        input,
        name,
        extract,
        expected,
      ],
    ),
  );

describe("extractIssueReferences bare-number contract", () => {
  it.each(rejectionCases)("rejects %s from %s", (input, _name, extract) => {
    // Arrange: the input carries no bare issue number.

    // Act
    const result = extract(input);

    // Assert
    expect(result).toEqual([]);
  });

  it.each(acceptanceCases)(
    "accepts %s from %s",
    (input, _name, extract, expected) => {
      // Arrange: the input carries at least one bare issue number.

      // Act
      const result = extract(input);

      // Assert
      expect(result).toEqual(expected);
    },
  );
});
