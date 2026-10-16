"""Tests for repository-relative path normalization in epic-planner readiness."""

from __future__ import annotations

from typing import Any

import pytest

from scripts.dev_tools.epic_planner_readiness import validate_epic_readiness_integrity
from tests.scripts.dev_tools.epic_planner_launch_evidence_test_support import (
    launch_evidence_fixture,
)
from tests.scripts.dev_tools.typescript_twin_test_support import (
    literals_missing_from_twin,
)

FOLDER = "docs/features/active/feature-101"
PLAN = "docs/features/active/feature-101/plan.md"
RESEARCH = "artifacts/research/feature-101.md"
FOLDER_REQUIRED_ERROR = (
    "Execution readiness requires feature folder: docs/features/active/feature-101"
)
ROOT_FOLDER_REQUIRED_ERROR = "Execution readiness requires feature folder: ."
FOLDER_ESCAPE_ERROR = (
    "Epic planner checkpoint features[0].feature_folder "
    "must stay within the workspace root."
)
FOLDER_SLASH_ERROR = (
    "Epic planner checkpoint features[0].feature_folder must use forward slashes."
)
FOLDER_EMPTY_ERROR = (
    "Epic planner checkpoint features[0].feature_folder "
    "must be a non-empty repository-relative path."
)
PLAN_ESCAPE_ERROR = (
    "Epic planner checkpoint features[0].plan_path "
    "must stay within the workspace root."
)
ASSERTED_MESSAGES = (
    FOLDER_REQUIRED_ERROR,
    ROOT_FOLDER_REQUIRED_ERROR,
    FOLDER_ESCAPE_ERROR,
    FOLDER_SLASH_ERROR,
    FOLDER_EMPTY_ERROR,
    PLAN_ESCAPE_ERROR,
)


def _errors(feature_folder: str, plan_path: str = PLAN) -> list[str]:
    """Validate readiness for one keyless feature with the given paths."""

    _, context, _ = launch_evidence_fixture()
    state: dict[str, Any] = {
        "epic_feature_folder": "sample-epic",
        "features": [
            {
                "feature_folder": feature_folder,
                "plan_path": plan_path,
                "research_path": RESEARCH,
            }
        ],
    }
    return validate_epic_readiness_integrity(
        state, "{}", context, require_launch_paths=True
    )


@pytest.mark.parametrize(
    ("folder", "expected"),
    [
        (FOLDER, FOLDER_REQUIRED_ERROR),
        (f"./{FOLDER}", FOLDER_REQUIRED_ERROR),
        ("docs/features/active/./feature-101", FOLDER_REQUIRED_ERROR),
        ("docs/features/active//feature-101", FOLDER_REQUIRED_ERROR),
        (f"{FOLDER}/", FOLDER_REQUIRED_ERROR),
        ("./", ROOT_FOLDER_REQUIRED_ERROR),
    ],
    ids=[
        "plain",
        "dot-prefix",
        "dot-segment",
        "double-slash",
        "trailing-slash",
        "dot-only",
    ],
)
def test_feature_folder_spelling_normalizes_to_repository_path(
    folder: str, expected: str
) -> None:
    """Normalize dot and empty segments in a feature_folder to one path."""

    errors = _errors(folder)

    assert expected in errors


@pytest.mark.parametrize(
    ("folder", "expected"),
    [
        ("../feature-101", FOLDER_ESCAPE_ERROR),
        (f"/{FOLDER}", FOLDER_ESCAPE_ERROR),
        ("docs\\features\\active\\feature-101", FOLDER_SLASH_ERROR),
        ("   ", FOLDER_EMPTY_ERROR),
        ("C:/docs/features/active/feature-101", FOLDER_ESCAPE_ERROR),
        ("c:docs/features/active/feature-101", FOLDER_ESCAPE_ERROR),
    ],
    ids=["parent", "absolute", "backslash", "blank", "drive-letter", "drive-relative"],
)
def test_unsafe_feature_folder_is_rejected(folder: str, expected: str) -> None:
    """Reject a feature_folder that is blank, uses backslashes, or escapes."""

    errors = _errors(folder)

    assert expected in errors


def test_dot_prefixed_plan_path_is_accepted() -> None:
    """Accept a dot-prefixed plan_path as the normalized repository path."""

    plan_path = f"./{PLAN}"

    errors = _errors(FOLDER, plan_path)

    assert FOLDER_REQUIRED_ERROR in errors
    assert PLAN_ESCAPE_ERROR not in errors


def test_asserted_messages_match_typescript_twin() -> None:
    """Keep every asserted message identical to its TypeScript twin literal."""

    missing = literals_missing_from_twin(
        ASSERTED_MESSAGES, "lib/validate/epic-planner-readiness-relative-paths.test.ts"
    )

    assert missing == []
