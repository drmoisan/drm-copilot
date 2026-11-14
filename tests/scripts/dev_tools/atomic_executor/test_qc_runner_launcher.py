"""
Launcher-outcome tests for QCRunner (issue #1158, spec D12 and D28).

Covers run_full_loop_with_artifacts, which raises RuntimeError when its test step
exits as a launcher queue timeout or policy refusal, and run_scoped, whose direct
pytest command keeps today's handling of exit 2. Each command is faked, so no
process starts.
"""

from pathlib import Path
from typing import TYPE_CHECKING

import pytest

import scripts.dev_tools.atomic_executor.qc_runner_expectations as qre
from scripts.dev_tools.atomic_executor.qc_runner import QCRunner, QCToolResult
from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch

QUEUE_LINE = "TEST_EXECUTION_QUEUE_TIMEOUT: lock held by pytest (pid 42); retry later"
REFUSAL_LINE = "TEST_EXECUTION_POLICY_BLOCKED: local golden lane is CI-only evidence"
PYTEST_SESSION = (
    "============================= test session starts =============================\n"
    "Interrupted: 1 error during collection\n"
)
PYTHON_STEPS = ("black", "ruff", "pyright", "pytest")
TS_STEPS = ("format", "lint", "typecheck", "test-unit")


def _runner_failing_on(
    mem_fs_path: Path,
    monkeypatch: "MonkeyPatch",
    failing_word: str,
    returncode: int,
    output: str,
) -> "QCRunner":
    """
    Prepare a runner whose loop step fails when its argv holds one word.

    Args:
        mem_fs_path (Path): In-memory workspace root.
        monkeypatch (MonkeyPatch): Pytest monkeypatch fixture.
        failing_word (str): An argv word that selects the failing step.
        returncode (int): Exit code of the failing step.
        output (str): Captured output of the failing step.

    Returns:
        QCRunner: A runner whose diff signature is stable and whose commands
        are faked.
    """

    def fake_run_and_record(*args: object, **kwargs: object) -> QCToolResult:
        """Fail the selected step and report success for every other step."""
        argv = kwargs.get("argv")
        # Only the step whose argv carries the selected word fails.
        if isinstance(argv, list) and failing_word in argv:
            return QCToolResult(step="tool", returncode=returncode, output=output)
        return QCToolResult(step="tool", returncode=0, output="")

    def fake_diff_signature(
        *args: object, **kwargs: object
    ) -> tuple[tuple[str, str, str], ...]:
        """Report an unchanged tree so the loop ends after one pass."""
        return ()

    runner = QCRunner(mem_fs_path)
    monkeypatch.setattr(runner, "_diff_signature", fake_diff_signature)
    monkeypatch.setattr(runner, "_run_and_record", fake_run_and_record)
    return runner


def _which_passthrough(command: str) -> str:
    """Resolve an executable name to itself for argv assertions."""
    return command


def _paths(mem_fs_path: Path, steps: tuple[str, ...]) -> dict[str, Path]:
    """Map each loop step to an in-memory artifact path."""
    return {step: mem_fs_path / f"artifacts/{step}.txt" for step in steps}


class TestFullLoopLauncherOutcomes:
    """run_full_loop_with_artifacts and launcher outcomes of its test step."""

    @pytest.mark.parametrize(
        ("returncode", "output", "prefix"),
        [
            (75, "", "TEST_EXECUTION_QUEUE_TIMEOUT:"),
            (2, REFUSAL_LINE + "\n", "TEST_EXECUTION_POLICY_BLOCKED:"),
        ],
    )
    def test_pytest_step_launcher_outcome_raises(
        self,
        mem_fs_path: Path,
        monkeypatch: "MonkeyPatch",
        returncode: int,
        output: str,
        prefix: str,
    ) -> None:
        """A pytest-step queue timeout or refusal raises RuntimeError by prefix."""
        runner = _runner_failing_on(
            mem_fs_path, monkeypatch, "pytest", returncode, output
        )

        with pytest.raises(RuntimeError) as info:
            runner.run_full_loop_with_artifacts(
                artifact_paths=_paths(mem_fs_path, PYTHON_STEPS), max_loops=1
            )

        assert str(info.value).startswith(prefix)

    def test_test_unit_step_queue_timeout_raises(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """The TypeScript test-unit step classifies the same way."""
        runner = _runner_failing_on(mem_fs_path, monkeypatch, "jest", 1, QUEUE_LINE)

        with pytest.raises(RuntimeError) as info:
            runner.run_full_loop_with_artifacts(
                artifact_paths=_paths(mem_fs_path, TS_STEPS),
                max_loops=1,
                toolchain=QCToolchain.TYPESCRIPT,
            )

        assert str(info.value).startswith("TEST_EXECUTION_QUEUE_TIMEOUT:")

    def test_pytest_exit_2_session_output_returned_unchanged(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A pytest exit 2 with its own session output is returned as a failure."""
        runner = _runner_failing_on(
            mem_fs_path, monkeypatch, "pytest", 2, PYTEST_SESSION
        )

        result = runner.run_full_loop_with_artifacts(
            artifact_paths=_paths(mem_fs_path, PYTHON_STEPS), max_loops=1
        )

        assert result.success is False
        assert result.failure is not None
        assert result.failure.step == "pytest"
        assert result.failure.returncode == 2
        assert result.failure.output == PYTEST_SESSION

    def test_lint_failure_with_prefix_returned_unchanged(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A lint step failure is never classified, even with a prefix line."""
        runner = _runner_failing_on(mem_fs_path, monkeypatch, "ruff", 2, REFUSAL_LINE)

        result = runner.run_full_loop_with_artifacts(
            artifact_paths=_paths(mem_fs_path, PYTHON_STEPS), max_loops=1
        )

        assert result.failure is not None
        assert result.failure.step == "ruff"
        assert result.failure.returncode == 2


class TestScopedRunKeepsDirectPytest:
    """run_scoped passes a direct pytest command whose exit 2 is a test result."""

    def test_scoped_pytest_exit_2_raises_plain_error(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """A scoped pytest exit 2 with expectations unset raises the plain error."""
        argvs: list[list[str]] = []

        def fake_run(
            argv: list[str], **kwargs: object
        ) -> "qre.subprocess.CompletedProcess[str]":
            """Report a changed test file, pass the static steps, fail pytest."""
            argvs.append(list(argv))
            # The direct pytest step fails with exit 2; every other step passes.
            if "pytest" in argv:
                raise qre.subprocess.CalledProcessError(2, argv)
            return qre.subprocess.CompletedProcess(
                args=argv, returncode=0, stdout=" M tests/test_a.py\n", stderr=""
            )

        monkeypatch.setattr(
            "scripts.dev_tools.atomic_executor.qc_runner.shutil.which",
            _which_passthrough,
        )
        monkeypatch.setattr(qre.subprocess, "run", fake_run)

        with pytest.raises(qre.subprocess.CalledProcessError) as info:
            QCRunner(mem_fs_path).run_scoped()

        assert not isinstance(info.value, qre.LauncherRefusedError)
        assert argvs[-1] == ["poetry", "run", "pytest", "tests/test_a.py"]
