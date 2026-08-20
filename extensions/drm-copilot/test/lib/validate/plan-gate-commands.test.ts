import { describe, expect, it } from "@jest/globals";

import {
  extractPlanCommands,
  PLAN_GATE_HEADING_PATTERN,
  PLAN_GATE_TASK_PATTERN,
  splitShellWords,
} from "../../../src/lib/validate/plan-gate-commands";

const TASK_LINE = "- [ ] [P1-T1] Do the thing";

/** Join fixture lines into a plan document. */
function plan(...lines: readonly string[]): string {
  return lines.join("\n") + "\n";
}

describe("extractPlanCommands", () => {
  it("returns the exact record field set", () => {
    // Arrange
    const text = plan(
      "### Phase 1 — Work",
      TASK_LINE,
      "  - Acceptance: `grep -F -n 'MIT License' LICENSE` reports one match.",
    );

    // Act
    const commands = extractPlanCommands(text);

    // Assert
    expect(commands).toHaveLength(1);
    const command = commands[0];
    expect(command).toBeDefined();
    expect(Object.keys(command ?? {}).sort()).toEqual([
      "argv",
      "kind",
      "rawSpan",
      "sourceLine",
      "taskId",
    ]);
    expect(command?.taskId).toBe("P1-T1");
    expect(command?.sourceLine).toBe(3);
    expect(command?.rawSpan).toBe("grep -F -n 'MIT License' LICENSE");
    expect(command?.argv).toEqual([
      "grep",
      "-F",
      "-n",
      "MIT License",
      "LICENSE",
    ]);
    expect(command?.kind).toBe("grep");
  });

  it("classifies grep, pytest_cov, and other kinds", () => {
    // Arrange
    const text = plan(
      "### Phase 1 — Work",
      TASK_LINE,
      "  - Acceptance: `git grep -F -l pinned LICENSE` and",
      "    `poetry run pytest -q --cov=scripts.dev_tools.foo` and",
      "    `poetry run black --check scripts`.",
    );

    // Act
    const kinds = extractPlanCommands(text).map((command) => command.kind);

    // Assert
    expect(kinds).toEqual(["grep", "pytest_cov", "other"]);
  });

  it("skips a span in the document preamble", () => {
    // Arrange: the span precedes the first task line, so it has no owner.
    const text = plan(
      "# Plan",
      "",
      "Run `poetry run pytest -q` before starting.",
      "",
      "### Phase 1 — Work",
      TASK_LINE,
    );

    // Act / Assert
    expect(extractPlanCommands(text)).toEqual([]);
  });

  it("skips a span in a phase preamble", () => {
    // Arrange: the span sits between a phase heading and its first task.
    const text = plan(
      "### Phase 1 — Work",
      "",
      "This phase runs `poetry run pytest -q` at the end.",
      "",
      TASK_LINE,
    );

    // Act / Assert
    expect(extractPlanCommands(text)).toEqual([]);
  });

  it("skips a span after an intervening heading", () => {
    // Arrange: a heading between the task line and the span closes the window.
    const text = plan(
      "### Phase 1 — Work",
      TASK_LINE,
      "",
      "#### Notes",
      "",
      "Run `poetry run pytest -q` manually.",
    );

    // Act / Assert
    expect(extractPlanCommands(text)).toEqual([]);
  });

  it("skips a span with unbalanced quoting", () => {
    // Arrange
    const text = plan(
      "### Phase 1 — Work",
      TASK_LINE,
      '  - Acceptance: `grep -F "unterminated` reports a match.',
    );

    // Act / Assert
    expect(extractPlanCommands(text)).toEqual([]);
    expect(splitShellWords('grep -F "unterminated')).toBeNull();
  });

  it("skips a command with no operand", () => {
    // Arrange: the span splits into fewer than two shell words.
    const text = plan(
      "### Phase 1 — Work",
      TASK_LINE,
      "  - Acceptance: `src/lib/validate/plan-gate-commands.ts` exists.",
    );

    // Act / Assert
    expect(extractPlanCommands(text)).toEqual([]);
  });

  it("splits single-quoted and double-quoted words", () => {
    // Arrange
    const text = plan(
      "### Phase 1 — Work",
      TASK_LINE,
      '  - Acceptance: `grep -n "\\"fast-uri\\"" package.json` reports a match.',
      "  - Acceptance: `grep -F 'MIT License' LICENSE` reports a match.",
    );

    // Act
    const commands = extractPlanCommands(text);

    // Assert
    expect(commands).toHaveLength(2);
    expect(commands[0]?.argv).toHaveLength(4);
    expect(commands[0]?.argv[2]).toBe('"fast-uri"');
    expect(commands[1]?.argv).toEqual(["grep", "-F", "MIT License", "LICENSE"]);
  });

  it("produces identical records for CRLF and LF fixtures", () => {
    // Arrange: the fixture carries an inline span and a fenced block so both
    // scanning paths are exercised under each line-ending convention.
    const lines = [
      "### Phase 1 — Work",
      TASK_LINE,
      "  - Acceptance: `poetry run pytest -q` reports 0 failed.",
      "",
      "```bash",
      "poetry run black --check scripts",
      "",
      "poetry run ruff check scripts",
      "```",
    ];

    // Act
    const lf = extractPlanCommands(lines.join("\n"));
    const crlf = extractPlanCommands(lines.join("\r\n"));

    // Assert
    expect(lf.map((command) => command.rawSpan)).toEqual([
      "poetry run pytest -q",
      "poetry run black --check scripts",
      "poetry run ruff check scripts",
    ]);
    expect(lf.map((command) => command.sourceLine)).toEqual([3, 6, 8]);
    expect(crlf).toEqual(lf);
  });

  it("declares patterns that match canonical task lines and headings", () => {
    // Arrange / Act / Assert
    expect(PLAN_GATE_TASK_PATTERN.test("- [x] [P1-T2] Second task")).toBe(true);
    expect(PLAN_GATE_HEADING_PATTERN.test("#### Notes")).toBe(true);
  });
});
