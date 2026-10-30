"""Keep explicit legacy text validation separate from installed workspace commands.

Selected-kind file checks retain their historical structural-only contract.
Canonical flags and fixed wrappers use the installed service; type probing is
never a substitute for selecting a kind or validating a captured workspace.
"""

from __future__ import annotations

import argparse
import sys
from collections.abc import Sequence
from pathlib import Path
from typing import TYPE_CHECKING, cast

from drm_copilot_discovery.cli import run_installed_cli
from drm_copilot_discovery.models import ParseLimits
from drm_copilot_discovery.report_models import ReportBudget

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

__all__ = ["compatibility_arguments", "load_schema", "report_arguments"]

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


def compatibility_arguments(argv: Sequence[str] | None) -> tuple[str, ...]:
    """Capture bounded argv (Sequence[str] or None for process arguments).

    Return immutable exact strings after reserving count, text traversal and
    encoded capacity before copying. Raise ValueError on malformed/excessive
    input. Only local counters change; no provider or filesystem I/O occurs.
    """
    active = sys.argv if argv is None else argv
    start = 1 if argv is None else 0
    if not isinstance(cast("object", active), Sequence) or isinstance(
        active, (str, bytes)
    ):
        raise ValueError("Compatibility arguments require a text sequence")
    end = len(active)
    count = end - start
    budget = ReportBudget(ParseLimits())
    if count < 0 or count > budget.limits.artifact_records:
        raise ValueError("Compatibility argument count exceeds limits")
    budget.work(4 * count)
    result: list[str] = []
    # Capture each token once; prepay later flag scans, argparse copies and encoding.
    for index in range(start, end):
        token = active[index]
        if type(token) is not str:
            raise ValueError("Compatibility arguments require exact text")
        budget.work(16 * len(token))
        budget.text(token)
        result.append(token)
    return tuple(result)


def report_arguments(
    argv: Sequence[str] | None, *, input_flags: tuple[str, ...]
) -> tuple[tuple[str, ...], bool]:
    """Select an explicit report route without evaluating artifacts or validators.

    argv (Sequence[str] | None) is captured under installed default limits;
    input_flags (tuple[str, ...]) contains the adapter's fixed legacy flags.
    Return the bounded arguments and whether legacy input/output flags occur.
    Raise ValueError on malformed, excessive or mixed workspace/file options.
    No callbacks, input mutation or I/O occur.
    """
    arguments = compatibility_arguments(argv)
    legacy_flags = (*input_flags, "--output")
    allowed = (*legacy_flags, "--help", "-h")
    legacy = False
    mixed = False
    # Only fixed option names select a route; filenames and artifact schemas cannot.
    for argument in arguments:
        if argument.startswith("-"):
            option = argument.partition("=")[0]
            legacy = legacy or option in legacy_flags
            mixed = mixed or option not in allowed
    if legacy and mixed:
        raise ValueError(
            "Use legacy file flags or canonical workspace flags separately"
        )
    return arguments, legacy


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
        type plus the refused `all` spelling, each taking one positional path.
        Canonical flag-based requests are forwarded before this legacy parser.

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

    # Selected legacy kinds retain argparse errors without guessing their schema.
    for artifact_type in (*_ARTIFACT_TYPES, "all"):
        artifact_parser = subparsers.add_parser(artifact_type)
        artifact_parser.add_argument("path")

    return parser


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
        OSError: Selected legacy input reading fails; the original error propagates.

    Side Effects:
        Reads only the explicitly selected kind's artifact; all/unknown read nothing.
    """

    if args.artifact_type == "all":
        return ["Select one artifact kind or use validate-all --workspace-root ROOT"]

    # Resolve the caller-selected kind before reading; no first-success probing remains.
    for artifact_type, validator in _ARTIFACT_VALIDATORS:
        if args.artifact_type == artifact_type:
            return validator(_read_text(Path(args.path)))

    return [f"Unsupported artifact type: {args.artifact_type}"]


def main(argv: list[str] | None = None) -> int:
    """Route argv (list[str] | None) by an explicit kind and argument form.

    Return the installed exit for canonical flags, 0/1 for selected legacy file
    checks, or 2 for unsafe ambiguity. None uses process arguments. Legacy
    argparse SystemExit and I/O errors propagate. Reads/writes occur only in
    the selected route; single-file all probing is refused before any read.
    """
    try:
        arguments = compatibility_arguments(argv)
    except ValueError:
        print(
            "Invalid discovery arguments; use an explicit kind and --help",
            file=sys.stderr,
        )
        return 2
    # Flag-based calls use the fixed installed command, never a guessed workspace.
    if arguments and arguments[0] in (*_ARTIFACT_TYPES, "all"):
        kind, remaining = arguments[0], arguments[1:]
        if not remaining or remaining[0].startswith("-"):
            command = "validate-all" if kind == "all" else "validate-" + kind
            return run_installed_cli(command, remaining)
        if kind == "all":
            print(
                "Select one artifact kind or use validate-all --workspace-root ROOT",
                file=sys.stderr,
            )
            return 2
    parser = build_parser()
    args = parser.parse_args(arguments)
    errors = _validate_from_args(args)
    if errors:
        # Retain the selected legacy validator's ordered structural diagnostics.
        for error in errors:
            print(error, file=sys.stderr)
        return 1
    print(f"{args.artifact_type} validation passed: {args.path}")
    return 0


def main_profile() -> int:
    """Return installed profile-validation exit using process argv and service I/O."""
    return run_installed_cli("validate-profile")


def main_feature_contract() -> int:
    """Return fixed feature-validation exit; installed CLI owns argv and I/O."""
    return run_installed_cli("validate-feature-contract")


def main_coverage_ledger() -> int:
    """Return fixed ledger-validation exit; installed CLI owns argv and I/O."""
    return run_installed_cli("validate-coverage-ledger")


def main_runtime_scenario() -> int:
    """Return fixed scenario-validation exit; installed CLI owns argv and I/O."""
    return run_installed_cli("validate-runtime-scenario")


def main_parity_matrix() -> int:
    """Return fixed parity-validation exit; installed CLI owns argv and I/O."""
    return run_installed_cli("validate-parity-matrix")


def main_unspecified_behavior() -> int:
    """Return fixed unspecified-behavior exit; installed CLI owns argv and I/O."""
    return run_installed_cli("validate-unspecified-behavior")


def main_product_decision() -> int:
    """Return fixed decision-validation exit; installed CLI owns argv and I/O."""
    return run_installed_cli("validate-product-decision")


def main_evidence_reference() -> int:
    """Return fixed evidence-validation exit; installed CLI owns argv and I/O."""
    return run_installed_cli("validate-evidence-reference")


if __name__ == "__main__":
    raise SystemExit(main())
