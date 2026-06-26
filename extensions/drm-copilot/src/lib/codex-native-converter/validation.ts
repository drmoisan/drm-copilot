/**
 * Validate planned conversions for the Codex-native converter.
 *
 * Purpose:
 *     Enforce the converter's fail-closed rules before apply mode writes native
 *     output. Ported from `validation.py`; pure logic, no I/O.
 *
 * Invariants:
 *     Blocking failures are reported explicitly with stable codes so review and
 *     apply mode share one auditable validation contract. Findings are returned
 *     in a deterministic sorted order.
 */

import {
  ConversionClass,
  type MappingRecord,
  type PlannedEmission,
  type RunOptions,
  TargetRole,
  type ValidationFinding,
} from "./models";
import { detectUnresolvedRuntimeReference } from "./rewrites";

// Note-flag substrings mapped to the finding code and message they raise,
// mirroring `_NOTE_FLAG_TO_FINDING`.
const NOTE_FLAG_TO_FINDING: ReadonlyArray<readonly [string, string, string]> = [
  [
    "requires-native-hard-gate",
    "unresolved-hard-gate-mapping",
    "Source artifact requires a native hard-gate mapping that is not yet resolved.",
  ],
  [
    "requires-handoff-review",
    "unresolved-handoff-mapping",
    "Source artifact requires handoff or delegation behavior that is not " +
      "yet resolved.",
  ],
  [
    "requires-mcp-rewrite",
    "unresolved-mcp-rewrite",
    "Source artifact requires a semantic MCP rewrite that is not yet resolved.",
  ],
  [
    "malformed-source-artifact",
    "malformed-source-artifact",
    "Source artifact metadata or content is malformed for v1 conversion.",
  ],
];

/**
 * Build a validation finding with a severity derived from the blocking flag.
 *
 * Mirrors `_build_finding`.
 *
 * @param options Finding code/blocking/paths/message/recommendedAction.
 * @returns The normalized validation finding.
 */
function buildFinding(options: {
  readonly code: string;
  readonly blocking: boolean;
  readonly sourcePath: string | null;
  readonly targetPath: string | null;
  readonly message: string;
  readonly recommendedAction: string;
}): ValidationFinding {
  return {
    code: options.code,
    severity: options.blocking ? "error" : "warning",
    blocking: options.blocking,
    sourcePath: options.sourcePath,
    targetPath: options.targetPath,
    message: options.message,
    recommendedAction: options.recommendedAction,
  };
}

/**
 * Validate run options that gate review and apply execution.
 *
 * Mirrors `_validate_required_inputs`.
 *
 * @param runOptions Requested converter run options.
 * @returns Findings for missing required inputs.
 */
function validateRequiredInputs(runOptions: RunOptions): ValidationFinding[] {
  const findings: ValidationFinding[] = [];
  if (runOptions.mode === "apply" && runOptions.destinationRoot === null) {
    findings.push(
      buildFinding({
        code: "missing-required-input",
        blocking: true,
        sourcePath: null,
        targetPath: null,
        message: "Apply mode requires an explicit destination root.",
        recommendedAction:
          "Provide destination_root before running apply mode.",
      }),
    );
  }
  return findings;
}

/**
 * Validate classified and mapped records for unsupported or flagged states.
 *
 * Mirrors `_validate_mapping_records`.
 *
 * @param mappingRecords Planned mappings for the current run.
 * @returns Findings derived from mapping records.
 */
function validateMappingRecords(
  mappingRecords: ReadonlyArray<MappingRecord>,
): ValidationFinding[] {
  const findings: ValidationFinding[] = [];

  for (const mappingRecord of mappingRecords) {
    // A required artifact with no safe mapping is a blocking finding.
    if (
      (mappingRecord.conversionClass === ConversionClass.UNSUPPORTED ||
        mappingRecord.targetRole === TargetRole.UNSUPPORTED) &&
      mappingRecord.isRequired
    ) {
      findings.push(
        buildFinding({
          code: "unsupported-ecosystem",
          blocking: true,
          sourcePath: mappingRecord.sourcePath,
          targetPath: mappingRecord.targetPath,
          message: "Required source artifact has no safe v1 mapping.",
          recommendedAction:
            "Review the artifact manually or add a verified " +
            "native mapping before apply mode.",
        }),
      );
    }

    // Each note may carry a flag that raises a specific unresolved finding.
    for (const note of mappingRecord.notes) {
      for (const [
        noteFlag,
        findingCode,
        findingMessage,
      ] of NOTE_FLAG_TO_FINDING) {
        if (note.includes(noteFlag)) {
          findings.push(
            buildFinding({
              code: findingCode,
              blocking: true,
              sourcePath: mappingRecord.sourcePath,
              targetPath: mappingRecord.targetPath,
              message: findingMessage,
              recommendedAction:
                "Resolve the flagged mapping or leave the " +
                "artifact in review-only status.",
            }),
          );
        }
      }
    }
  }

  return findings;
}

/**
 * Validate that planned target paths are unique.
 *
 * Mirrors `_validate_duplicate_targets`, including the `AGENTS.md`
 * standing-guidance exemption and the section-emission conflict detection.
 *
 * @param mappingRecords Planned mappings for the current run.
 * @param plannedEmissions Section-level planned emissions.
 * @returns Findings for duplicate target paths.
 */
function validateDuplicateTargets(
  mappingRecords: ReadonlyArray<MappingRecord>,
  plannedEmissions: ReadonlyArray<PlannedEmission>,
): ValidationFinding[] {
  const findings: ValidationFinding[] = [];
  const mappingRecordsByTarget = new Map<string, MappingRecord[]>();
  const sectionEmissionsByTarget = new Map<string, PlannedEmission[]>();

  // Group mapping records and planned emissions by their target path.
  for (const mappingRecord of mappingRecords) {
    if (mappingRecord.targetPath === null) {
      continue;
    }
    const group = mappingRecordsByTarget.get(mappingRecord.targetPath) ?? [];
    group.push(mappingRecord);
    mappingRecordsByTarget.set(mappingRecord.targetPath, group);
  }
  for (const plannedEmission of plannedEmissions) {
    if (plannedEmission.targetPath === null) {
      continue;
    }
    const group =
      sectionEmissionsByTarget.get(plannedEmission.targetPath) ?? [];
    group.push(plannedEmission);
    sectionEmissionsByTarget.set(plannedEmission.targetPath, group);
  }

  // Count mapping-record targets to find duplicates.
  const targetCounts = new Map<string, number>();
  for (const mappingRecord of mappingRecords) {
    if (mappingRecord.targetPath === null) {
      continue;
    }
    targetCounts.set(
      mappingRecord.targetPath,
      (targetCounts.get(mappingRecord.targetPath) ?? 0) + 1,
    );
  }
  const duplicatedTargets = new Set<string>();
  for (const [targetPath, count] of targetCounts) {
    if (count > 1) {
      duplicatedTargets.add(targetPath);
    }
  }
  // AGENTS.md is exempt when every record targeting it is standing guidance.
  for (const [targetPath, records] of mappingRecordsByTarget) {
    if (
      targetPath === "AGENTS.md" &&
      records.every(
        (record) => record.targetRole === TargetRole.STANDING_GUIDANCE,
      )
    ) {
      duplicatedTargets.delete(targetPath);
    }
  }

  // Report every record participating in a duplicate target collision.
  for (const mappingRecord of mappingRecords) {
    if (
      mappingRecord.targetPath !== null &&
      duplicatedTargets.has(mappingRecord.targetPath)
    ) {
      findings.push(
        buildFinding({
          code: "duplicate-target-path",
          blocking: true,
          sourcePath: mappingRecord.sourcePath,
          targetPath: mappingRecord.targetPath,
          message:
            "Multiple source artifacts resolve to the same target " + "path.",
          recommendedAction:
            "Refine the mapping plan so each target path has " +
            "exactly one authoritative source.",
        }),
      );
    }
  }

  // A section-emission target conflicts when it also has a mapping record, or
  // when its emissions span more than one (source_path, target_role) pair.
  const conflictingTargets = new Set<string>();
  for (const [targetPath, sectionEmissions] of sectionEmissionsByTarget) {
    const distinctPairs = new Set(
      sectionEmissions.map(
        (emission) => `${emission.sourcePath}\u0000${emission.targetRole}`,
      ),
    );
    if (mappingRecordsByTarget.has(targetPath) || distinctPairs.size > 1) {
      conflictingTargets.add(targetPath);
    }
  }

  // Report conflicting section emissions in sorted target-path order.
  for (const targetPath of [...conflictingTargets].sort((left, right) =>
    left < right ? -1 : left > right ? 1 : 0,
  )) {
    for (const plannedEmission of sectionEmissionsByTarget.get(targetPath) ??
      []) {
      findings.push(
        buildFinding({
          code: "duplicate-target-path",
          blocking: true,
          sourcePath: plannedEmission.sourcePath,
          targetPath,
          message:
            "Multiple planned emissions resolve to the same target path.",
          recommendedAction:
            "Refine the section-level mapping plan so each target path has " +
            "exactly one authoritative emission group.",
        }),
      );
    }
  }

  return findings;
}

/**
 * Validate generated output text for lingering runtime references.
 *
 * Mirrors `_validate_generated_output`.
 *
 * @param generatedOutput Generated output keyed by target path.
 * @returns Findings for lingering runtime references.
 */
function validateGeneratedOutput(
  generatedOutput: Readonly<Record<string, string>>,
): ValidationFinding[] {
  const findings: ValidationFinding[] = [];

  // Scan every generated target body after rewrites so apply mode fails closed
  // when native outputs still mention source-runtime surfaces.
  for (const targetPath of Object.keys(generatedOutput)) {
    const renderedText = generatedOutput[targetPath] ?? "";
    const unresolvedReferences = detectUnresolvedRuntimeReference(renderedText);
    if (unresolvedReferences.length > 0) {
      findings.push(
        buildFinding({
          code: "lingering-source-runtime-reference",
          blocking: true,
          sourcePath: null,
          targetPath,
          message:
            "Generated output retains unresolved source-runtime " +
            "references: " +
            unresolvedReferences.join(", "),
          recommendedAction:
            "Add a verified rewrite or adjust the generated " +
            "content before apply mode.",
        }),
      );
    }
  }

  return findings;
}

/**
 * Validate one planned conversion run.
 *
 * Mirrors `validate_conversion_plan`: applies the required-input, mapping,
 * duplicate-target, and generated-output checks, then sorts findings by
 * (code, sourcePath, targetPath) with null paths treated as the empty string.
 *
 * @param runOptions Requested converter run options.
 * @param mappingRecords Planned mappings for the current run.
 * @param plannedEmissions Section-level planned emissions for the current run.
 * @param generatedOutput Generated output keyed by target path.
 * @returns Validation findings sorted by stable key.
 */
export function validateConversionPlan(
  runOptions: RunOptions,
  mappingRecords: ReadonlyArray<MappingRecord>,
  plannedEmissions: ReadonlyArray<PlannedEmission>,
  generatedOutput: Readonly<Record<string, string>>,
): ReadonlyArray<ValidationFinding> {
  const findings: ValidationFinding[] = [
    ...validateRequiredInputs(runOptions),
    ...validateMappingRecords(mappingRecords),
    ...validateDuplicateTargets(mappingRecords, plannedEmissions),
    ...validateGeneratedOutput(generatedOutput),
  ];

  // Sort by (code, sourcePath, targetPath); null paths sort as empty strings.
  const compare = (left: string, right: string): number =>
    left < right ? -1 : left > right ? 1 : 0;
  return [...findings].sort((left, right) => {
    const byCode = compare(left.code, right.code);
    if (byCode !== 0) {
      return byCode;
    }
    const bySource = compare(left.sourcePath ?? "", right.sourcePath ?? "");
    if (bySource !== 0) {
      return bySource;
    }
    return compare(left.targetPath ?? "", right.targetPath ?? "");
  });
}
