"""Preserve the .NET CLI while rejecting unconsented optional legacy execution.

The .NET command keeps its profile/context/pipeline flow and injected I/O seams.
The optional command keeps argument parsing only, then reports the required v2
capture route before profile loading, filesystem construction or source access.
Neither command eagerly imports the optional implementation.
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
    """Return str UTC ISO-8601 time from the host clock; no arguments or writes.

    This default provider has no expected contract errors; tests inject a clock.
    """
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _default_schema_path() -> Path:
    """Return Path of the repository's v1 schema without reading its contents.

    No arguments. Resolves this module path; OSError propagates on resolution
    failures. No writes or optional imports.
    """
    repo_root = Path(__file__).resolve().parents[4]
    return repo_root / "schemas" / "discovery" / "v1" / "evidence-reference.schema.json"


def _build_parser(prog: str) -> argparse.ArgumentParser:
    """Build the flat argparse surface shared by both entry points.

    Args:
        prog (str): The program name used in usage and help output.

    Returns:
        argparse.ArgumentParser with the existing flat inventory argument shape.
        No I/O or expected contract errors occur until parsing is requested.
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
        analyzer_factory (Callable[[AnalyzerFileSystem], Analyzer]): Fixed factory.
        prog (str): The program name for argparse.
        argv (Sequence[str] | None): Arguments; None uses sys.argv[1:].
        clock (Callable[[], str]): Timestamp provider for captured_at.
        fs (AnalyzerFileSystem | None): I/O seam; None uses the real filesystem.
        schema_path (Path | None): Schema path; None selects the repository schema.

    Returns:
        int 0 on success or 1 on a domain/analyzer error. Argparse raises
        SystemExit(0/2) for help/usage. Loads profile/source through existing seams,
        delegates publication policy to run_analyzer, and prints the result.
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
        # Describe the completed pipeline result without granting additional writes.
        summary = {
            "record_count": len(result.records),
            # Preserve the pipeline's explicit publication result in the CLI view.
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
    """Delegate the unchanged .NET CLI flow through its injected boundaries.

    argv (Sequence[str] | None) supplies arguments; clock (Callable[[], str])
    supplies timestamps; fs (AnalyzerFileSystem | None) and schema_path
    (Path | None) supply existing optional seams. Returns int 0/1; argparse raises
    SystemExit for help/usage. Reads the profile/source and prints the pipeline
    summary; publication behavior remains owned by the existing pipeline.
    """
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
    """Retain legacy CLI usage while requiring the consented v2 analysis route.

    argv (Sequence[str] | None) supplies arguments or uses sys.argv. clock
    (Callable[[], str]), fs (AnalyzerFileSystem | None) and schema_path
    (Path | None) retain the historical call shape but are never accessed.
    Returns 1 with a fixed migration error on stderr; argparse raises SystemExit
    with 0 for help or 2 for invalid usage. No profile/source I/O, optional import,
    clock invocation or filesystem construction occurs.
    """
    del clock, fs, schema_path
    _build_parser("dev.discovery.vsto").parse_args(argv)
    print(
        "dev.discovery.vsto requires a v2 InventoryCapture and a configured "
        "ProfileV2 enabling office-vsto; use VstoOfficeAnalyzer.analyze(capture). "
        "No files were read or written.",
        file=sys.stderr,
    )
    return 1
