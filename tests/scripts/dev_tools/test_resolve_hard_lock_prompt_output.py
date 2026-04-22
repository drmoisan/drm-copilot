"""Tests for --output and --quiet flags in the hard-lock prompt resolver."""

from io import StringIO
from pathlib import Path
from unittest.mock import patch

from scripts.dev_tools.resolve_hard_lock_prompt import main


def _build_workspace(
    mem_fs_path: Path, template_body: str = "Plan: ${plan-path}"
) -> tuple[Path, Path]:
    """Build a minimal in-memory workspace and return (workspace, target) paths.

    Purpose:
        Deduplicate the common workspace scaffolding used across --output and
        --quiet behavior tests. Creates a ``workspace/`` directory with a
        ``.github/codex`` template and a ``plan.md`` target file.

    Args:
        mem_fs_path (Path): In-memory filesystem root from the fixture.
        template_body (str): Template text to write to the execute template.

    Returns:
        tuple[Path, Path]: Workspace directory and target plan file paths.

    Side Effects:
        Writes in-memory files and directories inside ``mem_fs_path``.
    """
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    template_dir = workspace / ".github" / "codex"
    template_dir.mkdir(parents=True)
    (template_dir / "execute-hard-lock.prompt.md").write_text(
        template_body,
        encoding="utf-8",
    )
    target_file = workspace / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")
    return workspace, target_file


def test_main_output_absolute_path_writes_resolved_prompt(mem_fs_path: Path) -> None:
    """--output with an absolute path writes the resolved prompt verbatim."""
    workspace, target_file = _build_workspace(mem_fs_path)
    output_path = mem_fs_path / "resolved-absolute.md"

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--workspace",
                str(workspace),
                "--output",
                str(output_path),
            ],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ),
        patch("sys.stdout", new_callable=StringIO),
        patch("sys.stderr", new_callable=StringIO),
    ):
        exit_code = main()

    assert exit_code == 0
    assert output_path.read_text(encoding="utf-8") == "Plan: plan.md"


def test_main_output_relative_path_resolves_against_workspace(
    mem_fs_path: Path,
) -> None:
    """--output with a relative path resolves against --workspace."""
    workspace, target_file = _build_workspace(mem_fs_path)

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--workspace",
                str(workspace),
                "--output",
                "artifacts/resolved-relative.md",
            ],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ),
        patch("sys.stdout", new_callable=StringIO),
        patch("sys.stderr", new_callable=StringIO),
    ):
        exit_code = main()

    expected = workspace / "artifacts" / "resolved-relative.md"
    assert exit_code == 0
    assert expected.read_text(encoding="utf-8") == "Plan: plan.md"


def test_main_output_relative_path_resolves_against_cwd_when_workspace_omitted(
    mem_fs_path: Path,
) -> None:
    """--output with a relative path and no --workspace resolves against cwd."""
    template_dir = mem_fs_path / ".github" / "codex"
    template_dir.mkdir(parents=True)
    (template_dir / "execute-hard-lock.prompt.md").write_text(
        "Plan: ${plan-path}",
        encoding="utf-8",
    )
    target_file = mem_fs_path / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--output",
                "cwd-resolved.md",
            ],
        ),
        patch("pathlib.Path.cwd", return_value=mem_fs_path),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ),
        patch("sys.stdout", new_callable=StringIO),
        patch("sys.stderr", new_callable=StringIO),
    ):
        exit_code = main()

    expected = mem_fs_path / "cwd-resolved.md"
    assert exit_code == 0
    assert expected.read_text(encoding="utf-8").startswith("Plan: ")


def test_main_output_creates_missing_parent_directories(mem_fs_path: Path) -> None:
    """--output creates deeply nested parent directories as needed."""
    workspace, target_file = _build_workspace(mem_fs_path)
    nested_output = mem_fs_path / "deep" / "nested" / "dir" / "resolved.md"

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--workspace",
                str(workspace),
                "--output",
                str(nested_output),
            ],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ),
        patch("sys.stdout", new_callable=StringIO),
        patch("sys.stderr", new_callable=StringIO),
    ):
        exit_code = main()

    assert exit_code == 0
    assert nested_output.exists()
    assert nested_output.read_text(encoding="utf-8") == "Plan: plan.md"


def test_main_output_write_failure_returns_exit_one_with_stderr(
    mem_fs_path: Path,
) -> None:
    """--output write failure reports the error to stderr and exits 1."""
    workspace, target_file = _build_workspace(mem_fs_path)
    output_path = mem_fs_path / "resolved-failing.md"

    original_write_text = Path.write_text

    def _selective_failure(
        self: Path, data: str, encoding: str | None = None, **_kw: object
    ) -> int:
        """Fail only the output-file write; allow all other writes to succeed."""
        del _kw
        # Only the output-file write path fails; template reads and the test
        # workspace scaffolding must continue working normally.
        if str(self) == str(output_path):
            raise OSError("disk full")
        return original_write_text(self, data, encoding=encoding)

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--workspace",
                str(workspace),
                "--output",
                str(output_path),
            ],
        ),
        patch.object(Path, "write_text", _selective_failure),
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 1
    assert "Error writing output file" in mock_stderr.getvalue()


def test_main_output_with_quiet_suppresses_stdout_and_clipboard(
    mem_fs_path: Path,
) -> None:
    """--output plus --quiet suppresses both stdout and the clipboard attempt."""
    workspace, target_file = _build_workspace(mem_fs_path)
    output_path = mem_fs_path / "resolved-quiet.md"

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--workspace",
                str(workspace),
                "--output",
                str(output_path),
                "--quiet",
            ],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
        ) as mock_copy,
        patch("sys.stdout", new_callable=StringIO) as mock_stdout,
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 0
    assert output_path.read_text(encoding="utf-8") == "Plan: plan.md"
    assert mock_stdout.getvalue() == ""
    assert mock_stderr.getvalue() == ""
    mock_copy.assert_not_called()


def test_main_output_without_quiet_preserves_stdout_and_clipboard(
    mem_fs_path: Path,
) -> None:
    """--output without --quiet keeps the stdout print and clipboard attempt."""
    workspace, target_file = _build_workspace(mem_fs_path)
    output_path = mem_fs_path / "resolved-verbose.md"

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--workspace",
                str(workspace),
                "--output",
                str(output_path),
            ],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ) as mock_copy,
        patch("sys.stdout", new_callable=StringIO) as mock_stdout,
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 0
    assert output_path.read_text(encoding="utf-8") == "Plan: plan.md"
    assert "Plan: plan.md" in mock_stdout.getvalue()
    assert "Copied to clipboard" in mock_stderr.getvalue()
    mock_copy.assert_called_once_with("Plan: plan.md")


def test_main_without_output_preserves_baseline_stdout_and_clipboard(
    mem_fs_path: Path,
) -> None:
    """Omitting --output keeps the original stdout + clipboard + exit-0 behavior."""
    workspace, target_file = _build_workspace(mem_fs_path)

    with (
        patch(
            "sys.argv",
            ["script", "--target", str(target_file), "--workspace", str(workspace)],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ) as mock_copy,
        patch("sys.stdout", new_callable=StringIO) as mock_stdout,
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 0
    assert "Plan: plan.md" in mock_stdout.getvalue()
    assert "Copied to clipboard" in mock_stderr.getvalue()
    mock_copy.assert_called_once_with("Plan: plan.md")


def test_main_quiet_without_output_is_hard_error(mem_fs_path: Path) -> None:
    """--quiet without --output is rejected as a hard error with exit code 1."""
    workspace, target_file = _build_workspace(mem_fs_path)

    with (
        patch(
            "sys.argv",
            [
                "script",
                "--target",
                str(target_file),
                "--workspace",
                str(workspace),
                "--quiet",
            ],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
        ) as mock_copy,
        patch("sys.stdout", new_callable=StringIO) as mock_stdout,
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 1
    assert "--quiet requires --output" in mock_stderr.getvalue()
    assert mock_stdout.getvalue() == ""
    mock_copy.assert_not_called()
