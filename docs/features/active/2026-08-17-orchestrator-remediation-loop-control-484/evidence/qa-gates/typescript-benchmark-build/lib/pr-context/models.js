"use strict";
/**
 * Shared models and pure helpers for PR context collection.
 *
 * Purpose:
 *     Port of `dev_tools/pr_context/models.py`. Define the structured records
 *     and pure string helpers shared across the pr-context port (git client, gh
 *     client, render, summary helpers, collector). Behavior — regex, string
 *     construction, truncation, and list formatting — is replicated exactly so
 *     the rendered summary and appendix output match the Python source.
 *
 * Responsibilities:
 *     - Define the data records (`IssueDetails`, `PullRequestDetails`,
 *       `FeatureDocExcerpt`, `PrContextResult`, `GitHubCliStatus`,
 *       `CiStatusSnapshot`, `BaseHeadInfo`, `ScopingDocChange`).
 *     - Re-export the {@link CommandResult} type alias from `subprocess-runner`.
 *     - Provide the `SECTION_LINE` template, `CONVENTIONAL_TYPES` tuple, and the
 *       pure helpers `section`, `truncate`, `truncateLines`, `normalizeReference`,
 *       `findUserStoryLink`, and `formatList`.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.CONVENTIONAL_TYPES = exports.SECTION_LINE = void 0;
exports.section = section;
exports.truncate = truncate;
exports.splitLines = splitLines;
exports.truncateLines = truncateLines;
exports.normalizeReference = normalizeReference;
exports.findUserStoryLink = findUserStoryLink;
exports.formatList = formatList;
/** Section banner template; mirrors Python `SECTION_LINE`. */
exports.SECTION_LINE = "===== {title} =====";
/** Recognized conventional-commit type prefixes; mirrors Python `CONVENTIONAL_TYPES`. */
exports.CONVENTIONAL_TYPES = [
    "feat",
    "fix",
    "refactor",
    "perf",
    "docs",
    "test",
    "chore",
    "build",
    "ci",
    "style",
];
/**
 * Build a section banner with leading and trailing newlines.
 *
 * Mirrors Python `section`: returns `"\n" + "===== <title> =====" + "\n"`.
 *
 * @param title Section title placed inside the banner.
 * @returns The banner line wrapped in surrounding newlines.
 */
function section(title) {
    return "\n" + exports.SECTION_LINE.replace("{title}", title) + "\n";
}
/**
 * Trim leading and trailing whitespace, mirroring Python `str.rstrip()` /
 * `str.strip()` over the default Unicode whitespace set used by the source.
 *
 * Python's `rstrip()` removes trailing whitespace (spaces, tabs, newlines,
 * etc.). The JavaScript `String.prototype.trimEnd` covers the same common
 * whitespace, which matches the inputs the source handles.
 *
 * @param value Text whose trailing whitespace is removed.
 * @returns `value` with trailing whitespace removed.
 */
function rstrip(value) {
    return value.replace(/\s+$/u, "");
}
/**
 * Truncate text to a character limit with an ellipsis suffix.
 *
 * Mirrors Python `truncate`: when `text.length <= limit`, return it unchanged;
 * otherwise return the first `limit - 3` characters with trailing whitespace
 * stripped, followed by `"..."`.
 *
 * @param text Text to truncate.
 * @param limit Maximum length before truncation (default 800).
 * @returns The original text or a truncated-with-ellipsis variant.
 */
function truncate(text, limit = 800) {
    if (text.length <= limit) {
        return text;
    }
    return rstrip(text.slice(0, limit - 3)) + "...";
}
/**
 * Split a string into lines the way Python `str.splitlines()` does.
 *
 * Python `splitlines()` breaks on `\n`, `\r`, and `\r\n` and does not include a
 * trailing empty element for a final line terminator. This helper reproduces
 * that behavior for the line-budget truncation used across the port.
 *
 * @param value Text to split into lines.
 * @returns The list of lines without their terminators.
 */
function splitLines(value) {
    if (value === "") {
        return [];
    }
    // Split on CRLF, CR, or LF; drop a single trailing terminator so a final
    // newline does not yield an extra empty line (Python `splitlines` semantics).
    const lines = value.split(/\r\n|\r|\n/u);
    if (lines.length > 0 &&
        lines[lines.length - 1] === "" &&
        /(\r\n|\r|\n)$/u.test(value)) {
        lines.pop();
    }
    return lines;
}
/**
 * Truncate text to a maximum number of lines.
 *
 * Mirrors Python `truncate_lines`: when the line count is at or under `limit`,
 * return the text unchanged; otherwise join the first `limit` lines and append
 * the `TRUNCATED: first N lines shown` suffix separated by a blank line.
 *
 * @param text Text to truncate.
 * @param limit Maximum number of lines retained.
 * @returns The original text or the truncated variant with the suffix.
 */
function truncateLines(text, limit) {
    const lines = splitLines(text);
    if (lines.length <= limit) {
        return text;
    }
    const head = lines.slice(0, limit).join("\n");
    return `${head}\n\nTRUNCATED: first ${limit} lines shown`;
}
/**
 * Normalize an issue reference token.
 *
 * Mirrors Python `normalize_reference`: strip a leading `#` then strip
 * surrounding whitespace.
 *
 * @param ref Raw reference token (for example `#42`).
 * @returns The reference without a leading `#` and without surrounding
 *   whitespace.
 */
function normalizeReference(ref) {
    return ref.replace(/^#+/u, "").trim();
}
/**
 * Find a user-story document link inside freeform body text.
 *
 * Mirrors Python `find_user_story_link`:
 * - Prefer a parenthesized `(... user-story.md)` capture.
 * - Fall back to a bare `\S*user-story.md` token.
 * - When the candidate is a GitHub blob URL, extract the repo-relative path
 *   after `blob/<ref>/`.
 * - Otherwise strip a single set of leading slashes.
 * - Return `null` when no candidate is found.
 *
 * @param body Body text to scan.
 * @returns The resolved user-story path, or `null` when absent.
 */
function findUserStoryLink(body) {
    if (!body) {
        return null;
    }
    // Prefer an explicit parenthesized markdown link target.
    const parenMatch = /\(([^)]+user-story\.md)\)/iu.exec(body);
    let candidate = parenMatch ? parenMatch[1] : null;
    if (!candidate) {
        // Fall back to any bare token ending in user-story.md.
        const fallback = /\S*user-story\.md/iu.exec(body);
        candidate = fallback ? fallback[0] : null;
    }
    if (!candidate) {
        return null;
    }
    // GitHub blob URLs carry the repo-relative path after blob/<ref>/.
    const githubBlob = /github\.com\/[^/]+\/[^/]+\/blob\/[^/]+\/(.+user-story\.md)/iu.exec(candidate);
    if (githubBlob) {
        return githubBlob[1];
    }
    return candidate.replace(/^\/+/u, "");
}
/**
 * Render an iterable of values as a markdown bullet list.
 *
 * Mirrors Python `format_list`: falsy values are filtered out; when nothing
 * remains the `emptyText` is returned; otherwise each surviving value becomes a
 * `- <item>` line joined by newlines.
 *
 * @param values Candidate values to render.
 * @param emptyText Text returned when no truthy values remain.
 * @returns The bullet list or `emptyText`.
 */
function formatList(values, emptyText) {
    const valuesList = [...values].filter((value) => value);
    if (valuesList.length === 0) {
        return emptyText;
    }
    return valuesList.map((item) => `- ${item}`).join("\n");
}
