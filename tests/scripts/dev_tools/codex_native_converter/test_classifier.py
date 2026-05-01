"""Tests for Codex-native converter artifact classification."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.classifier import classify_source_artifact
from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    SourceEcosystem,
    TargetRole,
)


def _fixture_root(fixture_name: str) -> Path:
    """Resolve one committed converter fixture root.

    Purpose:
        Return the committed fixture root used by the classification tests.

    Args:
        fixture_name (str): Fixture folder name beneath the committed converter
            fixtures.

    Returns:
        Path: Absolute path to the requested fixture root.

    Raises:
        None.

    Side Effects:
        None.
    """

    return (
        Path(__file__).resolve().parents[4]
        / "tests"
        / "fixtures"
        / "codex_native_converter"
        / fixture_name
    )


def _test_classify_github_copilot_expected_conversion_classes() -> None:
    """Classify the supported GitHub fixture surfaces into the expected roles."""

    fixture_root = _fixture_root("github_copilot")

    standing_guidance = classify_source_artifact(
        fixture_root,
        Path(".github/copilot-instructions.md"),
        SourceEcosystem.GITHUB_COPILOT,
    )
    path_scoped_instruction = classify_source_artifact(
        fixture_root,
        Path(".github/instructions/general-code-change.instructions.md"),
        SourceEcosystem.GITHUB_COPILOT,
    )
    reusable_skill = classify_source_artifact(
        fixture_root,
        Path(".github/skills/review-workflow/SKILL.md"),
        SourceEcosystem.GITHUB_COPILOT,
    )
    launcher_prompt = classify_source_artifact(
        fixture_root,
        Path(".github/prompts/launch-review.prompt.md"),
        SourceEcosystem.GITHUB_COPILOT,
    )

    assert standing_guidance.conversion_class is ConversionClass.DIRECT
    assert standing_guidance.target_role is TargetRole.STANDING_GUIDANCE
    assert path_scoped_instruction.conversion_class is ConversionClass.DECOMPOSED
    assert path_scoped_instruction.target_role is TargetRole.STANDING_GUIDANCE
    assert reusable_skill.conversion_class is ConversionClass.DIRECT
    assert reusable_skill.target_role is TargetRole.SHARED_SKILL
    assert launcher_prompt.conversion_class is ConversionClass.REPO_CONVENTION
    assert launcher_prompt.target_role is TargetRole.LAUNCHER


globals()[
    "test_classify_github_copilot_surfaces_maps_supported_items_to_expected_conversion_classes"
] = _test_classify_github_copilot_expected_conversion_classes


def test_classify_repo_wide_github_instruction_as_standing_guidance() -> None:
    """Map repo-wide GitHub instructions into standing guidance instead of a skill."""

    fixture_root = _fixture_root("github_copilot")
    repo_wide_instruction = classify_source_artifact(
        fixture_root,
        Path(".github/instructions/general-code-change.instructions.md"),
        SourceEcosystem.GITHUB_COPILOT,
    )

    assert repo_wide_instruction.conversion_class is ConversionClass.DECOMPOSED
    assert repo_wide_instruction.target_role is TargetRole.STANDING_GUIDANCE
    assert any("repo-wide" in note.lower() for note in repo_wide_instruction.notes)


def test_classify_claude_surfaces_marks_rules_and_unverified_handoffs_as_expected() -> (
    None
):
    """Mark Claude rules unsupported and agent handoff semantics for review."""

    fixture_root = _fixture_root("claude")
    claude_rule = classify_source_artifact(
        fixture_root,
        Path(".claude/rules/general-code-change.md"),
        SourceEcosystem.CLAUDE,
    )
    claude_agent = classify_source_artifact(
        fixture_root,
        Path(".claude/agents/orchestrator.md"),
        SourceEcosystem.CLAUDE,
    )

    assert claude_rule.conversion_class is ConversionClass.UNSUPPORTED
    assert claude_rule.target_role is TargetRole.UNSUPPORTED
    assert claude_agent.conversion_class is ConversionClass.DECOMPOSED
    assert claude_agent.target_role is TargetRole.SUBAGENT
    assert any("handoff" in note.lower() for note in claude_agent.notes)


def test_classify_github_prompt_templates_as_optional_launcher_artifacts() -> None:
    """Treat non-`.prompt.md` prompt templates as optional launcher artifacts."""

    fixture_root = _fixture_root("github_copilot")
    prompt_template = classify_source_artifact(
        fixture_root,
        Path(".github/prompts/execute-plan-template.md"),
        SourceEcosystem.GITHUB_COPILOT,
    )

    assert prompt_template.conversion_class is ConversionClass.REPO_CONVENTION
    assert prompt_template.target_role is TargetRole.LAUNCHER
    assert prompt_template.is_required is False


def test_classify_github_skills_readme_as_optional_unsupported_documentation() -> None:
    """Treat the skills index as optional documentation instead of a blocker."""

    fixture_root = _fixture_root("github_copilot")
    skills_readme = classify_source_artifact(
        fixture_root,
        Path(".github/skills/README.md"),
        SourceEcosystem.GITHUB_COPILOT,
    )

    assert skills_readme.conversion_class is ConversionClass.UNSUPPORTED
    assert skills_readme.target_role is TargetRole.UNSUPPORTED
    assert skills_readme.is_required is False
