"""Tests for the ``contract`` cost weight (issue #1013, spec D-7).

Pins four groups of behavior:

- Reader (AC-26): ``conflict_tolerance.weights.contract`` is a required weight
  name read like the other four (an integer of at least 1; booleans rejected),
  and the absent-key reading carries ``contract`` 1.
- Cost (AC-27): ``pair_cost`` adds the contract weight once per distinct shared
  contract identifier, compared ordinally, and changes nothing for a pair that
  shares no identifier; a contract-only pair stays a hard edge.
- Invariant (AC-29): at tolerance 0 the edges equal detection for any weight,
  and at every tolerance the edge and tolerated sets equal those produced with
  the contract term removed, which differs only in the edges' cost.
- Committed values (AC-07, AC-09, AC-26): both committed truth tables carry the
  five-name weights map with ``contract`` 8 as its last member.

Every config is built in memory without ``combination_threshold_percent``, and
every shared contract identifier is a token that is not a generic contract
token. The module uses only symbols that exist before implementation. No test
creates a file or starts a process.
"""

from __future__ import annotations

import itertools
import json
from pathlib import Path
from typing import TYPE_CHECKING, cast

import pytest

from scripts.dev_tools import _blast_radius_scheduling as scheduling
from scripts.dev_tools._blast_radius_conflicts import conflicts
from scripts.dev_tools._blast_radius_scheduling import (
    STRICT_CONFLICT_TOLERANCE,
    ConflictTolerance,
    SchedulingItem,
    SchedulingResult,
    config_conflict_tolerance,
    decide_pair,
    pair_cost,
    schedule_conflict_edges,
)
from scripts.dev_tools.compute_blast_radius import BlastRadius

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

REPO_ROOT = Path(__file__).resolve().parents[3]
COMMITTED_COPIES: tuple[Path, ...] = (
    REPO_ROOT / "config" / "blast-radius.json",
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "claude-customizations"
    / "config"
    / "blast-radius.json",
)
COPY_IDS = ("repository", "bundled")
COMMITTED_WEIGHTS: dict[str, int] = {
    "same_file": 8,
    "possible_overlap": 2,
    "append_only": 1,
    "module": 2,
    "contract": 8,
}
WEIGHTS_LABEL = r'config\["conflict_tolerance"\]\["weights"\]'
CONTRACT_LABEL = r'config\["conflict_tolerance"\]\["weights"\]\["contract"\]'
COMPUTED_AT = "2026-10-30T00-00"


def make_config(
    *, tolerance_percent: int = 100, weights: Mapping[str, object] | None = None
) -> dict[str, object]:
    """Build a truth table with the given tolerance and weights map."""
    return {
        "version": 1,
        "shared_surfaces": [],
        "shared_surface_globs": [],
        "mergeable_paths": [],
        "conflict_tolerance": {
            "tolerance_percent": tolerance_percent,
            "weights": dict(COMMITTED_WEIGHTS if weights is None else weights),
            "band_durations": {"C1": 1, "C2": 2, "C3": 4, "C4": 8},
            "default_band": "C1",
            "append_only_paths": ["**/CHANGELOG.md"],
        },
        "modules": {},
        "over_breadth_fraction": 0.25,
    }


def with_contract(value: object) -> dict[str, object]:
    """Return the committed weights with the contract value replaced."""
    return {**COMMITTED_WEIGHTS, "contract": value}


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


def committed_tolerance() -> tuple[dict[str, object], ConflictTolerance]:
    """Return a config with the committed weights and its validated reading."""
    config = make_config()
    return config, config_conflict_tolerance(config)


# ---------------------------------------------------------------- reader (AC-26)


@pytest.mark.parametrize("value", [1, 8, 1000])
def test_reader_accepts_a_contract_weight_of_at_least_one(value: int) -> None:
    """1, 8, and 1000 are read verbatim."""
    tolerance = config_conflict_tolerance(make_config(weights=with_contract(value)))

    assert tolerance.weights["contract"] == value


def test_reader_rejects_a_missing_contract_name() -> None:
    """The contract name is required, like the other four weight names."""
    weights = {k: v for k, v in COMMITTED_WEIGHTS.items() if k != "contract"}

    with pytest.raises(ValueError, match=WEIGHTS_LABEL):
        config_conflict_tolerance(make_config(weights=weights))


def test_reader_rejects_an_unknown_extra_weight_name() -> None:
    """A sixth, unknown weight name is still rejected."""
    weights = {**COMMITTED_WEIGHTS, "surface": 4}

    with pytest.raises(ValueError, match=WEIGHTS_LABEL):
        config_conflict_tolerance(make_config(weights=weights))


@pytest.mark.parametrize("value", [True, 8.0, "8"], ids=["boolean", "float", "string"])
def test_reader_rejects_a_non_integer_contract_weight(value: object) -> None:
    """A boolean, float, or string contract weight raises TypeError."""
    with pytest.raises(TypeError, match=CONTRACT_LABEL):
        config_conflict_tolerance(make_config(weights=with_contract(value)))


@pytest.mark.parametrize("value", [0, -1])
def test_reader_rejects_a_contract_weight_below_one(value: int) -> None:
    """0 and -1 raise ValueError naming the contract weight."""
    with pytest.raises(ValueError, match=CONTRACT_LABEL):
        config_conflict_tolerance(make_config(weights=with_contract(value)))


def test_strict_reading_carries_a_unit_contract_weight() -> None:
    """The absent-key reading carries contract 1, like every other weight."""
    assert STRICT_CONFLICT_TOLERANCE.weights["contract"] == 1


# ------------------------------------------------------------------ cost (AC-27)


@pytest.mark.parametrize(
    ("shared", "expected"),
    [((), 0), (("ParseLedger",), 8), (("FormatInvoice", "ParseLedger"), 16)],
    ids=["zero", "one", "two"],
)
def test_cost_adds_the_contract_weight_per_shared_identifier(
    shared: tuple[str, ...], expected: int
) -> None:
    """Disjoint paths sharing 0, 1, and 2 identifiers cost 0, 8, and 16."""
    config, tolerance = committed_tolerance()
    left = make_radius(paths=["src/a.py"], contracts=[*shared, "LeftOnly"])
    right = make_radius(paths=["src/b.py"], contracts=[*shared, "RightOnly"])

    assert pair_cost(left, right, config, tolerance) == expected


def test_cost_counts_a_repeated_identifier_once() -> None:
    """An identifier listed twice in one radius is counted once."""
    config, tolerance = committed_tolerance()
    left = make_radius(paths=["src/a.py"], contracts=["ParseLedger", "ParseLedger"])
    right = make_radius(paths=["src/b.py"], contracts=["ParseLedger"])

    assert pair_cost(left, right, config, tolerance) == 8


def test_identifiers_differing_in_case_are_not_shared() -> None:
    """Contract identifiers compare ordinally: a case change shares nothing."""
    config, tolerance = committed_tolerance()
    left = make_radius(paths=["src/a.py"], contracts=["ParseLedger"])
    right = make_radius(paths=["src/b.py"], contracts=["parseledger"])

    kinds = [reason.kind for reason in conflicts(left, right, config).reasons]

    assert pair_cost(left, right, config, tolerance) == 0
    assert "contract_dependency" not in kinds


def test_same_file_pair_sharing_one_identifier_costs_both_terms() -> None:
    """A same-file overlap plus one shared identifier costs 8 + 8."""
    config, tolerance = committed_tolerance()
    left = make_radius(paths=["src/x.py"], contracts=["ParseLedger"])
    right = make_radius(paths=["src/x.py"], contracts=["ParseLedger"])

    assert pair_cost(left, right, config, tolerance) == 16


NO_SHARED_CONTRACT_PAIRS: tuple[tuple[BlastRadius, BlastRadius], ...] = (
    (make_radius(paths=["src/x.py"]), make_radius(paths=["src/x.py"])),
    (
        make_radius(paths=["src/**"], modules=["core"]),
        make_radius(paths=["src/a.py"], modules=["core"]),
    ),
    (make_radius(paths=["CHANGELOG.md"]), make_radius(paths=["CHANGELOG.md"])),
    (make_radius(contracts=["ParseLedger"]), make_radius(contracts=["FormatInvoice"])),
    (
        make_radius(shared_surfaces=["poetry.lock"]),
        make_radius(shared_surfaces=["poetry.lock"]),
    ),
)


@pytest.mark.parametrize(("left", "right"), NO_SHARED_CONTRACT_PAIRS)
def test_cost_without_a_shared_identifier_is_independent_of_the_weight(
    left: BlastRadius, right: BlastRadius
) -> None:
    """A pair sharing no identifier costs the same under contract 1 and 1000."""
    low = make_config(weights=with_contract(1))
    high = make_config(weights=with_contract(1000))

    low_cost = pair_cost(left, right, low, config_conflict_tolerance(low))
    high_cost = pair_cost(left, right, high, config_conflict_tolerance(high))

    assert low_cost == high_cost


def test_contract_only_pair_stays_a_hard_edge_at_any_tolerance() -> None:
    """At tolerance 1000000 a contract-only pair is still a hard edge, cost 8."""
    config = make_config(tolerance_percent=1_000_000)
    left = make_radius(paths=["src/a.py"], contracts=["ParseLedger"])
    right = make_radius(paths=["src/b.py"], contracts=["ParseLedger"])

    decision = decide_pair(left, right, config)

    assert decision.hard is True
    assert decision.edge is True
    assert decision.cost == 8


# ------------------------------------------------------------ invariant (AC-29)

INVARIANT_RADII: tuple[BlastRadius, ...] = (
    make_radius(paths=["src/app.py"], modules=["core"], contracts=["ParseLedger"]),
    make_radius(paths=["src/app.py"], contracts=["FormatInvoice", "ParseLedger"]),
    make_radius(
        paths=["src/**"], modules=["core"], contracts=["FormatInvoice", "ParseLedger"]
    ),
    make_radius(paths=["CHANGELOG.md"], shared_surfaces=["poetry.lock"]),
    make_radius(
        modules=["core"], shared_surfaces=["poetry.lock"], contracts=["FormatInvoice"]
    ),
    make_radius(paths=["docs/guide.md", "CHANGELOG.md"], modules=["docs"]),
)
INVARIANT_BANDS: tuple[tuple[str | None, ...], ...] = (
    (None, None, None, None, None, None),
    ("C4", "C4", "C4", "C4", "C4", "C4"),
    ("C1", "C2", "C3", "C4", "C2", "C1"),
)
INVARIANT_TOLERANCES: tuple[int, ...] = (0, 1, 50, 100, 400, 1_000_000)
CONTRACT_WEIGHTS: tuple[int, ...] = (1, 8, 1000)


def invariant_items(bands: Sequence[str | None]) -> list[SchedulingItem]:
    """Pair every invariant radius template with one band vector."""
    return [
        SchedulingItem(key=index + 1, radius=radius, band=band)
        for index, (radius, band) in enumerate(zip(INVARIANT_RADII, bands, strict=True))
    ]


def shared_count(left: BlastRadius, right: BlastRadius) -> int:
    """Count the distinct contract identifiers two radii share."""
    return len(set(left.contracts) & set(right.contracts))


def without_contract_term(
    left: BlastRadius,
    right: BlastRadius,
    config: Mapping[str, object],
    tolerance: ConflictTolerance,
) -> int:
    """Return the pair cost with the contract term subtracted."""
    term = tolerance.weights["contract"] * shared_count(left, right)
    return pair_cost(left, right, config, tolerance) - term


def pair_sets(result: SchedulingResult) -> tuple[set[tuple[int, int]], ...]:
    """Return the edge and tolerated pair sets of a scheduling result."""
    return (
        {(edge.a, edge.b) for edge in result.edges},
        {(item.a, item.b) for item in result.tolerated_overlaps},
    )


@pytest.mark.parametrize("weight", CONTRACT_WEIGHTS)
def test_invariant_tolerance_zero_edges_equal_detection(weight: int) -> None:
    """At tolerance 0 the edge pairs equal the detected pairs for any weight."""
    config = make_config(tolerance_percent=0, weights=with_contract(weight))

    # Check every band vector over the fixed item set.
    for bands in INVARIANT_BANDS:
        items = invariant_items(bands)
        detected = {
            (a.key, b.key)
            for a, b in itertools.combinations(items, 2)
            if conflicts(a.radius, b.radius, config).conflict
        }

        result = schedule_conflict_edges(items, config)

        assert pair_sets(result) == (detected, set()), bands


@pytest.mark.parametrize("weight", CONTRACT_WEIGHTS)
@pytest.mark.parametrize("tolerance_percent", INVARIANT_TOLERANCES)
def test_invariant_contract_term_changes_only_edge_costs(
    weight: int, tolerance_percent: int, monkeypatch: pytest.MonkeyPatch
) -> None:
    """With and without the term the pair sets agree; costs differ by the term."""
    config = make_config(
        tolerance_percent=tolerance_percent, weights=with_contract(weight)
    )
    radii = dict(enumerate(INVARIANT_RADII, start=1))

    # Schedule each band vector with the term, then with it removed.
    for bands in INVARIANT_BANDS:
        items = invariant_items(bands)
        with_term = schedule_conflict_edges(items, config)
        with monkeypatch.context() as patch:
            patch.setattr(scheduling, "pair_cost", without_contract_term)
            without_term = schedule_conflict_edges(items, config)

        assert pair_sets(with_term) == pair_sets(without_term), bands
        base = {(edge.a, edge.b): edge.cost for edge in without_term.edges}
        for edge in with_term.edges:
            product = weight * shared_count(radii[edge.a], radii[edge.b])
            assert edge.cost - base[(edge.a, edge.b)] == product, (bands, edge)


def test_invariant_domain_carries_shared_contracts() -> None:
    """The invariant domain includes pairs sharing zero, one, and two contracts."""
    counts = {shared_count(a, b) for a, b in itertools.combinations(INVARIANT_RADII, 2)}

    assert {0, 1, 2} <= counts


# ------------------------------------------------- committed values (AC-07/09/26)


@pytest.mark.parametrize("path", COMMITTED_COPIES, ids=COPY_IDS)
def test_committed_tables_carry_the_contract_weight(path: Path) -> None:
    """Both committed weights maps equal the five-name map, contract last."""
    config = cast("dict[str, object]", json.loads(path.read_text(encoding="utf-8")))
    member = cast("dict[str, object]", config["conflict_tolerance"])
    weights = cast("dict[str, int]", member["weights"])

    assert weights == COMMITTED_WEIGHTS, path.name
    assert list(weights)[-1] == "contract", path.name
