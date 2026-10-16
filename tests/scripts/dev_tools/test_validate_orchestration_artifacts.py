"""Tests for the orchestration artifact validator."""

from __future__ import annotations

import scripts.dev_tools.validate_epic_orchestrator_state as epic_state_validator
import scripts.dev_tools.validate_orchestration_artifacts as validator
import scripts.dev_tools.validate_orchestration_review_artifacts as review_validator
import scripts.dev_tools.validate_orchestrator_state as state_validator
from tests.scripts.dev_tools.validate_orchestration_artifacts_test_support import (
    build_valid_policy_audit_text,
)


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
    assert (
        validator.validate_epic_orchestrator_state_text
        is epic_state_validator.validate_epic_orchestrator_state_text
    )
