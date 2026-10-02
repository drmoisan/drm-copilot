"""Cross-runtime parity assertions over the ``blocked_reason`` corpus (#523).

Parametrize over every ``tests/fixtures/orchestrator_state_blocked_reason/*.json``
file and assert that the Python validator emits exactly the ``blocked_reason``
errors the fixture records. The same corpus is asserted by the Jest suite
``orchestrator-state-blocked-reason-parity.test.ts`` (under
``extensions/drm-copilot/test/lib/validate/``) and the Pester suite
``OrchestratorStateBlockedReason.Parity.Tests.ps1`` (under
``tests/scripts/claude-lib/orchestrator-state/``), so the corpus binds the
three runtimes together. The pattern follows
``tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py``.

Fixture shape. Each file carries ``name`` (equal to the file stem), ``notes``,
``checkpoint`` (a completion-safe small-route checkpoint with ``blocked_reason``
set, replaced, or removed as named), ``expected_errors`` (the ordered
plain-validation errors containing ``blocked_reason``), and, on the two
completion cases only, ``expected_completion_errors`` (the ordered
``require_complete`` errors containing ``blocked_reason``).

The corpus files are committed and read in place. No temporary file is created
and no external process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

from scripts.dev_tools.validate_orchestrator_state import (
    validate_orchestrator_state_text,
)

# Repository root: this file lives three directories below it.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "orchestrator_state_blocked_reason"
CORPUS_SUFFIX = ".json"

# Floor on corpus size, so an empty or partial glob cannot pass vacuously.
MINIMUM_CORPUS_COUNT = 20

# Substring every compared error contains.
BLOCKED_REASON_SUBSTRING = "blocked_reason"


def _corpus_paths() -> list[Path]:
    """Return the corpus files in sorted order."""

    return sorted(CORPUS_DIR.glob(f"*{CORPUS_SUFFIX}"))


def _load_case(path: Path) -> dict[str, object]:
    """Parse one corpus file into its top-level mapping."""

    payload = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(payload, dict):
        raise TypeError(f"{path.name} must hold a JSON object.")
    return cast("dict[str, object]", payload)


def _filtered(errors: list[str]) -> list[str]:
    """Keep only the errors that mention ``blocked_reason``, in order."""

    return [error for error in errors if BLOCKED_REASON_SUBSTRING in error]


_CORPUS = _corpus_paths()
_COMPLETION_CASES = [
    path for path in _CORPUS if "expected_completion_errors" in _load_case(path)
]


def test_corpus_meets_minimum_count() -> None:
    """The corpus holds at least the minimum number of cases."""

    # Act
    count = len(_CORPUS)

    # Assert
    assert count >= MINIMUM_CORPUS_COUNT, f"found {count} corpus files"


def test_discovered_count_equals_on_disk_count() -> None:
    """Every JSON file on disk is discovered as a parametrized case."""

    # Arrange
    on_disk = [
        entry.name
        for entry in CORPUS_DIR.iterdir()
        if entry.is_file() and entry.name.endswith(CORPUS_SUFFIX)
    ]

    # Act
    discovered = [path.name for path in _CORPUS]

    # Assert
    assert len(discovered) == len(on_disk)
    assert sorted(discovered) == sorted(on_disk)


@pytest.mark.parametrize("path", _CORPUS, ids=lambda path: path.stem)
def test_name_equals_stem(path: Path) -> None:
    """Each case's ``name`` equals its file stem."""

    # Act
    case = _load_case(path)

    # Assert
    assert case["name"] == path.stem


@pytest.mark.parametrize("path", _CORPUS, ids=lambda path: path.stem)
def test_plain_errors_match_expected(path: Path) -> None:
    """Plain-validation ``blocked_reason`` errors equal ``expected_errors``."""

    # Arrange
    case = _load_case(path)
    text = json.dumps(case["checkpoint"])

    # Act
    actual = _filtered(validate_orchestrator_state_text(text))

    # Assert
    assert actual == case["expected_errors"], f"{path.stem}: {actual!r}"


@pytest.mark.parametrize("path", _COMPLETION_CASES, ids=lambda path: path.stem)
def test_completion_errors_match_expected(path: Path) -> None:
    """``require_complete`` ``blocked_reason`` errors equal the recorded list."""

    # Arrange
    case = _load_case(path)
    text = json.dumps(case["checkpoint"])

    # Act
    actual = _filtered(validate_orchestrator_state_text(text, require_complete=True))

    # Assert
    assert actual == case["expected_completion_errors"], f"{path.stem}: {actual!r}"
