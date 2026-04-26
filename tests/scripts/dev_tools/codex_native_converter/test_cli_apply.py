"""Tests for apply-mode converter execution."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.engine import run_apply_mode
from scripts.dev_tools.codex_native_converter.models import RunOptions, SourceEcosystem
from scripts.dev_tools.codex_native_converter.validation import validate_conversion_plan


class RecordingFileSystem:
    """Record converter writes without touching the local filesystem.

    Purpose:
        Capture report and destination writes for apply-mode assertions.

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
        """Initialize empty directory and file records."""

        self.directories: set[str] = set()
        self.files: dict[str, str] = {}

    def mkdir(self, path: Path) -> None:
        """Record one created directory path."""

        self.directories.add(path.as_posix())

    def write_text(self, path: Path, content: str) -> None:
        """Record one written file path and its content."""

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


def _test_apply_mode_requires_destination_root_and_writes_outputs() -> None:
    """Require a destination root for apply mode and write outputs when valid."""

    fixture_root = _fixture_root("github_copilot")
    invalid_run_options = RunOptions(
        mode="apply",
        source_root=fixture_root,
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        selected_paths=(),
        destination_root=None,
        artifact_root=Path("virtual/invalid-artifacts"),
    )

    findings = validate_conversion_plan(invalid_run_options, (), {})

    assert any(finding.code == "missing-required-input" for finding in findings)

    recording_fs = RecordingFileSystem()
    valid_run_options = RunOptions(
        mode="apply",
        source_root=fixture_root,
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        selected_paths=(),
        destination_root=Path("virtual/destination"),
        artifact_root=Path("virtual/apply-artifacts"),
    )

    result = run_apply_mode(valid_run_options, fs=recording_fs)
    written_paths = set(recording_fs.files)
    destination_root = valid_run_options.destination_root
    assert destination_root is not None
    resolved_destination_root = destination_root.resolve().as_posix()

    assert result.wrote_destination is True
    assert any(
        path.startswith(f"{resolved_destination_root}/") for path in written_paths
    )
    assert any(path.endswith("conversion-report.md") for path in written_paths)
    assert any(path.endswith("mapping-catalog.json") for path in written_paths)
    assert any(path.endswith("validation-results.json") for path in written_paths)


globals()[
    "test_apply_mode_requires_destination_root_and_writes_outputs_plus_report_artifacts"
] = _test_apply_mode_requires_destination_root_and_writes_outputs
