"""Compatibility wrapper for extension-side potential-to-issue promotion.

Purpose:
    Preserve the bundled-script entry point while delegating promotion behavior
    to the bundled package implementation.

Usage:
    python potential_to_issue.py --potential-path <path> --promotion-type <type> \
    --work-mode <mode>

Flow:
    1. Ensure `resources/scripts/` is importable at runtime.
    2. Import `dev_tools.potential_to_issue` from bundled sources.
    3. Invoke the bundled CLI entrypoint in-process with unmodified CLI args.

Invariants / Constraints:
    - No promotion business logic is implemented in this wrapper.
        - Argument contract is owned by the bundled promotion module and forwarded
            unchanged.

Side Effects:
    Imports bundled promotion code and executes it in the current Python process.
"""

from __future__ import annotations

import importlib
import sys
from collections.abc import Callable
from pathlib import Path
from typing import cast


def _ensure_bundled_scripts_import_path() -> None:
    """Prepend bundled `resources/scripts` directory to ``sys.path``."""
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)

    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    """Execute bundled potential-to-issue entrypoint in-process."""
    _ensure_bundled_scripts_import_path()
    module = importlib.import_module("dev_tools.potential_to_issue")
    module_main = cast(Callable[[], None], module.main)
    module_main()
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
