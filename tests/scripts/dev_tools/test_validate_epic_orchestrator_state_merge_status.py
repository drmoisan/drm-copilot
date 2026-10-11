"""Regression tests for non-string ``merge_status`` handling (issue #793).

The epic-orchestrator checkpoint validator tests ``merge_status`` against sets
of strings. A list or dict value is unhashable, so the membership test raised
``TypeError`` instead of reporting a validation error. These tests pin the
corrected behavior at both sites (enum membership and the completion gate),
through the public entry point, and through the CLI exit code, and they pin the
unchanged behavior for valid strings, ``None``, and a missing key.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, Any, cast

import pytest

import scripts.dev_tools.validate_epic_orchestrator_state as validator
import scripts.dev_tools.validate_orchestration_artifacts as cli
from tests.scripts.dev_tools.test_validate_epic_orchestrator_state import (
    build_valid_epic_state,
)
from tests.scripts.dev_tools.test_validate_orchestration_artifacts import (
    build_read_text_stub,
)

if TYPE_CHECKING:
    from collections.abc import Callable

    from pytest import MonkeyPatch

VALUE_ROWS = [
    pytest.param(["x"], "['x']", id="list"),
    pytest.param({"x": 1}, "{'x': 1}", id="dict"),
    pytest.param(5, "5", id="int"),
    pytest.param(True, "True", id="bool"),
]
UNHASHABLE_ROWS = [
    pytest.param(["x"], id="list"),
    pytest.param({"x": 1}, id="dict"),
]
COMPLETION_STATE: dict[str, Any] = {"epic_merge_pr": {"merge_commit_sha": "abc123"}}
COMPLETION_ERROR_A = (
    "Epic checkpoint completion validation failed: "
    "feature 'a' merge_status is not merged/worktree_removed."
)
COMPLETION_ERROR_CHILD_B = (
    "Epic checkpoint completion validation failed: "
    "feature '2026-07-02-child-b-301' merge_status is not merged/worktree_removed."
)


def enum_site() -> Callable[[list[dict[str, Any]]], list[str]]:
    """Return the private enum-membership validator without a suppression."""

    return cast(
        "Callable[[list[dict[str, Any]]], list[str]]",
        vars(validator)["_validate_merge_status_enum"],
    )


def completion_site() -> Callable[[list[dict[str, Any]], dict[str, Any]], list[str]]:
    """Return the private completion-gate validator without a suppression."""

    return cast(
        "Callable[[list[dict[str, Any]], dict[str, Any]], list[str]]",
        vars(validator)["_validate_completion"],
    )


def build_state_with_child_b_status(value: object) -> dict[str, object]:
    """Return the valid epic payload with the second feature's merge_status set."""

    state = build_valid_epic_state()
    features = cast("list[dict[str, object]]", state["features"])
    features[1]["merge_status"] = value
    return state


@pytest.mark.parametrize(("value", "expected_repr"), VALUE_ROWS)
def test_enum_site_reports_non_string_merge_status(
    value: object, expected_repr: str
) -> None:
    """Report a non-string merge_status as an error instead of raising."""

    features: list[dict[str, Any]] = [{"feature_folder": "a", "merge_status": value}]

    errors = enum_site()(features)

    assert errors == [
        "Epic checkpoint feature 'a' has invalid merge_status: " + expected_repr
    ]


@pytest.mark.parametrize(("value", "expected_repr"), VALUE_ROWS)
def test_completion_site_reports_non_string_merge_status(
    value: object, expected_repr: str
) -> None:
    """Report a non-string merge_status at the completion gate without raising."""

    features: list[dict[str, Any]] = [{"feature_folder": "a", "merge_status": value}]

    errors = completion_site()(features, COMPLETION_STATE)

    assert errors == [COMPLETION_ERROR_A], expected_repr


@pytest.mark.parametrize("value", UNHASHABLE_ROWS)
def test_entry_point_reports_invalid_merge_status_without_raising(
    value: object,
) -> None:
    """Return an invalid merge_status error from the public entry point."""

    state = build_state_with_child_b_status(value)

    errors = validator.validate_epic_orchestrator_state_text(json.dumps(state))

    assert any("invalid merge_status" in error for error in errors), errors


@pytest.mark.parametrize("value", UNHASHABLE_ROWS)
def test_entry_point_require_complete_reports_completion_error_without_raising(
    value: object,
) -> None:
    """Return enum and completion errors under require_complete without raising."""

    state = build_state_with_child_b_status(value)

    errors = validator.validate_epic_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("invalid merge_status" in error for error in errors), errors
    assert COMPLETION_ERROR_CHILD_B in errors


@pytest.mark.parametrize("value", UNHASHABLE_ROWS)
def test_cli_returns_exit_code_1_for_non_string_merge_status(
    value: object, monkeypatch: MonkeyPatch
) -> None:
    """Return exit code 1 from the CLI instead of an unhandled traceback."""

    state = build_state_with_child_b_status(value)
    monkeypatch.setattr(cli, "_read_text", build_read_text_stub(json.dumps(state)))

    result = cli.main(["epic-orchestrator-state", "ignored.json"])

    assert result == 1


def test_enum_site_accepts_every_valid_string_status() -> None:
    """Accept every member of the valid merge_status set without errors."""

    for status in sorted(validator.VALID_MERGE_STATUS):
        features: list[dict[str, Any]] = [
            {"feature_folder": "a", "merge_status": status}
        ]

        errors = enum_site()(features)

        assert errors == [], status


def test_enum_site_reports_invalid_string_status_with_unchanged_text() -> None:
    """Keep the existing error text for an invalid string merge_status."""

    features: list[dict[str, Any]] = [
        {"feature_folder": "a", "merge_status": "unknown_status"}
    ]

    errors = enum_site()(features)

    assert errors == [
        "Epic checkpoint feature 'a' has invalid merge_status: 'unknown_status'"
    ]


def test_enum_site_skips_none_and_missing_merge_status() -> None:
    """Skip features whose merge_status is None or absent."""

    features: list[dict[str, Any]] = [
        {"feature_folder": "a", "merge_status": None},
        {"feature_folder": "b"},
    ]

    errors = enum_site()(features)

    assert errors == []


def test_completion_site_accepts_merged_and_worktree_removed() -> None:
    """Accept features whose merge_status is merged or worktree_removed."""

    features: list[dict[str, Any]] = [
        {"feature_folder": "a", "merge_status": "merged"},
        {"feature_folder": "b", "merge_status": "worktree_removed"},
    ]

    errors = completion_site()(features, COMPLETION_STATE)

    assert errors == []


@pytest.mark.parametrize(
    "feature",
    [
        pytest.param({"feature_folder": "a", "merge_status": "pr_open"}, id="string"),
        pytest.param({"feature_folder": "a", "merge_status": None}, id="none"),
        pytest.param({"feature_folder": "a"}, id="missing"),
    ],
)
def test_completion_site_reports_invalid_string_none_and_missing(
    feature: dict[str, Any],
) -> None:
    """Report an unmerged string, None, or missing merge_status at the gate."""

    errors = completion_site()([feature], COMPLETION_STATE)

    assert errors == [COMPLETION_ERROR_A]
