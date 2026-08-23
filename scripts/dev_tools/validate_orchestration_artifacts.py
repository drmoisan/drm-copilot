"""Validate orchestration artifacts under the v2 remediation contract.

The public checkpoint contract separates review verdict/action/path fields,
attempts, and completed cycles. It uses ``blocked_remediation_loop_limit`` for
the unresolved third cycle and rejects ``blocked_cycle_limit`` as legacy input.
Stable ``ORCH_*`` diagnostics retain independent gate identity. Tracked research
uses a feature ``research/`` folder or ``docs/research/``. PR-creation readiness
excludes PR, CI, and pr-author gates; completion retains final lifecycle gates.
Local source/built/packed parity is required before release, while incompatible
published runtimes are external-runtime evidence and do not authorize a publish
or consumer pin.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

from scripts.dev_tools.epic_planner_readiness import build_epic_readiness_context
from scripts.dev_tools.parallel_codex_readiness_filesystem import (
    build_parallel_codex_readiness_evidence,
    build_parallel_readiness_file_context,
)
from scripts.dev_tools.parallel_kickoff_contract import validate_parallel_kickoff_text
from scripts.dev_tools.plan_gate_discrimination import (
    PlanGateContext,
    build_plan_gate_context,
    evaluate_plan_gates,
)
from scripts.dev_tools.validate_epic_orchestrator_state import (
    validate_epic_orchestrator_state_text,
)
from scripts.dev_tools.validate_epic_planner_state import (
    validate_epic_kickoff_text,
    validate_epic_planner_state_text,
)
from scripts.dev_tools.validate_orchestration_review_artifacts import (
    validate_code_review_text,
    validate_feature_audit_text,
)
from scripts.dev_tools.validate_orchestrator_state import (
    validate_orchestrator_state_text,
)
from scripts.dev_tools.validate_parallel_orchestrator_state import (
    validate_parallel_orchestrator_state_text,
)
from scripts.dev_tools.validate_parallel_planner_state import (
    validate_parallel_planner_state_text,
)
from scripts.dev_tools.validate_policy_audit_artifact import validate_policy_audit_text

PLAN_PHASE_RE = re.compile(r"^### Phase (?P<phase>\d+) — (?P<title>.+)$")
PLAN_TASK_RE = re.compile(
    r"^- \[(?P<state>[ xX])\] \[P(?P<phase>\d+)-T(?P<task>\d+)\] (?P<title>.+)$"
)
PLAN_GATE_WARNING_PREFIX = "PLAN GATE WARNING: "
ORCHESTRATOR_STATE_HELP = (
    "Validate REVIEW_VERDICT, REMEDIATION_ACTION, BLOCKER_FINGERPRINT, remediation "
    "paths, and remediation_loop schema version 2 attempt/cycle accounting. "
    "PASS/NONE enters PR readiness; non-actionable results "
    "stop before R1; candidate_applied gates commit/R4; only completed "
    "R4 adds a cycle. "
    "The third unresolved cycle is blocked_remediation_loop_limit; blocked_cycle_limit "
    "is rejected legacy input. ORCH_* diagnostics preserve independent gate identity. "
    "Research uses a tracked feature research/ folder or docs/research/. PR readiness "
    "excludes PR, CI, and pr-author gates; completion retains final lifecycle gates. "
    "Local source/built/packed parity precedes release; incompatible published "
    "runtimes "
    "are external-runtime evidence and never authorize publication or a consumer pin."
)
ROUTING_GATE_BY_CODE = {
    "ORCH_ROUTING_GATE_LEGACY": "legacy",
    "ORCH_ROUTING_GATE_CODEX_MODEL": "codex_model",
    "ORCH_ROUTING_GATE_CODEX_TOPOLOGY": "codex_topology",
}
ROUTING_RECORD_RE = re.compile(
    r"(?:\[(?P<index>\d+)\]|phase (?P<phase>[^ .]+)|delegated agent: (?P<agent>[^.]+))"
)


def _routing_diagnostic_identity(error: str) -> tuple[str, str, str, str] | None:
    """Return the canonical identity for a selected routing diagnostic."""

    for code, gate in ROUTING_GATE_BY_CODE.items():
        prefix = f"{code}: "
        if not error.startswith(prefix):
            continue
        subject = error[len(prefix) :]
        record_match = ROUTING_RECORD_RE.search(subject)
        record_id = record_match.group(0) if record_match is not None else "checkpoint"
        return gate, record_id, code, subject
    return None


def _deduplicate_selected_routing_diagnostics(errors: list[str]) -> list[str]:
    """Preserve order while removing only identical routing identities."""

    result: list[str] = []
    seen: set[tuple[str, str, str, str]] = set()
    for error in errors:
        identity = _routing_diagnostic_identity(error)
        if identity is not None and identity in seen:
            continue
        if identity is not None:
            seen.add(identity)
        result.append(error)
    return result


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
    """Validate canonical atomic-plan structure and acceptance-gate rules.

    Purpose:
        Enforce the repository's required phase and task formatting for atomic
        execution plans, plus the Blocking acceptance-gate findings. The
        signature and return type are unchanged; only Blocking findings are
        returned, so a Warning never reaches this channel.

    Args:
        text (str): Full plan document text.

    Returns:
        list[str]: Structural errors followed by Blocking gate findings.

    Raises:
        None.

    Side Effects:
        None.
    """

    return validate_plan_text_with_warnings(text)[0]


def validate_plan_text_with_warnings(
    text: str, *, context: PlanGateContext | None = None
) -> tuple[list[str], list[str]]:
    """Validate plan structure and gates on two severity channels.

    Purpose:
        Give the CLI and the MCP surface access to the Warning channel without
        widening the existing single-channel entry point, whose non-emptiness
        is the failure signal every caller already depends on.

    Args:
        text (str): Full plan document text.
        context (PlanGateContext | None): Repository seam. When `None` only the
            context-free gate rules run.

    Returns:
        tuple[list[str], list[str]]: Element 0 is the structural errors
        concatenated with the Blocking gate findings; element 1 is the
        Warning findings.

    Raises:
        None.

    Side Effects:
        May query the injected `git` seam via the supplied context.
    """

    report = evaluate_plan_gates(text, context=context)
    return _plan_structure_errors(text) + report.blocking, report.warnings


def _plan_structure_errors(text: str) -> list[str]:
    """Return the canonical phase and task structural errors, in source order."""

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
    """Create the stable orchestration-artifact CLI parser."""

    parser = argparse.ArgumentParser(
        description="Validate deterministic orchestration artifacts."
    )
    subparsers = parser.add_subparsers(dest="artifact_type", required=True)

    # The `plan` route carries a workspace root so the acceptance-gate rules
    # can query the tracked tree, mirroring the `epic-planner-state` subparser.
    plan_parser = subparsers.add_parser("plan")
    plan_parser.add_argument("path")
    plan_parser.add_argument(
        "--workspace-root",
        default=".",
        help="Repository root used for plan acceptance-gate tracked-tree checks.",
    )

    for artifact_type in (
        "policy-audit",
        "code-review",
        "feature-audit",
        "epic-kickoff",
    ):
        artifact_parser = subparsers.add_parser(artifact_type)
        artifact_parser.add_argument("path")

    parallel_kickoff_parser = subparsers.add_parser("parallel-kickoff")
    parallel_kickoff_parser.add_argument("path")
    parallel_kickoff_parser.add_argument(
        "--require-ready-for-execution",
        action="store_true",
        help="Require consistent version-1 committed kickoff identity.",
    )

    state_parser = subparsers.add_parser(
        "orchestrator-state", description=ORCHESTRATOR_STATE_HELP
    )
    state_parser.add_argument("path")
    state_parser.add_argument(
        "--require-complete",
        action="store_true",
        help=(
            "Require the final lifecycle gate, including route-appropriate PR, CI, "
            "pr-author, phase-completeness, and routing requirements."
        ),
    )
    state_parser.add_argument(
        "--require-pr-creation-ready",
        action="store_true",
        help=(
            "Validate a checkpoint is ready for the first `gh pr create` of a "
            "branch. Does not require `ci_gate`, `pr_gate`, or a `pr-author` "
            "delegation receipt, unlike --require-complete."
        ),
    )
    state_parser.add_argument(
        "--require-model-routing",
        action="store_true",
        help=(
            "Once the checkpoint records a delegation, require a matching "
            "model_routing_receipts entry per delegated agent and a "
            "complexity_assessments entry per matched phase. Independent of "
            "--require-complete; delegation-free checkpoints are unaffected."
        ),
    )
    state_parser.add_argument(
        "--require-codex-model-routing",
        action="store_true",
        help=(
            "Once the checkpoint records a delegation, require a deterministic "
            "codex_model_routing_receipts entry for each delegated agent."
        ),
    )
    state_parser.add_argument(
        "--require-codex-topology",
        action="store_true",
        help=(
            "Require a deterministic codex_topology_receipts decision and "
            "the exact resolved initial-agent delegation."
        ),
    )

    epic_state_parser = subparsers.add_parser("epic-orchestrator-state")
    epic_state_parser.add_argument("path")
    epic_state_parser.add_argument(
        "--require-complete",
        action="store_true",
        help="Require every feature to be merged/removed and the final PR recorded.",
    )
    epic_state_parser.add_argument(
        "--require-codex-model-routing",
        action="store_true",
        help="Require a Codex deployment receipt for each epic delegation.",
    )
    epic_state_parser.add_argument(
        "--require-codex-topology",
        action="store_true",
        help="Require the epic root and child-orchestrator topology receipts.",
    )
    planner_state_parser = subparsers.add_parser("epic-planner-state")
    planner_state_parser.add_argument("path")
    planner_state_parser.add_argument(
        "--workspace-root",
        default=".",
        help="Repository root used for readiness artifact and Git integrity checks.",
    )
    planner_state_parser.add_argument(
        "--require-ready-for-execution",
        action="store_true",
        help="Require every child to be prepared and preflight-cleared.",
    )

    parallel_state_parser = subparsers.add_parser("parallel-orchestrator-state")
    parallel_state_parser.add_argument("path")
    parallel_state_parser.add_argument(
        "--workspace-root",
        default=".",
        help="Repository root used for guarded Codex readiness evidence.",
    )
    parallel_state_parser.add_argument(
        "--require-complete",
        action="store_true",
        help=(
            "Require the mode-dependent completion gate: every non-withdrawn "
            "item merged or worktree-removed, plus a close mutation in open mode."
        ),
    )

    parallel_planner_parser = subparsers.add_parser("parallel-planner-state")
    parallel_planner_parser.add_argument("path")
    parallel_planner_parser.add_argument(
        "--workspace-root",
        default=".",
        help="Repository root used for guarded Codex readiness evidence.",
    )
    parallel_planner_parser.add_argument(
        "--require-ready-for-execution",
        action="store_true",
        help=(
            "Require the structural readiness gate: every item prepared and "
            "preflight-cleared, with the execution-ready sentinel recorded."
        ),
    )
    return parser


def _validate_from_args(args: argparse.Namespace) -> list[str]:
    """Dispatch the requested validator and return its error channel only.

    Purpose:
        Preserve the single-channel dispatch contract every existing caller and
        test depends on. Warnings reach `main` through the sibling below.

    Args:
        args (argparse.Namespace): Parsed CLI arguments.

    Returns:
        list[str]: Validation errors produced by the selected validator.

    Raises:
        None.

    Side Effects:
        Reads the target artifact from disk.
    """

    if args.artifact_type == "plan":
        return _plan_channels(args)[0]
    path = Path(args.path)
    if (
        args.artifact_type
        in (
            "epic-planner-state",
            "parallel-orchestrator-state",
            "parallel-planner-state",
        )
        and not path.is_absolute()
    ):
        path = Path(getattr(args, "workspace_root", ".")) / path
    return _validate_errors_only(args, _read_text(path))


def _plan_channels(args: argparse.Namespace) -> tuple[list[str], list[str]]:
    """Validate a plan artifact on both channels, building the repository seam."""

    text = _read_text(Path(args.path))
    context = build_plan_gate_context(Path(getattr(args, "workspace_root", ".")))
    return validate_plan_text_with_warnings(text, context=context)


def _validate_from_args_with_warnings(
    args: argparse.Namespace,
) -> tuple[list[str], list[str]]:
    """Dispatch the requested validator on both severity channels.

    Purpose:
        Route the parsed CLI request without changing the public artifact-type
        names accepted by the entrypoint. Only the `plan` route can populate
        the Warning channel today; every other route returns an empty list.

    Args:
        args (argparse.Namespace): Parsed CLI arguments.

    Returns:
        tuple[list[str], list[str]]: Validation errors and Warning findings.

    Raises:
        None. Reads the target artifact from disk and, for the `plan` route,
        may query `git` through the built plan-gate context.
    """

    if args.artifact_type == "plan":
        return _plan_channels(args)
    return _validate_from_args(args), []


def _validate_errors_only(args: argparse.Namespace, text: str) -> list[str]:
    """Route every non-plan artifact type to its single-channel validator."""

    if args.artifact_type == "policy-audit":
        return validate_policy_audit_text(text)
    if args.artifact_type == "code-review":
        return validate_code_review_text(text)
    if args.artifact_type == "feature-audit":
        return validate_feature_audit_text(text)
    if args.artifact_type == "epic-kickoff":
        return validate_epic_kickoff_text(text)
    if args.artifact_type == "orchestrator-state":
        return _deduplicate_selected_routing_diagnostics(
            validate_orchestrator_state_text(
                text,
                require_complete=bool(args.require_complete),
                require_pr_creation_ready=bool(args.require_pr_creation_ready),
                require_model_routing=bool(args.require_model_routing),
                require_codex_model_routing=bool(
                    getattr(args, "require_codex_model_routing", False)
                ),
                require_codex_topology=bool(
                    getattr(args, "require_codex_topology", False)
                ),
            )
        )
    if args.artifact_type == "epic-orchestrator-state":
        return validate_epic_orchestrator_state_text(
            text,
            require_complete=bool(args.require_complete),
            require_codex_model_routing=bool(
                getattr(args, "require_codex_model_routing", False)
            ),
            require_codex_topology=bool(getattr(args, "require_codex_topology", False)),
        )
    if args.artifact_type == "epic-planner-state":
        readiness_context = None
        if bool(args.require_ready_for_execution):
            readiness_context = build_epic_readiness_context(
                Path(args.workspace_root), Path(args.path)
            )
        return validate_epic_planner_state_text(
            text,
            require_ready_for_execution=bool(args.require_ready_for_execution),
            readiness_context=readiness_context,
        )
    if args.artifact_type == "parallel-orchestrator-state":
        require_complete = bool(getattr(args, "require_complete", False))
        readiness_errors: tuple[str, ...] = ()
        readiness_context = None
        if require_complete:
            readiness = build_parallel_codex_readiness_evidence(
                text,
                build_parallel_readiness_file_context(
                    Path(getattr(args, "workspace_root", ".")), Path(args.path)
                ),
            )
            readiness_errors = readiness.errors
            readiness_context = readiness.evidence
        return [
            *readiness_errors,
            *validate_parallel_orchestrator_state_text(
                text,
                require_complete=require_complete,
                readiness_context=readiness_context,
            ),
        ]
    if args.artifact_type == "parallel-planner-state":
        require_ready = bool(getattr(args, "require_ready_for_execution", False))
        readiness_errors = ()
        readiness_context = None
        if require_ready:
            readiness = build_parallel_codex_readiness_evidence(
                text,
                build_parallel_readiness_file_context(
                    Path(getattr(args, "workspace_root", ".")), Path(args.path)
                ),
            )
            readiness_errors = readiness.errors
            readiness_context = readiness.evidence
        return [
            *readiness_errors,
            *validate_parallel_planner_state_text(
                text,
                require_ready_for_execution=require_ready,
                readiness_context=readiness_context,
            ),
        ]
    if args.artifact_type == "parallel-kickoff":
        return validate_parallel_kickoff_text(
            text,
            require_ready_for_execution=bool(
                getattr(args, "require_ready_for_execution", False)
            ),
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
    errors, warnings = _validate_from_args_with_warnings(args)
    # Error lines are emitted exactly as before, then the warning lines, so a
    # run with no warnings produces byte-identical stderr.
    for error in errors:
        print(error, file=sys.stderr)
    for warning in warnings:
        print(f"{PLAN_GATE_WARNING_PREFIX}{warning}", file=sys.stderr)
    # The exit code is derived from the error list alone; warnings never fail.
    if errors:
        return 1
    print(f"{args.artifact_type} validation passed: {args.path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
