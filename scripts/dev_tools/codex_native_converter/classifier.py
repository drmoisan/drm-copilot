"""Classify source artifacts for the Codex-native converter.

Purpose:
    Assign a deterministic source kind, conversion class, and target role to
    each supported source artifact before path mapping occurs.

Usage:
    The converter engine calls ``classify_source_artifact`` for every discovered
    source path returned by the inventory module.

Flow:
    The classifier inspects the normalized relative path, applies the ecosystem
    routing rules, and emits a ``MappingRecord`` with ``target_path`` still
    unresolved.

Invariants / Constraints:
    Classification is deterministic and path-driven. Unsupported surfaces are
    marked explicitly rather than inferred into a best-effort native mapping.

Side Effects:
    Reads file contents only when necessary to annotate mixed-concern artifacts
    with additional review notes.
"""

from __future__ import annotations

from typing import TYPE_CHECKING

from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    MappingRecord,
    SourceEcosystem,
    SourceKind,
    TargetRole,
)

if TYPE_CHECKING:
    from pathlib import Path


def _read_optional_text(source_root: Path, source_path: Path) -> str:
    """Read source text when note generation requires content inspection.

    Purpose:
        Inspect agent manifests for mixed-concern markers such as handoffs
        without making text parsing a hard requirement for every file.

    Args:
        source_root (Path): Absolute or relative source root.
        source_path (Path): Source-root-relative path to inspect.

    Returns:
        str: File contents decoded as UTF-8 when possible; otherwise an empty
        string.

    Raises:
        None.

    Side Effects:
        Reads a source file from disk.
    """

    absolute_path = (source_root.resolve() / source_path).resolve()
    try:
        return absolute_path.read_text(encoding="utf-8")
    except OSError:
        return ""


def _classify_github_copilot(source_root: Path, source_path: Path) -> MappingRecord:
    """Classify one GitHub Copilot source artifact.

    Purpose:
        Apply deterministic GitHub Copilot classification rules for v1 mapping.

    Args:
        source_root (Path): Source root that bounds the artifact.
        source_path (Path): Source-root-relative artifact path.

    Returns:
        MappingRecord: The classification result with unresolved target path.

    Raises:
        None.

    Side Effects:
        May read agent manifests to add review notes for mixed-concern content.
    """

    path_text = source_path.as_posix()
    notes: list[str] = []

    if path_text == ".github/copilot-instructions.md":
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.STANDING_INSTRUCTION,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.STANDING_GUIDANCE,
            target_path=None,
        )

    if path_text.startswith(".github/instructions/") and path_text.endswith(
        ".instructions.md"
    ):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SHARED_SKILL,
            target_path=None,
            notes=(
                "Path-scoped instruction requires decomposition into shared "
                "skills or standing guidance.",
            ),
        )

    if "/SKILL.md" in path_text and path_text.startswith(".github/skills/"):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.REUSABLE_SKILL,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.SHARED_SKILL,
            target_path=None,
        )

    if path_text.startswith(".github/agents/") and path_text.endswith(".agent.md"):
        source_text = _read_optional_text(source_root, source_path)
        if "handoff" in source_text.lower() or "handoffs:" in source_text.lower():
            notes.append(
                "Agent manifest contains handoff semantics that require "
                "validation before apply mode."
            )
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.AGENT_MANIFEST,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SUBAGENT,
            target_path=None,
            notes=tuple(notes),
        )

    if path_text.startswith(".github/prompts/") and path_text.endswith(".prompt.md"):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.LAUNCHER_PROMPT,
            conversion_class=ConversionClass.REPO_CONVENTION,
            target_role=TargetRole.LAUNCHER,
            target_path=None,
            notes=(
                "Launcher prompts map only to the repository-convention "
                ".codex/prompts surface when explicitly enabled.",
            ),
            is_required=False,
        )

    return MappingRecord(
        source_path=path_text,
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        source_kind=SourceKind.UNKNOWN,
        conversion_class=ConversionClass.UNSUPPORTED,
        target_role=TargetRole.UNSUPPORTED,
        target_path=None,
        notes=("No supported GitHub Copilot v1 mapping rule matched this artifact.",),
    )


def _classify_claude(source_root: Path, source_path: Path) -> MappingRecord:
    """Classify one Claude source artifact.

    Purpose:
        Apply deterministic Claude classification rules for v1 mapping.

    Args:
        source_root (Path): Source root that bounds the artifact.
        source_path (Path): Source-root-relative artifact path.

    Returns:
        MappingRecord: The classification result with unresolved target path.

    Raises:
        None.

    Side Effects:
        May read agent manifests to add review notes for mixed-concern content.
    """

    path_text = source_path.as_posix()
    notes: list[str] = []

    if path_text == "CLAUDE.md":
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.STANDING_INSTRUCTION,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.STANDING_GUIDANCE,
            target_path=None,
        )

    if "/SKILL.md" in path_text and path_text.startswith(".claude/skills/"):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.REUSABLE_SKILL,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.SHARED_SKILL,
            target_path=None,
        )

    if path_text.startswith(".claude/agents/") and path_text.endswith(".md"):
        source_text = _read_optional_text(source_root, source_path)
        if "handoff" in source_text.lower() or "agent:" in source_text.lower():
            notes.append(
                "Claude agent manifest may encode orchestration or handoff "
                "semantics that require validation before apply mode."
            )
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.AGENT_MANIFEST,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SUBAGENT,
            target_path=None,
            notes=tuple(notes),
        )

    if path_text.startswith(".claude/hooks/"):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.HOOK_DEFINITION,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.HOOK,
            target_path=None,
        )

    if path_text == ".claude/settings.json":
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.PERMISSIONS_OR_SETTINGS,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.MCP_CONFIG,
            target_path=None,
            notes=(
                "Claude settings require decomposition across native Codex "
                "config, hooks, and approval surfaces.",
            ),
        )

    if path_text.startswith(".claude/rules/"):
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.SHELL_POLICY_OR_RULE,
            conversion_class=ConversionClass.UNSUPPORTED,
            target_role=TargetRole.UNSUPPORTED,
            target_path=None,
            notes=(
                "Claude Markdown rules do not have a verified direct "
                "Codex-native execution-policy mapping in v1.",
            ),
        )

    return MappingRecord(
        source_path=path_text,
        source_ecosystem=SourceEcosystem.CLAUDE,
        source_kind=SourceKind.UNKNOWN,
        conversion_class=ConversionClass.UNSUPPORTED,
        target_role=TargetRole.UNSUPPORTED,
        target_path=None,
        notes=("No supported Claude v1 mapping rule matched this artifact.",),
    )


def classify_source_artifact(
    source_root: Path,
    source_path: Path,
    source_ecosystem: SourceEcosystem,
) -> MappingRecord:
    """Classify one source artifact into conversion and target taxonomy.

    Purpose:
        Provide one deterministic classification record for a source artifact so
        later mapping and validation stages can stay pure and predictable.

    Args:
        source_root (Path): Root directory that bounds the source artifact.
        source_path (Path): Source-root-relative artifact path.
        source_ecosystem (SourceEcosystem): Declared source ecosystem.

    Returns:
        MappingRecord: Classification details for the source artifact with an
        unresolved target path.

    Raises:
        None.

    Side Effects:
        May read source files to append review notes for mixed-concern agent
        manifests.
    """

    if source_ecosystem is SourceEcosystem.GITHUB_COPILOT:
        return _classify_github_copilot(source_root, source_path)
    return _classify_claude(source_root, source_path)
