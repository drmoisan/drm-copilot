"use strict";
/**
 * Shared issue.md work-mode contract helpers for prompt resolvers.
 *
 * Purpose:
 *     Centralize parsing and fail-closed work-mode resolution so all prompt
 *     resolvers use one deterministic contract:
 *     1) Parse a persisted issue marker when valid.
 *     2) Normalize legacy `full` markers to a canonical full-mode variant.
 *     3) Fall back to `full-feature` when the marker is missing or malformed.
 *     4) Surface an auditable fallback or normalization reason string.
 *
 * This module is a direct port of
 * `scripts/dev_tools/prompt_mode_contract.py`; function signatures, return
 * shapes, error messages, and reason strings match the Python source verbatim.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ACCEPTED_WORK_MODES = exports.LEGACY_FULL_MODE = exports.CANONICAL_WORK_MODES = void 0;
exports.normalizeRequestedWorkMode = normalizeRequestedWorkMode;
exports.parseIssueWorkMode = parseIssueWorkMode;
exports.resolveSelectedWorkMode = resolveSelectedWorkMode;
exports.buildFallbackReason = buildFallbackReason;
/** Canonical work modes accepted as persisted marker values. */
exports.CANONICAL_WORK_MODES = [
    "minor-audit",
    "full-feature",
    "full-bug",
];
/** Legacy plain `full` marker retained for backward compatibility. */
exports.LEGACY_FULL_MODE = "full";
/** All accepted work modes, including the legacy `full` value. */
exports.ACCEPTED_WORK_MODES = [
    ...exports.CANONICAL_WORK_MODES,
    exports.LEGACY_FULL_MODE,
];
/**
 * Normalize a requested work mode into a canonical persisted value.
 *
 * Convert user-facing or legacy CLI values into canonical persisted markers.
 * Plain `full` remains accepted for backward compatibility but is normalized to
 * the deterministic variant that matches the promotion target.
 *
 * @param requestedMode Requested work mode from CLI or caller.
 * @param promotionType Promotion or feature type (`feature`, `bug`, etc.).
 * @returns Canonical work mode (`minor-audit`, `full-feature`, or `full-bug`).
 * @throws Error When the request is invalid or incompatible with the type.
 */
function normalizeRequestedWorkMode(requestedMode, promotionType) {
    // Reject any value outside the accepted set before branching on intent.
    if (!exports.ACCEPTED_WORK_MODES.includes(requestedMode)) {
        throw new Error("work_mode must be one of: minor-audit, full-feature, full-bug, full");
    }
    // minor-audit is already canonical and applies to any promotion type.
    if (requestedMode === "minor-audit") {
        return requestedMode;
    }
    const isBug = promotionType === "bug";
    // Legacy `full` is resolved to the variant matching the promotion target.
    if (requestedMode === exports.LEGACY_FULL_MODE) {
        return isBug ? "full-bug" : "full-feature";
    }
    // Canonical full-bug is only valid for bug work; reject otherwise.
    if (requestedMode === "full-bug" && !isBug) {
        throw new Error("full-bug may only be used with bug work");
    }
    // Canonical full-feature is invalid for bug work; reject that combination.
    if (requestedMode === "full-feature" && isBug) {
        throw new Error("full-feature may not be used with bug work");
    }
    return requestedMode;
}
/**
 * Parse the work-mode marker from issue.md content.
 *
 * Extract a valid `- Work Mode:` marker value from issue content while
 * distinguishing malformed marker lines from truly missing markers.
 *
 * @param issueContent Raw `issue.md` file content.
 * @returns A {@link ParsedWorkMode}: `mode` is the parsed value when valid
 *   (`minor-audit`, `full-feature`, `full-bug`, or legacy `full`), otherwise
 *   null; `malformed` indicates whether a malformed marker line was detected.
 */
function parseIssueWorkMode(issueContent) {
    // Mirror Python (?im) flags: case-insensitive, multiline (per-line anchors).
    const validMatch = /^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$/im.exec(issueContent);
    if (validMatch !== null) {
        return { mode: validMatch[1] ?? null, malformed: false };
    }
    // A marker line with an unrecognized value is malformed, not merely missing.
    const malformedMatch = /^-\s*Work Mode:\s*(.+)\s*$/im.exec(issueContent);
    return { mode: null, malformed: malformedMatch !== null };
}
/**
 * Resolve the selected work mode with fail-closed behavior.
 *
 * Honor a valid marker when present, normalize legacy `full` to `full-feature`,
 * and fail closed to `full-feature` for all other states.
 *
 * @param issueContent Raw issue content, or null when the file is unavailable.
 * @returns `minor-audit`, `full-feature`, or `full-bug`.
 */
function resolveSelectedWorkMode(issueContent) {
    // Decision logic:
    // - If the issue file is unavailable, fail closed immediately.
    // - If a valid marker exists, trust it as the selected mode.
    // - Otherwise, fail closed to full-feature.
    if (issueContent === null) {
        return "full-feature";
    }
    const { mode } = parseIssueWorkMode(issueContent);
    if (mode !== null) {
        if (mode === exports.LEGACY_FULL_MODE) {
            return "full-feature";
        }
        return mode;
    }
    return "full-feature";
}
/**
 * Build a deterministic fallback reason for mode resolution.
 *
 * Produce a stable reason string suitable for prompt substitution and audit
 * evidence, aligned with fail-closed mode semantics.
 *
 * @param issueContent Raw issue content, or null when missing or unreadable.
 * @returns `none` when no fallback was needed, otherwise an explicit reason.
 */
function buildFallbackReason(issueContent) {
    if (issueContent === null) {
        return "issue.md missing; fail closed to full-feature";
    }
    const { mode, malformed } = parseIssueWorkMode(issueContent);
    if (mode !== null) {
        if (mode === exports.LEGACY_FULL_MODE) {
            return "issue.md Work Mode marker uses legacy full; normalized to full-feature";
        }
        return "none";
    }
    // Branch by marker quality so diagnostics are explicit and actionable.
    if (malformed) {
        return "issue.md Work Mode marker malformed; fail closed to full-feature";
    }
    return "issue.md Work Mode marker missing; fail closed to full-feature";
}
