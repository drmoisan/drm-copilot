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
    replacement: str
    description: str


_REWRITE_RULES: tuple[RewriteRule, ...] = (
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
)

_UNRESOLVED_RUNTIME_PATTERNS: tuple[tuple[re.Pattern[str], str], ...] = (
    (
        re.compile(r"\bdrmCopilotExtension\.[A-Za-z0-9_]+\b"),
        "raw VS Code command identifier",
    ),
    (re.compile(r"(^|[^A-Za-z0-9_])\.github/"), "GitHub Copilot runtime path"),
    (re.compile(r"(^|[^A-Za-z0-9_])\.claude/"), "Claude runtime path"),
    (re.compile(r"\bCLAUDE\.md\b"), "Claude standing-instructions file"),
    (
        re.compile(r"\bscripts/dev_tools/[A-Za-z0-9_./-]+\b"),
        "repository-local script reference",
    ),
)


def rewrite_supported_automation_reference(text: str) -> tuple[str, tuple[str, ...]]:
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
    for rewrite_rule in _REWRITE_RULES:
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
