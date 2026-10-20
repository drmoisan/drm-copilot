"""Route two legacy artifacts through bounded runtime compatibility helpers.

The historical flags, callable exports and injected validators remain supported.
The resulting counts describe legacy artifacts only and confer no v2 completion,
planning or host-gate authority. This module owns argument and I/O routing.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery.completion_report import (
    build_completion_summary as build_completion_summary,
)
from drm_copilot_discovery.completion_report import (
    render_completion_report as render_completion_report,
)
from drm_copilot_discovery.parity_report import parse_parity_matrix
from drm_copilot_discovery.report_models import parse_coverage_ledger

from scripts.dev_tools.discovery.io import (
    ArtifactValidationError,
    ArtifactValidator,
    read_artifact_text,
    validate_or_raise,
    write_report,
)

if TYPE_CHECKING:
    from collections.abc import Sequence


def _default_coverage_ledger_validator(text: str) -> list[str]:
    """Validate text (str) through the lazy upstream coverage validator.

    Returns list[str] errors, empty on success; upstream exceptions propagate.
    The upstream validator may read a schema. Lazy import preserves injection.
    """
    from scripts.dev_tools.validate_discovery_schema_artifacts import (
        validate_coverage_ledger_text,
    )

    return validate_coverage_ledger_text(text)


def _default_parity_matrix_validator(text: str) -> list[str]:
    """Validate text (str) through the lazy upstream parity validator.

    Returns list[str] errors, empty on success; upstream exceptions propagate.
    The upstream validator may read a schema. Lazy import preserves injection.
    """
    from scripts.dev_tools.validate_discovery_schema_artifacts import (
        validate_parity_matrix_text,
    )

    return validate_parity_matrix_text(text)


def parse_args(argv: Sequence[str] | None) -> argparse.Namespace:
    """Parse argv (Sequence[str] or None) into the historical named paths.

    Returns argparse.Namespace; None reads sys.argv. Raises SystemExit for help
    or invalid arguments, with argparse output to stdout/stderr. No file I/O.
    """
    parser = argparse.ArgumentParser(
        description="Render a legacy coverage and parity compatibility summary"
    )
    parser.add_argument(
        "--coverage-input", required=True, help="Path to the Coverage Ledger JSON file"
    )
    parser.add_argument(
        "--parity-input", required=True, help="Path to the Parity Matrix JSON file"
    )
    parser.add_argument(
        "--output", default=None, help="Report destination; omit to write to stdout"
    )
    return parser.parse_args(list(argv) if argv is not None else None)


def main(
    argv: Sequence[str] | None = None,
    *,
    coverage_validator: ArtifactValidator | None = None,
    parity_validator: ArtifactValidator | None = None,
) -> int:
    """Read, validate and render two legacy artifacts through injectable seams.

    Args:
        argv (Sequence[str] | None): CLI arguments; None reads sys.argv.
        coverage_validator (ArtifactValidator | None): Coverage checker, or lazy
            upstream default. Injection cannot bypass runtime helper validation.
        parity_validator (ArtifactValidator | None): Parity checker, or lazy
            upstream default, subject to the same bounded helper authority.

    Returns:
        int: Zero after rendering; one for validator or runtime helper rejection.

    Raises:
        OSError: Input/output boundary failures propagate unchanged.
        SystemExit: argparse rejects arguments or handles help.
        Exception: Unexpected injected validator failures propagate unchanged.

    Side Effects:
        Reads both inputs and writes one compatibility report to disk or stdout.
        Validator diagnostics go to stderr; helper failures use a fixed message.
        No v2 publication, authored artifact change or gate assessment occurs.
    """
    args = parse_args(argv)
    active_coverage_validator = coverage_validator or _default_coverage_ledger_validator
    active_parity_validator = parity_validator or _default_parity_matrix_validator
    coverage_text = read_artifact_text(Path(args.coverage_input))
    parity_text = read_artifact_text(Path(args.parity_input))

    # Collect both validator outcomes before any parsing, building or publication.
    errors: list[str] = []
    try:
        validate_or_raise(coverage_text, active_coverage_validator)
    except ArtifactValidationError as exc:
        errors.extend(exc.errors)
    try:
        validate_or_raise(parity_text, active_parity_validator)
    except ArtifactValidationError as exc:
        errors.extend(exc.errors)
    if errors:
        # Preserve every upstream diagnostic in its original validator order.
        for error in errors:
            print(error, file=sys.stderr)
        return 1

    # Strict parsing and runtime builders retain authority with injected validators.
    try:
        coverage = parse_coverage_ledger(coverage_text)
        parity = parse_parity_matrix(parity_text)
        summary = build_completion_summary(coverage, parity)
        report_text = render_completion_report(summary)
    except ValueError:
        print(
            "Artifacts cannot be rendered as a legacy completion report",
            file=sys.stderr,
        )
        return 1

    # Keep the historical destination seam; v2 reports use controlled mutation APIs.
    if args.output:
        write_report(Path(args.output), report_text)
    else:
        print(report_text, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
