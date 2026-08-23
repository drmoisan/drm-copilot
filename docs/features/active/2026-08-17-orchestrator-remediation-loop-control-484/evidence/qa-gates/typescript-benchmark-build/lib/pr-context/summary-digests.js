"use strict";
/**
 * Digest and appendix renderers for PR context summarization.
 *
 * Purpose:
 *     Port of the digest/appendix portion of
 *     `dev_tools/pr_context/summary_helpers.py`. Extracted from
 *     `summary-helpers.ts` so each file stays under 500 lines.
 *
 * Responsibilities:
 *     - `lastWithTruncation`, `extractDigestBullets`.
 *     - `issueDigest`, `prDigest`, `issueAppendix`, `prAppendix`.
 *     Pure functions sharing `parseSection` from `summary-helpers.ts`.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.lastWithTruncation = lastWithTruncation;
exports.extractDigestBullets = extractDigestBullets;
exports.issueDigest = issueDigest;
exports.prDigest = prDigest;
exports.issueAppendix = issueAppendix;
exports.prAppendix = prAppendix;
const models_1 = require("./models");
const summary_helpers_1 = require("./summary-helpers");
/** Headings scanned for digest bullets, in fixed order. */
const DIGEST_HEADINGS = [
    "Why",
    "Context",
    "Root Cause",
    "Constraints",
    "Acceptance Criteria",
    "Test Strategy",
    "Risks",
    "Verification",
    "Follow-ups",
];
/**
 * Return the last `limit` items and whether truncation occurred.
 *
 * Mirrors Python `last_with_truncation`.
 *
 * @param items Source items.
 * @param limit Maximum retained from the end.
 * @returns A tuple of `[selectedItems, truncated]`.
 */
function lastWithTruncation(items, limit) {
    if (items.length <= limit) {
        return [items, false];
    }
    return [items.slice(items.length - limit), true];
}
/**
 * Extract up to `limit` digest bullets from a body's headings.
 *
 * Mirrors Python `extract_digest_bullets`: for each heading, strip leading
 * `-`/`*` from each non-blank section line and prefix with `<heading>: `.
 *
 * @param body Body markdown.
 * @param headings Headings to scan.
 * @param limit Maximum bullets returned.
 * @returns The collected bullets (capped at `limit`).
 */
function extractDigestBullets(body, headings, limit) {
    const bullets = [];
    // Scan each heading's section, collecting cleaned bullet lines up to the cap.
    for (const heading of headings) {
        const sectionText = (0, summary_helpers_1.parseSection)(body, heading);
        if (!sectionText) {
            continue;
        }
        for (const line of (0, models_1.splitLines)(sectionText)) {
            if (!line.trim()) {
                continue;
            }
            const cleaned = line.replace(/^[-*]+/u, "").trim();
            bullets.push(`${heading}: ${cleaned}`);
            if (bullets.length >= limit) {
                return bullets;
            }
        }
    }
    return bullets.slice(0, limit);
}
/**
 * Render the issue digest block.
 *
 * Mirrors Python `issue_digest`.
 *
 * @param issue Issue details.
 * @returns The formatted digest text.
 */
function issueDigest(issue) {
    const bullets = extractDigestBullets(issue.body, DIGEST_HEADINGS, 8);
    if (bullets.length === 0) {
        bullets.push(`State: ${issue.state}`);
        if (issue.labels.length > 0) {
            bullets.push(`Labels: ${issue.labels.join(", ")}`);
        }
    }
    const [selectedComments, truncated] = lastWithTruncation(issue.comments, 3);
    let commentBlock = selectedComments.length > 0
        ? selectedComments.map((comment) => `- ${comment}`).join("\n")
        : "(no comments)";
    if (truncated) {
        commentBlock += "\nTRUNCATED: last 3 comments shown";
    }
    const metadata = [
        `Identifier: ${issue.number}`,
        `Title: ${issue.title}`,
        `Author: ${issue.author}`,
        `Assignees: ${issue.assignees.length > 0 ? issue.assignees.join(", ") : "(none)"}`,
        `Labels: ${issue.labels.length > 0 ? issue.labels.join(", ") : "(none)"}`,
        `State: ${issue.state}`,
        `Last updated: ${issue.updatedAt}`,
    ];
    return [
        metadata.join("\n"),
        "Key bullets:",
        bullets.map((entry) => `- ${entry}`).join("\n"),
        "",
        "Recent comments:",
        commentBlock,
    ].join("\n");
}
/**
 * Render the PR digest block.
 *
 * Mirrors Python `pr_digest`.
 *
 * @param pr Pull request details.
 * @returns The formatted digest text.
 */
function prDigest(pr) {
    const bullets = extractDigestBullets(pr.body, DIGEST_HEADINGS, 8);
    if (bullets.length === 0) {
        if (pr.filesChanged.length > 0) {
            bullets.push(`Touches files: ${pr.filesChanged.slice(0, 3).join(", ")}` +
                (pr.filesChanged.length > 3 ? " ..." : ""));
        }
        bullets.push(`State: ${pr.state}`);
    }
    const metadata = [
        `Identifier: ${pr.number}`,
        `Title: ${pr.title}`,
        `Author: ${pr.author}`,
        `Base/Head: ${pr.baseRef} <- ${pr.headRef}`,
        `Last updated: ${pr.updatedAt}`,
    ];
    return [
        metadata.join("\n"),
        "Key bullets:",
        bullets.map((entry) => `- ${entry}`).join("\n"),
    ].join("\n");
}
/**
 * Render the issue appendix block.
 *
 * Mirrors Python `issue_appendix`: body truncated to 120 lines, last 10
 * comments, and an optional user-story block.
 *
 * @param issue Issue details.
 * @returns The formatted appendix text.
 */
function issueAppendix(issue) {
    const bodyText = (0, models_1.truncateLines)(issue.body, 120);
    const [comments, truncated] = lastWithTruncation(issue.comments, 10);
    let commentText = comments.length > 0
        ? comments.map((c) => `- ${c}`).join("\n")
        : "(no comments)";
    if (truncated) {
        commentText += "\nTRUNCATED: last 10 comments shown";
    }
    let userStoryBlock = "";
    if (issue.userStoryContent) {
        userStoryBlock = [
            "",
            `User story (${issue.userStoryPath ?? "user-story.md"}):`,
            (0, models_1.truncateLines)(issue.userStoryContent, 120),
        ].join("\n");
    }
    return [
        (0, models_1.section)(`Issue ${issue.number}: ${issue.title}`),
        `State: ${issue.state}`,
        `Labels: ${issue.labels.length > 0 ? issue.labels.join(", ") : "(none)"}`,
        `Assignees: ${issue.assignees.length > 0 ? issue.assignees.join(", ") : "(none)"}`,
        `Author: ${issue.author}`,
        `Created: ${issue.createdAt}`,
        `Updated: ${issue.updatedAt}`,
        "",
        bodyText,
        "",
        "Comments:",
        commentText,
        userStoryBlock,
    ].join("\n");
}
/**
 * Render the PR appendix block.
 *
 * Mirrors Python `pr_appendix`.
 *
 * @param pr Pull request details.
 * @returns The formatted appendix text.
 */
function prAppendix(pr) {
    const bodyText = (0, models_1.truncateLines)(pr.body, 120);
    return [
        (0, models_1.section)(`Pull Request ${pr.number}: ${pr.title}`),
        `State: ${pr.state}`,
        `Author: ${pr.author}`,
        `Base: ${pr.baseRef}`,
        `Head: ${pr.headRef}`,
        `Created: ${pr.createdAt}`,
        `Updated: ${pr.updatedAt}`,
        `Merged: ${pr.mergedAt ?? "(not merged)"}`,
        `Labels: ${pr.labels.length > 0 ? pr.labels.join(", ") : "(none)"}`,
        `Assignees: ${pr.assignees.length > 0 ? pr.assignees.join(", ") : "(none)"}`,
        "",
        bodyText,
        "",
        "Auto-close issues (from this PR):",
        (0, models_1.formatList)(pr.closingIssues, "(none)"),
        "",
        "Files (first 25):",
        (0, models_1.formatList)(pr.filesChanged.slice(0, 25), "(none)"),
    ].join("\n");
}
