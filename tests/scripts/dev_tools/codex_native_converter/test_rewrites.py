"""Tests for Codex-native converter runtime-reference rewrites."""

from __future__ import annotations

from scripts.dev_tools.codex_native_converter.rewrites import (
    detect_unresolved_runtime_reference,
    rewrite_supported_automation_reference,
)


def test_rewrite_supported_automation_reference_rewrites_known_paths_and_commands() -> (
    None
):
    """Rewrite supported Copilot paths and command identifiers to native targets."""

    source_text = """
See .github/copilot-instructions.md first.
Open .github/instructions/general-code-change.instructions.md.
Use .github/skills/review-workflow/SKILL.md during review.
Delegate to .github/agents/orchestrator.agent.md.
Run drmCopilotExtension.collectPrContext before proceeding.
""".strip()

    rewritten_text, applied_rewrites = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert "AGENTS.md" in rewritten_text
    assert ".agents/skills/general-code-change/SKILL.md" in rewritten_text
    assert ".agents/skills/review-workflow/SKILL.md" in rewritten_text
    assert ".codex/agents/orchestrator.toml" in rewritten_text
    assert "mcp__drmCopilotExtension__collect_pr_context" in rewritten_text
    assert ".github/" not in rewritten_text
    assert applied_rewrites
    assert not detect_unresolved_runtime_reference(rewritten_text)


def test_rewrite_supported_automation_reference_rewrites_prompt_paths() -> None:
    """Rewrite GitHub prompt references only when prompt output is enabled."""

    source_text = "Launch .github/prompts/launch-review.prompt.md after setup."

    rewritten_without_prompts, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )
    rewritten_with_prompts, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=True,
    )

    assert ".github/prompts/launch-review.prompt.md" in rewritten_without_prompts
    assert ".codex/prompts/launch-review.md" in rewritten_with_prompts


def test_rewrite_supported_automation_reference_rewrites_instruction_directories() -> (
    None
):
    """Rewrite directory-level instruction references to the native skill root."""

    source_text = "Review guidance in .github/instructions/ before proceeding."

    rewritten_text, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert ".agents/skills/" in rewritten_text
    assert ".github/instructions/" not in rewritten_text
    assert not detect_unresolved_runtime_reference(rewritten_text)


def test_detect_unresolved_runtime_reference_ignores_non_runtime_github_paths() -> None:
    """Do not treat repository workflow paths as source-runtime references."""

    rendered_text = "This skill applies to .github/workflows/*.yml files."

    assert not detect_unresolved_runtime_reference(rendered_text)
