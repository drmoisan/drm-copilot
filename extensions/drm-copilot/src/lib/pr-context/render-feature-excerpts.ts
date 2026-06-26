/**
 * Feature-document excerpt helpers for PR context rendering (render variant).
 *
 * Purpose:
 *     Port of `dev_tools/pr_context/render_feature_excerpts.py`. This is the
 *     render-module variant: it produces the smaller `contextFiles` set
 *     (spec/plan/user-story only) and carries no readiness or primary-issue
 *     fields, distinct from the collector `feature-docs.ts` variant.
 *
 * Responsibilities:
 *     - `parseSection`, `completedPlanTasks`, `extractIssueReferences`.
 *     - `directoryExists`, `resolveFeatureDir`, `readTextFile`.
 *     - `extractFeaturesFromPaths`, `extractSpecParts`, `extractPlanSections`,
 *       `extractStoryParts`, `buildExcerptText`, and `gatherFeatureExcerpts`.
 *     All filesystem access flows through the injected {@link FileSystem}.
 */

import { type FileSystem, toPosixPath } from "../file-system";
import {
  type FeatureDocExcerpt,
  section,
  splitLines,
  truncate,
} from "./models";

/** Spec headings extracted into the excerpt, in fixed order. */
const SPEC_HEADINGS = [
  "Context",
  "Root Cause",
  "Root Cause/Problem",
  "Problem",
  "Proposed Fix",
  "Acceptance Criteria",
  "Constraints & Risks",
  "Behavior",
  "Overview",
] as const;

/**
 * Extract markdown content under a top-level `##` heading.
 *
 * Mirrors Python `parse_section`.
 *
 * @param markdown Markdown content.
 * @param heading Heading to match.
 * @returns The trimmed section body, or `""`.
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
 * Extract normalized issue reference tokens from freeform text.
 *
 * Mirrors Python `_extract_issue_references`.
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
 * Return up to `limit` completed checklist items from markdown.
 *
 * Mirrors Python `completed_plan_tasks`.
 *
 * @param markdown Markdown content.
 * @param limit Maximum tasks returned (default 10).
 * @returns The completed-task texts.
 */
export function completedPlanTasks(markdown: string, limit = 10): string[] {
  const tasks: string[] = [];
  for (const line of splitLines(markdown)) {
    if (/\[x\]/iu.test(line)) {
      tasks.push(line.replace(/^[-*]\s*\[[xX]\]\s*/u, "").trim());
    }
    if (tasks.length >= limit) {
      break;
    }
  }
  return tasks;
}

/**
 * Return whether the provided path exists.
 *
 * Mirrors Python `directory_exists`.
 *
 * @param fs Injected filesystem.
 * @param path Path to test.
 * @returns True when the path exists.
 */
export function directoryExists(fs: FileSystem, path: string): boolean {
  return fs.exists(path);
}

/**
 * Resolve a feature directory by exact, strong-pattern, then weak match.
 *
 * Mirrors Python `resolve_feature_dir`: exact child; otherwise — when the base
 * directory exists — iterate sorted children classifying strong/weak matches.
 *
 * @param fs Injected filesystem.
 * @param baseDir Base directory.
 * @param feature Feature identifier.
 * @returns The resolved directory path, or `null`.
 */
export function resolveFeatureDir(
  fs: FileSystem,
  baseDir: string,
  feature: string,
): string | null {
  const direct = `${baseDir}/${feature}`;
  if (directoryExists(fs, direct)) {
    return direct;
  }

  if (!directoryExists(fs, baseDir)) {
    return null;
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
 * Mirrors Python `read_text_file`.
 *
 * @param fs Injected filesystem.
 * @param path File path.
 * @returns The file content, or `""`.
 */
export function readTextFile(fs: FileSystem, path: string): string {
  return fs.exists(path) ? fs.readTextFile(path) : "";
}

/**
 * Extract feature directory names from `docs/features/active/**` paths.
 *
 * Mirrors Python `extract_features_from_paths`.
 *
 * @param changedFiles Repo-relative changed file paths.
 * @returns The set of active-feature directory names.
 */
export function extractFeaturesFromPaths(
  changedFiles: Iterable<string>,
): Set<string> {
  const features = new Set<string>();
  for (const raw of changedFiles) {
    const parts = toPosixPath(raw).split("/");
    if (
      parts.length >= 4 &&
      parts[0] === "docs" &&
      parts[1] === "features" &&
      parts[2] === "active"
    ) {
      features.add(parts[3]!);
    }
  }
  return features;
}

/**
 * Extract high-value sections from a feature spec document.
 *
 * Mirrors Python `extract_spec_parts`.
 *
 * @param specText Spec markdown.
 * @returns The spec excerpt parts.
 */
export function extractSpecParts(specText: string): string[] {
  const specParts: string[] = [];
  for (const heading of SPEC_HEADINGS) {
    const sectionText = parseSection(specText, heading);
    if (sectionText) {
      specParts.push(`${heading}: ${truncate(sectionText)}`);
    }
  }
  return specParts;
}

/**
 * Extract completed tasks and verification notes from a plan document.
 *
 * Mirrors Python `extract_plan_sections`: `Verification` then `Test Plan`
 * fallback for the verification block.
 *
 * @param planText Plan markdown.
 * @returns A tuple of `[planSection, verificationBlock]`.
 */
export function extractPlanSections(planText: string): [string, string] {
  const planTasks = completedPlanTasks(planText);
  const planSection =
    planTasks.length > 0 ? planTasks.map((task) => `- ${task}`).join("\n") : "";
  let testPlanSection = parseSection(planText, "Verification");
  if (!testPlanSection) {
    testPlanSection = parseSection(planText, "Test Plan");
  }
  const verificationBlock = testPlanSection
    ? "Plan verification notes:\n" + truncate(testPlanSection)
    : "";
  return [planSection, verificationBlock];
}

/**
 * Extract story statement/problem snippets from user-story content.
 *
 * Mirrors Python `extract_story_parts`.
 *
 * @param userStoryText Active user-story markdown.
 * @param promotedStoryText Promoted-folder user-story markdown fallback.
 * @returns The story excerpt parts.
 */
export function extractStoryParts(
  userStoryText: string,
  promotedStoryText: string,
): string[] {
  const storyParts: string[] = [];
  const storyStatements = parseSection(userStoryText, "Story Statement");
  if (storyStatements) {
    const storyLines = splitLines(storyStatements)
      .filter((line) => line.trim())
      .map((line) => line.replace(/^[- ]+|[- ]+$/gu, ""));
    if (storyLines.length > 0) {
      storyParts.push(
        "Story Statement:\n" + storyLines.map((line) => `- ${line}`).join("\n"),
      );
    }
  }
  const problemSection = parseSection(userStoryText, "Problem / Why");
  if (problemSection) {
    storyParts.push("Problem / Why:\n" + truncate(problemSection));
  }
  if (storyParts.length === 0 && promotedStoryText) {
    let promotedProblem = parseSection(promotedStoryText, "Problem / Why");
    if (!promotedProblem) {
      promotedProblem = parseSection(promotedStoryText, "Summary");
    }
    if (promotedProblem) {
      storyParts.push("Problem / Why:\n" + truncate(promotedProblem));
    }
  }
  return storyParts;
}

/**
 * Build a formatted feature excerpt block from collected sections.
 *
 * Mirrors Python `build_excerpt_text`.
 *
 * @param feature Feature identifier.
 * @param storyParts Story excerpt parts.
 * @param specParts Spec excerpt parts.
 * @param planSection Completed-tasks block.
 * @param verificationBlock Verification block.
 * @returns The excerpt text.
 */
export function buildExcerptText(
  feature: string,
  storyParts: string[],
  specParts: string[],
  planSection: string,
  verificationBlock: string,
): string {
  const lines: string[] = [section(`Feature doc: ${feature}`)];
  if (storyParts.length > 0) {
    lines.push("User story excerpts:\n" + storyParts.join("\n\n"));
  }
  if (specParts.length > 0) {
    lines.push("Spec excerpts:\n" + specParts.join("\n\n"));
  }
  if (planSection) {
    lines.push("Plan completed tasks:\n" + planSection);
  }
  if (verificationBlock) {
    lines.push(verificationBlock);
  }
  if (lines.length === 1) {
    lines.push("(no spec/plan/user-story excerpts found)");
  }
  return lines.join("\n");
}

/**
 * Gather feature excerpt payloads for changed active-feature files (render
 * variant).
 *
 * Mirrors Python `gather_feature_excerpts` in `render_feature_excerpts.py`:
 * smaller `contextFiles` (spec/plan/user-story only), no readiness or
 * primary-issue fields.
 *
 * @param fs Injected filesystem.
 * @param root Repository root.
 * @param changedFiles Repo-relative changed file paths.
 * @returns One excerpt per resolved feature, sorted by feature name.
 */
export function gatherFeatureExcerpts(
  fs: FileSystem,
  root: string,
  changedFiles: Iterable<string>,
): FeatureDocExcerpt[] {
  const normalizedRoot = toPosixPath(root).replace(/\/+$/u, "");
  const features = extractFeaturesFromPaths(changedFiles);
  const excerpts: FeatureDocExcerpt[] = [];
  const baseDir = `${normalizedRoot}/docs/features/active`;
  const promotedDir = `${normalizedRoot}/docs/features/potential/promoted`;

  for (const feature of [...features].sort(compareCodePoint)) {
    const featureDir = resolveFeatureDir(fs, baseDir, feature);
    const promotedFeatureDir = resolveFeatureDir(fs, promotedDir, feature);
    if (featureDir === null && promotedFeatureDir === null) {
      continue;
    }
    const activeDir = featureDir ?? promotedFeatureDir;
    if (activeDir === null) {
      continue;
    }

    const specPath = `${activeDir}/spec.md`;
    const planPath = `${activeDir}/plan.md`;
    let userStoryPath = `${activeDir}/user-story.md`;
    const promotedStoryPath =
      promotedFeatureDir !== null
        ? `${promotedFeatureDir}/user-story.md`
        : null;
    const promotedStoryText =
      promotedStoryPath !== null ? readTextFile(fs, promotedStoryPath) : "";
    if (promotedStoryPath !== null && !fs.exists(userStoryPath)) {
      userStoryPath = promotedStoryPath;
    }

    let userStoryText = readTextFile(fs, userStoryPath);
    if (!userStoryText && promotedStoryText && promotedStoryPath !== null) {
      userStoryText = promotedStoryText;
      userStoryPath = promotedStoryPath;
    }

    const specText = readTextFile(fs, specPath);
    const planText = readTextFile(fs, planPath);

    const specParts = extractSpecParts(specText);
    const [planSection, verificationBlock] = extractPlanSections(planText);
    const storyParts = extractStoryParts(userStoryText, promotedStoryText);
    const excerptText = buildExcerptText(
      feature,
      storyParts,
      specParts,
      planSection,
      verificationBlock,
    );

    // Smaller context-files set: existing spec/plan/user-story only, in order.
    const contextFiles: string[] = [];
    for (const path of [specPath, planPath, userStoryPath]) {
      if (fs.exists(path)) {
        contextFiles.push(relativeToPosix(normalizedRoot, path));
      }
    }
    const issueRefs = extractIssueReferences(
      [specText, planText, userStoryText].join("\n"),
    );
    excerpts.push({
      feature,
      excerpt: excerptText,
      issueRefs,
      contextFiles,
      primaryIssueRef: null,
      readinessSignal: null,
    });
  }

  return excerpts;
}

/** Compute a repo-relative POSIX path for a path under `root`. */
function relativeToPosix(root: string, path: string): string {
  const normalized = toPosixPath(path);
  if (normalized.startsWith(`${root}/`)) {
    return normalized.slice(root.length + 1);
  }
  return normalized.replace(/^\/+/u, "");
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

/** Escape regex metacharacters for a dynamic heading pattern. */
function escapeRegExp(value: string): string {
  return value.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
}
