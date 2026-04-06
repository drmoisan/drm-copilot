"""Publish scoped Copilot customizations into a destination workspace.

Purpose:
    Provide the stable public entry point for the repository's one-way
    customization publisher while delegating filesystem and rewrite concerns to
    smaller helper modules.
"""

from __future__ import annotations

import argparse
import json
from collections.abc import Callable
from dataclasses import asdict, dataclass
from datetime import datetime, timezone
from pathlib import Path
from typing import TypedDict

try:
    from scripts.dev_tools.agentic_sync import ROOT_FOLDERS
    from scripts.dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
        RealPushDownFileSystem,
    )
    from scripts.dev_tools.push_down_copilot_customizations_rewrites import (
        rewrite_text_references,
    )
except ModuleNotFoundError as error:
    if error.name is None or not error.name.startswith("scripts"):
        raise
    from dev_tools.agentic_sync import ROOT_FOLDERS
    from dev_tools.push_down_copilot_customizations_filesystem import (
        PushDownFileSystem,
        RealPushDownFileSystem,
    )
    from dev_tools.push_down_copilot_customizations_rewrites import (
        rewrite_text_references,
    )

ARTIFACT_DIRECTORY = "artifacts/copilot-customizations"
MODULE_ENTRY_POINT = "scripts.dev_tools.push_down_copilot_customizations"
RewriteFunction = Callable[[str], tuple[str, int, int, list[str]]]

__all__ = ["PushDownSummary", "main", "parse_args", "push_down_customizations"]


class PushDownSummaryPayload(TypedDict):
    """Describe the JSON artifact schema for a push-down run."""

    repo_root: str
    destination_root: str
    started_at: str
    finished_at: str
    created_count: int
    overwritten_count: int
    rewritten_reference_count: int
    placeholder_rewrite_count: int
    unmatched_references: list[str]
    files: list[dict[str, object]]


@dataclass(frozen=True, slots=True)
class PushDownFileResult:
    """
    Record the outcome for a copied file.

    Purpose:
        Capture created-versus-overwritten classification and rewrite details so
        the JSON artifact stays auditable.

    Usage:
        Appended to the run summary in source-file processing order.

    Attributes:
        relative_path (str): Destination-relative file path.
        destination_status (str): Either `created` or `overwritten`.
        rewritten_reference_count (int): Number of non-placeholder rewrites.
        placeholder_rewrite_count (int): Number of placeholder rewrites.
        unmatched_references (list[str]): Unknown references left untouched.
    """

    relative_path: str
    destination_status: str
    rewritten_reference_count: int
    placeholder_rewrite_count: int
    unmatched_references: list[str]


@dataclass(frozen=True, slots=True)
class PushDownSummary:
    """
    Summarize a push-down publication run.

    Purpose:
        Return stable counts and per-file outcomes to callers and to the JSON
        summary artifact writer.

    Usage:
        Returned by `push_down_customizations()` and printed by `main()`.

    Flow:
        Validation runs first, then file enumeration, rewrite/copy, artifact
        emission, and finally summary reporting.

    Invariants / Constraints:
        Timestamps are timezone-aware UTC datetimes.

    Side Effects:
        None as a data container; artifact writing happens separately.

    Attributes:
        repo_root (str): Source repository root.
        destination_root (str): Destination workspace root.
        started_at (datetime): UTC start timestamp.
        finished_at (datetime): UTC finish timestamp.
        created_count (int): Number of created destination files.
        overwritten_count (int): Number of overwritten destination files.
        rewritten_reference_count (int): Number of implemented-command rewrites.
        placeholder_rewrite_count (int): Number of placeholder rewrites.
        unmatched_references (list[str]): Ordered unmatched script references.
        files (list[PushDownFileResult]): Per-file outcomes.
        artifact_path (str): JSON artifact path written for the run.
    """

    repo_root: str
    destination_root: str
    started_at: datetime
    finished_at: datetime
    created_count: int
    overwritten_count: int
    rewritten_reference_count: int
    placeholder_rewrite_count: int
    unmatched_references: list[str]
    files: list[PushDownFileResult]
    artifact_path: str


def enumerate_source_files(
    repo_root: Path,
    fs: PushDownFileSystem,
    *,
    source_root: Path | None = None,
    root_folders: tuple[Path, ...] | None = None,
) -> list[Path]:
    """
    Enumerate scoped source files in deterministic root and path order.

    Purpose:
        Preserve the `ROOT_FOLDERS` ordering contract while keeping file-order
        stable within each scoped root.

    Args:
        repo_root (Path): Source repository root (used as default source root).
        fs (PushDownFileSystem): Filesystem adapter.
        source_root (Path | None): Explicit source root for packaged content.
            Defaults to ``repo_root`` when ``None``.

    Returns:
        list[Path]: Ordered source file paths.

    Raises:
        None.

    Side Effects:
        Reads directory metadata through ``fs``.
    """
    effective_source = source_root if source_root is not None else repo_root
    effective_roots = root_folders if root_folders is not None else ROOT_FOLDERS
    ordered_files: list[Path] = []
    # Enumerate by scoped root first so summaries match the feature contract.
    for root in effective_roots:
        root_path = effective_source / root
        root_files = fs.list_files(root_path)
        ordered_files.extend(
            sorted(root_files, key=lambda path: path.relative_to(root_path).as_posix())
        )
    return ordered_files


def validate_destination(
    destination_root: Path,
    repo_root: Path,
    fs: PushDownFileSystem,
) -> None:
    """
    Validate the destination before any copy action begins.

    Raises:
        ValueError: When the destination path is missing, equals the source repo,
            or is not a directory.
    """
    if not fs.is_dir(destination_root):
        raise ValueError(
            "Invalid destination: destination directory does not exist: "
            f"{destination_root}"
        )
    if destination_root.resolve() == repo_root.resolve():
        raise ValueError(
            "Invalid destination: destination must not be the source "
            f"repository root: {destination_root}"
        )


def build_artifact_path(
    repo_root: Path,
    started_at: datetime,
    *,
    artifact_root: Path | None = None,
    artifact_directory: str = ARTIFACT_DIRECTORY,
) -> Path:
    """
    Build the deterministic JSON summary artifact path for a push-down run.

    Purpose:
        Keep artifact naming stable and predictable for audits and automation.

    Args:
        repo_root (Path): Source repository root (used as default artifact root).
        started_at (datetime): UTC timestamp captured at run start.
        artifact_root (Path | None): Explicit artifact root for bundled execution.
            Defaults to ``repo_root`` when ``None``.

    Returns:
        Path: Artifact path beneath the configured artifact directory.

    Raises:
        None.

    Side Effects:
        None.
    """
    effective_root = artifact_root if artifact_root is not None else repo_root
    timestamp = started_at.strftime("%Y%m%dT%H%M%SZ")
    return effective_root / artifact_directory / f"push-down-{timestamp}.json"


def render_push_down_summary(summary: PushDownSummary) -> str:
    """
    Render the push-down summary artifact as deterministic JSON.

    Purpose:
        Serialize summary output in a stable form for auditing and regression
        tests.

    Args:
        summary (PushDownSummary): Completed push-down summary.

    Returns:
        str: Deterministic JSON payload.

    Raises:
        None.

    Side Effects:
        None.
    """
    payload: PushDownSummaryPayload = {
        "repo_root": summary.repo_root,
        "destination_root": summary.destination_root,
        "started_at": summary.started_at.isoformat(),
        "finished_at": summary.finished_at.isoformat(),
        "created_count": summary.created_count,
        "overwritten_count": summary.overwritten_count,
        "rewritten_reference_count": summary.rewritten_reference_count,
        "placeholder_rewrite_count": summary.placeholder_rewrite_count,
        "unmatched_references": summary.unmatched_references,
        "files": [asdict(result) for result in summary.files],
    }
    return json.dumps(payload, indent=2, sort_keys=True)


def write_summary_artifact(
    fs: PushDownFileSystem,
    repo_root: Path,
    summary: PushDownSummary,
    *,
    artifact_root: Path | None = None,
    artifact_directory: str = ARTIFACT_DIRECTORY,
) -> Path:
    """
    Write the JSON summary artifact under `artifacts/copilot-customizations`.

    Purpose:
        Persist the run summary in the canonical artifact location.

    Args:
        fs (PushDownFileSystem): Filesystem adapter used for writes.
        repo_root (Path): Source repository root.
        summary (PushDownSummary): Summary to serialize.
        artifact_root (Path | None): Explicit artifact root for bundled
            execution. Defaults to ``repo_root`` when ``None``.

    Returns:
        Path: Written artifact path.

    Raises:
        OSError: Propagated when artifact creation fails.

    Side Effects:
        Creates the artifact directory and writes JSON to disk.
    """
    artifact_path = build_artifact_path(
        repo_root,
        summary.started_at,
        artifact_root=artifact_root,
        artifact_directory=artifact_directory,
    )
    fs.ensure_dir(artifact_path.parent)
    fs.write_text(artifact_path, render_push_down_summary(summary))
    return artifact_path


def push_down_customizations(
    *,
    repo_root: Path,
    destination_root: Path,
    fs: PushDownFileSystem,
    source_root: Path | None = None,
    artifact_root: Path | None = None,
    root_folders: tuple[Path, ...] | None = None,
    artifact_directory: str = ARTIFACT_DIRECTORY,
    rewrite_references: RewriteFunction = rewrite_text_references,
) -> PushDownSummary:
    """
    Copy scoped customizations into the destination workspace.

    Purpose:
        Execute validation, deterministic enumeration, text rewriting,
        overwrite-aware writes, and summary artifact emission for the one-way
        customization publisher.
    """
    effective_source = source_root if source_root is not None else repo_root
    effective_artifact = artifact_root if artifact_root is not None else repo_root
    validate_destination(destination_root, repo_root, fs)
    started_at = datetime.now(timezone.utc)
    created_count = 0
    overwritten_count = 0
    rewritten_reference_count = 0
    placeholder_rewrite_count = 0
    unmatched_references: list[str] = []
    file_results: list[PushDownFileResult] = []

    # Process files in stable order so artifacts and test expectations are reproducible.
    for source_path in enumerate_source_files(
        repo_root,
        fs,
        source_root=effective_source,
        root_folders=root_folders,
    ):
        relative_path = source_path.relative_to(effective_source)
        destination_path = destination_root / relative_path
        destination_status = (
            "overwritten" if fs.is_file(destination_path) else "created"
        )
        if destination_status == "created":
            created_count += 1
        else:
            overwritten_count += 1

        source_text = fs.read_text(source_path)
        rewritten_text, rewritten_delta, placeholder_delta, unmatched = (
            rewrite_references(source_text)
        )
        rewritten_reference_count += rewritten_delta
        placeholder_rewrite_count += placeholder_delta
        for reference in unmatched:
            if reference not in unmatched_references:
                unmatched_references.append(reference)

        # Create the destination parent first so both write paths share one
        # deterministic directory-preparation step.
        fs.ensure_dir(destination_path.parent)
        fs.write_text(destination_path, rewritten_text)
        file_results.append(
            PushDownFileResult(
                relative_path=relative_path.as_posix(),
                destination_status=destination_status,
                rewritten_reference_count=rewritten_delta,
                placeholder_rewrite_count=placeholder_delta,
                unmatched_references=unmatched,
            )
        )

    finished_at = datetime.now(timezone.utc)
    provisional_summary = PushDownSummary(
        repo_root=repo_root.as_posix(),
        destination_root=destination_root.as_posix(),
        started_at=started_at,
        finished_at=finished_at,
        created_count=created_count,
        overwritten_count=overwritten_count,
        rewritten_reference_count=rewritten_reference_count,
        placeholder_rewrite_count=placeholder_rewrite_count,
        unmatched_references=unmatched_references,
        files=file_results,
        artifact_path="",
    )
    artifact_path = write_summary_artifact(
        fs,
        repo_root,
        provisional_summary,
        artifact_root=effective_artifact,
        artifact_directory=artifact_directory,
    )
    return PushDownSummary(
        repo_root=provisional_summary.repo_root,
        destination_root=provisional_summary.destination_root,
        started_at=provisional_summary.started_at,
        finished_at=provisional_summary.finished_at,
        created_count=provisional_summary.created_count,
        overwritten_count=provisional_summary.overwritten_count,
        rewritten_reference_count=provisional_summary.rewritten_reference_count,
        placeholder_rewrite_count=provisional_summary.placeholder_rewrite_count,
        unmatched_references=provisional_summary.unmatched_references,
        files=provisional_summary.files,
        artifact_path=artifact_path.as_posix(),
    )


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    """
    Parse CLI arguments for the push-down publisher.

    Purpose:
        Define the stable CLI contract for callers using the module entry point.

    Args:
        argv (list[str] | None): Optional argument list for tests or embedding.

    Returns:
        argparse.Namespace: Parsed command-line arguments.

    Raises:
        SystemExit: Raised by `argparse` when arguments are invalid.

    Side Effects:
        Emits usage/help text through `argparse` when parsing fails.
    """
    parser = argparse.ArgumentParser(
        description=(
            "Publish scoped Copilot customizations with "
            f"python -m {MODULE_ENTRY_POINT}."
        )
    )
    parser.add_argument(
        "--destination",
        required=True,
        help="Destination workspace root that will receive the copied .github trees.",
    )
    return parser.parse_args(argv)


def main(
    argv: list[str] | None = None,
    *,
    repo_root: Path | None = None,
    fs: PushDownFileSystem | None = None,
) -> int:
    """
    Run the push-down publisher CLI.

    Purpose:
        Parse arguments, resolve defaults, execute the publisher, and print the
        JSON summary artifact path on success.
    """
    args = parse_args(argv)
    resolved_repo_root = (repo_root or Path.cwd()).expanduser().resolve()
    resolved_destination = Path(args.destination).expanduser().resolve()
    resolved_fs = fs or RealPushDownFileSystem()
    summary = push_down_customizations(
        repo_root=resolved_repo_root,
        destination_root=resolved_destination,
        fs=resolved_fs,
        source_root=resolved_repo_root,
        artifact_root=resolved_repo_root,
    )
    print(f"Wrote push-down summary artifact to: {summary.artifact_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
