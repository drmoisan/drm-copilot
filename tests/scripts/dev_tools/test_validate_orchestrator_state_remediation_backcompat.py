"""Back-compat replay of the remediation-loop checkpoint corpus (issue #484).

Each committed checkpoint under
``tests/fixtures/orchestrator_state_remediation_loop_backcompat/`` carries no
#484 key (`review_outcomes`, `completed_attempts`, `candidate_applied`,
`opened_by_review`). The companion file
``tests/fixtures/orchestrator_state_remediation_loop_backcompat_expected.json``
records, under its ``python`` section, the full, unfiltered, ordered error list
that the validator returned for each fixture in each supported mode before any
#484 production edit. This suite replays every fixture and requires the same
list byte for byte, so the remediation-loop change cannot alter the output for
a checkpoint that does not use the new keys.

The fixtures are committed and read in place; no temporary file is created and
no external process is started.
"""

from __future__ import annotations

import json
from pathlib import Path
from typing import cast

import pytest

import scripts.dev_tools.validate_orchestrator_state as state_validator

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
FIXTURE_DIR = (
    REPO_ROOT / "tests" / "fixtures" / "orchestrator_state_remediation_loop_backcompat"
)
EXPECTED_PATH = (
    REPO_ROOT
    / "tests"
    / "fixtures"
    / "orchestrator_state_remediation_loop_backcompat_expected.json"
)
EXPECTED_FIXTURE_COUNT = 11
RUNTIME_KEY = "python"

# Mode name in the expected file mapped to the keyword arguments that select it.
# ``plain`` sets no flag; each other mode sets exactly one flag.
MODE_FLAGS: dict[str, dict[str, bool]] = {
    "plain": {},
    "require_complete": {"require_complete": True},
    "require_pr_creation_ready": {"require_pr_creation_ready": True},
    "require_model_routing": {"require_model_routing": True},
}

FIXTURE_PATHS: tuple[Path, ...] = tuple(sorted(FIXTURE_DIR.glob("*.json")))
FIXTURE_STEMS: tuple[str, ...] = tuple(path.stem for path in FIXTURE_PATHS)


def load_expected() -> dict[str, dict[str, dict[str, list[str]]]]:
    """Read the committed expected-output file.

    Returns:
        dict[str, dict[str, dict[str, list[str]]]]: Mapping of fixture stem to
        runtime to mode to the ordered error list.

    Raises:
        TypeError: If the file does not parse to a JSON object.
    """
    parsed = cast("object", json.loads(EXPECTED_PATH.read_text(encoding="utf-8")))
    if not isinstance(parsed, dict):
        raise TypeError(f"{EXPECTED_PATH.name} must be a JSON object.")
    return cast("dict[str, dict[str, dict[str, list[str]]]]", parsed)


EXPECTED = load_expected()
CASES: list[tuple[str, str]] = [
    (stem, mode) for stem in FIXTURE_STEMS for mode in MODE_FLAGS
]
CASE_IDS: list[str] = [f"{stem}-{mode}" for stem, mode in CASES]


def test_backcompat_fixture_count_is_eleven() -> None:
    """Guard the parametrized replay against a missing or extra fixture."""
    # Arrange: fixtures are discovered at import.
    # Act: count the discovered fixtures.
    discovered = len(FIXTURE_PATHS)

    # Assert: the corpus is fixed at eleven checkpoints.
    assert discovered == EXPECTED_FIXTURE_COUNT, (
        f"Expected {EXPECTED_FIXTURE_COUNT} back-compat fixtures under "
        f"{FIXTURE_DIR}, discovered {discovered}."
    )


@pytest.mark.parametrize(("stem", "mode"), CASES, ids=CASE_IDS)
def test_backcompat_error_lists_are_unchanged(stem: str, mode: str) -> None:
    """Require the captured full error list for one fixture and one mode."""
    # Arrange: the fixture text and its captured expectation.
    text = (FIXTURE_DIR / f"{stem}.json").read_text(encoding="utf-8")
    expected = EXPECTED[stem][RUNTIME_KEY][mode]

    # Act: validate with only the selected flag set.
    observed = state_validator.validate_orchestrator_state_text(
        text, **MODE_FLAGS[mode]
    )

    # Assert: element for element and in order.
    assert observed == expected, (
        f"Back-compat fixture {stem} in mode {mode} produced a different error "
        f"list than the captured baseline."
    )
