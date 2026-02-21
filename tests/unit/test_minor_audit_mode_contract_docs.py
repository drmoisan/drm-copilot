"""Contract tests for persisted minor-audit work-mode documentation behavior."""

from __future__ import annotations

from pathlib import Path


def _read_text(path: Path) -> str:
    """Read UTF-8 text from a repository file path."""
    return path.read_text(encoding="utf-8")


def test_feature_review_branching_contract() -> None:
    """Verify feature review agent defines marker-driven AC source branching."""
    path = Path(".github/agents/feature-review.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "issue.md" in content
    assert "spec.md" in content and "user-story.md" in content


def test_epic_review_minor_audit_doc_completeness_contract() -> None:
    """Verify epic review agent defines minor-audit doc completeness contract."""
    path = Path(".github/agents/epic-review.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "doc completeness" in content
    assert "issue.md" in content
    assert "spec.md" in content and "user-story.md" in content
    assert "fallback to full" in content


def test_status_updater_branching_contract() -> None:
    """Verify status updater defines marker-driven Delivered and evidence branching."""
    path = Path(".github/agents/status_updater.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "Delivered" in content
    assert "issue.md" in content
    assert "spec.md" in content and "user-story.md" in content
    assert "evidence" in content


def test_feature_promotion_lifecycle_work_mode_contract() -> None:
    """Verify feature promotion lifecycle includes work-mode command semantics."""
    path = Path(".github/skills/feature-promotion-lifecycle/SKILL.md")
    content = _read_text(path)

    assert "--work-mode" in content
    assert "minor-audit" in content
    assert "issue.md" in content
    assert "spec.md" in content and "user-story.md" in content


def test_atomic_planning_agent_requires_mode_resolution_contract() -> None:
    """Verify atomic planning agent requires marker-first mode resolution contract."""
    path = Path(".github/agents/atomic_planning.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "issue.md" in content
    assert "fail closed to `full`" in content


def test_atomic_executor_agent_requires_preflight_mode_gate_contract() -> None:
    """Verify atomic executor requires mode-aware preflight rejection criteria."""
    path = Path(".github/agents/atomic_executor.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "issue.md" in content
    assert "PREFLIGHT: REVISIONS REQUIRED" in content


def test_python_typed_engineer_requires_mode_aware_planning_handoff_contract() -> None:
    """Verify python-typed-engineer requires mode-aware planning obligations."""
    path = Path(".github/agents/python-typed-engineer.agent.md")
    content = _read_text(path)

    assert "Work Mode: minor-audit" in content
    assert "issue.md" in content
    assert "baseline+targeted+end-state evidence" in content


def test_powershell_atomic_agents_require_mode_aware_preflight_contract() -> None:
    """Verify PowerShell atomic agents declare mode-first fail-closed routing."""
    planning_path = Path(".github/agents/powershell-atomic-planning.agent.md")
    executor_path = Path(".github/agents/powershell-atomic-executor.agent.md")

    planning_content = _read_text(planning_path)
    executor_content = _read_text(executor_path)

    assert "Work Mode: minor-audit" in planning_content
    assert "Work Mode: minor-audit" in executor_content
    assert "fail closed to `full`" in planning_content
    assert "fail closed to `full`" in executor_content


def test_atomic_plan_contract_skill_requires_preflight_directive_and_signals() -> None:
    """Verify atomic-plan-contract includes directive, signals, and precedence."""
    path = Path(".github/skills/atomic-plan-contract/SKILL.md")
    content = _read_text(path)

    assert "DIRECTIVE: PREFLIGHT VALIDATION ONLY" in content
    assert "PREFLIGHT: ALL CLEAR" in content
    assert "PREFLIGHT: REVISIONS REQUIRED" in content
    assert "Mode source precedence" in content


def test_feature_plan_template_forbids_placeholder_tokens() -> None:
    """Verify feature plan template contains no unresolved placeholder tokens."""
    path = Path("docs/features/templates/feature/plan.yyyy-MM-ddTHH-mm.md")
    content = _read_text(path)

    assert "<Phase Name>" not in content
    assert "<Atomic task" not in content
    assert "TBD" not in content
    assert "Add language-specific policies as needed" not in content


def test_feature_review_epic_review_status_updater_branch_by_marker() -> None:
    """Verify the review/status trio defines marker-driven documentation branching."""
    feature_review_content = _read_text(Path(".github/agents/feature-review.agent.md"))
    epic_review_content = _read_text(Path(".github/agents/epic-review.agent.md"))
    status_updater_content = _read_text(Path(".github/agents/status_updater.agent.md"))

    for content in [
        feature_review_content,
        epic_review_content,
        status_updater_content,
    ]:
        assert "Work Mode: minor-audit" in content
        assert "Work Mode: full" in content
        assert "issue.md" in content
        assert "spec.md" in content
        assert "user-story.md" in content
