"""Compatibility wrapper for extension-side hard-lock prompt resolution.

Purpose:
    Preserve the bundled-script entry point while delegating hard-lock prompt
    resolution behavior to the bundled package implementation.

Usage:
    python resolve_hard_lock_prompt.py --target <plan> --workspace <workspace>

Flow:
    1. Ensure `resources/scripts/` is importable at runtime.
    2. Inject the bundled `.github/codex` template root when the caller omitted it.
    3. Import `dev_tools.resolve_hard_lock_prompt` from bundled sources.
    4. Invoke the bundled CLI entrypoint in-process with the active CLI args.

Invariants / Constraints:
    - No prompt-resolution business logic is implemented in this wrapper.
    - Argument contract is owned by the bundled resolver module and forwarded
      unchanged except for additive `--template-root` injection.

Side Effects:
    Imports bundled resolver code and executes it in the current Python process.
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
    """Execute bundled hard-lock prompt resolution in-process.

    Injects `--template-root` pointing to the extension's bundled hard-lock
    prompt templates when the caller did not already provide one.
    """
    _ensure_bundled_scripts_import_path()

    template_root = str(
        Path(__file__).resolve().parent.parent / "customizations" / ".github" / "codex"
    )
    if "--template-root" not in sys.argv:
        sys.argv.extend(["--template-root", template_root])

    module = importlib.import_module("dev_tools.resolve_hard_lock_prompt")
    module_main = cast(Callable[[], int], module.main)
    return int(module_main())


if __name__ == "__main__":
    raise SystemExit(main())
