"""Parse source artifacts into section-level IR for native translation.

Purpose:
    Convert mixed-concern source files into structured sections so later
    classification and planning can operate on content rather than file paths
    alone.

Usage:
    The converter engine and section classifier call `parse_source_artifact`
    for artifacts that require section-aware decomposition, beginning with
    GitHub prompt files.

Flow:
    One source file is read, optional frontmatter is parsed, Markdown headings
    are split into deterministic sections, and each section is returned with
    stable source spans.

Invariants / Constraints:
    Parsed sections preserve source order and line numbers so report output
    stays auditable and deterministic.

Side Effects:
    Reads one source file from disk.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from scripts.dev_tools.codex_native_converter.models import (
    SemanticCue,
    SemanticCueKind,
    SourceArtifact,
    SourceEcosystem,
    SourceKind,
    SourceSection,
)

if TYPE_CHECKING:
    from pathlib import Path

_FRONTMATTER_BOUNDARY = "---"
_HEADING_PATTERN = re.compile(r"^(#{1,6})\s+(.+?)\s*$")

# Patterns for semantic cue detection within section content.
_NUMBERED_WORKFLOW_PATTERN = re.compile(
    r"^\s*(\d+[.)\s]|STEP\s+\d+)",
    re.MULTILINE,
)
_HARD_GATE_PATTERN = re.compile(
    r"\b(you MUST|MUST(?! NOT)|REQUIRED|SHALL(?! NOT)|is required|non-negotiable)",
    re.MULTILINE,
)
_FORBIDDEN_PATTERN_RE = re.compile(
    r"\b(MUST NOT|do NOT|NEVER|is forbidden|is prohibited|SHALL NOT|you must not)",
    re.MULTILINE | re.IGNORECASE,
)
_LAUNCHER_WRAPPER_PATTERN = re.compile(
    r"(```[\s\S]*?```|poetry run|node |npx |pwsh |bash "
    r"|cmd\.exe|Resolve.*Prompt|launch)",
    re.MULTILINE,
)
_TOOL_REQUIREMENT_PATTERN = re.compile(
    r"(mcp__|\btools:\b|\buses:\b|\bwith:\b|\btool_call|function_call|tool_definitions|allowed-tools)",
    re.MULTILINE,
)


def _read_source_text(source_root: Path, source_path: Path) -> str:
    """Read one source artifact as UTF-8 text."""

    return (source_root.resolve() / source_path).read_text(encoding="utf-8")


def _parse_frontmatter(lines: list[str]) -> tuple[dict[str, str], int]:
    """Parse a simple YAML-like frontmatter block from source lines."""

    if not lines or lines[0].strip() != _FRONTMATTER_BOUNDARY:
        return {}, 0

    closing_index = -1
    for index in range(1, len(lines)):
        if lines[index].strip() == _FRONTMATTER_BOUNDARY:
            closing_index = index
            break

    if closing_index < 0:
        return {}, 0

    frontmatter: dict[str, str] = {}
    for line in lines[1:closing_index]:
        if ":" not in line:
            continue
        key, _, raw_value = line.partition(":")
        frontmatter[key.strip()] = raw_value.strip().strip("'\"")

    return frontmatter, closing_index + 1


def _detect_cues(heading: str, content: str) -> tuple[SemanticCue, ...]:
    """Detect semantic cues present in one section's heading and content.

    Purpose:
        Produce evidence records so the section-intent classifier can make
        deterministic decisions based on explicit content signals rather than
        ad-hoc string matching at classification time.

    Args:
        heading (str): The section heading text.
        content (str): The full content of the section, including the heading
            line.

    Returns:
        tuple[SemanticCue, ...]: Zero or more cue instances in detection order.

    Side Effects:
        None.
    """

    cues: list[SemanticCue] = []

    # Every section that has a non-empty heading carries a heading-structure cue.
    if heading.strip():
        cues.append(SemanticCue(kind=SemanticCueKind.HEADING, value=heading))

    # Detect numbered-workflow patterns such as "1. Step", "2. Step", or
    # "STEP 1:" which indicate a procedural workflow block.
    if _NUMBERED_WORKFLOW_PATTERN.search(content):
        match = _NUMBERED_WORKFLOW_PATTERN.search(content)
        cues.append(
            SemanticCue(
                kind=SemanticCueKind.NUMBERED_WORKFLOW,
                value=(match.group(0).strip() if match else ""),
            )
        )

    # Detect hard-gate language that signals enforcement requirements such as
    # "you MUST", "REQUIRED", "non-negotiable".
    if _HARD_GATE_PATTERN.search(content):
        match = _HARD_GATE_PATTERN.search(content)
        cues.append(
            SemanticCue(
                kind=SemanticCueKind.HARD_GATE,
                value=(match.group(0).strip() if match else ""),
            )
        )

    # Detect forbidden-action language such as "MUST NOT", "do NOT", "NEVER",
    # "is forbidden".
    if _FORBIDDEN_PATTERN_RE.search(content):
        match = _FORBIDDEN_PATTERN_RE.search(content)
        cues.append(
            SemanticCue(
                kind=SemanticCueKind.FORBIDDEN_PATTERN,
                value=(match.group(0).strip() if match else ""),
            )
        )

    # Detect launcher-wrapper patterns such as shell invocations in code blocks
    # or known launcher command prefixes.
    if _LAUNCHER_WRAPPER_PATTERN.search(content):
        match = _LAUNCHER_WRAPPER_PATTERN.search(content)
        cues.append(
            SemanticCue(
                kind=SemanticCueKind.LAUNCHER_WRAPPER,
                value=(match.group(0).strip()[:60] if match else ""),
            )
        )

    # Detect tool-requirement language such as MCP tool references ("mcp__"),
    # tool definition keywords ("tools:", "uses:"), or allowed-tools declarations.
    if _TOOL_REQUIREMENT_PATTERN.search(content):
        match = _TOOL_REQUIREMENT_PATTERN.search(content)
        cues.append(
            SemanticCue(
                kind=SemanticCueKind.TOOL_REQUIREMENT,
                value=(match.group(0).strip() if match else ""),
            )
        )

    return tuple(cues)


def _build_section(
    source_path: Path,
    lines: list[str],
    *,
    heading: str,
    level: int,
    start_line: int,
    end_line: int,
) -> SourceSection:
    """Build one parsed section with normalized body text and attached cues."""

    body_text = "\n".join(lines[start_line - 1 : end_line]).rstrip()
    section_stem = re.sub(r"[^a-z0-9]+", "-", heading.lower()).strip("-") or "body"
    cues = _detect_cues(heading, body_text)
    return SourceSection(
        section_id=f"{source_path.as_posix()}#{section_stem}-{start_line}",
        heading=heading,
        level=level,
        content=body_text,
        start_line=start_line,
        end_line=end_line,
        cues=cues,
    )


def _split_sections(
    source_path: Path, raw_text: str, content_start_line: int
) -> tuple[SourceSection, ...]:
    """Split one source artifact body into deterministic sections."""

    lines = raw_text.splitlines()
    sections: list[SourceSection] = []
    current_heading = "Body"
    current_level = 0
    current_start_line = content_start_line

    for line_number in range(content_start_line, len(lines) + 1):
        heading_match = _HEADING_PATTERN.match(lines[line_number - 1])
        if heading_match is None:
            continue
        if line_number > current_start_line:
            pending_section = _build_section(
                source_path,
                lines,
                heading=current_heading,
                level=current_level,
                start_line=current_start_line,
                end_line=line_number - 1,
            )
            if pending_section.content.strip():
                sections.append(pending_section)
        current_heading = heading_match.group(2)
        current_level = len(heading_match.group(1))
        current_start_line = line_number

    if current_start_line <= len(lines):
        pending_section = _build_section(
            source_path,
            lines,
            heading=current_heading,
            level=current_level,
            start_line=current_start_line,
            end_line=len(lines),
        )
        if pending_section.content.strip():
            sections.append(pending_section)

    if sections:
        return tuple(sections)

    # No heading-based split was possible; treat the entire body as one section
    # and still detect cues so classifiers have evidence to work with.
    fallback_content = raw_text.rstrip()
    fallback_cues = _detect_cues("Body", fallback_content)
    return (
        SourceSection(
            section_id=f"{source_path.as_posix()}#body-1",
            heading="Body",
            level=0,
            content=fallback_content,
            start_line=1,
            end_line=len(lines),
            cues=fallback_cues,
        ),
    )


def parse_source_artifact(
    source_root: Path,
    source_path: Path,
    source_ecosystem: SourceEcosystem,
    source_kind: SourceKind,
) -> SourceArtifact:
    """Parse one source artifact into section-level intermediate representation."""

    raw_text = _read_source_text(source_root, source_path)
    lines = raw_text.splitlines()
    frontmatter, content_start_index = _parse_frontmatter(lines)
    content_start_line = content_start_index + 1 if content_start_index else 1
    sections = _split_sections(source_path, raw_text, content_start_line)
    return SourceArtifact(
        source_path=source_path.as_posix(),
        source_ecosystem=source_ecosystem,
        source_kind=source_kind,
        frontmatter=frontmatter,
        raw_text=raw_text,
        sections=sections,
    )
