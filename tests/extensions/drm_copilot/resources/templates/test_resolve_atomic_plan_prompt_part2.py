"""Additional tests for the bundled resolve_atomic_plan_prompt resolver stack."""

from __future__ import annotations

import importlib.util
import sys
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
