"""Additional tests for the extension-bundled resolve_hard_lock_prompt wrapper stack."""

from __future__ import annotations

import importlib.util
import sys
from io import StringIO
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import MagicMock, patch

import pytest

if TYPE_CHECKING:
    from types import ModuleType

ROOT = Path(__file__).resolve().parents[5]
_BUNDLED_RESOLVER_PATH = (
    ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "scripts"
    / "dev_tools"
    / "resolve_hard_lock_prompt.py"
)
_BUNDLED_SCRIPTS_PATH = str(
    ROOT / "extensions" / "drm-copilot" / "resources" / "scripts"
)


@pytest.fixture
def mem_path(tmp_path: Path) -> Path:
    """Alias fixture for cosmetic tmp_path->mem_path test parameter naming."""
    return tmp_path


def _load_module_from_path(module_name: str, file_path: Path) -> ModuleType:
    """Load a Python module directly from a file path for bundled-resource tests.

    Args:
        module_name: Unique module name used for this import instance.
        file_path: Absolute path to the Python module file.

    Returns:
        The imported module object.

    Raises:
        AssertionError: When a module spec cannot be created for the file.
    """
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    if spec is None or spec.loader is None:
        raise AssertionError(f"Unable to load module spec for {file_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules.pop(module_name, None)
    spec.loader.exec_module(module)
    return module


def test_bundled_resolver_uses_parent_issue_for_versioned_plan_path() -> None:
    """Use the parent issue.md when the bundled resolver target lives under v2."""
    module = _load_module_from_path(
        "ext_bundled_resolver_parent_issue",
        _BUNDLED_RESOLVER_PATH,
    )
    workspace_root = Path.cwd()
    target = (
        workspace_root / "docs" / "features" / "active" / "feature-1" / "v2" / "plan.md"
    )
    issue_path = (
        workspace_root / "docs" / "features" / "active" / "feature-1" / "issue.md"
    )

    def _exists(self: Path) -> bool:
        return self == issue_path

    def _read_text(self: Path, encoding: str = "utf-8") -> str:
        del encoding
        if self == issue_path:
            return "- Work Mode: full-feature\n"
        raise FileNotFoundError(str(self))

    try:
        with (
            patch.object(Path, "exists", _exists),
            patch.object(Path, "read_text", _read_text),
        ):
            result = module.resolve_prompt(
                "Mode=${work-mode};Reason=${fallback-reason}",
                target,
                workspace_root,
            )

        assert "Mode=full-feature" in result
        assert "Reason=none" in result
    finally:
        sys.modules.pop("ext_bundled_resolver_parent_issue", None)


def test_bundled_resolver_mode_fallback_when_issue_unreadable() -> None:
    """Fail closed when the bundled resolver cannot read issue.md."""
    module = _load_module_from_path(
        "ext_bundled_resolver_unreadable_issue",
        _BUNDLED_RESOLVER_PATH,
    )
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

    try:
        with (
            patch.object(Path, "exists", _exists),
            patch.object(Path, "read_text", _read_text),
        ):
            result = module.resolve_prompt(
                "Mode=${work-mode};Reason=${fallback-reason}",
                target,
                workspace_root,
            )

        assert "Mode=full-feature" in result
        assert "issue.md unreadable; fail closed to full-feature" in result
    finally:
        sys.modules.pop("ext_bundled_resolver_unreadable_issue", None)


def test_bundled_copy_to_clipboard_no_mechanism() -> None:
    """Return False when the bundled resolver cannot find any clipboard path."""
    module = _load_module_from_path(
        "ext_bundled_resolver_clipboard_none",
        _BUNDLED_RESOLVER_PATH,
    )

    try:
        with (
            patch.dict("sys.modules", {"pyperclip": None}),
            patch("shutil.which", return_value=None),
            patch("sys.stderr", new_callable=StringIO),
        ):
            assert module.copy_to_clipboard("test text") is False
    finally:
        sys.modules.pop("ext_bundled_resolver_clipboard_none", None)


def test_bundled_copy_to_clipboard_with_pyperclip_success() -> None:
    """Return True when bundled clipboard copy succeeds through pyperclip."""
    mock_pyperclip = MagicMock()
    mock_pyperclip.copy = MagicMock()

    with patch.dict("sys.modules", {"pyperclip": mock_pyperclip}):
        module = _load_module_from_path(
            "ext_bundled_resolver_clipboard_success",
            _BUNDLED_RESOLVER_PATH,
        )

        try:
            assert module.copy_to_clipboard("test text") is True
            mock_pyperclip.copy.assert_called_once_with("test text")
        finally:
            sys.modules.pop("ext_bundled_resolver_clipboard_success", None)


def test_bundled_copy_to_clipboard_pyperclip_failure_fallback() -> None:
    """Fall back to a validated native clipboard command after pyperclip fails."""
    mock_pyperclip = MagicMock()
    mock_pyperclip.copy = MagicMock(side_effect=RuntimeError("pyperclip failed"))

    with (
        patch.dict("sys.modules", {"pyperclip": mock_pyperclip}),
        patch("shutil.which", return_value="/usr/bin/clip"),
        patch("subprocess.run") as mock_run,
    ):
        module = _load_module_from_path(
            "ext_bundled_resolver_clipboard_fallback",
            _BUNDLED_RESOLVER_PATH,
        )

        try:
            assert module.copy_to_clipboard("test text") is True
            assert mock_run.called
        finally:
            sys.modules.pop("ext_bundled_resolver_clipboard_fallback", None)


def test_bundled_resolve_prompt_outside_workspace() -> None:
    """Keep the absolute target path when the bundled resolver cannot relativize it."""
    module = _load_module_from_path(
        "ext_bundled_resolver_outside_workspace",
        _BUNDLED_RESOLVER_PATH,
    )
    workspace_root = Path("/workspace/A")
    target = Path("/workspace/B/plan.md")

    try:
        with patch("pathlib.Path.relative_to", side_effect=ValueError):
            result = module.resolve_prompt("Plan=${plan-path}", target, workspace_root)

        assert str(target).replace("\\", "/") in result
    finally:
        sys.modules.pop("ext_bundled_resolver_outside_workspace", None)


def test_bundled_main_target_not_found(mem_path: Path) -> None:
    """Return a clear error when the bundled resolver target path is missing."""
    workspace = mem_path / "workspace"
    workspace.mkdir()
    template_root = mem_path / "bundled-codex"
    template_root.mkdir()
    (template_root / "execute-hard-lock.prompt.md").write_text(
        "bundled ${plan-path}",
        encoding="utf-8",
    )
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_resolver_target_missing",
            _BUNDLED_RESOLVER_PATH,
        )
        sys.argv = [
            "resolve_hard_lock_prompt.py",
            "--target",
            str(workspace / "missing.md"),
            "--workspace",
            str(workspace),
            "--template-root",
            str(template_root),
        ]

        with patch("sys.stderr", new_callable=StringIO) as mock_stderr:
            exit_code = module.main()

        assert exit_code == 1
        assert "Target file not found" in mock_stderr.getvalue()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_resolver_target_missing", None)


def test_bundled_main_clipboard_copy_fails(mem_path: Path) -> None:
    """Keep bundled resolver success when clipboard copy is unavailable."""
    workspace = mem_path / "workspace"
    workspace.mkdir()
    template_root = mem_path / "bundled-codex"
    template_root.mkdir()
    (template_root / "execute-hard-lock.prompt.md").write_text(
        "bundled ${plan-path}",
        encoding="utf-8",
    )
    target_file = workspace / "docs" / "plan.md"
    target_file.parent.mkdir(parents=True)
    target_file.write_text("# Plan", encoding="utf-8")
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_resolver_clipboard_fails",
            _BUNDLED_RESOLVER_PATH,
        )
        sys.argv = [
            "resolve_hard_lock_prompt.py",
            "--target",
            str(target_file),
            "--workspace",
            str(workspace),
            "--template-root",
            str(template_root),
        ]

        with (
            patch.object(module, "copy_to_clipboard", return_value=False),
            patch("sys.stdout", new_callable=StringIO),
            patch("sys.stderr", new_callable=StringIO) as mock_stderr,
        ):
            exit_code = module.main()

        assert exit_code == 0
        assert "Could not copy to clipboard" in mock_stderr.getvalue()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_resolver_clipboard_fails", None)


def test_bundled_main_template_read_error(mem_path: Path) -> None:
    """Return a clear error when the bundled resolver cannot read the template."""
    workspace = mem_path / "workspace"
    workspace.mkdir()
    template_root = mem_path / "bundled-codex"
    template_root.mkdir()
    template_file = template_root / "execute-hard-lock.prompt.md"
    template_file.write_text("bundled ${plan-path}", encoding="utf-8")
    target_file = workspace / "docs" / "plan.md"
    target_file.parent.mkdir(parents=True)
    target_file.write_text("# Plan", encoding="utf-8")
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_resolver_template_read_error",
            _BUNDLED_RESOLVER_PATH,
        )
        sys.argv = [
            "resolve_hard_lock_prompt.py",
            "--target",
            str(target_file),
            "--workspace",
            str(workspace),
            "--template-root",
            str(template_root),
        ]

        with (
            patch.object(Path, "read_text", side_effect=OSError("Read error")),
            patch("sys.stderr", new_callable=StringIO) as mock_stderr,
        ):
            exit_code = module.main()

        assert exit_code == 1
        assert "Error reading template" in mock_stderr.getvalue()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_resolver_template_read_error", None)
