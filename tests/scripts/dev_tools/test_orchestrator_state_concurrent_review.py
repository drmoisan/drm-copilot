"""Pin the checkpoint rules of ``review_mode: "concurrent"`` (issue #1097).

The committed corpus under ``tests/fixtures/orchestrator_state_concurrent_review/``
binds the Python rule to its TypeScript and PowerShell ports: each file records a
checkpoint and the ordered errors ``validate_concurrent_review_completion`` must
return. The remaining tests prove that the readiness gate relaxes only the pair
``step7_status`` and ``pending`` under the exact key, and that a checkpoint without
the key keeps the error list it has today.

The base checkpoint is a committed back-compat fixture read in place; keys are
changed in memory. No temporary file is created and no external process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_concurrent_review import (
    LAST_REVIEW_NOT_PASSED_ERROR,
    validate_concurrent_review_completion,
)
from scripts.dev_tools._orchestrator_state_pr_creation_readiness import (
    validate_orchestrator_state_pr_creation_readiness,
)

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURES = REPO_ROOT / "tests" / "fixtures"
CORPUS_DIR = FIXTURES / "orchestrator_state_concurrent_review"
BACKCOMPAT_DIR = FIXTURES / "orchestrator_state_blocked_reason_backcompat"
BASE_CHECKPOINT = BACKCOMPAT_DIR / "none.json"

# Floor on corpus size, matching the TypeScript and PowerShell readers. An empty
# glob would otherwise remove every parametrized case and pass vacuously.
MINIMUM_CORPUS_COUNT = 12
REVIEWED_HEAD = "abcdef0123456789abcdef0123456789abcdef01"
CORPUS_PATHS = tuple(sorted(CORPUS_DIR.glob("*.json")))
CORPUS_IDS = [path.stem for path in CORPUS_PATHS]


def load_json_object(path: Path) -> dict[str, Any]:
    """Read one committed JSON object.

    Args:
        path (Path): Absolute path to a committed fixture.

    Returns:
        dict[str, Any]: The parsed object, freshly built for the caller to change.

    Raises:
        OSError: If the fixture cannot be read.

    Side Effects:
        Reads the committed file.
    """
    return cast("dict[str, Any]", json.loads(path.read_text(encoding="utf-8")))


def build_state(**changes: object) -> dict[str, Any]:
    """Return the base checkpoint with top-level keys set in memory.

    Args:
        **changes (object): Top-level keys and their values.

    Returns:
        dict[str, Any]: A new checkpoint for one test.

    Raises:
        OSError: If the base fixture cannot be read.

    Side Effects:
        Reads the committed base fixture.
    """
    state = load_json_object(BASE_CHECKPOINT)
    state.update(changes)
    return state


@pytest.mark.parametrize("path", CORPUS_PATHS, ids=CORPUS_IDS)
def test_corpus_matches_expected_errors(path: Path) -> None:
    """Assert the rule returns exactly the ordered errors the corpus records.

    Args:
        path (Path): One corpus file.

    Returns:
        None: The assertion verifies the error list.
    """
    # Arrange
    fixture = load_json_object(path)

    # Act
    observed = validate_concurrent_review_completion(fixture["checkpoint"])

    # Assert
    assert fixture["name"] == path.stem
    assert observed == fixture["expected_errors"]


def test_corpus_count_meets_floor() -> None:
    """Guard the parametrized cases against an empty or partial corpus glob.

    Returns:
        None: The assertion verifies the discovered count.
    """
    # Arrange and act
    discovered = len(CORPUS_PATHS)

    # Assert
    assert discovered >= MINIMUM_CORPUS_COUNT


def test_readiness_allows_pending_step7_under_key() -> None:
    """A pending review does not block PR readiness under the exact key.

    Returns:
        None: The assertion verifies that no step7_status error is reported.
    """
    # Arrange
    state = build_state(step7_status="pending", review_mode="concurrent")

    # Act
    errors = validate_orchestrator_state_pr_creation_readiness(state)

    # Assert
    assert errors == []


def test_readiness_blocks_pending_step7_without_key() -> None:
    """A pending review still blocks PR readiness without the key.

    Returns:
        None: The assertion verifies the existing error.
    """
    # Arrange
    state = build_state(step7_status="pending")

    # Act
    errors = validate_orchestrator_state_pr_creation_readiness(state)

    # Assert
    assert any("step7_status is pending" in error for error in errors)


def test_readiness_blocks_pending_step7_for_case_variant() -> None:
    """The key comparison is ordinal, so a case variant relaxes nothing.

    Returns:
        None: The assertion verifies the existing error.
    """
    # Arrange
    state = build_state(step7_status="pending", review_mode="Concurrent")

    # Act
    errors = validate_orchestrator_state_pr_creation_readiness(state)

    # Assert
    assert any("step7_status is pending" in error for error in errors)


def test_readiness_still_blocks_blocked_step7_under_key() -> None:
    """Only the value pending is relaxed; a blocked review still blocks.

    Returns:
        None: The assertion verifies the existing error.
    """
    # Arrange
    state = build_state(step7_status="blocked", review_mode="concurrent")

    # Act
    errors = validate_orchestrator_state_pr_creation_readiness(state)

    # Assert
    assert any("step7_status is blocked" in error for error in errors)


@pytest.mark.parametrize("key", ["step5_status", "step6_status", "step8_status"])
def test_readiness_still_blocks_other_pending_steps_under_key(key: str) -> None:
    """Only step7_status is relaxed; every other pending step still blocks.

    Args:
        key (str): The step key set to pending.

    Returns:
        None: The assertion verifies the existing error.
    """
    # Arrange
    state = build_state(review_mode="concurrent", **{key: "pending"})

    # Act
    errors = validate_orchestrator_state_pr_creation_readiness(state)

    # Assert
    assert any(f"{key} is pending" in error for error in errors)


def test_require_complete_reports_review_error_under_key() -> None:
    """The key adds exactly one error, after the existing completion errors.

    Returns:
        None: The assertion compares against the same checkpoint without the key.
    """
    # Arrange
    with_key = json.dumps(build_state(review_mode="concurrent"))
    without_key = json.dumps(build_state())

    # Act
    observed = state_validator.validate_orchestrator_state_text(
        with_key, require_complete=True
    )
    expected = state_validator.validate_orchestrator_state_text(
        without_key, require_complete=True
    )

    # Assert
    assert observed == [*expected, LAST_REVIEW_NOT_PASSED_ERROR]


def test_require_complete_unchanged_without_key() -> None:
    """A sequential value adds no completion error.

    Returns:
        None: The assertion compares against the same checkpoint without the key.
    """
    # Arrange
    with_value = json.dumps(build_state(review_mode="sequential"))
    without_key = json.dumps(build_state())

    # Act
    observed = state_validator.validate_orchestrator_state_text(
        with_value, require_complete=True
    )
    expected = state_validator.validate_orchestrator_state_text(
        without_key, require_complete=True
    )

    # Assert
    assert observed == expected


def test_plain_validation_ignores_review_mode_and_head_sha() -> None:
    """Plain validation reads neither key, so its errors do not change.

    Returns:
        None: The assertion compares against the same checkpoint without the keys.
    """
    # Arrange
    recorded: dict[str, object] = {
        "verdict": "PASS",
        "findings": [],
        "head_sha": REVIEWED_HEAD,
    }
    unrecorded: dict[str, object] = {"verdict": "PASS", "findings": []}
    with_keys = build_state(
        review_mode="concurrent",
        remediation_loop={"review_outcomes": [recorded]},
    )
    without_keys = build_state(remediation_loop={"review_outcomes": [unrecorded]})

    # Act
    observed = state_validator.validate_orchestrator_state_text(json.dumps(with_keys))
    expected = state_validator.validate_orchestrator_state_text(
        json.dumps(without_keys)
    )

    # Assert
    assert observed == expected
