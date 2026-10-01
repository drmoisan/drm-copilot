"""Cross-runtime parity assertions over the remediation-loop corpus (issue #484).

Parametrize over every ``tests/fixtures/orchestrator_state_remediation_loop/*.json``
file and assert that the Python reference validator emits exactly the
remediation-family messages the case records in ``expected_errors``, in that
order. The same corpus files are asserted by the Jest suite
``extensions/drm-copilot/test/lib/validate/orchestrator-state-remediation-loop-parity.test.ts``
and the Pester suite
``tests/scripts/claude-lib/orchestrator-state/OrchestratorStateRemediationLoop.Parity.Tests.ps1``
so the corpus is the single artifact that pins the three runtimes together.
The pattern follows ``tests/scripts/dev_tools/test_parallel_cohort_barrier_parity.py``.

Fixture shape. Each file carries ``name`` (equal to the file stem), ``notes``
(one sentence naming the behavior the case pins), ``checkpoint`` (a complete
small-route checkpoint plus the case's ``remediation_loop``), and
``expected_errors`` (the ordered plain-validation errors containing
``remediation``, written from the spec message table).

This module imports only the public validator entry point and never the
remediation-loop helper module, so a missing helper name surfaces as an
assertion failure rather than an import error. The corpus files are committed
and read in place; no temporary file is created and no external process is
started.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "orchestrator_state_remediation_loop"
CORPUS_SUFFIX = ".json"

# Floor on corpus size. An empty or partially matched glob would make every
# parametrized case below disappear and the suite would pass vacuously.
MINIMUM_CORPUS_COUNT = 41

# Family filter restated from the spec: every remediation-family message
# contains this substring.
FAMILY_SUBSTRING = "remediation"

REQUIRED_FIXTURE_KEYS = ("name", "notes", "checkpoint", "expected_errors")

# The twelve R5-R11 message shapes from the spec message table, defined locally
# so the coverage check is pinned to the specification.
_INDEX = r"\d+"
NEW_MESSAGE_PATTERNS: dict[str, re.Pattern[str]] = {
    "R5": re.compile(
        rf"^Checkpoint remediation cycle #{_INDEX} candidate_applied must be a "
        r"boolean\.$"
    ),
    "R6": re.compile(
        rf"^Checkpoint remediation cycle #{_INDEX} candidate_applied is true but "
        r"execution_status is not 'complete'\.$"
    ),
    "R7a": re.compile(
        r"^Checkpoint remediation_loop completed_attempts must be a non-negative "
        r"integer\.$"
    ),
    "R7b": re.compile(
        rf"^Checkpoint remediation_loop completed_attempts is -?{_INDEX} but "
        rf"{_INDEX} cycles have candidate_applied true\.$"
    ),
    "R8a": re.compile(
        r"^Checkpoint remediation_loop review_outcomes must be a list\.$"
    ),
    "R8b": re.compile(
        rf"^Checkpoint remediation review outcome #{_INDEX} must be an object\.$"
    ),
    "R9a": re.compile(
        rf"^Checkpoint remediation review outcome #{_INDEX} verdict must be one of "
        r"PASS, REMEDIATION_REQUIRED, HALT_NON_REMEDIABLE, AWAITING_CI; got: .*$"
    ),
    "R9b": re.compile(
        rf"^Checkpoint remediation review outcome #{_INDEX} findings must be a "
        r"list\.$"
    ),
    "R9c": re.compile(
        rf"^Checkpoint remediation review outcome #{_INDEX} finding #{_INDEX} must "
        r"be an object\.$"
    ),
    "R9d": re.compile(
        rf"^Checkpoint remediation review outcome #{_INDEX} finding #{_INDEX} "
        r"remediability must be one of autonomous, external_dependency, "
        r"policy_hold, awaiting_ci, human_decision_required; got: .*$"
    ),
    "R10": re.compile(
        rf"^Checkpoint remediation review outcome #{_INDEX} verdict \S+ does not "
        r"match its findings \(expected \S+\)\.$"
    ),
    "R11": re.compile(
        rf"^Checkpoint remediation cycle #{_INDEX} opened_by_review must reference "
        r"a review outcome whose verdict is REMEDIATION_REQUIRED\.$"
    ),
}


def load_case(path: Path) -> dict[str, object]:
    """Read, parse, and structurally guard one committed corpus file.

    Args:
        path (Path): Path to a corpus JSON file.

    Returns:
        dict[str, object]: The parsed case object.

    Raises:
        TypeError: If the file or a field has the wrong JSON type.
        ValueError: If a required key is absent.
    """
    parsed = cast("object", json.loads(path.read_text(encoding="utf-8")))
    if not isinstance(parsed, dict):
        raise TypeError(f"{path.name} must be a JSON object.")
    case = cast("dict[str, object]", parsed)
    for key in REQUIRED_FIXTURE_KEYS:
        if key not in case:
            raise ValueError(f"{path.name} must carry the key {key}.")
    if not isinstance(case["checkpoint"], dict):
        raise TypeError(f"{path.name}.checkpoint must be a JSON object.")
    expected = case["expected_errors"]
    if not isinstance(expected, list) or not all(
        isinstance(entry, str) for entry in cast("list[object]", expected)
    ):
        raise TypeError(f"{path.name}.expected_errors must be a list of strings.")
    return case


def expected_errors(case: dict[str, object]) -> list[str]:
    """Return a case's ordered expected messages."""
    return cast("list[str]", case["expected_errors"])


CORPUS_PATHS: tuple[Path, ...] = tuple(sorted(CORPUS_DIR.glob(f"*{CORPUS_SUFFIX}")))
CORPUS_CASES: tuple[tuple[str, dict[str, object]], ...] = tuple(
    (path.stem, load_case(path)) for path in CORPUS_PATHS
)
CORPUS_IDS: list[str] = [stem for stem, _ in CORPUS_CASES]


def family_errors(checkpoint: object) -> list[str]:
    """Return the plain-validation errors containing the family token."""
    errors = state_validator.validate_orchestrator_state_text(json.dumps(checkpoint))
    return [error for error in errors if FAMILY_SUBSTRING in error]


def test_corpus_meets_the_minimum_size() -> None:
    """Guard every parametrized case below against an empty corpus glob."""
    # Arrange / Act: the corpus is discovered at import.
    discovered = len(CORPUS_PATHS)
    # Assert
    assert discovered >= MINIMUM_CORPUS_COUNT, (
        f"Expected at least {MINIMUM_CORPUS_COUNT} corpus files, "
        f"discovered {discovered}."
    )


def test_discovered_corpus_count_equals_the_json_file_count() -> None:
    """Require the discovery glob to reach every JSON file in the corpus."""
    # Arrange: enumerate the directory without the glob.
    on_disk = [
        entry
        for entry in CORPUS_DIR.iterdir()
        if entry.is_file() and entry.suffix == CORPUS_SUFFIX
    ]
    # Act / Assert
    assert len(CORPUS_PATHS) == len(on_disk)


@pytest.mark.parametrize(("stem", "case"), CORPUS_CASES, ids=CORPUS_IDS)
def test_case_name_equals_file_stem(stem: str, case: dict[str, object]) -> None:
    """A case cannot be renamed away from the file the other runtimes read."""
    assert case["name"] == stem


@pytest.mark.parametrize(("stem", "case"), CORPUS_CASES, ids=CORPUS_IDS)
def test_corpus_case_reproduces_expected_errors(
    stem: str, case: dict[str, object]
) -> None:
    """The validator emits exactly the case's remediation-family messages."""
    # Arrange
    expected = expected_errors(case)
    # Act
    observed = family_errors(case["checkpoint"])
    # Assert: element for element and in order.
    assert observed == expected, f"Corpus case {stem} differs from expected_errors."


def test_corpus_covers_every_new_message() -> None:
    """Each of the twelve R5-R11 messages occurs in at least one case."""
    # Arrange: every expected message across the corpus.
    messages = [
        message for _, case in CORPUS_CASES for message in expected_errors(case)
    ]
    # Act
    uncovered = [
        rule
        for rule, pattern in NEW_MESSAGE_PATTERNS.items()
        if not any(pattern.match(message) for message in messages)
    ]
    # Assert
    assert len(NEW_MESSAGE_PATTERNS) == 12
    assert uncovered == [], f"No corpus case expects the messages for {uncovered}."
