"""Validate planned conversions for the Codex-native converter.

Purpose:
    Enforce the converter's fail-closed rules before apply mode writes native
    output into a destination workspace.

Usage:
    The converter engine calls ``validate_conversion_plan`` after mapping and
    rewrite application and before report emission decides whether apply mode may
    proceed.

Flow:
    Validation checks required inputs first, then inspects mapping records for
    unsupported or unresolved states, then inspects generated output for
    duplicate targets and lingering runtime references.

Invariants / Constraints:
    Blocking failures are reported explicitly with stable codes so review and
    apply mode share one auditable validation contract.

Side Effects:
    None.
"""

from __future__ import annotations

from collections import Counter

from scripts.dev_tools.codex_native_converter.models import (
    ConversionClass,
    MappingRecord,
    PlannedEmission,
    RunOptions,
    TargetRole,
    ValidationFinding,
)
from scripts.dev_tools.codex_native_converter.rewrites import (
    detect_unresolved_runtime_reference,
)

_NOTE_FLAG_TO_FINDING: tuple[tuple[str, str, str], ...] = (
    (
        "requires-native-hard-gate",
        "unresolved-hard-gate-mapping",
        "Source artifact requires a native hard-gate mapping that is not yet resolved.",
    ),
    (
        "requires-handoff-review",
        "unresolved-handoff-mapping",
        "Source artifact requires handoff or delegation behavior that is not "
        "yet resolved.",
    ),
    (
        "requires-mcp-rewrite",
        "unresolved-mcp-rewrite",
        "Source artifact requires a semantic MCP rewrite that is not yet resolved.",
    ),
    (
        "malformed-source-artifact",
        "malformed-source-artifact",
        "Source artifact metadata or content is malformed for v1 conversion.",
    ),
)


def _build_finding(
    *,
    code: str,
    blocking: bool,
    source_path: str | None,
    target_path: str | None,
    message: str,
    recommended_action: str,
) -> ValidationFinding:
    """Build a validation finding with consistent severity values.

    Purpose:
        Keep finding construction consistent across all validation branches.

    Args:
        code (str): Stable machine-readable validation code.
        blocking (bool): Whether the finding must stop apply mode.
        source_path (str | None): Source-relative path associated with the
            finding.
        target_path (str | None): Target-relative path associated with the
            finding.
        message (str): Human-readable explanation.
        recommended_action (str): Human-readable remediation guidance.

    Returns:
        ValidationFinding: The normalized validation finding.

    Raises:
        None.

    Side Effects:
        None.
    """

    return ValidationFinding(
        code=code,
        severity="error" if blocking else "warning",
        blocking=blocking,
        source_path=source_path,
        target_path=target_path,
        message=message,
        recommended_action=recommended_action,
    )


def _validate_required_inputs(run_options: RunOptions) -> list[ValidationFinding]:
    """Validate run options that gate review and apply execution.

    Purpose:
        Fail early when the caller omitted required inputs.

    Args:
        run_options (RunOptions): Requested converter run options.

    Returns:
        list[ValidationFinding]: Findings for missing required inputs.

    Raises:
        None.

    Side Effects:
        None.
    """

    findings: list[ValidationFinding] = []
    if run_options.mode == "apply" and run_options.destination_root is None:
        findings.append(
            _build_finding(
                code="missing-required-input",
                blocking=True,
                source_path=None,
                target_path=None,
                message="Apply mode requires an explicit destination root.",
                recommended_action=(
                    "Provide destination_root before running apply mode."
                ),
            )
        )
    return findings


def _validate_mapping_records(
    mapping_records: tuple[MappingRecord, ...],
) -> list[ValidationFinding]:
    """Validate classified and mapped records for unsupported or flagged states.

    Purpose:
        Convert unsupported or unresolved record states into explicit findings.

    Args:
        mapping_records (tuple[MappingRecord, ...]): Planned mappings for the
            current run.

    Returns:
        list[ValidationFinding]: Findings derived from mapping records.

    Raises:
        None.

    Side Effects:
        None.
    """

    findings: list[ValidationFinding] = []

    for mapping_record in mapping_records:
        if (
            mapping_record.conversion_class is ConversionClass.UNSUPPORTED
            or mapping_record.target_role is TargetRole.UNSUPPORTED
        ) and mapping_record.is_required:
            findings.append(
                _build_finding(
                    code="unsupported-ecosystem",
                    blocking=True,
                    source_path=mapping_record.source_path,
                    target_path=mapping_record.target_path,
                    message="Required source artifact has no safe v1 mapping.",
                    recommended_action=(
                        "Review the artifact manually or add a verified "
                        "native mapping before apply mode."
                    ),
                )
            )

        for note in mapping_record.notes:
            for note_flag, finding_code, finding_message in _NOTE_FLAG_TO_FINDING:
                if note_flag in note:
                    findings.append(
                        _build_finding(
                            code=finding_code,
                            blocking=True,
                            source_path=mapping_record.source_path,
                            target_path=mapping_record.target_path,
                            message=finding_message,
                            recommended_action=(
                                "Resolve the flagged mapping or leave the "
                                "artifact in review-only status."
                            ),
                        )
                    )

    return findings


def _validate_duplicate_targets(
    mapping_records: tuple[MappingRecord, ...],
    planned_emissions: tuple[PlannedEmission, ...],
) -> list[ValidationFinding]:
    """Validate that planned target paths are unique.

    Purpose:
        Prevent ambiguous or silently overwritten target outputs.

    Args:
        mapping_records (tuple[MappingRecord, ...]): Planned mappings for the
            current run.
        planned_emissions (tuple[PlannedEmission, ...]): Section-level planned
            emissions that may also claim target paths.

    Returns:
        list[ValidationFinding]: Findings for duplicate target paths.

    Raises:
        None.

    Side Effects:
        None.
    """

    findings: list[ValidationFinding] = []
    mapping_records_by_target: dict[str, list[MappingRecord]] = {}
    section_emissions_by_target: dict[str, list[PlannedEmission]] = {}

    for mapping_record in mapping_records:
        if mapping_record.target_path is None:
            continue
        mapping_records_by_target.setdefault(mapping_record.target_path, []).append(
            mapping_record
        )
    for planned_emission in planned_emissions:
        if planned_emission.target_path is None:
            continue
        section_emissions_by_target.setdefault(planned_emission.target_path, []).append(
            planned_emission
        )

    target_counter = Counter(
        mapping_record.target_path
        for mapping_record in mapping_records
        if mapping_record.target_path is not None
    )
    duplicated_targets = {
        target_path for target_path, count in target_counter.items() if count > 1
    }
    duplicated_targets -= {
        target_path
        for target_path, records in mapping_records_by_target.items()
        if target_path == "AGENTS.md"
        and all(
            record.target_role is TargetRole.STANDING_GUIDANCE for record in records
        )
    }

    # Report every record that participates in a duplicate target collision so
    # the caller can trace all conflicting sources.
    for mapping_record in mapping_records:
        if mapping_record.target_path in duplicated_targets:
            findings.append(
                _build_finding(
                    code="duplicate-target-path",
                    blocking=True,
                    source_path=mapping_record.source_path,
                    target_path=mapping_record.target_path,
                    message=(
                        "Multiple source artifacts resolve to the same target " "path."
                    ),
                    recommended_action=(
                        "Refine the mapping plan so each target path has "
                        "exactly one authoritative source."
                    ),
                )
            )

    conflicting_targets = {
        target_path
        for target_path, section_emissions in section_emissions_by_target.items()
        if (
            target_path in mapping_records_by_target
            or len(
                {
                    (planned_emission.source_path, planned_emission.target_role)
                    for planned_emission in section_emissions
                }
            )
            > 1
        )
    }

    for target_path in sorted(conflicting_targets):
        for planned_emission in section_emissions_by_target[target_path]:
            findings.append(
                _build_finding(
                    code="duplicate-target-path",
                    blocking=True,
                    source_path=planned_emission.source_path,
                    target_path=target_path,
                    message=(
                        "Multiple planned emissions resolve to the same target path."
                    ),
                    recommended_action=(
                        "Refine the section-level mapping plan so each target path has "
                        "exactly one authoritative emission group."
                    ),
                )
            )
    return findings


def _validate_generated_output(
    generated_output: dict[str, str],
) -> list[ValidationFinding]:
    """Validate generated output text for lingering runtime references.

    Purpose:
        Ensure emitted native Codex outputs do not retain unresolved source
        runtime references.

    Args:
        generated_output (dict[str, str]): Generated output keyed by target path.

    Returns:
        list[ValidationFinding]: Findings for lingering runtime references.

    Raises:
        None.

    Side Effects:
        None.
    """

    findings: list[ValidationFinding] = []

    # Scan every generated target body after rewrites so apply mode fails closed
    # when native outputs still mention source-runtime surfaces.
    for target_path, rendered_text in generated_output.items():
        unresolved_references = detect_unresolved_runtime_reference(rendered_text)
        if unresolved_references:
            findings.append(
                _build_finding(
                    code="lingering-source-runtime-reference",
                    blocking=True,
                    source_path=None,
                    target_path=target_path,
                    message=(
                        "Generated output retains unresolved source-runtime "
                        "references: " + ", ".join(unresolved_references)
                    ),
                    recommended_action=(
                        "Add a verified rewrite or adjust the generated "
                        "content before apply mode."
                    ),
                )
            )

    return findings


def validate_conversion_plan(
    run_options: RunOptions,
    mapping_records: tuple[MappingRecord, ...],
    planned_emissions: tuple[PlannedEmission, ...],
    generated_output: dict[str, str],
) -> tuple[ValidationFinding, ...]:
    """Validate one planned conversion run.

    Purpose:
        Apply the converter's full fail-closed validation contract to the mapped
        artifacts and generated output for one run.

    Args:
        run_options (RunOptions): Requested converter run options.
        mapping_records (tuple[MappingRecord, ...]): Planned mappings for the
            current run.
        planned_emissions (tuple[PlannedEmission, ...]): Section-level planned
            emissions for the current run.
        generated_output (dict[str, str]): Generated output keyed by target path.

    Returns:
        tuple[ValidationFinding, ...]: Validation findings sorted by stable key.

    Raises:
        None.

    Side Effects:
        None.
    """

    findings: list[ValidationFinding] = []
    findings.extend(_validate_required_inputs(run_options))
    findings.extend(_validate_mapping_records(mapping_records))
    findings.extend(_validate_duplicate_targets(mapping_records, planned_emissions))
    findings.extend(_validate_generated_output(generated_output))

    return tuple(
        sorted(
            findings,
            key=lambda finding: (
                finding.code,
                finding.source_path or "",
                finding.target_path or "",
            ),
        )
    )
