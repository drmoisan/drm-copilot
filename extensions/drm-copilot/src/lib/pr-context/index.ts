/**
 * Public surface for the in-process PR context port.
 *
 * Purpose:
 *     Re-export the public API mirroring `dev_tools/pr_context/__init__.py` and
 *     the `collector.py` `__all__`: the models and pure helpers, the
 *     {@link GitClient} and {@link GhClient}, `buildPrContext`, `collectAndWrite`,
 *     and the render/summary helper functions consumers rely on.
 */

// Models and pure helpers.
export {
  type BaseHeadInfo,
  type CiStatusSnapshot,
  type CommandResult,
  CONVENTIONAL_TYPES,
  type ConventionalType,
  type FeatureDocExcerpt,
  type GitHubCliStatus,
  type IssueDetails,
  type PrContextResult,
  type PullRequestDetails,
  type ScopingDocChange,
  SECTION_LINE,
  findUserStoryLink,
  formatList,
  normalizeReference,
  section,
  splitLines,
  truncate,
  truncateLines,
} from "./models";

// Git and GitHub clients.
export { GitClient } from "./git-client";
export { GhClient, type GhClientOptions, type WhichGh } from "./gh-client-core";

// Render orchestrator and helpers (mirrors render.py __all__).
export {
  type BuildPrContextOptions,
  type GhLike,
  buildCloseCandidatesSection,
  buildExcerptText,
  buildPrContext,
  completedPlanTasks,
  convertNumstat,
  directoryExists,
  extensionSummary,
  extractChangedPaths,
  extractFeaturesFromPaths,
  extractIssueReferences,
  extractMergePrNumbers,
  extractPlanSections,
  extractSpecParts,
  extractStoryParts,
  formatDiffPath,
  formatIssueDetails,
  formatPrDetails,
  gatherFeatureExcerpts,
  parseSection,
  readTextFile,
  resolveFeatureDir,
  selectDefaultBase,
  summarizeConventionalCommits,
} from "./render";

// Autoclose section builder.
export { buildIssuesToAutocloseSection } from "./render-pr-helpers";

// Collector feature-docs variant (richer context_files + readiness).
export { gatherFeatureExcerpts as gatherCollectorFeatureExcerpts } from "./feature-docs";

// Verification evidence.
export {
  type NormalizedResult,
  type VerificationEvidenceRecord,
  discoverCanonicalEvidenceFiles,
  parseVerificationEvidenceFile,
  parseVerificationEvidenceMarkdown,
} from "./verification-evidence";

// Summary helpers and digests.
export {
  appendGenerationTimestamp,
  bucketText,
  isScopingDoc,
  parseNameStatusMap,
  parseNumstatDetailed,
  scopingDocChanges,
} from "./summary-helpers";
export {
  extractDigestBullets,
  issueAppendix,
  issueDigest,
  lastWithTruncation,
  prAppendix,
  prDigest,
} from "./summary-digests";

// Collector entry points and constants.
export {
  type CollectPrContextOptions,
  type CollectedPrContext,
  APPENDIX_PATH_DEFAULT,
  SUMMARY_PATH_DEFAULT,
  collectPrContext,
} from "./collector-core";
export {
  type CollectAndWriteOptions,
  buildAppendixText,
  buildSummaryText,
  collectAndWrite,
  renderVerificationEvidenceSection,
  writeOutput,
} from "./collector-output";
