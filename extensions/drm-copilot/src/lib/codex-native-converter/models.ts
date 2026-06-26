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

import { toPosixPath } from "../file-system";
import {
  type SemanticCue,
  type SourceSection,
  type TargetRole,
} from "./models-intermediate";

// Re-export the intermediate types so consumers import a single contract
// surface, mirroring the Python `models.py` re-exports and `__all__`.
export {
  PlannedEmission,
  SectionIntent,
  SectionIntentKind,
  SemanticCue,
  SemanticCueKind,
  SourceSection,
  TargetRole,
  TranslationTrace,
  plannedEmissionToJson,
  sectionIntentToJson,
  translationTraceToJson,
} from "./models-intermediate";

/**
 * Supported source runtime ecosystem.
 *
 * Identifies the top-level ecosystem the converter should interpret. String
 * values are preserved verbatim from the Python `SourceEcosystem` enum.
 */
export const SourceEcosystem = {
  GITHUB_COPILOT: "github-copilot",
  CLAUDE: "claude",
} as const;

/** Union of {@link SourceEcosystem} string values. */
export type SourceEcosystem =
  (typeof SourceEcosystem)[keyof typeof SourceEcosystem];

/**
 * Type of source artifact discovered in a source tree.
 *
 * Captures the role a source file or folder plays before conversion logic
 * decides whether it maps directly, decomposes, or fails as unsupported.
 * String values are preserved verbatim from the Python `SourceKind` enum.
 */
export const SourceKind = {
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
} as const;

/** Union of {@link SourceKind} string values. */
export type SourceKind = (typeof SourceKind)[keyof typeof SourceKind];

/**
 * How a source artifact should be converted.
 *
 * String values are preserved verbatim from the Python `ConversionClass` enum.
 */
export const ConversionClass = {
  DIRECT: "direct",
  DECOMPOSED: "decomposed",
  REPO_CONVENTION: "repo-convention",
  UNSUPPORTED: "unsupported",
} as const;

/** Union of {@link ConversionClass} string values. */
export type ConversionClass =
  (typeof ConversionClass)[keyof typeof ConversionClass];

/**
 * One parsed source artifact with structured sections.
 *
 * Carries file-level metadata and section structure through the compiler-style
 * translation pipeline.
 */
export interface SourceArtifact {
  readonly sourcePath: string;
  readonly sourceEcosystem: SourceEcosystem;
  readonly sourceKind: SourceKind;
  readonly frontmatter: Readonly<Record<string, string>>;
  readonly rawText: string;
  readonly sections: ReadonlyArray<SourceSection>;
}

/**
 * Planned conversion of one source artifact.
 *
 * Carries the normalized classification, mapping, and rewrite details for a
 * single source artifact from analysis through reporting. Paths are stored as
 * normalized relative text.
 */
export interface MappingRecord {
  readonly sourcePath: string;
  readonly sourceEcosystem: SourceEcosystem;
  readonly sourceKind: SourceKind;
  readonly conversionClass: ConversionClass;
  readonly targetRole: TargetRole;
  readonly targetPath: string | null;
  readonly notes: ReadonlyArray<string>;
  readonly isRequired: boolean;
}

/**
 * One source-to-destination relationship for reporting.
 *
 * Captures the topology relationships the report should visualize, including
 * decomposition fan-out and merged-target fan-in.
 */
export interface TopologyEdge {
  readonly sourcePath: string;
  readonly destinationPath: string;
}

/**
 * One validation result emitted by the converter.
 *
 * Captures blocking and non-blocking validation outcomes in a form that the
 * CLI, reports, and wrappers can all reuse.
 */
export interface ValidationFinding {
  readonly code: string;
  readonly severity: string;
  readonly blocking: boolean;
  readonly sourcePath: string | null;
  readonly targetPath: string | null;
  readonly message: string;
  readonly recommendedAction: string;
}

/**
 * One requested converter run.
 *
 * Bundles the validated inputs that control review or apply execution. Source
 * and output roots are stored as absolute normalized POSIX paths.
 */
export interface RunOptions {
  readonly mode: string;
  readonly sourceRoot: string;
  readonly sourceEcosystem: SourceEcosystem;
  readonly selectedPaths: ReadonlyArray<string>;
  readonly destinationRoot: string | null;
  readonly artifactRoot: string;
  readonly enableRepoPrompts: boolean;
  readonly emitIntermediateState: boolean;
}

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
export function mappingRecordToJson(
  record: MappingRecord,
): Record<string, unknown> {
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
export function validationFindingToJson(
  finding: ValidationFinding,
): Record<string, unknown> {
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
export function runOptionsToJson(options: RunOptions): Record<string, unknown> {
  return {
    mode: options.mode,
    source_root: toPosixPath(options.sourceRoot),
    source_ecosystem: options.sourceEcosystem,
    selected_paths: options.selectedPaths.map((path) => toPosixPath(path)),
    destination_root:
      options.destinationRoot !== null
        ? toPosixPath(options.destinationRoot)
        : null,
    artifact_root: toPosixPath(options.artifactRoot),
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
export function sourceArtifactToJson(
  artifact: SourceArtifact,
): Record<string, unknown> {
  const sortedFrontmatter: Record<string, string> = {};
  // Sort frontmatter keys to match Python `dict(sorted(...))` determinism.
  for (const key of Object.keys(artifact.frontmatter).sort((left, right) =>
    left < right ? -1 : left > right ? 1 : 0,
  )) {
    sortedFrontmatter[key] = artifact.frontmatter[key] as string;
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
      cues: section.cues.map((cue: SemanticCue) => ({
        kind: cue.kind,
        value: cue.value,
      })),
    })),
  };
}
