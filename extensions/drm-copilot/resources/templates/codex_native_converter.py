"""Compatibility wrapper for the bundled Codex-native converter.

Purpose:
    Preserve an extension-side Python entry point that delegates converter
    execution to the bundled ``dev_tools`` package published with the extension
    resources.
"""

from __future__ import annotations

import importlib
import sys
from pathlib import Path


def _ensure_bundled_scripts_import_path() -> None:
    """Prepend bundled `resources/scripts` directory to ``sys.path``."""

    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)
    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    """Execute the bundled Codex-native converter in-process."""

    _ensure_bundled_scripts_import_path()
    module = importlib.import_module("dev_tools.codex_native_converter.cli")
    module.main()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
