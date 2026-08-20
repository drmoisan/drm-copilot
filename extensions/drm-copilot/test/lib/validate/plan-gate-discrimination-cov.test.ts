import { describe, expect, it } from "@jest/globals";

import {
  covValues,
  dottedRemedy,
  evaluatePlanGates,
} from "../../../src/lib/validate/plan-gate-discrimination";
import { classifyKind } from "../../../src/lib/validate/plan-gate-commands";

const PHASE = "### Phase 3 — Work";

/** Build a minimal one-task plan whose acceptance bullet holds a command. */
function plan(acceptance: string, task = "P3-T4"): string {
  return [
    PHASE,
    `- [ ] [${task}] Do the thing`,
    `  - Acceptance: \`${acceptance}\` reports 0 failed.`,
    "",
  ].join("\n");
}

describe("evaluatePlanGates --cov classification", () => {
  it.each([
    // Placeholder values are never judged: the command was not meant to run.
    ["poetry run pytest --cov=<module>", 0, 0],
    // A `.py` suffix names a filesystem path, which coverage.py rejects.
    ["poetry run pytest --cov=scripts/dev_tools/foo.py", 1, 0],
    // Truncation at the first `::` exposes the `.py` suffix.
    ["poetry run pytest --cov=scripts/dev_tools/foo.py::TestFoo", 1, 0],
    // A slash path with no suffix needs the tracked tree, so no finding.
    ["poetry run pytest --cov=scripts/dev_tools/foo", 0, 0],
    // A tracked directory spelling likewise needs the tracked tree.
    ["poetry run pytest --cov=scripts/dev_tools", 0, 0],
    // A dotted module name is the accepted form.
    ["poetry run pytest --cov=scripts.dev_tools.foo", 0, 0],
    // `.` is an accepted coverage target.
    ["poetry run pytest --cov=.", 0, 0],
    // An empty value carries no path separator and is accepted.
    ["poetry run pytest --cov= tests", 0, 0],
    // The space-separated form is a Warning regardless of the value.
    ["poetry run pytest --cov tests/foo", 0, 1],
    // Neighbouring coverage flags are not `--cov` arguments.
    ["poetry run pytest --cov-branch --cov-report=term-missing", 0, 0],
  ])(
    "classifies %s on its severity channel",
    (
      acceptance: string,
      expectedBlocking: number,
      expectedWarnings: number,
    ) => {
      // Arrange
      const text = plan(acceptance);

      // Act
      const report = evaluatePlanGates(text);

      // Assert
      expect(report.blocking).toHaveLength(expectedBlocking);
      expect(report.warnings).toHaveLength(expectedWarnings);
    },
  );

  it("reports the dotted remedy for a .py cov path without context", () => {
    // Arrange
    const text = plan("poetry run pytest --cov=scripts/dev_tools/foo.py");

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toHaveLength(1);
    const finding = report.blocking[0] ?? "";
    expect(finding).toBe(
      "[P3-T4] --cov argument `scripts/dev_tools/foo.py` names a filesystem " +
        "path; coverage.py accepts only directories or importable names. " +
        "Use --cov=scripts.dev_tools.foo.",
    );
    expect(finding.slice(finding.indexOf("Use --cov="))).not.toContain(".py");
    expect(dottedRemedy("scripts\\dev_tools\\foo.py")).toBe(
      "scripts.dev_tools.foo",
    );
  });

  it("renders an offending value containing an apostrophe between backticks", () => {
    // Arrange: double quoting carries the apostrophe through shell splitting.
    const text = plan('poetry run pytest "--cov=scripts/dan\'s_tools/foo.py"');

    // Act
    const report = evaluatePlanGates(text);

    // Assert: the value sits bare between backticks, with no repr-style quotes.
    expect(report.blocking).toEqual([
      "[P3-T4] --cov argument `scripts/dan's_tools/foo.py` names a filesystem " +
        "path; coverage.py accepts only directories or importable names. " +
        "Use --cov=scripts.dan's_tools.foo.",
    ]);
  });

  it("every finding begins with the task identifier", () => {
    // Arrange: one task produces a Blocking finding, the next a Warning.
    const text = [
      PHASE,
      "- [ ] [P3-T4] Blocking case",
      "  - Acceptance: `poetry run pytest --cov=scripts/dev_tools/foo.py`.",
      "- [ ] [P3-T5] Warning case",
      "  - Acceptance: `poetry run pytest --cov tests/foo`.",
      "",
    ].join("\n");

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking.length).toBeGreaterThan(0);
    expect(report.warnings.length).toBeGreaterThan(0);
    expect(
      report.blocking.every((finding) => finding.startsWith("[P3-T4] ")),
    ).toBe(true);
    expect(
      report.warnings.every((finding) => finding.startsWith("[P3-T5] ")),
    ).toBe(true);
  });

  it("treats only exact --cov spellings as coverage arguments", () => {
    // Arrange
    const argv = [
      "poetry",
      "run",
      "pytest",
      "--cov-branch",
      "--cov-report=term-missing",
    ];

    // Act
    const values = covValues({
      taskId: "P3-T4",
      sourceLine: 1,
      rawSpan: argv.join(" "),
      argv,
      kind: classifyKind(argv),
    });

    // Assert
    expect(values).toEqual([]);
  });

  it("produces no finding for a trailing --cov flag with no value", () => {
    // Arrange
    const text = plan("poetry run pytest --cov");

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it.each(["<module>.py", "${MODULE}.py", "$(module).py", "%MODULE%.py"])(
    "suppresses every coverage finding for the marker %s",
    (marker: string) => {
      // Arrange
      const text = plan(`poetry run pytest --cov=scripts/${marker}`);

      // Act
      const report = evaluatePlanGates(text);

      // Assert
      expect(report.blocking).toEqual([]);
      expect(report.warnings).toEqual([]);
    },
  );
});
