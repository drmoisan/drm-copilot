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

import re
from typing import TYPE_CHECKING

from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    MappingRecord,
    SectionIntent,
    SectionIntentKind,
    SourceArtifact,
    SourceEcosystem,
    SourceKind,
    TargetRole,
)

if TYPE_CHECKING:
    from pathlib import Path

_REPO_WIDE_APPLY_TO_PATTERN = re.compile(r"(?m)^applyTo:\s*([\"'])?\*\*(?:\1)?\s*$")
_REPO_WIDE_PATHS_PATTERN = re.compile(r"(?m)^paths:\s*\n\s*-\s*([\"'])?\*\*(?:\1)?\s*$")
_PROMPT_WORKFLOW_HEADING_PATTERN = re.compile(
    r"(workflow|steps|task execution|required orchestration behavior|"
    r"completion criteria|output format|what to investigate|section rules|"
    r"execution rules|launch template|objective|goal)",
    re.IGNORECASE,
)
_PROMPT_ENFORCEMENT_PATTERN = re.compile(
    r"\b(must not|blocked|forbidden|non-negotiable|hard lock|hard gate|"
    r"must not begin|must be blocked)\b",
    re.IGNORECASE,
)
_NUMBERED_STEP_PATTERN = re.compile(r"(?m)^\d+[.)]\s+")


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


def _has_repo_wide_apply_to(source_root: Path, source_path: Path) -> bool:
    """Determine whether one instruction file applies repo-wide.

    Purpose:
        Identify instruction files whose declared scope is every path in the
        repository so they can merge into standing guidance instead of a skill.

    Args:
        source_root (Path): Absolute or relative source root.
        source_path (Path): Source-root-relative path to inspect.

    Returns:
        bool: True when the instruction declares `applyTo: "**"`.

    Raises:
        None.

    Side Effects:
        Reads one source file from disk.
    """

    source_text = _read_optional_text(source_root, source_path)
    return bool(_REPO_WIDE_APPLY_TO_PATTERN.search(source_text))


def _has_repo_wide_paths_yaml(source_root: Path, source_path: Path) -> bool:
    """Determine whether one rule file declares repo-wide YAML `paths` scope.

    Purpose:
        Identify Claude rule files whose declared scope is every path in the
        repository so they can merge into standing guidance instead of a skill.

    Args:
        source_root (Path): Absolute or relative source root.
        source_path (Path): Source-root-relative path to inspect.

    Returns:
        bool: True when the rule declares a YAML list-form `paths:` block whose
        only entry is `**`.

    Raises:
        None.

    Side Effects:
        Reads one source file from disk.
    """

    source_text = _read_optional_text(source_root, source_path)
    return bool(_REPO_WIDE_PATHS_PATTERN.search(source_text))


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
        if _has_repo_wide_apply_to(source_root, source_path):
            return MappingRecord(
                source_path=path_text,
                source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
                source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
                conversion_class=ConversionClass.DECOMPOSED,
                target_role=TargetRole.STANDING_GUIDANCE,
                target_path=None,
                notes=(
                    "Repo-wide instruction applies to all files and merges into "
                    "standing guidance.",
                ),
            )
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

    if path_text == ".github/skills/README.md":
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.UNKNOWN,
            conversion_class=ConversionClass.UNSUPPORTED,
            target_role=TargetRole.UNSUPPORTED,
            target_path=None,
            notes=("Skills index documentation has no native runtime surface in v1.",),
            is_required=False,
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

    if path_text.startswith(".github/prompts/") and path_text.endswith(".md"):
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

    if path_text.startswith(".claude/rules/") and path_text.endswith(".md"):
        if _has_repo_wide_paths_yaml(source_root, source_path):
            return MappingRecord(
                source_path=path_text,
                source_ecosystem=SourceEcosystem.CLAUDE,
                source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
                conversion_class=ConversionClass.DECOMPOSED,
                target_role=TargetRole.STANDING_GUIDANCE,
                target_path=None,
                notes=(
                    "Repo-wide Claude rule applies to all files and merges into "
                    "standing guidance.",
                ),
            )
        return MappingRecord(
            source_path=path_text,
            source_ecosystem=SourceEcosystem.CLAUDE,
            source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SHARED_SKILL,
            target_path=None,
            notes=(
                "Path-scoped Claude rule requires decomposition into shared "
                "skills or standing guidance.",
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


def classify_prompt_sections(
    source_artifact: SourceArtifact,
) -> tuple[SectionIntent, ...]:
    """Classify prompt sections into section-level semantic intents.

    Purpose:
        Provide content-aware decomposition for GitHub prompt files so report
        and planning stages can distinguish reusable workflows from enforceable
        gates instead of treating the entire prompt as one launcher blob.

    Args:
        source_artifact (SourceArtifact): Parsed source artifact for one prompt.

    Returns:
        tuple[SectionIntent, ...]: Deterministic section-intent records in
        source order.

    Raises:
        None.

    Side Effects:
        None.
    """

    if source_artifact.source_kind is not SourceKind.LAUNCHER_PROMPT:
        return ()

    section_intents: list[SectionIntent] = []
    for source_section in source_artifact.sections:
        section_text = source_section.content
        notes: list[str] = []
        intent_kind = SectionIntentKind.UNSUPPORTED

        if _PROMPT_ENFORCEMENT_PATTERN.search(section_text):
            intent_kind = SectionIntentKind.HOOK_CANDIDATE
            notes.append(
                "Section contains hard-gate or forbidden-action language that "
                "resembles a native validation hook."
            )
        elif (
            _PROMPT_WORKFLOW_HEADING_PATTERN.search(source_section.heading)
            or len(_NUMBERED_STEP_PATTERN.findall(section_text)) >= 2
        ):
            intent_kind = SectionIntentKind.SHARED_WORKFLOW
            notes.append(
                "Section contains reusable workflow or output-contract content "
                "that maps more naturally to a shared skill."
            )

        if intent_kind is SectionIntentKind.UNSUPPORTED:
            continue

        section_intents.append(
            SectionIntent(
                source_path=source_artifact.source_path,
                section_id=source_section.section_id,
                heading=source_section.heading,
                intent_kind=intent_kind,
                notes=tuple(notes),
            )
        )

    return tuple(section_intents)
