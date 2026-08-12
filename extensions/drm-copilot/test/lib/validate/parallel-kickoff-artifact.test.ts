import { describe, expect, it } from "@jest/globals";

import {
  parseParallelKickoff,
  validateParallelKickoffText,
} from "../../../src/lib/validate/parallel-kickoff-artifact";
import {
  HASH_40,
  HASH_64,
  ITEM_ROW_101,
  PLAN_PATH_101,
  kickoff,
  kickoffWithIntegrity,
} from "./parallel-kickoff-fixtures";

/**
 * Positive, structural-heading, and cross-runtime parity cases for the
 * parallel kickoff contract. The item-table and integrity-table negative cases
 * live in `parallel-kickoff-artifact-tables.test.ts` under the [P3-T9]
 * conditional-split instruction; both modules share the document builders in
 * the non-test module `parallel-kickoff-fixtures.ts`.
 */

describe("validateParallelKickoffText positive cases", () => {
  it("accepts a fully valid kickoff without an integrity section", () => {
    // Arrange / Act / Assert
    expect(validateParallelKickoffText(kickoff())).toEqual([]);
  });

  it("accepts a fully valid kickoff carrying an integrity section", () => {
    // Arrange / Act / Assert
    expect(validateParallelKickoffText(kickoffWithIntegrity())).toEqual([]);
  });

  it("accepts CRLF line endings", () => {
    // Arrange
    const document = kickoff().replace(/\n/g, "\r\n");

    // Act / Assert
    expect(validateParallelKickoffText(document)).toEqual([]);
  });

  it("accepts lone CR line endings", () => {
    // Arrange
    const document = kickoff().replace(/\n/g, "\r");

    // Act / Assert
    expect(validateParallelKickoffText(document)).toEqual([]);
  });

  it.each(["C1", "C2", "C3", "C4"])("accepts complexity band %s", (band) => {
    // Arrange
    const document = kickoff([ITEM_ROW_101.replace("| C3 |", `| ${band} |`)]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toEqual([]);
  });

  it.each([HASH_40, HASH_64])(
    "accepts a boundary-length plan hash",
    (planHash) => {
      // Arrange
      const document = kickoffWithIntegrity([
        "| plan-path | plan-hash |",
        "| --- | --- |",
        `| ${PLAN_PATH_101} | ${planHash} |`,
      ]);

      // Act / Assert
      expect(validateParallelKickoffText(document)).toEqual([]);
    },
  );

  it.each(["plan-hash", "plan_hash", "git-blob-sha", "git_blob_sha"])(
    "accepts the integrity hash-column header %s",
    (hashHeader) => {
      // Arrange
      const document = kickoffWithIntegrity([
        `| plan-path | ${hashHeader} |`,
        "| --- | --- |",
        `| ${PLAN_PATH_101} | ${HASH_40} |`,
      ]);

      // Act / Assert
      expect(validateParallelKickoffText(document)).toEqual([]);
    },
  );
});

describe("parseParallelKickoff", () => {
  it("parses every declared structural value", () => {
    // Arrange / Act
    const result = parseParallelKickoff(kickoffWithIntegrity());

    // Assert
    expect(result.errors).toEqual([]);
    expect(result.parsed).toEqual({
      slug: "sample-run",
      invocationSlug: "sample-run",
      manifestPath: "docs/features/parallel/sample-run/parallel.md",
      planHomeBranch: "parallel/sample-run-plan",
      items: [
        {
          issueNum: 101,
          featureFolder: "docs/features/active/item-101",
          cohort: 0,
          complexity: "C3",
          branch: "feature/item-101",
          planPath: PLAN_PATH_101,
        },
      ],
      planningCommit: "e".repeat(40),
      planHashes: { [PLAN_PATH_101]: HASH_40 },
    });
  });

  it("omits the planning commit when no integrity section is present", () => {
    // Arrange / Act
    const result = parseParallelKickoff(kickoff());

    // Assert
    expect(result.parsed?.planningCommit).toBeUndefined();
    expect(result.parsed?.planHashes).toEqual({});
  });

  it("returns no parsed structure when the document is malformed", () => {
    // Arrange / Act
    const result = parseParallelKickoff("");

    // Assert
    expect(result.parsed).toBeUndefined();
  });
});

describe("validateParallelKickoffText structural negative cases", () => {
  it("reports empty text", () => {
    // Arrange / Act / Assert
    expect(validateParallelKickoffText("")).toEqual([
      "Parallel kickoff is empty.",
    ]);
  });

  it("reports a first line that is not the kickoff heading", () => {
    // Arrange / Act / Assert
    expect(validateParallelKickoffText("not a heading")).toEqual([
      "Parallel kickoff first line must match '# Parallel Kickoff: <slug>'.",
    ]);
  });

  it("reports a slug outside the allowed pattern", () => {
    // Arrange
    const document = kickoff().replace(
      "# Parallel Kickoff: sample-run",
      "# Parallel Kickoff: Sample_Run",
    );

    // Act / Assert
    expect(validateParallelKickoffText(document)).toEqual([
      "Parallel kickoff first line must match '# Parallel Kickoff: <slug>'.",
    ]);
  });

  it("reports a missing invocation prompt section", () => {
    // Arrange
    const document = kickoff().replace("## Invocation Prompt\n", "");

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff is missing required section: ## Invocation Prompt",
    );
  });

  it("reports a missing item summary section", () => {
    // Arrange
    const document = kickoff().replace("## Item Summary\n", "");

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff is missing required section: ## Item Summary",
    );
  });

  it("reports a duplicate level-two heading", () => {
    // Arrange
    const document = kickoff().replace(
      "## Item Summary",
      "## Invocation Prompt",
    );

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff contains duplicate section: ## Invocation Prompt",
    );
  });

  it("reports an invocation prompt without the parallel-run call", () => {
    // Arrange
    const document = kickoff().replace(
      "Run `/parallel-run sample-run` to execute this parallel run.",
      "Execute this parallel run.",
    );

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff invocation must contain `Run /parallel-run <slug>`.",
    );
  });

  it("reports an invocation prompt without the manifest path", () => {
    // Arrange
    const document = kickoff().replace(
      "docs/features/parallel/sample-run/parallel.md",
      "the run manifest",
    );

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff invocation must structurally name the manifest, " +
        "plan-home branch, and atomic-execution resume boundary.",
    );
  });

  it("reports an invocation prompt without the plan-home branch", () => {
    // Arrange
    const document = kickoff().replace(
      "parallel/sample-run-plan",
      "some-other-branch",
    );

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff invocation must structurally name the manifest, " +
        "plan-home branch, and atomic-execution resume boundary.",
    );
  });

  it("reports an invocation prompt without the resume boundary", () => {
    // Arrange
    const document = kickoff().replace(
      "items resume at atomic execution from their committed plan-path on\n" +
        "their own pushed feature branch rather than re-planning.",
      "start the run.",
    );

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff invocation must structurally name the manifest, " +
        "plan-home branch, and atomic-execution resume boundary.",
    );
  });
});

/**
 * Cross-runtime parity block.
 *
 * The expected values below are transcribed literally from the error strings
 * emitted by `scripts/dev_tools/parallel_kickoff_contract.py` and its helper
 * `scripts/dev_tools/_parallel_kickoff_tables.py`. They are hardcoded on
 * purpose: `.claude/rules/general-unit-test.md` prohibits external processes
 * in unit tests, so this block must never spawn a Python interpreter, read a
 * generated file, or otherwise depend on anything outside this module. The
 * epic analogue `epic-kickoff-artifact.test.ts` likewise contains no Python
 * invocation. Each case pairs a shared fixture document with the exact,
 * ordered error list the Python runtime produces for it.
 */
const PYTHON_PARITY_CASES: ReadonlyArray<
  readonly [string, string, ReadonlyArray<string>]
> = [
  ["a fully valid kickoff", kickoff(), []],
  ["a valid kickoff with integrity", kickoffWithIntegrity(), []],
  ["empty text", "", ["Parallel kickoff is empty."]],
  [
    "a non-heading first line",
    "not a heading",
    ["Parallel kickoff first line must match '# Parallel Kickoff: <slug>'."],
  ],
  [
    "a heading-only document",
    "# Parallel Kickoff: sample-run",
    [
      "Parallel kickoff is missing required section: ## Invocation Prompt",
      "Parallel kickoff is missing required section: ## Item Summary",
      "Parallel kickoff invocation must contain `Run /parallel-run <slug>`.",
      "Parallel kickoff invocation must structurally name the manifest, " +
        "plan-home branch, and atomic-execution resume boundary.",
      "Parallel kickoff table is missing its header or separator row.",
    ],
  ],
  [
    "wrong item table headers",
    kickoff().replace("| issue_num |", "| issue |"),
    [
      "Parallel kickoff item table headers must be: issue_num | " +
        "feature_folder | cohort | complexity | branch | plan-path",
    ],
  ],
  [
    "a non-integer cohort",
    kickoff([ITEM_ROW_101.replace("/item-101 | 0 |", "/item-101 | first |")]),
    ["Parallel kickoff item row 0 cohort must be an integer."],
  ],
  [
    "an out-of-range complexity band",
    kickoff([ITEM_ROW_101.replace("| C3 |", "| C5 |")]),
    ["Parallel kickoff item row 0 complexity must be C1-C4."],
  ],
  [
    "a short plan hash",
    kickoffWithIntegrity([
      "| plan-path | plan-hash |",
      "| --- | --- |",
      `| ${PLAN_PATH_101} | ${"c".repeat(39)} |`,
    ]),
    [
      "Parallel kickoff integrity table row is invalid: " +
        `| ${PLAN_PATH_101} | ${"c".repeat(39)} |`,
    ],
  ],
  [
    "a repeated plan path",
    kickoffWithIntegrity([
      "| plan-path | plan-hash |",
      "| --- | --- |",
      `| ${PLAN_PATH_101} | ${HASH_40} |`,
      `| ${PLAN_PATH_101} | ${HASH_64} |`,
    ]),
    [`Parallel kickoff integrity repeats plan path: '${PLAN_PATH_101}'.`],
  ],
  [
    "a stray integrity line",
    kickoffWithIntegrity(["this is not an integrity field"]),
    [
      "Parallel kickoff integrity line is invalid: " +
        "this is not an integrity field",
    ],
  ],
];

describe("cross-runtime parity with the Python kickoff contract", () => {
  it.each(PYTHON_PARITY_CASES)(
    "matches the Python error strings for %s",
    (_name, document, expectedPythonErrors) => {
      // Arrange / Act
      const errors = validateParallelKickoffText(document);

      // Assert
      expect(errors).toEqual(expectedPythonErrors);
    },
  );
});

describe("validateParallelKickoffText committed readiness", () => {
  it("accepts a version-1 committed identity", () => {
    expect(
      validateParallelKickoffText(kickoffWithIntegrity(), {
        requireReadyForExecution: true,
      }),
    ).toEqual([]);
  });

  it("preserves legacy structural validation outside the explicit gate", () => {
    expect(validateParallelKickoffText(kickoff())).toEqual([]);
  });

  it("requires planning_commit at the explicit readiness gate", () => {
    expect(
      validateParallelKickoffText(kickoff(), {
        requireReadyForExecution: true,
      }),
    ).toContain(
      "Parallel kickoff readiness requires version-1 committed planning_commit identity.",
    );
  });

  it("rejects cross-wired heading and invocation identities", () => {
    const text = kickoffWithIntegrity().replace(
      "Run `/parallel-run sample-run`",
      "Run `/parallel-run other-run`",
    );

    expect(
      validateParallelKickoffText(text, { requireReadyForExecution: true }),
    ).toContain(
      "Parallel kickoff readiness requires heading and invocation slugs to match.",
    );
  });
});
