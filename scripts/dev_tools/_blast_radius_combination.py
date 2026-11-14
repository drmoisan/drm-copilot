"""Planning-time issue combination over the scheduling pair data (issue #1013).

Purpose and responsibilities:
    Find the pairs of work items whose integration cost is high enough that
    delivering them as one item (one branch, one PR, one CI cycle) costs less
    than merging them, and group those pairs into combinations (spec D-5).

Rules:
    1. Disabled when ``conflict_tolerance`` is absent or ``tolerance_percent``
       is 0, so the strict identity extends to the item set.
    2. ``decide_pair`` supplies each conflicting pair's reasons, cost (including
       the D-7 contract term), and benefit; edges and tolerated pairs are both
       evaluated.
    3. A pair is a candidate when its full reasons contain
       ``contract_dependency`` or ``has_same_file_overlap`` is true.
    4. A candidate qualifies when
       ``cost * 100 >= benefit * combination_threshold_percent``.
    5. Qualifying pairs are grouped into connected components (union-find);
       each component becomes one combination with ascending ``members``,
       ``primary = min(members)``, ``pairs`` sorted by ``(a, b)``, and
       ``estimated_savings`` equal to the sum of its pair costs.

Invariants, constraints, and side effects:
    Every function is pure and total over valid input: no I/O, and no argument
    is mutated. The overlap enumeration and the mergeable exclusion are the
    ones ``pair_cost`` uses, so a same-file candidate is exactly a pair that
    ``pair_cost`` weighs as ``same_file``.
"""

from __future__ import annotations

from dataclasses import dataclass
from typing import TYPE_CHECKING

from scripts.dev_tools._blast_radius_conflicts import CONFLICT_CONTRACT_DEPENDENCY
from scripts.dev_tools._blast_radius_glob import _entries_overlap, is_glob_entry
from scripts.dev_tools._blast_radius_mergeable import (
    config_mergeable_paths,
    exclude_mergeable_paths,
    matches_mergeable_path,
)
from scripts.dev_tools._blast_radius_scheduling import (
    config_conflict_tolerance,
    decide_pair,
)

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

    from scripts.dev_tools._blast_radius_scheduling import (
        ConflictTolerance,
        SchedulingItem,
    )
    from scripts.dev_tools.compute_blast_radius import BlastRadius

__all__ = [
    "Combination",
    "CombinationPair",
    "CombinationResult",
    "find_combinations",
    "has_same_file_overlap",
]

# The threshold is a percentage of the pair benefit.
_PERCENT = 100


@dataclass(frozen=True)
class CombinationPair:
    """One qualifying pair ``a < b`` with its integration cost and benefit."""

    a: int
    b: int
    cost: int
    benefit: int

    def to_dict(self) -> dict[str, object]:
        """Serialize the pair into its record shape."""
        return {"a": self.a, "b": self.b, "cost": self.cost, "benefit": self.benefit}


@dataclass(frozen=True)
class Combination:
    """One connected component of qualifying pairs, delivered as one item."""

    members: tuple[int, ...]
    primary: int
    pairs: tuple[CombinationPair, ...]
    estimated_savings: int

    def to_dict(self) -> dict[str, object]:
        """Serialize the combination into its record shape."""
        return {
            "members": list(self.members),
            "primary": self.primary,
            "pairs": [pair.to_dict() for pair in self.pairs],
            "estimated_savings": self.estimated_savings,
        }


@dataclass(frozen=True)
class CombinationResult:
    """Every qualifying pair, sorted by ``(a, b)``, and the combinations."""

    pairs: tuple[CombinationPair, ...]
    combinations: tuple[Combination, ...]


def has_same_file_overlap(
    radius_a: BlastRadius,
    radius_b: BlastRadius,
    config: Mapping[str, object],
    tolerance: ConflictTolerance,
) -> bool:
    """Report whether two radii share a non-append-only concrete file.

    Args:
        radius_a (BlastRadius): First radius.
        radius_b (BlastRadius): Second radius.
        config (Mapping[str, object]): Parsed truth table; only
            ``mergeable_paths`` is read, for the relation's exclusion.
        tolerance (ConflictTolerance): Supplies ``append_only_paths``.

    Returns:
        bool: True when an overlapping entry pair left after the mergeable
        exclusion consists of two equal concrete entries that do not match
        ``append_only_paths``; this mirrors the precedence ``pair_cost`` uses,
        so an append-only registry is never a same-file overlap.
    """
    mergeable = config_mergeable_paths(config)
    paths_a = exclude_mergeable_paths(radius_a.paths, mergeable)
    paths_b = exclude_mergeable_paths(radius_b.paths, mergeable)
    # Enumerate overlapping pairs with the relation's primitive; only an equal
    # concrete pair that is not append-only is the same file.
    return any(
        _entries_overlap(entry_a, entry_b)
        and entry_a == entry_b
        and not is_glob_entry(entry_a)
        and not matches_mergeable_path(entry_a, tolerance.append_only_paths)
        for entry_a in paths_a
        for entry_b in paths_b
    )


def find_combinations(
    items: Sequence[SchedulingItem], config: Mapping[str, object]
) -> CombinationResult:
    """Find the qualifying pairs of a set of items and group them.

    Args:
        items (Sequence[SchedulingItem]): The run's items, in any order.
        config (Mapping[str, object]): Parsed truth table.

    Returns:
        CombinationResult: Qualifying pairs sorted by ``(a, b)`` and the
        combinations sorted by ``primary``; both empty when combination is
        disabled (key absent or ``tolerance_percent`` 0).

    Raises:
        TypeError: If the config or its conflict_tolerance key is malformed.
        ValueError: If two items share a key, or conflict_tolerance or a band
            is invalid.
    """
    tolerance = config_conflict_tolerance(config)
    ordered = _ordered_by_key(items)
    # The absent key reads as the strict tolerance, whose percent is 0.
    if tolerance.tolerance_percent == 0:
        return CombinationResult(pairs=(), combinations=())

    qualifying: list[CombinationPair] = []
    # Visit each unordered pair once in (a, b) order, so the list comes out sorted.
    for index, first in enumerate(ordered):
        for second in ordered[index + 1 :]:
            pair = _qualifying_pair(first, second, config, tolerance)
            if pair is not None:
                qualifying.append(pair)
    return CombinationResult(
        pairs=tuple(qualifying), combinations=_components(qualifying)
    )


def _qualifying_pair(
    first: SchedulingItem,
    second: SchedulingItem,
    config: Mapping[str, object],
    tolerance: ConflictTolerance,
) -> CombinationPair | None:
    """Return the pair record when the pair is a qualifying candidate."""
    decision = decide_pair(
        first.radius, second.radius, config, band_a=first.band, band_b=second.band
    )
    if not decision.conflict:
        return None
    # The full reasons are read, because contract_dependency is never first.
    candidate = CONFLICT_CONTRACT_DEPENDENCY in decision.reasons or (
        has_same_file_overlap(first.radius, second.radius, config, tolerance)
    )
    threshold = decision.benefit * tolerance.combination_threshold_percent
    if not candidate or decision.cost * _PERCENT < threshold:
        return None
    return CombinationPair(first.key, second.key, decision.cost, decision.benefit)


def _components(pairs: Sequence[CombinationPair]) -> tuple[Combination, ...]:
    """Group qualifying pairs into connected components with union-find."""
    parent: dict[int, int] = {}

    def find(key: int) -> int:
        # Walk to the root, halving the path on the way.
        while parent.setdefault(key, key) != key:
            parent[key] = parent[parent[key]]
            key = parent[key]
        return key

    for pair in pairs:
        root_a, root_b = find(pair.a), find(pair.b)
        if root_a != root_b:
            parent[max(root_a, root_b)] = min(root_a, root_b)

    grouped: dict[int, list[CombinationPair]] = {}
    for pair in pairs:
        grouped.setdefault(find(pair.a), []).append(pair)
    combinations: list[Combination] = []
    for root in sorted(grouped):
        component = grouped[root]
        members = tuple(sorted({key for p in component for key in (p.a, p.b)}))
        combinations.append(
            Combination(
                members=members,
                primary=members[0],
                pairs=tuple(sorted(component, key=lambda p: (p.a, p.b))),
                estimated_savings=sum(p.cost for p in component),
            )
        )
    return tuple(combinations)


def _ordered_by_key(items: Sequence[SchedulingItem]) -> list[SchedulingItem]:
    """Return the items sorted by key, rejecting a repeated key.

    Raises:
        ValueError: If two items share a key.
    """
    keys = [item.key for item in items]
    if len(set(keys)) != len(keys):
        raise ValueError(f"combination item keys must be distinct: {sorted(keys)}.")
    return sorted(items, key=lambda item: item.key)
