"""Tests for the ``compute_complexity_floor`` reference implementation.

These tests exercise the deterministic complexity-floor formula: each present
floor signal contributes the candidate band ``C3``, the floor is the maximum
triggered candidate band, floors never exceed ``C3`` (``C4`` is never
floor-forced), and no present floor signal yields ``C1``.

The floor-signal catalog is read from the live routing matrix
(`load_routing_matrix()["model_policy"]["complexity"]["signals"]`), so the
tests track the ``model_policy`` block in
``config/orchestration-routing.json`` rather than hardcoding signal names.
"""

from __future__ import annotations

from typing import Any, cast

import pytest

from scripts.dev_tools._orchestrator_state_routing import load_routing_matrix
from scripts.dev_tools.compute_complexity_floor import compute_complexity_floor


def _floor_signals() -> tuple[str, ...]:
    """Return the ``[floor]``-flagged signal names from the live routing matrix.

    Purpose:
        Read the ``model_policy.complexity`` signal catalog from
        ``config/orchestration-routing.json`` and return the names of the
        signals flagged ``floor: true``, so the tests exercise the live
        catalog instead of a hardcoded list.

    Returns:
        tuple[str, ...]: The floor-signal names, in catalog order.

    Raises:
        None.

    Side Effects:
        Reads the routing matrix from disk.
    """

    matrix = load_routing_matrix()
    model_policy = cast("dict[str, Any]", matrix["model_policy"])
    signals = cast("list[dict[str, Any]]", model_policy["complexity"]["signals"])
    # Select the names of catalog signals flagged as floor signals.
    return tuple(str(entry["name"]) for entry in signals if entry.get("floor") is True)


@pytest.mark.parametrize("signal", _floor_signals())
def test_each_floor_signal_contributes_c3(signal: str) -> None:
    """Each present floor signal on its own raises the floor to ``C3``."""

    # Arrange: a single present floor signal.
    signals_present = [signal]

    # Act: compute the floor.
    floor = compute_complexity_floor(signals_present)

    # Assert: the floor is exactly C3.
    assert floor == "C3"


def test_max_of_multiple_floor_signals_is_c3() -> None:
    """Multiple present floor signals resolve to the max triggered band ``C3``."""

    # Arrange: every floor signal present at once.
    signals_present = list(_floor_signals())

    # Act: compute the floor across all present floor signals.
    floor = compute_complexity_floor(signals_present)

    # Assert: the maximum triggered candidate band is C3.
    assert floor == "C3"


def test_no_floor_signals_yields_c1() -> None:
    """With no present floor signal the floor is the lowest band ``C1``."""

    # Arrange: an empty present-signal sequence.
    signals_present: list[str] = []

    # Act: compute the floor.
    floor = compute_complexity_floor(signals_present)

    # Assert: the floor is C1.
    assert floor == "C1"


def test_floor_never_exceeds_c3() -> None:
    """No combination of present floor signals produces a band above ``C3``."""

    # Arrange: a large multiset of floor signals, including repeats, to prove
    # the ceiling clamp holds regardless of how many signals are present.
    signals_present = list(_floor_signals()) * 5

    # Act: compute the floor.
    floor = compute_complexity_floor(signals_present)

    # Assert: the floor is clamped to C3 and never reaches C4.
    assert floor == "C3"
    assert floor != "C4"


def test_determinism_across_repeated_calls() -> None:
    """Identical ``signals_present`` inputs yield identical output every call."""

    # Arrange: a fixed present-signal sequence.
    signals_present = list(_floor_signals())

    # Act: compute the floor repeatedly.
    results = [compute_complexity_floor(signals_present) for _ in range(5)]

    # Assert: every call returns the same band.
    assert len(set(results)) == 1


def test_determinism_independent_of_input_ordering() -> None:
    """Reordering ``signals_present`` does not change the computed floor."""

    # Arrange: the same signals in forward and reversed order.
    forward = list(_floor_signals())
    reversed_order = list(reversed(forward))

    # Act: compute the floor for both orderings.
    forward_floor = compute_complexity_floor(forward)
    reversed_floor = compute_complexity_floor(reversed_order)

    # Assert: ordering does not affect the result.
    assert forward_floor == reversed_floor
