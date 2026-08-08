"""Glob, subsumption, and path-overlap primitives behind the blast-radius facade.

Purpose:
    Own the shared string primitives that decide whether one path entry can name
    the same file as another: the fnmatch subset translation, the subsumption
    relation validation rule V1 applies, the wildcard-entry predicates, and the
    contention relation's entry-pair overlap test. This module is the Python
    counterpart of ``.claude/lib/blast-radius/BlastRadiusGlob.psm1``, which
    already grouped exactly these primitives.

Responsibilities:
    Translate the supported glob vocabulary to regex, match a candidate against
    a pattern, decide subsumption of a concrete path by a collection of entries,
    classify an entry as concrete or glob, select the concrete subset of a
    collection, and decide entry-pair overlap. Tokenizing document text belongs
    to ``scripts/dev_tools/_blast_radius_extraction.py``; emitting findings
    belongs to ``scripts/dev_tools/_blast_radius_validation.py``; assembling
    contention results belongs to ``scripts/dev_tools/_blast_radius_conflicts.py``.

Usage:
    ``_blast_radius_validation`` imports ``concrete_entries``,
    ``is_path_subsumed``, and ``matches_glob``; ``_blast_radius_conflicts``
    imports ``_entries_overlap``; the facade
    ``scripts/dev_tools/compute_blast_radius.py`` re-exports
    ``concrete_entries``. The PowerShell mirror reproduces these rules; this
    module remains the authoritative reference.

Invariants / Constraints:
    - This module is a leaf of the blast-radius import graph: it imports no
      ``_blast_radius_*`` sibling, which is what keeps the graph acyclic.
    - The glob vocabulary is a deliberate fnmatch subset (``**``, ``*``, ``?``);
      character classes are unsupported because PowerShell's ``-like`` does not
      agree with fnmatch on their semantics.
    - Every comparison is ordinal and case-sensitive, matching the PowerShell
      mirror's ``[System.StringComparison]::Ordinal``.
    - ``_entries_overlap`` fails closed: a pair the test cannot separate is
      reported as overlapping, because radius under-reporting is the dominant
      risk of the parallel design.

Side Effects:
    None. Every function is pure: no filesystem access, no subprocess, no
    network, and no wall-clock reads.
"""

from __future__ import annotations

import re
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Sequence

# Declared surface of this helper module. ``_literal_prefix`` and
# ``_entries_overlap`` keep their original underscore names because the spec and
# the parity corpus name them, and they are listed here so their use by the
# sibling ``_blast_radius_conflicts`` module is an intentional package-internal
# export rather than private access.
__all__ = [
    "GLOB_WILDCARDS",
    "_entries_overlap",
    "_literal_prefix",
    "concrete_entries",
    "is_glob_entry",
    "is_path_subsumed",
    "matches_glob",
]

# Wildcards that make a path entry a pattern rather than a file. ``?`` is
# included because the subsumption helper treats it as a pattern; admitting it
# here keeps every comparison in the fail-closed direction.
GLOB_WILDCARDS: tuple[str, ...] = ("*", "?")


def _glob_to_regex_text(pattern: str) -> str:
    """Translate the supported glob subset into equivalent regex text.

    Defining the fnmatch subset explicitly lets the PowerShell mirror reproduce
    it exactly; that mirror must not use ``-like``, whose character-class
    semantics differ from fnmatch.

    Args:
        pattern (str): Glob pattern. ``**`` matches any run of characters
            including separators, ``*`` matches any run excluding separators,
            ``?`` matches one non-separator character, and every other
            character, including ``[`` and ``]``, is literal.

    Returns:
        str: Regex source text matching the same strings as the pattern when
        applied as a full match.

    Raises:
        None.

    Side Effects:
        None.
    """
    parts: list[str] = []
    index = 0

    # Scan one character at a time so the two-character ``**`` token is
    # recognized before the single-character ``*`` rule applies; the order
    # matters because only ``**`` may cross directory separators.
    while index < len(pattern):
        if pattern.startswith("**", index):
            parts.append(".*")
            index += 2
            continue

        character = pattern[index]
        if character == "*":
            parts.append("[^/]*")
        elif character == "?":
            parts.append("[^/]")
        else:
            parts.append(re.escape(character))
        index += 1

    return "".join(parts)


def matches_glob(pattern: str, candidate: str) -> bool:
    """Report whether a candidate path matches a glob pattern.

    Args:
        pattern (str): Glob using the supported ``**``, ``*``, ``?`` vocabulary.
        candidate (str): Concrete repository-relative path to test.

    Returns:
        bool: ``True`` when the whole candidate matches the whole pattern.

    Raises:
        None.

    Side Effects:
        None.
    """
    return re.fullmatch(_glob_to_regex_text(pattern), candidate) is not None


def is_path_subsumed(path: str, covering_paths: Sequence[str]) -> bool:
    """Report whether a concrete path is covered by a collection of entries.

    Implements the coverage relation validation rule V1 applies: exact match,
    listed-directory prefix, or glob match.

    Args:
        path (str): Concrete repository-relative path to test.
        covering_paths (Sequence[str]): Declared path entries, which may mix
            concrete paths, directory names, and glob patterns.

    Returns:
        bool: ``True`` when at least one entry covers the path. An empty
        collection covers nothing, so the result is ``False``.

    Raises:
        None.

    Side Effects:
        None; the input sequence is not mutated.
    """
    # Test entries in order and return on the first cover; the three rules are
    # independent, so traversal order affects speed only, never the verdict.
    for entry in covering_paths:
        if entry == path:
            return True

        # A wildcard entry is a pattern matched with the shared glob subset. A
        # wildcard-free entry cannot be a pattern, so it is treated as a listed
        # directory covering everything beneath it.
        if "*" in entry or "?" in entry:
            if matches_glob(entry, path):
                return True
        elif path.startswith(entry.rstrip("/") + "/"):
            return True

    return False


def is_glob_entry(entry: str) -> bool:
    """Report whether a path entry is a wildcard pattern rather than a file.

    Args:
        entry (str): A ``paths`` entry from a radius or an extraction.

    Returns:
        bool: ``True`` when the entry carries any wildcard character.
    """
    return any(wildcard in entry for wildcard in GLOB_WILDCARDS)


def concrete_entries(entries: Sequence[str]) -> tuple[str, ...]:
    """Select the wildcard-free entries of a path collection.

    Only concrete entries can be compared for equality, so the rules that count
    files or enumerate surfaces use this subset.

    Args:
        entries (Sequence[str]): Entries mixing concrete paths and globs.

    Returns:
        tuple[str, ...]: Concrete entries in input order, already ordinal for
        any radius or extraction result.
    """
    return tuple(entry for entry in entries if not is_glob_entry(entry))


def _literal_prefix(entry: str) -> str:
    """Return the leading portion of a path entry before its first wildcard.

    Args:
        entry (str): A path entry that may contain wildcards.

    Returns:
        str: The literal prefix; the whole entry when it has no wildcard.
    """
    # Scanning for the earliest wildcard of any kind keeps the prefix a true
    # literal, which is what makes the disjointness test sound.
    for index, character in enumerate(entry):
        if is_glob_entry(character):
            return entry[:index]

    return entry


def _directory_prefix(entry: str) -> str:
    """Return the entry read as a directory, anchored with a trailing separator.

    Anchoring on ``/`` is what keeps the containment test sound: without it,
    ``scripts/dev_tools`` would appear to contain ``scripts/dev_toolsX/a.py``,
    because the sibling name shares a character prefix. Normalizing a trailing
    separator first makes ``scripts/dev_tools`` and ``scripts/dev_tools/``
    produce the same anchor.

    Args:
        entry (str): A concrete path entry, with or without a trailing ``/``.

    Returns:
        str: The entry with exactly one trailing ``/``.

    Raises:
        None.

    Side Effects:
        None.
    """
    return entry.rstrip("/") + "/"


def _prefixes_nest(left: str, right: str) -> bool:
    """Report whether either prefix is a prefix of the other.

    The test is deliberately two-way. A glob's literal prefix may sit above the
    concrete entry's directory (``scripts/`` above ``scripts/dev_tools/``) or
    below it (``scripts/dev_tools/`` below ``scripts/``), and both arrangements
    admit a common file, so a one-directional test would under-report.

    Args:
        left (str): First prefix, ordinally compared.
        right (str): Second prefix, ordinally compared.

    Returns:
        bool: ``True`` when the prefixes nest in either direction.

    Raises:
        None.

    Side Effects:
        None.
    """
    return left.startswith(right) or right.startswith(left)


def _entries_overlap(entry_a: str, entry_b: str) -> bool:
    """Report whether two path entries can name a common file.

    Glob-versus-glob containment is undecidable in general, so that case is
    decided conservatively from literal prefixes: the pair overlaps unless the
    prefixes diverge, which no single path could satisfy. Any pair the test
    cannot separate is reported as overlapping, the fail-closed direction.

    Args:
        entry_a (str): First path entry, concrete or glob.
        entry_b (str): Second path entry, concrete or glob.

    Returns:
        bool: ``True`` when the entries overlap; the relation is symmetric.
    """
    a_is_glob = is_glob_entry(entry_a)
    b_is_glob = is_glob_entry(entry_b)

    # The cases are decided by how many sides are patterns: two concrete entries
    # overlap when equal or when either names a directory containing the other,
    # a mixed pair overlaps on a pattern match or on a two-way nest between the
    # glob's literal prefix and the concrete entry's directory, and a pattern
    # pair falls back to the conservative prefix proof. The two directory rules
    # were added by issue #452; without them a plan citing a directory failed to
    # contend with a plan citing a file inside it, which under-reported the
    # radius in the one direction the design cannot tolerate.
    if not a_is_glob and not b_is_glob:
        return (
            entry_a == entry_b
            or entry_a.startswith(_directory_prefix(entry_b))
            or entry_b.startswith(_directory_prefix(entry_a))
        )
    if a_is_glob and not b_is_glob:
        return matches_glob(entry_a, entry_b) or _prefixes_nest(
            _literal_prefix(entry_a), _directory_prefix(entry_b)
        )
    if b_is_glob and not a_is_glob:
        return matches_glob(entry_b, entry_a) or _prefixes_nest(
            _literal_prefix(entry_b), _directory_prefix(entry_a)
        )

    prefix_a = _literal_prefix(entry_a)
    prefix_b = _literal_prefix(entry_b)
    return prefix_a.startswith(prefix_b) or prefix_b.startswith(prefix_a)
