"""Shared corpus for the recorded scheduling decisions (issue #1164, spec B10.1).

Each file of ``tests/fixtures/parallel_state_scheduling/`` holds an artifact
type, a complete planner or orchestrator checkpoint, and its ordered expected
errors. This suite runs every file through the Python validators; the
TypeScript port reads the same files through ``validateArtifact`` in
``extensions/drm-copilot/test/lib/validate/parallel-state-scheduling-parity.test.ts``,
so the two runtimes must produce byte-identical error strings. Fixtures are
read in place; no file is created.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)
from scripts.dev_tools.validate_parallel_planner_state import (
    validate_parallel_planner_state_text,
)

REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "parallel_state_scheduling"

# Floor on corpus size, so a broken glob cannot make the parametrized lane pass
# vacuously: three accepted cases and one rejecting case per check.
MINIMUM_CASE_COUNT = 20


def corpus_paths() -> list[Path]:
    """Return the committed corpus files in name order."""
    return sorted(CORPUS_DIR.glob("*.json"))


def load_case(path: Path) -> dict[str, object]:
    """Read one corpus file as a JSON object."""
    return cast("dict[str, object]", json.loads(path.read_text(encoding="utf-8")))


def validate_case(case: dict[str, object]) -> list[str]:
    """Validate one case's checkpoint with the validator its artifact type names."""
    text = json.dumps(case["checkpoint"])
    if case["artifact_type"] == "parallel-planner-state":
        return validate_parallel_planner_state_text(text)
    assert case["artifact_type"] == "parallel-orchestrator-state", case["name"]
    return validate_parallel_orchestrator_state_text(text)


def test_corpus_meets_the_floor() -> None:
    """The corpus holds every accepted and rejecting case."""
    count = len(corpus_paths())

    assert count >= MINIMUM_CASE_COUNT, f"expected {MINIMUM_CASE_COUNT}, found {count}"


@pytest.mark.parametrize("path", corpus_paths(), ids=lambda path: path.stem)
def test_validator_reproduces_the_expected_errors(path: Path) -> None:
    """The validator returns exactly the case's expected errors, in order."""
    case = load_case(path)

    errors = validate_case(case)

    assert errors == case["expected_errors"], path.stem
