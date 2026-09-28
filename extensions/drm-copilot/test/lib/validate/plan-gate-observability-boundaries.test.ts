import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  evaluatePlanGates,
  type PlanGateContext,
  type PlanGateGitRepository,
} from "../../../src/lib/validate/plan-gate-discrimination";

/**
 * Boundary and degradation tests for the observability plan-gate rules.
 *
 * The seventeen rule-behaviour cases live in
 * `plan-gate-observability.test.ts`. This companion file carries the eleven
 * boundary cases mirroring
 * `tests/scripts/dev_tools/test_plan_gate_observability_boundaries.py` one for
 * one: G9's two fault injections, the context-free split, the extraction-floor
 * limitation, the three attribution boundaries, and the four degenerate inputs.
 * The split exists because the twenty-eight required cases do not fit in one
 * file under the 500-line limit.
 */

/** Join fixture lines into a plan document. */
function plan(...lines: readonly string[]): string {
  return lines.join("\n") + "\n";
}

/** Build a one-phase, one-task plan around the supplied acceptance lines. */
function oneTaskPlan(...acceptanceLines: readonly string[]): string {
  return plan(
    "### Phase 1 — Work",
    "- [ ] [P1-T1] Do the thing",
    ...acceptanceLines,
  );
}

/**
 * Build the shared one-task parity fixture around an acceptance command.
 *
 * The builder is duplicated from `plan-gate-parity.test.ts` rather than
 * imported, because importing one Jest suite into another would re-register its
 * `describe` block inside this file's run.
 */
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

/**
 * The two context-free blocking strings recorded by [P0-T13] in
 * `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/baseline/plan-gate-preexisting-output.2026-08-24T00-00.md`.
 * Both are G1 findings; G1 is the only Blocking rule that decides without the
 * repository seam.
 */
const EXPECTED_BLOCKING_G1 =
  "[P1-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem " +
  "path; coverage.py accepts only directories or importable names. " +
  "Use --cov=scripts.dev_tools.foo.";

/**
 * The four fixtures whose rule requires the repository seam produce an empty
 * blocking channel with no context supplied.
 */
const SEAM_REQUIRING_FIXTURES: ReadonlyArray<readonly [string, string]> = [
  ["PARITY_G2", PARITY_G2],
  ["PARITY_G3", PARITY_G3],
  ["PARITY_G5", PARITY_G5],
  ["PARITY_G6", PARITY_G6],
];

const COVERAGE_SPAN = "poetry run pytest --cov=scripts.dev_tools.foo";

/** Tracked-tree seam whose every query raises. */
class RaisingGitRepository implements PlanGateGitRepository {
  /** Raise, standing in for a `git` invocation that could not run. */
  public filesContaining(): string[] {
    throw new Error("git unavailable");
  }

  /** Raise, standing in for a `git` invocation that could not run. */
  public isTrackedFile(): boolean {
    throw new Error("git unavailable");
  }

  /** Raise, standing in for a `git` invocation that could not run. */
  public isTrackedDirectory(): boolean {
    throw new Error("git unavailable");
  }

  /** Raise, standing in for a `git` invocation that could not run. */
  public readTrackedText(): string {
    throw new Error("git unavailable");
  }
}

/**
 * Tracked-tree seam modelling a `git` binary that exits non-zero.
 *
 * The production adapter translates a non-zero exit into a negative or empty
 * answer rather than an error, so this stub returns the same empty values.
 */
class NonZeroExitGitRepository implements PlanGateGitRepository {
  /** Return no matches, as the adapter does on a non-zero exit. */
  public filesContaining(): string[] {
    return [];
  }

  /** Return false, as the adapter does on a non-zero exit. */
  public isTrackedFile(): boolean {
    return false;
  }

  /** Return false, as the adapter does on a non-zero exit. */
  public isTrackedDirectory(): boolean {
    return false;
  }

  /** Return an empty string, as the adapter does on a non-zero exit. */
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

/** Wrap a stub git seam in a context with a stub filesystem. */
function context(git: PlanGateGitRepository): PlanGateContext {
  return {
    workspaceRoot: "/workspace",
    fileSystem: STUB_FILE_SYSTEM,
    git,
  };
}

describe("plan-gate observability boundaries", () => {
  it("skips G9 when the repository seam raises", () => {
    // Arrange
    const text = oneTaskPlan(
      `  - Acceptance: \`${COVERAGE_SPAN}\` reports the total.`,
    );

    // Act: no exception escapes the entry point, which is itself the assertion.
    const report = evaluatePlanGates(text, context(new RaisingGitRepository()));

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("skips G9 when the repository seam reports a non-zero exit", () => {
    // Arrange
    const text = oneTaskPlan(
      `  - Acceptance: \`${COVERAGE_SPAN}\` reports the total.`,
    );

    // Act
    const report = evaluatePlanGates(
      text,
      context(new NonZeroExitGitRepository()),
    );

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("does not run G9 without a context", () => {
    // Arrange
    const text = oneTaskPlan(
      `  - Acceptance: \`${COVERAGE_SPAN}\` reports the total.`,
    );

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("leaves the blocking channel unchanged without a context", () => {
    // Arrange / Act
    const blockingG1 = evaluatePlanGates(PARITY_G1).blocking;
    const blockingG4 = evaluatePlanGates(PARITY_G4).blocking;

    // Assert: G1 is the only Blocking rule that runs without the seam, and no
    // new rule may leak onto the blocking channel beside it.
    expect(blockingG1).toEqual([EXPECTED_BLOCKING_G1]);
    expect(blockingG4).toEqual([]);
    for (const [name, fixture] of SEAM_REQUIRING_FIXTURES) {
      const blocking = evaluatePlanGates(fixture).blocking;
      expect({ name, blocking }).toEqual({ name, blocking: [] });
    }
  });

  it("produces no finding for a single-token tool-name span", () => {
    // Arrange
    const text = oneTaskPlan("  - Acceptance: `run_poshqc_format` exits 0.");

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("produces no finding for a span in the document preamble", () => {
    // Arrange
    const text = plan(
      "# Plan",
      "",
      "Run `poetry run black .` before starting.",
      "",
      "### Phase 1 — Work",
      "- [ ] [P1-T1] Do the thing",
    );

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("produces no finding for a span in a phase preamble", () => {
    // Arrange
    const text = plan(
      "### Phase 1 — Work",
      "",
      "This phase runs `poetry run black .` at the end.",
      "",
      "- [ ] [P1-T1] Do the thing",
    );

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("produces no finding for a span after an intervening heading", () => {
    // Arrange
    const text = plan(
      "### Phase 1 — Work",
      "- [ ] [P1-T1] Do the thing",
      "",
      "#### Notes",
      "",
      "Run `poetry run black .` manually.",
    );

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("produces no finding for an empty plan", () => {
    // Arrange / Act
    const report = evaluatePlanGates("");

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("produces no finding for a plan without task lines", () => {
    // Arrange
    const text = plan(
      "# Plan",
      "",
      "## Notes",
      "",
      "Run `poetry run black .` and `git diff` when convenient.",
    );

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("produces no finding for a command span without an operand", () => {
    // Arrange
    const text = oneTaskPlan("  - Acceptance: `black` is on the path.");

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });
});
