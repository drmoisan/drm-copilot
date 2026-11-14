import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import type {
  CommandResult,
  CommandRunner,
} from "../../../src/lib/subprocess-runner";
import { validateArtifactWithWarnings } from "../../../src/lib/validate/orchestration-artifacts";
import {
  evaluateDocumentGates,
  LEGACY_PLAN_LINE_GUIDELINE,
  LEGACY_PLAN_TASK_GUIDELINE,
  PLAN_LINE_GUIDELINE,
  PLAN_STAMP_ZONES,
  PLAN_TASK_GUIDELINE,
  planFileStamp,
  planSizeGuideline,
} from "../../../src/lib/validate/plan-gate-document";
import { emptyPlanGateReport } from "../../../src/lib/validate/plan-gate-rules";

/**
 * Tests for the G13 guideline cutoff and plan-file stamp reader (issue #1097).
 *
 * Every row below is duplicated as a double-quoted literal in
 * `tests/scripts/dev_tools/test_plan_gate_guideline_cutoff.py`, which asserts
 * that each Python row appears verbatim here. Every test injects the fixed
 * cutoff pair, which names one instant in both zones, and reads no clock and
 * no committed cutoff value.
 */

/** One instant written in both zones: 10:00 in New York is 15:00 UTC. */
const CUTOFF: Readonly<Record<string, string>> = {
  "America/New_York": "2026-11-07T10-00",
  UTC: "2026-11-07T15-00",
};
const LEGACY: readonly [number, number] = [40, 400];
const NEW: readonly [number, number] = [20, 250];

const STAMP_ROWS: readonly (readonly [string, string, string])[] = [
  ["plan.2026-11-07T09-59.md", "2026-11-07T09-59", "America/New_York"],
  ["docs\\f\\plan.2026-11-07T09-59.md", "2026-11-07T09-59", "America/New_York"],
  [
    "/repo/docs/f/plan.2026-11-07T09-59.md",
    "2026-11-07T09-59",
    "America/New_York",
  ],
  [
    "C:\\repo\\f\\plan.2026-11-07T09-59.md",
    "2026-11-07T09-59",
    "America/New_York",
  ],
  ["plan.remediation-cycle-1.2026-11-07T14-59.md", "2026-11-07T14-59", "UTC"],
  [
    "docs\\f\\plan.remediation-cycle-12.2026-11-07T14-59.md",
    "2026-11-07T14-59",
    "UTC",
  ],
  [
    "/repo/docs/f/plan.remediation-cycle-1.2026-11-07T14-59.md",
    "2026-11-07T14-59",
    "UTC",
  ],
  [
    "C:\\repo\\f\\plan.remediation-cycle-1.2026-11-07T14-59.md",
    "2026-11-07T14-59",
    "UTC",
  ],
  ["remediation-plan.2026-11-07T14-59.md", "2026-11-07T14-59", "UTC"],
  ["docs\\f\\remediation-plan.2026-11-07T14-59.md", "2026-11-07T14-59", "UTC"],
  [
    "/repo/docs/f/remediation-plan.2026-11-07T14-59.md",
    "2026-11-07T14-59",
    "UTC",
  ],
  [
    "C:\\repo\\f\\remediation-plan.2026-11-07T14-59.md",
    "2026-11-07T14-59",
    "UTC",
  ],
  [
    "remediation/2026-11-07T14-59/remediation-plan.md",
    "2026-11-07T14-59",
    "UTC",
  ],
  [
    "docs\\f\\remediation\\2026-11-07T14-59\\remediation-plan.md",
    "2026-11-07T14-59",
    "UTC",
  ],
  [
    "/repo/f/remediation/2026-11-07T14-59/remediation-plan.md",
    "2026-11-07T14-59",
    "UTC",
  ],
  [
    "C:\\repo\\f\\remediation\\2026-11-07T14-59\\remediation-plan.md",
    "2026-11-07T14-59",
    "UTC",
  ],
];

const REJECTED_NAMES: readonly string[] = [
  "plan.md",
  "plan.yyyy-MM-ddTHH-mm.md",
  "remediation-plan-ledger.2026-11-07T06-50.md",
  "remediation/2026-11-07T14-59/plan.md",
  "remediation-plan.md",
  "Plan.2026-11-07T09-59.md",
  "",
];

const BOUNDARY_ROWS: readonly (readonly [string, readonly [number, number]])[] =
  [
    ["plan.2026-11-07T09-59.md", LEGACY],
    ["plan.2026-11-07T10-00.md", NEW],
    ["plan.2026-11-07T10-01.md", NEW],
    ["remediation-plan.2026-11-07T14-59.md", LEGACY],
    ["remediation-plan.2026-11-07T15-00.md", NEW],
    ["remediation-plan.2026-11-07T15-01.md", NEW],
  ];

const K4_SHAPE_ROWS: readonly (readonly [string, readonly [number, number]])[] =
  [
    ["plan.2026-11-07T09-59.md", LEGACY],
    ["plan.2026-11-07T10-00.md", NEW],
    ["plan.remediation-cycle-1.2026-11-07T14-59.md", LEGACY],
    ["plan.remediation-cycle-1.2026-11-07T15-00.md", NEW],
    ["remediation-plan.2026-11-07T14-59.md", LEGACY],
    ["remediation-plan.2026-11-07T15-00.md", NEW],
    ["remediation/2026-11-07T14-59/remediation-plan.md", LEGACY],
    ["remediation/2026-11-07T15-00/remediation-plan.md", NEW],
  ];

const UTC_ROWS: readonly (readonly [string, readonly [number, number]])[] = [
  ["remediation-plan.2026-11-07T14-30.md", LEGACY],
  ["plan.remediation-cycle-1.2026-11-07T14-30.md", LEGACY],
  ["remediation/2026-11-07T14-30/remediation-plan.md", LEGACY],
  ["plan.2026-11-07T14-30.md", NEW],
];

const LEGACY_MESSAGE =
  "Line 1: plan size `41 tasks, 41 lines` exceeds the guideline of 40 tasks or 400 lines and carries no `## Size Justification` section; split the item or state why the size is necessary.";
const NEW_MESSAGE =
  "Line 1: plan size `41 tasks, 41 lines` exceeds the guideline of 20 tasks or 250 lines and carries no `## Size Justification` section; split the item or state why the size is necessary.";
const OLD_PLAN_PATH = "docs/features/active/f/plan.2026-01-01T00-00.md";
const FUTURE_PLAN_PATH = "docs/features/active/f/plan.2099-12-31T23-59.md";
const MESSAGE_ROWS: readonly (readonly [string | undefined, string])[] = [
  [OLD_PLAN_PATH, LEGACY_MESSAGE],
  [FUTURE_PLAN_PATH, NEW_MESSAGE],
  [undefined, NEW_MESSAGE],
];

/** Read-only filesystem stub that answers negatively and reads nothing. */
const STUB_FILE_SYSTEM: FileSystem = {
  glob: () => [],
  isFile: () => false,
  exists: () => false,
  isDirectory: () => false,
  listDirectory: () => [],
  readTextFile: () => "",
  writeTextFile: () => undefined,
  ensureDir: () => undefined,
};

/** Command runner stub that answers every git query with empty output. */
class EmptyRunner implements CommandRunner {
  public run(): CommandResult {
    return { stdout: "", stderr: "", code: 0 };
  }
}

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

/**
 * Return the G13 findings the document gates report for a plan.
 *
 * @param text Plan text.
 * @param planPath Plan-file path, or `undefined`.
 * @returns The G13 findings.
 */
function g13Findings(text: string, planPath: string | undefined): string[] {
  const report = emptyPlanGateReport();
  evaluateDocumentGates(report, text, planPath);
  return report.blocking.filter((finding) => finding.includes("plan size"));
}

/**
 * Return the G13 findings of the dispatcher's error channel.
 *
 * @param errors Errors returned by `validateArtifactWithWarnings`.
 * @returns The G13 findings.
 */
function sizeErrors(errors: readonly string[]): string[] {
  return errors.filter((error) => error.includes("plan size"));
}

describe("G13 guideline cutoff", () => {
  it("test_guideline_constants_match_typescript", () => {
    // Arrange / Act / Assert
    expect([PLAN_TASK_GUIDELINE, PLAN_LINE_GUIDELINE]).toEqual(NEW);
    expect([LEGACY_PLAN_TASK_GUIDELINE, LEGACY_PLAN_LINE_GUIDELINE]).toEqual(
      LEGACY,
    );
    expect(PLAN_STAMP_ZONES).toEqual({
      plan: "America/New_York",
      "plan-remediation-cycle": "UTC",
      "remediation-plan": "UTC",
      "remediation-folder": "UTC",
    });
  });

  it.each(STAMP_ROWS)(
    "test_plan_file_stamp_reads_each_k4_shape %s",
    (path, stamp, zone) => {
      // Arrange / Act
      const result = planFileStamp(path);

      // Assert
      expect(result).toEqual([stamp, zone]);
    },
  );

  it.each([...REJECTED_NAMES, undefined])(
    "test_plan_file_stamp_rejects_other_names %s",
    (path) => {
      // Arrange / Act
      const result = planFileStamp(path);

      // Assert
      expect(result).toBeUndefined();
    },
  );

  it.each(BOUNDARY_ROWS)(
    "test_guideline_boundary_rows %s",
    (path, expected) => {
      // Arrange
      const stamped = planFileStamp(path);

      // Act
      const guideline = planSizeGuideline(stamped, CUTOFF);

      // Assert
      expect(guideline).toEqual(expected);
    },
  );

  it.each(K4_SHAPE_ROWS)(
    "test_guideline_k4_shape_rows %s",
    (path, expected) => {
      // Arrange
      const stamped = planFileStamp(path);

      // Act
      const guideline = planSizeGuideline(stamped, CUTOFF);

      // Assert
      expect(guideline).toEqual(expected);
    },
  );

  it.each(UTC_ROWS)(
    "test_utc_stamp_is_not_read_against_new_york_cutoff %s",
    (path, expected) => {
      // Arrange
      const stamped = planFileStamp(path);

      // Act
      const guideline = planSizeGuideline(stamped, CUTOFF);

      // Assert
      expect(guideline).toEqual(expected);
    },
  );

  it("test_guideline_for_a_zone_without_a_cutoff_entry_is_new", () => {
    // Arrange
    const stamped = planFileStamp("remediation-plan.2026-11-07T14-59.md");

    // Act
    const guideline = planSizeGuideline(stamped, {
      "America/New_York": "2026-11-07T10-00",
    });

    // Assert
    expect(guideline).toEqual(NEW);
  });

  it("test_guideline_without_path_is_new", () => {
    // Arrange
    const stamped = planFileStamp(undefined);

    // Act
    const guideline = planSizeGuideline(stamped, CUTOFF);

    // Assert
    expect(guideline).toEqual(NEW);
  });

  it.each(MESSAGE_ROWS)(
    "test_g13_message_states_the_guideline_that_applied %s",
    (planPath, expected) => {
      // Arrange
      const text = taskPlan(41);

      // Act
      const findings = g13Findings(text, planPath);

      // Assert
      expect(findings).toEqual([expected]);
    },
  );

  it("test_g13_keeps_legacy_result_for_older_stamp", () => {
    // Arrange
    const text = taskPlan(25);

    // Act
    const stamped = g13Findings(text, OLD_PLAN_PATH);
    const unstamped = g13Findings(text, undefined);

    // Assert
    expect(stamped).toEqual([]);
    expect(unstamped).toHaveLength(1);
  });

  it("test_plan_path_reaches_g13_without_a_context", () => {
    // Arrange
    const text = taskPlan(25);

    // Act
    const result = validateArtifactWithWarnings({
      artifactType: "plan",
      text,
      artifactPath: OLD_PLAN_PATH,
    });

    // Assert
    expect(sizeErrors(result.errors)).toEqual([]);
  });

  it("keeps the stamp result with full repository wiring", () => {
    // Arrange
    const text = taskPlan(25);

    // Act
    const result = validateArtifactWithWarnings({
      artifactType: "plan",
      text,
      artifactPath: OLD_PLAN_PATH,
      fs: STUB_FILE_SYSTEM,
      root: "/repo",
      runner: new EmptyRunner(),
    });

    // Assert
    expect(sizeErrors(result.errors)).toEqual([]);
  });

  it("applies the current guideline when no artifact path is supplied", () => {
    // Arrange
    const text = taskPlan(25);

    // Act
    const result = validateArtifactWithWarnings({ artifactType: "plan", text });

    // Assert
    expect(sizeErrors(result.errors)).toHaveLength(1);
  });
});
