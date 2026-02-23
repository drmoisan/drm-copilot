"""
QC toolchain execution for atomic task verification.

Supports both scoped QC (changed files only, fast task gate) and full QC
(entire codebase, phase gate).
"""

from __future__ import annotations

import os
import shutil
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor.qc_runner_expectations import (
    run_jest_with_expectations,
    run_pytest_with_expectations,
)
from scripts.dev_tools.atomic_executor.qc_runner_loop import (
    QCLoopResult,
    QCToolResult,
    diff_signature,
    git_has_changes,
    normalize_excluded_paths,
    run_and_record,
    run_full_loop_with_artifacts,
)
from scripts.dev_tools.atomic_executor.qc_runner_process import QCRunnerProcessMixin
from scripts.dev_tools.atomic_executor.qc_toolchain import (
    TOOLCHAIN_COMMANDS,
    QCToolchain,
)

# Compatibility anchor for tests that monkeypatch qc_runner.shutil.which.
COMPAT_SHUTIL = shutil

if TYPE_CHECKING:
    from collections.abc import Iterable
    from pathlib import Path

    from scripts.dev_tools.atomic_executor.pytest_expectations import (
        ResolvedTestExpectations,
    )


class QCRunner(QCRunnerProcessMixin):
    """
    Execute scoped and full QC toolchains.

    Purpose:
        Runs Python (Black/Ruff/Pyright/Pytest) and TypeScript
        (format/lint/typecheck/Jest) toolchains for scoped or full QC.

    Usage:
        runner = QCRunner(workspace)
        runner.run_scoped()   # After each task
        runner.run_full()     # After each phase

    Flow:
        Scoped QC:
          1. Detect changed Python files via git status
          2. Run Black/Ruff/Pyright on those files only
          3. Run Pytest only on changed test files (fast path)

        Full QC:
          - Python: Black/Ruff/Pyright/Pytest on entire codebase
          - TypeScript: format/lint/typecheck/test:unit on entire codebase

    Invariants:
        - workspace must be a git repository
        - Poetry environment must be active and have required tools

    Side Effects:
        - Calls subprocess commands (git, poetry, black, ruff, pyright, pytest)
        - Raises CalledProcessError if any QC step fails
    """

    # Full toolchain commands for phase gates (Python)
    FULL_FMT = ["poetry", "run", "black", "--check", "."]
    FULL_LINT = ["poetry", "run", "ruff", "check"]
    FULL_TYPE = ["poetry", "run", "pyright"]
    FULL_TEST = [
        "poetry",
        "run",
        "pytest",
        "--color=no",
        "--cov=src/lexile_corpus_tuner",
        "--cov-report=xml",
        "--cov-report=term-missing",
    ]

    # Full toolchain commands for phase gates (TypeScript)
    FULL_TS_FMT = TOOLCHAIN_COMMANDS[QCToolchain.TYPESCRIPT]["format"]
    FULL_TS_LINT = TOOLCHAIN_COMMANDS[QCToolchain.TYPESCRIPT]["lint"]
    FULL_TS_TYPE = TOOLCHAIN_COMMANDS[QCToolchain.TYPESCRIPT]["typecheck"]
    FULL_TS_TEST = TOOLCHAIN_COMMANDS[QCToolchain.TYPESCRIPT]["test-unit"]

    AUTO_QC_STEP_ORDER = ["black", "ruff", "pyright", "pytest"]
    EXECUTOR_LOCK_BYPASS_ENV = "ATOMIC_EXECUTOR_SKIP_LOCK"

    def __init__(self, workspace: Path) -> None:
        """
        Initialize the QC runner with workspace path.

        Args:
            workspace (Path): Repository root directory.
        """
        self.workspace = workspace

    def run_scoped(
        self, *, expectations: ResolvedTestExpectations | None = None
    ) -> None:
        """
        Run toolchain on changed files only (task gate).

        Purpose:
            Fast QC verification after a single task completes.

        Args:
            expectations (ResolvedTestExpectations | None): Optional expected
                pytest failures derived from the active plan.

        Raises:
            CalledProcessError: If any QC command fails.

        Side Effects:
            Runs git status, black, ruff, pyright, pytest on changed files.
        """
        files = self.changed_files()
        py_files = self._filter_python_files(files)
        test_files = self._filter_test_files(files)
        ts_files = self._filter_ts_files(files)
        ts_test_files = self._filter_ts_test_files(files)

        # No-op if no relevant changes
        if not (py_files or test_files or ts_files or ts_test_files):
            return

        # Run formatter, linter, type checker on changed Python files
        if py_files:
            self._run(["poetry", "run", "black", "--check", *py_files])
            self._run(["poetry", "run", "ruff", "check", *py_files])
            self._run(["poetry", "run", "pyright", *py_files])

        # Run tests only for changed test files (fast path)
        if test_files:
            self._run_pytest_scoped_with_expectations(
                test_files=test_files, expectations=expectations
            )

        # Run Jest unit tests for changed TypeScript test files
        if ts_test_files:
            self._run_jest_scoped_with_expectations(
                test_files=ts_test_files, expectations=expectations
            )

    def run_full(
        self,
        *,
        expectations: ResolvedTestExpectations | None = None,
        toolchain: QCToolchain = QCToolchain.PYTHON,
    ) -> None:
        """
        Run full toolchain on entire codebase (phase gate).

        Purpose:
            Comprehensive QC verification after a phase completes.

        Args:
            expectations (ResolvedTestExpectations | None): Optional expected
                test failures derived from the active plan.
            toolchain (QCToolchain): Toolchain to run (Python or TypeScript).

        Raises:
            CalledProcessError: If any QC command fails.

        Side Effects:
            Runs black, ruff, pyright, pytest with full coverage.
        """
        if toolchain is QCToolchain.PYTHON:
            self._run(self.FULL_FMT)
            self._run(self.FULL_LINT)
            self._run(self.FULL_TYPE)
            self._run_pytest_with_expectations(expectations)
            return

        if toolchain is QCToolchain.TYPESCRIPT:
            self._run(self.FULL_TS_FMT)
            self._run(self.FULL_TS_LINT)
            self._run(self.FULL_TS_TYPE)
            self._run_jest_with_expectations(
                cmd=self.FULL_TS_TEST, expectations=expectations
            )
            return

        raise RuntimeError(f"Unsupported QC toolchain: {toolchain}")

    def _run_pytest_with_expectations(
        self,
        expectations: ResolvedTestExpectations | None,
    ) -> None:
        """
        Run pytest and apply expectation filtering to failures.

        Purpose:
            Allow expected-fail tests to fail while still failing on unexpected
            errors or expected-pass overrides.

        Args:
            expectations (ResolvedTestExpectations | None): Optional expected
                pytest failures derived from the active plan.

        Raises:
            CalledProcessError: If pytest fails unexpectedly.
        """
        run_pytest_with_expectations(
            cmd=self.FULL_TEST,
            workspace=self.workspace,
            resolve_executable=self.resolve_executable,
            expectations=expectations,
            env=self._merge_env(self._lock_bypass_env()),
        )

    def _run_pytest_scoped_with_expectations(
        self,
        *,
        test_files: list[str],
        expectations: ResolvedTestExpectations | None,
    ) -> None:
        """
        Run pytest on specific test files with expectation filtering.

        Purpose:
            Allow expected-fail tests to fail during scoped QC checks
            (mid-execution project state).

        Args:
            test_files (list[str]): Test file paths to run.
            expectations (ResolvedTestExpectations | None): Optional expected
                pytest failures derived from the active plan.

        Raises:
            CalledProcessError: If pytest fails unexpectedly.
        """
        run_pytest_with_expectations(
            cmd=["poetry", "run", "pytest", *test_files],
            workspace=self.workspace,
            resolve_executable=self.resolve_executable,
            expectations=expectations,
            env=self._merge_env(self._lock_bypass_env()),
        )

    def _run_jest_with_expectations(
        self,
        *,
        cmd: list[str],
        expectations: ResolvedTestExpectations | None,
    ) -> None:
        """
        Run Jest with expectation filtering for known failures.

        Purpose:
            Allow expected-fail Jest tests to fail while still failing on
            unexpected errors or expected-pass overrides.

        Args:
            cmd (list[str]): Jest command to execute.
            expectations (ResolvedTestExpectations | None): Optional expected
                Jest failures derived from the active plan.

        Raises:
            CalledProcessError: If Jest fails unexpectedly.
        """
        run_jest_with_expectations(
            cmd=cmd,
            workspace=self.workspace,
            resolve_executable=self.resolve_executable,
            expectations=expectations,
        )

    def _run_jest_scoped_with_expectations(
        self,
        *,
        test_files: list[str],
        expectations: ResolvedTestExpectations | None,
    ) -> None:
        """
        Run Jest on specific test files with expectation filtering.

        Purpose:
            Allow expected-fail Jest tests to fail during scoped QC checks.

        Args:
            test_files (list[str]): Jest test file paths to run.
            expectations (ResolvedTestExpectations | None): Optional expected
                Jest failures derived from the active plan.

        Raises:
            CalledProcessError: If Jest fails unexpectedly.
        """
        cmd = ["npm", "run", "test:unit", "--", *test_files]
        self._run_jest_with_expectations(cmd=cmd, expectations=expectations)

    def run_full_loop_with_artifacts(
        self,
        *,
        artifact_paths: dict[str, Path],
        max_loops: int | None = 10,
        toolchain: QCToolchain = QCToolchain.PYTHON,
    ) -> QCLoopResult:
        """
        Run the full QC toolchain loop and capture outputs to artifact files.

        Purpose:
            Execute Black/Ruff/Pyright/Pytest in the required order, restarting
            the loop when formatting changes occur, and record each step's output
            to the specified artifact file.

        Args:
            artifact_paths (dict[str, Path]): Map from step name to output file.
            max_loops (int | None): Maximum loop iterations before aborting.
            toolchain (QCToolchain): Toolchain to run (Python or TypeScript).

        Returns:
            QCLoopResult: Success flag and failure details if applicable.

        Raises:
            RuntimeError: If loop iteration exceeds max_loops.

        Side Effects:
            Runs subprocess commands and writes output files under artifacts/.
        """

        def _diff_signature_callback(
            *,
            workspace: Path,
            run_checked: object,
            exclude_paths: Iterable[Path] | None = None,
        ) -> tuple[tuple[str, str, str], ...]:
            del workspace
            del run_checked
            return self._diff_signature(exclude_paths=exclude_paths)

        def _run_and_record_callback(
            *,
            workspace: Path,
            resolve_executable: object,
            argv: list[str],
            output_path: Path,
            env: dict[str, str] | None = None,
        ) -> QCToolResult:
            del workspace
            del resolve_executable
            return self._run_and_record(
                argv=argv,
                output_path=output_path,
                env=env,
            )

        return run_full_loop_with_artifacts(
            workspace=self.workspace,
            resolve_executable=self.resolve_executable,
            run_checked=self._run,
            artifact_paths=artifact_paths,
            lock_bypass_env=self._lock_bypass_env,
            merge_env=self._merge_env,
            full_fmt=["poetry", "run", "black", "."],
            full_lint=["poetry", "run", "ruff", "check"],
            full_type=["poetry", "run", "pyright"],
            full_test=[
                "poetry",
                "run",
                "pytest",
                "--cov=src/lexile_corpus_tuner",
                "--cov=scripts/dev_tools",
                "--cov-report=term-missing",
            ],
            full_ts_fmt=self.FULL_TS_FMT,
            full_ts_lint=self.FULL_TS_LINT,
            full_ts_type=self.FULL_TS_TYPE,
            full_ts_test=self.FULL_TS_TEST,
            diff_signature_fn=_diff_signature_callback,
            run_and_record_fn=_run_and_record_callback,
            max_loops=max_loops,
            toolchain=toolchain,
        )

    def changed_files(self) -> list[str]:
        """
        Detect changed files via git status.

        Purpose:
            Identify files modified/added/deleted for scoped QC.

        Returns:
            list[str]: Relative paths of changed files.

        Side Effects:
            Calls git status --porcelain.
        """
        result = self._run(
            ["git", "status", "--porcelain"],
            capture_output=True,
            text=True,
            errors="replace",
        )
        files: list[str] = []
        # Extract the path column so scoped QC targets only changed files.
        for line in result.stdout.splitlines():
            # Format: XY <path>
            parts = line.strip().split(maxsplit=1)
            if len(parts) == 2:
                files.append(parts[1])
        return files

    def _git_has_changes(self, *, exclude_paths: Iterable[Path] | None = None) -> bool:
        """
        Check if the git working tree has uncommitted changes.

        Purpose:
            Detect formatter modifications so the QC loop can restart from the
            beginning after Black rewrites files.

        Args:
            exclude_paths (Iterable[Path] | None): Paths to ignore when
                determining whether changes occurred. Useful when QC writes
                artifacts that should not trigger a retry loop.

        Returns:
            bool: True if there are uncommitted changes beyond exclusions,
                False otherwise.
        """
        return git_has_changes(
            workspace=self.workspace,
            run_checked=self._run,
            exclude_paths=exclude_paths,
        )

    def _diff_signature(
        self, *, exclude_paths: Iterable[Path] | None = None
    ) -> tuple[tuple[str, str, str], ...]:
        """
        Build a diff signature for the working tree.

        Purpose:
            Capture a stable fingerprint of current diffs so the QC loop can
            determine whether Black introduced changes even when files were
            already modified.

        Args:
            exclude_paths (Iterable[Path] | None): Paths to ignore when building
                the signature.

        Returns:
            tuple[tuple[str, str, str], ...]: Sorted tuples of
                (path, additions, deletions) for each changed file.
        """
        return diff_signature(
            workspace=self.workspace,
            run_checked=self._run,
            exclude_paths=exclude_paths,
        )

    def _normalize_excluded_paths(
        self, exclude_paths: Iterable[Path] | None
    ) -> set[str]:
        """
        Normalize excluded paths to repo-relative POSIX strings.

        Purpose:
            Ensure consistent comparisons between path objects and git output.

        Args:
            exclude_paths (Iterable[Path] | None): Paths to normalize.

        Returns:
            set[str]: Normalized paths in POSIX form.
        """
        return normalize_excluded_paths(self.workspace, exclude_paths)

    def _lock_bypass_env(self) -> dict[str, str]:
        """
        Provide an env flag that bypasses the executor lock in tests.

        Purpose:
            The executor holds a lock file during execute-all runs. When QC
            runs pytest in-process, tests that call the executor should not
            fail due to the existing lock, so we set a bypass env var for
            the pytest subprocess only.

        Returns:
            dict[str, str]: Environment overrides enabling lock bypass.
        """
        return {self.EXECUTOR_LOCK_BYPASS_ENV: "1"}

    def _merge_env(self, extra_env: dict[str, str] | None) -> dict[str, str] | None:
        """
        Merge extra environment variables into the current process env.

        Purpose:
            Ensure subprocesses inherit the current environment plus any
            explicit overrides.

        Args:
            extra_env (dict[str, str] | None): Environment overrides to apply.

        Returns:
            dict[str, str] | None: Merged environment or None if no overrides.
        """
        if not extra_env:
            return None

        env = dict(os.environ)
        env.update(extra_env)
        return env

    def _filter_python_files(self, paths: Iterable[str]) -> list[str]:
        """Filter to .py files only."""
        return [p for p in paths if p.endswith(".py")]

    def _filter_test_files(self, paths: Iterable[str]) -> list[str]:
        """Filter to python test files only (tests/ directory)."""
        return [
            p
            for p in paths
            if (p.startswith("tests/") or "/tests/" in p) and p.endswith(".py")
        ]

    def _filter_ts_files(self, paths: Iterable[str]) -> list[str]:
        """Filter to .ts/.tsx files only."""
        return [p for p in paths if p.endswith(".ts") or p.endswith(".tsx")]

    def _filter_ts_test_files(self, paths: Iterable[str]) -> list[str]:
        """Filter to typescript test files only (tests/ directory)."""
        return [
            p
            for p in paths
            if (p.startswith("tests/") or "/tests/" in p)
            and (p.endswith(".test.ts") or p.endswith(".spec.ts"))
        ]

    def _run_and_record(
        self,
        *,
        argv: list[str],
        output_path: Path,
        env: dict[str, str] | None = None,
    ) -> QCToolResult:
        """
        Execute a command, capture output, and write it to a file.

        Purpose:
            Run a QC step with output capture for artifact logging.

        Args:
            argv (list[str]): Command and arguments to execute.
            output_path (Path): File path for captured output.
            env (dict[str, str] | None): Environment overrides for the command.

        Returns:
            QCToolResult: Captured output and exit status.

        Side Effects:
            Creates parent directories and writes output to disk.
        """
        return run_and_record(
            workspace=self.workspace,
            resolve_executable=self.resolve_executable,
            argv=argv,
            output_path=output_path,
            env=env,
        )
