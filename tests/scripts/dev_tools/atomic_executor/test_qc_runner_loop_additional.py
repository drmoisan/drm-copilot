"""Additional unit tests for `scripts.dev_tools.atomic_executor.qc_runner`.

These tests focus on loop behavior.

Purpose:
    Increase coverage for the QC toolchain loop orchestration without executing
    external processes or writing to disk.

Design:
    These tests patch the runner's internal helpers (`_diff_signature` and
    `_run_and_record`) so we can deterministically exercise retry/failure/success
    branches.
"""

from __future__ import annotations

import subprocess
from pathlib import Path

import pytest  # noqa: TCH002 - pytest required at runtime for fixtures

from scripts.dev_tools.atomic_executor.qc_runner import (
    QCLoopFailure,
    QCLoopResult,
    QCRunner,
    QCToolchain,
    QCToolResult,
)


def _completed_process(stdout: str) -> subprocess.CompletedProcess[str]:
    """Create a CompletedProcess with provided stdout and success return code."""
    return subprocess.CompletedProcess(
        args=["git"], returncode=0, stdout=stdout, stderr=""
    )


def test_run_full_loop_retries_when_black_changes_then_fails_lint(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """The loop should restart on formatting changes and fail fast on lint errors."""
    runner = QCRunner(Path("/workspace"))

    artifact_paths = {
        "black": Path("/workspace/artifacts/black.txt"),
        "ruff": Path("/workspace/artifacts/ruff.txt"),
        "pyright": Path("/workspace/artifacts/pyright.txt"),
        "pytest": Path("/workspace/artifacts/pytest.txt"),
    }

    # Simulate two loop iterations.
    # - Loop 1: before_black != after_black triggers a retry (continue)
    # - Loop 2: before_black == after_black allows lint to run and fail
    signatures = iter(
        [
            (("a.py", "1", "0"),),
            (("a.py", "2", "0"),),
            (("a.py", "2", "0"),),
            (("a.py", "2", "0"),),
        ]
    )

    def fake_diff_signature(
        *, exclude_paths: object | None = None
    ) -> tuple[tuple[str, str, str], ...]:
        _ = exclude_paths
        return next(signatures)

    # Returncode sequence per step:
    # - Loop 1: black(0) only
    # - Loop 2: black(0), ruff(1)
    results = iter(
        [
            QCToolResult(step="black", returncode=0, output="fmt ok"),
            QCToolResult(step="black", returncode=0, output="fmt ok"),
            QCToolResult(step="ruff", returncode=1, output="lint failed"),
        ]
    )

    def fake_run_and_record(
        *, argv: list[str], output_path: Path, env: dict[str, str] | None = None
    ) -> QCToolResult:
        _ = argv
        _ = output_path
        _ = env
        return next(results)

    monkeypatch.setattr(runner, "_diff_signature", fake_diff_signature)
    monkeypatch.setattr(runner, "_run_and_record", fake_run_and_record)

    result = runner.run_full_loop_with_artifacts(
        artifact_paths=artifact_paths,
        max_loops=10,
        toolchain=QCToolchain.PYTHON,
    )

    assert isinstance(result, QCLoopResult)
    assert result.success is False
    assert isinstance(result.failure, QCLoopFailure)
    assert result.failure.step == "ruff"
    assert result.loop_count == 2


def test_run_full_loop_returns_success_when_all_steps_pass(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """A clean run should return success=True and loop_count=1."""
    runner = QCRunner(Path("/workspace"))

    artifact_paths = {
        "black": Path("/workspace/artifacts/black.txt"),
        "ruff": Path("/workspace/artifacts/ruff.txt"),
        "pyright": Path("/workspace/artifacts/pyright.txt"),
        "pytest": Path("/workspace/artifacts/pytest.txt"),
    }

    def fake_diff_signature(
        *, exclude_paths: object | None = None
    ) -> tuple[tuple[str, str, str], ...]:
        _ = exclude_paths
        return (("a.py", "0", "0"),)

    results = iter(
        [
            QCToolResult(step="black", returncode=0, output="fmt"),
            QCToolResult(step="ruff", returncode=0, output="lint"),
            QCToolResult(step="pyright", returncode=0, output="type"),
            QCToolResult(step="pytest", returncode=0, output="tests"),
        ]
    )

    def fake_run_and_record(
        *, argv: list[str], output_path: Path, env: dict[str, str] | None = None
    ) -> QCToolResult:
        _ = argv
        _ = output_path
        _ = env
        return next(results)

    monkeypatch.setattr(runner, "_diff_signature", fake_diff_signature)
    monkeypatch.setattr(runner, "_run_and_record", fake_run_and_record)

    result = runner.run_full_loop_with_artifacts(
        artifact_paths=artifact_paths,
        max_loops=10,
        toolchain=QCToolchain.PYTHON,
    )

    assert result.success is True
    assert result.failure is None
    assert result.loop_count == 1


def test_run_full_loop_raises_when_max_loops_exceeded(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """If Black keeps changing files, max_loops should bound the retry loop."""
    runner = QCRunner(Path("/workspace"))

    artifact_paths = {
        "black": Path("/workspace/artifacts/black.txt"),
        "ruff": Path("/workspace/artifacts/ruff.txt"),
        "pyright": Path("/workspace/artifacts/pyright.txt"),
        "pytest": Path("/workspace/artifacts/pytest.txt"),
    }

    # Force a retry by returning different signatures for before/after.
    signatures = iter(
        [
            (("a.py", "1", "0"),),
            (("a.py", "2", "0"),),
        ]
    )

    def fake_diff_signature(
        *, exclude_paths: object | None = None
    ) -> tuple[tuple[str, str, str], ...]:
        _ = exclude_paths
        return next(signatures)

    def fake_run_and_record(
        *, argv: list[str], output_path: Path, env: dict[str, str] | None = None
    ) -> QCToolResult:
        _ = argv
        _ = output_path
        _ = env
        return QCToolResult(step="black", returncode=0, output="fmt")

    monkeypatch.setattr(runner, "_diff_signature", fake_diff_signature)
    monkeypatch.setattr(runner, "_run_and_record", fake_run_and_record)

    with pytest.raises(RuntimeError, match="exceeded maximum iterations"):
        runner.run_full_loop_with_artifacts(
            artifact_paths=artifact_paths,
            max_loops=1,
            toolchain=QCToolchain.PYTHON,
        )


def test_changed_files_parses_git_porcelain_output(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """changed_files should return just the file path column from git status."""
    runner = QCRunner(Path("/workspace"))

    def fake_run(*args: object, **kwargs: object) -> subprocess.CompletedProcess[str]:
        _ = args
        _ = kwargs
        return _completed_process(" M scripts/x.py\n?? tests/y.py\n")

    monkeypatch.setattr(runner, "_run", fake_run)

    assert runner.changed_files() == ["scripts/x.py", "tests/y.py"]


def test_git_has_changes_ignores_excluded_paths(
    monkeypatch: pytest.MonkeyPatch,
) -> None:
    """_git_has_changes should ignore changes when they are all excluded."""
    runner = QCRunner(Path("/workspace"))

    def fake_run(*args: object, **kwargs: object) -> subprocess.CompletedProcess[str]:
        _ = args
        _ = kwargs
        return _completed_process(" M artifacts/black.txt\n")

    monkeypatch.setattr(runner, "_run", fake_run)

    assert (
        runner._git_has_changes(  # pyright: ignore[reportPrivateUsage]
            exclude_paths=[Path("/workspace/artifacts/black.txt")]
        )
        is False
    )

    def fake_run_with_other_change(
        *args: object, **kwargs: object
    ) -> subprocess.CompletedProcess[str]:
        _ = args
        _ = kwargs
        return _completed_process(" M artifacts/black.txt\n M src/other.py\n")

    monkeypatch.setattr(runner, "_run", fake_run_with_other_change)

    assert (
        runner._git_has_changes(  # pyright: ignore[reportPrivateUsage]
            exclude_paths=[Path("/workspace/artifacts/black.txt")]
        )
        is True
    )
