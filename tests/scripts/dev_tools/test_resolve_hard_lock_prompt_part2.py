"""Additional tests for scripts.dev_tools.resolve_hard_lock_prompt."""

from io import StringIO
from pathlib import Path
from unittest.mock import patch

from scripts.dev_tools.resolve_hard_lock_prompt import main


def test_main_template_not_found(mem_fs_path: Path) -> None:
    """Test main when template file doesn't exist."""
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()

    target_file = workspace / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")

    with (
        patch(
            "sys.argv",
            ["script", "--target", str(target_file), "--workspace", str(workspace)],
        ),
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 1
    error_output = mock_stderr.getvalue()
    assert "not found. Checked locations:" in error_output
    assert "execute-hard-lock.prompt.md" in error_output


def test_main_target_not_found(mem_fs_path: Path) -> None:
    """Test main when target file doesn't exist."""
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    template_dir = workspace / ".github" / "codex"
    template_dir.mkdir(parents=True)
    (template_dir / "execute-hard-lock.prompt.md").write_text(
        "Plan: ${plan-path}",
        encoding="utf-8",
    )
    target_file = workspace / "nonexistent.md"

    with (
        patch(
            "sys.argv",
            ["script", "--target", str(target_file), "--workspace", str(workspace)],
        ),
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 1
    assert "Target file not found" in mock_stderr.getvalue()


def test_main_clipboard_copy_fails(mem_fs_path: Path) -> None:
    """Test main when clipboard copy fails."""
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    template_dir = workspace / ".github" / "codex"
    template_dir.mkdir(parents=True)
    (template_dir / "execute-hard-lock.prompt.md").write_text(
        "Plan: ${plan-path}",
        encoding="utf-8",
    )
    target_file = workspace / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")

    with (
        patch(
            "sys.argv",
            ["script", "--target", str(target_file), "--workspace", str(workspace)],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=False,
        ),
        patch("sys.stdout", new_callable=StringIO),
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 0
    assert "✗ Could not copy to clipboard" in mock_stderr.getvalue()


def test_main_default_workspace(mem_fs_path: Path) -> None:
    """Test main with default workspace (cwd)."""
    template_dir = mem_fs_path / ".github" / "codex"
    template_dir.mkdir(parents=True)
    (template_dir / "execute-hard-lock.prompt.md").write_text(
        "Plan: ${plan-path}",
        encoding="utf-8",
    )
    target_file = mem_fs_path / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")

    with (
        patch("sys.argv", ["script", "--target", str(target_file)]),
        patch("pathlib.Path.cwd", return_value=mem_fs_path),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ),
        patch("sys.stdout", new_callable=StringIO) as mock_stdout,
        patch("sys.stderr", new_callable=StringIO),
    ):
        exit_code = main()

    assert exit_code == 0
    assert "plan.md" in mock_stdout.getvalue()


def test_main_template_read_error(mem_fs_path: Path) -> None:
    """Test main when template file cannot be read."""
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    template_dir = workspace / ".github" / "codex"
    template_dir.mkdir(parents=True)
    (template_dir / "execute-hard-lock.prompt.md").write_text(
        "Plan: ${plan-path}",
        encoding="utf-8",
    )
    target_file = workspace / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")

    with (
        patch(
            "sys.argv",
            ["script", "--target", str(target_file), "--workspace", str(workspace)],
        ),
        patch("pathlib.Path.read_text", side_effect=OSError("Read error")),
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 1
    assert "Error reading template" in mock_stderr.getvalue()


def test_main_resume_template_kind(mem_fs_path: Path) -> None:
    """Resolve resume template when --template-kind resume is provided."""
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    template_dir = workspace / ".github" / "codex"
    template_dir.mkdir(parents=True)
    (template_dir / "execute-hard-lock.prompt.md").write_text(
        "Execute ${plan-path}",
        encoding="utf-8",
    )
    (template_dir / "resume-hard-lock.prompt.md").write_text(
        "Resume ${plan-path} mode=${work-mode}",
        encoding="utf-8",
    )
    issue_file = workspace / "docs" / "issue.md"
    issue_file.parent.mkdir(parents=True)
    issue_file.write_text("- Work Mode: full-feature\n", encoding="utf-8")
    target_file = workspace / "docs" / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--workspace",
                str(workspace),
                "--template-kind",
                "resume",
            ],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ),
        patch("sys.stdout", new_callable=StringIO) as mock_stdout,
        patch("sys.stderr", new_callable=StringIO),
    ):
        exit_code = main()

    assert exit_code == 0
    assert "Resume docs/plan.md" in mock_stdout.getvalue()
    assert "mode=full-feature" in mock_stdout.getvalue()
