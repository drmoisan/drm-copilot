"""Start-guard parity assertions for the epic wave-barrier ordering invariant.

Each case of the committed fixture
``tests/fixtures/epic_wave_barrier/start-guard-matrix.json`` is turned into an
epic checkpoint document (the fixture envelope plus the case's ``features``),
validated through the public entry point
``validate_epic_orchestrator_state_text`` with default options, and the errors
that begin with ``EPIC_WAVE_BARRIER_VIOLATION: `` are compared, in order, with
the case's ``expected_barrier_errors``. The same fixture is asserted by
``extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-wave-barrier.test.ts``,
so both runtimes are pinned to one set of expected strings.

The fixture is committed and read-only here; no temporary file is created and no
external process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

from scripts.dev_tools._epic_orchestrator_state_wave_barrier import (
    feature_has_started,
    validate_wave_barrier_ordering,
)
from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)

# This file lives at tests/scripts/dev_tools/, so the repository root is three
# parents above its resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_PATH = (
    REPO_ROOT / "tests" / "fixtures" / "epic_wave_barrier" / "start-guard-matrix.json"
)
BARRIER_PREFIX = "EPIC_WAVE_BARRIER_VIOLATION: "
EXPECTED_CASE_COUNT = 14


def _load_fixture() -> dict[str, Any]:
    """Load and return the committed start-guard fixture as a mapping.

    Returns:
        dict[str, Any]: The parsed fixture object.

    Raises:
        TypeError: If the fixture root is not a JSON object.
    """
    parsed: object = json.loads(FIXTURE_PATH.read_text(encoding="utf-8"))
    if not isinstance(parsed, dict):
        raise TypeError(f"{FIXTURE_PATH.name} root must be a JSON object")
    return cast("dict[str, Any]", parsed)


FIXTURE = _load_fixture()
ENVELOPE = cast("dict[str, Any]", FIXTURE["envelope"])
CASES = cast("list[dict[str, Any]]", FIXTURE["cases"])


def _barrier_errors_for(features: list[Any]) -> list[str]:
    """Validate the envelope plus ``features`` and keep only barrier errors.

    Args:
        features (list[Any]): The case's ``features`` array.

    Returns:
        list[str]: Validator errors that start with the barrier prefix, in order.
    """
    document = {**ENVELOPE, "features": features}
    errors = validate_epic_orchestrator_state_text(json.dumps(document))
    return [error for error in errors if error.startswith(BARRIER_PREFIX)]


def test_start_guard_matrix_has_fourteen_unique_cases() -> None:
    """The fixture carries exactly fourteen cases with unique names."""
    # Arrange
    names = [case["name"] for case in CASES]

    # Act
    unique_names = set(names)

    # Assert
    assert len(names) == EXPECTED_CASE_COUNT, f"expected 14 cases, found {names}"
    assert len(unique_names) == len(names), f"duplicate case names in {names}"


@pytest.mark.parametrize(
    "case", CASES, ids=[cast("str", case["name"]) for case in CASES]
)
def test_start_guard_matrix_case(case: dict[str, Any]) -> None:
    """Each fixture case yields exactly its expected barrier errors, in order."""
    # Arrange
    features = cast("list[Any]", case["features"])
    expected = cast("list[str]", case["expected_barrier_errors"])

    # Act
    actual = _barrier_errors_for(features)

    # Assert
    assert actual == expected, f"case {case['name']}: {actual!r} != {expected!r}"


@pytest.mark.parametrize(
    ("feature", "expected"),
    [
        pytest.param(
            {"worktree_created_at": "2026-09-29T10-00", "merge_status": "not_started"},
            True,
            id="string-timestamp",
        ),
        pytest.param(
            {"worktree_created_at": "", "merge_status": "not_started"},
            True,
            id="empty-string-timestamp",
        ),
        pytest.param(
            {"merge_status": "not_started"}, False, id="not-started-no-timestamp"
        ),
        pytest.param(
            {"worktree_created_at": None, "merge_status": "not_started"},
            False,
            id="not-started-null-timestamp",
        ),
        pytest.param({"merge_status": "pr_open"}, True, id="other-status"),
        pytest.param({}, True, id="status-absent"),
        pytest.param({"merge_status": None}, True, id="status-null"),
        pytest.param({"merge_status": 3}, True, id="status-integer"),
    ],
)
def test_feature_has_started(feature: dict[str, Any], expected: bool) -> None:
    """The start predicate follows the fail-closed rule for every branch."""
    # Arrange
    record = dict(feature)

    # Act
    actual = feature_has_started(record)

    # Assert
    assert actual is expected, f"feature_has_started({feature!r}) returned {actual}"


def test_validate_wave_barrier_ordering_reports_unhashable_dependency_status() -> None:
    """A list-valued dependency merge_status is reported as not merged, not raised."""
    # Arrange
    features: list[dict[str, Any]] = [
        {
            "feature_folder": "2026-09-29-alpha-901",
            "issue_num": 901,
            "depends_on": [],
            "merge_status": ["merged"],
        },
        {
            "feature_folder": "2026-09-29-bravo-902",
            "issue_num": 902,
            "depends_on": ["2026-09-29-alpha-901"],
            "merge_status": "worktree_created",
        },
    ]

    # Act
    actual = validate_wave_barrier_ordering(features)

    # Assert
    assert actual == [
        "EPIC_WAVE_BARRIER_VIOLATION: 2026-09-29-bravo-902 is treated as started "
        "while dependency 2026-09-29-alpha-901 is not merged"
    ], f"unexpected barrier errors: {actual!r}"


def test_validate_wave_barrier_ordering_skips_malformed_and_unresolved_entries() -> (
    None
):
    """Non-string folders, non-list depends_on, and unresolved refs are skipped."""
    # Arrange
    features: list[dict[str, Any]] = [
        {"feature_folder": 5, "depends_on": ["x"]},
        {
            "feature_folder": "2026-09-29-delta-904",
            "merge_status": "worktree_created",
            "depends_on": "not-a-list",
        },
        {
            "feature_folder": "2026-09-29-echo-905",
            "merge_status": "worktree_created",
            "depends_on": ["2026-09-29-missing-999"],
        },
    ]

    # Act
    actual = validate_wave_barrier_ordering(features)

    # Assert
    assert actual == [], f"expected no barrier errors, found {actual!r}"
