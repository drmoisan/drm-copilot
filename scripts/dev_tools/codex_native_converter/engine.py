"""Run the end-to-end Codex-native conversion pipeline.

Purpose:
    Orchestrate source discovery, classification, target mapping, rewrite
    application, validation, report emission, and optional apply-mode writes.

Usage:
    The CLI calls ``run_review_mode`` or ``run_apply_mode`` with validated
    ``RunOptions`` and an optional filesystem adapter for output writes.

Flow:
    Inventory discovers artifacts, classification and mapping plan targets,
    generated output is rendered and rewritten, validation runs, the report set
    is written, and apply mode writes destination files only when no blocking
    finding remains.

Invariants / Constraints:
    Review mode never mutates the destination workspace. Apply mode writes no
    destination files when blocking validation findings are present.

Side Effects:
    Reads source files and writes report artifacts and, when allowed, destination
    files through the configured filesystem adapter.
"""

from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path

from scripts.dev_tools.codex_native_converter.classifier import classify_source_artifact
from scripts.dev_tools.codex_native_converter.intermediate_state import (
    IntermediateState,
    write_intermediate_state_artifacts,
)
from scripts.dev_tools.codex_native_converter.inventory import discover_source_artifacts
from scripts.dev_tools.codex_native_converter.mapping import plan_target_paths
from scripts.dev_tools.codex_native_converter.models import (
    MappingRecord,
    PlannedEmission,
    RunOptions,
    SectionIntent,
    SourceArtifact,
    SourceKind,
    SourceSection,
    TargetRole,
    TranslationTrace,
    ValidationFinding,
)
from scripts.dev_tools.codex_native_converter.parser import parse_source_artifact
from scripts.dev_tools.codex_native_converter.pipeline import (
    build_prompt_translation_traces,
    build_topology_edges,
    render_merged_standing_guidance,
    render_section_emission_content,
    render_target_content,
)
from scripts.dev_tools.codex_native_converter.reporting import (
    ConverterFileSystem,
    RealConverterFileSystem,
    ReportSetPaths,
    write_conversion_report_set,
)
from scripts.dev_tools.codex_native_converter.section_intent import (
    classify_section_intent,
)
from scripts.dev_tools.codex_native_converter.validation import validate_conversion_plan


@dataclass(frozen=True, slots=True)
class ConversionRunResult:
    """Describe the outcome of one review or apply run.

    Purpose:
        Return auditable run details to the CLI and any wrapper that needs the
        artifact paths, validation results, and write status.

    Usage:
        The CLI inspects this result to print artifact paths and choose its exit
        code.

    Flow:
        The engine populates this value after report writing and optional
        destination writes complete.

    Invariants / Constraints:
        Report paths always point to the written artifact set for the run.
    """

    mapping_records: tuple[MappingRecord, ...]
    validation_findings: tuple[ValidationFinding, ...]
    report_paths: ReportSetPaths
    generated_output: dict[str, str]
    wrote_destination: bool
    translation_traces: tuple[TranslationTrace, ...] = ()


def _plan_mappings(run_options: RunOptions) -> tuple[MappingRecord, ...]:
    """Plan mappings for one converter run.

    Purpose:
        Execute inventory, classification, and target-path planning as one pure
        preparation step before rendering output.

    Args:
        run_options (RunOptions): Requested run options for the current run.

    Returns:
        tuple[MappingRecord, ...]: Planned mappings sorted by source path.

    Raises:
        ValueError: Propagated when selected paths escape the source root.

    Side Effects:
        Reads filesystem metadata through inventory and source files through the
        classifier when mixed-concern notes are needed.
    """

    discovered_paths = discover_source_artifacts(
        run_options.source_root,
        run_options.source_ecosystem,
        run_options.selected_paths,
    )
    mapping_records: list[MappingRecord] = []

    # Classify and map each discovered artifact in source-path order so later
    # reporting and proposed-tree output remain deterministic.
    for source_path in discovered_paths:
        classified_record = classify_source_artifact(
            run_options.source_root,
            source_path,
            run_options.source_ecosystem,
        )
        mapped_record = plan_target_paths(
            classified_record,
            enable_repo_prompts=run_options.enable_repo_prompts,
        )
        mapping_records.append(mapped_record)

    return tuple(sorted(mapping_records, key=lambda record: record.source_path))


def _render_generated_output(
    run_options: RunOptions,
    mapping_records: tuple[MappingRecord, ...],
    planned_emissions: tuple[PlannedEmission, ...],
) -> dict[str, str]:
    """Render the generated output set for one run.

    Purpose:
        Build the full proposed native output tree before validation and report
        emission.

    Args:
        run_options (RunOptions): Requested run options.
        mapping_records (tuple[MappingRecord, ...]): Planned mappings.

    Returns:
        dict[str, str]: Generated output keyed by target path.

    Raises:
        OSError: Raised when a required source file cannot be read.

    Side Effects:
        Reads source files from disk.
    """

    generated_output: dict[str, str] = {}
    standing_guidance_source_paths = tuple(
        record.source_path
        for record in mapping_records
        if record.target_role is TargetRole.STANDING_GUIDANCE
        and record.target_path == "AGENTS.md"
    )
    mapping_records_by_target: dict[str, list[MappingRecord]] = defaultdict(list)
    section_emissions_by_target: dict[str, list[PlannedEmission]] = defaultdict(list)

    # Render only records with concrete target paths because unsupported items
    # are still represented through validation findings and report rows.
    for mapping_record in mapping_records:
        if mapping_record.target_path is None:
            continue
        mapping_records_by_target[mapping_record.target_path].append(mapping_record)
    for planned_emission in planned_emissions:
        if planned_emission.target_path is None:
            continue
        section_emissions_by_target[planned_emission.target_path].append(
            planned_emission
        )

    for target_path in sorted(mapping_records_by_target):
        records_for_target = mapping_records_by_target[target_path]
        if not records_for_target:
            continue
        target_records = tuple(records_for_target)
        if (
            target_path == "AGENTS.md"
            and all(
                record.target_role is TargetRole.STANDING_GUIDANCE
                for record in target_records
            )
            and len(target_records) > 1
        ):
            generated_output[target_path] = render_merged_standing_guidance(
                run_options,
                target_records,
            )
            continue
        generated_output[target_path] = render_target_content(
            run_options,
            records_for_target[-1],
            standing_guidance_source_paths=standing_guidance_source_paths,
        )
    section_lookup_by_id: dict[str, SourceSection] = {}
    parsed_source_paths = sorted(
        {
            planned_emission.source_path
            for planned_emission in planned_emissions
            if planned_emission.target_path is not None
        }
    )
    for source_path in parsed_source_paths:
        source_artifact = parse_source_artifact(
            run_options.source_root,
            Path(source_path),
            run_options.source_ecosystem,
            SourceKind.LAUNCHER_PROMPT,
        )
        section_lookup_by_id.update(
            {
                source_section.section_id: source_section
                for source_section in source_artifact.sections
            }
        )

    for target_path in sorted(section_emissions_by_target):
        if target_path in generated_output:
            continue
        generated_output[target_path] = render_section_emission_content(
            run_options,
            target_path,
            tuple(section_emissions_by_target[target_path]),
            section_lookup_by_id,
            standing_guidance_source_paths=standing_guidance_source_paths,
        )
    return generated_output


def _build_translation_traces(
    run_options: RunOptions,
    mapping_records: tuple[MappingRecord, ...],
) -> tuple[TranslationTrace, ...]:
    """Build section-aware translation traces for mixed prompt artifacts."""

    translation_traces: list[TranslationTrace] = []
    for mapping_record in mapping_records:
        translation_traces.extend(
            build_prompt_translation_traces(run_options, mapping_record)
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


def _build_planned_emissions(
    translation_traces: tuple[TranslationTrace, ...],
) -> tuple[PlannedEmission, ...]:
    """Build section-level planned emissions from translation traces."""

    return tuple(
        PlannedEmission(
            source_path=translation_trace.source_path,
            section_id=translation_trace.section_id,
            heading=translation_trace.heading,
            intent_kind=translation_trace.intent_kind,
            target_role=translation_trace.target_role,
            target_path=translation_trace.target_path,
            notes=translation_trace.notes,
        )
        for translation_trace in translation_traces
        if translation_trace.target_path is not None
        and translation_trace.target_role in {TargetRole.SHARED_SKILL, TargetRole.HOOK}
    )


def _write_destination_outputs(
    destination_root: Path,
    generated_output: dict[str, str],
    fs: ConverterFileSystem,
) -> None:
    """Write generated output files into the destination root.

    Purpose:
        Persist native converter outputs only after validation has allowed the
        apply run to proceed.

    Args:
        destination_root (Path): Destination root for apply mode.
        generated_output (dict[str, str]): Generated target files keyed by
            relative target path.
        fs (ConverterFileSystem): Filesystem adapter for writes.

    Returns:
        None: This method returns no value.

    Raises:
        OSError: Raised when a destination file cannot be written.

    Side Effects:
        Writes destination files through the filesystem adapter.
    """

    for target_path in sorted(generated_output):
        fs.write_text(destination_root / target_path, generated_output[target_path])


def _run_conversion(
    run_options: RunOptions,
    *,
    allow_destination_write: bool,
    fs: ConverterFileSystem | None = None,
) -> ConversionRunResult:
    """Run the shared conversion pipeline for review or apply mode.

    Purpose:
        Share the inventory-through-report pipeline across review and apply mode.

    Args:
        run_options (RunOptions): Requested run options.
        allow_destination_write (bool): Whether destination writes are allowed
            when validation passes.
        fs (ConverterFileSystem | None): Filesystem adapter for output writes.

    Returns:
        ConversionRunResult: Auditable conversion outcome.

    Raises:
        OSError: Raised when source files or report writes fail.

    Side Effects:
        Writes report artifacts and, when allowed, destination files.
    """

    resolved_fs = fs or RealConverterFileSystem()
    mapping_records = _plan_mappings(run_options)
    translation_traces = _build_translation_traces(run_options, mapping_records)
    planned_emissions = _build_planned_emissions(translation_traces)

    # Classify section intents for all parsed source artifacts so the
    # intermediate state captures the full v2 pipeline view. Parsing is
    # performed here in discovery order to keep the collection deterministic.
    source_artifacts: list[SourceArtifact] = []
    section_intents: list[SectionIntent] = []
    for mapping_record in mapping_records:
        source_artifact = parse_source_artifact(
            run_options.source_root,
            Path(mapping_record.source_path),
            mapping_record.source_ecosystem,
            mapping_record.source_kind,
        )
        source_artifacts.append(source_artifact)
        # Classify each section and accumulate intents for the intermediate
        # state and any downstream consumers.
        for source_section in source_artifact.sections:
            section_intents.append(
                classify_section_intent(source_section, source_artifact)
            )

    # Write intermediate state files when the caller has opted in, so the full
    # compiler-like pipeline state is available for audit without affecting
    # the emitted native outputs.
    if run_options.emit_intermediate_state:
        intermediate = IntermediateState(
            source_artifacts=tuple(source_artifacts),
            section_intents=tuple(section_intents),
            planned_emissions=planned_emissions,
            translation_traces=translation_traces,
        )
        write_intermediate_state_artifacts(
            intermediate,
            run_options.artifact_root,
        )

    generated_output = _render_generated_output(
        run_options,
        mapping_records,
        planned_emissions,
    )
    topology_edges = build_topology_edges(
        run_options,
        mapping_records,
        translation_traces,
    )
    validation_findings = validate_conversion_plan(
        run_options,
        mapping_records,
        planned_emissions,
        generated_output,
    )
    report_paths = write_conversion_report_set(
        run_options,
        mapping_records,
        topology_edges,
        translation_traces,
        validation_findings,
        generated_output,
        fs=resolved_fs,
    )

    blocking_findings = any(finding.blocking for finding in validation_findings)
    wrote_destination = False
    if (
        allow_destination_write
        and not blocking_findings
        and run_options.destination_root
    ):
        _write_destination_outputs(
            run_options.destination_root.resolve(),
            generated_output,
            resolved_fs,
        )
        wrote_destination = True

    return ConversionRunResult(
        mapping_records=mapping_records,
        translation_traces=translation_traces,
        validation_findings=validation_findings,
        report_paths=report_paths,
        generated_output=generated_output,
        wrote_destination=wrote_destination,
    )


def run_review_mode(
    run_options: RunOptions,
    *,
    fs: ConverterFileSystem | None = None,
) -> ConversionRunResult:
    """Run the converter in review mode.

    Purpose:
        Execute the full conversion pipeline without mutating a destination root.

    Args:
        run_options (RunOptions): Requested review-mode options.
        fs (ConverterFileSystem | None): Filesystem adapter for report writes.

    Returns:
        ConversionRunResult: Review-mode result including report paths and
        validation findings.

    Raises:
        OSError: Raised when source files or report writes fail.

    Side Effects:
        Writes only report artifacts.
    """

    return _run_conversion(run_options, allow_destination_write=False, fs=fs)


def run_apply_mode(
    run_options: RunOptions,
    *,
    fs: ConverterFileSystem | None = None,
) -> ConversionRunResult:
    """Run the converter in apply mode.

    Purpose:
        Execute the full conversion pipeline and write destination files only
        when validation passes without blocking findings.

    Args:
        run_options (RunOptions): Requested apply-mode options.
        fs (ConverterFileSystem | None): Filesystem adapter for report and
            destination writes.

    Returns:
        ConversionRunResult: Apply-mode result including whether destination
        files were written.

    Raises:
        OSError: Raised when source files or report writes fail.

    Side Effects:
        Writes report artifacts and, when validation allows it, destination
        files.
    """

    return _run_conversion(run_options, allow_destination_write=True, fs=fs)
