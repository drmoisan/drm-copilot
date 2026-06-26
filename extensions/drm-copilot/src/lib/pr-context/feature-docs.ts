/**
 * Feature-document excerpt assembly for PR context collection (collector
 * variant).
 *
 * Purpose:
 *     Port of `gather_feature_excerpts` from
 *     `dev_tools/pr_context/feature_docs.py` — the richer collector-used variant
 *     (distinct from `render_feature_excerpts.py`). It assembles spec/plan/
 *     user-story excerpts, the `context_files` set (including readiness source
 *     and canonical evidence files), the deterministic `primaryIssueRef`, and
 *     the `readinessSignal`.
 *
 * Responsibilities:
 *     - Resolve active and promoted feature directories and the
 *       user-story fallbacks.
 *     - Build the excerpt block and the ordered/deduplicated context-files set.
 *     All filesystem access flows through the injected {@link FileSystem}.
 */

import { type FileSystem, toPosixPath } from "../file-system";
import { type FeatureDocExcerpt, section, truncate } from "./models";
import {
  compareCodePoint,
  completedPlanTasks,
  extractIssueReferences,
  latestGlobPath,
  parsePrimaryIssueFromMetadata,
  parseSection,
  readText,
  relativeToPosix,
  resolveFeatureDir,
  resolveReadinessSignal,
  verificationText,
} from "./feature-docs-parsers";
import { discoverCanonicalEvidenceFiles } from "./verification-evidence";

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
 * Extract feature directory names from `docs/features/active/**` paths.
 *
 * Mirrors the Python set-comprehension over `Path(raw).parts`.
 *
 * @param changedFiles Repo-relative changed file paths.
 * @returns The set of active-feature directory names.
 */
function extractFeatures(changedFiles: Iterable<string>): Set<string> {
  const features = new Set<string>();
  // Collect the feature segment from any docs/features/active/<feature>/... path.
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
 * Gather feature excerpt payloads for changed active-feature files.
 *
 * Mirrors Python `gather_feature_excerpts` (collector variant), reproducing the
 * spec/plan/user-story excerpt assembly, the `context_files` set, the
 * `primaryIssueRef` source precedence, and the readiness signal.
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
  const features = extractFeatures(changedFiles);
  const excerpts: FeatureDocExcerpt[] = [];
  const baseDir = `${normalizedRoot}/docs/features/active`;
  const promotedDir = `${normalizedRoot}/docs/features/potential/promoted`;

  // Process features in sorted order for deterministic output.
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
    const issuePath = `${activeDir}/issue.md`;

    // Resolve plan path: prefer plan.md, else newest plan.<timestamp>.md.
    let planPath = `${activeDir}/plan.md`;
    if (!fs.exists(planPath)) {
      const latestPlan = latestGlobPath(fs, activeDir, "plan.*.md");
      if (latestPlan !== null) {
        planPath = latestPlan;
      }
    }

    let userStoryPath = `${activeDir}/user-story.md`;
    const promotedStoryPath =
      promotedFeatureDir !== null
        ? `${promotedFeatureDir}/user-story.md`
        : null;
    const promotedStoryText =
      promotedStoryPath !== null ? readText(fs, promotedStoryPath) : "";
    if (promotedStoryPath !== null && !fs.exists(userStoryPath)) {
      userStoryPath = promotedStoryPath;
    }

    let userStoryText = readText(fs, userStoryPath);
    if (!userStoryText && promotedStoryText && promotedStoryPath !== null) {
      userStoryText = promotedStoryText;
      userStoryPath = promotedStoryPath;
    }

    const specText = readText(fs, specPath);
    const issueText = readText(fs, issuePath);
    const planText = readText(fs, planPath);
    const primaryIssueRef = parsePrimaryIssueFromMetadata({
      specText,
      storyText: userStoryText,
      issueText,
    });
    const [readinessSignal, readinessSource] = resolveReadinessSignal(
      fs,
      activeDir,
    );

    const specParts = buildSpecParts(specText);
    const planSection = buildPlanSection(planText);
    const verificationBlock = buildVerificationBlock(planText);
    const storyParts = buildStoryParts(userStoryText, promotedStoryText);
    const excerpt = buildExcerpt(
      feature,
      storyParts,
      specParts,
      planSection,
      verificationBlock,
    );

    const contextFiles = buildContextFiles({
      fs,
      root: normalizedRoot,
      feature,
      candidatePaths: [specPath, issuePath, planPath, userStoryPath],
      readinessSource,
    });
    const issueRefs = extractIssueReferences(
      [specText, issueText, planText, userStoryText].join("\n"),
    );

    excerpts.push({
      feature,
      excerpt,
      issueRefs,
      contextFiles,
      primaryIssueRef,
      readinessSignal,
    });
  }

  return excerpts;
}

/** Build the spec excerpt parts in fixed heading order. */
function buildSpecParts(specText: string): string[] {
  const specParts: string[] = [];
  for (const heading of SPEC_HEADINGS) {
    const sectionText = parseSection(specText, heading);
    if (sectionText) {
      specParts.push(`${heading}: ${truncate(sectionText)}`);
    }
  }
  return specParts;
}

/** Build the completed-plan-tasks bullet block, or `""`. */
function buildPlanSection(planText: string): string {
  const planTasks = completedPlanTasks(planText);
  return planTasks.length > 0
    ? planTasks.map((task) => `- ${task}`).join("\n")
    : "";
}

/** Build the verification-notes block, or `""`. */
function buildVerificationBlock(planText: string): string {
  const text = verificationText(planText);
  return text ? "Plan verification notes:\n" + truncate(text) : "";
}

/** Build the user-story excerpt parts with the promoted-folder fallback. */
function buildStoryParts(
  userStoryText: string,
  promotedStoryText: string,
): string[] {
  const storyParts: string[] = [];
  const storyStatements = parseSection(userStoryText, "Story Statement");
  if (storyStatements) {
    const storyLines = storyStatements
      .split(/\r\n|\r|\n/u)
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

/** Assemble the excerpt block from the collected sections. */
function buildExcerpt(
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
 * Build the deduplicated, sorted context-files set including evidence files.
 *
 * Mirrors the Python `sorted(set(context_files + evidence_context_files))`,
 * where `context_files` holds existing spec/issue/plan/user-story paths plus the
 * readiness source.
 */
function buildContextFiles(params: {
  fs: FileSystem;
  root: string;
  feature: string;
  candidatePaths: string[];
  readinessSource: string | null;
}): string[] {
  const { fs, root, feature, candidatePaths, readinessSource } = params;
  const contextFiles: string[] = [];
  // Keep only existing candidate paths, as repo-relative POSIX paths.
  for (const path of candidatePaths) {
    if (fs.exists(path)) {
      contextFiles.push(relativeToPosix(root, path));
    }
  }
  if (readinessSource !== null) {
    contextFiles.push(relativeToPosix(root, readinessSource));
  }
  const evidenceContextFiles = discoverCanonicalEvidenceFiles(
    fs,
    root,
    feature,
  );
  return [...new Set([...contextFiles, ...evidenceContextFiles])].sort(
    compareCodePoint,
  );
}
