"""Python and TypeScript parity tests for the G11, G12, and G13 rules (issue #964).

The expected rows below are duplicated as double-quoted string literals in
`extensions/drm-copilot/test/lib/validate/plan-gate-document-parity.test.ts`.
Each Python expected string must appear verbatim in that file, so a message
divergence in either runtime fails here and in the Jest suite. One row renders
an apostrophe-bearing value through the message builder, because the
representation builtin would quote such a value differently from the TypeScript
twin.
"""

from __future__ import annotations

import re
from pathlib import Path

import pytest

from scripts.dev_tools import plan_gate_document
from scripts.dev_tools.plan_gate_discrimination import PlanGateReport
from scripts.dev_tools.plan_gate_document import (
    BLOCKING_CHANNEL,
    G11_SEVERITY,
    G12_SEVERITY,
    G13_SEVERITY,
    evaluate_document_gates,
    line_citation_message,
)

_REPO_ROOT = Path(__file__).resolve().parents[3]
_VALIDATE_DIR = _REPO_ROOT / "extensions" / "drm-copilot" / "src" / "lib" / "validate"
_TS_MODULE = _VALIDATE_DIR / "plan-gate-document.ts"
_TS_PARITY_SUITE = (
    _REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "test"
    / "lib"
    / "validate"
    / "plan-gate-document-parity.test.ts"
)
_PY_MODULE = _REPO_ROOT / "scripts" / "dev_tools" / "plan_gate_document.py"


def _task_plan(task_count: int) -> str:
    """Return a plan made only of `task_count` canonical task lines."""

    return "".join(f"- [ ] [P1-T{index}] Step.\n" for index in range(task_count))


_ROWS: tuple[tuple[str, str, tuple[str, ...]], ...] = (
    (
        "g11-prose",
        "See line 26 here.\n",
        (
            "Line 1: line-number citation `line 26` anchors on a position that "
            "moves when main moves; cite the symbol, heading, or test name instead.",
        ),
    ),
    (
        "g11-path",
        "Read `module.py:12` now.\n",
        (
            "Line 1: line-number citation `module.py:12` anchors on a position "
            "that moves when main moves; cite the symbol, heading, or test name "
            "instead.",
        ),
    ),
    (
        "g11-anchor",
        "Open a.ts#L5 now.\n",
        (
            "Line 1: line-number citation `#L5` anchors on a position that moves "
            "when main moves; cite the symbol, heading, or test name instead.",
        ),
    ),
    (
        "g12",
        "Pinned at a1b2c3d4.\n",
        (
            "Line 1: commit-SHA citation `a1b2c3d4` names a commit that goes "
            "stale when main moves; cite the branch, ref name, or merge base "
            "derivation instead.",
        ),
    ),
    (
        "g13",
        _task_plan(41),
        (
            "Line 1: plan size `41 tasks, 41 lines` exceeds the guideline of 40 "
            "tasks or 400 lines and carries no `## Size Justification` section; "
            "split the item or state why the size is necessary.",
        ),
    ),
)

_APOSTROPHE_VALUE = "it's.md:3"
_APOSTROPHE_EXPECTED = (
    "Line 9: line-number citation `it's.md:3` anchors on a position that moves "
    "when main moves; cite the symbol, heading, or test name instead."
)


@pytest.mark.parametrize(
    ("name", "text", "expected"), _ROWS, ids=[row[0] for row in _ROWS]
)
def test_document_gate_messages_match_expected_rows(
    name: str, text: str, expected: tuple[str, ...]
) -> None:
    """Each expected row matches the Python output for its fixture."""

    # Arrange
    report = PlanGateReport()

    # Act
    evaluate_document_gates(report, text)

    # Assert
    assert tuple(report.blocking) == expected, f"row {name}: {report.blocking}"


def test_apostrophe_row_renders_value_verbatim() -> None:
    """The apostrophe row renders the value verbatim between backticks."""

    # Arrange / Act
    message = line_citation_message(9, _APOSTROPHE_VALUE)

    # Assert
    assert (
        message == _APOSTROPHE_EXPECTED
    ), "apostrophe row must render the value verbatim between backticks"


def test_typescript_parity_suite_carries_identical_rows() -> None:
    """Each Python expected string appears verbatim in the TypeScript parity suite."""

    # Arrange
    suite = _TS_PARITY_SUITE.read_text(encoding="utf-8")
    expected_strings = [message for _, _, rows in _ROWS for message in rows]
    expected_strings.append(_APOSTROPHE_EXPECTED)

    # Act
    missing = [message for message in expected_strings if f'"{message}"' not in suite]

    # Assert
    assert missing == [], f"TypeScript parity suite lacks rows: {missing}"


def test_document_gate_severities_are_blocking() -> None:
    """G11, G12, and G13 are Blocking in Python and in the TypeScript module."""

    # Arrange
    module = _TS_MODULE.read_text(encoding="utf-8")

    # Act
    ts_values = {
        name: re.search(rf'{name}\s*:\s*string\s*=\s*"([^"]+)"', module)
        for name in ("G11_SEVERITY", "G12_SEVERITY", "G13_SEVERITY")
    }

    # Assert
    assert G11_SEVERITY == G12_SEVERITY == G13_SEVERITY == BLOCKING_CHANNEL
    for name, match in ts_values.items():
        assert match is not None, f"{name} not declared in the TypeScript module"
        assert match.group(1) == BLOCKING_CHANNEL, f"{name} differs in TypeScript"


def test_document_modules_use_no_repr() -> None:
    """The new modules contain no representation builtin or conversion flag."""

    # Arrange
    python_source = _PY_MODULE.read_text(encoding="utf-8")
    typescript_source = _TS_MODULE.read_text(encoding="utf-8")

    # Act / Assert
    assert plan_gate_document.__file__ is not None
    assert "repr(" not in python_source, "Python module must not call repr("
    assert "!r" not in python_source, "Python module must not use the !r flag"
    assert (
        "pythonRepr(" not in typescript_source
    ), "TypeScript must not call pythonRepr("
