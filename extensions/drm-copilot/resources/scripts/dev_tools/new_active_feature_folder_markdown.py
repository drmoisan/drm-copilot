"""Markdown transformation helpers for active feature folder creation."""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

from dev_tools.new_active_feature_folder_models import PLACEHOLDERS

if TYPE_CHECKING:
    from collections.abc import Callable


def format_checklist(text: str) -> str:
    """Normalize freeform checklist text into markdown checkboxes."""
    lines: list[str] = []
    for raw_line in text.splitlines():
        trimmed = raw_line.strip()
        if not trimmed:
            continue
        if re.match(r"^-\s*\[?\s*\]", trimmed):
            lines.append(trimmed)
        elif trimmed.startswith("-"):
            lines.append(trimmed)
        else:
            lines.append(f"- [ ] {trimmed}")
    return "\n".join(lines)


def get_section(content: str, name: str) -> str:
    """Extract a markdown section body by heading."""
    pattern = re.compile(
        rf"^\s*##\s+{re.escape(name)}\s*\r?\n(.*?)(?=^\s*##\s+|\Z)",
        re.DOTALL | re.MULTILINE,
    )
    match = pattern.search(content)
    if not match:
        return ""
    return match.group(1).strip()


def upsert_work_mode_marker(content: str, mode: str) -> str:
    """Insert or update work-mode marker directly above first `##` heading."""
    marker_line = f"- Work Mode: {mode}"
    marker_pattern = re.compile(
        r"^- Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$"
    )
    lines = [line for line in content.splitlines() if not marker_pattern.match(line)]

    for idx, line in enumerate(lines):
        if line.lstrip().startswith("## "):
            lines.insert(idx, "")
            lines.insert(idx, marker_line)
            return "\n".join(lines)

    if lines and lines[-1] != "":
        lines.append("")
    lines.append(marker_line)
    return "\n".join(lines)


def set_section(content: str, name: str, body: str) -> str:
    """Set or append a markdown section body."""
    if not body or not body.strip():
        return content

    pattern = re.compile(
        rf"(^##\s+{re.escape(name)}\s*\r?\n)(.*?)(?=^\s*##\s+|\Z)",
        re.DOTALL | re.MULTILINE,
    )
    if pattern.search(content):
        return pattern.sub(
            lambda match: f"{match.group(1)}{body}\n\n",
            content,
            count=1,
        )

    trimmed = content.rstrip()
    if trimmed:
        trimmed += "\n\n"
    return f"{trimmed}## {name}\n{body}\n"


def prepend_to_section_body(section_body: str, prefix: str) -> str:
    """Prepend text to an existing section body while preserving content."""
    trimmed_prefix = prefix.strip()
    if not trimmed_prefix:
        return section_body

    trimmed_body = section_body.strip()
    if not trimmed_body:
        return f"{trimmed_prefix}\n"
    return f"{trimmed_prefix}\n\n{trimmed_body}\n"


def update_section_body(
    content: str,
    section_name: str,
    updater: Callable[[str], str],
) -> tuple[str, bool]:
    """Update a `##` section body using a transformation function."""
    pattern = re.compile(
        rf"(^##\s+{re.escape(section_name)}\s*\r?\n)(.*?)(?=^\s*##\s+|\Z)",
        re.DOTALL | re.MULTILINE,
    )
    match = pattern.search(content)
    if not match:
        return content, False

    header = match.group(1)
    body = match.group(2)
    updated_body = updater(body)
    if updated_body == body:
        return content, False

    return (
        pattern.sub(
            lambda _match: f"{header}{updated_body}\n",
            content,
            count=1,
        ),
        True,
    )


def set_header_placeholder(
    content: str,
    feature_name: str,
    issue_field: str,
    owner_field: str,
    updated_field: str,
    status_field: str | None = None,
    parent_field: str | None = None,
    version_field: str | None = None,
) -> str:
    """Replace template placeholders in the frontmatter/header block."""
    result = content
    for placeholder in PLACEHOLDERS:
        result = result.replace(placeholder, feature_name)
    result = result.replace("<issue>", issue_field)
    if parent_field is not None:
        result = result.replace("<parent-id>", parent_field)
    if status_field is not None:
        result = result.replace("<status>", status_field)
    if version_field is not None:
        result = result.replace("<version_number>", version_field)
    result = re.sub(r"#`?<id>`?", issue_field, result)
    result = result.replace("<#id or TBD>", issue_field)
    result = result.replace("#<tracking-issue>", issue_field)

    result = re.sub(
        r"^-\s*\*\*Issue:\*\*\s+.*$",
        f"- **Issue:** {issue_field}",
        result,
        flags=re.MULTILINE,
    )
    result = re.sub(
        r"^-\s*Issue\s*:\s+.*$",
        f"- Issue: {issue_field}",
        result,
        flags=re.MULTILINE,
    )

    result = re.sub(
        r"^-\s*\*\*Owner:\*\*\s+(?:name|<name>|.*)$",
        f"- **Owner:** {owner_field}",
        result,
        flags=re.MULTILINE,
    )
    result = re.sub(
        r"^-\s*Owner\s*:\s+(?:name|<name>|.*)$",
        f"- Owner: {owner_field}",
        result,
        flags=re.MULTILINE,
    )

    if parent_field is not None:
        result = re.sub(
            r"^-\s*\*\*Parent \(optional\):\*\*\s+.*$",
            f"- **Parent (optional):** {parent_field}",
            result,
            flags=re.MULTILINE,
        )
        result = re.sub(
            r"^-\s*Parent \(optional\)\s*:\s+.*$",
            f"- Parent (optional): {parent_field}",
            result,
            flags=re.MULTILINE,
        )

    result = re.sub(
        r"^-\s*\*\*Last Updated:\*\*\s+.*$",
        f"- **Last Updated:** {updated_field}",
        result,
        flags=re.MULTILINE,
    )
    result = re.sub(
        r"^-\s*Last Updated\s*:\s+.*$",
        f"- Last Updated: {updated_field}",
        result,
        flags=re.MULTILINE,
    )

    result = re.sub(
        r"^-\s*\*\*Date:\*\*\s+.*$",
        f"- **Date:** {updated_field}",
        result,
        flags=re.MULTILINE,
    )
    result = re.sub(
        r"^-\s*Date\s*:\s+YYYY-MM-DD$",
        f"- Date: {updated_field}",
        result,
        flags=re.MULTILINE,
    )
    result = result.replace("<yyyy-MM-ddTHH-mm>", updated_field)

    if status_field is not None:
        result = re.sub(
            r"^-\s*\*\*Status:\*\*\s+.*$",
            f"- **Status:** {status_field}",
            result,
            flags=re.MULTILINE,
        )
        result = re.sub(
            r"^-\s*Status\s*:\s+.*$",
            f"- Status: {status_field}",
            result,
            flags=re.MULTILINE,
        )

    if version_field is not None:
        result = re.sub(
            r"^-\s*\*\*Version:\*\*\s+.*$",
            f"- **Version:** {version_field}",
            result,
            flags=re.MULTILINE,
        )
        result = re.sub(
            r"^-\s*Version\s*:\s+.*$",
            f"- Version: {version_field}",
            result,
            flags=re.MULTILINE,
        )

    if not re.search(
        r"^-\s*(?:\*\*Issue:\*\*\s*|Issue\s*:)\s*#?",
        result,
        flags=re.MULTILINE,
    ):
        result = f"- Issue: {issue_field}\n{result}"
    return result
