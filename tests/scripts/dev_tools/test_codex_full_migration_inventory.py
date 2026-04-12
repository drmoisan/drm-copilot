"""Inventory tests for Codex runtime agents and skills."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLE_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)

BESPOKE_AGENT_WRAPPERS = {
    "atomic-executor",
    "atomic-planner",
    "atomic-planning",
    "commit-steward",
    "csharp-atomic-executor",
    "csharp-atomic-planning",
    "csharp-orchestrator",
    "feature-reviewer",
    "orchestrator",
    "powershell-atomic-executor",
    "powershell-atomic-planning",
    "powershell-orchestrator",
    "pr-author",
    "python-atomic-executor",
    "python-atomic-planning",
    "python-orchestrator",
}

WRAPPER_REQUIRED_FRAGMENTS = (
    "Canonical migration source:",
    "Read the canonical source agent file first and follow it exactly.",
    (
        "Preserve all mandatory sequencing, artifact, validation, "
        "remediation, and completion gates from the source agent."
    ),
    (
        "If the source agent defines handoffs, preserve those handoffs with "
        "the same degree of process gating"
    ),
    (
        "Treat .agents/skills, .codex/agents, and .codex/prompts as the "
        "Codex runtime surfaces for migrated behavior"
    ),
    (
        "Do not weaken validation-only preflight loops, QA gates, "
        "remediation triggers, review gates, acceptance-criteria tracking, "
        "or evidence requirements that exist in the source agent."
    ),
)


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 text for a repo-relative file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def read_bundle_text(relative_path: str) -> str:
    """Return UTF-8 text for a bundled Codex/agents file."""

    return (BUNDLE_ROOT / relative_path).read_text(encoding="utf-8")


def test_all_repo_agent_skills_are_bundled_and_identical() -> None:
    """Require every repo `.agents` skill to exist verbatim in the bundle."""

    agent_skill_dirs = sorted(
        path.name
        for path in (REPO_ROOT / ".agents" / "skills").iterdir()
        if path.is_dir()
    )

    for skill_name in agent_skill_dirs:
        agent_relative = f".agents/skills/{skill_name}/SKILL.md"
        bundled_relative = f".agents/skills/{skill_name}/SKILL.md"

        assert (BUNDLE_ROOT / bundled_relative).exists()
        assert read_bundle_text(bundled_relative) == read_repo_text(agent_relative)


def test_every_repo_codex_agent_has_a_bundled_target() -> None:
    """Require every repo `.codex` agent to have a bundled target."""

    codex_agents = sorted(
        path.name
        for path in (REPO_ROOT / ".codex" / "agents").iterdir()
        if path.is_file() and path.name.endswith(".toml")
    )

    for codex_file in codex_agents:
        wrapper_relative = f".codex/agents/{codex_file}"

        assert (BUNDLE_ROOT / wrapper_relative).exists()


def test_codex_agent_contracts_follow_expected_wrapper_or_native_patterns() -> None:
    """Require Codex agents to be either strict wrappers or native contracts."""

    codex_agents = sorted(
        path.name
        for path in (REPO_ROOT / ".codex" / "agents").iterdir()
        if path.is_file() and path.name.endswith(".toml")
    )

    for codex_file in codex_agents:
        target_name = codex_file.removesuffix(".toml")
        if target_name in BESPOKE_AGENT_WRAPPERS:
            wrapper_text = read_bundle_text(f".codex/agents/{codex_file}")
            assert (
                "Use the following repo-local skills as the canonical workflow source"
                in wrapper_text
            ) or (
                "Use the following repo-local skill as the canonical workflow "
                "source" in wrapper_text
            )
            continue

        wrapper_relative = f".codex/agents/{codex_file}"
        wrapper_text = read_bundle_text(wrapper_relative)

        for fragment in WRAPPER_REQUIRED_FRAGMENTS:
            assert fragment in wrapper_text

        assert ".github/agents/" in wrapper_text
