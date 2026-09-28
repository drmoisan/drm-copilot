"""Unit tests for the G7, G8, G8b, and G9 observability plan-gate rules."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.plan_gate_discrimination import (
    PlanGateContext,
    evaluate_plan_gates,
)
from scripts.dev_tools.plan_gate_observability import (
    G7_SEVERITY,
    G8_SEVERITY,
    G8B_SEVERITY,
    G9_SEVERITY,
    WARNING_CHANNEL,
    WRITE_MODE_REGISTER,
)

# Committed `pyproject.toml` text the stub returns. It reproduces the project's
# real `addopts`, which supplies an LCOV reporter and no terminal reporter, so
# G9's project-value branch is exercised against the value the repository has.
_PROJECT_TEXT = 'addopts = "-ra --cov-report=lcov:artifacts/python/lcov.info"'

# One defective fixture span per write-mode register entry. The three PoshQC
# entries use the two-word form fixed in the plan's standing rules, because the
# extractor's two-word floor drops a bare single-token tool name.
_REGISTER_FIXTURES: dict[str, str] = {
    "black-write": "poetry run black .",
    "ruff-fix": "poetry run ruff check .",
    "prettier-write": "npx prettier --write src",
    "poshqc-format": "run_poshqc_format scripts/powershell",
    "poshqc-analyze-autofix": "run_poshqc_analyze_autofix scripts/powershell",
    "poshqc-suite": "run_poshqc_suite scripts/powershell",
}


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


def _findings(text: str) -> list[str]:
    """Return the union of both severity channels for a context-free run."""

    report = evaluate_plan_gates(text)
    return [*report.blocking, *report.warnings]


class _StubGitRepository:
    """Tracked-tree seam answering negatively except for the project file."""

    def files_containing(self, literal: str) -> list[str]:
        """Return no matches; the literal rules are not exercised here."""

        return []

    def is_tracked_file(self, path: str) -> bool:
        """Return False; the coverage-path rules are not exercised here."""

        return False

    def is_tracked_directory(self, path: str) -> bool:
        """Return False; the coverage-path rules are not exercised here."""

        return False

    def read_tracked_text(self, path: str) -> str:
        """Return the project configuration text, or an empty string."""

        return _PROJECT_TEXT if path == "pyproject.toml" else ""


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


def _stub_context() -> PlanGateContext:
    """Build a context whose seams answer from fixed in-memory values."""

    return PlanGateContext(
        workspace_root=Path("/workspace"),
        file_system=_StubFileSystem(),
        git=_StubGitRepository(),
    )


def _run_with_context(text: str) -> list[str]:
    """Return the union of both channels for a run with the stub context."""

    report = evaluate_plan_gates(text, context=_stub_context())
    return [*report.blocking, *report.warnings]


def test_defective_plan_fixture_produces_g7_and_g8_findings() -> None:
    """The two frozen defective spans each produce exactly one finding."""

    # Arrange
    text = _plan(
        "### Phase 1 — Work",
        "- [ ] [P1-T1] Format the tree, then confirm the extractor file is intact.",
        "  - Acceptance: `poetry run black .` exits 0, and",
        "    `git diff --exit-code -- scripts/dev_tools/plan_gate_commands.py`",
        "    exits 0.",
    )

    # Act
    findings = _findings(text)

    # Assert
    assert len(findings) == 2


def test_g7_reports_write_mode_command_without_observation_marker() -> None:
    """A formatter that rewrites and exits 0 is reported without a marker."""

    # Arrange
    text = _one_task_plan("  - Acceptance: `poetry run black .` exits 0.")

    # Act
    report = evaluate_plan_gates(text)
    findings = [*report.blocking, *report.warnings]

    # Assert
    assert findings == [
        "[P1-T1] write-mode command `poetry run black .` rewrites tracked "
        "source and exits 0 after rewriting; the attributed task text carries "
        "none of its observation markers. Record an observation beyond the "
        "exit code."
    ]
    channel = report.blocking if G7_SEVERITY != WARNING_CHANNEL else report.warnings
    assert channel == findings


def test_g7_exonerates_task_carrying_observation_marker() -> None:
    """A marker anywhere in the attributed window clears the command."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `poetry run black .` exits 0 and its summary line",
        "    reports that every file was left unchanged.",
    )

    # Act
    findings = _findings(text)

    # Assert
    assert findings == []


def test_g7_every_register_entry_is_exercised_by_a_fixture() -> None:
    """Every one of the six register entries fires on a fixture in this file."""

    # Arrange
    registered = {entry.name for entry in WRITE_MODE_REGISTER}

    # Act / Assert: the set equality catches a missing fixture and the per-entry
    # assertion catches a fixture that no longer matches its entry.
    assert set(_REGISTER_FIXTURES) == registered
    assert len(registered) == 6
    for name, span in _REGISTER_FIXTURES.items():
        findings = _findings(_one_task_plan(f"  - Acceptance: `{span}` exits 0."))
        assert len(findings) == 1, name
        assert findings[0].startswith("[P1-T1] write-mode command "), name
        assert f"`{span}`" in findings[0], name


def test_g7_ignores_git_add_and_npm_ci_exclusions() -> None:
    """The two excluded write-mode commands produce no G7 finding."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `git add scripts/dev_tools` exits 0, then",
        "    `npm ci` exits 0.",
    )

    # Act
    findings = _findings(text)

    # Assert
    assert findings == []


def test_g8_reports_bare_git_diff_without_ref_operand() -> None:
    """A bare worktree-against-index diff is reported with the frozen text."""

    # Arrange
    text = _one_task_plan("  - Acceptance: `git diff` produces no output.")

    # Act
    report = evaluate_plan_gates(text)
    findings = [*report.blocking, *report.warnings]

    # Assert
    assert findings == [
        "[P1-T1] git diff span `git diff` carries no ref operand and no "
        "--cached flag; it compares the worktree against the index and passes "
        "vacuously once the change is committed. Anchor the diff to a ref."
    ]
    channel = report.blocking if G8_SEVERITY != WARNING_CHANNEL else report.warnings
    assert channel == findings


def test_g8_reports_pathspec_only_git_diff() -> None:
    """A pathspec without a ref still compares the worktree against the index."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `git diff -- scripts/dev_tools` produces no output."
    )

    # Act
    findings = _findings(text)

    # Assert
    assert len(findings) == 1
    assert findings[0].startswith("[P1-T1] git diff span `git diff -- ")


def test_g8_ignores_git_diff_with_ref_operand() -> None:
    """An anchored diff discriminates after the change is committed."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `git diff main -- scripts/dev_tools` produces no output."
    )

    # Act
    findings = _findings(text)

    # Assert
    assert findings == []


def test_g8_ignores_git_diff_with_cached_flag() -> None:
    """An index-reading diff is not the ambient comparison G8 reports."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `git diff --cached -- scripts/dev_tools` shows the "
        "staged change."
    )

    # Act
    findings = _findings(text)

    # Assert
    assert findings == []


def test_g8_exonerates_task_carrying_a_second_diff_or_status_span() -> None:
    """A status companion in the same window clears an unanchored diff."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `git diff -- scripts/dev_tools` produces no output,",
        "    recorded together with `git status --porcelain -- scripts/dev_tools`.",
    )

    # Act
    findings = _findings(text)

    # Assert
    assert findings == []


def test_g8b_reports_anchored_name_only_diff_without_companion() -> None:
    """A name listing cannot see an untracked path, so it needs a companion."""

    # Arrange
    span = "git diff --name-only main -- scripts/dev_tools"
    text = _one_task_plan(f"  - Acceptance: `{span}` produces no output.")

    # Act
    report = evaluate_plan_gates(text)
    findings = [*report.blocking, *report.warnings]

    # Assert
    assert findings == [
        f"[P1-T1] name-listing diff `{span}` never reports an untracked file, "
        "and the attributed task text carries neither a staging span nor a "
        "porcelain-status span; a path the plan creates is invisible to it. "
        "Add a staging or porcelain-status companion."
    ]
    channel = report.blocking if G8B_SEVERITY != WARNING_CHANNEL else report.warnings
    assert channel == findings


def test_g8b_exonerates_task_carrying_staging_span() -> None:
    """Staging first makes the name listing able to report the new path."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `git add scripts/dev_tools` exits 0, then",
        "    `git diff --name-status main -- scripts/dev_tools` lists the path.",
    )

    # Act
    findings = _findings(text)

    # Assert
    assert findings == []


def test_g8b_exonerates_task_carrying_porcelain_status_span() -> None:
    """A porcelain-status companion reports the untracked path directly."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `git diff --name-only main -- scripts/dev_tools` and",
        "    `git status --porcelain -- scripts/dev_tools` are both recorded.",
    )

    # Act
    findings = _findings(text)

    # Assert
    assert findings == []


def test_g9_reports_coverage_command_without_terminal_reporter() -> None:
    """A coverage command that prints no table is reported with frozen text."""

    # Arrange
    span = "poetry run pytest --cov=scripts.dev_tools.foo"
    text = _one_task_plan(f"  - Acceptance: `{span}` reports the total.")

    # Act
    report = evaluate_plan_gates(text, context=_stub_context())
    findings = [*report.blocking, *report.warnings]

    # Assert
    assert findings == [
        f"[P1-T1] coverage command `{span}` supplies no terminal reporter and "
        "the project addopts supplies none either, so no coverage table is "
        "printed. Add --cov-report=term-missing."
    ]
    channel = report.blocking if G9_SEVERITY != WARNING_CHANNEL else report.warnings
    assert channel == findings


def test_g9_ignores_command_carrying_terminal_reporter() -> None:
    """An explicit terminal reporter prints the table the plan reads."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `poetry run pytest --cov-report=term-missing "
        "--cov=scripts.dev_tools.foo` reports the total."
    )

    # Act
    findings = _run_with_context(text)

    # Assert
    assert findings == []


def test_g9_ignores_command_carrying_fail_under_threshold() -> None:
    """A coverage threshold makes the run fail on its own, so no table is needed."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `poetry run pytest --cov-fail-under=85 "
        "--cov=scripts.dev_tools.foo` exits 0."
    )

    # Act
    findings = _run_with_context(text)

    # Assert
    assert findings == []


def test_g9_message_states_the_terminal_reporter_remedy() -> None:
    """The finding names the remedy and makes no unfalsifiability claim."""

    # Arrange
    text = _one_task_plan(
        "  - Acceptance: `poetry run pytest --cov=scripts.dev_tools.foo` "
        "reports the total."
    )

    # Act
    findings = _run_with_context(text)

    # Assert
    assert len(findings) == 1
    assert "Add --cov-report=term-missing." in findings[0]
    assert "no coverage table is printed" in findings[0]
    assert "unfalsifiable" not in findings[0]
    assert "cannot fail" not in findings[0]
