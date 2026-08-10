"""Table-level negative tests for the parallel kickoff Markdown contract.

Split out of `tests/scripts/dev_tools/test_parallel_kickoff_contract.py` under
the [P2-T8] conditional-split instruction so that neither test module exceeds
the repository's 500-line file-size limit. This module holds the item-table and
integrity-table negative scenarios; the positive and structural-heading
scenarios stay in the first module, from which the document-builder helpers are
imported. Every fixture document is an in-memory string literal.
"""

from __future__ import annotations

import pytest

from scripts.dev_tools.parallel_kickoff_contract import validate_parallel_kickoff_text
from tests.scripts.dev_tools.test_parallel_kickoff_contract import (
    HASH_40,
    ITEM_HEADER_ROW,
    ITEM_ROW_101,
    ITEM_SEPARATOR_ROW,
    kickoff,
    kickoff_with_integrity,
)

EXPECTED_HEADER_ERROR = (
    "Parallel kickoff item table headers must be: "
    "issue_num | feature_folder | cohort | complexity | branch | plan-path"
)
PLAN_PATH_101 = "docs/features/active/item-101/plan.md"


def test_item_table_with_wrong_header_text_is_reported() -> None:
    """A renamed item-table column is rejected with the exact header contract."""

    # Arrange
    document = kickoff().replace("| issue_num |", "| issue |")

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert EXPECTED_HEADER_ERROR in errors


def test_item_table_with_headers_in_the_wrong_order_is_reported() -> None:
    """Header order is contractual because row cells are read positionally."""

    # Arrange
    document = kickoff().replace(
        ITEM_HEADER_ROW,
        "| issue_num | feature_folder | complexity | cohort | branch | plan-path |",
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert EXPECTED_HEADER_ERROR in errors


def test_item_table_missing_its_separator_row_is_reported() -> None:
    """Removing the separator row makes the first data row an invalid separator."""

    # Arrange
    document = kickoff().replace(f"{ITEM_SEPARATOR_ROW}\n", "")

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff table separator row is invalid." in errors


def test_item_table_with_only_a_header_row_is_reported() -> None:
    """A table with fewer than two lines cannot carry a header and a separator."""

    # Arrange
    document = kickoff(rows=()).replace(f"\n{ITEM_SEPARATOR_ROW}", "")

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff table is missing its header or separator row." in errors


def test_item_row_with_the_wrong_cell_count_is_reported() -> None:
    """A row whose cell count differs from six is reported and skipped."""

    # Arrange
    short_row = "| 101 | docs/features/active/item-101 | 0 | C3 | feature/item-101 |"
    document = kickoff(rows=(short_row,))

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert f"Parallel kickoff table row is invalid: {short_row}" in errors


def test_item_row_that_is_not_pipe_delimited_is_reported() -> None:
    """A data line that is not a Markdown table row is reported and skipped."""

    # Arrange
    prose_row = "101 is scheduled in cohort 0"
    document = kickoff(rows=(prose_row,))

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert f"Parallel kickoff table row is invalid: {prose_row}" in errors


def test_item_table_with_zero_data_rows_is_reported() -> None:
    """A well-formed header and separator with no data row is still invalid."""

    # Arrange
    document = kickoff(rows=())

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff item table must contain at least one item row." in errors


def test_non_integer_issue_num_is_reported_with_its_row_index() -> None:
    """A non-numeric `issue_num` cell is reported against its row index."""

    # Arrange
    document = kickoff(rows=(ITEM_ROW_101.replace("| 101 |", "| one-oh-one |"),))

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff item row 0 issue_num must be an integer." in errors


def test_non_integer_cohort_is_reported_with_its_row_index() -> None:
    """A non-numeric `cohort` cell is reported against its row index."""

    # Arrange
    document = kickoff(
        rows=(ITEM_ROW_101.replace("/item-101 | 0 |", "/item-101 | first |"),)
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff item row 0 cohort must be an integer." in errors


@pytest.mark.parametrize("band", ["C0", "C5"])
def test_complexity_outside_the_allowed_bands_is_reported(band: str) -> None:
    """Both boundary bands just outside C1 through C4 are rejected."""

    # Arrange
    document = kickoff(rows=(ITEM_ROW_101.replace("| C3 |", f"| {band} |"),))

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff item row 0 complexity must be C1-C4." in errors


def test_second_row_violation_is_reported_against_the_second_row_index() -> None:
    """Row indexing is per-row so a later bad row is attributed correctly."""

    # Arrange
    bad_second_row = ITEM_ROW_101.replace("| 101 |", "| not-a-number |")
    document = kickoff(rows=(ITEM_ROW_101, bad_second_row))

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff item row 1 issue_num must be an integer." in errors


def test_integrity_table_with_a_wrong_header_is_reported() -> None:
    """An integrity table whose columns are not plan-path and a hash is rejected."""

    # Arrange
    document = kickoff_with_integrity(
        integrity_lines=(
            "| wrong | hash |",
            "| --- | --- |",
            f"| {PLAN_PATH_101} | {HASH_40} |",
        )
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert (
        "Parallel kickoff integrity table headers must be plan-path and plan-hash."
        in errors
    )


def test_integrity_table_missing_its_separator_row_is_reported() -> None:
    """An integrity table with a valid header but no separator row is rejected."""

    # Arrange
    document = kickoff_with_integrity(integrity_lines=("| plan-path | plan-hash |",))

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff integrity table is missing its separator row." in errors


def test_integrity_table_with_an_invalid_separator_row_is_reported() -> None:
    """An integrity separator row whose cells are not dash runs is rejected."""

    # Arrange
    document = kickoff_with_integrity(
        integrity_lines=(
            "| plan-path | plan-hash |",
            "| bad | bad |",
            f"| {PLAN_PATH_101} | {HASH_40} |",
        )
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff integrity table separator row is invalid." in errors


@pytest.mark.parametrize(
    "plan_hash",
    ["c" * 39, "d" * 65, "z" * 40],
    ids=["thirty-nine-hex", "sixty-five-hex", "non-hex"],
)
def test_out_of_contract_plan_hashes_are_reported(plan_hash: str) -> None:
    """Hashes below 40, above 64, or outside the hex alphabet are rejected."""

    # Arrange
    row = f"| {PLAN_PATH_101} | {plan_hash} |"
    document = kickoff_with_integrity(
        integrity_lines=("| plan-path | plan-hash |", "| --- | --- |", row)
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert f"Parallel kickoff integrity table row is invalid: {row}" in errors


def test_repeated_plan_path_in_the_integrity_table_is_reported() -> None:
    """A repeated plan path would make its recorded hash ambiguous."""

    # Arrange
    document = kickoff_with_integrity(
        integrity_lines=(
            "| plan-path | plan-hash |",
            "| --- | --- |",
            f"| {PLAN_PATH_101} | {HASH_40} |",
            f"| {PLAN_PATH_101} | {'b' * 64} |",
        )
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert f"Parallel kickoff integrity repeats plan path: {PLAN_PATH_101!r}." in errors


def test_duplicate_run_level_commit_field_is_reported() -> None:
    """Two `planning_commit` fields make the pinned plan-home head ambiguous."""

    # Arrange
    document = kickoff_with_integrity(
        integrity_lines=(
            f"planning_commit: {'e' * 40}",
            f"planning_commit: {'f' * 40}",
        )
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert "Parallel kickoff integrity has duplicate planning_commit fields." in errors


def test_stray_non_table_line_inside_integrity_is_reported() -> None:
    """A line that is neither the commit field nor a table row is rejected."""

    # Arrange
    document = kickoff_with_integrity(
        integrity_lines=("this is not an integrity field",)
    )

    # Act
    errors = validate_parallel_kickoff_text(document)

    # Assert
    assert (
        "Parallel kickoff integrity line is invalid: this is not an integrity field"
        in errors
    )
