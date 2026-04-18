"""Tests for --output and --quiet flags in the bundled resolve_hard_lock_prompt."""

from __future__ import annotations

import importlib.util
import sys
from io import StringIO
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import patch

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


def _build_workspace(
    mem_fs_path: Path,
) -> tuple[Path, Path, Path]:
    """Build an in-memory workspace with a bundled template root.

    Purpose:
        Deduplicate scaffolding for --output / --quiet tests against the bundled
        resolver. Creates a ``workspace/`` with a target plan file and a
        ``bundled-codex/`` directory containing the execute template.

    Args:
        mem_fs_path (Path): In-memory filesystem root from the fixture.

    Returns:
        tuple[Path, Path, Path]: (workspace, target_file, template_root) paths.

    Side Effects:
        Writes in-memory files inside ``mem_fs_path``.
    """
    workspace = mem_fs_path / "workspace"
    workspace.mkdir()
    template_root = mem_fs_path / "bundled-codex"
    template_root.mkdir()
    (template_root / "execute-hard-lock.prompt.md").write_text(
        "Plan: ${plan-path}",
        encoding="utf-8",
    )
    target_file = workspace / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")
    return workspace, target_file, template_root


def _invoke_bundled_main(
    module_name: str,
    argv_tail: list[str],
    *,
    copy_return: bool | None = True,
) -> tuple[int, str, str]:
    """Invoke the bundled resolver's main with patched argv, stdout, and stderr.

    Purpose:
        Centralize bundled-resolver invocation so each --output / --quiet test
        body stays focused on arrange/assert, not boilerplate.

    Args:
        module_name: Unique module name used for this import instance.
        argv_tail: The argv tokens to append after the program name.
        copy_return: Return value for ``copy_to_clipboard`` patch; when
            ``None``, the clipboard helper is not patched at all (so callers
            can attach their own mocks).

    Returns:
        tuple[int, str, str]: (exit_code, stdout_text, stderr_text).
    """
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(module_name, _BUNDLED_RESOLVER_PATH)
        sys.argv = ["resolve_hard_lock_prompt.py", *argv_tail]

        with (
            patch("sys.stdout", new_callable=StringIO) as mock_stdout,
            patch("sys.stderr", new_callable=StringIO) as mock_stderr,
        ):
            # Only patch clipboard when a return value is provided; leaving it
            # unpatched lets negative-path tests assert the call was suppressed.
            if copy_return is None:
                exit_code = module.main()
            else:
                with patch.object(
                    module, "copy_to_clipboard", return_value=copy_return
                ):
                    exit_code = module.main()
        return exit_code, mock_stdout.getvalue(), mock_stderr.getvalue()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop(module_name, None)


def test_bundled_main_output_absolute_path_writes_resolved_prompt(
    mem_fs_path: Path,
) -> None:
    """Bundled: --output with an absolute path writes the resolved prompt."""
    workspace, target_file, template_root = _build_workspace(mem_fs_path)
    output_path = mem_fs_path / "bundled-absolute.md"

    exit_code, _stdout, _stderr = _invoke_bundled_main(
        "ext_bundled_output_absolute",
        [
            "--target",
            str(target_file),
            "--workspace",
            str(workspace),
            "--template-root",
            str(template_root),
            "--output",
            str(output_path),
        ],
    )

    assert exit_code == 0
    assert output_path.read_text(encoding="utf-8") == "Plan: plan.md"


def test_bundled_main_output_relative_path_resolves_against_workspace(
    mem_fs_path: Path,
) -> None:
    """Bundled: --output with a relative path resolves against --workspace."""
    workspace, target_file, template_root = _build_workspace(mem_fs_path)

    exit_code, _stdout, _stderr = _invoke_bundled_main(
        "ext_bundled_output_relative_workspace",
        [
            "--target",
            str(target_file),
            "--workspace",
            str(workspace),
            "--template-root",
            str(template_root),
            "--output",
            "artifacts/bundled-relative.md",
        ],
    )

    expected = workspace / "artifacts" / "bundled-relative.md"
    assert exit_code == 0
    assert expected.read_text(encoding="utf-8") == "Plan: plan.md"


def test_bundled_main_output_relative_path_resolves_against_cwd_when_workspace_omitted(
    mem_fs_path: Path,
) -> None:
    """Bundled: --output relative path resolves against cwd when no --workspace."""
    template_root = mem_fs_path / "bundled-codex"
    template_root.mkdir()
    (template_root / "execute-hard-lock.prompt.md").write_text(
        "Plan: ${plan-path}",
        encoding="utf-8",
    )
    target_file = mem_fs_path / "plan.md"
    target_file.write_text("# Plan", encoding="utf-8")

    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_output_relative_cwd",
            _BUNDLED_RESOLVER_PATH,
        )
        sys.argv = [
            "resolve_hard_lock_prompt.py",
            "--target",
            str(target_file),
            "--template-root",
            str(template_root),
            "--output",
            "cwd-bundled.md",
        ]
        with (
            patch("pathlib.Path.cwd", return_value=mem_fs_path),
            patch.object(module, "copy_to_clipboard", return_value=True),
            patch("sys.stdout", new_callable=StringIO),
            patch("sys.stderr", new_callable=StringIO),
        ):
            exit_code = module.main()
        expected = mem_fs_path / "cwd-bundled.md"
        assert exit_code == 0
        assert expected.read_text(encoding="utf-8").startswith("Plan: ")
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_output_relative_cwd", None)


def test_bundled_main_output_creates_missing_parent_directories(
    mem_fs_path: Path,
) -> None:
    """Bundled: --output creates missing nested parent directories."""
    workspace, target_file, template_root = _build_workspace(mem_fs_path)
    nested_output = mem_fs_path / "a" / "b" / "c" / "bundled-nested.md"

    exit_code, _stdout, _stderr = _invoke_bundled_main(
        "ext_bundled_output_nested",
        [
            "--target",
            str(target_file),
            "--workspace",
            str(workspace),
            "--template-root",
            str(template_root),
            "--output",
            str(nested_output),
        ],
    )

    assert exit_code == 0
    assert nested_output.exists()
    assert nested_output.read_text(encoding="utf-8") == "Plan: plan.md"


def test_bundled_main_output_write_failure_returns_exit_one_with_stderr(
    mem_fs_path: Path,
) -> None:
    """Bundled: --output write failure reports the error and exits 1."""
    workspace, target_file, template_root = _build_workspace(mem_fs_path)
    output_path = mem_fs_path / "bundled-fail.md"
    original_write_text = Path.write_text

    def _selective_failure(
        self: Path, data: str, encoding: str | None = None, **_kw: object
    ) -> int:
        """Fail only the output-file write; allow all other writes to succeed."""
        del _kw
        if str(self) == str(output_path):
            raise OSError("disk full")
        return original_write_text(self, data, encoding=encoding)

    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_output_write_error",
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
            "--output",
            str(output_path),
        ]
        with (
            patch.object(Path, "write_text", _selective_failure),
            patch("sys.stderr", new_callable=StringIO) as mock_stderr,
        ):
            exit_code = module.main()
        assert exit_code == 1
        assert "Error writing output file" in mock_stderr.getvalue()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_output_write_error", None)


def test_bundled_main_output_with_quiet_suppresses_stdout_and_clipboard(
    mem_fs_path: Path,
) -> None:
    """Bundled: --output plus --quiet suppresses stdout and clipboard call."""
    workspace, target_file, template_root = _build_workspace(mem_fs_path)
    output_path = mem_fs_path / "bundled-quiet.md"

    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_output_quiet",
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
            "--output",
            str(output_path),
            "--quiet",
        ]
        with (
            patch.object(module, "copy_to_clipboard") as mock_copy,
            patch("sys.stdout", new_callable=StringIO) as mock_stdout,
            patch("sys.stderr", new_callable=StringIO) as mock_stderr,
        ):
            exit_code = module.main()
        assert exit_code == 0
        assert output_path.read_text(encoding="utf-8") == "Plan: plan.md"
        assert mock_stdout.getvalue() == ""
        assert mock_stderr.getvalue() == ""
        mock_copy.assert_not_called()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_output_quiet", None)


def test_bundled_main_output_without_quiet_preserves_stdout_and_clipboard(
    mem_fs_path: Path,
) -> None:
    """Bundled: --output without --quiet keeps stdout + clipboard."""
    workspace, target_file, template_root = _build_workspace(mem_fs_path)
    output_path = mem_fs_path / "bundled-verbose.md"

    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_output_verbose",
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
            "--output",
            str(output_path),
        ]
        with (
            patch.object(module, "copy_to_clipboard", return_value=True) as mock_copy,
            patch("sys.stdout", new_callable=StringIO) as mock_stdout,
            patch("sys.stderr", new_callable=StringIO) as mock_stderr,
        ):
            exit_code = module.main()
        assert exit_code == 0
        assert output_path.read_text(encoding="utf-8") == "Plan: plan.md"
        assert "Plan: plan.md" in mock_stdout.getvalue()
        assert "Copied to clipboard" in mock_stderr.getvalue()
        mock_copy.assert_called_once_with("Plan: plan.md")
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_output_verbose", None)


def test_bundled_main_without_output_preserves_baseline_stdout_and_clipboard(
    mem_fs_path: Path,
) -> None:
    """Bundled: omitting --output keeps original stdout + clipboard behavior."""
    workspace, target_file, template_root = _build_workspace(mem_fs_path)

    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_no_output_baseline",
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
            patch.object(module, "copy_to_clipboard", return_value=True) as mock_copy,
            patch("sys.stdout", new_callable=StringIO) as mock_stdout,
            patch("sys.stderr", new_callable=StringIO) as mock_stderr,
        ):
            exit_code = module.main()
        assert exit_code == 0
        assert "Plan: plan.md" in mock_stdout.getvalue()
        assert "Copied to clipboard" in mock_stderr.getvalue()
        mock_copy.assert_called_once_with("Plan: plan.md")
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_no_output_baseline", None)


def test_bundled_main_quiet_without_output_is_hard_error(mem_fs_path: Path) -> None:
    """Bundled: --quiet without --output is a hard error with exit code 1."""
    workspace, target_file, template_root = _build_workspace(mem_fs_path)

    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_bundled_quiet_without_output",
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
            "--quiet",
        ]
        with (
            patch.object(module, "copy_to_clipboard") as mock_copy,
            patch("sys.stdout", new_callable=StringIO) as mock_stdout,
            patch("sys.stderr", new_callable=StringIO) as mock_stderr,
        ):
            exit_code = module.main()
        assert exit_code == 1
        assert "--quiet requires --output" in mock_stderr.getvalue()
        assert mock_stdout.getvalue() == ""
        mock_copy.assert_not_called()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_bundled_quiet_without_output", None)
