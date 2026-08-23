"use strict";
/**
 * Pure helpers for composing the quick-pick entries shown by the
 * `drmCopilotExtension.showSubagentTree` command when more than one root
 * session candidate exists.
 *
 * Purpose:
 *     Keep all label formatting, path truncation, timestamp rendering, and
 *     ordering logic in a host-neutral module with no `vscode` and no
 *     `node:fs` import, so `src/subagent-tree-command.ts` performs only thin
 *     host wiring. Every function here is a pure transformation of its inputs;
 *     production code never reads the wall clock (`Date.now()` is not called).
 *
 * Path convention:
 *     Operates on plain strings only; performs no filesystem access.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.MAX_PATH_LABEL_LENGTH = void 0;
exports.truncateLeftAnchored = truncateLeftAnchored;
exports.formatLastActivityTimestamp = formatLastActivityTimestamp;
exports.buildRootSessionPickEntries = buildRootSessionPickEntries;
/** Maximum length of the right-anchored path label shown in a quick-pick entry. */
exports.MAX_PATH_LABEL_LENGTH = 60;
/**
 * Truncate `value` to at most `maxLength` characters, preserving the tail.
 *
 * When `value.length <= maxLength` the value is returned unchanged. Otherwise
 * an ellipsis-prefixed suffix is returned: `"…" + value.slice(value.length -
 * (maxLength - 1))`, so the result length equals `maxLength` and the final
 * characters always equal the final characters of `value` (the distinguishing
 * path tail stays visible). For `maxLength <= 1` the arithmetic degenerates to
 * a single `…` glyph.
 *
 * @param value The full string to truncate (typically an absolute path).
 * @param maxLength The maximum number of characters the result may occupy.
 * @returns The value unchanged, or an ellipsis-prefixed, left-truncated tail.
 */
function truncateLeftAnchored(value, maxLength) {
    if (value.length <= maxLength) {
        return value;
    }
    return `…${value.slice(value.length - (maxLength - 1))}`;
}
/**
 * Render an epoch-milliseconds value as a `yyyy-MM-dd HH:mm` UTC timestamp.
 *
 * This is a pure transformation of a value already read from disk (a
 * transcript file's mtime), not a wall-clock read: `new Date(epochMs)` is
 * constructed from the supplied epoch, and only the UTC component accessors
 * are used, so the output is stable across host time zones. An `undefined`
 * epoch (an unreadable mtime) renders as the literal `unknown`.
 *
 * @param epochMs Milliseconds since the Unix epoch, or `undefined` when the
 *   source mtime could not be read.
 * @returns The formatted UTC timestamp, or `unknown` for an absent value.
 */
function formatLastActivityTimestamp(epochMs) {
    if (epochMs === undefined) {
        return "unknown";
    }
    const date = new Date(epochMs);
    const year = date.getUTCFullYear().toString().padStart(4, "0");
    const month = padTwo(date.getUTCMonth() + 1);
    const day = padTwo(date.getUTCDate());
    const hours = padTwo(date.getUTCHours());
    const minutes = padTwo(date.getUTCMinutes());
    return `${year}-${month}-${day} ${hours}:${minutes}`;
}
/**
 * Build ordered quick-pick entries for the discovered root session candidates.
 *
 * Ordering is total and deterministic: last-activity timestamp descending;
 * candidates with an unreadable mtime (`undefined`) sort last; ties (equal
 * timestamps, or both `undefined`) are broken by path ascending. The input
 * array is not mutated.
 *
 * @param candidates The discovered candidates with their read mtimes.
 * @param maxPathLength The maximum length of the truncated path in each label.
 * @returns The ordered pick entries; an empty array for an empty input.
 */
function buildRootSessionPickEntries(candidates, maxPathLength) {
    return [...candidates].sort(compareCandidates).map((candidate) => ({
        label: `${formatLastActivityTimestamp(candidate.lastActivityMs)}  ${truncateLeftAnchored(candidate.path, maxPathLength)}`,
        detail: candidate.path,
        path: candidate.path,
    }));
}
/** Left-pad a non-negative integer to two digits. */
function padTwo(value) {
    return value.toString().padStart(2, "0");
}
/**
 * Compare two candidates for the deterministic quick-pick ordering: mtime
 * descending, `undefined` mtime last, path ascending as the tie-break.
 */
function compareCandidates(left, right) {
    const leftMs = left.lastActivityMs;
    const rightMs = right.lastActivityMs;
    if (leftMs !== rightMs) {
        if (leftMs === undefined) {
            return 1;
        }
        if (rightMs === undefined) {
            return -1;
        }
        return rightMs - leftMs;
    }
    return left.path < right.path ? -1 : left.path > right.path ? 1 : 0;
}
