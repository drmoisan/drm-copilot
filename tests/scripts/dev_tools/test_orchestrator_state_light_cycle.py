"""Unit tests for invariant 8, the light-remediation rule (issue #1097).

``validate_light_cycles`` is pure, so every test calls it directly with in-memory
cycles and review outcomes and a local stand-in for the R11 predicate it receives
as a seam. The real predicate is exercised through the public validator entry
point: the invariant 2 test and the corpus rows run it. The last test reads the
committed corpus in place to prove that every invariant 8 message is pinned by a
corpus row. No test creates a file or starts a process.
"""

from __future__ import annotations

import json
import re
from pathlib import Path
from typing import TYPE_CHECKING, Any, cast

import scripts.dev_tools.validate_orchestrator_state as state_validator
from scripts.dev_tools._orchestrator_state_light_cycle import validate_light_cycles

if TYPE_CHECKING:
    from collections.abc import Sequence

# This file lives at tests/scripts/dev_tools/, three parents below the repo root.
REPO_ROOT = Path(__file__).resolve().parents[3]
CORPUS_DIR = REPO_ROOT / "tests" / "fixtures" / "orchestrator_state_remediation_loop"
TEMPLATE_ROW = "r11_opened_by_remediation_required_accepted.json"

LIGHT_PREFIX = "Checkpoint remediation cycle #0 remediation_path is light but "

# The seven invariant 8 message shapes from the spec, one pattern per rule.
_N = r"\d+"
INVARIANT_8_PATTERNS: dict[str, re.Pattern[str]] = {
    "rule 1": re.compile(
        rf"^Checkpoint remediation cycle #{_N} remediation_path must be light or "
        r"full\.$"
    ),
    "rule 2": re.compile(
        rf"^Checkpoint remediation cycle #{_N} remediation_path is light but the "
        r"cycle carries preflight\.$"
    ),
    "rule 3": re.compile(
        rf"^Checkpoint remediation cycle #{_N} remediation_path is light but "
        r"opened_by_review does not name its opening review\.$"
    ),
    "rule 4": re.compile(
        rf"^Checkpoint remediation cycle #{_N} remediation_path is light but its "
        rf"opening review has {_N} findings; the limit is 3\.$"
    ),
    "rule 5": re.compile(
        rf"^Checkpoint remediation cycle #{_N} remediation_path is light but finding "
        rf"#{_N} is not autonomous\.$"
    ),
    "rule 6": re.compile(
        rf"^Checkpoint remediation cycle #{_N} remediation_path is light but finding "
        rf"#{_N} scope is not contained\.$"
    ),
    "rule 7": re.compile(
        rf"^Checkpoint remediation cycle #{_N} remediation_path is light but the "
        r"prior cycle is light\.$"
    ),
}


def _finding(
    remediability: str = "autonomous", scope: str | None = "contained"
) -> dict[str, Any]:
    """Return one finding object; a None scope omits the key."""
    finding: dict[str, Any] = {"remediability": remediability}
    if scope is not None:
        finding["scope"] = scope
    return finding


def _outcomes(*findings: object) -> list[object]:
    """Return a one-entry review_outcomes list opened by REMEDIATION_REQUIRED."""
    return [{"verdict": "REMEDIATION_REQUIRED", "findings": list(findings)}]


def _light(**extra: object) -> dict[str, Any]:
    """Return a light cycle opened by review 0, with optional extra keys."""
    cycle: dict[str, Any] = {
        "plan_path": "docs/features/active/x/remediation-inputs.md",
        "remediation_path": "light",
        "opened_by_review": 0,
        "execution_status": "complete",
    }
    cycle.update(extra)
    return cycle


def _opens_review(opened_by_review: object, outcomes: object) -> bool:
    """Stand in for the R11 predicate: an index of a REMEDIATION_REQUIRED object."""
    if not isinstance(opened_by_review, int) or not isinstance(outcomes, list):
        return False
    outcome_list = cast("list[object]", outcomes)
    if not 0 <= opened_by_review < len(outcome_list):
        return False
    target = outcome_list[opened_by_review]
    return isinstance(target, dict) and (
        cast("dict[str, Any]", target).get("verdict") == "REMEDIATION_REQUIRED"
    )


def _validate(cycles: Sequence[object], outcomes: object) -> list[str]:
    """Run invariant 8 with the stand-in R11 predicate."""
    return validate_light_cycles(cycles, outcomes, _opens_review)


def _template_checkpoint(remediation_loop: dict[str, Any]) -> dict[str, Any]:
    """Return the committed template checkpoint with the given remediation_loop."""
    row = json.loads((CORPUS_DIR / TEMPLATE_ROW).read_text(encoding="utf-8"))
    checkpoint = cast("dict[str, Any]", row["checkpoint"])
    checkpoint["remediation_loop"] = remediation_loop
    return checkpoint


def test_light_messages_equal_the_spec_strings() -> None:
    """Each rule's message is byte-identical to the string in the spec."""
    # Arrange: one input per rule, each violating exactly that rule.
    many = _outcomes(_finding(), _finding(), _finding(), _finding())
    cases: list[tuple[list[object], object, list[str]]] = [
        (
            [{"plan_path": "p", "remediation_path": "LIGHT"}],
            _outcomes(_finding()),
            ["Checkpoint remediation cycle #0 remediation_path must be light or full."],
        ),
        (
            [_light(preflight=None)],
            _outcomes(_finding()),
            [LIGHT_PREFIX + "the cycle carries preflight."],
        ),
        (
            [_light(opened_by_review=5)],
            _outcomes(_finding()),
            [LIGHT_PREFIX + "opened_by_review does not name its opening review."],
        ),
        (
            [_light()],
            many,
            [LIGHT_PREFIX + "its opening review has 4 findings; the limit is 3."],
        ),
        (
            [_light()],
            _outcomes(_finding("awaiting_ci")),
            [LIGHT_PREFIX + "finding #0 is not autonomous."],
        ),
        (
            [_light()],
            _outcomes(_finding(scope="design")),
            [LIGHT_PREFIX + "finding #0 scope is not contained."],
        ),
    ]

    # Act / Assert: each case reports exactly its own message.
    for cycles, outcomes, expected in cases:
        assert _validate(cycles, outcomes) == expected

    # Rule 7 needs two cycles, so it is asserted on its own.
    pair = [_light(), _light()]
    assert _validate(pair, _outcomes(_finding())) == [
        "Checkpoint remediation cycle #1 remediation_path is light but the prior "
        "cycle is light."
    ]


def test_valid_light_cycle_reports_nothing() -> None:
    """A light cycle with three contained autonomous findings is accepted."""
    # Arrange
    outcomes = _outcomes(_finding(), _finding(), _finding())

    # Act
    errors = _validate([_light()], outcomes)

    # Assert
    assert errors == []


def test_full_cycle_reports_nothing_from_invariant_8() -> None:
    """A full cycle reaches no invariant 8 rule, whatever its other keys hold."""
    # Arrange: a full cycle after a light one, with a preflight and no opening review.
    cycles: list[object] = [
        _light(),
        {"plan_path": "p", "remediation_path": "full", "preflight": {}},
    ]

    # Act
    errors = _validate(cycles, _outcomes(_finding(scope="design")))

    # Assert: only the light cycle's own scope error is reported.
    assert errors == [LIGHT_PREFIX + "finding #0 scope is not contained."]


def test_absent_key_reports_nothing_from_invariant_8() -> None:
    """A cycle without remediation_path, and a missing cycle list, report nothing."""
    # Arrange
    cycles: list[object] = [{"plan_path": "p", "preflight": {"final_status": "x"}}]

    # Act
    with_cycle = _validate(cycles, None)
    without_cycles = validate_light_cycles(None, None, _opens_review)

    # Assert
    assert with_cycle == []
    assert without_cycles == []


def test_non_object_finding_reports_both_finding_rules() -> None:
    """A non-object finding is neither autonomous nor contained."""
    # Arrange
    outcomes = _outcomes("not-an-object")

    # Act
    errors = _validate([_light()], outcomes)

    # Assert
    assert errors == [
        LIGHT_PREFIX + "finding #0 is not autonomous.",
        LIGHT_PREFIX + "finding #0 scope is not contained.",
    ]


def test_non_list_findings_count_as_empty() -> None:
    """A findings value that is not a list adds no invariant 8 error; R9b reports it."""
    # Arrange
    outcomes: list[object] = [{"verdict": "REMEDIATION_REQUIRED", "findings": "none"}]

    # Act
    errors = _validate([_light()], outcomes)

    # Assert
    assert errors == []


def test_non_object_prior_cycle_is_ignored() -> None:
    """Rule 7 reads only an object prior cycle, and skips a non-object cycle itself."""
    # Arrange
    cycles: list[object] = ["light", _light()]

    # Act
    errors = _validate(cycles, _outcomes(_finding()))

    # Assert
    assert errors == []


def test_invariant_2_skipped_only_for_exact_light() -> None:
    """Invariant 2 still runs for every value other than the exact string light."""
    # Arrange: one checkpoint per remediation_path value, each with no preflight.
    invariant_2 = (
        "Checkpoint remediation cycle #0 execution_status is complete but "
        "preflight.final_status is not 'clear'."
    )
    outcomes = _outcomes(_finding())
    results: dict[str, bool] = {}

    # Act: record whether invariant 2 fired for each value.
    for label, value in (
        ("light", "light"),
        ("Light", "Light"),
        ("full", "full"),
        ("list", ["light"]),
    ):
        checkpoint = _template_checkpoint(
            {"review_outcomes": outcomes, "cycles": [_light(remediation_path=value)]}
        )
        errors = state_validator.validate_orchestrator_state_text(
            json.dumps(checkpoint)
        )
        results[label] = invariant_2 in errors

    # Assert
    assert results == {"light": False, "Light": True, "full": True, "list": True}


def test_corpus_expects_every_invariant_8_message() -> None:
    """Each of the seven invariant 8 messages occurs in at least one corpus row."""
    # Arrange: every expected message across the committed corpus.
    messages: list[str] = []
    for path in sorted(CORPUS_DIR.glob("*.json")):
        row = json.loads(path.read_text(encoding="utf-8"))
        messages.extend(cast("list[str]", row["expected_errors"]))

    # Act: the rules with no matching corpus message.
    missing = [
        rule
        for rule, pattern in INVARIANT_8_PATTERNS.items()
        if not any(pattern.match(message) for message in messages)
    ]

    # Assert
    assert missing == []
