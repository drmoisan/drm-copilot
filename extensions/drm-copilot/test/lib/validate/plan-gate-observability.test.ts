import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  evaluatePlanGates,
  G7_SEVERITY,
  G8_SEVERITY,
  G8B_SEVERITY,
  G9_SEVERITY,
  WARNING_CHANNEL,
  WRITE_MODE_REGISTER,
  type PlanGateContext,
  type PlanGateGitRepository,
} from "../../../src/lib/validate/plan-gate-discrimination";

/**
 * Unit tests for the G7, G8, G8b, and G9 observability plan-gate rules.
 *
 * The seventeen cases below mirror
 * `tests/scripts/dev_tools/test_plan_gate_observability.py` one for one, so a
 * divergence in either runtime's rule behaviour fails on both sides.
 */

/**
 * Committed `pyproject.toml` text the stub returns.
 *
 * It reproduces the project's real `addopts`, which supplies an LCOV reporter
 * and no terminal reporter, so G9's project-value branch is exercised against
 * the value the repository has.
 */
const PROJECT_TEXT =
  'addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"';

/**
 * One defective fixture span per write-mode register entry.
 *
 * The three PoshQC entries use the two-word form fixed in the plan's standing
 * rules, because the extractor's two-word floor drops a bare single-token tool
 * name.
 */
const REGISTER_FIXTURES: ReadonlyArray<readonly [string, string]> = [
  ["black-write", "poetry run black ."],
  ["ruff-fix", "poetry run ruff check ."],
  ["prettier-write", "npx prettier --write src"],
  ["poshqc-format", "run_poshqc_format scripts/powershell"],
  ["poshqc-analyze-autofix", "run_poshqc_analyze_autofix scripts/powershell"],
  ["poshqc-suite", "run_poshqc_suite scripts/powershell"],
];

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

/** Return the union of both severity channels for a context-free run. */
function findings(text: string): string[] {
  const report = evaluatePlanGates(text);
  return [...report.blocking, ...report.warnings];
}

/** Tracked-tree seam answering negatively except for the project file. */
class StubGitRepository implements PlanGateGitRepository {
  /** Return no matches; the literal rules are not exercised here. */
  public filesContaining(): string[] {
    return [];
  }

  /** Return false; the coverage-path rules are not exercised here. */
  public isTrackedFile(): boolean {
    return false;
  }

  /** Return false; the coverage-path rules are not exercised here. */
  public isTrackedDirectory(): boolean {
    return false;
  }

  /** Return the project configuration text, or an empty string. */
  public readTrackedText(filePath: string): string {
    return filePath === "pyproject.toml" ? PROJECT_TEXT : "";
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

/** Build a context whose seams answer from fixed in-memory values. */
function stubContext(): PlanGateContext {
  return {
    workspaceRoot: "/workspace",
    fileSystem: STUB_FILE_SYSTEM,
    git: new StubGitRepository(),
  };
}

/** Return the union of both channels for a run with the stub context. */
function runWithContext(text: string): string[] {
  const report = evaluatePlanGates(text, stubContext());
  return [...report.blocking, ...report.warnings];
}

describe("plan-gate observability rules", () => {
  it("produces G7 and G8 findings for the two frozen defective spans", () => {
    // Arrange
    const text = plan(
      "### Phase 1 — Work",
      "- [ ] [P1-T1] Format the tree, then confirm the extractor file is intact.",
      "  - Acceptance: `poetry run black .` exits 0, and",
      "    `git diff --exit-code -- scripts/dev_tools/plan_gate_commands.py`",
      "    exits 0.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toHaveLength(2);
  });

  it("reports a write-mode command without an observation marker", () => {
    // Arrange
    const text = oneTaskPlan("  - Acceptance: `poetry run black .` exits 0.");

    // Act
    const report = evaluatePlanGates(text);
    const observed = [...report.blocking, ...report.warnings];

    // Assert
    expect(observed).toEqual([
      "[P1-T1] write-mode command `poetry run black .` rewrites tracked " +
        "source and exits 0 after rewriting; the attributed task text carries " +
        "none of its observation markers. Record an observation beyond the " +
        "exit code.",
    ]);
    const channel =
      G7_SEVERITY === WARNING_CHANNEL ? report.warnings : report.blocking;
    expect(channel).toEqual(observed);
  });

  it("exonerates a task carrying an observation marker", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `poetry run black .` exits 0 and its summary line",
      "    reports that every file was left unchanged.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("exercises every register entry with a fixture", () => {
    // Arrange
    const registered = WRITE_MODE_REGISTER.map((entry) => entry.name);

    // Act / Assert: the set equality catches a missing fixture and the
    // per-entry assertion catches a fixture that no longer matches its entry.
    expect(REGISTER_FIXTURES.map(([name]) => name).sort()).toEqual(
      [...registered].sort(),
    );
    expect(registered).toHaveLength(6);
    for (const [name, span] of REGISTER_FIXTURES) {
      const observed = findings(
        oneTaskPlan(`  - Acceptance: \`${span}\` exits 0.`),
      );
      expect({ name, count: observed.length }).toEqual({ name, count: 1 });
      expect(observed[0]).toContain("[P1-T1] write-mode command ");
      expect(observed[0]).toContain(`\`${span}\``);
    }
  });

  it("ignores the git add and npm ci exclusions", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `git add scripts/dev_tools` exits 0, then",
      "    `npm ci` exits 0.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("reports a bare git diff without a ref operand", () => {
    // Arrange
    const text = oneTaskPlan("  - Acceptance: `git diff` produces no output.");

    // Act
    const report = evaluatePlanGates(text);
    const observed = [...report.blocking, ...report.warnings];

    // Assert
    expect(observed).toEqual([
      "[P1-T1] git diff span `git diff` carries no ref operand and no " +
        "--cached flag; it compares the worktree against the index and passes " +
        "vacuously once the change is committed. Anchor the diff to a ref.",
    ]);
    const channel =
      G8_SEVERITY === WARNING_CHANNEL ? report.warnings : report.blocking;
    expect(channel).toEqual(observed);
  });

  it("reports a pathspec-only git diff", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `git diff -- scripts/dev_tools` produces no output.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toHaveLength(1);
    expect(observed[0]).toContain("[P1-T1] git diff span `git diff -- ");
  });

  it("ignores a git diff carrying a ref operand", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `git diff main -- scripts/dev_tools` produces no output.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("ignores a git diff carrying the cached flag", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `git diff --cached -- scripts/dev_tools` shows the " +
        "staged change.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("exonerates a task carrying a second diff or status span", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `git diff -- scripts/dev_tools` produces no output,",
      "    recorded together with `git status --porcelain -- scripts/dev_tools`.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("reports an anchored name-listing diff without a companion", () => {
    // Arrange
    const span = "git diff --name-only main -- scripts/dev_tools";
    const text = oneTaskPlan(`  - Acceptance: \`${span}\` produces no output.`);

    // Act
    const report = evaluatePlanGates(text);
    const observed = [...report.blocking, ...report.warnings];

    // Assert
    expect(observed).toEqual([
      `[P1-T1] name-listing diff \`${span}\` never reports an untracked file, ` +
        "and the attributed task text carries neither a staging span nor a " +
        "porcelain-status span; a path the plan creates is invisible to it. " +
        "Add a staging or porcelain-status companion.",
    ]);
    const channel =
      G8B_SEVERITY === WARNING_CHANNEL ? report.warnings : report.blocking;
    expect(channel).toEqual(observed);
  });

  it("exonerates a name listing whose task carries a staging span", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `git add scripts/dev_tools` exits 0, then",
      "    `git diff --name-status main -- scripts/dev_tools` lists the path.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("exonerates a name listing whose task carries a porcelain span", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `git diff --name-only main -- scripts/dev_tools` and",
      "    `git status --porcelain -- scripts/dev_tools` are both recorded.",
    );

    // Act
    const observed = findings(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("reports a coverage command without a terminal reporter", () => {
    // Arrange
    const span = "poetry run pytest --cov=scripts.dev_tools.foo";
    const text = oneTaskPlan(`  - Acceptance: \`${span}\` reports the total.`);

    // Act
    const report = evaluatePlanGates(text, stubContext());
    const observed = [...report.blocking, ...report.warnings];

    // Assert
    expect(observed).toEqual([
      `[P1-T1] coverage command \`${span}\` supplies no terminal reporter and ` +
        "the project addopts supplies none either, so no coverage table is " +
        "printed. Add --cov-report=term-missing.",
    ]);
    const channel =
      G9_SEVERITY === WARNING_CHANNEL ? report.warnings : report.blocking;
    expect(channel).toEqual(observed);
  });

  it("ignores a coverage command carrying a terminal reporter", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `poetry run pytest --cov-report=term-missing " +
        "--cov=scripts.dev_tools.foo` reports the total.",
    );

    // Act
    const observed = runWithContext(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("ignores a coverage command carrying a fail-under threshold", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `poetry run pytest --cov-fail-under=85 " +
        "--cov=scripts.dev_tools.foo` exits 0.",
    );

    // Act
    const observed = runWithContext(text);

    // Assert
    expect(observed).toEqual([]);
  });

  it("states the terminal-reporter remedy and claims no unfalsifiability", () => {
    // Arrange
    const text = oneTaskPlan(
      "  - Acceptance: `poetry run pytest --cov=scripts.dev_tools.foo` " +
        "reports the total.",
    );

    // Act
    const observed = runWithContext(text);

    // Assert
    expect(observed).toHaveLength(1);
    expect(observed[0]).toContain("Add --cov-report=term-missing.");
    expect(observed[0]).toContain("no coverage table is printed");
    expect(observed[0]).not.toContain("unfalsifiable");
    expect(observed[0]).not.toContain("cannot fail");
  });
});
