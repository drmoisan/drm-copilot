"""Unit and fixture tests for the integration-cost scheduling layer (issue #722).

Covers the edge rule of ``scripts/dev_tools/_blast_radius_scheduling.py``: the
hard reason classes, every integer cost term (same_file, append_only with its
precedence over same_file, possible_overlap, module, and the mergeable zero),
the pairwise benefit with its default_band fallback, the integer inequality at
its boundary, first-kind reason selection, the strict conflict_tolerance reader,
the committed scheduling fixtures, and strict identity over the existing
conflict corpus.

The names under test are imported from the scheduling module itself rather than
through the ``compute_blast_radius`` re-export, so a missing module surfaces as
a collection error naming it. Every fixture read here is a committed file under
``tests/fixtures/blast_radius``; no temporary file is created and no external
process is started.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools._blast_radius_scheduling import (
    STRICT_CONFLICT_TOLERANCE,
    ConflictTolerance,
    SchedulingItem,
    config_conflict_tolerance,
    decide_pair,
    pair_benefit,
    pair_cost,
    schedule_conflict_edges,
)
from scripts.dev_tools.compute_blast_radius import BlastRadius, conflicts

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_DIR = REPO_ROOT / "tests" / "fixtures" / "blast_radius"
SCHEDULING_DIR = FIXTURE_DIR / "scheduling"
COMPUTED_AT = "2026-09-27T00-00"

SCHEDULING_STEMS: tuple[str, ...] = (
    "scheduling-452-shared-surface-hard",
    "scheduling-452-directory-prefix-weighted",
    "scheduling-452-negative-controls",
    "scheduling-soft-pair-tolerated",
    "scheduling-absent-key-strict",
)
FIXTURE_452_STEMS: tuple[str, ...] = SCHEDULING_STEMS[:3]

# The committed conflict_tolerance member (plan block B2), used by the unit tests
# so every weight and band duration has its committed value.
COMMITTED_TOLERANCE: dict[str, object] = {
    "tolerance_percent": 100,
    "weights": {"same_file": 8, "possible_overlap": 2, "append_only": 1, "module": 2},
    "band_durations": {"C1": 1, "C2": 2, "C3": 4, "C4": 8},
    "default_band": "C1",
    "append_only_paths": ["**/CHANGELOG.md"],
}


def make_config(**tolerance_overrides: object) -> dict[str, object]:
    """Build a minimal truth table carrying the committed tolerance member.

    Args:
        **tolerance_overrides (object): Members replacing the committed values.

    Returns:
        dict[str, object]: A fresh truth table; callers may mutate it freely.
    """
    tolerance = copy.deepcopy(COMMITTED_TOLERANCE)
    tolerance.update(tolerance_overrides)
    return {
        "version": 1,
        "shared_surfaces": [],
        "shared_surface_globs": [],
        "mergeable_paths": ["**/*.csproj"],
        "conflict_tolerance": tolerance,
        "modules": {"config": ["config/**"]},
        "over_breadth_fraction": 0.25,
    }


def make_radius(
    *,
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


def load_json(path: Path) -> Mapping[str, object]:
    """Read one committed fixture file as a JSON object."""
    return cast("Mapping[str, object]", json.loads(path.read_text(encoding="utf-8")))


def records(value: object) -> list[Mapping[str, object]]:
    """Narrow a fixture array of objects for the type checker."""
    return cast("list[Mapping[str, object]]", value)


def fixture_items(fixture: Mapping[str, object]) -> list[SchedulingItem]:
    """Build scheduling items from a scheduling fixture's embedded radii."""
    # One scheduling item per fixture item, keeping the fixture's key and band.
    return [
        SchedulingItem(
            key=cast("int", item["key"]),
            radius=BlastRadius.from_dict(cast("Mapping[str, object]", item["radius"])),
            band=cast("str | None", item["band"]),
        )
        for item in records(fixture["items"])
    ]


def config_for_case(
    config: Mapping[str, object], tolerance_percent: object
) -> Mapping[str, object]:
    """Return the fixture config, with tolerance_percent replaced when given."""
    if tolerance_percent is None:
        return config
    replaced = copy.deepcopy(dict(config))
    member = cast("dict[str, object]", replaced["conflict_tolerance"])
    member["tolerance_percent"] = tolerance_percent
    return replaced


def conflict_fixture_paths() -> tuple[Path, ...]:
    """List the top-level contention fixtures of the existing corpus."""
    # A contention fixture is recognized by its radius_a input key.
    return tuple(
        path
        for path in sorted(FIXTURE_DIR.glob("*.json"))
        if "radius_a" in cast("Mapping[str, object]", load_json(path)["input"])
    )


def test_shared_surface_overlap_is_hard_at_every_tolerance() -> None:
    """A shared-surface overlap is a hard edge whatever the tolerance."""
    a = make_radius(paths=["src/a.py"], shared_surfaces=["poetry.lock"])
    b = make_radius(paths=["src/b.py"], shared_surfaces=["poetry.lock"])

    # Zero, committed, and very large tolerance must all keep the hard edge.
    for tolerance in (0, 100, 1_000_000):
        decision = decide_pair(a, b, make_config(tolerance_percent=tolerance))

        assert decision.hard, f"tolerance {tolerance}: shared surface must be hard"
        assert decision.edge, f"tolerance {tolerance}: a hard pair must be an edge"


def test_contract_dependency_is_hard() -> None:
    """A contract dependency is hard and stays an edge at a large tolerance."""
    a = make_radius(paths=["src/a.py"], contracts=["computeWidget"])
    b = make_radius(paths=["src/b.py"], contracts=["computeWidget"])

    decision = decide_pair(a, b, make_config(tolerance_percent=1_000_000))

    assert decision.hard
    assert decision.edge
    assert decision.cost == 0, "contract dependency carries no cost term"
    assert decision.reason == "contract_dependency"


def test_cost_same_file_weight_for_equal_concrete_entries() -> None:
    """Two equal concrete paths cost the same_file weight."""
    a = make_radius(paths=["src/app.py"])
    b = make_radius(paths=["src/app.py"])
    tolerance = config_conflict_tolerance(make_config())

    assert pair_cost(a, b, make_config(), tolerance) == 8


def test_cost_append_only_is_evaluated_before_same_file() -> None:
    """An append-only file named by both items costs append_only, not same_file."""
    a = make_radius(paths=["CHANGELOG.md"])
    b = make_radius(paths=["CHANGELOG.md"])
    nested_a = make_radius(paths=["docs"])
    nested_b = make_radius(paths=["docs/CHANGELOG.md"])
    tolerance = config_conflict_tolerance(make_config())

    assert pair_cost(a, b, make_config(), tolerance) == 1
    assert pair_cost(nested_a, nested_b, make_config(), tolerance) == 1


def test_cost_possible_overlap_for_directory_prefix() -> None:
    """Directory-prefix and glob overlaps cost the possible_overlap weight."""
    directory = make_radius(paths=["scripts/dev_tools"])
    file_inside = make_radius(paths=["scripts/dev_tools/compute_blast_radius.py"])
    glob = make_radius(paths=["scripts/dev_tools/**"])
    tolerance = config_conflict_tolerance(make_config())

    assert pair_cost(directory, file_inside, make_config(), tolerance) == 2
    assert pair_cost(directory, glob, make_config(), tolerance) == 2
    assert pair_cost(glob, file_inside, make_config(), tolerance) == 2


def test_cost_module_weight_times_shared_modules() -> None:
    """Each shared module adds the module weight; disjoint paths add nothing."""
    a = make_radius(paths=["src/a.py"], modules=["core", "docs", "tests"])
    b = make_radius(paths=["src/b.py"], modules=["core", "docs"])
    tolerance = config_conflict_tolerance(make_config())

    assert pair_cost(a, b, make_config(), tolerance) == 4


def test_cost_mergeable_paths_contribute_zero() -> None:
    """A mergeable path is excluded before enumeration and costs nothing."""
    only_mergeable_a = make_radius(paths=["pkg/app.csproj"])
    only_mergeable_b = make_radius(paths=["pkg/app.csproj"])
    mixed_a = make_radius(paths=["pkg/app.csproj", "src/app.py"])
    mixed_b = make_radius(paths=["pkg/app.csproj", "src/app.py"])
    tolerance = config_conflict_tolerance(make_config())

    assert pair_cost(only_mergeable_a, only_mergeable_b, make_config(), tolerance) == 0
    assert pair_cost(mixed_a, mixed_b, make_config(), tolerance) == 8


def test_benefit_is_minimum_band_duration() -> None:
    """The benefit is the shorter of the two band durations."""
    tolerance = config_conflict_tolerance(make_config())

    assert pair_benefit("C2", "C4", tolerance) == 2
    assert pair_benefit("C4", "C3", tolerance) == 4
    with pytest.raises(ValueError, match="band"):
        pair_benefit("C9", "C1", tolerance)


def test_benefit_uses_default_band_for_missing_band() -> None:
    """A missing band reads as default_band."""
    tolerance = config_conflict_tolerance(make_config(default_band="C3"))

    assert pair_benefit(None, "C4", tolerance) == 4
    assert pair_benefit(None, None, tolerance) == 4
    assert pair_benefit("C1", None, tolerance) == 1


def test_edge_rule_integer_inequality_boundary() -> None:
    """edge iff cost * 100 > benefit * tolerance_percent (strictly greater)."""
    a = make_radius(paths=["scripts/dev_tools"])
    b = make_radius(paths=["scripts/dev_tools/x.py"])

    below = decide_pair(a, b, make_config(tolerance_percent=199))
    at = decide_pair(a, b, make_config(tolerance_percent=200))

    assert (below.cost, below.benefit) == (2, 1)
    assert below.edge, "200 > 199 must yield an edge"
    assert not at.edge, "200 > 200 is false, so the pair is tolerated"
    assert at.conflict and not at.hard


def test_recorded_reason_is_first_canonical_kind() -> None:
    """The recorded reason is the first kind of the relation's reason list."""
    path_and_module_a = make_radius(paths=["src/app.py"], modules=["core"])
    path_and_module_b = make_radius(paths=["src/app.py"], modules=["core"])
    module_and_surface_a = make_radius(
        modules=["core"], shared_surfaces=["poetry.lock"]
    )
    module_and_surface_b = make_radius(
        modules=["core"], shared_surfaces=["poetry.lock"]
    )

    first = decide_pair(path_and_module_a, path_and_module_b, make_config())
    second = decide_pair(module_and_surface_a, module_and_surface_b, make_config())

    assert first.reasons == ("path_overlap", "module_overlap")
    assert first.reason == "path_overlap"
    assert second.reasons == ("module_overlap", "shared_surface_overlap")
    assert second.reason == "module_overlap"


def test_absent_key_reads_as_strict() -> None:
    """A truth table without conflict_tolerance reads as the strict semantics."""
    config = make_config()
    del config["conflict_tolerance"]

    tolerance = config_conflict_tolerance(config)

    assert tolerance == STRICT_CONFLICT_TOLERANCE
    assert tolerance == ConflictTolerance(
        tolerance_percent=0,
        weights={"same_file": 1, "possible_overlap": 1, "append_only": 1, "module": 1},
        band_durations={"C1": 1, "C2": 1, "C3": 1, "C4": 1},
        default_band="C1",
        append_only_paths=(),
    )


def _without(mapping_key: str, member: str) -> dict[str, object]:
    """Return the committed member with one name removed from a nested map."""
    member_copy = copy.deepcopy(COMMITTED_TOLERANCE)
    del cast("dict[str, object]", member_copy[mapping_key])[member]
    return member_copy


def _with(mapping_key: str, member: str, value: object) -> dict[str, object]:
    """Return the committed member with one nested value replaced."""
    member_copy = copy.deepcopy(COMMITTED_TOLERANCE)
    cast("dict[str, object]", member_copy[mapping_key])[member] = value
    return member_copy


INVALID_SHAPES: tuple[tuple[str, object], ...] = (
    ("non-object", ["tolerance_percent", 100]),
    ("percent-negative", {**COMMITTED_TOLERANCE, "tolerance_percent": -1}),
    ("percent-float", {**COMMITTED_TOLERANCE, "tolerance_percent": 1.5}),
    ("percent-string", {**COMMITTED_TOLERANCE, "tolerance_percent": "100"}),
    ("percent-bool", {**COMMITTED_TOLERANCE, "tolerance_percent": True}),
    ("weight-zero", _with("weights", "same_file", 0)),
    ("weight-bool", _with("weights", "module", True)),
    ("weight-float", _with("weights", "append_only", 1.0)),
    ("weight-unknown-name", _with("weights", "same_symbol", 3)),
    ("weight-missing-name", _without("weights", "module")),
    ("band-duration-zero", _with("band_durations", "C1", 0)),
    ("band-missing-name", _without("band_durations", "C4")),
    ("default-band-out-of-range", {**COMMITTED_TOLERANCE, "default_band": "C5"}),
    ("append-only-not-list", {**COMMITTED_TOLERANCE, "append_only_paths": "x.md"}),
)


@pytest.mark.parametrize(
    "member", [shape for _, shape in INVALID_SHAPES], ids=[n for n, _ in INVALID_SHAPES]
)
def test_conflict_tolerance_reader_rejects_invalid_shape(member: object) -> None:
    """Every invalid conflict_tolerance shape fails fast naming the key."""
    config = make_config()
    config["conflict_tolerance"] = member

    with pytest.raises((TypeError, ValueError), match="conflict_tolerance"):
        config_conflict_tolerance(config)


@pytest.mark.parametrize("stem", SCHEDULING_STEMS)
def test_scheduling_fixture_reproduces_expected_decisions(stem: str) -> None:
    """Every case of a committed scheduling fixture reproduces its expectations."""
    fixture = load_json(SCHEDULING_DIR / f"{stem}.json")
    config = cast("Mapping[str, object]", fixture["config"])
    items = fixture_items(fixture)

    # Each case reschedules the same items at its own tolerance.
    for index, case in enumerate(records(fixture["cases"])):
        result = schedule_conflict_edges(
            items, config_for_case(config, case["tolerance_percent"])
        )

        label = f"{stem} case {index}"
        assert [e.to_dict() for e in result.edges] == case["expected_edges"], label
        assert [t.to_dict() for t in result.tolerated_overlaps] == case[
            "expected_tolerated"
        ], label


def test_452_scheduling_fixtures_embed_radii() -> None:
    """Each #452 scheduling fixture embeds full radii rather than a file reference."""
    # Every item of every #452 fixture must carry a complete radius object.
    for stem in FIXTURE_452_STEMS:
        fixture = load_json(SCHEDULING_DIR / f"{stem}.json")

        assert "#452-case" in cast("list[str]", fixture["tags"]), stem
        for item in records(fixture["items"]):
            radius = item["radius"]
            assert isinstance(radius, dict), f"{stem}: radius must be embedded"
            BlastRadius.from_dict(cast("Mapping[str, object]", radius))
        assert ".json" not in json.dumps(fixture["items"]), stem


def test_strict_identity_over_existing_conflict_fixtures() -> None:
    """At tolerance 0 and with the key absent, edges equal detected conflicts."""
    paths = conflict_fixture_paths()
    assert len(paths) >= 10, "the existing contention corpus must be present"

    # Schedule each fixture pair twice: key absent, and key present at tolerance 0.
    for path in paths:
        fixture_input = cast("Mapping[str, object]", load_json(path)["input"])
        radius_a = BlastRadius.from_dict(
            cast("Mapping[str, object]", fixture_input["radius_a"])
        )
        radius_b = BlastRadius.from_dict(
            cast("Mapping[str, object]", fixture_input["radius_b"])
        )
        absent = dict(cast("Mapping[str, object]", fixture_input["config"]))
        absent.pop("conflict_tolerance", None)
        zero = {**absent, "conflict_tolerance": {**COMMITTED_TOLERANCE}}
        cast("dict[str, object]", zero["conflict_tolerance"])["tolerance_percent"] = 0
        items = [SchedulingItem(1, radius_a), SchedulingItem(2, radius_b)]
        detected: set[tuple[int, int]] = (
            {(1, 2)} if conflicts(radius_a, radius_b, absent).conflict else set()
        )

        for config in (absent, zero):
            result = schedule_conflict_edges(items, config)

            assert {(e.a, e.b) for e in result.edges} == detected, path.name
            assert result.tolerated_overlaps == (), path.name


def test_edges_and_tolerated_overlaps_are_sorted_by_pair() -> None:
    """Output is sorted by (a, b) with a < b whatever the input order."""
    shared = ["src/app.py"]
    items = [
        SchedulingItem(9, make_radius(paths=shared), "C4"),
        SchedulingItem(3, make_radius(paths=shared), "C4"),
        SchedulingItem(5, make_radius(paths=["CHANGELOG.md"]), "C4"),
        SchedulingItem(1, make_radius(paths=["CHANGELOG.md"]), "C4"),
        SchedulingItem(7, make_radius(paths=shared), "C4"),
    ]

    result = schedule_conflict_edges(items, make_config(tolerance_percent=50))

    assert [(e.a, e.b) for e in result.edges] == [(3, 7), (3, 9), (7, 9)]
    assert [(t.a, t.b) for t in result.tolerated_overlaps] == [(1, 5)]
    with pytest.raises(ValueError, match="distinct"):
        schedule_conflict_edges([items[0], items[0]], make_config())
    with pytest.raises(TypeError, match="key"):
        schedule_conflict_edges([SchedulingItem(True, make_radius())], make_config())
