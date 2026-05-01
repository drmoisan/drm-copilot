"""Write review and apply artifacts for the Codex-native converter.

Purpose:
    Emit the required report artifact set for review and apply runs in a stable,
    deterministic layout.

Usage:
    The converter engine calls ``write_conversion_report_set`` after validation
    so every run produces a report, mapping catalog, validation results, and a
    reviewable proposed tree.

Flow:
    Structured data is rendered first, artifact directories are created next,
    then the Markdown report, JSON catalogs, and proposed-tree files are
    written in deterministic path order.

Invariants / Constraints:
    Artifact filenames and serialization ordering remain stable across runs for
    the same inputs.

Side Effects:
    Writes report artifacts through the configured filesystem adapter.
"""

from __future__ import annotations

import json
from dataclasses import dataclass
from typing import TYPE_CHECKING, Protocol

if TYPE_CHECKING:
    from pathlib import Path

    from scripts.dev_tools.codex_native_converter.models import (
        MappingRecord,
        RunOptions,
        TopologyEdge,
        TranslationTrace,
        ValidationFinding,
    )

# Import topology rendering helpers from the dedicated topology module.
from scripts.dev_tools.codex_native_converter._reporting_topology import (
    render_destination_to_repeated_source_chart,
    render_source_to_destination_chart,
    render_source_to_repeated_destination_chart,
)


class ConverterFileSystem(Protocol):
    """Describe the filesystem operations needed by report writing.

    Purpose:
        Keep report generation testable without requiring temporary filesystem
        writes in the unit tests.

    Usage:
        Production code passes ``RealConverterFileSystem`` and tests may pass a
        fake implementation.

    Flow:
        Callers create directories first and then write report files through
        this interface.

    Invariants / Constraints:
        Implementations must preserve the provided path and text content.

    Side Effects:
        Implementation dependent.
    """

    def mkdir(self, path: Path) -> None:
        """Create a directory and any missing parent directories."""

    def write_text(self, path: Path, content: str) -> None:
        """Write UTF-8 text content to one path."""


class RealConverterFileSystem:
    """Write converter output to the real filesystem.

    Purpose:
        Provide the default report-writing adapter for production CLI runs.

    Usage:
        Passed into ``write_conversion_report_set`` by default.

    Flow:
        Directory creation ensures parent folders exist before text is written.

    Invariants / Constraints:
        Paths are written exactly as provided.

    Side Effects:
        Creates directories and writes files on disk.
    """

    def mkdir(self, path: Path) -> None:
        """Create a directory and any missing parents.

        Purpose:
            Ensure one artifact directory exists before files are written.

        Args:
            path (Path): Directory path to create.

        Returns:
            None: This method returns no value.

        Raises:
            OSError: Raised when the directory cannot be created.

        Side Effects:
            Creates directories on disk.
        """

        path.mkdir(parents=True, exist_ok=True)

    def write_text(self, path: Path, content: str) -> None:
        """Write UTF-8 text content to one path.

        Purpose:
            Persist a report artifact or proposed output file.

        Args:
            path (Path): File path to write.
            content (str): UTF-8 text content to persist.

        Returns:
            None: This method returns no value.

        Raises:
            OSError: Raised when the file cannot be written.

        Side Effects:
            Writes a text file on disk.
        """

        path.parent.mkdir(parents=True, exist_ok=True)
        path.write_text(content, encoding="utf-8")


@dataclass(frozen=True, slots=True)
class ReportSetPaths:
    """Describe the artifact paths written for one converter run.

    Purpose:
        Return the artifact index to engine callers and automation wrappers.

    Usage:
        The engine includes this value in review/apply summaries and TypeScript
        wrappers can surface the Markdown report path to users.

    Flow:
        The report writer constructs the paths before writing the artifact set.

    Invariants / Constraints:
        All stored paths are absolute paths rooted beneath the artifact root.

    Side Effects:
        None.
    """

    conversion_report: Path
    mapping_catalog: Path
    validation_results: Path
    proposed_tree_root: Path


def _render_conversion_report(
    run_options: RunOptions,
    mapping_records: tuple[MappingRecord, ...],
    topology_edges: tuple[TopologyEdge, ...],
    translation_traces: tuple[TranslationTrace, ...],
    validation_findings: tuple[ValidationFinding, ...],
) -> str:
    """Render the human-readable Markdown conversion report.

    Purpose:
        Provide a concise artifact that reviewers can read without opening the
        JSON catalogs directly.

    Args:
        run_options (RunOptions): Requested run options.
        mapping_records (tuple[MappingRecord, ...]): Planned mappings.
        validation_findings (tuple[ValidationFinding, ...]): Validation results.

    Returns:
        str: Markdown report text.

    Raises:
        None.

    Side Effects:
        None.
    """

    blocking_count = sum(1 for finding in validation_findings if finding.blocking)
    destination_root_text = (
        run_options.destination_root.as_posix()
        if run_options.destination_root is not None
        else "review-only"
    )
    sorted_mapping_records = tuple(
        sorted(mapping_records, key=lambda record: record.source_path)
    )
    sorted_topology_edges = tuple(
        sorted(
            topology_edges,
            key=lambda edge: (edge.source_path, edge.destination_path),
        )
    )
    sorted_translation_traces = tuple(
        sorted(
            translation_traces,
            key=lambda trace: (
                trace.source_path,
                trace.section_id,
                trace.target_role.value,
                trace.target_path or "",
            ),
        )
    )
    lines = [
        "# Conversion Report",
        "",
        f"- Mode: `{run_options.mode}`",
        f"- Source ecosystem: `{run_options.source_ecosystem.value}`",
        f"- Source root: `{run_options.source_root.as_posix()}`",
        f"- Destination root: `{destination_root_text}`",
        f"- Artifact root: `{run_options.artifact_root.as_posix()}`",
        f"- Mapping records: {len(mapping_records)}",
        (
            f"- Validation findings: {len(validation_findings)} "
            f"({blocking_count} blocking)"
        ),
        "",
        "## Mapping Topology",
        "",
        "### Shared Destination Nodes",
        "",
        "Source and destination nodes are both deduplicated in this view.",
        "",
    ]
    lines.extend(render_source_to_destination_chart(sorted_topology_edges))
    lines.extend(
        (
            "",
            "### Repeated Destination Nodes",
            "",
            (
                "Destination nodes may repeat in this source-to-destination "
                "view so fan-in stays legible."
            ),
        )
    )
    lines.extend(render_source_to_repeated_destination_chart(sorted_topology_edges))
    lines.extend(
        (
            "",
            "### Repeated Source Nodes",
            "",
            (
                "Source nodes may repeat in this destination-to-source view so "
                "fan-out stays legible."
            ),
        )
    )
    lines.extend(render_destination_to_repeated_source_chart(sorted_topology_edges))
    lines.extend(
        (
            "",
            "## Mappings",
            "",
            "| Source path | Conversion class | Target role | Target path | Notes |",
            "| --- | --- | --- | --- | --- |",
        )
    )

    # Render mappings in stable source-path order so review diffs stay small
    # and predictable.
    for mapping_record in sorted_mapping_records:
        notes = "<br>".join(mapping_record.notes) if mapping_record.notes else ""
        lines.append(
            "| "
            f"`{mapping_record.source_path}` | "
            f"`{mapping_record.conversion_class.value}` | "
            f"`{mapping_record.target_role.value}` | "
            f"`{mapping_record.target_path or ''}` | {notes} |"
        )

    lines.extend(["", "## Section Mappings", ""])
    if not sorted_translation_traces:
        lines.append("- None")
    else:
        lines.extend(
            (
                (
                    "| Source path | Section | Intent | Target role | "
                    "Target path | Notes |"
                ),
                "| --- | --- | --- | --- | --- | --- |",
            )
        )
        for translation_trace in sorted_translation_traces:
            notes = (
                "<br>".join(translation_trace.notes) if translation_trace.notes else ""
            )
            lines.append(
                "| "
                f"`{translation_trace.source_path}` | "
                f"`{translation_trace.heading}` | "
                f"`{translation_trace.intent_kind.value}` | "
                f"`{translation_trace.target_role.value}` | "
                f"`{translation_trace.target_path or ''}` | "
                f"{notes} |"
            )

    lines.extend(["", "## Validation Findings", ""])
    if not validation_findings:
        lines.append("- None")
    else:
        # Render validation findings in a stable order so the Markdown summary
        # mirrors JSON output.
        for validation_finding in sorted(
            validation_findings,
            key=lambda finding: (
                finding.code,
                finding.source_path or "",
                finding.target_path or "",
            ),
        ):
            lines.append(f"- `{validation_finding.code}`: {validation_finding.message}")

    return "\n".join(lines) + "\n"


def write_conversion_report_set(
    run_options: RunOptions,
    mapping_records: tuple[MappingRecord, ...],
    topology_edges: tuple[TopologyEdge, ...],
    translation_traces: tuple[TranslationTrace, ...],
    validation_findings: tuple[ValidationFinding, ...],
    generated_output: dict[str, str],
    *,
    fs: ConverterFileSystem | None = None,
) -> ReportSetPaths:
    """Write the required review/apply report artifact set.

    Purpose:
        Emit the required Markdown report, JSON catalogs, and proposed-tree
        snapshot for one converter run.

    Args:
        run_options (RunOptions): Requested run options.
        mapping_records (tuple[MappingRecord, ...]): Planned mappings.
        topology_edges (tuple[TopologyEdge, ...]): Derived topology edges for
            Mermaid report rendering.
        translation_traces (tuple[TranslationTrace, ...]): Section-level
            translation traces for mixed-content report rendering.
        validation_findings (tuple[ValidationFinding, ...]): Validation results.
        generated_output (dict[str, str]): Generated output keyed by target path.
        fs (ConverterFileSystem | None): Filesystem adapter for writes.

    Returns:
        ReportSetPaths: Paths to the written report artifacts.

    Raises:
        OSError: Raised when an artifact cannot be written.

    Side Effects:
        Creates artifact directories and writes the report set through the
        configured filesystem adapter.
    """

    resolved_fs = fs or RealConverterFileSystem()
    artifact_root = run_options.artifact_root.resolve()
    proposed_tree_root = artifact_root / "proposed-tree"
    report_paths = ReportSetPaths(
        conversion_report=artifact_root / "conversion-report.md",
        mapping_catalog=artifact_root / "mapping-catalog.json",
        validation_results=artifact_root / "validation-results.json",
        proposed_tree_root=proposed_tree_root,
    )

    resolved_fs.mkdir(artifact_root)
    resolved_fs.mkdir(proposed_tree_root)

    mapping_catalog_payload = [
        mapping_record.to_json_dict()
        for mapping_record in sorted(
            mapping_records, key=lambda record: record.source_path
        )
    ]
    validation_results_payload = [
        validation_finding.to_json_dict()
        for validation_finding in sorted(
            validation_findings,
            key=lambda finding: (
                finding.code,
                finding.source_path or "",
                finding.target_path or "",
            ),
        )
    ]

    resolved_fs.write_text(
        report_paths.conversion_report,
        _render_conversion_report(
            run_options,
            mapping_records,
            topology_edges,
            translation_traces,
            validation_findings,
        ),
    )
    resolved_fs.write_text(
        report_paths.mapping_catalog,
        json.dumps(mapping_catalog_payload, indent=2, sort_keys=True) + "\n",
    )
    resolved_fs.write_text(
        report_paths.validation_results,
        json.dumps(validation_results_payload, indent=2, sort_keys=True) + "\n",
    )

    # Write the proposed tree in stable path order so review runs always emit a
    # deterministic snapshot of the generated content.
    for target_path in sorted(generated_output):
        resolved_fs.write_text(
            proposed_tree_root / target_path, generated_output[target_path]
        )

    return report_paths
