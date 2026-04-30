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
    SourceArtifact,
    SourceEcosystem,
    SourceKind,
    SourceSection,
)

if TYPE_CHECKING:
    from pathlib import Path

_FRONTMATTER_BOUNDARY = "---"
_HEADING_PATTERN = re.compile(r"^(#{1,6})\s+(.+?)\s*$")


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


def _build_section(
    source_path: Path,
    lines: list[str],
    *,
    heading: str,
    level: int,
    start_line: int,
    end_line: int,
) -> SourceSection:
    """Build one parsed section with normalized body text."""

    body_text = "\n".join(lines[start_line - 1 : end_line]).rstrip()
    section_stem = re.sub(r"[^a-z0-9]+", "-", heading.lower()).strip("-") or "body"
    return SourceSection(
        section_id=f"{source_path.as_posix()}#{section_stem}-{start_line}",
        heading=heading,
        level=level,
        content=body_text,
        start_line=start_line,
        end_line=end_line,
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

    return (
        SourceSection(
            section_id=f"{source_path.as_posix()}#body-1",
            heading="Body",
            level=0,
            content=raw_text.rstrip(),
            start_line=1,
            end_line=len(lines),
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
