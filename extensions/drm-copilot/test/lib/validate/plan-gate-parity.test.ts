import { readFileSync } from "node:fs";
import * as path from "node:path";
import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  PLAN_GATE_TASK_PATTERN,
  PLAN_GATE_HEADING_PATTERN,
} from "../../../src/lib/validate/plan-gate-commands";
import { PLAN_TASK_RE } from "../../../src/lib/validate/orchestration-artifacts";
import {
  G5_SEVERITY,
  G7_SEVERITY,
  G8_SEVERITY,
  G8B_SEVERITY,
  G9_SEVERITY,
  type PlanGateContext,
  type PlanGateGitRepository,
  evaluatePlanGates,
} from "../../../src/lib/validate/plan-gate-discrimination";

/**
 * Cross-runtime parity fixtures for the atomic-plan acceptance gates.
 *
 * The eight `PARITY_*` fixtures below are duplicated verbatim in
 * `tests/scripts/dev_tools/test_plan_gate_parity.py`, together with the same
 * expected finding strings, so a divergence in either runtime's message text
 * fails on both sides (spec AC9).
 */

/** Build the shared one-task parity fixture around an acceptance command. */
function parityPlan(acceptance: string): string {
  return [
    "### Phase 1 — Work",
    "- [ ] [P1-T1] Do the thing",
    `  - Acceptance: \`${acceptance}\` reports the result.`,
    "",
  ].join("\n");
}

const PARITY_G1 = parityPlan(
  "poetry run pytest --cov=scripts/dev_tools/foo.py",
);
const PARITY_G2 = parityPlan("poetry run pytest --cov=scripts/dev_tools/foo");
const PARITY_G3 = parityPlan(
  "poetry run pytest --cov=scripts/dev_tools/missing",
);
const PARITY_G4 = parityPlan("poetry run pytest --cov tests.foo");
const PARITY_G5 = parityPlan("grep -F -n 'pinned items occupy' docs/design.md");
const PARITY_G6 = PARITY_G5;
const PARITY_G1_APOSTROPHE = parityPlan(
  'poetry run pytest "--cov=scripts/dan\'s_tools/foo.py"',
);
const PARITY_G5_APOSTROPHE = parityPlan(
  'grep -F -n "the planner\'s cohort" docs/design.md',
);
const PARITY_G7 = parityPlan("poetry run black .");
const PARITY_G8 = parityPlan("git diff -- scripts/dev_tools");
const PARITY_G8B = parityPlan("git diff --name-only main -- scripts/dev_tools");
const PARITY_G9 = parityPlan("poetry run pytest --cov=scripts.dev_tools.foo");
// Each apostrophe-bearing span carries its apostrophe inside double quotes, so
// shell-word splitting succeeds and the rendered span keeps the quotes verbatim.
const PARITY_G7_APOSTROPHE = parityPlan('poetry run black "dan\'s_tools"');
const PARITY_G8_APOSTROPHE = parityPlan('git diff -- "dan\'s_tools"');
const PARITY_G8B_APOSTROPHE = parityPlan(
  'git diff --name-only main -- "dan\'s_tools"',
);
const PARITY_G9_APOSTROPHE = parityPlan(
  'poetry run pytest "--cov=dan\'s_tools.foo"',
);

/**
 * Committed `pyproject.toml` text the G9 rows' stub returns.
 *
 * It reproduces the project's real `addopts`, which supplies an LCOV reporter
 * and no terminal reporter, so G9 decides against the value the repository
 * actually has.
 */
const PARITY_PROJECT_TEXT =
  'addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"';

const EXPECTED_G1 =
  "[P1-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem " +
  "path; coverage.py accepts only directories or importable names. " +
  "Use --cov=scripts.dev_tools.foo.";
const EXPECTED_G2 =
  "[P1-T1] --cov argument `scripts/dev_tools/foo` names a tracked module " +
  "file path; coverage.py accepts only directories or importable names. " +
  "Use --cov=scripts.dev_tools.foo.";
const EXPECTED_G3 =
  "[P1-T1] --cov argument `scripts/dev_tools/missing` contains a path " +
  "separator but resolves to neither a tracked file nor a tracked " +
  "directory; coverage may collect no data. Use the importable dotted form " +
  "or a tracked directory.";
const EXPECTED_G4 =
  "[P1-T1] --cov argument value `tests.foo` is supplied space-separated; " +
  "the ambiguous form can bind the following positional argument. " +
  "Use the --cov=<module> form.";
const EXPECTED_G5 =
  "[P1-T1] search literal `pinned items occupy` is absent from the tracked " +
  "tree and is not quoted in the plan; the search returns zero matches " +
  "whatever the executor does. Quote the exact literal the task will " +
  "create, or assert a literal that exists.";
const EXPECTED_G6 =
  "[P1-T1] search literal `pinned items occupy` is present only across " +
  "adjacent lines of a tracked file and matches no single line; a " +
  "line-oriented search returns zero matches. Search a shorter single-line " +
  "token.";
const EXPECTED_G1_APOSTROPHE =
  "[P1-T1] --cov argument `scripts/dan's_tools/foo.py` names a filesystem " +
  "path; coverage.py accepts only directories or importable names. " +
  "Use --cov=scripts.dan's_tools.foo.";
const EXPECTED_G5_APOSTROPHE =
  "[P1-T1] search literal `the planner's cohort` is absent from the tracked " +
  "tree and is not quoted in the plan; the search returns zero matches " +
  "whatever the executor does. Quote the exact literal the task will " +
  "create, or assert a literal that exists.";

/** Return the frozen G7 finding for one offending span. */
function expectedG7(span: string): string {
  return (
    `[P1-T1] write-mode command \`${span}\` rewrites tracked source and ` +
    "exits 0 after rewriting; the attributed task text carries none of " +
    "its observation markers. Record an observation beyond the exit code."
  );
}

/** Return the frozen G8 finding for one offending span. */
function expectedG8(span: string): string {
  return (
    `[P1-T1] git diff span \`${span}\` carries no ref operand and no ` +
    "--cached flag; it compares the worktree against the index and passes " +
    "vacuously once the change is committed. Anchor the diff to a ref."
  );
}

/** Return the frozen G8b finding for one offending span. */
function expectedG8b(span: string): string {
  return (
    `[P1-T1] name-listing diff \`${span}\` never reports an untracked file, ` +
    "and the attributed task text carries neither a staging span nor a " +
    "porcelain-status span; a path the plan creates is invisible to it. " +
    "Add a staging or porcelain-status companion."
  );
}

/** Return the frozen G9 finding for one offending span. */
function expectedG9(span: string): string {
  return (
    `[P1-T1] coverage command \`${span}\` supplies no terminal reporter and ` +
    "the project addopts supplies none either, so no coverage table is " +
    "printed. Add --cov-report=term-missing."
  );
}

/** Tracked-tree stub configured per parity fixture. */
class ParityGitRepository implements PlanGateGitRepository {
  public constructor(
    private readonly trackedFiles: ReadonlySet<string> = new Set(),
    private readonly matches: Readonly<Record<string, string[]>> = {},
    private readonly texts: Readonly<Record<string, string>> = {},
  ) {}

  public filesContaining(literal: string): string[] {
    return [...(this.matches[literal] ?? [])];
  }

  public isTrackedFile(filePath: string): boolean {
    return this.trackedFiles.has(filePath);
  }

  public isTrackedDirectory(): boolean {
    return false;
  }

  public readTrackedText(filePath: string): string {
    return this.texts[filePath] ?? "";
  }
}

/** Read-only filesystem stub that answers negatively and reads nothing. */
const PARITY_FILE_SYSTEM: FileSystem = {
  glob: () => [],
  isFile: () => false,
  exists: () => false,
  isDirectory: () => false,
  listDirectory: () => [],
  readTextFile: () => "",
  writeTextFile: () => undefined,
  ensureDir: () => undefined,
};

/** Wrap a parity git stub in a context with a stub filesystem. */
function context(git: PlanGateGitRepository): PlanGateContext {
  return {
    workspaceRoot: "/workspace",
    fileSystem: PARITY_FILE_SYSTEM,
    git,
  };
}

const G6_GIT = new ParityGitRepository(
  new Set(),
  { pinned: ["docs/design.md"] },
  { "docs/design.md": "the pinned\nitems occupy the cohort\n" },
);

/** One row per parity fixture whose channel is fixed by its rule. */
const PARITY_CASES: ReadonlyArray<
  readonly [string, string, PlanGateGitRepository, string[], string[]]
> = [
  ["PARITY_G1", PARITY_G1, new ParityGitRepository(), [EXPECTED_G1], []],
  [
    "PARITY_G2",
    PARITY_G2,
    new ParityGitRepository(new Set(["scripts/dev_tools/foo.py"])),
    [EXPECTED_G2],
    [],
  ],
  ["PARITY_G3", PARITY_G3, new ParityGitRepository(), [], [EXPECTED_G3]],
  ["PARITY_G4", PARITY_G4, new ParityGitRepository(), [], [EXPECTED_G4]],
  ["PARITY_G6", PARITY_G6, G6_GIT, [], [EXPECTED_G6]],
  [
    "PARITY_G1_APOSTROPHE",
    PARITY_G1_APOSTROPHE,
    new ParityGitRepository(),
    [EXPECTED_G1_APOSTROPHE],
    [],
  ],
];

/** The two G5 rows, whose channel depends on `G5_SEVERITY`. */
const PARITY_G5_CASES: ReadonlyArray<readonly [string, string, string]> = [
  ["PARITY_G5", PARITY_G5, EXPECTED_G5],
  ["PARITY_G5_APOSTROPHE", PARITY_G5_APOSTROPHE, EXPECTED_G5_APOSTROPHE],
];

const G9_GIT = new ParityGitRepository(
  new Set(),
  {},
  { "pyproject.toml": PARITY_PROJECT_TEXT },
);

/**
 * Eight observability rows: one fixture per new rule plus its
 * apostrophe-bearing twin.
 *
 * Each row carries the severity constant of the rule that produced it, so a
 * Phase 6 severity change moves the assertion to the other channel rather than
 * breaking the row. Only the G9 rows need a stub that answers with the project
 * configuration text; G7, G8, and G8b are context-free.
 */
const PARITY_OBSERVABILITY_CASES: ReadonlyArray<
  readonly [string, string, PlanGateGitRepository, string, string]
> = [
  [
    "PARITY_G7",
    PARITY_G7,
    new ParityGitRepository(),
    expectedG7("poetry run black ."),
    G7_SEVERITY,
  ],
  [
    "PARITY_G7_APOSTROPHE",
    PARITY_G7_APOSTROPHE,
    new ParityGitRepository(),
    expectedG7('poetry run black "dan\'s_tools"'),
    G7_SEVERITY,
  ],
  [
    "PARITY_G8",
    PARITY_G8,
    new ParityGitRepository(),
    expectedG8("git diff -- scripts/dev_tools"),
    G8_SEVERITY,
  ],
  [
    "PARITY_G8_APOSTROPHE",
    PARITY_G8_APOSTROPHE,
    new ParityGitRepository(),
    expectedG8('git diff -- "dan\'s_tools"'),
    G8_SEVERITY,
  ],
  [
    "PARITY_G8B",
    PARITY_G8B,
    new ParityGitRepository(),
    expectedG8b("git diff --name-only main -- scripts/dev_tools"),
    G8B_SEVERITY,
  ],
  [
    "PARITY_G8B_APOSTROPHE",
    PARITY_G8B_APOSTROPHE,
    new ParityGitRepository(),
    expectedG8b('git diff --name-only main -- "dan\'s_tools"'),
    G8B_SEVERITY,
  ],
  [
    "PARITY_G9",
    PARITY_G9,
    G9_GIT,
    expectedG9("poetry run pytest --cov=scripts.dev_tools.foo"),
    G9_SEVERITY,
  ],
  [
    "PARITY_G9_APOSTROPHE",
    PARITY_G9_APOSTROPHE,
    G9_GIT,
    expectedG9('poetry run pytest "--cov=dan\'s_tools.foo"'),
    G9_SEVERITY,
  ],
];

const GATE_MODULE_PATHS = [
  path.join(__dirname, "../../../src/lib/validate/plan-gate-commands.ts"),
  path.join(__dirname, "../../../src/lib/validate/plan-gate-rules.ts"),
  path.join(__dirname, "../../../src/lib/validate/plan-gate-discrimination.ts"),
  path.join(__dirname, "../../../src/lib/validate/plan-gate-observability.ts"),
];

describe("plan acceptance-gate cross-runtime parity", () => {
  it("produces the same finding strings as the Python runtime", () => {
    // Arrange / Act / Assert: one exact list comparison per fixture.
    for (const [name, text, git, blocking, warnings] of PARITY_CASES) {
      const report = evaluatePlanGates(text, context(git));
      expect({ name, blocking: report.blocking }).toEqual({ name, blocking });
      expect({ name, warnings: report.warnings }).toEqual({ name, warnings });
    }

    // The G5 rows assert the finding on the channel `G5_SEVERITY` names and
    // the absence of any finding on the other channel.
    for (const [name, text, expected] of PARITY_G5_CASES) {
      const report = evaluatePlanGates(
        text,
        context(new ParityGitRepository()),
      );
      const expectedBlocking = G5_SEVERITY === "blocking" ? [expected] : [];
      const expectedWarnings = G5_SEVERITY === "blocking" ? [] : [expected];
      expect({ name, blocking: report.blocking }).toEqual({
        name,
        blocking: expectedBlocking,
      });
      expect({ name, warnings: report.warnings }).toEqual({
        name,
        warnings: expectedWarnings,
      });
    }
  });

  it("produces the same observability findings as the Python runtime", () => {
    // Arrange / Act / Assert: each row asserts the finding on the channel its
    // severity constant names and the absence of any finding on the other.
    for (const [
      name,
      text,
      git,
      expected,
      severity,
    ] of PARITY_OBSERVABILITY_CASES) {
      const report = evaluatePlanGates(text, context(git));
      const expectedBlocking = severity === "blocking" ? [expected] : [];
      const expectedWarnings = severity === "blocking" ? [] : [expected];
      expect({ name, blocking: report.blocking }).toEqual({
        name,
        blocking: expectedBlocking,
      });
      expect({ name, warnings: report.warnings }).toEqual({
        name,
        warnings: expectedWarnings,
      });
    }
  });

  it("declares the same task pattern as the validator", () => {
    // Arrange / Act / Assert
    expect(PLAN_GATE_TASK_PATTERN.source).toBe(PLAN_TASK_RE.source);
    expect(PLAN_GATE_HEADING_PATTERN.source).toBe("^#{1,6} ");
  });

  it("renders offending values without pythonRepr formatting", () => {
    // Arrange / Act / Assert: the Python side never calls `repr`, so a
    // `pythonRepr` call would break byte identity in every quoted case. The
    // asserted token is the call form, because the module doc comments name the
    // helper in prose in order to record the prohibition.
    for (const modulePath of GATE_MODULE_PATHS) {
      expect(readFileSync(modulePath, "utf8")).not.toContain("pythonRepr(");
    }
  });
});
