"""Route the legacy parity CLI through bounded runtime compatibility helpers.

The public parse/build/render names remain available for existing callers.
They summarize v1 or safe placeholder entries without establishing v2 graph
completeness. This adapter owns only argument, validation and I/O routing.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import TYPE_CHECKING

from drm_copilot_discovery.parity_report import (
    build_parity_rows as build_parity_rows,
)
from drm_copilot_discovery.parity_report import (
    parse_parity_matrix as parse_parity_matrix,
)
from drm_copilot_discovery.parity_report import (
    render_parity_report as render_parity_report,
)

from scripts.dev_tools.discovery.io import (
    ArtifactValidationError,
    ArtifactValidator,
    read_artifact_text,
    validate_or_raise,
    write_report,
)

if TYPE_CHECKING:
    from collections.abc import Sequence


def _default_parity_matrix_validator(text: str) -> list[str]:
    """Validate text (str) through the lazily loaded upstream v1 validator.

    Returns list[str] errors, empty on success. Propagates upstream exceptions;
    the validator may read a local schema. Lazy binding preserves caller
    injection and keeps schema access out of ordinary adapter imports.
    """
    from scripts.dev_tools.validate_discovery_schema_artifacts import (
        validate_parity_matrix_text,
    )

    return validate_parity_matrix_text(text)


def parse_args(argv: Sequence[str] | None) -> argparse.Namespace:
    """Parse argv (Sequence[str] or None) into input/output path arguments.

    Returns argparse.Namespace; None reads sys.argv. Raises SystemExit for help
    or invalid arguments, with argparse output to stdout/stderr. No file I/O.
    """
    parser = argparse.ArgumentParser(
        description="Render a deterministic report from a Parity Matrix artifact"
    )
    parser.add_argument(
        "--input", required=True, help="Path to the Parity Matrix artifact JSON file"
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
    """Read, validate and render one legacy matrix through injectable seams.

    Args:
        argv (Sequence[str] | None): CLI arguments; None uses sys.argv.
        validator (ArtifactValidator | None): Injected schema checker or the
            lazy upstream default. It cannot bypass runtime helper validation.

    Returns:
        int: Zero after rendering; one for validator or helper rejection.

    Raises:
        OSError: Input/output boundary failures propagate unchanged.
        SystemExit: argparse rejects arguments or handles help.
        Exception: Unexpected injected validator failures propagate unchanged.

    Side Effects:
        Reads the input and writes a compatibility report to disk or stdout.
        Validation errors go to stderr; helper failures use a fixed diagnostic
        so malformed source text is never echoed. No v2 publication occurs.
    """
    args = parse_args(argv)
    active_validator = validator or _default_parity_matrix_validator

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
        artifact = parse_parity_matrix(text)
        rows, summary = build_parity_rows(artifact)
        report_text = render_parity_report(rows, summary)
    except ValueError:
        print("Parity matrix cannot be rendered as a legacy report", file=sys.stderr)
        return 1

    # Preserve explicit destination routing through the monkeypatchable I/O seam.
    if args.output:
        write_report(Path(args.output), report_text)
    else:
        print(report_text, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
