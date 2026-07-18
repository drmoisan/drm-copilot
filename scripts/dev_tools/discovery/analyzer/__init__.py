"""Domain-neutral analyzer framework and the repository inventory analyzer.

Purpose:
    Expose the public analyzer surface: the ``Analyzer`` protocol and the
    ``run_analyzer`` runner (from ``pipeline``) and the CLI ``main`` entry point
    (from ``cli``). Concrete analyzers plug into the ``Analyzer`` protocol; the
    inventory analyzer is the first concrete implementation.

Invariants / Constraints:
    - Domain specificity (markers, source root, globs) is supplied at runtime by
      the domain profile, never hardcoded in this package.
    - Re-exports are resolved lazily via module ``__getattr__`` (PEP 562) so
      importing this package does not eagerly import sibling submodules. This
      tolerates a partially-populated package (for example before the shared
      package root or a sibling submodule is present) without swallowing real
      import errors, which surface on attribute access.

Side Effects:
    None at import time.
"""

from __future__ import annotations

from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    from scripts.dev_tools.discovery.analyzer.cli import main
    from scripts.dev_tools.discovery.analyzer.pipeline import Analyzer, run_analyzer

__all__ = ["Analyzer", "main", "run_analyzer"]


def __getattr__(name: str) -> Any:
    """Resolve public re-exports lazily (PEP 562 module-level ``__getattr__``).

    Args:
        name: Attribute name requested on the package.

    Returns:
        The resolved public symbol.

    Raises:
        AttributeError: When ``name`` is not part of the public surface.
    """
    if name == "main":
        from scripts.dev_tools.discovery.analyzer.cli import main

        return main
    if name in ("Analyzer", "run_analyzer"):
        from scripts.dev_tools.discovery.analyzer import pipeline

        return getattr(pipeline, name)
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
