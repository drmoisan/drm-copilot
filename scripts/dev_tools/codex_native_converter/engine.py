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

from scripts.dev_tools.codex_native_converter.classifier import (
    classify_prompt_sections,
    classify_source_artifact,
)
from scripts.dev_tools.codex_native_converter.inventory import discover_source_artifacts
from scripts.dev_tools.codex_native_converter.mapping import (
    plan_section_target_path,
    plan_target_paths,
)
from scripts.dev_tools.codex_native_converter.models import (
    MappingRecord,
    PlannedEmission,
    RunOptions,
    SectionIntentKind,
    SourceKind,
    SourceSection,
    TargetRole,
    TopologyEdge,
    TranslationTrace,
    ValidationFinding,
)
from scripts.dev_tools.codex_native_converter.parser import parse_source_artifact
from scripts.dev_tools.codex_native_converter.reporting import (
    ConverterFileSystem,
    RealConverterFileSystem,
    ReportSetPaths,
    write_conversion_report_set,
)
from scripts.dev_tools.codex_native_converter.rewrites import (
    rewrite_supported_automation_reference,
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

    Side Effects:
        None.
    """

    mapping_records: tuple[MappingRecord, ...]
    validation_findings: tuple[ValidationFinding, ...]
    report_paths: ReportSetPaths
    generated_output: dict[str, str]
    wrote_destination: bool
    translation_traces: tuple[TranslationTrace, ...] = ()


def _read_source_text(source_root: Path, source_path: str) -> str:
    """Read one source artifact from the source root.

    Purpose:
        Provide the original source text that the engine will rewrite and wrap
        into native outputs.

    Args:
        source_root (Path): Source tree root.
        source_path (str): Source-root-relative artifact path.

    Returns:
        str: Source text decoded as UTF-8.

    Raises:
        OSError: Raised when the source file cannot be read.

    Side Effects:
        Reads one source file from disk.
    """

    return (source_root.resolve() / source_path).read_text(encoding="utf-8")


def _rewrite_text(
    run_options: RunOptions,
    source_text: str,
    *,
    standing_guidance_source_paths: tuple[str, ...],
) -> tuple[str, str]:
    """Rewrite one source text block and summarize applied rewrites."""

    rewritten_text, applied_rewrites = rewrite_supported_automation_reference(
        source_text,
        enable_repo_prompts=run_options.enable_repo_prompts,
        standing_guidance_source_paths=standing_guidance_source_paths,
    )
    rewrite_summary = (
        "\n".join(f"- {description}" for description in applied_rewrites)
        if applied_rewrites
        else "- None"
    )
    return rewritten_text.rstrip(), rewrite_summary


def _wrap_rendered_target_content(
    *,
    target_role: TargetRole,
    target_path: str | None,
    rewritten_text: str,
    rewrite_summary: str,
) -> str:
    """Wrap rewritten text in the target-role-specific native output shape."""

    if target_role is TargetRole.STANDING_GUIDANCE:
        return (
            "# Converted standing guidance\n\n"
            f"Applied rewrites:\n{rewrite_summary}\n\n"
            f"{rewritten_text}\n"
        )

    if target_role is TargetRole.SHARED_SKILL:
        return (
            "# Converted skill\n\n"
            f"Applied rewrites:\n{rewrite_summary}\n\n"
            f"{rewritten_text}\n"
        )

    if target_role is TargetRole.SUBAGENT:
        agent_name = Path(target_path or "agent.toml").stem
        return (
            f'name = "{agent_name}"\n'
            'description = "Converted subagent"\n'
            "developer_instructions = '''\n"
            f"Applied rewrites:\n{rewrite_summary}\n\n"
            f"{rewritten_text}\n"
            "'''\n"
        )

    if target_role is TargetRole.MCP_CONFIG:
        return (
            "# Review and merge native MCP, hook, and approval settings "
            "intentionally.\n\n"
            f"{rewritten_text}\n"
        )

    if target_role is TargetRole.HOOK:
        return (
            "# Converted hook\n"
            "# Review the generated hook behavior before enabling it.\n\n"
            f"{rewritten_text}\n"
        )

    if target_role is TargetRole.APPROVAL_RULE:
        return (
            "# Converted approval rule candidate\n"
            "# Review the generated rule semantics before enforcement.\n\n"
            f"{rewritten_text}\n"
        )

    if target_role is TargetRole.LAUNCHER:
        return f"# Converted launcher prompt\n\n{rewritten_text}\n"

    return f"{rewritten_text}\n"


def _render_target_content(
    run_options: RunOptions,
    mapping_record: MappingRecord,
    *,
    standing_guidance_source_paths: tuple[str, ...],
) -> str:
    """Render one generated target file for the mapping record.

    Purpose:
        Produce deterministic native output content for one mapped artifact.

    Args:
        run_options (RunOptions): Requested run options for the current run.
        mapping_record (MappingRecord): Planned mapping record.

    Returns:
        str: Rendered output text for the target path.

    Raises:
        OSError: Raised when a required source file cannot be read.

    Side Effects:
        Reads the source file associated with the mapping record.
    """

    source_text = _read_source_text(run_options.source_root, mapping_record.source_path)
    rewritten_text, rewrite_summary = _rewrite_text(
        run_options,
        source_text,
        standing_guidance_source_paths=standing_guidance_source_paths,
    )
    return _wrap_rendered_target_content(
        target_role=mapping_record.target_role,
        target_path=mapping_record.target_path,
        rewritten_text=rewritten_text,
        rewrite_summary=rewrite_summary,
    )


def _render_merged_standing_guidance(
    run_options: RunOptions,
    mapping_records: tuple[MappingRecord, ...],
) -> str:
    """Render one merged `AGENTS.md` output from standing-guidance sources.

    Purpose:
        Combine repo-wide standing-guidance inputs into one deterministic native
        `AGENTS.md` output while preserving source ordering and rewrite notes.

    Args:
        run_options (RunOptions): Requested run options for the current run.
        mapping_records (tuple[MappingRecord, ...]): Standing-guidance mapping
            records that all target `AGENTS.md`.

    Returns:
        str: One merged `AGENTS.md` output body.

    Raises:
        OSError: Raised when a required source file cannot be read.

    Side Effects:
        Reads the source files associated with the mapping records.
    """

    standing_guidance_source_paths = tuple(
        record.source_path for record in mapping_records
    )
    rendered_sections: list[str] = [
        "# Converted standing guidance",
        "",
        "Merged standing-guidance sources:",
        *(f"- `{Path(record.source_path).name}`" for record in mapping_records),
        "",
    ]

    for mapping_record in mapping_records:
        rendered_text = _render_target_content(
            run_options,
            mapping_record,
            standing_guidance_source_paths=standing_guidance_source_paths,
        ).rstrip()
        section_label = Path(mapping_record.source_path).name
        rendered_sections.extend(
            (
                f"## Source: `{section_label}`",
                "",
                rendered_text,
                "",
            )
        )

    return "\n".join(rendered_sections).rstrip() + "\n"


def _render_section_emission_content(
    run_options: RunOptions,
    target_path: str,
    planned_emissions: tuple[PlannedEmission, ...],
    section_lookup_by_id: dict[str, SourceSection],
    *,
    standing_guidance_source_paths: tuple[str, ...],
) -> str:
    """Render one merged native output from section-level planned emissions."""

    if not planned_emissions:
        return ""

    target_role = planned_emissions[0].target_role
    merged_sections: list[str] = []
    all_rewrite_descriptions: list[str] = []
    source_paths = tuple(
        dict.fromkeys(
            planned_emission.source_path for planned_emission in planned_emissions
        )
    )

    for planned_emission in planned_emissions:
        source_section = section_lookup_by_id.get(planned_emission.section_id)
        if source_section is None:
            continue
        rewritten_text, rewrite_summary = _rewrite_text(
            run_options,
            source_section.content,
            standing_guidance_source_paths=standing_guidance_source_paths,
        )
        rewrite_lines = tuple(
            line for line in rewrite_summary.splitlines() if line and line != "- None"
        )
        all_rewrite_descriptions.extend(rewrite_lines)
        merged_sections.extend(
            (
                f"## Source section: `{planned_emission.heading}`",
                "",
                "Applied rewrites:",
                *(rewrite_lines or ("- None",)),
                "",
                rewritten_text,
                "",
            )
        )

    unique_rewrite_descriptions = tuple(dict.fromkeys(all_rewrite_descriptions))
    rewrite_summary = (
        "\n".join(unique_rewrite_descriptions)
        if unique_rewrite_descriptions
        else "- None"
    )
    merged_text = "\n".join(
        (
            "Derived prompt sections:",
            *(
                f"- `{planned_emission.heading}`"
                for planned_emission in planned_emissions
            ),
            "",
            "Source artifacts:",
            *(f"- `{Path(source_path).name}`" for source_path in source_paths),
            "",
            *merged_sections,
        )
    ).rstrip()
    return _wrap_rendered_target_content(
        target_role=target_role,
        target_path=target_path,
        rewritten_text=merged_text,
        rewrite_summary=rewrite_summary,
    )


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
            generated_output[target_path] = _render_merged_standing_guidance(
                run_options,
                target_records,
            )
            continue
        generated_output[target_path] = _render_target_content(
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
        generated_output[target_path] = _render_section_emission_content(
            run_options,
            target_path,
            tuple(section_emissions_by_target[target_path]),
            section_lookup_by_id,
            standing_guidance_source_paths=standing_guidance_source_paths,
        )
    return generated_output


def _extract_topology_destinations(
    rendered_text: str,
    known_destination_paths: tuple[str, ...],
) -> tuple[str, ...]:
    """Extract referenced native destinations from rendered output text.

    Purpose:
        Recover decomposition fan-out by detecting native target paths that
        appear in one source artifact's rendered native content.

    Args:
        rendered_text (str): Rendered native output derived from one source.
        known_destination_paths (tuple[str, ...]): Known native target paths
            from the current conversion plan.

    Returns:
        tuple[str, ...]: Referenced destination paths in deterministic order.

    Raises:
        None.

    Side Effects:
        None.
    """

    destinations_by_position: list[tuple[int, str]] = []
    for destination_path in known_destination_paths:
        position = rendered_text.find(destination_path)
        if position >= 0:
            destinations_by_position.append((position, destination_path))
    return tuple(
        destination_path
        for _, destination_path in sorted(
            destinations_by_position,
            key=lambda item: (item[0], item[1]),
        )
    )


def _build_topology_edges(
    run_options: RunOptions,
    mapping_records: tuple[MappingRecord, ...],
    translation_traces: tuple[TranslationTrace, ...],
) -> tuple[TopologyEdge, ...]:
    """Build report topology edges from per-source rendered native intent.

    Purpose:
        Capture many-to-many relationships for decomposed artifacts and merged
        targets so Mermaid charts reflect actual native fan-out and fan-in.

    Args:
        run_options (RunOptions): Requested run options.
        mapping_records (tuple[MappingRecord, ...]): Planned mappings.

    Returns:
        tuple[TopologyEdge, ...]: Deterministic topology edges for reporting.

    Raises:
        OSError: Raised when a required source file cannot be read.

    Side Effects:
        Reads source files from disk through target rendering.
    """

    standing_guidance_source_paths = tuple(
        record.source_path
        for record in mapping_records
        if record.target_role is TargetRole.STANDING_GUIDANCE
        and record.target_path == "AGENTS.md"
    )
    known_destination_paths = tuple(
        sorted(
            {
                record.target_path
                for record in mapping_records
                if record.target_path is not None
            }
        )
    )
    topology_edges: list[TopologyEdge] = []
    translation_trace_source_paths = {trace.source_path for trace in translation_traces}

    for translation_trace in translation_traces:
        topology_edges.append(
            TopologyEdge(
                source_path=translation_trace.source_path,
                destination_path=translation_trace.target_path or "[no target]",
            )
        )

    for mapping_record in mapping_records:
        if mapping_record.source_path in translation_trace_source_paths:
            continue
        rendered_text = ""
        if mapping_record.target_path is not None:
            rendered_text = _render_target_content(
                run_options,
                mapping_record,
                standing_guidance_source_paths=standing_guidance_source_paths,
            )

        destination_paths: list[str] = []
        if mapping_record.target_path is not None:
            destination_paths.append(mapping_record.target_path)
            for destination_path in _extract_topology_destinations(
                rendered_text,
                known_destination_paths,
            ):
                if destination_path not in destination_paths:
                    destination_paths.append(destination_path)
        else:
            destination_paths.append("[no target]")

        for destination_path in destination_paths:
            topology_edges.append(
                TopologyEdge(
                    source_path=mapping_record.source_path,
                    destination_path=destination_path,
                )
            )

    return tuple(
        sorted(
            topology_edges,
            key=lambda edge: (edge.source_path, edge.destination_path),
        )
    )


def _build_prompt_translation_traces(
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


def _build_translation_traces(
    run_options: RunOptions,
    mapping_records: tuple[MappingRecord, ...],
) -> tuple[TranslationTrace, ...]:
    """Build section-aware translation traces for mixed prompt artifacts."""

    translation_traces: list[TranslationTrace] = []
    for mapping_record in mapping_records:
        translation_traces.extend(
            _build_prompt_translation_traces(run_options, mapping_record)
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
    generated_output = _render_generated_output(
        run_options,
        mapping_records,
        planned_emissions,
    )
    topology_edges = _build_topology_edges(
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
