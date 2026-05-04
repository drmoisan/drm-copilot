"""Expose the Typer CLI for the Codex-native converter.

Purpose:
    Provide the authoritative review/apply command surface for the converter so
    repository users and the extension wrapper invoke the same Python engine.

Usage:
    Run ``python -m scripts.dev_tools.codex_native_converter review`` or
    ``apply`` with the required source and output options.

Flow:
    Each command validates input, builds ``RunOptions``, runs the engine, then
    prints the artifact root and validation outcome to stdout.

Invariants / Constraints:
    The Python CLI is the authoritative converter surface. Apply mode must not
    proceed without an explicit destination root.

Side Effects:
    Runs the converter engine, which reads source files and writes report
    artifacts and, in valid apply runs, destination files.
"""

from __future__ import annotations

from pathlib import Path  # noqa: TCH003 - Path required at runtime for Typer CLI types

import typer

from scripts.dev_tools.codex_native_converter.engine import (
    ConversionRunResult,
    run_apply_mode,
    run_review_mode,
)
from scripts.dev_tools.codex_native_converter.models import RunOptions, SourceEcosystem

app = typer.Typer(help="Convert supported source runtimes into Codex-native assets.")

SOURCE_ROOT_OPTION = typer.Option(..., help="Source runtime root.")
SOURCE_ECOSYSTEM_OPTION = typer.Option(
    ..., help="Source ecosystem: github-copilot or claude."
)
DESTINATION_ROOT_OPTION = typer.Option(None, help="Destination root for native output.")
SELECTED_PATH_OPTION = typer.Option(
    [],
    "--selected-path",
    help="Optional source-root-relative path filter.",
)
ARTIFACT_ROOT_OPTION = typer.Option(None, help="Optional artifact output root.")
ENABLE_REPO_PROMPTS_OPTION = typer.Option(
    False, help="Enable repository-convention .codex/prompts output."
)
EMIT_INTERMEDIATE_STATE_OPTION = typer.Option(
    False,
    "--emit-intermediate-state",
    help="Write compiler-like intermediate state JSON artifacts.",
)


def _resolve_source_ecosystem(source_ecosystem: str) -> SourceEcosystem:
    """Resolve one CLI source ecosystem string into the typed enum.

    Purpose:
        Convert a CLI string value into the shared ecosystem enum with a clear
        error message when the value is unsupported.

    Args:
        source_ecosystem (str): CLI-provided source ecosystem value.

    Returns:
        SourceEcosystem: Resolved ecosystem enum.

    Raises:
        typer.BadParameter: Raised when the ecosystem value is unsupported.

    Side Effects:
        None.
    """

    try:
        return SourceEcosystem(source_ecosystem)
    except ValueError as error:
        raise typer.BadParameter(
            "source_ecosystem must be 'github-copilot' or 'claude'."
        ) from error


def _resolve_run_options(
    *,
    mode: str,
    source_root: Path,
    source_ecosystem: str,
    selected_paths: list[Path],
    destination_root: Path | None,
    artifact_root: Path | None,
    enable_repo_prompts: bool,
    emit_intermediate_state: bool,
) -> RunOptions:
    """Validate CLI input and build one run-options value object.

    Purpose:
        Centralize review/apply option validation so both commands share one
        authoritative input contract.

    Args:
        mode (str): Requested CLI mode.
        source_root (Path): Source tree root supplied by the caller.
        source_ecosystem (str): CLI ecosystem string.
        selected_paths (list[Path]): Optional selected paths beneath the source
            root.
        destination_root (Path | None): Optional destination root.
        artifact_root (Path | None): Optional artifact root.
        enable_repo_prompts (bool): Whether prompt output is enabled.
        emit_intermediate_state (bool): Whether intermediate-state artifacts
            should be written.

    Returns:
        RunOptions: Validated run options for the engine.

    Raises:
        typer.BadParameter: Raised when a required input is missing or invalid.

    Side Effects:
        None.
    """

    resolved_source_root = source_root.resolve()
    if not resolved_source_root.exists() or not resolved_source_root.is_dir():
        raise typer.BadParameter("source_root must point to an existing directory.")

    if mode == "apply" and destination_root is None:
        raise typer.BadParameter("apply mode requires --destination-root.")

    resolved_destination_root = destination_root.resolve() if destination_root else None
    resolved_artifact_root = (
        artifact_root.resolve()
        if artifact_root is not None
        else (resolved_source_root / "artifacts" / "codex-native-converter")
    )

    return RunOptions(
        mode=mode,
        source_root=resolved_source_root,
        source_ecosystem=_resolve_source_ecosystem(source_ecosystem),
        selected_paths=tuple(selected_paths),
        destination_root=resolved_destination_root,
        artifact_root=resolved_artifact_root,
        enable_repo_prompts=enable_repo_prompts,
        emit_intermediate_state=emit_intermediate_state,
    )


def _print_run_summary(result: ConversionRunResult) -> None:
    """Print the required CLI summary lines for one converter run.

    Purpose:
        Provide a concise CLI outcome summary that wrappers can also parse.

    Args:
        result (ConversionRunResult): Completed review or apply result.

    Returns:
        None: This method returns no value.

    Raises:
        None.

    Side Effects:
        Writes summary lines to stdout.
    """

    blocking_findings = sum(
        1 for finding in result.validation_findings if finding.blocking
    )
    typer.echo(
        f"Artifact root: {result.report_paths.conversion_report.parent.as_posix()}"
    )
    typer.echo(
        "Validation outcome: "
        + (
            "pass"
            if blocking_findings == 0
            else f"fail ({blocking_findings} blocking findings)"
        )
    )


@app.command()
def review(
    source_root: Path = SOURCE_ROOT_OPTION,
    source_ecosystem: str = SOURCE_ECOSYSTEM_OPTION,
    selected_path: list[Path] = SELECTED_PATH_OPTION,
    artifact_root: Path | None = ARTIFACT_ROOT_OPTION,
    enable_repo_prompts: bool = ENABLE_REPO_PROMPTS_OPTION,
    emit_intermediate_state: bool = EMIT_INTERMEDIATE_STATE_OPTION,
) -> None:
    """Run the converter in non-mutating review mode.

    Purpose:
        Generate the full review artifact set without writing destination files.

    Args:
        source_root (Path): Source runtime root.
        source_ecosystem (str): Declared source ecosystem string.
        selected_path (list[Path]): Optional selected source paths.
        artifact_root (Path | None): Optional artifact output root.
        enable_repo_prompts (bool): Whether repository prompt output is enabled.
        emit_intermediate_state (bool): Whether intermediate-state artifacts
            should be written.

    Returns:
        None: This command writes stdout summary lines.

    Raises:
        typer.BadParameter: Raised when required inputs are invalid.

    Side Effects:
        Writes report artifacts under the resolved artifact root.
    """

    run_options = _resolve_run_options(
        mode="review",
        source_root=source_root,
        source_ecosystem=source_ecosystem,
        selected_paths=selected_path,
        destination_root=None,
        artifact_root=artifact_root,
        enable_repo_prompts=enable_repo_prompts,
        emit_intermediate_state=emit_intermediate_state,
    )
    result = run_review_mode(run_options)
    _print_run_summary(result)


@app.command()
def apply(
    source_root: Path = SOURCE_ROOT_OPTION,
    source_ecosystem: str = SOURCE_ECOSYSTEM_OPTION,
    destination_root: Path | None = DESTINATION_ROOT_OPTION,
    selected_path: list[Path] = SELECTED_PATH_OPTION,
    artifact_root: Path | None = ARTIFACT_ROOT_OPTION,
    enable_repo_prompts: bool = ENABLE_REPO_PROMPTS_OPTION,
    emit_intermediate_state: bool = EMIT_INTERMEDIATE_STATE_OPTION,
) -> None:
    """Run the converter in mutating apply mode.

    Purpose:
        Generate the review artifact set and write destination files only when
        validation leaves no blocking findings.

    Args:
        source_root (Path): Source runtime root.
        source_ecosystem (str): Declared source ecosystem string.
        destination_root (Path | None): Destination root for native output.
        selected_path (list[Path]): Optional selected source paths.
        artifact_root (Path | None): Optional artifact output root.
        enable_repo_prompts (bool): Whether repository prompt output is enabled.
        emit_intermediate_state (bool): Whether intermediate-state artifacts
            should be written.

    Returns:
        None: This command writes stdout summary lines.

    Raises:
        typer.BadParameter: Raised when required inputs are invalid.

    Side Effects:
        Writes report artifacts and, when validation passes, destination output.
    """

    run_options = _resolve_run_options(
        mode="apply",
        source_root=source_root,
        source_ecosystem=source_ecosystem,
        selected_paths=selected_path,
        destination_root=destination_root,
        artifact_root=artifact_root,
        enable_repo_prompts=enable_repo_prompts,
        emit_intermediate_state=emit_intermediate_state,
    )
    result = run_apply_mode(run_options)
    _print_run_summary(result)
    if not result.wrote_destination and any(
        finding.blocking for finding in result.validation_findings
    ):
        raise typer.Exit(1)


def main() -> None:
    """Run the Typer application.

    Purpose:
        Provide the console-script entry point for the authoritative Python CLI.

    Args:
        None.

    Returns:
        None: Control is transferred to Typer.

    Raises:
        None.

    Side Effects:
        Executes the requested CLI command.
    """

    app()
