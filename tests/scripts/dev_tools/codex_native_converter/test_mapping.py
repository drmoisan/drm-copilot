"""Tests for Codex-native converter target-path planning."""

from __future__ import annotations

from scripts.dev_tools.codex_native_converter.mapping import plan_target_paths
from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    MappingRecord,
    SourceEcosystem,
    SourceKind,
    TargetRole,
)


def _test_plan_target_paths_leaves_launcher_prompts_unsupported() -> None:
    """Leave launcher prompts unsupported when repo-convention prompts are disabled."""

    mapping_record = MappingRecord(
        source_path=".github/prompts/launch-review.prompt.md",
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        source_kind=SourceKind.LAUNCHER_PROMPT,
        conversion_class=ConversionClass.REPO_CONVENTION,
        target_role=TargetRole.LAUNCHER,
        target_path=None,
    )

    planned_record = plan_target_paths(mapping_record, enable_repo_prompts=False)

    assert planned_record.conversion_class is ConversionClass.UNSUPPORTED
    assert planned_record.target_role is TargetRole.UNSUPPORTED
    assert planned_record.target_path is None


globals()[
    "test_plan_target_paths_leaves_launcher_prompts_unsupported_when_repo_prompts_disabled"
] = _test_plan_target_paths_leaves_launcher_prompts_unsupported


def test_plan_target_paths_emits_codex_prompts_when_repo_prompts_enabled() -> None:
    """Emit a `.codex/prompts` target path when prompt output is enabled."""

    mapping_record = MappingRecord(
        source_path=".github/prompts/launch-review.prompt.md",
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        source_kind=SourceKind.LAUNCHER_PROMPT,
        conversion_class=ConversionClass.REPO_CONVENTION,
        target_role=TargetRole.LAUNCHER,
        target_path=None,
    )

    planned_record = plan_target_paths(mapping_record, enable_repo_prompts=True)

    assert planned_record.target_path == ".codex/prompts/launch-review.md"


def test_plan_target_paths_uses_skill_folder_name_for_reusable_skill_targets() -> None:
    """Use the reusable skill folder name instead of the literal `SKILL` filename."""

    mapping_record = MappingRecord(
        source_path=".github/skills/review-workflow/SKILL.md",
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        source_kind=SourceKind.REUSABLE_SKILL,
        conversion_class=ConversionClass.DIRECT,
        target_role=TargetRole.SHARED_SKILL,
        target_path=None,
    )

    planned_record = plan_target_paths(mapping_record, enable_repo_prompts=False)

    assert planned_record.target_path == ".agents/skills/review-workflow/SKILL.md"


def test_plan_target_paths_keeps_filename_naming_for_path_scoped_instructions() -> None:
    """Keep filename-based naming for path-scoped instruction surfaces."""

    mapping_record = MappingRecord(
        source_path=".github/instructions/general-code-change.instructions.md",
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        source_kind=SourceKind.PATH_SCOPED_INSTRUCTION,
        conversion_class=ConversionClass.DECOMPOSED,
        target_role=TargetRole.SHARED_SKILL,
        target_path=None,
    )

    planned_record = plan_target_paths(mapping_record, enable_repo_prompts=False)

    assert planned_record.target_path == ".agents/skills/general-code-change/SKILL.md"


def test_plan_target_paths_emits_powershell_hook_targets() -> None:
    """Emit PowerShell hook targets without duplicating source script extensions."""

    mapping_record = MappingRecord(
        source_path=".claude/hooks/check-python-test-purity.ps1",
        source_ecosystem=SourceEcosystem.CLAUDE,
        source_kind=SourceKind.HOOK_DEFINITION,
        conversion_class=ConversionClass.DIRECT,
        target_role=TargetRole.HOOK,
        target_path=None,
    )

    planned_record = plan_target_paths(mapping_record, enable_repo_prompts=False)

    assert planned_record.target_path == ".codex/hooks/check-python-test-purity.ps1"
