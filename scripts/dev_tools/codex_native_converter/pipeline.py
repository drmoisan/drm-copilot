"""v2 pipeline stage functions for the codex-native converter.

Purpose:
    Hold rendering, topology, and translation-trace functions extracted from
    ``engine.py`` to comply with the 500-line file-size policy. These functions
    implement the v2 data-flow stages added in the section-level decomposition
    and topology-view commits.

Responsibilities:
    - Source text reading and rewriting.
    - Native target content rendering (per-record, merged standing-guidance,
      and section-level emission).
    - Topology edge construction.
    - Prompt translation-trace construction.

How to use:
    Import individual stage functions from this module into ``engine.py``
    where the pipeline orchestrator calls them.

Invariants / Constraints:
    This module must not import from ``engine.py`` to avoid circular
    dependencies. All imports are from external modules only.
"""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter._pipeline_traces import (
    build_prompt_translation_traces as build_prompt_translation_traces,
)
from scripts.dev_tools.codex_native_converter.models import (
    MappingRecord,
    PlannedEmission,
    RunOptions,
    SourceSection,
    TargetRole,
    TopologyEdge,
    TranslationTrace,
)
from scripts.dev_tools.codex_native_converter.rewrites import (
    rewrite_supported_automation_reference,
)


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


def render_target_content(
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


def render_merged_standing_guidance(
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
        rendered_text = render_target_content(
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


def render_section_emission_content(
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


def build_topology_edges(
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
        translation_traces (tuple[TranslationTrace, ...]): Prompt translation
            traces from the current run.

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
            rendered_text = render_target_content(
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
