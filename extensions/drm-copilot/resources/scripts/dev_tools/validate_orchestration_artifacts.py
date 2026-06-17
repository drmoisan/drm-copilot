"""Validate orchestration plan, review, and checkpoint artifacts.

Purpose:
    Provide the stable CLI entrypoint for deterministic orchestration artifact
    validation while delegating review- and checkpoint-specific logic to smaller
    modules that remain under the repository file-size limit.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

from dev_tools.validate_orchestration_review_artifacts import (
    validate_code_review_text,
    validate_feature_audit_text,
)
from dev_tools.validate_orchestrator_state import (
    validate_orchestrator_state_text,
)
from dev_tools.validate_policy_audit_artifact import validate_policy_audit_text

PLAN_PHASE_RE = re.compile(r"^### Phase (?P<phase>\d+) — (?P<title>.+)$")
PLAN_TASK_RE = re.compile(
    r"^- \[(?P<state>[ xX])\] \[P(?P<phase>\d+)-T(?P<task>\d+)\] (?P<title>.+)$"
)


def _read_text(path: Path) -> str:
    """Read a UTF-8 artifact from disk.

    Purpose:
        Centralize file reading for the CLI dispatcher and monkeypatched unit
        tests.

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


def validate_plan_text(text: str) -> list[str]:
    """Validate canonical atomic-plan structure.

    Purpose:
        Enforce the repository's required phase and task formatting for atomic
        execution plans.

    Args:
        text (str): Full plan document text.

    Returns:
        list[str]: Validation errors describing any structural contract
        violations.

    Raises:
        None.

    Side Effects:
        None.
    """

    errors: list[str] = []
    current_phase: int | None = None
    seen_phases: list[int] = []
    expected_task_num: dict[int, int] = {}
    found_task = False

    # Walk the document in source order so numbering and phase mismatches are
    # reported against the same line numbers a maintainer sees in the plan.
    for line_number, line in enumerate(text.splitlines(), start=1):
        if line.startswith("### Phase "):
            match = PLAN_PHASE_RE.match(line)
            if match is None:
                errors.append(
                    f"Line {line_number}: phase heading must match "
                    "`### Phase N — <Title>`."
                )
                current_phase = None
                continue
            current_phase = int(match.group("phase"))
            seen_phases.append(current_phase)
            expected_task_num.setdefault(current_phase, 1)
            continue

        if line.startswith("- [") and "[P" in line and "-T" in line:
            found_task = True
            match = PLAN_TASK_RE.match(line)
            if match is None:
                errors.append(
                    f"Line {line_number}: task line must match "
                    "`- [ ] [P#-T#] <Title>`."
                )
                continue
            task_phase = int(match.group("phase"))
            task_num = int(match.group("task"))
            if current_phase is None:
                errors.append(
                    "Line "
                    f"{line_number}: task appears before a canonical phase "
                    "heading."
                )
                continue
            if task_phase != current_phase:
                errors.append(
                    f"Line {line_number}: task phase P{task_phase} does not match "
                    f"current phase {current_phase}."
                )
            expected = expected_task_num.setdefault(task_phase, 1)
            if task_num != expected:
                errors.append(
                    f"Line {line_number}: expected task number T{expected} for phase "
                    f"{task_phase}, found T{task_num}."
                )
            expected_task_num[task_phase] = max(expected, task_num) + 1

    if not seen_phases:
        errors.append("Plan does not contain any canonical phase headings.")
    if not found_task:
        errors.append("Plan does not contain any canonical task lines.")
    return errors


def build_parser() -> argparse.ArgumentParser:
    """Create the CLI parser.

    Purpose:
        Define the stable command-line contract for orchestration artifact
        validation.

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
        description="Validate deterministic orchestration artifacts."
    )
    subparsers = parser.add_subparsers(dest="artifact_type", required=True)

    for artifact_type in ("plan", "policy-audit", "code-review", "feature-audit"):
        artifact_parser = subparsers.add_parser(artifact_type)
        artifact_parser.add_argument("path")

    state_parser = subparsers.add_parser("orchestrator-state")
    state_parser.add_argument("path")
    state_parser.add_argument(
        "--require-complete",
        action="store_true",
        help="Require all tracked statuses to be complete-state safe.",
    )
    return parser


def _validate_from_args(args: argparse.Namespace) -> list[str]:
    """Dispatch the requested validator.

    Purpose:
        Route the parsed CLI request to the correct validator without changing
        the public artifact-type names accepted by the entrypoint.

    Args:
        args (argparse.Namespace): Parsed CLI arguments.

    Returns:
        list[str]: Validation errors produced by the selected validator.

    Raises:
        None.

    Side Effects:
        Reads the target artifact from disk.
    """

    path = Path(args.path)
    text = _read_text(path)
    if args.artifact_type == "plan":
        return validate_plan_text(text)
    if args.artifact_type == "policy-audit":
        return validate_policy_audit_text(text)
    if args.artifact_type == "code-review":
        return validate_code_review_text(text)
    if args.artifact_type == "feature-audit":
        return validate_feature_audit_text(text)
    if args.artifact_type == "orchestrator-state":
        return validate_orchestrator_state_text(
            text, require_complete=bool(args.require_complete)
        )
    return [f"Unsupported artifact type: {args.artifact_type}"]


def main(argv: list[str] | None = None) -> int:
    """Run the orchestration-artifact validator CLI.

    Purpose:
        Execute the stable CLI entrypoint that validates orchestration plans,
        review artifacts, and checkpoint state.

    Args:
        argv (list[str] | None): Optional command-line arguments for testing or
            programmatic invocation.

    Returns:
        int: Exit code `0` for success and `1` for validation failure.

    Raises:
        None.

    Side Effects:
        Reads files from disk and writes validation results to stdout/stderr.
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


if __name__ == "__main__":
    raise SystemExit(main())
