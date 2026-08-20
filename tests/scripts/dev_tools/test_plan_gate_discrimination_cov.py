"""Unit tests for the context-free `--cov` classification rules G1 and G4."""

from __future__ import annotations

import pytest

from scripts.dev_tools.plan_gate_discrimination import (
    PlanGateReport,
    evaluate_plan_gates,
)

_PHASE = "### Phase 3 — Work"


def _plan(acceptance: str, *, task: str = "P3-T4") -> str:
    """Build a minimal one-task plan whose acceptance bullet holds a command."""

    return "\n".join(
        [
            _PHASE,
            f"- [ ] [{task}] Do the thing",
            f"  - Acceptance: `{acceptance}` reports 0 failed.",
            "",
        ]
    )


@pytest.mark.parametrize(
    ("acceptance", "expected_blocking", "expected_warnings"),
    [
        # Placeholder values are never judged: the command was not meant to run.
        ("poetry run pytest --cov=<module>", 0, 0),
        # A `.py` suffix names a filesystem path, which coverage.py rejects.
        ("poetry run pytest --cov=scripts/dev_tools/foo.py", 1, 0),
        # Truncation at the first `::` exposes the `.py` suffix.
        ("poetry run pytest --cov=scripts/dev_tools/foo.py::TestFoo", 1, 0),
        # A slash path with no suffix needs the tracked tree, so no finding.
        ("poetry run pytest --cov=scripts/dev_tools/foo", 0, 0),
        # A tracked directory spelling likewise needs the tracked tree.
        ("poetry run pytest --cov=scripts/dev_tools", 0, 0),
        # A dotted module name is the accepted form.
        ("poetry run pytest --cov=scripts.dev_tools.foo", 0, 0),
        # `.` is an accepted coverage target.
        ("poetry run pytest --cov=.", 0, 0),
        # An empty value carries no path separator and is accepted.
        ("poetry run pytest --cov= tests", 0, 0),
        # The space-separated form is a Warning regardless of the value.
        ("poetry run pytest --cov tests/foo", 0, 1),
        # Neighbouring coverage flags are not `--cov` arguments.
        ("poetry run pytest --cov-branch --cov-report=term-missing", 0, 0),
    ],
)
def test_cov_value_classification(
    acceptance: str, expected_blocking: int, expected_warnings: int
) -> None:
    """Each row of the `--cov` classification table lands on its channel."""

    # Arrange
    text = _plan(acceptance)

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert len(report.blocking) == expected_blocking
    assert len(report.warnings) == expected_warnings


def test_g1_reports_dotted_remedy_without_context() -> None:
    """G1 names the dotted remedy and keeps `.py` out of the remedy clause."""

    # Arrange
    text = _plan("poetry run pytest --cov=scripts/dev_tools/foo.py")

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert len(report.blocking) == 1
    finding = report.blocking[0]
    assert finding.startswith("[P3-T4] ")
    assert "`scripts/dev_tools/foo.py`" in finding
    assert "scripts.dev_tools.foo" in finding
    remedy = finding[finding.index("Use --cov=") :]
    assert ".py" not in remedy


def test_g1_dotted_remedy_normalizes_backslash_paths() -> None:
    """A backslash-spelled coverage path yields the same dotted remedy."""

    # Arrange: double quoting preserves the backslashes through shell splitting.
    text = _plan('poetry run pytest "--cov=scripts\\dev_tools\\foo.py"')

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert len(report.blocking) == 1
    assert "Use --cov=scripts.dev_tools.foo." in report.blocking[0]


def test_g4_space_separated_cov_is_warning_not_blocking() -> None:
    """A space-separated `--cov` value warns and never blocks."""

    # Arrange
    text = _plan("poetry run pytest --cov tests/foo")

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert len(report.warnings) == 1
    assert report.warnings[0].startswith("[P3-T4] ")
    assert "--cov=<module>" in report.warnings[0]


def test_trailing_cov_flag_without_value_produces_no_finding() -> None:
    """A `--cov` flag that ends the command supplies no value to judge."""

    # Arrange
    text = _plan("poetry run pytest --cov")

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_placeholder_markers_are_all_recognized() -> None:
    """Each interpolation marker form suppresses every coverage finding."""

    # Arrange
    markers = ("<module>.py", "${MODULE}.py", "$(module).py", "%MODULE%.py")

    # Act
    reports = [
        evaluate_plan_gates(_plan(f"poetry run pytest --cov=scripts/{marker}"))
        for marker in markers
    ]

    # Assert
    assert all(report.blocking == [] for report in reports)
    assert all(report.warnings == [] for report in reports)


def test_every_finding_begins_with_task_identifier() -> None:
    """Every Blocking and Warning finding is prefixed by its task identifier."""

    # Arrange
    text = "\n".join(
        [
            _PHASE,
            "- [ ] [P3-T4] Blocking case",
            "  - Acceptance: `poetry run pytest --cov=scripts/dev_tools/foo.py`.",
            "- [ ] [P3-T5] Warning case",
            "  - Acceptance: `poetry run pytest --cov tests/foo`.",
            "",
        ]
    )

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking, "fixture must produce at least one Blocking finding"
    assert report.warnings, "fixture must produce at least one Warning"
    assert all(finding.startswith("[P3-T4] ") for finding in report.blocking)
    assert all(finding.startswith("[P3-T5] ") for finding in report.warnings)


def test_report_channels_default_to_empty_and_independent_lists() -> None:
    """A fresh report starts with both channels empty and not shared."""

    # Arrange
    first = PlanGateReport()
    second = PlanGateReport()

    # Act
    first.blocking.append("finding")

    # Assert
    assert sorted(PlanGateReport.__dataclass_fields__) == ["blocking", "warnings"]
    assert second.blocking == []
    assert second.warnings == []


def test_context_free_call_returns_empty_for_tracked_path_value() -> None:
    """A tracked-path `--cov` value produces no Blocking finding without context."""

    # Arrange
    text = _plan("poetry run pytest --cov=scripts/dev_tools/plan_gate_commands")

    # Act
    report = evaluate_plan_gates(text, context=None)

    # Assert
    assert report.blocking == []
