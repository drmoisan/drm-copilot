/**
 * Orchestration half of the PR context collector.
 *
 * Purpose:
 *     Port of the data-gathering pipeline in
 *     `dev_tools/pr_context/collector.py` `collect_and_write` (up to the
 *     assembled inputs). Build the git/gh clients, gate availability, gather
 *     references and feature docs, classify references, fetch issue/PR details,
 *     compute diffs/scoping/CI, and partition change buckets.
 *
 * Responsibilities:
 *     - `collectPrContext`: run the pipeline and return a typed intermediate
 *       record consumed by `collector-output.ts`.
 *     - Hold the path/budget constants shared with the output builder.
 *     All filesystem/process access flows through the injected
 *     {@link FileSystem} and {@link CommandRunner}.
 */

import { type FileSystem } from "../file-system";
import { type CommandRunner } from "../subprocess-runner";
import {
  type FeatureDocExcerpt,
  type IssueDetails,
  type PrContextResult,
  type PullRequestDetails,
  type ScopingDocChange,
} from "./models";
import { GitClient } from "./git-client";
import { GhClient, type WhichGh } from "./gh-client-core";
import { buildPrContext } from "./render";
import {
  buildIssuesToAutocloseSection,
  extractChangedPaths,
} from "./render-pr-helpers";
import { gatherFeatureExcerpts } from "./feature-docs";
import { extractIssueReferences } from "./feature-docs-parsers";
import {
  parseNameStatusMap,
  parseNumstatDetailed,
  scopingDocChanges,
} from "./summary-helpers";

/** Default summary output path (repo-relative). */
export const SUMMARY_PATH_DEFAULT = "artifacts/pr_context.summary.txt";
/** Default appendix output path (repo-relative). */
export const APPENDIX_PATH_DEFAULT = "artifacts/pr_context.appendix.txt";
/** Summary character budget (10x: ~2300 lines at 70 chars/line). */
export const SUMMARY_CHAR_BUDGET = 160000;
/** Appendix character budget (10x: ~6900 lines at 70 chars/line). */
export const APPENDIX_CHAR_BUDGET = 480000;

/** A `[path, [adds, dels]]` bucket entry. */
export type BucketEntry = [string, [number, number]];

/** Typed intermediate record returned by {@link collectPrContext}. */
export interface CollectedPrContext {
  readonly resolvedRoot: string;
  readonly contextResult: PrContextResult;
  readonly featureDocs: FeatureDocExcerpt[];
  readonly additionalContextFiles: string[];
  readonly referencedIssues: string[];
  readonly referencedPrs: string[];
  readonly invalidRefs: string[];
  readonly verified: string[];
  readonly verifiedReason: string;
  readonly authorReason: string;
  readonly authorAsserted: string[];
  readonly issuesToAutocloseSection: string;
  readonly issueDetails: IssueDetails[];
  readonly prDetailsList: PullRequestDetails[];
  readonly scopingChanges: ScopingDocChange[];
  readonly materialScoping: {
    path: string;
    reasons: string[];
    excerpt: string | null;
  }[];
  readonly nonMaterialScoping: { path: string; reasons: string[] }[];
  readonly ciStatus: string | null;
  readonly ciJobs: string[];
  readonly bucketCore: BucketEntry[];
  readonly bucketRenames: BucketEntry[];
  readonly bucketDocs: BucketEntry[];
  readonly ghAvailable: boolean;
  readonly ghStatusOverride: string | null;
  readonly ghStatusMessage: string | null;
  readonly head: string | null;
}

/** Options for {@link collectPrContext}. */
export interface CollectPrContextOptions {
  readonly base: string | null;
  readonly head?: string | null;
  readonly repoRoot: string;
  readonly includeUntracked: boolean;
  readonly fs: FileSystem;
  readonly runner: CommandRunner;
  readonly clock?: () => Date;
  readonly whichGh?: WhichGh;
}

/**
 * Run the PR-context data-gathering pipeline.
 *
 * Mirrors the first half of Python `collect_and_write`: build/resolve the git
 * client, build the gh client and gate availability (with the override
 * message), fetch the current PR, run the first and (when feature refs exist)
 * second `buildPrContext`, gather feature docs, classify references across
 * feature/branch/path refs, derive verified/author reasons and pending-primary
 * autoclose targets, fetch issue/PR details, compute the diff selection,
 * scoping changes, CI status, and the core/renames/docs buckets.
 *
 * @param options Base/head/root, flags, and injected fs/runner/clock.
 * @returns The typed intermediate record for the output builder.
 */
export function collectPrContext(
  options: CollectPrContextOptions,
): CollectedPrContext {
  const { base, repoRoot, includeUntracked, fs, runner } = options;
  const head = options.head ?? null;
  const whichGh = options.whichGh;

  // Build the git client, resolve the repository root, then rebuild against it.
  let git = new GitClient(runner, repoRoot, fs);
  const resolvedRoot = git.resolveRoot();
  git = new GitClient(runner, resolvedRoot, fs);

  const gh = new GhClient({
    runner,
    cwd: resolvedRoot,
    fileSystem: fs,
    ...(whichGh === undefined ? {} : { whichGh }),
  });
  let ghAvailable = true;
  let ghStatusOverride: string | null = null;
  try {
    gh.ensureAvailable();
  } catch (exc) {
    ghAvailable = false;
    ghStatusOverride = `GitHub CLI unavailable: ${errorMessage(exc)}`;
  }

  const currentPr = gh.currentPr();

  // First pass builds context with no feature refs to discover changed paths.
  let contextResult = buildPrContext({
    git,
    gh,
    baseRef: base,
    headRef: head,
    includeUntracked,
    featureIssueRefs: [],
    currentPr,
    ghAvailable,
  });

  const changedPaths = extractChangedPaths(contextResult.text);
  const featureDocs = gatherFeatureExcerpts(fs, resolvedRoot, changedPaths);
  const additionalContextFiles = sortedSet(
    featureDocs.flatMap((doc) => doc.contextFiles).filter((path) => path),
  );
  const featureIssueRefs = sortedSet(
    featureDocs.flatMap((doc) => doc.issueRefs).filter((ref) => ref.trim()),
  );

  // When feature refs are found, rebuild context so they participate.
  if (featureIssueRefs.length > 0) {
    contextResult = buildPrContext({
      git,
      gh,
      baseRef: base,
      headRef: head,
      includeUntracked,
      featureIssueRefs,
      currentPr,
      ghAvailable,
    });
  }

  const referencedIssuesSet = new Set(contextResult.referencedIssues);
  const referencedPrsSet = new Set(contextResult.referencedPrs);
  const invalidRefsSet = new Set(contextResult.invalidReferences);
  const branchRefs = extractIssueReferences(git.branchName());
  const pathRefs = extractIssueReferences(changedPaths.join("\n"));
  classifyReferences({
    gh,
    ghAvailable,
    featureIssueRefs,
    branchRefs,
    pathRefs,
    referencedIssuesSet,
    referencedPrsSet,
    invalidRefsSet,
  });

  const referencedIssues = [...referencedIssuesSet].sort(compareCodePoint);
  const referencedPrs = [...referencedPrsSet].sort(compareCodePoint);
  const invalidRefs = [...invalidRefsSet].sort(compareCodePoint);

  let authorAsserted: string[] = [];
  const authorReasonInitial = "None (author has not asserted autoclose issues)";
  const verified = ghAvailable ? contextResult.verifiedClosing : [];
  let verifiedReason: string;
  if (!ghAvailable) {
    verifiedReason = "None (GitHub CLI unavailable)";
  } else if (currentPr === null) {
    verifiedReason = "None (no PR exists yet for this branch)";
  } else if (verified.length === 0) {
    verifiedReason = "None (closingIssuesReferences empty)";
  } else {
    verifiedReason = "(verified from GitHub PR metadata)";
  }

  let authorReason = authorReasonInitial;
  if (referencedIssues.length > 0) {
    authorAsserted = sortedSet([...authorAsserted, ...referencedIssues]);
    authorReason = "Detected issue references (classified)";
  }

  // Derive deterministic pending autoclose targets from explicit metadata only
  // when feature readiness is PASS.
  const pendingPrimary: string[] = [];
  for (const featureDoc of featureDocs) {
    if (featureDoc.readinessSignal !== "PASS") {
      continue;
    }
    if (!featureDoc.primaryIssueRef) {
      continue;
    }
    if (!pendingPrimary.includes(featureDoc.primaryIssueRef)) {
      pendingPrimary.push(featureDoc.primaryIssueRef);
    }
  }
  const readinessSignals = sortedSet(
    featureDocs
      .map((doc) => doc.readinessSignal)
      .filter((signal): signal is string => Boolean(signal)),
  );
  const issuesToAutocloseSection = buildIssuesToAutocloseSection({
    verified,
    pendingPrimary,
    readinessSignals,
  });

  const issuesToFetch = sortedSet([
    ...verified,
    ...authorAsserted,
    ...referencedIssues,
  ]);
  const issueDetails: IssueDetails[] = [];
  if (ghAvailable) {
    for (const ref of issuesToFetch) {
      issueDetails.push(gh.issueDetails(ref.replace(/^#+/u, "")));
    }
  }

  const prDetailsList: PullRequestDetails[] = [];
  if (ghAvailable) {
    for (const ref of referencedPrs) {
      prDetailsList.push(gh.prDetails(ref.replace(/^#+/u, "")));
    }
  }

  // Diff selection: merge-base+head when both known, else the working tree.
  let nameStatusText: string;
  let numstatText: string;
  if (contextResult.mergeBase && contextResult.headSha) {
    nameStatusText = git.diffRange([
      "--name-status",
      contextResult.mergeBase,
      contextResult.headSha,
    ]);
    numstatText = git.diffRange([
      "--numstat",
      contextResult.mergeBase,
      contextResult.headSha,
    ]);
  } else {
    nameStatusText = git.diffRange(["--name-status"]);
    numstatText = git.diffRange(["--numstat"]);
  }

  const [, , perFileStats] = parseNumstatDetailed(numstatText);
  const statusMap = parseNameStatusMap(nameStatusText);

  const scopingChanges = scopingDocChanges({
    git,
    fs,
    mergeBase: contextResult.mergeBase,
    headSha: contextResult.headSha,
    root: resolvedRoot,
    nameStatusText,
    numstatDetails: perFileStats,
  });
  const materialScoping = scopingChanges
    .filter((change) => change.material)
    .map((change) => ({
      path: change.path,
      reasons: change.reasons,
      excerpt: change.excerpt,
    }));
  const nonMaterialScoping = scopingChanges
    .filter((change) => !change.material)
    .map((change) => ({ path: change.path, reasons: change.reasons }));

  let ciTarget = contextResult.headSha;
  if (!ciTarget) {
    try {
      ciTarget = git.revParse("HEAD");
    } catch {
      ciTarget = null;
    }
  }
  const [ciStatus, ciJobs] =
    ciTarget && ghAvailable ? gh.ciStatus(ciTarget) : [null, []];

  const bucketCore: BucketEntry[] = [];
  const bucketRenames: BucketEntry[] = [];
  const bucketDocs: BucketEntry[] = [];
  // Partition changed files into core/renames/docs buckets by status and path.
  for (const [path, status] of statusMap) {
    const stats = perFileStats.get(path) ?? [0, 0];
    if (status.startsWith("R")) {
      bucketRenames.push([path, stats]);
    } else if (path.endsWith(".py") || path.endsWith(".ps1")) {
      bucketCore.push([path, stats]);
    } else if (
      path.startsWith("docs/") ||
      path.startsWith(".github") ||
      path.includes("AGENTS")
    ) {
      bucketDocs.push([path, stats]);
    }
  }

  return {
    resolvedRoot,
    contextResult,
    featureDocs,
    additionalContextFiles,
    referencedIssues,
    referencedPrs,
    invalidRefs,
    verified,
    verifiedReason,
    authorReason,
    authorAsserted: sortedSet(authorAsserted),
    issuesToAutocloseSection,
    issueDetails,
    prDetailsList,
    scopingChanges,
    materialScoping,
    nonMaterialScoping,
    ciStatus,
    ciJobs,
    bucketCore,
    bucketRenames,
    bucketDocs,
    ghAvailable,
    ghStatusOverride,
    ghStatusMessage: gh.statusMessage,
    head,
  };
}

/** Options for the reference-classification loop. */
interface ClassifyReferencesOptions {
  gh: GhClient;
  ghAvailable: boolean;
  featureIssueRefs: string[];
  branchRefs: string[];
  pathRefs: string[];
  referencedIssuesSet: Set<string>;
  referencedPrsSet: Set<string>;
  invalidRefsSet: Set<string>;
}

/**
 * Classify feature/branch/path references into the issue/PR/invalid sets.
 *
 * Mirrors the Python classification loop: when gh is available, classify each
 * feature ref and each branch/path ref via `classify_entity`; otherwise add all
 * feature, branch, and path refs to the issue set.
 *
 * @param options Classification inputs and the mutable target sets.
 */
function classifyReferences(options: ClassifyReferencesOptions): void {
  const {
    gh,
    ghAvailable,
    featureIssueRefs,
    branchRefs,
    pathRefs,
    referencedIssuesSet,
    referencedPrsSet,
    invalidRefsSet,
  } = options;

  if (ghAvailable) {
    // Classify the feature refs first, then the combined branch/path refs.
    for (const ref of featureIssueRefs) {
      classifyOne(
        gh,
        ref,
        referencedIssuesSet,
        referencedPrsSet,
        invalidRefsSet,
      );
    }
    for (const ref of [...branchRefs, ...pathRefs]) {
      classifyOne(
        gh,
        ref,
        referencedIssuesSet,
        referencedPrsSet,
        invalidRefsSet,
      );
    }
  } else {
    // gh unavailable: every ref is treated as an (unverified) issue.
    for (const ref of featureIssueRefs) {
      referencedIssuesSet.add(formatRef(ref));
    }
    for (const ref of [...branchRefs, ...pathRefs]) {
      referencedIssuesSet.add(formatRef(ref));
    }
  }
}

/** Classify a single reference into the appropriate set. */
function classifyOne(
  gh: GhClient,
  ref: string,
  issuesSet: Set<string>,
  prsSet: Set<string>,
  invalidSet: Set<string>,
): void {
  const formatted = formatRef(ref);
  const entity = gh.classifyEntity(ref.replace(/^#+/u, ""));
  if (entity === "issue") {
    issuesSet.add(formatted);
  } else if (entity === "pull") {
    prsSet.add(formatted);
  } else {
    invalidSet.add(formatted);
  }
}

/** Prefix a reference with `#` when not already present. */
function formatRef(ref: string): string {
  return ref.startsWith("#") ? ref : `#${ref}`;
}

/** Extract a message from a thrown value, matching Python `str(exc)`. */
function errorMessage(exc: unknown): string {
  return exc instanceof Error ? exc.message : String(exc);
}

/** Sort a deduplicated set of strings by Unicode code point. */
function sortedSet(values: Iterable<string>): string[] {
  return [...new Set(values)].sort(compareCodePoint);
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
