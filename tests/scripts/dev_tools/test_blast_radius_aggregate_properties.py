"""Set-level property tests for the aggregate cost cap (issue #1013, spec D-2).

Pins the five set-level properties that replace edge-set monotonicity once the
cap runs inside ``schedule_conflict_edges``:

- the capped edges are a superset of the pairwise edges and a subset of the
  detected conflicts;
- at tolerance 0 the capped output equals the uncapped output;
- after the pass every item is within its cap;
- the output is invariant to the order of the input items and overlaps;
- running the pass again over its own output changes nothing.

As in ``test_blast_radius_scheduling_properties.py``, ``hypothesis`` is not
installed, so each property is checked exhaustively over a fixed finite
domain: every four-item subset of the radius templates below, under every band
vector and every tolerance in the pools. The templates share modules, an
append-only file, a concrete file, a glob, a shared surface, and a contract, so
items carry several tolerated overlaps and the cap binds. The aggregate
module's symbols are imported inside each test, so the module collects before
the implementation exists. No test creates a file or starts a process.
"""

from __future__ import annotations

import itertools
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools._blast_radius_conflicts import conflicts
from scripts.dev_tools._blast_radius_scheduling import (
    ConflictEdge,
    SchedulingItem,
    SchedulingResult,
    ToleratedOverlap,
    config_conflict_tolerance,
    decide_pair,
    schedule_conflict_edges,
)
from scripts.dev_tools.compute_blast_radius import BlastRadius

if TYPE_CHECKING:
    from collections.abc import Iterator, Mapping, Sequence

COMPUTED_AT = "2026-10-30T00-00"


def make_radius(
    paths: Sequence[str] = (),
    modules: Sequence[str] = (),
    shared_surfaces: Sequence[str] = (),
    contracts: Sequence[str] = (),
) -> BlastRadius:
    """Build a declared radius whose unspecified levels are empty."""
    return BlastRadius(
        paths=paths,
        modules=modules,
        shared_surfaces=shared_surfaces,
        contracts=contracts,
        source="declared",
        computed_at=COMPUTED_AT,
    )


# Radius templates whose pairs overlap through every cost term.
TEMPLATES: tuple[BlastRadius, ...] = (
    make_radius(paths=["src/app.py"], modules=["core"]),
    make_radius(paths=["src/app.py", "CHANGELOG.md"]),
    make_radius(paths=["CHANGELOG.md"], modules=["core", "docs"]),
    make_radius(paths=["src/**"]),
    make_radius(modules=["core", "docs"]),
    make_radius(paths=["docs/guide.md"], modules=["docs"], contracts=["ParseLedger"]),
    make_radius(contracts=["ParseLedger"], shared_surfaces=["poetry.lock"]),
)
BAND_VECTORS: tuple[tuple[str | None, ...], ...] = (
    (None, "C2", "C4", "C3"),
    ("C4", "C4", "C4", "C4"),
    ("C1", "C2", "C3", "C4"),
)
TOLERANCES: tuple[int, ...] = (0, 50, 100, 200, 400, 1_000_000)


def make_config(tolerance_percent: int) -> dict[str, object]:
    """Build a truth table with the committed weights at one tolerance."""
    return {
        "version": 1,
        "shared_surfaces": [],
        "shared_surface_globs": [],
        "mergeable_paths": [],
        "conflict_tolerance": {
            "tolerance_percent": tolerance_percent,
            "weights": {
                "same_file": 8,
                "possible_overlap": 2,
                "append_only": 1,
                "module": 2,
                "contract": 8,
            },
            "band_durations": {"C1": 1, "C2": 2, "C3": 4, "C4": 8},
            "default_band": "C1",
            "append_only_paths": ["**/CHANGELOG.md"],
        },
        "modules": {},
        "over_breadth_fraction": 0.25,
    }


def item_sets() -> Iterator[list[SchedulingItem]]:
    """Yield every four-template subset under every band vector."""
    # Keys follow the template index, so every subset has distinct keys.
    for chosen in itertools.combinations(range(len(TEMPLATES)), 4):
        for bands in BAND_VECTORS:
            yield [
                SchedulingItem(key=index + 1, radius=TEMPLATES[index], band=band)
                for index, band in zip(chosen, bands, strict=True)
            ]


def uncapped(
    items: Sequence[SchedulingItem], config: Mapping[str, object]
) -> SchedulingResult:
    """Schedule pair by pair with the pairwise rule only (no cap)."""
    ordered = sorted(items, key=lambda item: item.key)
    edges: list[ConflictEdge] = []
    tolerated: list[ToleratedOverlap] = []
    # Visit each unordered pair once, in (a, b) order.
    for index, first in enumerate(ordered):
        for second in ordered[index + 1 :]:
            d = decide_pair(
                first.radius,
                second.radius,
                config,
                band_a=first.band,
                band_b=second.band,
            )
            if d.edge:
                edges.append(
                    ConflictEdge(
                        first.key, second.key, str(d.reason), d.hard, d.cost, d.benefit
                    )
                )
            elif d.conflict:
                tolerated.append(
                    ToleratedOverlap(
                        first.key, second.key, d.reasons, d.cost, d.benefit
                    )
                )
    return SchedulingResult(edges=tuple(edges), tolerated_overlaps=tuple(tolerated))


def edge_pairs(result: SchedulingResult) -> set[tuple[int, int]]:
    """Return the set of edge pairs of a scheduling result."""
    return {(edge.a, edge.b) for edge in result.edges}


@pytest.mark.parametrize("tolerance_percent", TOLERANCES)
def test_property_capped_edges_lie_between_pairwise_edges_and_conflicts(
    tolerance_percent: int,
) -> None:
    """Pairwise edges are kept and every capped edge is a detected conflict."""
    config = make_config(tolerance_percent)

    # Check every item set at this tolerance.
    for items in item_sets():
        capped = schedule_conflict_edges(items, config)
        pairwise = edge_pairs(uncapped(items, config))
        detected = {
            (a.key, b.key)
            for a, b in itertools.combinations(items, 2)
            if conflicts(a.radius, b.radius, config).conflict
        }

        assert pairwise <= edge_pairs(capped), items
        assert edge_pairs(capped) <= detected, items


def test_property_tolerance_zero_output_equals_uncapped_output() -> None:
    """At tolerance 0 the cap has nothing to read, so the output is unchanged."""
    config = make_config(0)

    # Compare the capped and uncapped results on every item set.
    for items in item_sets():
        assert schedule_conflict_edges(items, config) == uncapped(items, config)


@pytest.mark.parametrize("tolerance_percent", TOLERANCES)
def test_property_every_item_is_within_its_cap_after_the_pass(
    tolerance_percent: int,
) -> None:
    """No item's remaining tolerated cost exceeds its band share of tolerance."""
    config = make_config(tolerance_percent)
    tolerance = config_conflict_tolerance(config)

    # Sum each item's remaining tolerated cost and compare it to its cap.
    for items in item_sets():
        result = schedule_conflict_edges(items, config)
        for item in items:
            total = sum(
                overlap.cost
                for overlap in result.tolerated_overlaps
                if item.key in (overlap.a, overlap.b)
            )
            cap = tolerance.band_duration(item.band) * tolerance_percent

            assert total * 100 <= cap, (items, item.key, total)


@pytest.mark.parametrize("tolerance_percent", TOLERANCES)
def test_property_output_is_invariant_to_input_order(tolerance_percent: int) -> None:
    """Reordering the items or the overlaps leaves the output unchanged."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    config = make_config(tolerance_percent)
    tolerance = config_conflict_tolerance(config)

    # Compare the natural order with the reversed and a rotated order.
    for items in item_sets():
        expected = schedule_conflict_edges(items, config)
        overlaps = list(uncapped(items, config).tolerated_overlaps)
        bands = {item.key: item.band for item in items if item.band is not None}
        promoted = select_capped_pairs(overlaps, bands, tolerance)

        for reordered in (items[::-1], items[1:] + items[:1]):
            assert schedule_conflict_edges(reordered, config) == expected
        assert select_capped_pairs(overlaps[::-1], bands, tolerance) == promoted


@pytest.mark.parametrize("tolerance_percent", TOLERANCES)
def test_property_second_pass_changes_nothing(tolerance_percent: int) -> None:
    """The pass is idempotent: its remaining overlaps promote nothing more."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    config = make_config(tolerance_percent)
    tolerance = config_conflict_tolerance(config)

    # Run the cap again over the output's remaining tolerated overlaps.
    for items in item_sets():
        result = schedule_conflict_edges(items, config)
        bands = {item.key: item.band for item in items if item.band is not None}

        again = select_capped_pairs(list(result.tolerated_overlaps), bands, tolerance)

        assert again == (), (items, again)


def test_property_domain_exercises_the_cap() -> None:
    """At least one domain point promotes a pair, so the properties bind."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    config = make_config(100)
    tolerance = config_conflict_tolerance(config)

    # Count the item sets in which the cap promotes at least one overlap.
    binding = 0
    for items in item_sets():
        overlaps = list(uncapped(items, config).tolerated_overlaps)
        bands = {item.key: item.band for item in items if item.band is not None}
        if select_capped_pairs(overlaps, bands, tolerance):
            binding += 1

    assert binding > 0
