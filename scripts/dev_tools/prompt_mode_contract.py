"""Shared issue.md work-mode contract helpers for prompt resolvers.

Purpose:
    Centralize parsing and fail-closed work-mode resolution so all prompt
    resolvers use one deterministic contract:
    1) Parse persisted issue marker when valid.
    2) Normalize legacy `full` markers to a canonical full-mode variant.
    3) Fall back to `full-feature` when marker is missing or malformed.
    4) Surface an auditable fallback or normalization reason string.
"""

from __future__ import annotations

import re

CANONICAL_WORK_MODES = ("minor-audit", "full-feature", "full-bug")
LEGACY_FULL_MODE = "full"
ACCEPTED_WORK_MODES = (*CANONICAL_WORK_MODES, LEGACY_FULL_MODE)


def normalize_requested_work_mode(requested_mode: str, promotion_type: str) -> str:
    """Normalize a requested work mode into a canonical persisted value.

    Purpose:
        Convert user-facing or legacy CLI values into canonical persisted
        markers. Plain `full` remains accepted for backward compatibility but is
        normalized to the deterministic variant that matches the promotion
        target.

    Args:
        requested_mode (str): Requested work mode from CLI or caller.
        promotion_type (str): Promotion or feature type (`feature`, `bug`, etc.).

    Returns:
        str: Canonical work mode (`minor-audit`, `full-feature`, or `full-bug`).

    Raises:
        ValueError: If the request is invalid or incompatible with the type.
    """
    if requested_mode not in ACCEPTED_WORK_MODES:
        raise ValueError(
            "work_mode must be one of: minor-audit, full-feature, full-bug, full"
        )

    if requested_mode == "minor-audit":
        return requested_mode

    is_bug = promotion_type == "bug"
    if requested_mode == LEGACY_FULL_MODE:
        return "full-bug" if is_bug else "full-feature"

    if requested_mode == "full-bug" and not is_bug:
        raise ValueError("full-bug may only be used with bug work")

    if requested_mode == "full-feature" and is_bug:
        raise ValueError("full-feature may not be used with bug work")

    return requested_mode


def parse_issue_work_mode(issue_content: str) -> tuple[str | None, bool]:
    """Parse the work-mode marker from issue.md content.

    Purpose:
        Extract a valid `- Work Mode:` marker value from issue content while
        distinguishing malformed marker lines from truly missing markers.

    Args:
        issue_content (str): Raw `issue.md` file content.

    Returns:
        tuple[str | None, bool]:
            - Parsed mode (`minor-audit`, `full-feature`, `full-bug`, or legacy
              `full`) when valid; otherwise None.
            - Boolean indicating whether a malformed marker line was detected.

    Side Effects:
        None.
    """
    valid_match = re.search(
        r"(?im)^-\s*Work Mode:\s*(minor-audit|full-feature|full-bug|full)\s*$",
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
        marker when present, normalize legacy `full` to `full-feature`, and fail
        closed to `full-feature` for all other states.

    Args:
        issue_content (str | None): Raw issue content, or None when the file is
            unavailable.

    Returns:
        str: `minor-audit`, `full-feature`, or `full-bug`.

    Side Effects:
        None.
    """
    # Decision logic:
    # - If the issue file is unavailable, fail closed immediately.
    # - If a valid marker exists, trust it as the selected mode.
    # - Otherwise, fail closed to full.
    if issue_content is None:
        return "full-feature"

    parsed_mode, _has_malformed_marker = parse_issue_work_mode(issue_content)
    if parsed_mode is not None:
        if parsed_mode == LEGACY_FULL_MODE:
            return "full-feature"
        return parsed_mode

    return "full-feature"


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
        return "issue.md missing; fail closed to full-feature"

    parsed_mode, has_malformed_marker = parse_issue_work_mode(issue_content)
    if parsed_mode is not None:
        if parsed_mode == LEGACY_FULL_MODE:
            return (
                "issue.md Work Mode marker uses legacy full; normalized to full-feature"
            )
        return "none"

    # Branch by marker quality so diagnostics are explicit and actionable.
    if has_malformed_marker:
        return "issue.md Work Mode marker malformed; fail closed to full-feature"

    return "issue.md Work Mode marker missing; fail closed to full-feature"
