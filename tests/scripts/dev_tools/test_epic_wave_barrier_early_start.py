"""Python authority lane for the epic wave-barrier early-start corpus (issue #1097).

Each case of the committed fixture
``tests/fixtures/epic_wave_barrier/early-start-edge-cases.json`` is turned into
an epic checkpoint document (the fixture envelope plus the case's
``features``), validated through the public entry point
``validate_epic_orchestrator_state_text`` with default options, and the errors
that begin with ``EPIC_WAVE_BARRIER_VIOLATION: `` are compared, in order, with
the case's ``expected_barrier_errors``.

The TypeScript lane
``extensions/drm-copilot/test/lib/validate/epic-orchestrator-state-early-start.test.ts``
and the PowerShell lane
``tests/scripts/claude-lib/orchestrator-state/OrchestratorStateEpicWaveBarrier.Parity.Tests.ps1``
run the same corpus, so the three runtimes are pinned to one set of strings.

The fixtures are committed and read-only here; no temporary file is created and
no external process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import Any, cast

import pytest

from scripts.dev_tools._epic_orchestrator_state_wave_barrier import (
    EARLY_START_UNMERGED_FORMAT,
    EARLY_START_UNSYNCED_FORMAT,
)
from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)

# This file lives at tests/scripts/dev_tools/, so the repository root is three
# parents above its resolved directory.
REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_ROOT = REPO_ROOT / "tests" / "fixtures" / "epic_wave_barrier"
CORPUS_PATH = FIXTURE_ROOT / "early-start-edge-cases.json"
EXISTING_FIXTURES = ("layer2-parity-edge-cases.json", "start-guard-matrix.json")
BARRIER_PREFIX = "EPIC_WAVE_BARRIER_VIOLATION: "

# The two design strings of issue #1097, written out in full so a change to the
# module's format constants fails test_messages_equal_the_design_strings.
DESIGN_UNMERGED = (
    "EPIC_WAVE_BARRIER_VIOLATION: {f} is at pr_open or later while early_start "
    "dependency {d} is not merged"
)
DESIGN_UNSYNCED = (
    "EPIC_WAVE_BARRIER_VIOLATION: {f} is at pr_open or later without a string "
    "synced_at for early_start dependency {d}"
)


def _load(path: Path) -> dict[str, Any]:
    """Load and return one committed corpus file as a mapping.

    Args:
        path (Path): The committed fixture file to read.

    Returns:
        dict[str, Any]: The parsed corpus object.

    Raises:
        TypeError: If the corpus root is not a JSON object.

    Side Effects:
        Reads the committed corpus file; writes nothing.
    """
    parsed: object = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(parsed, dict):
        raise TypeError(f"{path.name} root must be a JSON object")
    return cast("dict[str, Any]", parsed)


CORPUS = _load(CORPUS_PATH)
ENVELOPE = cast("dict[str, Any]", CORPUS["envelope"])
CASES = cast("list[dict[str, Any]]", CORPUS["cases"])


def _barrier_errors_for(features: object) -> list[str]:
    """Validate the envelope plus ``features`` and keep only barrier errors.

    Args:
        features (object): The case's ``features`` value.

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


def _contains_key(value: object, key: str) -> bool:
    """Report whether a parsed JSON value holds ``key`` in any nested object.

    Args:
        value (object): A parsed JSON value.
        key (str): The exact key to look for.

    Returns:
        bool: True when some object at any depth carries the key.

    Raises:
        None.

    Side Effects:
        None.
    """
    # Route by JSON type: an object is checked and then searched through its
    # values, a list through its items, and a scalar holds no key.
    if isinstance(value, dict):
        mapping = cast("dict[str, object]", value)
        return key in mapping or any(_contains_key(v, key) for v in mapping.values())
    if isinstance(value, list):
        return any(_contains_key(item, key) for item in cast("list[object]", value))
    return False


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


def test_corpus_expects_both_new_messages() -> None:
    """The corpus expects message A and message B at least once each."""
    # Arrange: flatten every case's expected lines into one list.
    expected = [
        line
        for case in CASES
        for line in cast("list[str]", case["expected_barrier_errors"])
    ]

    # Act: keep the lines of each new message.
    unmerged = [line for line in expected if "while early_start dependency" in line]
    unsynced = [line for line in expected if "without a string synced_at" in line]

    # Assert
    assert unmerged, "the corpus must expect the unmerged early_start message"
    assert unsynced, "the corpus must expect the unsynced early_start message"


def test_messages_equal_the_design_strings() -> None:
    """The module's two format strings render exactly the design strings."""
    # Arrange
    folder, dependency = "2026-11-08-dependent-902", 901

    # Act
    unmerged = EARLY_START_UNMERGED_FORMAT.format(folder, dependency)
    unsynced = EARLY_START_UNSYNCED_FORMAT.format(folder, dependency)

    # Assert
    assert unmerged == DESIGN_UNMERGED.format(f=folder, d=dependency)
    assert unsynced == DESIGN_UNSYNCED.format(f=folder, d=dependency)


@pytest.mark.parametrize("name", EXISTING_FIXTURES)
def test_existing_corpus_holds_no_early_start_key(name: str) -> None:
    """The pre-#1097 corpora carry no early_start key, so they prove back-compat."""
    # Arrange
    corpus = _load(FIXTURE_ROOT / name)

    # Act
    carries_key = _contains_key(corpus, "early_start")

    # Assert
    assert not carries_key, f"{name} must not carry an early_start key"
