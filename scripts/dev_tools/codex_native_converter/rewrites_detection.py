"""Detect unresolved runtime references left after supported rewrites.

Purpose:
    Hold the fail-closed detector that scans generated native output for
    source-runtime references the rewrite catalog did not resolve, so
    ``rewrites.py`` stays within the 500-line policy.

Usage:
    ``rewrites.detect_unresolved_runtime_reference`` re-exports
    ``detect_unresolved_runtime_reference`` from this module; the converter
    engine and validation stage call it after the rewrite catalog has run.

Flow:
    Each pattern is paired with a human-readable description; every pattern
    that matches contributes one description, in table order.

Invariants / Constraints:
    The table names only runtime surfaces the converter supports as sources
    (GitHub Copilot and Claude paths, VS Code command identifiers, and
    repository-local scripts). Non-runtime GitHub paths such as workflows are
    deliberately not matched.

Side Effects:
    None.
"""

from __future__ import annotations

import re

_UNRESOLVED_RUNTIME_PATTERNS: tuple[tuple[re.Pattern[str], str], ...] = (
    (
        re.compile(r"\bdrmCopilotExtension\.[A-Za-z0-9_]+\b"),
        "raw VS Code command identifier",
    ),
    (
        re.compile(
            r"(^|[^A-Za-z0-9_])\.github/"
            r"(copilot-instructions\.md|instructions/|skills/|agents/|prompts/|hooks/)"
        ),
        "GitHub Copilot runtime path",
    ),
    (
        re.compile(
            r"(^|[^A-Za-z0-9_])\.claude/(skills/|agents/|hooks/|lib/|settings\.json)"
        ),
        "Claude runtime path",
    ),
    (re.compile(r"\bCLAUDE\.md\b"), "Claude standing-instructions file"),
    (
        re.compile(r"\bscripts/dev_tools/[A-Za-z0-9_./-]+\b"),
        "repository-local script reference",
    ),
)


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
