"""End-to-end tests for the Codex-native converter pipeline."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.engine import run_review_mode
from scripts.dev_tools.codex_native_converter.models import RunOptions, SourceEcosystem


class RecordingFileSystem:
    """Record converter writes without touching the local filesystem.

    Purpose:
        Capture report and proposed-tree writes for end-to-end assertions.

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


def test_github_copilot_fixture_review_run_produces_required_report_set() -> None:
    """Produce the required review artifact set for the GitHub Copilot fixture."""

    recording_fs = RecordingFileSystem()
    result = run_review_mode(
        RunOptions(
            mode="review",
            source_root=_fixture_root("github_copilot"),
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            selected_paths=(),
            destination_root=None,
            artifact_root=Path("virtual/end-to-end/github"),
        ),
        fs=recording_fs,
    )

    written_paths = set(recording_fs.files)

    assert any(path.endswith("conversion-report.md") for path in written_paths)
    assert any(path.endswith("mapping-catalog.json") for path in written_paths)
    assert any(path.endswith("validation-results.json") for path in written_paths)
    assert any("proposed-tree/AGENTS.md" in path for path in written_paths)
    assert len(result.mapping_records) >= 4


def _test_claude_fixture_review_surfaces_unsupported_constructs() -> None:
    """Surface unsupported Claude constructs in reports instead of dropping them."""

    recording_fs = RecordingFileSystem()
    result = run_review_mode(
        RunOptions(
            mode="review",
            source_root=_fixture_root("claude"),
            source_ecosystem=SourceEcosystem.CLAUDE,
            selected_paths=(),
            destination_root=None,
            artifact_root=Path("virtual/end-to-end/claude"),
        ),
        fs=recording_fs,
    )

    unsupported_rule_record = next(
        record
        for record in result.mapping_records
        if record.source_path == ".claude/rules/general-code-change.md"
    )

    assert unsupported_rule_record.target_path is None
    assert any(
        finding.source_path == ".claude/rules/general-code-change.md"
        and finding.code == "unsupported-ecosystem"
        for finding in result.validation_findings
    )
    assert any(path.endswith("mapping-catalog.json") for path in recording_fs.files)
    assert any(path.endswith("validation-results.json") for path in recording_fs.files)


globals()[
    "test_claude_fixture_review_run_surfaces_unsupported_constructs_without_dropping_them"
] = _test_claude_fixture_review_surfaces_unsupported_constructs
