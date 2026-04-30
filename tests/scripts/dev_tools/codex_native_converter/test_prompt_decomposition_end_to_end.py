"""End-to-end tests for prompt decomposition traces in converter reports."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.engine import run_review_mode
from scripts.dev_tools.codex_native_converter.models import RunOptions, SourceEcosystem


class RecordingFileSystem:
    """Record converter writes without touching the local filesystem."""

    def __init__(self) -> None:
        """Initialize empty directory and file records."""

        self.files: dict[str, str] = {}

    def mkdir(self, path: Path) -> None:
        """Record directory creation without persisting it."""

    def write_text(self, path: Path, content: str) -> None:
        """Record one written file path and its content."""

        self.files[path.as_posix()] = content


def _fixture_root() -> Path:
    """Resolve the committed GitHub Copilot fixture root."""

    return (
        Path(__file__).resolve().parents[4]
        / "tests"
        / "fixtures"
        / "codex_native_converter"
        / "github_copilot"
    )


def test_review_report_includes_prompt_decomposition_section_mappings() -> None:
    """Show launcher, workflow, and hook traces for a mixed prompt fixture."""

    recording_fs = RecordingFileSystem()
    run_review_mode(
        RunOptions(
            mode="review",
            source_root=_fixture_root(),
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            selected_paths=(Path(".github/prompts/mixed-runtime.prompt.md"),),
            destination_root=None,
            artifact_root=Path("virtual/end-to-end/github-prompt"),
            enable_repo_prompts=True,
        ),
        fs=recording_fs,
    )

    report_text = next(
        content
        for path, content in recording_fs.files.items()
        if path.endswith("conversion-report.md")
    )

    assert "`Launcher Surface`" in report_text
    assert "`shared-workflow`" in report_text
    assert "`hook-candidate`" in report_text
    assert "`.codex/prompts/mixed-runtime.md`" in report_text
    assert "`.agents/skills/mixed-runtime/SKILL.md`" in report_text
    assert "`.codex/hooks/mixed-runtime.py`" in report_text
