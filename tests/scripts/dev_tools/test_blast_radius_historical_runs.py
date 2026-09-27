"""Pinned historical parallel runs for the scheduling layer (issue #722).

Each committed fixture under ``tests/fixtures/blast_radius/historical-runs``
carries one historical run's recorded radii, per-item complexity bands, the
pre-change truth table, and the BEFORE values derived from them: the conflict
edges, the cohort partition, the cohort count, and the maximum cohort width.
The BEFORE tests re-derive those values with the unchanged contention relation
and assert that strict scheduling (the conflict_tolerance key absent, or set to
tolerance 0) reproduces the detected edge set and its cohort coloring exactly.

Each fixture also carries an AFTER section: the committed truth table (with
write-intent extraction and the committed conflict_tolerance) and the edges,
tolerated overlaps, and cohorts derived by normalizing every recorded radius
with that table and scheduling the run with the integration-cost edge rule. The
AFTER tests re-derive those values and assert that the AFTER edges are a subset
of the BEFORE edges.

Every value is read from the committed fixtures; no test reads a remote ref, a
generated build directory, or a temporary file, and no external process is
started.
"""

from __future__ import annotations

import json
from itertools import combinations
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._blast_radius_conflicts import conflicts
from scripts.dev_tools._blast_radius_scheduling import (
    SchedulingItem,
    SchedulingResult,
    schedule_conflict_edges,
)
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    normalize_declared_radius,
)
from scripts.dev_tools.parallel_cohort_computation import compute_cohorts

if TYPE_CHECKING:
    from collections.abc import Mapping

REPO_ROOT = Path(__file__).resolve().parents[3]
HISTORICAL_DIR = REPO_ROOT / "tests" / "fixtures" / "blast_radius" / "historical-runs"
RUNS: tuple[str, ...] = (
    "epic-655-followups",
    "backlog-2026-09-26",
    "followups-2026-09-27",
)

# A tolerance member at tolerance 0 with the committed weights: the second
# strict configuration, beside the absent key.
ZERO_TOLERANCE: dict[str, object] = {
    "tolerance_percent": 0,
    "weights": {"same_file": 8, "possible_overlap": 2, "append_only": 1, "module": 2},
    "band_durations": {"C1": 1, "C2": 2, "C3": 4, "C4": 8},
    "default_band": "C1",
    "append_only_paths": ["**/CHANGELOG.md"],
}


def load_run(run: str) -> Mapping[str, object]:
    """Read one committed historical-run fixture."""
    path = HISTORICAL_DIR / f"{run}.json"
    return cast("Mapping[str, object]", json.loads(path.read_text(encoding="utf-8")))


def records(value: object) -> list[Mapping[str, object]]:
    """Narrow a fixture array of objects for the type checker."""
    return cast("list[Mapping[str, object]]", value)


def section(fixture: Mapping[str, object], name: str) -> Mapping[str, object]:
    """Return one named section (``before`` or ``after``) of a fixture."""
    return cast("Mapping[str, object]", fixture[name])


def radii(fixture: Mapping[str, object]) -> dict[int, BlastRadius]:
    """Rebuild every recorded radius, keyed by item number."""
    # One radius per fixture item, constructed from its verbatim record.
    return {
        cast("int", item["issue_num"]): BlastRadius.from_dict(
            cast("Mapping[str, object]", item["radius"])
        )
        for item in records(fixture["items"])
    }


def scheduling_items(fixture: Mapping[str, object]) -> list[SchedulingItem]:
    """Build scheduling items carrying each fixture item's recorded band."""
    by_key = radii(fixture)
    # Pair every recorded radius with the item's band (None means default_band).
    return [
        SchedulingItem(
            key=cast("int", item["issue_num"]),
            radius=by_key[cast("int", item["issue_num"])],
            band=cast("str | None", item["complexity_band"]),
        )
        for item in records(fixture["items"])
    ]


def pinned_pairs(before: Mapping[str, object]) -> list[tuple[int, int]]:
    """Return the pinned BEFORE edge pairs in fixture order."""
    # Project each pinned edge record to its (a, b) pair.
    return [
        (cast("int", edge["a"]), cast("int", edge["b"]))
        for edge in records(before["edges"])
    ]


def after_scheduling(fixture: Mapping[str, object]) -> SchedulingResult:
    """Schedule the run as the AFTER section was derived.

    Every recorded radius is normalized with the AFTER truth table, then the
    run is scheduled with that same table, each item keeping its recorded band.

    Args:
        fixture (Mapping[str, object]): One committed historical-run fixture.

    Returns:
        SchedulingResult: The AFTER edges and tolerated overlaps.
    """
    config = cast("Mapping[str, object]", section(fixture, "after")["config"])
    # Re-apply the committed extraction rules to each recorded radius first.
    items = [
        SchedulingItem(
            key=item.key,
            radius=normalize_declared_radius(item.radius, config),
            band=item.band,
        )
        for item in scheduling_items(fixture)
    ]
    return schedule_conflict_edges(items, config)


@pytest.mark.parametrize("run", RUNS)
def test_before_radius_sizes_match_pins(run: str) -> None:
    """Every recorded radius has the pinned size at each of the four levels."""
    fixture = load_run(run)
    by_key = radii(fixture)

    # Compare each item's constructed radius with its pinned level counts.
    for pin in records(fixture["expected_radius_sizes"]):
        radius = by_key[cast("int", pin["issue_num"])]
        observed = {
            "paths": len(radius.paths),
            "modules": len(radius.modules),
            "shared_surfaces": len(radius.shared_surfaces),
            "contracts": len(radius.contracts),
        }

        expected = {key: pin[key] for key in observed}
        assert observed == expected, f"{run} item {pin['issue_num']}"


@pytest.mark.parametrize("run", RUNS)
def test_before_edges_match_pins(run: str) -> None:
    """The unchanged relation reproduces the pinned BEFORE edges exactly."""
    fixture = load_run(run)
    before = section(fixture, "before")
    config = cast("Mapping[str, object]", before["config"])
    by_key = radii(fixture)

    # Evaluate every unordered pair once, in ascending key order.
    derived: list[dict[str, object]] = []
    for a, b in combinations(sorted(by_key), 2):
        result = conflicts(by_key[a], by_key[b], config)
        if result.conflict:
            derived.append({"a": a, "b": b, "reason": result.reasons[0].kind})

    assert derived == before["edges"], run
    assert len(derived) == before["edge_count"], run


@pytest.mark.parametrize("run", RUNS)
def test_before_strict_scheduling_equals_detection(run: str) -> None:
    """With the key absent or at tolerance 0, scheduling edges equal detected edges."""
    fixture = load_run(run)
    before = section(fixture, "before")
    absent = dict(cast("Mapping[str, object]", before["config"]))
    absent.pop("conflict_tolerance", None)
    zero = {**absent, "conflict_tolerance": ZERO_TOLERANCE}
    items = scheduling_items(fixture)

    # Both strict configurations must yield the pinned edges and no tolerated pair.
    for config in (absent, zero):
        result = schedule_conflict_edges(items, config)

        assert [(e.a, e.b) for e in result.edges] == pinned_pairs(before), run
        assert [e.reason for e in result.edges] == [
            edge["reason"] for edge in records(before["edges"])
        ], run
        assert result.tolerated_overlaps == (), run


@pytest.mark.parametrize("run", RUNS)
def test_before_cohorts_match_pins(run: str) -> None:
    """Coloring the strict scheduling edge set reproduces the pinned partition."""
    fixture = load_run(run)
    before = section(fixture, "before")
    items = scheduling_items(fixture)
    strict = dict(cast("Mapping[str, object]", before["config"]))
    strict.pop("conflict_tolerance", None)
    edges = schedule_conflict_edges(items, strict).edges

    cohorts = compute_cohorts([item.key for item in items], [(e.a, e.b) for e in edges])

    assert cohorts == before["cohorts"], run
    assert len(cohorts) == before["cohort_count"], run
    assert max(len(cohort) for cohort in cohorts) == before["max_cohort_width"], run


@pytest.mark.parametrize("run", RUNS)
def test_after_edges_match_pins(run: str) -> None:
    """Normalizing and scheduling with the AFTER table reproduces the pinned edges."""
    fixture = load_run(run)
    after = section(fixture, "after")

    result = after_scheduling(fixture)

    assert [edge.to_dict() for edge in result.edges] == after["edges"], run
    assert len(result.edges) == after["edge_count"], run


@pytest.mark.parametrize("run", RUNS)
def test_after_tolerated_overlaps_match_pins(run: str) -> None:
    """The AFTER derivation reproduces the pinned tolerated overlaps exactly."""
    fixture = load_run(run)
    after = section(fixture, "after")

    result = after_scheduling(fixture)

    assert [overlap.to_dict() for overlap in result.tolerated_overlaps] == after[
        "tolerated_overlaps"
    ], run


@pytest.mark.parametrize("run", RUNS)
def test_after_cohorts_match_pins(run: str) -> None:
    """Coloring the AFTER edge set reproduces the pinned partition and widths."""
    fixture = load_run(run)
    after = section(fixture, "after")
    keys = [item.key for item in scheduling_items(fixture)]
    edges = after_scheduling(fixture).edges

    cohorts = compute_cohorts(keys, [(edge.a, edge.b) for edge in edges])

    assert cohorts == after["cohorts"], run
    assert len(cohorts) == after["cohort_count"], run
    assert max(len(cohort) for cohort in cohorts) == after["max_cohort_width"], run


@pytest.mark.parametrize("run", RUNS)
def test_after_edges_are_subset_of_before_edges(run: str) -> None:
    """Every AFTER edge pair is also a pinned BEFORE edge pair."""
    fixture = load_run(run)
    before_pairs = set(pinned_pairs(section(fixture, "before")))

    after_pairs = {(edge.a, edge.b) for edge in after_scheduling(fixture).edges}

    assert after_pairs <= before_pairs, f"{run}: {sorted(after_pairs - before_pairs)}"
