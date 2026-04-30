"""Tests for Codex-native converter source parsing."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.models import (
    SourceEcosystem,
    SourceKind,
)
from scripts.dev_tools.codex_native_converter.parser import parse_source_artifact


def _fixture_root(fixture_name: str) -> Path:
    """Resolve one committed converter fixture root."""

    return (
        Path(__file__).resolve().parents[4]
        / "tests"
        / "fixtures"
        / "codex_native_converter"
        / fixture_name
    )


def test_parse_source_artifact_splits_prompt_frontmatter_and_sections() -> None:
    """Parse frontmatter and heading-based sections from a mixed prompt."""

    source_artifact = parse_source_artifact(
        _fixture_root("github_copilot"),
        Path(".github/prompts/mixed-runtime.prompt.md"),
        SourceEcosystem.GITHUB_COPILOT,
        SourceKind.LAUNCHER_PROMPT,
    )

    assert source_artifact.frontmatter["agent"] == "orchestrator"
    assert source_artifact.frontmatter["description"].startswith("Fixture prompt")
    assert [section.heading for section in source_artifact.sections] == [
        "Mixed runtime prompt",
        "Hard Gate",
        "Workflow",
        "Launch Template",
    ]
