"""Corpus tests for the ``planner_worktrees`` rule of the epic-planner validator.

Parametrize over every ``tests/fixtures/epic_planner_state_planner_worktrees/*.json``
file and assert that ``validate_epic_planner_state_text`` returns exactly the
ordered ``expected_errors`` the file records (issue #1161). The TypeScript suite
``extensions/drm-copilot/test/lib/validate/epic-planner-state-planner-worktrees.test.ts``
asserts the same files, so the corpus binds the two runtimes to byte-identical
error strings.

The corpus files are committed and only read here. No temporary file is created
and no other process is started.
"""

from __future__ import annotations

import copy
import json
from pathlib import Path
from typing import Any, cast

import pytest

from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)

# This file lives at tests/scripts/dev_tools/, so the repository root is three
# parents above its resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "epic_planner_state_planner_worktrees"
# The plan fixes the corpus at seventeen files; a smaller glob would make the
# parametrized rows below pass vacuously.
EXPECTED_CORPUS_COUNT = 17
MAX_PARALLEL_ERROR = (
    "Epic planner checkpoint max_parallel_features must be an integer "
    "from 1 through 8."
)


def _load_case(path: Path) -> dict[str, Any]:
    """Read one corpus file and guard its four keys.

    Args:
        path (Path): The corpus file.

    Returns:
        dict[str, Any]: The parsed fixture with ``name``, ``notes``,
        ``checkpoint``, and ``expected_errors``.

    Raises:
        AssertionError: When a key is missing or ``name`` is not the file stem.
    """

    fixture = cast("dict[str, Any]", json.loads(path.read_text(encoding="utf-8")))
    for key in ("name", "notes", "checkpoint", "expected_errors"):
        assert key in fixture, f"{path.name} must carry the key {key}."
    assert fixture["name"] == path.stem, f"{path.name}.name must equal the stem."
    return fixture


CORPUS_FILES = sorted(CORPUS_DIR.glob("*.json"))
CORPUS = [_load_case(path) for path in CORPUS_FILES]


def test_corpus_holds_the_planned_file_count() -> None:
    """The corpus directory holds exactly the planned seventeen fixtures."""

    # Arrange and act: the module-level glob above.
    count = len(CORPUS)

    # Assert
    assert count == EXPECTED_CORPUS_COUNT, f"found {count} corpus files"


def test_corpus_exercises_accepting_and_rejecting_rows() -> None:
    """At least one fixture expects no error and at least one expects errors."""

    # Arrange and act
    expectations = [bool(case["expected_errors"]) for case in CORPUS]

    # Assert
    assert False in expectations and True in expectations


@pytest.mark.parametrize("case", CORPUS, ids=[case["name"] for case in CORPUS])
def test_validator_reproduces_the_corpus_errors(case: dict[str, Any]) -> None:
    """Plain validation returns exactly the ordered errors the fixture records."""

    # Arrange
    text = json.dumps(case["checkpoint"])

    # Act
    errors = validate_epic_planner_state_text(text)

    # Assert
    assert errors == case["expected_errors"]


@pytest.mark.parametrize("case", CORPUS, ids=[case["name"] for case in CORPUS])
def test_removing_the_key_removes_every_planner_error(case: dict[str, Any]) -> None:
    """Without ``planner_worktrees`` every corpus checkpoint validates clean."""

    # Arrange
    checkpoint = copy.deepcopy(case["checkpoint"])
    checkpoint.pop("planner_worktrees", None)

    # Act
    errors = validate_epic_planner_state_text(json.dumps(checkpoint))

    # Assert
    assert errors == []


def test_key_absent_checkpoint_keeps_its_existing_error_list() -> None:
    """A key-absent checkpoint with an existing error reports only that error."""

    # Arrange: the accepting key-absent fixture with an invalid parallelism value.
    base = next(case for case in CORPUS if case["name"] == "valid-key-absent")
    checkpoint = copy.deepcopy(base["checkpoint"])
    checkpoint["max_parallel_features"] = 0

    # Act
    errors = validate_epic_planner_state_text(json.dumps(checkpoint))

    # Assert
    assert errors == [MAX_PARALLEL_ERROR]


def test_planner_errors_follow_the_existing_checks() -> None:
    """Planner errors are appended after the max_parallel_features error."""

    # Arrange: a rejecting fixture whose parallelism value is also invalid.
    base = next(case for case in CORPUS if case["name"] == "wrong-purpose")
    checkpoint = copy.deepcopy(base["checkpoint"])
    checkpoint["max_parallel_features"] = 9

    # Act
    errors = validate_epic_planner_state_text(json.dumps(checkpoint))

    # Assert
    assert errors == [MAX_PARALLEL_ERROR, *base["expected_errors"]]
