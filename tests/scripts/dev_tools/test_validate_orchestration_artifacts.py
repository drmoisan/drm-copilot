"""Tests for the orchestration artifact validator."""

from __future__ import annotations

import argparse
import json
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_orchestration_artifacts as validator
import scripts.dev_tools.validate_orchestration_review_artifacts as review_validator
import scripts.dev_tools.validate_orchestrator_state as state_validator

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from pytest import MonkeyPatch


def build_valid_orchestrator_state() -> dict[str, object]:
    """Return a minimally valid orchestrator-state payload for test mutation."""

    return {
        "objective": "obj",
        "change_budget_estimate": "large",
        "path_selected": "large",
        "promotion-type": "feature",
        "short-name": "short",
        "relativeFile": "docs/features/potential/x.md",
        "long-name": "feature-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/feature-1",
        "work-mode": "full-feature",
        "plan-path": "docs/features/active/feature-1/plan.md",
        "completed_steps": [],
        "next_step": "done",
        "last_updated": "2026-04-07T10:00:00-04:00",
        "step5_status": "not-applicable",
        "step6_status": "not-applicable",
        "step7_status": "verified",
        "step8_status": "not-applicable",
        "step9_status": "verified",
        "step10_status": "not-applicable",
        "delegation_receipts": [
            {
                "step": "7",
                "agent_name": "atomic-planner",
                "agent_id": "a1",
                "skill_source": "orchestrator-workflow",
                "started_at": "2026-04-07T09:00:00-04:00",
                "completed_at": "2026-04-07T09:05:00-04:00",
                "result_signal": "PREFLIGHT: ALL CLEAR",
                "artifact_paths": ["docs/features/active/feature-1/plan.md"],
            }
        ],
        "blocked_reason": "none",
    }


def build_valid_policy_audit_text() -> str:
    """Return a policy-audit document that satisfies structural and evidence gates."""

    return "\n".join(
        (
            "# Policy Compliance Audit: Component",
            "**Audit Date:** 2026-04-12",
            "**Code Under Test:** `src/example.ts`, `scripts/example.ps1`",
            "**Coverage Metrics by Language:**",
            "",
            (
                "| Language | Files Changed | Tests | Test Result | "
                "Baseline Coverage | Post-Change Coverage | "
                "New Code Coverage |"
            ),
            (
                "|----------|--------------|-------|-------------|"
                "-------------------|---------------------|"
                "-------------------|"
            ),
            (
                "| TypeScript | 2 files | 12 tests | [✅] 12 pass, 0 fail | "
                "91% lines, 88% functions | 93% lines, 90% functions | 95% |"
            ),
            (
                "| PowerShell | 1 file | 8 tests | [✅] 8 pass, 0 fail | "
                "84% commands, 82% functions | 86% commands, 84% functions | "
                "92% |"
            ),
            "",
            "### Coverage Evidence Checklist",
            "",
            (
                "- TypeScript baseline coverage artifact: "
                "docs/features/active/example/evidence/baseline/typescript.md"
            ),
            (
                "- TypeScript post-change coverage artifact: "
                "docs/features/active/example/evidence/qa-gates/typescript.md"
            ),
            (
                "- PowerShell baseline coverage artifact: "
                "docs/features/active/example/evidence/baseline/powershell.md"
            ),
            (
                "- PowerShell post-change coverage artifact: "
                "docs/features/active/example/evidence/qa-gates/powershell.md"
            ),
            "- Per-language comparison summary: Section 1.2.1",
            "## Executive Summary",
            "## 1. General Unit Test Policy Compliance",
            "### 1.2.1 Per-Language Coverage Comparison",
            (
                "- TypeScript: Baseline: 91% lines, 88% functions -> "
                "Post-change: 93% lines, 90% functions. Change: +2% lines, "
                "+2% functions. New/changed-code coverage: 95%. "
                "Disposition: PASS. Evidence: "
                "docs/features/active/example/evidence/baseline/typescript.md; "
                "docs/features/active/example/evidence/qa-gates/typescript.md."
            ),
            (
                "- PowerShell: Baseline: 84% commands, 82% functions -> "
                "Post-change: 86% commands, 84% functions. Change: "
                "+2% commands, +2% functions. New/changed-code coverage: 92%. "
                "Disposition: PASS. Evidence: "
                "docs/features/active/example/evidence/baseline/powershell.md; "
                "docs/features/active/example/evidence/qa-gates/powershell.md."
            ),
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
    )


def build_read_text_stub(text: str) -> Callable[[Path], str]:
    """Return a typed `_read_text` replacement for monkeypatched CLI tests."""

    def _stub(_path: Path) -> str:
        return text

    return _stub


def get_first_receipt(state: dict[str, object]) -> dict[str, object]:
    """Return the first typed delegation receipt from a valid state payload."""

    receipts = cast("list[dict[str, object]]", state["delegation_receipts"])
    return dict(receipts[0])


def build_namespaced_orchestrator_state() -> dict[str, object]:
    """Return a valid orchestrator-state payload using the promotion namespace."""

    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = {
        "promotion": {
            "potential_entry": {"path": "docs/features/potential/demo.md"},
            "issue": "https://github.com/drmoisan/drm-copilot/issues/168",
            "feature_folder": {
                "path": (
                    "docs/features/active/2026-04-29-"
                    "harden-feature-promotion-lifecycle-mcp-only-168"
                )
            },
        }
    }
    return state


def test_validate_plan_text_rejects_noncanonical_phase_heading() -> None:
    """Reject colon-style phase headings."""

    text = "\n".join(
        (
            "### Phase 0: Baseline",
            "- [ ] [P0-T1] Capture baseline",
        )
    )

    errors = validator.validate_plan_text(text)

    assert any("phase heading" in error for error in errors)


def test_validate_plan_text_rejects_nonsequential_task_numbers() -> None:
    """Reject plans that skip task numbers inside a phase."""

    text = "\n".join(
        (
            "### Phase 0 — Baseline",
            "- [ ] [P0-T1] Capture baseline",
            "- [ ] [P0-T3] Capture more baseline",
        )
    )

    errors = validator.validate_plan_text(text)

    assert any("expected task number" in error for error in errors)


def test_validate_policy_audit_text_rejects_template_block() -> None:
    """Reject policy audits that retain template instructions."""

    errors = validator.validate_policy_audit_text(
        "# Policy Compliance Audit: [Component Name]\n\n"
        "> **Template Usage Instructions:**"
    )

    assert "template instruction block" in errors[0]


def test_validate_policy_audit_text_requires_checklist_lines() -> None:
    """Reject policy audits that omit the required coverage checklist."""

    errors = validator.validate_policy_audit_text(
        build_valid_policy_audit_text().replace(
            "- PowerShell post-change coverage artifact: "
            "docs/features/active/example/evidence/qa-gates/powershell.md\n",
            "",
        )
    )

    assert any("required checklist line" in error for error in errors)


def test_validate_policy_audit_text_requires_numeric_coverage_values() -> None:
    """Reject policy audits that omit numeric coverage metrics."""

    errors = validator.validate_policy_audit_text(
        build_valid_policy_audit_text().replace(
            "91% lines, 88% functions",
            "baseline pending",
            1,
        )
    )

    assert any("numeric baseline coverage for TypeScript" in error for error in errors)


def test_validate_code_review_text_requires_findings_table() -> None:
    """Reject code reviews without the required findings table."""

    errors = validator.validate_code_review_text(
        "# Code Review\n\n## Executive Summary\n\nMissing findings table."
    )

    assert any("findings table" in error for error in errors)


def test_validate_feature_audit_text_requires_canonical_headings() -> None:
    """Reject feature audits that omit the required sections."""

    errors = validator.validate_feature_audit_text(
        "# Feature Audit\n\n## Summary\n\nIncomplete."
    )

    assert any("Acceptance Criteria Inventory" in error for error in errors)


def test_entrypoint_reexports_split_validator_functions() -> None:
    """Require the stable entrypoint module to re-export the split validators.

    Purpose:
        Lock in the split-module layout while preserving the existing import
        contract for callers that still import from the stable CLI entrypoint.

    Args:
        None.

    Returns:
        None: Assertions verify that the entrypoint aliases the extracted
        review-artifact and orchestrator-state validators.

    Raises:
        None.

    Side Effects:
        None.
    """

    assert (
        validator.validate_policy_audit_text
        is review_validator.validate_policy_audit_text
    )
    assert (
        validator.validate_code_review_text
        is review_validator.validate_code_review_text
    )
    assert (
        validator.validate_feature_audit_text
        is review_validator.validate_feature_audit_text
    )
    assert (
        validator.validate_orchestrator_state_text
        is state_validator.validate_orchestrator_state_text
    )


def test_validate_orchestrator_state_text_requires_receipts_for_completion() -> None:
    """Reject complete-state checkpoints that still show blocked delegation."""

    state = build_valid_orchestrator_state()
    state["step8_status"] = "blocked"

    errors = validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("step8_status is blocked" in error for error in errors)


def test_validate_orchestrator_state_text_accepts_legacy_list_delegation_receipts() -> (
    None
):
    """Allow the legacy list-based delegation receipt payload."""

    errors = validator.validate_orchestrator_state_text(
        json.dumps(build_valid_orchestrator_state())
    )

    assert errors == []


def test_validate_orchestrator_state_text_accepts_promotion_receipt_namespace() -> None:
    """Allow the additive promotion receipt namespace without normalizing values."""

    errors = validator.validate_orchestrator_state_text(
        json.dumps(build_namespaced_orchestrator_state())
    )

    assert errors == []


def test_validate_orchestrator_state_text_rejects_json_root_that_is_not_an_object() -> (
    None
):
    """Reject orchestrator-state payloads whose JSON root is not an object."""

    errors = validator.validate_orchestrator_state_text("[]")

    assert errors == ["Checkpoint root must be a JSON object."]


def test_validate_orchestrator_state_rejects_noncontainer_receipts() -> None:
    """Reject scalar delegation receipt payloads that are not containers."""

    state = build_valid_orchestrator_state()
    state["delegation_receipts"] = "invalid"

    errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert any(
        "delegation_receipts must be a list or object namespace" in error
        for error in errors
    )


def test_validate_orchestrator_state_rejects_unknown_promotion_receipt_keys() -> None:
    """Reject nested promotion receipt keys outside the documented namespace."""

    state = build_namespaced_orchestrator_state()
    promotion = cast(
        "dict[str, object]",
        cast("dict[str, object]", state["delegation_receipts"])["promotion"],
    )
    promotion["extra_key"] = {"unexpected": True}

    errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert any(
        "delegation_receipts.promotion contains unsupported key: extra_key" in error
        for error in errors
    )


def test_validate_orchestrator_state_text_rejects_receipt_missing_result_signal() -> (
    None
):
    """Reject receipts that omit the contract-required result signal."""

    state = build_valid_orchestrator_state()
    receipt = get_first_receipt(state)
    receipt.pop("result_signal")
    state["delegation_receipts"] = [receipt]

    errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert any("missing key: result_signal" in error for error in errors)


def test_validate_orchestrator_state_rejects_receipt_nonlist_artifact_paths() -> None:
    """Reject receipts whose artifact path payload is not a list."""

    state = build_valid_orchestrator_state()
    receipt = get_first_receipt(state)
    receipt["artifact_paths"] = "docs/features/active/feature-1/plan.md"
    state["delegation_receipts"] = [receipt]

    errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert any("artifact_paths must be a list" in error for error in errors)


def test_validate_from_args_returns_unsupported_artifact_type(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return an unsupported-artifact error for unknown dispatch values."""

    monkeypatch.setattr(validator, "_read_text", build_read_text_stub("ignored"))
    # Access the private dispatch function via vars() to avoid Pyright
    # reportPrivateUsage and Ruff B009 (getattr with constant) conflicts.
    validate_from_args = cast(
        "Callable[[argparse.Namespace], list[str]]",
        vars(validator)["_validate_from_args"],
    )

    errors = validate_from_args(
        argparse.Namespace(path="ignored.md", artifact_type="unsupported")
    )

    assert errors == ["Unsupported artifact type: unsupported"]


def test_main_returns_exit_code_1_for_an_invalid_plan_artifact(
    monkeypatch: MonkeyPatch,
) -> None:
    """Return failure for an invalid plan artifact using in-memory text."""

    monkeypatch.setattr(
        validator,
        "_read_text",
        build_read_text_stub("### Phase 0: Baseline\n- [ ] [P0-T1] Capture baseline"),
    )

    result = validator.main(["plan", "ignored.md"])

    assert result == 1


def test_main_returns_zero_for_valid_policy_audit(monkeypatch: MonkeyPatch) -> None:
    """Return success for a template-shaped policy audit using in-memory text."""

    monkeypatch.setattr(
        validator,
        "_read_text",
        build_read_text_stub(build_valid_policy_audit_text()),
    )

    result = validator.main(["policy-audit", "ignored.md"])

    assert result == 0
