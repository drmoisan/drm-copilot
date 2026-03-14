"""Tests for the extension-bundled potential_to_issue.py wrapper template."""

from __future__ import annotations

import importlib.util
import sys
from pathlib import Path
from typing import TYPE_CHECKING
from unittest.mock import MagicMock, patch

if TYPE_CHECKING:
    from types import ModuleType

# Workspace root is five levels above this file:
# tests/extensions/drm_copilot/resources/templates/<this file>
ROOT = Path(__file__).resolve().parents[5]

_TEMPLATE_PATH = (
    ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "templates"
    / "potential_to_issue.py"
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


def test_imports_bundled_module() -> None:
    """Verify the wrapper imports successfully and exposes a ``main`` entrypoint."""
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_pti_imports",
            _TEMPLATE_PATH,
        )
        assert hasattr(module, "main")
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_imports", None)


def test_ensure_path_adds_scripts_dir_to_sys_path() -> None:
    """Verify _ensure_bundled_scripts_import_path inserts the scripts dir at index 0.

    When the computed scripts directory is absent from sys.path the function must
    insert it at position 0 so that bundled modules are resolved before any
    conflicting names on the wider path.
    """
    # Derive the scripts dir the same way the wrapper does at runtime.
    expected_scripts_dir = str(_TEMPLATE_PATH.resolve().parent.parent / "scripts")
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_pti_ensure_adds",
            _TEMPLATE_PATH,
        )
        # Remove the scripts dir from sys.path so the guard branch fires.
        sys.path[:] = [p for p in sys.path if p != expected_scripts_dir]

        module._ensure_bundled_scripts_import_path()

        assert (
            expected_scripts_dir in sys.path
        ), f"Expected {expected_scripts_dir!r} to be added to sys.path"
        assert (
            sys.path[0] == expected_scripts_dir
        ), "Scripts dir must be prepended (index 0) for correct import precedence"
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_ensure_adds", None)


def test_ensure_path_skips_duplicate_entry() -> None:
    """Verify _ensure_bundled_scripts_import_path does not duplicate an existing entry.

    When the scripts dir is already present in sys.path the function must leave
    sys.path unchanged so that no duplicate entry is introduced.
    """
    expected_scripts_dir = str(_TEMPLATE_PATH.resolve().parent.parent / "scripts")
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_pti_ensure_skip",
            _TEMPLATE_PATH,
        )
        # Guarantee the scripts dir IS present so the guard branch is skipped.
        if expected_scripts_dir not in sys.path:
            sys.path.insert(0, expected_scripts_dir)

        count_before = sys.path.count(expected_scripts_dir)
        module._ensure_bundled_scripts_import_path()
        count_after = sys.path.count(expected_scripts_dir)

        assert (
            count_after == count_before
        ), "sys.path must not gain a duplicate entry for the scripts dir"
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_ensure_skip", None)


def test_main_invokes_bundled_entrypoint_and_returns_zero() -> None:
    """Verify main() imports the bundled module, invokes its main, and returns 0.

    The bundled ``dev_tools.potential_to_issue`` module is mocked to avoid
    exercising real CLI argument parsing.  The test asserts on the return value and
    on the single call to the bundled entrypoint.
    """
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_pti_main_test",
            _TEMPLATE_PATH,
        )
        # Build a mock bundled module whose .main attribute is separately trackable.
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock()

        # Patch importlib.import_module on the importlib object the wrapper holds so
        # that the bundled module is never actually imported or executed.
        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 0, "main() must always return 0 on success"
        mock_bundled.main.assert_called_once()
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_pti_main_test", None)
