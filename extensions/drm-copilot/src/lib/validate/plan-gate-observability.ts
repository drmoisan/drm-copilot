/**
 * Evaluate the G7, G8, G8b, and G9 observability plan-gate rules.
 *
 * Purpose:
 *     Port `scripts/dev_tools/plan_gate_observability.py`. Hold the rule group
 *     that judges whether an atomic plan's acceptance conditions observe
 *     anything beyond an exit code, and whether the ambient state a `git diff`
 *     reads can still discriminate once the change is committed. G7 reports a
 *     write-mode command whose attributed task text records none of the tool's
 *     observation markers. G8 reports an unanchored `git diff`. G8b reports a
 *     name-listing diff that cannot see an untracked path. G9 reports a
 *     coverage command that prints no coverage table.
 *
 * Invariants / Constraints:
 *     - Every finding string is byte-identical to the Python rule's message.
 *     - Offending spans are rendered between backticks. No `pythonRepr`-style
 *       helper is called, because that helper always single-quotes while Python
 *       `repr` selects its quote character from the value's contents, and the
 *       two runtimes must agree byte for byte.
 *     - G7, G8, and G8b are context-free and run on every invocation. G9
 *       requires the tracked-tree seam, because the project `addopts` value can
 *       supply the terminal reporter the command omits.
 *     - This module decides commands only. It never constructs a report or a
 *       context; both arrive as parameters. It imports type declarations and
 *       the channel constants from `plan-gate-rules.ts`, which imports nothing
 *       from here, so the import graph stays acyclic. The Python twin declares
 *       its own copy of the channel names instead, because there the constants
 *       live in the module that imports it and a back-import would form a cycle.
 *
 * Side Effects:
 *     G9 queries the injected `git` seam of the supplied context in order to
 *     read the committed `pyproject.toml`. Nothing else performs I/O, and no
 *     function mutates its inputs beyond appending findings to the report.
 */

import { isCovFlagToken, type PlanCommand } from "./plan-gate-commands";
import {
  BLOCKING_CHANNEL,
  type PlanGateContext,
  type PlanGateReport,
} from "./plan-gate-rules";

/**
 * G7's severity channel.
 *
 * All four observability constants are authored at the Warning channel and are
 * re-set from the pre-declared decision rule applied to the counts recorded in
 * `docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-ambient-state-gates-519/evidence/qa-gates/corpus-measurement.2026-08-24T00-00.md`
 * and by nothing else.
 */
export const G7_SEVERITY: string = "warning";

/** G8's severity channel, fixed by the same corpus measurement as G7. */
export const G8_SEVERITY: string = "warning";

/** G8b's severity channel, fixed by the same corpus measurement as G7. */
export const G8B_SEVERITY: string = "warning";

/** G9's severity channel, fixed by the same corpus measurement as G7. */
export const G9_SEVERITY: string = "warning";

/**
 * One accepted argv shape of a write-mode register entry.
 *
 * Expresses a register entry's argv predicate as data rather than as a
 * callable, so the same six entries are transcribed rather than ported.
 */
export interface WriteModeShape {
  /** Consecutive argv words matched exactly, starting at an executable index. */
  readonly words?: readonly string[];
  /** Alternative to `words`: an executable-position word ending with this text. */
  readonly suffix?: string;
  /** Words that must appear anywhere in the argv for the shape to match. */
  readonly requires?: readonly string[];
}

/**
 * One member of the write-mode register: a predicate plus its markers.
 *
 * Names a tool that rewrites tracked source and still exits 0, together with
 * the literals its success-case output prints. A plan that states such an
 * invocation as an acceptance condition without recording one of those
 * literals has asserted nothing the tool can fail.
 */
export interface WriteModeEntry {
  /** Stable register-entry name, used by the completeness test. */
  readonly name: string;
  /** Accepted argv shapes; any match selects the entry. */
  readonly shapes: readonly WriteModeShape[];
  /** Words whose presence puts the tool into a non-writing mode. */
  readonly excludes: readonly string[];
  /** Observation markers, matched case-sensitively in the attributed text. */
  readonly markers: readonly string[];
}

/**
 * The six-entry write-mode register, in selection order.
 *
 * The first entry whose argv predicate matches decides the command. Each entry
 * names a tool that rewrites tracked source and exits 0 after rewriting, so its
 * exit code cannot distinguish a clean run from a repairing one.
 */
export const WRITE_MODE_REGISTER: readonly WriteModeEntry[] = [
  {
    name: "black-write",
    shapes: [{ words: ["black"] }],
    excludes: ["--check", "--diff"],
    markers: ["reformatted", "left unchanged", "unchanged"],
  },
  {
    name: "ruff-fix",
    shapes: [{ words: ["ruff", "check"] }],
    excludes: ["--no-fix"],
    markers: ["Fixed", "All checks passed", "fixes applied"],
  },
  {
    name: "prettier-write",
    shapes: [
      { words: ["prettier"], requires: ["--write"] },
      { words: ["npm", "run", "format"] },
    ],
    excludes: [],
    markers: ["(unchanged)", "unchanged", "rewrote"],
  },
  {
    name: "poshqc-format",
    shapes: [{ suffix: "run_poshqc_format" }],
    excludes: [],
    markers: ["formatted", "unchanged"],
  },
  {
    name: "poshqc-analyze-autofix",
    shapes: [{ suffix: "run_poshqc_analyze_autofix" }],
    excludes: [],
    markers: ["autofix", "Fixed", "unchanged"],
  },
  {
    name: "poshqc-suite",
    shapes: [{ suffix: "run_poshqc_suite" }],
    excludes: [],
    markers: ["formatted", "unchanged"],
  },
];

/**
 * Leading wrapper window an executable may occupy, matching the extractor's
 * `EXECUTABLE_SCAN_LIMIT`. A tool name further right is an operand, not an
 * invocation, so a task that searches a policy file for a register member's
 * name never reports a finding against its own search command.
 */
const EXECUTABLE_SCAN_LIMIT = 4;

/** Pathspec separator, which ends the operand run of a `git diff` invocation. */
const PATHSPEC_SEPARATOR = "--";

/** Flags that read the index, so the comparison is not the one G8 reports. */
const INDEX_FLAGS = ["--cached", "--staged"];

/** Flags that make a diff enumerate tracked names rather than content. */
const NAME_LISTING_FLAGS = ["--name-only", "--name-status"];

/** Second-diff companion span, searched case-sensitively in the task text. */
const GIT_DIFF_SPAN = "git diff";

/** Status companion span, searched case-sensitively in the task text. */
const GIT_STATUS_SPAN = "git status";

/** Staging companion span, searched case-sensitively in the task text. */
const GIT_ADD_SPAN = "git add";

/** Porcelain-status companion span, searched case-sensitively. */
const GIT_PORCELAIN_SPAN = "git status --porcelain";

/** Project file whose `addopts` value can supply the omitted reporter. */
const PROJECT_CONFIG_PATH = "pyproject.toml";

/** Token prefix that makes a coverage command print a terminal table. */
const TERMINAL_REPORTER_PREFIX = "--cov-report=term";

/** Token prefix that makes a coverage run fail on its own threshold. */
const FAIL_UNDER_PREFIX = "--cov-fail-under";

/**
 * `addopts` assignment patterns, double-quoted form first. They use literal
 * text, character classes, and the `*` quantifier only, so they parse
 * identically in the Python twin's dialect.
 */
const ADDOPTS_PATTERNS = [
  /addopts[ \t]*=[ \t]*"([^"]*)"/,
  /addopts[ \t]*=[ \t]*'([^']*)'/,
];

/** Append one finding to the channel the rule's severity constant names. */
function append(
  report: PlanGateReport,
  severity: string,
  finding: string,
): void {
  const channel =
    severity === BLOCKING_CHANNEL ? report.blocking : report.warnings;
  channel.push(finding);
}

/**
 * Return the argv indices a tool name may occupy to count as an invocation.
 *
 * An index qualifies when it lies inside the leading wrapper window and the
 * word immediately preceding it does not begin with a hyphen, so a tool name
 * supplied as the operand of a search flag is never read as an invocation.
 */
function executablePositions(argv: readonly string[]): number[] {
  const limit = Math.min(argv.length, EXECUTABLE_SCAN_LIMIT);
  const positions: number[] = [];
  for (let index = 0; index < limit; index += 1) {
    if (index === 0 || !(argv[index - 1] ?? "").startsWith("-")) {
      positions.push(index);
    }
  }
  return positions;
}

/** Report whether one accepted argv shape matches the command's argv. */
function shapeMatches(argv: readonly string[], shape: WriteModeShape): boolean {
  const requires = shape.requires ?? [];
  if (requires.some((required) => !argv.includes(required))) {
    return false;
  }
  const words = shape.words ?? [];
  for (const index of executablePositions(argv)) {
    if (shape.suffix !== undefined && shape.suffix !== "") {
      if ((argv[index] ?? "").endsWith(shape.suffix)) {
        return true;
      }
      continue;
    }
    const end = index + words.length;
    if (
      end <= argv.length &&
      words.every((word, offset) => argv[index + offset] === word)
    ) {
      return true;
    }
  }
  return false;
}

/** Return the first register entry whose argv predicate matches, if any. */
function matchingEntry(argv: readonly string[]): WriteModeEntry | null {
  for (const entry of WRITE_MODE_REGISTER) {
    // An excluded word puts the tool into a non-writing mode, so the entry
    // cannot match however its shapes read.
    if (entry.excludes.some((excluded) => argv.includes(excluded))) {
      continue;
    }
    if (entry.shapes.some((shape) => shapeMatches(argv, shape))) {
      return entry;
    }
  }
  return null;
}

/**
 * Return the attributed task text with the offending span removed once.
 *
 * The span is part of the window the markers and companion spans are searched
 * in, so a tool whose own name contains one of its markers would exonerate
 * itself unconditionally. Removing the span first is the same discipline the
 * existing plan-quotation check already applies.
 */
function taskTextWithoutSpan(command: PlanCommand): string {
  return command.taskText.replace(command.rawSpan, " ");
}

/** Apply G7 to one extracted command, in place. */
function evaluateWriteMode(report: PlanGateReport, command: PlanCommand): void {
  const entry = matchingEntry(command.argv);
  if (entry === null) {
    return;
  }
  // A marker is matched case-sensitively as a substring of the whole
  // attribution window, because a plan states its acceptance condition on the
  // lines that follow the task line rather than on the task line itself.
  const remainder = taskTextWithoutSpan(command);
  if (entry.markers.some((marker) => remainder.includes(marker))) {
    return;
  }
  append(
    report,
    G7_SEVERITY,
    `[${command.taskId}] write-mode command \`${command.rawSpan}\` rewrites ` +
      "tracked source and exits 0 after rewriting; the attributed task text " +
      "carries none of its observation markers. Record an observation beyond " +
      "the exit code.",
  );
}

/**
 * Return the index of `diff` in a `git diff` invocation, or `null`.
 *
 * Only the leading wrapper window is scanned, so a `git diff` pair appearing
 * later in the command is an operand rather than the invocation.
 */
function gitDiffIndex(argv: readonly string[]): number | null {
  const limit = Math.min(argv.length, EXECUTABLE_SCAN_LIMIT);
  for (let index = 0; index < limit; index += 1) {
    if (argv[index] === "git" && argv[index + 1] === "diff") {
      return index + 1;
    }
  }
  return null;
}

/** Return the words between `diff` and the `--` pathspec separator. */
function diffOperands(
  argv: readonly string[],
  diffIndex: number,
): readonly string[] {
  const operands: string[] = [];
  for (const word of argv.slice(diffIndex + 1)) {
    if (word === PATHSPEC_SEPARATOR) {
      break;
    }
    operands.push(word);
  }
  return operands;
}

/** Report whether the task text carries a second diff or a status span. */
function carriesPairingCompanion(command: PlanCommand): boolean {
  const remainder = taskTextWithoutSpan(command);
  return (
    remainder.includes(GIT_DIFF_SPAN) || remainder.includes(GIT_STATUS_SPAN)
  );
}

/** Report whether the task text carries a staging or porcelain-status span. */
function carriesListingCompanion(command: PlanCommand): boolean {
  const remainder = taskTextWithoutSpan(command);
  return (
    remainder.includes(GIT_ADD_SPAN) || remainder.includes(GIT_PORCELAIN_SPAN)
  );
}

/** Apply G8 and G8b to one extracted command, in place. */
function evaluateGitDiff(report: PlanGateReport, command: PlanCommand): void {
  const argv = command.argv;
  const diffIndex = gitDiffIndex(argv);
  if (diffIndex === null) {
    return;
  }

  const operands = diffOperands(argv, diffIndex);
  const hasRefOperand = operands.some((word) => !word.startsWith("-"));
  const hasIndexFlag = INDEX_FLAGS.some((flag) => argv.includes(flag));

  // G8: no ref operand and no index flag means the command compares the
  // worktree against the index, which is empty once the change is committed.
  if (!hasRefOperand && !hasIndexFlag) {
    if (!carriesPairingCompanion(command)) {
      append(
        report,
        G8_SEVERITY,
        `[${command.taskId}] git diff span \`${command.rawSpan}\` carries ` +
          "no ref operand and no --cached flag; it compares the worktree " +
          "against the index and passes vacuously once the change is " +
          "committed. Anchor the diff to a ref.",
      );
    }
    return;
  }

  // G8b: an anchored name-listing diff enumerates tracked changes only, so a
  // path the plan creates is invisible to it without a companion span.
  if (hasRefOperand && NAME_LISTING_FLAGS.some((flag) => argv.includes(flag))) {
    if (!carriesListingCompanion(command)) {
      append(
        report,
        G8B_SEVERITY,
        `[${command.taskId}] name-listing diff \`${command.rawSpan}\` never ` +
          "reports an untracked file, and the attributed task text carries " +
          "neither a staging span nor a porcelain-status span; a path the " +
          "plan creates is invisible to it. Add a staging or " +
          "porcelain-status companion.",
      );
    }
  }
}

/**
 * Return the project `addopts` value, or `null` when it cannot be read.
 *
 * Reads the committed `pyproject.toml` through the existing tracked-tree seam
 * so G9 can tell a command that omits a terminal reporter the project supplies
 * from one that omits a reporter nothing supplies. The result is the value with
 * its surrounding quotes removed, an empty string when the file was read but
 * declares no assignment, and `null` when the seam produced no text at all. The
 * three cases are distinguished because the finding claims the project supplies
 * no terminal reporter, and that claim is only supportable when the
 * configuration was actually read.
 */
export function projectAddopts(context: PlanGateContext): string | null {
  const text = context.git.readTrackedText(PROJECT_CONFIG_PATH);
  if (text === "") {
    return null;
  }
  // The double-quoted form is tried first, then the single-quoted form.
  for (const pattern of ADDOPTS_PATTERNS) {
    const match = pattern.exec(text);
    if (match !== null) {
      return match[1] ?? "";
    }
  }
  return "";
}

/**
 * Collect the G9 finding for one extracted command, if it has one.
 *
 * Findings are buffered rather than reported directly, so a repository seam
 * that fails part-way through discards the whole group instead of reporting it
 * partially.
 */
function collectCoverageReporter(
  pending: string[],
  command: PlanCommand,
  addopts: string,
): void {
  const argv = command.argv;
  if (!argv.some((word) => isCovFlagToken(word))) {
    return;
  }
  if (argv.some((word) => word.startsWith(TERMINAL_REPORTER_PREFIX))) {
    return;
  }
  // A coverage threshold makes the run fail on its own, so the acceptance
  // condition discriminates without a printed table.
  if (argv.some((word) => word.startsWith(FAIL_UNDER_PREFIX))) {
    return;
  }
  if (addopts.includes(TERMINAL_REPORTER_PREFIX)) {
    return;
  }
  pending.push(
    `[${command.taskId}] coverage command \`${command.rawSpan}\` supplies no ` +
      "terminal reporter and the project addopts supplies none either, so no " +
      "coverage table is printed. Add --cov-report=term-missing.",
  );
}

/**
 * Apply the observability rule group to every extracted command, in place.
 *
 * Findings are appended to the channel each rule's severity constant names.
 * When `context` is omitted only the context-free rules G7, G8, and G8b run,
 * because G9 cannot tell an omitted reporter from one the project
 * configuration supplies. A failing repository seam discards the whole G9
 * group rather than reporting it partially, and never propagates.
 */
export function evaluateObservabilityGates(
  report: PlanGateReport,
  commands: readonly PlanCommand[],
  context?: PlanGateContext,
): void {
  for (const command of commands) {
    evaluateWriteMode(report, command);
    evaluateGitDiff(report, command);
  }

  if (context === undefined) {
    return;
  }

  const pending: string[] = [];
  try {
    // The project value is read once per evaluation, not once per command.
    const addopts = projectAddopts(context);
    // A seam that produced no text cannot support the finding's claim that the
    // project supplies no terminal reporter, so the group is skipped.
    if (addopts === null) {
      return;
    }
    for (const command of commands) {
      collectCoverageReporter(pending, command, addopts);
    }
  } catch {
    // Broad by contract: a validation run must never fail because the
    // repository could not be queried (spec AC11, graceful degradation).
    return;
  }

  for (const finding of pending) {
    append(report, G9_SEVERITY, finding);
  }
}
