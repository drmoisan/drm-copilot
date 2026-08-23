"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.executeDiscoveryServiceCall = executeDiscoveryServiceCall;
exports.runValidateDiscoveryArtifacts = runValidateDiscoveryArtifacts;
exports.runDiscoveryInit = runDiscoveryInit;
exports.runDiscoveryRepoInventory = runDiscoveryRepoInventory;
exports.runDiscoveryDotnetAnalyzer = runDiscoveryDotnetAnalyzer;
exports.runDiscoveryVstoAnalyzer = runDiscoveryVstoAnalyzer;
exports.runDiscoveryScenarioGeneration = runDiscoveryScenarioGeneration;
exports.runDiscoveryReport = runDiscoveryReport;
const command_runtime_1 = require("./command-runtime");
const runtime_detection_1 = require("./runtime-detection");
// --- Central mapping table (landed dev.discovery.* console-script entries) ---
/** Module hosting every per-kind `validate_discovery_artifacts` entry. */
const VALIDATE_DISCOVERY_ARTIFACTS_MODULE = "scripts.dev_tools.validate_discovery_artifacts";
/** Per-`artifact_type` entry function within the validate module. */
const VALIDATE_ENTRY_FUNCTION_BY_ARTIFACT_TYPE = {
    profile: "main_profile",
    "feature-contract": "main_feature_contract",
    "coverage-ledger": "main_coverage_ledger",
    "runtime-scenario": "main_runtime_scenario",
    "parity-matrix": "main_parity_matrix",
    "unspecified-behavior": "main_unspecified_behavior",
    "product-decision": "main_product_decision",
    "evidence-reference": "main_evidence_reference",
    all: "main",
};
/** Single `module:function` entry for the init scaffold. */
const DISCOVERY_INIT_ENTRY = {
    module: "scripts.dev_tools.discovery.init_cli",
    functionName: "main",
};
/** Repository-inventory analyzer entry. */
const DISCOVERY_REPO_INVENTORY_ENTRY = {
    module: "scripts.dev_tools.discovery.analyzer.cli",
    functionName: "main",
};
/** .NET / VSTO stack analyzer entries (shared module, distinct functions). */
const DISCOVERY_STACK_ANALYZER_MODULE = "scripts.dev_tools.discovery.analyzer.stack_cli";
const DISCOVERY_DOTNET_ANALYZER_FUNCTION = "main_dotnet";
const DISCOVERY_VSTO_ANALYZER_FUNCTION = "main_vsto";
/** Acceptance-scenario generator entry. */
const DISCOVERY_SCENARIO_GENERATION_ENTRY = {
    module: "scripts.dev_tools.generate_acceptance_scenarios",
    functionName: "main",
};
/** Per-`report_type` report entry (`coverage` / `parity` / `completion`). */
const DISCOVERY_REPORT_ENTRY_BY_REPORT_TYPE = {
    coverage: {
        module: "scripts.dev_tools.discovery.coverage_report",
        functionName: "main",
    },
    parity: {
        module: "scripts.dev_tools.discovery.parity_report",
        functionName: "main",
    },
    completion: {
        module: "scripts.dev_tools.discovery.completion_report",
        functionName: "main",
    },
};
// --- Stdout artifact parsing (landed contracts) ---
function parseWrittenPathsJson(stdout) {
    const trimmed = stdout.trim();
    if (trimmed.length === 0) {
        return undefined;
    }
    let parsed;
    try {
        parsed = JSON.parse(trimmed);
    }
    catch {
        return undefined;
    }
    if (typeof parsed !== "object" || parsed === null || Array.isArray(parsed)) {
        return undefined;
    }
    const writtenPaths = parsed["written_paths"];
    if (!Array.isArray(writtenPaths)) {
        return undefined;
    }
    const paths = writtenPaths.filter((candidate) => typeof candidate === "string");
    return paths.length > 0 ? paths : undefined;
}
function parseOkWrotePath(stdout) {
    const match = /^ok:\s*wrote\s+(.+?)\s*$/im.exec(stdout);
    if (match === null) {
        return undefined;
    }
    const path = match[1]?.trim();
    return path !== undefined && path.length > 0 ? [path] : undefined;
}
function parseDiscoveryArtifacts(mode, stdout) {
    if (mode === "written_paths_json") {
        return parseWrittenPathsJson(stdout);
    }
    if (mode === "ok_wrote") {
        return parseOkWrotePath(stdout);
    }
    return undefined;
}
// --- Generic Python subprocess executor ---
/**
 * Resolves the Python interpreter, spawns the wrapped discovery entry via an
 * interpreter `-c` `module:function` call with `cwd = workspaceRoot`, streams
 * output through the injected sink, parses artifact paths where the landed CLI
 * emits them, and returns the service result. A non-zero exit propagates as
 * `CommandExecutionError` (thrown by {@link runCommandWithOutput}).
 *
 * @param output Output sink for command diagnostics.
 * @param request The fully composed discovery subprocess request.
 * @returns The service execution result with any parsed artifact paths.
 * @throws Error when the interpreter cannot be resolved or the CLI exits non-zero.
 */
async function executeDiscoveryServiceCall(output, request) {
    output.appendLine(`[${request.invocationId}] runtime probe start`);
    let runtime;
    try {
        runtime = (0, runtime_detection_1.detectRuntime)("python", request.workspaceRoot);
    }
    catch (error) {
        output.appendLine(`[${request.invocationId}] runtime probe failure`);
        throw error;
    }
    output.appendLine(`[${request.invocationId}] runtime probe success: ${runtime.executable}`);
    const entryCode = `import sys; from ${request.module} import ${request.functionName}; sys.exit(${request.functionName}())`;
    const args = [...runtime.argsPrefix, "-c", entryCode, ...request.cliArgs];
    output.appendLine(`[${request.invocationId}] command start: ${runtime.executable} -c <${request.module}:${request.functionName}>`);
    let processResult;
    try {
        processResult = await (0, command_runtime_1.runCommandWithOutput)(output, runtime.executable, args, request.workspaceRoot);
    }
    catch (error) {
        output.appendLine(`[${request.invocationId}] command failure`);
        throw error;
    }
    output.appendLine(`[${request.invocationId}] command success`);
    const artifacts = parseDiscoveryArtifacts(request.artifactParse, processResult.stdout);
    return {
        tool: request.tool,
        workspaceRoot: request.workspaceRoot,
        summary: request.summary,
        ...(artifacts === undefined ? {} : { artifacts }),
    };
}
// --- Per-tool CLI-arg composition + execution ---
function resolveInvocationId(input, fallback) {
    return input.invocationId ?? fallback;
}
/** Shared positional-profile + `--output-dir` + `--json` analyzer arg builder. */
function buildAnalyzerCliArgs(input) {
    return [
        ...(input.profilePath === undefined ? [] : [input.profilePath]),
        ...(input.outputDir === undefined ? [] : ["--output-dir", input.outputDir]),
        "--json",
    ];
}
async function runValidateDiscoveryArtifacts(output, input) {
    const functionName = VALIDATE_ENTRY_FUNCTION_BY_ARTIFACT_TYPE[input.artifactType];
    if (functionName === undefined) {
        throw new Error(`Unsupported discovery artifact_type '${input.artifactType}'.`);
    }
    return executeDiscoveryServiceCall(output, {
        tool: "validate_discovery_artifacts",
        module: VALIDATE_DISCOVERY_ARTIFACTS_MODULE,
        functionName,
        cliArgs: [input.artifactPath],
        workspaceRoot: input.workspaceRoot,
        invocationId: resolveInvocationId(input, "validate_discovery_artifacts"),
        summary: `Validated discovery artifact '${input.artifactPath}' as artifact type '${input.artifactType}'.`,
        artifactParse: "none",
    });
}
async function runDiscoveryInit(output, input) {
    const cliArgs = [
        input.targetDir,
        ...(input.templateRoot === undefined
            ? []
            : ["--template-root", input.templateRoot]),
        ...(input.force === true ? ["--force"] : []),
    ];
    return executeDiscoveryServiceCall(output, {
        tool: "run_discovery_init",
        module: DISCOVERY_INIT_ENTRY.module,
        functionName: DISCOVERY_INIT_ENTRY.functionName,
        cliArgs,
        workspaceRoot: input.workspaceRoot,
        invocationId: resolveInvocationId(input, "run_discovery_init"),
        summary: `Initialized the discovery workspace at '${input.targetDir}'.`,
        artifactParse: "none",
    });
}
async function runDiscoveryRepoInventory(output, input) {
    return executeDiscoveryServiceCall(output, {
        tool: "run_discovery_repo_inventory",
        module: DISCOVERY_REPO_INVENTORY_ENTRY.module,
        functionName: DISCOVERY_REPO_INVENTORY_ENTRY.functionName,
        cliArgs: buildAnalyzerCliArgs(input),
        workspaceRoot: input.workspaceRoot,
        invocationId: resolveInvocationId(input, "run_discovery_repo_inventory"),
        summary: "Generated the repository inventory discovery analysis.",
        artifactParse: "written_paths_json",
    });
}
async function runDiscoveryDotnetAnalyzer(output, input) {
    return executeDiscoveryServiceCall(output, {
        tool: "run_discovery_dotnet_analyzer",
        module: DISCOVERY_STACK_ANALYZER_MODULE,
        functionName: DISCOVERY_DOTNET_ANALYZER_FUNCTION,
        cliArgs: buildAnalyzerCliArgs(input),
        workspaceRoot: input.workspaceRoot,
        invocationId: resolveInvocationId(input, "run_discovery_dotnet_analyzer"),
        summary: "Generated the .NET stack discovery analysis.",
        artifactParse: "written_paths_json",
    });
}
async function runDiscoveryVstoAnalyzer(output, input) {
    return executeDiscoveryServiceCall(output, {
        tool: "run_discovery_vsto_analyzer",
        module: DISCOVERY_STACK_ANALYZER_MODULE,
        functionName: DISCOVERY_VSTO_ANALYZER_FUNCTION,
        cliArgs: buildAnalyzerCliArgs(input),
        workspaceRoot: input.workspaceRoot,
        invocationId: resolveInvocationId(input, "run_discovery_vsto_analyzer"),
        summary: "Generated the VSTO stack discovery analysis.",
        artifactParse: "written_paths_json",
    });
}
async function runDiscoveryScenarioGeneration(output, input) {
    const cliArgs = [
        "--feature-contract",
        input.featureContract,
        "--parity-matrix",
        input.parityMatrix,
        "--runtime-characterization",
        input.runtimeCharacterization,
        ...(input.outputPath === undefined ? [] : ["--output", input.outputPath]),
        ...(input.check === true ? ["--check"] : []),
    ];
    return executeDiscoveryServiceCall(output, {
        tool: "run_discovery_scenario_generation",
        module: DISCOVERY_SCENARIO_GENERATION_ENTRY.module,
        functionName: DISCOVERY_SCENARIO_GENERATION_ENTRY.functionName,
        cliArgs,
        workspaceRoot: input.workspaceRoot,
        invocationId: resolveInvocationId(input, "run_discovery_scenario_generation"),
        summary: "Generated discovery acceptance scenarios.",
        artifactParse: "ok_wrote",
    });
}
async function runDiscoveryReport(output, input) {
    const entry = DISCOVERY_REPORT_ENTRY_BY_REPORT_TYPE[input.reportType];
    if (entry === undefined) {
        throw new Error(`Unsupported discovery report_type '${input.reportType}'.`);
    }
    const cliArgs = input.reportType === "completion"
        ? [
            "--coverage-input",
            input.coverageInput ?? "",
            "--parity-input",
            input.parityInput ?? "",
            ...(input.outputPath === undefined
                ? []
                : ["--output", input.outputPath]),
        ]
        : [
            "--input",
            input.inputPath ?? "",
            ...(input.outputPath === undefined
                ? []
                : ["--output", input.outputPath]),
        ];
    return executeDiscoveryServiceCall(output, {
        tool: "run_discovery_report",
        module: entry.module,
        functionName: entry.functionName,
        cliArgs,
        workspaceRoot: input.workspaceRoot,
        invocationId: resolveInvocationId(input, "run_discovery_report"),
        summary: `Generated the '${input.reportType}' discovery report.`,
        artifactParse: "none",
    });
}
