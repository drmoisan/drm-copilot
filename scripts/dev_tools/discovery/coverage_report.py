"""Route explicit legacy files separately from installed workspace coverage.

The public parse/build/render names remain available for existing callers.
They summarize v1 or safe placeholder entries without establishing v2 graph
completeness. This adapter owns only argument, validation and I/O routing.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery.cli import run_installed_cli
from drm_copilot_discovery.report_models import (
    build_coverage_rows as build_coverage_rows,
)
from drm_copilot_discovery.report_models import (
    parse_coverage_ledger as parse_coverage_ledger,
)
from drm_copilot_discovery.report_models import (
    render_coverage_report as render_coverage_report,
)

from scripts.dev_tools.discovery.io import (
    ArtifactValidationError,
    ArtifactValidator,
    read_artifact_text,
    validate_or_raise,
    write_report,
)
from scripts.dev_tools.validate_discovery_artifacts import report_arguments

if TYPE_CHECKING:
    from collections.abc import Sequence


def _default_coverage_ledger_validator(text: str) -> list[str]:
    """Validate text (str) through the lazily loaded upstream v1 validator.

    Returns list[str] errors, empty on success. Propagates upstream exceptions;
    the validator may read a local schema. Lazy binding preserves caller
    injection and keeps schema access out of ordinary adapter imports.
    """
    from scripts.dev_tools.validate_discovery_schema_artifacts import (
        validate_coverage_ledger_text,
    )

    return validate_coverage_ledger_text(text)


def parse_args(argv: Sequence[str] | None) -> argparse.Namespace:
    """Parse argv (Sequence[str] or None) into input/output path arguments.

    Returns argparse.Namespace; None reads sys.argv. Raises SystemExit for help
    or invalid arguments, with argparse output to stdout/stderr. No file I/O.
    """
    parser = argparse.ArgumentParser(
        description="Render a deterministic report from a Coverage Ledger artifact"
    )
    parser.add_argument(
        "--input", required=True, help="Path to the Coverage Ledger artifact JSON file"
    )
    parser.add_argument(
        "--output",
        default=None,
        help="Path to write the rendered report; omit to write to stdout",
    )
    return parser.parse_args(list(argv) if argv is not None else None)


def main(
    argv: Sequence[str] | None = None,
    *,
    validator: ArtifactValidator | None = None,
) -> int:
    """Forward workspace flags or render an explicitly selected legacy ledger.

    Args:
        argv (Sequence[str] | None): CLI arguments; None uses sys.argv.
        validator (ArtifactValidator | None): Injected schema checker or the
            lazy upstream default on the legacy route. Canonical calls refuse
            injection before callbacks; legacy helpers still enforce version.

    Returns:
        int: Installed exit for workspace calls; legacy 0/1 for render/rejection,
            or 2 for mixed routes, invalid argv or canonical validator injection.

    Raises:
        OSError: Input/output boundary failures propagate unchanged.
        SystemExit: argparse rejects arguments or handles help.
        Exception: Unexpected injected validator failures propagate unchanged.

    Side Effects:
        Reads the input and writes a compatibility report to disk or stdout.
        Validation errors go to stderr; helper failures use a fixed diagnostic
        so malformed source text is never echoed. Canonical effects belong solely
        to the installed service; the legacy route grants no v2 authority.
    """
    try:
        arguments, legacy = report_arguments(argv, input_flags=("--input",))
    except ValueError:
        print(
            "Use separate legacy file or canonical workspace report arguments",
            file=sys.stderr,
        )
        return 2
    # Canonical execution cannot discard a caller's explicitly injected validator.
    if not legacy:
        if validator is not None:
            print("Injected validators require the legacy file route", file=sys.stderr)
            return 2
        return run_installed_cli("coverage-report", arguments)
    args = parse_args(arguments)
    active_validator = validator or _default_coverage_ledger_validator

    text = read_artifact_text(Path(args.input))
    try:
        validate_or_raise(text, active_validator)
    except ArtifactValidationError as exc:
        # Preserve each validator diagnostic without attempting report generation.
        for error in exc.errors:
            print(error, file=sys.stderr)
        return 1

    # Runtime helpers retain version, shape and resource authority even when
    # an injected validator accepts arbitrary text. Emit nothing on rejection.
    try:
        artifact = parse_coverage_ledger(text)
        rows, summary = build_coverage_rows(artifact)
        report_text = render_coverage_report(rows, summary)
    except ValueError:
        print("Coverage ledger cannot be rendered as a legacy report", file=sys.stderr)
        return 1

    # Preserve explicit destination routing through the monkeypatchable I/O seam.
    if args.output:
        write_report(Path(args.output), report_text)
    else:
        print(report_text, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
