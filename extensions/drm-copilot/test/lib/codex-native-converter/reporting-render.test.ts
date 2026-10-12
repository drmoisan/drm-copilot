// Coverage tests for `src/lib/codex-native-converter/reporting-render.ts`,
// added under the coordinator standing decision of 2026-10-09 for #796 (every
// changed line must be covered).
import { describe, expect, it } from "@jest/globals";

import { renderConversionReport } from "../../../src/lib/codex-native-converter/reporting-render";
import {
  type RunOptions,
  SectionIntentKind,
  SourceEcosystem,
  TargetRole,
  type TranslationTrace,
  type ValidationFinding,
} from "../../../src/lib/codex-native-converter/models";

const RUN_OPTIONS: RunOptions = {
  mode: "review",
  sourceRoot: "fixtures/source",
  sourceEcosystem: SourceEcosystem.GITHUB_COPILOT,
  selectedPaths: [],
  destinationRoot: null,
  artifactRoot: "fixtures/artifacts",
  enableRepoPrompts: false,
  emitIntermediateState: false,
};

/** Build a trace that shares one source path and one section id. */
function trace(
  heading: string,
  targetRole: TargetRole,
  targetPath: string | null,
): TranslationTrace {
  return {
    sourcePath: ".github/prompts/p.prompt.md",
    sectionId: ".github/prompts/p.prompt.md#workflow-3",
    heading,
    intentKind: SectionIntentKind.SHARED_WORKFLOW,
    targetRole,
    targetPath,
    notes: [],
  };
}

/** Build a validation finding with the given sort keys. */
function finding(
  code: string,
  sourcePath: string | null,
  targetPath: string | null,
  message: string,
): ValidationFinding {
  return {
    code,
    severity: "warning",
    blocking: false,
    sourcePath,
    targetPath,
    message,
    recommendedAction: "none",
  };
}

describe("coverage: reporting-render.ts", () => {
  it("orders section traces with equal source and section by target role, then target path", () => {
    // Arrange: equal sourcePath and sectionId, so targetRole and then
    // targetPath decide; the input order is the reverse of the expected one.
    const traces = [
      trace("third", TargetRole.SHARED_SKILL, "z/SKILL.md"),
      trace("second", TargetRole.SHARED_SKILL, "a/SKILL.md"),
      trace("first", TargetRole.HOOK, null),
    ];

    // Act
    const report = renderConversionReport(RUN_OPTIONS, [], [], traces, []);

    // Assert: "hook" sorts before "shared-skill"; within shared-skill the
    // target path decides.
    const first = report.indexOf("`first`");
    const second = report.indexOf("`second`");
    const third = report.indexOf("`third`");
    expect(first).toBeGreaterThan(-1);
    expect(first).toBeLessThan(second);
    expect(second).toBeLessThan(third);
  });

  it("orders validation findings by code, then source path, then target path", () => {
    // Arrange: equal codes force the source-path and target-path keys.
    const findings = [
      finding("C1", "b.md", null, "msg-four"),
      finding("C1", "a.md", "z.md", "msg-three"),
      finding("C1", "a.md", "m.md", "msg-two"),
      finding("C0", null, null, "msg-one"),
    ];

    // Act
    const report = renderConversionReport(RUN_OPTIONS, [], [], [], findings);

    // Assert
    const lines = report.split("\n").filter((line) => line.startsWith("- `C"));
    expect(lines).toEqual([
      "- `C0`: msg-one",
      "- `C1`: msg-two",
      "- `C1`: msg-three",
      "- `C1`: msg-four",
    ]);
  });

  it("889-null-arm: sorts a null trace target path before a non-null one in both input orders", () => {
    // Arrange: equal source, section, and role, so the target path decides;
    // both input orders exercise the null default on each operand.
    const nonNull = trace("second", TargetRole.SHARED_SKILL, "a/SKILL.md");
    const nullPath = trace("first", TargetRole.SHARED_SKILL, null);
    const inputOrders = [
      [nonNull, nullPath],
      [nullPath, nonNull],
    ];

    for (const traces of inputOrders) {
      // Act
      const report = renderConversionReport(RUN_OPTIONS, [], [], traces, []);

      // Assert: the null-path trace renders first.
      const first = report.indexOf("`first`");
      expect(first).toBeGreaterThan(-1);
      expect(first).toBeLessThan(report.indexOf("`second`"));
    }
  });

  it("889-null-arm: sorts a null finding target path before a non-null one in both input orders", () => {
    // Arrange: equal code and source path, so the target path decides.
    const nonNull = finding("C", "a.md", "z.md", "two");
    const nullPath = finding("C", "a.md", null, "one");
    const inputOrders = [
      [nonNull, nullPath],
      [nullPath, nonNull],
    ];

    for (const findings of inputOrders) {
      // Act
      const report = renderConversionReport(RUN_OPTIONS, [], [], [], findings);

      // Assert
      const lines = report
        .split("\n")
        .filter((line) => line.startsWith("- `C`:"));
      expect(lines).toEqual(["- `C`: one", "- `C`: two"]);
    }
  });
});
