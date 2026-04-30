"""Tests for Codex-native converter validation behavior."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    MappingRecord,
    PlannedEmission,
    RunOptions,
    SectionIntentKind,
    SourceEcosystem,
    SourceKind,
    TargetRole,
)
from scripts.dev_tools.codex_native_converter.validation import validate_conversion_plan


def _run_options() -> RunOptions:
    """Build a stable run-options value for validation tests.

    Purpose:
        Avoid repetitive test setup while keeping the validation tests explicit.

    Args:
        None.

    Returns:
        RunOptions: Shared run options for validation-only tests.

    Raises:
        None.

    Side Effects:
        None.
    """

    return RunOptions(
        mode="apply",
        source_root=Path("fixtures/source"),
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        selected_paths=(),
        destination_root=Path("fixtures/destination"),
        artifact_root=Path("fixtures/artifacts"),
    )


def _test_validate_conversion_plan_blocks_unresolved_strict_mappings() -> None:
    """Block apply mode when note flags require unresolved strict mappings."""

    mapping_records = (
        MappingRecord(
            source_path="hard-gate.md",
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.AGENT_MANIFEST,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SUBAGENT,
            target_path=".codex/agents/hard-gate.toml",
            notes=("requires-native-hard-gate",),
        ),
        MappingRecord(
            source_path="handoff.md",
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.AGENT_MANIFEST,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SUBAGENT,
            target_path=".codex/agents/handoff.toml",
            notes=("requires-handoff-review",),
        ),
        MappingRecord(
            source_path="mcp.md",
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.HOST_ADAPTER_REFERENCE,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.MCP_CONFIG,
            target_path=".codex/config.toml",
            notes=("requires-mcp-rewrite",),
        ),
    )

    findings = validate_conversion_plan(_run_options(), mapping_records, (), {})
    finding_codes = {finding.code for finding in findings}

    assert "unresolved-hard-gate-mapping" in finding_codes
    assert "unresolved-handoff-mapping" in finding_codes
    assert "unresolved-mcp-rewrite" in finding_codes


globals()[
    "test_validate_conversion_plan_blocks_unresolved_hard_gate_handoff_and_mcp_failures"
] = _test_validate_conversion_plan_blocks_unresolved_strict_mappings


def _test_validate_conversion_plan_blocks_duplicate_targets_and_runtime_refs() -> None:
    """Block apply mode for duplicate targets and unresolved runtime references."""

    mapping_records = (
        MappingRecord(
            source_path="first.md",
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.REUSABLE_SKILL,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.SHARED_SKILL,
            target_path=".agents/skills/shared/SKILL.md",
        ),
        MappingRecord(
            source_path="second.md",
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.SHARED_SKILL,
            target_path=".agents/skills/shared/SKILL.md",
        ),
    )
    generated_output = {
        ".agents/skills/shared/SKILL.md": (
            "This output still points at "
            ".github/instructions/runtime.instructions.md."
        )
    }

    findings = validate_conversion_plan(
        _run_options(), mapping_records, (), generated_output
    )
    finding_codes = {finding.code for finding in findings}

    assert "duplicate-target-path" in finding_codes
    assert "lingering-source-runtime-reference" in finding_codes


globals()[
    "test_validate_conversion_plan_blocks_duplicate_targets_and_lingering_source_runtime_references"
] = _test_validate_conversion_plan_blocks_duplicate_targets_and_runtime_refs


def test_validate_conversion_plan_allows_merged_standing_guidance_targets() -> None:
    """Allow multiple standing-guidance inputs to merge into one `AGENTS.md` target."""

    mapping_records = (
        MappingRecord(
            source_path=".github/copilot-instructions.md",
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.STANDING_INSTRUCTION,
            conversion_class=ConversionClass.DIRECT,
            target_role=TargetRole.STANDING_GUIDANCE,
            target_path="AGENTS.md",
        ),
        MappingRecord(
            source_path=".github/instructions/general-code-change.instructions.md",
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
            conversion_class=ConversionClass.DECOMPOSED,
            target_role=TargetRole.STANDING_GUIDANCE,
            target_path="AGENTS.md",
        ),
    )

    findings = validate_conversion_plan(_run_options(), mapping_records, (), {})

    assert not any(finding.code == "duplicate-target-path" for finding in findings)


def test_validate_conversion_plan_allows_same_source_section_emissions_to_merge() -> (
    None
):
    """Allow multiple sections from one source prompt to merge into one target."""

    planned_emissions = (
        PlannedEmission(
            source_path=".github/prompts/review-feature.prompt.md",
            section_id=".github/prompts/review-feature.prompt.md#gate-1",
            heading="Minor-audit integrity gate",
            intent_kind=SectionIntentKind.HOOK_CANDIDATE,
            target_role=TargetRole.HOOK,
            target_path=".codex/hooks/review-feature.ps1",
        ),
        PlannedEmission(
            source_path=".github/prompts/review-feature.prompt.md",
            section_id=".github/prompts/review-feature.prompt.md#gate-2",
            heading="Required deliverables",
            intent_kind=SectionIntentKind.HOOK_CANDIDATE,
            target_role=TargetRole.HOOK,
            target_path=".codex/hooks/review-feature.ps1",
        ),
    )

    findings = validate_conversion_plan(_run_options(), (), planned_emissions, {})

    assert not any(finding.code == "duplicate-target-path" for finding in findings)


def test_validate_conversion_plan_blocks_conflicting_section_emission_targets() -> None:
    """Block conflicting target paths claimed by separate section-emission groups."""

    planned_emissions = (
        PlannedEmission(
            source_path=".github/prompts/review-feature.prompt.md",
            section_id=".github/prompts/review-feature.prompt.md#gate-1",
            heading="Minor-audit integrity gate",
            intent_kind=SectionIntentKind.HOOK_CANDIDATE,
            target_role=TargetRole.HOOK,
            target_path=".codex/hooks/review-feature.ps1",
        ),
        PlannedEmission(
            source_path=".github/prompts/review-staged.prompt.md",
            section_id=".github/prompts/review-staged.prompt.md#gate-1",
            heading="Required deliverables",
            intent_kind=SectionIntentKind.HOOK_CANDIDATE,
            target_role=TargetRole.HOOK,
            target_path=".codex/hooks/review-feature.ps1",
        ),
    )

    findings = validate_conversion_plan(_run_options(), (), planned_emissions, {})

    assert any(finding.code == "duplicate-target-path" for finding in findings)
