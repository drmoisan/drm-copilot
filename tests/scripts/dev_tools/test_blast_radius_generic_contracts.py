"""Regression tests for generic spreadsheet contract tokens (issue #1006).

A default spreadsheet sheet-tab name such as ``Sheet1`` names no exported
symbol, schema, or CLI identifier, yet the contract harvest recorded it as a
contract, so two unrelated work items whose specs mentioned a worksheet received
a hard ``contract_dependency`` edge. ``quality-tiers.yml`` produced a second
false hard edge as a shared surface. These tests cover the generic-contract
predicate, every Python contract-filtering site, and the end-to-end issue
scenario under both committed truth tables.

The token-shape module is imported as a module object and its new members are
read as attributes inside each test, so collection succeeds against the
pre-change code and every row fails on its own (fail-before evidence).

Every configuration is a committed truth table or an in-memory copy of one; no
temporary file is created and no external process is started.
"""

from __future__ import annotations

import copy
from typing import TYPE_CHECKING, cast

import pytest

import scripts.dev_tools._blast_radius_token_shapes as token_shapes
from scripts.dev_tools._blast_radius_extraction import extract_contract_identifiers
from scripts.dev_tools._blast_radius_glob import concrete_entries
from scripts.dev_tools._blast_radius_validation import resolve_shared_surfaces
from scripts.dev_tools._blast_radius_write_intent import (
    extract_write_intent_contracts,
)
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    SchedulingItem,
    conflicts,
    derive_blast_radius,
    normalize_declared_radius,
    schedule_conflict_edges,
)
from tests.scripts.dev_tools.blast_radius_parity_test_support import (
    BUNDLED_CONFIG,
    SELF_HOSTED_CONFIG,
)

if TYPE_CHECKING:
    from collections.abc import Mapping

# Deterministic timestamp for every radius built here.
COMPUTED_AT = "2026-10-30T11-05"

# A spec whose interface section names a default worksheet and one genuine
# contract identifier. Only the genuine identifier is a contract.
SPEC_WITH_SHEET_AND_CONTRACT = "\n".join(
    [
        "# Example spec",
        "## Interface",
        "- Reads worksheet `Sheet1` and exports `ParseLedger`.",
    ]
)

# The issue scenario spec: an interface section naming only the worksheet.
SCENARIO_SPEC = "\n".join(
    [
        "# Scenario spec",
        "## Interface",
        "- The importer reads worksheet `Sheet1`.",
    ]
)

# The issue scenario plan: one write to an ordinary file that is neither a
# shared surface nor matched by a shared-surface glob in either committed table.
SCENARIO_PLAN = "\n".join(
    [
        "### Phase 1 - Implementation",
        "- [ ] [P1-T1] Edit `src/issue_1006_ordinary_module.py`.",
    ]
)

# The append-only registry the planner appends after normalization.
TIER_MAP = "quality-tiers.yml"

# Both committed truth tables, labelled for readable parametrized node IDs.
COMMITTED_TABLES = (
    pytest.param(SELF_HOSTED_CONFIG, id="self-hosted"),
    pytest.param(BUNDLED_CONFIG, id="bundled"),
)


@pytest.mark.parametrize("token", ["Sheet1", "sheet12", "CHART3"])
def test_generic_contract_token_is_recognized(token: str) -> None:
    """A sheet or chart stem followed by ASCII digits is a generic token."""
    # Act
    result = token_shapes.is_generic_contract_token(token)

    # Assert
    assert result is True, f"{token!r} must be recognized as a generic token."


@pytest.mark.parametrize(
    "token",
    [
        "Sheet",
        "Sheet1a",
        "MySheet1",
        "Sheet1.Range",
        "",
        "Sheet１",
        "Sheet1K",
        "ſheet1",
        "Book1",
        "Table1",
    ],
)
def test_non_generic_token_is_rejected(token: str) -> None:
    """Every other shape, including non-ASCII look-alikes, is not generic."""
    # Act
    result = token_shapes.is_generic_contract_token(token)

    # Assert
    assert result is False, f"{token!r} must not be recognized as generic."


def test_generic_contract_stems_are_sheet_and_chart() -> None:
    """The stem constant is the closed set of default sheet-tab stems."""
    # Act
    stems = token_shapes.GENERIC_CONTRACT_STEMS

    # Assert
    assert stems == ("Sheet", "Chart")


def test_extract_contract_identifiers_drops_a_generic_token() -> None:
    """The current-extraction site keeps the genuine contract only."""
    # Act
    identifiers = extract_contract_identifiers(SPEC_WITH_SHEET_AND_CONTRACT)

    # Assert
    assert identifiers == ("ParseLedger",)


def test_extract_write_intent_contracts_drops_a_generic_token() -> None:
    """The write-intent site keeps the genuine contract only."""
    # Act
    identifiers = extract_write_intent_contracts(SPEC_WITH_SHEET_AND_CONTRACT)

    # Assert
    assert identifiers == ("ParseLedger",)


def test_normalize_declared_radius_drops_a_recorded_generic_contract() -> None:
    """A previously recorded ``Sheet1`` contract is dropped on recompute."""
    # Arrange: a declared radius recorded by the pre-change extractor.
    recorded = BlastRadius(
        paths=("docs/features/active/2026-10-30-recorded-item/**",),
        modules=(),
        shared_surfaces=(),
        contracts=("ParseLedger", "Sheet1"),
        source="declared",
        computed_at=COMPUTED_AT,
    )

    # Act
    normalized = normalize_declared_radius(recorded, SELF_HOSTED_CONFIG)

    # Assert
    assert normalized.contracts == ("ParseLedger",)


def _scenario_radius(feature_folder: str, config: Mapping[str, object]) -> BlastRadius:
    """Build one issue-scenario radius the way the planner records it.

    The radius is derived and normalized against ``config``; the planner then
    appends ``quality-tiers.yml`` to ``paths`` after normalization, and the
    shared surfaces are re-resolved from the extended path list.

    Args:
        feature_folder (str): Bare feature folder name of the item.
        config (Mapping[str, object]): Committed truth table to derive against.

    Returns:
        BlastRadius: The declared radius carrying the appended registry path.
    """
    derived = derive_blast_radius(
        SCENARIO_PLAN,
        SCENARIO_SPEC,
        feature_folder,
        config,
        source="declared",
        computed_at=COMPUTED_AT,
    )
    normalized = normalize_declared_radius(derived, config)
    paths = (*normalized.paths, TIER_MAP)
    return BlastRadius(
        paths=paths,
        modules=normalized.modules,
        shared_surfaces=resolve_shared_surfaces(concrete_entries(paths), config),
        contracts=normalized.contracts,
        source=normalized.source,
        computed_at=normalized.computed_at,
    )


def _scenario_items(config: Mapping[str, object]) -> tuple[SchedulingItem, ...]:
    """Build the two scheduling items of the issue scenario.

    Args:
        config (Mapping[str, object]): Committed truth table to derive against.

    Returns:
        tuple[SchedulingItem, ...]: Items keyed 41 and 42, as in the issue.
    """
    return (
        SchedulingItem(41, _scenario_radius("2026-10-30-item-41", config)),
        SchedulingItem(42, _scenario_radius("2026-10-30-item-42", config)),
    )


@pytest.mark.parametrize("config", COMMITTED_TABLES)
def test_issue_1006_scenario_has_no_hard_edge(config: Mapping[str, object]) -> None:
    """Benign overlap of the issue scenario never yields a hard edge."""
    # Arrange
    items = _scenario_items(config)
    radii = {item.key: item.radius for item in items}

    # Act
    result = schedule_conflict_edges(items, config)

    # Assert: name the reason kinds the relation reports for every hard edge,
    # because an edge record keeps only the first kind.
    hard_reasons = {
        (edge.a, edge.b): [
            reason.kind
            for reason in conflicts(radii[edge.a], radii[edge.b], config).reasons
        ]
        for edge in result.edges
        if edge.hard
    }
    assert hard_reasons == {}, f"Hard edges with reason kinds: {hard_reasons}."


@pytest.mark.parametrize("config", COMMITTED_TABLES)
def test_issue_1006_scenario_tolerance_zero_equals_detection(
    config: Mapping[str, object],
) -> None:
    """At tolerance zero the edge set equals the detected-conflict set."""
    # Arrange: the committed table with only the tolerance set to zero.
    strict = copy.deepcopy(dict(config))
    tolerance = cast("dict[str, object]", strict["conflict_tolerance"])
    tolerance["tolerance_percent"] = 0
    items = _scenario_items(strict)

    # Act
    result = schedule_conflict_edges(items, strict)

    # Assert: every pair the relation reports is an edge, and nothing else is.
    edge_pairs = {(edge.a, edge.b) for edge in result.edges}
    detected_pairs = {
        (first.key, second.key)
        for index, first in enumerate(items)
        for second in items[index + 1 :]
        if conflicts(first.radius, second.radius, strict).conflict
    }
    assert detected_pairs, "The scenario must contain at least one conflict."
    assert edge_pairs == detected_pairs
