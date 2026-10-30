"""Forward historical inventory entrypoints to the installed, bounded CLI."""

from __future__ import annotations

import sys
from typing import TYPE_CHECKING

from drm_copilot_discovery.cli_arguments import parse_cli_arguments
from drm_copilot_discovery.models import ParseLimits

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence
    from pathlib import Path

    from drm_copilot_discovery.analyzer.pipeline import AnalyzerFileSystem
    from drm_copilot_discovery.cli_arguments import CliError, CliHelp, CliInvocation


def parse_args(argv: Sequence[str] | None = None) -> CliInvocation | CliHelp | CliError:
    """Parse inventory argv through the public bounded parser, without I/O.

    argv (Sequence[str] | None) supplies canonical options; None uses process
    arguments. Return CliInvocation, CliHelp or CliError, never argparse authority.
    Invalid arguments become fixed diagnostics; caller/provider errors propagate.
    No profile, source, schema, clock or filesystem is accessed.
    """
    limits = ParseLimits()
    # Bound the process-vector copy before slicing; explicit vectors stay borrowed.
    selected = argv
    if selected is None:
        selected = (
            sys.argv if len(sys.argv) > limits.artifact_records + 1 else sys.argv[1:]
        )
    return parse_cli_arguments("inventory", selected, limits=limits)


def forward_analyzer(
    command: str,
    argv: Sequence[str] | None,
    *,
    clock: Callable[[], str] | None,
    fs: AnalyzerFileSystem | None,
    schema_path: Path | None,
) -> int:
    """Retain harmless call shapes while refusing unsupported legacy authority.

    command (str) selects a fixed installed
    entry. argv (Sequence[str] | None) is forwarded without copying. clock
    (Callable[[], str] | None), fs (AnalyzerFileSystem | None) and schema_path
    (Path | None) must be None: legacy seams cannot establish v2 capture/grants.
    Return int 2 for unsupported seams, otherwise the installed exit unchanged.
    Refusal writes fixed stderr only; installed execution owns all later effects
    and errors. No supplied value is invoked, formatted, compared or inspected.
    """
    if clock is not None or fs is not None or schema_path is not None:
        print(
            "Legacy analyzer seams are unsupported. Migrate to "
            "dev.discovery.inventory "
            "with --workspace-root and --repository-id; use the installed "
            "CliPorts API for trusted injection. No files were read or written.",
            file=sys.stderr,
        )
        return 2
    # Installed composition retains selection/consent and all publication authority.
    from drm_copilot_discovery.cli import run_installed_cli

    return run_installed_cli(command, argv)


def main(
    argv: Sequence[str] | None = None,
    *,
    clock: Callable[[], str] | None = None,
    fs: AnalyzerFileSystem | None = None,
    schema_path: Path | None = None,
) -> int:
    """Forward canonical inventory arguments without reconstructing legacy context.

    argv (Sequence[str] | None) retains explicit/process options. clock
    (Callable[[], str] | None), fs (AnalyzerFileSystem | None), schema_path
    (Path | None) preserve names but reject non-None legacy seams before access.
    Return installed int exit, including help 0 and invocation refusal 2. Fixed
    refusal or installed streams may be written; installed errors/effects remain
    owned by its boundary. No independent parsing, capture or publication occurs.
    """
    return forward_analyzer(
        "inventory", argv, clock=clock, fs=fs, schema_path=schema_path
    )
