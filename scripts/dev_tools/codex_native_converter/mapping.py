"""Resolve approved Codex-native target paths for classified artifacts.

Purpose:
    Convert classification records into concrete Codex-native destination paths
    while preserving the approved runtime surfaces defined by the feature scope.

Usage:
    The converter engine calls ``plan_target_paths`` after classification and
    before validation.

Flow:
    The planner chooses a target path from the record's target role, applies
    naming normalization, and returns a copy of the mapping record with the
    planned target path.

Invariants / Constraints:
    Only approved Codex-native surfaces are emitted. Repository-convention
    prompt output remains disabled unless the caller explicitly enables it.

Side Effects:
    None.
"""

from __future__ import annotations

from dataclasses import replace
from pathlib import PurePosixPath

from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    MappingRecord,
    SourceEcosystem,
    SourceKind,
    TargetRole,
)


def _normalized_name(source_path: str) -> str:
    """Normalize one source path into a stable target-friendly base name.

    Purpose:
        Produce consistent skill, agent, hook, and prompt names from mixed
        source filenames and folder structures.

    Args:
        source_path (str): Source-root-relative path for the artifact.

    Returns:
        str: A kebab-case friendly base name without ecosystem-specific suffixes.

    Raises:
        None.

    Side Effects:
        None.
    """

    source_name = PurePosixPath(source_path).name
    normalized_name = source_name
    for suffix in (".instructions.md", ".agent.md", ".prompt.md", ".md", ".json"):
        if normalized_name.endswith(suffix):
            normalized_name = normalized_name[: -len(suffix)]
            break
    return normalized_name.replace("_", "-")


def _planned_skill_name(mapping_record: MappingRecord) -> str:
    """Derive the target skill name for one mapped skill-like artifact.

    Purpose:
        Preserve the reusable skill folder identity for `*/skills/<name>/SKILL.md`
        while keeping filename-based naming for path-scoped instruction files.

    Args:
        mapping_record (MappingRecord): Skill-like mapping record whose target
            folder name must be planned.

    Returns:
        str: The normalized skill folder name for the target path.

    Raises:
        None.

    Side Effects:
        None.
    """

    source_path = PurePosixPath(mapping_record.source_path)
    if (
        mapping_record.source_kind is SourceKind.REUSABLE_SKILL
        and source_path.name == "SKILL.md"
        and source_path.parent.name
    ):
        return source_path.parent.name.replace("_", "-")
    return _normalized_name(mapping_record.source_path)


def _planned_hook_name(mapping_record: MappingRecord) -> str:
    """Derive the target hook name without carrying source script extensions."""

    source_name = PurePosixPath(mapping_record.source_path).name
    if source_name.endswith((".ps1", ".py")):
        normalized_name = source_name.rsplit(".", 1)[0]
        return normalized_name.replace("_", "-")
    return _normalized_name(mapping_record.source_path)


def plan_target_paths(
    mapping_record: MappingRecord,
    *,
    enable_repo_prompts: bool,
) -> MappingRecord:
    """Resolve the approved Codex-native target path for one mapping record.

    Purpose:
        Attach a concrete target path to a classified mapping record when the
        approved v1 target surface is known.

    Args:
        mapping_record (MappingRecord): Classified mapping record whose target
            path is still unresolved.
        enable_repo_prompts (bool): Whether repository-convention prompt output
            is enabled for this run.

    Returns:
        MappingRecord: A copy of the input record with ``target_path`` resolved
        when the artifact has an approved destination.

    Raises:
        None.

    Side Effects:
        None.
    """

    if mapping_record.target_role is TargetRole.STANDING_GUIDANCE:
        return replace(mapping_record, target_path="AGENTS.md")

    if mapping_record.target_role is TargetRole.SHARED_SKILL:
        skill_name = _planned_skill_name(mapping_record)
        return replace(
            mapping_record,
            target_path=f".agents/skills/{skill_name}/SKILL.md",
        )

    if mapping_record.target_role is TargetRole.SUBAGENT:
        agent_name = _normalized_name(mapping_record.source_path)
        return replace(
            mapping_record,
            target_path=f".codex/agents/{agent_name}.toml",
        )

    if mapping_record.target_role is TargetRole.MCP_CONFIG:
        return replace(mapping_record, target_path=".codex/config.toml")

    if mapping_record.target_role is TargetRole.HOOK:
        hook_name = _planned_hook_name(mapping_record)
        return replace(
            mapping_record,
            target_path=f".codex/hooks/{hook_name}.ps1",
        )

    if mapping_record.target_role is TargetRole.APPROVAL_RULE:
        rule_name = _normalized_name(mapping_record.source_path)
        return replace(
            mapping_record,
            target_path=f".codex/rules/{rule_name}.rules",
        )

    if mapping_record.target_role is TargetRole.LAUNCHER:
        if enable_repo_prompts:
            prompt_name = _normalized_name(mapping_record.source_path)
            return replace(
                mapping_record,
                target_path=f".codex/prompts/{prompt_name}.md",
            )
        return replace(
            mapping_record,
            conversion_class=ConversionClass.UNSUPPORTED,
            target_role=TargetRole.UNSUPPORTED,
            target_path=None,
            notes=(
                *mapping_record.notes,
                "Repository-convention prompt output is disabled for this run.",
            ),
            is_required=False,
        )

    return replace(mapping_record, target_path=None)


def plan_section_target_path(
    source_path: str,
    *,
    source_ecosystem: SourceEcosystem,
    source_kind: SourceKind,
    target_role: TargetRole,
    enable_repo_prompts: bool,
) -> str | None:
    """Resolve a native target path for one section-level planned emission.

    Purpose:
        Reuse the file-level path-planning rules for section-level prompt and
        mixed-artifact emissions without duplicating naming logic.

    Args:
        source_path (str): Source-root-relative artifact path.
        source_kind (SourceKind): Source kind associated with the section.
        target_role (TargetRole): Native role selected for the section.
        enable_repo_prompts (bool): Whether repository-convention prompt output
            is enabled for the current run.

    Returns:
        str | None: Planned target path when the role has an approved native
            destination, otherwise None.

    Raises:
        None.

    Side Effects:
        None.
    """

    return plan_target_paths(
        MappingRecord(
            source_path=source_path,
            source_ecosystem=source_ecosystem,
            source_kind=source_kind,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=target_role,
            target_path=None,
        ),
        enable_repo_prompts=enable_repo_prompts,
    ).target_path
