"""Inventory tests for GitHub-to-Codex agent and skill migrations."""

from __future__ import annotations

import re
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
    "commit-steward",
    "feature-reviewer",
    "orchestrator",
    "pr-author",
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


def normalize_agent_target(file_name: str) -> str:
    """Map a GitHub agent filename to its default Codex wrapper target."""

    stem = file_name.removesuffix(".agent.md")
    return re.sub(r"-{2,}", "-", re.sub(r"[ _]+", "-", stem.lower()))


def get_frontmatter_handoffs(agent_text: str) -> tuple[str, ...]:
    """Return unique handoff agent names declared in the source frontmatter."""

    if not agent_text.startswith("---\n"):
        return ()

    end = agent_text.find("\n---", 4)
    if end == -1:
        return ()

    frontmatter = agent_text[4:end]
    handoffs = re.findall(r"(?m)^\s*agent:\s*(.+?)\s*$", frontmatter)
    unique_handoffs: list[str] = []
    for handoff in handoffs:
        if handoff not in unique_handoffs:
            unique_handoffs.append(handoff)
    return tuple(unique_handoffs)


def test_all_github_skills_are_migrated_and_identical_in_agents_tree() -> None:
    """Require every GitHub skill to exist verbatim in `.agents/skills`."""

    github_skill_dirs = sorted(
        path.name
        for path in (REPO_ROOT / ".github" / "skills").iterdir()
        if path.is_dir()
    )

    for skill_name in github_skill_dirs:
        github_relative = f".github/skills/{skill_name}/SKILL.md"
        codex_relative = f".agents/skills/{skill_name}/SKILL.md"
        bundled_relative = (
            f"extensions/drm-copilot/resources/codex-and-agents-customizations/"
            f".agents/skills/{skill_name}/SKILL.md"
        )

        assert (REPO_ROOT / codex_relative).exists()
        assert read_repo_text(codex_relative) == read_repo_text(github_relative)
        assert read_repo_text(bundled_relative) == read_repo_text(codex_relative)


def test_every_github_agent_has_a_codex_wrapper_file() -> None:
    """Require every legacy GitHub agent to have a Codex wrapper target."""

    github_agents = sorted(
        path.name
        for path in (REPO_ROOT / ".github" / "agents").iterdir()
        if path.is_file() and path.name.endswith(".agent.md")
    )

    for github_file in github_agents:
        wrapper_relative = f".codex/agents/{normalize_agent_target(github_file)}.toml"
        bundled_relative = (
            "extensions/drm-copilot/resources/codex-and-agents-customizations/"
            f".codex/agents/{normalize_agent_target(github_file)}.toml"
        )

        assert (REPO_ROOT / wrapper_relative).exists()
        assert read_repo_text(bundled_relative) == read_repo_text(wrapper_relative)


def test_generated_agent_wrappers_reference_source_and_preserve_handoffs() -> None:
    """Require thin migration wrappers to carry source and handoff rigor."""

    github_agents = sorted(
        path.name
        for path in (REPO_ROOT / ".github" / "agents").iterdir()
        if path.is_file() and path.name.endswith(".agent.md")
    )

    for github_file in github_agents:
        target_name = normalize_agent_target(github_file)
        if target_name in BESPOKE_AGENT_WRAPPERS:
            continue

        github_relative = f".github/agents/{github_file}"
        wrapper_relative = f".codex/agents/{target_name}.toml"
        github_text = read_repo_text(github_relative)
        wrapper_text = read_repo_text(wrapper_relative)

        for fragment in WRAPPER_REQUIRED_FRAGMENTS:
            assert fragment in wrapper_text

        assert github_relative in wrapper_text

        handoffs = get_frontmatter_handoffs(github_text)
        if handoffs:
            assert "Mandatory source handoffs to preserve:" in wrapper_text
            for handoff in handoffs:
                assert f"- {handoff}" in wrapper_text
        else:
            assert (
                "The source agent does not declare explicit frontmatter handoffs."
                in wrapper_text
            )
