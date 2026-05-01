"""Tests for section-intent classification in the v2 converter pipeline."""

from __future__ import annotations

from scripts.dev_tools.codex_native_converter.models import (
    SectionIntentKind,
    SemanticCue,
    SemanticCueKind,
    SourceArtifact,
    SourceEcosystem,
    SourceKind,
    SourceSection,
)
from scripts.dev_tools.codex_native_converter.section_intent import (
    classify_section_intent,
)


def _make_section(
    *,
    heading: str,
    content: str = "",
    cues: tuple[SemanticCue, ...] = (),
) -> SourceSection:
    """Construct a minimal SourceSection for use in classification tests.

    Args:
        heading (str): Section heading text.
        content (str): Optional section body content.
        cues (tuple[SemanticCue, ...]): Optional semantic cues to attach.

    Returns:
        SourceSection: A valid section instance with deterministic identifiers.

    Side Effects:
        None.
    """

    section_stem = heading.lower().replace(" ", "-") or "body"
    return SourceSection(
        section_id=f"fixture.md#{section_stem}-1",
        heading=heading,
        level=2,
        content=content,
        start_line=1,
        end_line=max(1, len(content.splitlines())),
        cues=cues,
    )


def _make_artifact(
    *, source_kind: SourceKind = SourceKind.STANDING_INSTRUCTION
) -> SourceArtifact:
    """Construct a minimal SourceArtifact for use in classification tests.

    Args:
        source_kind (SourceKind): The source kind to assign to the artifact.

    Returns:
        SourceArtifact: A valid artifact instance with no sections.

    Side Effects:
        None.
    """

    return SourceArtifact(
        source_path="fixture.md",
        source_ecosystem=SourceEcosystem.GITHUB_COPILOT,
        source_kind=source_kind,
        frontmatter={},
        raw_text="",
        sections=(),
    )


def test_classify_section_intent_assigns_standing_guidance_for_instruction_sections() -> (  # noqa: E501
    None
):
    """classify_section_intent returns standing_guidance for headed instruction
    sections.

    Scenario:
        A section with a HEADING cue and no enforcement, workflow, identity, or
        config signals is from a STANDING_INSTRUCTION artifact.
    Expected:
        The returned intent_kind is ``standing_guidance``, confirming that
        general instruction headings map to the standing-guidance surface.
    """

    # Arrange: a headed section with no special cue signals.
    # Use a heading that does not contain identity, rule, or config keywords so
    # the classifier falls through to standing_guidance as the default for a
    # headed section.
    section = _make_section(
        heading="Agent Behavior",
        content="Use a professional tone in all written output.",
        cues=(SemanticCue(kind=SemanticCueKind.HEADING, value="Agent Behavior"),),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act: classify the section.
    intent = classify_section_intent(section, artifact)

    # Assert: a plain headed instruction section maps to standing guidance.
    assert intent.intent_kind is SectionIntentKind.STANDING_GUIDANCE
    assert intent.source_path == "fixture.md"
    assert intent.section_id == section.section_id
    assert intent.heading == "Agent Behavior"
    assert len(intent.notes) > 0


def test_classify_section_intent_assigns_hook_candidate_for_enforcement_sections() -> (
    None
):
    """classify_section_intent returns hook_candidate for enforcement sections.

    Scenario:
        A section carries both a HEADING cue and a HARD_GATE cue, indicating
        non-negotiable enforcement language such as "you MUST" or "REQUIRED".
    Expected:
        The returned intent_kind is ``hook_candidate``, confirming that
        hard-gate content maps to a native enforcement hook surface.
    """

    # Arrange: a section with a hard-gate enforcement cue.
    section = _make_section(
        heading="Mandatory Safety Check",
        content="You MUST run the full toolchain before submitting.",
        cues=(
            SemanticCue(kind=SemanticCueKind.HEADING, value="Mandatory Safety Check"),
            SemanticCue(kind=SemanticCueKind.HARD_GATE, value="you MUST"),
        ),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act: classify the section.
    intent = classify_section_intent(section, artifact)

    # Assert: hard-gate language maps to a hook candidate.
    assert intent.intent_kind is SectionIntentKind.HOOK_CANDIDATE
    assert intent.source_path == "fixture.md"
    assert len(intent.notes) > 0


def test_tool_requirement_plus_config_heading_yields_config_candidate() -> None:
    """classify_section_intent returns config_candidate when a TOOL_REQUIREMENT cue
    is paired with a config-like heading (lines 163-166).

    Scenario:
        A section carries a TOOL_REQUIREMENT cue and a heading that matches the
        config-heading pattern (contains "config" keyword).  No HARD_GATE,
        FORBIDDEN_PATTERN, or NUMBERED_WORKFLOW cues are present so those earlier
        branches do not fire.
    Expected:
        The returned intent_kind is ``config_candidate``, confirming that tool
        requirements combined with a config-type heading produce a config
        classification.
    """

    # Arrange: section with TOOL_REQUIREMENT cue and a config-like heading.
    section = _make_section(
        heading="Config Requirements",
        content="The tool requires the MCP server to be configured before use.",
        cues=(
            SemanticCue(
                kind=SemanticCueKind.TOOL_REQUIREMENT, value="requires MCP server"
            ),
        ),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act
    intent = classify_section_intent(section, artifact)

    # Assert: TOOL_REQUIREMENT + config heading → config_candidate.
    assert intent.intent_kind is SectionIntentKind.CONFIG_CANDIDATE
    assert intent.source_path == "fixture.md"
    assert len(intent.notes) > 0


def test_tool_requirement_plus_rule_heading_yields_rule_candidate() -> None:
    """classify_section_intent returns rule_candidate when a TOOL_REQUIREMENT cue
    is paired with a rule-like heading (lines 179-182).

    Scenario:
        A section carries a TOOL_REQUIREMENT cue and a heading that matches the
        rule-heading pattern (contains "policy" keyword).  The heading does not
        match the config-heading pattern, so the config-candidate branch
        (line 160) does not fire.
    Expected:
        The returned intent_kind is ``rule_candidate``.
    """

    # Arrange: section with TOOL_REQUIREMENT cue and a rule-like heading.
    # "Enforcement Policy" matches _RULE_HEADING_PATTERN via "policy"
    # and does not match _CONFIG_HEADING_PATTERN.
    section = _make_section(
        heading="Enforcement Policy",
        content="The tool must enforce this policy before each commit.",
        cues=(
            SemanticCue(kind=SemanticCueKind.TOOL_REQUIREMENT, value="must enforce"),
        ),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act
    intent = classify_section_intent(section, artifact)

    # Assert: TOOL_REQUIREMENT + rule heading → rule_candidate.
    assert intent.intent_kind is SectionIntentKind.RULE_CANDIDATE
    assert len(intent.notes) > 0


def test_config_heading_without_tool_requirement_yields_config_candidate() -> None:
    """classify_section_intent returns config_candidate for a config-like heading
    when no TOOL_REQUIREMENT cue is present (lines 203-204).

    Scenario:
        A section has no cues at all and a heading that matches the
        config-heading pattern ("Settings").  The TOOL_REQUIREMENT-gated
        branches are skipped; the standalone config-heading branch fires.
    Expected:
        The returned intent_kind is ``config_candidate``.
    """

    # Arrange: section with no cues and a config-like heading.
    # "Environment Settings" matches _CONFIG_HEADING_PATTERN via "setting".
    section = _make_section(
        heading="Environment Settings",
        content="Set the environment variables before running the tool.",
        cues=(),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act
    intent = classify_section_intent(section, artifact)

    # Assert: config heading alone → config_candidate.
    assert intent.intent_kind is SectionIntentKind.CONFIG_CANDIDATE
    assert len(intent.notes) > 0


def test_classify_section_intent_returns_identity_for_identity_heading() -> None:
    """classify_section_intent returns identity for an identity-like heading
    (lines 214-215).

    Scenario:
        A section has no cues and a heading that matches the identity-heading
        pattern ("Overview").  The rule-heading and config-heading branches
        are skipped because neither pattern matches; the identity-heading branch
        fires.
    Expected:
        The returned intent_kind is ``identity``.
    """

    # Arrange: section with an identity-like heading and no cues.
    # "Overview" matches _IDENTITY_HEADING_PATTERN via "overview".
    section = _make_section(
        heading="Overview",
        content="This document describes the agent behavior.",
        cues=(),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act
    intent = classify_section_intent(section, artifact)

    # Assert: identity heading → identity.
    assert intent.intent_kind is SectionIntentKind.IDENTITY
    assert len(intent.notes) > 0


def test_no_cues_and_no_keyword_heading_yields_unsupported() -> None:
    """classify_section_intent returns unsupported for sections with no cues and
    no heading keyword match (lines 240-243).

    Scenario:
        A section has an empty cues tuple and a heading that does not match the
        identity, rule, or config heading patterns.  No HEADING cue is attached,
        so the standing-guidance fallback (line 225) also does not fire.
    Expected:
        The returned intent_kind is ``unsupported``, confirming the fail-closed
        fallback path.
    """

    # Arrange: section with no cues and a heading that contains none of the
    # recognized keywords (no identity/rule/config/heading cue signal).
    section = _make_section(
        heading="Getting Started",
        content="Follow the steps below to begin.",
        cues=(),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act
    intent = classify_section_intent(section, artifact)

    # Assert: no-cue + non-keyword heading → unsupported.
    assert intent.intent_kind is SectionIntentKind.UNSUPPORTED
    assert len(intent.notes) > 0


def test_launcher_prompt_with_launcher_wrapper_cue_yields_launcher_only() -> None:
    """classify_section_intent returns launcher_only for launcher-prompt sections.

    Scenario:
        A section from a LAUNCHER_PROMPT artifact carries only a LAUNCHER_WRAPPER
        cue with no HARD_GATE, FORBIDDEN_PATTERN, or NUMBERED_WORKFLOW signals.
    Expected:
        The returned intent_kind is ``launcher_only``.
    """

    # Arrange: LAUNCHER_PROMPT artifact + LAUNCHER_WRAPPER cue only.
    section = _make_section(
        heading="Launcher Prologue",
        content="This is the entry-point wrapper for the launcher prompt.",
        cues=(SemanticCue(kind=SemanticCueKind.LAUNCHER_WRAPPER, value="launcher"),),
    )
    artifact = _make_artifact(source_kind=SourceKind.LAUNCHER_PROMPT)

    # Act
    intent = classify_section_intent(section, artifact)

    # Assert: launcher-prompt source + LAUNCHER_WRAPPER → launcher_only.
    assert intent.intent_kind is SectionIntentKind.LAUNCHER_ONLY
    assert len(intent.notes) > 0


def test_numbered_workflow_cue_yields_shared_workflow() -> None:
    """classify_section_intent returns shared_workflow for numbered-workflow cues.

    Scenario:
        A section contains a NUMBERED_WORKFLOW cue indicating a reusable
        procedural workflow structure.
    Expected:
        The returned intent_kind is ``shared_workflow``.
    """

    # Arrange: section with NUMBERED_WORKFLOW cue; source kind is irrelevant.
    section = _make_section(
        heading="Step-by-Step Guide",
        content="1. Step one\n2. Step two\n3. Step three",
        cues=(
            SemanticCue(kind=SemanticCueKind.NUMBERED_WORKFLOW, value="numbered steps"),
        ),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act
    intent = classify_section_intent(section, artifact)

    # Assert: NUMBERED_WORKFLOW cue → shared_workflow.
    assert intent.intent_kind is SectionIntentKind.SHARED_WORKFLOW
    assert len(intent.notes) > 0


def test_rule_heading_without_tool_requirement_yields_rule_candidate() -> None:
    """classify_section_intent returns rule_candidate via heading-only match.

    Scenario:
        A section has a rule-like heading keyword but no SemanticCue instances,
        so it reaches the heading-only rule_candidate branch.
    Expected:
        The returned intent_kind is ``rule_candidate``.
    """

    # Arrange: section with rule-like heading and no cues.
    # "constraint" matches _RULE_HEADING_PATTERN as a standalone word.
    section = _make_section(
        heading="File Size Constraint",
        content="No production file may exceed 500 lines.",
        cues=(),
    )
    artifact = _make_artifact(source_kind=SourceKind.STANDING_INSTRUCTION)

    # Act
    intent = classify_section_intent(section, artifact)

    # Assert: rule-like heading with no cues → rule_candidate via heading path.
    assert intent.intent_kind is SectionIntentKind.RULE_CANDIDATE
    assert len(intent.notes) > 0
