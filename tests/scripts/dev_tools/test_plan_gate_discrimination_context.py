"""Unit tests for the plan-gate repository context and rules G2 and G3."""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.plan_gate_discrimination import (
    GitPlanGateRepository,
    PlanGateContext,
    build_plan_gate_context,
    evaluate_plan_gates,
)
from scripts.dev_tools.pr_context.models import CommandResult

if TYPE_CHECKING:
    from collections.abc import Sequence

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


class RecordingRunner:
    """In-memory command runner recording every argv it is handed.

    Purpose:
        Let the adapter tests assert the exact `git` argv lists without
        spawning a subprocess or touching the filesystem.

    Usage:
        Construct with a mapping from the first argument after `git` to the
        stdout the runner should return, then read `calls` after the exercise.

    Attributes:
        calls (list[list[str]]): Every argv the runner received, in order.
    """

    def __init__(self, outputs: dict[str, str] | None = None) -> None:
        self.calls: list[list[str]] = []
        self._outputs = outputs or {}

    def run(
        self,
        args: Sequence[str],
        *,
        cwd: Path | None = None,
        allow_error: bool = False,
    ) -> CommandResult:
        """Record the argv and return the configured stdout with exit code 0."""

        recorded = list(args)
        self.calls.append(recorded)
        key = recorded[1] if len(recorded) > 1 else ""
        return CommandResult(stdout=self._outputs.get(key, ""), stderr="", code=0)


class StubGitRepository:
    """Stub tracked-tree seam whose answers are supplied per test.

    Purpose:
        Drive the context-requiring rules from fixed answers so the tests never
        depend on the state of the working tree.

    Attributes:
        tracked_files (set[str]): Paths reported as tracked files.
        tracked_directories (set[str]): Paths reported as tracked directories.
        matches (dict[str, list[str]]): `files_containing` answers by literal.
        texts (dict[str, str]): `read_tracked_text` answers by path.
    """

    def __init__(
        self,
        *,
        tracked_files: set[str] | None = None,
        tracked_directories: set[str] | None = None,
        matches: dict[str, list[str]] | None = None,
        texts: dict[str, str] | None = None,
    ) -> None:
        self.tracked_files = tracked_files or set()
        self.tracked_directories = tracked_directories or set()
        self.matches = matches or {}
        self.texts = texts or {}

    def files_containing(self, literal: str) -> list[str]:
        """Return the configured match list for the literal."""

        return list(self.matches.get(literal, []))

    def is_tracked_file(self, path: str) -> bool:
        """Return whether the path is in the configured tracked-file set."""

        return path in self.tracked_files

    def is_tracked_directory(self, path: str) -> bool:
        """Return whether the path is in the configured tracked-directory set."""

        return path in self.tracked_directories

    def read_tracked_text(self, path: str) -> str:
        """Return the configured text for the path."""

        return self.texts.get(path, "")


def _context(git: StubGitRepository) -> PlanGateContext:
    """Wrap a stub git seam in a context with a stub filesystem."""

    return PlanGateContext(
        workspace_root=Path("/workspace"),
        file_system=_StubFileSystem(),
        git=git,
    )


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
        """Return an empty list; no rule consults the filesystem seam."""

        return []


def test_git_adapter_issues_expected_git_argv() -> None:
    """The adapter issues the exact documented `git` argv for each query."""

    # Arrange
    runner = RecordingRunner(
        {
            "grep": "scripts/dev_tools/foo.py",
            "ls-files": "scripts/dev_tools/foo.py",
            "show": "committed text",
        }
    )
    adapter = GitPlanGateRepository(Path("/workspace"), runner)

    # Act
    matches = adapter.files_containing("pinned items occupy")
    tracked_file = adapter.is_tracked_file("scripts/dev_tools/foo.py")
    tracked_directory = adapter.is_tracked_directory("scripts/dev_tools")
    committed = adapter.read_tracked_text("scripts/dev_tools/foo.py")

    # Assert
    assert runner.calls == [
        ["git", "grep", "-F", "-l", "--", "pinned items occupy"],
        ["git", "ls-files", "--", "scripts/dev_tools/foo.py"],
        ["git", "ls-files", "--", "scripts/dev_tools"],
        ["git", "show", "HEAD:scripts/dev_tools/foo.py"],
    ]
    assert matches == ["scripts/dev_tools/foo.py"]
    assert tracked_file is True
    assert tracked_directory is True
    assert committed == "committed text"


def test_build_plan_gate_context_returns_git_adapter() -> None:
    """The builder wires a working `GitPlanGateRepository` over the runner."""

    # Arrange
    runner = RecordingRunner()

    # Act
    context = build_plan_gate_context(Path("."), runner=runner)

    # Assert
    assert isinstance(context.git, GitPlanGateRepository)
    assert context.workspace_root.is_absolute()
    # An empty `git` result must answer every query negatively.
    assert context.git.files_containing("absent literal") == []
    assert context.git.is_tracked_file("scripts/dev_tools/foo.py") is False
    assert context.git.is_tracked_directory("scripts/dev_tools") is False
    assert context.git.read_tracked_text("scripts/dev_tools/foo.py") == ""


def test_g2_tracked_module_path_is_blocking() -> None:
    """A `--cov` path whose `.py` sibling is tracked is a Blocking finding."""

    # Arrange
    git = StubGitRepository(tracked_files={"scripts/dev_tools/foo.py"})
    text = _plan("poetry run pytest --cov=scripts/dev_tools/foo")

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert len(report.blocking) == 1
    assert report.blocking[0].startswith("[P3-T4] ")
    assert "scripts.dev_tools.foo" in report.blocking[0]
    assert report.warnings == []


def test_g3_unresolvable_path_is_warning() -> None:
    """A `--cov` path resolving to nothing tracked is a Warning, not Blocking."""

    # Arrange
    git = StubGitRepository()
    text = _plan("poetry run pytest --cov=scripts/dev_tools/missing")

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert len(report.warnings) == 1
    assert report.warnings[0].startswith("[P3-T4] ")


def test_tracked_directory_produces_no_finding() -> None:
    """A `--cov` value naming a tracked directory is an accepted form."""

    # Arrange
    git = StubGitRepository(tracked_directories={"scripts/dev_tools"})
    text = _plan("poetry run pytest --cov=scripts/dev_tools")

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


class _RaisingGitRepository(StubGitRepository):
    """Stub whose every tracked-tree lookup raises, modelling an absent `git`.

    Purpose:
        Model the production failure the graceful-degradation clause covers:
        `subprocess.run` raises rather than exiting non-zero when `git` is not
        on `PATH`, so the seam itself raises instead of answering negatively.
    """

    def is_tracked_file(self, path: str) -> bool:
        """Raise instead of answering, as an unavailable `git` seam does."""

        raise RuntimeError("git is unavailable")

    def is_tracked_directory(self, path: str) -> bool:
        """Raise instead of answering, as an unavailable `git` seam does."""

        raise RuntimeError("git is unavailable")


def test_failing_git_adapter_skips_g2_g3_without_raising() -> None:
    """A raising tracked-tree seam degrades G2 and G3 to zero findings."""

    # Arrange
    git = _RaisingGitRepository()
    text = _plan("poetry run pytest --cov=scripts/dev_tools/missing")

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert report.blocking == []
    assert report.warnings == []


def _two_task_plan(first: str, second: str) -> str:
    """Build a two-task plan whose acceptance bullets each hold a command."""

    return "\n".join(
        [
            _PHASE,
            "- [ ] [P3-T4] Do the first thing",
            f"  - Acceptance: `{first}` reports 0 failed.",
            "- [ ] [P3-T5] Do the second thing",
            f"  - Acceptance: `{second}` reports 0 failed.",
            "",
        ]
    )


def test_raising_adapter_reports_only_context_free_findings() -> None:
    """Degradation silences G2 and G3 while G1 and G4 still report."""

    # Arrange
    git = _RaisingGitRepository()
    text = _two_task_plan(
        "poetry run pytest --cov=scripts/dev_tools/foo.py",
        "poetry run pytest --cov scripts/dev_tools/missing",
    )

    # Act
    report = evaluate_plan_gates(text, context=_context(git))

    # Assert
    assert len(report.blocking) == 1
    assert report.blocking[0].startswith("[P3-T4] ")
    assert "names a filesystem path" in report.blocking[0]
    assert len(report.warnings) == 1
    assert report.warnings[0].startswith("[P3-T5] ")
    assert "space-separated" in report.warnings[0]
