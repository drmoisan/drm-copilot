import { describe, expect, it } from "@jest/globals";

import type { FileSystem } from "../../../src/lib/file-system";
import {
  G5_SEVERITY,
  type PlanGateContext,
  type PlanGateGitRepository,
  type PlanGateReport,
  evaluatePlanGates,
} from "../../../src/lib/validate/plan-gate-discrimination";

const PHASE = "### Phase 2 — Work";
const LITERAL = "pinned items occupy";
const ACCEPTANCE = `grep -F -n '${LITERAL}' docs/design.md`;

/** Stub tracked-tree seam whose answers are supplied per test. */
class StubGitRepository implements PlanGateGitRepository {
  public constructor(
    private readonly matches: Readonly<Record<string, string[]>> = {},
    private readonly texts: Readonly<Record<string, string>> = {},
    private readonly failure: Error | null = null,
  ) {}

  public filesContaining(literal: string): string[] {
    if (this.failure !== null) {
      throw this.failure;
    }
    return [...(this.matches[literal] ?? [])];
  }

  public isTrackedFile(): boolean {
    return false;
  }

  public isTrackedDirectory(): boolean {
    return false;
  }

  public readTrackedText(path: string): string {
    return this.texts[path] ?? "";
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

/** Build a one-task plan whose acceptance bullet holds a command. */
function plan(
  acceptance: string,
  extra: readonly string[] = [],
  task = "P2-T1",
): string {
  return [
    PHASE,
    `- [ ] [${task}] Do the thing`,
    `  - Acceptance: \`${acceptance}\` reports one match.`,
    ...extra,
    "",
  ].join("\n");
}

/** Return the report channel G5 findings are routed to. */
function channel(report: PlanGateReport): string[] {
  return G5_SEVERITY === "blocking" ? report.blocking : report.warnings;
}

/** Return the report channel G5 findings must never appear on. */
function otherChannel(report: PlanGateReport): string[] {
  return G5_SEVERITY === "blocking" ? report.warnings : report.blocking;
}

describe("evaluatePlanGates search literals", () => {
  it("reports a literal absent from tree and plan", () => {
    // Arrange: the only occurrence of the literal is the command span itself.
    const text = plan(ACCEPTANCE);

    // Act
    const report = evaluatePlanGates(text, context(new StubGitRepository()));

    // Assert
    expect(channel(report)).toHaveLength(1);
    expect(otherChannel(report)).toEqual([]);
    expect(channel(report)[0]).toBe(
      "[P2-T1] search literal `pinned items occupy` is absent from the " +
        "tracked tree and is not quoted in the plan; the search returns zero " +
        "matches whatever the executor does. Quote the exact literal the task " +
        "will create, or assert a literal that exists.",
    );
  });

  it("exonerates a literal quoted in the plan", () => {
    // Arrange: the same plan plus one prose sentence quoting the literal.
    const text = plan(ACCEPTANCE, [
      `  - The task writes the sentence ${LITERAL} into the design note.`,
    ]);

    // Act
    const report = evaluatePlanGates(text, context(new StubGitRepository()));

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("reports a cross-line literal as a warning", () => {
    // Arrange: the first word matches a line, but the phrase wraps.
    const git = new StubGitRepository(
      { pinned: ["docs/design.md"] },
      { "docs/design.md": "the pinned\nitems occupy the cohort\n" },
    );

    // Act
    const report = evaluatePlanGates(plan(ACCEPTANCE), context(git));

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([
      "[P2-T1] search literal `pinned items occupy` is present only " +
        "across adjacent lines of a tracked file and matches no single " +
        "line; a line-oriented search returns zero matches. Search a " +
        "shorter single-line token.",
    ]);
  });

  it("skips context rules with no context", () => {
    // Arrange
    const text = plan(ACCEPTANCE, [
      "  - Also: `poetry run pytest --cov=scripts/x`.",
    ]);

    // Act
    const report = evaluatePlanGates(text);

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("produces no finding when the git adapter throws", () => {
    // Arrange
    const git = new StubGitRepository({}, {}, new Error("git unavailable"));

    // Act
    const report = evaluatePlanGates(plan(ACCEPTANCE), context(git));

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("skips a literal containing a placeholder operand", () => {
    // Arrange
    const text = plan("grep -F -n '<expected message>' docs/design.md");

    // Act
    const report = evaluatePlanGates(text, context(new StubGitRepository()));

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("skips a pattern carrying regex metacharacters without -F", () => {
    // Arrange
    const text = plan("grep -n 'recolor_unstarted(' src/lib/validate/foo.ts");

    // Act
    const report = evaluatePlanGates(text, context(new StubGitRepository()));

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("accepts a metacharacter pattern supplied with the fixed-string flag", () => {
    // Arrange
    const text = plan(
      "grep -F -n 'recolor_unstarted(' src/lib/validate/foo.ts",
    );

    // Act
    const report = evaluatePlanGates(text, context(new StubGitRepository()));

    // Assert
    expect(channel(report)).toHaveLength(1);
    expect(channel(report)[0]).toContain("`recolor_unstarted(`");
  });

  it("does not join lines five apart into one window", () => {
    // Arrange: `pinned` is on line 1 and `occupy` on line 5.
    const git = new StubGitRepository(
      { pinned: ["docs/design.md"] },
      { "docs/design.md": "pinned\nalpha\nbeta\ngamma\nitems occupy\n" },
    );

    // Act
    const report = evaluatePlanGates(plan(ACCEPTANCE), context(git));

    // Assert
    expect(channel(report)).toHaveLength(1);
    expect(otherChannel(report)).toEqual([]);
    expect(
      [...report.blocking, ...report.warnings].every(
        (finding) => !finding.includes("shorter single-line token"),
      ),
    ).toBe(true);
  });

  it("exonerates a literal present in the tracked tree", () => {
    // Arrange
    const git = new StubGitRepository({ [LITERAL]: ["docs/design.md"] });

    // Act
    const report = evaluatePlanGates(plan(ACCEPTANCE), context(git));

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("reports a single-word literal without a window scan", () => {
    // Arrange
    const text = plan("grep -F -n pinned docs/design.md");

    // Act
    const report = evaluatePlanGates(text, context(new StubGitRepository()));

    // Assert
    expect(channel(report)).toHaveLength(1);
    expect(otherChannel(report)).toEqual([]);
    expect(channel(report)[0]).toContain("`pinned`");
  });

  it("produces no finding for a grep fragment with no operand", () => {
    // Arrange
    const text = plan("grep -r -F");

    // Act
    const report = evaluatePlanGates(text, context(new StubGitRepository()));

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });

  it("skips the tracked-tree cov rules when the adapter throws", () => {
    // Arrange: a throwing seam must not fail the run for G2 or G3 either.
    class ThrowingTrackedRepository extends StubGitRepository {
      public override isTrackedFile(): boolean {
        throw new Error("git unavailable");
      }
    }
    const text = plan("poetry run pytest --cov=scripts/dev_tools/missing");

    // Act
    const report = evaluatePlanGates(
      text,
      context(new ThrowingTrackedRepository()),
    );

    // Assert
    expect(report.blocking).toEqual([]);
    expect(report.warnings).toEqual([]);
  });
});
