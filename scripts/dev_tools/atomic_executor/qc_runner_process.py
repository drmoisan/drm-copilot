"""Process execution helpers for the atomic executor QC runner."""

from __future__ import annotations

import shutil
import subprocess
from typing import TYPE_CHECKING

from scripts.dev_tools.atomic_executor.pytest_expectations import (
    JestFailureSummary,
    parse_jest_failure_output,
)

if TYPE_CHECKING:
    from pathlib import Path


class QCRunnerProcessMixin:
    """Provide subprocess execution and executable-resolution helpers."""

    workspace: Path
    FULL_TS_TEST: list[str]

    def check_jest_skipped_tests(
        self, *, test_files: list[str] | None = None
    ) -> JestFailureSummary:
        """Run Jest and return parsed output summary, including skip counts."""
        if test_files:
            cmd = ["npm", "run", "test:unit", "--", *test_files]
        else:
            cmd = self.FULL_TS_TEST

        exe = shutil.which(cmd[0])
        if exe is None:
            raise FileNotFoundError(f"Required executable not found on PATH: {cmd[0]}")
        resolved_cmd = [exe, *cmd[1:]]

        result = subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            resolved_cmd,
            cwd=self.workspace,
            check=False,
            capture_output=True,
            text=True,
            errors="replace",
        )
        combined = (result.stdout or "") + (result.stderr or "")
        return parse_jest_failure_output(combined)

    def resolve_executable(self, argv: list[str]) -> list[str]:
        """Resolve argv[0] to an absolute executable path via PATH/PATHEXT."""
        if not argv:
            raise ValueError("Command argv must not be empty.")

        exe = shutil.which(argv[0])
        if exe is None:
            raise FileNotFoundError(f"Required executable not found on PATH: {argv[0]}")

        return [exe, *argv[1:]]

    def run_command(
        self,
        argv: list[str],
        *,
        capture_output: bool = False,
        text: bool = True,
        errors: str | None = "replace",
        env: dict[str, str] | None = None,
    ) -> subprocess.CompletedProcess[str]:
        """Run a command with shared QC defaults."""
        return self._run(
            argv,
            capture_output=capture_output,
            text=text,
            errors=errors,
            env=env,
        )

    def _run(
        self,
        argv: list[str],
        *,
        capture_output: bool = False,
        text: bool = True,
        errors: str | None = "replace",
        env: dict[str, str] | None = None,
    ) -> subprocess.CompletedProcess[str]:
        """Execute a subprocess command with consistent workspace defaults."""
        resolved_argv = self.resolve_executable(argv)
        return subprocess.run(  # noqa: S603 - static analysis can't verify runtime validation
            resolved_argv,
            cwd=self.workspace,
            check=True,
            capture_output=capture_output,
            text=text,
            errors=errors if text else None,
            env=env,
        )
