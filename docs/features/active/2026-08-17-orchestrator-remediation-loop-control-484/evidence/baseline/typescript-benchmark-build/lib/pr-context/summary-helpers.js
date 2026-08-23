"use strict";
/**
 * Helper routines for PR context rendering and summarization.
 *
 * Purpose:
 *     Port of the numstat/name-status/scoping/bucket/section/timestamp portion
 *     of `dev_tools/pr_context/summary_helpers.py`. The digest/appendix
 *     renderers live in `summary-digests.ts` to keep each file under 500 lines.
 *
 * Responsibilities:
 *     - `parseNumstatDetailed`, `parseNameStatusMap`.
 *     - `isScopingDoc`, `scopingDocChanges` (materiality rules).
 *     - `bucketText`, `parseSection`, `formatDiffPath` (delegate), and
 *       `appendGenerationTimestamp` (injected clock).
 *     - Re-export the digest/appendix renderers.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.prDigest = exports.prAppendix = exports.lastWithTruncation = exports.issueDigest = exports.issueAppendix = exports.extractDigestBullets = void 0;
exports.parseNumstatDetailed = parseNumstatDetailed;
exports.parseNameStatusMap = parseNameStatusMap;
exports.isScopingDoc = isScopingDoc;
exports.scopingDocChanges = scopingDocChanges;
exports.bucketText = bucketText;
exports.parseSection = parseSection;
exports.formatDiffPath = formatDiffPath;
exports.appendGenerationTimestamp = appendGenerationTimestamp;
const models_1 = require("./models");
const render_pr_helpers_1 = require("./render-pr-helpers");
// Re-export digest/appendix renderers so consumers import from one module.
var summary_digests_1 = require("./summary-digests");
Object.defineProperty(exports, "extractDigestBullets", { enumerable: true, get: function () { return summary_digests_1.extractDigestBullets; } });
Object.defineProperty(exports, "issueAppendix", { enumerable: true, get: function () { return summary_digests_1.issueAppendix; } });
Object.defineProperty(exports, "issueDigest", { enumerable: true, get: function () { return summary_digests_1.issueDigest; } });
Object.defineProperty(exports, "lastWithTruncation", { enumerable: true, get: function () { return summary_digests_1.lastWithTruncation; } });
Object.defineProperty(exports, "prAppendix", { enumerable: true, get: function () { return summary_digests_1.prAppendix; } });
Object.defineProperty(exports, "prDigest", { enumerable: true, get: function () { return summary_digests_1.prDigest; } });
/** Scoping-doc heading prefixes that mark a material key-section change. */
const KEY_SECTION_PREFIXES = [
    "## Context",
    "## Root Cause",
    "## Proposed Fix",
    "## Acceptance Criteria",
    "## Test Strategy",
    "## Risks",
];
/** Excerpt headings rendered for a material scoping-doc change, in order. */
const SCOPING_EXCERPT_HEADINGS = [
    "Acceptance Criteria",
    "Root Cause",
    "Proposed Fix",
    "Test Strategy",
];
/**
 * Parse numstat into totals and a per-file add/del map.
 *
 * Mirrors Python `parse_numstat_detailed`.
 *
 * @param numstatText Raw `git diff --numstat` output.
 * @returns A tuple of `[addsTotal, delsTotal, perFileMap]`.
 */
function parseNumstatDetailed(numstatText) {
    let addsTotal = 0;
    let delsTotal = 0;
    const perFile = new Map();
    // Parse each non-blank row, accumulating totals and per-file counts.
    for (const rawLine of (0, models_1.splitLines)(numstatText)) {
        if (!rawLine.trim()) {
            continue;
        }
        const parts = rawLine.split("\t");
        if (parts.length < 3) {
            continue;
        }
        const [addPart, delPart, filePart] = [parts[0], parts[1], parts[2]];
        const addCount = isDigits(addPart) ? Number.parseInt(addPart, 10) : 0;
        const delCount = isDigits(delPart) ? Number.parseInt(delPart, 10) : 0;
        addsTotal += addCount;
        delsTotal += delCount;
        perFile.set(formatDiffPath(filePart), [addCount, delCount]);
    }
    return [addsTotal, delsTotal, perFile];
}
/**
 * Parse name-status output into a path -> status map.
 *
 * Mirrors Python `parse_name_status_map`.
 *
 * @param nameStatusText Raw `git diff --name-status` output.
 * @returns A map of normalized path to status code.
 */
function parseNameStatusMap(nameStatusText) {
    const mapping = new Map();
    // Parse each non-blank row into a status and its (normalized) final path.
    for (const rawLine of (0, models_1.splitLines)(nameStatusText)) {
        if (!rawLine.trim()) {
            continue;
        }
        const parts = rawLine.split("\t");
        if (parts.length < 2) {
            continue;
        }
        const status = parts[0].trim();
        const path = formatDiffPath(parts[parts.length - 1].trim());
        mapping.set(path, status);
    }
    return mapping;
}
/**
 * Return whether a path is a scoping document.
 *
 * Mirrors Python `is_scoping_doc`.
 *
 * @param path Repo-relative path.
 * @returns True when the path is a recognized scoping doc.
 */
function isScopingDoc(path) {
    const lowered = path.toLowerCase();
    return (lowered.startsWith("docs/features/") &&
        (lowered.endsWith("/spec.md") ||
            lowered.endsWith("/plan.md") ||
            lowered.endsWith("/bug-remediation-plan.md") ||
            lowered.endsWith("/user-story.md") ||
            lowered.endsWith("/readme.md")));
}
/**
 * Compute scoping-doc changes and their materiality.
 *
 * Mirrors Python `scoping_doc_changes`: a change is material when it is a new
 * doc, when `additions + deletions >= 15`, or when a key section heading is
 * touched; link/whitespace-only additions demote a change to non-material when
 * no heading is touched, fewer than 15 lines changed, and it is not an add. A
 * material change's excerpt is read from the doc through the injected FS.
 *
 * @param options Git/fs clients, range, root, and parsed diff inputs.
 * @returns The per-doc scoping change records.
 */
function scopingDocChanges(options) {
    const { git, fs, mergeBase, headSha, root, nameStatusText, numstatDetails } = options;
    if (!mergeBase || !headSha) {
        return [];
    }
    const changes = [];
    const nameStatusMap = parseNameStatusMap(nameStatusText);
    // Evaluate each changed path that is a scoping doc for materiality.
    for (const [path, status] of nameStatusMap) {
        if (!isScopingDoc(path)) {
            continue;
        }
        const [additions, deletions] = numstatDetails.get(path) ?? [0, 0];
        const reasons = [];
        let material = false;
        if (status.startsWith("A")) {
            material = true;
            reasons.push("new scoping doc");
        }
        if (additions + deletions >= 15) {
            material = true;
            reasons.push(">=15 lines changed");
        }
        const diffText = git.diffRange([
            "--unified=0",
            mergeBase,
            headSha,
            "--",
            path,
        ]);
        let headingTouched = false;
        // Scan added lines for a touched key-section heading.
        for (const line of (0, models_1.splitLines)(diffText)) {
            if (!line.startsWith("+") || line.startsWith("+++")) {
                continue;
            }
            const stripped = line.replace(/^\++/u, "").trim();
            if (KEY_SECTION_PREFIXES.some((prefix) => stripped.toLowerCase().startsWith(prefix.toLowerCase()))) {
                headingTouched = true;
                break;
            }
        }
        if (headingTouched) {
            material = true;
            reasons.push("key section touched");
        }
        const addedLines = (0, models_1.splitLines)(diffText)
            .filter((line) => line.startsWith("+") && !line.startsWith("+++"))
            .map((line) => line.replace(/^\++/u, "").trim());
        if (addedLines.length > 0 &&
            addedLines.every((line) => !line || line.startsWith("[") || line.startsWith("http"))) {
            reasons.push("link/whitespace-only changes");
            if (!headingTouched &&
                additions + deletions < 15 &&
                !status.startsWith("A")) {
                material = false;
            }
        }
        let excerpt = null;
        const docPath = `${stripTrailingSlash(root)}/${path}`;
        if (material && fs.exists(docPath)) {
            const content = fs.readTextFile(docPath);
            const excerptParts = [];
            for (const heading of SCOPING_EXCERPT_HEADINGS) {
                const sectionText = parseSection(content, heading);
                if (sectionText) {
                    excerptParts.push(`${heading}:\n${(0, models_1.truncateLines)(sectionText, 40)}`);
                }
            }
            excerpt =
                excerptParts.length > 0 ? excerptParts.slice(0, 3).join("\n\n") : null;
        }
        changes.push({
            path,
            additions,
            deletions,
            changeType: status,
            material,
            reasons,
            excerpt,
        });
    }
    return changes;
}
/**
 * Render a churn-sorted bucket summary (top 10).
 *
 * Mirrors Python `bucket_text`.
 *
 * @param name Bucket label.
 * @param entries `[path, [adds, dels]]` entries.
 * @returns The formatted bucket text.
 */
function bucketText(name, entries) {
    if (entries.length === 0) {
        return `${name}: 0 files`;
    }
    const sortedEntries = [...entries].sort((left, right) => right[1][0] + right[1][1] - (left[1][0] + left[1][1]));
    const lines = [
        `${name}: ${entries.length} files`,
        ...sortedEntries
            .slice(0, 10)
            .map(([path, [adds, dels]]) => `- ${path} (+${adds}/-${dels})`),
    ];
    return lines.join("\n");
}
/**
 * Extract markdown content under a top-level `##` heading.
 *
 * Mirrors Python `parse_section` (summary_helpers copy).
 *
 * @param markdown Markdown content.
 * @param heading Heading to match.
 * @returns The trimmed section body, or `""`.
 */
function parseSection(markdown, heading) {
    const escaped = heading.replace(/[.*+?^${}()|[\]\\]/gu, "\\$&");
    const pattern = new RegExp(`^##\\s+${escaped}\\s*\\r?\\n([\\s\\S]*?)(?=^##\\s+|$(?![\\s\\S]))`, "m");
    const match = pattern.exec(markdown);
    if (!match) {
        return "";
    }
    return match[1].trim();
}
/**
 * Normalize a git diff path (delegates to render-pr-helpers).
 *
 * Mirrors Python `summary_helpers.format_diff_path`, which delegates to
 * `render.format_diff_path` to avoid the source's circular-import shim.
 *
 * @param pathText Raw diff path text.
 * @returns The normalized path.
 */
function formatDiffPath(pathText) {
    return pathText !== null ? (0, render_pr_helpers_1.formatDiffPath)(pathText) : "";
}
/**
 * Generate a timestamp section showing when context was collected.
 *
 * Mirrors Python `append_generation_timestamp`: format the current UTC time as
 * `%Y-%m-%d %H:%M:%S %Z` (with `%Z` rendered as `UTC`). The clock is injected
 * (`() => Date`, defaulting to the real clock) so wall-clock reads do not occur
 * directly, per the TypeScript determinism rule.
 *
 * @param clock Clock returning the current `Date` (defaults to `() => new Date()`).
 * @returns The formatted timestamp section.
 */
function appendGenerationTimestamp(clock = () => new Date()) {
    const now = clock();
    const timestamp = formatUtcTimestamp(now);
    return (0, models_1.section)("Context generated") + "\n" + timestamp + "\n";
}
/** Format a Date as `YYYY-MM-DD HH:MM:SS UTC` (Python `%Y-%m-%d %H:%M:%S %Z`). */
function formatUtcTimestamp(date) {
    const year = date.getUTCFullYear().toString().padStart(4, "0");
    const month = (date.getUTCMonth() + 1).toString().padStart(2, "0");
    const day = date.getUTCDate().toString().padStart(2, "0");
    const hours = date.getUTCHours().toString().padStart(2, "0");
    const minutes = date.getUTCMinutes().toString().padStart(2, "0");
    const seconds = date.getUTCSeconds().toString().padStart(2, "0");
    return `${year}-${month}-${day} ${hours}:${minutes}:${seconds} UTC`;
}
/** Strip a single trailing slash for path joining. */
function stripTrailingSlash(value) {
    return value.replace(/\/+$/u, "");
}
/** Test whether a string is a non-empty run of ASCII digits (Python isdigit). */
function isDigits(value) {
    return value.length > 0 && /^\d+$/u.test(value);
}
