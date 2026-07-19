"""Coverage report CLI: render a Coverage Ledger artifact as a report.

Purpose:
    Implement the `dev.discovery.coverage-report` Poetry console-script: read
    a Coverage Ledger artifact, validate it, and render a deterministic
    human-readable report from its entries.

Constraints:
    Field names used by `build_coverage_rows` (a top-level `"entries"` list,
    each entry an arbitrary dict with an optional `"id"` field) are a
    documented, minimal, domain-neutral placeholder shape pending
    `legacy-discovery-schemas` (#9002); see `plan.2026-07-17T15-03.md`
    "Open Questions / Notes".
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


def parse_coverage_ledger(text: str) -> dict[str, Any]:
    """Parse Coverage Ledger artifact text into a plain dict.

    Args:
        text (str): Raw, already-validated Coverage Ledger JSON text.

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


def build_coverage_rows(
    artifact: dict[str, Any],
) -> tuple[list[dict[str, Any]], dict[str, Any]]:
    """Build sorted report rows and a summary from a parsed Coverage Ledger.

    Args:
        artifact (dict[str, Any]): Parsed Coverage Ledger document. Entries
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


def render_coverage_report(rows: list[dict[str, Any]], summary: dict[str, Any]) -> str:
    """Render sorted coverage rows and a summary into report text.

    Args:
        rows (list[dict[str, Any]]): Sorted Coverage Ledger entries, as
            produced by `build_coverage_rows`.
        summary (dict[str, Any]): Aggregate summary dict, as produced by
            `build_coverage_rows`.

    Returns:
        str: Deterministic, pretty-printed JSON report text.

    Raises:
        None.

    Side Effects:
        None.
    """
    return rendering.render_pretty_json({"summary": summary, "entries": rows})


def _default_coverage_ledger_validator(text: str) -> list[str]:
    """Bind and invoke the real upstream Coverage Ledger validator.

    Purpose:
        Provide the default `ArtifactValidator` used by `main` when no
        test-injected validator is supplied. The upstream import is
        performed lazily, inside this function body, so importing this
        module never hard-fails if the upstream validator module is
        unavailable, and so unit tests (which always inject a fake
        validator) never trigger this import path.

    Args:
        text (str): Raw Coverage Ledger artifact text to validate.

    Returns:
        list[str]: Empty list when `text` conforms to the Coverage Ledger
        schema; otherwise one or more human-readable error strings.

    Raises:
        None beyond what the upstream validator itself may raise.

    Side Effects:
        May read a local or cached schema file via the upstream validator.
    """
    from scripts.dev_tools.validate_discovery_schema_artifacts import (
        validate_coverage_ledger_text,
    )

    return validate_coverage_ledger_text(text)


def parse_args(argv: Sequence[str] | None) -> argparse.Namespace:
    """Parse command-line arguments for the coverage-report CLI.

    Args:
        argv (Sequence[str] | None): Argument list; `None` defers to
            `argparse`'s own `sys.argv[1:]` default.

    Returns:
        argparse.Namespace: Parsed arguments with `input` and `output`.
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
    """Entry point for the `dev.discovery.coverage-report` CLI.

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
    active_validator = validator or _default_coverage_ledger_validator

    text = read_artifact_text(Path(args.input))
    try:
        validate_or_raise(text, active_validator)
    except ArtifactValidationError as exc:
        # Fail fast: print every validator-reported error and return
        # non-zero without parsing or rendering the artifact.
        for error in exc.errors:
            print(error, file=sys.stderr)
        return 1

    artifact = parse_coverage_ledger(text)
    rows, summary = build_coverage_rows(artifact)
    report_text = render_coverage_report(rows, summary)

    if args.output:
        write_report(Path(args.output), report_text)
    else:
        print(report_text, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
