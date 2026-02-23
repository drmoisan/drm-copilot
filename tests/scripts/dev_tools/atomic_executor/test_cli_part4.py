"""
Tests for atomic_executor.cli module.

Tests cover CLI argument parsing, workspace resolution, precondition checks,
clipboard operations, and main execution orchestration.
"""

# pyright: reportArgumentType=false, reportUnknownLambdaType=false, reportUnknownArgumentType=false, reportPrivateUsage=false

import os
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import Mock

import pytest

if TYPE_CHECKING:
    from _pytest.monkeypatch import MonkeyPatch


@pytest.fixture
def mem_path(tmp_path: Path) -> Path:
    """Alias fixture for cosmetic tmp_path->mem_path test parameter rename."""
    return tmp_path


class TestRunCopilot:
    """Tests for run_copilot() function."""

    def test_run_copilot_raises_when_executable_not_found(
        self, mem_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() raises FileNotFoundError when copilot not found."""
        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_path / "config-root"))
        # Set PATH to empty so no copilot executable can be found
        monkeypatch.setenv("PATH", "")

        log_file = mem_path / "test.log"

        with pytest.raises(
            FileNotFoundError,
            match=r"Required executable not found on PATH: copilot\b",
        ):
            run_copilot(
                workspace=mem_path,
                prompt_text="test prompt",
                log_file=log_file,
                task_id="P1-T1",
                preferred_model=None,
                run_id="2026-01-07_000000",
            )

    def test_run_copilot_rejects_vscode_shim(
        self, mem_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() skips VS Code shim and finds no other copilot."""
        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_path / "config-root"))
        # Create shim directory structure that matches the detection pattern
        # Pattern: .../Code/User/globalStorage/github.copilot-chat/copilotCli/
        # Use nested dirs to ensure we hit the pattern matching logic
        shim_dir = (
            mem_path
            / "Code"
            / "User"
            / "globalStorage"
            / "github.copilot-chat"
            / "copilotCli"
        )
        shim_dir.mkdir(parents=True)

        # Create executable shim
        # In cli.py, it checks specifically for copilot.exe, copilot.bat, copilot
        fake_shim = shim_dir / "copilot"
        fake_shim.touch()
        fake_shim.chmod(0o755)

        # Update PATH to point to this directory
        monkeypatch.setenv("PATH", str(shim_dir))

        log_file = mem_path / "test.log"

        with pytest.raises(
            FileNotFoundError,
            match=r"Required executable not found on PATH: copilot\b",
        ):
            run_copilot(
                workspace=mem_path,
                prompt_text="test prompt",
                log_file=log_file,
                task_id="P1-T1",
                preferred_model=None,
                run_id="2026-01-07_000000",
            )

    def test_run_copilot_rejects_vscode_shim_remote_paths(
        self, mem_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() rejects the VS Code Remote/Devcontainer shim path."""
        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_path / "config-root"))
        # VS Code Remote (including devcontainers) stores its shim under a Linux
        # path, e.g. ~/.vscode-server/data/User/globalStorage/github.copilot-chat/
        # copilotCli/. If we accidentally execute this shim, it can block waiting
        # for interactive install/auth and appear as a hang.
        shim_dir = (
            mem_path
            / ".vscode-server"
            / "data"
            / "User"
            / "globalStorage"
            / "github.copilot-chat"
            / "copilotCli"
        )
        shim_dir.mkdir(parents=True)

        fake_shim = shim_dir / "copilot"
        fake_shim.touch()
        fake_shim.chmod(0o755)

        # Ensure the shim is the ONLY PATH entry.
        monkeypatch.setenv("PATH", str(shim_dir))

        # Guard: if the implementation tries to execute the shim, fail the test.
        def _should_not_invoke_popen(*args: object, **kwargs: object) -> None:
            pytest.fail("run_copilot attempted to execute a VS Code shim")

        monkeypatch.setattr("subprocess.Popen", _should_not_invoke_popen)

        log_file = mem_path / "test.log"

        with pytest.raises(
            FileNotFoundError,
            match=r"Required executable not found on PATH: copilot\b",
        ):
            run_copilot(
                workspace=mem_path,
                prompt_text="test prompt",
                log_file=log_file,
                task_id="P1-T1",
                preferred_model=None,
                run_id="2026-01-07_000000",
            )

    def test_run_copilot_creates_log_directory(
        self, mem_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() creates log directory if missing."""
        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_path / "config-root"))
        # Setup fake copilot on PATH
        bin_dir = mem_path / "bin"
        bin_dir.mkdir()
        copilot_exe = bin_dir / "copilot"
        copilot_exe.touch()
        copilot_exe.chmod(0o755)
        path = os.environ.get("PATH", "")
        monkeypatch.setenv("PATH", f"{str(bin_dir)}{os.pathsep}{path}")

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

        # Also mock run purely to avoid confusion, though unused by run_copilot directly
        def mock_run(*args: object, **kwargs: object) -> Mock:
            return Mock(returncode=0)

        monkeypatch.setattr("subprocess.run", mock_run)

        log_dir = mem_path / "nested" / "log" / "dir"
        log_file = log_dir / "test.log"

        run_copilot(
            workspace=mem_path,
            prompt_text="test prompt",
            log_file=log_file,
            task_id="P1-T1",
            preferred_model=None,
            run_id="2026-01-07_000000",
        )

        assert log_dir.exists()
        assert log_file.exists()

    def test_run_copilot_prefers_cmd_wrapper_over_bare_executable_name(
        self, mem_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() prefers copilot.cmd over a bare 'copilot' file on Windows."""

        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_path / "config-root"))

        # Arrange a PATH entry with both:
        # - copilot (often a POSIX shim from npm, not executable by CreateProcess)
        # - copilot.cmd (Windows-friendly wrapper)
        fake_bin = mem_path / "bin"
        fake_bin.mkdir()
        (fake_bin / "copilot").write_text("#!/usr/bin/env node\n", encoding="utf-8")
        (fake_bin / "copilot.cmd").write_text("@echo fake copilot\n", encoding="utf-8")
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

        log_file = mem_path / "test.log"

        run_copilot(
            workspace=mem_path,
            prompt_text="test prompt",
            log_file=log_file,
            task_id="P1-T1",
            preferred_model=None,
            run_id="2026-01-07_000000",
        )

        assert captured_argv
        assert Path(captured_argv[0]).name == "copilot.cmd"

    def test_run_copilot_invokes_with_correct_arguments(
        self, mem_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() invokes copilot with correct arguments."""
        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_path / "config-root"))
        # Create a fake copilot executable on PATH
        fake_bin = mem_path / "bin"
        fake_bin.mkdir()
        fake_copilot = fake_bin / "copilot.exe"
        fake_copilot.write_text("@echo fake copilot")
        monkeypatch.setenv("PATH", str(fake_bin))

        captured_argv: list[str] = []
        captured_stdin: str | None = None
        captured_stdin_was_provided = False

        class MockStdout:
            def read(self, size: int = -1) -> bytes:
                return b""

        class MockPopen:
            def __init__(
                self, argv: list[str], *args: object, **kwargs: object
            ) -> None:
                nonlocal captured_stdin
                nonlocal captured_stdin_was_provided
                captured_argv.extend(argv)
                # Capture stdin content if provided
                stdin_arg = kwargs.get("stdin")
                captured_stdin_was_provided = (
                    "stdin" in kwargs and stdin_arg is not None
                )
                if stdin_arg and hasattr(stdin_arg, "read"):
                    # Type narrowing: we know it has a read method and returns bytes
                    raw_content = stdin_arg.read()  # type: ignore[union-attr]
                    # Explicitly cast to bytes for type checker
                    content_bytes: bytes = (
                        raw_content if isinstance(raw_content, bytes) else b""
                    )
                    captured_stdin = content_bytes.decode("utf-8")
                self.stdout = MockStdout()
                self.returncode = 0

            def poll(self) -> int:
                return 0

            def wait(self) -> int:
                return 0

        monkeypatch.setattr("subprocess.Popen", MockPopen)

        log_file = mem_path / "test.log"

        run_copilot(
            workspace=mem_path,
            prompt_text="test prompt",
            log_file=log_file,
            task_id="P1-T1",
            preferred_model="gpt-5.1-codex-max",
            run_id="2026-01-07_000000",
        )

        expected_prompt_file = (
            log_file.parent / "prompts" / "prompt_2026-01-07_000000_P1-T1.md"
        )
        assert expected_prompt_file.exists()
        assert expected_prompt_file.read_text(encoding="utf-8") == "test prompt"

        assert captured_argv[0] == str(fake_copilot)
        assert "--agent" in captured_argv
        agent_idx = captured_argv.index("--agent")
        assert captured_argv[agent_idx + 1] == "atomic_executor"
        assert "--model" in captured_argv
        assert "gpt-5.1-codex-max" in captured_argv
        assert "--session-path" not in captured_argv
        # Prompt must be passed via programmatic mode (-p/--prompt) with an @path
        # reference to the on-disk prompt file.
        assert "-p" in captured_argv or "--prompt" in captured_argv
        prompt_flag = "-p" if "-p" in captured_argv else "--prompt"
        prompt_idx = captured_argv.index(prompt_flag)
        prompt_value = captured_argv[prompt_idx + 1]
        assert f"@{expected_prompt_file}" in prompt_value

        # Prompt must NOT be provided via stdin.
        assert captured_stdin_was_provided is False
        assert captured_stdin is None
        assert "--share" in captured_argv
        assert "--allow-tool" in captured_argv
        assert "write" in captured_argv

        # Headless-friendly defaults must include broad shell and path permissions.
        assert "--allow-tool" in captured_argv
        assert "shell" in captured_argv
        assert "--allow-all-paths" in captured_argv

        # Tool approvals required for headless QC must remain present.
        assert "shell(poetry)" in captured_argv
        assert "shell(git)" in captured_argv

    def test_run_copilot_normalizes_gpt_5_2_codex_display_name(
        self, mem_path: Path, monkeypatch: "MonkeyPatch"
    ) -> None:
        """run_copilot() normalizes GPT-5.2 Codex display names for Copilot CLI."""

        from scripts.dev_tools.atomic_executor.cli import run_copilot

        monkeypatch.setenv("XDG_CONFIG_HOME", str(mem_path / "config-root"))
        # Create a fake copilot executable on PATH.
        fake_bin = mem_path / "bin"
        fake_bin.mkdir()
        fake_copilot = fake_bin / "copilot.exe"
        fake_copilot.write_text("@echo fake copilot")
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

        log_file = mem_path / "test.log"

        # VS Code tasks sometimes pass this exact display-style model string.
        # The executor should normalize it to the Copilot CLI model key.
        run_copilot(
            workspace=mem_path,
            prompt_text="test prompt",
            log_file=log_file,
            task_id="P1-T1",
            preferred_model="GPT-5.2-Codex",
            run_id="2026-01-07_000000",
        )

        assert "--model" in captured_argv
        model_idx = captured_argv.index("--model")
        assert captured_argv[model_idx + 1] == "gpt-5.2-codex"
