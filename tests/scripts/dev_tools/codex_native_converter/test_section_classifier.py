"""Tests for section-level prompt decomposition."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.classifier import classify_prompt_sections
from scripts.dev_tools.codex_native_converter.models import (
    SectionIntentKind,
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


def test_classify_prompt_sections_distinguishes_workflow_and_hook_candidates() -> None:
    """Classify mixed prompt sections into hook and workflow intents."""

    source_artifact = parse_source_artifact(
        _fixture_root("github_copilot"),
        Path(".github/prompts/mixed-runtime.prompt.md"),
        SourceEcosystem.GITHUB_COPILOT,
        SourceKind.LAUNCHER_PROMPT,
    )

    section_intents = classify_prompt_sections(source_artifact)

    assert any(
        intent.heading == "Hard Gate"
        and intent.intent_kind is SectionIntentKind.HOOK_CANDIDATE
        for intent in section_intents
    )
    assert any(
        intent.heading == "Workflow"
        and intent.intent_kind is SectionIntentKind.SHARED_WORKFLOW
        for intent in section_intents
    )
