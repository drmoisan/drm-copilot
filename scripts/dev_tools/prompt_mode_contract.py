"""Shared issue.md work-mode contract helpers for prompt resolvers.

Purpose:
    Centralize parsing and fail-closed work-mode resolution so all prompt
    resolvers use one deterministic contract:
    1) Parse persisted issue marker when valid.
    2) Fall back to full when marker is missing or malformed.
    3) Surface an auditable fallback reason string.
"""

from __future__ import annotations

import re


def parse_issue_work_mode(issue_content: str) -> tuple[str | None, bool]:
    """Parse the work-mode marker from issue.md content.

    Purpose:
        Extract a valid `- Work Mode:` marker value from issue content while
        distinguishing malformed marker lines from truly missing markers.

    Args:
        issue_content (str): Raw `issue.md` file content.

    Returns:
        tuple[str | None, bool]:
            - Parsed mode (`minor-audit` or `full`) when valid; otherwise None.
            - Boolean indicating whether a malformed marker line was detected.

    Side Effects:
        None.
    """
    valid_match = re.search(
        r"(?im)^-\s*Work Mode:\s*(minor-audit|full)\s*$",
        issue_content,
    )
    if valid_match is not None:
        return valid_match.group(1), False

    malformed_match = re.search(r"(?im)^-\s*Work Mode:\s*(.+)\s*$", issue_content)
    return None, malformed_match is not None


def resolve_selected_work_mode(issue_content: str | None) -> str:
    """Resolve selected work mode with fail-closed behavior.

    Purpose:
        Provide a deterministic selected mode for templates by honoring a valid
        marker when present and failing closed to `full` for all other states.

    Args:
        issue_content (str | None): Raw issue content, or None when the file is
            unavailable.

    Returns:
        str: `minor-audit` or `full`.

    Side Effects:
        None.
    """
    # Decision logic:
    # - If the issue file is unavailable, fail closed immediately.
    # - If a valid marker exists, trust it as the selected mode.
    # - Otherwise, fail closed to full.
    if issue_content is None:
        return "full"

    parsed_mode, _has_malformed_marker = parse_issue_work_mode(issue_content)
    if parsed_mode is not None:
        return parsed_mode

    return "full"


def build_fallback_reason(issue_content: str | None) -> str:
    """Build a deterministic fallback reason for mode resolution.

    Purpose:
        Produce a stable reason string suitable for prompt substitution and
        audit evidence, aligned with fail-closed mode semantics.

    Args:
        issue_content (str | None): Raw issue content, or None when missing or
            unreadable.

    Returns:
        str: `none` when no fallback was needed, otherwise an explicit reason.

    Side Effects:
        None.
    """
    if issue_content is None:
        return "issue.md missing; fail closed to full"

    parsed_mode, has_malformed_marker = parse_issue_work_mode(issue_content)
    if parsed_mode is not None:
        return "none"

    # Branch by marker quality so diagnostics are explicit and actionable.
    if has_malformed_marker:
        return "issue.md Work Mode marker malformed; fail closed to full"

    return "issue.md Work Mode marker missing; fail closed to full"
