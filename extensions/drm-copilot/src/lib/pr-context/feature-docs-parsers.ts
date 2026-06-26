/**
 * Pure parsing helpers for the collector feature-docs variant.
 *
 * Purpose:
 *     Port of the pure helpers in `dev_tools/pr_context/feature_docs.py`
 *     (section/task/issue parsing, feature-dir resolution, readiness signal).
 *     Extracted from `feature-docs.ts` so each file stays under 500 lines.
 *
 * Responsibilities:
 *     - `parseSection`, `completedPlanTasks`, `extractIssueReferences`.
 *     - `resolveFeatureDir`, `readText`, `latestGlobPath`, `verificationText`.
 *     - `parsePrimaryIssueFromMetadata`, `parseReadinessValue`,
 *       `resolveReadinessSignal`.
 *     All filesystem access flows through the injected {@link FileSystem}.
 */

import { type FileSystem, toPosixPath } from "../file-system";
import { splitLines } from "./models";

/**
 * Extract markdown content under a top-level `##` heading.
 *
 * Mirrors Python `parse_section`: matches `^## <heading>` (optional CR) and
 * captures up to the next `^## ` heading or end of document, trimmed.
 *
 * @param markdown Markdown content.
 * @param heading Heading text to match (escaped).
 * @returns The trimmed section body, or `""` when not found.
 */
export function parseSection(markdown: string, heading: string): string {
  const escaped = escapeRegExp(heading);
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
 * Return up to `limit` completed checklist items from markdown.
 *
 * Mirrors Python `completed_plan_tasks`: a line containing `[x]`
 * (case-insensitive) contributes, with the leading `- [x] ` / `* [X] ` marker
 * stripped and the remainder trimmed.
 *
 * @param markdown Markdown content.
 * @param limit Maximum number of tasks returned (default 10).
 * @returns The collected completed-task texts.
 */
export function completedPlanTasks(markdown: string, limit = 10): string[] {
  const tasks: string[] = [];
  // Walk every line, collecting checked checklist items until the limit.
  for (const line of splitLines(markdown)) {
    if (/\[x\]/iu.test(line)) {
      const cleaned = line.replace(/^[-*]\s*\[[xX]\]\s*/u, "").trim();
      tasks.push(cleaned);
    }
    if (tasks.length >= limit) {
      break;
    }
  }
  return tasks;
}

/**
 * Extract issue tokens like `#123` and `ABC-123` in encounter order.
 *
 * Mirrors Python `extract_issue_references`: ordered dedup over the combined
 * `#\d+` / `[A-Z][A-Z0-9]+-\d+` matches.
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
  // Preserve first-encounter order while removing duplicates.
  for (const item of matches) {
    if (!seen.has(item)) {
      seen.add(item);
      ordered.push(item);
    }
  }
  return ordered;
}

/**
 * Resolve a feature directory by exact, strong-pattern, then weak match.
 *
 * Mirrors Python `_resolve_feature_dir`: exact child first; otherwise iterate
 * the sorted directory children, collecting strong matches
 * (`(?:^|[-_])<feature>(?:[-_]|$)`) and weak substring matches, preferring the
 * first strong match, then the first weak match.
 *
 * @param fs Injected filesystem.
 * @param baseDir Base directory to resolve under.
 * @param feature Feature identifier.
 * @returns The resolved directory path, or `null` when none matches.
 */
export function resolveFeatureDir(
  fs: FileSystem,
  baseDir: string,
  feature: string,
): string | null {
  const direct = `${baseDir}/${feature}`;
  if (fs.exists(direct)) {
    return direct;
  }

  const pattern = new RegExp(
    `(?:^|[-_])${escapeRegExp(feature)}(?:[-_]|$)`,
    "u",
  );
  const strongMatches: string[] = [];
  const weakMatches: string[] = [];

  // Iterate sorted children, classifying directories by match strength.
  for (const name of fs.listDirectory(baseDir)) {
    const candidate = `${baseDir}/${name}`;
    if (!fs.isDirectory(candidate)) {
      continue;
    }
    if (pattern.test(name)) {
      strongMatches.push(candidate);
    } else if (name.includes(feature)) {
      weakMatches.push(candidate);
    }
  }

  if (strongMatches.length > 0) {
    return strongMatches[0]!;
  }
  if (weakMatches.length > 0) {
    return weakMatches[0]!;
  }
  return null;
}

/**
 * Read UTF-8 text if the path exists, otherwise return an empty string.
 *
 * Mirrors Python `_read_text`.
 *
 * @param fs Injected filesystem.
 * @param path File path.
 * @returns The file content, or `""` when absent.
 */
export function readText(fs: FileSystem, path: string): string {
  return fs.exists(path) ? fs.readTextFile(path) : "";
}

/**
 * Return the lexicographically latest matching file path.
 *
 * Mirrors Python `_latest_glob_path`: sort the glob matches and return the last
 * one (timestamped filenames sort by their suffix).
 *
 * @param fs Injected filesystem.
 * @param directory Directory to glob.
 * @param pattern Glob pattern.
 * @returns The latest matching path, or `null` when none match.
 */
export function latestGlobPath(
  fs: FileSystem,
  directory: string,
  pattern: string,
): string | null {
  const matches = [...fs.glob(directory, pattern)].sort(compareCodePoint);
  return matches.length > 0 ? matches[matches.length - 1]! : null;
}

/**
 * Resolve verification notes: `Verification` then `Test Plan`.
 *
 * Mirrors Python `_verification_text`.
 *
 * @param planText Plan markdown.
 * @returns The first non-empty section body, or `""`.
 */
export function verificationText(planText: string): string {
  for (const heading of ["Verification", "Test Plan"]) {
    const sectionText = parseSection(planText, heading);
    if (sectionText) {
      return sectionText;
    }
  }
  return "";
}

/**
 * Parse a deterministic primary issue from metadata lines only.
 *
 * Mirrors Python `_parse_primary_issue_from_metadata`: matches
 * `^\s*[-*]?\s*Issue:\s*(#\d+)\s*$` (case-insensitive), preferring spec, then
 * story, then issue text.
 *
 * @param params Spec/story/issue markdown texts.
 * @returns The first matching `#NN` reference, or `null`.
 */
export function parsePrimaryIssueFromMetadata(params: {
  specText: string;
  storyText: string;
  issueText: string;
}): string | null {
  const pattern = /^\s*[-*]?\s*Issue:\s*(#\d+)\s*$/iu;
  // Prefer spec metadata, then story, then issue.md, scanning each line.
  for (const sourceText of [
    params.specText,
    params.storyText,
    params.issueText,
  ]) {
    for (const line of splitLines(sourceText)) {
      const match = pattern.exec(line);
      if (match) {
        return match[1]!;
      }
    }
  }
  return null;
}

/**
 * Normalize a readiness value from feature-audit markdown.
 *
 * Mirrors Python `_parse_readiness_value`: strip `**`, match
 * `Readiness`/`Overall feature readiness`, uppercase, and accept only `PASS`,
 * `NEEDS REVISION`, or `BLOCKED`.
 *
 * @param text Feature-audit markdown.
 * @returns The normalized readiness, or `null`.
 */
export function parseReadinessValue(text: string): string | null {
  const normalized = text.replaceAll("**", "");
  const match =
    /^\s*(?:Readiness|Overall feature readiness):\s*(.+?)\s*$/im.exec(
      normalized,
    );
  if (!match) {
    return null;
  }
  const value = match[1]!.trim().toUpperCase();
  if (value === "PASS" || value === "NEEDS REVISION" || value === "BLOCKED") {
    return value;
  }
  return null;
}

/**
 * Resolve the readiness signal from the newest readable `feature-audit.*.md`.
 *
 * Mirrors Python `_resolve_readiness_signal`: glob `feature-audit.*.md`, sort,
 * and evaluate newest-first, returning the first parseable readiness with its
 * source path.
 *
 * @param fs Injected filesystem.
 * @param featureDir Active feature directory.
 * @returns A tuple of `[readiness, sourcePath]`, each `null` when absent.
 */
export function resolveReadinessSignal(
  fs: FileSystem,
  featureDir: string,
): [string | null, string | null] {
  const auditFiles = [...fs.glob(featureDir, "feature-audit.*.md")].sort(
    compareCodePoint,
  );
  // Evaluate newest-first; return the first audit with a parseable readiness.
  for (let index = auditFiles.length - 1; index >= 0; index -= 1) {
    const auditPath = auditFiles[index]!;
    const readiness = parseReadinessValue(readText(fs, auditPath));
    if (readiness) {
      return [readiness, auditPath];
    }
  }
  return [null, null];
}

/**
 * Compute a repo-relative POSIX path for a path under `root`.
 *
 * Mirrors Python `Path.relative_to(root).as_posix()`.
 *
 * @param root Repository root.
 * @param path Absolute path under `root`.
 * @returns The repo-relative POSIX path.
 */
export function relativeToPosix(root: string, path: string): string {
  const normalizedRoot = toPosixPath(root).replace(/\/+$/u, "");
  const normalized = toPosixPath(path);
  if (normalized.startsWith(`${normalizedRoot}/`)) {
    return normalized.slice(normalizedRoot.length + 1);
  }
  return normalized.replace(/^\/+/u, "");
}

/** Compare two strings by Unicode code point (Python `sorted` semantics). */
export function compareCodePoint(left: string, right: string): number {
  if (left < right) {
    return -1;
  }
  if (left > right) {
    return 1;
  }
  return 0;
}

/**
 * Escape regex metacharacters for use in a dynamic pattern.
 *
 * @param value Literal text.
 * @returns The escaped text.
 */
function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}
