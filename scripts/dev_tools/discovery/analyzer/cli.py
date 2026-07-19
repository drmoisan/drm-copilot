"""Console entry point for the repository inventory analyzer.

Purpose:
    Provide the ``dev.discovery.inventory`` command. It loads a domain profile,
    constructs the ``InventoryAnalyzer``, runs the analyzer end-to-end, and
    writes one Evidence Reference instance per inventoried unit.

Responsibilities:
    - Parse a flat argument surface (optional positional ``profile`` path,
      ``--output-dir``, ``--json``).
    - Delegate loading and validation to ``load_domain_profile`` (imported here
      so tests can patch it at this module boundary).
    - Map errors to exit codes: ``0`` success; ``1`` on ``DomainProfileError`` or
      ``AnalyzerError`` caught at the CLI boundary; ``2`` argparse usage error.

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

from scripts.dev_tools.discovery.analyzer.inventory import (
    AnalyzerError,
    InventoryAnalyzer,
)
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

    from scripts.dev_tools.discovery.analyzer.pipeline import AnalyzerFileSystem
    from scripts.dev_tools.discovery.domain_profile_models import DomainProfile


def _utc_now() -> str:
    """Return the current UTC time as a schema-conforming ISO-8601 timestamp."""
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _default_schema_path() -> Path:
    """Return the repository path of the discovery v1 Evidence Reference schema."""
    repo_root = Path(__file__).resolve().parents[4]
    return repo_root / "schemas" / "discovery" / "v1" / "evidence-reference.schema.json"


def parse_args(argv: Sequence[str] | None = None) -> argparse.Namespace:
    """Parse the flat command-line surface.

    Args:
        argv: Argument vector; ``None`` uses ``sys.argv[1:]``.

    Returns:
        A namespace with ``profile`` (str), ``output_dir`` (str | None), and
        ``json`` (bool).
    """
    parser = argparse.ArgumentParser(
        prog="dev.discovery.inventory",
        description="Inventory a consumer source tree into Evidence References.",
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
    return parser.parse_args(argv)


def _build_context(
    profile: DomainProfile,
    output_dir: str | None,
    schema_path: Path,
    clock: Callable[[], str],
) -> AnalyzerContext:
    """Assemble the run context from the resolved profile and CLI options."""
    artifact_root = Path(output_dir) if output_dir else Path(profile.artifacts.root)
    return AnalyzerContext(
        source_root=Path(profile.legacy_source.root),
        include=profile.legacy_source.include,
        exclude=profile.legacy_source.exclude,
        artifact_root=artifact_root,
        schema_path=schema_path,
        captured_at=clock(),
    )


def main(
    argv: Sequence[str] | None = None,
    *,
    clock: Callable[[], str] = _utc_now,
    fs: AnalyzerFileSystem | None = None,
    schema_path: Path | None = None,
) -> int:
    """Run the inventory analyzer end-to-end.

    Args:
        argv: Argument vector; ``None`` uses ``sys.argv[1:]``.
        clock: Injected timestamp provider for ``captured_at``.
        fs: Injected filesystem seam; defaults to the real filesystem.
        schema_path: Injected schema-file path; defaults to the repository schema.

    Returns:
        ``0`` on success; ``1`` on a domain or analyzer error. Argparse raises
        ``SystemExit(2)`` for usage errors before this returns.
    """
    args = parse_args(argv)
    seam: AnalyzerFileSystem = fs if fs is not None else RealAnalyzerFileSystem()
    resolved_schema = schema_path if schema_path is not None else _default_schema_path()
    try:
        profile = load_domain_profile(Path(args.profile))
    except DomainProfileError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    ctx = _build_context(profile, args.output_dir, resolved_schema, clock)
    analyzer = InventoryAnalyzer(fs=seam)
    try:
        result = run_analyzer(analyzer, ctx, seam)
    except AnalyzerError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    if args.json:
        summary = {
            "record_count": len(result.records),
            "written_paths": [str(path) for path in result.written_paths],
        }
        print(json.dumps(summary, sort_keys=True, indent=2))
    else:
        print(f"Wrote {len(result.written_paths)} evidence instance(s).")
    return 0
