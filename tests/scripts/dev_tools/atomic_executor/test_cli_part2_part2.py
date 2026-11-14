"""
Tests for atomic_executor.cli module.

Tests cover CLI argument parsing, workspace resolution, precondition checks,
clipboard operations, and main execution orchestration.
"""

# pyright: reportArgumentType=false, reportUnknownLambdaType=false, reportUnknownArgumentType=false, reportPrivateUsage=false

import os
import subprocess
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import Mock

import pytest

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch


class TestMainEdgeCases:
    """Edge case tests for main execution flow."""

    def test_main_successful_execution_with_scoped_qc(
        self,
        mem_fs_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() successfully executes task with scoped QC."""
        from scripts.dev_tools.atomic_executor.cli import main

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_fs_path / "config-root"))

        # Setup feature folder
        feature_dir = mem_fs_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        plan_file = feature_dir / "plan.md"
        plan_file.write_text(
            "# Phase 0\n- [ ] [P0-T1] Task 1\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [ ] [P2-T1] Black\n"
            "- [ ] [P2-T2] Ruff\n"
            "- [ ] [P2-T3] Pyright\n"
            "- [ ] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        template_dir = mem_fs_path / ".github" / "prompts"
        template_dir.mkdir(parents=True)
        (template_dir / "execute-plan-template.md").write_text(
            "Task: {{task_id}}\n", encoding="utf-8"
        )

        # Setup fake copilot on PATH for run_copilot
        bin_dir = mem_fs_path / "bin"
        bin_dir.mkdir()
        copilot_exe = bin_dir / "copilot"
        copilot_exe.touch()
        copilot_exe.chmod(0o755)  # Make executable-ish
        path = os.environ.get("PATH", "")
        monkeypatch.setenv("PATH", f"{str(bin_dir)}{os.pathsep}{path}")

        # Track subprocess calls
        subprocess_calls: list[list[str]] = []

        def mock_run(
            argv: list[str], *args: object, **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            subprocess_calls.append(argv)
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        class MockStdout:
            def read(self, size: int = -1) -> bytes:
                return b""

        class MockPopen:
            def __init__(
                self, argv: list[str], *args: object, **kwargs: object
            ) -> None:
                subprocess_calls.append(argv)
                self.stdout = MockStdout()
                self.returncode = 0

            def poll(self) -> int:
                return 0

            def wait(self) -> int:
                return 0

        monkeypatch.setattr("subprocess.run", mock_run)
        monkeypatch.setattr("subprocess.Popen", MockPopen)
        monkeypatch.setattr("shutil.which", lambda x: f"/usr/bin/{x}")

        # Mock QCRunner methods to succeed
        from scripts.dev_tools.atomic_executor.qc_runner import QCRunner

        monkeypatch.setattr(
            QCRunner,
            "run_scoped",
            lambda self, expectations=None: None,  # Accept expectations param
        )

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_fs_path),
                "--skip-preflight-qc",
            ]
        )

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "complete and gated" in captured.out.lower()

        # Verify copilot was invoked
        copilot_calls = [c for c in subprocess_calls if "copilot" in c[0]]
        assert len(copilot_calls) == 1


class TestPreflightParallelCommand:
    """Tests that the preflight QC pytest step runs on pytest-xdist workers."""

    def test_preflight_pytest_step_runs_xdist_workers(
        self,
        mem_fs_path: Path,
        monkeypatch: "MonkeyPatch",
    ) -> None:
        """The pytest step of _run_preflight_qc_with_capture passes -n auto."""
        from scripts.dev_tools.atomic_executor.cli import _run_preflight_qc_with_capture

        argvs: list[list[str]] = []

        def mock_run(
            argv: list[str], **kwargs: object
        ) -> subprocess.CompletedProcess[str]:
            """Record each argv and report success for every step."""
            argvs.append(list(argv))
            return subprocess.CompletedProcess(
                args=argv, returncode=0, stdout="OK", stderr=""
            )

        monkeypatch.setattr("subprocess.run", mock_run)
        # Keep argv[0] bare so no case depends on pwsh being on PATH (#1158).
        monkeypatch.setattr(
            "scripts.dev_tools.atomic_executor.cli_preflight.shutil.which",
            lambda name: name,
        )

        _run_preflight_qc_with_capture(mem_fs_path)

        # The first recorded argv that names pytest is the pytest step.
        pytest_argv = next(argv for argv in argvs if "pytest" in argv)
        start = pytest_argv.index("pytest")
        assert pytest_argv[start : start + 3] == ["pytest", "-n", "auto"]
        assert "--cov=src/lexile_corpus_tuner" not in pytest_argv
