/**
 * Helper routines for PR context rendering and summarization.
 *
 * Purpose:
 *     Port of the numstat/name-status/scoping/bucket/section/timestamp portion
 *     of `dev_tools/pr_context/summary_helpers.py`. The digest/appendix
 *     renderers live in `summary-digests.ts` to keep each file under 500 lines.
 *
 * Responsibilities:
 *     - `parseNumstatDetailed`, `parseNameStatusMap`.
 *     - `isScopingDoc`, `scopingDocChanges` (materiality rules).
 *     - `bucketText`, `parseSection`, `formatDiffPath` (delegate), and
 *       `appendGenerationTimestamp` (injected clock).
 *     - Re-export the digest/appendix renderers.
 */

import {
  type ScopingDocChange,
  section,
  splitLines,
  truncateLines,
} from "./models";
import { type GitClient } from "./git-client";
import { type FileSystem } from "../file-system";
import { formatDiffPath as renderFormatDiffPath } from "./render-pr-helpers";

// Re-export digest/appendix renderers so consumers import from one module.
export {
  extractDigestBullets,
  issueAppendix,
  issueDigest,
  lastWithTruncation,
  prAppendix,
  prDigest,
} from "./summary-digests";

/** Scoping-doc heading prefixes that mark a material key-section change. */
const KEY_SECTION_PREFIXES = [
  "## Context",
  "## Root Cause",
  "## Proposed Fix",
  "## Acceptance Criteria",
  "## Test Strategy",
  "## Risks",
] as const;

/** Excerpt headings rendered for a material scoping-doc change, in order. */
const SCOPING_EXCERPT_HEADINGS = [
  "Acceptance Criteria",
  "Root Cause",
  "Proposed Fix",
  "Test Strategy",
] as const;

/**
 * Parse numstat into totals and a per-file add/del map.
 *
 * Mirrors Python `parse_numstat_detailed`.
 *
 * @param numstatText Raw `git diff --numstat` output.
 * @returns A tuple of `[addsTotal, delsTotal, perFileMap]`.
 */
export function parseNumstatDetailed(
  numstatText: string,
): [number, number, Map<string, [number, number]>] {
  let addsTotal = 0;
  let delsTotal = 0;
  const perFile = new Map<string, [number, number]>();
  // Parse each non-blank row, accumulating totals and per-file counts.
  for (const rawLine of splitLines(numstatText)) {
    if (!rawLine.trim()) {
      continue;
    }
    const parts = rawLine.split("\t");
    if (parts.length < 3) {
      continue;
    }
    const [addPart, delPart, filePart] = [parts[0]!, parts[1]!, parts[2]!];
    const addCount = isDigits(addPart) ? Number.parseInt(addPart, 10) : 0;
    const delCount = isDigits(delPart) ? Number.parseInt(delPart, 10) : 0;
    addsTotal += addCount;
    delsTotal += delCount;
    perFile.set(formatDiffPath(filePart), [addCount, delCount]);
  }
  return [addsTotal, delsTotal, perFile];
}

/**
 * Parse name-status output into a path -> status map.
 *
 * Mirrors Python `parse_name_status_map`.
 *
 * @param nameStatusText Raw `git diff --name-status` output.
 * @returns A map of normalized path to status code.
 */
export function parseNameStatusMap(
  nameStatusText: string,
): Map<string, string> {
  const mapping = new Map<string, string>();
  // Parse each non-blank row into a status and its (normalized) final path.
  for (const rawLine of splitLines(nameStatusText)) {
    if (!rawLine.trim()) {
      continue;
    }
    const parts = rawLine.split("\t");
    if (parts.length < 2) {
      continue;
    }
    const status = parts[0]!.trim();
    const path = formatDiffPath(parts[parts.length - 1]!.trim());
    mapping.set(path, status);
  }
  return mapping;
}

/**
 * Return whether a path is a scoping document.
 *
 * Mirrors Python `is_scoping_doc`.
 *
 * @param path Repo-relative path.
 * @returns True when the path is a recognized scoping doc.
 */
export function isScopingDoc(path: string): boolean {
  const lowered = path.toLowerCase();
  return (
    lowered.startsWith("docs/features/") &&
    (lowered.endsWith("/spec.md") ||
      lowered.endsWith("/plan.md") ||
      lowered.endsWith("/bug-remediation-plan.md") ||
      lowered.endsWith("/user-story.md") ||
      lowered.endsWith("/readme.md"))
  );
}

/** Options for {@link scopingDocChanges}. */
export interface ScopingDocChangesOptions {
  git: GitClient;
  fs: FileSystem;
  mergeBase: string | null;
  headSha: string | null;
  root: string;
  nameStatusText: string;
  numstatDetails: Map<string, [number, number]>;
}

/**
 * Compute scoping-doc changes and their materiality.
 *
 * Mirrors Python `scoping_doc_changes`: a change is material when it is a new
 * doc, when `additions + deletions >= 15`, or when a key section heading is
 * touched; link/whitespace-only additions demote a change to non-material when
 * no heading is touched, fewer than 15 lines changed, and it is not an add. A
 * material change's excerpt is read from the doc through the injected FS.
 *
 * @param options Git/fs clients, range, root, and parsed diff inputs.
 * @returns The per-doc scoping change records.
 */
export function scopingDocChanges(
  options: ScopingDocChangesOptions,
): ScopingDocChange[] {
  const { git, fs, mergeBase, headSha, root, nameStatusText, numstatDetails } =
    options;
  if (!mergeBase || !headSha) {
    return [];
  }
  const changes: ScopingDocChange[] = [];
  const nameStatusMap = parseNameStatusMap(nameStatusText);
  // Evaluate each changed path that is a scoping doc for materiality.
  for (const [path, status] of nameStatusMap) {
    if (!isScopingDoc(path)) {
      continue;
    }
    const [additions, deletions] = numstatDetails.get(path) ?? [0, 0];
    const reasons: string[] = [];
    let material = false;
    if (status.startsWith("A")) {
      material = true;
      reasons.push("new scoping doc");
    }
    if (additions + deletions >= 15) {
      material = true;
      reasons.push(">=15 lines changed");
    }

    const diffText = git.diffRange([
      "--unified=0",
      mergeBase,
      headSha,
      "--",
      path,
    ]);
    let headingTouched = false;
    // Scan added lines for a touched key-section heading.
    for (const line of splitLines(diffText)) {
      if (!line.startsWith("+") || line.startsWith("+++")) {
        continue;
      }
      const stripped = line.replace(/^\++/u, "").trim();
      if (
        KEY_SECTION_PREFIXES.some((prefix) =>
          stripped.toLowerCase().startsWith(prefix.toLowerCase()),
        )
      ) {
        headingTouched = true;
        break;
      }
    }
    if (headingTouched) {
      material = true;
      reasons.push("key section touched");
    }

    const addedLines = splitLines(diffText)
      .filter((line) => line.startsWith("+") && !line.startsWith("+++"))
      .map((line) => line.replace(/^\++/u, "").trim());
    if (
      addedLines.length > 0 &&
      addedLines.every(
        (line) => !line || line.startsWith("[") || line.startsWith("http"),
      )
    ) {
      reasons.push("link/whitespace-only changes");
      if (
        !headingTouched &&
        additions + deletions < 15 &&
        !status.startsWith("A")
      ) {
        material = false;
      }
    }

    let excerpt: string | null = null;
    const docPath = `${stripTrailingSlash(root)}/${path}`;
    if (material && fs.exists(docPath)) {
      const content = fs.readTextFile(docPath);
      const excerptParts: string[] = [];
      for (const heading of SCOPING_EXCERPT_HEADINGS) {
        const sectionText = parseSection(content, heading);
        if (sectionText) {
          excerptParts.push(`${heading}:\n${truncateLines(sectionText, 40)}`);
        }
      }
      excerpt =
        excerptParts.length > 0 ? excerptParts.slice(0, 3).join("\n\n") : null;
    }

    changes.push({
      path,
      additions,
      deletions,
      changeType: status,
      material,
      reasons,
      excerpt,
    });
  }
  return changes;
}

/**
 * Render a churn-sorted bucket summary (top 10).
 *
 * Mirrors Python `bucket_text`.
 *
 * @param name Bucket label.
 * @param entries `[path, [adds, dels]]` entries.
 * @returns The formatted bucket text.
 */
export function bucketText(
  name: string,
  entries: [string, [number, number]][],
): string {
  if (entries.length === 0) {
    return `${name}: 0 files`;
  }
  const sortedEntries = [...entries].sort(
    (left, right) => right[1][0] + right[1][1] - (left[1][0] + left[1][1]),
  );
  const lines = [
    `${name}: ${entries.length} files`,
    ...sortedEntries
      .slice(0, 10)
      .map(([path, [adds, dels]]) => `- ${path} (+${adds}/-${dels})`),
  ];
  return lines.join("\n");
}

/**
 * Extract markdown content under a top-level `##` heading.
 *
 * Mirrors Python `parse_section` (summary_helpers copy).
 *
 * @param markdown Markdown content.
 * @param heading Heading to match.
 * @returns The trimmed section body, or `""`.
 */
export function parseSection(markdown: string, heading: string): string {
  const escaped = heading.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
  const pattern = new RegExp(
    `^##\\s+${escaped}\\s*\\r?\\n([\\s\\S]*?)(?=^##\\s+|$(?![\\s\\S]))`,
    "m",
  );
  const match = pattern.exec(markdown);
  if (!match) {
    return "";
  }
  return match[1]!.trim();
}

/**
 * Normalize a git diff path (delegates to render-pr-helpers).
 *
 * Mirrors Python `summary_helpers.format_diff_path`, which delegates to
 * `render.format_diff_path` to avoid the source's circular-import shim.
 *
 * @param pathText Raw diff path text.
 * @returns The normalized path.
 */
export function formatDiffPath(pathText: string | null): string {
  return pathText !== null ? renderFormatDiffPath(pathText) : "";
}

/** Section title of the generated-context freshness header, both runtimes. */
export const GENERATED_CONTEXT_SECTION_TITLE = "Context generated";
/** Prefix of the head-SHA line in the freshness header, both runtimes. */
export const HEAD_SHA_LABEL = "Head SHA:";
/** Rendered in place of the SHA when the collected context carries none. */
export const UNKNOWN_HEAD_SHA_PLACEHOLDER = "(unknown)";

/**
 * Generate the freshness header showing when context was collected and which
 * head it describes.
 *
 * Mirrors Python `append_generation_timestamp`: format the current UTC time as
 * `%Y-%m-%d %H:%M:%S %Z` (with `%Z` rendered as `UTC`), then emit the head-SHA
 * line beneath it. The clock is injected (`() => Date`, defaulting to the real
 * clock) so wall-clock reads do not occur directly, per the TypeScript
 * determinism rule. The Python helper takes no clock parameter; that divergence
 * is pre-existing and deliberate and is not corrected in either direction.
 *
 * The head-SHA parameter is optional so existing call sites compile unchanged.
 * When no head SHA is available the line renders
 * {@link UNKNOWN_HEAD_SHA_PLACEHOLDER}, matching the unknown-value convention used
 * elsewhere in the summary.
 *
 * @param clock Clock returning the current `Date` (defaults to `() => new Date()`).
 * @param headSha Head SHA of the branch the context describes, when known.
 * @returns The formatted freshness header section.
 */
export function appendGenerationTimestamp(
  clock: () => Date = () => new Date(),
  headSha: string | null = null,
): string {
  const now = clock();
  const timestamp = formatUtcTimestamp(now);
  const shaText = headSha !== null && headSha !== "" ? headSha : UNKNOWN_HEAD_SHA_PLACEHOLDER;
  return (
    section(GENERATED_CONTEXT_SECTION_TITLE) +
    "\n" +
    timestamp +
    "\n" +
    `${HEAD_SHA_LABEL} ${shaText}` +
    "\n"
  );
}

/** Format a Date as `YYYY-MM-DD HH:MM:SS UTC` (Python `%Y-%m-%d %H:%M:%S %Z`). */
function formatUtcTimestamp(date: Date): string {
  const year = date.getUTCFullYear().toString().padStart(4, "0");
  const month = (date.getUTCMonth() + 1).toString().padStart(2, "0");
  const day = date.getUTCDate().toString().padStart(2, "0");
  const hours = date.getUTCHours().toString().padStart(2, "0");
  const minutes = date.getUTCMinutes().toString().padStart(2, "0");
  const seconds = date.getUTCSeconds().toString().padStart(2, "0");
  return `${year}-${month}-${day} ${hours}:${minutes}:${seconds} UTC`;
}

/** Strip a single trailing slash for path joining. */
function stripTrailingSlash(value: string): string {
  return value.replace(/\/+$/u, "");
}

/** Test whether a string is a non-empty run of ASCII digits (Python isdigit). */
function isDigits(value: string): boolean {
  return value.length > 0 && /^\d+$/u.test(value);
}
