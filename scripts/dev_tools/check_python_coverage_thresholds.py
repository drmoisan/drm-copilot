"""Fail a build when measured Python coverage falls below the policy floors.

Purpose:
    Provide the enforcement gate invoked by the ``Enforce Python coverage
    thresholds`` step of ``.github/workflows/_quality-checks.yml``. The step
    runs ``poetry run python -m
    scripts.dev_tools.check_python_coverage_thresholds --report
    artifacts/python/coverage.json --min-line 85 --min-branch 75`` and relies
    on this module's exit code to stop a run whose coverage regressed below the
    uniform thresholds recorded in ``.claude/rules/quality-tiers.md``.

Responsibilities:
    Separate the pure threshold comparison (``find_threshold_breaches``) from
    the report read (``load_totals``) and from argument parsing (``main``), so
    the comparison is testable without any filesystem interaction.

Usage:
    Command line::

        python -m scripts.dev_tools.check_python_coverage_thresholds \\
            --report artifacts/python/coverage.json \\
            --min-line 85 --min-branch 75

    The report is the JSON document written by ``coverage.py`` through
    ``pytest --cov-report=json:<path>``; its ``totals`` mapping supplies
    ``percent_statements_covered`` and ``percent_branches_covered``.

Invariants / Constraints:
    - Comparison is inclusive at the floor: a value exactly equal to its floor
      passes.
    - A missing metric is a failure, never a silent pass. A report produced
      without ``--cov-branch`` carries no branch percentage and is rejected
      with a message reporting that branch data was not collected.
    - Both metrics are evaluated on every call, so a report breaching both
      floors reports both messages rather than only the first.
    - The floors default to the policy values, so an omitted argument can never
      weaken the gate.
    - The report is read through ``pathlib.Path.read_text`` and parsed with
      ``json.loads``. The builtin ``open``, ``json.load`` applied to a file
      object, and ``os``-level reads are prohibited in this module: the
      repository forbids temporary files in unit tests, and the in-memory
      filesystem fixture that makes the loader testable patches ``Path``
      methods rather than the builtin ``open``.
    - The module adds no third-party dependency.

Side Effects:
    Reads the report file named on the command line and writes failure
    messages to standard error.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Mapping, Sequence

# The uniform coverage floors defined by `.claude/rules/quality-tiers.md`.
# They are the argument defaults so that an invocation that omits either
# option enforces policy rather than disabling the corresponding check.
DEFAULT_MIN_LINE = 85.0
DEFAULT_MIN_BRANCH = 75.0

# The `totals` keys emitted by the coverage.py JSON report. The line metric is
# reported per statement, which is what the policy line threshold measures.
LINE_PERCENT_KEY = "percent_statements_covered"
BRANCH_PERCENT_KEY = "percent_branches_covered"


class CoverageReportError(RuntimeError):
    """Raised when the coverage report cannot be read, parsed, or interpreted."""


def _evaluate_metric(
    totals: Mapping[str, object],
    *,
    key: str,
    floor: float,
    absent_message: str,
    breach_label: str,
) -> str | None:
    """Compare one recorded coverage metric against its floor.

    Purpose:
        Carry the shared comparison for both policy metrics so the absent-value
        rule and the inclusive-floor rule are expressed exactly once.

    Args:
        totals (Mapping[str, object]): The report's parsed ``totals`` mapping.
        key (str): The ``totals`` key holding the metric percentage.
        floor (float): The minimum acceptable percentage.
        absent_message (str): Message returned when the key is missing or holds
            a non-numeric value.
        breach_label (str): Human-readable metric name used to open the breach
            message.

    Returns:
        str | None: ``None`` when the metric is present and at or above its
        floor; otherwise the failure message describing the problem.

    Raises:
        None.

    Side Effects:
        None. This helper is pure.
    """

    value = totals.get(key)

    # A missing key, or a value that is not a number, means the metric was
    # never measured. Treating that as a pass would let a report produced
    # without branch measurement satisfy the branch threshold.
    if not isinstance(value, int | float):
        return absent_message

    percentage = float(value)

    # The comparison is strict, so a value exactly equal to the floor passes.
    if percentage < floor:
        return f"{breach_label} {percentage} is below the required floor {floor}."

    return None


def find_threshold_breaches(
    totals: Mapping[str, object],
    *,
    min_line: float,
    min_branch: float,
) -> list[str]:
    """Report every coverage threshold the supplied totals fail to meet.

    Purpose:
        Provide the pure comparison at the centre of the gate, so the threshold
        rules can be tested without reading a file.

    Args:
        totals (Mapping[str, object]): The ``totals`` mapping of a coverage.py
            JSON report.
        min_line (float): Minimum acceptable line-coverage percentage.
        min_branch (float): Minimum acceptable branch-coverage percentage.

    Returns:
        list[str]: One message per failure, in line-then-branch order. An empty
        list means the gate passes. Both metrics are always evaluated, so a
        totals mapping breaching both floors yields both messages.

    Raises:
        None.

    Side Effects:
        None. This function is pure and does not mutate ``totals``.
    """

    breaches: list[str] = []

    line_message = _evaluate_metric(
        totals,
        key=LINE_PERCENT_KEY,
        floor=min_line,
        absent_message=(
            "line coverage was not measured: the report totals carry no numeric "
            f"`{LINE_PERCENT_KEY}` value."
        ),
        breach_label="line coverage",
    )
    if line_message is not None:
        breaches.append(line_message)

    branch_message = _evaluate_metric(
        totals,
        key=BRANCH_PERCENT_KEY,
        floor=min_branch,
        absent_message=(
            "branch data was not collected: the report totals carry no numeric "
            f"`{BRANCH_PERCENT_KEY}` value, which is the shape produced when the "
            "branch measurement flag was omitted."
        ),
        breach_label="branch coverage",
    )
    if branch_message is not None:
        breaches.append(branch_message)

    return breaches


def load_totals(report_path: Path) -> Mapping[str, object]:
    """Read a coverage.py JSON report and return its ``totals`` mapping.

    Purpose:
        Isolate the single filesystem interaction of this module so the
        threshold comparison stays pure.

    Args:
        report_path (Path): Path to the coverage.py JSON report.

    Returns:
        Mapping[str, object]: The report's ``totals`` mapping.

    Raises:
        CoverageReportError: When the file is missing or unreadable, when its
            content is not valid JSON, when its root is not a JSON object, or
            when ``totals`` is absent or is not a mapping. Every message names
            the report path.

    Side Effects:
        Reads ``report_path`` through ``pathlib.Path.read_text``. The builtin
        ``open`` is deliberately not used; see the module docstring.
    """

    try:
        report_text = report_path.read_text(encoding="utf-8")
    except OSError as error:
        raise CoverageReportError(
            f"Coverage report could not be read: {report_path}: {error}"
        ) from error

    try:
        document: object = json.loads(report_text)
    except json.JSONDecodeError as error:
        raise CoverageReportError(
            f"Coverage report is not valid JSON: {report_path}: {error}"
        ) from error

    if not isinstance(document, dict):
        raise CoverageReportError(
            f"Coverage report root is not a JSON object: {report_path}"
        )

    totals = cast("dict[str, object]", document).get("totals")
    if not isinstance(totals, dict):
        raise CoverageReportError(
            f"Coverage report carries no `totals` mapping: {report_path}"
        )

    return cast("dict[str, object]", totals)


def main(argv: Sequence[str] | None = None) -> int:
    """Run the coverage-threshold enforcement CLI.

    Purpose:
        Provide the entry point the quality-checks workflow invokes, converting
        threshold failures into a non-zero exit code.

    Args:
        argv (Sequence[str] | None): Optional argument vector for programmatic
            invocation. ``None`` reads ``sys.argv``.

    Returns:
        int: ``0`` when every measured metric meets its floor, ``1`` when the
        report cannot be interpreted or any metric falls short.

    Raises:
        SystemExit: Propagated from ``argparse`` for ``--help`` and for invalid
            arguments.

    Side Effects:
        Reads the report file and writes failure messages to standard error.
    """

    parser = argparse.ArgumentParser(
        prog="check_python_coverage_thresholds",
        description=(
            "Fail the build when a coverage.py JSON report records line or "
            "branch coverage below the repository's uniform policy floors."
        ),
    )
    parser.add_argument(
        "--report",
        required=True,
        help="Path to the coverage.py JSON report to read.",
    )
    parser.add_argument(
        "--min-line",
        type=float,
        default=DEFAULT_MIN_LINE,
        help=(
            "Minimum acceptable line-coverage percentage. Defaults to "
            f"{DEFAULT_MIN_LINE}."
        ),
    )
    parser.add_argument(
        "--min-branch",
        type=float,
        default=DEFAULT_MIN_BRANCH,
        help=(
            "Minimum acceptable branch-coverage percentage. Defaults to "
            f"{DEFAULT_MIN_BRANCH}."
        ),
    )

    namespace = parser.parse_args(argv)
    report_path = Path(str(namespace.report))
    min_line = float(namespace.min_line)
    min_branch = float(namespace.min_branch)

    # The report read is the only failure mode that prevents any comparison, so
    # it is reported and returned immediately rather than swallowed. There is
    # no broad handler anywhere in this function: an unread metric can never
    # produce a success exit code.
    try:
        totals = load_totals(report_path)
    except CoverageReportError as error:
        print(str(error), file=sys.stderr)
        return 1

    breaches = find_threshold_breaches(
        totals,
        min_line=min_line,
        min_branch=min_branch,
    )
    for message in breaches:
        print(message, file=sys.stderr)

    return 1 if breaches else 0


if __name__ == "__main__":
    raise SystemExit(main())
