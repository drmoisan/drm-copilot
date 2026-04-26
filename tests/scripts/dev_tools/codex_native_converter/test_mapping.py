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
