/**
 * Task-attributed shell-command extractor for atomic-plan text.
 *
 * Purpose:
 *     Port `scripts/dev_tools/plan_gate_commands.py`. Provide the reusable
 *     command-extraction layer consumed by the plan acceptance-gate
 *     discrimination rules, reporting every shell command an atomic plan
 *     attributes to a specific task so downstream rules can judge whether the
 *     plan's acceptance conditions are falsifiable.
 *
 * Invariants / Constraints:
 *     - This module declares its own task-line and heading patterns and never
 *       imports `orchestration-artifacts.ts`, which imports this module
 *       transitively. Importing the validator here would form a cycle.
 *     - Record fields and `kind` values are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */

/** Characters that separate shell words outside a quoted run. */
const SHELL_WHITESPACE = new Set([" ", "\t", "\r", "\n"]);

/** Shell escape character. */
const ESCAPE = "\\";

/** Exact `--cov` flag spelling. */
export const COV_FLAG = "--cov";

/** Prefix of the `--cov=<value>` flag spelling. */
export const COV_FLAG_PREFIX = "--cov=";

/** Grep-family executables the literal rules judge. */
const GREP_EXECUTABLES = new Set(["grep", "egrep", "fgrep", "rg"]);

/**
 * Leading-window width searched for the grep-family executable.
 *
 * Scanning only the leading wrapper window keeps a grep-family name that
 * appears as an operand later in the command from being mistaken for the
 * executable.
 */
const EXECUTABLE_SCAN_LIMIT = 4;

/**
 * Canonical task line, declared here and never imported from the validator.
 *
 * `orchestration-artifacts.ts` imports this module transitively, so importing
 * its `PLAN_TASK_RE` here would form a cycle. The parity test
 * `declares the same task pattern as the validator` asserts the two sources
 * stay textually identical.
 */
export const PLAN_GATE_TASK_PATTERN =
  /^- \[(?<state>[ xX])\] \[P(?<phase>\d+)-T(?<task>\d+)\] (?<title>.+)$/;

/** Markdown ATX heading, which closes the current attribution window. */
export const PLAN_GATE_HEADING_PATTERN = /^#{1,6} /;

/** Single-backtick inline code span. */
const INLINE_SPAN_RE = /`([^`]+)`/g;

/** Fenced-code-block delimiter. */
const FENCE_RE = /^\s*```/;

/** Minimum argv length a usable command candidate must reach. */
const MINIMUM_ARGV_LENGTH = 2;

/** Rule family that judges an extracted command. */
export type PlanCommandKind = "grep" | "pytest_cov" | "other";

/**
 * A single shell command an atomic plan attributes to one task.
 *
 * Carries the extracted command together with the plan location and task
 * identifier the discrimination rules need in order to report a finding that a
 * maintainer can act on.
 */
export interface PlanCommand {
  /** Canonical `P#-T#` identifier of the owning task. */
  readonly taskId: string;
  /** 1-based line number the command span was read from. */
  readonly sourceLine: number;
  /** Verbatim span text, before shell-word splitting. */
  readonly rawSpan: string;
  /** Shell words the span splits into. */
  readonly argv: readonly string[];
  /** One of `grep`, `pytest_cov`, or `other`. */
  readonly kind: PlanCommandKind;
  /**
   * Newline-joined text of the command's whole attribution window — the owning
   * task line plus every following line up to, but not including, the line that
   * closes the window. Empty for a record built outside any window. The field
   * is trailing, so every existing construction of this record keeps working.
   */
  readonly taskText: string;
}

/**
 * Split a command span into shell words using POSIX quoting rules.
 *
 * Purpose:
 *     Mirror Python `shlex.split(span, posix=True)`. Reject spans whose quoting
 *     is unbalanced rather than guess at the author's intent, so a malformed
 *     span never produces a finding.
 *
 * Invariants:
 *     - Inside single quotes every character is literal.
 *     - Inside double quotes a backslash emits both characters unless the next
 *       character is the quote character or the escape character itself, which
 *       reproduces `shlex`'s `escapedquotes` behaviour exactly.
 *
 * @param span Verbatim span text read from the plan.
 * @returns Shell words, or `null` when the span's quoting is unbalanced or the
 *     span ends on a dangling escape character.
 */
export function splitShellWords(span: string): readonly string[] | null {
  const words: string[] = [];
  // `null` distinguishes "no token in progress" from an empty quoted token, so
  // `--cov=` followed by a space still yields a word.
  let token: string | null = null;
  let quote: '"' | "'" | null = null;
  let index = 0;

  // Walk the span character by character so quoting state is unambiguous.
  while (index < span.length) {
    const char = span[index] ?? "";
    index += 1;

    // Outside any quoted run: whitespace closes a word, quotes open a run.
    if (quote === null) {
      if (SHELL_WHITESPACE.has(char)) {
        if (token !== null) {
          words.push(token);
          token = null;
        }
        continue;
      }
      if (char === ESCAPE) {
        const next = span[index];
        if (next === undefined) {
          return null;
        }
        index += 1;
        token = (token ?? "") + next;
        continue;
      }
      if (char === '"' || char === "'") {
        quote = char;
        token = token ?? "";
        continue;
      }
      token = (token ?? "") + char;
      continue;
    }

    // Inside a quoted run: only the matching quote closes it.
    if (char === quote) {
      quote = null;
      continue;
    }
    if (quote === '"' && char === ESCAPE) {
      const next = span[index];
      if (next === undefined) {
        return null;
      }
      index += 1;
      if (next !== quote && next !== ESCAPE) {
        token = (token ?? "") + ESCAPE;
      }
      token = (token ?? "") + next;
      continue;
    }
    token = (token ?? "") + char;
  }

  if (quote !== null) {
    return null;
  }
  if (token !== null) {
    words.push(token);
  }
  return words;
}

/**
 * Report whether a shell word is a `--cov` coverage argument.
 *
 * Centralizes the exact token-match rule so neighbouring pytest-cov flags such
 * as `--cov-branch` and `--cov-report=term-missing` are never mistaken for a
 * `--cov` argument by prefix matching.
 *
 * @param token Single shell word from an extracted command.
 * @returns True when the token equals `--cov` exactly or begins with the six
 *     characters `--cov=`.
 */
export function isCovFlagToken(token: string): boolean {
  return token === COV_FLAG || token.startsWith(COV_FLAG_PREFIX);
}

/**
 * Locate the grep-family executable within an argv.
 *
 * Gives both the kind classifier and the pattern-operand selector a single
 * definition of where a grep-family command's operands begin.
 *
 * @param argv Shell words of an extracted command.
 * @returns Index of the grep-family executable, or `null` when the argv does
 *     not invoke one within the leading scan window.
 */
export function grepExecutableIndex(argv: readonly string[]): number | null {
  const limit = Math.min(argv.length, EXECUTABLE_SCAN_LIMIT);
  // Inspect only the leading wrapper window, in order, so the first matching
  // executable wins and later operands never shadow it.
  for (let index = 0; index < limit; index += 1) {
    const word = argv[index];
    if (word === undefined) {
      continue;
    }
    if (GREP_EXECUTABLES.has(word)) {
      return index;
    }
    // `git grep` places the grep-family verb one position after `git`.
    if (word === "git" && argv[index + 1] === "grep") {
      return index + 1;
    }
  }
  return null;
}

/**
 * Classify an extracted command by the rule family that judges it.
 *
 * Executable shape is checked before flag shape because a grep-family
 * invocation is judged by the literal rules regardless of which flags it
 * carries, whereas the coverage rules key on a flag rather than a verb.
 *
 * @param argv Shell words of an extracted command.
 * @returns `grep` for a grep-family invocation, `pytest_cov` for an argv
 *     carrying a `--cov` argument, and `other` otherwise.
 */
export function classifyKind(argv: readonly string[]): PlanCommandKind {
  if (grepExecutableIndex(argv) !== null) {
    return "grep";
  }
  // Any `--cov` argument anywhere in the argv marks the command as a coverage
  // invocation, because wrappers such as `poetry run` push the verb rightward.
  if (argv.some((word) => isCovFlagToken(word))) {
    return "pytest_cov";
  }
  return "other";
}

/**
 * Split document text into lines tolerantly of every line-ending convention.
 *
 * The split expression matches `orchestration-artifacts.ts` line 82 so a CRLF
 * plan and its LF equivalent produce identical records.
 *
 * @param text Full document text.
 * @returns Lines without their terminators.
 */
function splitLines(text: string): string[] {
  if (text === "") {
    return [];
  }
  const lines = text.split(/\r\n|\n|\r/);
  // Python `str.splitlines()` yields no trailing empty line for text that ends
  // with a line terminator, while `String.prototype.split` does. Dropping that
  // element keeps every record field identical across the two runtimes,
  // including the newline-joined whole-window task text. No record was ever
  // produced from the dropped element, so no existing finding changes.
  if (lines[lines.length - 1] === "") {
    lines.pop();
  }
  return lines;
}

/**
 * Collect every inline code span on one line, in source order.
 *
 * A single line may carry several backticked spans; each is a candidate.
 *
 * @param line One plan line.
 * @returns Span bodies without their surrounding backticks.
 */
function inlineSpans(line: string): string[] {
  const spans: string[] = [];
  // `matchAll` iterates non-overlapping spans without mutating the shared
  // regex's `lastIndex`, matching Python `findall` semantics.
  for (const match of line.matchAll(INLINE_SPAN_RE)) {
    const body = match[1];
    if (body !== undefined) {
      spans.push(body);
    }
  }
  return spans;
}

/**
 * Append one extracted command when the span is a usable candidate.
 *
 * Applies the two drop rules — unbalanced quoting and an argv shorter than two
 * words — at the single point where records are created.
 *
 * @param commands Accumulator the record is appended to.
 * @param taskId Canonical `P#-T#` identifier of the owning task.
 * @param sourceLine 1-based line number the span was read from.
 * @param rawSpan Verbatim span text.
 * @returns Nothing. Mutates the supplied accumulator.
 */
function appendCommand(
  commands: PlanCommand[],
  taskId: string,
  sourceLine: number,
  rawSpan: string,
): void {
  const argv = splitShellWords(rawSpan);
  if (argv === null || argv.length < MINIMUM_ARGV_LENGTH) {
    return;
  }
  commands.push({
    taskId,
    sourceLine,
    rawSpan,
    argv,
    kind: classifyKind(argv),
    taskText: "",
  });
}

/**
 * Assign the closing window's whole text to every record it produced.
 *
 * Applies the whole-window definition of attributed task text at the single
 * moment the window closes, so the extractor still walks the document exactly
 * once and no second implementation of the window invariant is created.
 *
 * @param commands Accumulator holding every record so far.
 * @param windowStart Index of the first record the closing window produced;
 *     records before it belong to an earlier window.
 * @param windowLines Verbatim lines of the closing window, in source order.
 * @returns Nothing. Mutates the supplied accumulator.
 */
function closeWindow(
  commands: PlanCommand[],
  windowStart: number,
  windowLines: readonly string[],
): void {
  if (windowStart >= commands.length) {
    return;
  }
  const taskText = windowLines.join("\n");
  for (let index = windowStart; index < commands.length; index += 1) {
    const record = commands[index];
    if (record === undefined) {
      continue;
    }
    commands[index] = { ...record, taskText };
  }
}

/**
 * Extract every task-attributed command candidate from plan text.
 *
 * Purpose:
 *     Walk the plan in source order, tracking the attribution window, and
 *     report the commands a plan states as part of a task's acceptance
 *     condition. Spans outside an attribution window are dropped, because a
 *     span that belongs to no task cannot be reported against one.
 *
 * @param text Full plan document text.
 * @returns Extracted commands in source order.
 */
export function extractPlanCommands(text: string): PlanCommand[] {
  const commands: PlanCommand[] = [];
  let currentTask: string | null = null;
  let inFence = false;
  let windowLines: string[] = [];
  let windowStart = 0;

  const lines = splitLines(text);
  // Walk the plan in source order, maintaining the attribution window so each
  // span is reported against the task whose acceptance condition states it.
  for (let index = 0; index < lines.length; index += 1) {
    const line = lines[index] ?? "";
    const lineNumber = index + 1;

    if (FENCE_RE.test(line)) {
      inFence = !inFence;
      if (currentTask !== null) {
        windowLines.push(line);
      }
      continue;
    }

    // Inside a fence every non-blank line is a whole-line command candidate.
    if (inFence) {
      if (currentTask === null) {
        continue;
      }
      windowLines.push(line);
      const fenced = line.trim();
      if (fenced !== "") {
        appendCommand(commands, currentTask, lineNumber, fenced);
      }
      continue;
    }

    // A heading closes the current attribution window.
    if (PLAN_GATE_HEADING_PATTERN.test(line)) {
      closeWindow(commands, windowStart, windowLines);
      windowStart = commands.length;
      windowLines = [];
      currentTask = null;
      continue;
    }

    const taskMatch = PLAN_GATE_TASK_PATTERN.exec(line);
    if (taskMatch !== null) {
      // A task line closes the preceding window and opens the next one.
      closeWindow(commands, windowStart, windowLines);
      windowStart = commands.length;
      windowLines = [];
      const phase = taskMatch.groups?.["phase"] ?? "";
      const task = taskMatch.groups?.["task"] ?? "";
      currentTask = `P${phase}-T${task}`;
    }

    if (currentTask === null) {
      continue;
    }

    windowLines.push(line);
    // Collect each backticked span on the line as a separate candidate.
    for (const span of inlineSpans(line)) {
      appendCommand(commands, currentTask, lineNumber, span);
    }
  }

  // The end of the document closes the final window.
  closeWindow(commands, windowStart, windowLines);
  return commands;
}
