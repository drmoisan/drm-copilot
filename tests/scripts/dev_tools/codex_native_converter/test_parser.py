"""Tests for Codex-native converter source parsing."""

from __future__ import annotations

from pathlib import Path

from scripts.dev_tools.codex_native_converter.models import (
    SemanticCueKind,
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


def test_parse_source_artifact_splits_frontmatter_and_sections_deterministically() -> (
    None
):
    """Parse an instruction file twice and verify both results are identical.

    Scenario:
        ``parse_source_artifact`` is called on the same committed fixture file
        twice in sequence.
    Expected:
        Both calls return equal ``SourceArtifact`` instances, confirming that
        parsing is deterministic and independent of call order.
    """

    fixture_root = _fixture_root("github_copilot")
    fixture_path = Path(".github/instructions/general-code-change.instructions.md")

    # Parse the same fixture artifact twice to confirm deterministic output.
    first_result = parse_source_artifact(
        fixture_root,
        fixture_path,
        SourceEcosystem.GITHUB_COPILOT,
        SourceKind.PATH_SCOPED_INSTRUCTION,
    )
    second_result = parse_source_artifact(
        fixture_root,
        fixture_path,
        SourceEcosystem.GITHUB_COPILOT,
        SourceKind.PATH_SCOPED_INSTRUCTION,
    )

    # Both calls must produce structurally identical artifacts.
    assert first_result == second_result

    # Verify frontmatter is split correctly from the body sections.
    assert first_result.frontmatter["applyTo"] == "**"
    assert first_result.frontmatter["name"] == "fixture-general-policy"

    # Verify sections are extracted with correct headings and content.
    assert len(first_result.sections) == 1
    assert first_result.sections[0].heading == "Fixture instruction"


def test_parse_source_artifact_attaches_semantic_cues_for_known_cue_kinds() -> None:
    """Verify that parse_source_artifact attaches semantic cues based on content.

    Scenario:
        The mixed-runtime fixture contains a hard-gate section (with forbidden
        language) and a workflow section (with numbered steps).
    Expected:
        The ``Hard Gate`` section carries a ``FORBIDDEN_PATTERN`` cue and the
        ``Workflow`` section carries a ``NUMBERED_WORKFLOW`` cue. All named
        sections carry a ``HEADING`` cue.
    """

    source_artifact = parse_source_artifact(
        _fixture_root("github_copilot"),
        Path(".github/prompts/mixed-runtime.prompt.md"),
        SourceEcosystem.GITHUB_COPILOT,
        SourceKind.LAUNCHER_PROMPT,
    )

    # Build a lookup from heading to cue kinds for clear assertions.
    cues_by_heading = {
        section.heading: frozenset(cue.kind for cue in section.cues)
        for section in source_artifact.sections
    }

    # Every named section must carry a HEADING cue.
    for heading, cue_kinds in cues_by_heading.items():
        assert (
            SemanticCueKind.HEADING in cue_kinds
        ), f"Section '{heading}' missing HEADING cue"

    # The enforcement section must carry a FORBIDDEN_PATTERN cue for "must not".
    assert (
        SemanticCueKind.FORBIDDEN_PATTERN in cues_by_heading["Hard Gate"]
    ), "Hard Gate section missing FORBIDDEN_PATTERN cue"

    # The workflow section must carry a NUMBERED_WORKFLOW cue for "1.", "2.", "3.".
    assert (
        SemanticCueKind.NUMBERED_WORKFLOW in cues_by_heading["Workflow"]
    ), "Workflow section missing NUMBERED_WORKFLOW cue"
