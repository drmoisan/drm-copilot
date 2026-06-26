/**
 * Content and metadata helpers for potential-to-issue promotion workflows.
 *
 * Purpose:
 *     In-process TypeScript port of the bundled
 *     `resources/scripts/dev_tools/potential_to_issue_content.py`. All helpers
 *     here are pure: no subprocess, no filesystem, no wall-clock access. The
 *     workflow module (`promotion.ts`) and the service-call helper consume these
 *     functions to parse potential markdown, build issue bodies, and rewrite the
 *     potential file's metadata block after promotion.
 *
 * Parity:
 *     Regexes, section headings, the smart-punctuation map, body-builder format
 *     strings, the issue-URL pattern, and the `Status` metadata string are
 *     byte-identical to the Python source. `normalizeSmartPunctuation` replaces
 *     ALL occurrences of each mapped character (Python `str.translate`).
 *     `extractLastUpdated` parses the provided ISO timestamp string
 *     deterministically and never reads the wall clock.
 */

import * as nodePath from "node:path";

/** Placeholder inserted when a potential file omits a required section body. */
export const PLACEHOLDER = "(not provided in potential file)";

/**
 * Pattern matching a created-issue URL and capturing the trailing issue number.
 *
 * Mirrors Python `re.compile(r"https?://\S+/issues/(\d+)")`.
 */
export const ISSUE_URL_PATTERN = /https?:\/\/\S+\/issues\/(\d+)/;

/**
 * Canonical bug section headings, in render order.
 *
 * Mirrors the Python `BUG_SECTION_HEADINGS` list verbatim; downstream issue
 * templates and audits rely on this deterministic order.
 */
export const BUG_SECTION_HEADINGS: readonly string[] = [
  "Summary",
  "Environment",
  "Steps to Reproduce",
  "Expected Behavior",
  "Actual Behavior",
  "Logs / Screenshots",
  "Impact / Severity",
];

/**
 * Smart-punctuation to ASCII replacement map.
 *
 * Mirrors the Python `SMART_PUNCTUATION_MAP`: curly double/single quotes to
 * ASCII quotes/apostrophes, en/em dash to hyphen, and non-breaking space to a
 * regular space. Each entry is applied with replace-all semantics.
 */
export const SMART_PUNCTUATION_MAP: Readonly<Record<string, string>> = {
  "“": '"',
  "”": '"',
  "‘": "'",
  "’": "'",
  "–": "-",
  "—": "-",
  " ": " ",
};

/**
 * Escape regular-expression metacharacters in a literal pattern segment.
 *
 * Mirrors Python `re.escape` for the subset of inputs used here (section
 * headings and metadata labels). Returns the input with regex metacharacters
 * backslash-escaped so it can be embedded safely in a dynamic RegExp.
 *
 * @param value Literal text to embed in a RegExp.
 * @returns The text with regex metacharacters escaped.
 */
function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}

/**
 * Remove a trailing `(Potential...)` suffix marker from a heading value.
 *
 * Mirrors Python `strip_potential_marker`: strip the case-insensitive
 * `(Potential...)` marker, trim whitespace, and fall back to the trimmed
 * original when stripping leaves an empty string.
 *
 * @param value Raw heading text that may carry a `(Potential...)` marker.
 * @returns The cleaned heading, or the trimmed original when cleaning empties it.
 */
export function stripPotentialMarker(value: string): string {
  const cleaned = value.replace(/\s*\(Potential[^)]*\)/i, "").trim();
  // Fall back to the trimmed original when the marker was the whole value.
  return cleaned || value.trim();
}

/**
 * Derive the feature name from the first markdown H1 or a filename fallback.
 *
 * Mirrors Python `get_feature_name`: prefer the first `# ` heading (with the
 * `(Potential...)` marker stripped); otherwise use the file basename with a
 * trailing `.md` (case-insensitive) removed.
 *
 * @param content Full potential-file markdown content.
 * @param filePath Resolved potential-file path string (basename used for the
 *   fallback).
 * @returns The derived feature name.
 */
export function getFeatureName(content: string, filePath: string): string {
  // Prefer the first markdown H1 heading when present and non-empty.
  const headingMatch = /^\s*#\s+(.+)$/m.exec(content);
  if (headingMatch?.[1] !== undefined) {
    const featureName = stripPotentialMarker(headingMatch[1]);
    if (featureName) {
      return featureName;
    }
  }

  // Fallback: the basename with a trailing `.md` removed (case-insensitive).
  const name = nodePath.basename(filePath);
  return name.toLowerCase().endsWith(".md") ? name.slice(0, -3) : name;
}

/**
 * Convert a feature name into a filesystem-safe path token.
 *
 * Mirrors Python `get_feature_path`: replace runs of whitespace with `_`, then
 * drop any character outside `[A-Za-z0-9_-]`.
 *
 * @param featureName Human-readable feature name.
 * @returns The sanitized path token.
 */
export function getFeaturePath(featureName: string): string {
  const replaced = featureName.replace(/\s+/g, "_");
  return replaced.replace(/[^A-Za-z0-9_-]/g, "");
}

/**
 * Extract the markdown section body beneath a top-level `## <heading>` block.
 *
 * Mirrors Python `get_section`: match from the heading line up to the next
 * `## ` heading or end-of-string (multiline + dotall semantics), and return the
 * trimmed body. Returns an empty string when the heading is absent.
 *
 * @param content Full markdown content to search.
 * @param heading Heading text (without the leading `## `).
 * @returns The trimmed section body, or `""` when the heading is not found.
 */
export function getSection(content: string, heading: string): string {
  const escaped = escapeRegExp(heading);
  // `[^]` emulates Python DOTALL (`.` matching newlines); the lookahead stops
  // the body at the next `## ` heading (multiline anchor) or end-of-string.
  const pattern = new RegExp(
    `^##\\s+${escaped}\\s*\\r?\\n([^]*?)(?=^##\\s+|$(?![^]))`,
    "m",
  );
  const match = pattern.exec(content);
  if (!match?.[1]) {
    // No heading match, or an empty captured body, yields an empty string.
    return match?.[1] === undefined ? "" : match[1].trim();
  }
  return match[1].trim();
}

/**
 * Construct the standard full-feature issue body.
 *
 * Mirrors Python `build_body`: a `- Work Mode:` first line, five `##` sections,
 * and a `## Source` footer, with `\n\n` between sections and a single trailing
 * newline.
 *
 * @param workMode Selected work mode.
 * @param problem Problem / Why body.
 * @param behavior Proposed Behavior body.
 * @param criteria Acceptance Criteria body.
 * @param constraints Constraints & Risks body.
 * @param tests Test Conditions body.
 * @param relativePath POSIX source path used in the footer.
 * @returns The composed full-feature issue body.
 */
export function buildBody(
  workMode: string,
  problem: string,
  behavior: string,
  criteria: string,
  constraints: string,
  tests: string,
  relativePath: string,
): string {
  return (
    `- Work Mode: ${workMode}\n` +
    `## Problem / Why\n${problem}\n\n` +
    `## Proposed Behavior\n${behavior}\n\n` +
    `## Acceptance Criteria\n${criteria}\n\n` +
    `## Constraints & Risks\n${constraints}\n\n` +
    `## Test Conditions\n${tests}\n\n` +
    `## Source\nFrom: ${relativePath}\n`
  );
}

/**
 * Construct the bug issue body from canonical bug section headings.
 *
 * Mirrors Python `build_bug_body`: a `- Work Mode:` first part, one part per
 * canonical bug heading, and a `## Source` footer part, joined with `\n\n` and
 * terminated with a single trailing newline.
 *
 * @param workMode Selected work mode.
 * @param sections Map from each bug heading to its (placeholder-filled) body.
 * @param relativePath POSIX source path used in the footer.
 * @returns The composed bug issue body.
 */
export function buildBugBody(
  workMode: string,
  sections: Readonly<Record<string, string>>,
  relativePath: string,
): string {
  const parts: string[] = [`- Work Mode: ${workMode}`];
  // Emit one section part per canonical heading, preserving heading order.
  for (const heading of BUG_SECTION_HEADINGS) {
    parts.push(`## ${heading}\n${sections[heading] ?? ""}`);
  }
  parts.push(`## Source\nFrom: ${relativePath}`);
  return parts.join("\n\n") + "\n";
}

/**
 * Evaluate deterministic eligibility for minor-audit mode.
 *
 * Mirrors Python `evaluate_minor_audit_eligibility`. This helper is part of the
 * content module's public surface (covered by the content tests) even though
 * the MCP promotion path does not call it directly.
 *
 * Routing table (decision order matters):
 * - bootstrapped/pre-cooked keyword -> eligible (fast path).
 * - <= 3 production files AND a low-integration-risk signal -> eligible.
 * - > 3 production files -> fallback (overflow).
 * - otherwise -> fallback (missing low-risk signal).
 *
 * @param content Full potential-file markdown content.
 * @returns A `[eligible, reason]` tuple with byte-identical reason strings.
 */
export function evaluateMinorAuditEligibility(
  content: string,
): [boolean, string] {
  const lower = content.toLowerCase();
  // Fast path: explicit bootstrapped/pre-cooked entries are always eligible.
  if (lower.includes("bootstrapped") || lower.includes("pre-cooked")) {
    return [true, "eligible: bootstrapped/pre-cooked"];
  }

  // Count `- [production] file:` lines to gauge production-file footprint.
  const productionFiles = (
    content.match(/^\s*-\s*(?:production\s+)?file\s*:/gim) ?? []
  ).length;
  const hasLowRisk =
    lower.includes("low integration risk") || lower.includes("risk: low");
  if (productionFiles <= 3 && hasLowRisk) {
    return [true, "eligible: <=3 production files and low integration risk"];
  }
  if (productionFiles > 3) {
    return [false, "fallback: production file count exceeds 3"];
  }
  return [false, "fallback: missing low integration risk signal"];
}

/**
 * Build the required issue sections for minor-audit mode.
 *
 * Mirrors Python `build_minor_audit_body`: a `- Work Mode:` first line, six
 * `##` sections, and a `## Source` footer, with `\n\n` between sections and a
 * single trailing newline.
 *
 * @param workMode Selected work mode.
 * @param problem Problem / Why body.
 * @param implementationIntent Implementation Intent body.
 * @param acceptanceCriteria Acceptance Criteria body.
 * @param dependenciesRisks Dependencies / Risks body.
 * @param verificationSteps Verification Steps body.
 * @param evidenceChecklist Evidence Checklist body.
 * @param relativePath POSIX source path used in the footer.
 * @returns The composed minor-audit issue body.
 */
export function buildMinorAuditBody(
  workMode: string,
  problem: string,
  implementationIntent: string,
  acceptanceCriteria: string,
  dependenciesRisks: string,
  verificationSteps: string,
  evidenceChecklist: string,
  relativePath: string,
): string {
  return (
    `- Work Mode: ${workMode}\n` +
    `## Problem / Why\n${problem}\n\n` +
    `## Implementation Intent\n${implementationIntent}\n\n` +
    `## Acceptance Criteria\n${acceptanceCriteria}\n\n` +
    `## Dependencies / Risks\n${dependenciesRisks}\n\n` +
    `## Verification Steps\n${verificationSteps}\n\n` +
    `## Evidence Checklist\n${evidenceChecklist}\n\n` +
    `## Source\nFrom: ${relativePath}\n`
  );
}

/**
 * Parse the created-issue URL and number from gh output lines.
 *
 * Mirrors Python `parse_issue_reference`: join lines with `\n`, search for the
 * issue-URL pattern, and return `[fullUrl, number]` or `[null, null]`.
 *
 * @param output gh stdout+stderr lines.
 * @returns A `[url, number]` tuple, or `[null, null]` when no URL is present.
 */
export function parseIssueReference(
  output: readonly string[],
): [string | null, string | null] {
  const text = output.join("\n");
  const match = ISSUE_URL_PATTERN.exec(text);
  if (!match) {
    return [null, null];
  }
  return [match[0], match[1] ?? null];
}

/**
 * Extract the issue updated date (YYYY-MM-DD) from a gh JSON payload.
 *
 * Mirrors Python `extract_last_updated`: parse JSON (null on parse error), read
 * `updatedAt` (null when missing or non-string), parse the ISO timestamp
 * (replacing a trailing `Z` with `+00:00`), and return the date portion. This
 * parses the provided string deterministically and never reads the wall clock.
 *
 * @param issueJson Raw gh `issue view --json ...` payload text.
 * @returns The `YYYY-MM-DD` date string, or null on any parse failure.
 */
export function extractLastUpdated(issueJson: string): string | null {
  let data: unknown;
  try {
    data = JSON.parse(issueJson);
  } catch {
    // Malformed JSON yields no date, matching Python's JSONDecodeError branch.
    return null;
  }

  // The payload must be an object carrying a string `updatedAt`.
  if (typeof data !== "object" || data === null) {
    return null;
  }
  const updatedRaw = (data as Record<string, unknown>)["updatedAt"];
  if (typeof updatedRaw !== "string") {
    return null;
  }

  // Match Python `datetime.fromisoformat(... .replace("Z", "+00:00"))` by
  // extracting the leading date and validating it as a real calendar date.
  const isoLike = updatedRaw.replace("Z", "+00:00");
  const dateMatch = /^(\d{4})-(\d{2})-(\d{2})/.exec(isoLike);
  if (!dateMatch) {
    return null;
  }
  const datePortion = dateMatch[0];
  // Validate the calendar date (e.g. reject 2024-13-40) without wall-clock use.
  const parsed = new Date(`${datePortion}T00:00:00.000Z`);
  if (
    Number.isNaN(parsed.getTime()) ||
    parsed.toISOString().slice(0, 10) !== datePortion
  ) {
    return null;
  }
  return datePortion;
}

/**
 * Locate the insertion point where the header metadata block ends.
 *
 * Mirrors Python `find_meta_end`: the index of the first line whose left-trimmed
 * content starts with `## `, or `lines.length` when no such line exists.
 *
 * @param lines Potential-file lines.
 * @returns The metadata-block boundary index.
 */
export function findMetaEnd(lines: readonly string[]): number {
  // Walk lines to find the first section heading, which bounds the metadata.
  for (let idx = 0; idx < lines.length; idx += 1) {
    const line = lines[idx] ?? "";
    if (line.trimStart().startsWith("## ")) {
      return idx;
    }
  }
  return lines.length;
}

/**
 * Set or insert a metadata line and return the updated boundary index.
 *
 * Mirrors Python `set_line_value`: when a `- <label>:` line exists, replace it
 * in place and return `metaEnd` unchanged; otherwise insert the new line at
 * `metaEnd` and return `metaEnd + 1`.
 *
 * @param lines Mutable line array (modified in place).
 * @param label Metadata label (e.g. `Issue`).
 * @param value Metadata value.
 * @param metaEnd Current metadata-block boundary index.
 * @returns The (possibly advanced) metadata-block boundary index.
 */
export function setLineValue(
  lines: string[],
  label: string,
  value: string,
  metaEnd: number,
): number {
  const pattern = new RegExp(`^- ${escapeRegExp(label)}:`);
  // Replace an existing label line in place when one is found.
  for (let idx = 0; idx < lines.length; idx += 1) {
    if (pattern.test(lines[idx] ?? "")) {
      lines[idx] = `- ${label}: ${value}`;
      return metaEnd;
    }
  }
  // Otherwise insert the new metadata line at the block boundary.
  lines.splice(metaEnd, 0, `- ${label}: ${value}`);
  return metaEnd + 1;
}

/**
 * Apply issue metadata updates to potential markdown lines.
 *
 * Mirrors Python `update_metadata_lines`: rewrite the title line, then set or
 * insert `Issue`, `Issue URL`, optional `Last Updated`, and `Status` lines. The
 * `Status` string is byte-identical, including the `->` arrow and trailing slash.
 *
 * @param lines Potential-file lines (mutated in place and returned).
 * @param featureName Feature name for the rewritten title.
 * @param issueNumber Created issue number.
 * @param issueUrl Created issue URL.
 * @param lastUpdated Issue updated date, or null to omit the `Last Updated` line.
 * @param featurePath Sanitized feature-path token for the `Status` line.
 * @returns The mutated `lines` array.
 */
export function updateMetadataLines(
  lines: string[],
  featureName: string,
  issueNumber: string,
  issueUrl: string,
  lastUpdated: string | null,
  featurePath: string,
): string[] {
  // Rewrite the title line when the document has at least one line.
  if (lines.length > 0) {
    lines[0] = `# ${featureName} (Issue #${issueNumber})`;
  }

  let metaEnd = findMetaEnd(lines);
  metaEnd = setLineValue(lines, "Issue", `#${issueNumber}`, metaEnd);
  metaEnd = setLineValue(lines, "Issue URL", issueUrl, metaEnd);
  // The `Last Updated` line is only set when a date was resolved.
  if (lastUpdated) {
    metaEnd = setLineValue(lines, "Last Updated", lastUpdated, metaEnd);
  }
  const statusValue = `Promoted -> docs/features/active/${featurePath}/ (Issue #${issueNumber})`;
  setLineValue(lines, "Status", statusValue, metaEnd);
  return lines;
}

/**
 * Replace all smart-punctuation characters with their ASCII equivalents.
 *
 * Mirrors Python `normalize_smart_punctuation` (`str.translate`): every
 * occurrence of each mapped character is replaced, not just the first.
 *
 * @param text Input text that may contain smart punctuation.
 * @returns The text with all mapped characters replaced.
 */
export function normalizeSmartPunctuation(text: string): string {
  let result = text;
  // Apply each mapping with replace-all semantics to match str.translate.
  for (const [from, to] of Object.entries(SMART_PUNCTUATION_MAP)) {
    result = result.split(from).join(to);
  }
  return result;
}
