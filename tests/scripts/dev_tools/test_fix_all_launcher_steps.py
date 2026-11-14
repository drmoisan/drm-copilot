"""
Launcher test-step tests for the fix_all branches (issue #1158, spec D10, D12, D28).

Covers the serialization of the four test steps through one suite lock, the
direct-call path with no lock, the classification of launcher exits (queue
timeout, policy refusal) ahead of the existing failure handling, and the log
lines that replace ``run_simple_step``. Commands are faked, so no process
starts, and serialization is read from the lock's acquire and release record
rather than from timing.
"""

from __future__ import annotations

import threading
from io import StringIO
from typing import TYPE_CHECKING

import pytest

from scripts.dev_tools import (
    fix_all,
    fix_all_branches,
    fix_all_branches_extra,
    fix_all_runtime,
)
from scripts.dev_tools.atomic_executor.qc_runner_expectations import (
    TEST_SUITE_LAUNCHER_ARGV,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Mapping, Sequence
    from types import TracebackType

LAUNCHER_STEPS = {
    "Shell: test",
    "Pytest: test with coverage",
    "PoshQC: test",
    "Jest: test with coverage",
}
REFUSAL_LINE = (
    "TEST_EXECUTION_POLICY_BLOCKED: local integration lane is CI-only evidence"
)
PYTEST_SESSION = (
    "============================= test session starts =============================\n"
    "Interrupted: 1 error during collection\n"
)
SHELL_USAGE = "usage: shell-qc.sh <format|check|test> [--coverage]\n"


class RecordingLock:
    """
    A suite lock that records each acquire and release around a real lock.

    Purpose:
        Prove that each launcher step runs while the lock is held, without
        reading thread timing: the real lock orders the shared record.

    Attributes:
        held (bool): True between acquire and release.
        record (list[str]): Shared ordered record of lock and run events.
    """

    def __init__(self, record: list[str]) -> None:
        """Wrap a new threading.Lock and share the given record list."""
        self._lock = threading.Lock()
        self.held = False
        self.record = record

    def __enter__(self) -> RecordingLock:
        """Acquire the lock, then mark it held and record the acquire."""
        self._lock.acquire()
        self.held = True
        self.record.append("acquire")
        return self

    def __exit__(
        self,
        exc_type: type[BaseException] | None,
        exc: BaseException | None,
        traceback: TracebackType | None,
    ) -> None:
        """Record the release and clear the held flag before releasing."""
        self.record.append("release")
        self.held = False
        self._lock.release()


class StepRunner:
    """A fake command runner that passes every step except configured ones."""

    def __init__(
        self,
        results: Mapping[str, fix_all.CommandResult],
        on_run: Callable[[str], None] | None = None,
    ) -> None:
        """Store per-step results and an optional per-call hook."""
        self.results = dict(results)
        self.on_run = on_run
        self.calls: list[tuple[str, list[str]]] = []

    def run(self, command: Sequence[str], *, step_name: str) -> fix_all.CommandResult:
        """Record the call and return the configured result, else a pass."""
        self.calls.append((step_name, list(command)))
        if self.on_run is not None:
            self.on_run(step_name)
        return self.results.get(step_name, fix_all.CommandResult(0, ""))


def _run_branch(
    branch: str, results: Mapping[str, fix_all.CommandResult]
) -> tuple[fix_all.BranchResult, StepRunner, list[str]]:
    """
    Call one branch function directly with no suite lock.

    Args:
        branch: One of ``shell``, ``python``, ``powershell``, ``typescript``.
        results: Per-step results for the fake runner.

    Returns:
        tuple: The branch result, the runner, and the recorded statuses.
    """
    runner = StepRunner(results)
    statuses: list[str] = []

    def factory(name: str, logger: fix_all.StepLogger) -> fix_all.CommandRunner:
        """Return the shared fake runner for the branch."""
        return runner

    def record_status(name: str, status: str) -> None:
        """Record each status transition of the branch."""
        statuses.append(status)

    # Route to the branch function under test; each keeps suite_lock=None.
    if branch == "shell":
        result = fix_all_branches.run_shell_branch(
            factory=factory, emit_status_transition=record_status, api=fix_all
        )
    elif branch == "powershell":
        result = fix_all_branches.run_powershell_branch(
            factory=factory, emit_status_transition=record_status, api=fix_all
        )
    elif branch == "python":
        result = fix_all_branches_extra.run_python_branch(
            factory=factory,
            emit_status_transition=record_status,
            include_coverage=True,
            max_black_retries=1,
            max_ruff_retries=1,
            api=fix_all,
        )
    else:
        result = fix_all_branches_extra.run_typescript_branch(
            factory=factory,
            emit_status_transition=record_status,
            include_coverage=True,
            api=fix_all,
        )
    return result, runner, statuses


TEST_STEP_BY_BRANCH = {
    "shell": "Shell: test",
    "python": "Pytest: test with coverage",
    "powershell": "PoshQC: test",
    "typescript": "Jest: test with coverage",
}


def test_test_steps_never_overlap_under_the_suite_lock() -> None:
    """The four test steps run in strict acquire-run-release triples."""
    record: list[str] = []
    lock = RecordingLock(record)
    runners: list[StepRunner] = []

    def on_run(step_name: str) -> None:
        """Record launcher steps and require the lock to be held for each."""
        if step_name in LAUNCHER_STEPS:
            assert lock.held, f"{step_name} ran outside the suite lock"
            record.append(f"run:{step_name}")

    def factory(name: str, logger: fix_all.StepLogger) -> fix_all.CommandRunner:
        """Build one recording runner per branch."""
        runner = StepRunner({}, on_run=on_run)
        runners.append(runner)
        return runner

    exit_code = fix_all_runtime.run_fix_all(
        max_ruff_retries=1,
        include_coverage=True,
        runner_factory=factory,
        logger=fix_all.StepLogger(stream=StringIO()),
        complete_all=True,
        suite_lock=lock,
    )

    assert exit_code == 0
    # Keep only lock events and launcher runs; other branches' static steps can
    # interleave and are not part of the serialization claim.
    events = [
        event
        for event in record
        if event in ("acquire", "release") or event.startswith("run:")
    ]
    triples = [events[index : index + 3] for index in range(0, len(events), 3)]
    assert len(events) == 12
    assert all(triple[0] == "acquire" and triple[2] == "release" for triple in triples)
    assert {triple[1].removeprefix("run:") for triple in triples} == LAUNCHER_STEPS


@pytest.mark.parametrize("branch", sorted(TEST_STEP_BY_BRANCH))
def test_direct_branch_call_without_lock_runs_test_step(branch: str) -> None:
    """A branch called directly with suite_lock=None still runs its test step."""
    result, runner, _ = _run_branch(branch, {})

    step_names = [call[0] for call in runner.calls]
    assert result.success is True
    assert step_names[-1] == TEST_STEP_BY_BRANCH[branch]
    assert runner.calls[-1][1][: len(TEST_SUITE_LAUNCHER_ARGV)] == (
        TEST_SUITE_LAUNCHER_ARGV
    )


@pytest.mark.parametrize("branch", sorted(TEST_STEP_BY_BRANCH))
def test_queue_timeout_fails_branch_at_test_step(branch: str) -> None:
    """Exit 75 fails the branch at its test step and logs the queue prefix."""
    step = TEST_STEP_BY_BRANCH[branch]

    result, _, _ = _run_branch(branch, {step: fix_all.CommandResult(75, "")})

    assert result.success is False
    assert result.failed_step == step
    assert "TEST_EXECUTION_QUEUE_TIMEOUT" in result.output
    assert "re-run" in result.output


@pytest.mark.parametrize("branch", sorted(TEST_STEP_BY_BRANCH))
def test_policy_refusal_fails_branch_at_test_step(branch: str) -> None:
    """Exit 2 with the refusal line first logs the refusal prefix."""
    step = TEST_STEP_BY_BRANCH[branch]

    result, _, _ = _run_branch(branch, {step: fix_all.CommandResult(2, REFUSAL_LINE)})

    assert result.success is False
    assert result.failed_step == step
    assert "TEST_EXECUTION_POLICY_BLOCKED" in result.output


def test_pytest_exit_2_with_session_output_keeps_todays_message() -> None:
    """A pytest exit 2 with session output is a test failure, not a refusal."""
    step = TEST_STEP_BY_BRANCH["python"]

    result, _, _ = _run_branch(
        "python", {step: fix_all.CommandResult(2, PYTEST_SESSION)}
    )

    assert result.success is False
    assert "Pytest failed" in result.output
    assert "TEST_EXECUTION_POLICY_BLOCKED" not in result.output


def test_shell_exit_2_with_usage_output_keeps_todays_message() -> None:
    """A shell-qc usage exit 2 is a test failure, not a refusal."""
    result, _, _ = _run_branch(
        "shell", {"Shell: test": fix_all.CommandResult(2, SHELL_USAGE)}
    )

    assert result.success is False
    assert "Shell tests failed" in result.output
    assert "TEST_EXECUTION_POLICY_BLOCKED" not in result.output


@pytest.mark.parametrize(
    ("branch", "step_line", "success_line"),
    [
        (
            "powershell",
            "Step 4: Running PowerShell tests (Pester, parallel shards)...",
            "[OK] PowerShell tests passed",
        ),
        ("python", "Step 4: Running Pytest with coverage...", "[OK] Pytest passed"),
        ("typescript", "Step 4: Running Jest with coverage...", "[OK] Jest passed"),
    ],
)
def test_test_step_pass_keeps_log_lines(
    branch: str, step_line: str, success_line: str
) -> None:
    """Exit 0 logs the same Step 4 line and success message as run_simple_step."""
    result, _, _ = _run_branch(branch, {})

    assert step_line in result.output
    assert success_line in result.output


@pytest.mark.parametrize(
    ("branch", "failure_line"),
    [
        ("powershell", "[FAIL] PowerShell tests failed."),
        ("python", "[FAIL] Pytest failed."),
        ("typescript", "[FAIL] Jest failed."),
    ],
)
def test_test_step_exit_1_keeps_failure_message(branch: str, failure_line: str) -> None:
    """Exit 1 logs the same failure message with the exit code as before."""
    step = TEST_STEP_BY_BRANCH[branch]

    result, _, _ = _run_branch(branch, {step: fix_all.CommandResult(1, "1 failed")})

    assert result.success is False
    assert failure_line in result.output
    assert "(exit code 1)" in result.output


def test_shell_exit_0_with_skip_marker_reports_skip() -> None:
    """Exit 0 with a skip marker still reports SKIP tests."""
    result, _, statuses = _run_branch(
        "shell",
        {
            "Shell: test": fix_all.CommandResult(
                0, "No shell test directories found; skipping."
            )
        },
    )

    assert result.success is True
    assert statuses[-1] == "SKIP tests"
    assert "Shell tests skipped" in result.output
