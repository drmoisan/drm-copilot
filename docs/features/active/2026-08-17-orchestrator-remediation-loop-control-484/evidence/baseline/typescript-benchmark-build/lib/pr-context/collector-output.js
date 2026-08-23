"use strict";
/**
 * Rendering/write half of the PR context collector.
 *
 * Purpose:
 *     Port of the rendering/write half of
 *     `dev_tools/pr_context/collector.py` `collect_and_write`. Build the summary
 *     and appendix text verbatim (section ordering, placeholders, budget
 *     truncation, verification-evidence rows), write both files through the
 *     injected {@link FileSystem}, and emit the two `Wrote context ...` log lines.
 *
 * Responsibilities:
 *     - `renderVerificationEvidenceSection`.
 *     - `buildSummaryText` / `buildAppendixText`.
 *     - `writeOutput` (with append semantics) and `collectAndWrite`.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.renderVerificationEvidenceSection = renderVerificationEvidenceSection;
exports.buildSummaryText = buildSummaryText;
exports.buildAppendixText = buildAppendixText;
exports.writeOutput = writeOutput;
exports.collectAndWrite = collectAndWrite;
const file_system_1 = require("../file-system");
const models_1 = require("./models");
const collector_core_1 = require("./collector-core");
const summary_helpers_1 = require("./summary-helpers");
const summary_digests_1 = require("./summary-digests");
const render_pr_helpers_1 = require("./render-pr-helpers");
const verification_evidence_1 = require("./verification-evidence");
/**
 * Render canonical verification evidence rows for the summary.
 *
 * Mirrors Python `_render_verification_evidence_section`: parse only the
 * context files whose normalized path contains `/evidence/`, tolerate read
 * failures, keep pass/fail records, and render deterministic rows sorted by
 * source — or the fallback `No canonical verification evidence parsed`.
 *
 * @param fs Injected filesystem.
 * @param resolvedRoot Repository root used to read evidence files.
 * @param featureDocs Feature excerpts whose context files may include evidence.
 * @returns The formatted evidence section body.
 */
function renderVerificationEvidenceSection(fs, resolvedRoot, featureDocs) {
    const records = [];
    // Parse only canonical evidence files already enumerated in context files.
    for (const doc of featureDocs) {
        for (const rawPath of doc.contextFiles) {
            const normalized = (0, file_system_1.toPosixPath)(rawPath);
            if (!normalized.includes("/evidence/")) {
                continue;
            }
            try {
                records.push((0, verification_evidence_1.parseVerificationEvidenceFile)({
                    fs,
                    root: resolvedRoot,
                    feature: doc.feature,
                    relativePath: normalized,
                }));
            }
            catch {
                // Tolerate unreadable artifacts, matching the Python OSError catch.
                continue;
            }
        }
    }
    const parseableRecords = records.filter((item) => item.normalizedResult === "pass" || item.normalizedResult === "fail");
    if (parseableRecords.length === 0) {
        return "No canonical verification evidence parsed";
    }
    const lines = [];
    // Render deterministic rows sorted by source path for stable artifacts.
    const sorted = [...parseableRecords].sort((left, right) => left.sourceFile < right.sourceFile
        ? -1
        : left.sourceFile > right.sourceFile
            ? 1
            : 0);
    for (const record of sorted) {
        lines.push(`- Feature: ${record.feature}`, `  - Source: ${record.sourceFile}`, `  - Timestamp: ${record.timestamp}`, `  - Command: ${record.command}`, `  - EXIT_CODE: ${record.exitCode}`, `  - Normalized result: ${record.normalizedResult}`);
    }
    return lines.join("\n");
}
/**
 * Build the summary text from a collected record.
 *
 * Mirrors the Python summary-sections assembly verbatim, including the
 * stale-base WARNING, the autoclose/close-candidates/additional-context/
 * feature-doc/referenced/PR/invalid/scoping/changed-files/digests/
 * verification-evidence/CI/appendix-pointer ordering, and the
 * `SUMMARY_CHAR_BUDGET` truncation suffix.
 *
 * @param collected The intermediate record.
 * @param fs Injected filesystem (for evidence reads).
 * @param appendixPath The appendix path referenced by the pointer section.
 * @returns The (possibly truncated) summary text.
 */
function buildSummaryText(collected, fs, appendixPath) {
    const ctx = collected.contextResult;
    const ghStatusText = resolveGhStatusText(collected);
    const intentBlock = [
        (0, models_1.section)("PR Intent"),
        "Primary outcome:",
        "User/dev impact:",
        "Risks:",
        "Author-asserted autoclose issues:",
    ].join("\n");
    const summarySections = [
        (0, models_1.section)("GitHub CLI status"),
        ghStatusText,
        intentBlock,
        (0, models_1.section)("Base/Head"),
        `Base ref (requested): ${ctx.baseRef ?? "(default)"}`,
        `Base ref (resolved): ${ctx.resolvedBase ?? "(unknown)"} @ ${ctx.baseSha ?? "(unknown)"}`,
        `Head ref (resolved): ${ctx.headRef ?? collected.head ?? "(unknown)"} @ ${ctx.headSha ?? "(unknown)"}`,
        `Merge base: ${ctx.mergeBase ?? "(unknown)"}`,
        `Range: ${ctx.revRange ?? "(unknown)"}`,
    ];
    // Emit the stale-base WARNING when a requested local base did not resolve to
    // an origin/ ref.
    if (ctx.baseRef &&
        ctx.resolvedBase &&
        !ctx.resolvedBase.startsWith("origin/")) {
        summarySections.push("WARNING: Requested base is local and may be stale; prefer " +
            `origin/${ctx.baseRef}`);
    }
    const issueDigests = collected.issueDetails
        .map((detail) => (0, summary_digests_1.issueDigest)(detail))
        .join("\n\n");
    const prDigests = collected.prDetailsList
        .map((detail) => (0, summary_digests_1.prDigest)(detail))
        .join("\n\n");
    const featureSummary = buildFeatureSummary(collected.featureDocs);
    const verificationEvidenceSection = renderVerificationEvidenceSection(fs, collected.resolvedRoot, collected.featureDocs);
    const closeCandidates = buildCloseCandidatesSectionFromCollected(collected);
    const scopingSummary = buildScopingSummaryLines(collected).join("\n");
    summarySections.push("", collected.issuesToAutocloseSection, "", closeCandidates, "", (0, models_1.section)("Additional context files"), (0, models_1.formatList)(collected.additionalContextFiles, "(none)"), "", (0, models_1.section)("Feature doc excerpts"), featureSummary, "", (0, models_1.section)("Referenced issues (classified)"), (0, models_1.formatList)(collected.referencedIssues, "(none)") +
        (!collected.ghAvailable ? "\nNOTE: Unverified (GitHub unavailable)" : ""), "", (0, models_1.section)("PRs in range (classified)"), (0, models_1.formatList)(collected.referencedPrs, "(none)"), "", (0, models_1.section)("Invalid references (not found)"), (0, models_1.formatList)(collected.invalidRefs, "(none)"), "", (0, models_1.section)("Scoping docs changed"), scopingSummary, "", (0, models_1.section)("Changed files overview"), (0, summary_helpers_1.bucketText)("Core logic changes", collected.bucketCore), "", (0, summary_helpers_1.bucketText)("Mechanical moves/renames", collected.bucketRenames), "", (0, summary_helpers_1.bucketText)("Docs/templates/agents/tooling", collected.bucketDocs), "", (0, models_1.section)("Issue digests"), issueDigests || "(none)", "", (0, models_1.section)("PR digests"), prDigests || "(none)", "", (0, models_1.section)("Verification evidence (feature docs + canonical artifacts)"), verificationEvidenceSection, "", (0, models_1.section)("CI status (HEAD)"), renderCiStatus(collected), "", (0, models_1.section)("Appendix pointer"), `See ${appendixPath}`);
    let summaryText = summarySections.join("\n");
    if (summaryText.length > collector_core_1.SUMMARY_CHAR_BUDGET) {
        summaryText =
            summaryText.slice(0, collector_core_1.SUMMARY_CHAR_BUDGET) +
                "\nTRUNCATED: summary budget exceeded";
    }
    return summaryText;
}
/**
 * Build the appendix text from a collected record.
 *
 * Mirrors the Python appendix assembly: timestamp + context text + issue/PR
 * appendix sections + the optional feature block, with the
 * `APPENDIX_CHAR_BUDGET` truncation suffix.
 *
 * @param collected The intermediate record.
 * @param clock Clock injected into the timestamp helper.
 * @returns The (possibly truncated) appendix text.
 */
function buildAppendixText(collected, clock) {
    const featureBlock = collected.featureDocs
        .map((doc) => doc.excerpt)
        .join("\n");
    const issueSections = collected.issueDetails.map((detail) => (0, summary_digests_1.issueAppendix)(detail));
    const prSections = collected.prDetailsList.map((detail) => (0, summary_digests_1.prAppendix)(detail));
    const appendixParts = [
        (0, summary_helpers_1.appendGenerationTimestamp)(clock),
        collected.contextResult.text,
        "",
        (0, models_1.section)("Issue details"),
        issueSections.length > 0 ? issueSections.join("\n\n") : "(none)",
        "",
        (0, models_1.section)("Contributing pull requests"),
        prSections.length > 0 ? prSections.join("\n\n") : "(none)",
    ];
    if (featureBlock) {
        appendixParts.push("", featureBlock);
    }
    let appendixText = appendixParts.join("\n");
    if (appendixText.length > collector_core_1.APPENDIX_CHAR_BUDGET) {
        appendixText =
            appendixText.slice(0, collector_core_1.APPENDIX_CHAR_BUDGET) +
                "\nTRUNCATED: appendix budget exceeded";
    }
    return appendixText;
}
/**
 * Write `text` to `outPath` through the injected filesystem.
 *
 * Mirrors Python `write_output`: ensure the parent directory exists, then write
 * (overwrite) or append. The F1 filesystem has no append primitive, so append
 * mode reads the existing content (when present) and concatenates, replicating
 * Python `mode="a"` exactly.
 *
 * @param fs Injected filesystem.
 * @param text Content to write.
 * @param outPath Output path.
 * @param append When true, concatenate to existing content.
 */
function writeOutput(fs, text, outPath, append) {
    const parent = parentDir(outPath);
    if (parent) {
        fs.ensureDir(parent);
    }
    if (append && fs.isFile(outPath)) {
        const existing = fs.readTextFile(outPath);
        fs.writeTextFile(outPath, existing + text);
    }
    else {
        fs.writeTextFile(outPath, text);
    }
}
/**
 * Run the collector and write both output files.
 *
 * Calls {@link collectPrContext}, builds the summary and appendix text, writes
 * both files through the injected filesystem, and emits the two
 * `Wrote context ...` log lines through the injected sink (matching the Python
 * `print` statements).
 *
 * @param options Collector options plus output paths, append flag, and log sink.
 */
function collectAndWrite(options) {
    const clock = options.clock ?? (() => new Date());
    const collected = (0, collector_core_1.collectPrContext)(options);
    const summaryText = buildSummaryText(collected, options.fs, options.appendixOut);
    const appendixText = buildAppendixText(collected, clock);
    writeOutput(options.fs, summaryText, options.out, options.append);
    writeOutput(options.fs, appendixText, options.appendixOut, options.append);
    const log = options.log ?? (() => undefined);
    log(`Wrote context summary to: ${options.out}`);
    log(`Wrote context appendix to: ${options.appendixOut}`);
}
/** Resolve the GitHub CLI status text shown in the summary. */
function resolveGhStatusText(collected) {
    let ghStatusText = collected.ghStatusOverride ||
        collected.ghStatusMessage ||
        "GitHub CLI authenticated.";
    if (!collected.ghAvailable && !collected.ghStatusOverride) {
        ghStatusText = "GitHub CLI unavailable; references unverified.";
    }
    return ghStatusText;
}
/** Build the feature-doc excerpt summary block, or `(none)`. */
function buildFeatureSummary(featureDocs) {
    const lines = [];
    for (const doc of featureDocs) {
        lines.push(`Feature: ${doc.feature}`, "Excerpt:", (0, models_1.truncateLines)(doc.excerpt, 80), "Context files:", (0, models_1.formatList)(doc.contextFiles, "(none)"), "");
    }
    return lines.length > 0 ? lines.join("\n").replace(/\s+$/u, "") : "(none)";
}
/** Build the scoping-docs summary lines (material then non-material). */
function buildScopingSummaryLines(collected) {
    const lines = [];
    if (collected.materialScoping.length > 0) {
        lines.push("Scoping docs changed (material):");
        for (const { path, reasons, excerpt } of collected.materialScoping) {
            const reasonText = `Reasons: ${reasons.length > 0 ? reasons.join(", ") : "(unspecified)"}`;
            lines.push(`- ${path} (${reasonText})`);
            if (excerpt) {
                lines.push((0, models_1.truncateLines)(excerpt, 40));
            }
        }
    }
    if (collected.nonMaterialScoping.length > 0) {
        lines.push("Scoping docs changed (non-material):");
        for (const { path, reasons } of collected.nonMaterialScoping.slice(0, 5)) {
            const reasonText = `Reasons: ${reasons.length > 0 ? reasons.join(", ") : "(unspecified)"}`;
            lines.push(`- ${path} (${reasonText})`);
        }
    }
    if (lines.length === 0) {
        lines.push("(none)");
    }
    return lines;
}
/** Render the CI-status section body. */
function renderCiStatus(collected) {
    if (!collected.ciStatus) {
        return "(not available)";
    }
    return (`Status: ${collected.ciStatus}\n` +
        (collected.ciJobs.length > 0
            ? `Failing jobs: ${collected.ciJobs.join(", ")}`
            : ""));
}
/** Build the close-candidates section from the collected reasons/refs. */
function buildCloseCandidatesSectionFromCollected(collected) {
    // Reuse the shared builder; verified/author/referenced and the reason strings
    // come straight from the collected record.
    return (0, render_pr_helpers_1.buildCloseCandidatesSection)({
        verified: collected.verified,
        authorAsserted: collected.authorAsserted,
        referenced: collected.referencedIssues,
        verifiedReason: collected.verifiedReason,
        authorReason: collected.authorReason,
    });
}
/** Return the parent directory of a path (POSIX), or `""` when none. */
function parentDir(path) {
    const normalized = (0, file_system_1.toPosixPath)(path);
    const index = normalized.lastIndexOf("/");
    return index <= 0 ? "" : normalized.slice(0, index);
}
