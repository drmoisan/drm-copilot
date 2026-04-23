"""Additional tests for the bundled resolve_atomic_plan_prompt resolver stack."""

from __future__ import annotations

import argparse
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
    / "resolve_file_prompt.py"
)
_BUNDLED_SCRIPTS_PATH = str(
    ROOT / "extensions" / "drm-copilot" / "resources" / "scripts"
)


def _load_module_from_path(module_name: str, file_path: Path) -> ModuleType:
    """Load a Python module directly from a file path for bundled-resource tests.

    Args:
        module_name: Unique name to register for this import instance.
        file_path: Absolute path to the Python module file.

    Returns:
        ModuleType: Imported module object.

    Raises:
        AssertionError: If a module spec cannot be created for the file.
    """
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    if spec is None or spec.loader is None:
        raise AssertionError(f"Unable to load module spec for {file_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules.pop(module_name, None)
    spec.loader.exec_module(module)
    return module


def test_bundled_resolver_injects_minor_audit_work_mode_and_reason() -> None:
    """Resolve `${work-mode}` and `${fallback-reason}` from a valid marker."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_minor_audit",
            _BUNDLED_RESOLVER_PATH,
        )
        workspace_root = Path.cwd()
        feature_dir = (
            workspace_root
            / "docs"
            / "features"
            / "active"
            / "2026-04-17-bundle-resolve-atomic-plan-prompt-command-152"
        )
        target = feature_dir / "plan.2026-04-17T19-54.md"
        issue_path = feature_dir / "issue.md"

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
            result = module.resolve_prompt(
                "Mode=${work-mode};Reason=${fallback-reason}",
                target,
                workspace_root,
            )

        assert "Mode=minor-audit" in result
        assert "Reason=none" in result
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_minor_audit", None)


def test_bundled_resolver_removes_research_line_when_missing() -> None:
    """Remove the entire `${research}` line when the optional file is absent."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_research_missing",
            _BUNDLED_RESOLVER_PATH,
        )
        workspace_root = Path.cwd()
        target = (
            workspace_root
            / "docs"
            / "features"
            / "active"
            / "2026-04-17-bundle-resolve-atomic-plan-prompt-command-152"
            / "plan.md"
        )
        template = (
            "Line1\n" "Use research at `${research}`\n" "Line3\n" "Spec=${spec}\n"
        )

        def _exists_false(self: Path) -> bool:
            del self
            return False

        with patch.object(Path, "exists", _exists_false):
            result = module.resolve_prompt(template, target, workspace_root)

        assert "`${research}`" not in result
        assert "Use research at" not in result
        assert "Line1" in result
        assert "Line3" in result
        assert "spec.md" in result
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_research_missing", None)


def test_bundled_copy_to_clipboard_uses_validated_fallback() -> None:
    """Use a validated clipboard executable when pyperclip is unavailable."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_clipboard_success",
            _BUNDLED_RESOLVER_PATH,
        )

        def _resolve_executable(executable: str) -> str | None:
            if executable == "clip.exe":
                return "C:/Windows/System32/clip.exe"
            return None

        with (
            patch.object(
                module.pyperclip, "copy", side_effect=RuntimeError("no clipboard")
            ),
            patch.object(module.shutil, "which", side_effect=_resolve_executable),
            patch.object(module.subprocess, "run") as mock_run,
        ):
            assert module.copy_to_clipboard("resolved prompt") is True

        mock_run.assert_called_once()
        invoked_command = mock_run.call_args.args[0]
        assert invoked_command == ["C:/Windows/System32/clip.exe"]
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_clipboard_success", None)


def test_bundled_copy_to_clipboard_reports_failure_when_no_fallback_exists() -> None:
    """Return False after exhausting clipboard fallbacks and report the failure."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_clipboard_failure",
            _BUNDLED_RESOLVER_PATH,
        )
        captured_error = StringIO()

        with (
            patch.object(
                module.pyperclip, "copy", side_effect=RuntimeError("no clipboard")
            ),
            patch.object(module.shutil, "which", return_value=None),
            patch.object(sys, "stderr", captured_error),
        ):
            assert module.copy_to_clipboard("resolved prompt") is False

        assert "pyperclip copy failed: no clipboard" in captured_error.getvalue()
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_clipboard_failure", None)


def test_bundled_resolver_resolves_research_when_present() -> None:
    """Resolve `${research}` when the optional research document exists."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_research_present",
            _BUNDLED_RESOLVER_PATH,
        )
        workspace_root = Path.cwd()
        feature_dir = (
            workspace_root
            / "docs"
            / "features"
            / "active"
            / "2026-04-17-bundle-resolve-atomic-plan-prompt-command-152"
        )
        target = feature_dir / "plan.2026-04-17T19-54.md"
        template = "Research=${research}\nStory=${user-story}\n"

        def _exists(self: Path) -> bool:
            return self.name in {"research.md", "user-story.md"}

        with patch.object(Path, "exists", _exists):
            result = module.resolve_prompt(template, target, workspace_root)

        assert "research.md" in result
        assert "user-story.md" in result
        assert "${" not in result
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_research_present", None)


def test_bundled_resolver_fails_closed_when_issue_marker_missing() -> None:
    """Fail closed to full-feature when the issue marker is missing."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_missing_marker",
            _BUNDLED_RESOLVER_PATH,
        )
        workspace_root = Path.cwd()
        feature_dir = (
            workspace_root
            / "docs"
            / "features"
            / "active"
            / "2026-04-17-bundle-resolve-atomic-plan-prompt-command-152"
        )
        target = feature_dir / "plan.2026-04-17T19-54.md"
        issue_path = feature_dir / "issue.md"

        def _exists(self: Path) -> bool:
            return self == issue_path

        def _read_text(self: Path, encoding: str = "utf-8") -> str:
            del encoding
            if self == issue_path:
                return "# issue without work mode marker\n"
            raise FileNotFoundError(str(self))

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
        assert "marker missing" in result
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_missing_marker", None)


def test_bundled_main_reports_missing_template() -> None:
    """Exit with code 1 when the template path does not exist."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_main_missing_template",
            _BUNDLED_RESOLVER_PATH,
        )
        captured_error = StringIO()

        with (
            patch.object(
                module.argparse.ArgumentParser,
                "parse_args",
                return_value=argparse.Namespace(
                    template="missing-template.md",
                    target="plan.md",
                    workspace=None,
                ),
            ),
            patch.object(module.Path, "exists", return_value=False),
            patch.object(sys, "stderr", captured_error),
        ):
            assert module.main() == 1

        assert "Template file not found" in captured_error.getvalue()
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_main_missing_template", None)


def test_bundled_main_reports_missing_target() -> None:
    """Exit with code 1 when the target path does not exist."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_main_missing_target",
            _BUNDLED_RESOLVER_PATH,
        )
        captured_error = StringIO()

        def _exists(self: Path) -> bool:
            return self.name == "prompt.md"

        with (
            patch.object(
                module.argparse.ArgumentParser,
                "parse_args",
                return_value=argparse.Namespace(
                    template="prompt.md",
                    target="missing-plan.md",
                    workspace=None,
                ),
            ),
            patch.object(module.Path, "exists", _exists),
            patch.object(sys, "stderr", captured_error),
        ):
            assert module.main() == 1

        assert "Target file not found" in captured_error.getvalue()
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_main_missing_target", None)


def test_bundled_main_reports_template_read_errors() -> None:
    """Exit with code 1 when the template file cannot be read."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_main_read_error",
            _BUNDLED_RESOLVER_PATH,
        )
        captured_error = StringIO()

        with (
            patch.object(
                module.argparse.ArgumentParser,
                "parse_args",
                return_value=argparse.Namespace(
                    template="prompt.md",
                    target="plan.md",
                    workspace=None,
                ),
            ),
            patch.object(module.Path, "exists", return_value=True),
            patch.object(module.Path, "read_text", side_effect=OSError("Disk error")),
            patch.object(sys, "stderr", captured_error),
        ):
            assert module.main() == 1

        assert "Error reading template: Disk error" in captured_error.getvalue()
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_main_read_error", None)


def test_bundled_main_reports_processing_errors() -> None:
    """Exit with code 1 when prompt resolution raises a processing error."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_main_processing_error",
            _BUNDLED_RESOLVER_PATH,
        )
        captured_error = StringIO()

        with (
            patch.object(
                module.argparse.ArgumentParser,
                "parse_args",
                return_value=argparse.Namespace(
                    template="prompt.md",
                    target="plan.md",
                    workspace=None,
                ),
            ),
            patch.object(module.Path, "exists", return_value=True),
            patch.object(module.Path, "read_text", return_value="Prompt ${file}"),
            patch.object(
                module, "resolve_prompt", side_effect=ValueError("bad placeholders")
            ),
            patch.object(sys, "stderr", captured_error),
        ):
            assert module.main() == 1

        assert "Error processing prompt: bad placeholders" in captured_error.getvalue()
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_main_processing_error", None)


def test_bundled_main_prints_stdout_when_clipboard_copy_is_unavailable() -> None:
    """Print the resolved prompt to stdout when clipboard copy is unavailable."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_main_stdout_fallback",
            _BUNDLED_RESOLVER_PATH,
        )
        captured_output = StringIO()
        captured_error = StringIO()

        with (
            patch.object(
                module.argparse.ArgumentParser,
                "parse_args",
                return_value=argparse.Namespace(
                    template="prompt.md",
                    target="plan.md",
                    workspace=None,
                ),
            ),
            patch.object(module.Path, "exists", return_value=True),
            patch.object(module.Path, "read_text", return_value="Prompt ${file}"),
            patch.object(module, "resolve_prompt", return_value="Resolved prompt body"),
            patch.object(module, "copy_to_clipboard", return_value=False),
            patch.object(sys, "stdout", captured_output),
            patch.object(sys, "stderr", captured_error),
        ):
            assert module.main() == 0

        assert "Resolved prompt body" in captured_output.getvalue()
        assert (
            "Could not copy to clipboard; printing resolved prompt to stdout."
            in captured_error.getvalue()
        )
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_main_stdout_fallback", None)


def test_bundled_main_resolves_relative_target_against_workspace_argument() -> None:
    """Resolve a relative target path against the provided workspace root."""
    original_sys_path = list(sys.path)
    try:
        if _BUNDLED_SCRIPTS_PATH not in sys.path:
            sys.path.insert(0, _BUNDLED_SCRIPTS_PATH)
        module = _load_module_from_path(
            "ext_rapp_bundled_main_workspace_relative_target",
            _BUNDLED_RESOLVER_PATH,
        )
        workspace_root = Path.cwd()
        resolved_targets: list[Path] = []

        def _exists(self: Path) -> bool:
            if self == Path("prompt.md"):
                return True
            return self == (
                workspace_root
                / "docs"
                / "features"
                / "active"
                / "2026-04-17-bundle-resolve-atomic-plan-prompt-command-152"
                / "plan.2026-04-17T19-54.md"
            )

        def _resolve_prompt(template: str, target: Path, cwd: Path) -> str:
            del template
            resolved_targets.append(target)
            assert cwd == workspace_root
            return str(target)

        with (
            patch.object(
                module.argparse.ArgumentParser,
                "parse_args",
                return_value=argparse.Namespace(
                    template="prompt.md",
                    target="docs/features/active/2026-04-17-bundle-resolve-atomic-plan-prompt-command-152/plan.2026-04-17T19-54.md",
                    workspace=str(workspace_root),
                ),
            ),
            patch.object(module.Path, "exists", _exists),
            patch.object(module.Path, "read_text", return_value="Prompt ${file}"),
            patch.object(module, "resolve_prompt", side_effect=_resolve_prompt),
            patch.object(module, "copy_to_clipboard", return_value=True),
        ):
            assert module.main() == 0

        assert resolved_targets == [
            workspace_root
            / "docs"
            / "features"
            / "active"
            / "2026-04-17-bundle-resolve-atomic-plan-prompt-command-152"
            / "plan.2026-04-17T19-54.md"
        ]
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_bundled_main_workspace_relative_target", None)
