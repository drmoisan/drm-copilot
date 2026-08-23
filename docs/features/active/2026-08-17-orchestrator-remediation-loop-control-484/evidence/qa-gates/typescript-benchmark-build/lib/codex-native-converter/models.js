"use strict";
/**
 * Typed domain models for the Codex-native converter.
 *
 * Purpose:
 *     Centralize the typed enums and value objects that the converter uses to
 *     classify source artifacts, plan targets, report findings, and describe a
 *     conversion run. Ported from `models.py`; re-exports the intermediate
 *     types from `models-intermediate.ts` so consumers share one contract.
 *
 * Invariants:
 *     Relative paths recorded by these models stay normalized to POSIX-style
 *     text so report output remains deterministic across operating systems.
 */
Object.defineProperty(exports, "__esModule", { value: true });
exports.ConversionClass = exports.SourceKind = exports.SourceEcosystem = exports.translationTraceToJson = exports.sectionIntentToJson = exports.plannedEmissionToJson = exports.TargetRole = exports.SemanticCueKind = exports.SectionIntentKind = void 0;
exports.mappingRecordToJson = mappingRecordToJson;
exports.validationFindingToJson = validationFindingToJson;
exports.runOptionsToJson = runOptionsToJson;
exports.sourceArtifactToJson = sourceArtifactToJson;
const file_system_1 = require("../file-system");
// Re-export the intermediate types so consumers import a single contract
// surface, mirroring the Python `models.py` re-exports and `__all__`.
var models_intermediate_1 = require("./models-intermediate");
Object.defineProperty(exports, "SectionIntentKind", { enumerable: true, get: function () { return models_intermediate_1.SectionIntentKind; } });
Object.defineProperty(exports, "SemanticCueKind", { enumerable: true, get: function () { return models_intermediate_1.SemanticCueKind; } });
Object.defineProperty(exports, "TargetRole", { enumerable: true, get: function () { return models_intermediate_1.TargetRole; } });
Object.defineProperty(exports, "plannedEmissionToJson", { enumerable: true, get: function () { return models_intermediate_1.plannedEmissionToJson; } });
Object.defineProperty(exports, "sectionIntentToJson", { enumerable: true, get: function () { return models_intermediate_1.sectionIntentToJson; } });
Object.defineProperty(exports, "translationTraceToJson", { enumerable: true, get: function () { return models_intermediate_1.translationTraceToJson; } });
/**
 * Supported source runtime ecosystem.
 *
 * Identifies the top-level ecosystem the converter should interpret. String
 * values are preserved verbatim from the Python `SourceEcosystem` enum.
 */
exports.SourceEcosystem = {
    GITHUB_COPILOT: "github-copilot",
    CLAUDE: "claude",
};
/**
 * Type of source artifact discovered in a source tree.
 *
 * Captures the role a source file or folder plays before conversion logic
 * decides whether it maps directly, decomposes, or fails as unsupported.
 * String values are preserved verbatim from the Python `SourceKind` enum.
 */
exports.SourceKind = {
    STANDING_INSTRUCTION: "standing-instruction",
    PATH_SCOPED_INSTRUCTION: "path-scoped-instruction",
    REUSABLE_SKILL: "reusable-skill",
    AGENT_MANIFEST: "agent-manifest",
    LAUNCHER_PROMPT: "launcher-prompt",
    HOOK_DEFINITION: "hook-definition",
    PERMISSIONS_OR_SETTINGS: "permissions-or-settings",
    SHELL_POLICY_OR_RULE: "shell-policy-or-rule",
    MCP_DEPENDENCY_DECLARATION: "mcp-dependency-declaration",
    HOST_ADAPTER_REFERENCE: "host-adapter-reference",
    UNKNOWN: "unknown",
};
/**
 * How a source artifact should be converted.
 *
 * String values are preserved verbatim from the Python `ConversionClass` enum.
 */
exports.ConversionClass = {
    DIRECT: "direct",
    DECOMPOSED: "decomposed",
    REPO_CONVENTION: "repo-convention",
    UNSUPPORTED: "unsupported",
};
/**
 * Serialize one mapping record to a JSON-friendly object.
 *
 * Preserves the Python `MappingRecord.to_json_dict` key names, ordering, and
 * value shapes (enum string values, notes as a plain array, the default
 * `is_required` true).
 *
 * @param record Mapping record to serialize.
 * @returns A JSON-safe representation of the mapping record.
 */
function mappingRecordToJson(record) {
    return {
        source_path: record.sourcePath,
        source_ecosystem: record.sourceEcosystem,
        source_kind: record.sourceKind,
        conversion_class: record.conversionClass,
        target_role: record.targetRole,
        target_path: record.targetPath,
        notes: [...record.notes],
        is_required: record.isRequired,
    };
}
/**
 * Serialize one validation finding to a JSON-friendly object.
 *
 * Preserves the Python `ValidationFinding.to_json_dict` key names and value
 * shapes, including null source/target paths.
 *
 * @param finding Validation finding to serialize.
 * @returns A JSON-safe representation of the validation finding.
 */
function validationFindingToJson(finding) {
    return {
        code: finding.code,
        severity: finding.severity,
        blocking: finding.blocking,
        source_path: finding.sourcePath,
        target_path: finding.targetPath,
        message: finding.message,
        recommended_action: finding.recommendedAction,
    };
}
/**
 * Serialize one run-options value to a JSON-friendly object.
 *
 * Preserves the Python `RunOptions.to_json_dict` semantics: POSIX path
 * conversion (`as_posix` equivalent via {@link toPosixPath}), the
 * `selected_paths` array, and the `destination_root` null handling.
 *
 * @param options Run options to serialize.
 * @returns A JSON-safe representation of the run options.
 */
function runOptionsToJson(options) {
    return {
        mode: options.mode,
        source_root: (0, file_system_1.toPosixPath)(options.sourceRoot),
        source_ecosystem: options.sourceEcosystem,
        selected_paths: options.selectedPaths.map((path) => (0, file_system_1.toPosixPath)(path)),
        destination_root: options.destinationRoot !== null
            ? (0, file_system_1.toPosixPath)(options.destinationRoot)
            : null,
        artifact_root: (0, file_system_1.toPosixPath)(options.artifactRoot),
        enable_repo_prompts: options.enableRepoPrompts,
        emit_intermediate_state: options.emitIntermediateState,
    };
}
/**
 * Serialize one source artifact to a JSON-friendly object.
 *
 * Mirrors the Python `intermediate_state._serialize_source_artifact`: sorts
 * frontmatter keys, and serializes each section's id/heading/level/spans/cues.
 *
 * @param artifact Source artifact to serialize.
 * @returns A JSON-safe representation of the source artifact.
 */
function sourceArtifactToJson(artifact) {
    const sortedFrontmatter = {};
    // Sort frontmatter keys to match Python `dict(sorted(...))` determinism.
    for (const key of Object.keys(artifact.frontmatter).sort((left, right) => left < right ? -1 : left > right ? 1 : 0)) {
        sortedFrontmatter[key] = artifact.frontmatter[key];
    }
    return {
        source_path: artifact.sourcePath,
        source_ecosystem: artifact.sourceEcosystem,
        source_kind: artifact.sourceKind,
        frontmatter: sortedFrontmatter,
        sections: artifact.sections.map((section) => ({
            section_id: section.sectionId,
            heading: section.heading,
            level: section.level,
            start_line: section.startLine,
            end_line: section.endLine,
            cues: section.cues.map((cue) => ({
                kind: cue.kind,
                value: cue.value,
            })),
        })),
    };
}
