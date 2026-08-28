"""Boundary and degradation tests for the observability plan-gate rules.

The seventeen rule-behaviour cases live in
`tests/scripts/dev_tools/test_plan_gate_observability.py`. This companion file
carries the eleven boundary cases: G9's two fault injections, the context-free
split, the extraction-floor limitation, the three attribution boundaries, and
the four degenerate inputs. The split exists because the twenty-eight required
cases do not fit in one file under the 500-line limit.
"""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.plan_gate_discrimination import (
    PlanGateContext,
    evaluate_plan_gates,
)
from tests.scripts.dev_tools.test_plan_gate_parity import (
    PARITY_G1,
    PARITY_G2,
    PARITY_G3,
    PARITY_G4,
    PARITY_G5,
    PARITY_G6,
)

# The two context-free blocking strings recorded by [P0-T13] in
# docs/features/active/2026-08-23-plan-acceptance-gates-miss-unobservable-and-
# ambient-state-gates-519/evidence/baseline/
# plan-gate-preexisting-output.2026-08-24T00-00.md. Both are G1 findings; G1 is
# the only Blocking rule that decides without the repository seam.
_EXPECTED_BLOCKING_G1 = (
    "[P1-T1] --cov argument `scripts/dev_tools/foo.py` names a filesystem "
    "path; coverage.py accepts only directories or importable names. "
    "Use --cov=scripts.dev_tools.foo."
)

# The four fixtures whose rule requires the repository seam produce an empty
# blocking channel with no context supplied.
_SEAM_REQUIRING_FIXTURES = (
    ("PARITY_G2", PARITY_G2),
    ("PARITY_G3", PARITY_G3),
    ("PARITY_G5", PARITY_G5),
    ("PARITY_G6", PARITY_G6),
)

_COVERAGE_SPAN = "poetry run pytest --cov=scripts.dev_tools.foo"


def _plan(*lines: str) -> str:
    """Join fixture lines into a plan document."""

    return "\n".join(lines) + "\n"


def _one_task_plan(*acceptance_lines: str) -> str:
    """Build a one-phase, one-task plan around the supplied acceptance lines."""

    return _plan(
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Do the thing",
        *acceptance_lines,
    )


class _RaisingGitRepository:
    """Tracked-tree seam whose every query raises."""

    def files_containing(self, literal: str) -> list[str]:
        """Raise, standing in for a `git` invocation that could not run."""

        raise RuntimeError("git unavailable")

    def is_tracked_file(self, path: str) -> bool:
        """Raise, standing in for a `git` invocation that could not run."""

        raise RuntimeError("git unavailable")

    def is_tracked_directory(self, path: str) -> bool:
        """Raise, standing in for a `git` invocation that could not run."""

        raise RuntimeError("git unavailable")

    def read_tracked_text(self, path: str) -> str:
        """Raise, standing in for a `git` invocation that could not run."""

        raise RuntimeError("git unavailable")


class _NonZeroExitGitRepository:
    """Tracked-tree seam modelling a `git` binary that exits non-zero.

    The production adapter translates a non-zero exit into a negative or empty
    answer rather than an error, so this stub returns the same empty values.
    """

    def files_containing(self, literal: str) -> list[str]:
        """Return no matches, as the adapter does on a non-zero exit."""

        return []

    def is_tracked_file(self, path: str) -> bool:
        """Return False, as the adapter does on a non-zero exit."""

        return False

    def is_tracked_directory(self, path: str) -> bool:
        """Return False, as the adapter does on a non-zero exit."""

        return False

    def read_tracked_text(self, path: str) -> str:
        """Return an empty string, as the adapter does on a non-zero exit."""

        return ""


class _StubFileSystem:
    """Read-only filesystem stub that answers negatively and reads nothing."""

    def is_file(self, path: Path) -> bool:
        """Return False; no rule consults the filesystem seam."""

        return False

    def is_dir(self, path: Path) -> bool:
        """Return False; no rule consults the filesystem seam."""

        return False

    def read_text(self, path: Path) -> str:
        """Return an empty string; no rule consults the filesystem seam."""

        return ""

    def read_bytes(self, path: Path) -> bytes:
        """Return empty bytes; no rule consults the filesystem seam."""

        return b""

    def glob(self, directory: Path, pattern: str) -> list[Path]:
        """Return no matches; no rule consults the filesystem seam."""

        return []


def _context(git: _RaisingGitRepository | _NonZeroExitGitRepository) -> PlanGateContext:
    """Wrap a stub git seam in a context with a stub filesystem."""

    return PlanGateContext(
        workspace_root=Path("/workspace"),
        file_system=_StubFileSystem(),
        git=git,
    )


def test_g9_skipped_when_repository_seam_raises() -> None:
    """A raising seam discards the whole G9 group without propagating."""

    # Arrange
    text = _one_task_plan(f"  - Acceptance: `{_COVERAGE_SPAN}` reports the total.")

    # Act: no exception escapes the entry point, which is itself the assertion.
    report = evaluate_plan_gates(text, context=_context(_RaisingGitRepository()))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_g9_skipped_when_repository_seam_reports_nonzero_exit() -> None:
    """A seam that produced no text cannot support the finding's claim."""

    # Arrange
    text = _one_task_plan(f"  - Acceptance: `{_COVERAGE_SPAN}` reports the total.")

    # Act
    report = evaluate_plan_gates(text, context=_context(_NonZeroExitGitRepository()))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_g9_does_not_run_without_context() -> None:
    """G9 needs the project value, so it produces nothing with no context."""

    # Arrange
    text = _one_task_plan(f"  - Acceptance: `{_COVERAGE_SPAN}` reports the total.")

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_blocking_channel_is_unchanged_without_context() -> None:
    """The context-free blocking channel matches the pre-change reference."""

    # Arrange / Act
    blocking_g1 = evaluate_plan_gates(PARITY_G1).blocking
    blocking_g4 = evaluate_plan_gates(PARITY_G4).blocking

    # Assert: G1 is the only Blocking rule that runs without the seam, and no
    # new rule may leak onto the blocking channel beside it.
    assert blocking_g1 == [_EXPECTED_BLOCKING_G1]
    assert blocking_g4 == []
    for name, fixture in _SEAM_REQUIRING_FIXTURES:
        assert evaluate_plan_gates(fixture).blocking == [], name


def test_single_token_tool_name_span_produces_no_findings() -> None:
    """The two-word extraction floor drops a bare single-token tool name."""

    # Arrange
    text = _one_task_plan("  - Acceptance: `run_poshqc_format` exits 0.")

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_write_mode_command_in_document_preamble_produces_no_findings() -> None:
    """A span before the first task line belongs to no attribution window."""

    # Arrange
    text = _plan(
        "# Plan",
        "",
        "Run `poetry run black .` before starting.",
        "",
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Do the thing",
    )

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_write_mode_command_in_phase_preamble_produces_no_findings() -> None:
    """A span between a phase heading and its first task is dropped."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        "",
        "This phase runs `poetry run black .` at the end.",
        "",
        "- [ ] [P1-T1] Do the thing",
    )

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_write_mode_command_after_heading_produces_no_findings() -> None:
    """A heading between a task line and a span closes the window."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Do the thing",
        "",
        "#### Notes",
        "",
        "Run `poetry run black .` manually.",
    )

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_empty_plan_produces_no_findings() -> None:
    """Empty text carries no command and therefore no finding."""

    # Arrange / Act
    report = evaluate_plan_gates("")

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_plan_without_task_lines_produces_no_findings() -> None:
    """A document with no task line has no attribution window at all."""

    # Arrange
    text = _plan(
        "# Plan",
        "",
        "## Notes",
        "",
        "Run `poetry run black .` and `git diff` when convenient.",
    )

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def test_command_span_without_operand_produces_no_findings() -> None:
    """A span that splits into fewer than two words produces no record."""

    # Arrange
    text = _one_task_plan("  - Acceptance: `black` is on the path.")

    # Act
    report = evaluate_plan_gates(text)

    # Assert
    assert report.blocking == []
    assert report.warnings == []
