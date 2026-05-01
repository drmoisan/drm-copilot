"""Compatibility wrapper for extension-side active feature folder creation.

Purpose:
    Preserve the bundled-script entry point while delegating folder-creation
    behavior to the bundled package implementation.

Usage:
    python new_active_feature_folder.py --feature-name <name> --type <type> \
    [--issue-number <number>] --work-mode <mode>

Flow:
    1. Ensure `resources/scripts/` is importable at runtime.
    2. Import `dev_tools.new_active_feature_folder` from bundled sources.
    3. Invoke the bundled CLI entrypoint in-process with unmodified CLI args.

Invariants / Constraints:
    - No feature-folder business logic is implemented in this wrapper.
    - Argument contract is owned by the bundled folder-creation module and
      forwarded unchanged.

Side Effects:
    Imports bundled folder-creation code and executes it in the current Python
    process.
"""

from __future__ import annotations

import importlib
import sys
from pathlib import Path
from typing import TYPE_CHECKING, cast

if TYPE_CHECKING:
    from collections.abc import Callable


def _ensure_bundled_scripts_import_path() -> None:
    """Prepend bundled `resources/scripts` directory to ``sys.path``."""
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)

    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    """Execute bundled active-feature-folder entrypoint in-process.

    Injects ``--template-root`` pointing to the extension's bundled
    ``feature-templates`` directory so the downstream module resolves
    templates from the extension rather than the workspace.
    """
    _ensure_bundled_scripts_import_path()

    # Compute the bundled template root relative to this wrapper script.
    template_root = str(Path(__file__).resolve().parent.parent / "feature-templates")
    if "--template-root" not in sys.argv:
        sys.argv.extend(["--template-root", template_root])

    module = importlib.import_module("dev_tools.new_active_feature_folder")
    module_main = cast("Callable[[], None]", module.main)
    module_main()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
