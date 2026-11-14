"""Unit tests for the G13 guideline cutoff and plan-file stamp reader (issue #1097).

G13 applies 20 tasks and 250 physical lines, except to a plan file whose stamp
sorts before the `PLAN_GUIDELINE_CUTOFF` entry of its stamp zone, which keeps
40 tasks and 400 lines. Every test injects the fixed cutoff pair below, which
names one instant in both zones, and reads no clock and no committed cutoff
value. The boundary, shape, zone, and message rows are duplicated as
double-quoted literals in
`extensions/drm-copilot/test/lib/validate/plan-gate-guideline-cutoff.test.ts`,
and `test_typescript_suite_carries_identical_rows` fails when they diverge.
"""

from __future__ import annotations

import json
import re
from pathlib import Path

import pytest

from scripts.dev_tools.plan_gate_discrimination import PlanGateReport
from scripts.dev_tools.plan_gate_document import (
    LEGACY_PLAN_LINE_GUIDELINE,
    LEGACY_PLAN_TASK_GUIDELINE,
    PLAN_LINE_GUIDELINE,
    PLAN_STAMP_ZONES,
    PLAN_TASK_GUIDELINE,
    evaluate_document_gates,
    plan_file_stamp,
    plan_size_guideline,
)
from scripts.dev_tools.validate_orchestration_artifacts import (
    validate_plan_text_with_warnings,
)

_REPO_ROOT = Path(__file__).resolve().parents[3]
_TS_MODULE = (
    _REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "src"
    / "lib"
    / "validate"
    / "plan-gate-document.ts"
)
_TS_SUITE = (
    _REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "test"
    / "lib"
    / "validate"
    / "plan-gate-guideline-cutoff.test.ts"
)

# One instant written in both zones: 10:00 in New York is 15:00 UTC.
_CUTOFF = {"America/New_York": "2026-11-07T10-00", "UTC": "2026-11-07T15-00"}
_LEGACY = (40, 400)
_NEW = (20, 250)

_STAMP_ROWS: tuple[tuple[str, str, str], ...] = (
    ("plan.2026-11-07T09-59.md", "2026-11-07T09-59", "America/New_York"),
    ("docs\\f\\plan.2026-11-07T09-59.md", "2026-11-07T09-59", "America/New_York"),
    ("/repo/docs/f/plan.2026-11-07T09-59.md", "2026-11-07T09-59", "America/New_York"),
    ("C:\\repo\\f\\plan.2026-11-07T09-59.md", "2026-11-07T09-59", "America/New_York"),
    ("plan.remediation-cycle-1.2026-11-07T14-59.md", "2026-11-07T14-59", "UTC"),
    (
        "docs\\f\\plan.remediation-cycle-12.2026-11-07T14-59.md",
        "2026-11-07T14-59",
        "UTC",
    ),
    (
        "/repo/docs/f/plan.remediation-cycle-1.2026-11-07T14-59.md",
        "2026-11-07T14-59",
        "UTC",
    ),
    (
        "C:\\repo\\f\\plan.remediation-cycle-1.2026-11-07T14-59.md",
        "2026-11-07T14-59",
        "UTC",
    ),
    ("remediation-plan.2026-11-07T14-59.md", "2026-11-07T14-59", "UTC"),
    ("docs\\f\\remediation-plan.2026-11-07T14-59.md", "2026-11-07T14-59", "UTC"),
    ("/repo/docs/f/remediation-plan.2026-11-07T14-59.md", "2026-11-07T14-59", "UTC"),
    ("C:\\repo\\f\\remediation-plan.2026-11-07T14-59.md", "2026-11-07T14-59", "UTC"),
    ("remediation/2026-11-07T14-59/remediation-plan.md", "2026-11-07T14-59", "UTC"),
    (
        "docs\\f\\remediation\\2026-11-07T14-59\\remediation-plan.md",
        "2026-11-07T14-59",
        "UTC",
    ),
    (
        "/repo/f/remediation/2026-11-07T14-59/remediation-plan.md",
        "2026-11-07T14-59",
        "UTC",
    ),
    (
        "C:\\repo\\f\\remediation\\2026-11-07T14-59\\remediation-plan.md",
        "2026-11-07T14-59",
        "UTC",
    ),
)

_REJECTED_NAMES: tuple[str, ...] = (
    "plan.md",
    "plan.yyyy-MM-ddTHH-mm.md",
    "remediation-plan-ledger.2026-11-07T06-50.md",
    "remediation/2026-11-07T14-59/plan.md",
    "remediation-plan.md",
    "Plan.2026-11-07T09-59.md",
    "",
)

_BOUNDARY_ROWS: tuple[tuple[str, tuple[int, int]], ...] = (
    ("plan.2026-11-07T09-59.md", _LEGACY),
    ("plan.2026-11-07T10-00.md", _NEW),
    ("plan.2026-11-07T10-01.md", _NEW),
    ("remediation-plan.2026-11-07T14-59.md", _LEGACY),
    ("remediation-plan.2026-11-07T15-00.md", _NEW),
    ("remediation-plan.2026-11-07T15-01.md", _NEW),
)

_K4_SHAPE_ROWS: tuple[tuple[str, tuple[int, int]], ...] = (
    ("plan.2026-11-07T09-59.md", _LEGACY),
    ("plan.2026-11-07T10-00.md", _NEW),
    ("plan.remediation-cycle-1.2026-11-07T14-59.md", _LEGACY),
    ("plan.remediation-cycle-1.2026-11-07T15-00.md", _NEW),
    ("remediation-plan.2026-11-07T14-59.md", _LEGACY),
    ("remediation-plan.2026-11-07T15-00.md", _NEW),
    ("remediation/2026-11-07T14-59/remediation-plan.md", _LEGACY),
    ("remediation/2026-11-07T15-00/remediation-plan.md", _NEW),
)

_UTC_ROWS: tuple[tuple[str, tuple[int, int]], ...] = (
    ("remediation-plan.2026-11-07T14-30.md", _LEGACY),
    ("plan.remediation-cycle-1.2026-11-07T14-30.md", _LEGACY),
    ("remediation/2026-11-07T14-30/remediation-plan.md", _LEGACY),
    ("plan.2026-11-07T14-30.md", _NEW),
)

_LEGACY_MESSAGE = (
    "Line 1: plan size `41 tasks, 41 lines` exceeds the guideline of 40 tasks "
    "or 400 lines and carries no `## Size Justification` section; split the "
    "item or state why the size is necessary."
)
_NEW_MESSAGE = (
    "Line 1: plan size `41 tasks, 41 lines` exceeds the guideline of 20 tasks "
    "or 250 lines and carries no `## Size Justification` section; split the "
    "item or state why the size is necessary."
)
_OLD_PLAN_PATH = "docs/features/active/f/plan.2026-01-01T00-00.md"
_FUTURE_PLAN_PATH = "docs/features/active/f/plan.2099-12-31T23-59.md"
_MESSAGE_ROWS: tuple[tuple[str | None, str], ...] = (
    (_OLD_PLAN_PATH, _LEGACY_MESSAGE),
    (_FUTURE_PLAN_PATH, _NEW_MESSAGE),
    (None, _NEW_MESSAGE),
)


def _task_plan(task_count: int) -> str:
    """Return a plan made only of `task_count` canonical task lines."""

    return "".join(f"- [ ] [P1-T{index}] Step.\n" for index in range(task_count))


def _g13_findings(text: str, plan_path: str | None) -> list[str]:
    """Return the G13 findings `evaluate_document_gates` reports for a plan."""

    report = PlanGateReport()
    evaluate_document_gates(report, text, plan_path=plan_path)
    return [finding for finding in report.blocking if "plan size" in finding]


def test_guideline_constants_match_typescript() -> None:
    """Both validators declare the same guideline pairs and stamp-zone rows."""

    # Arrange
    source = _TS_MODULE.read_text(encoding="utf-8")
    zones_block = re.search(
        r"export const PLAN_STAMP_ZONES[^{]*\{(?P<body>[^}]*)\}", source
    )

    # Act: read each guideline constant the TypeScript module exports.
    numbers = {
        name: int(match.group(1))
        for name in (
            "PLAN_TASK_GUIDELINE",
            "PLAN_LINE_GUIDELINE",
            "LEGACY_PLAN_TASK_GUIDELINE",
            "LEGACY_PLAN_LINE_GUIDELINE",
        )
        if (match := re.search(rf"export const {name} = ([0-9]+);", source))
    }
    assert zones_block is not None, "plan-gate-document.ts declares no zone table"
    ts_zones = dict(
        re.findall(r'"?([A-Za-z-]+)"?: "([^"]+)"', zones_block.group("body"))
    )

    # Assert
    assert numbers == {
        "PLAN_TASK_GUIDELINE": 20,
        "PLAN_LINE_GUIDELINE": 250,
        "LEGACY_PLAN_TASK_GUIDELINE": 40,
        "LEGACY_PLAN_LINE_GUIDELINE": 400,
    }, f"TypeScript guideline constants differ: {numbers}"
    assert (PLAN_TASK_GUIDELINE, PLAN_LINE_GUIDELINE) == _NEW
    assert (LEGACY_PLAN_TASK_GUIDELINE, LEGACY_PLAN_LINE_GUIDELINE) == _LEGACY
    assert ts_zones == dict(PLAN_STAMP_ZONES), f"zone tables differ: {ts_zones}"


@pytest.mark.parametrize(("path", "stamp", "zone"), _STAMP_ROWS)
def test_plan_file_stamp_reads_each_k4_shape(path: str, stamp: str, zone: str) -> None:
    """Each K4 shape yields its stamp and zone under both separators and prefixes."""

    # Arrange / Act
    result = plan_file_stamp(path)

    # Assert
    assert result == (stamp, zone), f"{path} read as {result}"


@pytest.mark.parametrize("path", [*_REJECTED_NAMES, None])
def test_plan_file_stamp_rejects_other_names(path: str | None) -> None:
    """A name outside the K4 shapes, an empty path, and no path yield no stamp."""

    # Arrange / Act
    result = plan_file_stamp(path)

    # Assert
    assert result is None, f"{path} unexpectedly read as {result}"


@pytest.mark.parametrize(("path", "expected"), _BOUNDARY_ROWS)
def test_guideline_boundary_rows(path: str, expected: tuple[int, int]) -> None:
    """The minute before each zone's entry keeps the legacy pair; the entry does not."""

    # Arrange
    stamped = plan_file_stamp(path)

    # Act
    guideline = plan_size_guideline(stamped, cutoff=_CUTOFF)

    # Assert
    assert guideline == expected, f"{path} applied {guideline}"


@pytest.mark.parametrize(("path", "expected"), _K4_SHAPE_ROWS)
def test_guideline_k4_shape_rows(path: str, expected: tuple[int, int]) -> None:
    """Each K4 shape is compared with the cutoff entry of its own zone."""

    # Arrange
    stamped = plan_file_stamp(path)

    # Act
    guideline = plan_size_guideline(stamped, cutoff=_CUTOFF)

    # Assert
    assert guideline == expected, f"{path} applied {guideline}"


@pytest.mark.parametrize(("path", "expected"), _UTC_ROWS)
def test_utc_stamp_is_not_read_against_new_york_cutoff(
    path: str, expected: tuple[int, int]
) -> None:
    """A UTC stamp after the New York entry but before the instant keeps 40 and 400."""

    # Arrange
    stamped = plan_file_stamp(path)

    # Act
    guideline = plan_size_guideline(stamped, cutoff=_CUTOFF)

    # Assert
    assert guideline == expected, f"{path} applied {guideline}"


def test_guideline_for_a_zone_without_a_cutoff_entry_is_new() -> None:
    """A stamp whose zone has no cutoff entry uses 20 and 250."""

    # Arrange
    stamped = plan_file_stamp("remediation-plan.2026-11-07T14-59.md")

    # Act
    guideline = plan_size_guideline(
        stamped, cutoff={"America/New_York": "2026-11-07T10-00"}
    )

    # Assert
    assert guideline == _NEW, f"zone without an entry applied {guideline}"


def test_guideline_without_path_is_new() -> None:
    """A plan validated without a path uses 20 and 250."""

    # Arrange
    stamped = plan_file_stamp(None)

    # Act
    guideline = plan_size_guideline(stamped, cutoff=_CUTOFF)

    # Assert
    assert guideline == _NEW, f"no-path plan applied {guideline}"


@pytest.mark.parametrize(("plan_path", "expected"), _MESSAGE_ROWS)
def test_g13_message_states_the_guideline_that_applied(
    plan_path: str | None, expected: str
) -> None:
    """The G13 message names the pair that applied to the plan's stamp."""

    # Arrange
    text = _task_plan(41)

    # Act
    findings = _g13_findings(text, plan_path)

    # Assert
    assert findings == [expected], f"unexpected G13 findings: {findings}"


def test_g13_keeps_legacy_result_for_older_stamp() -> None:
    """A 25-task plan passes under its older stamp and fails without a path."""

    # Arrange
    text = _task_plan(25)

    # Act
    stamped_findings = _g13_findings(text, _OLD_PLAN_PATH)
    unstamped_findings = _g13_findings(text, None)

    # Assert
    assert stamped_findings == [], f"older stamp reported: {stamped_findings}"
    assert len(unstamped_findings) == 1, f"no-path findings: {unstamped_findings}"


def test_plan_path_reaches_g13_without_a_context() -> None:
    """The plan path selects the guideline when no repository context is supplied."""

    # Arrange
    text = _task_plan(25)

    # Act
    with_path, _ = validate_plan_text_with_warnings(
        text, context=None, plan_path=_OLD_PLAN_PATH
    )
    without_path, _ = validate_plan_text_with_warnings(text, context=None)

    # Assert
    assert not [e for e in with_path if "plan size" in e], f"G13 reported: {with_path}"
    assert len([e for e in without_path if "plan size" in e]) == 1


def test_typescript_suite_carries_identical_rows() -> None:
    """Every row and the injected pair appear verbatim in the TypeScript suite."""

    # Arrange
    suite = _TS_SUITE.read_text(encoding="utf-8")
    literals: list[str] = [*_CUTOFF.values(), _LEGACY_MESSAGE, _NEW_MESSAGE]
    # Collect each path, stamp, and zone string of the shared row tables.
    for path, stamp, zone in _STAMP_ROWS:
        literals.extend((path, stamp, zone))
    # Collect the path of each guideline row and each rejected non-empty name.
    for path, _ in (*_BOUNDARY_ROWS, *_K4_SHAPE_ROWS, *_UTC_ROWS):
        literals.append(path)
    literals.extend(name for name in _REJECTED_NAMES if name)

    # Act: a JSON string literal is the double-quoted TypeScript spelling.
    missing = [value for value in literals if json.dumps(value) not in suite]

    # Assert
    assert missing == [], f"rows missing from the TypeScript suite: {missing}"
