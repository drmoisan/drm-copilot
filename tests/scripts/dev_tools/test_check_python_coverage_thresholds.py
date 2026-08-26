"""Unit tests for the Python coverage-threshold enforcement gate.

Every test drives the module through its ``main`` entry point so the assertion
is on the exit code the quality-checks workflow step actually observes. Reports
are written into the in-memory filesystem supplied by the ``mem_fs_path``
fixture, so no test creates a temporary file on disk.
"""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import scripts.dev_tools.check_python_coverage_thresholds as checker

if TYPE_CHECKING:
    from pathlib import Path

    import pytest


def _write_report(root: Path, totals: dict[str, float]) -> Path:
    """Write an in-memory coverage.py JSON report and return its path."""
    report_path = root / "coverage.json"
    report_path.write_text(json.dumps({"totals": totals}), encoding="utf-8")
    return report_path


def test_both_metrics_above_floors_exit_zero(mem_fs_path: Path) -> None:
    """A report above both floors passes the gate with exit code 0."""
    # Arrange
    report_path = _write_report(
        mem_fs_path,
        {"percent_statements_covered": 92.6, "percent_branches_covered": 85.2},
    )

    # Act
    exit_code = checker.main(["--report", str(report_path)])

    # Assert
    assert exit_code == 0


def test_line_coverage_at_floor_is_accepted(mem_fs_path: Path) -> None:
    """Line coverage exactly at the 85.0 floor is inclusive and passes."""
    # Arrange
    report_path = _write_report(
        mem_fs_path,
        {"percent_statements_covered": 85.0, "percent_branches_covered": 90.0},
    )

    # Act
    exit_code = checker.main(["--report", str(report_path)])

    # Assert
    assert exit_code == 0


def test_branch_coverage_at_floor_is_accepted(mem_fs_path: Path) -> None:
    """Branch coverage exactly at the 75.0 floor is inclusive and passes."""
    # Arrange
    report_path = _write_report(
        mem_fs_path,
        {"percent_statements_covered": 90.0, "percent_branches_covered": 75.0},
    )

    # Act
    exit_code = checker.main(["--report", str(report_path)])

    # Assert
    assert exit_code == 0


def test_line_coverage_below_floor_exits_non_zero(
    mem_fs_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Line coverage below its floor fails the gate and names the metric."""
    # Arrange
    report_path = _write_report(
        mem_fs_path,
        {"percent_statements_covered": 84.9, "percent_branches_covered": 90.0},
    )

    # Act
    exit_code = checker.main(["--report", str(report_path)])
    captured = capsys.readouterr()

    # Assert
    assert exit_code != 0
    assert "line coverage" in captured.err


def test_branch_coverage_below_floor_exits_non_zero(
    mem_fs_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """Branch coverage below its floor fails the gate and names the metric."""
    # Arrange
    report_path = _write_report(
        mem_fs_path,
        {"percent_statements_covered": 90.0, "percent_branches_covered": 74.9},
    )

    # Act
    exit_code = checker.main(["--report", str(report_path)])
    captured = capsys.readouterr()

    # Assert
    assert exit_code != 0
    assert "branch coverage" in captured.err


def test_both_metrics_below_floor_are_both_reported(
    mem_fs_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A single invocation reports both breaches, not only the first."""
    # Arrange
    report_path = _write_report(
        mem_fs_path,
        {"percent_statements_covered": 60.0, "percent_branches_covered": 50.0},
    )

    # Act
    exit_code = checker.main(["--report", str(report_path)])
    captured = capsys.readouterr()

    # Assert
    assert exit_code != 0
    assert "line coverage" in captured.err
    assert "branch coverage" in captured.err


def test_absent_branch_data_exits_non_zero(
    mem_fs_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A report carrying no branch percentage fails rather than passing silently."""
    # Arrange
    report_path = _write_report(
        mem_fs_path,
        {"percent_statements_covered": 90.0},
    )

    # Act
    exit_code = checker.main(["--report", str(report_path)])
    captured = capsys.readouterr()

    # Assert
    assert exit_code != 0
    assert "branch data was not collected" in captured.err


def test_missing_report_file_exits_non_zero(
    mem_fs_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A report path that was never written fails and names the path."""
    # Arrange
    report_argument = str(mem_fs_path / "never-written.json")

    # Act
    exit_code = checker.main(["--report", report_argument])
    captured = capsys.readouterr()

    # Assert
    assert exit_code != 0
    assert report_argument in captured.err


def test_unparseable_report_exits_non_zero(
    mem_fs_path: Path,
    capsys: pytest.CaptureFixture[str],
) -> None:
    """A report whose content is not JSON fails and names the path."""
    # Arrange
    report_path = mem_fs_path / "unparseable.json"
    report_path.write_text("this content is not JSON", encoding="utf-8")
    report_argument = str(report_path)

    # Act
    exit_code = checker.main(["--report", report_argument])
    captured = capsys.readouterr()

    # Assert
    assert exit_code != 0
    assert report_argument in captured.err
