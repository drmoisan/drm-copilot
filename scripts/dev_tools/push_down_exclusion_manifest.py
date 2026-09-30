"""Parse and apply the destination-owned push-down exclusion manifest.

Purpose:
    Hold the pure logic behind ``.push-down-exclusions``: the manifest grammar,
    entry normalization, the path matcher, and the first-match exclusion plan
    that partitions a payload into kept and skipped paths. The module performs
    no I/O; the filesystem decorator in ``push_down_claude_exclusion_filter``
    reads the manifest and applies this plan at enumeration time.

Invariants / Constraints:
    - Entries are destination-relative POSIX paths compared ordinally and
      case-sensitively against payload path strings.
    - A wildcard-free entry matches the path itself and every path beneath it;
      a trailing ``/`` documents intent only.
    - A wildcard entry uses the ``_blast_radius_glob`` vocabulary (``**``,
      ``*``, ``?``) and must match the whole candidate.
    - Entries are evaluated in manifest order; the first match wins.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING, Literal

try:
    from scripts.dev_tools._blast_radius_glob import matches_glob
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools._blast_radius_glob import matches_glob

if TYPE_CHECKING:
    from collections.abc import Callable, Iterable, Sequence

__all__ = [
    "EXCLUSION_MANIFEST_RELATIVE_PATH",
    "DestinationStatus",
    "ExclusionEntry",
    "ExclusionEntryKind",
    "ExclusionManifest",
    "ExclusionManifestError",
    "ExclusionPlan",
    "SkippedPath",
    "assert_manifest_path_is_root_level",
    "find_first_match",
    "matches_exclusion_entry",
    "normalize_exclusion_entry",
    "parse_exclusion_manifest",
    "plan_exclusions",
    "unmatched_exclusion_entries",
]

# Destination-root location of the manifest. It sits outside every published
# root, so the engines can never enumerate it as a payload path.
EXCLUSION_MANIFEST_RELATIVE_PATH = ".push-down-exclusions"

ExclusionEntryKind = Literal["exact", "directory", "glob"]
DestinationStatus = Literal["present", "absent"]

_BYTE_ORDER_MARK = "﻿"
_WILDCARDS: tuple[str, ...] = ("*", "?")
_LINE_SPLIT = re.compile(r"\r?\n")
_REPEATED_SLASH = re.compile(r"/{2,}")
_DRIVE_PREFIX = re.compile(r"^[A-Za-z]:")


class ExclusionManifestError(ValueError):
    """Raised when the exclusion manifest cannot be trusted.

    Purpose:
        Fail the push-down before any destination write when the manifest is
        not a regular file, is not decodable, or holds a malformed entry.

    Attributes:
        path (str): Destination-relative manifest path.
        line (int | None): 1-based offending line, or ``None`` when the
            condition concerns the whole file.
    """

    def __init__(self, path: str, line: int | None, reason: str) -> None:
        """Build the error message from the manifest path, line, and reason."""

        location = path if line is None else f"{path} line {line}"
        super().__init__(f"Malformed push-down exclusion manifest {location}: {reason}")
        self.path = path
        self.line = line


@dataclass(frozen=True, slots=True)
class ExclusionEntry:
    """One parsed manifest entry.

    Attributes:
        raw (str): The line text as written, without the line terminator.
        normalized (str): The normalized destination-relative entry.
        kind (ExclusionEntryKind): ``exact``, ``directory``, or ``glob``.
        line (int): 1-based line number in the manifest.
    """

    raw: str
    normalized: str
    kind: ExclusionEntryKind
    line: int


@dataclass(frozen=True, slots=True)
class ExclusionManifest:
    """A parsed manifest: its relative path and entries in file order."""

    path: str
    entries: tuple[ExclusionEntry, ...]


@dataclass(frozen=True, slots=True)
class SkippedPath:
    """A payload path withheld from the destination by a manifest entry.

    Attributes:
        relative_path (str): Destination-relative POSIX path that was skipped.
        entry (str): Normalized text of the first matching entry.
        line (int): Manifest line of that entry.
        destination_status (DestinationStatus): ``present`` when the
            destination already holds a regular file at the path (a conflict).
    """

    relative_path: str
    entry: str
    line: int
    destination_status: DestinationStatus


@dataclass(frozen=True, slots=True)
class ExclusionPlan:
    """The partition of a payload produced by ``plan_exclusions``."""

    kept: tuple[str, ...]
    skipped: tuple[SkippedPath, ...]
    unmatched_entries: tuple[ExclusionEntry, ...]


def normalize_exclusion_entry(raw: str) -> str:
    """Normalize one entry: trim, ``\\`` to ``/``, drop ``./``, collapse ``/``.

    Args:
        raw (str): Entry text as written in the manifest.

    Returns:
        str: The normalized entry; empty when nothing remains.
    """

    text = raw.strip().replace("\\", "/")
    if text.startswith("./"):
        text = text[2:]
    return _REPEATED_SLASH.sub("/", text)


def _malformed_reason(normalized: str) -> str | None:
    """Return why a normalized entry is malformed, or ``None`` when valid."""

    has_wildcard = any(wildcard in normalized for wildcard in _WILDCARDS)
    # Checks run in a fixed order so the reported reason is deterministic.
    checks: tuple[tuple[bool, str], ...] = (
        (normalized == "", "entry is empty after normalization"),
        (
            normalized.startswith("/") or _DRIVE_PREFIX.match(normalized) is not None,
            "entry is an absolute path",
        ),
        (".." in normalized.split("/"), "entry contains a '..' segment"),
        (normalized.startswith("!"), "negation entries are not supported"),
        (
            "[" in normalized or "]" in normalized,
            "character classes are not supported",
        ),
        (
            has_wildcard and normalized.endswith("/"),
            "a wildcard entry must not end with '/'",
        ),
    )
    for failed, reason in checks:
        if failed:
            return reason
    return None


def _classify(normalized: str) -> ExclusionEntryKind:
    """Classify a valid normalized entry by the matcher it uses."""

    if any(wildcard in normalized for wildcard in _WILDCARDS):
        return "glob"
    if normalized.endswith("/"):
        return "directory"
    return "exact"


def parse_exclusion_manifest(text: str, path: str) -> ExclusionManifest:
    """Parse manifest text into entries, failing fast on a malformed entry.

    Args:
        text (str): Manifest content; a leading byte-order mark is ignored.
        path (str): Destination-relative manifest path used in errors.

    Returns:
        ExclusionManifest: The entries in file order with 1-based lines.

    Raises:
        ExclusionManifestError: On the first malformed entry.
    """

    if text.startswith(_BYTE_ORDER_MARK):
        text = text[len(_BYTE_ORDER_MARK) :]
    entries: list[ExclusionEntry] = []
    for index, raw in enumerate(_LINE_SPLIT.split(text), start=1):
        stripped = raw.strip()
        # Blank lines and comment lines carry no entry but still count lines.
        if stripped == "" or stripped.startswith("#"):
            continue
        normalized = normalize_exclusion_entry(raw)
        reason = _malformed_reason(normalized)
        if reason is not None:
            raise ExclusionManifestError(path, index, reason)
        entries.append(
            ExclusionEntry(
                raw=raw,
                normalized=normalized,
                kind=_classify(normalized),
                line=index,
            )
        )
    return ExclusionManifest(path=path, entries=tuple(entries))


def matches_exclusion_entry(entry: ExclusionEntry, candidate: str) -> bool:
    """Report whether a destination-relative candidate matches an entry.

    Args:
        entry (ExclusionEntry): Parsed manifest entry.
        candidate (str): Destination-relative POSIX payload path.

    Returns:
        bool: ``True`` on an exact, directory-prefix, or whole-glob match.
    """

    if entry.kind == "glob":
        return matches_glob(entry.normalized, candidate)
    base = entry.normalized.rstrip("/")
    return candidate == base or candidate.startswith(base + "/")


def find_first_match(
    manifest: ExclusionManifest, candidate: str
) -> ExclusionEntry | None:
    """Return the first entry in manifest order that matches the candidate."""

    for entry in manifest.entries:
        if matches_exclusion_entry(entry, candidate):
            return entry
    return None


def unmatched_exclusion_entries(
    manifest: ExclusionManifest, skipped: Iterable[SkippedPath]
) -> tuple[ExclusionEntry, ...]:
    """Return the entries that are the first match of no skipped path.

    A shadowed entry, one whose paths an earlier entry already claimed, is
    therefore reported as unmatched, keeping the report self-consistent.
    """

    claimed = {(skip.entry, skip.line) for skip in skipped}
    return tuple(
        entry
        for entry in manifest.entries
        if (entry.normalized, entry.line) not in claimed
    )


def plan_exclusions(
    payload_relative_paths: Sequence[str],
    manifest: ExclusionManifest,
    destination_exists: Callable[[str], bool],
) -> ExclusionPlan:
    """Partition payload paths into kept and skipped using first-match order.

    Args:
        payload_relative_paths (Sequence[str]): Destination-relative payload
            paths in enumeration order.
        manifest (ExclusionManifest): Parsed manifest.
        destination_exists (Callable[[str], bool]): Probe reporting whether the
            destination holds a regular file at a relative path; called only
            for skipped paths.

    Returns:
        ExclusionPlan: Kept paths, skipped records, and unmatched entries, each
        in input or manifest order.
    """

    kept: list[str] = []
    skipped: list[SkippedPath] = []
    for relative_path in payload_relative_paths:
        entry = find_first_match(manifest, relative_path)
        if entry is None:
            kept.append(relative_path)
            continue
        status: DestinationStatus = (
            "present" if destination_exists(relative_path) else "absent"
        )
        skipped.append(
            SkippedPath(
                relative_path=relative_path,
                entry=entry.normalized,
                line=entry.line,
                destination_status=status,
            )
        )
    return ExclusionPlan(
        kept=tuple(kept),
        skipped=tuple(skipped),
        unmatched_entries=unmatched_exclusion_entries(manifest, skipped),
    )


def assert_manifest_path_is_root_level(
    relative_path: str, root_folders: Sequence[str]
) -> None:
    """Assert the manifest path lies at the destination root, outside payload roots.

    Args:
        relative_path (str): Manifest path relative to the destination root.
        root_folders (Sequence[str]): Published root folder names.

    Raises:
        ValueError: When the path contains ``/`` or begins with a root name.
    """

    if "/" in relative_path:
        raise ValueError(f"Exclusion manifest path must be root-level: {relative_path}")
    for root in root_folders:
        if relative_path.startswith(root):
            raise ValueError(
                "Exclusion manifest path must not begin with published root "
                f"{root}: {relative_path}"
            )
