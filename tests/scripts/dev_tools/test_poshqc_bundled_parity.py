"""Regression tests for repo-root versus bundled PoshQC module parity."""

from __future__ import annotations

from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[3]

POSHQC_PARITY_PATHS = (
    "scripts/powershell/PoshQC/PoshQC.psm1",
    "scripts/powershell/PoshQC/PoshQC.FileDiscovery.psm1",
    "scripts/powershell/PoshQC/PoshQC.Analyzer.psm1",
    "scripts/powershell/PoshQC/PoshQC.Testing.psm1",
)


def read_repo_text(relative_path: str) -> str:
    """Return UTF-8 repository text for a repo-root PoshQC contract file.

    Args:
        relative_path: Repository-relative source path under the repo root.

    Returns:
        The UTF-8 text content for the requested repo-root file.

    Raises:
        FileNotFoundError: If the requested file is missing.

    Side Effects:
        Reads a checked-in repository file from disk.
    """

    return (REPO_ROOT / relative_path).read_text(encoding="utf-8")


def read_bundle_text(relative_path: str) -> str:
    """Return UTF-8 repository text for the bundled PoshQC mirror file.

    Args:
        relative_path: Repository-relative repo-root source path.

    Returns:
        The UTF-8 text content for the matching bundled file path.

    Raises:
        FileNotFoundError: If the bundled mirror file is missing.

    Side Effects:
        Reads a checked-in bundled repository file from disk.
    """

    bundled_relative_path = relative_path.replace(
        "scripts/powershell/PoshQC/",
        "extensions/drm-copilot/resources/powershell/PoshQC/",
    )
    return (REPO_ROOT / bundled_relative_path).read_text(encoding="utf-8")


def test_poshqc_bundled_module_files_match_repo_root_sources() -> None:
    """Require the bundled PoshQC module files to match the repo-root sources.

    Args:
        None.

    Returns:
        None.

    Raises:
        AssertionError: If any bundled file drifts from its repo-root source.

    Side Effects:
        Reads the checked-in repo-root and bundled PoshQC files from disk.
    """

    # Lock all repo-root versus bundled PowerShell module pairs to exact text parity.
    for relative_path in POSHQC_PARITY_PATHS:
        assert read_bundle_text(relative_path) == read_repo_text(relative_path)
