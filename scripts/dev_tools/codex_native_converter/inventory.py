"""Discover and normalize source artifacts for the Codex-native converter.

Purpose:
    Provide deterministic source-file enumeration for supported ecosystems while
    preventing caller-selected paths from escaping the declared source root.

Usage:
    The converter engine calls ``normalize_selected_paths`` first when the user
    provides an explicit subset, then calls ``discover_source_artifacts`` to
    collect the final artifact list.

Flow:
    Supported top-level source surfaces are selected by ecosystem, candidate
    files are enumerated beneath those surfaces, and the result is sorted by
    normalized relative path.

Invariants / Constraints:
    All returned paths are source-root-relative ``Path`` values using a stable
    path ordering that is independent of host operating system traversal order.

Side Effects:
    Reads the filesystem metadata under the declared source root.
"""

from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from scripts.dev_tools.codex_native_converter.models import SourceEcosystem

if TYPE_CHECKING:
    from collections.abc import Iterable

_SUPPORTED_ROOTS: dict[SourceEcosystem, tuple[Path, ...]] = {
    SourceEcosystem.GITHUB_COPILOT: (
        Path(".github/copilot-instructions.md"),
        Path(".github/instructions"),
        Path(".github/skills"),
        Path(".github/agents"),
        Path(".github/prompts"),
    ),
    SourceEcosystem.CLAUDE: (
        Path("CLAUDE.md"),
        Path(".claude/skills"),
        Path(".claude/agents"),
        Path(".claude/hooks"),
        Path(".claude/settings.json"),
        Path(".claude/rules"),
    ),
}


def _normalize_relative_path(source_root: Path, candidate_path: Path) -> Path:
    """Normalize one candidate path relative to the declared source root.

    Purpose:
        Convert an absolute or relative caller-provided path into a validated
        source-root-relative path.

    Args:
        source_root (Path): Absolute or relative root that bounds the converter
            input set.
        candidate_path (Path): Caller-provided source path to validate.

    Returns:
        Path: A normalized relative path beneath ``source_root``.

    Raises:
        ValueError: Raised when the candidate path escapes the declared source
            root.

    Side Effects:
        Resolves filesystem paths to normalize parent-segment references.
    """

    resolved_root = source_root.resolve()
    resolved_candidate = (
        candidate_path.resolve()
        if candidate_path.is_absolute()
        else (resolved_root / candidate_path).resolve()
    )
    try:
        return resolved_candidate.relative_to(resolved_root)
    except ValueError as error:
        raise ValueError(
            f"Selected path escapes the declared source root: {candidate_path}"
        ) from error


def normalize_selected_paths(
    source_root: Path,
    selected_paths: Iterable[Path],
) -> tuple[Path, ...]:
    """Normalize selected source paths beneath the declared source root.

    Purpose:
        Validate user-selected paths and return them in deterministic normalized
        relative-path order.

    Args:
        source_root (Path): Root directory that bounds valid source input.
        selected_paths (Iterable[Path]): Caller-selected paths beneath the root.

    Returns:
        tuple[Path, ...]: Unique normalized relative paths sorted by POSIX text.

    Raises:
        ValueError: Raised when any selected path escapes the declared source
            root.

    Side Effects:
        Resolves filesystem paths while validating the selected paths.
    """

    normalized_paths = {
        _normalize_relative_path(source_root, candidate_path)
        for candidate_path in selected_paths
    }
    return tuple(sorted(normalized_paths, key=lambda path: path.as_posix()))


def _iter_supported_artifacts(
    source_root: Path,
    source_ecosystem: SourceEcosystem,
) -> tuple[Path, ...]:
    """Yield supported artifacts for one source ecosystem.

    Purpose:
        Enumerate existing supported files below the configured ecosystem roots.

    Args:
        source_root (Path): Source tree root to scan.
        source_ecosystem (SourceEcosystem): Ecosystem that defines supported
            surfaces.

    Returns:
        tuple[Path, ...]: Unique supported relative file paths beneath the
            source root.

    Raises:
        None.

    Side Effects:
        Reads directory contents below the supported roots.
    """

    discovered_paths: set[Path] = set()
    resolved_root = source_root.resolve()

    # Enumerate only the supported ecosystem surfaces so classification starts
    # from the approved v1 input set.
    for supported_root in _SUPPORTED_ROOTS[source_ecosystem]:
        absolute_supported_root = (resolved_root / supported_root).resolve()
        if not absolute_supported_root.exists():
            continue
        if absolute_supported_root.is_file():
            discovered_paths.add(absolute_supported_root.relative_to(resolved_root))
            continue

        # Walk supported directories recursively while preserving files only.
        for candidate_path in absolute_supported_root.rglob("*"):
            if candidate_path.is_file():
                discovered_paths.add(candidate_path.relative_to(resolved_root))

    return tuple(sorted(discovered_paths, key=lambda path: path.as_posix()))


def discover_source_artifacts(
    source_root: Path,
    source_ecosystem: SourceEcosystem,
    selected_paths: Iterable[Path] | None = None,
) -> tuple[Path, ...]:
    """Discover source artifacts in deterministic normalized-relative-path order.

    Purpose:
        Produce the set of source files that the converter should classify for a
        given run.

    Args:
        source_root (Path): Root directory of the source ecosystem tree.
        source_ecosystem (SourceEcosystem): Declared source ecosystem.
        selected_paths (Iterable[Path] | None): Optional caller-selected subset
            of files or directories beneath the source root.

    Returns:
        tuple[Path, ...]: Supported source artifact paths relative to the source
            root, sorted by POSIX path text.

    Raises:
        ValueError: Raised when selected paths escape the source root.

    Side Effects:
        Reads directory contents beneath the source root.
    """

    all_artifacts = _iter_supported_artifacts(source_root, source_ecosystem)
    if selected_paths is None:
        return all_artifacts

    normalized_selected_paths = normalize_selected_paths(source_root, selected_paths)
    if not normalized_selected_paths:
        return all_artifacts

    selected_set = set(normalized_selected_paths)
    matched_artifacts: list[Path] = []

    # Include files selected directly and files contained beneath selected
    # directories so the caller can target either shape deterministically.
    for artifact_path in all_artifacts:
        if artifact_path in selected_set:
            matched_artifacts.append(artifact_path)
            continue
        if any(parent in artifact_path.parents for parent in selected_set):
            matched_artifacts.append(artifact_path)

    return tuple(sorted(matched_artifacts, key=lambda path: path.as_posix()))
