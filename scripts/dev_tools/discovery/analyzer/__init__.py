"""Retain lazy analyzer exports with exact authoritative legacy protocol identities."""

from __future__ import annotations

from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from drm_copilot_discovery.analyzer.pipeline import Analyzer, run_analyzer

    from scripts.dev_tools.discovery.analyzer.cli import main

__all__ = ["Analyzer", "main", "run_analyzer"]


def __getattr__(name: str) -> object:
    """Resolve supported name (str) lazily; return its original exported object.

    Analyzer/run_analyzer retain runtime legacy pipeline identity, while main is
    the compatibility forwarding callable. Unknown names raise AttributeError.
    Imports have normal module-loading effects; no analysis or I/O is initiated.
    """
    # CLI and protocol exports remain separate so importing values needs no CLI.
    if name == "main":
        from scripts.dev_tools.discovery.analyzer.cli import main

        return main
    if name in ("Analyzer", "run_analyzer"):
        from drm_copilot_discovery.analyzer import pipeline

        return getattr(pipeline, name)
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
