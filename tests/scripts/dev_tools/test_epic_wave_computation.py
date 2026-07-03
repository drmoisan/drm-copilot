"""Tests for the epic wave-computation reference implementation."""

from __future__ import annotations

import pytest

from scripts.dev_tools.epic_wave_computation import (
    EpicWaveCycleError,
    compute_wave_numbers,
)


def test_compute_wave_numbers_diamond_dag_matches_user_story_scenario() -> None:
    """Assign wave numbers for the user-story diamond-DAG scenario.

    `child-a` has no dependencies; `child-b` and `child-c` each depend on
    `child-a`; `child-d` depends on both `child-b` and `child-c`.
    """

    manifest = {
        "child-a": [],
        "child-b": ["child-a"],
        "child-c": ["child-a"],
        "child-d": ["child-b", "child-c"],
    }

    waves = compute_wave_numbers(manifest)

    assert waves == {"child-a": 0, "child-b": 1, "child-c": 1, "child-d": 2}


def test_compute_wave_numbers_linear_chain() -> None:
    """Assign strictly increasing wave numbers along a linear dependency chain."""

    manifest = {
        "a": [],
        "b": ["a"],
        "c": ["b"],
        "d": ["c"],
    }

    waves = compute_wave_numbers(manifest)

    assert waves == {"a": 0, "b": 1, "c": 2, "d": 3}


def test_compute_wave_numbers_raises_on_cycle() -> None:
    """Raise EpicWaveCycleError when the manifest contains a two-node cycle."""

    manifest = {
        "a": ["b"],
        "b": ["a"],
    }

    with pytest.raises(EpicWaveCycleError):
        compute_wave_numbers(manifest)


def test_compute_wave_numbers_empty_manifest_returns_empty_mapping() -> None:
    """Return an empty mapping for an empty manifest (edge case)."""

    assert compute_wave_numbers({}) == {}


def test_compute_wave_numbers_disconnected_features_each_resolve_independently() -> (
    None
):
    """Resolve wave numbers for features that share no dependency edges."""

    manifest: dict[str, list[str]] = {
        "isolated-1": [],
        "isolated-2": [],
    }

    waves = compute_wave_numbers(manifest)

    assert waves == {"isolated-1": 0, "isolated-2": 0}


def test_compute_wave_numbers_self_referential_cycle_raises() -> None:
    """Raise EpicWaveCycleError when a feature depends on itself."""

    manifest = {"a": ["a"]}

    with pytest.raises(EpicWaveCycleError):
        compute_wave_numbers(manifest)


def test_compute_wave_numbers_three_node_cycle_raises() -> None:
    """Raise EpicWaveCycleError for a longer (three-node) dependency cycle."""

    manifest = {
        "a": ["b"],
        "b": ["c"],
        "c": ["a"],
    }

    with pytest.raises(EpicWaveCycleError):
        compute_wave_numbers(manifest)


def test_epic_wave_cycle_error_message_names_the_feature_folder() -> None:
    """Include the cycle-triggering feature folder in the exception message."""

    manifest = {"a": ["b"], "b": ["a"]}

    with pytest.raises(EpicWaveCycleError) as excinfo:
        compute_wave_numbers(manifest)

    assert excinfo.value.feature_folder in {"a", "b"}
    assert excinfo.value.feature_folder in str(excinfo.value)
