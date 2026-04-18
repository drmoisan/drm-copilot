"""Tests for the extension-bundled resolve_atomic_plan_prompt wrapper."""

from __future__ import annotations

import importlib.util
import sys
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
    / "resolve_atomic_plan_prompt.py"
)
_EXPECTED_TEMPLATE_PATH = (
    ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "customizations"
    / ".github"
    / "prompts"
    / "generate-atomic-plan.prompt.md"
)
_BUNDLED_SCRIPTS_PATH = str(
    ROOT / "extensions" / "drm-copilot" / "resources" / "scripts"
)


def _load_module_from_path(module_name: str, file_path: Path) -> ModuleType:
    """Load a Python module directly from a file path for wrapper tests.

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


def test_main_injects_bundled_template_when_flag_is_absent() -> None:
    """Inject the bundled atomic-plan prompt when the caller omits --template."""
    assert _TEMPLATE_PATH.exists(), f"Expected wrapper to exist at {_TEMPLATE_PATH}"
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_rapp_injects_template",
            _TEMPLATE_PATH,
        )
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock(return_value=0)
        sys.argv = [
            "resolve_atomic_plan_prompt.py",
            "--target",
            "C:/workspace/docs/features/active/feature-152/plan.md",
        ]

        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 0
        assert sys.path[0] == _BUNDLED_SCRIPTS_PATH
        assert sys.argv.count("--template") == 1
        template_index = sys.argv.index("--template")
        assert sys.argv[template_index + 1] == str(_EXPECTED_TEMPLATE_PATH)
        mock_bundled.main.assert_called_once()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_injects_template", None)


def test_main_preserves_explicit_template_when_wrapper_flag_is_present() -> None:
    """Preserve a caller-supplied template path instead of appending a second one."""
    assert _TEMPLATE_PATH.exists(), f"Expected wrapper to exist at {_TEMPLATE_PATH}"
    explicit_template = "C:/caller-provided/generate-atomic-plan.prompt.md"
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_rapp_preserves_template",
            _TEMPLATE_PATH,
        )
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock(return_value=0)
        sys.argv = [
            "resolve_atomic_plan_prompt.py",
            "--target",
            "C:/workspace/docs/features/active/feature-152/plan.md",
            "--template",
            explicit_template,
        ]

        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 0
        assert sys.argv.count("--template") == 1
        template_index = sys.argv.index("--template")
        assert sys.argv[template_index + 1] == explicit_template
        mock_bundled.main.assert_called_once()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_preserves_template", None)


def test_main_propagates_bundled_non_zero_exit_code() -> None:
    """Return the delegated bundled resolver exit code unchanged."""
    assert _TEMPLATE_PATH.exists(), f"Expected wrapper to exist at {_TEMPLATE_PATH}"
    original_argv = list(sys.argv)
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_rapp_propagates_nonzero_exit",
            _TEMPLATE_PATH,
        )
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock(return_value=7)
        sys.argv = [
            "resolve_atomic_plan_prompt.py",
            "--target",
            "C:/workspace/docs/features/active/feature-152/plan.md",
        ]

        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 7
        mock_bundled.main.assert_called_once()
    finally:
        sys.argv = original_argv
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_rapp_propagates_nonzero_exit", None)
