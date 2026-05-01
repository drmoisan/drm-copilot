"""Parity tests for bundled push-down customization support modules."""

from __future__ import annotations

import importlib
import importlib.util
import sys
from importlib.machinery import SourceFileLoader
from pathlib import Path
from typing import TYPE_CHECKING, Protocol, cast

if TYPE_CHECKING:
    from types import ModuleType

REPO_ROOT = Path(__file__).resolve().parents[3]
ROOT_FILESYSTEM_MODULE = "scripts.dev_tools.push_down_copilot_customizations_filesystem"
BUNDLED_FILESYSTEM_PATH = REPO_ROOT / (
    "extensions/drm-copilot/resources/scripts/dev_tools/"
    "push_down_copilot_customizations_filesystem.py"
)


class PushDownFilesystem(Protocol):
    """Represent the observable filesystem adapter operations used by parity tests."""

    def list_files(self, root: Path) -> list[Path]:
        """Return files below the supplied root."""
        ...

    def is_dir(self, path: Path) -> bool:
        """Return whether the path is a directory."""
        ...

    def is_file(self, path: Path) -> bool:
        """Return whether the path is a file."""
        ...

    def read_text(self, path: Path) -> str:
        """Return UTF-8 text from the supplied file path."""
        ...


class PushDownFilesystemModule(Protocol):
    """Represent a module that exposes the real push-down filesystem adapter."""

    RealPushDownFileSystem: type[PushDownFilesystem]


def _load_python_module(module_name: str, module_path: Path) -> ModuleType:
    """Load a Python module from a checked-in source path."""
    loader = SourceFileLoader(module_name, str(module_path))
    spec = importlib.util.spec_from_loader(module_name, loader)
    if spec is None:
        raise AssertionError(f"Unable to load module spec for {module_path}")

    module = importlib.util.module_from_spec(spec)
    sys.modules[module_name] = module
    loader.exec_module(module)
    return module


def _as_push_down_filesystem_module(module: ModuleType) -> PushDownFilesystemModule:
    """Return a typed view over a dynamically loaded filesystem module."""
    if not hasattr(module, "RealPushDownFileSystem"):
        raise AssertionError("Module does not expose RealPushDownFileSystem")
    return cast("PushDownFilesystemModule", module)


def _relative_paths(paths: list[Path]) -> list[str]:
    """Return repository-relative POSIX paths for deterministic comparison."""
    return [path.relative_to(REPO_ROOT).as_posix() for path in paths]


def test_bundled_push_down_filesystem_matches_observable_reads() -> None:
    """Compare root and bundled filesystem adapter output for the same fixture input."""
    root_module = _as_push_down_filesystem_module(
        importlib.import_module(ROOT_FILESYSTEM_MODULE)
    )
    bundled_module = _as_push_down_filesystem_module(
        _load_python_module(
            "bundled_push_down_copilot_customizations_filesystem",
            BUNDLED_FILESYSTEM_PATH,
        )
    )
    root_fs = root_module.RealPushDownFileSystem()
    bundled_fs = bundled_module.RealPushDownFileSystem()
    fixture_root = REPO_ROOT / ".github"
    fixture_file = fixture_root / "copilot-instructions.md"

    assert _relative_paths(bundled_fs.list_files(fixture_root)) == _relative_paths(
        root_fs.list_files(fixture_root)
    )
    assert bundled_fs.is_dir(fixture_root) == root_fs.is_dir(fixture_root)
    assert bundled_fs.is_file(fixture_file) == root_fs.is_file(fixture_file)
    assert bundled_fs.read_text(fixture_file) == root_fs.read_text(fixture_file)
