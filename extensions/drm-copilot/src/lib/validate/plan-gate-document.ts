/**
 * Evaluate the document-level plan-gate rules G11, G12, and G13.
 *
 * Purpose:
 *     Port `scripts/dev_tools/plan_gate_document.py`. Report the plan-text
 *     defects that make a design-level plan go stale or grow past review size
 *     (issue #964). G11 reports a line-number citation, G12 reports a
 *     commit-SHA citation, and G13 reports a plan whose task or physical-line
 *     count exceeds the size guideline without a `## Size Justification`
 *     section.
 *
 * Invariants / Constraints:
 *     - All three rules are document-level and context-free. They read the
 *       whole plan text, skip lines inside fenced code blocks, and never
 *       consult the repository seam.
 *     - Every finding string is byte-identical to the Python rule's message.
 *       The offending value is rendered verbatim between backticks; no
 *       `pythonRepr`-style helper is called.
 *     - No pattern uses lookbehind, so the JavaScript and Python dialects
 *       agree; G12's adjacency conditions are checked in code.
 *     - The module imports only type declarations from `plan-gate-rules.ts`
 *       and the shared line splitter, `PLAN_WHITESPACE_CLASS`, and
 *       `normalizePlanWhitespace` from `plan-gate-commands.ts`, so the import
 *       graph stays acyclic.
 *
 * Side Effects:
 *     None. The module reads no file, clock, environment variable, or git
 *     state.
 */

import {
  normalizePlanWhitespace,
  PLAN_WHITESPACE_CLASS,
  splitPlanLines,
} from "./plan-gate-commands";
import type { PlanGateReport } from "./plan-gate-rules";

/** G11 ships on the Blocking channel by operator-approved scope (issue #964). */
export const G11_SEVERITY: string = "blocking";
/** G12 ships on the Blocking channel by operator-approved scope (issue #964). */
export const G12_SEVERITY: string = "blocking";
/** G13 ships on the Blocking channel because its exoneration is author-controlled. */
export const G13_SEVERITY: string = "blocking";

/** G13 guideline for canonical task lines. */
export const PLAN_TASK_GUIDELINE = 40;
/** G13 guideline for physical lines. */
export const PLAN_LINE_GUIDELINE = 400;

/** G11 prose form, evaluated with inline code spans masked. */
export const G11_PROSE_PATTERN = String.raw`\b[Ll]ines?[ \t]+[0-9]+`;
/** G11 path form, evaluated including inline code. */
export const G11_PATH_PATTERN = String.raw`[A-Za-z0-9_./-]+\.[A-Za-z][A-Za-z0-9]{0,5}:[0-9]+`;
/** G11 anchor form. */
export const G11_ANCHOR_PATTERN = String.raw`#L[0-9]+`;
/** G12 bounded hexadecimal run; digit, letter, and adjacency checks are code. */
export const G12_SHA_PATTERN = String.raw`\b[0-9a-f]{7,40}\b`;
/** G13 canonical task line. */
export const G13_TASK_PATTERN = String.raw`^- \[[ xX]\] \[P[0-9]+-T[0-9]+\] `;
/** Inline code span masked before the G11 prose form is applied. */
export const INLINE_CODE_PATTERN = "`[^`]*`";

/** The command extractor's fence pattern, as in `plan-gate-scratch.ts`. */
const FENCE_RE = /^\s*```/;
const PROSE_RE = new RegExp(G11_PROSE_PATTERN, "g");
const PATH_RE = new RegExp(G11_PATH_PATTERN, "g");
const ANCHOR_RE = new RegExp(G11_ANCHOR_PATTERN, "g");
const SHA_RE = new RegExp(G12_SHA_PATTERN, "g");
const TASK_RE = new RegExp(G13_TASK_PATTERN);
const INLINE_CODE_RE = new RegExp(INLINE_CODE_PATTERN, "g");
const WHITESPACE_RE = new RegExp(`^${PLAN_WHITESPACE_CLASS}$`);
const JUSTIFICATION_HEADING_RE = /^##[ \t]+Size Justification[ \t]*$/;
const SECTION_END_RE = /^#{1,2}(?:[ \t]|$)/;
const HEADING_RE = /^#{1,6}(?:[ \t]|$)/;
const DIGITS = "0123456789";
const HEX_LETTERS = "abcdef";
const SHA_BEFORE_REJECT = "-_.";
const SHA_AFTER_REJECT = "-_";

/**
 * Return every physical line outside a fenced code block with its number.
 *
 * @param text Full document text.
 * @returns `[1-based line number, line]` pairs in source order; fence lines
 *     themselves are excluded.
 */
export function unfencedLines(text: string): Array<[number, string]> {
  const result: Array<[number, string]> = [];
  let inFence = false;
  for (const [index, line] of splitPlanLines(text).entries()) {
    if (FENCE_RE.test(line)) {
      inFence = !inFence;
      continue;
    }
    if (!inFence) {
      result.push([index + 1, line]);
    }
  }
  return result;
}

/**
 * Replace each inline code span with spaces of the same length.
 *
 * @param line Physical line.
 * @returns The line with inline code masked.
 */
function maskInlineCode(line: string): string {
  return line.replace(INLINE_CODE_RE, (span) => " ".repeat(span.length));
}

/**
 * Return whether one character belongs to `PLAN_WHITESPACE_CLASS`.
 *
 * @param character Single character, or undefined past the line end.
 * @returns True for a whitespace class member.
 */
function isWhitespace(character: string | undefined): boolean {
  return character !== undefined && WHITESPACE_RE.test(character);
}

/**
 * Return the whitespace-delimited token that contains a match.
 *
 * @param line Physical line.
 * @param start Match start index.
 * @param end Match end index.
 * @returns The enclosing token.
 */
function enclosingToken(line: string, start: number, end: number): string {
  let left = start;
  while (left > 0 && !isWhitespace(line[left - 1])) {
    left -= 1;
  }
  let right = end;
  while (right < line.length && !isWhitespace(line[right])) {
    right += 1;
  }
  return line.slice(left, right);
}

/**
 * Return every G11 line-number citation in unfenced text.
 *
 * @param text Full document text.
 * @returns One `[line number, matched text]` pair per match, in line order
 *     and, within a line, in form order (prose, path, anchor).
 */
export function lineCitations(text: string): Array<[number, string]> {
  const findings: Array<[number, string]> = [];
  for (const [lineNumber, line] of unfencedLines(text)) {
    for (const match of maskInlineCode(line).matchAll(PROSE_RE)) {
      findings.push([lineNumber, match[0]]);
    }
    for (const match of line.matchAll(PATH_RE)) {
      const token = enclosingToken(
        line,
        match.index,
        match.index + match[0].length,
      );
      if (!token.includes("://")) {
        findings.push([lineNumber, match[0]]);
      }
    }
    for (const match of line.matchAll(ANCHOR_RE)) {
      findings.push([lineNumber, match[0]]);
    }
  }
  return findings;
}

/**
 * Return whether a bounded hex run is reportable as a commit SHA.
 *
 * @param line Physical line.
 * @param start Match start index.
 * @param end Match end index.
 * @returns True when the run has a digit and a letter and no rejected
 *     neighbour.
 */
function isShaCandidate(line: string, start: number, end: number): boolean {
  const token = line.slice(start, end);
  if (![...token].some((character) => DIGITS.includes(character))) {
    return false;
  }
  if (![...token].some((character) => HEX_LETTERS.includes(character))) {
    return false;
  }
  const before = start > 0 ? line.charAt(start - 1) : "";
  if (before !== "" && SHA_BEFORE_REJECT.includes(before)) {
    return false;
  }
  const after = end < line.length ? line.charAt(end) : "";
  return !(after !== "" && SHA_AFTER_REJECT.includes(after));
}

/**
 * Return every G12 commit-SHA citation in unfenced text.
 *
 * @param text Full document text.
 * @returns One `[line number, hex run]` pair per accepted match.
 */
export function shaCitations(text: string): Array<[number, string]> {
  const findings: Array<[number, string]> = [];
  for (const [lineNumber, line] of unfencedLines(text)) {
    for (const match of line.matchAll(SHA_RE)) {
      if (isShaCandidate(line, match.index, match.index + match[0].length)) {
        findings.push([lineNumber, match[0]]);
      }
    }
  }
  return findings;
}

/**
 * Return whether a `## Size Justification` section carries content.
 *
 * @param text Full document text.
 * @returns True when an unfenced, non-blank, non-heading line follows the
 *     heading before the next heading of level one or two.
 */
export function hasSizeJustification(text: string): boolean {
  let inSection = false;
  for (const [, line] of unfencedLines(text)) {
    if (JUSTIFICATION_HEADING_RE.test(line)) {
      inSection = true;
      continue;
    }
    if (!inSection) {
      continue;
    }
    if (SECTION_END_RE.test(line)) {
      inSection = false;
      continue;
    }
    if (normalizePlanWhitespace(line) !== "" && !HEADING_RE.test(line)) {
      return true;
    }
  }
  return false;
}

/**
 * Return the canonical task-line count and the physical-line count.
 *
 * @param text Full document text.
 * @returns `[unfenced task lines, physical lines]`.
 */
export function planSize(text: string): [number, number] {
  const tasks = unfencedLines(text).filter(([, line]) =>
    TASK_RE.test(line),
  ).length;
  return [tasks, splitPlanLines(text).length];
}

/**
 * Return the G11 finding string, byte-identical to Python.
 *
 * @param lineNumber 1-based physical line number.
 * @param value Matched citation text.
 * @returns The finding string.
 */
export function lineCitationMessage(lineNumber: number, value: string): string {
  return (
    `Line ${String(lineNumber)}: line-number citation \`${value}\` anchors on a ` +
    "position that moves when main moves; cite the symbol, heading, or " +
    "test name instead."
  );
}

/**
 * Return the G12 finding string, byte-identical to Python.
 *
 * @param lineNumber 1-based physical line number.
 * @param value Matched hex run.
 * @returns The finding string.
 */
export function shaCitationMessage(lineNumber: number, value: string): string {
  return (
    `Line ${String(lineNumber)}: commit-SHA citation \`${value}\` names a commit ` +
    "that goes stale when main moves; cite the branch, ref name, or merge " +
    "base derivation instead."
  );
}

/**
 * Return the G13 finding string, byte-identical to Python.
 *
 * @param tasks Canonical task-line count.
 * @param lines Physical-line count.
 * @returns The finding string.
 */
export function planSizeMessage(tasks: number, lines: number): string {
  return (
    `Line 1: plan size \`${String(tasks)} tasks, ${String(lines)} lines\` exceeds the ` +
    `guideline of ${String(PLAN_TASK_GUIDELINE)} tasks or ${String(PLAN_LINE_GUIDELINE)} ` +
    "lines and carries no `## Size Justification` section; split the item " +
    "or state why the size is necessary."
  );
}

/**
 * Return the report list a severity constant selects.
 *
 * @param report Report holding both channels.
 * @param severity Channel name.
 * @returns The Blocking list for `"blocking"`, otherwise the Warning list.
 */
function channelFor(report: PlanGateReport, severity: string): string[] {
  return severity === "blocking" ? report.blocking : report.warnings;
}

/**
 * Append the G11, G12, and G13 findings for a plan document to the report.
 *
 * @param report Report whose channels receive the findings.
 * @param text Full plan document text.
 */
export function evaluateDocumentGates(
  report: PlanGateReport,
  text: string,
): void {
  const g11 = channelFor(report, G11_SEVERITY);
  for (const [lineNumber, value] of lineCitations(text)) {
    g11.push(lineCitationMessage(lineNumber, value));
  }
  const g12 = channelFor(report, G12_SEVERITY);
  for (const [lineNumber, value] of shaCitations(text)) {
    g12.push(shaCitationMessage(lineNumber, value));
  }
  const [tasks, lines] = planSize(text);
  const overGuideline =
    tasks > PLAN_TASK_GUIDELINE || lines > PLAN_LINE_GUIDELINE;
  if (overGuideline && !hasSizeJustification(text)) {
    channelFor(report, G13_SEVERITY).push(planSizeMessage(tasks, lines));
  }
}
