"""Compatibility wrapper for extension-side atomic-plan prompt resolution.

Purpose:
    Preserve a stable bundled-script entry point while delegating atomic-plan
    prompt resolution to the bundled resolver module under `resources/scripts`.

Usage:
    python resolve_atomic_plan_prompt.py --target <plan> --workspace <root>

Flow:
    1. Ensure `resources/scripts/` is importable.
    2. Inject the bundled atomic-plan prompt template when `--template` is absent.
    3. Import `dev_tools.resolve_file_prompt` from bundled sources.
    4. Execute the bundled resolver in-process and return its exit code.
"""

from __future__ import annotations

import importlib
import sys
from collections.abc import Callable
from pathlib import Path
from typing import cast


def _ensure_bundled_scripts_import_path() -> None:
    """Prepend bundled `resources/scripts` directory to `sys.path`."""
    scripts_dir = Path(__file__).resolve().parent.parent / "scripts"
    scripts_dir_str = str(scripts_dir)
    if scripts_dir_str not in sys.path:
        sys.path.insert(0, scripts_dir_str)


def main() -> int:
    """Execute bundled atomic-plan prompt resolution in-process.

    Purpose:
        Keep the wrapper free of prompt-resolution business logic while ensuring
        the bundled atomic-plan prompt template is supplied when the caller does
        not pass `--template` explicitly.

    Args:
        None.

    Returns:
        int: Exit code returned by the bundled resolver module.

    Raises:
        None explicitly. Import or resolver failures propagate to the caller.

    Side Effects:
        Mutates `sys.argv` additively when `--template` is absent and imports the
        bundled resolver module in the current Python process.
    """
    _ensure_bundled_scripts_import_path()

    template_path = (
        Path(__file__).resolve().parent.parent
        / "customizations"
        / ".github"
        / "prompts"
        / "generate-atomic-plan.prompt.md"
    )
    if "--template" not in sys.argv:
        sys.argv.extend(["--template", str(template_path)])

    module = importlib.import_module("dev_tools.resolve_file_prompt")
    module_main = cast("Callable[[], int]", module.main)
    return int(module_main())


if __name__ == "__main__":
    raise SystemExit(main())
