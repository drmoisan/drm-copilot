"""End-to-end tests for the Codex-native converter pipeline."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.engine import (
    ConversionRunResult,
    run_review_mode,
)
from scripts.dev_tools.codex_native_converter.mapping import (
    STANDING_GUIDANCE_NOT_EMITTED_NOTE,
)
from scripts.dev_tools.codex_native_converter.models import RunOptions, SourceEcosystem

# Repo-wide standing-guidance sources of the GitHub Copilot fixture.
STANDING_GUIDANCE_SOURCES = (
    ".github/copilot-instructions.md",
    ".github/instructions/general-code-change.instructions.md",
)


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
    assert not any("proposed-tree/AGENTS.md" in path for path in written_paths)
    assert len(result.mapping_records) >= 4


def _run_github_review(recording_fs: RecordingFileSystem) -> ConversionRunResult:
    """Run review mode over the GitHub Copilot fixture into a recording file system.

    Args:
        recording_fs (RecordingFileSystem): Adapter that records report writes.

    Returns:
        ConversionRunResult: The review-mode run result.
    """

    return run_review_mode(
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


def test_github_copilot_fixture_emits_no_agents_target_for_standing_guidance() -> None:
    """Emit no `AGENTS.md` output for repo-wide standing-guidance sources."""

    result = _run_github_review(RecordingFileSystem())

    assert "AGENTS.md" not in result.generated_output
    assert not any(
        "Converted standing guidance" in output
        for output in result.generated_output.values()
    )
    standing_records = [
        record
        for record in result.mapping_records
        if record.source_path in STANDING_GUIDANCE_SOURCES
    ]
    assert len(standing_records) == len(STANDING_GUIDANCE_SOURCES)
    assert all(record.target_path is None for record in standing_records)
    assert not any(
        finding.code == "duplicate-target-path"
        for finding in result.validation_findings
    )


def test_github_copilot_fixture_reports_standing_guidance_as_not_emitted() -> None:
    """Record each standing-guidance source as not emitted, with the reason."""

    recording_fs = RecordingFileSystem()
    result = _run_github_review(recording_fs)

    report = next(
        content
        for path, content in recording_fs.files.items()
        if path.endswith("conversion-report.md")
    )
    # Check the record note and the report row of each standing-guidance source.
    for source_path in STANDING_GUIDANCE_SOURCES:
        record = next(
            record
            for record in result.mapping_records
            if record.source_path == source_path
        )
        assert STANDING_GUIDANCE_NOT_EMITTED_NOTE in record.notes
        row = next(
            line
            for line in report.splitlines()
            if line.startswith(f"| `{source_path}`")
        )
        assert STANDING_GUIDANCE_NOT_EMITTED_NOTE in row


def test_github_copilot_fixture_keeps_standing_guidance_reference_rewrites() -> None:
    """Keep the rewrites to `AGENTS.md` in the topology agent output."""

    result = _run_github_review(RecordingFileSystem())

    agent_output = next(
        output
        for target_path, output in result.generated_output.items()
        if target_path.endswith("beast-topology.toml")
    )
    assert "AGENTS.md" in agent_output
    assert ".github/copilot-instructions.md" not in agent_output


def _test_claude_fixture_review_maps_rules_to_shared_skills() -> None:
    """Map Claude rule files to shared skills or standing guidance."""

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

    rule_record = next(
        record
        for record in result.mapping_records
        if record.source_path == ".claude/rules/general-code-change.md"
    )

    assert rule_record.target_path is not None
    assert not any(
        finding.source_path == ".claude/rules/general-code-change.md"
        and finding.code == "unsupported-ecosystem"
        for finding in result.validation_findings
    )
    assert any(path.endswith("mapping-catalog.json") for path in recording_fs.files)
    assert any(path.endswith("validation-results.json") for path in recording_fs.files)


globals()[
    "test_claude_fixture_review_run_maps_rules_to_shared_skills_without_failing"
] = _test_claude_fixture_review_maps_rules_to_shared_skills


def test_native_surfaces_fixture_publishes_github_hooks_through_approved_mappings() -> (
    None
):
    """Deliver GitHub hook surfaces natively while unrelated paths stay unsupported."""

    recording_fs = RecordingFileSystem()
    result = run_review_mode(
        RunOptions(
            mode="review",
            source_root=_fixture_root("native_surfaces"),
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            selected_paths=(),
            destination_root=None,
            artifact_root=Path("virtual/end-to-end/native-surfaces"),
        ),
        fs=recording_fs,
    )

    targets = {
        record.source_path: record.target_path for record in result.mapping_records
    }

    assert targets[".github/hooks/discovery-pre-tool.ps1"] == (
        ".codex/hooks/discovery-pre-tool.ps1"
    )
    assert targets[".github/hooks/discovery.json"] == ".codex/config.toml"
    assert targets[".github/hooks/README.md"] is None
    # Workflows are not an inventoried surface, so no record exists for them.
    assert ".github/workflows/ci.yml" not in targets
    assert not any(
        finding.code == "unsupported-ecosystem"
        and finding.source_path == ".github/hooks/README.md"
        for finding in result.validation_findings
    )
    hook_output = next(
        content
        for path, content in recording_fs.files.items()
        if path.endswith("proposed-tree/.codex/hooks/discovery-pre-tool.ps1")
    )
    assert hook_output.startswith("# Converted hook\n")
    assert ".codex/lib/discovery-validation/DiscoveryValidation.psm1" in hook_output


def test_native_surfaces_fixture_publishes_claude_helpers_verbatim() -> None:
    """Emit shared PowerShell helpers verbatim under `.codex/lib` after rewrites."""

    recording_fs = RecordingFileSystem()
    result = run_review_mode(
        RunOptions(
            mode="review",
            source_root=_fixture_root("native_surfaces"),
            source_ecosystem=SourceEcosystem.CLAUDE,
            selected_paths=(),
            destination_root=None,
            artifact_root=Path("virtual/end-to-end/native-surfaces"),
        ),
        fs=recording_fs,
    )

    targets = {
        record.source_path: record.target_path for record in result.mapping_records
    }
    helper_source = ".claude/lib/discovery-validation/DiscoveryValidation.psm1"
    helper_output = next(
        content
        for path, content in recording_fs.files.items()
        if path.endswith(
            "proposed-tree/.codex/lib/discovery-validation/DiscoveryValidation.psm1"
        )
    )

    assert (
        targets[helper_source]
        == ".codex/lib/discovery-validation/DiscoveryValidation.psm1"
    )
    assert targets[".claude/lib/bash/parallel-common.sh"] is None
    assert not helper_output.startswith("# Converted hook")
    assert "function Test-FixtureDiscoveryAuthority" in helper_output
    assert "imported from .codex/lib/discovery-validation/" in helper_output
    assert ".claude/lib/" not in helper_output
