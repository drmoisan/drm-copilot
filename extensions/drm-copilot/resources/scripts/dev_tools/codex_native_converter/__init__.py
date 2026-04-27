"""Bridge the bundled extension runner to the authoritative converter package.

Purpose:
    Expose the bundled ``dev_tools.codex_native_converter`` import path that the
    extension wrapper expects while delegating to the authoritative repository
    implementation.
"""

from scripts.dev_tools.codex_native_converter.cli import main

__all__ = ["main"]
