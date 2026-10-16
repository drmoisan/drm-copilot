import { describe, expect, it } from "@jest/globals";

import { evaluatePlanGates } from "../../../src/lib/validate/plan-gate-discrimination";
import {
  evaluateDocumentGates,
  lineCitationMessage,
  PLAN_LINE_GUIDELINE,
  PLAN_TASK_GUIDELINE,
  planSizeMessage,
  shaCitationMessage,
} from "../../../src/lib/validate/plan-gate-document";
import {
  emptyPlanGateReport,
  type PlanGateReport,
} from "../../../src/lib/validate/plan-gate-rules";

/**
 * Unit tests for the document-level plan-gate rules G11, G12, and G13 (issue
 * #964). The eleven cases carry the same names and fixtures as
 * `tests/scripts/dev_tools/test_plan_gate_document.py`. Every fixture is an
 * in-memory string with LF line endings.
 */

const FULL_SHA = "0123456789abcdef0123456789abcdef01234567";
const DIGEST = "0123456789abcdef".repeat(4);

/**
 * Evaluate the document gates alone into a fresh report.
 *
 * @param text Plan text.
 * @returns The populated report.
 */
function run(text: string): PlanGateReport {
  const report = emptyPlanGateReport();
  evaluateDocumentGates(report, text);
  return report;
}

/**
 * Return a plan with exactly `taskCount` task lines and `lineCount` lines.
 *
 * @param taskCount Number of canonical task lines.
 * @param lineCount Number of physical lines.
 * @param extra Optional text inserted after the title block.
 * @returns The plan text, terminated by a final LF.
 */
function plan(taskCount: number, lineCount: number, extra = ""): string {
  const lines = ["# Plan", ""];
  if (extra !== "") {
    lines.push(...extra.split("\n"));
  }
  for (let index = 0; index < taskCount; index += 1) {
    lines.push(`- [ ] [P1-T${String(index)}] Do step ${String(index)}.`);
  }
  while (lines.length < lineCount) {
    lines.push("Filler prose.");
  }
  expect(lines).toHaveLength(lineCount);
  return `${lines.join("\n")}\n`;
}

describe("plan-gate-document G11", () => {
  it("test_g11_reports_prose_path_and_anchor_forms", () => {
    // Arrange
    const text =
      "# Plan\n" +
      "See line 26 for the detail.\n" +
      "Edit lines 134-143 next.\n" +
      "Read `repo-automation-args.ts:20` and ModelRouting.psm1:42 here.\n" +
      "Link https://example.com/o/r/blob/main/a.ts#L20 for review.\n";

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([
      lineCitationMessage(2, "line 26"),
      lineCitationMessage(3, "lines 134"),
      lineCitationMessage(4, "repo-automation-args.ts:20"),
      lineCitationMessage(4, "ModelRouting.psm1:42"),
      lineCitationMessage(5, "#L20"),
    ]);
    expect(report.warnings).toEqual([]);
  });

  it("test_g11_ignores_count_phrases_inline_code_prose_url_ports_and_fences", () => {
    // Arrange
    const text =
      "# Plan\n" +
      "The file stays at or below 500 lines and the guidelines 40 apply.\n" +
      "Quote the validator prefix `Line 5:` exactly.\n" +
      "Call https://example.com:8443/status for health.\n" +
      "```text\n" +
      "line 12 inside a fence\n" +
      "module.py:3 and #L9\n" +
      "```\n";

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([]);
  });
});

describe("plan-gate-document G12", () => {
  it("test_g12_reports_full_and_abbreviated_shas_in_prose_and_inline_code", () => {
    // Arrange
    const text =
      "# Plan\n" +
      `Compare against ${FULL_SHA} first.\n` +
      "Then check `a1b2c3d` and deadbee1 in prose.\n";

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([
      shaCitationMessage(2, FULL_SHA),
      shaCitationMessage(3, "a1b2c3d"),
      shaCitationMessage(3, "deadbee1"),
    ]);
  });

  it("test_g12_ignores_ids_words_uuids_suffixes_digests_and_fences", () => {
    // Arrange
    const text =
      "# Plan\n" +
      "Run 18542345678 used ruleset 15241672 on 2026-10-16.\n" +
      "The word defaced is not a commit.\n" +
      "Request 123e4567-e89b-12d3-a456-426614174000 was logged.\n" +
      "Worktree agent-a2c70f7fea97f192f and build 1a2b3c4d-x and file.1a2b3c4d.\n" +
      `Digest ${DIGEST} is asserted.\n` +
      "```\n" +
      "a1b2c3d4 inside a fence\n" +
      "```\n";

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([]);
  });
});

describe("plan-gate-document G13", () => {
  it("test_g13_fires_above_task_guideline_without_justification", () => {
    // Arrange
    const text = plan(PLAN_TASK_GUIDELINE + 1, 60);

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([
      planSizeMessage(PLAN_TASK_GUIDELINE + 1, 60),
    ]);
  });

  it("test_g13_fires_above_line_guideline_without_justification", () => {
    // Arrange
    const text = plan(3, PLAN_LINE_GUIDELINE + 1);

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([
      planSizeMessage(3, PLAN_LINE_GUIDELINE + 1),
    ]);
  });

  it("test_g13_silent_at_both_guidelines", () => {
    // Arrange
    const text = plan(PLAN_TASK_GUIDELINE, PLAN_LINE_GUIDELINE);

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([]);
  });

  it("test_g13_silent_with_nonempty_justification", () => {
    // Arrange
    const justification =
      "## Size Justification\n\n### Why\n\nThe inventory spans three surfaces.\n\n## Phases";
    const text = plan(
      PLAN_TASK_GUIDELINE + 5,
      PLAN_LINE_GUIDELINE + 5,
      justification,
    );

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([]);
  });

  it("test_g13_empty_justification_does_not_exonerate", () => {
    // Arrange
    const justification =
      "## Size Justification\n\n### Reason\n\n## Phases\n\nPhase prose.";
    const text = plan(PLAN_TASK_GUIDELINE + 1, 80, justification);

    // Act
    const report = run(text);

    // Assert
    expect(report.blocking).toEqual([
      planSizeMessage(PLAN_TASK_GUIDELINE + 1, 80),
    ]);
  });
});

describe("plan-gate-document integration", () => {
  it("test_evaluate_plan_gates_reports_document_gates_after_g10", () => {
    // Arrange
    const text =
      "# Plan\n" +
      "- SCRATCH means the session scratchpad directory.\n" +
      "See line 7 of the brief.\n";

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toHaveLength(2);
    expect(report.blocking[0]).toMatch(/^Line 2: SCRATCH definition/);
    expect(report.blocking[1]).toBe(lineCitationMessage(3, "line 7"));
  });

  it("test_document_gates_run_without_context", () => {
    // Arrange
    const text = "# Plan\n\nPinned to a1b2c3d4e5 at the time of writing.\n";

    // Act
    const report = evaluatePlanGates(text, undefined);

    // Assert
    expect(report.blocking).toEqual([shaCitationMessage(3, "a1b2c3d4e5")]);
    expect(report.warnings).toEqual([]);
  });
});
