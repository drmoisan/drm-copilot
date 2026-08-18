"""Read-by-mandate exclusion helpers for blast-radius entry collections.

Purpose and responsibilities:
    Hold the pure predicate and filter that remove read-by-mandate citations
    from a harvested or extracted path collection. Every agent is instructed to
    read the policy rules, the tier map, and the process artifacts before doing
    any work, so a citation of one of those paths is evidence that the author
    obeyed the reading order rather than evidence that the change will write the
    file. Counting such citations as contention made thematically unrelated work
    items collide (issue #489).

Usage:
    ``derive_blast_radius`` and ``validate_blast_radius`` both call
    ``exclude_mandate_reads`` over the same ``config_mandate_reads(config)``
    result, which is what keeps a derived radius passing V1 and V2 against its
    own plan. ``scripts/dev_tools/compute_blast_radius.py`` also calls it from
    ``normalize_declared_radius``.

Invariants, constraints, and side effects:
    Only the glob vocabulary is imported, and never
    ``_blast_radius_validation``; guarding a caller-supplied value is the
    caller's job through ``scripts/dev_tools/_blast_radius_guards.py``. That
    keeps this module a leaf and prevents an import cycle, since
    ``_blast_radius_validation`` imports it. Every function is pure and mutates
    no input, and an empty mandate-read collection excludes nothing, which
    reproduces pre-change behaviour exactly. No filesystem, subprocess,
    network, or wall-clock access.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools._blast_radius_glob import is_glob_entry, matches_glob

if TYPE_CHECKING:
    from collections.abc import Sequence


def matches_mandate_read(entry: str, mandate_reads: Sequence[str]) -> bool:
    """Report whether one radius entry is a read-by-mandate citation.

    Three comparisons are applied, in the order they are cheapest and most
    specific. Exact ordinal equality settles both a concrete path listed
    verbatim and a glob entry that repeats a configured glob character for
    character. Glob containment then covers a concrete path that falls inside a
    configured subtree pattern such as ``artifacts/**``. A glob entry is
    deliberately never tested for containment in another glob: deciding whether
    one pattern subsumes another is not a comparison this repository's glob
    vocabulary supports, and guessing would silently drop a genuine claim.

    Args:
        entry (str): One harvested or extracted radius entry. May be a concrete
            repository-relative path or a glob pattern.
        mandate_reads (Sequence[str]): Configured mandate-read patterns, from
            ``config_mandate_reads``. An empty collection matches nothing.

    Returns:
        bool: ``True`` when the entry is a read-by-mandate citation and must be
        excluded from contention.

    Raises:
        None.

    Side Effects:
        None; the input sequence is not mutated.
    """
    # Exact equality first: it is the only rule that can settle a glob entry,
    # and it is also the common case for a listed file such as
    # ``quality-tiers.yml``.
    for pattern in mandate_reads:
        if entry == pattern:
            return True

    # A glob entry that did not match exactly is left alone; only a concrete
    # path is tested for containment in a configured subtree pattern.
    if is_glob_entry(entry):
        return False

    return any(matches_glob(pattern, entry) for pattern in mandate_reads)


def exclude_mandate_reads(
    entries: Sequence[str], mandate_reads: Sequence[str]
) -> tuple[str, ...]:
    """Drop every read-by-mandate citation from a collection of radius entries.

    Args:
        entries (Sequence[str]): Harvested or extracted radius entries.
        mandate_reads (Sequence[str]): Configured mandate-read patterns, from
            ``config_mandate_reads``. An empty collection excludes nothing, so
            the returned content equals the input content.

    Returns:
        tuple[str, ...]: The surviving entries, deduplicated and ordinally
        sorted so the result is comparable across both language runtimes.

    Raises:
        None.

    Side Effects:
        None; the input sequences are not mutated.
    """
    survivors = {
        entry for entry in entries if not matches_mandate_read(entry, mandate_reads)
    }
    return tuple(sorted(survivors))
