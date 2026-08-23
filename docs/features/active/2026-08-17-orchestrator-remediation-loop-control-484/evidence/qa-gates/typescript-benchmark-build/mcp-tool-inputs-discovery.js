"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.DISCOVERY_REPORT_TYPES = exports.DISCOVERY_ARTIFACT_TYPES = void 0;
exports.resolveValidateDiscoveryArtifactsToolInput = resolveValidateDiscoveryArtifactsToolInput;
exports.resolveRunDiscoveryInitToolInput = resolveRunDiscoveryInitToolInput;
exports.resolveRunDiscoveryRepoInventoryToolInput = resolveRunDiscoveryRepoInventoryToolInput;
exports.resolveRunDiscoveryDotnetAnalyzerToolInput = resolveRunDiscoveryDotnetAnalyzerToolInput;
exports.resolveRunDiscoveryVstoAnalyzerToolInput = resolveRunDiscoveryVstoAnalyzerToolInput;
exports.resolveRunDiscoveryScenarioGenerationToolInput = resolveRunDiscoveryScenarioGenerationToolInput;
exports.resolveRunDiscoveryReportToolInput = resolveRunDiscoveryReportToolInput;
const workflow_command_arguments_1 = require("./workflow-command-arguments");
const mcp_tool_inputs_1 = require("./mcp-tool-inputs");
/**
 * Enum constants for the discovery tools (the single source of these literals).
 *
 * `DISCOVERY_ARTIFACT_TYPES` are the landed `validate_discovery_artifacts`
 * kinds plus `all`; `DISCOVERY_REPORT_TYPES` are the landed `run_discovery_report`
 * report kinds. The tool definitions consume these constants and the contract
 * tests assert equality, so the enum literals live only in this module and the
 * central mapping table.
 */
exports.DISCOVERY_ARTIFACT_TYPES = [
    "profile",
    "feature-contract",
    "coverage-ledger",
    "runtime-scenario",
    "parity-matrix",
    "unspecified-behavior",
    "product-decision",
    "evidence-reference",
    "all",
];
exports.DISCOVERY_REPORT_TYPES = [
    "coverage",
    "parity",
    "completion",
];
/**
 * Validates an optional boolean field, throwing on a non-boolean value.
 *
 * @param value The raw field value.
 * @param fieldName The field name used in the error message.
 * @returns The boolean value, or `undefined` when omitted.
 * @throws Error when the value is present but not a boolean.
 */
function normalizeOptionalBoolean(value, fieldName) {
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
function resolveValidateDiscoveryArtifactsToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    const artifactType = (0, workflow_command_arguments_1.validateChoice)((0, workflow_command_arguments_1.normalizeRequiredText)(args["artifact_type"], "artifact_type"), "artifact_type", exports.DISCOVERY_ARTIFACT_TYPES);
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        artifactType,
        artifactPath: (0, workflow_command_arguments_1.normalizeRequiredText)(args["artifact_path"], "artifact_path"),
    };
}
/**
 * Resolves the raw MCP arguments for `run_discovery_init`.
 *
 * @throws Error when `target_dir` is missing/non-string, or when
 *   `template_root`/`force` are present with the wrong type.
 */
function resolveRunDiscoveryInitToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    const templateRoot = (0, workflow_command_arguments_1.normalizeOptionalText)(args["template_root"], "template_root");
    const force = normalizeOptionalBoolean(args["force"], "force");
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        targetDir: (0, workflow_command_arguments_1.normalizeRequiredText)(args["target_dir"], "target_dir"),
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
function resolveDiscoveryAnalyzerToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    const profilePath = (0, workflow_command_arguments_1.normalizeOptionalText)(args["profile_path"], "profile_path");
    const outputDir = (0, workflow_command_arguments_1.normalizeOptionalText)(args["output_dir"], "output_dir");
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        ...(profilePath === undefined ? {} : { profilePath }),
        ...(outputDir === undefined ? {} : { outputDir }),
    };
}
function resolveRunDiscoveryRepoInventoryToolInput(rawInput, fallbackWorkspaceRoot) {
    return resolveDiscoveryAnalyzerToolInput(rawInput, fallbackWorkspaceRoot);
}
function resolveRunDiscoveryDotnetAnalyzerToolInput(rawInput, fallbackWorkspaceRoot) {
    return resolveDiscoveryAnalyzerToolInput(rawInput, fallbackWorkspaceRoot);
}
function resolveRunDiscoveryVstoAnalyzerToolInput(rawInput, fallbackWorkspaceRoot) {
    return resolveDiscoveryAnalyzerToolInput(rawInput, fallbackWorkspaceRoot);
}
/**
 * Resolves the raw MCP arguments for `run_discovery_scenario_generation`.
 *
 * @throws Error when any of `feature_contract`, `parity_matrix`, or
 *   `runtime_characterization` is missing/non-string, or when
 *   `output_path`/`check` are present with the wrong type.
 */
function resolveRunDiscoveryScenarioGenerationToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    const outputPath = (0, workflow_command_arguments_1.normalizeOptionalText)(args["output_path"], "output_path");
    const check = normalizeOptionalBoolean(args["check"], "check");
    return {
        workspaceRoot: (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot),
        featureContract: (0, workflow_command_arguments_1.normalizeRequiredText)(args["feature_contract"], "feature_contract"),
        parityMatrix: (0, workflow_command_arguments_1.normalizeRequiredText)(args["parity_matrix"], "parity_matrix"),
        runtimeCharacterization: (0, workflow_command_arguments_1.normalizeRequiredText)(args["runtime_characterization"], "runtime_characterization"),
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
function resolveRunDiscoveryReportToolInput(rawInput, fallbackWorkspaceRoot) {
    const args = (0, mcp_tool_inputs_1.asToolArgumentObject)(rawInput);
    const reportType = (0, workflow_command_arguments_1.validateChoice)((0, workflow_command_arguments_1.normalizeRequiredText)(args["report_type"], "report_type"), "report_type", exports.DISCOVERY_REPORT_TYPES);
    const outputPath = (0, workflow_command_arguments_1.normalizeOptionalText)(args["output_path"], "output_path");
    const workspaceRoot = (0, workflow_command_arguments_1.normalizeWorkspaceRoot)(args["workspace_root"], fallbackWorkspaceRoot);
    if (reportType === "completion") {
        return {
            workspaceRoot,
            reportType,
            coverageInput: (0, workflow_command_arguments_1.normalizeRequiredText)(args["coverage_input"], "coverage_input"),
            parityInput: (0, workflow_command_arguments_1.normalizeRequiredText)(args["parity_input"], "parity_input"),
            ...(outputPath === undefined ? {} : { outputPath }),
        };
    }
    return {
        workspaceRoot,
        reportType,
        inputPath: (0, workflow_command_arguments_1.normalizeRequiredText)(args["input_path"], "input_path"),
        ...(outputPath === undefined ? {} : { outputPath }),
    };
}
