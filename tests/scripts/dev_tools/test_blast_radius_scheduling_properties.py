"""Property tests for the integration-cost scheduling rule (issue #722).

Pins four properties of the pair decision in
``scripts/dev_tools/_blast_radius_scheduling.py``:

- an edge implies a detected conflict;
- at tolerance 0 the edge verdict equals the conflict verdict;
- raising tolerance_percent never adds an edge (monotonicity);
- the decision for (a, b) equals the decision for (b, a) (symmetry).

The ``hypothesis`` package is not installed in this repository (the existing
property suites state that it stays absent), and a pseudo-random generator
would need a lint suppression this change is not authorized to add. Each
property is therefore checked exhaustively over a fixed finite domain: every
ordered pair of the radius templates below, under every truth table, every
band combination, and every tolerance in the pools. The domain mixes concrete
files, listed directories, globs, an append-only file, a mergeable project
file, modules, a shared surface, and a contract, so every cost term and both
hard classes occur. No test creates a temporary file or starts a process.
"""

from __future__ import annotations

import itertools
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools._blast_radius_conflicts import conflicts
from scripts.dev_tools._blast_radius_scheduling import PairDecision, decide_pair
from scripts.dev_tools.compute_blast_radius import BlastRadius

if TYPE_CHECKING:
    from collections.abc import Iterator, Mapping, Sequence

COMPUTED_AT = "2026-09-27T00-00"


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


# Radius templates spanning every cost term and both hard classes.
RADII: tuple[BlastRadius, ...] = (
    make_radius(),
    make_radius(paths=["src/app.py"]),
    make_radius(paths=["src/lib"]),
    make_radius(paths=["src/lib/util.py", "docs/guide.md"]),
    make_radius(paths=["src/**"], modules=["core"]),
    make_radius(paths=["docs/**/*.md"], modules=["docs"]),
    make_radius(paths=["CHANGELOG.md"]),
    make_radius(paths=["**/CHANGELOG.md", "tests/test_app.py"]),
    make_radius(paths=["pkg/app.csproj", "src/app.py"], modules=["core", "docs"]),
    make_radius(paths=["tests/test_app.py"], shared_surfaces=["poetry.lock"]),
    make_radius(modules=["core"], shared_surfaces=["poetry.lock"]),
    make_radius(paths=["docs/guide.md"], contracts=["computeWidget"]),
    make_radius(contracts=["computeWidget"], modules=["tests"]),
)
BANDS: tuple[str | None, ...] = (None, "C2", "C4")
TOLERANCES: tuple[int, ...] = (0, 1, 50, 99, 100, 150, 400, 800, 1_000_000)

# Three truth tables: the committed weights, unit weights, and skewed weights
# with a non-default default_band, so the rule is not checked at one point only.
TOLERANCE_MEMBERS: dict[str, dict[str, object]] = {
    "committed": {
        "weights": {
            "same_file": 8,
            "possible_overlap": 2,
            "append_only": 1,
            "module": 2,
        },
        "band_durations": {"C1": 1, "C2": 2, "C3": 4, "C4": 8},
        "default_band": "C1",
    },
    "unit": {
        "weights": {
            "same_file": 1,
            "possible_overlap": 1,
            "append_only": 1,
            "module": 1,
        },
        "band_durations": {"C1": 1, "C2": 1, "C3": 1, "C4": 1},
        "default_band": "C1",
    },
    "skewed": {
        "weights": {
            "same_file": 3,
            "possible_overlap": 9,
            "append_only": 5,
            "module": 1,
        },
        "band_durations": {"C1": 7, "C2": 1, "C3": 3, "C4": 2},
        "default_band": "C3",
    },
}
MEMBER_NAMES: tuple[str, ...] = tuple(TOLERANCE_MEMBERS)


def make_config(member_name: str, tolerance_percent: int) -> dict[str, object]:
    """Build a truth table from a named member and a tolerance."""
    return {
        "version": 1,
        "shared_surfaces": [],
        "shared_surface_globs": [],
        "mergeable_paths": ["**/*.csproj"],
        "conflict_tolerance": {
            **TOLERANCE_MEMBERS[member_name],
            "tolerance_percent": tolerance_percent,
            "append_only_paths": ["**/CHANGELOG.md"],
        },
        "modules": {"config": ["config/**"]},
        "over_breadth_fraction": 0.25,
    }


def domain() -> Iterator[tuple[BlastRadius, BlastRadius, str | None, str | None]]:
    """Yield every ordered radius pair with every band combination."""
    # The product covers self pairs and both orders of every distinct pair.
    for a, b in itertools.product(RADII, repeat=2):
        for band_a, band_b in itertools.product(BANDS, repeat=2):
            yield a, b, band_a, band_b


def decide(
    a: BlastRadius,
    b: BlastRadius,
    config: Mapping[str, object],
    bands: tuple[str | None, str | None],
) -> PairDecision:
    """Run the pair decision with explicit bands for both items."""
    return decide_pair(a, b, config, band_a=bands[0], band_b=bands[1])


@pytest.mark.parametrize("member_name", MEMBER_NAMES)
def test_property_edge_implies_conflict(member_name: str) -> None:
    """Whatever the tolerance, an edge is only ever a detected conflict."""
    configs = [make_config(member_name, tolerance) for tolerance in TOLERANCES]

    # Check every domain point under every tolerance.
    for a, b, band_a, band_b in domain():
        for config in configs:
            decision = decide(a, b, config, (band_a, band_b))

            if decision.edge:
                assert conflicts(a, b, config).conflict, (a, b, band_a, band_b)


@pytest.mark.parametrize("member_name", MEMBER_NAMES)
def test_property_tolerance_zero_equals_conflict(member_name: str) -> None:
    """At tolerance 0 the edge verdict equals the relation's verdict exactly."""
    config = make_config(member_name, 0)

    # Check every domain point at tolerance 0.
    for a, b, band_a, band_b in domain():
        decision = decide(a, b, config, (band_a, band_b))

        assert decision.edge == conflicts(a, b, config).conflict, (a, b, decision)


@pytest.mark.parametrize("member_name", MEMBER_NAMES)
def test_property_monotone_in_tolerance(member_name: str) -> None:
    """An edge at a higher tolerance is also an edge at every lower tolerance."""
    configs = [make_config(member_name, tolerance) for tolerance in TOLERANCES]

    # Walk the ascending tolerances per domain point; once the edge disappears
    # it must not reappear.
    for a, b, band_a, band_b in domain():
        edges = [decide(a, b, config, (band_a, band_b)).edge for config in configs]

        assert edges == sorted(edges, reverse=True), (a, b, band_a, band_b, edges)


@pytest.mark.parametrize("member_name", MEMBER_NAMES)
def test_property_symmetric_decision(member_name: str) -> None:
    """Swapping the two items (with their bands) leaves the decision unchanged."""
    configs = [make_config(member_name, tolerance) for tolerance in TOLERANCES]

    # Compare both argument orders at every domain point and tolerance.
    for a, b, band_a, band_b in domain():
        for config in configs:
            forward = decide(a, b, config, (band_a, band_b))
            backward = decide(b, a, config, (band_b, band_a))

            assert forward == backward, (a, b, band_a, band_b, forward, backward)
