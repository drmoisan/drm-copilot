"""Validate orchestration plan, review, and checkpoint artifacts.

Purpose:
    Provide a fail-closed validator for deterministic orchestration contracts so
    plan approval, review completion, and checkpoint completion can rely on
    schema checks instead of narrative judgment.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any, cast

PLAN_PHASE_RE = re.compile(r"^### Phase (?P<phase>\d+) — (?P<title>.+)$")
PLAN_TASK_RE = re.compile(
    r"^- \[(?P<state>[ xX])\] \[P(?P<phase>\d+)-T(?P<task>\d+)\] (?P<title>.+)$"
)

POLICY_AUDIT_REQUIRED_HEADINGS = (
    "## Executive Summary",
    "## 1. General Unit Test Policy Compliance",
    "## 2. General Code Change Policy Compliance",
    "## 3. Language-Specific Code Change Policy Compliance",
    "## 4. Language-Specific Unit Test Policy Compliance",
    "## 5. Test Coverage Detail",
    "## 6. Test Execution Metrics",
    "## 7. Code Quality Checks",
    "## 8. Gaps and Exceptions",
    "## 9. Summary of Changes",
    "## 10. Compliance Verdict",
    "## Appendix A: Test Inventory",
    "## Appendix B: Toolchain Commands Reference",
)
CODE_REVIEW_REQUIRED_HEADINGS = (
    "## Executive Summary",
    "## Findings Table",
)
FEATURE_AUDIT_REQUIRED_HEADINGS = (
    "## Scope and Baseline",
    "## Acceptance Criteria Inventory",
    "## Acceptance Criteria Evaluation",
    "## Summary",
    "## Acceptance Criteria Check-off",
)
REQUIRED_STATE_KEYS = (
    "objective",
    "change_budget_estimate",
    "path_selected",
    "promotion-type",
    "short-name",
    "relativeFile",
    "long-name",
    "issue-num",
    "feature-folder",
    "work-mode",
    "plan-path",
    "completed_steps",
    "next_step",
    "last_updated",
    "step5_status",
    "step6_status",
    "step7_status",
    "step8_status",
    "step9_status",
    "step10_status",
    "delegation_receipts",
    "blocked_reason",
)
VALID_STEP_STATUS = {"not-applicable", "pending", "delegated", "verified", "blocked"}
VALID_BLOCKED_REASONS = {
    "none",
    "spawn_agent_unavailable",
    "delegation_launch_failed",
    "delegate_no_receipt",
    "delegate_contract_incomplete",
    "validator_failed",
    "user_requested_stop",
}
REQUIRED_RECEIPT_KEYS = (
    "step",
    "agent_name",
    "agent_id",
    "skill_source",
    "started_at",
    "completed_at",
    "result_signal",
    "artifact_paths",
)


def _read_text(path: Path) -> str:
    """Read a UTF-8 artifact from disk."""

    return path.read_text(encoding="utf-8")


def validate_plan_text(text: str) -> list[str]:
    """Validate canonical atomic-plan structure."""

    errors: list[str] = []
    current_phase: int | None = None
    seen_phases: list[int] = []
    expected_task_num: dict[int, int] = {}
    found_task = False

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


def validate_policy_audit_text(text: str) -> list[str]:
    """Validate template-derived policy-audit structure."""

    errors: list[str] = []
    if "Template Usage Instructions" in text:
        errors.append("Policy audit still contains the template instruction block.")
    if "[Component Name]" in text:
        errors.append("Policy audit still contains placeholder component text.")
    for heading in POLICY_AUDIT_REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"Policy audit missing required heading: {heading}")
    return errors


def validate_code_review_text(text: str) -> list[str]:
    """Validate audit-grade code-review structure."""

    errors: list[str] = []
    for heading in CODE_REVIEW_REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"Code review missing required heading: {heading}")
    table_header = (
        "| Severity | File | Location | Finding | Recommendation | "
        "Rationale | Evidence |"
    )
    if table_header not in text:
        errors.append("Code review missing the required findings table header.")
    return errors


def validate_feature_audit_text(text: str) -> list[str]:
    """Validate feature-audit structure."""

    errors: list[str] = []
    for heading in FEATURE_AUDIT_REQUIRED_HEADINGS:
        if heading not in text:
            errors.append(f"Feature audit missing required heading: {heading}")
    return errors


def validate_orchestrator_state_text(
    text: str, *, require_complete: bool = False
) -> list[str]:
    """Validate checkpoint schema and completion-state fields."""

    errors: list[str] = []
    try:
        state = json.loads(text)
    except json.JSONDecodeError as exc:
        return [f"Checkpoint is not valid JSON: {exc}"]

    if not isinstance(state, dict):
        return ["Checkpoint root must be a JSON object."]
    state_map = cast(dict[str, Any], state)

    for key in REQUIRED_STATE_KEYS:
        if key not in state_map:
            errors.append(f"Checkpoint missing required key: {key}")

    for key in (
        "step5_status",
        "step6_status",
        "step7_status",
        "step8_status",
        "step9_status",
        "step10_status",
    ):
        value = state_map.get(key)
        if value is not None and value not in VALID_STEP_STATUS:
            errors.append(f"Checkpoint has invalid {key}: {value}")

    blocked_reason = state_map.get("blocked_reason")
    if blocked_reason is not None and blocked_reason not in VALID_BLOCKED_REASONS:
        errors.append(f"Checkpoint has invalid blocked_reason: {blocked_reason}")

    receipts = state_map.get("delegation_receipts")
    if receipts is not None and not isinstance(receipts, list):
        errors.append("Checkpoint delegation_receipts must be a list.")
    if isinstance(receipts, list):
        typed_receipts = cast(list[object], receipts)
        for index, receipt in enumerate(typed_receipts):
            if not isinstance(receipt, dict):
                errors.append(
                    f"Checkpoint delegation receipt #{index} must be an object."
                )
                continue
            for key in REQUIRED_RECEIPT_KEYS:
                if key not in receipt:
                    errors.append(
                        f"Checkpoint delegation receipt #{index} missing key: {key}"
                    )
            artifact_paths = cast(dict[str, Any], receipt).get("artifact_paths")
            if artifact_paths is not None and not isinstance(artifact_paths, list):
                errors.append(
                    "Checkpoint delegation receipt "
                    f"#{index} artifact_paths must be a list."
                )

    if require_complete:
        for key in (
            "step5_status",
            "step6_status",
            "step7_status",
            "step8_status",
            "step9_status",
            "step10_status",
        ):
            value = state_map.get(key)
            if value in {"pending", "blocked"}:
                errors.append(
                    f"Checkpoint completion validation failed: {key} is {value}."
                )
        if state_map.get("blocked_reason") not in {None, "none"}:
            errors.append(
                "Checkpoint completion validation failed: blocked_reason is not `none`."
            )
    return errors


def build_parser() -> argparse.ArgumentParser:
    """Create the CLI parser."""

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
    """Dispatch the requested validator."""

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
    """Run the orchestration-artifact validator CLI."""

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
