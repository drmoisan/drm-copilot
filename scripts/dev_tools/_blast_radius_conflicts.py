"""The fail-closed contention relation between two blast radii.

Purpose and responsibilities:
    Carry the contention half of the facade
    ``scripts/dev_tools/compute_blast_radius.py`` so every production module
    stays inside the 500-line limit. This module owns the ``ConflictReason`` and
    ``ConflictResult`` records, the four-disjunct ``conflicts`` relation, and
    the path-overlap primitives it needs. Building radius objects and emitting
    validation findings belong to the facade and to
    ``scripts/dev_tools/_blast_radius_validation.py``.

Usage:
    The facade re-exports all three public names, so a scheduler imports the
    whole surface from one module and never depends on this file directly.

Invariants, constraints, and side effects:
    The relation fails closed: a glob pair that cannot be proven disjoint counts
    as overlapping, because radius under-reporting is the dominant risk of the
    parallel design. Reasons are reported in ``CONFLICT_KINDS`` order and the
    result is symmetric in its two arguments, verdict and reasons alike. The
    PowerShell mirror reproduces these semantics; this module is the
    authoritative reference. Every function is pure and mutates no input.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from scripts.dev_tools._blast_radius_extraction import matches_glob
from scripts.dev_tools._blast_radius_validation import (
    is_glob_entry,
    require_mapping,
    require_text,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

    from scripts.dev_tools.compute_blast_radius import BlastRadius

# Contention reason kinds, in the fixed order every result reports them. These
# strings are contract literals consumed by the downstream parallel schema.
CONFLICT_PATH_OVERLAP = "path_overlap"
CONFLICT_MODULE_OVERLAP = "module_overlap"
CONFLICT_SHARED_SURFACE_OVERLAP = "shared_surface_overlap"
CONFLICT_CONTRACT_DEPENDENCY = "contract_dependency"
CONFLICT_KINDS: tuple[str, ...] = (
    CONFLICT_PATH_OVERLAP,
    CONFLICT_MODULE_OVERLAP,
    CONFLICT_SHARED_SURFACE_OVERLAP,
    CONFLICT_CONTRACT_DEPENDENCY,
)

# Separator used in an overlapping-pair detail string. The pair is ordered
# ordinally before formatting so the detail is identical in both argument
# orders, which is what makes the relation observably symmetric.
PAIR_DETAIL_SEPARATOR = " ~ "


@dataclass(frozen=True)
class ConflictReason:
    """Immutable record of one triggered contention disjunct.

    Names which of the four contention levels overlapped and cites the
    overlapping evidence, so a cohort decision is auditable. The record holds no
    verdict of its own; ``ConflictResult`` carries that. ``conflicts``
    constructs at most one instance per kind and orders them by
    ``CONFLICT_KINDS``. Construction checks the vocabulary; the instance is
    frozen and has no side effects.

    Attributes:
        kind (str): One of ``CONFLICT_KINDS``.
        detail (str): The overlapping path pair, module, surface, or identifier.
    """

    kind: str
    detail: str

    def __post_init__(self) -> None:
        """Reject any reason outside the frozen contention vocabulary.

        Returns:
            None.

        Raises:
            ValueError: If ``kind`` is out of vocabulary or ``detail`` is blank.
        """
        if self.kind not in CONFLICT_KINDS:
            raise ValueError(f"ConflictReason kind must be one of {CONFLICT_KINDS}.")
        require_text(self.detail, "ConflictReason.detail")


@dataclass(frozen=True)
class ConflictResult:
    """Immutable verdict of the contention relation between two radii.

    Reports whether two work items contend and why, carrying every triggered
    disjunct rather than the first because cohort audits need the full reason
    set. A scheduler reads ``conflict`` to decide cohort membership and records
    ``reasons`` as conflict-edge evidence. Construction enforces that
    ``conflict`` equals whether ``reasons`` is non-empty and that reason kinds
    appear in ``CONFLICT_KINDS`` order without repetition. The instance is
    frozen and has no side effects.

    Attributes:
        conflict (bool): Whether the two radii contend.
        reasons (tuple[ConflictReason, ...]): Triggered disjuncts in fixed order.
    """

    conflict: bool
    reasons: tuple[ConflictReason, ...]

    def __post_init__(self) -> None:
        """Enforce verdict agreement and the fixed reason ordering.

        Returns:
            None.

        Raises:
            ValueError: If the verdict disagrees with the reason count, or the
                reasons are out of order or repeat a kind.
        """
        if self.conflict != bool(self.reasons):
            raise ValueError("conflict must be True exactly when reasons is non-empty.")

        # Filtering the vocabulary by the observed kinds reproduces the required
        # order, so one comparison catches both a wrong order and a repeat.
        observed = [reason.kind for reason in self.reasons]
        expected = [kind for kind in CONFLICT_KINDS if kind in observed]
        if observed != expected:
            raise ValueError(
                f"conflict reasons must follow the order {CONFLICT_KINDS}."
            )


def conflicts(
    a: BlastRadius, b: BlastRadius, config: Mapping[str, object]
) -> ConflictResult:
    """Decide whether two radii contend, and report every triggered disjunct.

    Args:
        a (BlastRadius): First radius.
        b (BlastRadius): Second radius.
        config (Mapping[str, object]): Parsed ``config/blast-radius.json``. The
            relation reads no key from it today; it is validated and kept in the
            signature because the contract is frozen for downstream consumers.

    Returns:
        ConflictResult: The verdict plus one reason per triggered level, in
        ``CONFLICT_KINDS`` order. Two empty radii, and an empty radius against a
        non-empty one, do not conflict.

    Raises:
        TypeError: If ``config`` is not a mapping.
    """
    require_mapping(config, "config")

    reasons: list[ConflictReason] = []
    path_detail = _smallest_path_overlap(a.paths, b.paths)
    if path_detail is not None:
        reasons.append(ConflictReason(kind=CONFLICT_PATH_OVERLAP, detail=path_detail))

    # The remaining three levels are plain set intersections differing only in
    # which collection they read, so one pass over the level table keeps them in
    # the required kind order without repeating the intersection logic.
    levels: tuple[tuple[str, Sequence[str], Sequence[str]], ...] = (
        (CONFLICT_MODULE_OVERLAP, a.modules, b.modules),
        (CONFLICT_SHARED_SURFACE_OVERLAP, a.shared_surfaces, b.shared_surfaces),
        (CONFLICT_CONTRACT_DEPENDENCY, a.contracts, b.contracts),
    )
    for kind, left, right in levels:
        shared = _smallest_common(left, right)
        if shared is not None:
            reasons.append(ConflictReason(kind=kind, detail=shared))

    return ConflictResult(conflict=bool(reasons), reasons=tuple(reasons))


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
    # overlap only when equal, a mixed pair is a plain pattern match, and a
    # pattern pair falls back to the conservative prefix proof.
    if not a_is_glob and not b_is_glob:
        return entry_a == entry_b
    if a_is_glob and not b_is_glob:
        return matches_glob(entry_a, entry_b)
    if b_is_glob and not a_is_glob:
        return matches_glob(entry_b, entry_a)

    prefix_a = _literal_prefix(entry_a)
    prefix_b = _literal_prefix(entry_b)
    return prefix_a.startswith(prefix_b) or prefix_b.startswith(prefix_a)


def _smallest_path_overlap(
    a_paths: Sequence[str], b_paths: Sequence[str]
) -> str | None:
    """Find the ordinally smallest overlapping path pair between two radii.

    Selecting the smallest pair rather than the first one encountered keeps the
    reported detail identical when the arguments are swapped, which is what the
    symmetry invariant requires.

    Args:
        a_paths (Sequence[str]): Path entries of the first radius.
        b_paths (Sequence[str]): Path entries of the second radius.

    Returns:
        str | None: The overlapping pair rendered with its two entries in
        ordinal order, or ``None`` when no pair overlaps.
    """
    # Each overlapping pair is ordered before it is recorded, so the minimum is
    # taken over a set that does not depend on argument order.
    details: list[str] = []
    for entry_a in a_paths:
        for entry_b in b_paths:
            if not _entries_overlap(entry_a, entry_b):
                continue
            ordered = (entry_a, entry_b) if entry_a <= entry_b else (entry_b, entry_a)
            details.append(PAIR_DETAIL_SEPARATOR.join(ordered))

    if not details:
        return None
    return min(details)


def _smallest_common(left: Sequence[str], right: Sequence[str]) -> str | None:
    """Find the ordinally smallest element two collections share.

    Args:
        left (Sequence[str]): First collection.
        right (Sequence[str]): Second collection.

    Returns:
        str | None: The smallest shared element, or ``None`` when the
        intersection is empty. Two empty collections share nothing.
    """
    common = set(left) & set(right)
    if not common:
        return None
    return min(common)
