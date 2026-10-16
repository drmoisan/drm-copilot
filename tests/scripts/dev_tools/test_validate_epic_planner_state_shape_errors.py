"""Tests for epic-planner checkpoint shape errors and Python repr rendering."""

from __future__ import annotations

import json
from typing import Any

import pytest

from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)
from tests.scripts.dev_tools.typescript_twin_test_support import (
    literals_missing_from_twin,
)

VERDICT_ERROR = (
    "Epic planner checkpoint epic_worthiness.verdict " "must be 'epic' or 'non_epic'."
)
RATIONALE_ERROR = "Epic planner checkpoint epic_worthiness.rationale must be non-empty."
MISSING_KEYS_ERROR = (
    "Epic planner checkpoint features[0] missing required keys: preflight_status."
)
DEPENDS_ON_ERROR = "Epic planner checkpoint features[0].depends_on must be a list."
WAVE_SHAPE_ERROR = (
    "Epic planner checkpoint features[0].wave " "must be a non-negative integer."
)
BAND_ERROR = (
    "Epic planner checkpoint features[0].complexity_band "
    "must be one of ('C1', 'C2', 'C3', 'C4')."
)
TWO_FEATURES_ERROR = "Execution-ready epic planning requires at least two features."
RESEARCH_PATH_ERROR = (
    "Epic planner checkpoint features[0].research_path " "must be a non-empty string."
)
NON_EPIC_NEXT_STEP_ERROR = (
    "Non-epic planner checkpoint next_step " "must be 'NON_EPIC_RECOMMENDED'."
)
NONE_WAVE_ERROR = (
    "Epic planner checkpoint features[0].wave "
    "must be 0 from the dependency graph, found None."
)
LIST_WAVE_ERROR = (
    "Epic planner checkpoint features[0].wave "
    "must be 0 from the dependency graph, found [0]."
)
BOOL_ISSUE_ERROR = "Epic planner checkpoint features[1].issue_num must be unique: True."
ASSERTED_MESSAGES = (
    VERDICT_ERROR,
    RATIONALE_ERROR,
    MISSING_KEYS_ERROR,
    DEPENDS_ON_ERROR,
    WAVE_SHAPE_ERROR,
    BAND_ERROR,
    TWO_FEATURES_ERROR,
    RESEARCH_PATH_ERROR,
    NON_EPIC_NEXT_STEP_ERROR,
    NONE_WAVE_ERROR,
    LIST_WAVE_ERROR,
    BOOL_ISSUE_ERROR,
)


def _feature(number: int, /, **overrides: object) -> dict[str, Any]:
    """Build one prepared feature carrying only the required feature keys."""

    feature: dict[str, Any] = {
        "issue_num": number,
        "feature_folder": f"docs/features/active/feature-{number}",
        "depends_on": [],
        "wave": 0,
        "complexity_band": "C3",
        "preparation_status": "prepared",
        "research_path": f"artifacts/research/feature-{number}.md",
        "plan_path": f"docs/features/active/feature-{number}/plan.md",
        "preflight_status": "PREFLIGHT: ALL CLEAR",
    }
    feature.update(overrides)
    return feature


def _state(features: list[object], **overrides: object) -> dict[str, Any]:
    """Build a Claude-shaped ready checkpoint around the given feature entries."""

    state: dict[str, Any] = {
        "objective": "prepare two related features",
        "epic_feature_folder": "sample-epic",
        "epic_manifest_path": "docs/features/epics/sample-epic/epic.md",
        "integration_branch": "epic/sample-epic-integration",
        "max_parallel_features": 4,
        "epic_worthiness": {"verdict": "epic", "rationale": "two features"},
        "features": features,
        "kickoff_prompt_path": "artifacts/orchestration/epic-kickoff-sample-epic.md",
        "completed_steps": ["decomposition", "preparation", "fan-in"],
        "next_step": "EPIC_EXECUTION_READY",
        "last_updated": "2026-07-10T10:00:00Z",
    }
    state.update(overrides)
    return state


def _errors(state: dict[str, Any], *, ready: bool = False) -> list[str]:
    """Validate the serialized checkpoint, optionally under the ready gate."""

    return validate_epic_planner_state_text(
        json.dumps(state), require_ready_for_execution=ready
    )


def test_worthiness_verdict_and_rationale_are_validated() -> None:
    """Report an invalid worthiness verdict and a blank rationale."""

    state = _state(
        [_feature(101), _feature(102)],
        epic_worthiness={"verdict": "maybe", "rationale": " "},
    )

    errors = _errors(state)

    assert VERDICT_ERROR in errors
    assert RATIONALE_ERROR in errors


def test_feature_missing_required_keys_are_listed() -> None:
    """List the required keys a feature entry is missing."""

    first = _feature(101)
    del first["preflight_status"]
    state = _state([first, _feature(102)])

    errors = _errors(state)

    assert MISSING_KEYS_ERROR in errors


def test_feature_shape_fields_are_validated() -> None:
    """Report invalid depends_on, wave, and complexity_band values."""

    state = _state(
        [
            _feature(101, depends_on="101", wave=-1, complexity_band="C9"),
            _feature(102),
        ]
    )

    errors = _errors(state)

    assert DEPENDS_ON_ERROR in errors
    assert WAVE_SHAPE_ERROR in errors
    assert BAND_ERROR in errors


def test_ready_gate_requires_at_least_two_features() -> None:
    """Require at least two features under the ready gate."""

    state = _state([_feature(101)])

    errors = _errors(state, ready=True)

    assert TWO_FEATURES_ERROR in errors


def test_ready_gate_requires_non_empty_path_fields() -> None:
    """Require non-empty path fields under the ready gate."""

    state = _state([_feature(101, research_path=""), _feature(102)])

    errors = _errors(state, ready=True)

    assert RESEARCH_PATH_ERROR in errors


def test_non_epic_verdict_requires_non_epic_next_step() -> None:
    """Require the non-epic next step for a non-epic verdict."""

    state = _state(
        [_feature(101), _feature(102)],
        epic_worthiness={"verdict": "non_epic", "rationale": "one feature suffices"},
    )

    errors = _errors(state)

    assert NON_EPIC_NEXT_STEP_ERROR in errors


@pytest.mark.parametrize(
    ("first", "second", "expected"),
    [
        ({"wave": None}, {}, NONE_WAVE_ERROR),
        ({"wave": [0]}, {}, LIST_WAVE_ERROR),
        ({"issue_num": True}, {"issue_num": True}, BOOL_ISSUE_ERROR),
    ],
    ids=["none", "list", "bool"],
)
def test_dependency_messages_render_python_repr(
    first: dict[str, object], second: dict[str, object], expected: str
) -> None:
    """Render None, list, and bool values with Python repr in messages."""

    state = _state([_feature(101, **first), _feature(102, **second)])

    errors = _errors(state)

    assert expected in errors


def test_asserted_messages_match_typescript_twin() -> None:
    """Keep every asserted message identical to its TypeScript twin literal."""

    missing = literals_missing_from_twin(
        ASSERTED_MESSAGES, "lib/validate/epic-planner-state-shape-errors.test.ts"
    )

    assert missing == []
