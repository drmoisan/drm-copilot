"""Destination ``.gitignore`` merge and delivery for the Claude push-down.

Purpose:
    Port ``mergeClaudeGitignore`` from
    ``extensions/drm-copilot/src/lib/push-down/claude-gitignore-merge.ts`` and
    ``deliverDestinationGitignore`` from ``claude-customizations.ts`` so a
    Python push-down leaves the same drm-copilot managed ignore block in the
    destination ``.gitignore`` as the TypeScript push-down (issue #790).

Placement (decision D3):
    ``deliver_destination_gitignore`` lives in this module rather than in
    ``push_down_claude_customizations`` because the entry module is at the
    500-line limit. TypeScript keeps the delivery in its entry module.

CRLF limitation (decision D2):
    ``RealPushDownFileSystem.read_text`` applies universal-newline translation.
    A CRLF destination ``.gitignore`` that already holds an up-to-date block is
    therefore read as LF text equal to the merged text, is not rewritten, and
    keeps its CRLF line endings. TypeScript reads raw text and rewrites such a
    file as LF. Whenever any change is needed, both implementations write
    LF-only text.

Side Effects:
    ``merge_claude_gitignore`` is pure. ``deliver_destination_gitignore``
    performs I/O only through the injected ``PushDownFileSystem``.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

try:
    from scripts.dev_tools.push_down_exclusion_manifest import (
        SkippedPath,
        find_first_match,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_exclusion_manifest import SkippedPath, find_first_match

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
    )
    from scripts.dev_tools.push_down_exclusion_manifest import ExclusionManifest

__all__ = [
    "GITIGNORE_BEGIN_SENTINEL",
    "GITIGNORE_END_SENTINEL",
    "GITIGNORE_RELATIVE_PATH",
    "MANAGED_IGNORE_ENTRIES",
    "deliver_destination_gitignore",
    "merge_claude_gitignore",
]

# Destination-relative path of the file this module merges.
GITIGNORE_RELATIVE_PATH = ".gitignore"
# Lines that open and close the drm-copilot managed ignore block.
GITIGNORE_BEGIN_SENTINEL = "# BEGIN drm-copilot managed ignores"
GITIGNORE_END_SENTINEL = "# END drm-copilot managed ignores"
# Runtime-state directories the push-down manages, in emission order.
MANAGED_IGNORE_ENTRIES: tuple[str, ...] = (".claude/state/", ".codex/state/")

_LINE_SEPARATOR = "\n"
_LINE_ENDING = re.compile(r"\r\n?")


def _to_lines(normalized: str) -> list[str]:
    """Split LF text into lines, dropping the one empty element a final LF leaves."""

    if normalized == "":
        return []
    lines = normalized.split(_LINE_SEPARATOR)
    if lines[-1] == "":
        lines.pop()
    return lines


def _to_document(lines: list[str]) -> str:
    """Join lines with LF and terminate the document with exactly one LF."""

    return _LINE_SEPARATOR.join(lines) + _LINE_SEPARATOR


def _managed_block() -> list[str]:
    """Return the managed block, sentinels included, as a list of lines."""

    return [GITIGNORE_BEGIN_SENTINEL, *MANAGED_IGNORE_ENTRIES, GITIGNORE_END_SENTINEL]


def _append_managed_block(lines: list[str]) -> str:
    """Append the block after one blank line, or return it alone for no content."""

    trimmed = list(lines)
    while trimmed and trimmed[-1] == "":
        trimmed.pop()
    if not trimmed:
        return _to_document(_managed_block())
    return _to_document([*trimmed, "", *_managed_block()])


def merge_claude_gitignore(current_text: str) -> str:
    """Merge the managed ignore block into destination ``.gitignore`` text.

    Args:
        current_text (str): Current destination text; ``""`` represents an
            absent file.

    Returns:
        str: LF-only, newline-terminated merged text. Applying the function to
        its own output returns that output unchanged.
    """

    lines = _to_lines(_LINE_ENDING.sub(_LINE_SEPARATOR, current_text))
    if GITIGNORE_BEGIN_SENTINEL not in lines:
        return _append_managed_block(lines)
    begin_index = lines.index(GITIGNORE_BEGIN_SENTINEL)
    # Only an END sentinel at or after the first BEGIN closes the block; without
    # one, the block is the BEGIN line alone and later lines are kept.
    following = lines[begin_index:]
    end_index = (
        begin_index + following.index(GITIGNORE_END_SENTINEL)
        if GITIGNORE_END_SENTINEL in following
        else begin_index
    )
    return _to_document(
        [*lines[:begin_index], *_managed_block(), *lines[end_index + 1 :]]
    )


def deliver_destination_gitignore(
    fs: PushDownFileSystem,
    destination_root: Path,
    manifest: ExclusionManifest | None,
) -> SkippedPath | None:
    """Merge the managed block into ``<destination>/.gitignore`` after the copy.

    Args:
        fs (PushDownFileSystem): Raw injected adapter (not a decorator), so the
            exclusion write guard does not apply to this write.
        destination_root (Path): Destination workspace root.
        manifest (ExclusionManifest | None): Destination exclusion manifest.

    Returns:
        SkippedPath | None: The skip record when a manifest entry matches
        ``.gitignore`` (no read and no write are performed); otherwise ``None``.

    Side Effects:
        Reads the destination ``.gitignore`` and writes it only when the merged
        text differs from the text read.
    """

    destination_path = destination_root / GITIGNORE_RELATIVE_PATH
    entry = (
        None
        if manifest is None
        else find_first_match(manifest, GITIGNORE_RELATIVE_PATH)
    )
    if entry is not None:
        return SkippedPath(
            relative_path=GITIGNORE_RELATIVE_PATH,
            entry=entry.normalized,
            line=entry.line,
            destination_status="present" if fs.is_file(destination_path) else "absent",
        )
    current_text = (
        fs.read_text(destination_path) if fs.is_file(destination_path) else ""
    )
    merged_text = merge_claude_gitignore(current_text)
    if merged_text != current_text:
        fs.write_text(destination_path, merged_text)
    return None
