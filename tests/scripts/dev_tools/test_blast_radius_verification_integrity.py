"""Regression pin for the `verification-integrity` false-conflict-edge defect.

Purpose:
    Pin the recorded before-state of the `verification-integrity` parallel run
    (issues 485, 486, 487) so the blast-radius fix delivered for issue #489 is
    demonstrated against committed data rather than against a gitignored
    working-tree checkpoint.

Responsibilities:
    This module asserts both states. BEFORE: the three radii load at their
    recorded sizes, the frozen contention relation over those radii under the
    pre-fix config yields the complete K3 triangle, and colouring that triangle
    yields three single-item cohorts (fully serial execution). AFTER: the same
    recorded radii, re-filtered by `normalize_declared_radius` against the
    committed `config/blast-radius.json`, contend on one pair only, and that
    pair colours into two cohorts with 485 and 486 concurrent.

Key invariants and constraints:
    Every assertion here must hold both before and after the fix. The
    Every BEFORE assertion here must hold both before and after the fix. The
    contention relation in `scripts/dev_tools/_blast_radius_conflicts.py` is a
    frozen surface for issue #489, and the pre-fix config is embedded in the
    fixture rather than read from `config/blast-radius.json`, so neither input
    moves when the repository config is amended. The AFTER assertions read the
    committed repository config deliberately: the fix is only delivered if the
    config that actually ships produces the two-cohort partition.

Important side effects:
    None. Every test reads one committed JSON fixture and calls pure functions.
"""

from __future__ import annotations

import json
from itertools import combinations
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools._blast_radius_conflicts import conflicts
from scripts.dev_tools.compute_blast_radius import (
    BlastRadius,
    normalize_declared_radius,
)
from scripts.dev_tools.parallel_cohort_computation import compute_cohorts

FIXTURE_PATH = Path(
    "tests/fixtures/blast_radius/verification-integrity"
    "/verification-integrity-485-486-487.json"
)

# The three items of the recorded run, ascending. Edge identity is canonical
# (a < b), so this ordering also fixes the expected edge-pair ordering below.
ITEM_KEYS: tuple[int, ...] = (485, 486, 487)

# Recorded radius cardinalities as (paths, modules, shared_surfaces, contracts).
# These pin the fixture against silent truncation of the captured source data.
EXPECTED_SIZES: dict[int, tuple[int, int, int, int]] = {
    485: (184, 6, 1, 40),
    486: (125, 3, 2, 45),
    487: (140, 4, 1, 10),
}

# The complete triangle the defect produced: every pair contended, so the
# colouring had no choice but to serialise all three items.
EXPECTED_BEFORE_EDGES: list[tuple[int, int]] = [(485, 486), (485, 487), (486, 487)]

# Three single-item cohorts, i.e. fully serial execution.
EXPECTED_BEFORE_COHORTS: list[list[int]] = [[485], [486], [487]]

# The committed repository truth table, read rather than embedded: the fix is
# delivered only if the config that actually ships produces the after state.
COMMITTED_CONFIG_PATH = Path("config/blast-radius.json")

# The one genuine conflict of the recorded run. 486 and 487 both edit the MCP
# tool surface; every other edge of the K3 triangle was an artefact of citations
# that were evidence of a mandated read rather than of a write.
EXPECTED_AFTER_EDGES: list[tuple[int, int]] = [(486, 487)]
SURVIVING_OVERLAP = "extensions/drm-copilot/src/mcp-tools.ts"

# Two cohorts: 485 and 486 run concurrently, 487 follows.
EXPECTED_AFTER_COHORTS: list[list[int]] = [[485, 486], [487]]


@pytest.fixture(name="fixture_document")
def fixture_document_fixture() -> dict[str, object]:
    """Load the committed verification-integrity fixture document.

    Returns:
        dict[str, object]: The parsed fixture carrying `radii`,
        `pre_fix_config`, and `post_fix_config`.
    """

    return json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))


@pytest.fixture(name="before_radii")
def before_radii_fixture(fixture_document: dict[str, object]) -> dict[int, BlastRadius]:
    """Build the three recorded radii as `BlastRadius` instances.

    Args:
        fixture_document (dict[str, object]): The parsed fixture document.

    Returns:
        dict[int, BlastRadius]: The radius per issue number, unmodified from
        the recorded capture.
    """

    radii = cast("dict[str, dict[str, object]]", fixture_document["radii"])
    # Build one instance per item; `from_dict` enforces the exact radius key
    # set, so a fixture that drifted from the recorded shape fails here.
    return {key: BlastRadius.from_dict(radii[str(key)]) for key in ITEM_KEYS}


def test_fixture_radii_load_at_recorded_sizes(
    before_radii: dict[int, BlastRadius],
) -> None:
    """Each recorded radius loads at exactly its captured cardinality."""

    # Arrange / Act — measure each loaded radius against the recorded capture.
    measured = {
        key: (
            len(radius.paths),
            len(radius.modules),
            len(radius.shared_surfaces),
            len(radius.contracts),
        )
        for key, radius in before_radii.items()
    }

    # Assert
    assert measured == EXPECTED_SIZES


def test_before_state_yields_complete_conflict_triangle(
    before_radii: dict[int, BlastRadius],
    fixture_document: dict[str, object],
) -> None:
    """Under the pre-fix config every pair contends, forming the K3 triangle."""

    # Arrange
    pre_fix_config = cast("dict[str, object]", fixture_document["pre_fix_config"])

    # Act — evaluate the frozen relation over each canonical ascending pair.
    edges = [
        (left, right)
        for left, right in combinations(ITEM_KEYS, 2)
        if conflicts(before_radii[left], before_radii[right], pre_fix_config).conflict
    ]

    # Assert
    assert edges == EXPECTED_BEFORE_EDGES


def test_before_state_colours_into_three_serial_cohorts(
    before_radii: dict[int, BlastRadius],
    fixture_document: dict[str, object],
) -> None:
    """The K3 triangle colours into three single-item cohorts, i.e. serial."""

    # Arrange
    pre_fix_config = cast("dict[str, object]", fixture_document["pre_fix_config"])
    edges = [
        (left, right)
        for left, right in combinations(ITEM_KEYS, 2)
        if conflicts(before_radii[left], before_radii[right], pre_fix_config).conflict
    ]

    # Act
    cohorts = compute_cohorts(list(ITEM_KEYS), edges)

    # Assert
    assert cohorts == EXPECTED_BEFORE_COHORTS


@pytest.fixture(name="committed_config")
def committed_config_fixture() -> dict[str, object]:
    """Load the committed repository truth table.

    Returns:
        dict[str, object]: The parsed `config/blast-radius.json` mapping.
    """

    return json.loads(COMMITTED_CONFIG_PATH.read_text(encoding="utf-8"))


@pytest.fixture(name="after_radii")
def after_radii_fixture(
    before_radii: dict[int, BlastRadius],
    committed_config: dict[str, object],
) -> dict[int, BlastRadius]:
    """Re-filter each recorded radius against the committed truth table.

    Args:
        before_radii (dict[int, BlastRadius]): The recorded radii.
        committed_config (dict[str, object]): The committed truth table.

    Returns:
        dict[int, BlastRadius]: The normalized radius per issue number.
    """

    return {
        key: normalize_declared_radius(radius, committed_config)
        for key, radius in before_radii.items()
    }


def after_edges(
    after_radii: dict[int, BlastRadius], config: dict[str, object]
) -> list[tuple[int, int]]:
    """Evaluate the frozen relation over each canonical ascending pair.

    Args:
        after_radii (dict[int, BlastRadius]): The normalized radii.
        config (dict[str, object]): The truth table to compare against.

    Returns:
        list[tuple[int, int]]: The contending pairs, ascending.
    """

    return [
        (left, right)
        for left, right in combinations(ITEM_KEYS, 2)
        if conflicts(after_radii[left], after_radii[right], config).conflict
    ]


def test_after_state_yields_only_the_genuine_conflict_edge(
    after_radii: dict[int, BlastRadius],
    committed_config: dict[str, object],
) -> None:
    """Normalization collapses the K3 triangle to the single real conflict."""

    # Arrange / Act
    edges = after_edges(after_radii, committed_config)

    # Assert
    assert edges == EXPECTED_AFTER_EDGES


def test_after_state_surviving_edge_cites_the_shared_mcp_tool_surface(
    after_radii: dict[int, BlastRadius],
    committed_config: dict[str, object],
) -> None:
    """The one surviving edge is a real path overlap, not a residual artefact."""

    # Arrange / Act
    result = conflicts(after_radii[486], after_radii[487], committed_config)
    details = tuple(reason.detail for reason in result.reasons)

    # Assert — both sides of the reported overlap name the same edited file.
    assert result.conflict is True
    assert details == (f"{SURVIVING_OVERLAP} ~ {SURVIVING_OVERLAP}",), (
        "The surviving edge must be the shared MCP tool surface; observed "
        f"{details}."
    )


def test_after_state_colours_into_two_cohorts(
    after_radii: dict[int, BlastRadius],
    committed_config: dict[str, object],
) -> None:
    """485 and 486 become concurrent; only 487 is forced into a later cohort."""

    # Arrange
    edges = after_edges(after_radii, committed_config)

    # Act
    cohorts = compute_cohorts(list(ITEM_KEYS), edges)

    # Assert
    assert cohorts == EXPECTED_AFTER_COHORTS
