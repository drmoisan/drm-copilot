/**
 * Section-level intermediate types for the Codex-native converter.
 *
 * Purpose:
 *     Collect the enums and immutable value types that represent the
 *     intermediate compiler state produced by section-aware parsing and
 *     classification. Ported from `models_intermediate.py`; `models.ts`
 *     re-exports every name defined here so consumers import one contract
 *     surface.
 *
 * Flow:
 *     The parser produces {@link SourceSection} instances; the classifier
 *     attaches {@link SemanticCue} records and emits {@link SectionIntent}
 *     values; the planner produces {@link PlannedEmission} records; and the
 *     engine derives {@link TranslationTrace} values for reporting.
 *
 * Invariants:
 *     All types in this module are self-contained and do not import from other
 *     converter modules to avoid circular dependencies.
 */

/**
 * Codex-native role targeted by a mapped artifact.
 *
 * Captures the intended Codex-native destination role independent of the final
 * file path. The classifier assigns a role and the mapping module resolves the
 * concrete path for that role. String values are preserved verbatim from the
 * Python `TargetRole` enum.
 */
export const TargetRole = {
  STANDING_GUIDANCE: "standing-guidance",
  SHARED_SKILL: "shared-skill",
  SUBAGENT: "subagent",
  HOOK: "hook",
  APPROVAL_RULE: "approval-rule",
  MCP_CONFIG: "mcp-config",
  LAUNCHER: "launcher",
  UNSUPPORTED: "unsupported",
} as const;

/** Union of {@link TargetRole} string values. */
export type TargetRole = (typeof TargetRole)[keyof typeof TargetRole];

/**
 * Semantic intent detected for one source section.
 *
 * Captures section-level meaning so mixed-concern source files can be
 * decomposed into multiple Codex-native surfaces deterministically. String
 * values are preserved verbatim from the Python `SectionIntentKind` enum.
 */
export const SectionIntentKind = {
  IDENTITY: "identity",
  STANDING_GUIDANCE: "standing-guidance",
  SHARED_WORKFLOW: "shared-workflow",
  HOOK_CANDIDATE: "hook-candidate",
  RULE_CANDIDATE: "rule-candidate",
  CONFIG_CANDIDATE: "config-candidate",
  LAUNCHER_ONLY: "launcher-only",
  UNSUPPORTED: "unsupported",
} as const;

/** Union of {@link SectionIntentKind} string values. */
export type SectionIntentKind =
  (typeof SectionIntentKind)[keyof typeof SectionIntentKind];

/**
 * One low-level semantic cue discovered in a source section.
 *
 * String values are preserved verbatim from the Python `SemanticCueKind` enum.
 */
export const SemanticCueKind = {
  HEADING: "heading",
  NUMBERED_WORKFLOW: "numbered-workflow",
  HARD_GATE: "hard-gate",
  FORBIDDEN_PATTERN: "forbidden-pattern",
  LAUNCHER_WRAPPER: "launcher-wrapper",
  TOOL_REQUIREMENT: "tool-requirement",
} as const;

/** Union of {@link SemanticCueKind} string values. */
export type SemanticCueKind =
  (typeof SemanticCueKind)[keyof typeof SemanticCueKind];

/**
 * One semantic cue detected in a source section.
 *
 * Preserves the evidence that led a section classifier toward one intent.
 */
export interface SemanticCue {
  readonly kind: SemanticCueKind;
  readonly value: string;
}

/**
 * One parsed section from a source artifact.
 *
 * Preserves heading structure, source spans, and semantic cues so mixed
 * artifacts can be translated section by section.
 */
export interface SourceSection {
  readonly sectionId: string;
  readonly heading: string;
  readonly level: number;
  readonly content: string;
  readonly startLine: number;
  readonly endLine: number;
  readonly cues: ReadonlyArray<SemanticCue>;
}

/**
 * Classified intent for one parsed source section.
 *
 * Separates section meaning from final target planning so planners can map one
 * source file to multiple native destinations.
 */
export interface SectionIntent {
  readonly sourcePath: string;
  readonly sectionId: string;
  readonly heading: string;
  readonly intentKind: SectionIntentKind;
  readonly notes: ReadonlyArray<string>;
}

/**
 * One planned native emission for one source section.
 *
 * Captures section-level mapping decisions before final rendering or
 * validation.
 */
export interface PlannedEmission {
  readonly sourcePath: string;
  readonly sectionId: string;
  readonly heading: string;
  readonly intentKind: SectionIntentKind;
  readonly targetRole: TargetRole;
  readonly targetPath: string | null;
  readonly notes: ReadonlyArray<string>;
}

/**
 * One section-level source-to-native translation trace.
 *
 * Provides a report-friendly trace of how one source section maps to one
 * native target or unresolved native concept.
 */
export interface TranslationTrace {
  readonly sourcePath: string;
  readonly sectionId: string;
  readonly heading: string;
  readonly intentKind: SectionIntentKind;
  readonly targetRole: TargetRole;
  readonly targetPath: string | null;
  readonly notes: ReadonlyArray<string>;
}

/**
 * Serialize one planned emission to a JSON-friendly object.
 *
 * Preserves the Python `_serialize_planned_emission` key names and value shapes
 * (snake_case keys, enum string values, notes as a plain array).
 *
 * @param emission Planned emission to serialize.
 * @returns A JSON-safe representation of the planned emission.
 */
export function plannedEmissionToJson(
  emission: PlannedEmission,
): Record<string, unknown> {
  return {
    source_path: emission.sourcePath,
    section_id: emission.sectionId,
    heading: emission.heading,
    intent_kind: emission.intentKind,
    target_role: emission.targetRole,
    target_path: emission.targetPath,
    notes: [...emission.notes],
  };
}

/**
 * Serialize one section intent to a JSON-friendly object.
 *
 * Preserves the Python `_serialize_section_intent` key names and value shapes.
 *
 * @param intent Section intent to serialize.
 * @returns A JSON-safe representation of the section intent.
 */
export function sectionIntentToJson(
  intent: SectionIntent,
): Record<string, unknown> {
  return {
    source_path: intent.sourcePath,
    section_id: intent.sectionId,
    heading: intent.heading,
    intent_kind: intent.intentKind,
    notes: [...intent.notes],
  };
}

/**
 * Serialize one translation trace to a JSON-friendly object.
 *
 * Preserves the Python `_serialize_translation_trace` key names and value
 * shapes.
 *
 * @param trace Translation trace to serialize.
 * @returns A JSON-safe representation of the translation trace.
 */
export function translationTraceToJson(
  trace: TranslationTrace,
): Record<string, unknown> {
  return {
    source_path: trace.sourcePath,
    section_id: trace.sectionId,
    heading: trace.heading,
    intent_kind: trace.intentKind,
    target_role: trace.targetRole,
    target_path: trace.targetPath,
    notes: [...trace.notes],
  };
}
