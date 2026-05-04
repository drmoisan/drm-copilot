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
    """Rewrite GitHub prompt references to native targets in both prompt modes."""

    source_text = "Launch .github/prompts/launch-review.prompt.md after setup."

    rewritten_without_prompts, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )
    rewritten_with_prompts, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=True,
    )

    assert ".github/prompts/" not in rewritten_without_prompts
    assert ".agents/skills/launch-review.prompt.md" in rewritten_without_prompts
    assert ".codex/prompts/launch-review.md" in rewritten_with_prompts


def test_rewrite_supported_automation_reference_rewrites_known_prompt_fallbacks() -> (
    None
):
    """Rewrite known prompt references to shared-skill fallbacks when disabled."""

    source_text = """
Use .github/prompts/generate-atomic-plan.prompt.md as the canonical template.
Then run .github/prompts/review-feature.prompt.md for the audit workflow.
Finally use .github/prompts/research-issue.prompt.md for implementation research.
""".strip()

    rewritten_text, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert ".agents/skills/atomic-plan-contract/SKILL.md" in rewritten_text
    assert ".agents/skills/review-feature/SKILL.md" in rewritten_text
    assert ".agents/skills/research-issue/SKILL.md" in rewritten_text
    assert ".github/prompts/" not in rewritten_text
    assert not detect_unresolved_runtime_reference(rewritten_text)


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


def test_rewrite_supported_automation_reference_rewrites_claude_hook_paths() -> None:
    """Rewrite Claude hook paths to PowerShell Codex hook targets."""

    source_text = "Run .claude/hooks/check-python-test-purity.ps1 before review."

    rewritten_text, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert ".codex/hooks/check-python-test-purity.ps1" in rewritten_text
    assert ".ps1.ps1" not in rewritten_text
    assert ".py" not in rewritten_text
    assert not detect_unresolved_runtime_reference(rewritten_text)


def test_rewrite_supported_automation_reference_rewrites_claude_dir_fallbacks() -> None:
    """Rewrite bare and placeholder Claude directory references to native roots."""

    source_text = """
See .claude/skills/<name>/SKILL.md and .claude/skills/**/SKILL.md examples.
Reference .claude/agents/*.md and .claude/hooks/<name>.ps1 for routing.
Edit(/.claude/skills/execute-hard-lock/**) is also possible.
Bare ref: .claude/hooks/ followed by content.
""".strip()

    rewritten_text, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert ".claude/skills/" not in rewritten_text
    assert ".claude/agents/" not in rewritten_text
    assert ".claude/hooks/" not in rewritten_text
    assert ".agents/skills/" in rewritten_text
    assert ".codex/agents/" in rewritten_text
    assert ".codex/hooks/" in rewritten_text
    assert not detect_unresolved_runtime_reference(rewritten_text)


def test_rewrite_supported_automation_reference_rewrites_claude_rule_paths() -> None:
    """Rewrite named Claude rule paths to shared skill paths."""

    source_text = (
        "Apply .claude/rules/python.md and .claude/rules/tonality.md before review."
    )

    rewritten_text, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert ".agents/skills/python/SKILL.md" in rewritten_text
    assert ".agents/skills/tonality/SKILL.md" in rewritten_text
    assert ".claude/rules/" not in rewritten_text


def test_rewrite_supported_reference_expands_atomic_planner_preflight_contract() -> (
    None
):
    """Expand the Claude planner shorthand into the Codex handoff contract."""

    source_text = (
        "Return the finalized plan for validation-only preflight through "
        "`atomic-executor` and preserve the same target file path across revision "
        "loops. Do not claim nested worker delegation from within planner execution."
    )

    rewritten_text, applied_rewrites = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert "explicitly spawn the `atomic-executor` subagent" in rewritten_text
    assert "`DIRECTIVE: PREFLIGHT VALIDATION ONLY`" in rewritten_text
    assert "`PREFLIGHT: ALL CLEAR`" in rewritten_text
    assert "`PREFLIGHT: REVISIONS REQUIRED`" in rewritten_text
    assert "Treat executor preflight findings as binding plan defects" in rewritten_text
    assert "Reuse the same target plan file" in rewritten_text
    assert "stop and report blocked state" in rewritten_text
    assert "validate_orchestration_artifacts` MCP tool" in rewritten_text
    assert any(
        "Expand the Claude atomic-planner preflight shorthand" in description
        for description in applied_rewrites
    )


def test_rewrite_supported_automation_reference_rewrites_claude_rules_directory() -> (
    None
):
    """Rewrite bare Claude rules-directory references to the native skill root."""

    source_text = "Browse .claude/rules/ for the policy catalog."

    rewritten_text, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert ".claude/rules/" not in rewritten_text
    assert ".agents/skills/" in rewritten_text


def test_rewrite_supported_reference_rewrites_prompt_dir_when_disabled() -> None:
    """Rewrite bare GitHub prompt-directory references when prompts are disabled."""

    source_text = (
        "Browse .github/prompts/ and look at .github/prompts/*.prompt.md for guidance."
    )

    rewritten_text, _ = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=False,
    )

    assert ".github/prompts/" not in rewritten_text
    assert ".agents/skills/" in rewritten_text
    assert not detect_unresolved_runtime_reference(rewritten_text)


def test_detect_unresolved_runtime_reference_ignores_non_runtime_github_paths() -> None:
    """Do not treat repository workflow paths as source-runtime references."""

    rendered_text = "This skill applies to .github/workflows/*.yml files."

    assert not detect_unresolved_runtime_reference(rendered_text)
