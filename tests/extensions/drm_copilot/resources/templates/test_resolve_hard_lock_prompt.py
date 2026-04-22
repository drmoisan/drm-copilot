"""Tests for the extension-bundled resolve_hard_lock_prompt.py wrapper template."""

from __future__ import annotations

import importlib.util
import sys
from io import StringIO
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import MagicMock, patch

if TYPE_CHECKING:
    from types import ModuleType

ROOT = Path(__file__).resolve().parents[5]
_TEMPLATE_PATH = (
    ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "templates"
    / "resolve_hard_lock_prompt.py"
)
_EXPECTED_TEMPLATE_ROOT = (
    ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "customizations"
    / ".github"
    / "codex"
)
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


def _load_module_from_path(module_name: str, file_path: Path) -> ModuleType:
    """Load a Python module directly from a file path for wrapper import tests.

    Args:
        module_name: Unique name to register in sys.modules for this load.
        file_path: Absolute path to the .py file to load.

    Returns:
        The loaded module object.

    Raises:
        AssertionError: If a module spec cannot be created for the given path.
    """
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    if spec is None or spec.loader is None:
        raise AssertionError(f"Unable to load module spec for {file_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules.pop(module_name, None)
    spec.loader.exec_module(module)
    return module


def test_main_injects_bundled_template_root_when_flag_is_absent() -> None:
    """Inject the bundled codex root when the wrapper caller omits --template-root."""
    assert _TEMPLATE_PATH.exists(), f"Expected wrapper to exist at {_TEMPLATE_PATH}"
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_rhlp_injects_template_root",
            _TEMPLATE_PATH,
        )
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock(return_value=0)
        sys.argv = ["resolve_hard_lock_prompt.py", "--target", "C:/workspace/plan.md"]

        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 0
        assert "--template-root" in sys.argv
        template_root_index = sys.argv.index("--template-root")
        assert sys.argv[template_root_index + 1] == str(_EXPECTED_TEMPLATE_ROOT)
        mock_bundled.main.assert_called_once()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rhlp_injects_template_root", None)


def test_main_propagates_bundled_non_zero_exit_code() -> None:
    """Return the delegated bundled resolver exit code instead of masking failures.

    Purpose:
        Protect the wrapper/extension process boundary so missing-target or
        missing-template failures remain visible to the VS Code command runtime.

    Returns:
        None.
    """
    assert _TEMPLATE_PATH.exists(), f"Expected wrapper to exist at {_TEMPLATE_PATH}"
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_rhlp_propagates_nonzero_exit",
            _TEMPLATE_PATH,
        )
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock(return_value=1)
        sys.argv = [
            "resolve_hard_lock_prompt.py",
            "--target",
            "C:/workspace/missing.md",
        ]

        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 1
        mock_bundled.main.assert_called_once()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rhlp_propagates_nonzero_exit", None)


def test_main_preserves_explicit_template_root_when_wrapper_flag_is_present() -> None:
    """Keep a caller-supplied template root instead of appending the bundled one."""
    assert _TEMPLATE_PATH.exists(), f"Expected wrapper to exist at {_TEMPLATE_PATH}"
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)
    explicit_template_root = "C:/caller-provided/codex"

    try:
        module = _load_module_from_path(
            "ext_rhlp_preserves_template_root",
            _TEMPLATE_PATH,
        )
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock(return_value=0)
        sys.argv = [
            "resolve_hard_lock_prompt.py",
            "--target",
            "C:/workspace/plan.md",
            "--template-root",
            explicit_template_root,
        ]

        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 0
        assert sys.argv.count("--template-root") == 1
        template_root_index = sys.argv.index("--template-root")
        assert sys.argv[template_root_index + 1] == explicit_template_root
        mock_bundled.main.assert_called_once()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rhlp_preserves_template_root", None)


def test_bundled_resolver_prefers_template_root_before_workspace_codex(
    mem_fs_path: Path,
) -> None:
    """Prefer the explicit template root before the workspace codex fallback."""
    assert _BUNDLED_RESOLVER_PATH.exists()
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    workspace_template_dir = workspace / ".github" / "codex"
    workspace_template_dir.mkdir(parents=True)
    (workspace_template_dir / "execute-hard-lock.prompt.md").write_text(
        "workspace ${plan-path}",
        encoding="utf-8",
    )
    template_root = mem_fs_path / "bundled-codex"
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
            "ext_bundled_resolver_prefers_template_root",
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
            patch.object(module, "copy_to_clipboard", return_value=True),
            patch("sys.stdout", new_callable=StringIO) as mock_stdout,
            patch("sys.stderr", new_callable=StringIO),
        ):
            exit_code = module.main()

        assert exit_code == 0
        assert "bundled docs/plan.md" in mock_stdout.getvalue()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_resolver_prefers_template_root", None)


def test_bundled_resolver_falls_back_to_workspace_codex_when_template_is_missing(
    mem_fs_path: Path,
) -> None:
    """Fall back to workspace codex when the explicit template root lacks the file."""
    assert _BUNDLED_RESOLVER_PATH.exists()
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    workspace_template_dir = workspace / ".github" / "codex"
    workspace_template_dir.mkdir(parents=True)
    (workspace_template_dir / "execute-hard-lock.prompt.md").write_text(
        "workspace ${plan-path}",
        encoding="utf-8",
    )
    template_root = mem_fs_path / "bundled-codex"
    template_root.mkdir()
    target_file = workspace / "docs" / "plan.md"
    target_file.parent.mkdir(parents=True)
    target_file.write_text("# Plan", encoding="utf-8")
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_resolver_workspace_fallback",
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
            patch.object(module, "copy_to_clipboard", return_value=True),
            patch("sys.stdout", new_callable=StringIO) as mock_stdout,
            patch("sys.stderr", new_callable=StringIO),
        ):
            exit_code = module.main()

        assert exit_code == 0
        assert "workspace docs/plan.md" in mock_stdout.getvalue()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_resolver_workspace_fallback", None)


def test_bundled_resolver_reports_checked_template_paths_on_lookup_failure(
    mem_fs_path: Path,
) -> None:
    """Report both checked template locations when bundled lookup fails."""
    assert _BUNDLED_RESOLVER_PATH.exists()
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    template_root = mem_fs_path / "bundled-codex"
    template_root.mkdir()
    target_file = workspace / "docs" / "plan.md"
    target_file.parent.mkdir(parents=True)
    target_file.write_text("# Plan", encoding="utf-8")
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_resolver_missing_template",
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

        with patch("sys.stderr", new_callable=StringIO) as mock_stderr:
            exit_code = module.main()

        stderr_output = mock_stderr.getvalue()
        assert exit_code == 1
        assert str(template_root / "execute-hard-lock.prompt.md") in stderr_output
        assert (
            str(workspace / ".github" / "codex" / "execute-hard-lock.prompt.md")
            in stderr_output
        )
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_resolver_missing_template", None)


def test_bundled_resolver_injects_work_mode_from_issue_marker() -> None:
    """Inject the bundled resolver work-mode marker from the nearest issue.md."""
    module = _load_module_from_path(
        "ext_bundled_resolver_mode_marker",
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
        if self == issue_path:
            return "- Work Mode: minor-audit\n"
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

        assert "Mode=minor-audit" in result
        assert "Reason=none" in result
    finally:
        sys.modules.pop("ext_bundled_resolver_mode_marker", None)
