"""Regression tests for orchestrator direct-command markdown contracts."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
ROOT_ORCHESTRATOR_AGENT_PATHS = (
    ".github/agents/orchestrator.agent.md",
    ".github/agents/python-orchestrator.agent.md",
    ".github/agents/powershell-orchestrator.agent.md",
    ".github/agents/csharp-orchestrator.agent.md",
)
MIRRORED_ORCHESTRATOR_AGENT_PATHS = (
    "extensions/drm-copilot/resources/customizations/.github/agents/orchestrator.agent.md",
    "extensions/drm-copilot/resources/customizations/.github/agents/python-orchestrator.agent.md",
    "extensions/drm-copilot/resources/customizations/.github/agents/powershell-orchestrator.agent.md",
    "extensions/drm-copilot/resources/customizations/.github/agents/csharp-orchestrator.agent.md",
)


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 content for a checked-in repository text file."""
    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def test_root_orchestrators_use_direct_potential_entry_commands() -> None:
    """Require root orchestrators to document direct potential-entry command usage."""
    raw_feature_command = "${workspaceFolder}/scripts/dev-tools/new-potential-entry.ps1"
    raw_bug_command = "scripts/dev_tools/new_potential_bug_entry.py --short-name"

    for relative_path in ROOT_ORCHESTRATOR_AGENT_PATHS:
        agent_text = read_repo_text(relative_path)

        assert "drmCopilotExtension.newPotentialEntry" in agent_text
        assert "drmCopilotExtension.newPotentialBugEntry" in agent_text
        assert raw_feature_command not in agent_text
        assert raw_bug_command not in agent_text


def test_root_orchestrators_use_direct_potential_to_issue_commands() -> None:
    """Require root orchestrators to document direct promotion commands.

    The documented promotion flow must include explicit work-mode values.
    """
    raw_promotion_command = "python -m scripts.dev_tools.potential_to_issue"

    for relative_path in ROOT_ORCHESTRATOR_AGENT_PATHS:
        agent_text = read_repo_text(relative_path)

        assert "drmCopilotExtension.potentialToIssue" in agent_text
        assert "minor-audit" in agent_text
        assert "full-feature" in agent_text
        assert "full-bug" in agent_text
        assert raw_promotion_command not in agent_text


def test_root_orchestrators_use_direct_new_active_feature_folder_commands() -> None:
    """Require root orchestrators to document direct active-folder command usage."""
    raw_active_folder_command = "python -m scripts.dev_tools.new_active_feature_folder"

    for relative_path in ROOT_ORCHESTRATOR_AGENT_PATHS:
        agent_text = read_repo_text(relative_path)

        assert "drmCopilotExtension.newActiveFeatureFolder" in agent_text
        assert "--issue-number" in agent_text
        assert "full-feature" in agent_text
        assert "full-bug" in agent_text
        assert raw_active_folder_command not in agent_text


def test_mirrored_orchestrator_agents_match_root_direct_command_contracts() -> None:
    """Require mirrored orchestrator docs to match root contracts exactly."""
    for root_relative_path, mirror_relative_path in zip(
        ROOT_ORCHESTRATOR_AGENT_PATHS,
        MIRRORED_ORCHESTRATOR_AGENT_PATHS,
        strict=True,
    ):
        root_text = read_repo_text(root_relative_path)
        mirror_text = read_repo_text(mirror_relative_path)

        assert "drmCopilotExtension.newPotentialEntry" in root_text
        assert "drmCopilotExtension.potentialToIssue" in root_text
        assert "drmCopilotExtension.newActiveFeatureFolder" in root_text
        assert mirror_text == root_text
