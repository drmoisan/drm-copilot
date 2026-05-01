"""Classify source sections into semantic intent kinds for native translation.

Purpose:
    Provide content-aware section classification so mixed-concern source files
    can be decomposed into distinct Codex-native surfaces deterministically.

Usage:
    The converter engine calls `classify_section_intent` for each section in a
    parsed `SourceArtifact` before the emission planner maps intents to native
    targets.

Flow:
    One `SourceSection` is inspected using its attached `SemanticCue` instances
    and heading text. The function returns a `SectionIntent` with a non-null
    `intent_kind` value drawn from the eight supported kinds.

Invariants / Constraints:
    A section is classified as `unsupported` when no cue pattern or heading
    keyword matches; the function never raises for unrecognized content.

Side Effects:
    None.
"""

from __future__ import annotations

import re

from scripts.dev_tools.codex_native_converter.models import (
    SectionIntent,
    SectionIntentKind,
    SemanticCueKind,
    SourceArtifact,
    SourceKind,
    SourceSection,
)

# Heading keywords that indicate a section introduces identity or overview
# information about the document, agent, or workflow.
_IDENTITY_HEADING_PATTERN = re.compile(
    r"\b(overview|about|introduction|what is|who |identity|name|role|purpose)\b",
    re.IGNORECASE,
)

# Heading keywords that suggest rule-level policy content suitable for a
# Codex-native rule file.
_RULE_HEADING_PATTERN = re.compile(
    r"\b(rule|policy|constraint|convention|standard|principle|guideline)\b",
    re.IGNORECASE,
)

# Heading keywords that suggest configuration, settings, or permissions content
# suitable for Codex config or MCP-config output.
_CONFIG_HEADING_PATTERN = re.compile(
    r"\b(setting|config|permission|option|flag|parameter|environment|env)\b",
    re.IGNORECASE,
)


def _cue_kinds(section: SourceSection) -> frozenset[SemanticCueKind]:
    """Return the set of cue kinds present in a section.

    Args:
        section (SourceSection): The section whose cues to inspect.

    Returns:
        frozenset[SemanticCueKind]: All cue kinds attached to the section.

    Side Effects:
        None.
    """

    return frozenset(cue.kind for cue in section.cues)


def classify_section_intent(
    section: SourceSection,
    source_artifact: SourceArtifact,
) -> SectionIntent:
    """Classify one parsed section into a semantic intent kind.

    Purpose:
        Produce a `SectionIntent` record that documents which Codex-native
        surface the section should contribute to, based on the semantic cues
        attached by the parser and the context provided by the source artifact.

    Args:
        section (SourceSection): The parsed section to classify.
        source_artifact (SourceArtifact): The artifact that owns the section,
            used to apply ecosystem- and kind-specific classification overrides.

    Returns:
        SectionIntent: A record with a non-null `intent_kind` drawn from the
        eight supported values: ``identity``, ``standing_guidance``,
        ``shared_workflow``, ``hook_candidate``, ``rule_candidate``,
        ``config_candidate``, ``launcher_only``, or ``unsupported``.

    Raises:
        None.

    Side Effects:
        None.
    """

    cues = _cue_kinds(section)
    heading = section.heading
    notes: list[str] = []

    # Sections from launcher-prompt source kinds that contain only a launcher
    # wrapper cue and no workflow or enforcement signals should be classified
    # as launcher_only to preserve emit semantics without decomposition.
    if (
        source_artifact.source_kind is SourceKind.LAUNCHER_PROMPT
        and SemanticCueKind.LAUNCHER_WRAPPER in cues
        and SemanticCueKind.HARD_GATE not in cues
        and SemanticCueKind.FORBIDDEN_PATTERN not in cues
        and SemanticCueKind.NUMBERED_WORKFLOW not in cues
    ):
        notes.append("Section is a launcher-only block in a launcher-prompt source.")
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.LAUNCHER_ONLY,
            notes=tuple(notes),
        )

    # Hard-gate or forbidden-action language indicates the section should be
    # enforced as a native hook rather than emitted as passive guidance.
    if SemanticCueKind.HARD_GATE in cues or SemanticCueKind.FORBIDDEN_PATTERN in cues:
        notes.append(
            "Section contains hard-gate or forbidden-action language that maps "
            "to a native enforcement hook."
        )
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.HOOK_CANDIDATE,
            notes=tuple(notes),
        )

    # Numbered workflow structures indicate the section is a reusable procedural
    # workflow that should be preserved as a shared skill.
    if SemanticCueKind.NUMBERED_WORKFLOW in cues:
        notes.append(
            "Section contains numbered-workflow structure suitable for a shared "
            "skill."
        )
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.SHARED_WORKFLOW,
            notes=tuple(notes),
        )

    # Tool-requirement cues combined with a config-like heading indicate the
    # section describes configuration or settings content.
    if SemanticCueKind.TOOL_REQUIREMENT in cues and _CONFIG_HEADING_PATTERN.search(
        heading
    ):
        notes.append(
            "Section references tool requirements and has a config-like heading."
        )
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.CONFIG_CANDIDATE,
            notes=tuple(notes),
        )

    # Tool-requirement cues with a rule-like heading indicate the section
    # defines toolchain or approval rules.
    if SemanticCueKind.TOOL_REQUIREMENT in cues and _RULE_HEADING_PATTERN.search(
        heading
    ):
        notes.append(
            "Section references tool requirements and has a rule-like heading."
        )
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.RULE_CANDIDATE,
            notes=tuple(notes),
        )

    # Rule-like headings without tool requirements also map to rule_candidate.
    if _RULE_HEADING_PATTERN.search(heading):
        notes.append("Section heading indicates rule or policy content.")
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.RULE_CANDIDATE,
            notes=tuple(notes),
        )

    # Config-like headings without tool requirements map to config_candidate.
    if _CONFIG_HEADING_PATTERN.search(heading):
        notes.append("Section heading indicates configuration or settings content.")
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.CONFIG_CANDIDATE,
            notes=tuple(notes),
        )

    # Identity-like headings indicate a document or agent overview section.
    if _IDENTITY_HEADING_PATTERN.search(heading):
        notes.append("Section heading indicates identity or overview content.")
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.IDENTITY,
            notes=tuple(notes),
        )

    # Any section with a heading cue that did not match a more specific pattern
    # is treated as general standing guidance.
    if SemanticCueKind.HEADING in cues:
        notes.append(
            "Section has a heading but no specific enforcement, workflow, or "
            "config signal; classified as standing guidance."
        )
        return SectionIntent(
            source_path=source_artifact.source_path,
            section_id=section.section_id,
            heading=heading,
            intent_kind=SectionIntentKind.STANDING_GUIDANCE,
            notes=tuple(notes),
        )

    # No matching cue pattern was found; classify as unsupported rather than
    # raising an exception to preserve fail-closed validation behavior.
    notes.append(
        "No matching cue pattern or heading keyword was found for this section."
    )
    return SectionIntent(
        source_path=source_artifact.source_path,
        section_id=section.section_id,
        heading=heading,
        intent_kind=SectionIntentKind.UNSUPPORTED,
        notes=tuple(notes),
    )
