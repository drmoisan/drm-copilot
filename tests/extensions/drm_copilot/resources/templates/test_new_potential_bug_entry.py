"""Tests for the extension-bundled new_potential_bug_entry.py wrapper template."""

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
    / "new_potential_bug_entry.py"
)


def _load_module_from_path(module_name: str, file_path: Path) -> ModuleType:
    """Load a Python module directly from a file path for wrapper import tests.

    Purpose:
        Import the current template file without relying on package installation so
        wrapper-template behavior can be validated directly from disk.

    Args:
        module_name (str): Unique name used to register the loaded module in
            ``sys.modules`` for this test session.
        file_path (Path): Absolute path to the template file that should be loaded.

    Returns:
        ModuleType: The loaded module object for direct wrapper assertions.

    Raises:
        AssertionError: Raised when Python cannot create an import spec for the
            requested file path.

    Side Effects:
        Mutates ``sys.modules`` for the duration of the load.
    """
    spec = importlib.util.spec_from_file_location(module_name, file_path)
    if spec is None or spec.loader is None:
        raise AssertionError(f"Unable to load module spec for {file_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules.pop(module_name, None)
    spec.loader.exec_module(module)
    return module


def test_imports_bundled_module() -> None:
    """Verify the wrapper imports successfully and exposes a ``main`` entrypoint.

    Purpose:
        Lock in the template's importability from disk so follow-on wrapper tests
        can focus on delegation behavior instead of module-load failures.

    Args:
        None.

    Returns:
        None: Assertions validate the imported module surface.

    Raises:
        AssertionError: Raised when the template fails to import or does not
            expose a ``main`` entrypoint.

    Side Effects:
        Temporarily mutates ``sys.path`` and ``sys.modules`` while loading the
        template from disk.
    """
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_npbe_imports",
            _TEMPLATE_PATH,
        )
        assert hasattr(module, "main")
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_npbe_imports", None)


def test_ensure_path_adds_scripts_dir_to_sys_path() -> None:
    """Verify _ensure_bundled_scripts_import_path inserts the scripts dir at index 0.

    Purpose:
        Define the wrapper-path contract so the future thin adapter prepends the
        bundled scripts directory ahead of ambient interpreter paths.

    Args:
        None.

    Returns:
        None: Assertions validate the expected ``sys.path`` mutation contract.

    Raises:
        AssertionError: Raised when the bundled scripts directory is not added or
            is inserted anywhere other than index ``0``.

    Side Effects:
        Temporarily mutates ``sys.path`` and ``sys.modules`` while loading the
        wrapper module from disk.
    """
    expected_scripts_dir = str(_TEMPLATE_PATH.resolve().parent.parent / "scripts")
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_npbe_ensure_adds",
            _TEMPLATE_PATH,
        )
        # Remove the scripts dir first so the insertion branch is the one under test.
        sys.path[:] = [
            path_entry for path_entry in sys.path if path_entry != expected_scripts_dir
        ]

        module._ensure_bundled_scripts_import_path()

        assert (
            expected_scripts_dir in sys.path
        ), f"Expected {expected_scripts_dir!r} to be added to sys.path"
        assert (
            sys.path[0] == expected_scripts_dir
        ), "Scripts dir must be prepended at index 0 for bundled import precedence"
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_npbe_ensure_adds", None)


def test_ensure_path_skips_duplicate_entry() -> None:
    """Verify _ensure_bundled_scripts_import_path does not duplicate an existing entry.

    Purpose:
        Preserve idempotent wrapper path setup so repeated calls do not grow
        ``sys.path`` with duplicate bundled-scripts entries.

    Args:
        None.

    Returns:
        None: Assertions validate the duplicate-guard contract.

    Raises:
        AssertionError: Raised when the bundled scripts directory count changes
            after a duplicate-safe call.

    Side Effects:
        Temporarily mutates ``sys.path`` and ``sys.modules`` while loading the
        wrapper module from disk.
    """
    expected_scripts_dir = str(_TEMPLATE_PATH.resolve().parent.parent / "scripts")
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_npbe_ensure_skip",
            _TEMPLATE_PATH,
        )
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
        sys.modules.pop("ext_npbe_ensure_skip", None)


def test_main_invokes_bundled_entrypoint_and_returns_zero() -> None:
    """Verify main() delegates to the bundled module and returns 0.

    Purpose:
        Lock in the thin-wrapper contract before refactoring so this test fails
        against the current in-template implementation and passes once the wrapper
        delegates to ``dev_tools.new_potential_bug_entry``.

    Args:
        None.

    Returns:
        None: Assertions validate the wrapper contract directly.

    Raises:
        AssertionError: Raised when the wrapper does not return ``0`` or fails to
            invoke the bundled module entrypoint exactly once.

    Side Effects:
        Temporarily patches the template module's import pathway and restores
        ``sys.path`` and ``sys.modules`` afterwards.
    """
    original_sys_path = list(sys.path)

    try:
        module = _load_module_from_path(
            "ext_npbe_main_test",
            _TEMPLATE_PATH,
        )
        mock_bundled = MagicMock()
        mock_bundled.main = MagicMock()

        # Patch the wrapper's dynamic import boundary so the test observes only the
        # delegation contract, not real bundled CLI execution.
        with patch.object(module.importlib, "import_module", return_value=mock_bundled):
            result = module.main()

        assert result == 0, "main() must return 0 after the bundled delegation succeeds"
        mock_bundled.main.assert_called_once()
    finally:
        sys.path[:] = original_sys_path
        sys.modules.pop("ext_npbe_main_test", None)
