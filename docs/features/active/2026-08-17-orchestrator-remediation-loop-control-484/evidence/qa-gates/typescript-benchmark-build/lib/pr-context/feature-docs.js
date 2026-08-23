"use strict";
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
Object.defineProperty(exports, "__esModule", { value: true });
exports.gatherFeatureExcerpts = gatherFeatureExcerpts;
const file_system_1 = require("../file-system");
const models_1 = require("./models");
const feature_docs_parsers_1 = require("./feature-docs-parsers");
const verification_evidence_1 = require("./verification-evidence");
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
];
/**
 * Extract feature directory names from `docs/features/active/**` paths.
 *
 * Mirrors the Python set-comprehension over `Path(raw).parts`.
 *
 * @param changedFiles Repo-relative changed file paths.
 * @returns The set of active-feature directory names.
 */
function extractFeatures(changedFiles) {
    const features = new Set();
    // Collect the feature segment from any docs/features/active/<feature>/... path.
    for (const raw of changedFiles) {
        const parts = (0, file_system_1.toPosixPath)(raw).split("/");
        if (parts.length >= 4 &&
            parts[0] === "docs" &&
            parts[1] === "features" &&
            parts[2] === "active") {
            features.add(parts[3]);
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
function gatherFeatureExcerpts(fs, root, changedFiles) {
    const normalizedRoot = (0, file_system_1.toPosixPath)(root).replace(/\/+$/u, "");
    const features = extractFeatures(changedFiles);
    const excerpts = [];
    const baseDir = `${normalizedRoot}/docs/features/active`;
    const promotedDir = `${normalizedRoot}/docs/features/potential/promoted`;
    // Process features in sorted order for deterministic output.
    for (const feature of [...features].sort(feature_docs_parsers_1.compareCodePoint)) {
        const featureDir = (0, feature_docs_parsers_1.resolveFeatureDir)(fs, baseDir, feature);
        const promotedFeatureDir = (0, feature_docs_parsers_1.resolveFeatureDir)(fs, promotedDir, feature);
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
            const latestPlan = (0, feature_docs_parsers_1.latestGlobPath)(fs, activeDir, "plan.*.md");
            if (latestPlan !== null) {
                planPath = latestPlan;
            }
        }
        let userStoryPath = `${activeDir}/user-story.md`;
        const promotedStoryPath = promotedFeatureDir !== null
            ? `${promotedFeatureDir}/user-story.md`
            : null;
        const promotedStoryText = promotedStoryPath !== null ? (0, feature_docs_parsers_1.readText)(fs, promotedStoryPath) : "";
        if (promotedStoryPath !== null && !fs.exists(userStoryPath)) {
            userStoryPath = promotedStoryPath;
        }
        let userStoryText = (0, feature_docs_parsers_1.readText)(fs, userStoryPath);
        if (!userStoryText && promotedStoryText && promotedStoryPath !== null) {
            userStoryText = promotedStoryText;
            userStoryPath = promotedStoryPath;
        }
        const specText = (0, feature_docs_parsers_1.readText)(fs, specPath);
        const issueText = (0, feature_docs_parsers_1.readText)(fs, issuePath);
        const planText = (0, feature_docs_parsers_1.readText)(fs, planPath);
        const primaryIssueRef = (0, feature_docs_parsers_1.parsePrimaryIssueFromMetadata)({
            specText,
            storyText: userStoryText,
            issueText,
        });
        const [readinessSignal, readinessSource] = (0, feature_docs_parsers_1.resolveReadinessSignal)(fs, activeDir);
        const specParts = buildSpecParts(specText);
        const planSection = buildPlanSection(planText);
        const verificationBlock = buildVerificationBlock(planText);
        const storyParts = buildStoryParts(userStoryText, promotedStoryText);
        const excerpt = buildExcerpt(feature, storyParts, specParts, planSection, verificationBlock);
        const contextFiles = buildContextFiles({
            fs,
            root: normalizedRoot,
            feature,
            candidatePaths: [specPath, issuePath, planPath, userStoryPath],
            readinessSource,
        });
        const issueRefs = (0, feature_docs_parsers_1.extractIssueReferences)([specText, issueText, planText, userStoryText].join("\n"));
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
function buildSpecParts(specText) {
    const specParts = [];
    for (const heading of SPEC_HEADINGS) {
        const sectionText = (0, feature_docs_parsers_1.parseSection)(specText, heading);
        if (sectionText) {
            specParts.push(`${heading}: ${(0, models_1.truncate)(sectionText)}`);
        }
    }
    return specParts;
}
/** Build the completed-plan-tasks bullet block, or `""`. */
function buildPlanSection(planText) {
    const planTasks = (0, feature_docs_parsers_1.completedPlanTasks)(planText);
    return planTasks.length > 0
        ? planTasks.map((task) => `- ${task}`).join("\n")
        : "";
}
/** Build the verification-notes block, or `""`. */
function buildVerificationBlock(planText) {
    const text = (0, feature_docs_parsers_1.verificationText)(planText);
    return text ? "Plan verification notes:\n" + (0, models_1.truncate)(text) : "";
}
/** Build the user-story excerpt parts with the promoted-folder fallback. */
function buildStoryParts(userStoryText, promotedStoryText) {
    const storyParts = [];
    const storyStatements = (0, feature_docs_parsers_1.parseSection)(userStoryText, "Story Statement");
    if (storyStatements) {
        const storyLines = storyStatements
            .split(/\r\n|\r|\n/u)
            .filter((line) => line.trim())
            .map((line) => line.replace(/^[- ]+|[- ]+$/gu, ""));
        if (storyLines.length > 0) {
            storyParts.push("Story Statement:\n" + storyLines.map((line) => `- ${line}`).join("\n"));
        }
    }
    const problemSection = (0, feature_docs_parsers_1.parseSection)(userStoryText, "Problem / Why");
    if (problemSection) {
        storyParts.push("Problem / Why:\n" + (0, models_1.truncate)(problemSection));
    }
    if (storyParts.length === 0 && promotedStoryText) {
        let promotedProblem = (0, feature_docs_parsers_1.parseSection)(promotedStoryText, "Problem / Why");
        if (!promotedProblem) {
            promotedProblem = (0, feature_docs_parsers_1.parseSection)(promotedStoryText, "Summary");
        }
        if (promotedProblem) {
            storyParts.push("Problem / Why:\n" + (0, models_1.truncate)(promotedProblem));
        }
    }
    return storyParts;
}
/** Assemble the excerpt block from the collected sections. */
function buildExcerpt(feature, storyParts, specParts, planSection, verificationBlock) {
    const lines = [(0, models_1.section)(`Feature doc: ${feature}`)];
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
function buildContextFiles(params) {
    const { fs, root, feature, candidatePaths, readinessSource } = params;
    const contextFiles = [];
    // Keep only existing candidate paths, as repo-relative POSIX paths.
    for (const path of candidatePaths) {
        if (fs.exists(path)) {
            contextFiles.push((0, feature_docs_parsers_1.relativeToPosix)(root, path));
        }
    }
    if (readinessSource !== null) {
        contextFiles.push((0, feature_docs_parsers_1.relativeToPosix)(root, readinessSource));
    }
    const evidenceContextFiles = (0, verification_evidence_1.discoverCanonicalEvidenceFiles)(fs, root, feature);
    return [...new Set([...contextFiles, ...evidenceContextFiles])].sort(feature_docs_parsers_1.compareCodePoint);
}
