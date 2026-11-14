"""
Launcher-outcome tests for run_preflight_qc_fix_loop (issue #1158, spec D12, D28).

A preflight result whose ``launcher_outcome`` is set stops the loop with exit 5
before the missing-executable check and before any Copilot fix prompt; a
result without the field keeps today's Copilot path even when its output quotes
a launcher prefix. The module's other paths (plan task helpers, the fix prompt,
the fix loop's exits, and ``execute_auto_qc_phase``) are covered below. The QC
run and Copilot are replaced through monkeypatch.
"""

from __future__ import annotations

from dataclasses import dataclass
from types import SimpleNamespace
from typing import TYPE_CHECKING, cast
from unittest.mock import Mock

import pytest

from scripts.dev_tools.atomic_executor import cli_task_runtime
from scripts.dev_tools.atomic_executor.cli_preflight import (
    MISSING_EXECUTABLE_PREFIX,
    PreflightQCResult,
)
from scripts.dev_tools.atomic_executor.copilot_throttling import FailureKind
from scripts.dev_tools.atomic_executor.qc_runner_expectations import (
    LauncherOutcome,
)
from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

if TYPE_CHECKING:
    from pathlib import Path

    from _pytest.monkeypatch import MonkeyPatch

    from scripts.dev_tools.atomic_executor.plan_parser import AutoQCPhase, PlanParser
    from scripts.dev_tools.atomic_executor.qc_runner import QCRunner

QUEUE_OUTPUT = "=== PYTEST ===\n\nTEST_EXECUTION_QUEUE_TIMEOUT: lock busy; re-run later"


class CopilotCalledError(Exception):
    """Raised by the fake Copilot to stop the loop once it is reached."""


def _run_loop(
    workspace: Path,
    monkeypatch: MonkeyPatch,
    results: dict[QCToolchain, PreflightQCResult],
    toolchains: list[QCToolchain],
) -> tuple[int, list[str]]:
    """
    Run the fix loop with faked QC results and a recording Copilot.

    Args:
        workspace: In-memory workspace root.
        monkeypatch: Pytest monkeypatch fixture.
        results: The preflight result returned for each toolchain.
        toolchains: Toolchains passed to the loop, in order.

    Returns:
        tuple[int, list[str]]: The loop's exit code and the Copilot task ids.

    Raises:
        CopilotCalledError: When the loop reaches Copilot.
    """
    copilot_calls: list[str] = []

    def fake_capture(
        _workspace: Path, *, expectations: object, toolchain: QCToolchain
    ) -> PreflightQCResult:
        """Return the configured result for the toolchain."""
        return results[toolchain]

    def fake_copilot(**kwargs: object) -> object:
        """Record the call and stop the loop."""
        copilot_calls.append(str(kwargs.get("task_id")))
        raise CopilotCalledError

    def no_log(_log_file: Path, _message: str) -> None:
        """Discard log lines so no file is written."""

    monkeypatch.setattr(cli_task_runtime, "run_preflight_qc_with_capture", fake_capture)
    monkeypatch.setattr(cli_task_runtime, "run_copilot", fake_copilot)
    monkeypatch.setattr(cli_task_runtime, "log_msg", no_log)

    exit_code = cli_task_runtime.run_preflight_qc_fix_loop(
        workspace=workspace,
        log_file=workspace / "log.txt",
        run_id="run",
        preferred_model=None,
        copilot_rate_limiter=Mock(),
        copilot_backoff=Mock(),
        copilot_max_retries=0,
        copilot_output_tail_bytes=100,
        copilot_allow_shell=False,
        copilot_allow_all_paths=False,
        copilot_allow_all_urls=False,
        copilot_trust_workspace=False,
        max_fix_attempts=1,
        expectations=None,
        toolchains=toolchains,
    )
    return exit_code, copilot_calls


def _failure(
    output: str, outcome: LauncherOutcome | None, toolchain: QCToolchain
) -> PreflightQCResult:
    """Build a failed preflight result for a test step."""
    return PreflightQCResult(
        success=False,
        output=output,
        failed_step="pytest" if toolchain is QCToolchain.PYTHON else "test-unit",
        toolchain=toolchain,
        launcher_outcome=outcome,
    )


def test_launcher_outcome_returns_5_without_copilot(
    mem_fs_path: Path, monkeypatch: MonkeyPatch
) -> None:
    """A result with launcher_outcome set returns 5 and never calls Copilot."""
    results = {
        QCToolchain.PYTHON: _failure(
            QUEUE_OUTPUT, LauncherOutcome.QUEUE_TIMEOUT, QCToolchain.PYTHON
        )
    }

    exit_code, calls = _run_loop(
        mem_fs_path, monkeypatch, results, [QCToolchain.PYTHON]
    )

    assert exit_code == 5
    assert calls == []


def test_typescript_outcome_after_python_pass_returns_5(
    mem_fs_path: Path, monkeypatch: MonkeyPatch
) -> None:
    """A passing Python run then a TypeScript launcher outcome returns 5."""
    results = {
        QCToolchain.PYTHON: PreflightQCResult(success=True, output="ok"),
        QCToolchain.TYPESCRIPT: _failure(
            "TEST_EXECUTION_POLICY_BLOCKED: x",
            LauncherOutcome.POLICY_REFUSAL,
            QCToolchain.TYPESCRIPT,
        ),
    }

    exit_code, calls = _run_loop(
        mem_fs_path,
        monkeypatch,
        results,
        [QCToolchain.PYTHON, QCToolchain.TYPESCRIPT],
    )

    assert exit_code == 5
    assert calls == []


def test_launcher_outcome_precedes_missing_executable(
    mem_fs_path: Path, monkeypatch: MonkeyPatch
) -> None:
    """A launcher outcome returns 5 even when the output names a missing tool."""
    output = f"{QUEUE_OUTPUT}\n{MISSING_EXECUTABLE_PREFIX} npm"
    results = {
        QCToolchain.PYTHON: _failure(
            output, LauncherOutcome.QUEUE_TIMEOUT, QCToolchain.PYTHON
        )
    }

    exit_code, _ = _run_loop(mem_fs_path, monkeypatch, results, [QCToolchain.PYTHON])

    assert exit_code == 5


def test_quoted_prefix_without_outcome_reaches_copilot(
    mem_fs_path: Path, monkeypatch: MonkeyPatch
) -> None:
    """Output quoting the prefix on a later line, with no outcome, reaches Copilot."""
    output = (
        "=== PYTEST ===\n\nFAILED tests/test_a.py::x\n"
        "TEST_EXECUTION_POLICY_BLOCKED: quoted"
    )
    results = {QCToolchain.PYTHON: _failure(output, None, QCToolchain.PYTHON)}

    with pytest.raises(CopilotCalledError):
        _run_loop(mem_fs_path, monkeypatch, results, [QCToolchain.PYTHON])


# ---------------------------------------------------------------------------
# Coverage of the module's other paths (P7-T5 holds cli_task_runtime.py to the
# 85% line and 75% branch thresholds). Every collaborator is a fake: no process
# starts, no file is written outside the in-memory workspace, and no real wait.
# ---------------------------------------------------------------------------


@dataclass
class _Task:
    """A plan task with the fields the runtime reads."""

    task_id: str
    phase: int
    task_num: int
    title: str
    checked: bool = False


class _Parser:
    """A plan parser fake that records flipped checkboxes."""

    def __init__(self, tasks: list[_Task]) -> None:
        """Store the tasks the fake parser returns."""
        self.tasks = tasks
        self.flipped: list[str] = []

    def parse(self) -> SimpleNamespace:
        """Return a plan model holding the stored tasks."""
        return SimpleNamespace(tasks=self.tasks)

    def find_task_by_id(self, task_id: str) -> _Task:
        """Return the stored task with the given id."""
        return next(task for task in self.tasks if task.task_id == task_id)

    def flip_checkbox(self, task: _Task) -> None:
        """Record the flipped task id."""
        self.flipped.append(task.task_id)


@dataclass
class _CopilotResult:
    """A Copilot run result with the fields the runtime reads."""

    exit_code: int
    output_tail: str = ""


def _patch_copilot(
    monkeypatch: MonkeyPatch, exit_codes: list[int]
) -> list[dict[str, object]]:
    """
    Replace run_copilot, the failure classifier, and log_msg with fakes.

    Args:
        monkeypatch: Pytest monkeypatch fixture.
        exit_codes: Copilot exit codes returned in order; 7 classifies as a
            throttle and every other non-zero code as a non-throttle failure.

    Returns:
        list[dict[str, object]]: The keyword arguments of each Copilot call.
    """
    calls: list[dict[str, object]] = []
    remaining = list(exit_codes)

    def fake_copilot(**kwargs: object) -> _CopilotResult:
        """Record the call and return the next configured exit code."""
        calls.append(kwargs)
        return _CopilotResult(exit_code=remaining.pop(0))

    def fake_classify(*, exit_code: int, output_tail: str) -> FailureKind:
        """Classify exit 7 as a throttle and any other code as non-throttle."""
        return FailureKind.THROTTLE if exit_code == 7 else FailureKind.NON_THROTTLE

    def no_log(_log_file: Path, _message: str) -> None:
        """Discard log lines so no file is written."""

    monkeypatch.setattr(cli_task_runtime, "run_copilot", fake_copilot)
    monkeypatch.setattr(cli_task_runtime, "classify_copilot_failure", fake_classify)
    monkeypatch.setattr(cli_task_runtime, "log_msg", no_log)
    return calls


def _limiter_and_backoff(delay: float) -> tuple[Mock, Mock]:
    """Return a rate limiter and backoff whose throttle delay is ``delay``."""
    backoff = Mock()
    backoff.on_throttle.return_value = delay
    return Mock(), backoff


class TestPlanTaskHelpers:
    """is_phase0_read_task, phase0_read_tasks, and first_non_read_task."""

    def test_read_tasks_and_first_non_read_task(self) -> None:
        """Phase 0 read tasks are listed in order and skipped by the lookup."""
        tasks = [
            _Task("P1-T1", 1, 1, "Implement"),
            _Task("P0-T2", 0, 2, "Read the spec"),
            _Task("P0-T1", 0, 1, "read the rules", checked=True),
            _Task("P0-T3", 0, 3, "Capture baselines"),
        ]
        parser = cast("PlanParser", _Parser(tasks))

        reads = cli_task_runtime.phase0_read_tasks(parser)
        first = cli_task_runtime.first_non_read_task(parser)

        assert [task.task_id for task in reads] == ["P0-T2"]
        assert first is not None
        assert first.task_id == "P0-T3"

    def test_first_non_read_task_returns_none_when_all_done(self) -> None:
        """No unchecked non-read task gives None."""
        parser = cast(
            "PlanParser",
            _Parser([_Task("P0-T1", 0, 1, "Read x"), _Task("P1-T1", 1, 1, "y", True)]),
        )

        assert cli_task_runtime.first_non_read_task(parser) is None


class TestBuildQcFixPrompt:
    """_build_qc_fix_prompt with and without failure detail."""

    def test_prompt_names_step_code_output_and_artifacts(
        self, mem_fs_path: Path
    ) -> None:
        """A failure yields a prompt naming the step, code, output, and artifacts."""
        phase = SimpleNamespace(
            phase=3, artifact_paths={"pytest": mem_fs_path / "artifacts/pytest.txt"}
        )
        failure = SimpleNamespace(
            failure=SimpleNamespace(step="pytest", returncode=1, output="1 failed")
        )

        prompt = cli_task_runtime.__dict__["_build_qc_fix_prompt"](
            feature_dir=mem_fs_path, phase=phase, failure=failure
        )

        assert "- Step: pytest" in prompt
        assert "- Exit code: 1" in prompt
        assert "1 failed" in prompt
        assert "artifacts/pytest.txt" in prompt

    def test_prompt_without_detail(self, mem_fs_path: Path) -> None:
        """A result without failure detail gives the unknown-detail prompt."""
        prompt = cli_task_runtime.__dict__["_build_qc_fix_prompt"](
            feature_dir=mem_fs_path,
            phase=SimpleNamespace(phase=1, artifact_paths={}),
            failure=SimpleNamespace(failure=None),
        )

        assert prompt == "Auto-QC failure: unknown failure detail."


def _fix_loop(
    workspace: Path,
    monkeypatch: MonkeyPatch,
    results: list[PreflightQCResult],
    *,
    max_fix_attempts: int = 3,
    max_retries: int = 1,
    shutdown: bool = False,
    delay: float = 0.0,
) -> tuple[int, Mock]:
    """Run the fix loop over a sequence of preflight results."""
    remaining = list(results)

    def fake_capture(
        _workspace: Path, *, expectations: object, toolchain: QCToolchain
    ) -> PreflightQCResult:
        """Return the next configured preflight result."""
        return remaining.pop(0)

    def is_shutdown() -> bool:
        """Report the configured shutdown request."""
        return shutdown

    monkeypatch.setattr(cli_task_runtime, "run_preflight_qc_with_capture", fake_capture)
    limiter, backoff = _limiter_and_backoff(delay)
    exit_code = cli_task_runtime.run_preflight_qc_fix_loop(
        workspace=workspace,
        log_file=workspace / "log.txt",
        run_id="run",
        preferred_model=None,
        copilot_rate_limiter=limiter,
        copilot_backoff=backoff,
        copilot_max_retries=max_retries,
        copilot_output_tail_bytes=100,
        copilot_allow_shell=False,
        copilot_allow_all_paths=False,
        copilot_allow_all_urls=False,
        copilot_trust_workspace=False,
        max_fix_attempts=max_fix_attempts,
        expectations=None,
        toolchains=[QCToolchain.PYTHON],
        shutdown_requested=is_shutdown,
    )
    return exit_code, limiter


_FAILED = PreflightQCResult(success=False, output="ruff failed", failed_step="ruff")
_PASSED = PreflightQCResult(success=True, output="ok")


class TestPreflightFixLoopPaths:
    """The fix loop's exits other than the launcher outcome."""

    def test_shutdown_returns_130(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch
    ) -> None:
        """A shutdown request returns 130 before any QC run."""
        _patch_copilot(monkeypatch, [])

        exit_code, _ = _fix_loop(mem_fs_path, monkeypatch, [], shutdown=True)

        assert exit_code == 130

    def test_pass_returns_0(self, mem_fs_path: Path, monkeypatch: MonkeyPatch) -> None:
        """A passing preflight returns 0 without Copilot."""
        calls = _patch_copilot(monkeypatch, [])

        exit_code, _ = _fix_loop(mem_fs_path, monkeypatch, [_PASSED])

        assert exit_code == 0
        assert calls == []

    def test_missing_executable_returns_6(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch
    ) -> None:
        """A missing executable without a launcher outcome returns 6."""
        _patch_copilot(monkeypatch, [])
        missing = PreflightQCResult(
            success=False,
            output=f"{MISSING_EXECUTABLE_PREFIX} pwsh",
            failed_step="pytest",
        )

        exit_code, _ = _fix_loop(mem_fs_path, monkeypatch, [missing])

        assert exit_code == 6

    def test_copilot_fix_then_pass_returns_0(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch
    ) -> None:
        """A throttle, a successful fix, and a passing re-run return 0."""
        calls = _patch_copilot(monkeypatch, [7, 0])

        exit_code, limiter = _fix_loop(
            mem_fs_path, monkeypatch, [_FAILED, _PASSED], delay=0.5
        )

        assert exit_code == 0
        assert len(calls) == 2
        limiter.sleeper.sleep.assert_called_once_with(0.5)

    @pytest.mark.parametrize(
        ("exit_codes", "max_retries"),
        [([9], 1), ([7], 0), ([7], -1)],
        ids=["non-throttle", "retries-exhausted", "negative-retries"],
    )
    def test_copilot_failure_returns_6(
        self,
        mem_fs_path: Path,
        monkeypatch: MonkeyPatch,
        exit_codes: list[int],
        max_retries: int,
    ) -> None:
        """A non-throttle failure or exhausted retries return 6."""
        _patch_copilot(monkeypatch, exit_codes)

        exit_code, _ = _fix_loop(
            mem_fs_path, monkeypatch, [_FAILED], max_retries=max_retries
        )

        assert exit_code == 6

    def test_attempt_limit_returns_6(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch
    ) -> None:
        """A failure after the last allowed attempt returns 6."""
        _patch_copilot(monkeypatch, [0])

        exit_code, _ = _fix_loop(
            mem_fs_path, monkeypatch, [_FAILED, _FAILED], max_fix_attempts=1
        )

        assert exit_code == 6


def _auto_qc(
    workspace: Path,
    monkeypatch: MonkeyPatch,
    run_results: list[object],
    *,
    max_fix_attempts: int = 3,
    max_retries: int = 1,
    print_prompt: bool = False,
    delay: float = 0.0,
) -> tuple[int, _Parser, Mock]:
    """Run execute_auto_qc_phase over a sequence of loop results or errors."""
    remaining = list(run_results)

    def run_full_loop_with_artifacts(**_kwargs: object) -> object:
        """Return or raise the next configured loop result."""
        result = remaining.pop(0)
        # A configured exception stands for the loop method's RuntimeError.
        if isinstance(result, Exception):
            raise result
        return result

    qc_runner = SimpleNamespace(
        run_full_loop_with_artifacts=run_full_loop_with_artifacts
    )
    parser = _Parser(
        [_Task("P2-T1", 2, 1, "QC", checked=True), _Task("P2-T2", 2, 2, "QC")]
    )
    phase = SimpleNamespace(
        phase=2,
        task_ids=["P2-T1", "P2-T2"],
        artifact_paths={"pytest": workspace / "artifacts/pytest.txt"},
        toolchain=QCToolchain.PYTHON,
    )
    limiter, backoff = _limiter_and_backoff(delay)
    exit_code = cli_task_runtime.execute_auto_qc_phase(
        workspace=workspace,
        phase=cast("AutoQCPhase", phase),
        parser=cast("PlanParser", parser),
        qc_runner=cast("QCRunner", qc_runner),
        log_file=workspace / "log.txt",
        feature_dir=workspace,
        preferred_model=None,
        run_id="run",
        copilot_rate_limiter=limiter,
        copilot_backoff=backoff,
        copilot_max_retries=max_retries,
        copilot_output_tail_bytes=100,
        copilot_allow_shell=False,
        copilot_allow_all_paths=False,
        copilot_allow_all_urls=False,
        copilot_trust_workspace=False,
        max_fix_attempts=max_fix_attempts,
        print_prompt=print_prompt,
    )
    return exit_code, parser, limiter


_LOOP_PASSED = SimpleNamespace(success=True, failure=None)
_LOOP_NO_DETAIL = SimpleNamespace(success=False, failure=None)
_LOOP_FAILED = SimpleNamespace(
    success=False,
    failure=SimpleNamespace(step="ruff", returncode=1, output="E501"),
)


class TestExecuteAutoQcPhase:
    """execute_auto_qc_phase exits."""

    def test_print_prompt_returns_0_without_running(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch
    ) -> None:
        """Prompt printing generates no prompt and runs no QC."""
        _patch_copilot(monkeypatch, [])

        exit_code, _, _ = _auto_qc(mem_fs_path, monkeypatch, [], print_prompt=True)

        assert exit_code == 0

    def test_pass_flips_unchecked_tasks(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch
    ) -> None:
        """A passing loop checks off only the unchecked phase tasks."""
        _patch_copilot(monkeypatch, [])

        exit_code, parser, _ = _auto_qc(mem_fs_path, monkeypatch, [_LOOP_PASSED])

        assert exit_code == 0
        assert parser.flipped == ["P2-T2"]

    @pytest.mark.parametrize(
        "loop_result",
        [RuntimeError("TEST_EXECUTION_QUEUE_TIMEOUT: busy"), _LOOP_NO_DETAIL],
        ids=["launcher-outcome", "no-detail"],
    )
    def test_loop_error_returns_5(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch, loop_result: object
    ) -> None:
        """A RuntimeError (a launcher outcome) or a detail-less failure returns 5."""
        calls = _patch_copilot(monkeypatch, [])

        exit_code, _, _ = _auto_qc(mem_fs_path, monkeypatch, [loop_result])

        assert exit_code == 5
        assert calls == []

    def test_fix_then_pass_returns_0(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch
    ) -> None:
        """A throttle, a successful fix, and a passing re-run return 0."""
        calls = _patch_copilot(monkeypatch, [7, 0])

        exit_code, _, limiter = _auto_qc(
            mem_fs_path, monkeypatch, [_LOOP_FAILED, _LOOP_PASSED], delay=0.25
        )

        assert exit_code == 0
        assert calls[1]["resume_session"] is True
        limiter.sleeper.sleep.assert_called_once_with(0.25)

    @pytest.mark.parametrize(
        ("exit_codes", "max_retries"),
        [([9], 1), ([7], 0), ([7], -1)],
        ids=["non-throttle", "retries-exhausted", "negative-retries"],
    )
    def test_copilot_failure_returns_5(
        self,
        mem_fs_path: Path,
        monkeypatch: MonkeyPatch,
        exit_codes: list[int],
        max_retries: int,
    ) -> None:
        """A non-throttle failure or exhausted retries return 5."""
        _patch_copilot(monkeypatch, exit_codes)

        exit_code, _, _ = _auto_qc(
            mem_fs_path, monkeypatch, [_LOOP_FAILED], max_retries=max_retries
        )

        assert exit_code == 5

    def test_attempt_limit_returns_5(
        self, mem_fs_path: Path, monkeypatch: MonkeyPatch
    ) -> None:
        """A failure after the last allowed attempt returns 5."""
        _patch_copilot(monkeypatch, [0])

        exit_code, _, _ = _auto_qc(
            mem_fs_path, monkeypatch, [_LOOP_FAILED], max_fix_attempts=1
        )

        assert exit_code == 5
