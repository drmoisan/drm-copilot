"""Shared console entry points for the stack-specific analyzers.

Purpose:
    Provide the ``dev.discovery.dotnet`` and ``dev.discovery.vsto`` commands.
    Both delegate to one shared ``_run`` helper that loads a domain profile,
    builds the run context, drives the analyzer end-to-end, and writes one
    Evidence Reference instance per detection. The argparse surface and exit-code
    contract mirror ``dev.discovery.inventory`` (#363).

Coordination note (recorded, not a blocker):
    #363's ``cli.py`` does not factor its profile-load / context-build / run /
    summary flow into a reusable helper (its ``main`` is bound to
    ``InventoryAnalyzer``). This module therefore implements a local ``_run``
    helper rather than copying that flow into duplicated modules. The preferred
    resolution is to propose extracting a reusable CLI-flow helper into #363 at
    integration-branch time; that refactor proposal is an open coordination item.

Responsibilities:
    - Parse the flat argument surface (optional positional ``profile`` path,
      ``--output-dir``, ``--json``).
    - Delegate loading and validation to ``load_domain_profile`` (imported here so
      tests can patch it at this module boundary, per the python.md rule).
    - Map errors to exit codes: ``0`` success; ``1`` on ``DomainProfileError`` or
      ``AnalyzerError`` caught only at the CLI boundary; ``2`` argparse usage
      error (raised by argparse as ``SystemExit(2)``).

Invariants / Constraints:
    - Only ``DomainProfileError`` and ``AnalyzerError`` are caught; there is no
      broad exception handler.
    - ``captured_at`` is produced by an injected clock (defaulting to a UTC
      wall-clock provider) so runs are deterministic under test.

Side Effects:
    Reads the profile file (via ``load_domain_profile``), reads the consumer
    source tree, writes Evidence Reference instances, and prints to stdout and
    stderr.
"""

from __future__ import annotations

import argparse
import json
import sys
from datetime import datetime, timezone
from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.discovery.analyzer.dotnet_inventory import (
    DotnetInventoryAnalyzer,
)
from scripts.dev_tools.discovery.analyzer.inventory import AnalyzerError
from scripts.dev_tools.discovery.analyzer.models import AnalyzerContext
from scripts.dev_tools.discovery.analyzer.pipeline import (
    RealAnalyzerFileSystem,
    run_analyzer,
)
from scripts.dev_tools.discovery.analyzer.vsto_office import VstoOfficeAnalyzer
from scripts.dev_tools.discovery.domain_profile import (
    DEFAULT_PROFILE_FILENAME,
    load_domain_profile,
)
from scripts.dev_tools.discovery.domain_profile_models import DomainProfileError

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence

    from scripts.dev_tools.discovery.analyzer.pipeline import (
        Analyzer,
        AnalyzerFileSystem,
    )


def _utc_now() -> str:
    """Return the current UTC time as a schema-conforming ISO-8601 timestamp."""
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _default_schema_path() -> Path:
    """Return the repository path of the discovery v1 Evidence Reference schema."""
    repo_root = Path(__file__).resolve().parents[4]
    return repo_root / "schemas" / "discovery" / "v1" / "evidence-reference.schema.json"


def _build_parser(prog: str) -> argparse.ArgumentParser:
    """Build the flat argparse surface shared by both entry points.

    Args:
        prog: The program name used in usage and help output.

    Returns:
        A configured ``ArgumentParser`` whose surface matches
        ``dev.discovery.inventory``.
    """
    parser = argparse.ArgumentParser(
        prog=prog,
        description="Scan a consumer source tree into Evidence References.",
    )
    parser.add_argument(
        "profile",
        nargs="?",
        default=DEFAULT_PROFILE_FILENAME,
        help=f"Path to the domain-profile file (default: {DEFAULT_PROFILE_FILENAME}).",
    )
    parser.add_argument(
        "--output-dir",
        default=None,
        help="Override the profile's artifacts.root output location.",
    )
    parser.add_argument(
        "--json",
        action="store_true",
        help="Emit a machine-readable run summary to stdout.",
    )
    return parser


def _run(
    analyzer_factory: Callable[[AnalyzerFileSystem], Analyzer],
    prog: str,
    argv: Sequence[str] | None,
    *,
    clock: Callable[[], str],
    fs: AnalyzerFileSystem | None,
    schema_path: Path | None,
) -> int:
    """Load, run, and summarize one stack analyzer end-to-end.

    Args:
        analyzer_factory: Builds the concrete analyzer from a filesystem seam.
        prog: The program name for argparse.
        argv: Argument vector; ``None`` uses ``sys.argv[1:]``.
        clock: Injected timestamp provider for ``captured_at``.
        fs: Injected filesystem seam; defaults to the real filesystem.
        schema_path: Injected schema-file path; defaults to the repository schema.

    Returns:
        ``0`` on success; ``1`` on a domain or analyzer error. Argparse raises
        ``SystemExit(2)`` for usage errors before this returns.
    """
    parser = _build_parser(prog)
    args = parser.parse_args(argv)
    seam: AnalyzerFileSystem = fs if fs is not None else RealAnalyzerFileSystem()
    resolved_schema = schema_path if schema_path is not None else _default_schema_path()
    # Profile loading is the first failure boundary; a malformed profile exits 1.
    try:
        profile = load_domain_profile(Path(args.profile))
    except DomainProfileError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    # The output root comes from ``--output-dir`` when given, else the profile.
    artifact_root = (
        Path(args.output_dir) if args.output_dir else Path(profile.artifacts.root)
    )
    ctx = AnalyzerContext(
        source_root=Path(profile.legacy_source.root),
        include=profile.legacy_source.include,
        exclude=profile.legacy_source.exclude,
        artifact_root=artifact_root,
        schema_path=resolved_schema,
        captured_at=clock(),
    )
    analyzer = analyzer_factory(seam)
    # An unreachable root or other analyzer failure is the second boundary (exit 1).
    try:
        result = run_analyzer(analyzer, ctx, seam)
    except AnalyzerError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    # Success output: a machine-readable summary with ``--json``, else a count.
    if args.json:
        summary = {
            "record_count": len(result.records),
            "written_paths": [str(path) for path in result.written_paths],
        }
        print(json.dumps(summary, sort_keys=True, indent=2))
    else:
        print(f"Wrote {len(result.written_paths)} evidence instance(s).")
    return 0


def main_dotnet(
    argv: Sequence[str] | None = None,
    *,
    clock: Callable[[], str] = _utc_now,
    fs: AnalyzerFileSystem | None = None,
    schema_path: Path | None = None,
) -> int:
    """Run the .NET/C# inventory analyzer end-to-end (``dev.discovery.dotnet``)."""
    return _run(
        lambda seam: DotnetInventoryAnalyzer(fs=seam),
        "dev.discovery.dotnet",
        argv,
        clock=clock,
        fs=fs,
        schema_path=schema_path,
    )


def main_vsto(
    argv: Sequence[str] | None = None,
    *,
    clock: Callable[[], str] = _utc_now,
    fs: AnalyzerFileSystem | None = None,
    schema_path: Path | None = None,
) -> int:
    """Run the VSTO/Office analyzer end-to-end (``dev.discovery.vsto``)."""
    return _run(
        lambda seam: VstoOfficeAnalyzer(fs=seam),
        "dev.discovery.vsto",
        argv,
        clock=clock,
        fs=fs,
        schema_path=schema_path,
    )
