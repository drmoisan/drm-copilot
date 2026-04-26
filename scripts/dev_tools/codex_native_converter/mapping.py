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
        skill_name = _normalized_name(mapping_record.source_path)
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
        hook_name = _normalized_name(mapping_record.source_path)
        return replace(
            mapping_record,
            target_path=f".codex/hooks/{hook_name}.py",
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
