"""First-occurrence tests for `parse_verification_evidence_markdown` (issue #744).

The Python parser must keep the first occurrence of every accepted schema field
(`Timestamp`, `Command`, `EXIT_CODE`, and `ExpectedExitCode`), matching the
TypeScript parser, so an artifact that records several gates reports its first
gate and a later empty value cannot clear an earlier one.

All markdown fixtures are inline strings; no file is read or written.
"""

import pytest

from scripts.dev_tools.pr_context.verification_evidence import (
    VerificationEvidenceRecord,
    parse_verification_evidence_markdown,
)
from tests.scripts.dev_tools.pr_context.test_verification_evidence import (
    SHAPE_CASES,
)

FEATURE = "feature-744"
SOURCE = "evidence/qa-gates/gate.md"

_SCHEMA_KEYS: tuple[str, ...] = (
    "Timestamp",
    "Command",
    "EXIT_CODE",
    "ExpectedExitCode",
)


def _row_keys(markdown: str) -> list[str]:
    """Return the row key of every line that contains a colon.

    Args:
        markdown: Raw evidence-artifact markdown.

    Returns:
        The stripped text before the first colon of each colon-bearing line.

    Side Effects:
        None.
    """
    return [
        line.split(":", 1)[0].strip() for line in markdown.splitlines() if ":" in line
    ]


def _carries_each_key_at_most_once(markdown: str) -> bool:
    """Return whether no schema key appears more than once as a row key.

    Args:
        markdown: Raw evidence-artifact markdown.

    Returns:
        `True` when each of the four schema keys occurs at most once.

    Side Effects:
        None.
    """
    keys = _row_keys(markdown)
    return all(keys.count(schema_key) <= 1 for schema_key in _SCHEMA_KEYS)


# Shapes whose markdown repeats no schema key; the parser fix must leave their
# records unchanged. The derivation selects every shape except `shape-06`.
SINGLE_OCCURRENCE_CASES: list[tuple[str, str, str, int | None, int]] = [
    case for case in SHAPE_CASES if _carries_each_key_at_most_once(case[1])
]


def parse(markdown: str) -> VerificationEvidenceRecord:
    """Parse inline markdown with this module's fixed feature and source ids.

    Args:
        markdown: Raw evidence-artifact markdown.

    Returns:
        The parsed `VerificationEvidenceRecord`.

    Side Effects:
        None.
    """
    return parse_verification_evidence_markdown(
        feature=FEATURE, source_file=SOURCE, markdown=markdown
    )


def test_two_gate_file_pairs_first_command_with_first_expectation() -> None:
    """A two-gate artifact reports its first gate with the first expectation."""
    # Arrange
    markdown = (
        "Timestamp: 2026-09-30T04-00\nCommand: a\nEXIT_CODE: 1\nExpectedExitCode: 1"
        "\n\nCommand: b\nEXIT_CODE: 0"
    )

    # Act
    record = parse(markdown)

    # Assert
    assert record.command == "a", f"expected first command 'a', got {record.command!r}"
    assert (
        record.exit_code == 1
    ), f"expected first exit code 1, got {record.exit_code!r}"
    assert record.expected_exit_code == 1
    assert record.normalized_result == "pass"


def test_duplicated_timestamp_takes_first_occurrence() -> None:
    """A duplicated `Timestamp` row resolves to its first value."""
    # Arrange
    markdown = "Timestamp: first\nTimestamp: second\nCommand: c\nEXIT_CODE: 0"

    # Act
    record = parse(markdown)

    # Assert
    assert record.timestamp == "first", f"got {record.timestamp!r}"
    assert record.normalized_result == "pass"


def test_duplicated_command_takes_first_occurrence() -> None:
    """A duplicated `Command` row resolves to its first value."""
    # Arrange
    markdown = "Timestamp: t\nCommand: first\nCommand: second\nEXIT_CODE: 0"

    # Act
    record = parse(markdown)

    # Assert
    assert record.command == "first", f"got {record.command!r}"


def test_duplicated_exit_code_takes_first_occurrence() -> None:
    """A duplicated `EXIT_CODE` row resolves to its first value."""
    # Arrange
    markdown = "Timestamp: t\nCommand: c\nEXIT_CODE: 3\nEXIT_CODE: 0"

    # Act
    record = parse(markdown)

    # Assert
    assert record.exit_code == 3, f"got {record.exit_code!r}"
    assert record.normalized_result == "fail"


def test_empty_second_command_does_not_make_record_unparseable() -> None:
    """An empty later `Command` row does not clear the first value."""
    # Arrange
    markdown = "Timestamp: t\nCommand: c\nCommand:\nEXIT_CODE: 0"

    # Act
    record = parse(markdown)

    # Assert
    assert record.command == "c", f"got {record.command!r}"
    assert record.normalized_result == "pass"


@pytest.mark.parametrize(
    (
        "shape_id",
        "markdown",
        "expected_result",
        "expected_exit",
        "expected_expectation",
    ),
    SINGLE_OCCURRENCE_CASES,
    ids=[case[0] for case in SINGLE_OCCURRENCE_CASES],
)
def test_single_occurrence_record_is_unchanged(
    shape_id: str,
    markdown: str,
    expected_result: str,
    expected_exit: int | None,
    expected_expectation: int,
) -> None:
    """A shape that repeats no schema key keeps its pinned record."""
    # Arrange / Act
    record = parse(markdown)

    # Assert
    assert record.normalized_result == expected_result, shape_id
    assert record.exit_code == expected_exit, shape_id
    assert record.expected_exit_code == expected_expectation, shape_id
