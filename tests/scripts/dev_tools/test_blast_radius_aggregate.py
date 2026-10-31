"""Fixture-driven tests for the aggregate cost cap (issue #1013, spec D-2).

The three committed fixtures under ``tests/fixtures/blast_radius/aggregate``
carry hand-derived expectations: the pairwise tolerated overlaps the cap
reads, the pairs it promotes in order, and the edges and tolerated overlaps
``schedule_conflict_edges`` returns once the cap has run. The tests call
``select_capped_pairs`` directly and through the scheduling entry point, and
pin the no-op at tolerance 0 and with the key absent, purity, and the one-way
import direction between the two modules.

The aggregate module's symbols are imported inside each test, so the module
collects before the implementation exists. No test creates a file or starts a
process.
"""

from __future__ import annotations

import ast
import copy
import json
from dataclasses import dataclass
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._blast_radius_conflicts import conflicts
from scripts.dev_tools._blast_radius_scheduling import (
    STRICT_CONFLICT_TOLERANCE,
    SchedulingItem,
    ToleratedOverlap,
    config_conflict_tolerance,
    decide_pair,
    schedule_conflict_edges,
)
from scripts.dev_tools.compute_blast_radius import BlastRadius

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

REPO_ROOT = Path(__file__).resolve().parents[3]
AGGREGATE_DIR = REPO_ROOT / "tests" / "fixtures" / "blast_radius" / "aggregate"
AGGREGATE_SOURCE = REPO_ROOT / "scripts" / "dev_tools" / "_blast_radius_aggregate.py"
FIXTURE_NAMES: tuple[str, ...] = (
    "aggregate-cap-promotes-cheapest-pair",
    "aggregate-cap-tie-break",
    "aggregate-cap-cascade",
)
SCHEDULING_MODULE = "scripts.dev_tools._blast_radius_scheduling"


def load_fixture(name: str) -> Mapping[str, object]:
    """Read one committed aggregate fixture."""
    path = AGGREGATE_DIR / f"{name}.json"
    return cast("Mapping[str, object]", json.loads(path.read_text(encoding="utf-8")))


def records(value: object) -> list[Mapping[str, object]]:
    """Narrow a fixture array of objects for the type checker."""
    return cast("list[Mapping[str, object]]", value)


def fixture_cases() -> list[tuple[str, Mapping[str, object], Mapping[str, object]]]:
    """Return every (fixture name, fixture, case) triple across the corpus."""
    # One parameter per case, so a failure names the fixture and the case.
    cases: list[tuple[str, Mapping[str, object], Mapping[str, object]]] = []
    for name in FIXTURE_NAMES:
        fixture = load_fixture(name)
        cases.extend((name, fixture, case) for case in records(fixture["cases"]))
    return cases


CASES = fixture_cases()
CASE_IDS = [f"{name}-{case['name']}" for name, _, case in CASES]


def case_config(
    fixture: Mapping[str, object], *, tolerance_percent: int | None = None
) -> dict[str, object]:
    """Copy a fixture's truth table, optionally overriding tolerance_percent."""
    config = cast("dict[str, object]", copy.deepcopy(dict(fixture["config"])))
    if tolerance_percent is not None:
        member = cast("dict[str, object]", config["conflict_tolerance"])
        member["tolerance_percent"] = tolerance_percent
    return config


def case_items(case: Mapping[str, object]) -> list[SchedulingItem]:
    """Build scheduling items from a case's items (a missing band is None)."""
    return [
        SchedulingItem(
            key=cast("int", item["key"]),
            radius=BlastRadius.from_dict(cast("Mapping[str, object]", item["radius"])),
            band=cast("str | None", item.get("band")),
        )
        for item in records(case["items"])
    ]


def case_bands(case: Mapping[str, object]) -> dict[int, str]:
    """Return the key-to-band map; an item without a band is left out."""
    return {
        cast("int", item["key"]): cast("str", item["band"])
        for item in records(case["items"])
        if "band" in item
    }


def overlaps(value: object) -> list[ToleratedOverlap]:
    """Rebuild tolerated overlaps from their recorded dict shape."""
    return [
        ToleratedOverlap(
            a=cast("int", record["a"]),
            b=cast("int", record["b"]),
            reasons=tuple(cast("list[str]", record["reasons"])),
            cost=cast("int", record["cost"]),
            benefit=cast("int", record["benefit"]),
        )
        for record in records(value)
    ]


def detected(
    items: Sequence[SchedulingItem], config: Mapping[str, object]
) -> list[tuple[int, int]]:
    """Return every conflicting pair ``(a, b)`` with ``a < b``, sorted."""
    ordered = sorted(items, key=lambda item: item.key)
    return [
        (first.key, second.key)
        for index, first in enumerate(ordered)
        for second in ordered[index + 1 :]
        if conflicts(first.radius, second.radius, config).conflict
    ]


def pairs_of(
    value: Sequence[tuple[int, int]] | Sequence[Sequence[int]],
) -> list[list[int]]:
    """Render a sequence of pairs as lists, the fixture's JSON shape."""
    return [list(pair) for pair in value]


@pytest.mark.parametrize(("name", "fixture", "case"), CASES, ids=CASE_IDS)
def test_select_capped_pairs_matches_fixture(
    name: str, fixture: Mapping[str, object], case: Mapping[str, object]
) -> None:
    """The cap promotes exactly the hand-derived pairs, in promotion order."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    tolerance = config_conflict_tolerance(case_config(fixture))

    promoted = select_capped_pairs(
        overlaps(case["pairwise_tolerated"]), case_bands(case), tolerance
    )

    assert pairs_of(promoted) == case["expected_promoted"], name


@pytest.mark.parametrize(("name", "fixture", "case"), CASES, ids=CASE_IDS)
def test_pairwise_decision_reproduces_cap_input(
    name: str, fixture: Mapping[str, object], case: Mapping[str, object]
) -> None:
    """Uncapped scheduling yields the fixture's recorded cap input."""
    config = case_config(fixture)
    tolerance = config_conflict_tolerance(config)
    items = sorted(case_items(case), key=lambda item: item.key)

    # Collect every conflicting pair the pairwise rule tolerates.
    tolerated: list[dict[str, object]] = []
    for index, first in enumerate(items):
        for second in items[index + 1 :]:
            decision = decide_pair(
                first.radius,
                second.radius,
                config,
                band_a=first.band,
                band_b=second.band,
            )
            if decision.conflict and not decision.edge:
                tolerated.append(
                    ToleratedOverlap(
                        first.key,
                        second.key,
                        decision.reasons,
                        decision.cost,
                        decision.benefit,
                    ).to_dict()
                )

    assert tolerance.tolerance_percent == 100, name
    assert tolerated == case["pairwise_tolerated"], name


@pytest.mark.parametrize(("name", "fixture", "case"), CASES, ids=CASE_IDS)
def test_schedule_conflict_edges_applies_the_cap(
    name: str, fixture: Mapping[str, object], case: Mapping[str, object]
) -> None:
    """Promoted overlaps become non-hard edges carrying their first reason."""
    result = schedule_conflict_edges(case_items(case), case_config(fixture))

    assert [edge.to_dict() for edge in result.edges] == case["expected_edges"], name
    assert [
        overlap.to_dict() for overlap in result.tolerated_overlaps
    ] == case["expected_tolerated"], name


@pytest.mark.parametrize(("name", "fixture", "case"), CASES, ids=CASE_IDS)
def test_capped_lists_are_sorted_by_pair(
    name: str, fixture: Mapping[str, object], case: Mapping[str, object]
) -> None:
    """Both capped lists stay sorted by (a, b) after promotion."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    config = case_config(fixture)
    tolerance = config_conflict_tolerance(config)
    promoted = select_capped_pairs(
        overlaps(case["pairwise_tolerated"]), case_bands(case), tolerance
    )

    result = schedule_conflict_edges(case_items(case), config)

    edge_pairs = [(edge.a, edge.b) for edge in result.edges]
    overlap_pairs = [(item.a, item.b) for item in result.tolerated_overlaps]
    assert promoted, name
    assert edge_pairs == sorted(edge_pairs), name
    assert overlap_pairs == sorted(overlap_pairs), name
    assert all(not edge.hard for edge in result.edges), name


@pytest.mark.parametrize(("name", "fixture", "case"), CASES, ids=CASE_IDS)
def test_tolerance_zero_cap_is_a_no_op(
    name: str, fixture: Mapping[str, object], case: Mapping[str, object]
) -> None:
    """At tolerance 0 nothing is tolerated, so the edges equal detection."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    config = case_config(fixture, tolerance_percent=0)
    items = case_items(case)

    result = schedule_conflict_edges(items, config)

    zero = config_conflict_tolerance(config)
    assert select_capped_pairs([], case_bands(case), zero) == (), name
    assert result.tolerated_overlaps == (), name
    assert [(e.a, e.b) for e in result.edges] == detected(items, config), name


@pytest.mark.parametrize(("name", "fixture", "case"), CASES, ids=CASE_IDS)
def test_absent_key_cap_is_a_no_op(
    name: str, fixture: Mapping[str, object], case: Mapping[str, object]
) -> None:
    """With the key absent the strict reading applies and nothing is tolerated."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    config = case_config(fixture)
    del config["conflict_tolerance"]
    items = case_items(case)

    result = schedule_conflict_edges(items, config)

    strict = select_capped_pairs([], case_bands(case), STRICT_CONFLICT_TOLERANCE)
    assert strict == (), name
    assert result.tolerated_overlaps == (), name
    assert [(e.a, e.b) for e in result.edges] == detected(items, config), name


def test_select_capped_pairs_does_not_mutate_its_inputs() -> None:
    """The overlaps list and the band map are unchanged after the pass."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    name, fixture, case = CASES[-1]
    tolerated = overlaps(case["pairwise_tolerated"])
    bands = case_bands(case)
    tolerated_before = list(tolerated)
    bands_before = dict(bands)

    promoted = select_capped_pairs(
        tolerated, bands, config_conflict_tolerance(case_config(fixture))
    )

    assert promoted, name
    assert tolerated == tolerated_before, name
    assert bands == bands_before, name


@dataclass(frozen=True)
class PlainOverlap:
    """A structural stand-in exposing only a, b, cost, and benefit."""

    a: int
    b: int
    cost: int
    benefit: int


def test_select_capped_pairs_accepts_any_structural_overlap() -> None:
    """Any object exposing a, b, cost, and benefit is accepted."""
    from scripts.dev_tools._blast_radius_aggregate import select_capped_pairs

    name, fixture, case = CASES[0]
    plain = [
        PlainOverlap(o.a, o.b, o.cost, o.benefit)
        for o in overlaps(case["pairwise_tolerated"])
    ]

    promoted = select_capped_pairs(
        plain, case_bands(case), config_conflict_tolerance(case_config(fixture))
    )

    assert pairs_of(promoted) == case["expected_promoted"], name


def test_aggregate_module_has_no_runtime_import_of_scheduling() -> None:
    """The aggregate module imports the scheduling module only for typing."""
    source = AGGREGATE_SOURCE.read_text(encoding="utf-8")
    tree = ast.parse(source)

    # Collect every import that sits outside an `if TYPE_CHECKING:` block.
    runtime_imports: list[str] = []
    for node in tree.body:
        if isinstance(node, ast.If) and ast.unparse(node.test) == "TYPE_CHECKING":
            continue
        for child in ast.walk(node):
            if isinstance(child, ast.ImportFrom) and child.module:
                runtime_imports.append(child.module)
            elif isinstance(child, ast.Import):
                runtime_imports.extend(alias.name for alias in child.names)

    assert SCHEDULING_MODULE not in runtime_imports, runtime_imports
    assert all("_blast_radius_scheduling" not in name for name in runtime_imports)
