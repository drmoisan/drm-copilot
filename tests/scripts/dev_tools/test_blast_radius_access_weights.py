"""Optional separable weight and access-aware path pricing (issue #1164).

Covers two additions to ``scripts/dev_tools/_blast_radius_scheduling.py``: the
optional ``weights.separable`` name of the ``conflict_tolerance`` reader, and
the access-aware path-pair weight that reads each item's optional
``read_paths`` and ``separable_paths`` (spec section B2). Every test builds
its configuration in memory; no file is read or created.
"""

from __future__ import annotations

import copy
from typing import cast

import pytest

from scripts.dev_tools._blast_radius_scheduling import (
    NO_ACCESS,
    ConflictTolerance,
    ItemAccess,
    _path_pair_weight,  # pyright: ignore[reportPrivateUsage]
    config_conflict_tolerance,
)

# A conflict_tolerance member carrying the recalibrated committed minutes.
BASE_TOLERANCE: dict[str, object] = {
    "tolerance_percent": 100,
    "weights": {
        "same_file": 90,
        "possible_overlap": 20,
        "append_only": 10,
        "module": 10,
        "contract": 90,
    },
    "band_durations": {"C1": 30, "C2": 45, "C3": 90, "C4": 180},
    "default_band": "C1",
    "append_only_paths": ["**/CHANGELOG.md"],
}


def make_config(**weight_overrides: object) -> dict[str, object]:
    """Build a truth table whose weights carry the given extra or changed names.

    Args:
        **weight_overrides (object): Weight names and values added to the base.

    Returns:
        dict[str, object]: A fresh truth table; callers may mutate it freely.
    """
    tolerance = copy.deepcopy(BASE_TOLERANCE)
    weights = cast("dict[str, object]", tolerance["weights"])
    weights.update(weight_overrides)
    return {"version": 1, "mergeable_paths": [], "conflict_tolerance": tolerance}


def read(config: dict[str, object]) -> ConflictTolerance:
    """Read the conflict_tolerance key of a truth table."""
    return config_conflict_tolerance(config)


# ---------------------------------------------------------------- reader (B3)


def test_separable_weight_absent_reads_without_key() -> None:
    """A table without separable reads cleanly and carries no separable key."""
    tolerance = read(make_config())

    assert "separable" not in tolerance.weights
    assert dict(tolerance.weights)["same_file"] == 90


def test_separable_weight_accepts_positive_integer() -> None:
    """A separable weight of at least 1 is read as given."""
    tolerance = read(make_config(separable=15))

    assert tolerance.weights["separable"] == 15


def test_separable_weight_rejects_zero() -> None:
    """A separable weight of 0 fails like any other weight below 1."""
    with pytest.raises(ValueError, match=r'\["separable"\] must be >= 1, got 0'):
        read(make_config(separable=0))


def test_separable_weight_rejects_negative() -> None:
    """A negative separable weight is rejected with the minimum message."""
    with pytest.raises(ValueError, match=r'\["separable"\] must be >= 1, got -3'):
        read(make_config(separable=-3))


def test_separable_weight_rejects_boolean() -> None:
    """A boolean separable weight is rejected even though bool subclasses int."""
    with pytest.raises(TypeError, match=r'\["separable"\] must be an integer'):
        read(make_config(separable=True))


def test_separable_weight_rejects_non_integer() -> None:
    """A string separable weight is rejected with the integer message."""
    with pytest.raises(TypeError, match=r'\["separable"\] must be an integer'):
        read(make_config(separable="15"))


def test_unknown_weight_name_still_rejected() -> None:
    """Another unknown weight name still fails the exact name check."""
    with pytest.raises(ValueError, match=r"unknown \['shared'\]"):
        read(make_config(separable=15, shared=4))


# ------------------------------------------------- access-aware weight (B2)

SEPARABLE_TOLERANCE = config_conflict_tolerance(make_config(separable=15))
PLAIN_TOLERANCE = config_conflict_tolerance(make_config())


def weigh(
    entry_a: str,
    entry_b: str,
    *,
    access_a: ItemAccess = NO_ACCESS,
    access_b: ItemAccess = NO_ACCESS,
    tolerance: ConflictTolerance = SEPARABLE_TOLERANCE,
) -> int:
    """Weigh one overlapping path pair through the scheduling module."""
    return _path_pair_weight(entry_a, entry_b, tolerance, access_a, access_b)


def test_read_only_either_side_weighs_zero() -> None:
    """A path read on side A or on side B costs 0."""
    reader = ItemAccess(read_paths=("src/app.py",))

    assert weigh("src/app.py", "src/app.py", access_a=reader) == 0
    assert weigh("src/**", "src/app.py", access_b=reader) == 0


def test_append_only_precedes_separable() -> None:
    """An append-only file keeps its weight when both sides declare it separable."""
    both = ItemAccess(separable_paths=("CHANGELOG.md",))

    assert weigh("CHANGELOG.md", "CHANGELOG.md", access_a=both, access_b=both) == 10


def test_both_side_separable_weighs_separable() -> None:
    """A path both sides declare separable costs the separable weight."""
    both = ItemAccess(separable_paths=("src/app.py",))

    assert weigh("src/app.py", "src/app.py", access_a=both, access_b=both) == 15


def test_one_side_separable_falls_through() -> None:
    """A separable declaration on one side only falls through to same_file."""
    one = ItemAccess(separable_paths=("src/app.py",))

    assert weigh("src/app.py", "src/app.py", access_a=one) == 90


def test_absent_separable_weight_falls_through() -> None:
    """Without a configured separable weight, both-side separable reads as same_file."""
    both = ItemAccess(separable_paths=("src/app.py",))

    assert (
        weigh(
            "src/app.py",
            "src/app.py",
            access_a=both,
            access_b=both,
            tolerance=PLAIN_TOLERANCE,
        )
        == 90
    )


def test_glob_overlap_weighs_possible_overlap() -> None:
    """A glob overlap without access declarations costs possible_overlap."""
    assert weigh("src/**", "src/app.py") == 20


@pytest.mark.parametrize(
    ("entry_a", "entry_b", "expected"),
    [
        ("CHANGELOG.md", "CHANGELOG.md", 10),
        ("docs", "docs/CHANGELOG.md", 10),
        ("src/app.py", "src/app.py", 90),
        ("scripts/dev_tools", "scripts/dev_tools/x.py", 20),
        ("src/**", "src/app.py", 20),
    ],
)
def test_no_access_lists_match_legacy_weight(
    entry_a: str, entry_b: str, expected: int
) -> None:
    """Without access lists each pair keeps its pre-issue-1164 path weight."""
    assert weigh(entry_a, entry_b) == expected
    assert _path_pair_weight(entry_a, entry_b, SEPARABLE_TOLERANCE) == expected
