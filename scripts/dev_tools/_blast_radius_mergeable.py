"""Mechanically-mergeable path exclusion applied inside the contention relation.

Purpose:
    Own the reader and the matcher for ``config["mergeable_paths"]``, the class
    of project-file shapes whose overlap a merge step can reconcile without
    re-delegating the work (issue #643). Two items touching the same ``.csproj``
    are not genuinely in contention, so this class is removed from both radii
    immediately before the contention relation compares them.

Responsibilities:
    Read the optional key, decide class membership for one entry, and drop the
    class from a collection. Glob translation belongs to ``_blast_radius_glob``,
    the read-by-mandate exclusion to ``_blast_radius_normalization``, and
    contention assembly to ``_blast_radius_conflicts``, which applies both
    public helpers here where the smallest path overlap is computed.
    ``compute_blast_radius`` re-exports the reader; the mirror
    ``.claude/lib/blast-radius/BlastRadiusConflict.psm1`` reproduces the rules.

Invariants / Constraints:
    - The exclusion is applied ONLY inside the contention relation, and changes
      no radius record: a derived, declared, or observed radius still lists every
      project file it cited, so drift detection and validation see the paths they
      saw before this key existed.
    - The key is optional and fail-closed: an absent key and an empty list both
      exclude nothing and reproduce pre-change behaviour exactly.
    - Every comparison is ordinal and case-sensitive, matching the mirror and
      its ``[System.StringComparison]::Ordinal`` comparisons.

Side Effects:
    None. Every function is pure: no I/O, no subprocess, no wall-clock read.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools._blast_radius_glob import is_glob_entry, matches_glob
from scripts.dev_tools._blast_radius_normalization import matches_mandate_read
from scripts.dev_tools._blast_radius_validation import config_string_list

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

__all__ = [
    "CONFIG_MERGEABLE_PATHS",
    "config_mergeable_paths",
    "exclude_mergeable_paths",
    "matches_mergeable_path",
]

# Truth-table key naming the class, declared as a constant so the reader, its
# tests, and the PowerShell mirror all name one string rather than a literal.
CONFIG_MERGEABLE_PATHS = "mergeable_paths"

# Prefix making a pattern match at any depth. It is stripped in the third
# matching step so a root-level file can satisfy it; see the matcher below.
_ANY_DEPTH_PREFIX = "**/"


def config_mergeable_paths(config: Mapping[str, object]) -> tuple[str, ...]:
    """Read the mechanically-mergeable path list from the truth table.

    Args:
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``. Only
            the ``mergeable_paths`` key is read; entries are project-file
            shapes, normally anchored globs such as ``**/*.csproj``.

    Returns:
        tuple[str, ...]: The configured entries, sorted and deduplicated. An
        absent key yields an empty tuple, which excludes nothing.

    Raises:
        TypeError: If the value is present but is not a list of strings.
        ValueError: If an entry is blank.

    Side Effects:
        None; the mapping is not mutated.
    """
    return config_string_list(config, CONFIG_MERGEABLE_PATHS)


def matches_mergeable_path(entry: str, mergeable: Sequence[str]) -> bool:
    """Report whether one radius entry belongs to the mergeable path class.

    Three comparisons apply in order. The first two are the read-by-mandate
    rules, delegated rather than restated: ordinal equality, the only rule that
    can settle a glob entry, then glob containment for a concrete entry only.
    The third is specific to this class, because an anchored pattern requires a
    separator and so excludes a root-level file; retesting a concrete entry with
    the anchor removed admits ``packages.config`` at the repository root while
    leaving the glob vocabulary untouched. A glob entry is never mergeable
    unless it equals a configured pattern character for character, because
    pattern subsumption is not a comparison this vocabulary supports.

    Args:
        entry (str): One radius ``paths`` entry, concrete path or glob pattern.
        mergeable (Sequence[str]): Configured patterns, from
            ``config_mergeable_paths``. An empty collection matches nothing.

    Returns:
        bool: ``True`` when the entry belongs to the mergeable class and is
        therefore excluded from the contention comparison.

    Side Effects:
        None; the sequence is not mutated.
    """
    # Steps one and two are the mandate-read rules verbatim, reused rather than
    # duplicated: a divergence would silently split two exclusions that share a
    # vocabulary.
    if matches_mandate_read(entry, mergeable):
        return True

    # A glob entry that did not match exactly is left alone. Only a concrete
    # path reaches the anchor-stripping step.
    if is_glob_entry(entry):
        return False

    # Retest against each anchored pattern with its anchor removed, which is the
    # only way a root-level file can satisfy an anchored pattern.
    for pattern in mergeable:
        if not pattern.startswith(_ANY_DEPTH_PREFIX):
            continue

        stripped = pattern[len(_ANY_DEPTH_PREFIX) :]
        # A stripped pattern that still carries a wildcard is a glob and is
        # matched as one; a wildcard-free remainder can only be compared for
        # ordinal equality.
        if is_glob_entry(stripped):
            if matches_glob(stripped, entry):
                return True
        elif stripped == entry:
            return True

    return False


def exclude_mergeable_paths(
    entries: Sequence[str], mergeable: Sequence[str]
) -> tuple[str, ...]:
    """Drop every mechanically-mergeable entry from a collection of paths.

    Args:
        entries (Sequence[str]): Radius ``paths`` entries to filter. The caller
            passes the content by value; the radius record is never rewritten.
        mergeable (Sequence[str]): Configured patterns, from
            ``config_mergeable_paths``. An empty collection excludes nothing.

    Returns:
        tuple[str, ...]: The survivors, deduplicated and ordinally sorted so the
        result is comparable across both language runtimes.

    Side Effects:
        None; the sequences are not mutated.
    """
    # Collect into a set so a radius listing the same path twice does not change
    # the comparison, matching the mandate-read filter contract.
    survivors = {
        entry for entry in entries if not matches_mergeable_path(entry, mergeable)
    }
    return tuple(sorted(survivors))
