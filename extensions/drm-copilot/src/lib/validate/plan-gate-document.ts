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
export const PLAN_TASK_GUIDELINE = 20;
/** G13 guideline for physical lines. */
export const PLAN_LINE_GUIDELINE = 250;
/** G13 task guideline kept by a plan file stamped before its zone's cutoff. */
export const LEGACY_PLAN_TASK_GUIDELINE = 40;
/** G13 line guideline kept by a plan file stamped before its zone's cutoff. */
export const LEGACY_PLAN_LINE_GUIDELINE = 400;

const NEW_YORK_ZONE = "America/New_York";
const UTC_ZONE = "UTC";

/**
 * Stamp zone of each plan-file name shape: the feature-folder tooling stamps
 * `plan.<stamp>.md` in America/New_York, and remediation plans carry the UTC
 * stamp of the review that produced them.
 */
export const PLAN_STAMP_ZONES: Readonly<Record<string, string>> = Object.freeze(
  {
    plan: "America/New_York",
    "plan-remediation-cycle": "UTC",
    "remediation-plan": "UTC",
    "remediation-folder": "UTC",
  },
);

/**
 * G13 guideline cutoff: one instant, the clock reading of the G13 commit,
 * written once per stamp zone. Each entry is a `yyyy-MM-ddTHH-mm` stamp.
 */
export const PLAN_GUIDELINE_CUTOFF: Readonly<Record<string, string>> =
  Object.freeze({
    "America/New_York": "2026-11-07T18-31",
    UTC: "2026-11-07T23-31",
  });

/** A plan-file stamp with the zone of its name shape. */
export type PlanFileStamp = readonly [stamp: string, zone: string];

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
const STAMP_TEXT = "[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}-[0-9]{2}";
/**
 * K4 shapes as patterns over the end of a path, each paired with its zone.
 * Each pattern starts at the path start or a `/` or `\` separator and holds no
 * separator itself, so it matches only a full file name (and, for the folder
 * form, the two full segments above it). Matching is case-sensitive.
 */
const STAMP_SHAPES: readonly (readonly [RegExp, string])[] = [
  [
    new RegExp(String.raw`(?:^|[\\/])plan\.(${STAMP_TEXT})\.md$`),
    NEW_YORK_ZONE,
  ],
  [
    new RegExp(
      String.raw`(?:^|[\\/])plan\.remediation-cycle-[0-9]+\.(${STAMP_TEXT})\.md$`,
    ),
    UTC_ZONE,
  ],
  [
    new RegExp(String.raw`(?:^|[\\/])remediation-plan\.(${STAMP_TEXT})\.md$`),
    UTC_ZONE,
  ],
  [
    new RegExp(
      String.raw`(?:^|[\\/])remediation[\\/](${STAMP_TEXT})[\\/]remediation-plan\.md$`,
    ),
    UTC_ZONE,
  ],
];

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
 * Return the stamp of a plan-file path with the zone of its name shape.
 *
 * Reads the K4 shapes `plan.<stamp>.md` (America/New_York),
 * `plan.remediation-cycle-<N>.<stamp>.md`, `remediation-plan.<stamp>.md`, and
 * `remediation/<stamp>/remediation-plan.md` (all UTC). The path is split on
 * both `/` and `\`, matching is case-sensitive, and each name must match
 * fully. The path is parsed as text and never read from disk.
 *
 * @param path Plan-file path, relative or absolute, or `undefined`.
 * @returns `[stamp, zone]` for a recognized shape; `undefined` for any other
 *     name, an empty path, or no path.
 */
export function planFileStamp(path?: string): PlanFileStamp | undefined {
  // Try each shape in order; the shapes cannot both match one path, and an
  // absent or empty path matches none of them.
  for (const [pattern, zone] of STAMP_SHAPES) {
    const stamp = pattern.exec(path ?? "")?.[1];
    if (stamp !== undefined) {
      return [stamp, zone];
    }
  }
  return undefined;
}

/**
 * Return the G13 task and line guideline that applies to a plan stamp.
 *
 * A stamp is compared, as a string, with the cutoff entry of its own zone, so
 * a UTC stamp is never read against the New York entry.
 *
 * @param stamped `[stamp, zone]` from {@link planFileStamp}, or `undefined`.
 * @param cutoff Cutoff stamp per zone; tests inject a fixed pair.
 * @returns The legacy pair when a stamp exists and sorts strictly before its
 *     zone's entry; otherwise the current pair.
 */
export function planSizeGuideline(
  stamped: PlanFileStamp | undefined,
  cutoff: Readonly<Record<string, string>> = PLAN_GUIDELINE_CUTOFF,
): readonly [number, number] {
  // Only a stamped plan from before the cutoff keeps the legacy pair; an
  // unstamped plan and a stamp at or after the cutoff use the current pair.
  // A zone with no cutoff entry compares with the empty string, which no
  // stamp sorts before, so it uses the current pair.
  if (stamped !== undefined && stamped[0] < (cutoff[stamped[1]] ?? "")) {
    return [LEGACY_PLAN_TASK_GUIDELINE, LEGACY_PLAN_LINE_GUIDELINE];
  }
  return [PLAN_TASK_GUIDELINE, PLAN_LINE_GUIDELINE];
}

/**
 * Return the G13 finding string, byte-identical to Python.
 *
 * @param tasks Canonical task-line count.
 * @param lines Physical-line count.
 * @param guideline The task and line guideline that applied.
 * @returns The finding string.
 */
export function planSizeMessage(
  tasks: number,
  lines: number,
  guideline: readonly [number, number] = [
    PLAN_TASK_GUIDELINE,
    PLAN_LINE_GUIDELINE,
  ],
): string {
  const [taskGuideline, lineGuideline] = guideline;
  return (
    `Line 1: plan size \`${String(tasks)} tasks, ${String(lines)} lines\` exceeds the ` +
    `guideline of ${String(taskGuideline)} tasks or ${String(lineGuideline)} ` +
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
 * G13 selects its guideline from the stamp of `planPath`: a plan stamped
 * before the cutoff of its stamp zone keeps the legacy pair, and a plan with
 * no path or no recognized stamp uses the current pair.
 *
 * @param report Report whose channels receive the findings.
 * @param text Full plan document text.
 * @param planPath Plan-file path, used only to read its stamp.
 */
export function evaluateDocumentGates(
  report: PlanGateReport,
  text: string,
  planPath?: string,
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
  const guideline = planSizeGuideline(planFileStamp(planPath));
  const overGuideline = tasks > guideline[0] || lines > guideline[1];
  if (overGuideline && !hasSizeJustification(text)) {
    channelFor(report, G13_SEVERITY).push(
      planSizeMessage(tasks, lines, guideline),
    );
  }
}
