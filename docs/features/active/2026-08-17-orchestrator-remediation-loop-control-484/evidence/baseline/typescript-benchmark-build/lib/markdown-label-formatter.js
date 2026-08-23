"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.SEPARATOR_LINE = exports.LABEL_PREFIXES = void 0;
exports.isLabelLine = isLabelLine;
exports.isSeparatorLine = isSeparatorLine;
exports.formatLabelHeading = formatLabelHeading;
exports.ensureSeparatorBlock = ensureSeparatorBlock;
exports.prefixContentLine = prefixContentLine;
exports.processMarkdown = processMarkdown;
exports.readContent = readContent;
exports.writeOutput = writeOutput;
/**
 * Format markdown chat transcripts with labeled sections.
 *
 * This module is a port of the pure-logic and I/O functions of
 * `scripts/dev_tools/markdown_label_formatter.py`. The CLI entry-point glue
 * (`parse_args`/`main`) is intentionally NOT ported here: service wiring is
 * deferred to a consuming feature, so this module exposes only host-neutral,
 * testable functions. File and stream access flow through an injected
 * {@link FileSystem} and explicit stream callbacks rather than `node:fs` or
 * `process.stdin`/`process.stdout`.
 */
/** Recognized speaker-label prefixes that become H1 headings. */
exports.LABEL_PREFIXES = ["User:", "GitHub Copilot:"];
/** Separator token inserted between labeled sections. */
exports.SEPARATOR_LINE = "---";
/**
 * Split content into lines mirroring Python `str.splitlines()`.
 *
 * Python `splitlines()` splits on line boundaries (`\n`, `\r`, `\r\n`) and does
 * not emit a trailing empty element when the content ends in a newline. This
 * helper replicates that behavior so trailing-newline handling matches the
 * Python source exactly.
 *
 * @param content Raw text content.
 * @returns The list of lines without their terminating newline characters.
 */
function splitLines(content) {
    const lines = [];
    let current = "";
    let index = 0;
    // Walk the content character by character, breaking on line boundaries.
    // \r\n is consumed as a single boundary to avoid emitting an empty line.
    while (index < content.length) {
        const char = content[index];
        if (char === "\n") {
            lines.push(current);
            current = "";
            index += 1;
            continue;
        }
        if (char === "\r") {
            lines.push(current);
            current = "";
            // Consume a following \n as part of the same \r\n boundary.
            if (content[index + 1] === "\n") {
                index += 2;
            }
            else {
                index += 1;
            }
            continue;
        }
        current += char;
        index += 1;
    }
    // A non-empty trailing segment (no terminating newline) is its own line.
    if (current !== "") {
        lines.push(current);
    }
    return lines;
}
/**
 * Return true when the line starts with a known speaker label.
 *
 * @param line A single line of input.
 * @returns True when the line begins with one of {@link LABEL_PREFIXES}.
 */
function isLabelLine(line) {
    // Match Python str.startswith(tuple): true if any prefix matches.
    return exports.LABEL_PREFIXES.some((prefix) => line.startsWith(prefix));
}
/**
 * Return true when the line is blank or exactly the separator token.
 *
 * @param line A single line of input.
 * @returns True when the stripped line is empty or equals `---`.
 */
function isSeparatorLine(line) {
    const stripped = line.trim();
    return stripped === "" || stripped === exports.SEPARATOR_LINE;
}
/**
 * Convert a label line to an H1 heading and return remaining text.
 *
 * Mirrors Python `line.partition(":")`: split on the first colon, format the
 * heading from the stripped label, and left-strip the trailing remainder.
 *
 * @param line A line starting with one of the supported labels.
 * @returns The formatted heading and any trailing text following the label.
 */
function formatLabelHeading(line) {
    const colonIndex = line.indexOf(":");
    // partition(":"): when no colon exists, label is the whole line and trailing
    // is empty. The supported labels always contain a colon, but replicate the
    // full partition semantics for parity.
    const label = colonIndex === -1 ? line : line.slice(0, colonIndex);
    const trailing = colonIndex === -1 ? "" : line.slice(colonIndex + 1);
    const heading = `# ${label.trim()}:`;
    return { heading, trailing: trailing.replace(/^\s+/, "") };
}
/**
 * Ensure a blank/---/blank separator exists before the next label.
 *
 * Mutates `outputLines` in place: pop trailing blank lines, then append the
 * separator block. Replicates the Python `ensure_separator_block` behavior.
 *
 * @param outputLines The accumulated output lines, mutated in place.
 */
function ensureSeparatorBlock(outputLines) {
    // Remove any trailing blank lines so the separator block is well-formed.
    while (outputLines.length > 0 &&
        outputLines[outputLines.length - 1]?.trim() === "") {
        outputLines.pop();
    }
    outputLines.push("", exports.SEPARATOR_LINE, "");
}
/**
 * Prefix a non-label, non-separator line with a markdown quote marker.
 *
 * @param line A content line.
 * @returns `> <line>` for non-empty input, otherwise `>`.
 */
function prefixContentLine(line) {
    return line ? `> ${line}` : ">";
}
/**
 * Process markdown text according to the requested formatting rules.
 *
 * Labels become H1 headings preceded (when not first) by a separator block;
 * separators are normalized; all other lines are quoted. A trailing newline in
 * the input is preserved in the output.
 *
 * @param content Raw markdown content.
 * @returns The formatted markdown content.
 */
function processMarkdown(content) {
    const lines = splitLines(content);
    const trailingNewline = content.endsWith("\n");
    const outputLines = [];
    // Walk each input line and route it by kind: label, separator, or content.
    for (const line of lines) {
        if (isLabelLine(line)) {
            // A label that is not the first output gets a separator block above it.
            if (outputLines.length > 0) {
                ensureSeparatorBlock(outputLines);
            }
            const { heading, trailing } = formatLabelHeading(line);
            outputLines.push(heading);
            // Inline text after the label is spaced out and quoted on its own line.
            if (trailing) {
                outputLines.push("", "");
                outputLines.push(prefixContentLine(trailing));
            }
            continue;
        }
        if (isSeparatorLine(line)) {
            // A literal `---` is preserved; whitespace-only lines collapse to blank.
            outputLines.push(line.trim() ? exports.SEPARATOR_LINE : "");
            continue;
        }
        outputLines.push(prefixContentLine(line));
    }
    let result = outputLines.join("\n");
    if (trailingNewline) {
        result += "\n";
    }
    return result;
}
/**
 * Read content from a file path, or from a stdin callback when path is null.
 *
 * @param fs Injected filesystem used for file reads.
 * @param source File path to read, or null to read from `stdin`.
 * @param stdin Callback returning the standard-input content.
 * @returns The content read from the file or from `stdin`.
 */
function readContent(fs, source, stdin) {
    if (source === null) {
        return stdin();
    }
    return fs.readTextFile(source);
}
/**
 * Write content to a file path, or to a stdout callback when path is null.
 *
 * @param fs Injected filesystem used for file writes.
 * @param content The content to write.
 * @param target File path to write, or null to write to `stdout`.
 * @param stdout Callback receiving the content when no target path is given.
 */
function writeOutput(fs, content, target, stdout) {
    if (target === null) {
        stdout(content);
        return;
    }
    fs.writeTextFile(target, content);
}
