"""Regression tests for the C# orchestration markdown contracts."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]


def read_repo_text(relative_path: str) -> str:
    """
    Return repository text content for a checked-in contract file.

    Purpose:
        Let markdown contract tests assert required lifecycle language without
        depending on temporary files or external processes.

    Args:
        relative_path (str): Repository-relative path to the text file.

    Returns:
        str: UTF-8 text content for the requested repository file.

    Raises:
        FileNotFoundError: When the requested file does not exist.

    Side Effects:
        Reads a checked-in repository file from disk.
    """
    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def test_csharp_orchestrator_small_path_requires_minor_audit_lifecycle() -> None:
    """Require the C# small path to mirror the enforced short-path lifecycle."""
    agent_text = read_repo_text(".github/agents/csharp-orchestrator.agent.md")

    assert "Build minimal-audit atomic plan (preflight all clear)" in agent_text
    assert "Execute Phase 0 only" in agent_text
    assert "Small-scope implementation path" in agent_text
    assert "Validate small-path delivery and post-QC docs" in agent_text
    assert "Post-implementation small-path audit" in agent_text
    assert "${plan-path}" in agent_text


def test_orchestrate_csharp_work_prompt_requires_minor_audit_lifecycle() -> None:
    """Require the C# prompt to document the enforced short-path lifecycle."""
    prompt_text = read_repo_text(".github/prompts/orchestrate-csharp-work.prompt.md")
    direct_delegate_text = (
        "Delegate directly to `csharp-typed-engineer` for plan + "
        "implementation + QA closure."
    )

    assert "minor-audit" in prompt_text
    assert "DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED" in prompt_text
    assert "PREFLIGHT: ALL CLEAR" in prompt_text
    assert "Phase 0 only" in prompt_text
    assert "validation against issue.md" in prompt_text
    assert direct_delegate_text not in prompt_text


def _assert_state_machine_contract() -> None:
    """Require the C# checkpoint contract to include short-path continuity fields."""
    state_machine_text = read_repo_text(
        ".github/skills/csharp-orchestration-state-machine/SKILL.md"
    )

    assert "work-mode" in state_machine_text
    assert "plan-path" in state_machine_text
    assert "bootstrap_mode" in state_machine_text
    assert "phase0_execution_summary" in state_machine_text
    assert "resume_after_manual_bootstrap" in state_machine_text


test_csharp_orchestration_state_machine_requires_plan_path_and_bootstrap_fields = (
    _assert_state_machine_contract
)


def test_csharp_change_budget_router_requires_orchestrated_small_path_wording() -> None:
    """Require the C# router to describe the enforced short-path lifecycle."""
    router_text = read_repo_text(".github/skills/csharp-change-budget-router/SKILL.md")

    assert "1-3" in router_text
    assert ">3" in router_text
    assert "--work-mode minor-audit" in router_text
    assert "DIRECTIVE: MINIMAL-AUDIT PLAN REQUIRED" in router_text
    assert "PREFLIGHT: ALL CLEAR" in router_text
    assert "Phase 0 only via atomic_executor" in router_text


def _assert_bundle_mirror_contract() -> None:
    """Require bundled C# customizations to mirror root contracts and shared skills."""
    root_agent = read_repo_text(".github/agents/csharp-orchestrator.agent.md")
    mirror_agent_path = REPO_ROOT / (
        "extensions/drm-copilot/resources/customizations/.github/agents/"
        "csharp-orchestrator.agent.md"
    )
    mirror_prompt_path = REPO_ROOT / (
        "extensions/drm-copilot/resources/customizations/.github/prompts/"
        "orchestrate-csharp-work.prompt.md"
    )
    mirror_state_machine_path = REPO_ROOT / (
        "extensions/drm-copilot/resources/customizations/.github/skills/"
        "csharp-orchestration-state-machine/SKILL.md"
    )
    mirror_router_path = REPO_ROOT / (
        "extensions/drm-copilot/resources/customizations/.github/skills/"
        "csharp-change-budget-router/SKILL.md"
    )
    mirror_acceptance_skill_path = REPO_ROOT / (
        "extensions/drm-copilot/resources/customizations/.github/skills/"
        "acceptance-criteria-tracking/SKILL.md"
    )

    assert mirror_agent_path.read_text(encoding="utf-8") == root_agent
    assert mirror_prompt_path.read_text(encoding="utf-8") == read_repo_text(
        ".github/prompts/orchestrate-csharp-work.prompt.md"
    )
    assert mirror_state_machine_path.read_text(encoding="utf-8") == read_repo_text(
        ".github/skills/csharp-orchestration-state-machine/SKILL.md"
    )
    assert mirror_router_path.read_text(encoding="utf-8") == read_repo_text(
        ".github/skills/csharp-change-budget-router/SKILL.md"
    )
    assert mirror_acceptance_skill_path.exists()


test_csharp_customization_bundle_requires_contract_mirror_and_shared_skill_presence = (
    _assert_bundle_mirror_contract
)


def test_csharp_orchestrator_large_path_chain_remains_csharp_atomic_pipeline() -> None:
    """Keep the large-path C# workflow on the existing C# atomic planning chain."""
    agent_text = read_repo_text(".github/agents/csharp-orchestrator.agent.md")

    assert "Build C# atomic plan (preflight all clear)" in agent_text
    assert "Execute approved C# atomic plan" in agent_text
