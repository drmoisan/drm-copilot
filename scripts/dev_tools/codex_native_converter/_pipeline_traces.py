"""Section-level translation-trace builder for prompt source artifacts.

Purpose:
    Extract ``build_prompt_translation_traces`` from ``pipeline.py`` to keep
    that module within the 500-line file-size policy while grouping the
    prompt-specific trace-building logic in a focused helper module.

Usage:
    Import ``build_prompt_translation_traces`` from this module or from
    ``pipeline.py`` (which re-exports it for backward compatibility).

Invariants / Constraints:
    This module must not import from ``engine.py`` or ``pipeline.py`` to avoid
    circular dependencies. All imports are from external modules only.

Side Effects:
    None at module level.
"""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.classifier import classify_prompt_sections
from scripts.dev_tools.codex_native_converter.mapping import plan_section_target_path
from scripts.dev_tools.codex_native_converter.models import (
    MappingRecord,
    RunOptions,
    SectionIntentKind,
    SourceKind,
    TargetRole,
    TranslationTrace,
)
from scripts.dev_tools.codex_native_converter.parser import parse_source_artifact


def build_prompt_translation_traces(
    run_options: RunOptions,
    mapping_record: MappingRecord,
) -> tuple[TranslationTrace, ...]:
    """Build section-level translation traces for one GitHub prompt artifact.

    Purpose:
        Recover content-aware decomposition for prompt files without changing
        the existing file-level apply pipeline yet.

    Args:
        run_options (RunOptions): Requested run options.
        mapping_record (MappingRecord): File-level mapping record for one prompt.

    Returns:
        tuple[TranslationTrace, ...]: Section-level traces for launcher,
            workflow, and enforcement sections in deterministic order.

    Raises:
        OSError: Raised when the source file cannot be read.

    Side Effects:
        Reads the prompt source file from disk.
    """

    if mapping_record.source_kind is not SourceKind.LAUNCHER_PROMPT:
        return ()

    source_artifact = parse_source_artifact(
        run_options.source_root,
        Path(mapping_record.source_path),
        mapping_record.source_ecosystem,
        mapping_record.source_kind,
    )
    translation_traces: list[TranslationTrace] = []
    launcher_target_path = plan_section_target_path(
        mapping_record.source_path,
        source_ecosystem=mapping_record.source_ecosystem,
        source_kind=mapping_record.source_kind,
        target_role=TargetRole.LAUNCHER,
        enable_repo_prompts=run_options.enable_repo_prompts,
    )
    launcher_notes: tuple[str, ...] = (
        (
            "Prompt launcher wrapper maps only to the repository-convention "
            "launcher surface."
        ),
        *(
            ("Repository-convention prompt output is disabled for this run.",)
            if launcher_target_path is None
            else ()
        ),
    )
    translation_traces.append(
        TranslationTrace(
            source_path=mapping_record.source_path,
            section_id=f"{mapping_record.source_path}#__launcher__",
            heading="Launcher Surface",
            intent_kind=SectionIntentKind.LAUNCHER_ONLY,
            target_role=TargetRole.LAUNCHER,
            target_path=launcher_target_path,
            notes=launcher_notes,
        )
    )

    for section_intent in classify_prompt_sections(source_artifact):
        target_role = TargetRole.UNSUPPORTED
        if section_intent.intent_kind is SectionIntentKind.SHARED_WORKFLOW:
            target_role = TargetRole.SHARED_SKILL
        elif section_intent.intent_kind is SectionIntentKind.HOOK_CANDIDATE:
            target_role = TargetRole.HOOK

        if target_role is TargetRole.UNSUPPORTED:
            continue

        translation_traces.append(
            TranslationTrace(
                source_path=section_intent.source_path,
                section_id=section_intent.section_id,
                heading=section_intent.heading,
                intent_kind=section_intent.intent_kind,
                target_role=target_role,
                target_path=plan_section_target_path(
                    mapping_record.source_path,
                    source_ecosystem=mapping_record.source_ecosystem,
                    source_kind=mapping_record.source_kind,
                    target_role=target_role,
                    enable_repo_prompts=run_options.enable_repo_prompts,
                ),
                notes=section_intent.notes,
            )
        )

    return tuple(
        sorted(
            translation_traces,
            key=lambda trace: (
                trace.source_path,
                trace.section_id,
                trace.target_role.value,
            ),
        )
    )
