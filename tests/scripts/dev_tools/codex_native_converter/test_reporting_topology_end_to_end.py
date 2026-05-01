"""End-to-end topology-report tests for the Codex-native converter."""

from __future__ import annotations

import re
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


def _extract_labeled_edges(mermaid_block: str) -> set[tuple[str, str]]:
    """Resolve Mermaid node ids back to labels for edge assertions."""

    node_labels = {
        match.group("node_id"): match.group("label")
        for match in re.finditer(
            r'^\s*(?P<node_id>\w+)\["(?P<label>.+?)"\]\s*$',
            mermaid_block,
            flags=re.MULTILINE,
        )
    }
    return {
        (node_labels[source_id], node_labels[destination_id])
        for source_id, destination_id in re.findall(
            r"^\s*(\w+)\s+-->\s+(\w+)\s*$",
            mermaid_block,
            flags=re.MULTILINE,
        )
    }


def test_conversion_report_topology_shows_decomposed_agent_fan_out() -> None:
    """Show native fan-out for a decomposed agent in every topology chart."""

    recording_fs = RecordingFileSystem()
    run_review_mode(
        RunOptions(
            mode="review",
            source_root=_fixture_root(),
            source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
            selected_paths=(),
            destination_root=None,
            artifact_root=Path("virtual/end-to-end/github-topology"),
        ),
        fs=recording_fs,
    )

    report_text = next(
        content
        for path, content in recording_fs.files.items()
        if path.endswith("conversion-report.md")
    )
    mermaid_blocks = re.findall(
        r"```mermaid\n(.*?)\n```",
        report_text,
        flags=re.DOTALL,
    )

    assert len(mermaid_blocks) == 3

    beast_source = ".github/agents/beast-topology.agent.md"
    beast_agent_target = ".codex/agents/beast-topology.toml"
    shared_guidance_target = "AGENTS.md"
    skill_target = ".agents/skills/review-workflow/SKILL.md"

    shared_edges = _extract_labeled_edges(mermaid_blocks[0])
    repeated_destination_edges = _extract_labeled_edges(mermaid_blocks[1])
    repeated_source_edges = _extract_labeled_edges(mermaid_blocks[2])

    assert (beast_source, beast_agent_target) in shared_edges
    assert (beast_source, shared_guidance_target) in shared_edges
    assert (beast_source, skill_target) in shared_edges
    assert (beast_source, beast_agent_target) in repeated_destination_edges
    assert (beast_source, shared_guidance_target) in repeated_destination_edges
    assert (beast_source, skill_target) in repeated_destination_edges
    assert (beast_agent_target, beast_source) in repeated_source_edges
    assert (shared_guidance_target, beast_source) in repeated_source_edges
    assert (skill_target, beast_source) in repeated_source_edges
