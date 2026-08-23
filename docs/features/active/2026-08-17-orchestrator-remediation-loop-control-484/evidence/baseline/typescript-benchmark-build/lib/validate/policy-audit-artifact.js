"use strict";
/**
 * Policy-audit orchestration-review artifact validator.
 *
 * Purpose:
 *     Port `scripts/dev_tools/validate_policy_audit_artifact.py`. Validate the
 *     required policy-audit headings, checklist labels, coverage-table rows, and
 *     per-language coverage-comparison bullets, rejecting placeholder text and
 *     non-numeric coverage evidence.
 *
 * Responsibilities:
 *     - `validatePolicyAuditText`: heading + placeholder + template-resolver
 *       checks plus the substantive requirements.
 *     - `validatePolicyAuditSubstantiveRequirements`: checklist, coverage-table,
 *       and per-language comparison evidence checks.
 *
 * Invariants / Constraints:
 *     - Placeholder markers are treated as failures.
 *     - Coverage rows must retain numeric evidence unless the field is N/A.
 *     - Error-message strings are identical to the Python source.
 *
 * Side Effects:
 *     None.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.TEMPLATE_RESOLVER_MISSING_MARKERS = exports.TEMPLATE_RESOLVER_TOOL = exports.PLACEHOLDER_MARKERS = exports.POLICY_AUDIT_COMPARISON_HEADING = exports.POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS = exports.POLICY_AUDIT_REQUIRED_HEADINGS = exports.COVERAGE_PERCENT_RE = void 0;
exports.validatePolicyAuditSubstantiveRequirements = validatePolicyAuditSubstantiveRequirements;
exports.validatePolicyAuditText = validatePolicyAuditText;
/** Match a numeric percentage token (mirrors Python `COVERAGE_PERCENT_RE`). */
exports.COVERAGE_PERCENT_RE = /\b\d+(?:\.\d+)?%/;
/** Required policy-audit headings, in document order. */
exports.POLICY_AUDIT_REQUIRED_HEADINGS = [
    "## Executive Summary",
    "## 1. General Unit Test Policy Compliance",
    "## 2. General Code Change Policy Compliance",
    "## 3. Language-Specific Code Change Policy Compliance",
    "## 4. Language-Specific Unit Test Policy Compliance",
    "## 5. Test Coverage Detail",
    "## 6. Test Execution Metrics",
    "## 7. Code Quality Checks",
    "## 8. Gaps and Exceptions",
    "## 9. Summary of Changes",
    "## 10. Compliance Verdict",
    "## Appendix A: Test Inventory",
    "## Appendix B: Toolchain Commands Reference",
];
/** Required checklist labels that must appear as bullet lines. */
exports.POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS = [
    "TypeScript baseline coverage artifact:",
    "TypeScript post-change coverage artifact:",
    "PowerShell baseline coverage artifact:",
    "PowerShell post-change coverage artifact:",
    "Per-language comparison summary:",
];
/** Heading that bounds the per-language coverage-comparison section. */
exports.POLICY_AUDIT_COMPARISON_HEADING = "### 1.2.1 Per-Language Coverage Comparison";
/** Substrings indicating unfinished template/draft markers. */
exports.PLACEHOLDER_MARKERS = [
    "[n]",
    "[path",
    "[artifact",
    "[section reference",
    "[language]",
    "tbd",
    "unverified",
    "missing",
];
/** The MCP resolver tool name referenced by readiness checks. */
exports.TEMPLATE_RESOLVER_TOOL = "resolve_policy_audit_template_asset";
/** Markers indicating the template resolver was unavailable. */
exports.TEMPLATE_RESOLVER_MISSING_MARKERS = [
    "not exposed",
    "was not exposed",
    "missing resolver exposure",
    "fallback template",
    "fallback-template",
];
/**
 * Return true when a coverage field contains a numeric percentage.
 *
 * @param value Raw coverage field text.
 * @returns True when the value contains at least one percentage token.
 */
function hasNumericCoverage(value) {
    return exports.COVERAGE_PERCENT_RE.test(value);
}
/**
 * Return true when an audit field explicitly records not-applicable.
 *
 * @param value Raw field text.
 * @returns True when the value begins with an N/A marker.
 */
function isNaValue(value) {
    return value.trim().toLowerCase().startsWith("n/a");
}
/**
 * Return true when a field still contains template placeholder text.
 *
 * @param value Raw field text.
 * @returns True when the field includes a known placeholder marker.
 */
function hasPlaceholderMarker(value) {
    const lowered = value.toLowerCase();
    // A field is a placeholder when any known marker substring is present.
    return exports.PLACEHOLDER_MARKERS.some((marker) => lowered.includes(marker));
}
/**
 * Return true for fallback-template artifacts that still claim success.
 *
 * @param text Full policy-audit artifact text.
 * @returns True when the resolver is reported missing yet the text claims pass.
 */
function reportsMissingTemplateResolverSuccess(text) {
    const lowered = text.toLowerCase();
    if (!lowered.includes(exports.TEMPLATE_RESOLVER_TOOL)) {
        return false;
    }
    // The resolver-missing claim only matters when a missing marker is present.
    if (!exports.TEMPLATE_RESOLVER_MISSING_MARKERS.some((m) => lowered.includes(m))) {
        return false;
    }
    return /\b(pass|ready|readiness)\b/.test(lowered);
}
/**
 * Parse the seven-column policy-audit coverage table into named rows.
 *
 * @param text Full policy-audit artifact text.
 * @returns Parsed coverage rows keyed by canonical column names.
 */
function extractPolicyAuditCoverageRows(text) {
    const rows = [];
    // Interpret only seven-column table rows, skipping headers/separators so that
    // narrative tables elsewhere in the document do not contribute rows.
    for (const line of text.split("\n")) {
        if (!line.startsWith("|")) {
            continue;
        }
        // Mirror Python `line.split("|")[1:-1]`: drop the leading and trailing
        // empty cells produced by the bounding pipes, then trim each cell.
        const segments = line.split("|");
        const cells = segments.slice(1, -1).map((cell) => cell.trim());
        if (cells.length !== 7) {
            continue;
        }
        const language = cells[0] ?? "";
        if (language === "Language" || language === "----------" || !language) {
            continue;
        }
        // Skip pure-dash separator cells (a cell consisting only of '-').
        if (language.length > 0 && /^-+$/.test(language)) {
            continue;
        }
        rows.push({
            Language: language,
            "Files Changed": cells[1] ?? "",
            Tests: cells[2] ?? "",
            "Test Result": cells[3] ?? "",
            "Baseline Coverage": cells[4] ?? "",
            "Post-Change Coverage": cells[5] ?? "",
            "New Code Coverage": cells[6] ?? "",
        });
    }
    return rows;
}
/**
 * Return the checklist bullet line containing a required label.
 *
 * @param text Full policy-audit artifact text.
 * @param label Required checklist label to locate.
 * @returns The matching checklist line, or null when absent.
 */
function findPolicyAuditChecklistLine(text, label) {
    // Search only checklist bullets because the same label text may appear in
    // narrative prose elsewhere in the document.
    for (const line of text.split("\n")) {
        const stripped = line.trim();
        if (stripped.startsWith("- ") && stripped.includes(label)) {
            return stripped;
        }
    }
    return null;
}
/**
 * Return per-language comparison lines keyed by normalized language name.
 *
 * @param text Full policy-audit artifact text.
 * @returns Mapping of lowercase language name to the matching comparison bullet.
 */
function extractPolicyAuditComparisonLines(text) {
    let inSection = false;
    const comparisonLines = new Map();
    // Limit parsing to the per-language coverage section so unrelated bullets do
    // not satisfy the evidence checks accidentally.
    for (const line of text.split("\n")) {
        const stripped = line.trim();
        if (stripped === exports.POLICY_AUDIT_COMPARISON_HEADING) {
            inSection = true;
            continue;
        }
        if (inSection && stripped.startsWith("### ")) {
            break;
        }
        if (!inSection || !stripped.startsWith("- ")) {
            continue;
        }
        // Partition on the first colon to separate the language from its summary.
        const body = stripped.slice(2);
        const colonIndex = body.indexOf(":");
        if (colonIndex === -1) {
            continue;
        }
        const language = body.slice(0, colonIndex);
        comparisonLines.set(language.trim().toLowerCase(), stripped);
    }
    return comparisonLines;
}
/**
 * Escape regex metacharacters in a literal label segment.
 *
 * @param value Literal text to escape.
 * @returns The text safe for embedding in a RegExp source.
 */
function escapeRegExp(value) {
    return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
/**
 * Return true when a comparison line includes a labelled percentage.
 *
 * @param line Comparison bullet text.
 * @param label Required label to anchor the percentage search.
 * @returns True when labelled numeric evidence is present.
 */
function comparisonLineHasLabelledPercentage(line, label) {
    const pattern = new RegExp(`${escapeRegExp(label)}.*?\\d+(?:\\.\\d+)?%`);
    return pattern.test(line);
}
/**
 * Validate policy-audit evidence requirements beyond headings.
 *
 * Purpose:
 *     Enforce the numeric coverage and evidence checklist requirements that turn
 *     the review template into an auditable artifact.
 *
 * @param text Full policy-audit artifact text.
 * @returns Validation errors describing each missing or malformed element.
 */
function validatePolicyAuditSubstantiveRequirements(text) {
    const errors = [];
    // Require every checklist line to exist and remain free of placeholders
    // before the audit can report a passing verdict.
    for (const label of exports.POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS) {
        const line = findPolicyAuditChecklistLine(text, label);
        if (line === null) {
            errors.push(`Policy audit missing required checklist line: ${label}`);
            continue;
        }
        if (hasPlaceholderMarker(line)) {
            errors.push(`Policy audit checklist line still contains placeholder text: ${label}`);
        }
    }
    const coverageRows = extractPolicyAuditCoverageRows(text);
    if (coverageRows.length === 0) {
        errors.push("Policy audit missing coverage metrics table rows.");
    }
    if (!text.includes(exports.POLICY_AUDIT_COMPARISON_HEADING)) {
        errors.push(`Policy audit missing required heading: ${exports.POLICY_AUDIT_COMPARISON_HEADING}`);
    }
    const comparisonLines = extractPolicyAuditComparisonLines(text);
    // Validate each language row against the comparison summary so baseline,
    // post-change, and changed-code evidence remain synchronized.
    for (const row of coverageRows) {
        const language = row.Language;
        const baseline = row["Baseline Coverage"];
        const postChange = row["Post-Change Coverage"];
        const newCode = row["New Code Coverage"];
        const requiresCoverageComparison = [baseline, postChange, newCode].some((value) => !isNaValue(value));
        if (!isNaValue(baseline) && !hasNumericCoverage(baseline)) {
            errors.push(`Policy audit missing numeric baseline coverage for ${language}.`);
        }
        if (!isNaValue(postChange) && !hasNumericCoverage(postChange)) {
            errors.push(`Policy audit missing numeric post-change coverage for ${language}.`);
        }
        if (!isNaValue(newCode) && !hasNumericCoverage(newCode)) {
            errors.push(`Policy audit missing numeric new/changed-code coverage for ${language}.`);
        }
        if (!requiresCoverageComparison) {
            continue;
        }
        const comparisonLine = comparisonLines.get(language.toLowerCase());
        if (comparisonLine === undefined) {
            errors.push(`Policy audit missing per-language comparison line for ${language}.`);
            continue;
        }
        if (!comparisonLineHasLabelledPercentage(comparisonLine, "Baseline:")) {
            errors.push(`Policy audit comparison line missing numeric baseline for ${language}.`);
        }
        if (!comparisonLineHasLabelledPercentage(comparisonLine, "Post-change:")) {
            errors.push(`Policy audit comparison line missing numeric post-change coverage for ${language}.`);
        }
        if (!comparisonLine.includes("Change:")) {
            errors.push(`Policy audit comparison line missing explicit change text for ${language}.`);
        }
        if (!/Disposition:\s*(PASS|FAIL|N\/A|INCOMPLETE|BLOCKED)/.test(comparisonLine)) {
            errors.push(`Policy audit comparison line missing disposition for ${language}.`);
        }
        if (!isNaValue(newCode) &&
            !comparisonLineHasLabelledPercentage(comparisonLine, "New/changed-code coverage:")) {
            errors.push(`Policy audit comparison line missing numeric new/changed-code coverage for ${language}.`);
        }
        if (!comparisonLine.includes("Evidence:")) {
            errors.push(`Policy audit comparison line missing evidence reference for ${language}.`);
        }
        else if (hasPlaceholderMarker(comparisonLine)) {
            errors.push(`Policy audit comparison line still contains placeholder text for ${language}.`);
        }
    }
    return errors;
}
/**
 * Validate template-derived policy-audit structure.
 *
 * Purpose:
 *     Enforce the required policy-audit headings and substantive evidence checks
 *     for repository review artifacts.
 *
 * @param text Full policy-audit artifact text.
 * @returns Validation errors for missing headings or evidence.
 */
function validatePolicyAuditText(text) {
    const errors = [];
    if (text.includes("Template Usage Instructions")) {
        errors.push("Policy audit still contains the template instruction block.");
    }
    if (text.includes("[Component Name]")) {
        errors.push("Policy audit still contains placeholder component text.");
    }
    if (reportsMissingTemplateResolverSuccess(text)) {
        errors.push("Policy audit cannot report PASS or READY when " +
            `${exports.TEMPLATE_RESOLVER_TOOL} is reported as missing or not exposed.`);
    }
    for (const heading of exports.POLICY_AUDIT_REQUIRED_HEADINGS) {
        if (!text.includes(heading)) {
            errors.push(`Policy audit missing required heading: ${heading}`);
        }
    }
    errors.push(...validatePolicyAuditSubstantiveRequirements(text));
    return errors;
}
