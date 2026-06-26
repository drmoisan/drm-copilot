/**
 * Public surface for the Codex-native converter port.
 *
 * Purpose:
 *     Re-export the models/enums, the engine review/apply entry points and run
 *     result, the CLI command surface, and the report/topology helpers. Mirrors
 *     the role of `codex_native_converter/__init__.py` while exposing the full
 *     in-process API the service helper and tests consume.
 *
 * Invariants:
 *     This module adds no behavior; it only re-exports the converter contract.
 */

export {
  ConversionClass,
  type MappingRecord,
  mappingRecordToJson,
  PlannedEmission,
  type RunOptions,
  runOptionsToJson,
  SectionIntent,
  SectionIntentKind,
  SemanticCue,
  SemanticCueKind,
  type SourceArtifact,
  SourceEcosystem,
  SourceKind,
  type SourceSection,
  sourceArtifactToJson,
  TargetRole,
  type TopologyEdge,
  TranslationTrace,
  type ValidationFinding,
  validationFindingToJson,
} from "./models";

export {
  type ConversionRunResult,
  runApplyMode,
  runReviewMode,
} from "./engine";

export {
  apply,
  type ConverterCommandOptions,
  type ConverterCommandOutcome,
  printRunSummary,
  resolveRunOptions,
  resolveSourceEcosystem,
  review,
} from "./cli";

export { type ReportSetPaths, writeConversionReportSet } from "./reporting";

export {
  renderDestinationToRepeatedSourceChart,
  renderSourceToDestinationChart,
  renderSourceToRepeatedDestinationChart,
} from "./reporting-topology";
