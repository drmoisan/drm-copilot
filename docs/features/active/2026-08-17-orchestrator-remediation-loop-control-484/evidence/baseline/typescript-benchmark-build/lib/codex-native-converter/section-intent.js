"use strict";
/**
 * Classify source sections into semantic intent kinds for native translation.
 *
 * Purpose:
 *     Provide content-aware section classification so mixed-concern source
 *     files can be decomposed into distinct Codex-native surfaces
 *     deterministically. Ported from `section_intent.py`; pure logic, no I/O.
 *
 * Flow:
 *     One {@link SourceSection} is inspected using its attached
 *     {@link SemanticCue} instances and heading text. The function returns a
 *     {@link SectionIntent} with one of the eight supported intent kinds.
 *
 * Invariants:
 *     A section is classified as `unsupported` when no cue pattern or heading
 *     keyword matches; the function never throws for unrecognized content.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.classifySectionIntent = classifySectionIntent;
const models_1 = require("./models");
// Heading keywords indicating identity or overview content.
const IDENTITY_HEADING_PATTERN = /\b(overview|about|introduction|what is|who |identity|name|role|purpose)\b/i;
// Heading keywords suggesting rule-level policy content.
const RULE_HEADING_PATTERN = /\b(rule|policy|constraint|convention|standard|principle|guideline)\b/i;
// Heading keywords suggesting configuration, settings, or permissions content.
const CONFIG_HEADING_PATTERN = /\b(setting|config|permission|option|flag|parameter|environment|env)\b/i;
/**
 * Return the set of cue kinds present in a section.
 *
 * @param section Section whose cues to inspect.
 * @returns The set of cue kinds attached to the section.
 */
function cueKinds(section) {
    return new Set(section.cues.map((cue) => cue.kind));
}
/**
 * Build a {@link SectionIntent} record with shared fields populated.
 *
 * @param section Section being classified.
 * @param sourceArtifact Owning artifact (supplies the source path).
 * @param intentKind Selected intent kind.
 * @param note Single note describing the decision.
 * @returns The constructed section intent.
 */
function buildIntent(section, sourceArtifact, intentKind, note) {
    return {
        sourcePath: sourceArtifact.sourcePath,
        sectionId: section.sectionId,
        heading: section.heading,
        intentKind,
        notes: [note],
    };
}
/**
 * Classify one parsed section into a semantic intent kind.
 *
 * Mirrors `classify_section_intent`, preserving every branch, intent kind, and
 * note string verbatim and in the same evaluation order.
 *
 * @param section Parsed section to classify.
 * @param sourceArtifact Artifact that owns the section.
 * @returns A {@link SectionIntent} with a non-null intent kind.
 */
function classifySectionIntent(section, sourceArtifact) {
    const cues = cueKinds(section);
    const heading = section.heading;
    // Launcher-only blocks: a launcher-prompt section that has only a launcher
    // wrapper cue and no workflow/enforcement signals stays a launcher.
    if (sourceArtifact.sourceKind === models_1.SourceKind.LAUNCHER_PROMPT &&
        cues.has(models_1.SemanticCueKind.LAUNCHER_WRAPPER) &&
        !cues.has(models_1.SemanticCueKind.HARD_GATE) &&
        !cues.has(models_1.SemanticCueKind.FORBIDDEN_PATTERN) &&
        !cues.has(models_1.SemanticCueKind.NUMBERED_WORKFLOW)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.LAUNCHER_ONLY, "Section is a launcher-only block in a launcher-prompt source.");
    }
    // Hard-gate or forbidden-action language maps to a native enforcement hook.
    if (cues.has(models_1.SemanticCueKind.HARD_GATE) ||
        cues.has(models_1.SemanticCueKind.FORBIDDEN_PATTERN)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.HOOK_CANDIDATE, "Section contains hard-gate or forbidden-action language that maps " +
            "to a native enforcement hook.");
    }
    // Numbered-workflow structures map to a reusable shared skill.
    if (cues.has(models_1.SemanticCueKind.NUMBERED_WORKFLOW)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.SHARED_WORKFLOW, "Section contains numbered-workflow structure suitable for a shared " +
            "skill.");
    }
    // Tool-requirement cue with a config-like heading -> config candidate.
    if (cues.has(models_1.SemanticCueKind.TOOL_REQUIREMENT) &&
        CONFIG_HEADING_PATTERN.test(heading)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.CONFIG_CANDIDATE, "Section references tool requirements and has a config-like heading.");
    }
    // Tool-requirement cue with a rule-like heading -> rule candidate.
    if (cues.has(models_1.SemanticCueKind.TOOL_REQUIREMENT) &&
        RULE_HEADING_PATTERN.test(heading)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.RULE_CANDIDATE, "Section references tool requirements and has a rule-like heading.");
    }
    // Rule-like headings without tool requirements also map to rule_candidate.
    if (RULE_HEADING_PATTERN.test(heading)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.RULE_CANDIDATE, "Section heading indicates rule or policy content.");
    }
    // Config-like headings without tool requirements map to config_candidate.
    if (CONFIG_HEADING_PATTERN.test(heading)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.CONFIG_CANDIDATE, "Section heading indicates configuration or settings content.");
    }
    // Identity-like headings map to an identity/overview intent.
    if (IDENTITY_HEADING_PATTERN.test(heading)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.IDENTITY, "Section heading indicates identity or overview content.");
    }
    // A heading cue with no specific signal becomes general standing guidance.
    if (cues.has(models_1.SemanticCueKind.HEADING)) {
        return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.STANDING_GUIDANCE, "Section has a heading but no specific enforcement, workflow, or " +
            "config signal; classified as standing guidance.");
    }
    // No matching cue pattern; classify as unsupported (fail-closed) rather than
    // raising, preserving validation behavior.
    return buildIntent(section, sourceArtifact, models_1.SectionIntentKind.UNSUPPORTED, "No matching cue pattern or heading keyword was found for this section.");
}
