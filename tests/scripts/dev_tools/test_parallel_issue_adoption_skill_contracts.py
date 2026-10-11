"""Contract tests for the issue-adoption instructions in the parallel skills (#849).

Purpose:
    Pin the skill and rule-document text that tells a parallel preparation
    child and a parallel execution child to adopt an existing GitHub issue
    (record a top-level ``issue_adoption`` object) instead of promoting it, and
    the origin-conditional ``potential_record`` requirement stated by the
    orchestrator-state rule document and the two skills that describe it.

Invariants and constraints:
    The added prompt text must carry no mode marker, no issue-number shape the
    preimplementation-gate hook would resolve, and no active feature-folder
    path, so hook target resolution and mode classification are unchanged.
    The parallel-plan kickoff line must stay byte-for-byte unchanged, and the
    parallel-orchestrate kickoff parameter must keep exactly five elements.

Side effects:
    Reads committed repository files inside test bodies only. Nothing is read
    at collection time, no temporary file is created, and no process is
    started.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    collapse_whitespace,
    extract_section,
    read_repo_text,
)

if TYPE_CHECKING:
    from collections.abc import Callable

PARALLEL_PLAN_SKILL = Path(".claude/skills/parallel-plan/SKILL.md")
PARALLEL_ORCHESTRATE_SKILL = Path(".claude/skills/parallel-orchestrate/SKILL.md")
ORCHESTRATE_SKILL = Path(".claude/skills/orchestrate/SKILL.md")
LIFECYCLE_SKILL = Path(".claude/skills/feature-promotion-lifecycle/SKILL.md")
ORCHESTRATOR_STATE_RULE = Path(".claude/rules/orchestrator-state.md")

ITEM_INTAKE_HEADING = "## Item Intake"
FAN_OUT_HEADING = "## Preparation Fan-Out"
KICKOFF_PARAMETER_HEADING = "## Parallel-Mode Kickoff Parameter"
INVARIANTS_HEADING = "## Invariants (issue_adoption object)"

ADOPTION_LINE_PREFIX = "> `Issue adoption:"
INTAKE_FRAGMENT = "Issue-number items are adopted, not promoted."
ELEMENT_FOUR_FRAGMENT = "the preparation checkpoint does not carry over"
MODE_MARKERS: tuple[str, ...] = (
    "Epic mode: true",
    "Parallel mode: true",
    "Preparation mode: true",
)
SHARED_RECORD_FRAGMENTS: tuple[str, ...] = (
    "required when `origin` is `epic_decomposition`",
    "optional when `origin` is `transferred` or `filed_before_orchestration`",
    "validated whenever it is present",
)
PROMOTED_RECORD_FRAGMENT = (
    "A lifecycle record moved to `docs/features/potential/promoted/` satisfies "
    "the `potential_record` path rule"
)

# The issue-number shape the preimplementation-gate hook resolves from a prompt.
HOOK_ISSUE_NUMBER_PATTERN = re.compile(
    r"issue(?:[_-]?num(?:ber)?|\s+number)\s*[:=]\s*#?(\d+)", re.IGNORECASE
)

# The parallel-plan kickoff blockquote line, copied verbatim from the baseline.
KICKOFF_LINE = (
    "> `Preparation mode: true. route_id: preparation. parallel_slug: <slug>. "
    "Perform promotion, research, feature documents (spec.md, user-story.md), "
    "atomic planning, and preflight clearance only. Atomic execution, PR "
    "authoring, and CI monitoring are out of scope for this run and are executed "
    "later by parallel-orchestrator. After the atomic-executor preflight returns "
    "PREFLIGHT: ALL CLEAR, commit the feature folder and plan to the current "
    "branch, push the current branch to origin, set out-of-scope step statuses "
    "to not-applicable, set next_step to S5_atomic_execution, and stop, "
    "reporting the plan-path and preflight status.`"
)


def _fan_out_section() -> str:
    """Return the ``## Preparation Fan-Out`` section of the parallel-plan skill."""

    return extract_section(read_repo_text(PARALLEL_PLAN_SKILL), FAN_OUT_HEADING)


def _adoption_line() -> str:
    """Return the single issue-adoption blockquote line of the fan-out section.

    Raises:
        AssertionError: If the section does not hold exactly one such line.
    """

    lines = [
        line
        for line in _fan_out_section().splitlines()
        if line.startswith(ADOPTION_LINE_PREFIX)
    ]
    if len(lines) != 1:
        raise AssertionError(
            f"expected exactly one line starting {ADOPTION_LINE_PREFIX!r} in "
            f"{FAN_OUT_HEADING}, found {len(lines)}"
        )
    return lines[0]


def _element_four_text() -> str:
    """Return element 4 of the parallel-orchestrate kickoff parameter, joined.

    Raises:
        AssertionError: If the element 4 or element 5 line cannot be located.
    """

    section = extract_section(
        read_repo_text(PARALLEL_ORCHESTRATE_SKILL), KICKOFF_PARAMETER_HEADING
    )
    lines = section.splitlines()
    starts = [index for index, line in enumerate(lines) if line.startswith("4. ")]
    ends = [index for index, line in enumerate(lines) if line.startswith("5. ")]
    if len(starts) != 1 or len(ends) != 1 or ends[0] <= starts[0]:
        raise AssertionError(
            f"element 4 boundaries not found: starts={starts}, ends={ends}"
        )
    return "\n".join(lines[starts[0] : ends[0]])


ADDED_TEXT_SOURCES: dict[str, Callable[[], str]] = {
    "parallel-plan-adoption-line": _adoption_line,
    "parallel-orchestrate-element-four": _element_four_text,
}
SKILL_SOURCES: dict[str, Path] = {
    "orchestrate": ORCHESTRATE_SKILL,
    "feature-promotion-lifecycle": LIFECYCLE_SKILL,
}


def test_parallel_plan_item_intake_declares_issue_number_items_adopted() -> None:
    """Item Intake states that issue-number items are adopted, not promoted."""

    # Arrange
    text = read_repo_text(PARALLEL_PLAN_SKILL)

    # Act
    collapsed = collapse_whitespace(extract_section(text, ITEM_INTAKE_HEADING))

    # Assert
    assert INTAKE_FRAGMENT in collapsed, "Item Intake lacks the adoption statement"
    assert "issue_adoption" in collapsed, "Item Intake does not name issue_adoption"


def test_parallel_plan_fan_out_carries_issue_adoption_prompt_line() -> None:
    """The fan-out section carries one issue-adoption line naming the object."""

    # Arrange / Act
    line = _adoption_line()

    # Assert
    assert "issue_adoption" in line, f"adoption line lacks issue_adoption: {line}"
    assert "potential_to_issue" in line, f"adoption line lacks the tool: {line}"


def test_parallel_plan_issue_adoption_line_carries_no_mode_marker() -> None:
    """The issue-adoption line carries no epic, parallel, or preparation marker."""

    # Arrange
    line = _adoption_line()

    # Act
    present = [marker for marker in MODE_MARKERS if marker in line]

    # Assert
    assert present == [], f"adoption line carries mode markers: {present}"


def test_parallel_plan_kickoff_line_is_unchanged() -> None:
    """The preparation kickoff line is still present verbatim."""

    # Arrange
    section = _fan_out_section()

    # Act
    lines = section.splitlines()

    # Assert
    assert KICKOFF_LINE in lines, "the preparation kickoff line was changed"


def test_parallel_orchestrate_element_four_carries_issue_adoption() -> None:
    """Kickoff element 4 tells the execution child to record its own adoption."""

    # Arrange
    text = _element_four_text()

    # Act
    collapsed = collapse_whitespace(text)

    # Assert
    assert "issue_adoption" in collapsed, "element 4 does not name issue_adoption"
    assert "potential_to_issue" in collapsed, "element 4 does not name the tool"
    assert ELEMENT_FOUR_FRAGMENT in collapsed, "element 4 lacks the carry-over note"


def test_parallel_orchestrate_kickoff_keeps_five_elements() -> None:
    """The kickoff parameter still declares exactly five elements."""

    # Arrange
    text = read_repo_text(PARALLEL_ORCHESTRATE_SKILL)

    # Act
    section = extract_section(text, KICKOFF_PARAMETER_HEADING)
    sixth = [line for line in section.splitlines() if line.startswith("6. ")]

    # Assert
    assert "exactly these five elements" in collapse_whitespace(section)
    assert sixth == [], f"kickoff parameter gained a sixth element: {sixth}"


@pytest.mark.parametrize("source_id", sorted(ADDED_TEXT_SOURCES), ids=str)
def test_added_skill_text_does_not_match_hook_issue_number_pattern(
    source_id: str,
) -> None:
    """Added prompt text carries no hook issue-number shape and no active path."""

    # Arrange
    text = ADDED_TEXT_SOURCES[source_id]()

    # Act
    match = HOOK_ISSUE_NUMBER_PATTERN.search(text)

    # Assert
    assert match is None, f"{source_id} matches the hook pattern: {match}"
    assert "docs/features/active/" not in text, f"{source_id} names an active path"


def test_rule_doc_states_origin_conditional_potential_record() -> None:
    """The rule document states the origin-conditional record requirement."""

    # Arrange
    text = read_repo_text(ORCHESTRATOR_STATE_RULE)

    # Act
    collapsed = collapse_whitespace(extract_section(text, INVARIANTS_HEADING))

    # Assert
    for fragment in (*SHARED_RECORD_FRAGMENTS, PROMOTED_RECORD_FRAGMENT):
        assert fragment in collapsed, f"rule document lacks: {fragment}"


@pytest.mark.parametrize("skill_id", sorted(SKILL_SOURCES), ids=str)
def test_skill_states_origin_conditional_potential_record(skill_id: str) -> None:
    """The skill states the origin-conditional record requirement."""

    # Arrange
    text = read_repo_text(SKILL_SOURCES[skill_id])

    # Act
    collapsed = collapse_whitespace(text)

    # Assert
    for fragment in SHARED_RECORD_FRAGMENTS:
        assert fragment in collapsed, f"{skill_id} skill lacks: {fragment}"
