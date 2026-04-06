"""Regression tests for migrated Codex handoff-contract parity."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]

SHARED_SKILL_NAMES = (
    "acceptance-criteria-tracking",
    "atomic-plan-contract",
    "csharp-change-budget-router",
    "csharp-orchestration-state-machine",
    "evidence-and-timestamp-conventions",
    "feature-promotion-lifecycle",
    "make-skill-template",
    "policy-audit-template-usage",
    "policy-compliance-order",
    "powershell-change-budget-router",
    "powershell-orchestration-state-machine",
    "pr-base-branch-merge-base",
    "pr-context-artifacts",
    "remediation-handoff-atomic-planner",
    "skill-canonical-location-audit",
)


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 content for a repository contract file."""

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def test_shared_codex_skills_match_github_contract_sources() -> None:
    """Require migrated shared skills to stay identical to GitHub source contracts."""

    for skill_name in SHARED_SKILL_NAMES:
        github_path = f".github/skills/{skill_name}/SKILL.md"
        codex_path = f".agents/skills/{skill_name}/SKILL.md"
        assert read_repo_text(codex_path) == read_repo_text(github_path)


def test_atomic_planner_handoff_contract_is_strict_in_skill_and_agent() -> None:
    """Require planner preflight handoff strictness in both Codex surfaces."""

    skill_text = read_repo_text(".agents/skills/atomic-planner/SKILL.md")
    agent_text = read_repo_text(".codex/agents/atomic-planner.toml")

    required_fragments = (
        "DIRECTIVE: PREFLIGHT VALIDATION ONLY",
        "atomic-planner -> atomic-executor",
        "PREFLIGHT: ALL CLEAR",
        "PREFLIGHT: REVISIONS REQUIRED",
        "precise plan delta",
        "do not create additional sibling `plan.*.md` files",
    )

    for fragment in required_fragments:
        assert fragment in skill_text

    assert "DIRECTIVE: PREFLIGHT VALIDATION ONLY" in agent_text
    assert "PREFLIGHT: ALL CLEAR" in agent_text
    assert "PREFLIGHT: REVISIONS REQUIRED" in agent_text
    assert "same target plan file" in agent_text


def test_atomic_executor_handoff_contract_is_strict_in_skill_and_agent() -> None:
    """Require executor validation-only preflight behavior in both Codex surfaces."""

    skill_text = read_repo_text(".agents/skills/atomic-executor/SKILL.md")
    agent_text = read_repo_text(".codex/agents/atomic-executor.toml")

    for fragment in (
        "DIRECTIVE: PREFLIGHT VALIDATION ONLY",
        "PREFLIGHT: ALL CLEAR",
        "PREFLIGHT: REVISIONS REQUIRED",
        "precise plan delta",
        "only authoritative checklist",
    ):
        assert fragment in skill_text

    assert "DIRECTIVE: PREFLIGHT VALIDATION ONLY" in agent_text
    assert "PREFLIGHT: ALL CLEAR" in agent_text
    assert "PREFLIGHT: REVISIONS REQUIRED" in agent_text
    assert "precise plan delta" in agent_text


def test_feature_review_remediation_handoff_is_strict_in_skill_and_agent() -> None:
    """Require automatic remediation handoff strictness in both Codex surfaces."""

    skill_text = read_repo_text(".agents/skills/feature-review/SKILL.md")
    agent_text = read_repo_text(".codex/agents/feature-reviewer.toml")

    for fragment in (
        (
            "create `remediation-inputs.<timestamp>.md` before any "
            "remediation planning handoff"
        ),
        (
            "create the remediation plan target file on disk before "
            "delegating plan creation"
        ),
        "automatically delegate remediation planning to `atomic-planner`",
        "primary requirements source",
        (
            "review artifacts, and the original feature plan file(s) in "
            "the delegated context package"
        ),
        (
            "do not claim review completion until the remediation plan "
            "file exists on disk"
        ),
    ):
        assert fragment in skill_text

    assert (
        "automatically delegate remediation planning to the atomic-planner agent"
        in agent_text
    )
    assert (
        "Create the remediation plan target file on disk before the planning handoff."
        in agent_text
    )
    assert "primary requirements source" in agent_text
    assert "original feature plan file(s)" in agent_text
    assert "remediation plan file exists on disk" in agent_text
