"""Compatibility wrapper for extension-side orchestration artifact validation.

Purpose:
    Preserve the bundled-script entry point while delegating validation
    behavior to the bundled package implementation.

Usage:
    python validate_orchestration_artifacts.py <artifact_type> <path>
        [--require-complete]

Flow:
    1. Ensure ``resources/scripts/`` is importable at runtime.
    2. Import ``dev_tools.validate_orchestration_artifacts`` from bundled sources.
    3. Invoke the bundled CLI entrypoint in-process with the active CLI args.

Invariants / Constraints:
    - No validation business logic is implemented in this wrapper.
    - Argument contract is owned by the bundled validator module and forwarded
      unchanged.

Side Effects:
    Imports bundled validator code and executes it in the current Python process.
"""

from __future__ import annotations

import importlib
import sys
from pathlib import Path
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Callable


def _ensure_bundled_scripts_import_path() -> None:
    """Prepend bundled ``resources/scripts`` directory to ``sys.path``."""
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)

    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    """Execute bundled orchestration artifact validation in-process."""
    _ensure_bundled_scripts_import_path()

    module = importlib.import_module("dev_tools.validate_orchestration_artifacts")
    module_main = cast("Callable[..., int]", module.main)
    return int(module_main())


if __name__ == "__main__":
    raise SystemExit(main())
