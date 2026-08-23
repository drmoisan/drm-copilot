"use strict";
/**
 * Public surface for the in-process PR context port.
 *
 * Purpose:
 *     Re-export the public API mirroring `dev_tools/pr_context/__init__.py` and
 *     the `collector.py` `__all__`: the models and pure helpers, the
 *     {@link GitClient} and {@link GhClient}, `buildPrContext`, `collectAndWrite`,
 *     and the render/summary helper functions consumers rely on.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.prAppendix = exports.lastWithTruncation = exports.issueDigest = exports.issueAppendix = exports.extractDigestBullets = exports.scopingDocChanges = exports.parseNumstatDetailed = exports.parseNameStatusMap = exports.isScopingDoc = exports.bucketText = exports.appendGenerationTimestamp = exports.parseVerificationEvidenceMarkdown = exports.parseVerificationEvidenceFile = exports.discoverCanonicalEvidenceFiles = exports.gatherCollectorFeatureExcerpts = exports.buildIssuesToAutocloseSection = exports.summarizeConventionalCommits = exports.selectDefaultBase = exports.resolveFeatureDir = exports.readTextFile = exports.parseSection = exports.gatherFeatureExcerpts = exports.formatPrDetails = exports.formatIssueDetails = exports.formatDiffPath = exports.extractStoryParts = exports.extractSpecParts = exports.extractPlanSections = exports.extractMergePrNumbers = exports.extractIssueReferences = exports.extractFeaturesFromPaths = exports.extractChangedPaths = exports.extensionSummary = exports.directoryExists = exports.convertNumstat = exports.completedPlanTasks = exports.buildPrContext = exports.buildExcerptText = exports.buildCloseCandidatesSection = exports.GhClient = exports.GitClient = exports.truncateLines = exports.truncate = exports.splitLines = exports.section = exports.normalizeReference = exports.formatList = exports.findUserStoryLink = exports.SECTION_LINE = exports.CONVENTIONAL_TYPES = void 0;
exports.writeOutput = exports.renderVerificationEvidenceSection = exports.collectAndWrite = exports.buildSummaryText = exports.buildAppendixText = exports.collectPrContext = exports.SUMMARY_PATH_DEFAULT = exports.APPENDIX_PATH_DEFAULT = exports.prDigest = void 0;
// Models and pure helpers.
var models_1 = require("./models");
Object.defineProperty(exports, "CONVENTIONAL_TYPES", { enumerable: true, get: function () { return models_1.CONVENTIONAL_TYPES; } });
Object.defineProperty(exports, "SECTION_LINE", { enumerable: true, get: function () { return models_1.SECTION_LINE; } });
Object.defineProperty(exports, "findUserStoryLink", { enumerable: true, get: function () { return models_1.findUserStoryLink; } });
Object.defineProperty(exports, "formatList", { enumerable: true, get: function () { return models_1.formatList; } });
Object.defineProperty(exports, "normalizeReference", { enumerable: true, get: function () { return models_1.normalizeReference; } });
Object.defineProperty(exports, "section", { enumerable: true, get: function () { return models_1.section; } });
Object.defineProperty(exports, "splitLines", { enumerable: true, get: function () { return models_1.splitLines; } });
Object.defineProperty(exports, "truncate", { enumerable: true, get: function () { return models_1.truncate; } });
Object.defineProperty(exports, "truncateLines", { enumerable: true, get: function () { return models_1.truncateLines; } });
// Git and GitHub clients.
var git_client_1 = require("./git-client");
Object.defineProperty(exports, "GitClient", { enumerable: true, get: function () { return git_client_1.GitClient; } });
var gh_client_core_1 = require("./gh-client-core");
Object.defineProperty(exports, "GhClient", { enumerable: true, get: function () { return gh_client_core_1.GhClient; } });
// Render orchestrator and helpers (mirrors render.py __all__).
var render_1 = require("./render");
Object.defineProperty(exports, "buildCloseCandidatesSection", { enumerable: true, get: function () { return render_1.buildCloseCandidatesSection; } });
Object.defineProperty(exports, "buildExcerptText", { enumerable: true, get: function () { return render_1.buildExcerptText; } });
Object.defineProperty(exports, "buildPrContext", { enumerable: true, get: function () { return render_1.buildPrContext; } });
Object.defineProperty(exports, "completedPlanTasks", { enumerable: true, get: function () { return render_1.completedPlanTasks; } });
Object.defineProperty(exports, "convertNumstat", { enumerable: true, get: function () { return render_1.convertNumstat; } });
Object.defineProperty(exports, "directoryExists", { enumerable: true, get: function () { return render_1.directoryExists; } });
Object.defineProperty(exports, "extensionSummary", { enumerable: true, get: function () { return render_1.extensionSummary; } });
Object.defineProperty(exports, "extractChangedPaths", { enumerable: true, get: function () { return render_1.extractChangedPaths; } });
Object.defineProperty(exports, "extractFeaturesFromPaths", { enumerable: true, get: function () { return render_1.extractFeaturesFromPaths; } });
Object.defineProperty(exports, "extractIssueReferences", { enumerable: true, get: function () { return render_1.extractIssueReferences; } });
Object.defineProperty(exports, "extractMergePrNumbers", { enumerable: true, get: function () { return render_1.extractMergePrNumbers; } });
Object.defineProperty(exports, "extractPlanSections", { enumerable: true, get: function () { return render_1.extractPlanSections; } });
Object.defineProperty(exports, "extractSpecParts", { enumerable: true, get: function () { return render_1.extractSpecParts; } });
Object.defineProperty(exports, "extractStoryParts", { enumerable: true, get: function () { return render_1.extractStoryParts; } });
Object.defineProperty(exports, "formatDiffPath", { enumerable: true, get: function () { return render_1.formatDiffPath; } });
Object.defineProperty(exports, "formatIssueDetails", { enumerable: true, get: function () { return render_1.formatIssueDetails; } });
Object.defineProperty(exports, "formatPrDetails", { enumerable: true, get: function () { return render_1.formatPrDetails; } });
Object.defineProperty(exports, "gatherFeatureExcerpts", { enumerable: true, get: function () { return render_1.gatherFeatureExcerpts; } });
Object.defineProperty(exports, "parseSection", { enumerable: true, get: function () { return render_1.parseSection; } });
Object.defineProperty(exports, "readTextFile", { enumerable: true, get: function () { return render_1.readTextFile; } });
Object.defineProperty(exports, "resolveFeatureDir", { enumerable: true, get: function () { return render_1.resolveFeatureDir; } });
Object.defineProperty(exports, "selectDefaultBase", { enumerable: true, get: function () { return render_1.selectDefaultBase; } });
Object.defineProperty(exports, "summarizeConventionalCommits", { enumerable: true, get: function () { return render_1.summarizeConventionalCommits; } });
// Autoclose section builder.
var render_pr_helpers_1 = require("./render-pr-helpers");
Object.defineProperty(exports, "buildIssuesToAutocloseSection", { enumerable: true, get: function () { return render_pr_helpers_1.buildIssuesToAutocloseSection; } });
// Collector feature-docs variant (richer context_files + readiness).
var feature_docs_1 = require("./feature-docs");
Object.defineProperty(exports, "gatherCollectorFeatureExcerpts", { enumerable: true, get: function () { return feature_docs_1.gatherFeatureExcerpts; } });
// Verification evidence.
var verification_evidence_1 = require("./verification-evidence");
Object.defineProperty(exports, "discoverCanonicalEvidenceFiles", { enumerable: true, get: function () { return verification_evidence_1.discoverCanonicalEvidenceFiles; } });
Object.defineProperty(exports, "parseVerificationEvidenceFile", { enumerable: true, get: function () { return verification_evidence_1.parseVerificationEvidenceFile; } });
Object.defineProperty(exports, "parseVerificationEvidenceMarkdown", { enumerable: true, get: function () { return verification_evidence_1.parseVerificationEvidenceMarkdown; } });
// Summary helpers and digests.
var summary_helpers_1 = require("./summary-helpers");
Object.defineProperty(exports, "appendGenerationTimestamp", { enumerable: true, get: function () { return summary_helpers_1.appendGenerationTimestamp; } });
Object.defineProperty(exports, "bucketText", { enumerable: true, get: function () { return summary_helpers_1.bucketText; } });
Object.defineProperty(exports, "isScopingDoc", { enumerable: true, get: function () { return summary_helpers_1.isScopingDoc; } });
Object.defineProperty(exports, "parseNameStatusMap", { enumerable: true, get: function () { return summary_helpers_1.parseNameStatusMap; } });
Object.defineProperty(exports, "parseNumstatDetailed", { enumerable: true, get: function () { return summary_helpers_1.parseNumstatDetailed; } });
Object.defineProperty(exports, "scopingDocChanges", { enumerable: true, get: function () { return summary_helpers_1.scopingDocChanges; } });
var summary_digests_1 = require("./summary-digests");
Object.defineProperty(exports, "extractDigestBullets", { enumerable: true, get: function () { return summary_digests_1.extractDigestBullets; } });
Object.defineProperty(exports, "issueAppendix", { enumerable: true, get: function () { return summary_digests_1.issueAppendix; } });
Object.defineProperty(exports, "issueDigest", { enumerable: true, get: function () { return summary_digests_1.issueDigest; } });
Object.defineProperty(exports, "lastWithTruncation", { enumerable: true, get: function () { return summary_digests_1.lastWithTruncation; } });
Object.defineProperty(exports, "prAppendix", { enumerable: true, get: function () { return summary_digests_1.prAppendix; } });
Object.defineProperty(exports, "prDigest", { enumerable: true, get: function () { return summary_digests_1.prDigest; } });
// Collector entry points and constants.
var collector_core_1 = require("./collector-core");
Object.defineProperty(exports, "APPENDIX_PATH_DEFAULT", { enumerable: true, get: function () { return collector_core_1.APPENDIX_PATH_DEFAULT; } });
Object.defineProperty(exports, "SUMMARY_PATH_DEFAULT", { enumerable: true, get: function () { return collector_core_1.SUMMARY_PATH_DEFAULT; } });
Object.defineProperty(exports, "collectPrContext", { enumerable: true, get: function () { return collector_core_1.collectPrContext; } });
var collector_output_1 = require("./collector-output");
Object.defineProperty(exports, "buildAppendixText", { enumerable: true, get: function () { return collector_output_1.buildAppendixText; } });
Object.defineProperty(exports, "buildSummaryText", { enumerable: true, get: function () { return collector_output_1.buildSummaryText; } });
Object.defineProperty(exports, "collectAndWrite", { enumerable: true, get: function () { return collector_output_1.collectAndWrite; } });
Object.defineProperty(exports, "renderVerificationEvidenceSection", { enumerable: true, get: function () { return collector_output_1.renderVerificationEvidenceSection; } });
Object.defineProperty(exports, "writeOutput", { enumerable: true, get: function () { return collector_output_1.writeOutput; } });
