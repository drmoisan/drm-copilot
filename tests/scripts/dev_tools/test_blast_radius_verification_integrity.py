"""Regression pin for the `verification-integrity` false-conflict-edge defect.

Purpose:
    Pin the recorded before-state of the `verification-integrity` parallel run
    (issues 485, 486, 487) so the blast-radius fix delivered for issue #489 is
    demonstrated against committed data rather than against a gitignored
    working-tree checkpoint.

Responsibilities:
    This module asserts the BEFORE state only: the three radii load at their
    recorded sizes, the frozen contention relation over those radii under the
    pre-fix config yields the complete K3 triangle, and colouring that triangle
    yields three single-item cohorts (fully serial execution). The AFTER-state
    assertions, which exercise the new mandate-read exclusion, are added
    separately and read the same fixture's `post_fix_config` block.

Key invariants and constraints:
    Every assertion here must hold both before and after the fix. The
    contention relation in `scripts/dev_tools/_blast_radius_conflicts.py` is a
    frozen surface for issue #489, and the pre-fix config is embedded in the
    fixture rather than read from `config/blast-radius.json`, so neither input
    moves when the repository config is amended.

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
from scripts.dev_tools.compute_blast_radius import BlastRadius
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
