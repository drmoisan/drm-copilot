"""Destination scan for the blast-radius derivation (algorithm step 1).

Purpose:
    Python port of the scan half of
    ``extensions/drm-copilot/src/lib/push-down/claude-blast-radius-derive.ts``.
    Collect a deterministic observation list by a depth-limited breadth-first
    scan of the destination root. Steps 2 through 8 belong to the pure core
    ``push_down_claude_blast_radius_derive_core``.

Tolerance rule (pinned, identical to TypeScript):
    A listing failure at any level, including on the destination root itself,
    contributes no entries and does not fail the derivation. An in-memory test
    destination such as ``/dest`` cannot be seen by the real-filesystem lister,
    so a root-level failure must degrade to zero observations, which the core's
    payload floor then handles.

Side Effects:
    ``real_directory_lister`` reads directory listings from the real filesystem.
    ``collect_destination_observations`` performs I/O only through the lister it
    is given.
"""

from __future__ import annotations

import os
from collections.abc import Callable, Sequence
from dataclasses import dataclass
from typing import TYPE_CHECKING

try:
    from scripts.dev_tools.push_down_claude_blast_radius_derive_core import (
        SCAN_DEPTH_LIMIT,
        DirectoryObservation,
    )
    from scripts.dev_tools.push_down_claude_blast_radius_derive_manifests import (
        is_excluded_directory_name,
    )
except ModuleNotFoundError as error:  # pragma: no cover - bundled import fallback
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.push_down_claude_blast_radius_derive_core import (
        SCAN_DEPTH_LIMIT,
        DirectoryObservation,
    )
    from dev_tools.push_down_claude_blast_radius_derive_manifests import (
        is_excluded_directory_name,
    )

if TYPE_CHECKING:
    from pathlib import Path

__all__ = [
    "DirectoryEntry",
    "DirectoryLister",
    "collect_destination_observations",
    "real_directory_lister",
]


@dataclass(frozen=True)
class DirectoryEntry:
    """One entry of a shallow directory listing.

    Attributes:
        name (str): Entry name, not a path.
        is_dir (bool): ``True`` when the entry is a directory.
    """

    name: str
    is_dir: bool


# Shallow directory lister seam: returns the entries directly inside a root.
DirectoryLister = Callable[["Path"], Sequence[DirectoryEntry]]


def real_directory_lister(root: Path) -> list[DirectoryEntry]:
    """List a real directory, ordinally sorted by name.

    Args:
        root (Path): Absolute directory to list.

    Returns:
        list[DirectoryEntry]: Entries directly inside ``root`` sorted by name;
        an empty list when the directory cannot be read.
    """

    try:
        with os.scandir(root) as iterator:
            entries = [DirectoryEntry(entry.name, entry.is_dir()) for entry in iterator]
    except OSError:
        # An unreadable directory contributes no entries (tolerance rule).
        return []
    return sorted(entries, key=lambda entry: entry.name)


def _list_tolerantly(lister: DirectoryLister, path: Path) -> Sequence[DirectoryEntry]:
    """Call a lister without letting its failure abort the derivation.

    The broad handler is the pinned tolerance rule (TypeScript
    ``claude-blast-radius-derive.ts`` lines 27-35): an injected lister may fail
    in any way on an unreadable directory, and every failure is treated as a
    listing with zero entries so the scan and the default lister agree.
    """

    try:
        return lister(path)
    except Exception:
        return []


def collect_destination_observations(
    destination_root: Path, lister: DirectoryLister
) -> list[DirectoryObservation]:
    """Collect the destination observation list (algorithm step 1).

    Breadth-first from the destination root to ``SCAN_DEPTH_LIMIT``, visiting
    subdirectories in listing order and pruning excluded and dot-prefixed
    names, so the list is a pure function of the visible layout.

    Args:
        destination_root (Path): Destination workspace root.
        lister (DirectoryLister): Shallow directory lister.

    Returns:
        list[DirectoryObservation]: One observation per visited directory, the
        root first.
    """

    observations: list[DirectoryObservation] = []
    # Depth 1 is the root, so the bound admits the root plus two nested levels.
    queue: list[tuple[Path, str]] = [(destination_root, "")]
    depth = 1
    while depth <= SCAN_DEPTH_LIMIT and queue:
        next_queue: list[tuple[Path, str]] = []
        for path, relative_path in queue:
            file_names: list[str] = []
            for entry in _list_tolerantly(lister, path):
                if not entry.is_dir:
                    file_names.append(entry.name)
                    continue
                if is_excluded_directory_name(entry.name):
                    continue
                child_relative = (
                    entry.name
                    if relative_path == ""
                    else f"{relative_path}/{entry.name}"
                )
                next_queue.append((path / entry.name, child_relative))
            observations.append(DirectoryObservation(relative_path, tuple(file_names)))
        queue = next_queue
        depth += 1
    return observations
