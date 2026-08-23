"use strict";
/**
 * Rendering orchestrator for PR context collection.
 *
 * Purpose:
 *     Port of `dev_tools/pr_context/render.py` `build_pr_context` and
 *     `resolve_feature_dir`. Build the full PR context payload from git/gh state
 *     and references, reproducing the exact section ordering, base/merge-base
 *     resolution, classification, and failure-path behavior of the source.
 *
 * Responsibilities:
 *     - `buildPrContext`: assemble the combined context text and the
 *       {@link PrContextResult} record.
 *     - `resolveFeatureDir`: the render-module feature-dir resolver.
 *     - Re-export the render-pr-helpers and render-feature-excerpts symbols, as
 *       the Python `render.py` `__all__` does.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.readTextFile = exports.parseSection = exports.gatherFeatureExcerpts = exports.extractStoryParts = exports.extractSpecParts = exports.extractPlanSections = exports.extractFeaturesFromPaths = exports.directoryExists = exports.completedPlanTasks = exports.buildExcerptText = exports.summarizeConventionalCommits = exports.selectDefaultBase = exports.formatPrDetails = exports.formatIssueDetails = exports.formatDiffPath = exports.extractMergePrNumbers = exports.extractIssueReferences = exports.extractChangedPaths = exports.extensionSummary = exports.convertNumstat = exports.buildCloseCandidatesSection = void 0;
exports.resolveFeatureDir = resolveFeatureDir;
exports.buildPrContext = buildPrContext;
const models_1 = require("./models");
const render_pr_helpers_1 = require("./render-pr-helpers");
const render_feature_excerpts_1 = require("./render-feature-excerpts");
// Re-export the render-pr-helpers and render-feature-excerpts symbols so this
// module presents the same surface as the Python `render.py` `__all__`.
var render_pr_helpers_2 = require("./render-pr-helpers");
Object.defineProperty(exports, "buildCloseCandidatesSection", { enumerable: true, get: function () { return render_pr_helpers_2.buildCloseCandidatesSection; } });
Object.defineProperty(exports, "convertNumstat", { enumerable: true, get: function () { return render_pr_helpers_2.convertNumstat; } });
Object.defineProperty(exports, "extensionSummary", { enumerable: true, get: function () { return render_pr_helpers_2.extensionSummary; } });
Object.defineProperty(exports, "extractChangedPaths", { enumerable: true, get: function () { return render_pr_helpers_2.extractChangedPaths; } });
Object.defineProperty(exports, "extractIssueReferences", { enumerable: true, get: function () { return render_pr_helpers_2.extractIssueReferences; } });
Object.defineProperty(exports, "extractMergePrNumbers", { enumerable: true, get: function () { return render_pr_helpers_2.extractMergePrNumbers; } });
Object.defineProperty(exports, "formatDiffPath", { enumerable: true, get: function () { return render_pr_helpers_2.formatDiffPath; } });
Object.defineProperty(exports, "formatIssueDetails", { enumerable: true, get: function () { return render_pr_helpers_2.formatIssueDetails; } });
Object.defineProperty(exports, "formatPrDetails", { enumerable: true, get: function () { return render_pr_helpers_2.formatPrDetails; } });
Object.defineProperty(exports, "selectDefaultBase", { enumerable: true, get: function () { return render_pr_helpers_2.selectDefaultBase; } });
Object.defineProperty(exports, "summarizeConventionalCommits", { enumerable: true, get: function () { return render_pr_helpers_2.summarizeConventionalCommits; } });
var render_feature_excerpts_2 = require("./render-feature-excerpts");
Object.defineProperty(exports, "buildExcerptText", { enumerable: true, get: function () { return render_feature_excerpts_2.buildExcerptText; } });
Object.defineProperty(exports, "completedPlanTasks", { enumerable: true, get: function () { return render_feature_excerpts_2.completedPlanTasks; } });
Object.defineProperty(exports, "directoryExists", { enumerable: true, get: function () { return render_feature_excerpts_2.directoryExists; } });
Object.defineProperty(exports, "extractFeaturesFromPaths", { enumerable: true, get: function () { return render_feature_excerpts_2.extractFeaturesFromPaths; } });
Object.defineProperty(exports, "extractPlanSections", { enumerable: true, get: function () { return render_feature_excerpts_2.extractPlanSections; } });
Object.defineProperty(exports, "extractSpecParts", { enumerable: true, get: function () { return render_feature_excerpts_2.extractSpecParts; } });
Object.defineProperty(exports, "extractStoryParts", { enumerable: true, get: function () { return render_feature_excerpts_2.extractStoryParts; } });
Object.defineProperty(exports, "gatherFeatureExcerpts", { enumerable: true, get: function () { return render_feature_excerpts_2.gatherFeatureExcerpts; } });
Object.defineProperty(exports, "parseSection", { enumerable: true, get: function () { return render_feature_excerpts_2.parseSection; } });
Object.defineProperty(exports, "readTextFile", { enumerable: true, get: function () { return render_feature_excerpts_2.readTextFile; } });
/**
 * Resolve a feature directory by exact, strong-pattern, then weak match.
 *
 * Mirrors Python `render.resolve_feature_dir`, delegating the matching logic to
 * the render-feature-excerpts variant.
 *
 * @param fs Injected filesystem.
 * @param baseDir Base directory.
 * @param feature Feature identifier.
 * @returns The resolved directory path, or `null`.
 */
function resolveFeatureDir(fs, baseDir, feature) {
    // The Python render variant first checks the direct child, then guards on the
    // base directory existing; delegate to the shared render resolver which does
    // exactly that.
    if ((0, render_feature_excerpts_1.directoryExists)(fs, `${baseDir}/${feature}`)) {
        return `${baseDir}/${feature}`;
    }
    return (0, render_feature_excerpts_1.resolveFeatureDir)(fs, baseDir, feature);
}
/**
 * Build the full PR context payload from git/gh state and references.
 *
 * Mirrors Python `build_pr_context` exactly: gh-available defaulting, base
 * resolution and the `origin/<base>` remote-probe with the stale-base warning,
 * rev-parse/merge-base/range, the log invocations, author sorted-set,
 * numstat/extension/merge-PR summaries, issue/PR classification with the
 * gh-unavailable fallback, the `===== PR Comparison =====` block ordering, the
 * catch-all failure block with reset fields, the PR Intent block, and the final
 * combined-text section ordering ending in the staged/unstaged diffs and
 * `prBlock`.
 *
 * @param options Git/gh clients, refs, and reference inputs.
 * @returns The assembled {@link PrContextResult}.
 */
function buildPrContext(options) {
    const { git, gh, baseRef, headRef, includeUntracked } = options;
    // gh-available defaulting: prefer the explicit flag, else the gh property,
    // else True (matching the Python precedence chain).
    let ghAvailable;
    if (options.ghAvailable === undefined || options.ghAvailable === null) {
        ghAvailable = typeof gh.available === "boolean" ? gh.available : true;
    }
    else {
        ghAvailable = options.ghAvailable;
    }
    if (ghAvailable) {
        gh.ensureAvailable();
    }
    const branchName = git.branchName();
    const upstream = git.upstream() || "(none)";
    const remotes = git.remoteVerbose();
    const statusShort = git.statusShort();
    const untracked = includeUntracked ? git.untracked() : "";
    const untrackedDisplay = untracked.trim() ? untracked : "(none)";
    const featureIssueList = [...(options.featureIssueRefs ?? [])];
    let referencedIssues;
    let referencedPrs;
    const currentPr = options.currentPr ?? null;
    let verifiedClosing = currentPr && ghAvailable ? currentPr.closingIssues : [];
    let invalidReferences = [];
    let resolvedBase;
    let baseSha;
    let headSha;
    let headRefResolved;
    let mergeBase;
    let revRange;
    let prBlock;
    try {
        const requestedBase = baseRef;
        resolvedBase = baseRef || (0, render_pr_helpers_1.selectDefaultBase)(git);
        if (!resolvedBase) {
            throw new Error("Failed to resolve base ref (tried common defaults)");
        }
        let baseWarning = null;
        // Probe origin/<base> for a local base ref; warn when the requested base is
        // local and a remote counterpart could not be confirmed.
        if (!resolvedBase.startsWith("origin/")) {
            const remoteCandidate = `origin/${resolvedBase}`;
            const remoteProbe = git.run(["rev-parse", "--verify", "--quiet", remoteCandidate], { allowError: true });
            if (remoteProbe.code === 0 && remoteProbe.stdout.trim()) {
                resolvedBase = remoteCandidate;
            }
            else if (requestedBase) {
                baseWarning =
                    "WARNING: Requested base is local and may be stale; prefer " +
                        `origin/${requestedBase}`;
            }
        }
        baseSha = git.revParse(resolvedBase);
        headRefResolved = headRef || branchName;
        headSha = git.revParse(headRefResolved || "HEAD");
        mergeBase = git.mergeBase(baseSha, headSha);
        revRange = `${mergeBase}..${headSha}`;
        const oneline = git.log("--pretty=format:%h %ad %an %s", revRange);
        const subjects = git.log("--pretty=%s", revRange);
        const authors = git.log("--format=%an <%ae>", revRange);
        const authorsList = sortedSet(splitLines(authors)
            .map((line) => line.trim())
            .filter((line) => line));
        const nameStatus = git.diffRange(["--name-status", mergeBase, headSha]);
        const numstat = git.diffRange(["--numstat", mergeBase, headSha]);
        const shortstat = git.diffRange(["--shortstat", mergeBase, headSha]);
        const stat = git.diffRange(["--stat", mergeBase, headSha]);
        const [additions, deletions, files] = (0, render_pr_helpers_1.convertNumstat)(numstat);
        const extSummary = (0, render_pr_helpers_1.extensionSummary)(files);
        const mergePrs = (0, render_pr_helpers_1.extractMergePrNumbers)(splitLines(oneline));
        const issueCandidates = (0, render_pr_helpers_1.extractIssueReferences)(oneline + "\n" + subjects).filter((ref) => !mergePrs.includes(ref));
        const issues = [];
        const prs = [];
        // Classify each candidate reference, falling back to "issue" when gh is
        // unavailable so references are still surfaced.
        for (const ref of issueCandidates) {
            const numberRef = (0, models_1.normalizeReference)(ref);
            const entity = ghAvailable ? gh.classifyEntity(numberRef) : null;
            const formattedRef = ref.startsWith("#") ? ref : `#${ref}`;
            if (entity === "issue") {
                issues.push(formattedRef);
            }
            else if (entity === "pull") {
                prs.push(formattedRef);
            }
            else if (ghAvailable) {
                invalidReferences.push(formattedRef);
            }
            else {
                issues.push(formattedRef);
            }
        }
        referencedIssues = sortedSet(issues);
        referencedPrs = sortedSet([...prs, ...mergePrs]);
        let issuesDisplay = sortedSet([
            ...referencedIssues,
            ...featureIssueList,
        ]).join(", ");
        if (!issuesDisplay) {
            issuesDisplay = "(none)";
        }
        const prsDisplay = referencedPrs.length > 0 ? referencedPrs.join(", ") : "(none)";
        const onelineDisplay = oneline.trim() ? oneline : "(none)";
        const authorsDisplay = authorsList.length > 0 ? authorsList.join("\n") : "(none)";
        const nameStatusDisplay = nameStatus.trim() ? nameStatus : "(none)";
        const shortDisplay = shortstat.trim() ? shortstat : "(none)";
        const extDisplay = extSummary ? extSummary : "(none)";
        const statDisplay = stat.trim() ? stat : "(none)";
        const blockLines = [
            (0, models_1.section)("PR Comparison"),
            `Base ref (requested): ${requestedBase || "(default)"}`,
            `Base ref (resolved): ${resolvedBase} @ ${baseSha}`,
            `Head ref (resolved): ${headRefResolved} @ ${headSha}`,
            `Merge-base: ${mergeBase}`,
        ];
        if (baseWarning) {
            blockLines.push(`Base warning: ${baseWarning}`);
        }
        blockLines.push(`Range: ${revRange}\n`, (0, models_1.section)("Commits in range"), onelineDisplay, "", (0, models_1.section)("Conventional commit type summary"), (0, render_pr_helpers_1.summarizeConventionalCommits)(subjects), "", (0, models_1.section)("Authors"), authorsDisplay, "", (0, models_1.section)("Changed files (name-status)"), nameStatusDisplay, "", (0, models_1.section)("Diff shortstat"), shortDisplay, "", (0, models_1.section)("Additions/Deletions totals (from numstat)"), `Additions: ${additions}\nDeletions: ${deletions}\n`, (0, models_1.section)("Files by extension"), extDisplay, "", (0, models_1.section)("Referenced issues (detected)"), issuesDisplay, "", (0, models_1.section)("PRs in range"), prsDisplay, "", (0, models_1.section)("Diff stat"), statDisplay);
        prBlock = blockLines.join("\n");
    }
    catch (exc) {
        // On any failure, emit the failure block and reset all derived fields,
        // matching the Python catch-all.
        prBlock =
            (0, models_1.section)("PR Comparison") +
                `(FAILED to compute PR context: ${errorMessage(exc)})\n`;
        referencedIssues = [];
        referencedPrs = [];
        verifiedClosing = [];
        invalidReferences = [];
        resolvedBase = null;
        baseSha = null;
        headSha = null;
        headRefResolved = headRef || branchName;
        mergeBase = null;
        revRange = null;
    }
    const intent = [
        (0, models_1.section)("PR Intent (edit before generating PR body)"),
        "Primary outcome:",
        "Impact (user/developer):",
        "Risks:",
        "Author-asserted autoclose issues:",
    ].join("\n");
    const combinedText = [
        intent,
        (0, models_1.section)("Repository remotes"),
        remotes,
        "",
        (0, models_1.section)("Current branch"),
        branchName,
        "",
        (0, models_1.section)("Upstream"),
        upstream,
        "",
        (0, models_1.section)("Status (short)"),
        statusShort,
        "",
        (0, models_1.section)("Untracked files"),
        untrackedDisplay,
        "",
        (0, models_1.section)("Working tree diff (staged)"),
        git.diffNameStatus({ staged: true }),
        git.diffPatch({ staged: true }),
        "",
        (0, models_1.section)("Working tree diff (unstaged)"),
        git.diffNameStatus({ staged: false }),
        git.diffPatch({ staged: false }),
        prBlock,
    ].join("\n");
    return {
        text: combinedText,
        referencedIssues,
        referencedPrs,
        verifiedClosing: sortedSet(verifiedClosing),
        invalidReferences: sortedSet(invalidReferences),
        baseRef,
        resolvedBase,
        baseSha,
        headRef: headRefResolved,
        headSha,
        mergeBase,
        revRange,
        ghAvailable,
    };
}
/** Extract a message from a thrown value, matching Python `str(exc)`. */
function errorMessage(exc) {
    return exc instanceof Error ? exc.message : String(exc);
}
/** Sort a deduplicated set of strings by Unicode code point. */
function sortedSet(values) {
    return [...new Set(values)].sort(compareCodePoint);
}
/** Compare two strings by Unicode code point (Python `sorted` semantics). */
function compareCodePoint(left, right) {
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
function splitLines(value) {
    if (value === "") {
        return [];
    }
    const lines = value.split(/\r\n|\r|\n/u);
    if (lines.length > 0 &&
        lines[lines.length - 1] === "" &&
        /(\r\n|\r|\n)$/u.test(value)) {
        lines.pop();
    }
    return lines;
}
