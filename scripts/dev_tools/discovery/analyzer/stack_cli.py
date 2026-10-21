"""Keep fixed stack entry names while delegating consent to the installed CLI."""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools.discovery.analyzer.cli import forward_analyzer

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence
    from pathlib import Path

    from drm_copilot_discovery.analyzer.pipeline import AnalyzerFileSystem


def main_dotnet(
    argv: Sequence[str] | None = None,
    *,
    clock: Callable[[], str] | None = None,
    fs: AnalyzerFileSystem | None = None,
    schema_path: Path | None = None,
) -> int:
    """Forward the fixed dotnet alias without reading source or inventing grants.

    argv (Sequence[str] | None) supplies canonical/process arguments. clock
    (Callable[[], str] | None), fs (AnalyzerFileSystem | None) and schema_path
    (Path | None) retain names but must be None. Return installed int exit or
    unsupported-seam 2. Refusal writes fixed stderr only; installed composition
    owns effects/errors and default read-only analysis. No local I/O occurs.
    """
    return forward_analyzer("dotnet", argv, clock=clock, fs=fs, schema_path=schema_path)


def main_vsto(
    argv: Sequence[str] | None = None,
    *,
    clock: Callable[[], str] | None = None,
    fs: AnalyzerFileSystem | None = None,
    schema_path: Path | None = None,
) -> int:
    """Forward the fixed vsto alias; installed selection retains consent checks.

    argv (Sequence[str] | None) supplies canonical/process arguments. clock
    (Callable[[], str] | None), fs (AnalyzerFileSystem | None) and schema_path
    (Path | None) retain names but must be None. Return installed int exit or
    unsupported-seam 2. Refusal writes fixed stderr only; installed composition
    owns effects/errors. No optional implementation, profile or source is loaded
    here, and no clock/filesystem callback is invoked before validated selection.
    """
    return forward_analyzer("vsto", argv, clock=clock, fs=fs, schema_path=schema_path)
