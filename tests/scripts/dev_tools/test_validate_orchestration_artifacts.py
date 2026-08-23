"""Tests for the orchestration artifact validator."""

from __future__ import annotations

import json
from typing import TYPE_CHECKING, cast

import scripts.dev_tools.validate_epic_orchestrator_state as epic_state_validator
import scripts.dev_tools.validate_orchestration_artifacts as validator
import scripts.dev_tools.validate_orchestration_review_artifacts as review_validator
import scripts.dev_tools.validate_orchestrator_state as state_validator
import tests.scripts.dev_tools.orchestrator_state_test_support as remediation_support
from scripts.dev_tools.resolve_codex_deployment import resolve_codex_deployment

if TYPE_CHECKING:
    from collections.abc import Callable
    from pathlib import Path

    from pytest import MonkeyPatch

deduplicate_selected_routing_diagnostics = cast(
    "Callable[[list[str]], list[str]]",
    vars(validator)["_deduplicate_selected_routing_diagnostics"],
)


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


def build_complete_large_orchestrator_state() -> dict[str, object]:
    """Return a completion-safe large-route checkpoint for CLI tests."""

    from scripts.dev_tools._orchestrator_state_routing import load_routing_matrix

    matrix = load_routing_matrix()
    large = cast(
        "dict[str, object]",
        cast("dict[str, object]", matrix["routes"])["large"],
    )
    required_agents = cast("list[str]", large["required_agents"])
    required_skills = cast("list[str]", large["required_skills"])
    required_mcp_tools = cast("list[str]", large["required_mcp_tools"])
    return {
        "objective": "obj",
        "change_budget_estimate": "large",
        "route_id": "large",
        "path_selected": "large",
        "promotion-type": "feature",
        "short-name": "short",
        "relativeFile": "docs/features/potential/x.md",
        "long-name": "feature-1",
        "issue-num": "1",
        "feature-folder": "docs/features/active/feature-1",
        "work-mode": "full-feature",
        "plan-path": "docs/features/active/feature-1/plan.md",
        "completed_steps": ["S7", "S8", "S9"],
        "next_step": "done",
        "last_updated": "2026-04-07T10:00:00-04:00",
        "step5_status": "not-applicable",
        "step6_status": "not-applicable",
        "step7_status": "verified",
        "step8_status": "verified",
        "step9_status": "verified",
        "step10_status": "not-applicable",
        "pr_gate": {
            "pr_number": 1,
            "pr_url": "https://github.com/drmoisan/drm-copilot/pull/1",
            "head_branch": "feature-1",
            "head_sha": "current-head-sha",
        },
        "ci_gate": {
            "conclusion": "success",
            "head_sha": "current-head-sha",
            "verified_at": "2026-04-07T10:00:00Z",
        },
        "required_agents": required_agents,
        "required_skills": required_skills,
        "required_mcp_tools": required_mcp_tools,
        "delegation_receipts": [
            {
                "step": f"handoff-{index}",
                "agent_name": agent,
                "agent_id": f"{agent}-1",
                "skill_source": "orchestrate",
                "started_at": "2026-04-07T09:00:00-04:00",
                "completed_at": "2026-04-07T09:05:00-04:00",
                "result_signal": "COMPLETE",
                "artifact_paths": [f"artifacts/orchestration/{agent}.receipt.json"],
            }
            for index, agent in enumerate(required_agents, start=1)
        ],
        "skill_receipts": [
            {
                "skill": skill,
                "required": True,
                "acknowledged_at_phase": "completion",
                "evidence": f"artifact:{skill}",
            }
            for skill in required_skills
        ],
        "mcp_call_receipts": [
            {"tool": tool, "ok": True, "evidence": f"mcp_call:{tool}"}
            for tool in required_mcp_tools
        ],
        "local_execution_overrides": [],
        "delegation_bypasses": [],
        "lifecycle_operations": [
            {"name": tool, "surface": "mcp"} for tool in required_mcp_tools
        ],
        "blocked_reason": "none",
    }


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
    """Require the stable entrypoint to re-export the split validators."""

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


def test_require_pr_creation_ready_is_independent_from_require_complete() -> None:
    """Keep pre-PR readiness independent from completion-only gates."""

    state = build_complete_large_orchestrator_state()
    state.pop("pr_gate")
    state.pop("ci_gate")
    state["delegation_receipts"] = [
        receipt
        for receipt in cast("list[dict[str, object]]", state["delegation_receipts"])
        if receipt["agent_name"] != "pr-author"
    ]
    text = json.dumps(state)

    readiness_errors = state_validator.validate_orchestrator_state_text(
        text, require_pr_creation_ready=True
    )
    completion_errors = state_validator.validate_orchestrator_state_text(
        text, require_complete=True
    )

    assert readiness_errors == []
    assert completion_errors == [
        "Checkpoint completion validation failed: pr_gate must be an object "
        "with keys: pr_number, pr_url, head_branch, head_sha.",
        "Checkpoint completion validation failed: ci_gate must be an object "
        "with keys: conclusion, head_sha, verified_at.",
        "Checkpoint missing required agent receipt: pr-author.",
    ]


def test_codex_commit_steward_receipt_does_not_require_legacy_routing() -> None:
    """Accept Codex commit stewardship without legacy routing receipts."""

    state = build_valid_orchestrator_state()
    delegation = cast("list[dict[str, object]]", state["delegation_receipts"])[0]
    delegation.update(step="S6_commit_steward", agent_name="commit-steward-c4")
    receipt: dict[str, object] = dict(
        resolve_codex_deployment("commit-steward", "C4", "standalone", "C4")
    )
    receipt["phase"] = "S6_commit_steward"
    state["codex_model_routing_receipts"] = [receipt]

    errors = state_validator.validate_orchestrator_state_text(
        json.dumps(state), require_codex_model_routing=True
    )

    assert "model_routing_receipts" not in state
    assert errors == []


def test_selected_routing_diagnostics_are_unique() -> None:
    """Retain the first occurrence and distinct selected routing gates."""

    legacy = "ORCH_ROUTING_GATE_LEGACY: failure for phase S5."
    codex = "ORCH_ROUTING_GATE_CODEX_MODEL: failure for phase S5."
    unrelated = "Checkpoint unrelated failure."

    errors = deduplicate_selected_routing_diagnostics(
        [legacy, legacy, codex, unrelated, codex]
    )

    assert errors == [legacy, codex, unrelated]


def test_pre_and_post_validation_use_identical_flags(
    monkeypatch: MonkeyPatch,
) -> None:
    """Forward the same selected flags across repeated validation boundaries."""

    calls: list[dict[str, bool]] = []

    def _spy(_text: str, **kwargs: bool) -> list[str]:
        calls.append(kwargs)
        return []

    monkeypatch.setattr(validator, "_read_text", build_read_text_stub("{}"))
    monkeypatch.setattr(validator, "validate_orchestrator_state_text", _spy)
    argv = [
        "orchestrator-state",
        "ignored.json",
        "--require-complete",
        "--require-pr-creation-ready",
        "--require-model-routing",
        "--require-codex-model-routing",
        "--require-codex-topology",
    ]

    pre_result = validator.main(argv)
    post_result = validator.main(argv)

    expected = {
        "require_complete": True,
        "require_pr_creation_ready": True,
        "require_model_routing": True,
        "require_codex_model_routing": True,
        "require_codex_topology": True,
    }
    assert [pre_result, post_result] == [0, 0]
    assert calls == [expected, expected]


def test_remediation_limit_status_has_ordered_canonical_diagnostics() -> None:
    """Accept the three-cycle terminal and reject its legacy alias once."""

    fingerprints = (
        remediation_support.BLOCKER_FINGERPRINT_A,
        remediation_support.BLOCKER_FINGERPRINT_B,
    ) * 2
    attempts = [
        remediation_support.build_remediation_attempt(
            attempt_id=index,
            source_review_fingerprint=fingerprints[index - 1],
        )
        for index in range(1, 4)
    ]
    cycles = [
        remediation_support.build_remediation_cycle(
            cycle_id=index,
            attempt_id=index,
            review_verdict="BLOCKED",
            remediation_action="AUTONOMOUS",
            blocker_fingerprint_before=fingerprints[index - 1],
            blocker_fingerprint_after=fingerprints[index],
            blocking_count=1,
            exit_condition_met=False,
        )
        for index in range(1, 4)
    ]
    state = remediation_support.build_valid_orchestrator_state()
    loop = remediation_support.build_remediation_loop(
        status="blocked_remediation_loop_limit", attempts=attempts, cycles=cycles
    )
    state["remediation_loop"] = loop

    canonical_errors = validator.validate_orchestrator_state_text(json.dumps(state))
    assert loop["status"] == "blocked_remediation_loop_limit"
    loop["status"] = "blocked_cycle_limit"
    legacy_errors = validator.validate_orchestrator_state_text(json.dumps(state))

    assert canonical_errors == []
    assert legacy_errors == [
        "ORCH_REMEDIATION_SCHEMA: remediation_loop.status must be a documented status."
    ]
