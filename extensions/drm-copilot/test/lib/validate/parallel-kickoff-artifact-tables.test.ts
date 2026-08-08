import { describe, expect, it } from "@jest/globals";

import { validateParallelKickoffText } from "../../../src/lib/validate/parallel-kickoff-artifact";
import {
  HASH_40,
  HASH_64,
  ITEM_HEADER_ROW,
  ITEM_ROW_101,
  ITEM_SEPARATOR_ROW,
  PLAN_PATH_101,
  kickoff,
  kickoffWithIntegrity,
} from "./parallel-kickoff-fixtures";

/**
 * Item-table and integrity-table negative cases for the parallel kickoff
 * contract, split out of `parallel-kickoff-artifact.test.ts` under the
 * [P3-T9] conditional-split instruction so that neither test module exceeds
 * the repository's 500-line file-size limit. The document builders are shared
 * through the non-test module `parallel-kickoff-fixtures.ts`.
 */

const EXPECTED_HEADER_ERROR =
  "Parallel kickoff item table headers must be: issue_num | " +
  "feature_folder | cohort | complexity | branch | plan-path";

describe("validateParallelKickoffText item table negative cases", () => {
  it("reports wrong item table header text", () => {
    // Arrange
    const document = kickoff().replace("| issue_num |", "| issue |");

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      EXPECTED_HEADER_ERROR,
    );
  });

  it("reports item table headers in the wrong order", () => {
    // Arrange
    const document = kickoff().replace(
      ITEM_HEADER_ROW,
      "| issue_num | feature_folder | complexity | cohort | branch | plan-path |",
    );

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      EXPECTED_HEADER_ERROR,
    );
  });

  it("reports a missing item table separator row", () => {
    // Arrange
    const document = kickoff().replace(`${ITEM_SEPARATOR_ROW}\n`, "");

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff table separator row is invalid.",
    );
  });

  it("reports a table with fewer than two lines", () => {
    // Arrange
    const document = kickoff([]).replace(`\n${ITEM_SEPARATOR_ROW}`, "");

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff table is missing its header or separator row.",
    );
  });

  it("reports an item row whose cell count is not six", () => {
    // Arrange
    const shortRow =
      "| 101 | docs/features/active/item-101 | 0 | C3 | feature/item-101 |";
    const document = kickoff([shortRow]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      `Parallel kickoff table row is invalid: ${shortRow}`,
    );
  });

  it("reports an item row that is not pipe-delimited", () => {
    // Arrange
    const proseRow = "101 is scheduled in cohort 0";
    const document = kickoff([proseRow]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      `Parallel kickoff table row is invalid: ${proseRow}`,
    );
  });

  it("reports an item table with zero data rows", () => {
    // Arrange / Act / Assert
    expect(validateParallelKickoffText(kickoff([]))).toContain(
      "Parallel kickoff item table must contain at least one item row.",
    );
  });

  it("reports a non-integer issue_num against its row index", () => {
    // Arrange
    const document = kickoff([
      ITEM_ROW_101.replace("| 101 |", "| one-oh-one |"),
    ]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff item row 0 issue_num must be an integer.",
    );
  });

  it("reports a non-integer cohort against its row index", () => {
    // Arrange
    const document = kickoff([
      ITEM_ROW_101.replace("/item-101 | 0 |", "/item-101 | first |"),
    ]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff item row 0 cohort must be an integer.",
    );
  });

  it.each(["C0", "C5"])(
    "reports complexity band %s as out of range",
    (band) => {
      // Arrange
      const document = kickoff([ITEM_ROW_101.replace("| C3 |", `| ${band} |`)]);

      // Act / Assert
      expect(validateParallelKickoffText(document)).toContain(
        "Parallel kickoff item row 0 complexity must be C1-C4.",
      );
    },
  );

  it("reports a later bad row against its own row index", () => {
    // Arrange
    const badSecondRow = ITEM_ROW_101.replace("| 101 |", "| not-a-number |");
    const document = kickoff([ITEM_ROW_101, badSecondRow]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff item row 1 issue_num must be an integer.",
    );
  });
});

describe("validateParallelKickoffText integrity negative cases", () => {
  it("reports a wrong integrity table header", () => {
    // Arrange
    const document = kickoffWithIntegrity([
      "| wrong | hash |",
      "| --- | --- |",
      `| ${PLAN_PATH_101} | ${HASH_40} |`,
    ]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff integrity table headers must be plan-path and plan-hash.",
    );
  });

  it("reports a missing integrity table separator row", () => {
    // Arrange
    const document = kickoffWithIntegrity(["| plan-path | plan-hash |"]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff integrity table is missing its separator row.",
    );
  });

  it("reports an invalid integrity table separator row", () => {
    // Arrange
    const document = kickoffWithIntegrity([
      "| plan-path | plan-hash |",
      "| bad | bad |",
      `| ${PLAN_PATH_101} | ${HASH_40} |`,
    ]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff integrity table separator row is invalid.",
    );
  });

  it.each([
    ["c".repeat(39), "thirty-nine hex"],
    ["d".repeat(65), "sixty-five hex"],
    ["z".repeat(40), "non hex"],
  ])("reports an out-of-contract plan hash (%s)", (planHash) => {
    // Arrange
    const row = `| ${PLAN_PATH_101} | ${planHash} |`;
    const document = kickoffWithIntegrity([
      "| plan-path | plan-hash |",
      "| --- | --- |",
      row,
    ]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      `Parallel kickoff integrity table row is invalid: ${row}`,
    );
  });

  it("reports a repeated plan path", () => {
    // Arrange
    const document = kickoffWithIntegrity([
      "| plan-path | plan-hash |",
      "| --- | --- |",
      `| ${PLAN_PATH_101} | ${HASH_40} |`,
      `| ${PLAN_PATH_101} | ${HASH_64} |`,
    ]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      `Parallel kickoff integrity repeats plan path: '${PLAN_PATH_101}'.`,
    );
  });

  it("reports duplicate run-level commit fields", () => {
    // Arrange
    const document = kickoffWithIntegrity([
      `planning_commit: ${"e".repeat(40)}`,
      `planning_commit: ${"f".repeat(40)}`,
    ]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff integrity has duplicate planning_commit fields.",
    );
  });

  it("reports a stray non-table line inside the integrity section", () => {
    // Arrange
    const document = kickoffWithIntegrity(["this is not an integrity field"]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toContain(
      "Parallel kickoff integrity line is invalid: this is not an integrity field",
    );
  });

  it("accepts an abbreviated uppercase commit and lowercases it", () => {
    // Arrange
    const document = kickoffWithIntegrity(["- planning_commit: `ABCDEF1`"]);

    // Act / Assert
    expect(validateParallelKickoffText(document)).toEqual([]);
  });
});
