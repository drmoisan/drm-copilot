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
    assert "`.codex/hooks/mixed-runtime.ps1`" in report_text


def test_review_run_emits_prompt_hook_and_skill_outputs() -> None:
    """Emit prompt-derived hook and skill outputs into the proposed tree."""

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

    written_paths = set(recording_fs.files)
    hook_path = next(
        path
        for path in written_paths
        if path.endswith("proposed-tree/.codex/hooks/mixed-runtime.ps1")
    )
    skill_path = next(
        path
        for path in written_paths
        if path.endswith("proposed-tree/.agents/skills/mixed-runtime/SKILL.md")
    )
    launcher_path = next(
        path
        for path in written_paths
        if path.endswith("proposed-tree/.codex/prompts/mixed-runtime.md")
    )

    assert "Hard Gate" in recording_fs.files[hook_path]
    assert "Workflow" in recording_fs.files[skill_path]
    assert "Launch Template" in recording_fs.files[launcher_path]


def test_review_run_emits_prompt_hook_and_skill_without_launcher_when_disabled() -> (
    None
):
    """Keep prompt-derived hook and skill outputs when launcher output is disabled."""

    recording_fs = RecordingFileSystem()
    run_review_mode(
        RunOptions(
            mode="review",
            source_root=_fixture_root(),
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            selected_paths=(Path(".github/prompts/mixed-runtime.prompt.md"),),
            destination_root=None,
            artifact_root=Path("virtual/end-to-end/github-prompt-disabled"),
            enable_repo_prompts=False,
        ),
        fs=recording_fs,
    )

    written_paths = set(recording_fs.files)

    assert any(
        path.endswith("proposed-tree/.codex/hooks/mixed-runtime.ps1")
        for path in written_paths
    )
    assert any(
        path.endswith("proposed-tree/.agents/skills/mixed-runtime/SKILL.md")
        for path in written_paths
    )
    assert not any(
        path.endswith("proposed-tree/.codex/prompts/mixed-runtime.md")
        for path in written_paths
    )
