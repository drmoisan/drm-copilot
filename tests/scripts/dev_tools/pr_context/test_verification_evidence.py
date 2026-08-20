"""Tests for `scripts.dev_tools.pr_context.verification_evidence`.

Covers the declared-expectation parsing added for issue #485: the optional
`ExpectedExitCode` evidence key, the pure `normalize_result` helper, and the
pre-existing shapes whose records must stay byte-identical.

All markdown fixtures are inline strings and the one file-reading test goes
through the in-memory `mem_fs_path` fixture, so no temporary file is created.
"""

from pathlib import Path

import pytest

from scripts.dev_tools.pr_context.verification_evidence import (
    VerificationEvidenceRecord,
    normalize_result,
    parse_verification_evidence_file,
    parse_verification_evidence_markdown,
)

FEATURE = "feature-485"
SOURCE = "evidence/qa-gates/gate.md"

# Eleven-shape fixture table transcribed from `spec.md` "Unit tests (pytest)".
# Each tuple is (shape_id, markdown, expected_result, expected_exit_code,
# expected_expectation). The identifiers and their ORDER are the contract that
# makes this table textually diffable against the TypeScript transcription in
# `extensions/drm-copilot/test/lib/pr-context/verification-evidence.test.ts`
# (AC8). Shapes 01-05 and 07-11 each carry exactly ONE `EXIT_CODE:` line, so the
# duplicate-`EXIT_CODE` precedence divergence deferred by the spec cannot
# confound them.
#
# shape-06 is the DUPLICATED-`EXIT_CODE` case and therefore carries TWO
# `EXIT_CODE:` lines by definition. Its expected record is RUNTIME-SPECIFIC:
# Python assigns unconditionally in the parse loop, so LAST occurrence wins and
# this case asserts the SECOND value (`0`). The TypeScript case asserts the
# FIRST value (`1`). shape-06 is EXCLUDED from the AC8 cross-runtime agreement
# assertion; the exclusion is attributable to the deferred duplicate-`EXIT_CODE`
# defect, not to this change.
SHAPE_CASES: list[tuple[str, str, str, int | None, int]] = [
    (
        "shape-01",
        "Timestamp: t\nCommand: c\nEXIT_CODE: 0",
        "pass",
        0,
        0,
    ),
    (
        "shape-02",
        "Timestamp: t\nCommand: c\nEXIT_CODE: 1",
        "fail",
        1,
        0,
    ),
    (
        "shape-03",
        "Timestamp: t\nCommand: c\nEXIT_CODE: ok",
        "unparseable",
        None,
        0,
    ),
    (
        "shape-04",
        "Timestamp: t\nEXIT_CODE: 0",
        "unparseable",
        None,
        0,
    ),
    (
        "shape-05",
        "Timestamp: t\nCommand:\nEXIT_CODE: 0",
        "unparseable",
        None,
        0,
    ),
    (
        "shape-06",
        "Timestamp: t\nCommand: c\nEXIT_CODE: 1\nEXIT_CODE: 0",
        "pass",
        0,
        0,
    ),
    (
        "shape-07",
        "Timestamp: t\nCommand: c\nEXIT_CODE: 0\nOutput Summary: all gates green",
        "pass",
        0,
        0,
    ),
    (
        "shape-08",
        "Timestamp: t\nCommand: c\nEXIT_CODE: 2",
        "fail",
        2,
        0,
    ),
    (
        "shape-09",
        "Timestamp: t\nCommand: c\nEXIT_CODE: 1\nExpectedExitCode: 1",
        "pass",
        1,
        1,
    ),
    (
        "shape-10",
        "Timestamp: t\nCommand: c\nEXIT_CODE: 2\nExpectedExitCode: 1",
        "fail",
        2,
        1,
    ),
    (
        "shape-11",
        "Timestamp: t\nCommand: c\nEXIT_CODE: 1\nExpectedExitCode: banana",
        "unparseable",
        None,
        0,
    ),
]

# Shapes 1-8 are the pre-existing population: none carries an expectation key,
# so each must reproduce the pre-change record exactly (AC1, Invariant A).
ADDITIVE_SHAPE_IDS = tuple(case[0] for case in SHAPE_CASES[:8])


def parse(markdown: str) -> VerificationEvidenceRecord:
    """Parse inline markdown with the module's standard feature and source ids.

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


@pytest.mark.parametrize(
    (
        "shape_id",
        "markdown",
        "expected_result",
        "expected_exit",
        "expected_expectation",
    ),
    SHAPE_CASES,
    ids=[case[0] for case in SHAPE_CASES],
)
def test_eleven_shape_fixture_table(
    shape_id: str,
    markdown: str,
    expected_result: str,
    expected_exit: int | None,
    expected_expectation: int,
) -> None:
    """Each of the eleven fixture shapes parses to its specified record."""
    # Arrange / Act
    record = parse(markdown)

    # Assert
    assert record.normalized_result == expected_result, shape_id
    assert record.exit_code == expected_exit, shape_id
    assert record.expected_exit_code == expected_expectation, shape_id


@pytest.mark.parametrize(
    ("shape_id", "markdown"),
    [(case[0], case[1]) for case in SHAPE_CASES[:8]],
    ids=list(ADDITIVE_SHAPE_IDS),
)
def test_absent_expectation_records_match_pre_change_shapes(
    shape_id: str, markdown: str
) -> None:
    """Shapes 1-8 carry no expectation key and match the pre-change record (AC1)."""
    # Arrange / Act
    record = parse(markdown)

    # Assert — the expectation always defaults to zero for this population, and
    # the result is exactly the pre-change expression restated inline. An
    # unparseable shape keeps its pre-change unparseable outcome.
    assert record.expected_exit_code == 0, shape_id
    if record.exit_code is None:
        assert record.normalized_result == "unparseable", shape_id
    else:
        pre_change = "pass" if record.exit_code == 0 else "fail"
        assert record.normalized_result == pre_change, shape_id


@pytest.mark.parametrize(
    "observed",
    [
        *range(-8, 9),
        -2147483648,
        -1000000,
        1000000,
        2147483647,
    ],
)
def test_normalize_result_with_default_expectation_matches_pre_change_expression(
    observed: int,
) -> None:
    """`normalize_result(observed, 0)` restates the pre-change expression (AC3)."""
    # Arrange
    pre_change = "pass" if observed == 0 else "fail"

    # Act
    result = normalize_result(observed, 0)

    # Assert
    assert result == pre_change


@pytest.mark.parametrize(
    ("observed", "expectation"),
    [(1, 1), (137, 137), (-3, -3)],
)
def test_observed_equal_to_nonzero_expectation_passes(
    observed: int, expectation: int
) -> None:
    """An observed code equal to a non-zero expectation passes and is retained (AC4)."""
    # Arrange
    markdown = "\n".join(
        (
            "Timestamp: 2026-08-20T09-53",
            "Command: git grep -n forbidden-token",
            f"EXIT_CODE: {observed}",
            f"ExpectedExitCode: {expectation}",
        )
    )

    # Act
    record = parse(markdown)

    # Assert
    assert record.normalized_result == "pass"
    assert record.exit_code == observed
    assert record.expected_exit_code == expectation


@pytest.mark.parametrize(("observed", "expectation"), [(2, 1), (0, 1)])
def test_observed_differing_from_nonzero_expectation_fails(
    observed: int, expectation: int
) -> None:
    """An observed code differing from a non-zero expectation fails (AC5)."""
    # Arrange
    markdown = "\n".join(
        (
            "Timestamp: t",
            "Command: c",
            f"EXIT_CODE: {observed}",
            f"ExpectedExitCode: {expectation}",
        )
    )

    # Act
    record = parse(markdown)

    # Assert
    assert record.normalized_result == "fail"
    assert record.exit_code == observed
    assert record.expected_exit_code == expectation


@pytest.mark.parametrize(
    "expectation_row",
    ["ExpectedExitCode: banana", "ExpectedExitCode:"],
)
def test_non_integer_expectation_is_unparseable_and_clears_fields(
    expectation_row: str,
) -> None:
    """A non-integer or empty expectation is unparseable and clears fields (AC6)."""
    # Arrange
    markdown = "\n".join(
        ("Timestamp: t", "Command: c", "EXIT_CODE: 1", expectation_row)
    )

    # Act
    record = parse(markdown)

    # Assert — Invariant E: no partial data survives on an unparseable record.
    assert record.normalized_result == "unparseable"
    assert record.exit_code is None
    assert record.expected_exit_code == 0


def test_duplicate_expectation_key_takes_first_occurrence() -> None:
    """A duplicated expectation key resolves to its first occurrence (AC7)."""
    # Arrange
    markdown = "\n".join(
        (
            "Timestamp: t",
            "Command: c",
            "EXIT_CODE: 7",
            "ExpectedExitCode: 7",
            "ExpectedExitCode: 9",
        )
    )

    # Act
    record = parse(markdown)

    # Assert
    assert record.expected_exit_code == 7
    assert record.normalized_result == "pass"


@pytest.mark.parametrize(
    "markdown",
    [
        "Timestamp: t\nCommand: c\nEXIT_CODE: SKIPPED",
        "Timestamp: t\nCommand: c\nEXIT_CODE: SKIPPED\nExpectedExitCode: 1",
    ],
    ids=["without-expectation", "with-expectation"],
)
def test_skipped_exit_code_remains_unparseable(markdown: str) -> None:
    """`EXIT_CODE: SKIPPED` stays unparseable with or without an expectation (AC14)."""
    # Arrange / Act
    record = parse(markdown)

    # Assert — Invariant F: the literal `SKIPPED` is never treated as passing.
    assert record.normalized_result == "unparseable"
    assert record.exit_code is None
    assert record.expected_exit_code == 0


def test_unrecognized_rows_are_ignored() -> None:
    """Rows outside the accept-list, including wrong casing, are discarded (AC15)."""
    # Arrange — the wrong-cased key and the summary row must both be ignored, so
    # the record must equal the one parsed from the same artifact without them.
    with_extra_rows = "\n".join(
        (
            "Timestamp: t",
            "Command: c",
            "EXIT_CODE: 1",
            "Output Summary: one gate, zero matches",
            "expectedexitcode: 1",
        )
    )
    without_extra_rows = "Timestamp: t\nCommand: c\nEXIT_CODE: 1"

    # Act
    record = parse(with_extra_rows)
    reference = parse(without_extra_rows)

    # Assert
    assert record == reference
    assert record.normalized_result == "fail"
    assert record.expected_exit_code == 0


def test_value_containing_further_colons_is_preserved_intact() -> None:
    """Only the first colon splits a row, so later colons stay in the value."""
    # Arrange
    command = "pwsh -Command Get-Content C:/repo/file.md ; echo done: yes"
    markdown = "\n".join(
        ("Timestamp: 2026-08-20T09-53", f"Command: {command}", "EXIT_CODE: 0")
    )

    # Act
    record = parse(markdown)

    # Assert
    assert record.command == command
    assert record.normalized_result == "pass"


def test_parse_verification_evidence_file_propagates_read_failure(
    mem_fs_path: Path,
) -> None:
    """A missing evidence file still raises `OSError` through the file parser."""
    # Arrange
    relative = Path("docs/features/active/feature-485/evidence/qa-gates/absent.md")

    # Act / Assert
    with pytest.raises(OSError):
        parse_verification_evidence_file(
            root=mem_fs_path, feature=FEATURE, relative_path=relative
        )


def test_parse_verification_evidence_file_reads_declared_expectation(
    mem_fs_path: Path,
) -> None:
    """The file parser carries the declared expectation through to the record."""
    # Arrange
    relative = Path("docs/features/active/feature-485/evidence/qa-gates/gate.md")
    target = mem_fs_path / relative
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_text(
        "Timestamp: 2026-08-20T09-53\nCommand: c\nEXIT_CODE: 1\nExpectedExitCode: 1\n",
        encoding="utf-8",
    )

    # Act
    record = parse_verification_evidence_file(
        root=mem_fs_path, feature=FEATURE, relative_path=relative
    )

    # Assert
    assert record.normalized_result == "pass"
    assert record.exit_code == 1
    assert record.expected_exit_code == 1
    assert record.source_file == relative.as_posix()
