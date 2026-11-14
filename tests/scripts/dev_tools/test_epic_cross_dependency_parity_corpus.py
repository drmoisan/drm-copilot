"""Python authority lane for the issue #1162 cross-epic dependency corpus.

Each case of ``tests/fixtures/epic_cross_dependency/cross-dependency-cases.json``
is turned into one checkpoint per listed checkpoint type (the type's envelope,
the case's ``features``, and its ``extra`` top-level keys), validated through
the public text entry point of that type, and the errors that begin with
``EPIC_CROSS_DEPENDENCY_`` are compared, in order, with ``expected``. The
TypeScript lane
(``extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-cross-dependency.test.ts``)
and the PowerShell lane
(``tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicCrossDependency.Parity.Tests.ps1``)
read the same file, so the three runtimes are pinned to one set of strings.

The fixture is committed and read-only; no temporary file is created.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)
from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_planner_state_text,
)

# This file lives at tests/scripts/dev_tools/, so the repository root is three
# parents above its resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_PATH = (
    REPO_ROOT
    / "tests"
    / "fixtures"
    / "epic_cross_dependency"
    / "cross-dependency-cases.json"
)
ERROR_PREFIX = "EPIC_CROSS_DEPENDENCY_"


def _load_corpus() -> dict[str, Any]:
    """Load the committed corpus.

    Returns:
        dict[str, Any]: The parsed corpus with ``envelopes`` and ``cases``.

    Raises:
        OSError: When the fixture cannot be read.
        json.JSONDecodeError: When the fixture is not valid JSON.

    Side Effects:
        Reads the committed fixture file.
    """

    return cast("dict[str, Any]", json.loads(CORPUS_PATH.read_text(encoding="utf-8")))


def _case_parameters() -> list[Any]:
    """Expand every corpus case into one pytest parameter per checkpoint type.

    Returns:
        list[Any]: ``pytest.param`` entries of (checkpoint type, case, envelope).

    Raises:
        None.

    Side Effects:
        Reads the committed fixture file.
    """

    corpus = _load_corpus()
    envelopes = cast("dict[str, Any]", corpus["envelopes"])
    parameters: list[Any] = []
    # One parameter per (case, checkpoint type) pair, named for the report.
    for case in cast("list[dict[str, Any]]", corpus["cases"]):
        for checkpoint_type in cast("list[str]", case["checkpoint_types"]):
            parameters.append(
                pytest.param(
                    checkpoint_type,
                    case,
                    envelopes[checkpoint_type],
                    id=f"{checkpoint_type}:{case['name']}",
                )
            )
    return parameters


def _validate(checkpoint_type: str, text: str, *, require_complete: bool) -> list[str]:
    """Validate checkpoint text through the public entry point of its type.

    Args:
        checkpoint_type (str): ``epic-orchestrator-state`` or ``epic-planner-state``.
        text (str): Checkpoint JSON text.
        require_complete (bool): Completion gate flag (orchestrator only).

    Returns:
        list[str]: Every validator error.

    Raises:
        None.

    Side Effects:
        None.
    """

    # Route by checkpoint type; only the orchestrator validator has a completion gate.
    if checkpoint_type == "epic-orchestrator-state":
        return validate_epic_orchestrator_state_text(
            text, require_complete=require_complete
        )
    return validate_epic_planner_state_text(text)


def test_corpus_holds_cases_for_every_check_and_both_types() -> None:
    """The corpus covers shape cases in both types, violations, and completion."""

    # Arrange
    cases = cast("list[dict[str, Any]]", _load_corpus()["cases"])

    # Act
    planner_shape = [
        c
        for c in cases
        if "epic-planner-state" in c["checkpoint_types"] and c["expected"]
    ]
    expected_errors = [error for case in cases for error in case["expected"]]

    # Assert
    assert len(planner_shape) >= 10
    assert any(
        e.startswith("EPIC_CROSS_DEPENDENCY_VIOLATION: ") for e in expected_errors
    )
    assert any(
        e.startswith("EPIC_CROSS_DEPENDENCY_MAIN_GATE_INCOMPLETE: ")
        for e in expected_errors
    )


@pytest.mark.parametrize(("checkpoint_type", "case", "envelope"), _case_parameters())
def test_corpus_case_matches_python_validator(
    checkpoint_type: str, case: dict[str, Any], envelope: dict[str, Any]
) -> None:
    """Each corpus case yields exactly its expected cross-epic errors, in order."""

    # Arrange
    checkpoint = dict(envelope)
    checkpoint["features"] = case["features"]
    checkpoint.update(cast("dict[str, Any]", case["extra"]))
    text = json.dumps(checkpoint)

    # Act
    errors = _validate(
        checkpoint_type, text, require_complete=bool(case["require_complete"])
    )
    cross_errors = [error for error in errors if error.startswith(ERROR_PREFIX)]

    # Assert
    assert cross_errors == case["expected"], case["name"]
