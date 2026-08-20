import type { FileSystem } from "../file-system";
import {
  COV_FLAG,
  COV_FLAG_PREFIX,
  grepExecutableIndex,
  type PlanCommand,
} from "./plan-gate-commands";

/**
 * Shared predicates and the coverage-argument rule cascade for plan gates.
 *
 * Purpose:
 *     Carry the portion of `scripts/dev_tools/plan_gate_discrimination.py` that
 *     is pure: the report shape, the repository seam declarations, the literal
 *     and coverage predicates, and the G1 through G4 coverage cascade. The
 *     module exists because the combined port exceeds the repository's 500-line
 *     ceiling; `plan-gate-discrimination.ts` re-exports every symbol declared
 *     here, so the specification's public surface remains a single module.
 *
 * Invariants / Constraints:
 *     - Every finding string is byte-identical to the Python rule's message.
 *     - Offending values are rendered between backticks. No `pythonRepr`-style
 *       formatting is used, because the Python side does not use `repr()`.
 *     - This module imports the extractor only, so the import direction stays
 *       `orchestration-artifacts` to `plan-gate-discrimination` to
 *       `plan-gate-rules` to `plan-gate-commands` with no cycle.
 *
 * Side Effects:
 *     Queries the injected `git` seam when a context is supplied.
 */

/**
 * Findings produced by one evaluation of the plan acceptance-gate rules.
 *
 * Carries the two severity channels separately so a Warning can never be
 * mistaken for a rejection by a caller that treats a non-empty error list as
 * the failure signal.
 */
export interface PlanGateReport {
  /** Findings that must fail the gate. */
  blocking: string[];
  /** Findings surfaced without failing the gate. */
  warnings: string[];
}

/** Build an empty report with two independent channel arrays. */
export function emptyPlanGateReport(): PlanGateReport {
  return { blocking: [], warnings: [] };
}

/** Blocking severity channel name. */
export const BLOCKING_CHANNEL = "blocking";

/** Warning severity channel name. */
export const WARNING_CHANNEL = "warning";

/**
 * Focused Git query surface the context-requiring rules depend on.
 *
 * Mirrors the Python `PlanGateGitRepository` Protocol member for member.
 */
export interface PlanGateGitRepository {
  /** Return tracked paths carrying the literal on a single line. */
  filesContaining(literal: string): string[];
  /** Return whether `git ls-files` lists the path itself. */
  isTrackedFile(path: string): boolean;
  /** Return whether entries exist beneath the path but none equals it. */
  isTrackedDirectory(path: string): boolean;
  /** Return the committed text of the path at `HEAD`, or an empty string. */
  readTrackedText(path: string): string;
}

/**
 * Injected repository context for the context-requiring plan-gate rules.
 *
 * Mirrors the shape of the epic planner's readiness context so the plan route
 * acquires a repository seam the same way the epic planner route already does.
 */
export interface PlanGateContext {
  /** Workspace root the `git` adapter runs against. */
  readonly workspaceRoot: string;
  /** Read-only filesystem seam. */
  readonly fileSystem: FileSystem;
  /** Tracked-tree query seam. */
  readonly git: PlanGateGitRepository;
}

/** Placeholder and interpolation markers that make a value undecidable. */
const PLACEHOLDER_MARKERS = ["<", ">", "${", "$(", "%"];

/** Path separators that mark a coverage value as a filesystem path. */
const PATH_SEPARATORS = ["/", "\\"];

/** Python module suffix. */
const PYTHON_SUFFIX = ".py";

/** Pytest node-id separator, truncated before the suffix test. */
const PYTEST_NODE_SEPARATOR = "::";

/** Regular-expression metacharacters that make a pattern non-literal. */
const REGEX_METACHARACTERS = new Set([...".*[]^$\\(){}|+?"]);

/** Grep flag that forces fixed-string matching. */
const FIXED_STRING_FLAG = "-F";

/** G6 sliding-window width in adjacent non-blank lines. */
const WINDOW_SIZE = 4;

/**
 * Report whether the value carries a placeholder or interpolation marker.
 *
 * A value the plan spelled with a placeholder was never intended to run
 * verbatim, so its resolvability is not decidable and no rule may report it.
 *
 * @param value Coverage value or search pattern read from a command.
 * @returns True when any placeholder marker occurs in the value.
 */
export function isPlaceholder(value: string): boolean {
  return PLACEHOLDER_MARKERS.some((marker) => value.includes(marker));
}

/**
 * Return the importable dotted form of a filesystem-path coverage value.
 *
 * @param value Coverage value that may carry a `.py` suffix and separators.
 * @returns The value with the `.py` suffix stripped and every separator
 *     replaced by a dot.
 */
export function dottedRemedy(value: string): string {
  const stem = value.endsWith(PYTHON_SUFFIX)
    ? value.slice(0, value.length - PYTHON_SUFFIX.length)
    : value;
  return stem.split("/").join(".").split("\\").join(".");
}

/** One `--cov` argument value and the form it was supplied in. */
export interface CovValue {
  /** The coverage value as written. */
  readonly value: string;
  /** True when the value came from the following word rather than after `=`. */
  readonly spaceSeparated: boolean;
}

/**
 * Return each `--cov` value paired with whether it was space-separated.
 *
 * A word is a `--cov` argument if and only if it equals `--cov` exactly or
 * begins with the six characters `--cov=`, so prefix matching never treats
 * `--cov-branch` or `--cov-report=term-missing` as a `--cov` argument.
 *
 * @param command Extracted command whose argv is scanned.
 * @returns Coverage values in argv order.
 */
export function covValues(command: PlanCommand): CovValue[] {
  const values: CovValue[] = [];
  const argv = command.argv;
  // Walk positionally: the space-separated form takes its value from the
  // following word, which a per-word filter cannot see.
  for (let index = 0; index < argv.length; index += 1) {
    const word = argv[index];
    if (word === undefined) {
      continue;
    }
    if (word === COV_FLAG) {
      const next = argv[index + 1];
      if (next !== undefined) {
        values.push({ value: next, spaceSeparated: true });
      }
      continue;
    }
    if (word.startsWith(COV_FLAG_PREFIX)) {
      values.push({
        value: word.slice(COV_FLAG_PREFIX.length),
        spaceSeparated: false,
      });
    }
  }
  return values;
}

/**
 * Apply the G1 through G4 cascade to one `--cov` value, in place.
 *
 * The cascade decides each value once, so a value G1 rejects is never
 * additionally reported by G2 or G3.
 *
 * @param report Accumulating report the finding is appended to.
 * @param command Command the value was read from.
 * @param cov The coverage value and the form it was supplied in.
 * @param context Repository seam, or `undefined` when only G1 and G4 may run.
 * @returns Nothing. Mutates the supplied report.
 */
export function evaluateCovValue(
  report: PlanGateReport,
  command: PlanCommand,
  cov: CovValue,
  context: PlanGateContext | undefined,
): void {
  const task = command.taskId;

  // G4 is independent of resolvability: the ambiguous form is always reported.
  if (cov.spaceSeparated) {
    report.warnings.push(
      `[${task}] --cov argument value \`${cov.value}\` is supplied ` +
        "space-separated; the ambiguous form can bind the following " +
        "positional argument. Use the --cov=<module> form.",
    );
  }

  if (isPlaceholder(cov.value)) {
    return;
  }

  const truncated = cov.value.split(PYTEST_NODE_SEPARATOR)[0] ?? "";

  // G1 is context-free: a `.py` suffix proves a filesystem path, so no lookup.
  if (truncated.endsWith(PYTHON_SUFFIX)) {
    report.blocking.push(
      `[${task}] --cov argument \`${cov.value}\` names a filesystem path; ` +
        "coverage.py accepts only directories or importable names. " +
        `Use --cov=${dottedRemedy(truncated)}.`,
    );
    return;
  }

  // No path separator means a dotted name, `.`, or empty: all accepted forms.
  if (!PATH_SEPARATORS.some((separator) => cov.value.includes(separator))) {
    return;
  }

  // G2 and G3 need the tracked tree, so without a context they do not run.
  if (context === undefined) {
    return;
  }

  try {
    evaluateTrackedCovValue(report, task, cov, truncated, context);
  } catch {
    // Broad by contract: a validation run must never fail because the
    // repository could not be queried (spec AC10, graceful degradation).
  }
}

/**
 * Apply the tracked-tree rules G2 and G3 to one `--cov` value, in place.
 *
 * @param report Accumulating report the finding is appended to.
 * @param task Canonical `P#-T#` identifier the finding is prefixed with.
 * @param cov The coverage value and the form it was supplied in.
 * @param truncated The value truncated at the first pytest node separator.
 * @param context Repository seam supplying tracked-tree answers.
 * @returns Nothing. Mutates the supplied report.
 */
function evaluateTrackedCovValue(
  report: PlanGateReport,
  task: string,
  cov: CovValue,
  truncated: string,
  context: PlanGateContext,
): void {
  // G2: value plus `.py` is a tracked module, so the remedy is known exactly.
  if (context.git.isTrackedFile(truncated + PYTHON_SUFFIX)) {
    report.blocking.push(
      `[${task}] --cov argument \`${cov.value}\` names a tracked module file ` +
        "path; coverage.py accepts only directories or importable names. " +
        `Use --cov=${dottedRemedy(truncated)}.`,
    );
    return;
  }

  // A tracked directory is an accepted coverage target.
  if (context.git.isTrackedDirectory(truncated)) {
    return;
  }

  // G3: nothing tracked resolves, so warn rather than reject: data collection
  // is unknown rather than provably absent.
  report.warnings.push(
    `[${task}] --cov argument \`${cov.value}\` contains a path separator but ` +
      "resolves to neither a tracked file nor a tracked directory; coverage " +
      "may collect no data. Use the importable dotted form or a tracked " +
      "directory.",
  );
}

/**
 * Return the first non-flag operand after the grep-family executable.
 *
 * Flags and the `--` separator precede the pattern; the first plain word after
 * the executable is the operand.
 *
 * @param argv Shell words of an extracted command.
 * @returns The pattern operand, or `null` when the argv carries none.
 */
export function patternOperand(argv: readonly string[]): string | null {
  const executable = grepExecutableIndex(argv);
  if (executable === null) {
    return null;
  }
  // Walk rightward from the executable, skipping flags, and take the first
  // plain word as the search pattern.
  for (let index = executable + 1; index < argv.length; index += 1) {
    const word = argv[index];
    if (word === undefined || word.startsWith("-")) {
      continue;
    }
    return word;
  }
  return null;
}

/**
 * Return whether the pattern can be checked as a fixed literal.
 *
 * The condition is conservative in POSIX BRE, POSIX ERE, PCRE, and the Rust
 * regex dialect simultaneously, so no dialect-selection logic is required. A
 * placeholder operand is excluded because a command that was never intended to
 * run verbatim states no real acceptance assertion.
 *
 * @param argv Shell words of an extracted command.
 * @param pattern The command's pattern operand.
 * @returns True when the pattern may be compared literally against the tree.
 */
export function isCheckableLiteral(
  argv: readonly string[],
  pattern: string,
): boolean {
  if (isPlaceholder(pattern)) {
    return false;
  }
  if (argv.includes(FIXED_STRING_FLAG)) {
    return true;
  }
  return ![...pattern].some((character) => REGEX_METACHARACTERS.has(character));
}

/**
 * Collapse every whitespace run to a single space and drop empty segments.
 *
 * Mirrors Python `" ".join(value.split())`.
 *
 * @param value Text to normalise.
 * @returns The whitespace-normalised text.
 */
function normalizeWhitespace(value: string): string {
  return value
    .split(/\s+/)
    .filter((word) => word !== "")
    .join(" ");
}

/**
 * Return whether the plan quotes the literal outside its own command span.
 *
 * The literal is read out of a command that is itself part of the plan text, so
 * the originating span must be removed or the answer would be `true`
 * unconditionally. Only the originating span is excluded: erasing every
 * extracted span would delete the plan's normal way of instructing the executor
 * to create a literal.
 *
 * @param text Full plan document text.
 * @param literal The search literal under judgement.
 * @param excludeSpan The `rawSpan` of the command the literal came from.
 * @returns True when the normalised literal occurs in the remaining plan text.
 */
export function planQuotesLiteral(
  text: string,
  literal: string,
  excludeSpan: string,
): boolean {
  const remainder = text.split(excludeSpan).join(" ");
  const needle = normalizeWhitespace(literal);
  if (needle === "") {
    return false;
  }
  return normalizeWhitespace(remainder).includes(needle);
}

/**
 * Return the whitespace-normalised join of each sliding window of lines.
 *
 * One window per start position keeps the boundary exact: lines further apart
 * than `size` never appear in the same join.
 *
 * @param lines Committed file lines, blank lines included.
 * @param size Window width in adjacent non-blank lines.
 * @returns One joined window per non-blank start position.
 */
export function windowJoin(
  lines: readonly string[],
  size: number = WINDOW_SIZE,
): string[] {
  const dense = lines
    .filter((line) => line.trim() !== "")
    .map((line) => normalizeWhitespace(line));
  const windows: string[] = [];
  // Emit one window per start position so the boundary is exact.
  for (let index = 0; index < dense.length; index += 1) {
    windows.push(dense.slice(index, index + size).join(" "));
  }
  return windows;
}

/**
 * Return whether a tracked file carries the literal only across lines.
 *
 * Candidate files are located by searching for the literal's first word, which
 * stays contiguous on one line however the literal wraps.
 *
 * @param context Repository seam supplying tracked-tree answers.
 * @param literal The search literal under judgement.
 * @returns True when some tracked file matches the literal only in its window
 *     join and on no single line.
 */
export function hasCrossLinePresence(
  context: PlanGateContext,
  literal: string,
): boolean {
  const words = literal.split(/\s+/).filter((word) => word !== "");
  if (words.length < 2) {
    return false;
  }
  const needle = words.join(" ");
  const firstWord = words[0] ?? "";

  // A candidate carries the first word on one line: necessary for a wrap.
  for (const path of context.git.filesContaining(firstWord)) {
    const lines = context.git.readTrackedText(path).split(/\r\n|\n|\r/);
    if (lines.some((line) => normalizeWhitespace(line).includes(needle))) {
      continue;
    }
    if (windowJoin(lines).some((window) => window.includes(needle))) {
      return true;
    }
  }
  return false;
}
