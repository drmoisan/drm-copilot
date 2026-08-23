"use strict";
/**
 * Markdown transformation helpers for active feature folder creation.
 *
 * Purpose:
 *     Direct TypeScript port of the bundled
 *     `dev_tools/new_active_feature_folder_markdown.py`. Every regex, format,
 *     and message is byte-identical to the Python source.
 *
 * Escape-safety:
 *     `setSection` and `updateSectionBody` use function-form replacement
 *     callbacks so backslash-rich bodies (e.g. `C:\Outlook\Objects`) are
 *     inserted verbatim and never interpreted as regex replacement escapes.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.formatChecklist = formatChecklist;
exports.getSection = getSection;
exports.upsertWorkModeMarker = upsertWorkModeMarker;
exports.setSection = setSection;
exports.prependToSectionBody = prependToSectionBody;
exports.updateSectionBody = updateSectionBody;
exports.setHeaderPlaceholder = setHeaderPlaceholder;
const models_1 = require("./models");
/**
 * Escape regular-expression metacharacters in a literal segment.
 *
 * Mirrors Python `re.escape` for the characters that appear in section names
 * and metadata labels used by this module.
 *
 * @param value Literal text that may contain regex metacharacters.
 * @returns The text with metacharacters escaped for safe RegExp embedding.
 */
function escapeRegExp(value) {
    return value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
}
/**
 * Split text into lines on `\n`, `\r\n`, or `\r`.
 *
 * Mirrors Python `str.splitlines()` for the line breaks present in the markdown
 * inputs handled here.
 *
 * @param text Source text.
 * @returns The text split into lines without trailing line-break characters.
 */
function splitLines(text) {
    return text.split(/\r\n|\r|\n/);
}
/**
 * Normalize freeform checklist text into markdown checkboxes.
 *
 * Mirrors Python `format_checklist`: trims each line, skips blanks, keeps lines
 * that already look like a checkbox or a bullet, and prefixes plain lines with
 * `- [ ] `.
 *
 * @param text Freeform multi-line text.
 * @returns The normalized checklist joined with `\n`.
 */
function formatChecklist(text) {
    const lines = [];
    // Walk every input line, normalizing each to a markdown list item while
    // dropping blank lines so the generated checklist stays compact.
    for (const rawLine of splitLines(text)) {
        const trimmed = rawLine.trim();
        if (!trimmed) {
            continue;
        }
        // A line already shaped like a checkbox (`- [ ]`/`-[]`) is kept verbatim;
        // any other bullet line is also kept; everything else becomes a checkbox.
        if (/^-\s*\[?\s*\]/.test(trimmed)) {
            lines.push(trimmed);
        }
        else if (trimmed.startsWith("-")) {
            lines.push(trimmed);
        }
        else {
            lines.push(`- [ ] ${trimmed}`);
        }
    }
    return lines.join("\n");
}
/**
 * Extract a markdown section body by heading.
 *
 * Mirrors Python `get_section` with `re.DOTALL | re.MULTILINE`.
 *
 * @param content Full markdown content.
 * @param name Section heading text (matched after `## `).
 * @returns The trimmed section body, or `""` when the heading is absent.
 */
function getSection(content, name) {
    const pattern = new RegExp(`^\\s*##\\s+${escapeRegExp(name)}\\s*\\r?\\n([\\s\\S]*?)(?=^\\s*##\\s+|$(?![\\s\\S]))`, "m");
    const match = pattern.exec(content);
    if (!match) {
        return "";
    }
    return (match[1] ?? "").trim();
}
/**
 * Insert or update the work-mode marker directly above the first `##` heading.
 *
 * Mirrors Python `upsert_work_mode_marker`: removes any existing marker line,
 * then inserts `- Work Mode: <mode>` followed by a blank line above the first
 * `## ` heading; when no heading exists it appends the marker (after a trailing
 * blank line when the last line is non-empty).
 *
 * @param content Full markdown content.
 * @param mode Work-mode value to persist.
 * @returns The content with the marker inserted or updated, joined with `\n`.
 */
function upsertWorkModeMarker(content, mode) {
    const markerLine = `- Work Mode: ${mode}`;
    const markerPattern = /^- Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$/;
    // Drop any existing marker line so a single canonical marker remains.
    const lines = splitLines(content).filter((line) => !markerPattern.test(line));
    // Insert the marker (followed by a blank line) directly above the first
    // top-level `## ` heading so it sits in the document frontmatter region.
    for (let idx = 0; idx < lines.length; idx += 1) {
        const line = lines[idx] ?? "";
        if (line.replace(/^\s+/, "").startsWith("## ")) {
            lines.splice(idx, 0, "");
            lines.splice(idx, 0, markerLine);
            return lines.join("\n");
        }
    }
    // No heading exists: append a trailing blank separator when needed, then the
    // marker line, mirroring the Python fallback ordering.
    if (lines.length > 0 && lines[lines.length - 1] !== "") {
        lines.push("");
    }
    lines.push(markerLine);
    return lines.join("\n");
}
/**
 * Set or append a markdown section body.
 *
 * Mirrors Python `set_section`. When `body` is empty/whitespace the content is
 * returned unchanged. When a `## <name>` block exists its body is replaced with
 * `<body>\n\n`; otherwise a new `## <name>\n<body>\n` block is appended.
 *
 * The replacement uses a function-form callback so a `body` containing
 * backslash sequences (e.g. `C:\Outlook\Objects`) is inserted literally.
 *
 * @param content Full markdown content.
 * @param name Section heading text.
 * @param body Section body to set.
 * @returns The updated content.
 */
function setSection(content, name, body) {
    if (!body || !body.trim()) {
        return content;
    }
    const pattern = new RegExp(`(^##\\s+${escapeRegExp(name)}\\s*\\r?\\n)([\\s\\S]*?)(?=^\\s*##\\s+|$(?![\\s\\S]))`, "m");
    if (pattern.test(content)) {
        // Function-form replacement: `group1` is the heading line; the body is
        // returned literally so `$`/`\` in `body` are never treated as escapes.
        return content.replace(pattern, (_match, group1) => `${group1}${body}\n\n`);
    }
    let trimmed = content.replace(/\s+$/, "");
    if (trimmed) {
        trimmed += "\n\n";
    }
    return `${trimmed}## ${name}\n${body}\n`;
}
/**
 * Prepend text to an existing section body while preserving content.
 *
 * Mirrors Python `prepend_to_section_body`.
 *
 * @param sectionBody Existing section body.
 * @param prefix Text to prepend.
 * @returns The combined body.
 */
function prependToSectionBody(sectionBody, prefix) {
    const trimmedPrefix = prefix.trim();
    if (!trimmedPrefix) {
        return sectionBody;
    }
    const trimmedBody = sectionBody.trim();
    if (!trimmedBody) {
        return `${trimmedPrefix}\n`;
    }
    return `${trimmedPrefix}\n\n${trimmedBody}\n`;
}
/**
 * Update a `##` section body using a transformation function.
 *
 * Mirrors Python `update_section_body`. Returns `[content, false]` when the
 * section is absent or the updater leaves the body unchanged; otherwise returns
 * `[newContent, true]`.
 *
 * The replacement uses a function-form callback so updater output containing
 * backslashes is inserted literally.
 *
 * @param content Full markdown content.
 * @param sectionName Section heading text.
 * @param updater Transformation applied to the current body.
 * @returns A tuple of the (possibly updated) content and a changed flag.
 */
function updateSectionBody(content, sectionName, updater) {
    const pattern = new RegExp(`(^##\\s+${escapeRegExp(sectionName)}\\s*\\r?\\n)([\\s\\S]*?)(?=^\\s*##\\s+|$(?![\\s\\S]))`, "m");
    const match = pattern.exec(content);
    if (!match) {
        return [content, false];
    }
    const header = match[1] ?? "";
    const body = match[2] ?? "";
    const updatedBody = updater(body);
    if (updatedBody === body) {
        return [content, false];
    }
    // Function-form replacement so updater output (which may contain backslashes)
    // is inserted verbatim.
    const newContent = content.replace(pattern, () => `${header}${updatedBody}\n`);
    return [newContent, true];
}
/**
 * Replace template placeholders in the frontmatter/header block.
 *
 * Mirrors Python `set_header_placeholder` exactly: the placeholder/token
 * substitution chain, the optional `status`/`parent`/`version` branches, every
 * multiline metadata-line rewrite (both `**Bold:**` and plain `- Label:`
 * forms), and the final `- Issue:` prepend when no Issue metadata line exists.
 *
 * All substitutions are escape-safe with respect to the field values:
 * `String.replace` with a string argument treats `$` specially, so each field
 * value is wrapped in a function-form replacement to insert it literally.
 *
 * @param content Full markdown content.
 * @param featureName Feature name substituted for every placeholder token.
 * @param issueField Issue field value (e.g. `#123` or `TBD`).
 * @param ownerField Owner field value.
 * @param updatedField Last-updated/date field value.
 * @param statusField Optional status field value.
 * @param parentField Optional parent field value.
 * @param versionField Optional version field value.
 * @returns The content with header placeholders and metadata lines rewritten.
 */
function setHeaderPlaceholder(content, featureName, issueField, ownerField, updatedField, statusField, parentField, versionField) {
    let result = content;
    // Replace each header placeholder token with the resolved feature name.
    for (const placeholder of models_1.PLACEHOLDERS) {
        result = replaceAllLiteral(result, placeholder, featureName);
    }
    result = replaceAllLiteral(result, "<issue>", issueField);
    // The parent/status/version tokens are only substituted when their
    // corresponding field was supplied (matching the Python None guards).
    if (parentField !== undefined) {
        result = replaceAllLiteral(result, "<parent-id>", parentField);
    }
    if (statusField !== undefined) {
        result = replaceAllLiteral(result, "<status>", statusField);
    }
    if (versionField !== undefined) {
        result = replaceAllLiteral(result, "<version_number>", versionField);
    }
    result = replaceRegexLiteral(result, /#`?<id>`?/g, issueField);
    result = replaceAllLiteral(result, "<#id or TBD>", issueField);
    result = replaceAllLiteral(result, "#<tracking-issue>", issueField);
    result = replaceRegexLiteral(result, /^-\s*\*\*Issue:\*\*\s+.*$/gm, `- **Issue:** ${issueField}`);
    result = replaceRegexLiteral(result, /^-\s*Issue\s*:\s+.*$/gm, `- Issue: ${issueField}`);
    result = replaceRegexLiteral(result, /^-\s*\*\*Owner:\*\*\s+(?:name|<name>|.*)$/gm, `- **Owner:** ${ownerField}`);
    result = replaceRegexLiteral(result, /^-\s*Owner\s*:\s+(?:name|<name>|.*)$/gm, `- Owner: ${ownerField}`);
    // The Parent (optional) metadata lines are only rewritten when a parent field
    // was provided, mirroring the Python conditional block.
    if (parentField !== undefined) {
        result = replaceRegexLiteral(result, /^-\s*\*\*Parent \(optional\):\*\*\s+.*$/gm, `- **Parent (optional):** ${parentField}`);
        result = replaceRegexLiteral(result, /^-\s*Parent \(optional\)\s*:\s+.*$/gm, `- Parent (optional): ${parentField}`);
    }
    result = replaceRegexLiteral(result, /^-\s*\*\*Last Updated:\*\*\s+.*$/gm, `- **Last Updated:** ${updatedField}`);
    result = replaceRegexLiteral(result, /^-\s*Last Updated\s*:\s+.*$/gm, `- Last Updated: ${updatedField}`);
    result = replaceRegexLiteral(result, /^-\s*\*\*Date:\*\*\s+.*$/gm, `- **Date:** ${updatedField}`);
    result = replaceRegexLiteral(result, /^-\s*Date\s*:\s+YYYY-MM-DD$/gm, `- Date: ${updatedField}`);
    result = replaceAllLiteral(result, "<yyyy-MM-ddTHH-mm>", updatedField);
    // Status metadata lines are rewritten only when a status field was supplied.
    if (statusField !== undefined) {
        result = replaceRegexLiteral(result, /^-\s*\*\*Status:\*\*\s+.*$/gm, `- **Status:** ${statusField}`);
        result = replaceRegexLiteral(result, /^-\s*Status\s*:\s+.*$/gm, `- Status: ${statusField}`);
    }
    // Version metadata lines are rewritten only when a version field was supplied.
    if (versionField !== undefined) {
        result = replaceRegexLiteral(result, /^-\s*\*\*Version:\*\*\s+.*$/gm, `- **Version:** ${versionField}`);
        result = replaceRegexLiteral(result, /^-\s*Version\s*:\s+.*$/gm, `- Version: ${versionField}`);
    }
    // When no Issue metadata line is present, prepend one so the generated doc
    // always carries an issue reference at the top.
    if (!/^-\s*(?:\*\*Issue:\*\*\s*|Issue\s*:)\s*#?/m.test(result)) {
        result = `- Issue: ${issueField}\n${result}`;
    }
    return result;
}
/**
 * Replace every literal occurrence of `search` with `replacement`.
 *
 * Uses a split/join so the replacement is inserted verbatim (no `$`-pattern
 * interpretation), mirroring Python `str.replace`.
 *
 * @param source Source text.
 * @param search Literal substring to replace.
 * @param replacement Literal replacement text.
 * @returns The text with all occurrences replaced.
 */
function replaceAllLiteral(source, search, replacement) {
    return source.split(search).join(replacement);
}
/**
 * Replace regex matches with a literal replacement string.
 *
 * Uses a function-form callback so `$`/`\` in `replacement` are inserted
 * verbatim, mirroring Python `re.sub` with a plain replacement string built
 * from interpolated field values (which Python does not treat as escapes here
 * because the fields contain no group references).
 *
 * @param source Source text.
 * @param pattern Match pattern (global flag controls single vs. all).
 * @param replacement Literal replacement text inserted for each match.
 * @returns The text with matches replaced.
 */
function replaceRegexLiteral(source, pattern, replacement) {
    return source.replace(pattern, () => replacement);
}
