"""
Tests for atomic_executor.cli module.

Tests cover CLI argument parsing, workspace resolution, precondition checks,
clipboard operations, and main execution orchestration.
"""

# pyright: reportArgumentType=false, reportUnknownLambdaType=false, reportUnknownArgumentType=false, reportPrivateUsage=false

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


class TestMainEdgeCases:
    """Edge case tests for main execution flow."""

    def test_main_exits_early_with_print_prompt(
        self,
        mem_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() exits early with --print-prompt without running copilot."""
        from scripts.dev_tools.atomic_executor.cli import main

        # Setup minimal feature folder
        feature_dir = mem_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        (feature_dir / "plan.md").write_text(
            "# Phase 0\n- [ ] [P0-T1] Task 1\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [ ] [P2-T1] Black\n"
            "- [ ] [P2-T2] Ruff\n"
            "- [ ] [P2-T3] Pyright\n"
            "- [ ] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        template_dir = mem_path / ".github" / "prompts"
        template_dir.mkdir(parents=True)
        (template_dir / "execute-plan-template.md").write_text(
            "TEMPLATE\n", encoding="utf-8"
        )

        # Mock all subprocess calls
        def mock_run(*args: object, **kwargs: object) -> Mock:
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        monkeypatch.setattr("subprocess.run", mock_run)

        # Mock copilot to not be found (shouldn't be called)
        monkeypatch.setattr("shutil.which", lambda x: None if x == "copilot" else "git")  # type: ignore[arg-type,misc]

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_path),
                "--print-prompt",
                "--skip-preflight-qc",
            ]
        )

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "TEMPLATE" in captured.out
        assert "CURRENT TASK" in captured.out

    def test_main_exits_early_with_copy_prompt(
        self,
        mem_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() exits early with --copy-prompt without running copilot."""
        from scripts.dev_tools.atomic_executor.cli import main

        # Setup minimal feature folder
        feature_dir = mem_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        (feature_dir / "plan.md").write_text(
            "# Phase 0\n- [ ] [P0-T1] Task 1\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [ ] [P2-T1] Black\n"
            "- [ ] [P2-T2] Ruff\n"
            "- [ ] [P2-T3] Pyright\n"
            "- [ ] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        template_dir = mem_path / ".github" / "prompts"
        template_dir.mkdir(parents=True)
        (template_dir / "execute-plan-template.md").write_text(
            "TEMPLATE\n", encoding="utf-8"
        )

        # Mock all subprocess calls
        def mock_run(*args: object, **kwargs: object) -> Mock:
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        monkeypatch.setattr("subprocess.run", mock_run)

        # Mock clipboard to succeed
        monkeypatch.setattr(
            "scripts.dev_tools.atomic_executor.cli.copy_to_clipboard", lambda x: True  # type: ignore[arg-type,misc]
        )

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_path),
                "--copy-prompt",
                "--skip-preflight-qc",
            ]
        )

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "copied to clipboard" in captured.err.lower()

    def test_main_returns_error_for_missing_plan(
        self,
        mem_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() returns error code when plan.md missing."""
        from scripts.dev_tools.atomic_executor.cli import main

        # Setup feature folder without plan.md
        feature_dir = mem_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        # Mock git to be clean
        def mock_run(*args: object, **kwargs: object) -> Mock:
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        monkeypatch.setattr("subprocess.run", mock_run)

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_path),
            ]
        )

        assert exit_code == 2
        captured = capsys.readouterr()
        assert "Missing required plan file" in captured.err

    def test_main_returns_zero_when_plan_already_complete(
        self,
        mem_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() returns 0 when all tasks already checked."""
        from scripts.dev_tools.atomic_executor.cli import main

        # Setup feature folder with all tasks checked
        feature_dir = mem_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        (feature_dir / "plan.md").write_text(
            "# Phase 0\n- [x] [P0-T1] Task 1\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [x] [P2-T1] Black\n"
            "- [x] [P2-T2] Ruff\n"
            "- [x] [P2-T3] Pyright\n"
            "- [x] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        template_dir = mem_path / ".github" / "prompts"
        template_dir.mkdir(parents=True)
        (template_dir / "execute-plan-template.md").write_text(
            "TEMPLATE\n", encoding="utf-8"
        )

        # Mock git to be clean
        def mock_run(*args: object, **kwargs: object) -> Mock:
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        monkeypatch.setattr("subprocess.run", mock_run)

        exit_code = main(
            [
                "resume",
                str(feature_dir),
                "--workspace",
                str(mem_path),
            ]
        )

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "already complete" in captured.out.lower()

    def test_main_returns_error_for_missing_template(
        self,
        mem_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() returns error code when prompt template missing."""
        from scripts.dev_tools.atomic_executor.cli import main

        # Setup feature folder with plan.md
        feature_dir = mem_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        (feature_dir / "plan.md").write_text(
            "# Phase 0\n- [ ] [P0-T1] Task 1\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [ ] [P2-T1] Black\n"
            "- [ ] [P2-T2] Ruff\n"
            "- [ ] [P2-T3] Pyright\n"
            "- [ ] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        # Don't create template file

        # Mock git to be clean
        def mock_run(*args: object, **kwargs: object) -> Mock:
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        monkeypatch.setattr("subprocess.run", mock_run)

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_path),
            ]
        )

        assert exit_code == 2
        captured = capsys.readouterr()
        assert "Prompt template not found" in captured.err

    def test_main_with_copy_prompt_fallback_when_clipboard_fails(
        self,
        mem_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() prints prompt when --copy-prompt fails."""
        from scripts.dev_tools.atomic_executor.cli import main

        # Setup minimal feature folder
        feature_dir = mem_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        (feature_dir / "plan.md").write_text(
            "# Phase 0\n- [ ] [P0-T1] Task 1\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [ ] [P2-T1] Black\n"
            "- [ ] [P2-T2] Ruff\n"
            "- [ ] [P2-T3] Pyright\n"
            "- [ ] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        template_dir = mem_path / ".github" / "prompts"
        template_dir.mkdir(parents=True)
        (template_dir / "execute-plan-template.md").write_text(
            "TEMPLATE\n", encoding="utf-8"
        )

        # Mock all subprocess calls
        def mock_run(*args: object, **kwargs: object) -> Mock:
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        monkeypatch.setattr("subprocess.run", mock_run)

        # Mock clipboard to fail
        monkeypatch.setattr(
            "scripts.dev_tools.atomic_executor.cli.copy_to_clipboard",
            lambda x: False,  # type: ignore[arg-type,misc]
        )

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_path),
                "--copy-prompt",
                "--skip-preflight-qc",
            ]
        )

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "Clipboard copy not available" in captured.err
        assert "TEMPLATE" in captured.out

    def test_main_execute_with_start_flag(
        self,
        mem_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() executes with --start flag to begin at specific task."""
        from scripts.dev_tools.atomic_executor.cli import main

        # Setup feature folder with multiple tasks
        feature_dir = mem_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        (feature_dir / "plan.md").write_text(
            "# Phase 0\n"
            "- [x] [P0-T1] First task\n"
            "- [ ] [P0-T2] Second task\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [ ] [P2-T1] Black\n"
            "- [ ] [P2-T2] Ruff\n"
            "- [ ] [P2-T3] Pyright\n"
            "- [ ] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        template_dir = mem_path / ".github" / "prompts"
        template_dir.mkdir(parents=True)
        (template_dir / "execute-plan-template.md").write_text(
            "TEMPLATE\n", encoding="utf-8"
        )

        # Mock git to be clean
        def mock_run(*args: object, **kwargs: object) -> Mock:
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        monkeypatch.setattr("subprocess.run", mock_run)

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_path),
                "--start",
                "P0-T2",
                "--print-prompt",
                "--skip-preflight-qc",
            ]
        )

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "P0-T2" in captured.out
        assert "Second task" in captured.out

    def test_main_execute_when_all_tasks_complete(
        self,
        mem_path: Path,
        monkeypatch: "MonkeyPatch",
        capsys: pytest.CaptureFixture[str],
    ) -> None:
        """main() exits when execute subcommand finds no unchecked tasks."""
        from scripts.dev_tools.atomic_executor.cli import main

        # Setup feature folder with all tasks checked
        feature_dir = mem_path / "docs" / "features" / "active" / "my-feature"
        feature_dir.mkdir(parents=True)
        (feature_dir / "plan.md").write_text(
            "# Phase 0\n- [x] [P0-T1] Task 1\n\n"
            "# Phase 2 (QA/Toolchain)\n"
            "- [x] [P2-T1] Black\n"
            "- [x] [P2-T2] Ruff\n"
            "- [x] [P2-T3] Pyright\n"
            "- [x] [P2-T4] Pytest",
            encoding="utf-8",
        )
        (feature_dir / "spec.md").write_text("# Spec\n", encoding="utf-8")

        template_dir = mem_path / ".github" / "prompts"
        template_dir.mkdir(parents=True)
        (template_dir / "execute-plan-template.md").write_text(
            "TEMPLATE\n", encoding="utf-8"
        )

        # Mock git to be clean
        def mock_run(*args: object, **kwargs: object) -> Mock:
            result = Mock()
            result.stdout = ""
            result.returncode = 0
            return result  # type: ignore[return-value]

        monkeypatch.setattr("subprocess.run", mock_run)

        exit_code = main(
            [
                "execute",
                str(feature_dir),
                "--workspace",
                str(mem_path),
            ]
        )

        assert exit_code == 0
        captured = capsys.readouterr()
        assert "already complete" in captured.out.lower()
