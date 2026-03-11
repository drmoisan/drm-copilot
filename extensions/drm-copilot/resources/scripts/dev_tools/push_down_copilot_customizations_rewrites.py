"""Reference rewrite helpers for the push-down customization publisher.

Purpose:
    Keep command-reference normalization and rewrite catalog logic separate from
    the publisher's orchestration flow so each module stays cohesive and easier
    to test.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

TRAILING_PUNCTUATION = ".,;:!?)"
SCRIPT_REFERENCE_PATTERN = re.compile(
    r"(?:(?:poetry\s+run\s+python\s+-m)\s+)?(?:\$\{workspaceFolder\}[\\/])?scripts(?:\.dev_tools\.[A-Za-z0-9_.]+|[\\/](?:dev_tools|dev-tools)[A-Za-z0-9_.\\/-]+)"
)


@dataclass(frozen=True, slots=True)
class RewriteTarget:
    """
    Describe how a known script reference maps to a VS Code command.

    Purpose:
        Keep rewrite metadata explicit so implemented commands and placeholder
        commands render the same stable textual command-reference format.

    Usage:
        Selected by normalized script-reference keys during text rewriting.

    Flow:
        A matched reference normalizes to `normalized_key`, then the target is
        rendered through `render_command_reference()`.

    Invariants / Constraints:
        `command_id` values must match the extension's registered command IDs.

    Side Effects:
        None.

    Attributes:
        normalized_key (str): Canonical lookup key for a script reference.
        command_id (str): VS Code command identifier.
        title (str): User-facing command title.
        script_reference (str): Original script reference documented by the
            placeholder contract.
        is_placeholder (bool): Whether the command intentionally remains a
            placeholder.
    """

    normalized_key: str
    command_id: str
    title: str
    script_reference: str
    is_placeholder: bool


def build_rewrite_catalog() -> dict[str, RewriteTarget]:
    """
    Build the command rewrite catalog for supported script references.

    Purpose:
        Keep the supported rewrite surface explicit and deterministic.

    Args:
        None.

    Returns:
        dict[str, RewriteTarget]: Catalog keyed by normalized reference.

    Raises:
        None.

    Side Effects:
        None.
    """
    targets = (
        RewriteTarget(
            normalized_key="scripts.dev_tools.pr_context.collector",
            command_id="drmCopilotExtension.collectPrContext",
            title="drm-copilot: Collect PR Context",
            script_reference="scripts.dev_tools.pr_context.collector",
            is_placeholder=False,
        ),
        RewriteTarget(
            normalized_key="scripts.dev_tools.new_active_feature_folder",
            command_id="drmCopilotExtension.newActiveFeatureFolderPlaceholder",
            title="drm-copilot: New Active Feature Folder (Placeholder)",
            script_reference="scripts.dev_tools.new_active_feature_folder",
            is_placeholder=True,
        ),
        RewriteTarget(
            normalized_key="scripts.dev_tools.potential_to_issue",
            command_id="drmCopilotExtension.potentialToIssuePlaceholder",
            title="drm-copilot: Potential To Issue (Placeholder)",
            script_reference="scripts.dev_tools.potential_to_issue",
            is_placeholder=True,
        ),
        RewriteTarget(
            normalized_key="scripts/dev_tools/new_potential_bug_entry.py",
            command_id="drmCopilotExtension.newPotentialBugEntryPyPlaceholder",
            title="drm-copilot: New Potential Bug Entry (Python Placeholder)",
            script_reference="scripts/dev_tools/new_potential_bug_entry.py",
            is_placeholder=True,
        ),
        RewriteTarget(
            normalized_key="scripts/dev_tools/new-potential-entry.ps1",
            command_id="drmCopilotExtension.newPotentialEntryPsPlaceholder",
            title="drm-copilot: New Potential Entry (PowerShell Placeholder)",
            script_reference="scripts/dev-tools/new-potential-entry.ps1",
            is_placeholder=True,
        ),
        RewriteTarget(
            normalized_key="scripts.dev_tools.push_down_copilot_customizations",
            command_id="drmCopilotExtension.pushDownCopilotCustomizations",
            title="drm-copilot: Push Down Copilot Customizations",
            script_reference="scripts.dev_tools.push_down_copilot_customizations",
            is_placeholder=False,
        ),
    )
    return {target.normalized_key: target for target in targets}


def render_command_reference(target: RewriteTarget) -> str:
    """
    Render a canonical textual command reference for copied files.

    Purpose:
        Keep replacement text uniform regardless of whether the destination
        command is implemented or still a placeholder.

    Args:
        target (RewriteTarget): Catalog entry for the matched reference.

    Returns:
        str: Stable textual command reference.

    Raises:
        None.

    Side Effects:
        None.
    """
    return f"VS Code command: `{target.title}` (command ID: `{target.command_id}`)"


def normalize_reference_for_lookup(reference_text: str) -> str:
    """
    Normalize a matched textual reference before catalog lookup.

    Purpose:
        Collapse workspace prefixes and slash variants onto canonical lookup
        keys so the rewrite catalog has one stable matching surface.

    Args:
        reference_text (str): Raw matched script reference.

    Returns:
        str: Canonical lookup key.

    Raises:
        None.

    Side Effects:
        None.
    """
    normalized = reference_text.strip()
    normalized = re.sub(r"^poetry\s+run\s+python\s+-m\s+", "", normalized)
    normalized = normalized.replace("${workspaceFolder}\\", "")
    normalized = normalized.replace("${workspaceFolder}/", "")
    normalized = normalized.replace("\\", "/")
    normalized = normalized.replace("scripts/dev-tools/", "scripts/dev_tools/")
    return normalized


def split_trailing_punctuation(reference_text: str) -> tuple[str, str]:
    """
    Split a matched reference into its core text and trailing punctuation.

    Purpose:
        Preserve prose punctuation so rewrites do not disturb surrounding
        documentation.

    Args:
        reference_text (str): Matched reference including surrounding
            punctuation.

    Returns:
        tuple[str, str]: Core reference text and trailing punctuation.

    Raises:
        None.

    Side Effects:
        None.
    """
    core = reference_text
    suffix = ""
    # Preserve trailing sentence punctuation so rewrites do not disturb prose.
    while core and core[-1] in TRAILING_PUNCTUATION:
        suffix = core[-1] + suffix
        core = core[:-1]
    return core, suffix


def rewrite_matched_reference(
    reference_text: str,
    catalog: dict[str, RewriteTarget],
) -> tuple[str, int, int, list[str]]:
    """
    Rewrite one matched script reference when it belongs to the catalog.

    Purpose:
        Handle one matched reference so the surrounding regex pass can stay
        focused on streaming replacements and counts.

    Args:
        reference_text (str): Matched script reference text.
        catalog (dict[str, RewriteTarget]): Lookup table keyed by normalized
            reference.

    Returns:
        tuple[str, int, int, list[str]]: Replacement text, implemented rewrite
        count, placeholder rewrite count, and unmatched references.

    Raises:
        None.

    Side Effects:
        None.
    """
    core_reference, suffix = split_trailing_punctuation(reference_text)
    normalized_reference = normalize_reference_for_lookup(core_reference)
    target = catalog.get(normalized_reference)
    if target is None:
        return reference_text, 0, 0, [normalized_reference]

    replacement = render_command_reference(target) + suffix
    if target.is_placeholder:
        return replacement, 0, 1, []
    return replacement, 1, 0, []


def rewrite_text_references(text: str) -> tuple[str, int, int, list[str]]:
    """
    Rewrite supported script references within text content.

    Purpose:
        Apply replacements only to matched script references and report unknown
        references without changing them.

    Args:
        text (str): Source text to rewrite.

    Returns:
        tuple[str, int, int, list[str]]: Rewritten text, implemented rewrite
        count, placeholder rewrite count, and ordered unmatched references.

    Raises:
        None.

    Side Effects:
        None.
    """
    catalog = build_rewrite_catalog()
    rewritten_count = 0
    placeholder_count = 0
    unmatched_references: list[str] = []

    def replace_match(match: re.Match[str]) -> str:
        """Rewrite one regex match while accumulating deterministic counters."""
        nonlocal rewritten_count, placeholder_count
        replacement, rewritten_delta, placeholder_delta, unmatched = (
            rewrite_matched_reference(match.group(0), catalog)
        )
        rewritten_count += rewritten_delta
        placeholder_count += placeholder_delta
        # Preserve first-seen order so unmatched reporting stays deterministic.
        for reference in unmatched:
            if reference not in unmatched_references:
                unmatched_references.append(reference)
        return replacement

    rewritten_text = SCRIPT_REFERENCE_PATTERN.sub(replace_match, text)
    return rewritten_text, rewritten_count, placeholder_count, unmatched_references
