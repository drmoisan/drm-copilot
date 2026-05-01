"""Define the v2 section-level intermediate types for the Codex-native converter.

Purpose:
    Collect the dataclasses and enums that represent the intermediate compiler
    state produced by v2 section-aware parsing and classification.  These types
    were extracted from ``models.py`` to keep that module under the 500-line
    size policy while preserving backward-compatibility: ``models.py`` re-exports
    every name defined here.

Usage:
    Import from ``scripts.dev_tools.codex_native_converter.models`` rather than
    from this module directly.  The re-export layer in ``models.py`` means
    consumers do not need to know that the definition lives here.

Flow:
    The parser produces ``SourceSection`` instances; the classifier attaches
    ``SemanticCue`` records and emits ``SectionIntent`` values; the planner
    produces ``PlannedEmission`` records; and the engine derives
    ``TranslationTrace`` values for reporting.

Invariants / Constraints:
    All types in this module are self-contained and do not import from other
    converter modules to avoid circular dependencies.  ``TargetRole`` is included
    here so ``PlannedEmission`` and ``TranslationTrace`` can reference it without
    requiring a cross-module dependency back to ``models.py``.

Side Effects:
    None.
"""

from __future__ import annotations

from dataclasses import dataclass
from enum import Enum


class TargetRole(str, Enum):
    """Describe the Codex-native role targeted by a mapped artifact.

    Purpose:
        Capture the intended Codex-native destination role independent of the
        final file path.

    Usage:
        Mapping records use this enum to explain why a given output path was
        selected and which native runtime surface it serves.

    Flow:
        The classifier assigns a role, then the mapping module resolves the
        concrete path for that role.

    Invariants / Constraints:
        Roles are limited to the native surfaces approved by the feature scope.

    Side Effects:
        None.
    """

    STANDING_GUIDANCE = "standing-guidance"
    SHARED_SKILL = "shared-skill"
    SUBAGENT = "subagent"
    HOOK = "hook"
    APPROVAL_RULE = "approval-rule"
    MCP_CONFIG = "mcp-config"
    LAUNCHER = "launcher"
    UNSUPPORTED = "unsupported"


class SectionIntentKind(str, Enum):
    """Describe the semantic intent detected for one source section.

    Purpose:
        Capture section-level meaning so mixed-concern source files can be
        decomposed into multiple Codex-native surfaces deterministically.

    Usage:
        Parser and classifier stages assign these intent kinds before the
        planner maps them to concrete target roles and target paths.

    Flow:
        One source artifact is parsed into sections, each section receives one
        semantic intent, and later stages convert the intent into a native
        emission or an unresolved finding.

    Invariants / Constraints:
        Intents describe section meaning, not final output locations.

    Side Effects:
        None.
    """

    IDENTITY = "identity"
    STANDING_GUIDANCE = "standing-guidance"
    SHARED_WORKFLOW = "shared-workflow"
    HOOK_CANDIDATE = "hook-candidate"
    RULE_CANDIDATE = "rule-candidate"
    CONFIG_CANDIDATE = "config-candidate"
    LAUNCHER_ONLY = "launcher-only"
    UNSUPPORTED = "unsupported"


class SemanticCueKind(str, Enum):
    """Describe one low-level semantic cue discovered in a source section."""

    HEADING = "heading"
    NUMBERED_WORKFLOW = "numbered-workflow"
    HARD_GATE = "hard-gate"
    FORBIDDEN_PATTERN = "forbidden-pattern"
    LAUNCHER_WRAPPER = "launcher-wrapper"
    TOOL_REQUIREMENT = "tool-requirement"


@dataclass(frozen=True, slots=True)
class SemanticCue:
    """Represent one semantic cue detected in a source section.

    Purpose:
        Preserve the evidence that led a section classifier toward one intent.

    Usage:
        Parser and classifier stages attach cue records to sections so later
        reporting can explain why a section was decomposed to a native surface.

    Side Effects:
        None.
    """

    kind: SemanticCueKind
    value: str


@dataclass(frozen=True, slots=True)
class SourceSection:
    """Represent one parsed section from a source artifact.

    Purpose:
        Preserve heading structure, source spans, and semantic cues so mixed
        artifacts can be translated section by section.

    Usage:
        The parser emits one ``SourceSection`` per top-level or implicit body
        section inside one source file.

    Side Effects:
        None.
    """

    section_id: str
    heading: str
    level: int
    content: str
    start_line: int
    end_line: int
    cues: tuple[SemanticCue, ...] = ()


@dataclass(frozen=True, slots=True)
class SectionIntent:
    """Represent the classified intent for one parsed source section.

    Purpose:
        Separate section meaning from final target planning so planners can map
        one source file to multiple native destinations.

    Usage:
        Section classifiers emit one intent record per parsed section.

    Side Effects:
        None.
    """

    source_path: str
    section_id: str
    heading: str
    intent_kind: SectionIntentKind
    notes: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class PlannedEmission:
    """Represent one planned native emission for one source section.

    Purpose:
        Capture section-level mapping decisions before final rendering or
        validation.

    Usage:
        The planner emits these values when one section should contribute to a
        skill, hook, launcher prompt, or other native surface.

    Side Effects:
        None.
    """

    source_path: str
    section_id: str
    heading: str
    intent_kind: SectionIntentKind
    target_role: TargetRole
    target_path: str | None
    notes: tuple[str, ...] = ()


@dataclass(frozen=True, slots=True)
class TranslationTrace:
    """Represent one section-level source-to-native translation trace.

    Purpose:
        Provide a report-friendly trace of how one source section maps to one
        native target or unresolved native concept.

    Usage:
        The engine derives these traces for Mermaid topology graphs and the
        section-level mapping table in the conversion report.

    Side Effects:
        None.
    """

    source_path: str
    section_id: str
    heading: str
    intent_kind: SectionIntentKind
    target_role: TargetRole
    target_path: str | None
    notes: tuple[str, ...] = ()
