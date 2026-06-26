/**
 * PR context rendering utility helpers.
 *
 * Purpose:
 *     Port of `dev_tools/pr_context/render_pr_helpers.py`. Provide the pure
 *     rendering and extraction helpers used to build the PR comparison and
 *     summary sections: base selection, diff-path normalization, numstat
 *     conversion, extension summary, issue/PR reference extraction, conventional
 *     commit summary, issue/PR detail rendering, close-candidate and autoclose
 *     sections, and changed-path extraction.
 *
 * Responsibilities:
 *     - Replicate every regex, format string, and ordering exactly so the
 *       rendered output matches the Python source.
 *     - `selectDefaultBase` accepts an injected {@link GitClient}.
 */

import {
  CONVENTIONAL_TYPES,
  type IssueDetails,
  type PullRequestDetails,
  formatList,
  section,
  truncate,
} from "./models";
import { type GitClient } from "./git-client";

/** Default base ref candidates, probed in fixed order. */
const DEFAULT_BASE_CANDIDATES = [
  "origin/main",
  "origin/master",
  "main",
  "master",
  "origin/develop",
  "develop",
] as const;

/**
 * Select the first existing base ref from standard default candidates.
 *
 * Mirrors Python `select_default_base`: probe each candidate with
 * `rev-parse --verify --quiet`, returning the first whose exit is `0` and whose
 * stdout is non-empty.
 *
 * @param git Injected git client.
 * @returns The first existing candidate ref, or `null` when none verify.
 */
export function selectDefaultBase(git: GitClient): string | null {
  // Probe each candidate ref in priority order; the first that verifies wins.
  for (const ref of DEFAULT_BASE_CANDIDATES) {
    const result = git.run(["rev-parse", "--verify", "--quiet", ref], {
      allowError: true,
    });
    if (result.code === 0 && result.stdout.trim()) {
      return ref;
    }
  }
  return null;
}

/**
 * Normalize a git diff path, including rename syntax variants.
 *
 * Mirrors Python `format_diff_path`: `null` -> `""`; an all-whitespace string is
 * returned unchanged; otherwise strip quotes, collapse `{old => new}` brace
 * renames to the new segment, and resolve `old => new` arrow renames to the new
 * path.
 *
 * @param pathText Raw diff path text.
 * @returns The normalized path.
 */
export function formatDiffPath(pathText: string | null): string {
  if (pathText === null) {
    return "";
  }
  if (pathText.trim() === "") {
    return pathText;
  }

  let trimmed = pathText.trim().replace(/^"+|"+$/gu, "");
  trimmed = trimmed.replace(/\{[^{}]*\s=>\s([^{}]*)\}/gu, "$1");

  const arrowMatch = /^\s*(.+?)\s=>\s(.+?)\s*$/u.exec(trimmed);
  if (arrowMatch) {
    return arrowMatch[2]!;
  }
  return trimmed;
}

/**
 * Convert git numstat output into totals and a raw path list.
 *
 * Mirrors Python `convert_numstat`: sum integer add/del columns, collect the
 * third tab-separated field as the path, skipping blank/short lines.
 *
 * @param numstatText Raw `git diff --numstat` output.
 * @returns A tuple of `[additions, deletions, files]`.
 */
export function convertNumstat(
  numstatText: string,
): [number, number, string[]] {
  let adds = 0;
  let dels = 0;
  const files: string[] = [];

  // Parse each non-blank numstat row into add/del totals and the file path.
  for (const rawLine of splitLines(numstatText)) {
    if (!rawLine.trim()) {
      continue;
    }
    const parts = rawLine.split("\t");
    if (parts.length < 3) {
      continue;
    }
    const [addPart, delPart, filePart] = [parts[0]!, parts[1]!, parts[2]!];
    if (isDigits(addPart)) {
      adds += Number.parseInt(addPart, 10);
    }
    if (isDigits(delPart)) {
      dels += Number.parseInt(delPart, 10);
    }
    files.push(filePart);
  }

  return [adds, dels, files];
}

/**
 * Summarize changed files by extension.
 *
 * Mirrors Python `extension_summary`: normalize each path, take its suffix
 * (`(noext)` when none), count per extension, and render `%8d  ext` lines sorted
 * by extension.
 *
 * @param files Iterable of raw file paths.
 * @returns The formatted per-extension summary.
 */
export function extensionSummary(files: Iterable<string>): string {
  const counts = new Map<string, number>();
  // Count files per extension, normalizing the diff path first.
  for (const raw of files) {
    const name = formatDiffPath(raw);
    const suffix = pathSuffix(name);
    const ext = suffix ? suffix : "(noext)";
    counts.set(ext, (counts.get(ext) ?? 0) + 1);
  }

  const lines = [...counts.keys()]
    .sort(compareCodePoint)
    .map((key) => `${padCount(counts.get(key)!)}  ${key}`);
  return lines.join("\n");
}

/**
 * Extract issue tokens like `#123` and `ABC-123` in encounter order.
 *
 * Mirrors Python `extract_issue_references`.
 *
 * @param text Source text.
 * @returns Ordered, deduplicated reference tokens.
 */
export function extractIssueReferences(text: string): string[] {
  if (!text) {
    return [];
  }
  const matches = text.match(/(?<!\w)#\d+|\b[A-Z][A-Z0-9]+-\d+\b/gu) ?? [];
  const seen = new Set<string>();
  const ordered: string[] = [];
  for (const item of matches) {
    if (!seen.has(item)) {
      seen.add(item);
      ordered.push(item);
    }
  }
  return ordered;
}

/**
 * Extract merged PR numbers from commit subject lines.
 *
 * Mirrors Python `extract_merge_pr_numbers`: match `Merge pull request #N`
 * (case-insensitive) and return sorted `#N` strings.
 *
 * @param subjects Iterable of commit subject lines.
 * @returns Sorted `#N` PR numbers.
 */
export function extractMergePrNumbers(subjects: Iterable<string>): string[] {
  const numbers = new Set<string>();
  const pattern = /Merge pull request #(\d+)/iu;
  // Scan each subject for a merge-commit PR reference.
  for (const subj of subjects) {
    const match = pattern.exec(subj);
    if (match) {
      numbers.add(`#${match[1]!}`);
    }
  }
  return [...numbers].sort(compareCodePoint);
}

/**
 * Count conventional commit types in subject lines.
 *
 * Mirrors Python `summarize_conventional_commits`: count each recognized type
 * prefix (`type(`, `type!`, `type:`) else `other`; render `name<9 : value`
 * lines for non-zero counts, or the no-types fallback.
 *
 * @param subjects Newline-separated commit subjects.
 * @returns The conventional-commit summary text.
 */
export function summarizeConventionalCommits(subjects: string): string {
  const counts = new Map<string, number>();
  // Initialize every recognized type plus the "other" bucket to zero.
  for (const key of CONVENTIONAL_TYPES) {
    counts.set(key, 0);
  }
  counts.set("other", 0);

  const typePattern =
    /^(feat|fix|refactor|perf|docs|test|chore|build|ci|style)(\(|!|:)/u;
  // Classify each non-blank subject line by its conventional-commit prefix.
  for (const rawLine of splitLines(subjects)) {
    const line = rawLine.trim();
    if (!line) {
      continue;
    }
    const match = typePattern.exec(line);
    const label = match ? match[1]! : "other";
    counts.set(label, (counts.get(label) ?? 0) + 1);
  }

  // Preserve insertion order (recognized types, then "other"), keeping non-zero.
  const nonZero = [...counts.entries()].filter(([, value]) => value > 0);
  if (nonZero.length === 0) {
    return "(no recognizable conventional commit types)";
  }
  return nonZero
    .map(([name, value]) => `${padName(name)} : ${value}`)
    .join("\n");
}

/**
 * Render structured issue details for the appendix.
 *
 * Mirrors Python `format_issue_details`.
 *
 * @param issue Issue details record.
 * @returns The formatted issue block.
 */
export function formatIssueDetails(issue: IssueDetails): string {
  const commentsText = formatList(issue.comments, "(no comments)");
  const lines = [
    section(`Issue ${issue.number}: ${issue.title}`),
    `State: ${issue.state}`,
    `Author: ${issue.author}`,
    `Labels: ${issue.labels.length > 0 ? issue.labels.join(", ") : "(none)"}`,
    `Assignees: ${issue.assignees.length > 0 ? issue.assignees.join(", ") : "(none)"}`,
    `Created: ${issue.createdAt}`,
    `Updated: ${issue.updatedAt}`,
    "",
    truncate(issue.body, 1200),
    "",
    "Comments:",
    commentsText,
  ];
  if (issue.userStoryContent) {
    lines.push(
      "",
      `User story (${issue.userStoryPath ?? "user-story.md"}):`,
      truncate(issue.userStoryContent, 1200),
    );
  }
  return lines.join("\n");
}

/**
 * Render structured pull request details for the appendix.
 *
 * Mirrors Python `format_pr_details`.
 *
 * @param pr Pull request details record.
 * @returns The formatted PR block.
 */
export function formatPrDetails(pr: PullRequestDetails): string {
  return [
    section(`Pull Request ${pr.number}: ${pr.title}`),
    `State: ${pr.state}`,
    `Author: ${pr.author}`,
    `Base: ${pr.baseRef}`,
    `Head: ${pr.headRef}`,
    `Created: ${pr.createdAt}`,
    `Updated: ${pr.updatedAt}`,
    `Merged: ${pr.mergedAt ?? "(not merged)"}`,
    `Labels: ${pr.labels.length > 0 ? pr.labels.join(", ") : "(none)"}`,
    `Assignees: ${pr.assignees.length > 0 ? pr.assignees.join(", ") : "(none)"}`,
    truncate(pr.body, 1200),
    "",
    "Auto-close issues (from this PR):",
    formatList(pr.closingIssues, "(none)"),
    "",
    "Files (first 15):",
    formatList(pr.filesChanged.slice(0, 15), "(none)"),
  ].join("\n");
}

/**
 * Render the close-candidate section grouped by verification source.
 *
 * Mirrors Python `build_close_candidates_section`.
 *
 * @param params Verified/author-asserted/referenced refs and reason strings.
 * @returns The formatted close-candidates section.
 */
export function buildCloseCandidatesSection(params: {
  verified: string[];
  authorAsserted: string[];
  referenced: string[];
  verifiedReason: string;
  authorReason: string;
}): string {
  const { verified, authorAsserted, referenced, verifiedReason, authorReason } =
    params;
  const allAutoClose = new Set([...verified, ...authorAsserted, ...referenced]);
  const authorAutoClose = [...allAutoClose].sort(compareCodePoint);
  const referencedOnly = referenced
    .filter((ref) => !allAutoClose.has(ref))
    .filter((ref, index, arr) => arr.indexOf(ref) === index)
    .sort(compareCodePoint);

  return [
    section("Close candidates"),
    "Auto-close issues (verified from GitHub PR metadata):",
    formatList(verified, verifiedReason),
    "",
    "Auto-close issues (author asserted):",
    formatList(authorAutoClose, authorReason),
    "",
    "Referenced issues (detected):",
    formatList(referencedOnly, "(none)"),
  ].join("\n");
}

/**
 * Render the approved autoclose section from verified and pending refs.
 *
 * Mirrors Python `build_issues_to_autoclose_section`: verified first, then
 * pending deterministic refs not already verified; when none, the PASS vs
 * non-PASS conservative fallback text.
 *
 * @param params Verified/pending refs and observed readiness signals.
 * @returns The formatted autoclose section.
 */
export function buildIssuesToAutocloseSection(params: {
  verified: string[];
  pendingPrimary: string[];
  readinessSignals: string[];
}): string {
  const { verified, pendingPrimary, readinessSignals } = params;
  // Verified issues first, then pending deterministic issues not yet verified.
  const ordered: string[] = [];
  for (const issue of [...verified, ...pendingPrimary]) {
    if (issue && !ordered.includes(issue)) {
      ordered.push(issue);
    }
  }

  let body: string;
  if (ordered.length > 0) {
    body = formatList(ordered, "(none)");
  } else if (readinessSignals.some((signal) => signal === "PASS")) {
    body =
      "None (no verified closing issues and no deterministic pending issue)";
  } else {
    body = "None (no verified closing issues and readiness not PASS)";
  }

  return [section("Issues to autoclose (verified or pending)"), body].join(
    "\n",
  );
}

/**
 * Extract changed file paths from the 'Changed files' section text.
 *
 * Mirrors Python `extract_changed_paths`: capture lines after a
 * `===== Changed files` header until the next `=====` banner; tab-bearing lines
 * yield the last tab field, otherwise the whole trimmed line, each normalized.
 *
 * @param contextText Full PR context text.
 * @returns The normalized changed file paths.
 */
export function extractChangedPaths(contextText: string): string[] {
  const paths: string[] = [];
  let capture = false;
  // Walk lines, toggling capture at the section header and stopping at the
  // next banner; collect normalized paths from captured lines.
  for (const line of splitLines(contextText)) {
    if (line.startsWith("===== Changed files")) {
      capture = true;
      continue;
    }
    if (capture) {
      if (line.startsWith("=====")) {
        break;
      }
      if (line.trim() && line.includes("\t")) {
        const partsArr = line.split("\t");
        const pathPart = partsArr[partsArr.length - 1]!;
        paths.push(formatDiffPath(pathPart.trim()));
      } else if (line.trim()) {
        paths.push(formatDiffPath(line.trim()));
      }
    }
  }
  return paths;
}

/**
 * Return the final suffix of a path, mirroring Python `Path(name).suffix`.
 *
 * `Path.suffix` is the substring from the last `.` of the final path segment,
 * but only when the dot is not the first character of that segment (so
 * `.gitignore` has no suffix and `archive.tar.gz` yields `.gz`).
 *
 * @param name Path string.
 * @returns The suffix (including the leading dot), or `""`.
 */
function pathSuffix(name: string): string {
  const segment = name.split(/[/\\]/u).pop() ?? "";
  const dotIndex = segment.lastIndexOf(".");
  if (dotIndex <= 0 || dotIndex === segment.length - 1) {
    return "";
  }
  return segment.slice(dotIndex);
}

/** Right-align a count in a width-8 field, mirroring Python `%8d`. */
function padCount(count: number): string {
  return String(count).padStart(8, " ");
}

/** Left-align a name in a width-9 field, mirroring Python `%-9s` (`name:<9`). */
function padName(name: string): string {
  return name.padEnd(9, " ");
}

/** Test whether a string is a non-empty run of ASCII digits (Python isdigit). */
function isDigits(value: string): boolean {
  return value.length > 0 && /^\d+$/u.test(value);
}

/** Compare two strings by Unicode code point (Python `sorted` semantics). */
function compareCodePoint(left: string, right: string): number {
  if (left < right) {
    return -1;
  }
  if (left > right) {
    return 1;
  }
  return 0;
}

/**
 * Split text into lines the way Python `str.splitlines()` does.
 *
 * @param value Text to split.
 * @returns Lines without terminators.
 */
function splitLines(value: string): string[] {
  if (value === "") {
    return [];
  }
  const lines = value.split(/\r\n|\r|\n/u);
  if (
    lines.length > 0 &&
    lines[lines.length - 1] === "" &&
    /(\r\n|\r|\n)$/u.test(value)
  ) {
    lines.pop();
  }
  return lines;
}
