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
COVERAGE_PERCENT_RE = re.compile(r"\b\d+(?:\.\d+)?%")

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
POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS = (
    "TypeScript baseline coverage artifact:",
    "TypeScript post-change coverage artifact:",
    "PowerShell baseline coverage artifact:",
    "PowerShell post-change coverage artifact:",
    "Per-language comparison summary:",
)
POLICY_AUDIT_COMPARISON_HEADING = "### 1.2.1 Per-Language Coverage Comparison"
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
PLACEHOLDER_MARKERS = (
    "[n]",
    "[path",
    "[artifact",
    "[section reference",
    "[language]",
    "tbd",
    "unverified",
    "missing",
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


def _has_numeric_coverage(value: str) -> bool:
    """Return True when a coverage value contains a numeric percentage."""

    return COVERAGE_PERCENT_RE.search(value) is not None


def _is_na_value(value: str) -> bool:
    """Return True when an audit field explicitly records not-applicable."""

    return value.strip().lower().startswith("n/a")


def _has_placeholder_marker(value: str) -> bool:
    """Return True when an audit field still contains template placeholders."""

    lowered = value.lower()
    return any(marker in lowered for marker in PLACEHOLDER_MARKERS)


def _extract_policy_audit_coverage_rows(text: str) -> list[dict[str, str]]:
    """Parse the coverage metrics table rows from a policy audit."""

    rows: list[dict[str, str]] = []
    for line in text.splitlines():
        if not line.startswith("|"):
            continue
        cells = [cell.strip() for cell in line.split("|")[1:-1]]
        if len(cells) != 7:
            continue
        language = cells[0]
        if language in {"Language", "----------"} or not language:
            continue
        if set(language) == {"-"}:
            continue
        rows.append(
            {
                "Language": language,
                "Files Changed": cells[1],
                "Tests": cells[2],
                "Test Result": cells[3],
                "Baseline Coverage": cells[4],
                "Post-Change Coverage": cells[5],
                "New Code Coverage": cells[6],
            }
        )
    return rows


def _find_policy_audit_checklist_line(text: str, label: str) -> str | None:
    """Return the checklist line containing the provided label, if present."""

    for line in text.splitlines():
        stripped = line.strip()
        if stripped.startswith("- ") and label in stripped:
            return stripped
    return None


def _extract_policy_audit_comparison_lines(text: str) -> dict[str, str]:
    """Return per-language comparison lines keyed by normalized language name."""

    in_section = False
    comparison_lines: dict[str, str] = {}

    for line in text.splitlines():
        stripped = line.strip()
        if stripped == POLICY_AUDIT_COMPARISON_HEADING:
            in_section = True
            continue
        if in_section and stripped.startswith("### "):
            break
        if not in_section or not stripped.startswith("- "):
            continue
        language, separator, _ = stripped[2:].partition(":")
        if not separator:
            continue
        comparison_lines[language.strip().lower()] = stripped

    return comparison_lines


def _comparison_line_has_labelled_percentage(line: str, label: str) -> bool:
    """Return True when the line contains a numeric percentage after a label."""

    pattern = re.compile(rf"{re.escape(label)}.*?\d+(?:\.\d+)?%")
    return pattern.search(line) is not None


def validate_policy_audit_substantive_requirements(text: str) -> list[str]:
    """Validate policy-audit evidence requirements beyond headings."""

    errors: list[str] = []

    for label in POLICY_AUDIT_REQUIRED_CHECKLIST_LABELS:
        line = _find_policy_audit_checklist_line(text, label)
        if line is None:
            errors.append(f"Policy audit missing required checklist line: {label}")
            continue
        if _has_placeholder_marker(line):
            errors.append(
                f"Policy audit checklist line still contains placeholder text: {label}"
            )

    coverage_rows = _extract_policy_audit_coverage_rows(text)
    if not coverage_rows:
        errors.append("Policy audit missing coverage metrics table rows.")

    if POLICY_AUDIT_COMPARISON_HEADING not in text:
        errors.append(
            "Policy audit missing required heading: "
            f"{POLICY_AUDIT_COMPARISON_HEADING}"
        )

    comparison_lines = _extract_policy_audit_comparison_lines(text)
    for row in coverage_rows:
        language = row["Language"]
        baseline = row["Baseline Coverage"]
        post_change = row["Post-Change Coverage"]
        new_code = row["New Code Coverage"]
        requires_coverage_comparison = any(
            not _is_na_value(value) for value in (baseline, post_change, new_code)
        )

        if not _is_na_value(baseline) and not _has_numeric_coverage(baseline):
            errors.append(
                f"Policy audit missing numeric baseline coverage for {language}."
            )
        if not _is_na_value(post_change) and not _has_numeric_coverage(post_change):
            errors.append(
                f"Policy audit missing numeric post-change coverage for {language}."
            )
        if not _is_na_value(new_code) and not _has_numeric_coverage(new_code):
            errors.append(
                f"Policy audit missing numeric new/changed-code coverage for "
                f"{language}."
            )

        if not requires_coverage_comparison:
            continue

        comparison_line = comparison_lines.get(language.lower())
        if comparison_line is None:
            errors.append(
                "Policy audit missing per-language comparison line for " f"{language}."
            )
            continue

        if not _comparison_line_has_labelled_percentage(comparison_line, "Baseline:"):
            errors.append(
                f"Policy audit comparison line missing numeric baseline for "
                f"{language}."
            )
        if not _comparison_line_has_labelled_percentage(
            comparison_line, "Post-change:"
        ):
            errors.append(
                f"Policy audit comparison line missing numeric post-change "
                f"coverage for {language}."
            )
        if "Change:" not in comparison_line:
            errors.append(
                f"Policy audit comparison line missing explicit change text for "
                f"{language}."
            )
        if (
            re.search(
                r"Disposition:\s*(PASS|FAIL|N/A|INCOMPLETE|BLOCKED)",
                comparison_line,
            )
            is None
        ):
            errors.append(
                f"Policy audit comparison line missing disposition for " f"{language}."
            )
        if not _is_na_value(new_code) and not _comparison_line_has_labelled_percentage(
            comparison_line, "New/changed-code coverage:"
        ):
            errors.append(
                "Policy audit comparison line missing numeric new/changed-code "
                f"coverage for {language}."
            )
        if "Evidence:" not in comparison_line:
            errors.append(
                f"Policy audit comparison line missing evidence reference for "
                f"{language}."
            )
        elif _has_placeholder_marker(comparison_line):
            errors.append(
                "Policy audit comparison line still contains placeholder text for "
                f"{language}."
            )

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
    errors.extend(validate_policy_audit_substantive_requirements(text))
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
    state_map = cast("dict[str, Any]", state)

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
        typed_receipts = cast("list[object]", receipts)
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
            artifact_paths = cast("dict[str, Any]", receipt).get("artifact_paths")
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
