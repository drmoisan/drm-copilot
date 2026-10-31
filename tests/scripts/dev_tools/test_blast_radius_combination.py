"""Fixture-driven tests for issue combination (issue #1013, spec D-5 and D-7).

The four committed fixtures under ``tests/fixtures/blast_radius/combination``
carry hand-derived qualifying pairs and combinations: the threshold boundary,
the candidate classes, a three-item component chain with the tolerance-0 and
absent-key cases, and a contract-only pair that combines through the D-7
contract term. The tests run ``find_combinations`` over every case and pin
``has_same_file_overlap``, rule 1 (disabled at tolerance 0 and with the key
absent), ``estimated_savings``, and purity.

The combination module's symbols are imported inside each test, so the module
collects before the implementation exists. No test creates a file or starts a
process.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._blast_radius_scheduling import (
    SchedulingItem,
    config_conflict_tolerance,
)
from scripts.dev_tools.compute_blast_radius import BlastRadius

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

REPO_ROOT = Path(__file__).resolve().parents[3]
COMBINATION_DIR = REPO_ROOT / "tests" / "fixtures" / "blast_radius" / "combination"
FIXTURE_NAMES: tuple[str, ...] = (
    "combination-threshold-boundary",
    "combination-candidate-classes",
    "combination-component-chain",
    "combination-contract-only",
)
COMPUTED_AT = "2026-10-30T00-00"


def load_fixture(name: str) -> Mapping[str, object]:
    """Read one committed combination fixture."""
    path = COMBINATION_DIR / f"{name}.json"
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
    fixture: Mapping[str, object], case: Mapping[str, object]
) -> dict[str, object]:
    """Copy a fixture's truth table and apply the case's tolerance override."""
    config = copy.deepcopy(dict(cast("Mapping[str, object]", fixture["config"])))
    if case.get("conflict_tolerance_absent") is True:
        del config["conflict_tolerance"]
    elif "tolerance_percent" in case:
        member = cast("dict[str, object]", config["conflict_tolerance"])
        member["tolerance_percent"] = case["tolerance_percent"]
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


def make_radius(
    paths: Sequence[str] = (), contracts: Sequence[str] = ()
) -> BlastRadius:
    """Build a declared radius with only paths and contracts set."""
    return BlastRadius(
        paths=paths,
        modules=(),
        shared_surfaces=(),
        contracts=contracts,
        source="declared",
        computed_at=COMPUTED_AT,
    )


def base_config(*, mergeable: Sequence[str] = ()) -> dict[str, object]:
    """Return the candidate-classes truth table with optional mergeable paths."""
    fixture = load_fixture("combination-candidate-classes")
    config = copy.deepcopy(dict(cast("Mapping[str, object]", fixture["config"])))
    config["mergeable_paths"] = list(mergeable)
    return config


@pytest.mark.parametrize(("name", "fixture", "case"), CASES, ids=CASE_IDS)
def test_find_combinations_matches_fixture(
    name: str, fixture: Mapping[str, object], case: Mapping[str, object]
) -> None:
    """Qualifying pairs and combinations equal the hand-derived expectations."""
    from scripts.dev_tools._blast_radius_combination import find_combinations

    result = find_combinations(case_items(case), case_config(fixture, case))

    assert [pair.to_dict() for pair in result.pairs] == case["expected_pairs"], name
    assert [combination.to_dict() for combination in result.combinations] == case[
        "expected_combinations"
    ], name


@pytest.mark.parametrize(("name", "fixture", "case"), CASES, ids=CASE_IDS)
def test_estimated_savings_is_the_sum_of_qualifying_pair_costs(
    name: str, fixture: Mapping[str, object], case: Mapping[str, object]
) -> None:
    """Each combination's savings equal the summed cost of its pairs."""
    from scripts.dev_tools._blast_radius_combination import find_combinations

    result = find_combinations(case_items(case), case_config(fixture, case))

    for combination in result.combinations:
        total = sum(pair.cost for pair in combination.pairs)
        assert combination.estimated_savings == total, name
        assert combination.primary == min(combination.members), name
        assert list(combination.members) == sorted(combination.members), name


def test_contract_only_pair_combines_when_its_cost_meets_the_threshold() -> None:
    """The C2 contract-only pair combines and the C3/C4 pair does not (AC-28)."""
    from scripts.dev_tools._blast_radius_combination import find_combinations

    fixture = load_fixture("combination-contract-only")
    case = records(fixture["cases"])[0]

    result = find_combinations(case_items(case), case_config(fixture, case))

    assert [(pair.a, pair.b) for pair in result.pairs] == [(1, 2)]
    assert [list(c.members) for c in result.combinations] == [[1, 2]]


def test_combination_is_disabled_at_tolerance_zero() -> None:
    """Rule 1: tolerance_percent 0 returns no pairs and no combinations."""
    from scripts.dev_tools._blast_radius_combination import find_combinations

    fixture = load_fixture("combination-component-chain")
    case = records(fixture["cases"])[0]
    config = case_config(fixture, {"tolerance_percent": 0})

    result = find_combinations(case_items(case), config)

    assert result.pairs == ()
    assert result.combinations == ()


def test_combination_is_disabled_when_the_key_is_absent() -> None:
    """Rule 1: an absent conflict_tolerance key returns nothing."""
    from scripts.dev_tools._blast_radius_combination import find_combinations

    fixture = load_fixture("combination-component-chain")
    case = records(fixture["cases"])[0]
    config = case_config(fixture, {"conflict_tolerance_absent": True})

    result = find_combinations(case_items(case), config)

    assert result.pairs == ()
    assert result.combinations == ()


def test_find_combinations_does_not_mutate_its_inputs() -> None:
    """The item list and the config are unchanged after the call."""
    from scripts.dev_tools._blast_radius_combination import find_combinations

    fixture = load_fixture("combination-component-chain")
    case = records(fixture["cases"])[0]
    items = case_items(case)
    config = case_config(fixture, case)
    items_before = list(items)
    config_before = copy.deepcopy(config)

    result = find_combinations(items, config)

    assert result.combinations
    assert items == items_before
    assert config == config_before


@pytest.mark.parametrize(
    ("label", "paths_a", "paths_b", "mergeable", "expected"),
    [
        ("equal concrete entries", ["src/x.py"], ["src/x.py"], (), True),
        (
            "append-only equal entries",
            ["docs/CHANGELOG.md"],
            ["docs/CHANGELOG.md"],
            (),
            False,
        ),
        ("glob against concrete", ["src/**"], ["src/x.py"], (), False),
        ("equal globs", ["src/**"], ["src/**"], (), False),
        (
            "mergeable equal entries",
            ["pkg/app.csproj"],
            ["pkg/app.csproj"],
            ("**/*.csproj",),
            False,
        ),
        ("disjoint entries", ["src/x.py"], ["src/y.py"], (), False),
        (
            "one same file among others",
            ["a.py", "docs/CHANGELOG.md"],
            ["a.py", "docs/CHANGELOG.md"],
            (),
            True,
        ),
    ],
)
def test_has_same_file_overlap(
    label: str,
    paths_a: list[str],
    paths_b: list[str],
    mergeable: tuple[str, ...],
    expected: bool,
) -> None:
    """Only two equal, non-mergeable, non-append-only concrete entries count."""
    from scripts.dev_tools._blast_radius_combination import has_same_file_overlap

    config = base_config(mergeable=mergeable)
    tolerance = config_conflict_tolerance(config)

    observed = has_same_file_overlap(
        make_radius(paths_a), make_radius(paths_b), config, tolerance
    )

    assert observed is expected, label


def test_has_same_file_overlap_is_symmetric() -> None:
    """Swapping the two radii leaves the verdict unchanged."""
    from scripts.dev_tools._blast_radius_combination import has_same_file_overlap

    config = base_config()
    tolerance = config_conflict_tolerance(config)
    left = make_radius(["src/x.py", "src/**"])
    right = make_radius(["src/x.py"])

    forward = has_same_file_overlap(left, right, config, tolerance)
    backward = has_same_file_overlap(right, left, config, tolerance)

    assert forward is backward is True


def test_combination_record_to_dict_shape() -> None:
    """A combination record serializes members, primary, pairs, and savings."""
    from scripts.dev_tools._blast_radius_combination import find_combinations

    fixture = load_fixture("combination-component-chain")
    case = records(fixture["cases"])[0]

    result = find_combinations(case_items(case), case_config(fixture, case))

    assert set(result.combinations[0].to_dict()) == {
        "members",
        "primary",
        "pairs",
        "estimated_savings",
    }
    assert set(result.pairs[0].to_dict()) == {"a", "b", "cost", "benefit"}
