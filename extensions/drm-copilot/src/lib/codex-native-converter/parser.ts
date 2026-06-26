/**
 * Parse source artifacts into section-level IR for native translation.
 *
 * Purpose:
 *     Convert mixed-concern source files into structured sections so later
 *     classification and planning can operate on content rather than file paths
 *     alone. Ported from `parser.py`; source content is read through the
 *     injected {@link FileSystem}.
 *
 * Invariants:
 *     Parsed sections preserve source order and line numbers so report output
 *     stays auditable and deterministic. The frontmatter parser replicates the
 *     Python regex/partition behavior exactly (no YAML library).
 */

import { type FileSystem } from "../file-system";
import {
  type SemanticCue,
  SemanticCueKind,
  type SourceArtifact,
  type SourceEcosystem,
  type SourceKind,
  type SourceSection,
} from "./models";

const FRONTMATTER_BOUNDARY = "---";
const HEADING_PATTERN = /^(#{1,6})\s+(.+?)\s*$/;

// Semantic cue detection patterns (mirroring parser.py, including flags).
const NUMBERED_WORKFLOW_PATTERN = /^\s*(\d+[.)\s]|STEP\s+\d+)/m;
const HARD_GATE_PATTERN =
  /\b(you MUST|MUST(?! NOT)|REQUIRED|SHALL(?! NOT)|is required|non-negotiable)/m;
const FORBIDDEN_PATTERN_RE =
  /\b(MUST NOT|do NOT|NEVER|is forbidden|is prohibited|SHALL NOT|you must not)/im;
const LAUNCHER_WRAPPER_PATTERN =
  /(```[\s\S]*?```|poetry run|node |npx |pwsh |bash |cmd\.exe|Resolve.*Prompt|launch)/m;
const TOOL_REQUIREMENT_PATTERN =
  /(mcp__|\btools:\b|\buses:\b|\bwith:\b|\btool_call|function_call|tool_definitions|allowed-tools)/m;

/**
 * Read one source artifact as UTF-8 text through the injected filesystem.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source root.
 * @param sourcePath Source-root-relative POSIX path.
 * @returns The file content decoded as UTF-8.
 * @throws Error When the source file cannot be read.
 */
function readSourceText(
  fileSystem: FileSystem,
  sourceRoot: string,
  sourcePath: string,
): string {
  const normalizedRoot = sourceRoot.replace(/\/+$/, "");
  const normalizedRelative = sourcePath.replace(/^\/+/, "");
  const absolute =
    normalizedRoot === ""
      ? normalizedRelative
      : `${normalizedRoot}/${normalizedRelative}`;
  return fileSystem.readTextFile(absolute);
}

/**
 * Split text into lines using the Python `str.splitlines` convention (no
 * trailing empty element for a final newline).
 *
 * @param text Text to split.
 * @returns The lines without their terminators.
 */
function splitLines(text: string): string[] {
  if (text === "") {
    return [];
  }
  // Match Python splitlines: split on \r\n, \r, or \n and drop a trailing
  // empty element produced by a final line terminator.
  const lines = text.split(/\r\n|\r|\n/);
  if (lines.length > 0 && lines[lines.length - 1] === "") {
    lines.pop();
  }
  return lines;
}

/**
 * Strip trailing whitespace, matching Python `str.rstrip()`.
 *
 * @param value Value to strip.
 * @returns The value without trailing whitespace.
 */
function rstrip(value: string): string {
  return value.replace(/\s+$/u, "");
}

/**
 * Parse a simple YAML-like frontmatter block from source lines.
 *
 * Mirrors `_parse_frontmatter`: requires the first line to be `---`, finds the
 * closing `---`, and splits each `key: value` line, stripping surrounding
 * quotes. Returns the frontmatter map and the index after the closing boundary.
 *
 * @param lines Source lines.
 * @returns A tuple of the parsed frontmatter and the post-boundary index.
 */
function parseFrontmatter(
  lines: ReadonlyArray<string>,
): [Record<string, string>, number] {
  if (lines.length === 0 || (lines[0] ?? "").trim() !== FRONTMATTER_BOUNDARY) {
    return [{}, 0];
  }

  let closingIndex = -1;
  // Find the closing boundary line.
  for (let index = 1; index < lines.length; index += 1) {
    if ((lines[index] ?? "").trim() === FRONTMATTER_BOUNDARY) {
      closingIndex = index;
      break;
    }
  }

  if (closingIndex < 0) {
    return [{}, 0];
  }

  const frontmatter: Record<string, string> = {};
  // Parse each `key: value` line between the boundaries.
  for (let index = 1; index < closingIndex; index += 1) {
    const line = lines[index] ?? "";
    if (!line.includes(":")) {
      continue;
    }
    const separator = line.indexOf(":");
    const key = line.slice(0, separator).trim();
    const rawValue = line.slice(separator + 1).trim();
    frontmatter[key] = rawValue.replace(/^['"]+|['"]+$/g, "");
  }

  return [frontmatter, closingIndex + 1];
}

/**
 * Detect semantic cues present in one section's heading and content.
 *
 * Mirrors `_detect_cues`, preserving detection order and the launcher-wrapper
 * 60-character value truncation.
 *
 * @param heading Section heading text.
 * @param content Section content text.
 * @returns Zero or more cue instances in detection order.
 */
function detectCues(heading: string, content: string): SemanticCue[] {
  const cues: SemanticCue[] = [];

  if (heading.trim() !== "") {
    cues.push({ kind: SemanticCueKind.HEADING, value: heading });
  }

  const numberedMatch = NUMBERED_WORKFLOW_PATTERN.exec(content);
  if (numberedMatch) {
    cues.push({
      kind: SemanticCueKind.NUMBERED_WORKFLOW,
      value: numberedMatch[0].trim(),
    });
  }

  const hardGateMatch = HARD_GATE_PATTERN.exec(content);
  if (hardGateMatch) {
    cues.push({
      kind: SemanticCueKind.HARD_GATE,
      value: hardGateMatch[0].trim(),
    });
  }

  const forbiddenMatch = FORBIDDEN_PATTERN_RE.exec(content);
  if (forbiddenMatch) {
    cues.push({
      kind: SemanticCueKind.FORBIDDEN_PATTERN,
      value: forbiddenMatch[0].trim(),
    });
  }

  const launcherMatch = LAUNCHER_WRAPPER_PATTERN.exec(content);
  if (launcherMatch) {
    cues.push({
      kind: SemanticCueKind.LAUNCHER_WRAPPER,
      value: launcherMatch[0].trim().slice(0, 60),
    });
  }

  const toolMatch = TOOL_REQUIREMENT_PATTERN.exec(content);
  if (toolMatch) {
    cues.push({
      kind: SemanticCueKind.TOOL_REQUIREMENT,
      value: toolMatch[0].trim(),
    });
  }

  return cues;
}

/**
 * Build one parsed section with normalized body text and attached cues.
 *
 * Mirrors `_build_section`, including the heading-stem normalization and the
 * `<path>#<stem>-<startLine>` section id.
 *
 * @param sourcePath Source-root-relative POSIX path.
 * @param lines Source lines.
 * @param heading Section heading.
 * @param level Heading level.
 * @param startLine 1-based inclusive start line.
 * @param endLine 1-based inclusive end line.
 * @returns The constructed section.
 */
function buildSection(
  sourcePath: string,
  lines: ReadonlyArray<string>,
  heading: string,
  level: number,
  startLine: number,
  endLine: number,
): SourceSection {
  const bodyText = rstrip(lines.slice(startLine - 1, endLine).join("\n"));
  const sectionStem =
    heading
      .toLowerCase()
      .replace(/[^a-z0-9]+/g, "-")
      .replace(/^-+|-+$/g, "") || "body";
  const cues = detectCues(heading, bodyText);
  return {
    sectionId: `${sourcePath}#${sectionStem}-${startLine}`,
    heading,
    level,
    content: bodyText,
    startLine,
    endLine,
    cues,
  };
}

/**
 * Split one source artifact body into deterministic sections.
 *
 * Mirrors `_split_sections`, including the heading-driven split, the
 * non-empty-content filter, and the no-heading fallback single section.
 *
 * @param sourcePath Source-root-relative POSIX path.
 * @param rawText Full source text.
 * @param contentStartLine 1-based content start line.
 * @returns The parsed sections.
 */
function splitSections(
  sourcePath: string,
  rawText: string,
  contentStartLine: number,
): SourceSection[] {
  const lines = splitLines(rawText);
  const sections: SourceSection[] = [];
  let currentHeading = "Body";
  let currentLevel = 0;
  let currentStartLine = contentStartLine;

  // Walk each line from the content start; a heading ends the current section.
  for (
    let lineNumber = contentStartLine;
    lineNumber <= lines.length;
    lineNumber += 1
  ) {
    const headingMatch = HEADING_PATTERN.exec(lines[lineNumber - 1] ?? "");
    if (headingMatch === null) {
      continue;
    }
    if (lineNumber > currentStartLine) {
      const pendingSection = buildSection(
        sourcePath,
        lines,
        currentHeading,
        currentLevel,
        currentStartLine,
        lineNumber - 1,
      );
      if (pendingSection.content.trim() !== "") {
        sections.push(pendingSection);
      }
    }
    currentHeading = headingMatch[2] ?? "";
    currentLevel = (headingMatch[1] ?? "").length;
    currentStartLine = lineNumber;
  }

  if (currentStartLine <= lines.length) {
    const pendingSection = buildSection(
      sourcePath,
      lines,
      currentHeading,
      currentLevel,
      currentStartLine,
      lines.length,
    );
    if (pendingSection.content.trim() !== "") {
      sections.push(pendingSection);
    }
  }

  if (sections.length > 0) {
    return sections;
  }

  // No heading-based split was possible; treat the whole body as one section
  // while still detecting cues so classifiers have evidence.
  const fallbackContent = rstrip(rawText);
  const fallbackCues = detectCues("Body", fallbackContent);
  return [
    {
      sectionId: `${sourcePath}#body-1`,
      heading: "Body",
      level: 0,
      content: fallbackContent,
      startLine: 1,
      endLine: lines.length,
      cues: fallbackCues,
    },
  ];
}

/**
 * Parse one source artifact into section-level intermediate representation.
 *
 * Mirrors `parse_source_artifact`.
 *
 * @param fileSystem Injected filesystem.
 * @param sourceRoot POSIX source root.
 * @param sourcePath Source-root-relative POSIX path.
 * @param sourceEcosystem Declared source ecosystem.
 * @param sourceKind Classified source kind.
 * @returns The parsed source artifact.
 * @throws Error When the source file cannot be read.
 */
export function parseSourceArtifact(
  fileSystem: FileSystem,
  sourceRoot: string,
  sourcePath: string,
  sourceEcosystem: SourceEcosystem,
  sourceKind: SourceKind,
): SourceArtifact {
  const rawText = readSourceText(fileSystem, sourceRoot, sourcePath);
  const lines = splitLines(rawText);
  const [frontmatter, contentStartIndex] = parseFrontmatter(lines);
  const contentStartLine = contentStartIndex ? contentStartIndex + 1 : 1;
  const sections = splitSections(sourcePath, rawText, contentStartLine);
  return {
    sourcePath,
    sourceEcosystem,
    sourceKind,
    frontmatter,
    rawText,
    sections,
  };
}
