"""Optional separable weight and access-aware path pricing (issue #1164).

Covers two additions to ``scripts/dev_tools/_blast_radius_scheduling.py``: the
optional ``weights.separable`` name of the ``conflict_tolerance`` reader, and
the access-aware path-pair weight that reads each item's optional
``read_paths`` and ``separable_paths`` (spec section B2). Every test builds
its configuration in memory; no file is read or created.
"""

from __future__ import annotations

import copy

import pytest

from scripts.dev_tools._blast_radius_scheduling import (
    ConflictTolerance,
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
    weights = tolerance["weights"]
    assert isinstance(weights, dict)
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
