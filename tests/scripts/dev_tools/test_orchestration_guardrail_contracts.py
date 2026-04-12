"""Regression tests for Codex orchestration guardrail contract wording."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
CODEX_BUNDLE_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)

ROOT_CODEX_ORCHESTRATOR_PATHS = (
    ".codex/agents/orchestrator.toml",
    ".codex/agents/python-orchestrator.toml",
    ".codex/agents/powershell-orchestrator.toml",
    ".codex/agents/csharp-orchestrator.toml",
)


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 content for a repository text file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def read_bundle_text(relative_path: str) -> str:
    """Return UTF-8 content for a Codex bundle text file."""

    return (CODEX_BUNDLE_ROOT / relative_path).read_text(encoding="utf-8")


def test_codex_orchestrators_enforce_checkpoint_and_lifecycle_guardrails() -> None:
    """Require Codex orchestrators to fail closed on lifecycle and state misuse."""

    required_fragments = (
        "checkpoint_conflict",
        "Do not rename, back up, or create sidecar checkpoint files",
        "Do not persist placeholder lifecycle values such as `NONE`, `TBD`",
        (
            "Do not create or edit `${feature-folder}/issue.md`, "
            "`${feature-folder}/spec.md`, `${feature-folder}/user-story.md`, "
            "or `plan*.md` until"
        ),
    )

    for relative_path in ROOT_CODEX_ORCHESTRATOR_PATHS:
        agent_text = read_repo_text(relative_path)

        for fragment in required_fragments:
            assert fragment in agent_text


def test_language_specific_codex_orchestrators_require_ordered_lifecycle() -> None:
    """Require language-specific orchestrators to enforce numeric issue capture."""

    orchestrator_paths = (
        ".codex/agents/python-orchestrator.toml",
        ".codex/agents/powershell-orchestrator.toml",
        ".codex/agents/csharp-orchestrator.toml",
    )

    for relative_path in orchestrator_paths:
        agent_text = read_repo_text(relative_path)

        assert (
            "Require `${relativeFile}` to resolve to a real potential-entry"
            in agent_text
        )
        assert (
            "Require issue promotion to complete before branch creation" in agent_text
        )
        assert (
            "Require `${issue-num}` to be numeric before `new_active_feature_folder`"
            in agent_text
        )
        assert (
            "Do not treat delegated planning as complete until the returned "
            "`plan-path` is concrete" in agent_text
        )


def test_published_codex_orchestration_agents_match_repo_sources() -> None:
    """Require published Codex orchestration-chain agents to match repo sources."""

    agent_names = (
        "orchestrator",
        "python-orchestrator",
        "powershell-orchestrator",
        "csharp-orchestrator",
        "atomic-planning",
        "python-atomic-planning",
        "powershell-atomic-planning",
        "csharp-atomic-planning",
        "python-atomic-executor",
        "powershell-atomic-executor",
        "csharp-atomic-executor",
    )

    for agent_name in agent_names:
        relative_path = f".codex/agents/{agent_name}.toml"
        assert read_bundle_text(relative_path) == read_repo_text(relative_path)


def test_codex_only_orchestration_skills_match_published_bundle() -> None:
    """Require Codex-only orchestration skills to publish exact bundle copies."""

    codex_only_skills = (
        "orchestrator-workflow",
        "repo-automation-adapter",
    )

    for skill_name in codex_only_skills:
        relative_path = f".agents/skills/{skill_name}/SKILL.md"
        assert read_bundle_text(relative_path) == read_repo_text(relative_path)


def test_orchestration_skills_state_non_interpretable_guardrails() -> None:
    """Require `.agents` skills to document specific fail-closed rules."""

    fragment_expectations = {
        ".agents/skills/orchestrator-workflow/SKILL.md": (
            "blocked_reason` MUST be one of:",
            "Do not rename, back up, or create sidecar checkpoint files",
            "Do not persist placeholder lifecycle values such as `NONE` or `TBD`",
        ),
        ".agents/skills/repo-automation-adapter/SKILL.md": (
            "Execute these lifecycle operations as one ordered chain:",
            "`new_active_feature_folder` is not an allowed bootstrap substitute",
            "If `${issue-num}` is missing, non-numeric, or placeholder text, stop",
        ),
        ".agents/skills/feature-promotion-lifecycle/SKILL.md": (
            "`${relativeFile}` MUST resolve to a real potential markdown path",
            (
                "`${issue-num}` MUST be numeric after promotion and before "
                "branch or folder creation."
            ),
            "Do not infer or synthesize the missing value.",
        ),
        ".agents/skills/csharp-orchestration-state-machine/SKILL.md": (
            (
                "Never create sidecar checkpoint files, suffixed variants, "
                "or backup files as active state."
            ),
            (
                "stop and report the conflict instead of renaming or backing "
                "up the active checkpoint."
            ),
        ),
        ".agents/skills/powershell-orchestration-state-machine/SKILL.md": (
            (
                "Never create sidecar checkpoint files, suffixed variants, "
                "or backup files as active state."
            ),
            (
                "stop and report the conflict instead of renaming or backing "
                "up the active checkpoint."
            ),
        ),
    }

    for relative_path, required_fragments in fragment_expectations.items():
        file_text = read_repo_text(relative_path)

        for fragment in required_fragments:
            assert fragment in file_text
