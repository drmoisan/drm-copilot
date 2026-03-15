"""Tests for scripts.dev_tools.resolve_hard_lock_prompt."""

from io import StringIO
from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from scripts.dev_tools.resolve_hard_lock_prompt import (
    main,
    resolve_prompt,
)


@pytest.fixture
def mem_path(tmp_path: Path) -> Path:
    """Alias fixture for cosmetic tmp_path->mem_path test parameter rename."""
    return tmp_path


def test_resolve_prompt_basic() -> None:
    """Test basic resolution of ${plan-path} variable."""
    template = "Execute plan at: ${plan-path}"
    workspace_root = Path.cwd()
    target = workspace_root / "docs" / "features" / "active" / "plan.md"

    result = resolve_prompt(template, target, workspace_root)

    assert "docs/features/active/plan.md" in result
    assert "${plan-path}" not in result


def test_resolve_prompt_forward_slashes() -> None:
    """Test that backslashes are converted to forward slashes."""
    template = "Plan: ${plan-path}"
    workspace_root = Path.cwd()
    target = workspace_root / "subdir" / "nested" / "plan.md"

    result = resolve_prompt(template, target, workspace_root)

    # Should use forward slashes regardless of platform
    assert "subdir/nested/plan.md" in result
    assert "\\" not in result
    assert "${plan-path}" not in result


def test_resolve_prompt_outside_workspace() -> None:
    """Test fallback when target is outside workspace."""
    template = "External plan: ${plan-path}"
    workspace_root = Path("/workspace/A")
    target = Path("/workspace/B/plan.md")

    # Force relative_to to fail by mocking
    with patch("pathlib.Path.relative_to", side_effect=ValueError):
        result = resolve_prompt(template, target, workspace_root)

        # Should contain the full target path with forward slashes
        assert (
            "workspace/B/plan.md" in result or str(target).replace("\\", "/") in result
        )


def test_resolve_prompt_empty_template() -> None:
    """Test resolution with empty template."""
    template = ""
    workspace_root = Path.cwd()
    target = workspace_root / "plan.md"

    result = resolve_prompt(template, target, workspace_root)

    assert result == ""


def test_resolve_prompt_no_variables() -> None:
    """Test template without any variables."""
    template = "This is a static template with no variables."
    workspace_root = Path.cwd()
    target = workspace_root / "plan.md"

    result = resolve_prompt(template, target, workspace_root)

    assert result == template


def test_resolve_prompt_multiple_occurrences() -> None:
    """Test that all occurrences of ${plan-path} are replaced."""
    template = "First: ${plan-path}\n" "Second: ${plan-path}\n" "Third: ${plan-path}"
    workspace_root = Path.cwd()
    target = workspace_root / "docs" / "plan.md"

    result = resolve_prompt(template, target, workspace_root)

    # All occurrences should be replaced
    assert result.count("${plan-path}") == 0
    assert result.count("docs/plan.md") == 3


def test_resolve_prompt_nested_path() -> None:
    """Test resolution with deeply nested path."""
    template = "Path: ${plan-path}"
    workspace_root = Path.cwd()
    target = (
        workspace_root
        / "docs"
        / "features"
        / "active"
        / "2026-01-30-feature-123"
        / "v2"
        / "plan.md"
    )

    result = resolve_prompt(template, target, workspace_root)

    expected = "docs/features/active/2026-01-30-feature-123/v2/plan.md"
    assert expected in result
    assert "${plan-path}" not in result


def test_resolve_prompt_injects_work_mode_from_issue_marker() -> None:
    """Inject ${work-mode} from issue.md marker when available."""
    template = "Plan=${plan-path};Mode=${work-mode};Reason=${fallback-reason}"
    workspace_root = Path.cwd()
    target = workspace_root / "docs" / "features" / "active" / "feature-1" / "plan.md"
    issue_path = (
        workspace_root / "docs" / "features" / "active" / "feature-1" / "issue.md"
    )

    def _exists(self: Path) -> bool:
        return self == issue_path

    def _read_text(self: Path, encoding: str = "utf-8") -> str:
        del encoding
        if self == issue_path:
            return "- Work Mode: minor-audit\n"
        raise FileNotFoundError(str(self))

    with (
        patch.object(Path, "exists", _exists),
        patch.object(Path, "read_text", _read_text),
    ):
        result = resolve_prompt(template, target, workspace_root)

    assert "Mode=minor-audit" in result
    assert "Reason=none" in result


def test_resolve_prompt_uses_parent_issue_for_versioned_plan_path() -> None:
    """Use parent folder issue.md when target is inside a versioned folder."""
    template = "Mode=${work-mode};Reason=${fallback-reason}"
    workspace_root = Path.cwd()
    target = (
        workspace_root / "docs" / "features" / "active" / "feature-1" / "v2" / "plan.md"
    )
    parent_issue = (
        workspace_root / "docs" / "features" / "active" / "feature-1" / "issue.md"
    )

    def _exists(self: Path) -> bool:
        return self == parent_issue

    def _read_text(self: Path, encoding: str = "utf-8") -> str:
        del encoding
        if self == parent_issue:
            return "- Work Mode: full-feature\n"
        raise FileNotFoundError(str(self))

    with (
        patch.object(Path, "exists", _exists),
        patch.object(Path, "read_text", _read_text),
    ):
        result = resolve_prompt(template, target, workspace_root)

    assert "Mode=full-feature" in result
    assert "Reason=none" in result


def _test_resolve_prompt_windows_v2_path_uses_forward_slashes() -> None:
    """Normalize Windows-style versioned plan paths to forward slashes."""
    template = "Plan=${plan-path}"
    workspace_root = Path(r"C:\workspace")
    target = Path(r"C:\workspace\docs\features\active\feature-1\v2\plan.md")

    result = resolve_prompt(template, target, workspace_root)

    assert "docs/features/active/feature-1/v2/plan.md" in result
    assert "\\" not in result


test_resolve_prompt_uses_forward_slash_path_for_versioned_windows_style_target = (
    _test_resolve_prompt_windows_v2_path_uses_forward_slashes
)


def test_resolve_prompt_mode_fallback_when_issue_unreadable() -> None:
    """Emit unreadable fallback reason when issue.md cannot be read."""
    template = "Mode=${work-mode};Reason=${fallback-reason}"
    workspace_root = Path.cwd()
    target = workspace_root / "docs" / "features" / "active" / "feature-1" / "plan.md"
    issue_path = (
        workspace_root / "docs" / "features" / "active" / "feature-1" / "issue.md"
    )

    def _exists(self: Path) -> bool:
        return self == issue_path

    def _read_text(self: Path, encoding: str = "utf-8") -> str:
        del encoding
        raise OSError("boom")

    with (
        patch.object(Path, "exists", _exists),
        patch.object(Path, "read_text", _read_text),
    ):
        result = resolve_prompt(template, target, workspace_root)

    assert "Mode=full-feature" in result
    assert "issue.md unreadable; fail closed to full-feature" in result


def test_copy_to_clipboard_with_pyperclip_success() -> None:
    """Test successful clipboard copy with pyperclip."""
    mock_pyperclip = MagicMock()
    mock_pyperclip.copy = MagicMock()

    with patch.dict("sys.modules", {"pyperclip": mock_pyperclip}):
        # Force reimport to use the mock
        # Reload to pick up the patched pyperclip
        import importlib

        from scripts.dev_tools import resolve_hard_lock_prompt

        importlib.reload(resolve_hard_lock_prompt)

        result = resolve_hard_lock_prompt.copy_to_clipboard("test text")

        assert result is True
        mock_pyperclip.copy.assert_called_once_with("test text")


def test_copy_to_clipboard_pyperclip_failure_fallback() -> None:
    """Test fallback to system commands when pyperclip fails."""
    mock_pyperclip = MagicMock()
    mock_pyperclip.copy = MagicMock(side_effect=RuntimeError("pyperclip failed"))

    with (
        patch.dict("sys.modules", {"pyperclip": mock_pyperclip}),
        patch("shutil.which", return_value="/usr/bin/clip"),
        patch("subprocess.run") as mock_run,
    ):
        # Force reimport
        import importlib

        from scripts.dev_tools import resolve_hard_lock_prompt

        importlib.reload(resolve_hard_lock_prompt)

        result = resolve_hard_lock_prompt.copy_to_clipboard("test text")

        assert result is True
        assert mock_run.called


def test_copy_to_clipboard_no_mechanism() -> None:
    """Test failure when no clipboard mechanism is available."""
    # Mock pyperclip as unavailable
    with (
        patch.dict("sys.modules", {"pyperclip": None}),
        patch("shutil.which", return_value=None),
    ):
        import importlib

        from scripts.dev_tools import resolve_hard_lock_prompt

        importlib.reload(resolve_hard_lock_prompt)

        # Capture stderr to avoid test noise
        with patch("sys.stderr", new_callable=StringIO):
            result = resolve_hard_lock_prompt.copy_to_clipboard("test text")

        assert result is False


def test_main_success(mem_path: Path) -> None:
    """Test successful main execution."""
    # Create workspace structure
    workspace = mem_path / "workspace"
    workspace.mkdir()

    # Create template file
    template_dir = workspace / ".github" / "codex"
    template_dir.mkdir(parents=True)
    template_file = template_dir / "execute-hard-lock.prompt.md"
    template_file.write_text("Plan: ${plan-path}", encoding="utf-8")

    # Create target file
    target_dir = workspace / "docs"
    target_dir.mkdir()
    target_file = target_dir / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")

    with (
        patch(
            "sys.argv",
            ["script", "--target", str(target_file), "--workspace", str(workspace)],
        ),
        patch(
            "scripts.dev_tools.resolve_hard_lock_prompt.copy_to_clipboard",
            return_value=True,
        ),
        patch("sys.stdout", new_callable=StringIO) as mock_stdout,
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    assert exit_code == 0
    stdout_output = mock_stdout.getvalue()
    assert "docs/plan.md" in stdout_output
    assert "${plan-path}" not in stdout_output
    assert "✓ Copied to clipboard" in mock_stderr.getvalue()


def test_main_prefers_template_root_before_workspace_codex(mem_path: Path) -> None:
    """Prefer the explicit template root over workspace codex templates."""
    workspace = mem_path / "workspace"
    workspace.mkdir()
    workspace_template_dir = workspace / ".github" / "codex"
    workspace_template_dir.mkdir(parents=True)
    (workspace_template_dir / "execute-hard-lock.prompt.md").write_text(
        "workspace ${plan-path}",
        encoding="utf-8",
    )
    template_root = mem_path / "bundled-codex"
    template_root.mkdir()
    (template_root / "execute-hard-lock.prompt.md").write_text(
        "bundled ${plan-path}",
        encoding="utf-8",
    )
    target_file = workspace / "docs" / "plan.md"
    target_file.parent.mkdir(parents=True)
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
                "--template-root",
                str(template_root),
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
    assert "bundled docs/plan.md" in mock_stdout.getvalue()


def test_main_falls_back_to_workspace_codex_when_template_root_template_is_missing(
    mem_path: Path,
) -> None:
    """Fall back to workspace codex when the explicit template root lacks it."""
    workspace = mem_path / "workspace"
    workspace.mkdir()
    workspace_template_dir = workspace / ".github" / "codex"
    workspace_template_dir.mkdir(parents=True)
    (workspace_template_dir / "execute-hard-lock.prompt.md").write_text(
        "workspace ${plan-path}",
        encoding="utf-8",
    )
    template_root = mem_path / "bundled-codex"
    template_root.mkdir()
    target_file = workspace / "docs" / "plan.md"
    target_file.parent.mkdir(parents=True)
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
                "--template-root",
                str(template_root),
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
    assert "workspace docs/plan.md" in mock_stdout.getvalue()


def test_main_reports_checked_template_paths_when_template_lookup_fails(
    mem_path: Path,
) -> None:
    """Report every checked template path when no template candidate exists."""
    workspace = mem_path / "workspace"
    workspace.mkdir()
    template_root = mem_path / "bundled-codex"
    template_root.mkdir()
    target_file = workspace / "docs" / "plan.md"
    target_file.parent.mkdir(parents=True)
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
                "--template-root",
                str(template_root),
            ],
        ),
        patch("sys.stderr", new_callable=StringIO) as mock_stderr,
    ):
        exit_code = main()

    expected_workspace_template = (
        workspace / ".github" / "codex" / "execute-hard-lock.prompt.md"
    )
    expected_bundled_template = template_root / "execute-hard-lock.prompt.md"
    stderr_output = mock_stderr.getvalue()

    assert exit_code == 1
    assert str(expected_bundled_template) in stderr_output
    assert str(expected_workspace_template) in stderr_output
