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

from dataclasses import dataclass
from pathlib import Path

from scripts.dev_tools.codex_native_converter.classifier import classify_source_artifact
from scripts.dev_tools.codex_native_converter.inventory import discover_source_artifacts
from scripts.dev_tools.codex_native_converter.mapping import plan_target_paths
from scripts.dev_tools.codex_native_converter.models import (
    MappingRecord,
    RunOptions,
    TargetRole,
    ValidationFinding,
)
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


def _render_target_content(
    run_options: RunOptions, mapping_record: MappingRecord
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
    rewritten_text, applied_rewrites = rewrite_supported_automation_reference(
        source_text
    )
    rewrite_summary = (
        "\n".join(f"- {description}" for description in applied_rewrites)
        if applied_rewrites
        else "- None"
    )

    if mapping_record.target_role is TargetRole.STANDING_GUIDANCE:
        return (
            f"# Converted standing guidance\n\n"
            f"Applied rewrites:\n{rewrite_summary}\n\n"
            f"{rewritten_text.rstrip()}\n"
        )

    if mapping_record.target_role is TargetRole.SHARED_SKILL:
        return (
            f"# Converted skill\n\n"
            f"Applied rewrites:\n{rewrite_summary}\n\n"
            f"{rewritten_text.rstrip()}\n"
        )

    if mapping_record.target_role is TargetRole.SUBAGENT:
        agent_name = Path(mapping_record.target_path or "agent.toml").stem
        return (
            f'name = "{agent_name}"\n'
            'description = "Converted subagent"\n'
            "developer_instructions = '''\n"
            f"Applied rewrites:\n{rewrite_summary}\n\n"
            f"{rewritten_text.rstrip()}\n"
            "'''\n"
        )

    if mapping_record.target_role is TargetRole.MCP_CONFIG:
        return (
            "# Review and merge native MCP, hook, and approval settings "
            "intentionally.\n\n"
            f"{rewritten_text.rstrip()}\n"
        )

    if mapping_record.target_role is TargetRole.HOOK:
        return (
            f"# Converted hook\n"
            "# Review the generated hook behavior before enabling it.\n\n"
            f"{rewritten_text.rstrip()}\n"
        )

    if mapping_record.target_role is TargetRole.APPROVAL_RULE:
        return (
            "# Converted approval rule candidate\n"
            "# Review the generated rule semantics before enforcement.\n\n"
            f"{rewritten_text.rstrip()}\n"
        )

    if mapping_record.target_role is TargetRole.LAUNCHER:
        return f"# Converted launcher prompt\n\n" f"{rewritten_text.rstrip()}\n"

    return rewritten_text


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

    # Render only records with concrete target paths because unsupported items
    # are still represented through validation findings and report rows.
    for mapping_record in mapping_records:
        if mapping_record.target_path is None:
            continue
        generated_output[mapping_record.target_path] = _render_target_content(
            run_options,
            mapping_record,
        )
    return generated_output


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
    generated_output = _render_generated_output(run_options, mapping_records)
    validation_findings = validate_conversion_plan(
        run_options,
        mapping_records,
        generated_output,
    )
    report_paths = write_conversion_report_set(
        run_options,
        mapping_records,
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
