"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.PLAN_GATE_HEADING_PATTERN = exports.PLAN_GATE_TASK_PATTERN = exports.COV_FLAG_PREFIX = exports.COV_FLAG = void 0;
exports.splitShellWords = splitShellWords;
exports.isCovFlagToken = isCovFlagToken;
exports.grepExecutableIndex = grepExecutableIndex;
exports.classifyKind = classifyKind;
exports.extractPlanCommands = extractPlanCommands;
/** Characters that separate shell words outside a quoted run. */
const SHELL_WHITESPACE = new Set([" ", "\t", "\r", "\n"]);
/** Shell escape character. */
const ESCAPE = "\\";
/** Exact `--cov` flag spelling. */
exports.COV_FLAG = "--cov";
/** Prefix of the `--cov=<value>` flag spelling. */
exports.COV_FLAG_PREFIX = "--cov=";
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
exports.PLAN_GATE_TASK_PATTERN = /^- \[(?<state>[ xX])\] \[P(?<phase>\d+)-T(?<task>\d+)\] (?<title>.+)$/;
/** Markdown ATX heading, which closes the current attribution window. */
exports.PLAN_GATE_HEADING_PATTERN = /^#{1,6} /;
/** Single-backtick inline code span. */
const INLINE_SPAN_RE = /`([^`]+)`/g;
/** Fenced-code-block delimiter. */
const FENCE_RE = /^\s*```/;
/** Minimum argv length a usable command candidate must reach. */
const MINIMUM_ARGV_LENGTH = 2;
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
function splitShellWords(span) {
    const words = [];
    // `null` distinguishes "no token in progress" from an empty quoted token, so
    // `--cov=` followed by a space still yields a word.
    let token = null;
    let quote = null;
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
function isCovFlagToken(token) {
    return token === exports.COV_FLAG || token.startsWith(exports.COV_FLAG_PREFIX);
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
function grepExecutableIndex(argv) {
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
function classifyKind(argv) {
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
function splitLines(text) {
    return text.split(/\r\n|\n|\r/);
}
/**
 * Collect every inline code span on one line, in source order.
 *
 * A single line may carry several backticked spans; each is a candidate.
 *
 * @param line One plan line.
 * @returns Span bodies without their surrounding backticks.
 */
function inlineSpans(line) {
    const spans = [];
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
function appendCommand(commands, taskId, sourceLine, rawSpan) {
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
    });
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
function extractPlanCommands(text) {
    const commands = [];
    let currentTask = null;
    let inFence = false;
    const lines = splitLines(text);
    // Walk the plan in source order, maintaining the attribution window so each
    // span is reported against the task whose acceptance condition states it.
    for (let index = 0; index < lines.length; index += 1) {
        const line = lines[index] ?? "";
        const lineNumber = index + 1;
        if (FENCE_RE.test(line)) {
            inFence = !inFence;
            continue;
        }
        // Inside a fence every non-blank line is a whole-line command candidate.
        if (inFence) {
            const fenced = line.trim();
            if (currentTask !== null && fenced !== "") {
                appendCommand(commands, currentTask, lineNumber, fenced);
            }
            continue;
        }
        // A heading closes the current attribution window.
        if (exports.PLAN_GATE_HEADING_PATTERN.test(line)) {
            currentTask = null;
            continue;
        }
        const taskMatch = exports.PLAN_GATE_TASK_PATTERN.exec(line);
        if (taskMatch !== null) {
            const phase = taskMatch.groups?.["phase"] ?? "";
            const task = taskMatch.groups?.["task"] ?? "";
            currentTask = `P${phase}-T${task}`;
        }
        if (currentTask === null) {
            continue;
        }
        // Collect each backticked span on the line as a separate candidate.
        for (const span of inlineSpans(line)) {
            appendCommand(commands, currentTask, lineNumber, span);
        }
    }
    return commands;
}
