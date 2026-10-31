"""Contract tests for the parallel mutation rejection signal (issue #1012).

The closed rejection code set is defined once, in the rule section
``## Mutation Rejection Signal (issue #1012)`` of
``.claude/rules/parallel-orchestration.md``. The four parallel mutation skills
consume it: each mapped STOP path names only its own code in a
``PARALLEL_MUTATION_REJECTED: <code>`` line, every skill cites the rule section
by heading, and no skill restates the full member set. The three skills that
mutate a running run also state that their run-existence check is evaluated
first and that their unmapped STOP paths emit no signal.

The tests read committed repository files only; they create no file and start
no process.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

from tests.scripts.dev_tools.parallel_orchestrator_surface_test_support import (
    collapse_whitespace,
    extract_section,
    read_repo_text,
)

RULE_RELATIVE = Path(".claude/rules/parallel-orchestration.md")
RULE_HEADING = "## Mutation Rejection Signal (issue #1012)"
ENUM_OWNERSHIP_HEADING = "## Enum Ownership (F6/F7/F8 consume, never extend)"
F7_SEAM_HEADING = "## F7 Seam"
EXPECTED_CODES: tuple[str, ...] = (
    "kickoff_artifact_missing",
    "run_not_started",
    "items_in_flight",
    "unknown_item",
)

# A table row whose first cell is a single backticked code.
TABLE_CODE_ROW = re.compile(r"^\| `([a-z_]+)` \|", re.MULTILINE)
# An emitted signal line naming a concrete code; a placeholder such as <code>
# does not match.
SIGNAL_CODE = re.compile(r"PARALLEL_MUTATION_REJECTED: ([a-z_]+)")

PREREQUISITES_HEADING = "## Prerequisites"
PROCEDURE_HEADING = "## Procedure"
BEHAVIOR_TABLE_HEADING = "## State-Dependent Behavior Table (Normative)"

# The emission map of the spec: skill name, section heading, and the codes that
# section emits.
EMISSION_MAP: tuple[tuple[str, str, frozenset[str]], ...] = (
    ("parallel-run", PROCEDURE_HEADING, frozenset({"kickoff_artifact_missing"})),
    ("parallel-add", PREREQUISITES_HEADING, frozenset({"run_not_started"})),
    ("parallel-close", PREREQUISITES_HEADING, frozenset({"run_not_started"})),
    ("parallel-close", PROCEDURE_HEADING, frozenset({"items_in_flight"})),
    ("parallel-remove", PREREQUISITES_HEADING, frozenset({"run_not_started"})),
    (
        "parallel-remove",
        BEHAVIOR_TABLE_HEADING,
        frozenset({"items_in_flight", "unknown_item"}),
    ),
)
ALL_SKILLS: tuple[str, ...] = (
    "parallel-run",
    "parallel-add",
    "parallel-close",
    "parallel-remove",
)
MUTATING_SKILLS: tuple[str, ...] = ("parallel-add", "parallel-close", "parallel-remove")
RUN_EXISTENCE_FIRST = "run-existence check is evaluated first"
NO_SIGNAL_STATEMENT = "emits no rejection signal"


def _skill_text(skill: str) -> str:
    """Return the text of one parallel skill.

    Args:
        skill (str): Skill directory name under ``.claude/skills``.

    Returns:
        str: The SKILL.md text.

    Raises:
        OSError: If the skill file is absent.

    Side Effects:
        Reads one repository file.
    """

    return read_repo_text(Path(".claude/skills") / skill / "SKILL.md")


def _rule_section() -> str:
    """Return the body of the rejection signal rule section.

    Returns:
        str: The section body, bounded by the next top-level heading.

    Raises:
        ValueError: If the heading is absent.

    Side Effects:
        Reads one repository file.
    """

    return extract_section(read_repo_text(RULE_RELATIVE), RULE_HEADING)


def _rule_codes() -> tuple[str, ...]:
    """Return the codes of the rule section table in document order.

    Returns:
        tuple[str, ...]: The backticked first-cell codes of the table rows.

    Raises:
        ValueError: If the heading is absent.

    Side Effects:
        Reads one repository file.
    """

    return tuple(TABLE_CODE_ROW.findall(_rule_section()))


def _emitted_codes(text: str) -> frozenset[str]:
    """Return the distinct codes named by signal lines in a text.

    Args:
        text (str): Text to scan.

    Returns:
        frozenset[str]: The codes that follow ``PARALLEL_MUTATION_REJECTED: ``.

    Raises:
        None.

    Side Effects:
        None.
    """

    return frozenset(SIGNAL_CODE.findall(text))


def test_rule_section_heading_appears_once() -> None:
    """The rule file carries the rejection section heading exactly once."""

    # Arrange
    lines = read_repo_text(RULE_RELATIVE).splitlines()

    # Act
    count = sum(1 for line in lines if line == RULE_HEADING)

    # Assert
    assert count == 1, f"{RULE_HEADING} appears {count} times"


def test_rule_section_sits_between_enum_ownership_and_f7_seam() -> None:
    """The rejection section directly follows Enum Ownership and precedes F7 Seam."""

    # Arrange
    headings = [
        line
        for line in read_repo_text(RULE_RELATIVE).splitlines()
        if line.startswith("## ")
    ]

    # Act
    position = headings.index(RULE_HEADING) if RULE_HEADING in headings else -1

    # Assert
    assert position > 0, f"{RULE_HEADING} is not a top-level heading"
    assert headings[position - 1] == ENUM_OWNERSHIP_HEADING, headings[position - 1]
    assert headings[position + 1] == F7_SEAM_HEADING, headings[position + 1]


def test_rule_section_table_defines_four_unique_codes() -> None:
    """The rule section table lists the four codes once each, in rule order."""

    # Act
    codes = _rule_codes()

    # Assert
    assert codes == EXPECTED_CODES, f"rule table codes: {codes}"
    assert len(set(codes)) == len(codes), f"duplicate code in {codes}"


def test_rule_section_states_output_signal_and_not_an_enum() -> None:
    """The rule section states the signal is an output signal and not an enum."""

    # Act
    section = collapse_whitespace(_rule_section())

    # Assert
    assert "output signal" in section
    assert "not one of the nine enums" in section


@pytest.mark.parametrize(
    ("skill", "heading", "expected"),
    EMISSION_MAP,
    ids=[f"{skill}:{heading}" for skill, heading, _ in EMISSION_MAP],
)
def test_skill_section_emits_only_mapped_codes(
    skill: str, heading: str, expected: frozenset[str]
) -> None:
    """Each mapped STOP section emits exactly its mapped codes."""

    # Arrange
    section = extract_section(_skill_text(skill), heading)

    # Act
    emitted = _emitted_codes(section)

    # Assert
    assert emitted == expected, f"{skill} {heading} emits {sorted(emitted)}"


@pytest.mark.parametrize("skill", ALL_SKILLS)
def test_skill_emits_only_rule_codes(skill: str) -> None:
    """Every code a skill emits is defined by the rule section table."""

    # Arrange
    rule_codes = frozenset(_rule_codes())

    # Act
    emitted = _emitted_codes(_skill_text(skill))

    # Assert
    assert emitted, f"{skill} emits no rejection signal code"
    assert emitted <= rule_codes, f"{skill} emits {sorted(emitted - rule_codes)}"


@pytest.mark.parametrize("skill", ALL_SKILLS)
def test_skill_cites_rule_heading(skill: str) -> None:
    """Every skill cites the rule section by its heading."""

    # Act
    text = collapse_whitespace(_skill_text(skill))

    # Assert
    assert RULE_HEADING in text, f"{skill} does not cite {RULE_HEADING}"


@pytest.mark.parametrize("skill", ALL_SKILLS)
def test_skill_does_not_restate_full_code_set(skill: str) -> None:
    """No skill names all four codes, so the set is defined only in the rule."""

    # Arrange
    text = _skill_text(skill)

    # Act
    named = [code for code in EXPECTED_CODES if code in text]

    # Assert
    assert len(named) < len(EXPECTED_CODES), f"{skill} names every code: {named}"


@pytest.mark.parametrize("skill", MUTATING_SKILLS)
def test_skill_states_run_existence_check_first(skill: str) -> None:
    """The mutating skills evaluate their run-existence check first."""

    # Act
    section = collapse_whitespace(
        extract_section(_skill_text(skill), PREREQUISITES_HEADING)
    )

    # Assert
    assert RUN_EXISTENCE_FIRST in section, f"{skill} {PREREQUISITES_HEADING}"


@pytest.mark.parametrize("skill", MUTATING_SKILLS)
def test_skill_states_unmapped_paths_emit_no_signal(skill: str) -> None:
    """The mutating skills state that their unmapped STOP paths emit no signal."""

    # Act
    text = collapse_whitespace(_skill_text(skill))

    # Assert
    assert NO_SIGNAL_STATEMENT in text, f"{skill} has no unmapped-path statement"
