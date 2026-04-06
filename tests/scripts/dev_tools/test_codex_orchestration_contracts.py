"""Regression tests for migrated Codex orchestration contracts."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]
BUNDLED_ROOT = (
    REPO_ROOT
    / "extensions"
    / "drm-copilot"
    / "resources"
    / "codex-and-agents-customizations"
)
REQUIRED_BUNDLED_PATHS = (
    Path(".codex/agents/orchestrator.toml"),
    Path(".agents/skills/orchestrator-workflow/SKILL.md"),
)


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 text for a checked-in contract file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def read_bundle_text(relative_path: str) -> str:
    """Return UTF-8 text for a bundled Codex/agents contract file."""

    return (BUNDLED_ROOT / relative_path).read_text(encoding="utf-8")


def test_codex_orchestrator_agent_requires_mandatory_specialist_handoffs() -> None:
    """Require the Codex orchestrator agent to enforce specialist delegation."""

    agent_text = read_bundle_text(".codex/agents/orchestrator.toml")

    assert "you must delegate planning to it" in agent_text
    assert (
        "you must delegate plan preflight validation, execution, and "
        "post-delivery validation to it" in agent_text
    )
    assert "you must delegate post-implementation review to it" in agent_text
    assert "explicit fallback reason" in agent_text
    assert "required evidence-backed QA artifacts" in agent_text
    assert "stale PR-context artifacts" in agent_text


def test_codex_orchestrator_workflow_requires_large_path_evidence_gates() -> None:
    """Require the Codex workflow skill to restore large-path hard enforcement."""

    skill_text = read_bundle_text(".agents/skills/orchestrator-workflow/SKILL.md")

    assert "- `pr-context-artifacts`" in skill_text
    assert "- `pr-base-branch-merge-base`" in skill_text
    assert (
        "The planning route MUST be `atomic-planner -> atomic-executor` "
        "for preflight validation." in skill_text
    )
    assert (
        "Do not mark Step 8 complete until execution output includes "
        "execution summary, QA summary, lint/type/test/coverage deltas, "
        "and numeric baseline/post/new-code coverage metrics where policy "
        "requires them." in skill_text
    )
    assert (
        "Do not mark Step 9 complete until expected review artifacts are "
        "present on disk in `${feature-folder}`." in skill_text
    )
    assert (
        "PR-context artifacts are missing or stale relative to the current "
        "branch state" in skill_text
    )
    assert (
        "all required delegations completed or an explicit fallback reason "
        "was recorded" in skill_text
    )
    assert (
        "required baseline and final-QA evidence artifacts referenced by the "
        "approved plan exist on disk" in skill_text
    )


def test_codex_orchestration_bundle_contains_required_runtime_surfaces() -> None:
    """Require bundled Codex orchestration resources to be present in the payload."""

    for relative_path in REQUIRED_BUNDLED_PATHS:
        assert (BUNDLED_ROOT / relative_path).is_file()
