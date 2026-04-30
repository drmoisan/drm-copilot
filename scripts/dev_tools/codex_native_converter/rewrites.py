"""Rewrite supported automation references for the Codex-native converter.

Purpose:
    Centralize the approved runtime-reference rewrites that convert supported
    host-specific automation references into the repository's semantic MCP usage
    model on server ``drmCopilotExtension``.

Usage:
    The converter engine applies ``rewrite_supported_automation_reference`` to
    generated content and then calls ``detect_unresolved_runtime_reference`` to
    identify fail-closed leftovers.

Flow:
    A small deterministic catalog rewrites supported references first, then the
    detector scans the resulting text for runtime-specific references that still
    require manual review or blocking validation.

Invariants / Constraints:
    Only verified catalog entries are rewritten automatically. Unknown runtime
    references remain explicit instead of being guessed.

Side Effects:
    None.
"""

from __future__ import annotations

import re
from dataclasses import dataclass
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    from collections.abc import Callable


@dataclass(frozen=True, slots=True)
class RewriteRule:
    """Represent one supported runtime-reference rewrite rule.

    Purpose:
        Keep the rewrite catalog structured and easy to serialize or test.

    Usage:
        ``rewrite_supported_automation_reference`` iterates over these rules in
        order and applies any matching replacements.

    Flow:
        Each rule exposes a compiled pattern and a semantic MCP replacement.

    Invariants / Constraints:
        Rules must remain deterministic and side-effect free.

    Side Effects:
        None.
    """

    pattern: re.Pattern[str]
    replacement: str | Callable[[re.Match[str]], str]
    description: str


def _normalize_target_name(name: str) -> str:
    """Normalize one extracted path segment for use in native target paths."""

    return name.replace("_", "-")


def _normalize_hook_target_name(name: str) -> str:
    """Normalize one extracted hook path segment without script extensions."""

    normalized_name = _normalize_target_name(name)
    for suffix in (".ps1", ".py"):
        if normalized_name.endswith(suffix):
            return normalized_name[: -len(suffix)]
    return normalized_name


def _camel_or_pascal_to_snake(value: str) -> str:
    """Convert a mixed-case command identifier into snake_case."""

    snake_value = re.sub(r"([a-z0-9])([A-Z])", r"\1_\2", value)
    snake_value = re.sub(r"([A-Z]+)([A-Z][a-z])", r"\1_\2", snake_value)
    return snake_value.replace("-", "_").lower()


_BASE_REWRITE_RULES: tuple[RewriteRule, ...] = (
    RewriteRule(
        pattern=re.compile(r"(?<![A-Za-z0-9_])\.github/copilot-instructions\.md\b"),
        replacement="AGENTS.md",
        description="Rewrite GitHub Copilot standing guidance paths to AGENTS.md.",
    ),
    RewriteRule(
        pattern=re.compile(
            r"(?<![A-Za-z0-9_])\.github/instructions/([A-Za-z0-9_.-]+)\.instructions\.md\b"
        ),
        replacement=lambda match: (
            f".agents/skills/{_normalize_target_name(match.group(1))}/SKILL.md"
        ),
        description=(
            "Rewrite GitHub Copilot path-scoped instructions to shared skill paths."
        ),
    ),
    RewriteRule(
        pattern=re.compile(
            r"(?<![A-Za-z0-9_])\.github/skills/([A-Za-z0-9_.-]+)/SKILL\.md\b"
        ),
        replacement=lambda match: (
            f".agents/skills/{_normalize_target_name(match.group(1))}/SKILL.md"
        ),
        description=(
            "Rewrite GitHub Copilot reusable skill paths to shared skill paths."
        ),
    ),
    RewriteRule(
        pattern=re.compile(
            r"(?<![A-Za-z0-9_])\.github/agents/([A-Za-z0-9_.-]+)\.agent\.md\b"
        ),
        replacement=lambda match: (
            f".codex/agents/{_normalize_target_name(match.group(1))}.toml"
        ),
        description="Rewrite GitHub Copilot agent manifest paths to Codex agent paths.",
    ),
    RewriteRule(
        pattern=re.compile(r"(?<![A-Za-z0-9_])\.github/instructions/"),
        replacement=".agents/skills/",
        description=(
            "Rewrite GitHub Copilot instruction-directory references to the native "
            "skill root."
        ),
    ),
    RewriteRule(
        pattern=re.compile(r"(?<![A-Za-z0-9_])\.github/skills/"),
        replacement=".agents/skills/",
        description=(
            "Rewrite GitHub Copilot skill-directory references to the native skill "
            "root."
        ),
    ),
    RewriteRule(
        pattern=re.compile(r"(?<![A-Za-z0-9_])\.github/agents/"),
        replacement=".codex/agents/",
        description=(
            "Rewrite GitHub Copilot agent-directory references to the native agent "
            "root."
        ),
    ),
    RewriteRule(
        pattern=re.compile(r"(?<![A-Za-z0-9_])CLAUDE\.md\b"),
        replacement="AGENTS.md",
        description="Rewrite Claude standing guidance paths to AGENTS.md.",
    ),
    RewriteRule(
        pattern=re.compile(
            r"(?<![A-Za-z0-9_])\.claude/skills/([A-Za-z0-9_.-]+)/SKILL\.md\b"
        ),
        replacement=lambda match: (
            f".agents/skills/{_normalize_target_name(match.group(1))}/SKILL.md"
        ),
        description="Rewrite Claude skill paths to shared skill paths.",
    ),
    RewriteRule(
        pattern=re.compile(r"(?<![A-Za-z0-9_])\.claude/agents/([A-Za-z0-9_.-]+)\.md\b"),
        replacement=lambda match: (
            f".codex/agents/{_normalize_target_name(match.group(1))}.toml"
        ),
        description="Rewrite Claude agent manifest paths to Codex agent paths.",
    ),
    RewriteRule(
        pattern=re.compile(r"(?<![A-Za-z0-9_])\.claude/hooks/([A-Za-z0-9_.-]+)\b"),
        replacement=lambda match: (
            f".codex/hooks/{_normalize_hook_target_name(match.group(1))}.ps1"
        ),
        description="Rewrite Claude hook paths to Codex hook paths.",
    ),
    RewriteRule(
        pattern=re.compile(r"(?<![A-Za-z0-9_])\.claude/settings\.json\b"),
        replacement=".codex/config.toml",
        description="Rewrite Claude settings paths to Codex config paths.",
    ),
    RewriteRule(
        pattern=re.compile(r"\bdrmCopilotExtension\.collectPrContext\b"),
        replacement="mcp__drmCopilotExtension__collect_pr_context",
        description=(
            "Rewrite VS Code collectPrContext command IDs to semantic MCP "
            "tool usage."
        ),
    ),
    RewriteRule(
        pattern=re.compile(r"\bdrmCopilotExtension\.validateOrchestrationArtifacts\b"),
        replacement="mcp__drmCopilotExtension__validate_orchestration_artifacts",
        description=(
            "Rewrite orchestration validator command IDs to semantic MCP tool " "usage."
        ),
    ),
    RewriteRule(
        pattern=re.compile(r"\bdrmCopilotExtension\.runPoshQcSuite\b"),
        replacement="mcp__drmCopilotExtension__run_poshqc_analyze",
        description=(
            "Rewrite PoshQC suite command IDs to the semantic MCP analyzer " "surface."
        ),
    ),
    RewriteRule(
        pattern=re.compile(r"\bdrmCopilotExtension\.([A-Za-z0-9_]+)\b"),
        replacement=lambda match: (
            "mcp__drmCopilotExtension__" + _camel_or_pascal_to_snake(match.group(1))
        ),
        description="Rewrite remaining VS Code command IDs to semantic MCP tool usage.",
    ),
)

_PROMPT_SKILL_FALLBACKS: tuple[tuple[str, str], ...] = (
    (
        ".github/prompts/fillout-prd-feature.prompt.md",
        ".agents/skills/fillout-prd-feature/SKILL.md",
    ),
    (
        ".github/prompts/generate-atomic-plan.prompt.md",
        ".agents/skills/atomic-plan-contract/SKILL.md",
    ),
    (
        ".github/prompts/orchestrate-csharp-work.prompt.md",
        ".agents/skills/orchestrate-csharp-work/SKILL.md",
    ),
    (
        ".github/prompts/orchestrate-powershell-work.prompt.md",
        ".agents/skills/orchestrate-powershell-work/SKILL.md",
    ),
    (
        ".github/prompts/orchestrate-python-work.prompt.md",
        ".agents/skills/orchestrate-python-work/SKILL.md",
    ),
    (
        ".github/prompts/orchestrate-work.prompt.md",
        ".agents/skills/orchestrate-work/SKILL.md",
    ),
    (
        ".github/prompts/research-issue.prompt.md",
        ".agents/skills/research-issue/SKILL.md",
    ),
    (
        ".github/prompts/review-feature.prompt.md",
        ".agents/skills/review-feature/SKILL.md",
    ),
)


def _rewrite_rules(
    *,
    enable_repo_prompts: bool,
    standing_guidance_source_paths: tuple[str, ...],
) -> tuple[RewriteRule, ...]:
    """Build the ordered rewrite catalog for one converter run."""

    standing_guidance_rules = tuple(
        RewriteRule(
            pattern=re.compile(rf"(?<![A-Za-z0-9_]){re.escape(source_path)}\b"),
            replacement="AGENTS.md",
            description=(
                "Rewrite merged standing-guidance source paths to the native "
                "AGENTS.md target."
            ),
        )
        for source_path in standing_guidance_source_paths
    )
    prompt_skill_fallback_rules = tuple(
        RewriteRule(
            pattern=re.compile(rf"(?<![A-Za-z0-9_]){re.escape(source_path)}\b"),
            replacement=target_path,
            description=(
                "Rewrite a known GitHub prompt reference to the native shared "
                "skill fallback when repository prompt launchers are disabled."
            ),
        )
        for source_path, target_path in _PROMPT_SKILL_FALLBACKS
    )
    prompt_rewrite_rules: tuple[RewriteRule, ...] = ()
    if enable_repo_prompts:
        prompt_rewrite_rules = (
            RewriteRule(
                pattern=re.compile(
                    r"(?<![A-Za-z0-9_])\.github/prompts/([A-Za-z0-9_.-]+?)(?:\.prompt)?\.md\b"
                ),
                replacement=lambda match: (
                    f".codex/prompts/{_normalize_target_name(match.group(1))}.md"
                ),
                description=(
                    "Rewrite GitHub prompt references to repository prompt paths."
                ),
            ),
            RewriteRule(
                pattern=re.compile(r"(?<![A-Za-z0-9_])\.github/prompts/"),
                replacement=".codex/prompts/",
                description=(
                    "Rewrite GitHub prompt-directory references to repository prompt "
                    "paths."
                ),
            ),
        )

    return (
        standing_guidance_rules
        + _BASE_REWRITE_RULES
        + (() if enable_repo_prompts else prompt_skill_fallback_rules)
        + prompt_rewrite_rules
    )


_UNRESOLVED_RUNTIME_PATTERNS: tuple[tuple[re.Pattern[str], str], ...] = (
    (
        re.compile(r"\bdrmCopilotExtension\.[A-Za-z0-9_]+\b"),
        "raw VS Code command identifier",
    ),
    (
        re.compile(
            r"(^|[^A-Za-z0-9_])\.github/(copilot-instructions\.md|instructions/|skills/|agents/|prompts/)"
        ),
        "GitHub Copilot runtime path",
    ),
    (
        re.compile(
            r"(^|[^A-Za-z0-9_])\.claude/(skills/|agents/|hooks/|settings\.json)"
        ),
        "Claude runtime path",
    ),
    (re.compile(r"\bCLAUDE\.md\b"), "Claude standing-instructions file"),
    (
        re.compile(r"\bscripts/dev_tools/[A-Za-z0-9_./-]+\b"),
        "repository-local script reference",
    ),
)


def rewrite_supported_automation_reference(
    text: str,
    *,
    enable_repo_prompts: bool,
    standing_guidance_source_paths: tuple[str, ...] = (),
) -> tuple[str, tuple[str, ...]]:
    """Rewrite supported runtime references toward semantic MCP usage.

    Purpose:
        Apply the approved rewrite catalog to a block of generated text.

    Args:
        text (str): Generated text that may contain host-specific runtime
            references.

    Returns:
        tuple[str, tuple[str, ...]]: The rewritten text plus the descriptions of
        rewrite rules that were applied.

    Raises:
        None.

    Side Effects:
        None.
    """

    rewritten_text = text
    applied_descriptions: list[str] = []

    # Apply the catalog in a fixed order so the same input always yields the
    # same rewritten output and applied-rule metadata.
    for rewrite_rule in _rewrite_rules(
        enable_repo_prompts=enable_repo_prompts,
        standing_guidance_source_paths=standing_guidance_source_paths,
    ):
        updated_text, replacement_count = rewrite_rule.pattern.subn(
            rewrite_rule.replacement,
            rewritten_text,
        )
        if replacement_count > 0:
            applied_descriptions.append(rewrite_rule.description)
            rewritten_text = updated_text

    return rewritten_text, tuple(applied_descriptions)


def detect_unresolved_runtime_reference(text: str) -> tuple[str, ...]:
    """Detect runtime-specific references that still require manual handling.

    Purpose:
        Flag unresolved source-runtime references that cannot remain in emitted
        native Codex output.

    Args:
        text (str): Generated text to inspect after supported rewrites have run.

    Returns:
        tuple[str, ...]: Human-readable descriptions of unresolved runtime
        references discovered in the text.

    Raises:
        None.

    Side Effects:
        None.
    """

    findings: list[str] = []

    # Scan for unresolved source-runtime references that must block apply mode
    # when a native Codex target is required.
    for unresolved_pattern, description in _UNRESOLVED_RUNTIME_PATTERNS:
        if unresolved_pattern.search(text):
            findings.append(description)

    return tuple(findings)
