"""Tests for review-mode converter execution."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.engine import run_review_mode
from scripts.dev_tools.codex_native_converter.models import RunOptions, SourceEcosystem


class RecordingFileSystem:
    """Record converter writes without touching the local filesystem.

    Purpose:
        Capture report and proposed-tree writes for review-mode assertions.

    Usage:
        Pass this adapter into the engine when a test needs to inspect written
        paths and content without using temporary files.

    Flow:
        The engine calls ``mkdir`` and ``write_text``; the adapter records both.

    Invariants / Constraints:
        Recorded paths are stored by their POSIX string representation.

    Side Effects:
        None.
    """

    def __init__(self) -> None:
        """Initialize empty directory and file records.

        Purpose:
            Prepare the in-memory write ledger used by the tests.

        Args:
            None.

        Returns:
            None: This method returns no value.

        Raises:
            None.

        Side Effects:
            None.
        """

        self.directories: set[str] = set()
        self.files: dict[str, str] = {}

    def mkdir(self, path: Path) -> None:
        """Record one created directory path.

        Purpose:
            Mirror the converter's directory-creation request in memory.

        Args:
            path (Path): Directory path requested by the engine.

        Returns:
            None: This method returns no value.

        Raises:
            None.

        Side Effects:
            None.
        """

        self.directories.add(path.as_posix())

    def write_text(self, path: Path, content: str) -> None:
        """Record one written file path and its content.

        Purpose:
            Capture the converter's written output for assertions.

        Args:
            path (Path): File path requested by the engine.
            content (str): Text content written by the engine.

        Returns:
            None: This method returns no value.

        Raises:
            None.

        Side Effects:
            None.
        """

        self.files[path.as_posix()] = content


def _fixture_root(fixture_name: str) -> Path:
    """Resolve one committed converter fixture root."""

    return (
        Path(__file__).resolve().parents[4]
        / "tests"
        / "fixtures"
        / "codex_native_converter"
        / fixture_name
    )


def test_review_mode_writes_required_artifacts_without_destination_mutation() -> None:
    """Write the review-mode report set without destination output."""

    fixture_root = _fixture_root("github_copilot")
    recording_fs = RecordingFileSystem()
    run_options = RunOptions(
        mode="review",
        source_root=fixture_root,
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        selected_paths=(),
        destination_root=None,
        artifact_root=Path("virtual/review-artifacts"),
    )

    result = run_review_mode(run_options, fs=recording_fs)
    written_paths = set(recording_fs.files)

    assert result.wrote_destination is False
    assert any(path.endswith("conversion-report.md") for path in written_paths)
    assert any(path.endswith("mapping-catalog.json") for path in written_paths)
    assert any(path.endswith("validation-results.json") for path in written_paths)
    assert any("proposed-tree/AGENTS.md" in path for path in written_paths)
