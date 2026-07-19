"""Completion report CLI: aggregate readiness across discovery artifacts.

Purpose:
    Implement the `dev.discovery.completion-report` Poetry console-script:
    read and validate both a Coverage Ledger and a Parity Matrix artifact,
    then render a deterministic aggregate-readiness report over them.

Constraints:
    Per `spec.md` "Constraints & Risks" ("Completion-report scope risk"),
    the v1 scope of this aggregation is restricted to the Coverage Ledger
    and Parity Matrix artifact categories only (this feature's declared
    `depends_on`). `build_completion_summary` performs no validation itself;
    validation of both inputs already occurred in `main` before this
    function is called, so `"readiness"` reflects that both artifacts were
    successfully validated, not any entry-count threshold.
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


def build_completion_summary(
    coverage_artifact: dict[str, Any], parity_artifact: dict[str, Any]
) -> dict[str, Any]:
    """Aggregate readiness across a Coverage Ledger and a Parity Matrix.

    Purpose:
        Produce a pure aggregation summary over the two v1-scoped discovery
        artifact categories. This function performs no validation; callers
        must have already validated both artifacts (via `main`'s
        validate-then-aggregate ordering) before calling this function, so
        `"readiness"` can unconditionally report `"ready"` here.

    Args:
        coverage_artifact (dict[str, Any]): Parsed Coverage Ledger document.
        parity_artifact (dict[str, Any]): Parsed Parity Matrix document.

    Returns:
        dict[str, Any]: A summary dict with one entry per artifact category
        (`"coverage_ledger"`, `"parity_matrix"`), each
        `{"present": True, "entry_count": <int>}`, plus a top-level
        `"readiness"` field equal to `"ready"`.

    Raises:
        None.

    Side Effects:
        None.
    """
    return {
        "coverage_ledger": {
            "present": True,
            "entry_count": len(coverage_artifact.get("entries", [])),
        },
        "parity_matrix": {
            "present": True,
            "entry_count": len(parity_artifact.get("entries", [])),
        },
        "readiness": "ready",
    }


def render_completion_report(summary: dict[str, Any]) -> str:
    """Render an aggregate-readiness summary into report text.

    Args:
        summary (dict[str, Any]): Summary dict, as produced by
            `build_completion_summary`.

    Returns:
        str: Deterministic, pretty-printed JSON report text.

    Raises:
        None.

    Side Effects:
        None.
    """
    return rendering.render_pretty_json(summary)


def _default_coverage_ledger_validator(text: str) -> list[str]:
    """Bind and invoke the real upstream Coverage Ledger validator.

    Purpose:
        Provide the default coverage-input `ArtifactValidator` used by
        `main` when no test-injected validator is supplied, mirroring
        `coverage_report.py`'s `_default_coverage_ledger_validator`. The
        upstream import is performed lazily, inside this function body, so
        importing this module never hard-fails if the upstream validator
        module is unavailable, and so unit tests (which always inject fake
        validators for both inputs) never trigger this import path.

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


def _default_parity_matrix_validator(text: str) -> list[str]:
    """Bind and invoke the real upstream Parity Matrix validator.

    Purpose:
        Provide the default parity-input `ArtifactValidator` used by `main`
        when no test-injected validator is supplied, mirroring
        `parity_report.py`'s `_default_parity_matrix_validator`. The
        upstream import is performed lazily, inside this function body, for
        the same reason as `_default_coverage_ledger_validator` above.

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
    """Parse command-line arguments for the completion-report CLI.

    Purpose:
        Use explicit `--coverage-input`/`--parity-input` flags (rather than
        a repeated generic `--input`) so the CLI can dispatch each artifact
        to the correct validator without depending on an unverified
        type-indicating field inside the not-yet-defined schema, per
        `spec.md` "Completion-report CLI flag naming deviation".

    Args:
        argv (Sequence[str] | None): Argument list; `None` defers to
            `argparse`'s own `sys.argv[1:]` default.

    Returns:
        argparse.Namespace: Parsed arguments with `coverage_input`,
        `parity_input`, and `output`.
    """
    parser = argparse.ArgumentParser(
        description=(
            "Render an aggregate-readiness report from a Coverage Ledger and "
            "a Parity Matrix artifact"
        )
    )
    parser.add_argument(
        "--coverage-input",
        required=True,
        help="Path to the Coverage Ledger artifact JSON file",
    )
    parser.add_argument(
        "--parity-input",
        required=True,
        help="Path to the Parity Matrix artifact JSON file",
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
    coverage_validator: ArtifactValidator | None = None,
    parity_validator: ArtifactValidator | None = None,
) -> int:
    """Entry point for the `dev.discovery.completion-report` CLI.

    Args:
        argv (Sequence[str] | None): Argument list; defaults to
            `sys.argv[1:]` via `parse_args`.
        coverage_validator (ArtifactValidator | None): Optional injected
            validator for the Coverage Ledger input, used by tests in place
            of the real lazily-imported `_default_coverage_ledger_validator`.
        parity_validator (ArtifactValidator | None): Optional injected
            validator for the Parity Matrix input, used by tests in place
            of the real lazily-imported `_default_parity_matrix_validator`.

    Returns:
        int: `0` on success; `1` when either validator reports errors.

    Raises:
        None. `ArtifactValidationError` is caught internally.

    Side Effects:
        Reads both input artifacts from disk, writes the rendered report to
        disk or stdout, and may print validation errors to stderr.
    """
    args = parse_args(argv)
    active_coverage_validator = coverage_validator or _default_coverage_ledger_validator
    active_parity_validator = parity_validator or _default_parity_matrix_validator

    coverage_text = read_artifact_text(Path(args.coverage_input))
    parity_text = read_artifact_text(Path(args.parity_input))

    # Validate both inputs before any aggregation or rendering occurs;
    # collect errors from both so a caller sees every problem in one run
    # rather than fixing one artifact at a time across repeated invocations.
    all_errors: list[str] = []
    try:
        validate_or_raise(coverage_text, active_coverage_validator)
    except ArtifactValidationError as exc:
        all_errors.extend(exc.errors)
    try:
        validate_or_raise(parity_text, active_parity_validator)
    except ArtifactValidationError as exc:
        all_errors.extend(exc.errors)

    if all_errors:
        for error in all_errors:
            print(error, file=sys.stderr)
        return 1

    coverage_artifact = json.loads(coverage_text)
    parity_artifact = json.loads(parity_text)
    summary = build_completion_summary(coverage_artifact, parity_artifact)
    report_text = render_completion_report(summary)

    if args.output:
        write_report(Path(args.output), report_text)
    else:
        print(report_text, end="")
    return 0


if __name__ == "__main__":
    sys.exit(main())
