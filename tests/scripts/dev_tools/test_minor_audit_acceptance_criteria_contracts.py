"""Regression tests for the explicit minor-audit acceptance-criteria contract."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]

ROOT_MIRROR_PAIRS = (
    (
        ".github/skills/acceptance-criteria-tracking/SKILL.md",
        "extensions/drm-copilot/resources/customizations/.github/skills/"
        "acceptance-criteria-tracking/SKILL.md",
    ),
    (
        ".github/skills/atomic-plan-contract/SKILL.md",
        "extensions/drm-copilot/resources/customizations/.github/skills/"
        "atomic-plan-contract/SKILL.md",
    ),
    (
        ".github/skills/feature-promotion-lifecycle/SKILL.md",
        "extensions/drm-copilot/resources/customizations/.github/skills/"
        "feature-promotion-lifecycle/SKILL.md",
    ),
    (
        ".github/prompts/review-feature.prompt.md",
        "extensions/drm-copilot/resources/customizations/.github/prompts/"
        "review-feature.prompt.md",
    ),
    (
        ".github/prompts/orchestrate-work.prompt.md",
        "extensions/drm-copilot/resources/customizations/.github/prompts/"
        "orchestrate-work.prompt.md",
    ),
    (
        ".github/prompts/orchestrate-csharp-work.prompt.md",
        "extensions/drm-copilot/resources/customizations/.github/prompts/"
        "orchestrate-csharp-work.prompt.md",
    ),
)


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 text for a repository file used by contract assertions."""
    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def test_minor_audit_contract_files_require_explicit_acceptance_section() -> None:
    """Require minor-audit contracts to mention the explicit issue AC section."""
    required_paths = (
        ".github/skills/acceptance-criteria-tracking/SKILL.md",
        ".github/skills/atomic-plan-contract/SKILL.md",
        ".github/skills/feature-promotion-lifecycle/SKILL.md",
        ".github/prompts/review-feature.prompt.md",
        ".github/prompts/orchestrate-work.prompt.md",
        ".github/prompts/orchestrate-csharp-work.prompt.md",
    )

    for relative_path in required_paths:
        text = read_repo_text(relative_path)
        assert "explicit `## Acceptance Criteria` section" in text


def test_minor_audit_customization_mirrors_match_root_contracts() -> None:
    """Require bundled customization mirrors to stay identical to root contracts."""
    for root_relative_path, mirror_relative_path in ROOT_MIRROR_PAIRS:
        assert read_repo_text(mirror_relative_path) == read_repo_text(
            root_relative_path
        )


def test_minor_audit_template_readme_documents_explicit_issue_section() -> None:
    """Require template guidance to document the explicit issue AC section."""
    template_readme = read_repo_text("docs/features/templates/README.md")

    assert "`minor-audit`: `issue.md` and `plan.md`" in template_readme
    assert "explicit `## Acceptance Criteria` section" in template_readme
