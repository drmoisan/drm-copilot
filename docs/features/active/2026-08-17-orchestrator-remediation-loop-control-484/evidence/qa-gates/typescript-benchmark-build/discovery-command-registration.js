"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
exports.registerDiscoveryCommands = registerDiscoveryCommands;
const vscode = __importStar(require("vscode"));
const command_runtime_1 = require("./command-runtime");
const extension_command_helpers_1 = require("./extension-command-helpers");
const mcp_tool_inputs_discovery_1 = require("./mcp-tool-inputs-discovery");
/**
 * Prompts for a required non-empty text value.
 *
 * @returns The trimmed value, or `undefined` when cancelled or left blank.
 */
async function promptForText(title, prompt) {
    const value = await vscode.window.showInputBox({
        title,
        prompt,
        ignoreFocusOut: true,
    });
    if (value === undefined) {
        return undefined;
    }
    const trimmed = value.trim();
    return trimmed.length === 0 ? undefined : trimmed;
}
/** Whether a direct (non-interactive) invocation was supplied. */
function isDirectInvocation(rawArgs) {
    return rawArgs.length > 0;
}
function registerValidateDiscoveryArtifactsCommand(options) {
    const commandId = "drmCopilotExtension.validateDiscoveryArtifacts";
    return vscode.commands.registerCommand(commandId, async (...rawArgs) => {
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => isDirectInvocation(rawArgs)
            ? {
                mode: "direct",
                input: (0, mcp_tool_inputs_discovery_1.resolveValidateDiscoveryArtifactsToolInput)(rawArgs[0], workspaceRoot),
            }
            : { mode: "interactive" });
        if (invocation.mode === "direct") {
            await options.service.validateDiscoveryArtifacts({
                ...invocation.input,
                invocationId: commandId,
            });
            return;
        }
        const artifactType = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Validate Discovery Artifacts", "Choose the artifact type.", mcp_tool_inputs_discovery_1.DISCOVERY_ARTIFACT_TYPES);
        if (!artifactType) {
            return;
        }
        const artifactPath = await promptForText("drm-copilot: Validate Discovery Artifacts", "Enter the artifact path.");
        if (!artifactPath) {
            return;
        }
        await options.service.validateDiscoveryArtifacts({
            workspaceRoot,
            invocationId: commandId,
            artifactType,
            artifactPath,
        });
    });
}
function registerRunDiscoveryInitCommand(options) {
    const commandId = "drmCopilotExtension.runDiscoveryInit";
    return vscode.commands.registerCommand(commandId, async (...rawArgs) => {
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => isDirectInvocation(rawArgs)
            ? {
                mode: "direct",
                input: (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryInitToolInput)(rawArgs[0], workspaceRoot),
            }
            : { mode: "interactive" });
        if (invocation.mode === "direct") {
            await options.service.runDiscoveryInit({
                ...invocation.input,
                invocationId: commandId,
            });
            return;
        }
        const targetDir = await promptForText("drm-copilot: Run Discovery Init", "Enter the target directory to scaffold.");
        if (!targetDir) {
            return;
        }
        await options.service.runDiscoveryInit({
            workspaceRoot,
            invocationId: commandId,
            targetDir,
        });
    });
}
function registerAnalyzerCommand(options, commandId, resolveInput, invoke) {
    return vscode.commands.registerCommand(commandId, async (...rawArgs) => {
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => isDirectInvocation(rawArgs)
            ? { mode: "direct", input: resolveInput(rawArgs[0], workspaceRoot) }
            : { mode: "interactive" });
        if (invocation.mode === "direct") {
            await invoke({ ...invocation.input, invocationId: commandId });
            return;
        }
        // No tool-specific fields are required; run against the resolved workspace.
        await invoke({ workspaceRoot, invocationId: commandId });
    });
}
function registerRunDiscoveryScenarioGenerationCommand(options) {
    const commandId = "drmCopilotExtension.runDiscoveryScenarioGeneration";
    return vscode.commands.registerCommand(commandId, async (...rawArgs) => {
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => isDirectInvocation(rawArgs)
            ? {
                mode: "direct",
                input: (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryScenarioGenerationToolInput)(rawArgs[0], workspaceRoot),
            }
            : { mode: "interactive" });
        if (invocation.mode === "direct") {
            await options.service.runDiscoveryScenarioGeneration({
                ...invocation.input,
                invocationId: commandId,
            });
            return;
        }
        const featureContract = await promptForText("drm-copilot: Run Discovery Scenario Generation", "Enter the feature-contract path.");
        if (!featureContract) {
            return;
        }
        const parityMatrix = await promptForText("drm-copilot: Run Discovery Scenario Generation", "Enter the parity-matrix path.");
        if (!parityMatrix) {
            return;
        }
        const runtimeCharacterization = await promptForText("drm-copilot: Run Discovery Scenario Generation", "Enter the runtime-characterization path.");
        if (!runtimeCharacterization) {
            return;
        }
        await options.service.runDiscoveryScenarioGeneration({
            workspaceRoot,
            invocationId: commandId,
            featureContract,
            parityMatrix,
            runtimeCharacterization,
        });
    });
}
async function promptReportInteractive(options, commandId, workspaceRoot) {
    const reportType = await (0, extension_command_helpers_1.promptForChoice)("drm-copilot: Run Discovery Report", "Choose the report type.", mcp_tool_inputs_discovery_1.DISCOVERY_REPORT_TYPES);
    if (!reportType) {
        return;
    }
    if (reportType === "completion") {
        const coverageInput = await promptForText("drm-copilot: Run Discovery Report", "Enter the coverage-ledger input path.");
        if (!coverageInput) {
            return;
        }
        const parityInput = await promptForText("drm-copilot: Run Discovery Report", "Enter the parity-matrix input path.");
        if (!parityInput) {
            return;
        }
        await options.service.runDiscoveryReport({
            workspaceRoot,
            invocationId: commandId,
            reportType,
            coverageInput,
            parityInput,
        });
        return;
    }
    const inputPath = await promptForText("drm-copilot: Run Discovery Report", "Enter the report input path.");
    if (!inputPath) {
        return;
    }
    await options.service.runDiscoveryReport({
        workspaceRoot,
        invocationId: commandId,
        reportType,
        inputPath,
    });
}
function registerRunDiscoveryReportCommand(options) {
    const commandId = "drmCopilotExtension.runDiscoveryReport";
    return vscode.commands.registerCommand(commandId, async (...rawArgs) => {
        const workspaceRoot = (0, command_runtime_1.getWorkspaceRoot)();
        const invocation = (0, extension_command_helpers_1.resolveWorkflowInvocation)(options.output, commandId, () => isDirectInvocation(rawArgs)
            ? {
                mode: "direct",
                input: (0, mcp_tool_inputs_discovery_1.resolveRunDiscoveryReportToolInput)(rawArgs[0], workspaceRoot),
            }
            : { mode: "interactive" });
        if (invocation.mode === "direct") {
            await options.service.runDiscoveryReport({
                ...invocation.input,
                invocationId: commandId,
            });
            return;
        }
        await promptReportInteractive(options, commandId, workspaceRoot);
    });
}
/**
 * Registers the seven discovery VS Code commands, each a front-end over the
 * shared {@link RepoAutomationCommandRegistrationOptions.service} method with
 * direct-argument and interactive-prompt invocation paths.
 *
 * @param options The shared registration context (context, output, service).
 * @returns The registered command disposables.
 */
function registerDiscoveryCommands(options) {
    return [
        registerValidateDiscoveryArtifactsCommand(options),
        registerRunDiscoveryInitCommand(options),
        registerAnalyzerCommand(options, "drmCopilotExtension.runDiscoveryRepoInventory", mcp_tool_inputs_discovery_1.resolveRunDiscoveryRepoInventoryToolInput, (input) => options.service.runDiscoveryRepoInventory(input)),
        registerAnalyzerCommand(options, "drmCopilotExtension.runDiscoveryDotnetAnalyzer", mcp_tool_inputs_discovery_1.resolveRunDiscoveryDotnetAnalyzerToolInput, (input) => options.service.runDiscoveryDotnetAnalyzer(input)),
        registerAnalyzerCommand(options, "drmCopilotExtension.runDiscoveryVstoAnalyzer", mcp_tool_inputs_discovery_1.resolveRunDiscoveryVstoAnalyzerToolInput, (input) => options.service.runDiscoveryVstoAnalyzer(input)),
        registerRunDiscoveryScenarioGenerationCommand(options),
        registerRunDiscoveryReportCommand(options),
    ];
}
