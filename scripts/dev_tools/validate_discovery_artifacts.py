"""Umbrella CLI for discovery-artifact validators.

Purpose:
    Provide the single stable CLI entrypoint dispatching to the domain-profile
    validator (#9001 seam) and the seven discovery schema validators (#9002
    seam), following the canonical argparse-subparser pattern established by
    `scripts/dev_tools/validate_orchestration_artifacts.py`. This module
    contains no validation logic itself; it only reads, dispatches, and
    reports.
"""

from __future__ import annotations

import argparse
import sys
from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.validate_discovery_profile import validate_profile_text
from scripts.dev_tools.validate_discovery_schema_artifacts import (
    load_schema,
    validate_coverage_ledger_text,
    validate_evidence_reference_text,
    validate_feature_contract_text,
    validate_parity_matrix_text,
    validate_product_decision_text,
    validate_runtime_scenario_text,
    validate_unspecified_behavior_text,
)

if TYPE_CHECKING:
    from collections.abc import Callable

__all__ = ["load_schema"]

_ARTIFACT_TYPES: tuple[str, ...] = (
    "profile",
    "feature-contract",
    "coverage-ledger",
    "runtime-scenario",
    "parity-matrix",
    "unspecified-behavior",
    "product-decision",
    "evidence-reference",
)

# Fixed dispatch order per Design Decision 1: `profile`, then the seven
# schemas in the order enumerated in the epic's Shared Design.
_ARTIFACT_VALIDATORS: tuple[tuple[str, Callable[[str], list[str]]], ...] = (
    ("profile", validate_profile_text),
    ("feature-contract", validate_feature_contract_text),
    ("coverage-ledger", validate_coverage_ledger_text),
    ("runtime-scenario", validate_runtime_scenario_text),
    ("parity-matrix", validate_parity_matrix_text),
    ("unspecified-behavior", validate_unspecified_behavior_text),
    ("product-decision", validate_product_decision_text),
    ("evidence-reference", validate_evidence_reference_text),
)


def _read_text(path: Path) -> str:
    """Read a UTF-8 artifact from disk.

    Purpose:
        Centralize file reading for the CLI dispatcher and monkeypatched
        unit tests, mirroring
        `validate_orchestration_artifacts.py::_read_text`.

    Args:
        path (Path): Artifact path to read.

    Returns:
        str: UTF-8 text content for the requested artifact.

    Raises:
        OSError: Raised when the file cannot be read.

    Side Effects:
        Reads from disk.
    """

    return path.read_text(encoding="utf-8")


def build_parser() -> argparse.ArgumentParser:
    """Create the discovery-validator CLI parser.

    Purpose:
        Define the stable command-line contract: one subparser per artifact
        type plus `all`, each taking exactly one positional `path` argument.

    Args:
        None.

    Returns:
        argparse.ArgumentParser: Configured parser for the supported artifact
        types.

    Raises:
        None.

    Side Effects:
        None.
    """

    parser = argparse.ArgumentParser(
        description=(
            "Validate legacy-discovery domain-profile and schema-governed artifacts."
        )
    )
    subparsers = parser.add_subparsers(dest="artifact_type", required=True)

    for artifact_type in (*_ARTIFACT_TYPES, "all"):
        artifact_parser = subparsers.add_parser(artifact_type)
        artifact_parser.add_argument("path")

    return parser


def _validate_all_text(text: str) -> list[str]:
    """Validate `text` against every known artifact type.

    Purpose:
        Implement `all`'s semantics per Design Decision 1: succeed on the
        first per-type validator that returns an empty list; otherwise return
        the aggregated, per-type-prefixed errors from every validator.

    Args:
        text (str): Raw artifact document text.

    Returns:
        list[str]: `[]` when `text` conforms to at least one artifact type;
        otherwise the aggregated `f"{artifact_type}: {message}"` errors from
        every type.

    Raises:
        None.

    Side Effects:
        None.
    """

    aggregated: list[str] = []
    for artifact_type, validator in _ARTIFACT_VALIDATORS:
        errors = validator(text)
        if not errors:
            return []
        aggregated.extend(f"{artifact_type}: {message}" for message in errors)
    return aggregated


def _validate_from_args(args: argparse.Namespace) -> list[str]:
    """Dispatch the requested validator.

    Purpose:
        Route the parsed CLI request to the correct validator without
        changing the public artifact-type names accepted by the entrypoint.

    Args:
        args (argparse.Namespace): Parsed CLI arguments.

    Returns:
        list[str]: Validation errors produced by the selected validator.

    Raises:
        None.

    Side Effects:
        Reads the target artifact from disk.
    """

    text = _read_text(Path(args.path))

    if args.artifact_type == "all":
        return _validate_all_text(text)

    for artifact_type, validator in _ARTIFACT_VALIDATORS:
        if args.artifact_type == artifact_type:
            return validator(text)

    return [f"Unsupported artifact type: {args.artifact_type}"]


def main(argv: list[str] | None = None) -> int:
    """Run the discovery-artifact validator CLI.

    Purpose:
        Execute the stable CLI entrypoint validating a domain-profile or
        schema-governed discovery artifact.

    Args:
        argv (list[str] | None): Optional command-line arguments for testing
            or programmatic invocation.

    Returns:
        int: Exit code `0` for success and `1` for validation failure.

    Raises:
        None.

    Side Effects:
        Reads a file from disk and writes validation results to
        stdout/stderr.
    """

    parser = build_parser()
    args = parser.parse_args(argv)
    errors = _validate_from_args(args)
    if errors:
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print(f"{args.artifact_type} validation passed: {args.path}")
    return 0


def main_profile() -> int:
    """Console-script entry point for `dev.discovery.validate-profile`."""
    return main(["profile", *sys.argv[1:]])


def main_feature_contract() -> int:
    """Console-script entry point for `dev.discovery.validate-feature-contract`."""
    return main(["feature-contract", *sys.argv[1:]])


def main_coverage_ledger() -> int:
    """Console-script entry point for `dev.discovery.validate-coverage-ledger`."""
    return main(["coverage-ledger", *sys.argv[1:]])


def main_runtime_scenario() -> int:
    """Console-script entry point for `dev.discovery.validate-runtime-scenario`."""
    return main(["runtime-scenario", *sys.argv[1:]])


def main_parity_matrix() -> int:
    """Console-script entry point for `dev.discovery.validate-parity-matrix`."""
    return main(["parity-matrix", *sys.argv[1:]])


def main_unspecified_behavior() -> int:
    """Console-script entry point for `dev.discovery.validate-unspecified-behavior`."""
    return main(["unspecified-behavior", *sys.argv[1:]])


def main_product_decision() -> int:
    """Console-script entry point for `dev.discovery.validate-product-decision`."""
    return main(["product-decision", *sys.argv[1:]])


def main_evidence_reference() -> int:
    """Console-script entry point for `dev.discovery.validate-evidence-reference`."""
    return main(["evidence-reference", *sys.argv[1:]])


if __name__ == "__main__":
    raise SystemExit(main())
