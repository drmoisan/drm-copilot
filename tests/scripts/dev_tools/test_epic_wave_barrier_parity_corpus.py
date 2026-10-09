"""Python authority lane for the epic wave-barrier Layer 2 parity corpus.

Each case of the committed fixture
``tests/fixtures/epic_wave_barrier/layer2-parity-edge-cases.json`` is turned
into an epic checkpoint document (the fixture envelope plus the case's
``features``), validated through the public entry point
``validate_epic_orchestrator_state_text`` with default options, and the errors
that begin with ``EPIC_WAVE_BARRIER_VIOLATION: `` are compared, in order, with
the case's ``expected_barrier_errors``. A wrong expectation in the corpus
therefore fails against the Python authority.

The PowerShell sibling lane,
``tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1``,
runs the same corpus through the PowerShell port
``Get-OrchestratorStateEpicWaveBarrierError`` (issue #840), so both runtimes are
pinned to one set of expected strings.

The fixture is committed and read-only here; no temporary file is created and no
external process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)

# This file lives at tests/scripts/dev_tools/, so the repository root is three
# parents above its resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_PATH = (
    REPO_ROOT
    / "tests"
    / "fixtures"
    / "epic_wave_barrier"
    / "layer2-parity-edge-cases.json"
)
BARRIER_PREFIX = "EPIC_WAVE_BARRIER_VIOLATION: "


def _load_corpus() -> dict[str, Any]:
    """Load and return the committed Layer 2 parity corpus as a mapping.

    Returns:
        dict[str, Any]: The parsed corpus object.

    Raises:
        TypeError: If the corpus root is not a JSON object.

    Side Effects:
        Reads the committed corpus file; writes nothing.
    """
    parsed: object = json.loads(CORPUS_PATH.read_text(encoding="utf-8"))
    if not isinstance(parsed, dict):
        raise TypeError(f"{CORPUS_PATH.name} root must be a JSON object")
    return cast("dict[str, Any]", parsed)


CORPUS = _load_corpus()
ENVELOPE = cast("dict[str, Any]", CORPUS["envelope"])
CASES = cast("list[dict[str, Any]]", CORPUS["cases"])


def _barrier_errors_for(features: object) -> list[str]:
    """Validate the envelope plus ``features`` and keep only barrier errors.

    Args:
        features (object): The case's ``features`` value. It is usually a list,
            but a case may deliberately supply another JSON type.

    Returns:
        list[str]: Validator errors that start with the barrier prefix, in order.

    Raises:
        None.

    Side Effects:
        None.
    """
    document = {**ENVELOPE, "features": features}
    errors = validate_epic_orchestrator_state_text(json.dumps(document))
    return [error for error in errors if error.startswith(BARRIER_PREFIX)]


def test_corpus_is_non_empty_with_unique_case_names() -> None:
    """The corpus carries at least one case and every case name is unique."""
    # Arrange
    names = [cast("str", case["name"]) for case in CASES]

    # Act
    unique_names = set(names)

    # Assert
    assert len(names) > 0, "the parity corpus must carry at least one case"
    assert len(unique_names) == len(names), f"duplicate case names in {names}"


def test_corpus_executes_every_case() -> None:
    """Every corpus case is executed and matches its expected barrier errors."""
    # Arrange
    executed = 0
    mismatches: list[str] = []

    # Act: run each case through the authority, counting executions and
    # collecting the name of every case whose output differs from the corpus.
    for case in CASES:
        actual = _barrier_errors_for(case["features"])
        executed += 1
        if actual != cast("list[str]", case["expected_barrier_errors"]):
            mismatches.append(cast("str", case["name"]))

    # Assert
    assert executed == len(CASES), f"executed {executed} of {len(CASES)} cases"
    assert mismatches == [], f"cases differing from the authority: {mismatches}"


@pytest.mark.parametrize(
    "case", CASES, ids=[cast("str", case["name"]) for case in CASES]
)
def test_corpus_case(case: dict[str, Any]) -> None:
    """Each corpus case yields exactly its expected barrier errors, in order."""
    # Arrange
    expected = cast("list[str]", case["expected_barrier_errors"])

    # Act
    actual = _barrier_errors_for(case["features"])

    # Assert
    assert actual == expected, f"case {case['name']}: {actual} != {expected}"
