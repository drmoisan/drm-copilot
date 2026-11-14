"""
Launcher-outcome tests for run_preflight_qc_fix_loop (issue #1158, spec D12, D28).

A preflight result whose ``launcher_outcome`` is set stops the loop with exit 5
before the missing-executable check and before any Copilot fix prompt; a
result without the field keeps today's Copilot path even when its output quotes
a launcher prefix. The QC run and Copilot are replaced through monkeypatch.
"""

from __future__ import annotations

from typing import TYPE_CHECKING
from unittest.mock import Mock

import pytest

from scripts.dev_tools.atomic_executor import cli_task_runtime
from scripts.dev_tools.atomic_executor.cli_preflight import (
    MISSING_EXECUTABLE_PREFIX,
    PreflightQCResult,
)
from scripts.dev_tools.atomic_executor.qc_runner_expectations import (
    LauncherOutcome,
)
from scripts.dev_tools.atomic_executor.qc_toolchain import QCToolchain

if TYPE_CHECKING:
    from pathlib import Path

    from _pytest.monkeypatch import MonkeyPatch

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
