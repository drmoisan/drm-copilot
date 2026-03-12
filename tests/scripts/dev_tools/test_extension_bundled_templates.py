"""Tests for extension-bundled Python wrapper templates."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from types import ModuleType

ROOT = Path(__file__).resolve().parents[3]


def _load_module_from_path(module_name: str, file_path: Path) -> ModuleType:
    """Load a Python module directly from a file path for wrapper import tests."""
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    if spec is None or spec.loader is None:
        raise AssertionError(f"Unable to load module spec for {file_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules.pop(module_name, None)
    spec.loader.exec_module(module)
    return module


def test_potential_to_issue_template_imports_bundled_module() -> None:
    """Verify the bundled potential_to_issue wrapper imports successfully."""
    template_path = (
        ROOT
        / "extensions"
        / "drm-copilot"
        / "resources"
        / "templates"
        / "potential_to_issue.py"
    )
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "extension_bundled_potential_to_issue_template", template_path
        )
        assert hasattr(module, "main")
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("extension_bundled_potential_to_issue_template", None)


def test_new_active_feature_folder_template_imports_bundled_module() -> None:
    """Verify the bundled new_active_feature_folder wrapper imports successfully."""
    template_path = (
        ROOT
        / "extensions"
        / "drm-copilot"
        / "resources"
        / "templates"
        / "new_active_feature_folder.py"
    )
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "extension_bundled_new_active_feature_folder_template",
            template_path,
        )
        assert hasattr(module, "main")
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop(
            "extension_bundled_new_active_feature_folder_template",
            None,
        )
