import { describe, expect, it } from "@jest/globals";

import {
  evaluateDocumentGates,
  G11_SEVERITY,
  G12_SEVERITY,
  G13_SEVERITY,
  lineCitationMessage,
} from "../../../src/lib/validate/plan-gate-document";
import { G10_SEVERITY } from "../../../src/lib/validate/plan-gate-scratch";
import { emptyPlanGateReport } from "../../../src/lib/validate/plan-gate-rules";

/**
 * Parity rows for the G11, G12, and G13 rules (issue #964).
 *
 * The expected strings are written as double-quoted literals and are asserted
 * verbatim by `tests/scripts/dev_tools/test_plan_gate_document_parity.py`, so a
 * message divergence in either runtime fails on both sides. One row renders an
 * apostrophe-bearing value through the message builder.
 */

/**
 * Return a plan made only of canonical task lines.
 *
 * @param taskCount Number of task lines.
 * @returns The plan text.
 */
function taskPlan(taskCount: number): string {
  let text = "";
  for (let index = 0; index < taskCount; index += 1) {
    text += `- [ ] [P1-T${String(index)}] Step.\n`;
  }
  return text;
}

const ROWS: ReadonlyArray<[string, string, readonly string[]]> = [
  [
    "g11-prose",
    "See line 26 here.\n",
    [
      "Line 1: line-number citation `line 26` anchors on a position that moves when main moves; cite the symbol, heading, or test name instead.",
    ],
  ],
  [
    "g11-path",
    "Read `module.py:12` now.\n",
    [
      "Line 1: line-number citation `module.py:12` anchors on a position that moves when main moves; cite the symbol, heading, or test name instead.",
    ],
  ],
  [
    "g11-anchor",
    "Open a.ts#L5 now.\n",
    [
      "Line 1: line-number citation `#L5` anchors on a position that moves when main moves; cite the symbol, heading, or test name instead.",
    ],
  ],
  [
    "g12",
    "Pinned at a1b2c3d4.\n",
    [
      "Line 1: commit-SHA citation `a1b2c3d4` names a commit that goes stale when main moves; cite the branch, ref name, or merge base derivation instead.",
    ],
  ],
  [
    "g13",
    taskPlan(41),
    [
      "Line 1: plan size `41 tasks, 41 lines` exceeds the guideline of 40 tasks or 400 lines and carries no `## Size Justification` section; split the item or state why the size is necessary.",
    ],
  ],
];

const APOSTROPHE_EXPECTED =
  "Line 9: line-number citation `it's.md:3` anchors on a position that moves when main moves; cite the symbol, heading, or test name instead.";

describe("plan-gate-document parity", () => {
  it.each(ROWS)(
    "row %s matches the expected message",
    (_name, text, expected) => {
      // Arrange
      const report = emptyPlanGateReport();

      // Act
      evaluateDocumentGates(report, text);

      // Assert
      expect(report.blocking).toEqual(expected);
    },
  );

  it("renders an apostrophe-bearing value verbatim between backticks", () => {
    // Arrange / Act
    const message = lineCitationMessage(9, "it's.md:3");

    // Assert
    expect(message).toBe(APOSTROPHE_EXPECTED);
  });

  it("declares G11, G12, and G13 on the same Blocking channel as G10", () => {
    // Arrange / Act / Assert
    expect(G11_SEVERITY).toBe("blocking");
    expect(G12_SEVERITY).toBe("blocking");
    expect(G13_SEVERITY).toBe("blocking");
    expect(G11_SEVERITY).toBe(G10_SEVERITY);
  });
});
