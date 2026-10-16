"""Unit, dispatcher, CLI, and parity tests for the G10 plan-gate rule (issue #932).

G10 reports a SCRATCH definition that is not namespaced by issue number. The
fixtures below are copied from the `spec.md` detection contract of the issue
#932 feature folder (accepted, rejected, and non-definition examples, and the
Error Message Contract) and are duplicated in
`extensions/drm-copilot/test/lib/validate/plan-gate-scratch.test.ts`, so a
divergence in either runtime fails on both sides.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

import scripts.dev_tools.validate_orchestration_artifacts as validator
from scripts.dev_tools import plan_gate_commands
from scripts.dev_tools.plan_gate_discrimination import (
    PlanGateContext,
    PlanGateReport,
    evaluate_plan_gates,
)
from scripts.dev_tools.plan_gate_scratch import (
    BLOCKING_CHANNEL,
    FENCE_RE,
    G10_SEVERITY,
    WARNING_CHANNEL,
    bare_scratch_definitions,
    evaluate_scratch_gate,
)
from tests.scripts.dev_tools.validate_orchestration_artifacts_test_support import (
    build_read_text_stub,
)

if TYPE_CHECKING:
    from pytest import CaptureFixture, MonkeyPatch

_REPO_ROOT = Path(__file__).resolve().parents[3]
_TYPESCRIPT_MODULE = (
    _REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "src"
    / "lib"
    / "validate"
    / "plan-gate-scratch.ts"
)
_G10_SEVERITY_TS_RE = re.compile(r'G10_SEVERITY\s*:\s*string\s*=\s*"([^"]+)"')

_ACCEPTED_FORMS = (
    "- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`.",
    "- `SCRATCH` means `<session scratchpad>/issue-900/`.",
    "- `SCRATCH` = `<session scratchpad>/issue-932-2026-10-15T19-52/`.",
)

_REJECTED_FORMS = (
    "- SCRATCH means the executor's session scratchpad directory, outside the "
    "repository.",
    "SCRATCH is the session scratchpad outside the repository.",
    "- `SCRATCH` = the executor session scratchpad directory",
    "- `SCRATCH` = the `889/` subdirectory of the session scratchpad",
    "**SCRATCH:** `SCRATCH` abbreviates the absolute directory "
    "`<executing worktree root>/SCRATCH`",
    "- SCRATCH := <session scratchpad>",
    "- SCRATCH: the session scratchpad directory",
    "- `SCRATCH` denotes the session scratchpad.",
    "- SCRATCH refers to the session scratchpad.",
    "- SCRATCH stands for the session scratchpad.",
    "- SCRATCH is an alias for the session scratchpad.",
)

_NON_DEFINITIONS = (
    "Write the report to SCRATCH/932/cov.txt.",
    "SCRATCH is never committed.",
    "Redacted path: <SCRATCH>/x and <SCRATCHPAD>/derive-worklists.ps1",
    "`SCRATCHPAD` = the session scratchpad root",
    'echo "$SCRATCH"',
    "```text\nSCRATCH is the session scratchpad outside the repository.\n```",
)

_WRAPPED_FIXTURE = "\n".join(
    [
        "Unrelated introductory line.",
        "- SCRATCH means the session scratchpad and is never",
        "  committed to the repository.",
    ]
)

_DEFINITION_LINE = "- SCRATCH means the session scratchpad."
_STOP_FIXTURES = (
    pytest.param(
        [_DEFINITION_LINE, "  ```text", "  fenced content line", "  ```"],
        id="indented-fence",
    ),
    pytest.param([_DEFINITION_LINE, "## Heading"], id="column-0-heading"),
    pytest.param(
        [_DEFINITION_LINE, "- [ ] [P1-T1] Do the thing"], id="column-0-task-line"
    ),
)
_ABSORB_FIXTURES = (
    pytest.param(
        _DEFINITION_LINE + "\n  ## Indented heading",
        (1, "- SCRATCH means the session scratchpad. ## Indented heading"),
        id="indented-heading",
    ),
    pytest.param(
        _DEFINITION_LINE + "\n  - [ ] [P1-T1] Do the thing",
        (1, "- SCRATCH means the session scratchpad. - [ ] [P1-T1] Do the thing"),
        id="indented-task-line",
    ),
)
_SEPARATOR_FIXTURES = (
    pytest.param(
        "intro\fSCRATCH is the session scratchpad.",
        (1, "intro SCRATCH is the session scratchpad."),
        id="form-feed",
    ),
    pytest.param(
        "intro\u2028SCRATCH is the session scratchpad.",
        (1, "intro SCRATCH is the session scratchpad."),
        id="line-separator",
    ),
)

_APOSTROPHE_FIXTURE = (
    "- SCRATCH means the executor's session scratchpad directory, outside the "
    "repository."
)
_APOSTROPHE_MESSAGE = (
    "Line 1: SCRATCH definition `- SCRATCH means the executor's session "
    "scratchpad directory, outside the repository.` is not namespaced by issue "
    "number; define SCRATCH as `<session scratchpad>/issue-<issue-num>/`."
)
_TAB_FIXTURE = "- `SCRATCH`\t=\tthe executor session scratchpad directory"
_TAB_MESSAGE = (
    "Line 1: SCRATCH definition `- `SCRATCH` = the executor session scratchpad "
    "directory` is not namespaced by issue number; define SCRATCH as "
    "`<session scratchpad>/issue-<issue-num>/`."
)

_BARE_LINE = "SCRATCH is the session scratchpad outside the repository."
_BARE_MESSAGE = (
    "Line 1: SCRATCH definition `SCRATCH is the session scratchpad outside the "
    "repository.` is not namespaced by issue number; define SCRATCH as "
    "`<session scratchpad>/issue-<issue-num>/`."
)
_NAMESPACED_LINE = "- `SCRATCH` resolves to `<session scratchpad>/issue-<issue-num>/`."


def _plan_with_first_line(first_line: str) -> str:
    """Build a structurally valid plan whose first line is the given line."""

    return "\n".join(
        [first_line, "### Phase 1 — Work", "- [ ] [P1-T1] Do the thing", ""]
    )


class _StubGitRepository:
    """Tracked-tree seam that answers negatively; G10 never consults it."""

    def files_containing(self, literal: str) -> list[str]:
        """Return no matches."""

        return []

    def is_tracked_file(self, path: str) -> bool:
        """Return False."""

        return False

    def is_tracked_directory(self, path: str) -> bool:
        """Return False."""

        return False

    def read_tracked_text(self, path: str) -> str:
        """Return an empty string."""

        return ""


class _StubFileSystem:
    """Read-only filesystem stub that answers negatively and reads nothing."""

    def is_file(self, path: Path) -> bool:
        """Return False."""

        return False

    def is_dir(self, path: Path) -> bool:
        """Return False."""

        return False

    def read_text(self, path: Path) -> str:
        """Return an empty string."""

        return ""

    def read_bytes(self, path: Path) -> bytes:
        """Return empty bytes."""

        return b""

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        """Return no matches."""

        return []


def _stub_context() -> PlanGateContext:
    """Return a context whose seams answer negatively and perform no I/O."""

    return PlanGateContext(
        workspace_root=Path("/workspace"),
        file_system=_StubFileSystem(),
        git=_StubGitRepository(),
    )


def test_g10_severity_is_blocking() -> None:
    """G10 ships on the Blocking channel declared by the module."""

    # Arrange / Act / Assert
    assert BLOCKING_CHANNEL == "blocking"
    assert G10_SEVERITY == BLOCKING_CHANNEL


@pytest.mark.parametrize("line", _ACCEPTED_FORMS)
def test_bare_scratch_definitions_accepts_namespaced_forms(line: str) -> None:
    """An issue-namespaced definition produces no finding."""

    # Arrange
    text = line

    # Act
    findings = bare_scratch_definitions(text)

    # Assert
    assert findings == [], f"accepted form flagged: {line}"


@pytest.mark.parametrize("line", _REJECTED_FORMS)
def test_bare_scratch_definitions_flags_unnamespaced_forms(line: str) -> None:
    """Each unnamespaced definition produces exactly one finding at line 1."""

    # Arrange
    expected = [(1, " ".join(line.split()))]

    # Act
    findings = bare_scratch_definitions(line)

    # Assert
    assert findings == expected, f"rejected form not flagged once: {line}"


@pytest.mark.parametrize("text", _NON_DEFINITIONS)
def test_bare_scratch_definitions_ignores_non_definitions(text: str) -> None:
    """Usage, property statements, other tokens, and fenced text are ignored."""

    # Arrange / Act
    findings = bare_scratch_definitions(text)

    # Assert
    assert findings == [], f"non-definition flagged: {text}"


def test_wrapped_definition_reports_first_line() -> None:
    """A wrapped definition is one logical line reported at its first line."""

    # Arrange
    expected = [
        (
            2,
            "- SCRATCH means the session scratchpad and is never committed to "
            "the repository.",
        )
    ]

    # Act
    findings = bare_scratch_definitions(_WRAPPED_FIXTURE)

    # Assert
    assert findings == expected


@pytest.mark.parametrize("lines", _STOP_FIXTURES)
def test_logical_line_stops_at_heading_fence_and_task_line(lines: list[str]) -> None:
    """Continuation stops at an indented fence and at any line not beginning with
    whitespace."""

    # Arrange
    text = "\n".join(lines)

    # Act
    findings = bare_scratch_definitions(text)

    # Assert
    assert findings == [(1, _DEFINITION_LINE)]


@pytest.mark.parametrize(("text", "expected"), _ABSORB_FIXTURES)
def test_indented_heading_and_task_line_continue_logical_line(
    text: str, expected: tuple[int, str]
) -> None:
    """An indented heading or task line is absorbed into the logical line."""

    # Arrange
    document = text

    # Act
    findings = bare_scratch_definitions(document)

    # Assert
    assert findings == [expected]


@pytest.mark.parametrize(("text", "expected"), _SEPARATOR_FIXTURES)
def test_bare_scratch_definitions_splits_only_on_cr_lf_terminators(
    text: str, expected: tuple[int, str]
) -> None:
    """A form feed or line separator does not end a physical line."""

    # Arrange
    document = text

    # Act
    findings = bare_scratch_definitions(document)

    # Assert
    assert findings == [expected]


@pytest.mark.parametrize(
    ("fixture", "expected"),
    [
        pytest.param(_APOSTROPHE_FIXTURE, _APOSTROPHE_MESSAGE, id="apostrophe"),
        pytest.param(_TAB_FIXTURE, _TAB_MESSAGE, id="tab"),
    ],
)
def test_g10_message_matches_frozen_string(fixture: str, expected: str) -> None:
    """The finding equals the frozen Error Message Contract string."""

    # Arrange
    report = PlanGateReport()

    # Act
    evaluate_scratch_gate(report, fixture)

    # Assert
    assert report.blocking == [expected]
    assert report.warnings == []


def test_evaluate_scratch_gate_routes_by_severity_argument() -> None:
    """An explicit severity argument selects the channel."""

    # Arrange
    warning_report = PlanGateReport()
    blocking_report = PlanGateReport()

    # Act
    evaluate_scratch_gate(warning_report, _BARE_LINE, severity=WARNING_CHANNEL)
    evaluate_scratch_gate(blocking_report, _BARE_LINE, severity=BLOCKING_CHANNEL)

    # Assert
    assert warning_report.warnings == [_BARE_MESSAGE]
    assert warning_report.blocking == []
    assert blocking_report.blocking == [_BARE_MESSAGE]
    assert blocking_report.warnings == []


def test_evaluate_plan_gates_reports_g10_with_and_without_context() -> None:
    """G10 is context-free: both calls report the same Blocking findings."""

    # Arrange
    text = _plan_with_first_line(_BARE_LINE)

    # Act
    without_context = evaluate_plan_gates(text).blocking
    with_context = evaluate_plan_gates(text, context=_stub_context()).blocking

    # Assert
    assert without_context == [_BARE_MESSAGE]
    assert with_context == [_BARE_MESSAGE]
    assert without_context == with_context


def test_cli_rejects_bare_scratch_definition(
    monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
) -> None:
    """The CLI prints the G10 message and exits 1 for a bare definition."""

    # Arrange
    text = _plan_with_first_line(_BARE_LINE)
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(text))

    # Act
    exit_code = validator.main(["plan", "ignored.md"])
    captured = capsys.readouterr()

    # Assert
    assert exit_code == 1
    assert _BARE_MESSAGE in captured.err.splitlines()


def test_cli_accepts_namespaced_scratch_definition(
    monkeypatch: MonkeyPatch, capsys: CaptureFixture[str]
) -> None:
    """The CLI reports no G10 finding and exits 0 for a namespaced definition."""

    # Arrange
    text = _plan_with_first_line(_NAMESPACED_LINE)
    monkeypatch.setattr(validator, "_read_text", build_read_text_stub(text))

    # Act
    exit_code = validator.main(["plan", "ignored.md"])
    captured = capsys.readouterr()

    # Assert
    assert "SCRATCH definition" not in captured.err
    assert exit_code == 0


def test_g10_severity_constant_matches_typescript() -> None:
    """The TypeScript `G10_SEVERITY` literal equals the Python constant."""

    # Arrange
    source = _TYPESCRIPT_MODULE.read_text(encoding="utf-8")

    # Act
    match = _G10_SEVERITY_TS_RE.search(source)

    # Assert
    assert match is not None, "G10_SEVERITY literal not found in TypeScript"
    assert match.group(1) == G10_SEVERITY


def test_fence_pattern_matches_extractor() -> None:
    """G10 recognises fences with the command extractor's exact pattern."""

    # Arrange
    extractor_pattern: str = vars(plan_gate_commands)["_FENCE_RE"].pattern

    # Act
    scratch_pattern = FENCE_RE.pattern

    # Assert
    assert scratch_pattern == extractor_pattern
