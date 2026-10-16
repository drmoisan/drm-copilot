import { readFileSync } from "node:fs";
import * as path from "node:path";
import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import { validateArtifactWithWarnings } from "../../../src/lib/validate/orchestration-artifacts";
import * as discrimination from "../../../src/lib/validate/plan-gate-discrimination";
import {
  emptyPlanGateReport,
  type PlanGateContext,
  type PlanGateGitRepository,
} from "../../../src/lib/validate/plan-gate-rules";
import {
  G10_SEVERITY,
  bareScratchDefinitions,
  evaluateScratchGate,
  scratchFindingMessage,
} from "../../../src/lib/validate/plan-gate-scratch";

/**
 * Unit, dispatcher, and parity tests for the G10 plan-gate rule (issue #932).
 *
 * The fixtures are copied from the `spec.md` detection contract of the issue
 * #932 feature folder and are duplicated in
 * `tests/scripts/dev_tools/test_plan_gate_scratch.py`, together with the same
 * frozen message strings, so a divergence in either runtime fails on both
 * sides.
 */

const ACCEPTED_FORMS: readonly string[] = [
  "- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`.",
  "- `SCRATCH` means `<session scratchpad>/issue-900/`.",
  "- `SCRATCH` = `<session scratchpad>/issue-932-2026-10-15T19-52/`.",
];

const REJECTED_FORMS: readonly string[] = [
  "- SCRATCH means the executor's session scratchpad directory, outside the " +
    "repository.",
  "SCRATCH is the session scratchpad outside the repository.",
  "- `SCRATCH` = the executor session scratchpad directory",
  "- `SCRATCH` = the `889/` subdirectory of the session scratchpad",
  "**SCRATCH:** `SCRATCH` abbreviates the absolute directory " +
    "`<executing worktree root>/SCRATCH`",
  "- SCRATCH := <session scratchpad>",
  "- SCRATCH: the session scratchpad directory",
  "- `SCRATCH` denotes the session scratchpad.",
  "- SCRATCH refers to the session scratchpad.",
  "- SCRATCH stands for the session scratchpad.",
  "- SCRATCH is an alias for the session scratchpad.",
];

const NON_DEFINITIONS: readonly string[] = [
  "Write the report to SCRATCH/932/cov.txt.",
  "SCRATCH is never committed.",
  "Redacted path: <SCRATCH>/x and <SCRATCHPAD>/derive-worklists.ps1",
  "`SCRATCHPAD` = the session scratchpad root",
  'echo "$SCRATCH"',
  "```text\nSCRATCH is the session scratchpad outside the repository.\n```",
];

const WRAPPED_FIXTURE = [
  "Unrelated introductory line.",
  "- SCRATCH means the session scratchpad and is never",
  "  committed to the repository.",
].join("\n");

const DEFINITION_LINE = "- SCRATCH means the session scratchpad.";
const STOP_FIXTURES: readonly string[] = [
  [DEFINITION_LINE, "  ```text", "  fenced content line", "  ```"].join("\n"),
  [DEFINITION_LINE, "## Heading"].join("\n"),
  [DEFINITION_LINE, "- [ ] [P1-T1] Do the thing"].join("\n"),
];

const APOSTROPHE_FIXTURE =
  "- SCRATCH means the executor's session scratchpad directory, outside the " +
  "repository.";
const APOSTROPHE_MESSAGE =
  "Line 1: SCRATCH definition `- SCRATCH means the executor's session " +
  "scratchpad directory, outside the repository.` is not namespaced by issue " +
  "number; define SCRATCH as `<session scratchpad>/issue-<issue-num>/`.";
const TAB_FIXTURE = "- `SCRATCH`\t=\tthe executor session scratchpad directory";
const TAB_MESSAGE =
  "Line 1: SCRATCH definition `- `SCRATCH` = the executor session scratchpad " +
  "directory` is not namespaced by issue number; define SCRATCH as " +
  "`<session scratchpad>/issue-<issue-num>/`.";

const BARE_LINE = "SCRATCH is the session scratchpad outside the repository.";
const BARE_MESSAGE =
  "Line 1: SCRATCH definition `SCRATCH is the session scratchpad outside the " +
  "repository.` is not namespaced by issue number; define SCRATCH as " +
  "`<session scratchpad>/issue-<issue-num>/`.";
const NAMESPACED_LINE =
  "- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`.";

const DISCRIMINATION_SOURCE = path.join(
  __dirname,
  "../../../src/lib/validate/plan-gate-discrimination.ts",
);
const JEST_CONFIG_SOURCE = path.join(__dirname, "../../../jest.config.cjs");

/** Build a structurally valid plan whose first line is the given line. */
function planWithFirstLine(firstLine: string): string {
  return [
    firstLine,
    "### Phase 1 — Work",
    "- [ ] [P1-T1] Do the thing",
    "",
  ].join("\n");
}

/** Tracked-tree seam that answers negatively; G10 never consults it. */
class StubGitRepository implements PlanGateGitRepository {
  /** Return no matches. */
  public filesContaining(): string[] {
    return [];
  }

  /** Return false. */
  public isTrackedFile(): boolean {
    return false;
  }

  /** Return false. */
  public isTrackedDirectory(): boolean {
    return false;
  }

  /** Return an empty string. */
  public readTrackedText(): string {
    return "";
  }
}

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

/** Return a context whose seams answer negatively and perform no I/O. */
function stubContext(): PlanGateContext {
  return {
    workspaceRoot: "/workspace",
    fileSystem: STUB_FILE_SYSTEM,
    git: new StubGitRepository(),
  };
}

/** Return the normalized text of one physical line. */
function normalize(line: string): string {
  return line
    .split(/\s+/)
    .filter((word) => word !== "")
    .join(" ");
}

describe("plan-gate-scratch G10", () => {
  it("declares G10_SEVERITY as the blocking channel", () => {
    // Arrange / Act / Assert
    expect(G10_SEVERITY).toBe("blocking");
  });

  it("accepts every issue-namespaced definition", () => {
    // Arrange
    const expected = ACCEPTED_FORMS.map(() => []);

    // Act
    const results = ACCEPTED_FORMS.map((line) => bareScratchDefinitions(line));

    // Assert
    expect(results).toEqual(expected);
  });

  it("flags each unnamespaced definition exactly once at line 1", () => {
    // Arrange
    const expected = REJECTED_FORMS.map((line) => [[1, normalize(line)]]);

    // Act
    const results = REJECTED_FORMS.map((line) => bareScratchDefinitions(line));

    // Assert
    expect(results).toEqual(expected);
  });

  it("ignores non-definitions and fenced definitions", () => {
    // Arrange
    const expected = NON_DEFINITIONS.map(() => []);

    // Act
    const results = NON_DEFINITIONS.map((text) => bareScratchDefinitions(text));

    // Assert
    expect(results).toEqual(expected);
  });

  it("reports a wrapped definition at its first physical line", () => {
    // Arrange
    const expected = [
      [
        2,
        "- SCRATCH means the session scratchpad and is never committed to " +
          "the repository.",
      ],
    ];

    // Act
    const results = bareScratchDefinitions(WRAPPED_FIXTURE);

    // Assert
    expect(results).toEqual(expected);
  });

  it("stops a logical line at an indented fence and at a column-0 heading or task line", () => {
    // Arrange
    const expected = STOP_FIXTURES.map(() => [[1, DEFINITION_LINE]]);

    // Act
    const results = STOP_FIXTURES.map((text) => bareScratchDefinitions(text));

    // Assert
    expect(results).toEqual(expected);
  });

  it("absorbs an indented heading or task line into the logical line", () => {
    // Arrange
    const fixtures = [
      DEFINITION_LINE + "\n  ## Indented heading",
      DEFINITION_LINE + "\n  - [ ] [P1-T1] Do the thing",
    ];
    const expected = [
      [[1, "- SCRATCH means the session scratchpad. ## Indented heading"]],
      [
        [
          1,
          "- SCRATCH means the session scratchpad. - [ ] [P1-T1] Do the thing",
        ],
      ],
    ];

    // Act
    const results = fixtures.map((text) => bareScratchDefinitions(text));

    // Assert
    expect(results).toEqual(expected);
  });

  it("does not end a physical line at a form feed or a line separator", () => {
    // Arrange
    const fixtures = [
      "intro\fSCRATCH is the session scratchpad.",
      "intro\u2028SCRATCH is the session scratchpad.",
    ];
    const expected = [
      [[1, "intro SCRATCH is the session scratchpad."]],
      [[1, "intro SCRATCH is the session scratchpad."]],
    ];

    // Act
    const results = fixtures.map((text) => bareScratchDefinitions(text));

    // Assert
    expect(results).toEqual(expected);
  });

  it("decides continuation with the plan whitespace class", () => {
    // Arrange: nel-led, unit-separator-led, bom-led, nbsp-led, space-then-nel.
    const fixtures = [
      DEFINITION_LINE + "\n\u0085continued text",
      DEFINITION_LINE + "\n\u001fcontinued text",
      DEFINITION_LINE + "\n\ufeffcontinued text",
      DEFINITION_LINE + "\n\u00a0continued text",
      DEFINITION_LINE + "\n \u0085",
    ];
    const expected = [
      [[1, "- SCRATCH means the session scratchpad."]],
      [[1, "- SCRATCH means the session scratchpad."]],
      [[1, "- SCRATCH means the session scratchpad."]],
      [[1, "- SCRATCH means the session scratchpad. continued text"]],
      [[1, "- SCRATCH means the session scratchpad. \u0085"]],
    ];

    // Act
    const results = fixtures.map((text) => bareScratchDefinitions(text));

    // Assert
    expect(results).toEqual(expected);
  });

  it("normalizes whitespace with the plan whitespace class", () => {
    // Arrange: nel-inline, unit-separator-inline, bom-inline, nbsp-inline.
    const fixtures = [
      "intro\u0085SCRATCH is the session scratchpad.",
      "intro\u001fSCRATCH is the session scratchpad.",
      "intro\ufeffSCRATCH is the session scratchpad.",
      "intro\u00a0SCRATCH is the session scratchpad.",
    ];
    const expected = [
      [[1, "intro\u0085SCRATCH is the session scratchpad."]],
      [[1, "intro\u001fSCRATCH is the session scratchpad."]],
      [[1, "intro\ufeffSCRATCH is the session scratchpad."]],
      [[1, "intro SCRATCH is the session scratchpad."]],
    ];

    // Act
    const results = fixtures.map((text) => bareScratchDefinitions(text));

    // Assert
    expect(results).toEqual(expected);
  });

  it("renders the frozen message for the apostrophe and tab fixtures", () => {
    // Arrange
    const apostropheReport = emptyPlanGateReport();
    const tabReport = emptyPlanGateReport();

    // Act
    evaluateScratchGate(apostropheReport, APOSTROPHE_FIXTURE);
    evaluateScratchGate(tabReport, TAB_FIXTURE);

    // Assert
    expect([apostropheReport.blocking, tabReport.blocking]).toEqual([
      [APOSTROPHE_MESSAGE],
      [TAB_MESSAGE],
    ]);
  });

  it("routes findings to the channel named by the severity argument", () => {
    // Arrange
    const warningReport = emptyPlanGateReport();
    const blockingReport = emptyPlanGateReport();

    // Act
    evaluateScratchGate(warningReport, BARE_LINE, "warning");
    evaluateScratchGate(blockingReport, BARE_LINE, "blocking");

    // Assert
    expect([warningReport, blockingReport]).toEqual([
      { blocking: [], warnings: [BARE_MESSAGE] },
      { blocking: [BARE_MESSAGE], warnings: [] },
    ]);
  });

  it("reports G10 on the blocking channel with and without a context", () => {
    // Arrange
    const text = planWithFirstLine(BARE_LINE);

    // Act
    const withoutContext = discrimination.evaluatePlanGates(text).blocking;
    const withContext = discrimination.evaluatePlanGates(
      text,
      stubContext(),
    ).blocking;

    // Assert
    expect([withoutContext, withContext]).toEqual([
      [BARE_MESSAGE],
      [BARE_MESSAGE],
    ]);
  });

  it("returns the G10 message as an error only for a bare definition", () => {
    // Arrange
    const bare = planWithFirstLine(BARE_LINE);
    const namespaced = planWithFirstLine(NAMESPACED_LINE);

    // Act
    const bareResult = validateArtifactWithWarnings({
      artifactType: "plan",
      text: bare,
    });
    const namespacedResult = validateArtifactWithWarnings({
      artifactType: "plan",
      text: namespaced,
    });

    // Assert
    expect(bareResult.errors).toEqual([BARE_MESSAGE]);
    expect(namespacedResult.errors.join("\n")).not.toContain(
      "SCRATCH definition",
    );
  });

  it("re-exports the G10 symbols from plan-gate-discrimination", () => {
    // Arrange / Act
    const reExported = [
      discrimination.bareScratchDefinitions,
      discrimination.evaluateScratchGate,
      discrimination.scratchFindingMessage,
      discrimination.G10_SEVERITY,
    ];

    // Assert
    expect(reExported).toEqual([
      bareScratchDefinitions,
      evaluateScratchGate,
      scratchFindingMessage,
      G10_SEVERITY,
    ]);
  });

  it("names G10 in the evaluatePlanGates JSDoc", () => {
    // Arrange
    const source = readFileSync(DISCRIMINATION_SOURCE, "utf8");
    const declaration = source.indexOf("export function evaluatePlanGates");
    const docStart = source.lastIndexOf("/**", declaration);

    // Act
    const jsDoc = source.slice(docStart, declaration);

    // Assert
    expect(declaration).toBeGreaterThan(0);
    expect(jsDoc).toContain("G10");
    expect(source).not.toContain("pre-change output");
  });

  it("declares the jest coverage threshold for plan-gate-scratch.ts", () => {
    // Arrange / Act
    const source = readFileSync(JEST_CONFIG_SOURCE, "utf8");

    // Assert
    expect(source).toMatch(
      /"\.\/src\/lib\/validate\/plan-gate-scratch\.ts":\s*\{\s*lines:\s*85,\s*branches:\s*75,?\s*\}/,
    );
  });
});
