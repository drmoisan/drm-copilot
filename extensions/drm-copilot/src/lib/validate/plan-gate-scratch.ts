/**
 * Evaluate the G10 plan-gate rule: a SCRATCH definition must name an issue.
 *
 * Purpose:
 *     Port `scripts/dev_tools/plan_gate_scratch.py`. Report every logical line
 *     of an atomic plan that defines the `SCRATCH` token without namespacing it
 *     by issue number. Concurrent child runs in one session share one session
 *     scratchpad, so a plan must point `SCRATCH` at
 *     `<session scratchpad>/issue-<issue-num>/` rather than at the bare
 *     scratchpad (issue #900 introduced the rule; issue #932 enforces it).
 *
 * Invariants / Constraints:
 *     - G10 is document-level and context-free. It reads the whole plan text,
 *       including the preamble the command extractor drops, never consults the
 *       repository seam, and skips lines inside fenced code blocks.
 *     - Every finding string is byte-identical to the Python rule's message.
 *       The logical line is rendered verbatim between backticks; no
 *       `pythonRepr`-style helper is called.
 *     - The module imports only type declarations from `plan-gate-rules.ts`
 *       and the shared line splitter, `PLAN_WHITESPACE_CLASS`, and
 *       `normalizePlanWhitespace` from `plan-gate-commands.ts`, so the import
 *       graph stays acyclic.
 *     - Blank-line, continuation, and normalization tests use
 *       `PLAN_WHITESPACE_CLASS`, which G6 also uses and whose pattern string
 *       is identical in the Python module.
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

/**
 * G10's severity channel, mirroring the Python constant exactly.
 *
 * G10 ships on the Blocking channel by operator-approved scope for issue #932
 * and by the pre-declared two-conjunct decision rule recorded in the issue #932
 * feature folder evidence.
 */
export const G10_SEVERITY: string = "blocking";

/** The backtick character, substituted so the raw patterns match Python's. */
const BACKTICK = "`";

/**
 * Step 1 of the detection contract: a definition of SCRATCH.
 *
 * The pattern uses no lookbehind, so the JavaScript and Python dialects agree.
 * The string is identical to the Python `SCRATCH_DEFINITION_PATTERN`.
 */
export const SCRATCH_DEFINITION_PATTERN = String.raw`(?:^|[^A-Za-z0-9_<>$/.-])${BACKTICK}?SCRATCH${BACKTICK}?(?:\*\*)?[ \t]*(?:means\b|:=|=|:|is (?:the|a|an)\b|resolves to\b|abbreviates\b|denotes\b|refers to\b|stands for\b)`;

/**
 * Step 2 of the detection contract: an accepted issue namespace.
 *
 * The string is identical to the Python `SCRATCH_NAMESPACE_PATTERN`.
 */
export const SCRATCH_NAMESPACE_PATTERN = String.raw`issue-(?:<issue-num>|[0-9]+)`;

/** The command extractor's fence pattern. */
const FENCE_RE = /^\s*```/;

const DEFINITION_RE = new RegExp(SCRATCH_DEFINITION_PATTERN);
const NAMESPACE_RE = new RegExp(SCRATCH_NAMESPACE_PATTERN);

const LEADING_WHITESPACE_RE = new RegExp(`^${PLAN_WHITESPACE_CLASS}`);

/**
 * Return whether a physical line continues the current logical line.
 *
 * A continuation is non-blank, begins with whitespace, and is not a fence
 * line. A Markdown ATX heading or task line written at column 0 therefore ends
 * the logical line, while an indented heading or task line is absorbed into it.
 * Whitespace here means `PLAN_WHITESPACE_CLASS`.
 *
 * @param line Physical line following the logical line's last line.
 * @returns True when the line continues the logical line.
 */
function continuesLogicalLine(line: string): boolean {
  if (
    normalizePlanWhitespace(line) === "" ||
    !LEADING_WHITESPACE_RE.test(line)
  ) {
    return false;
  }
  return !FENCE_RE.test(line);
}

/**
 * Return whether a normalized logical line defines SCRATCH without a namespace.
 *
 * @param logical Normalized logical line.
 * @returns True when the definition pattern matches and the text after the
 *     first definition match carries no accepted issue namespace.
 */
function isBareDefinition(logical: string): boolean {
  const match = DEFINITION_RE.exec(logical);
  if (match === null) {
    return false;
  }
  return !NAMESPACE_RE.test(logical.slice(match.index + match[0].length));
}

/** A logical line under construction: its first line index and its parts. */
interface PendingLogicalLine {
  readonly start: number;
  readonly parts: string[];
}

/**
 * Record one completed logical line when it is a bare SCRATCH definition.
 *
 * @param findings Accumulated findings, appended to in place.
 * @param pending Completed logical line.
 */
function recordIfBare(
  findings: Array<[number, string]>,
  pending: PendingLogicalLine,
): void {
  const logical = normalizePlanWhitespace(pending.parts.join(" "));
  if (isBareDefinition(logical)) {
    findings.push([pending.start + 1, logical]);
  }
}

/**
 * Return every unfenced logical line that defines SCRATCH without an issue.
 *
 * @param text Full document text.
 * @returns One `[line number, normalized logical line]` pair per offending
 *     logical line, in source order. The line number is the 1-based physical
 *     line number of the logical line's first line.
 */
export function bareScratchDefinitions(text: string): Array<[number, string]> {
  const findings: Array<[number, string]> = [];
  let inFence = false;
  let pending: PendingLogicalLine | null = null;

  // Walk the document once. A continuation line extends the pending logical
  // line; any other line completes it. A fence line toggles the fence state,
  // and every fenced line is skipped, so a fenced definition is not reported.
  for (const [index, line] of splitPlanLines(text).entries()) {
    if (pending !== null && continuesLogicalLine(line)) {
      pending.parts.push(line);
      continue;
    }
    if (pending !== null) {
      recordIfBare(findings, pending);
      pending = null;
    }
    if (FENCE_RE.test(line)) {
      inFence = !inFence;
      continue;
    }
    if (inFence || normalizePlanWhitespace(line) === "") {
      continue;
    }
    // A logical line starts here and absorbs its continuation lines.
    pending = { start: index, parts: [line] };
  }
  if (pending !== null) {
    recordIfBare(findings, pending);
  }
  return findings;
}

/**
 * Return the G10 finding string for one offending logical line.
 *
 * @param lineNumber 1-based first physical line of the logical line.
 * @param logicalLine Normalized logical line, rendered verbatim.
 * @returns The Error Message Contract string, byte-identical to Python.
 */
export function scratchFindingMessage(
  lineNumber: number,
  logicalLine: string,
): string {
  return (
    `Line ${String(lineNumber)}: SCRATCH definition \`${logicalLine}\` is not ` +
    "namespaced by issue number; define SCRATCH as " +
    "`<session scratchpad>/issue-<issue-num>/`."
  );
}

/**
 * Append one G10 finding per offending logical line to the report.
 *
 * @param report Report whose channels receive the findings.
 * @param text Full plan document text.
 * @param severity Channel name. `"blocking"` selects the Blocking list; any
 *     other value selects the Warning list. Defaults to `G10_SEVERITY`.
 */
export function evaluateScratchGate(
  report: PlanGateReport,
  text: string,
  severity: string = G10_SEVERITY,
): void {
  const channel = severity === "blocking" ? report.blocking : report.warnings;
  for (const [lineNumber, logicalLine] of bareScratchDefinitions(text)) {
    channel.push(scratchFindingMessage(lineNumber, logicalLine));
  }
}
