"""Compatibility wrapper for extension-side PR context collection.

Purpose:
    Preserve the historical bundled-script entry point while delegating all
    collection/rendering behavior to the bundled package implementation.

Usage:
    python collect_pr_context.py --base <ref> --repo-root <path> \
    --out <path> --appendix-out <path>

Flow:
    1. Ensure `resources/scripts/` is importable at runtime.
    2. Import `dev_tools.pr_context.collector.main` from bundled sources.
    3. Invoke collector entrypoint in-process with unmodified CLI args.

Invariants / Constraints:
    - No PR context rendering logic is implemented in this wrapper.
    - Argument contract is owned by the collector module and forwarded unchanged.

Side Effects:
    Imports bundled collector code and executes it in the current Python process.
"""

from __future__ import annotations

import importlib
import sys
from collections.abc import Callable
from pathlib import Path
from typing import cast


def _ensure_bundled_scripts_import_path() -> None:
    """Prepend bundled `resources/scripts` directory to ``sys.path``.

    Purpose:
        Make extension-bundled Python packages importable regardless of the
        destination workspace layout.

    Side Effects:
        Mutates ``sys.path`` by inserting the bundled scripts directory at
        index 0 when not already present.
    """
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)

    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    """Execute bundled PR-context collector entrypoint in-process.

    Purpose:
        Keep the bundled extension script as a thin adapter and avoid duplicated
        PR-context business logic while preserving collector-owned CLI parsing.

    Returns:
        Exit code from bundled collector main function.

    Side Effects:
        Imports the bundled collector module and executes its CLI flow.
    """
    _ensure_bundled_scripts_import_path()
    collector_module = importlib.import_module("dev_tools.pr_context.collector")
    collector_main = cast(Callable[[], int], collector_module.main)

    return collector_main()


if __name__ == "__main__":
    raise SystemExit(main())
