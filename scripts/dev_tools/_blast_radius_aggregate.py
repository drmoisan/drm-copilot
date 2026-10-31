"""Aggregate integration-cost cap over tolerated overlaps (issue #1013, D-2).

Purpose and responsibilities:
    The pairwise edge rule of ``_blast_radius_scheduling`` judges each pair
    alone, so one item can accumulate many tolerated overlaps whose summed cost
    exceeds what running it serially would cost. ``select_capped_pairs`` caps
    each item's summed tolerated cost and returns the pairs to promote to
    scheduling edges; ``schedule_conflict_edges`` applies the result.

Cap rule:
    ``total(i)`` is the summed cost of the remaining tolerated overlaps that
    include item ``i``. Item ``i`` is over its cap when
    ``total(i) * 100 > band_duration(i) * tolerance_percent``, evaluated in
    integers; a missing band reads as ``default_band``. While an item is over
    its cap, the smallest-key such item promotes its overlap with the minimum
    key ``(benefit ascending, cost descending, a ascending, b ascending)``.

Invariants, constraints, and side effects:
    The function is pure and total over valid input: it reads its arguments,
    mutates none of them, and raises only for a band outside the configured
    bands. Each round removes one overlap, so the loop terminates, and every
    choice is made by a total order, so the result does not depend on the input
    order. ``ConflictTolerance`` is imported only for type checking, so this
    module never imports the scheduling module at runtime.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

    from scripts.dev_tools._blast_radius_scheduling import ConflictTolerance

__all__ = ["CappableOverlap", "select_capped_pairs"]

# tolerance_percent is a percentage of the band duration.
_PERCENT = 100


class CappableOverlap(Protocol):
    """Any tolerated overlap record exposing its pair, cost, and benefit."""

    @property
    def a(self) -> int:
        """Smaller item key of the pair."""
        ...

    @property
    def b(self) -> int:
        """Larger item key of the pair."""
        ...

    @property
    def cost(self) -> int:
        """Integer integration cost of the pair."""
        ...

    @property
    def benefit(self) -> int:
        """Integer parallelism benefit of the pair."""
        ...


def select_capped_pairs(
    tolerated_overlaps: Sequence[CappableOverlap],
    bands: Mapping[int, str | None],
    tolerance: ConflictTolerance,
) -> tuple[tuple[int, int], ...]:
    """Return the tolerated pairs to promote so every item is within its cap.

    Args:
        tolerated_overlaps (Sequence[CappableOverlap]): The pairwise tolerated
            overlaps, in any order.
        bands (Mapping[int, str | None]): Item key to complexity band; a key
            that is absent or maps to ``None`` reads as ``default_band``.
        tolerance (ConflictTolerance): The validated tolerance reading.

    Returns:
        tuple[tuple[int, int], ...]: The promoted ``(a, b)`` pairs in promotion
        order; empty when no item is over its cap.

    Raises:
        ValueError: If a band is not one of the configured bands.
    """
    # Sort once, so every later scan visits the overlaps in canonical order.
    remaining = sorted(tolerated_overlaps, key=lambda overlap: (overlap.a, overlap.b))
    promoted: list[tuple[int, int]] = []
    while True:
        item = _first_over_cap_item(remaining, bands, tolerance)
        if item is None:
            return tuple(promoted)
        cheapest = min(
            (overlap for overlap in remaining if item in (overlap.a, overlap.b)),
            key=_serialize_key,
        )
        remaining.remove(cheapest)
        promoted.append((cheapest.a, cheapest.b))


def _serialize_key(overlap: CappableOverlap) -> tuple[int, int, int, int]:
    """Order overlaps cheapest-to-serialize first: least benefit, most cost."""
    return (overlap.benefit, -overlap.cost, overlap.a, overlap.b)


def _first_over_cap_item(
    remaining: Sequence[CappableOverlap],
    bands: Mapping[int, str | None],
    tolerance: ConflictTolerance,
) -> int | None:
    """Return the smallest item key whose tolerated total exceeds its cap."""
    totals: dict[int, int] = {}
    # Each overlap's cost counts toward both of its items.
    for overlap in remaining:
        for key in (overlap.a, overlap.b):
            totals[key] = totals.get(key, 0) + overlap.cost
    for key in sorted(totals):
        cap = tolerance.band_duration(bands.get(key)) * tolerance.tolerance_percent
        if totals[key] * _PERCENT > cap:
            return key
    return None
