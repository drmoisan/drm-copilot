import {
  normalizeOptionalText,
  normalizeRequiredText,
  normalizeWorkspaceRoot,
  validateChoice,
} from "./workflow-command-arguments";
import { asToolArgumentObject } from "./mcp-tool-inputs";
import type {
  RunDiscoveryAnalyzerInput,
  RunDiscoveryInitInput,
  RunDiscoveryReportInput,
  RunDiscoveryScenarioGenerationInput,
  ValidateDiscoveryArtifactsInput,
} from "./repo-automation-execute-discovery";

/**
 * Enum constants for the discovery tools (the single source of these literals).
 *
 * `DISCOVERY_ARTIFACT_TYPES` are the landed `validate_discovery_artifacts`
 * kinds plus `all`; `DISCOVERY_REPORT_TYPES` are the landed `run_discovery_report`
 * report kinds. The tool definitions consume these constants and the contract
 * tests assert equality, so the enum literals live only in this module and the
 * central mapping table.
 */
export const DISCOVERY_ARTIFACT_TYPES = [
  "profile",
  "feature-contract",
  "coverage-ledger",
  "runtime-scenario",
  "parity-matrix",
  "unspecified-behavior",
  "product-decision",
  "evidence-reference",
  "all",
] as const;

export const DISCOVERY_REPORT_TYPES = [
  "coverage",
  "parity",
  "completion",
] as const;

export type DiscoveryArtifactType = (typeof DISCOVERY_ARTIFACT_TYPES)[number];
export type DiscoveryReportType = (typeof DISCOVERY_REPORT_TYPES)[number];

/**
 * Validates an optional boolean field, throwing on a non-boolean value.
 *
 * @param value The raw field value.
 * @param fieldName The field name used in the error message.
 * @returns The boolean value, or `undefined` when omitted.
 * @throws Error when the value is present but not a boolean.
 */
function normalizeOptionalBoolean(
  value: unknown,
  fieldName: string,
): boolean | undefined {
  if (value === undefined) {
    return undefined;
  }
  if (typeof value !== "boolean") {
    throw new Error(`Field '${fieldName}' must be a boolean when provided.`);
  }
  return value;
}

/**
 * Resolves the raw MCP arguments for `validate_discovery_artifacts`.
 *
 * @throws Error when `artifact_type` is missing/out-of-enum or `artifact_path`
 *   is missing/non-string.
 */
export function resolveValidateDiscoveryArtifactsToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): ValidateDiscoveryArtifactsInput {
  const args = asToolArgumentObject(rawInput);
  const artifactType = validateChoice(
    normalizeRequiredText(args["artifact_type"], "artifact_type"),
    "artifact_type",
    DISCOVERY_ARTIFACT_TYPES,
  );
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    artifactType,
    artifactPath: normalizeRequiredText(args["artifact_path"], "artifact_path"),
  };
}

/**
 * Resolves the raw MCP arguments for `run_discovery_init`.
 *
 * @throws Error when `target_dir` is missing/non-string, or when
 *   `template_root`/`force` are present with the wrong type.
 */
export function resolveRunDiscoveryInitToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryInitInput {
  const args = asToolArgumentObject(rawInput);
  const templateRoot = normalizeOptionalText(
    args["template_root"],
    "template_root",
  );
  const force = normalizeOptionalBoolean(args["force"], "force");
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    targetDir: normalizeRequiredText(args["target_dir"], "target_dir"),
    ...(templateRoot === undefined ? {} : { templateRoot }),
    ...(force === undefined ? {} : { force }),
  };
}

/**
 * Resolves the shared analyzer arguments (`profile_path`, `output_dir`) for the
 * repo-inventory, .NET, and VSTO analyzer tools.
 *
 * @throws Error when `profile_path`/`output_dir` are present with the wrong type.
 */
function resolveDiscoveryAnalyzerToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryAnalyzerInput {
  const args = asToolArgumentObject(rawInput);
  const profilePath = normalizeOptionalText(
    args["profile_path"],
    "profile_path",
  );
  const outputDir = normalizeOptionalText(args["output_dir"], "output_dir");
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    ...(profilePath === undefined ? {} : { profilePath }),
    ...(outputDir === undefined ? {} : { outputDir }),
  };
}

export function resolveRunDiscoveryRepoInventoryToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryAnalyzerInput {
  return resolveDiscoveryAnalyzerToolInput(rawInput, fallbackWorkspaceRoot);
}

export function resolveRunDiscoveryDotnetAnalyzerToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryAnalyzerInput {
  return resolveDiscoveryAnalyzerToolInput(rawInput, fallbackWorkspaceRoot);
}

export function resolveRunDiscoveryVstoAnalyzerToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryAnalyzerInput {
  return resolveDiscoveryAnalyzerToolInput(rawInput, fallbackWorkspaceRoot);
}

/**
 * Resolves the raw MCP arguments for `run_discovery_scenario_generation`.
 *
 * @throws Error when any of `feature_contract`, `parity_matrix`, or
 *   `runtime_characterization` is missing/non-string, or when
 *   `output_path`/`check` are present with the wrong type.
 */
export function resolveRunDiscoveryScenarioGenerationToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryScenarioGenerationInput {
  const args = asToolArgumentObject(rawInput);
  const outputPath = normalizeOptionalText(args["output_path"], "output_path");
  const check = normalizeOptionalBoolean(args["check"], "check");
  return {
    workspaceRoot: normalizeWorkspaceRoot(
      args["workspace_root"],
      fallbackWorkspaceRoot,
    ),
    featureContract: normalizeRequiredText(
      args["feature_contract"],
      "feature_contract",
    ),
    parityMatrix: normalizeRequiredText(args["parity_matrix"], "parity_matrix"),
    runtimeCharacterization: normalizeRequiredText(
      args["runtime_characterization"],
      "runtime_characterization",
    ),
    ...(outputPath === undefined ? {} : { outputPath }),
    ...(check === undefined ? {} : { check }),
  };
}

/**
 * Resolves the raw MCP arguments for `run_discovery_report`.
 *
 * The `report_type` enum drives the required-field check: `coverage`/`parity`
 * require `input_path`; `completion` requires both `coverage_input` and
 * `parity_input`. All checks run before any service or spawn work.
 *
 * @throws Error when `report_type` is missing/out-of-enum, when the
 *   report_type-specific required inputs are missing/non-string, or when
 *   `output_path` is present with the wrong type.
 */
export function resolveRunDiscoveryReportToolInput(
  rawInput: unknown,
  fallbackWorkspaceRoot?: string,
): RunDiscoveryReportInput {
  const args = asToolArgumentObject(rawInput);
  const reportType = validateChoice(
    normalizeRequiredText(args["report_type"], "report_type"),
    "report_type",
    DISCOVERY_REPORT_TYPES,
  );
  const outputPath = normalizeOptionalText(args["output_path"], "output_path");
  const workspaceRoot = normalizeWorkspaceRoot(
    args["workspace_root"],
    fallbackWorkspaceRoot,
  );

  if (reportType === "completion") {
    return {
      workspaceRoot,
      reportType,
      coverageInput: normalizeRequiredText(
        args["coverage_input"],
        "coverage_input",
      ),
      parityInput: normalizeRequiredText(args["parity_input"], "parity_input"),
      ...(outputPath === undefined ? {} : { outputPath }),
    };
  }

  return {
    workspaceRoot,
    reportType,
    inputPath: normalizeRequiredText(args["input_path"], "input_path"),
    ...(outputPath === undefined ? {} : { outputPath }),
  };
}
