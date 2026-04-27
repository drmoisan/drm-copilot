"""Run the Codex-native converter module entry point.

Purpose:
    Delegate ``python -m scripts.dev_tools.codex_native_converter`` to the
    authoritative Typer CLI implementation.

Usage:
    Python invokes this module when the package is executed with ``-m``.

Flow:
    Import ``main`` from ``cli.py`` and execute it under ``SystemExit``.

Invariants / Constraints:
    The module adds no behavior beyond delegating to the CLI entry point.

Side Effects:
    Executes the requested CLI command.
"""

from scripts.dev_tools.codex_native_converter.cli import main

if __name__ == "__main__":
    raise SystemExit(main())
