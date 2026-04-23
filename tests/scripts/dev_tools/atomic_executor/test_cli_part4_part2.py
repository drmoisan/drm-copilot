"""
Tests for atomic_executor.cli module.

Tests cover CLI argument parsing, workspace resolution, precondition checks,
clipboard operations, and main execution orchestration.
"""

# pyright: reportArgumentType=false, reportUnknownLambdaType=false, reportUnknownArgumentType=false, reportPrivateUsage=false

import os
from pathlib import Path
from typing import TYPE_CHECKING

import pytest

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch


class TestRunCopilot:
    """Tests for run_copilot() function."""

    def test_run_copilot_permission_denied_fails_fast_with_actionable_error(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() raises promptly when Copilot reports a permission denial."""

        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_fs_path / "config-root"))
        # Create a fake copilot executable on PATH.
        fake_bin = mem_fs_path / "bin"
        fake_bin.mkdir()
        fake_copilot = fake_bin / "copilot.exe"
        fake_copilot.write_text("@echo fake copilot")
        monkeypatch.setenv("PATH", str(fake_bin))

        captured_argv: list[str] = []

        permission_denied = (
            "Permission denied and could not request permission from user"
        )

        class MockStdout:
            def __init__(self) -> None:
                self._chunks = [permission_denied.encode("utf-8"), b""]

            def read(self, size: int = -1) -> bytes:
                return self._chunks.pop(0) if self._chunks else b""

            def read1(self, size: int = -1) -> bytes:
                return self.read(size)

        class MockPopen:
            def __init__(
                self, argv: list[str], *args: object, **kwargs: object
            ) -> None:
                captured_argv.extend(argv)
                self.stdout = MockStdout()
                self.returncode = 1

            def poll(self) -> int:
                return 1

            def wait(self, timeout: float | None = None) -> int:
                return 1

        monkeypatch.setattr("subprocess.Popen", MockPopen)

        log_file = mem_fs_path / "test.log"

        with pytest.raises(RuntimeError) as exc_info:
            run_copilot(
                workspace=mem_fs_path,
                prompt_text="test prompt",
                log_file=log_file,
                task_id="P1-T1",
                preferred_model="gpt-5.1-codex-max",
                run_id="2026-01-07_000000",
            )

        error_text = str(exc_info.value)
        assert permission_denied in error_text
        assert "copilot" in error_text.lower()
        assert "-p" in error_text or "--prompt" in error_text
        assert "--allow-tool" in error_text
        assert "write" in error_text
        assert "shell(poetry)" in error_text
        assert "shell(git)" in error_text
        assert "--allow-all-paths" in error_text

        # Sanity check the argv we actually attempted to run.
        assert captured_argv
        assert captured_argv[0] == str(fake_copilot)

    def test_run_copilot_reuses_session_when_requested(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() adds --continue when resume_session=True."""
        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_fs_path / "config-root"))
        fake_bin = mem_fs_path / "bin"
        fake_bin.mkdir()
        fake_copilot = fake_bin / "copilot"
        fake_copilot.write_text("#!/bin/sh\necho copilot")
        monkeypatch.setenv("PATH", str(fake_bin))

        captured_argv: list[str] = []

        class MockStdout:
            def read(self, size: int = -1) -> bytes:
                return b""

        class MockPopen:
            def __init__(
                self, argv: list[str], *args: object, **kwargs: object
            ) -> None:
                captured_argv.extend(argv)
                self.stdout = MockStdout()
                self.returncode = 0

            def poll(self) -> int:
                return 0

            def wait(self) -> int:
                return 0

        monkeypatch.setattr("subprocess.Popen", MockPopen)

        log_file = mem_fs_path / "log" / "test.log"

        run_copilot(
            workspace=mem_fs_path,
            prompt_text="retry prompt",
            log_file=log_file,
            task_id="P1-T1",
            preferred_model=None,
            run_id="2026-01-07_000000",
            resume_session=True,
        )

        # resume_session=True should add --continue flag
        assert "--continue" in captured_argv

    def test_run_copilot_trusts_workspace_in_config(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() writes workspace to trusted_folders when enabled."""
        from scripts.dev_tools.atomic_executor.cli import run_copilot

        # Route Copilot config to a temp directory for isolation.
        config_root = mem_fs_path / "config-root"
        monkeypatch.setenv("XDG_CONFIG_HOME", str(config_root))

        fake_bin = mem_fs_path / "bin"
        fake_bin.mkdir()
        fake_copilot = fake_bin / "copilot"
        fake_copilot.write_text("#!/bin/sh\necho copilot")
        monkeypatch.setenv("PATH", str(fake_bin))

        class MockStdout:
            def read(self, size: int = -1) -> bytes:
                return b""

        class MockPopen:
            def __init__(
                self, argv: list[str], *args: object, **kwargs: object
            ) -> None:
                self.stdout = MockStdout()
                self.returncode = 0

            def poll(self) -> int:
                return 0

            def wait(self) -> int:
                return 0

        monkeypatch.setattr("subprocess.Popen", MockPopen)

        log_file = mem_fs_path / "log" / "test.log"

        run_copilot(
            workspace=mem_fs_path,
            prompt_text="trust prompt",
            log_file=log_file,
            task_id="P1-T1",
            preferred_model=None,
            run_id="2026-01-07_000000",
            allow_all_paths=True,
            allow_all_urls=False,
            allow_shell=True,
            trust_workspace=True,
        )

        config_file = config_root / "copilot" / "config.json"
        assert config_file.exists()
        config_text = config_file.read_text(encoding="utf-8")
        import json

        config_data = json.loads(config_text)
        trusted_folders = config_data.get("trusted_folders", [])
        assert str(mem_fs_path.resolve()) in trusted_folders

    def test_run_copilot_times_out_when_cli_is_idle(
        self, mem_fs_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() terminates when Copilot CLI produces no output."""
        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_fs_path / "config-root"))
        bin_dir = mem_fs_path / "bin"
        bin_dir.mkdir()
        copilot_exe = bin_dir / "copilot"
        copilot_exe.write_text("#!/bin/sh\nexit 0")
        copilot_exe.chmod(0o755)

        path = os.environ.get("PATH", "")
        monkeypatch.setenv("PATH", f"{str(bin_dir)}{os.pathsep}{path}")
        monkeypatch.setenv("ATOMIC_EXECUTOR_COPILOT_IDLE_TIMEOUT_SECONDS", "0.2")

        stdout_r, stdout_w = os.pipe()
        os.close(stdout_w)
        stdout_stream = os.fdopen(stdout_r, "rb", buffering=0)

        hung_process_holder: dict[str, object] = {}

        class HungProcess:
            def __init__(self, argv: list[str]) -> None:
                self.args = argv
                self.stdout = stdout_stream
                self.returncode: int | None = None
                self.killed = False

            def poll(self) -> int | None:
                return self.returncode

            def wait(self, timeout: float | None = None) -> int | None:
                return self.returncode

            def kill(self) -> None:
                self.killed = True
                self.returncode = -9

        def fake_popen(argv: list[str], *args: object, **kwargs: object) -> HungProcess:
            proc = HungProcess(argv)
            hung_process_holder["proc"] = proc
            return proc

        monkeypatch.setattr("subprocess.Popen", fake_popen)

        log_file = mem_fs_path / "log" / "test.log"

        with pytest.raises(TimeoutError):
            run_copilot(
                workspace=mem_fs_path,
                prompt_text="idle prompt",
                log_file=log_file,
                task_id="P1-T1",
                preferred_model=None,
                run_id="2026-01-07_000000",
            )

        proc = hung_process_holder.get("proc")
        assert proc is not None
        assert getattr(proc, "killed", False) is True
        stdout_stream.close()
