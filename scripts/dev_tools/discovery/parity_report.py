"""Parity report CLI: render a Parity Matrix artifact as a report.

Purpose:
    Implement the `dev.discovery.parity-report` Poetry console-script: read a
    Parity Matrix artifact, validate it, and render a deterministic
    human-readable report from its entries.

Constraints:
    Field names used by `build_parity_rows` (a top-level `"entries"` list,
    each entry an arbitrary dict with an optional `"id"` field) are a
    documented, minimal, domain-neutral placeholder shape pending
    `legacy-discovery-schemas` (#9002); see `plan.2026-07-17T15-03.md`
    "Open Questions / Notes". This module mirrors `coverage_report.py`'s
    pipeline exactly (parse -> build_rows -> render -> CLI).
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path
from typing import TYPE_CHECKING, Any

from scripts.dev_tools.discovery import rendering
from scripts.dev_tools.discovery.io import (
    ArtifactValidationError,
    ArtifactValidator,
    read_artifact_text,
    validate_or_raise,
    write_report,
)

if TYPE_CHECKING:
    from collections.abc import Sequence


def parse_parity_matrix(text: str) -> dict[str, Any]:
    """Parse Parity Matrix artifact text into a plain dict.

    Args:
        text (str): Raw, already-validated Parity Matrix JSON text.

    Returns:
        dict[str, Any]: The parsed artifact document.

    Raises:
        json.JSONDecodeError: Propagated unchanged when `text` is not valid
            JSON. Callers only invoke this after `validate_or_raise` has
            already accepted `text`, so this path is not expected in normal
            operation.

    Side Effects:
        None.
    """
    return json.loads(text)


def build_parity_rows(
    artifact: dict[str, Any],
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    """Build sorted report rows and a summary from a parsed Parity Matrix.

    Args:
        artifact (dict[str, Any]): Parsed Parity Matrix document. Entries
            are read from an optional top-level `"entries"` list; an absent
            key is treated as an empty list.

    Returns:
        tuple[list[dict[str, Any]], dict[str, Any]]: A tuple of
        `(sorted_rows, summary)`, where `summary` currently carries only
        `"total_entries"`.

    Raises:
        None.

    Side Effects:
        None.
    """
    entries = artifact.get("entries", [])
    return rendering.sort_rows(entries), {"total_entries": len(entries)}


def render_parity_report(rows: list[dict[str, Any]], summary: dict[str, Any]) -> str:
    """Render sorted parity rows and a summary into report text.

    Args:
        rows (list[dict[str, Any]]): Sorted Parity Matrix entries, as
            produced by `build_parity_rows`.
        summary (dict[str, Any]): Aggregate summary dict, as produced by
            `build_parity_rows`.

    Returns:
        str: Deterministic, pretty-printed JSON report text.

    Raises:
        None.

    Side Effects:
        None.
    """
    return rendering.render_pretty_json({"summary": summary, "entries": rows})


def _default_parity_matrix_validator(text: str) -> list[str]:
    """Bind and invoke the real upstream Parity Matrix validator.

    Purpose:
        Provide the default `ArtifactValidator` used by `main` when no
        test-injected validator is supplied. The upstream import is
        performed lazily, inside this function body, so importing this
        module never hard-fails if the upstream validator module is
        unavailable, and so unit tests (which always inject a fake
        validator) never trigger this import path.

    Args:
        text (str): Raw Parity Matrix artifact text to validate.

    Returns:
        list[str]: Empty list when `text` conforms to the Parity Matrix
        schema; otherwise one or more human-readable error strings.

    Raises:
        None beyond what the upstream validator itself may raise.

    Side Effects:
        May read a local or cached schema file via the upstream validator.
    """
    from scripts.dev_tools.validate_discovery_schema_artifacts import (
        validate_parity_matrix_text,
    )

    return validate_parity_matrix_text(text)


def parse_args(argv: Sequence[str] | None) -> argparse.Namespace:
    """Parse command-line arguments for the parity-report CLI.

    Args:
        argv (Sequence[str] | None): Argument list; `None` defers to
            `argparse`'s own `sys.argv[1:]` default.

    Returns:
        argparse.Namespace: Parsed arguments with `input` and `output`.
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
    """Entry point for the `dev.discovery.parity-report` CLI.

    Args:
        argv (Sequence[str] | None): Argument list; defaults to
            `sys.argv[1:]` via `parse_args`.
        validator (ArtifactValidator | None): Optional injected validator,
            used by tests in place of the real lazily-imported default.

    Returns:
        int: `0` on success; `1` when validation fails.

    Raises:
        None. `ArtifactValidationError` is caught internally.

    Side Effects:
        Reads the input artifact from disk, writes the rendered report to
        disk or stdout, and may print validation errors to stderr.
    """
    args = parse_args(argv)
    active_validator = validator or _default_parity_matrix_validator

    text = read_artifact_text(Path(args.input))
    try:
        validate_or_raise(text, active_validator)
    except ArtifactValidationError as exc:
        # Fail fast: print every validator-reported error and return
        # non-zero without parsing or rendering the artifact.
        for error in exc.errors:
            print(error, file=sys.stderr)
        return 1

    artifact = parse_parity_matrix(text)
    rows, summary = build_parity_rows(artifact)
    report_text = render_parity_report(rows, summary)

    if args.output:
        write_report(Path(args.output), report_text)
    else:
        print(report_text, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
