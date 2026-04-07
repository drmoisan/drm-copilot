"""Tests for the orchestration artifact validator."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING

import scripts.dev_tools.validate_orchestration_artifacts as validator

if TYPE_CHECKING:
    from pathlib import Path


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


def test_validate_orchestrator_state_text_requires_receipts_for_completion() -> None:
    """Reject complete-state checkpoints that still show blocked delegation."""

    state = {
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
        "step8_status": "blocked",
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

    errors = validator.validate_orchestrator_state_text(
        json.dumps(state), require_complete=True
    )

    assert any("step8_status is blocked" in error for error in errors)


def test_main_returns_zero_for_valid_policy_audit(tmp_path: Path) -> None:
    """Return success for a template-shaped policy audit."""

    audit_path = tmp_path / "policy-audit.md"
    audit_path.write_text(
        "\n".join(
            (
                "# Policy Compliance Audit: Component",
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
        ),
        encoding="utf-8",
    )

    result = validator.main(["policy-audit", str(audit_path)])

    assert result == 0
