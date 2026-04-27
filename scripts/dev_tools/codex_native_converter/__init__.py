"""Expose the public package surface for the Codex-native converter.

Purpose:
    Provide the package-level import that higher-level callers use to reach the
    converter CLI entry point.

Usage:
    Import ``main`` from this package when a caller needs the converter's
    command-line entry point.

Flow:
    Re-export the CLI ``main`` function without adding conversion behavior.

Invariants / Constraints:
    The package surface intentionally stays small so the Python CLI remains the
    authoritative converter contract.

Side Effects:
    None.
"""

from scripts.dev_tools.codex_native_converter.cli import main

__all__ = ["main"]
