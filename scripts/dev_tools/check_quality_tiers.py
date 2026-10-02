"""Validate the root ``quality-tiers.yml`` against the projects git tracks.

Purpose:
    CLI and I/O boundary for the tier-classification check. It reads the
    manifest file, lists the tracked files with ``git ls-files -z``, and hands
    both to the pure core in ``scripts.dev_tools.quality_tiers_contract``.

Usage:
    poetry run python -m scripts.dev_tools.check_quality_tiers
        [--file quality-tiers.yml] [--repo-root .]

Exit codes:
    0 the manifest is valid and classifies every discovered project.
    1 any QT error; each error is written to stderr as ``QTnnn: <message>``.
    2 argparse usage error.

Failure codes produced here:
    QT001 the manifest is missing or unreadable.
    QT009 ``git ls-files`` is unavailable or failed (fail closed).
"""

from __future__ import annotations

import argparse
import shutil
import subprocess
import sys
from pathlib import Path
from typing import TYPE_CHECKING, Protocol

from scripts.dev_tools.quality_tiers_contract import (
    QualityTierError,
    discover_projects,
    find_classification_errors,
    find_entry_errors,
    parse_quality_tiers,
)

if TYPE_CHECKING:
    from collections.abc import Callable, Sequence

DEFAULT_MANIFEST_FILE = "quality-tiers.yml"
DEFAULT_REPO_ROOT = "."


class GitRunResult(Protocol):
    """The subset of a completed git process that the lister reads."""

    @property
    def returncode(self) -> int:
        """Process exit code."""
        ...

    @property
    def stdout(self) -> bytes:
        """Captured standard output."""
        ...


def read_manifest_text(path: Path) -> str:
    """Return the UTF-8 text of the manifest at ``path``.

    Raises:
        OSError: When the file is missing or unreadable.
    """
    return path.read_text(encoding="utf-8")


def list_tracked_files(
    repo_root: Path,
    *,
    which: Callable[[str], str | None] = shutil.which,
    run: Callable[..., GitRunResult] | None = None,
) -> list[str]:
    """Return the repository-relative paths that git tracks under ``repo_root``.

    Args:
        repo_root: Folder in which ``git ls-files -z`` runs.
        which: Resolver for the git executable; defaults to ``shutil.which``.
        run: Process runner; defaults to ``subprocess.run``.

    Raises:
        FileNotFoundError: When ``which`` cannot resolve git.
        OSError: When git exits with a non-zero code.
    """
    git = which("git")
    if git is None:
        raise FileNotFoundError("git executable not found on PATH")
    runner = subprocess.run if run is None else run
    result = runner(  # noqa: S603 - static analysis can't verify runtime validation
        [git, "ls-files", "-z"], cwd=repo_root, capture_output=True, check=False
    )
    if result.returncode != 0:
        raise OSError(f"git ls-files exited with code {result.returncode}")
    output = result.stdout.decode("utf-8", errors="surrogateescape")
    return [path for path in output.split("\0") if path]


def _report(errors: Sequence[QualityTierError]) -> None:
    """Write each error to stderr on its own line in the rendered QT form."""
    for error in errors:
        print(error.render(), file=sys.stderr)


def _build_parser() -> argparse.ArgumentParser:
    """Return the argument parser for the CLI."""
    parser = argparse.ArgumentParser(
        prog="check_quality_tiers",
        description="Validate quality-tiers.yml against the tracked projects.",
    )
    parser.add_argument(
        "--file",
        default=DEFAULT_MANIFEST_FILE,
        help="Manifest path; a relative path is resolved against --repo-root.",
    )
    parser.add_argument(
        "--repo-root",
        default=DEFAULT_REPO_ROOT,
        help="Repository root in which git lists tracked files.",
    )
    return parser


def main(
    argv: Sequence[str] | None = None,
    *,
    read_manifest_text: Callable[[Path], str] = read_manifest_text,
    list_tracked_files: Callable[[Path], Sequence[str]] = list_tracked_files,
) -> int:
    """Run the tier-classification check and return the process exit code.

    Args:
        argv: Command-line arguments; ``None`` reads ``sys.argv``.
        read_manifest_text: Reader for the manifest file.
        list_tracked_files: Lister for the tracked repository paths.

    Returns:
        0 when valid, 1 when any QT error was reported.

    Raises:
        SystemExit: With code 2 for an argparse usage error.
    """
    arguments = _build_parser().parse_args(argv)
    repo_root = Path(str(arguments.repo_root))
    manifest_path = Path(str(arguments.file))
    if not manifest_path.is_absolute():
        manifest_path = repo_root / manifest_path

    try:
        text = read_manifest_text(manifest_path)
    except OSError as error:
        _report(
            [
                QualityTierError(
                    code="QT001",
                    message=f"cannot read '{manifest_path.as_posix()}': {error}",
                    path=manifest_path.as_posix(),
                )
            ]
        )
        return 1

    manifest, errors = parse_quality_tiers(text)
    if manifest is None:
        _report(errors)
        return 1

    try:
        tracked = list_tracked_files(repo_root)
    except OSError as error:
        errors.extend(find_entry_errors(manifest))
        errors.append(
            QualityTierError(
                code="QT009", message=f"cannot list tracked files: {error}"
            )
        )
        _report(errors)
        return 1

    projects = discover_projects(tracked)
    errors.extend(find_classification_errors(manifest, projects))
    if errors:
        _report(errors)
        return 1
    print(
        f"quality-tiers: OK ({len(manifest.entries)} entries, "
        f"{len(projects)} discovered projects)"
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
